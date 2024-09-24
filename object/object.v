module object

enum Obj {
	integer
	boolean
}

type Object = Integer | Boolean

fn (ob Object) kind() Obj {
	return match ob {
		Integer { .integer }
		Boolean { .boolean }
	}
}

fn (ob Object) inspect() string {
	return match ob {
		Integer { ob.str() }
		Boolean { ob.str() }
	}
}

struct Integer {
	value int
}

fn (itr Integer) str() string {
	return itr.value.str()
}

struct Boolean {
	value bool
}

fn (boo Boolean) str() string {
	return boo.value.str()
}
