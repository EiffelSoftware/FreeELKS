note
	description: "Concrete of an external iteration cursor for {LINKED_LIST}. Reversed traversal has a `(n (n + 1)) / 2' operations cost."
	library: "EiffelBase: Library of reusable components for Eiffel."
	copyright: "Copyright (c) 1984-2009, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class
	LINKED_LIST_ITERATION_CURSOR [G]

inherit
	INDEXABLE_ITERATION_CURSOR [G]
		redefine
			start,
			item,
			off,
			forth,
			target
		end

create
	make

feature -- Access

	item: G
			-- <Precursor>
		local
			l_active: like active
		do
			if is_reversed then
				Result := Precursor
			else
				l_active := active
					-- Required because `start' sets `active' and `active' can become detached
					-- when falling off the end of the list.
				check l_active_attached: attached l_active end
				Result := l_active.item
			end
		end

feature -- Status report

	off: BOOLEAN
			-- <Precursor>
		do
			if is_reversed then
				Result := Precursor
			else
				Result := active = Void
			end
		end

feature -- Cursor movement

	start
			-- <Precursor>
		do
			Precursor
			if not is_reversed then
				active := target.first_element
			end
		end

	forth
			-- <Precursor>
		local
			i: like step
		do
			Precursor
			if not is_reversed then
				from
					i := 1
				until
					i > step or else not attached active as l_active
				loop
					active := l_active.right
					i := i + 1
				end
			end
		end

feature {NONE} -- Implementation

	active: detachable LINKABLE [G]
			-- Currrently active linkable node for ascending traversal

	target: LINKED_LIST [G]
			-- <Precursor>

end
