module main

import os
import toml
import cli { Command }

struct ConfigFile {
mut:
	general struct {
    browser string
	mut:
		path string
	}
	server struct {
		port int
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
	subjects := parse_subjects(config.general.path)!

	subject_options := subjects.map("<b>${it.name:-40}</b><span size='smaller'>${it.short}</span>")

	i, _ := rofi('Select subject', subject_options, ['-markup-rows'], true) or { return }

	selected_subject := subjects[i]


  // Chapters
	chapters := parse_chapters(config.general.path, selected_subject.path)!


	ellipsis:=fn (s string, n int) string{
    if s.runes().len <= n {
      return s
    }
    return s.substr(0,n-3) + "..."
  }

	chapter_options := chapters.map("<b>${ellipsis(it.name, 38):-40}</b><span size='smaller'>${it.date or {""}}</span>")

	j, _ := rofi('Select subject', chapter_options, ['-markup-rows'], true) or { return }

  selected_chapter := chapters[j]

  filepath := os.join_path(selected_chapter.path, selected_chapter.filename)

  os.execute("${config.general.browser} http://localhost:${config.server.port}/live?path=${filepath}")
}
