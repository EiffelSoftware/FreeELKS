indexing
	description: "Real values, double precision" 
	library: "Free implementation of ELKS library"
	copyright: "Copyright (c) 1986-2004, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

expanded class DOUBLE inherit

	DOUBLE_REF

create
	default_create,
	make_from_reference

convert
	make_from_reference ({DOUBLE_REF}),
	to_reference: {DOUBLE_REF, NUMERIC, COMPARABLE, PART_COMPARABLE, HASHABLE, ANY},
	truncated_to_real: {REAL}

end -- class DOUBLE
