module ast

import lexer.token

// no match on str: made it segfault, too much recursions?  (no error)
pub type Statement = LetStatement | ReturnStatement | ExpressionStatement | BlockStatement

pub fn (st Statement) token_literal() string {
	return st.token_literal()
}

pub fn (st Statement) str() string {
	return match st {
		LetStatement { st.str() }
		ReturnStatement { st.str() }
		ExpressionStatement { st.str() }
		BlockStatement { st.str() }
	}
}

pub struct LetStatement {
pub:
	token token.TokenType
pub mut:
	value ?Expression
	name  Identifier
}

pub fn (ls LetStatement) token_literal() string {
	return ls.token.value
}

pub fn (ls LetStatement) str() string {
	mut output := ''
	output += '${ls.token_literal()} ${ls.name} = '
	if lv := ls.value {
		output += '${lv}'
	}
	output += ';'
	return output
}

pub struct ReturnStatement {
pub:
	token token.TokenType
pub mut:
	return_value ?Expression
}

pub fn (rs ReturnStatement) token_literal() string {
	return rs.token.value
}

pub fn (rs ReturnStatement) str() string {
	mut output := ''
	output += '${rs.token_literal()} '
	if rv := rs.return_value {
		output += '${rv}'
	}
	output += ';'
	return output
}

pub fn (es ExpressionStatement) token_literal() string {
	return es.token.value
}

pub fn (es ExpressionStatement) str() string {
	return es.expression.str()
}

pub struct Boolean {
pub:
	token token.TokenType
	value bool
}

pub fn (b Boolean) token_literal() string {
	return b.token.value
}

pub fn (b Boolean) str() string {
	return '${b.token.value}'
}

pub struct BlockStatement {
pub:
	token token.TokenType
pub mut:
	statements []Statement
}

fn (bs BlockStatement) token_literal() string {
	return bs.token.value
}

fn (bs BlockStatement) str() string {
	mut output := ''
	for stmt in bs.statements {
		output += stmt.str()
	}
	return output
}

pub struct IfExpression {
pub:
	token token.TokenType
pub mut:
	alternative ?BlockStatement
	consequence BlockStatement
	condition   Expression
}

fn (ie IfExpression) token_literal() string {
	return ie.token.value
}

fn (ie IfExpression) str() string {
	mut output := ''
	output += 'if'
	output += '${ie.condition} '
	output += '${ie.consequence}'
	if ie.alternative != none {
		output += 'else '
		output += '${ie.alternative}'
	}
	return output
}

pub struct FunctionLiteral {
pub:
	token token.TokenType
pub mut:
	parameters ?[]Identifier
	body       BlockStatement
}

fn (fl FunctionLiteral) token_literal() string {
	return fl.token.value
}

fn (fl FunctionLiteral) str() string {
	mut output := ''
	mut params := []string{}
	for param in params {
		params << param
	}
	output += fl.token_literal()
	output += '('
	output += params.join(', ')
	output += ')'
	output += '${fl.body.str()}'
	return output
}

pub struct CallExpression {
pub:
	token    token.TokenType
	function Expression
pub mut:
	arguments ?[]Expression
}

fn (ce CallExpression) token_literal() string {
	return ce.token.value
}

fn (ce CallExpression) str() string {
	mut output := ''
	mut args := []string{}
	for arg in ce.arguments {
		args << arg.str()
	}
	output += ce.function.str()
	output += '('
	output += args.join(', ')
	output += ')'
	return output
}

pub type Expression = Identifier
	| IntegerLiteral
	| PrefixExpression
	| InfixExpression
	| Boolean
	| IfExpression
	| FunctionLiteral
	| CallExpression

pub fn (exp Expression) token_literal() string {
	return match exp {
		Identifier { exp.token_literal() }
		IntegerLiteral { exp.token_literal() }
		PrefixExpression { exp.token_literal() }
		InfixExpression { exp.token_literal() }
		Boolean { exp.token_literal() }
		IfExpression { exp.token_literal() }
		FunctionLiteral { exp.token_literal() }
		CallExpression { exp.token_literal() }
	}
}

pub fn (exp Expression) str() string {
	return match exp {
		Identifier { '${exp.str()}' }
		IntegerLiteral { '${exp.str()}' }
		PrefixExpression { '${exp.str()}' }
		InfixExpression { '${exp.str()}' }
		Boolean { '${exp.str()}' }
		IfExpression { '${exp.str()}' }
		FunctionLiteral { '${exp.str()}' }
		CallExpression { '${exp.str()}' }
	}
}

pub struct ExpressionStatement {
pub:
	token token.TokenType
pub mut:
	expression Expression
}

pub struct IntegerLiteral {
pub:
	token token.TokenType
pub mut:
	value int
}

pub fn (il IntegerLiteral) token_literal() string {
	return il.token.value
}

pub fn (il IntegerLiteral) str() string {
	return il.token.value
}

pub struct PrefixExpression {
pub:
	token    token.TokenType
	operator string
pub mut:
	right ?Expression
}

pub fn (pe PrefixExpression) token_literal() string {
	return pe.token.value
}

pub fn (pe PrefixExpression) str() string {
	mut output := ''
	output += '('
	output += '${pe.operator}'
	right := pe.right or { Expression{} }
	output += '${right.str()}'
	output += ')'
	return output
}

pub struct InfixExpression {
pub:
	token token.TokenType
pub mut:
	left     Expression
	operator string
	right    ?Expression
}

pub fn (ie InfixExpression) token_literal() string {
	return ie.token.value
}

pub fn (ie InfixExpression) str() string {
	mut output := ''
	output += '('
	output += '${ie.left.str()}'
	output += ' ${ie.operator} '
	right := ie.right or { Expression{} }
	output += '${right.str()}'
	output += ')'
	return output
}

pub struct Identifier {
pub mut:
	token token.TokenType
	value string
}

pub fn (id Identifier) token_literal() string {
	return id.token.value
}

pub fn (id Identifier) str() string {
	return '${id.value}'
}

pub struct Program {
pub mut:
	statements []Statement
mut:
	idx int
}

fn (mut prog Program) next() ?Statement {
	if prog.idx >= prog.statements.len {
		return none
	}
	defer {
		prog.idx++
	}
	return prog.statements[prog.idx]
}

fn (pro Program) token_literal() string {
	if pro.statements.len > 0 {
		return pro.statements[0].token_literal()
	}
	return ''
}

fn (pro Program) str() string {
	mut output := ''
	for stmt in pro.statements {
		output += '${stmt.str()}'
	}
	return output
}
