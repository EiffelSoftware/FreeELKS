note
	description: "[
		Concrete of an external iteration cursor for {ARRAY}.
		]"
	library: "Free implementation of ELKS library"
	date: "$Date$"
	revision: "$Revision$"

class
	INDEXABLE_ITERATION_CURSOR [G]

inherit
	ITERATION_CURSOR [G]

create
	make

feature {NONE} -- Initialization

	make (a_indexable: like indexable)
			-- Initialize cursor using a {ARRAY} based indexable `a_indexable'.
		require
			a_indexable_attached: attached a_indexable
		do
			indexable := a_indexable
		ensure
			indexable_set: indexable = a_indexable
		end

feature -- Access

	item: G
			-- <Precursor>
		local
			l_indexable: like indexable
		do
			l_indexable := indexable
			Result := l_indexable[(index + l_indexable.index_set.lower - 1)]
		end

	index: INTEGER
			-- <Precursor>

feature -- Status report

	after: BOOLEAN
			-- <Precursor>
		do
			Result := index > indexable.index_set.count
		ensure then
			index_small_enough: not Result implies index <= indexable.index_set.count
		end

feature -- Cursor movement

	start
			-- <Precursor>
		do
			index := 1
		end

	forth
			-- <Precursor>
		do
			index := index + 1
		end

feature {NONE} -- Implementation

	indexable: INDEXABLE [G, INTEGER_32]
			-- Structure to iterate over.

invariant
	indexable_attached: attached indexable

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
