indexing
	description: "Integer values coded on 64 bits"
	library: "Free implementation of ELKS library"
	copyright: "Copyright (c) 1986-2004, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

expanded class INTEGER_64

inherit
	INTEGER_64_REF

create
	default_create,
	make_from_reference

convert
	make_from_reference ({INTEGER_64_REF}),
	to_reference: {INTEGER_64_REF, NUMERIC, COMPARABLE, PART_COMPARABLE, HASHABLE, ANY},
	to_real: {REAL},
	to_double: {DOUBLE}

end -- class INTEGER_64
