module ast

import lexer.token

fn test_ast_string() {
	program := Program{
		statements: [
			LetStatement{
				token: token.TokenType{
					@type: .let
					value: 'let'
				}
				name: Identifier{
					token: token.TokenType{
						@type: .ident
						value: 'myVar'
					}
					value: 'myVar'
				}
				value: Identifier{
					token: token.TokenType{
						@type: .ident
						value: 'anotherVar'
					}
					value: 'anotherVar'
				}
			},
		]
	}
	assert program.str() == 'let myVar = anotherVar;', 'program failed to stringify, got: ${program.str()}'
}

