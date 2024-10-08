module parser

import lexer.token
import lexer
import ast

// const data_kun = map[string]token.TokenType{}

type PrefixParseFunc = fn () ast.Expression

type PrefixParseFuncOptional = fn () ?ast.Expression

type Prefixes = PrefixParseFunc | PrefixParseFuncOptional

type InfixParseFunc = fn (ast.Expression) ast.Expression

type InfixParseFuncOptional = fn (ast.Expression) ?ast.Expression

type Infixes = InfixParseFunc | InfixParseFuncOptional

enum Precedence {
	_
	lowest
	equals
	less_greater
	sum
	product
	prefix
	call
	index
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
	token.Token.lparen:   Precedence.call
	token.Token.lbracket: Precedence.index
}

// should've read the docs, just needed to return a
// reference during the new function
@[heap]
pub struct Parser {
mut:
	lex        lexer.Lexer
	curr_token token.TokenType
	peek_token token.TokenType
	errors     []string
}

fn (mut p Parser) find_prefix_parse(tok token.Token) ?Prefixes {
	return match tok {
		.ident { p.parse_identifier }
		.integer { p.parse_integer_literal }
		.bang { p.parse_prefix_expression }
		.minus { p.parse_prefix_expression }
		.@true { p.parse_boolean }
		.@false { p.parse_boolean }
		.lparen { p.parse_grouped_expression }
		.@if { p.parse_if_expression }
		.function { p.parse_function_literal }
		.string { p.parse_string_literal }
		.lbracket { p.parse_array_literal }
		.lbrace { p.parse_hash_literal }
		else { none }
	}
}

fn (mut p Parser) find_infix_parse(tok token.Token) ?Infixes {
	return match tok {
		.plus { p.parse_infix_expression }
		.minus { p.parse_infix_expression }
		.slash { p.parse_infix_expression }
		.asterisk { p.parse_infix_expression }
		.eq { p.parse_infix_expression }
		.not_eq { p.parse_infix_expression }
		.lt { p.parse_infix_expression }
		.gt { p.parse_infix_expression }
		.lparen { p.parse_call_expression }
		.lbracket { p.parse_index_expression }
		else { none }
	}
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

pub fn Parser.new(lex lexer.Lexer) &Parser {
	mut par := &Parser{
		lex: lex
	}
	par.next_token()
	par.next_token()
	return par
}

fn (mut p Parser) parse_hash_literal() ?ast.Expression {
	mut hash_lit := ast.HashLiteral{
		token: p.curr_token
	}
	for !p.peek_token_is(.rbrace) {
		p.next_token()
		key := p.parse_expression(.lowest)?
		if !p.expect_peek(.colon) {
			return none
		}
		p.next_token()
		val := p.parse_expression(.lowest)?
		hash_lit.pairs << ast.HashExpressionPair{
			key:   key
			value: val
		}
		if !p.peek_token_is(.rbrace) && !p.expect_peek(.comma) {
			return none
		}
	}
	if !p.expect_peek(.rbrace) {
		return none
	}
	return hash_lit
}

fn (mut p Parser) parse_array_literal() ?ast.Expression {
	mut array := ast.ArrayLiteral{
		token: p.curr_token
	}
	array.elements = p.parse_expression_list(.rbracket)?
	return array
}

fn (mut p Parser) parse_index_expression(left ast.Expression) ?ast.Expression {
	mut exp := ast.IndexExpression{
		token: p.curr_token
		left:  left
	}
	p.next_token()
	exp.index = p.parse_expression(.lowest)?
	if !p.expect_peek(.rbracket) {
		return none
	}
	return exp
}

fn (mut p Parser) parse_expression_list(end token.Token) ?[]ast.Expression {
	mut list := []ast.Expression{}
	if p.peek_token_is(end) {
		p.next_token()
		return list
	}
	p.next_token()
	list << p.parse_expression(.lowest)?
	for p.peek_token_is(.comma) {
		p.next_token()
		p.next_token()
		list << p.parse_expression(.lowest)?
	}
	if !p.expect_peek(end) {
		return none
	}
	return list
}

fn (mut p Parser) parse_string_literal() ast.Expression {
	return ast.StringLiteral{
		token: p.curr_token
		value: p.curr_token.value
	}
}

fn (mut p Parser) parse_call_expression(function ast.Expression) ast.Expression {
	mut exp := ast.CallExpression{
		token:    p.curr_token
		function: function
	}
	exp.arguments = p.parse_expression_list(.rparen)
	return exp
}

fn (mut p Parser) parse_call_arguments() ?[]ast.Expression {
	mut args := []ast.Expression{}
	if p.peek_token_is(.rparen) {
		p.next_token()
		return args
	}
	p.next_token()
	args << p.parse_expression(.lowest)?
	for p.peek_token_is(.comma) {
		p.next_token()
		p.next_token()
		args << p.parse_expression(.lowest)?
	}
	if !p.expect_peek(.rparen) {
		return none
	}
	return args
}

fn (mut p Parser) parse_function_literal() ?ast.Expression {
	mut lit := ast.FunctionLiteral{
		token: p.curr_token
	}
	if !p.expect_peek(.lparen) {
		return none
	}
	lit.parameters = p.parse_function_parameters()
	if !p.expect_peek(.lbrace) {
		return none
	}
	lit.body = p.parse_block_statement()
	return lit
}

fn (mut p Parser) parse_function_parameters() ?[]ast.Identifier {
	mut identifiers := []ast.Identifier{}
	if p.peek_token_is(.rparen) {
		p.next_token()
		return identifiers
	}
	p.next_token()
	identifiers << ast.Identifier{
		token: p.curr_token
		value: p.curr_token.value
	}
	for p.peek_token_is(.comma) {
		p.next_token()
		p.next_token()
		identifiers << ast.Identifier{
			token: p.curr_token
			value: p.curr_token.value
		}
	}
	if !p.expect_peek(.rparen) {
		return none
	}
	return identifiers
}

fn (mut p Parser) parse_if_expression() ?ast.Expression {
	mut exp := ast.IfExpression{
		token: p.curr_token
	}
	if !p.expect_peek(.lparen) {
		return none
	}
	p.next_token()
	exp.condition = p.parse_expression(.lowest)?
	if !p.expect_peek(.rparen) {
		return none
	}
	if !p.expect_peek(.lbrace) {
		return none
	}
	exp.consequence = p.parse_block_statement()
	if p.peek_token_is(.@else) {
		p.next_token()
		if !p.expect_peek(.lbrace) {
			return none
		}
		exp.alternative = p.parse_block_statement()
	}
	return exp
}

fn (mut p Parser) parse_block_statement() ast.BlockStatement {
	mut block := ast.BlockStatement{
		token: p.curr_token
	}
	block.statements = []ast.Statement{}
	p.next_token()
	for !p.curr_token_is(.rbrace) && !p.curr_token_is(.eof) {
		stmt := p.parse_statement()
		if stmt != none {
			block.statements << stmt
		}
		p.next_token()
	}
	return block
}

fn (mut p Parser) parse_grouped_expression() ?ast.Expression {
	p.next_token()
	exp := p.parse_expression(.lowest)
	if !p.expect_peek(.rparen) {
		return none
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
	// apparently Go just evals once??
	for {
		stmt := p.parse_statement()
		if stmt != none {
			program.statements << stmt
		}
		p.next_token()
		if p.peek_token_is(.eof) {
			break
		}
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
	p.next_token()
	stmt.value = p.parse_expression(.lowest)
	if p.peek_token_is(.semicolon) {
		p.next_token()
	}
	return stmt
}

fn (mut p Parser) parse_return_statement() ?ast.Statement {
	mut stmt := ast.ReturnStatement{
		token: p.curr_token
	}
	p.next_token()
	stmt.return_value = p.parse_expression(.lowest)
	if p.peek_token_is(.semicolon) {
		p.next_token()
	}
	return stmt
}

fn (mut p Parser) parse_expression_statement() ?ast.Statement {
	mut stmt := ast.ExpressionStatement{
		token: p.curr_token
	}
	stmt.expression = p.parse_expression(.lowest)?
	if p.peek_token_is(.semicolon) {
		p.next_token()
	}
	return stmt
}

fn (mut p Parser) parse_expression(precedence Precedence) ?ast.Expression {
	prefix := p.find_prefix_parse(p.curr_token.@type) or {
		p.errors << 'no prefix parse func for ${p.curr_token} found'
		return none
	}
	mut left_exp := match prefix {
		PrefixParseFunc { prefix() }
		PrefixParseFuncOptional { prefix()? }
	}
	for !p.peek_token_is(.semicolon) && int(precedence) < int(p.peek_precedence()) {
		infix := p.find_infix_parse(p.peek_token.@type) or { return left_exp }
		p.next_token()
		left_exp = match infix {
			InfixParseFunc { infix(left_exp) }
			InfixParseFuncOptional { infix(left_exp)? }
		}
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
