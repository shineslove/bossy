module object

import hash
import ast

pub enum Obj {
	integer
	boolean
	null
	@return
	error
	function
	string
	builtin
	array
	hash
}

pub struct Array {
pub mut:
	elements []Object
}

fn (arr Array) str() string {
	mut output := ''
	mut elements := []string{}
	for el in arr.elements {
		elements << el.inspect()
	}
	output += '['
	output += elements.join(', ')
	output += ']'
	return output
}

pub type BuiltinFunction = fn (args ...Object) Object

pub struct Builtin {
pub:
	func BuiltinFunction @[required]
}

fn (bu Builtin) str() string {
	return 'builtin function'
}

pub fn hashable(ob Object) bool {
	return ob in [String, Integer, Boolean]
}

pub type Object = Null
	| Hash
	| Array
	| Builtin
	| String
	| Integer
	| Boolean
	| Return
	| Err
	| Function

pub fn (ob Object) kind() Obj {
	return match ob {
		Integer { .integer }
		Boolean { .boolean }
		Null { .null }
		Return { .@return }
		Err { .error }
		Function { .function }
		String { .string }
		Builtin { .builtin }
		Array { .array }
		Hash { .hash }
	}
}

pub fn (ob Object) inspect() string {
	return match ob {
		Integer { ob.str() }
		Boolean { ob.str() }
		Null { ob.str() }
		Return { ob.str() }
		Err { ob.str() }
		Function { ob.str() }
		String { ob.str() }
		Builtin { ob.str() }
		Array { ob.str() }
		Hash { ob.str() }
	}
}

pub fn (ob Object) hash_key() u64 {
	return match ob {
		Integer { ob.hash_key() }
		Boolean { ob.hash_key() }
		String { ob.hash_key() }
		else { panic("you can't do this buddy!!") }
	}
}

struct HashKey {
	kind  Obj
	value Object
}

pub struct HashPair {
pub:
	key   Object
	value Object
}

pub struct Hash {
pub:
	pairs map[u64]HashPair
}

fn (hh Hash) str() string {
	mut output := ''
	mut pairs := []string{}
	for _, pair in hh.pairs {
		pairs << '${pair.key.inspect()}: ${pair.value.inspect()}'
	}
	output += '{'
	output += pairs.join(', ')
	output += '}'
	return output
}

pub struct String {
pub:
	value string
}

fn (st String) str() string {
	return st.value.str()
}

pub fn (st String) hash_key() u64 {
	return hash.sum64_string(HashKey{ kind: .string, value: st }.str(), 1_000)
}

pub struct Integer {
pub:
	value int
}

fn (itr Integer) str() string {
	return itr.value.str()
}

pub fn (itr Integer) hash_key() u64 {
	return hash.sum64_string(HashKey{ kind: .integer, value: itr }.str(), 1_000)
}

pub struct Boolean {
pub:
	value bool
}

fn (boo Boolean) str() string {
	return boo.value.str()
}

pub fn (boo Boolean) hash_key() u64 {
	return hash.sum64_string(HashKey{ kind: .boolean, value: boo }.str(), 1_000)
}

pub struct Null {}

fn (nul Null) str() string {
	return 'null'
}

pub struct Return {
pub:
	value Object
}

fn (rt Return) str() string {
	return rt.value.inspect()
}

pub struct Err {
pub:
	message string
}

fn (e Err) str() string {
	return 'ERROR: ${e.message}'
}

pub struct Function {
pub:
	parameters []ast.Identifier
	body       ast.BlockStatement
	env        Environment
}

fn (fun Function) str() string {
	mut output := ''
	mut params := []string{}
	for param in params {
		params << param.str()
	}
	output += 'fn'
	output += '('
	output += params.join(', ')
	output += ') {\n'
	output += '${fun.body}'
	output += '\n}'
	return output
}
