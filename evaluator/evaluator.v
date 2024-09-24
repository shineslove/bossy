module evaluator

import ast
import object

pub fn eval(node ast.Node) ?object.Object {
	return match node {
		ast.Expression {
			match node {
				ast.IntegerLiteral {
					object.Integer{
						value: node.value
					}
				}
				else {
					none
				}
			}
		}
		ast.Statement {
			match node {
				ast.ExpressionStatement { eval(node.expression) }
				else { none }
			}
		}
		ast.Program {
			eval_statements(node.statements)
		}
	}
}

fn eval_statements(stmts []ast.Statement) ?object.Object {
	mut result := object.Object{}
	for stmt in stmts {
		result = eval(stmt)?
	}
	return result
}
