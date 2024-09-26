module object
import ast

pub enum Obj {
	integer
	boolean
	null
	@return
	error
	function
}

pub type Object = Integer | Boolean | Null | Return | Err | Function

pub fn (ob Object) kind() Obj {
	return match ob {
		Integer { .integer }
		Boolean { .boolean }
		Null { .null }
		Return { .@return }
		Err { .error }
		Function { .function }
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
	}
}

pub struct Integer {
pub:
	value int
}

fn (itr Integer) str() string {
	return itr.value.str()
}

pub struct Boolean {
pub:
	value bool
}

fn (boo Boolean) str() string {
	return boo.value.str()
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
	body ast.BlockStatement
	env Environment
}

fn (fun Function) str() string {
	mut output := ""
	mut params := []string{}
	for param in params {
		params << param.str()
	}
	output += "fn"
	output += "("
	output += params.join(', ')
	output += ") {\n"
	output += '${fun.body}'
	output += "\n}"
	return output
}



