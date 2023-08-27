module lexer

import lexer.token { Token, TokenType }

pub struct Lexer {
	input string
mut:
	position      int
	read_position int
	ch            rune
}

pub fn (l Lexer) new(input string) Lexer {
    mut lex := Lexer { input: input }
    lex.read_char()
    return lex
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

fn is_letter(ch rune) bool {
	return match ch {
		`a`...`z` { true }
		`A`...`Z` { true }
		else { false }
	}
}

fn (mut lex Lexer) read_number() string {
	position := lex.position
	for is_digit(lex.ch) {
		lex.read_char()
	}
	return lex.input[position..lex.position]
}

fn is_digit(ch rune) bool {
	return match ch {
		`0`...`9` { true }
		else { false }
	}
}

pub fn (mut lex Lexer) skip_whitespace() {
	for lex.ch.str().is_blank() {
		lex.read_char()
	}
}

pub fn (mut lex Lexer) next_token() TokenType {
	lex.skip_whitespace()
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
				tok_type := match literal {
					'fn' { Token.function }
					'let' { Token.let }
					else { Token.ident }
				}
				return TokenType{
					value: literal
					@type: tok_type
				}
			} else if is_digit(lex.ch) {
				number := lex.read_number()
				return TokenType{
					value: number
					@type: .integer
				}
			} else {
				TokenType{
					value: lex.ch.str()
					@type: .illegal
				}
			}
		}
	}
    lex.read_char()
	return tok
}
