indexing
	description: "References to objects meant to be exchanged with non-Eiffel software."
	library: "Free implementation of ELKS library"
	copyright: "Copyright (c) 1986-2004, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

expanded class POINTER inherit

	POINTER_REF

create
	default_create,
	make_from_reference

convert
	make_from_reference ({POINTER_REF}),
	to_reference: {POINTER_REF, HASHABLE, ANY}

end -- class POINTER
