module repl

import readline
import strings
import lexer
import parser
import evaluator

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
		evaluated := evaluator.eval(prog)
		if evaluated != none {
			println('${evaluated.inspect()}\n')
		}
	}
}

fn print_parser_errors(errors []string) {
	err_msg := 'Woops! We ran into some monkey business here!' 
	// creating enough monkeys for length of string
	println(strings.repeat_string('🐒', err_msg.len / 2))
	println(err_msg)
	println(' parser errors:')
	for e in errors {
		println('\t${e}\n')
	}
}
