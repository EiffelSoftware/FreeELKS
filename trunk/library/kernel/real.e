indexing
	description: "Real values, single precision" 
	library: "Free implementation of ELKS library"
	copyright: "Copyright (c) 1986-2004, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

expanded class REAL inherit

	REAL_REF

create
	default_create,
	make_from_reference

convert
	make_from_reference ({REAL_REF}),
	to_reference: {REAL_REF, NUMERIC, COMPARABLE, PART_COMPARABLE, HASHABLE, ANY},
	to_double: {DOUBLE}

end -- class REAL
