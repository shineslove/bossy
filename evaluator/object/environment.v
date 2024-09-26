module object

pub struct Environment {
mut:
  store map[string]Object
}

pub fn Environment.new() Environment {
	st := map[string]Object{}
	return Environment {store: st}
}

pub fn (env Environment) get(name string) ?Object{
	return env.store[name] or { none }
}

pub fn (mut env Environment) set(name string, val Object) Object{
	env.store[name] = val
	return val
}
