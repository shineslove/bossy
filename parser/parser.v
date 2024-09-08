module parser

import lexer.token
import lexer
import ast

pub struct Parser {
mut:
	lex        lexer.Lexer
	curr_token token.TokenType
	peek_token token.TokenType
	errors     []string
}

pub fn Parser.new(lex lexer.Lexer) Parser {
	mut par := Parser{
		lex: lex
	}
	par.next_token()
	par.next_token()
	return par
}

pub fn (p Parser) errors() []string {
	return p.errors
}

fn (mut p Parser) peek_error(tok token.Token) {
	msg := 'expected next token to be ${tok}, got ${p.peek_token.@type}'
	p.errors << msg
}

fn (mut p Parser) next_token() {
	p.curr_token = p.peek_token
	p.peek_token = p.lex.next_token()
}

pub fn (mut p Parser) parse_program() ast.Program {
	mut program := ast.Program{}
	program.statements = []ast.Statement{}
	for p.curr_token.@type != .eof {
		stmt := p.parse_statement()
		if stmt != none {
			program.statements << stmt
		}
		p.next_token()
	}
	return program
}

fn (mut p Parser) parse_statement() ?ast.Statement {
	return match p.curr_token.@type {
		.let { p.parse_let_statement() }
		.@return { p.parse_return_statement() }
		else { none }
	}
}

fn (mut p Parser) parse_let_statement() ?ast.Statement {
	mut stmt := ast.LetStatement{
		token: p.curr_token
	}
	if !p.expect_peek(token.Token.ident) {
		return none
	}
	stmt.name = ast.Identifier{
		token: p.curr_token
		value: p.curr_token.value
	}
	if !p.expect_peek(token.Token.assign) {
		return none
	}
	// TODO: skipping expressions for now
	for !p.curr_token_is(token.Token.semicolon) {
		p.next_token()
	}
	return stmt
}

fn (mut p Parser) parse_return_statement() ?ast.Statement {
	mut stmt := ast.ReturnStatement{
		token: p.curr_token
	}
	p.next_token()
	// TODO: skipping expressions for now
	for !p.curr_token_is(token.Token.semicolon) {
		p.next_token()
	}
	return stmt
}

fn (p Parser) curr_token_is(tok token.Token) bool {
	return p.curr_token.@type == tok
}

fn (mut p Parser) expect_peek(tok token.Token) bool {
	return match p.peek_token.@type {
		tok {
			p.next_token()
			true
		}
		else {
			p.peek_error(tok)
			false
		}
	}
}
