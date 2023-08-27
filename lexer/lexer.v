module lexer

import lexer.token { TokenType }

pub struct Lexer {
	input string
mut:
	position      int
	read_position int
	ch            byte
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

fn (mut lex Lexer) read_ident() string {
	position := lex.position
	for is_letter(lex.ch) {
		lex.read_char()
	}
	return lex.input[position..lex.position]
}

fn is_letter(ch byte) bool {
	return match ch {
		`a`...`z` { true }
		`A`...`Z` { true }
		else { false }
	}
}

pub fn (mut lex Lexer) next_token() TokenType {
	lex.read_char()
	tok := match lex.ch {
		`=` {
			TokenType{
				value: '='
				@type: .assign
			}
		}
		`;` {
			TokenType{
				value: ';'
				@type: .semicolon
			}
		}
		`(` {
			TokenType{
				value: '('
				@type: .lparen
			}
		}
		`)` {
			TokenType{
				value: ')'
				@type: .rparen
			}
		}
		`,` {
			TokenType{
				value: ','
				@type: .comma
			}
		}
		`+` {
			TokenType{
				value: '+'
				@type: .plus
			}
		}
		`{` {
			TokenType{
				value: '{'
				@type: .lbrace
			}
		}
		`}` {
			TokenType{
				value: '}'
				@type: .rbrace
			}
		}
		0 {
			TokenType{
				value: ''
				@type: .eof
			}
		}
		else {
			if is_letter(lex.ch) {
				literal := lex.read_ident()
				TokenType{
					value: literal
					@type: .ident
				}
			} else {
				TokenType{
					value: lex.ch.str()
					@type: .illegal
				}
			}
		}
	}
	return tok
}
