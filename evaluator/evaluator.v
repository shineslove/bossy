module evaluator

import ast
import object

const truth = object.Boolean{
	value: true
}

const falsy = object.Boolean{
	value: false
}

const null = object.Null{}

fn native_bool_to_boolean_object(input bool) object.Boolean {
	if input {
		return truth
	}
	return falsy
}

fn return_obj(obj object.Object) object.Object {
	// V wasn't letting me return object.Int and object.Bool
	return obj
}

pub fn eval(node ast.Node) ?object.Object {
	return match node {
		ast.Expression {
			match node {
				ast.IntegerLiteral {
					obj := object.Integer{
						value: node.value
					}
					return_obj(obj)
				}
				ast.Boolean {
					obj := native_bool_to_boolean_object(node.value)
					return_obj(obj)
				}
				ast.PrefixExpression {
					right := eval(node.right?)
					eval_prefix_expression(node.operator, right?)
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

fn eval_prefix_expression(operator string, right object.Object) object.Object {
	return match operator {
		'!' { eval_bang_operator_expression(right) }
		'-' { eval_minus_operator_expression(right) }
		else { null }
	}
}

fn eval_minus_operator_expression(right object.Object) object.Object {
	if right.kind() != .integer {
		return null
	}
	integer := right as object.Integer
	value := integer.value
	return object.Integer{
		value: -value
	}
}

fn eval_bang_operator_expression(right object.Object) object.Object {
	// couldn't use constants for the match
	return match right {
		object.Boolean {
			match right {
				truth { falsy }
				else { truth }
			}
		}
		object.Null {
			truth
		}
		else {
			falsy
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
