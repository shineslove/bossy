module main

import lexer
import token as t

fn test_next_token() {
	input := '=+(){},;'
	tests := [
		t.Token.assign,
		t.Token.plus,
		t.Token.lparen,
		t.Token.rparen,
		t.Token.lbrace,
		t.Token.rbrace,
		t.Token.comma,
		t.Token.semicolon,
		t.Token.eof,
	]
	mut lex := lexer.Lexer{
		input: input
	}
	for typ in tests {
		tok := lex.next_token()
		assert tok == typ , 'test for type failed'
	}
}
