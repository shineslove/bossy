module lexer

import token { Token }

pub struct Lexer {
	input string
mut:
	position      int
	read_position int
	ch            byte
}

pub fn (mut lex Lexer) next_token() Token {
	lex.read_char()
	tok := match lex.ch {
		`=` {
			Token.assign
		}
		`;` {
			Token.semicolon
		}
		`(` {
			Token.lparen
		}
		`)` {
			Token.rparen
		}
		`,` {
			Token.comma
		}
		`+` {
			Token.plus
		}
		`{` {
			Token.lbrace
		}
		`}` {
			Token.rbrace
		}
		0 {
			Token.eof
		}
		else {
			Token.illegal
		}
	}
	return tok
}

pub fn (mut lex Lexer) read_char() {
	if lex.read_position >= lex.input.len {
		lex.ch = 0
	} else {
		lex.ch = lex.input[lex.read_position]
	}
	lex.position = lex.read_position
	lex.read_position += 1
}
