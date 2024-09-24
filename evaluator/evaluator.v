module evaluator

import ast
import object

const truth = object.Boolean{
	value: true
}

const falsehood = object.Boolean{
	value: false
}

fn native_bool_to_boolean_object(input bool) object.Boolean {
	if input {
		return truth
	}
	return falsehood
}

pub fn eval(node ast.Node) ?object.Object {
	mut data := []object.Object{cap: 1}
	return match node {
		ast.Expression {
			match node {
				ast.IntegerLiteral {
					obj := object.Integer{
						value: node.value
					}
					data << obj
					data[0]
				}
				ast.Boolean {
					data << native_bool_to_boolean_object(node.value)
					data[0]
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
