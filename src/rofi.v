module main

import os

fn rofi(prompt string, options []string, rofi_args ?[]string, fuzzy bool) ?(int, string) {
	optionstr := options.map(it.replace('\n', ' ')).join('\n')

	mut args := '-dmenu -sort -sorting-method fzf -theme-str \'entry {placeholder:"${prompt}";}\' -format s -i'
	if fuzzy {
		args += '-matching fuzzy'
	}
	if a := rofi_args {
		args += ' ' + a.join(' ')
	}

	result := os.execute('echo "${optionstr}" | rofi ${args} 2>/dev/null')
	selected := result.output.trim_space()

	mut index := -1
	for i, opt in options {
		if opt.trim_space() == selected {
			index = i
			break
		}
	}

	if index > -1 {
		return index, selected
	}
	return none
}
