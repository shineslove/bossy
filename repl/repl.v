module repl

import readline
import lexer

//R.E.P.L for outputting 'Monkey'
pub fn start() {
	prompt := '>> '
	mut reader := readline.Readline{}
	for {
		input := reader.read_line(prompt) or { '' }
		if input.is_blank() {
			break
		}
		l := lexer.Lexer.new(input)
		for tok in l {
			println(tok)
		}
	}
}
