module main

import os
import repl

fn main() {
	user := os.getenv('USER')
	println('Hello there dear: ${user}')
	println('Try out some commands boi!')
	repl.start()
}
