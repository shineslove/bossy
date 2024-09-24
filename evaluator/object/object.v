module object

pub enum Obj {
	integer
	boolean
	null
}

pub type Object = Integer | Boolean | Null

pub fn (ob Object) kind() Obj {
	return match ob {
		Integer { .integer }
		Boolean { .boolean }
		Null { .null }
	}
}

pub fn (ob Object) inspect() string {
	return match ob {
		Integer { ob.str() }
		Boolean { ob.str() }
		Null { ob.str() }
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
