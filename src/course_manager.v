module main

import json
import veb
import os
import cli { Command }

pub struct Context {
	veb.Context
}

pub struct App {
	veb.StaticHandler
	root_meta RootMeta
	subjects  []SubjectMeta
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

fn parse_subjects(root_path string) ![]SubjectMeta {
	directories := (os.ls(root_path) or { [] }).filter(os.is_dir(os.join_path(root_path,
		it)))

	mut subjects := []SubjectMeta{}
	for dir in directories {
		meta_file_path := os.join_path(root_path, dir, 'info.json')
		info_json := os.read_file(meta_file_path)!
		mut info_decoded := json.decode(SubjectMeta, info_json)!
		if os.exists(os.join_path(root_path, dir, 'cover.svg')) {
			info_decoded.cover = 'cover.svg'
		}
		info_decoded.path = dir
		subjects << info_decoded
	}

	return subjects
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

	// Sujbect list
	subjects := parse_subjects(figure_folder_path)!

	// Start the web server
	mut app := &App{
		root_meta: root_meta
		subjects:  subjects
	}
	app.static_mime_types['.md'] = 'txt/plain'
	app.static_mime_types['.mde'] = 'txt/plain'
	app.mount_static_folder_at(figure_folder_path, '/raw')!
	veb.run[App, Context](mut app, 8081)
}

pub fn (app &App) index(mut ctx Context) veb.Result {
	return $veb.html()
}
