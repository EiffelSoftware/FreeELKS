indexing
	description: "Truth values, with the boolean operations"
	library: "Free implementation of ELKS library"
	copyright: "Copyright (c) 1986-2004, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

expanded class BOOLEAN

inherit
	BOOLEAN_REF

create
	default_create,
	make_from_reference

convert
	make_from_reference ({BOOLEAN_REF}),
	to_reference: {BOOLEAN_REF, HASHABLE, ANY}

end -- class BOOLEAN



