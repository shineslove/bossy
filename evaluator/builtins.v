module evaluator

import object

const builtins = {
	'len':   object.Builtin{
		func: fn (args ...object.Object) object.Object {
			if args.len != 1 {
				return new_error('wrong number of arguments. got', '${args.len}, want: 1')
			}
			arg := args[0]
			return match arg {
				object.String {
					object.Integer{
						value: arg.value.len
					}
				}
				object.Array {
					object.Integer{
						value: arg.elements.len
					}
				}
				else {
					new_error("argument to 'len' not supported, got", '${arg.kind()}')
				}
			}
		}
	}
	'first': object.Builtin{
		func: fn (args ...object.Object) object.Object {
			if args.len != 1 {
				return new_error('wrong number of arguments. got', '${args.len}, want: 1')
			}
			if args[0].kind() != .array {
				return new_error("argument to 'first' must be array, got", args[0].kind().str())
			}
			arr := args[0] as object.Array
			if arr.elements.len > 0 {
				return arr.elements[0]
			}
			return null
		}
	}
	'last':  object.Builtin{
		func: fn (args ...object.Object) object.Object {
			if args.len != 1 {
				return new_error('wrong number of arguments. got', '${args.len}, want: 1')
			}
			if args[0].kind() != .array {
				return new_error("argument to 'last' must be array, got", args[0].kind().str())
			}
			arr := args[0] as object.Array
			length := arr.elements.len
			if length > 0 {
				return arr.elements[length - 1]
			}
			return null
		}
	}
	'rest':  object.Builtin{
		func: fn (args ...object.Object) object.Object {
			if args.len != 1 {
				return new_error('wrong number of arguments. got', '${args.len}, want: 1')
			}
			if args[0].kind() != .array {
				return new_error("argument to 'rest' must be array, got", args[0].kind().str())
			}
			arr := args[0] as object.Array
			if arr.elements.len > 0 {
				return object.Array{
					elements: arr.elements[1..]
				}
			}
			return null
		}
	}
	'push':  object.Builtin{
		func: fn (args ...object.Object) object.Object {
			if args.len != 2 {
				return new_error('wrong number of arguments. got', '${args.len}, want: 2')
			}
			if args[0].kind() != .array {
				return new_error("argument to 'push' must be array, got", args[0].kind().str())
			}
			arr := args[0] as object.Array
			mut new_elements := arr.elements.clone()
			new_elements << args[1]
			return object.Array{
				elements: new_elements
			}
		}
	}
}
