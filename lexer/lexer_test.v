module main

import lexer
import token as t

fn test_next_token() {
	input := 'let five = 5;
    let ten = 10;
    let add = fn(x,y) {
        x + y;
    };
    let result = add(five,ten);
    '
	tests := [
        t.Token.let,
        t.Token.ident,
		t.Token.assign,
		t.Token.integer,
		t.Token.semicolon,
		t.Token.let,
		t.Token.ident,
		t.Token.assign,
		t.Token.integer,
		t.Token.semicolon,
		t.Token.let,
		t.Token.ident,
		t.Token.assign,
		t.Token.function,
		t.Token.lparen,
		t.Token.ident,
		t.Token.comma,
		t.Token.ident,
		t.Token.rparen,
		t.Token.lbrace,
		t.Token.ident,
		t.Token.plus,
		t.Token.ident,
		t.Token.semicolon,
		t.Token.rbrace,
		t.Token.semicolon,
		t.Token.let,
		t.Token.ident,
		t.Token.assign,
		t.Token.ident,
		t.Token.lparen,
		t.Token.ident,
		t.Token.comma,
		t.Token.ident,
		t.Token.rparen,
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
