module main

import veb
import veb.sse
import os
import json
import ttytm.vvatch as w
import md_parser { md_to_html }
import cli { Command }

pub struct Context {
	veb.Context
}

pub struct App {
	veb.StaticHandler
	root      string
	root_meta RootMeta
mut:
	file_to_watch string
	active_conn   &sse.SSEConnection = unsafe { nil }
	watch_id      w.WatchID
}

fn web(cmd Command, config ConfigFile) ! {
	root_path := config.general.path

	if !os.exists(root_path) {
		error('Folder does not exists')
	}

	// Root metadata
	meta_file_path := os.join_path_single(root_path, 'info.json')
	info_json := os.read_file(meta_file_path)!
	root_meta := json.decode(RootMeta, info_json)!

	// Start the web server
	mut app := &App{
		root:      root_path
		root_meta: root_meta
	}
	app.static_mime_types['.md'] = 'txt/plain'
	app.static_mime_types['.mde'] = 'txt/plain'
	app.static_mime_types['.sample'] = 'txt/plain' // Git
	app.static_mime_types['.pack'] = 'txt/plain' // Git
	app.static_mime_types['.idx'] = 'txt/plain' // Git
	app.static_mime_types['.rev'] = 'txt/plain' // Git
	// FIXME: Mimetype
	app.static_mime_types['.ml'] = 'txt/plain' // OCaml
	app.static_mime_types['.cmi'] = 'txt/plain' // OCaml
	app.static_mime_types['.cmo'] = 'txt/plain' // OCaml
	app.static_mime_types['.out'] = 'txt/plain' // OCaml
	app.mount_static_folder_at(root_path, '/raw')!

	// app.mount_static_folder_at('static', '/static')!
	veb.run[App, Context](mut app, config.server.port)
}

@['/static/:requested_path...']
pub fn (app &App) assets(mut ctx Context, requested_path string) veb.Result {
	if requested_path !in embedded_files {
		return ctx.not_found()
	}
	data := embedded_files[requested_path]
	ctx.set_content_type(content_type(requested_path))
	return ctx.ok(data)
}

@['/']
pub fn (app &App) index(mut ctx Context) veb.Result {
	subjects := parse_subjects(app.root) or { return ctx.request_error('Error') }
	return $veb.html()
}

@['/subject/:short']
pub fn (app &App) subject(mut ctx Context, requested_subject string) veb.Result {
	subjects := parse_subjects(app.root) or { return ctx.request_error('Error parsing subjects') }
	subject := subjects.filter(it.short == requested_subject)[0] or {
		return ctx.request_error('Error: no such subject found')
	}
	chapters := parse_chapters(app.root, subject.path) or {
		return ctx.request_error('Error parsing chapters')
	}

	return $veb.html()
}

@['/subject/:short/chapter/:name/view']
pub fn (app &App) course(mut ctx Context, subject_short string, chapter_name string) veb.Result {
	subjects := parse_subjects(app.root) or { return ctx.request_error('Error parsing subjects') }
	subject := subjects.filter(it.short == subject_short)[0] or {
		return ctx.request_error('Error: no such subject found')
	}
	chapters := parse_chapters(app.root, subject.path) or {
		return ctx.request_error('Error parsing chapters')
	}
	chapter := chapters.filter(it.name == chapter_name)[0] or {
		return ctx.request_error('Error: no such chapter found')
	}

	first_file := os.join_path(app.root, chapter.path, chapter.files[0])
	first_content := os.read_file(first_file) or { return ctx.not_found() }
	chap_title := first_content.all_before('\n').all_after_first('# ')

	mut content := ''

	for i, file in chapter.files {
		if i > 0 {
			content += '\n<hr class="new-file" data-filepath="${os.join_path_single(chapter.path,
				file)}">\n'
		}
		content += os.read_file(os.join_path(app.root, chapter.path, file)) or {
			return ctx.not_found()
		}
	}

	// Change directory for correct figure files detection, the parser should do the job by using absolute paths
	current_path := os.abs_path('')
	os.chdir(os.dir(first_file)) or { return ctx.request_error('Error') }
	_, html := md_to_html(content)
	os.chdir(current_path) or { return ctx.request_error('Error') }

	return ctx.html($tmpl('templates/course.html')) // Hack to send unescaped html
}

@['/subject/:short/chapter/:name/figures/:figure_path...']
pub fn (app &App) figure(mut ctx Context, subject_short string, chapter_name string, figure_path string) veb.Result {
	subjects := parse_subjects(app.root) or { return ctx.request_error('Error parsing subjects') }
	subject := subjects.filter(it.short == subject_short)[0] or {
		return ctx.request_error('Error: no such subject found')
	}
	chapters := parse_chapters(app.root, subject.path) or {
		return ctx.request_error('Error parsing chapters')
	}
	chapter := chapters.filter(it.name == chapter_name)[0] or {
		return ctx.request_error('Error: no such chapter found')
	}

	filepath := os.join_path(app.root, chapter.path, 'figures', figure_path)
	if !os.exists(filepath) {
		return ctx.not_found()
	}

	return ctx.file(filepath)
}

@['/live']
pub fn (mut app App) live(mut ctx Context, subject_short string, chapter_name string) veb.Result {
	if ctx.query['path'].is_blank() {
		return ctx.request_error('Missing "path" parameter')
	}
	file_path := os.join_path_single(app.root, ctx.query['path'] or { '' })
	if !os.exists(file_path) {
		return ctx.request_error('Invalid "path" parameter')
	}

	// Stop any previous watcher
	if app.watch_id != 0 {
		app.watch_id.unwatch()
		app.watch_id = 0
	}

	app.file_to_watch = file_path
	watch_dir := os.dir(file_path)

	app.watch_id = w.watch(watch_dir, watch_callback, w.WatchFlag.recursive, app) or {
		eprintln('Failed to start watcher: ${err}')
		return ctx.text('Failed to start watcher')
	}

	// println('Now watching: ${file_path}')

	return ctx.html($embed_file('templates/live.html').to_string())
}

@['/sse']
pub fn (mut app App) sse(mut ctx Context) veb.Result {
	// Start SSE connection
	ctx.takeover_conn()
	mut conn := sse.start_connection(mut ctx.Context)
	app.active_conn = conn

	// Send initial content
	app.broadcast_file_content()

	return veb.no_result()
}

fn (mut app App) broadcast_file_content() {
	if app.active_conn == unsafe { nil } || app.file_to_watch == '' {
		return
	}
	content := os.read_file(app.file_to_watch) or {
		println('Error reading ${app.file_to_watch}: ${err}')
		return
	}

	current_path := os.abs_path('')
	os.chdir(os.dir(app.file_to_watch)) or { return }
	_, html := md_to_html(content) // TODO: Send metadata
	os.chdir(current_path) or { return }

	app.active_conn.send_message(data: html.replace('\n', '\ndata: ')) or {
		// println('SSE connection lost, stopping watcher')
		if app.watch_id != 0 {
			app.watch_id.unwatch()
			app.watch_id = 0
		}
		app.active_conn = unsafe { nil }
	}
}

fn watch_callback(watch_id w.WatchID, action w.Action, root_path string, file_path string, old_file_path string, mut app App) {
	// Only react if it's the file we're watching
	// if os.real_path(file_path) != os.real_path(app.file_to_watch) {
	// 	return
	// }
	if action in [.modify, .create] {
		app.broadcast_file_content()
	}
}

@['/figures/:figure_path...']
pub fn (app &App) figure_live(mut ctx Context, figure_path string) veb.Result {
	filepath := os.join_path(os.dir(app.file_to_watch), 'figures', figure_path)

	if !os.exists(filepath) {
		return ctx.not_found()
	}

	return ctx.file(filepath)
}
