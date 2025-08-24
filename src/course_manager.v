module main

import os
import toml
import cli { Command }
import net.urllib

struct ConfigFile {
mut:
	general struct {
		browser string
	mut:
		path string
	}
	server  struct {
		port int
	}
	editor  struct {
		command string
		args    []string
	}
}

fn main() {
	// Read config file
	config_file_path := os.join_path_single(os.config_dir() or {
		panic('Unable to locate config dir')
	}, 'course_manager/config.toml')
	mut config := toml.decode[ConfigFile](os.read_file(config_file_path) or {
		panic('Error reading config file')
	}) or { panic('Invalid config file') }

	config.general.path = os.expand_tilde_to_home(config.general.path)

	mut app := Command{
		name:        'course-manager'
		description: 'TODO'
		commands:    [
			Command{
				name:    'web'
				execute: fn [config] (cmd Command) ! {
					web(cmd, config)!
				}
			},
			Command{
				name:    'live'
				execute: fn [config] (cmd Command) ! {
					live(cmd, config)!
				}
			},
			Command{
				name:    'open'
				execute: fn [config] (cmd Command) ! {
					open(cmd, config)!
				}
			},
			Command{
				name:    'edit'
				execute: fn [config] (cmd Command) ! {
					edit(cmd, config)!
				}
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

fn live(c Command, config ConfigFile) ! {
	_, selected_chapter := ask_for_path(config)!
	filepath := os.join_path(selected_chapter.path, selected_chapter.filename)

	path := os.find_abs_path_of_executable(config.general.browser)!
	mut p := os.new_process(path)
	p.set_args(['http://localhost:${config.server.port}/live?path=${filepath}'])
	p.run()
}

fn open(c Command, config ConfigFile) ! {
	selected_subject, selected_chapter := ask_for_path(config)!

	path := os.find_abs_path_of_executable(config.general.browser)!
	mut p := os.new_process(path)
	p.set_args([
		'http://localhost:${config.server.port}/subject/${selected_subject.short}/chapter/${urllib.path_escape(selected_chapter.name)}/view',
	])
	p.run()
}

fn edit(c Command, config ConfigFile) ! {
	_, selected_chapter := ask_for_path(config)!
	filepath := os.join_path(selected_chapter.path, selected_chapter.filename)

	// Browser
	path := os.find_abs_path_of_executable(config.general.browser)!
	mut p := os.new_process(path)
	p.set_args(['http://localhost:${config.server.port}/live?path=${filepath}'])
	p.run()

	// Editor
	editor_path := os.find_abs_path_of_executable(config.editor.command)!
	mut p2 := os.new_process(editor_path)
	mut args := config.editor.args.clone()
	args << [os.join_path_single(config.general.path, filepath)]
	p2.set_args(args)
	p2.run()
}
