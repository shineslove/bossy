module parser

import ast
import lexer

struct PrefixTests {
	input    string
	operator string
	value    LocalAny
}

struct InfixTests {
	input    string
	left     LocalAny
	operator string
	right    LocalAny
}

type LocalAny = string | int | bool

fn infix_expression_test(exp ast.Expression, left LocalAny, operator string, right LocalAny) bool {
	op_exp := exp as ast.InfixExpression
	assert literal_expression_test(op_exp.left, left)
	assert op_exp.operator == operator, 'exp.oper is not ${op_exp.operator} got: ${operator}'
	assert literal_expression_test(op_exp.right, right)
	return true
}

fn literal_expression_test(exp ast.Expression, expected LocalAny) bool {
	return match expected {
		string { check_identifier(exp, expected) }
		int { check_integer_literal(exp, expected) }
		bool { check_boolean(exp, expected) }
	}
}

fn check_identifier(exp ast.Expression, value string) bool {
	ident := exp as ast.Identifier
	assert ident.value == value, 'ident value is not ${value} got: ${ident.value}'
	assert ident.token_literal() == value, 'ident token literal not ${value}, got: ${ident.token_literal()}'
	return true
}

fn check_boolean(exp ast.Expression, value bool) bool {
	boolean := exp as ast.Boolean
	assert boolean.value == value, 'ident value is not ${value} got: ${boolean.value}'
	assert boolean.token_literal() == value.str(), 'ident token literal not ${value}, got: ${boolean.token_literal()}'
	return true
}

fn test_operator_precedence_parsing() {
	tsts := create_test_cases_operator_pred_parse([
		['-a * b', '((-a) * b)'],
		['!-a', '(!(-a))'],
		['a + b + c', '((a + b) + c)'],
		['a + b - c', '((a + b) - c)'],
		['a * b * c', '((a * b) * c)'],
		['a * b / c', '((a * b) / c)'],
		['a + b / c', '(a + (b / c))'],
		['a + b * c + d / e - f', '(((a + (b * c)) + (d / e)) - f)'],
		['3 + 4; -5 * 5', '(3 + 4)((-5) * 5)'],
		['5 > 4 == 3 < 4', '((5 > 4) == (3 < 4))'],
		['5 < 4 != 3 > 4', '((5 < 4) != (3 > 4))'],
		['3 + 4 * 5 == 3 * 1 + 4 * 5', '((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))'],
		['true;', 'true'],
		['false;', 'false'],
		['3 > 5 == false', '((3 > 5) == false)'],
		['3 < 5 == true', '((3 < 5) == true)'],
		['1 + (2 + 3) + 4', '((1 + (2 + 3)) + 4)'],
		['(5 + 5) * 2', '((5 + 5) * 2)'],
		['2 / (5 + 5)', '(2 / (5 + 5))'],
		['-(5 + 5)', '(-(5 + 5))'],
		['!(true == true)', '(!(true == true))'],
	])
	for tst in tsts {
		lex := lexer.Lexer.new(tst['input'])
		mut par := Parser.new(lex)
		prog := par.parse_program()
		check_parser_errors(par)
		actual := '${prog}'
		assert actual == tst['expected'], "didn't get expected -> input [ ${tst['input']} ] : ${tst['expected']} got: ${actual} and statements: ${prog.statements}"
	}
}

fn test_parsing_prefix_expressions() {
	inputs := [PrefixTests{
		input:    '!5;'
		operator: '!'
		value:    5
	}, PrefixTests{
		input:    '-15;'
		operator: '-'
		value:    15
	}, PrefixTests{
		input:    '!true;'
		operator: '!'
		value:    true
	}, PrefixTests{
		input:    '!false;'
		operator: '!'
		value:    false
	}]
	for tst in inputs {
		lex := lexer.Lexer.new(tst.input)
		mut par := Parser.new(lex)
		prog := par.parse_program()
		check_parser_errors(par)
		assert prog.statements.len == 1, 'prog doesnt have 1 statement(s), got: ${prog.statements.len} -> input: ${prog.statements}'
		stmt := prog.statements[0] as ast.ExpressionStatement
		exp := stmt.expression as ast.PrefixExpression
		assert exp.operator == tst.operator, 'exp operator is not ${tst.operator} but ${exp.operator}'
		assert literal_expression_test(exp.right, tst.value)
	}
}

fn test_parsing_infix_expressions() {
	inputs := [
		InfixTests{
			input:    '5 + 5;'
			left:     5
			operator: '+'
			right:    5
		},
		InfixTests{
			input:    '5 - 5;'
			left:     5
			operator: '-'
			right:    5
		},
		InfixTests{
			input:    '5 * 5;'
			left:     5
			operator: '*'
			right:    5
		},
		InfixTests{
			input:    '5 / 5;'
			left:     5
			operator: '/'
			right:    5
		},
		InfixTests{
			input:    '5 > 5;'
			left:     5
			operator: '>'
			right:    5
		},
		InfixTests{
			input:    '5 < 5;'
			left:     5
			operator: '<'
			right:    5
		},
		InfixTests{
			input:    '5 == 5;'
			left:     5
			operator: '=='
			right:    5
		},
		InfixTests{
			input:    '5 != 5;'
			left:     5
			operator: '!='
			right:    5
		},
		InfixTests{
			input:    'true == true'
			left:     true
			operator: '=='
			right:    true
		},
		InfixTests{
			input:    'true != false'
			left:     true
			operator: '!='
			right:    false
		},
		InfixTests{
			input:    'false == false'
			left:     false
			operator: '=='
			right:    false
		},
	]
	for tst in inputs {
		lex := lexer.Lexer.new(tst.input)
		mut par := Parser.new(lex)
		prog := par.parse_program()
		check_parser_errors(par)
		assert prog.statements.len == 1, 'prog doesnt have 1 statement(s), got: ${prog.statements.len} -> input: ${prog.statements}'
		stmt := prog.statements[0] as ast.ExpressionStatement
		assert infix_expression_test(stmt.expression, tst.left, tst.operator, tst.right), 'values didnt match up'
	}
}

fn check_integer_literal(il ast.Expression, value int) bool {
	integer := il as ast.IntegerLiteral
	if integer.value != value {
		eprintln('int value was not expected ${value}, got: ${integer.value}')
		return false
	}
	if integer.token_literal() != '${value}' {
		eprintln('token literal for it was not expected ${value}, got: ${integer.token_literal()}')
		return false
	}
	return true
}

fn test_integer_literal_expression() {
	input := '5;'
	lex := lexer.Lexer.new(input)
	mut par := Parser.new(lex)
	prog := par.parse_program()
	check_parser_errors(par)
	assert prog.statements.len == 1, 'prog doesnt have 1 statement(s), got: ${prog.statements.len}'
	stmt := prog.statements[0] as ast.ExpressionStatement
	assert literal_expression_test(stmt.expression, 5)
}

fn test_boolean_literal_expression() {
	inputs := {
		'true;':  true
		'false;': false
	}
	for input, value in inputs {
		lex := lexer.Lexer.new(input)
		mut par := Parser.new(lex)
		prog := par.parse_program()
		check_parser_errors(par)
		assert prog.statements.len == 1, 'prog doesnt have 1 statement(s), got: ${prog.statements.len}'
		stmt := prog.statements[0] as ast.ExpressionStatement
		assert literal_expression_test(stmt.expression, value)
	}
}

fn test_identifier_expressions() {
	input := 'foobar;'
	lex := lexer.Lexer.new(input)
	mut par := Parser.new(lex)
	prog := par.parse_program()
	check_parser_errors(par)
	assert prog.statements.len == 1, 'prog doesnt have 1 statement(s), got: ${prog.statements.len}'
	stmt := prog.statements[0] as ast.ExpressionStatement
	literal_expression_test(stmt.expression, 'foobar')
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

fn create_test_cases_operator_pred_parse(tsts [][]string) []map[string]string {
	mut tst_cases := []map[string]string{}
	for tst in tsts {
		case := {
			'input':    tst[0]
			'expected': tst[1]
		}
		tst_cases << case
	}
	return tst_cases
}
