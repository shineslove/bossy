module main

import lexer { Lexer }

fn main() {
	input := '=+(){},;'
	mut lex := Lexer{}
	l := lex.new(input)
    for tok in l {
        println(tok)
    }
}
