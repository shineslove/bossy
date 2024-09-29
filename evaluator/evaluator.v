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
	return obj
}

fn new_error(format string, values string) object.Err {
	return object.Err{
		message: '${format}: ${values}'
	}
}

fn is_error(obj ?object.Object) bool {
	if obj != none {
		return obj.kind() == .error
	}
	return false
}

fn apply_function(fun object.Object, args []object.Object) ?object.Object {
	return match fun {
		object.Function {
			func := fun as object.Function
			mut extend_env := extend_function_env(func, args)
			evaluated := eval(func.body, mut extend_env)
			unwrap_return_val(evaluated?)
		}
		object.Builtin {
			fun.func(...args)
		}
		else {
			obj := new_error('not a function', '${fun.kind()}')
			return_obj(obj)
		}
	}
}

fn extend_function_env(fun object.Function, args []object.Object) &object.Environment {
	mut env := object.new_enclosed_environment(fun.env)
	for param_idx, param in fun.parameters {
		env.set(param.value, args[param_idx])
	}
	return env
}

fn unwrap_return_val(obj object.Object) object.Object {
	if obj is object.Return {
		rv := obj as object.Return
		return rv.value
	}
	return obj
}

pub fn eval(node ast.Node, mut env object.Environment) ?object.Object {
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
					right := eval(node.right?, mut env)
					if is_error(right) {
						return right
					}
					eval_prefix_expression(node.operator, right?)
				}
				ast.InfixExpression {
					left := eval(node.left, mut env)
					if is_error(left) {
						return left
					}
					right := eval(node.right?, mut env)
					if is_error(right) {
						return right
					}
					eval_infix_expression(node.operator, left?, right?)
				}
				ast.IfExpression {
					eval_if_expression(node, mut env)
				}
				ast.Identifier {
					eval_identifier(node, env)
				}
				ast.FunctionLiteral {
					params := node.parameters
					body := node.body
					obj := object.Function{
						parameters: params?
						env:        env
						body:       body
					}
					return_obj(obj)
				}
				ast.CallExpression {
					function := eval(node.function, mut env)?
					if is_error(function) {
						return function
					}
					args := eval_expressions(node.arguments?, mut env)
					if args.len > 0 {
						// V tries to access args here for some reason
						if args.len == 1 && is_error(args[0]) {
							return args[0]
						}
					}
					// doing a return here breaks things
					apply_function(function, args)
				}
				ast.StringLiteral {
					return_obj(object.String{ value: node.value })
				}
				ast.ArrayLiteral {
					elements := eval_expressions(node.elements, mut env)
					if elements.len > 0 {
						// happened here again, accessing empty array
						if elements.len == 1 && is_error(elements[0]) {
							return elements[0]
						}
					}
					return_obj(object.Array{ elements: elements })
				}
				ast.IndexExpression {
					left := eval(node.left, mut env)
					if is_error(left) {
						return left
					}
					index := eval(node.index, mut env)
					if is_error(index) {
						return index
					}
					eval_index_expression(left?, index?)
				}
			}
		}
		ast.Statement {
			match node {
				ast.ExpressionStatement {
					eval(node.expression, mut env)
				}
				ast.ReturnStatement {
					val := eval(node.return_value?, mut env)?
					if is_error(val) {
						return val
					}
					obj := object.Return{
						value: val
					}
					return_obj(obj)
				}
				ast.LetStatement {
					val := eval(node.value?, mut env)
					if is_error(val) {
						return val
					}
					env.set(node.name.value, val?)
				}
				else {
					none
				}
			}
		}
		ast.Program {
			eval_program(node, mut env)
		}
		ast.BlockStatement {
			eval_block_statement(node, mut env)
		}
	}
}

fn eval_expressions(exps []ast.Expression, mut env object.Environment) []object.Object {
	mut result := []object.Object{}
	for exp in exps {
		if evaluated := eval(exp, mut env) {
			if is_error(evaluated) {
				result << evaluated
				return result
			}
			result << evaluated
		}
	}
	return result
}

fn eval_identifier(node ast.Identifier, env object.Environment) object.Object {
	if builtin := builtins[node.value] {
		return builtin
	}
	val := env.get(node.value)
	return val or { new_error('identifier not found', node.value) }
}

fn eval_block_statement(block ast.BlockStatement, mut env object.Environment) ?object.Object {
	mut result := object.Object{}
	for stmt in block.statements {
		result = eval(stmt, mut env)?
		if result.kind() in [.@return, .error] {
			return result
		}
	}
	return result
}

fn eval_program(prog ast.Program, mut env object.Environment) ?object.Object {
	mut result := object.Object{}
	for stmt in prog {
		result = eval(stmt, mut env)?
		if result is object.Return {
			return_value := result as object.Return
			return return_value.value
		} else if result is object.Err {
			return result
		}
	}
	return result
}

fn eval_infix_expression(operator string, left object.Object, right object.Object) object.Object {
	if left.kind() == .string && right.kind() == .string {
		return eval_string_infix_expression(operator, left, right)
	}
	if left.kind() == .integer && right.kind() == .integer {
		return eval_integer_infix_expression(operator, left, right)
	}
	if left.kind() != right.kind() {
		return new_error('type mismatch', '${left.kind()} ${operator} ${right.kind()}')
	}
	return match operator {
		'==' { native_bool_to_boolean_object(left == right) }
		'!=' { native_bool_to_boolean_object(left != right) }
		else { new_error('unknown operator', '${left.kind()} ${operator} ${right.kind()}') }
	}
}

fn eval_string_infix_expression(operator string, left object.Object, right object.Object) object.Object {
	return match operator {
		'+' {
			left_val := (left as object.String).value
			right_val := (right as object.String).value
			object.String{
				value: left_val + right_val
			}
		}
		else {
			new_error('unknown operator', '${left.kind()} ${operator} ${right.kind()}')
		}
	}
}

fn eval_integer_infix_expression(operator string, left object.Object, right object.Object) object.Object {
	left_val := (left as object.Integer).value
	right_val := (right as object.Integer).value
	return match operator {
		'+' {
			object.Integer{
				value: left_val + right_val
			}
		}
		'-' {
			object.Integer{
				value: left_val - right_val
			}
		}
		'*' {
			object.Integer{
				value: left_val * right_val
			}
		}
		'/' {
			object.Integer{
				value: left_val / right_val
			}
		}
		'<' {
			native_bool_to_boolean_object(left_val < right_val)
		}
		'>' {
			native_bool_to_boolean_object(left_val > right_val)
		}
		'==' {
			native_bool_to_boolean_object(left_val == right_val)
		}
		'!=' {
			native_bool_to_boolean_object(left_val != right_val)
		}
		else {
			new_error('unknown operator', '${left.kind()} ${operator} ${right.kind()}')
		}
	}
}

fn eval_if_expression(ie ast.IfExpression, mut env object.Environment) ?object.Object {
	condition := eval(ie.condition, mut env)
	if is_error(condition) {
		return condition
	}
	if is_truthy(condition?) {
		return eval(ie.consequence, mut env)
	} else if ie.alternative != none {
		return eval(ie.alternative?, mut env)
	} else {
		return null
	}
}

fn eval_prefix_expression(operator string, right object.Object) object.Object {
	return match operator {
		'!' { eval_bang_operator_expression(right) }
		'-' { eval_minus_operator_expression(right) }
		else { new_error('unknown operator', '${operator}${right.kind()}') }
	}
}

fn eval_minus_operator_expression(right object.Object) object.Object {
	if right.kind() != .integer {
		return new_error('unknown operator', '-${right.kind()}')
	}
	value := (right as object.Integer).value
	return object.Integer{
		value: -value
	}
}

fn is_truthy(obj object.Object) bool {
	return match obj {
		object.Boolean {
			match obj {
				truth { true }
				else { false }
			}
		}
		object.Null {
			false
		}
		else {
			true
		}
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

fn eval_statements(stmts []ast.Statement, mut env object.Environment) ?object.Object {
	mut result := object.Object{}
	for stmt in stmts {
		result = eval(stmt, mut env)?
		if result is object.Return {
			return_value := result as object.Return
			return return_value.value
		}
	}
	return result
}

fn eval_index_expression(left object.Object, index object.Object) object.Object {
	if left.kind() == .array && index.kind() == .integer {
		return eval_array_index_expression(left, index)
	}
	return new_error('index operator not supported', left.kind().str())
}

fn eval_array_index_expression(array object.Object, index object.Object) object.Object {
	arr_obj := array as object.Array
	idx := (index as object.Integer).value
	max := arr_obj.elements.len - 1
	if idx < 0 || idx > max {
		return null
	}
	return arr_obj.elements[idx]
}
