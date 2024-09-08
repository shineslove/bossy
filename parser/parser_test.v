module parser

import ast
import lexer

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

fn check_let_statement(letStmt ast.LetStatement, name string) bool {
	if letStmt.token.@type != .let {
		eprintln("token wasn't a let type -> type was ${letStmt.token.@type}")
		return false
	}
	if letStmt.name.token.value != name {
		eprintln('statement value was ${name} -> type was ${letStmt.name.token.value}')
		return false
	}
	if letStmt.name.token_literal() != name {
		eprintln("statement literal wasn't ${name} -> type was ${letStmt.name.token_literal()}")
		return false
	}
	return true
}
