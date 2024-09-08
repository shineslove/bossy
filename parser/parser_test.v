module parser

import ast
import lexer

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
		assert ret_stmt.token.@type == .@return,  '${stmt.token.@type} was not a return'
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
