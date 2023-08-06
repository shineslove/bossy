module main

enum TokenType {
	assign
	plus
	lparen
	rparen
	lbrace
	rbrace
	comma
	semicolon
	eof
}

struct Token {
	char_type    TokenType
	char_literal string
}

fn test_next_token() {
	input := '=+(){},;'
	tests := [
		Token{.assign, '='},
		Token{.plus, '+'},
		Token{.lparen, '('},
		Token{.rparen, ')'},
		Token{.lbrace, '{'},
		Token{.rbrace, '}'},
		Token{.comma, ','},
		Token{.semicolon, ';'},
		Token{.eof, ''},
	]
	lex := Lexer(input)
	for typ in tests {
		tok := lex.next_token()
		assert tok.char_type == typ.char_type, 'test for type failed'
		tok.char_literal == typ.char_literal, 'test for literal failed'
	}
}
