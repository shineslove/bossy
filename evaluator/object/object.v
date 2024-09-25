module object

pub enum Obj {
	integer
	boolean
	null
	@return
}

pub type Object = Integer | Boolean | Null | Return

pub fn (ob Object) kind() Obj {
	return match ob {
		Integer { .integer }
		Boolean { .boolean }
		Null { .null }
		Return { .@return }
	}
}

pub fn (ob Object) inspect() string {
	return match ob {
		Integer { ob.str() }
		Boolean { ob.str() }
		Null { ob.str() }
		Return { ob.str() }
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
