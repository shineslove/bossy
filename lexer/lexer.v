module lexer

import lexer.token { Token, TokenType }

pub struct Lexer {
	input string
mut:
	position      int
	read_position int
	ch            rune
}

pub fn Lexer.new(input string) Lexer {
	mut lex := Lexer{
		input: input
	}
	lex.read_char()
	return lex
}

fn (mut lex Lexer) read_char() {
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

fn (mut lex Lexer) skip_whitespace() {
	for lex.ch.str().is_blank() {
		lex.read_char()
	}
}

fn (lex Lexer) peek_char() ?rune {
	if !(lex.read_position >= lex.input.len) {
		return lex.input[lex.read_position]
	}
	return none
}

fn (mut lex Lexer) next() ?TokenType {
	tok := lex.next_token()
	if tok.@type == .eof {
		return none
	}
	return tok
}

pub fn (mut lex Lexer) next_token() TokenType {
	lex.skip_whitespace()
	tok := match lex.ch {
		`=` {
			next_char := lex.peek_char() or { ` ` }
			if next_char == `=` {
				line := lex.ch
				lex.read_char()
				literal := '${line}${lex.ch}'
				TokenType{
					value: literal
					@type: .eq
				}
			} else {
				TokenType{
					value: lex.ch.str()
					@type: .assign
				}
			}
		}
		`;` {
			TokenType{
				value: lex.ch.str()
				@type: .semicolon
			}
		}
		`(` {
			TokenType{
				value: lex.ch.str()
				@type: .lparen
			}
		}
		`)` {
			TokenType{
				value: lex.ch.str()
				@type: .rparen
			}
		}
		`,` {
			TokenType{
				value: lex.ch.str()
				@type: .comma
			}
		}
		`+` {
			TokenType{
				value: lex.ch.str()
				@type: .plus
			}
		}
		`-` {
			TokenType{
				value: lex.ch.str()
				@type: .minus
			}
		}
		`!` {
			next_char := lex.peek_char() or { ` ` }
			if next_char == `=` {
				line := lex.ch
				lex.read_char()
				literal := '${line}${lex.ch}'
				TokenType{
					value: literal
					@type: .not_eq
				}
			} else {
				TokenType{
					value: lex.ch.str()
					@type: .bang
				}
			}
		}
		`/` {
			TokenType{
				value: lex.ch.str()
				@type: .slash
			}
		}
		`*` {
			TokenType{
				value: lex.ch.str()
				@type: .asterisk
			}
		}
		`<` {
			TokenType{
				value: lex.ch.str()
				@type: .lt
			}
		}
		`>` {
			TokenType{
				value: lex.ch.str()
				@type: .gt
			}
		}
		`{` {
			TokenType{
				value: lex.ch.str()
				@type: .lbrace
			}
		}
		`}` {
			TokenType{
				value: lex.ch.str()
				@type: .rbrace
			}
		}
		0 {
			TokenType{
				value: lex.ch.str()
				@type: .eof
			}
		}
		else {
			if is_letter(lex.ch) {
				literal := lex.read_ident()
				tok_type := match literal {
					'fn' { Token.function }
					'let' { Token.let }
					'true' { Token.@true }
					'false' { Token.@false }
					'if' { Token.@if }
					'else' { Token.@else }
					'return' { Token.@return }
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
