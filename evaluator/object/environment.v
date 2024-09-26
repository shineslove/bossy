module object

@[heap]
pub struct Environment {
mut:
	store map[string]Object
	outer ?&Environment
}

pub fn Environment.new() &Environment {
	st := map[string]Object{}
	return &Environment{
		store: st
	}
}

pub fn (env Environment) get(name string) ?Object {
	if obj := env.store[name] {
		return obj
	}
	return match env.outer {
		none { none }
		else { env.outer?.get(name) }
	}
}

pub fn (mut env Environment) set(name string, val Object) Object {
	env.store[name] = val
	return val
}

pub fn new_enclosed_environment(outer &Environment) &Environment {
	mut env := Environment.new()
	env.outer = outer
	return env
}
