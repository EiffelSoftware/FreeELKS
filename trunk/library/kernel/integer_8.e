indexing
	description: "Integer values coded on 8 bits"
	library: "Free implementation of ELKS library"
	copyright: "Copyright (c) 1986-2004, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

expanded class INTEGER_8 inherit

	INTEGER_8_REF

create
	default_create,
	make_from_reference

convert
	make_from_reference ({INTEGER_8_REF}),
	to_reference: {INTEGER_8_REF, NUMERIC, COMPARABLE, PART_COMPARABLE, HASHABLE, ANY},
	to_real: {REAL},
	to_double: {DOUBLE},
	to_integer_16: {INTEGER_16},
	to_integer_32: {INTEGER},
	to_integer_64: {INTEGER_64}

end
