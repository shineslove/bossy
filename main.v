module main

import lexer { Lexer }

fn main() {
	input := '=+(){},;'
	mut lex := Lexer{}
	l := lex.new(input)
	println(l)
}
