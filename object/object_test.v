module object

fn test_string_hash_key() {
	hello_1 := String{
		value: 'Hello World'
	}
	hello_2 := String{
		value: 'Hello World'
	}
	diff_1 := String{
		value: 'My name is johnny'
	}
	diff_2 := String{
		value: 'My name is johnny'
	}
	assert hello_1.hash_key() == hello_2.hash_key(), 'strings with same content have different hash keys'
	assert diff_1.hash_key() == diff_2.hash_key(), 'strings with same content have different hash keys'
	assert diff_1.hash_key() != hello_1.hash_key(), 'strings with different content have same hash keys'
}

fn test_int_hash_key() {
	hello_1 := Integer{
		value: 1
	}
	hello_2 := Integer{
		value: 1
	}
	diff_1 := Integer{
		value: 100
	}
	diff_2 := Integer{
		value: 100
	}
	assert hello_1.hash_key() == hello_2.hash_key(), 'strings with same content have different hash keys'
	assert diff_1.hash_key() == diff_2.hash_key(), 'strings with same content have different hash keys'
	assert diff_1.hash_key() != hello_1.hash_key(), 'strings with different content have same hash keys'
}

fn test_bool_hash_key() {
	hello_1 := Boolean{
		value: true
	}
	hello_2 := Boolean{
		value: true
	}
	diff_1 := Boolean{
		value: false
	}
	diff_2 := Boolean{
		value: false
	}
	assert hello_1.hash_key() == hello_2.hash_key(), 'strings with same content have different hash keys'
	assert diff_1.hash_key() == diff_2.hash_key(), 'strings with same content have different hash keys'
	assert diff_1.hash_key() != hello_1.hash_key(), 'strings with different content have same hash keys'
}
