module parser

import lexer.token
import lexer
import ast
import time

const data_kun := map[string]token.TokenType{}

type PrefixParseFunc = fn (from string) ast.Expression

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

// can't use TokenType as a key for maps
// ended up not needed them, great...
pub fn (mut p Parser) register_prefix(tok token.Token, func PrefixParseFunc) {
	p.prefix_parse_funcs[tok] = func
}

pub fn (mut p Parser) register_infix(tok token.Token, func InfixParseFunc) {
	p.infix_parse_funcs[tok] = func
}

pub fn Parser.new(lex lexer.Lexer) Parser {
	mut par := Parser{
		lex: lex
	}
	par.next_token('init 1')
	par.next_token('init 2')
	par.prefix_parse_funcs = map[token.Token]PrefixParseFunc{}
	// par.register_prefix(.ident, par.parse_identifier)
	// had to add parser to heap after this one
	par.register_prefix(.integer, par.parse_integer_literal)
	par.register_prefix(.bang, par.parse_prefix_expression)
	par.register_prefix(.minus, par.parse_prefix_expression)
	return par
}

fn (p Parser) parse_identifier() ast.Expression {
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

fn (mut p Parser) next_token(from string) {
	println('before(${from}) | (${time.now().nanosecond}): curr -> ${p.curr_token} peek -> ${p.peek_token}')
	p.curr_token = p.peek_token
	p.peek_token = p.lex.next_token()
	unsafe {
		data_kun['current'] = p.curr_token
		data_kun['peek'] = p.peek_token
	}
	println('after(${from}) | (${time.now().nanosecond}): curr -> ${p.curr_token} peek -> ${p.peek_token}')
}

pub fn (mut p Parser) parse_program() ast.Program {
	mut program := ast.Program{}
	program.statements = []ast.Statement{}
	for !p.peek_token_is(.eof) {
		println('start of eof check loop in prog: (${time.now().nanosecond})')
		stmt := p.parse_statement()
		if stmt != none {
			program.statements << stmt
			println('from within none stmt check (${time.now().nanosecond}) -> ${p.curr_token}')
			if p.curr_token != data_kun['current'] {
				p.next_token('data-kun helped out')
			}
		}
		p.next_token('parse prog')
	}
	println('end of eof check loop in prog')
	return program
}

fn (mut p Parser) parse_statement() ?ast.Statement {
	return match p.curr_token.@type {
		.let { p.parse_let_statement() }
		.@return { p.parse_return_statement() }
		else { p.parse_expression_statement('parse_state') }
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
		p.next_token('let semicolon check')
	}
	return stmt
}

fn (mut p Parser) parse_return_statement() ?ast.Statement {
	mut stmt := ast.ReturnStatement{
		token: p.curr_token
	}
	p.next_token('return statement')
	// TODO: skipping expressions for now
	for !p.curr_token_is(.semicolon) {
		p.next_token('return semi check')
	}
	return stmt
}

fn (mut p Parser) parse_expression_statement(from string) ast.Statement {
	println('start of parse exp from ${from}')
	mut stmt := ast.ExpressionStatement{
		token: p.curr_token
	}
	stmt.expression = p.parse_expression('parse exp STATEMENT')
	if p.peek_token_is(.semicolon) {
		println('peek token check from ${from}')
		p.next_token('exp semi check')
	}
	return stmt
}

fn (mut p Parser) parse_expression(from string) ?ast.Expression {
	prefix := p.prefix_parse_funcs[p.curr_token.@type] or {
		println('no prefix found for ${p.curr_token.@type}')
		p.errors << 'no prefix parse func for ${p.curr_token.@type} found'
		return none
	}
	println('calling of parse exp from: ${from}')
	println('parse exp data (curr token) -> ${p.curr_token}')
	println('parse exp data (peek token) -> ${p.peek_token}')
	left_exp := prefix('parse exp')
	return left_exp
}

fn (mut p Parser) parse_prefix_expression(from string) ast.Expression {
	mut expression := ast.PrefixExpression{
		token:    p.curr_token
		operator: p.curr_token.value
	}
	println('prefix called from ${from}')
	p.next_token('prefix exp')
	// original didn't handle nil expection
	expression.right = p.parse_expression('prefix exp')
	return expression
}

fn (mut p Parser) parse_integer_literal(from string) ast.Expression {
	println('int lit called from: ${from}')
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
			p.next_token('expect peek')
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
