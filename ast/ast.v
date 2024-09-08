module ast

import lexer.token

pub fn (ls LetStatement) token_literal() string {
	return ls.token.value
}

pub fn (id Identifier) token_literal() string {
	return id.token.value
}

type Expression = Identifier

pub struct Identifier {
pub mut:
	token token.TokenType
	value string
}

pub struct LetStatement {
pub:
	token token.TokenType
	value Expression
pub mut:
	name  Identifier
}

// test if statement is expression
pub type Statement = LetStatement

pub struct Program {
pub mut:
	statements []Statement
mut:
	idx int
}

fn (mut prog Program) next() ?Statement {
	if prog.idx >= prog.statements.len 	{
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
