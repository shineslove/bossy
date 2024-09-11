module main

import lexer
import parser { Parser }
import ast

fn main() {
	exclaim := {
		'input':     '!5;'
		'operator':  '!'
		'int_value': '5'
	}
	neg := {
		'input':     '-15;'
		'operator':  '-'
		'int_value': '15'
	}
	inputs := [exclaim, neg]
	for idx, tst in inputs {
		println('test no: ${idx}')
		println('test: ${tst}')
		lex := lexer.Lexer.new(tst['input'])
		mut par := Parser.new(lex)
		prog := par.parse_program()
		check_parser_errors(par)
		assert prog.statements.len == 1, 'prog doesnt have 1 statement(s), got: ${prog.statements.len} -> input: ${prog.statements}'
		stmt := prog.statements[0] as ast.ExpressionStatement
		println(stmt)
		exp := stmt.expression as ast.PrefixExpression
		assert exp.operator == tst['operator'], 'exp operator is not ${tst['operator']} but ${exp.operator}'
		assert check_integer_literal(exp.right, tst['int_value'].int())
	}
}

fn check_integer_literal(il ast.Expression, value int) bool {
	integer := il as ast.IntegerLiteral
	if integer.value != value {
		eprintln('int value was not expected ${value}, got: ${integer.value}')
		eprintln('int types are: ${typeof(value).name}, got: ${typeof(integer.value).name}')
		return false
	}
	if integer.token_literal() != '${value}' {
		eprintln('token literal for it was not expected ${value}, got: ${integer.token_literal()}')
		return false
	}
	return true
}

fn check_parser_errors(p Parser) {
	errors := p.errors()
	if errors.len > 0 {
		for msg in errors {
			eprintln('parser error: ${msg}')
		}
	}
	assert errors.len == 0, 'parser had ${errors.len} errors'
}
