module main
import lexer { Lexer }

fn main() {
	input := '=+(){},;'
	mut l := Lexer{
		input: input
	}
	l.read_char()
	println(l)
}
