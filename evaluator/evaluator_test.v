module evaluator

import lexer
import object
import parser

struct EvalIntTests {
	input    string
	expected int
}

struct EvalBoolTests {
	input    string
	expected bool
}

struct BangTests {
	input    string
	expected bool
}

struct EvalIfTests {
	input    string
	expected ?int
}

struct EvalReturnTests {
	input    string
	expected int
}

struct ErrorTests {
	input            string
	expected_message string
}

struct LetTests {
	input    string
	expected int
}

struct FunctionTests {
	input    string
	expected int
}

fn test_function_application(){
	tsts := [
		FunctionTests{input: "let identity = fn(x) { x; }; identity(5);" expected: 5},
		FunctionTests{input: "let identity = fn(x) { return x; }; identity(5);" expected: 5},
		FunctionTests{input: "let double = fn(x) { x * 2; }; double(5);" expected: 10},
		FunctionTests{input: "let add = fn(x, y) { x + y; }; add(5, 5);" expected: 10},
		FunctionTests{input: "let add = fn(x, y) { x + y; }; add(5 + 5, add(5, 5));" expected: 20},
		FunctionTests{input: "fn(x) { x; }(5)" expected: 5},
	]
	for tst in tsts {
		evaluated := eval_test(tst.input)
		assert evaluated != none, 'this test: ${tst.input} returned none'
		assert int_object_test(evaluated?, tst.expected)
	}
}

<<<<<<< Updated upstream
fn test_function_object() {
	input := "fn(x) { x + 2; };"
	evaluated := eval_test(input)
	func := evaluated as object.Function
	assert func.parameters.len == 1, 'function has wrong params. Parameters: ${func.parameters}'
	assert '${func.parameters[0]}' == 'x', 'param is not x. got: ${func.parameters[0]}'
	expected_body := "(x + 2)"
	assert '${func.body}' == expected_body, 'body is not ${expected_body}. got: ${func.body}'
=======
struct FunctionTests {
	input    string
	expected int
}

fn test_function_application(){
	tsts := [
		FunctionTests{input: "let identity = fn(x) { x; }; identity(5);" expected: 5},
		FunctionTests{input: "let identity = fn(x) { return x; }; identity(5);" expected: 5},
		FunctionTests{input: "let double = fn(x) { x * 2; }; double(5);" expected: 10},
		FunctionTests{input: "let add = fn(x, y) { x + y; }; add(5, 5);" expected: 10},
		FunctionTests{input: "let add = fn(x, y) { x + y; }; add(5 + 5, add(5, 5));" expected: 20},
		FunctionTests{input: "fn(x) { x; }(5)" expected: 5},
	]
	for tst in tsts {
		evaluated := eval_test(tst.input)
		assert evaluated != none, 'this test: ${tst.input} returned none'
		assert int_object_test(evaluated?, tst.expected)
	}
>>>>>>> Stashed changes
}

fn test_let_statements() {
	tsts := [
		LetTests{
			input:    'let a = 5; a;'
			expected: 5
		},
		LetTests{
			input:    'let a = 5 * 5; a;'
			expected: 25
		},
		LetTests{
			input:    'let a = 5; let b = a; b;'
			expected: 5
		},
		LetTests{
			input:    'let a = 5; let b = a; let c = a + b + 5; c;'
			expected: 15
		},
	]
	for tst in tsts {
		int_object_test(eval_test(tst.input)?, tst.expected)
	}
}

fn test_error_handling() {
	tsts := [
		ErrorTests{
			input:            '5 + true;'
			expected_message: 'type mismatch: integer + boolean'
		},
		ErrorTests{
			input:            '5 + true; 5;'
			expected_message: 'type mismatch: integer + boolean'
		},
		ErrorTests{
			input:            '-true'
			expected_message: 'unknown operator: -boolean'
		},
		ErrorTests{
			input:            'true + false;'
			expected_message: 'unknown operator: boolean + boolean'
		},
		ErrorTests{
			input:            '5; true + false; 5'
			expected_message: 'unknown operator: boolean + boolean'
		},
		ErrorTests{
			input:            'if (10 > 1) { true + false; }'
			expected_message: 'unknown operator: boolean + boolean'
		},
		ErrorTests{
			input:            'if (10 > 1) { if (10 > 1) { return true + false; } return 1;}'
			expected_message: 'unknown operator: boolean + boolean'
		},
		ErrorTests{
			input:            'foobar'
			expected_message: 'identifier not found: foobar'
		},
	]
	for tst in tsts {
		evaluated := eval_test(tst.input)
		err_obj := evaluated as object.Err
		assert err_obj.message == tst.expected_message, 'wrong err message. expected: ${tst.expected_message}, got: ${err_obj.message}'
	}
}

fn test_if_else_expressions() {
	tsts := [
		EvalIfTests{
			input:    'if (true) { 10 }'
			expected: 10
		},
		EvalIfTests{
			input:    'if (false) { 10 }'
			expected: none
		},
		EvalIfTests{
			input:    'if (1) { 10 }'
			expected: 10
		},
		EvalIfTests{
			input:    'if (1 < 2) { 10 }'
			expected: 10
		},
		EvalIfTests{
			input:    'if (1 > 2) { 10 }'
			expected: none
		},
		EvalIfTests{
			input:    'if (1 > 2) { 10 } else { 20 }'
			expected: 20
		},
		EvalIfTests{
			input:    'if (1 < 2) { 10 } else { 20 }'
			expected: 10
		},
	]
	for tst in tsts {
		evaluated := eval_test(tst.input)
		int_opt := tst.expected
		if int_opt != none {
			integer := int_opt as int
			int_object_test(evaluated or {
				panic('didnt work bud -> val: ${evaluated} opt: ${int_opt}')
			}, integer)
		} else {
			null_object_test(evaluated?)
		}
	}
}

fn test_eval_boolean_expression() {
	tsts := [
		EvalBoolTests{
			input:    'true'
			expected: true
		},
		EvalBoolTests{
			input:    'false'
			expected: false
		},
		EvalBoolTests{
			input:    '1 < 2'
			expected: true
		},
		EvalBoolTests{
			input:    '1 > 2'
			expected: false
		},
		EvalBoolTests{
			input:    '1 < 1'
			expected: false
		},
		EvalBoolTests{
			input:    '1 > 1'
			expected: false
		},
		EvalBoolTests{
			input:    '1 == 1'
			expected: true
		},
		EvalBoolTests{
			input:    '1 != 1'
			expected: false
		},
		EvalBoolTests{
			input:    '1 == 2'
			expected: false
		},
		EvalBoolTests{
			input:    '1 != 2'
			expected: true
		},
		EvalBoolTests{
			input:    'true == true'
			expected: true
		},
		EvalBoolTests{
			input:    'false == false'
			expected: true
		},
		EvalBoolTests{
			input:    'true == false'
			expected: false
		},
		EvalBoolTests{
			input:    'true != false'
			expected: true
		},
		EvalBoolTests{
			input:    'false != true'
			expected: true
		},
		EvalBoolTests{
			input:    '(1 < 2) == true'
			expected: true
		},
		EvalBoolTests{
			input:    '(1 < 2) == false'
			expected: false
		},
		EvalBoolTests{
			input:    '(1 > 2) == true'
			expected: false
		},
		EvalBoolTests{
			input:    '(1 > 2) == false'
			expected: true
		},
	]
	for tst in tsts {
		evaluated := eval_test(tst.input)
		assert evaluated != none, 'object is not Boolean, got ${evaluated}'
		assert boolean_object_test(evaluated?, tst.expected)
	}
}

fn test_bang_operator() {
	tsts := [
		BangTests{'!true', false},
		BangTests{'!false', true},
		BangTests{'!5', false},
		BangTests{'!!true', true},
		BangTests{'!!false', false},
		BangTests{'!!5', true},
	]
	for tst in tsts {
		evaluated := eval_test(tst.input)
		assert evaluated != none, 'object is not Boolean, got ${evaluated}'
		assert boolean_object_test(evaluated?, tst.expected)
	}
}

fn test_eval_integer_expression() {
	tsts := [
		EvalIntTests{
			input:    '5'
			expected: 5
		},
		EvalIntTests{
			input:    '10'
			expected: 10
		},
		EvalIntTests{
			input:    '-5'
			expected: -5
		},
		EvalIntTests{
			input:    '-10'
			expected: -10
		},
		EvalIntTests{
			input:    '5 + 5 + 5 + 5 - 10'
			expected: 10
		},
		EvalIntTests{
			input:    '2 * 2 * 2 * 2 * 2'
			expected: 32
		},
		EvalIntTests{
			input:    '-50 + 100 + -50'
			expected: 0
		},
		EvalIntTests{
			input:    '5 * 2 + 10'
			expected: 20
		},
		EvalIntTests{
			input:    '5 + 2 * 10'
			expected: 25
		},
		EvalIntTests{
			input:    '20 + 2 * -10'
			expected: 0
		},
		EvalIntTests{
			input:    '50 / 2 * 2 + 10'
			expected: 60
		},
		EvalIntTests{
			input:    '2 * (5 + 10)'
			expected: 30
		},
		EvalIntTests{
			input:    '3 * 3 * 3 + 10'
			expected: 37
		},
		EvalIntTests{
			input:    '3 * (3 * 3) + 10'
			expected: 37
		},
		EvalIntTests{
			input:    '(5 + 10 * 2 + 15 / 3) * 2 + -10'
			expected: 50
		},
	]
	for tst in tsts {
		evaluated := eval_test(tst.input)
		assert evaluated != none, 'object is not Integer, got ${evaluated}'
		assert int_object_test(evaluated?, tst.expected)
	}
}

fn test_return_statements() {
	tsts := [
		EvalReturnTests{
			input:    'return 10;'
			expected: 10
		},
		EvalReturnTests{
			input:    'return 10; 9;'
			expected: 10
		},
		EvalReturnTests{
			input:    'return 2 * 5; 9;'
			expected: 10
		},
		EvalReturnTests{
			input:    '9; return 2 * 5; 9;'
			expected: 10
		},
		EvalReturnTests{
			input:    'if (10 > 1) { if (10 > 1) { return 10; } return 1;}'
			expected: 10
		},
	]
	for tst in tsts {
		evaluated := eval_test(tst.input)
		assert evaluated != none, 'object is not Integer, got ${evaluated}'
		assert int_object_test(evaluated?, tst.expected)
	}
}

fn eval_test(input string) ?object.Object {
	lex := lexer.Lexer.new(input)
	mut par := parser.Parser.new(lex)
	prog := par.parse_program()
	mut env := object.Environment.new()
	return eval(prog, mut env)
}

fn boolean_object_test(obj object.Object, expected bool) bool {
	res := obj as object.Boolean
	assert res.value == expected, 'object has wrong val, got: ${res.value}, wanted: ${expected}'
	return true
}

fn int_object_test(obj object.Object, expected int) bool {
	res := obj as object.Integer
	assert res.value == expected, 'object has wrong val, got: ${res.value}, wanted: ${expected}'
	return true
}

fn null_object_test(obj object.Object) bool {
	_ := obj as object.Null
	// {panic('object is not null, got: ${obj} (${typeof(obj).name})')}
	return true
}
