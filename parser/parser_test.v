module parser

import ast
import lexer

fn test_parsing_prefix_expressions() {
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
	for tst in inputs {
		lex := lexer.Lexer.new(tst['input'])
		mut par := Parser.new(lex)
		prog := par.parse_program()
		// panic(prog)
		check_parser_errors(par)
		assert prog.statements.len == 1, 'prog doesnt have 1 statement(s), got: ${prog.statements.len} -> input: ${prog.statements}'
		stmt := prog.statements[0] as ast.ExpressionStatement
		exp := stmt.expression as ast.PrefixExpression
		assert exp.operator == tst['operator'], 'exp operator is not ${tst['operator']} but ${exp.operator}'
		assert check_integer_literal(exp.right, tst['int_value'].int())
	}
}

fn check_integer_literal(il ast.Expression, value int) bool {
	integer := il as ast.IntegerLiteral
	if integer.value == value {
		eprintln('int value was not expected ${value}, got: ${integer.value}')
		return false
	}
	if integer.token_literal() == '${value}' {
		eprintln('token literal for it was not expected ${value}, got: ${integer.token_literal()}')
		return false
	}
	return true
}

fn test_interger_literal_expression() {
	input := '5;'
	lex := lexer.Lexer.new(input)
	mut par := Parser.new(lex)
	prog := par.parse_program()
	check_parser_errors(par)
	assert prog.statements.len == 1, 'prog doesnt have 1 statement(s), got: ${prog.statements.len}'
	stmt := prog.statements[0] as ast.ExpressionStatement
	literal := stmt.expression as ast.IntegerLiteral
	assert literal.value == 5, "literal value wasn't 5 got: ${literal.value}"
	assert literal.token_literal() == '5', "literal token literal wasn't 5 got: ${literal.value}"
}

fn test_identifier_expressions() {
	input := 'foobar;'
	lex := lexer.Lexer.new(input)
	mut par := Parser.new(lex)
	prog := par.parse_program()
	check_parser_errors(par)
	assert prog.statements.len == 1, 'prog doesnt have 1 statement(s), got: ${prog.statements.len}'
	stmt := prog.statements[0] as ast.ExpressionStatement
	// options broke here and didn't show much
	ident := stmt.expression as ast.Identifier
	assert ident.value == 'foobar', "didn't get foobar got ${ident.value}"
	assert ident.token_literal() == 'foobar', "didn't get foobar got ${ident.token_literal()}"
}

fn test_return_statements() {
	input := '
	return 5;
	return 10;
	return 993322;
	'
	lex := lexer.Lexer.new(input)
	mut par := Parser.new(lex)
	prog := par.parse_program()
	check_parser_errors(par)
	assert prog.statements.len == 3, 'prog doesnt have 3 statements'
	for stmt in prog {
		ret_stmt := stmt as ast.ReturnStatement
		assert ret_stmt.token.@type == .@return, '${stmt.token.@type} was not a return'
	}
}

fn test_let_statements() {
	input := '
	let x = 5;
	let y = 10;
	let foobar = 838383;
	'
	lex := lexer.Lexer.new(input)
	mut par := Parser.new(lex)
	prog := par.parse_program()
	check_parser_errors(par)
	// assert prog != none, 'parse program returned non' ?? why no works
	assert prog.statements.len == 3, 'prog doesnt have 3 statements'
	tests := ['x', 'y', 'foobar']
	for i, stmt in prog {
		assert check_let_statement(stmt, tests[i])
	}
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

fn check_let_statement(stmt ast.Statement, name string) bool {
	let_stmt := stmt as ast.LetStatement
	if let_stmt.token.@type != .let {
		eprintln("token wasn't a let type -> type was ${let_stmt.token.@type}")
		return false
	}
	if let_stmt.name.token.value != name {
		eprintln('statement value was ${name} -> type was ${let_stmt.name.token.value}')
		return false
	}
	if let_stmt.name.token_literal() != name {
		eprintln("statement literal wasn't ${name} -> type was ${let_stmt.name.token_literal()}")
		return false
	}
	return true
}
