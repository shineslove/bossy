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

fn eval_test(input string) ?object.Object {
	lex := lexer.Lexer.new(input)
	mut par := parser.Parser.new(lex)
	prog := par.parse_program()
	return eval(prog)
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
