module ast

import lexer.token

// no match on str: made it segfault, too much recursions?  (no error)
pub type Statement = LetStatement | ReturnStatement | ExpressionStatement

pub fn (st Statement) token_literal() string {
	return st.token_literal()
}

pub fn (st Statement) str() string {
	return match st {
		LetStatement { st.str() }
		ReturnStatement { st.str() }
		ExpressionStatement { st.str() }
	}
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

pub struct ReturnStatement {
pub:
	token        token.TokenType
	return_value ?Expression
}

pub type Expression = Identifier | IntegerLiteral | PrefixExpression

pub fn (exp Expression) token_literal() string {
	return match exp {
		Identifier { exp.token_literal() }
		IntegerLiteral { exp.token_literal() }
		PrefixExpression { exp.token_literal() }
	}
}

pub fn (exp Expression) str() string {
	return match exp {
		Identifier { '${exp.str()}' }
		IntegerLiteral { '${exp.str()}' }
		PrefixExpression { '${exp.str()}' }
	}
}

pub struct IntegerLiteral {
pub:
	token token.TokenType
pub mut:
	value int
}

pub struct PrefixExpression {
pub:
	token token.TokenType
pub mut:
	operator string
	right    Expression
}

pub struct ExpressionStatement {
pub:
	token token.TokenType
pub mut:
	expression Expression
}

pub struct LetStatement {
pub:
	token token.TokenType
	value ?Expression
pub mut:
	name Identifier
}

pub fn (id Identifier) token_literal() string {
	return id.token.value
}

pub fn (id Identifier) str() string {
	return '${id.value}'
}

pub fn (il IntegerLiteral) token_literal() string {
	return il.token.value
}

pub fn (il IntegerLiteral) str() string {
	return il.token.value
}

pub fn (pe PrefixExpression) token_literal() string {
	return pe.token.value
}

pub fn (pe PrefixExpression) str() string {
	mut output := ''
	output += '('
	output += '${pe.operator}'
	output += '${pe.right}'
	output += ')'
	return output
}

pub struct Identifier {
pub mut:
	token token.TokenType
	value string
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
