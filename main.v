module main

import os
import repl

fn main() {
	user := os.getenv('USER')
	if os.args.len == 1 {
		println('Hello there dear: ${user}')
		println('Try out some commands boi!')
		repl.start()
	} else if os.args.len == 2 {
		filename := os.args[1]
		if !filename.ends_with('monkey') {
			eprintln('this is only for monkey files')
			return
		}
		repl.evaluate_from_file(filename)
	}
}
