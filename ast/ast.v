module ast

import lexer.token

pub type Statement = LetStatement | ReturnStatement

pub fn (st Statement) token_literal() string {
	return match st {
		LetStatement { st.token_literal() }
		ReturnStatement { st.token_literal() }
	}
}

pub fn (ls LetStatement) token_literal() string {
	return ls.token.value
}

pub fn (rs ReturnStatement) token_literal() string {
	return rs.token.value
}

pub struct ReturnStatement {
pub:
	token        token.TokenType
	return_value Expression
}

pub struct LetStatement {
pub:
	token token.TokenType
	value Expression
pub mut:
	name Identifier
}

type Expression = Identifier

pub fn (id Identifier) token_literal() string {
	return id.token.value
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
