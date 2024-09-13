module parser

import lexer.token
import lexer
import ast

// const data_kun = map[string]token.TokenType{}

type PrefixParseFunc = fn () ast.Expression

type InfixParseFunc = fn (ast.Expression) ast.Expression

enum Precedence {
	_
	lowest
	equals
	less_greater
	sum
	product
	prefix
	call
}

const precedences = {
	token.Token.eq:       Precedence.equals
	token.Token.not_eq:   Precedence.equals
	token.Token.lt:       Precedence.less_greater
	token.Token.gt:       Precedence.less_greater
	token.Token.plus:     Precedence.sum
	token.Token.minus:    Precedence.sum
	token.Token.slash:    Precedence.product
	token.Token.asterisk: Precedence.product
}

// should've read the docs, just needed to return a
// reference during the new function
@[heap]
pub struct Parser {
mut:
	lex                lexer.Lexer
	curr_token         token.TokenType
	peek_token         token.TokenType
	errors             []string
	prefix_parse_funcs map[token.Token]PrefixParseFunc
	infix_parse_funcs  map[token.Token]InfixParseFunc
}

fn (p Parser) peek_precedence() Precedence {
	if prec := precedences[p.peek_token.@type] {
		return prec
	}
	return .lowest
}

fn (p Parser) curr_precedence() Precedence {
	if prec := precedences[p.curr_token.@type] {
		return prec
	}
	return .lowest
}

pub fn (mut p Parser) register_prefix(tok token.Token, func PrefixParseFunc) {
	p.prefix_parse_funcs[tok] = func
}

pub fn (mut p Parser) register_infix(tok token.Token, func InfixParseFunc) {
	p.infix_parse_funcs[tok] = func
}

pub fn Parser.new(lex lexer.Lexer) &Parser {
	// TODO: look into match token func instead of map
	mut par := &Parser{
		lex: lex
	}
	par.prefix_parse_funcs = map[token.Token]PrefixParseFunc{}
	par.register_prefix(.ident, par.parse_identifier)
	// had to add parser to heap after this one
	par.register_prefix(.integer, par.parse_integer_literal)
	par.register_prefix(.bang, par.parse_prefix_expression)
	par.register_prefix(.minus, par.parse_prefix_expression)
	par.register_prefix(.@true, par.parse_boolean)
	par.register_prefix(.@false, par.parse_boolean)
	par.register_prefix(.lparen, par.parse_grouped_expression)
	par.infix_parse_funcs = map[token.Token]InfixParseFunc{}
	par.register_infix(.plus, par.parse_infix_expression)
	par.register_infix(.minus, par.parse_infix_expression)
	par.register_infix(.slash, par.parse_infix_expression)
	par.register_infix(.asterisk, par.parse_infix_expression)
	par.register_infix(.eq, par.parse_infix_expression)
	par.register_infix(.not_eq, par.parse_infix_expression)
	par.register_infix(.lt, par.parse_infix_expression)
	par.register_infix(.gt, par.parse_infix_expression)
	par.next_token()
	par.next_token()
	return par
}

fn (mut p Parser) parse_grouped_expression() ast.Expression {
	p.next_token()
	exp := p.parse_expression(.lowest)
	if !p.expect_peek(.rparen) {
		return ast.Expression{}
	}
	return exp
}

fn (mut p Parser) parse_boolean() ast.Expression {
	return ast.Boolean{
		token: p.curr_token
		value: p.curr_token_is(.@true)
	}
}

// this caused me hours of pain, needed to be mut Parser
// to get latest value...
fn (mut p Parser) parse_identifier() ast.Expression {
	return ast.Identifier{
		token: p.curr_token
		value: p.curr_token.value
	}
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
	for !p.peek_token_is(.eof) {
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
		else { p.parse_expression_statement() }
	}
}

fn (mut p Parser) parse_let_statement() ?ast.Statement {
	mut stmt := ast.LetStatement{
		token: p.curr_token
	}
	if !p.expect_peek(.ident) {
		return none
	}
	stmt.name = ast.Identifier{
		token: p.curr_token
		value: p.curr_token.value
	}
	if !p.expect_peek(.assign) {
		return none
	}
	// TODO: skipping expressions for now
	for !p.curr_token_is(.semicolon) {
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
	for !p.curr_token_is(.semicolon) {
		p.next_token()
	}
	return stmt
}

fn (mut p Parser) parse_expression_statement() ast.Statement {
	mut stmt := ast.ExpressionStatement{
		token: p.curr_token
	}
	stmt.expression = p.parse_expression(.lowest)
	if p.peek_token_is(.semicolon) {
		p.next_token()
	}
	return stmt
}

fn (mut p Parser) parse_expression(precedence Precedence) ast.Expression {
	prefix := p.prefix_parse_funcs[p.curr_token.@type] or {
		p.errors << 'no prefix parse func for ${p.curr_token.@type} found'
		return ast.Expression{}
	}
	mut left_exp := prefix()
	for !p.peek_token_is(.semicolon) && int(precedence) < int(p.peek_precedence()) {
		infix := p.infix_parse_funcs[p.peek_token.@type] or { return left_exp }
		p.next_token()
		left_exp = infix(left_exp)
	}
	return left_exp
}

fn (mut p Parser) parse_prefix_expression() ast.Expression {
	mut expression := ast.PrefixExpression{
		token:    p.curr_token
		operator: p.curr_token.value
	}
	p.next_token()
	// original didn't handle nil expection
	expression.right = p.parse_expression(.prefix)
	return expression
}

fn (mut p Parser) parse_infix_expression(left ast.Expression) ast.Expression {
	mut expression := ast.InfixExpression{
		token:    p.curr_token
		operator: p.curr_token.value
		left:     left
	}
	precedence := p.curr_precedence()
	p.next_token()
	// original didn't handle nil expection
	right := p.parse_expression(precedence)
	expression.right = right
	return expression
}

fn (mut p Parser) parse_integer_literal() ast.Expression {
	mut lit := ast.IntegerLiteral{
		token: p.curr_token
	}
	value := p.curr_token.value.int()
	lit.value = value
	return lit
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

fn (p Parser) peek_token_is(tok token.Token) bool {
	return p.peek_token.@type == tok
}
