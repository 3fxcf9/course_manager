module main

import os
import json
import md_parser { parse_metadata }

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
	date        ?string
	description ?string
	keywords    ?[]string
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
		filename := (os.ls(chapter_absolute_path) or { [] }).filter(it.ends_with('.md')
			|| it.ends_with('.mde'))[0]!
		file_content := os.read_lines(os.join_path_single(chapter_absolute_path, filename))!
		chap_title := file_content[0]!.all_after_first('# ')
		metadata, _ := parse_metadata(file_content.join('\n'))

		chapters << ChapterMeta{
			name:        chap_title
			date:        if 'date' in metadata { metadata['date'] } else { none }
			description: if 'description' in metadata { metadata['description'] } else { none }
			keywords:    if 'keywords' in metadata {
				metadata['keywords'].split_by_space()
			} else {
				none
			}
			cover:       if os.exists(os.join_path_single(chapter_absolute_path, 'cover.svg')) {
				'cover.svg'
			} else {
				none
			}
			path:        os.join_path_single(subject_path, dir)
			filename:    filename
		}
	}

	return chapters
}

fn ask_for_path(config ConfigFile) !(SubjectMeta, ChapterMeta) {
	subjects := parse_subjects(config.general.path)!

	subject_options := subjects.map("<b>${it.name:-40}</b><span size='smaller'>${it.short}</span>")

	i, _ := rofi('Select subject', subject_options, ['-markup-rows'], true) or { exit(1) }

	selected_subject := subjects[i]

	// Chapters
	chapters := parse_chapters(config.general.path, selected_subject.path)!

	ellipsis := fn (s string, n int) string {
		if s.runes().len <= n {
			return s
		}
		return s.substr(0, n - 3) + '...'
	}

	chapter_options := chapters.map("<b>${ellipsis(it.name, 38):-40}</b><span size='smaller'>${it.date or {
		''
	}}</span>")

	j, _ := rofi('Select subject', chapter_options, ['-markup-rows'], true) or { exit(1) }

	return selected_subject, chapters[j]
}

fn content_type(path string) string {
	ext := os.file_ext(path).to_lower()
	dump(ext)
	return match ext {
		'.html' { 'text/html; charset=utf-8' }
		'.css' { 'text/css; charset=utf-8' }
		'.js' { 'application/javascript; charset=utf-8' }
		'.json' { 'application/json; charset=utf-8' }
		'.png' { 'image/png' }
		'.jpg', '.jpeg' { 'image/jpeg' }
		'.svg' { 'image/svg+xml' }
		'.woff' { 'font/woff' }
		'.woff2' { 'font/woff2' }
		else { 'application/octet-stream' }
	}
}
