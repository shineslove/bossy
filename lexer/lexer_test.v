module lexer

import token as t

struct TokenTests {
	expected_type    t.Token
	expected_literal string
}

fn test_next_token() {
	input := 'let five = 5;
    let ten = 10;

    let add = fn(x,y) {
        x + y;
    };

    let result = add(five,ten);
    !-/*5;
    5 < 10 > 5;

    if (5 < 10) {
        return true;
    } else {
        return false;
    }

    10 == 10;
    10 != 9;
    '
	mut lex := Lexer.new(input)
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
		t.Token.bang,
		t.Token.minus,
		t.Token.slash,
		t.Token.asterisk,
		t.Token.integer,
		t.Token.semicolon,
		t.Token.integer,
		t.Token.lt,
		t.Token.integer,
		t.Token.gt,
		t.Token.integer,
		t.Token.semicolon,
		t.Token.@if,
		t.Token.lparen,
		t.Token.integer,
		t.Token.lt,
		t.Token.integer,
		t.Token.rparen,
		t.Token.lbrace,
		t.Token.@return,
		t.Token.@true,
		t.Token.semicolon,
		t.Token.rbrace,
		t.Token.@else,
		t.Token.lbrace,
		t.Token.@return,
		t.Token.@false,
		t.Token.semicolon,
		t.Token.rbrace,
		t.Token.integer,
		t.Token.eq,
		t.Token.integer,
		t.Token.semicolon,
		t.Token.integer,
		t.Token.not_eq,
		t.Token.integer,
		t.Token.semicolon,
	]
	for typ in tests {
		tok := lex.next_token()
		assert tok.@type == typ, 'test for type failed ${tok.value}'
	}
}

fn test_literal_tokens() {
	literal_input := '
	    "foobar"
	    "foo bar"
	'
	literal_tests := [
		TokenTests{
			expected_type:    .string
			expected_literal: 'foobar'
		},
		TokenTests{
			expected_type:    .string
			expected_literal: 'foo bar'
		},
	]
	mut literal_lex := Lexer.new(literal_input)
	for lit_typ in literal_tests {
		lit_tok := literal_lex.next_token()
		assert lit_tok.@type == lit_typ.expected_type, 'test for type failed ${lit_tok.@type}'
		assert lit_tok.value == lit_typ.expected_literal, 'test for literal failed ${lit_tok.value}'
	}
}
