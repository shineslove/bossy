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
    println('char is: ${lex.ch.str().is_blank()}')
	for lex.ch.str().is_blank() {
		lex.read_char()
	}
}

pub fn (mut lex Lexer) next_token() TokenType {
	lex.skip_whitespace()
	tok := match lex.ch {
		`=` {
            println('detected: ${lex.ch}')
			TokenType{
				value: '='
				@type: .assign
			}
		}
		`;` {
            println('detected: ${lex.ch}')
			TokenType{
				value: ';'
				@type: .semicolon
			}
		}
		`(` {
            println('detected: ${lex.ch}')
			TokenType{
				value: '('
				@type: .lparen
			}
		}
		`)` {
            println('detected: ${lex.ch}')
			TokenType{
				value: ')'
				@type: .rparen
			}
		}
		`,` {
            println('detected: ${lex.ch}')
			TokenType{
				value: ','
				@type: .comma
			}
		}
		`+` {
            println('detected: ${lex.ch}')
			TokenType{
				value: '+'
				@type: .plus
			}
		}
		`{` {
            println('detected: ${lex.ch}')
			TokenType{
				value: '{'
				@type: .lbrace
			}
		}
		`}` {
            println('detected: ${lex.ch}')
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
				println('letter is: ${lex.ch}')
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
				println('digit is: ${lex.ch}')
				number := lex.read_number()
				return TokenType{
					value: number
					@type: .integer
				}
			} else {
				println('illegal is: ${lex.ch}')
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
