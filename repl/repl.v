module repl

import readline
import lexer
import parser

// R.P.P.L for outputting 'Monkey'
pub fn start() {
	prompt := '>> '
	mut reader := readline.Readline{}
	for {
		input := reader.read_line(prompt) or { '' }
		if input.is_blank() {
			break
		}
		l := lexer.Lexer.new(input)
		mut par := parser.Parser.new(l)
		prog := par.parse_program()
		if par.errors().len != 0 {
			print_parser_errors(par.errors())
			continue
		}
		println('${prog}\n')
	}
}

fn print_parser_errors(errors []string) {
	println('🐒🐒🐒🐒')
	println('Woops! We ran into some monkey business here!')
	println(' parser errors:')
	for e in errors {
		println('\t${e}\n')
	}
}
