module main

import json
import veb
import os
import cli { Command }
import md_parser { md_to_html }

pub struct Context {
	veb.Context
}

pub struct App {
	veb.StaticHandler
	root      string
	root_meta RootMeta
}

fn main() {
	mut app := Command{
		name:        'course-manager'
		description: 'TODO'
		commands:    [
			Command{
				name:          'web'
				usage:         '<path>'
				required_args: 1
				execute:       web
			},
			// Command{
			// 	name:          'edit'
			// 	usage:         '<path>'
			// 	required_args: 1
			// 	execute:       edit
			// 	flags:         [
			// 		Flag{
			// 			flag:        .string
			// 			name:        'name'
			// 			description: 'The figure name (same as the filename without hyphen)'
			// 		},
			// 	]
			// },
		]
	}
	app.setup()
	app.parse(os.args)
}

struct RootMeta {
	name string
	date string
}

struct SubjectMeta {
	name    string
	short   string
	teacher string
mut:
	cover ?string @[json: '-']
	path  string  @[json: '-']
}

struct ChapterMeta {
	name        string
	date        string
	description ?string
	cover       ?string
	path        string
	filename    string
}

fn parse_subjects(root_path string) ![]SubjectMeta {
	directories := (os.ls(root_path) or { [] }).filter(os.is_dir(os.join_path(root_path,
		it)))

	mut subjects := []SubjectMeta{}
	for dir in directories {
		meta_file_path := os.join_path(root_path, dir, 'info.json')

		info_json := os.read_file(meta_file_path) or { continue }
		mut info_decoded := json.decode(SubjectMeta, info_json)!
		if os.exists(os.join_path(root_path, dir, 'cover.svg')) {
			info_decoded.cover = 'cover.svg'
		}
		info_decoded.path = dir
		subjects << info_decoded
	}

	return subjects
}

fn parse_chapters(root_path string, subject_path string) ![]ChapterMeta {
	directories := (os.ls(os.join_path_single(root_path, subject_path)) or { [] }).filter(os.is_dir(os.join_path(root_path,
		subject_path, it)))

	mut chapters := []ChapterMeta{}
	for dir in directories {
		// Parse title and in-file metadata
		chapter_absolute_path := os.join_path(root_path, subject_path, dir)
		content_file := (os.ls(chapter_absolute_path) or { [] }).filter(it.ends_with('.md')
			|| it.ends_with('.mde'))[0]!
		chap_title := os.read_lines(os.join_path_single(chapter_absolute_path, content_file))![0]!.all_after_first('# ')
		// TODO: Parse in-file metadata

		chapters << ChapterMeta{
			name:        chap_title
			date:        'FA/KE/DATE' // TODO: Use md date (add to md parser)
			description: 'Briefly describe what is in this chapter, to be retrieved from the md file.'
			cover:       if os.exists(os.join_path_single(chapter_absolute_path, 'cover.svg')) {
				'cover.svg'
			} else {
				none
			}
			path:        os.join_path_single(subject_path, dir)
			filename:    content_file
		}
	}

	return chapters
}

fn web(cmd Command) ! {
	figure_folder_path := cmd.args[0]

	if !os.exists(figure_folder_path) {
		error('Folder does not exists')
	}

	// Root metadata
	meta_file_path := os.join_path_single(figure_folder_path, 'info.json')
	info_json := os.read_file(meta_file_path)!
	root_meta := json.decode(RootMeta, info_json)!

	// Start the web server
	mut app := &App{
		root:      figure_folder_path
		root_meta: root_meta
	}
	app.static_mime_types['.md'] = 'txt/plain'
	app.static_mime_types['.mde'] = 'txt/plain'
	app.mount_static_folder_at(figure_folder_path, '/raw')!
	app.mount_static_folder_at('static', '/static')!
	veb.run[App, Context](mut app, 8081)
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

@['/course/:path...']
pub fn (app &App) course(mut ctx Context, path string) veb.Result {
	requested_path := os.join_path_single(app.root, path)

	if !os.exists(requested_path) {
		return ctx.not_found()
	}

	if path.ends_with('.md') || path.ends_with('.mde') {
		content := os.read_file(requested_path) or { return ctx.not_found() }
		chap_title := content.all_before('\n').all_after_first('# ')

		current_path := os.abs_path('')
		os.chdir(os.dir(requested_path)) or { return ctx.request_error('Error') }
		html := md_to_html(content)
		os.chdir(current_path) or { return ctx.request_error('Error') }
		return ctx.html($tmpl('templates/course.html'))
	}

	return ctx.file(requested_path)
}
