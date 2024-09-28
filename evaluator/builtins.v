module evaluator

import object

const builtins = {
	'len': object.Builtin{
		func: fn (args ...object.Object) object.Object {
			if args.len != 1 {
				return new_error('wrong number of arguments. got','${args.len}, want: 1')
			}
			arg := args[0]
			return match arg {
				object.String { object.Integer{value: arg.value.len}}
				else { new_error("argument to 'len' not supported, got",'${arg.kind()}')}
			}
		}
	}
}
