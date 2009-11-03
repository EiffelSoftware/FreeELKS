note
	description: "[
		Concrete of an external iteration cursor for {ARRAY}.
		]"
	library: "Free implementation of ELKS library"
	date: "$Date$"
	revision: "$Revision$"

class
	ARRAY_ITERATION_CURSOR [G]

inherit
	ITERATION_CURSOR [G]

create
	make

feature {NONE} -- Initialization

	make (a_array: like array)
			-- Initialize cursor using a {ARRAY} based array `a_array'.
		require
			a_array_attached: attached a_array
		do
			array := a_array
		ensure
			array_set: array = a_array
		end

feature -- Access

	item: G
			-- <Precursor>
		do
			Result := array[index.to_integer_32]
		end

	index: INTEGER
			-- <Precursor>

feature -- Status report

	after: BOOLEAN
			-- <Precursor>
		do
			Result := index > array.upper
		end

feature -- Cursor movement

	start
			-- <Precursor>
		do
			index := array.lower
		end

	forth
			-- <Precursor>
		do
			index := index + 1
		end

feature {NONE} -- Implementation

	array: ARRAY [G]
			-- Structure to iterate over.

invariant
	array_attached: attached array

note
	copyright: "Copyright (c) 1984-2009, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"

end
