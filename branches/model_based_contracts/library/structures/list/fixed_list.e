indexing

	description:
		"Lists with fixed maximum numbers of items, implemented by arrays"
	legal: "See notice at end of class."

	status: "See notice at end of class."
	names: fixed, sequence;
	representation: array;
	access: index, cursor, membership;
	contents: generic;
	model: sequence, index, capacity, object_comparison; -- extendible, prunable?
	date: "$Date$"
	revision: "$Revision$"

class FIXED_LIST [G] inherit

	LIST [G]
		export
			{ANY}
				put
			{NONE}
				force, extend,
				fill,
				prune, prune_all
		undefine
			force, prune, infix "@", put_i_th,
			prune_all, copy, i_th
		redefine
			first,
			last,
			swap,
			duplicate,
			move,
			start,
			finish,
			go_i_th,
			put,
			remove
		select
			extendible, index_set, sequence
		end

	ARRAY [G]
		rename
			make as array_make,
			put as put_i_th,
			item as i_th alias "[]",
			force as force_i_th,
			bag_put as put,
			index_set as array_index_set,
			extendible as array_extendible
		export
			{NONE}
				all
			{ANY}
				i_th,
				put_i_th,
				infix "@",
				is_equal,
				occurrences,
				valid_index,
				copy,
				area,
				has
			{FIXED_LIST, FIXED_TREE}
				array_make, lower, upper, subarray
		undefine
			count, linear_representation, put, resizable, fill,
			for_all, there_exists, do_all, do_if, occurrences, has,
			valid_index, is_equal
		redefine
			full, extend, prunable
		end

	FIXED [G]
		undefine
			copy, is_equal,
			full,
			bag
		end

create

	make, make_filled

feature -- Initialization

	make (n: INTEGER) is
			-- Create an empty list.
		do
			array_make (1, n)
			count := 0
		ensure
			is_before: before
			new_count: count = 0
		-- ensure: model
			sequence_effect: sequence.is_empty
			index_effect: index = 0
			capacity_effect: capacity = n
			object_comparison_effect: not object_comparison
		end

	make_filled (n: INTEGER) is
			-- Create a list with `n' void elements.
		do
			array_make (1, n)
			count := n
		ensure
			is_before: before
			new_count: count = n
		-- ensure: model
			sequence_domain_effect: sequence.count = n
			sequence_range_effect: sequence.for_all (agent is_default)
			index_effect: index = 0
			capacity_effect: capacity = n
			object_comparison_effect: not object_comparison
		end

feature -- Access

	index: INTEGER
		-- Current position in the list

	item: G is
			-- Current item
		do
			Result := area.item (index - 1)
		end

	first: G is
			-- Item at first position
		do
			Result := area.item (0)
		end

	last: like first is
			-- Item at last position
		do
			Result := area.item (count - 1)
		end

	cursor: ARRAYED_LIST_CURSOR is
			-- Current cursor position
		do
			create Result.make (index)
		end

feature -- Measurement

	count: INTEGER

feature -- Status report

	extendible: BOOLEAN is
			-- May new items be added?
		do
			Result := (count < capacity)
		ensure then
		-- ensure then: model
			definition: Result = (sequence.count < capacity)
		end

	prunable: BOOLEAN is
			-- May items be removed?
		do
			Result := not is_empty
		ensure then
		-- ensure then: model
			definition: Result = not sequence.is_empty
		end

	full: BOOLEAN is
			-- Is the list full?
		do
			Result := count = capacity
		end

	valid_cursor (p: CURSOR): BOOLEAN is
			-- Is `p' a valid cursor?
		do
			if {fl_c: ARRAYED_LIST_CURSOR} p then
				Result := valid_cursor_index (fl_c.index)
			end
		end

feature -- Cursor movement

	move (i: INTEGER) is
			-- Move cursor `i' positions.
		do
			index := index + i
			if (index > count + 1) then
				index := count + 1
			elseif index < 0 then
				index := 0
			end
		end

	start is
			-- Move cursor to first position.
		do
			index := 1
		end

	finish is
			-- Move cursor to last position.
		do
			index := count
		end

	forth is
			-- Move cursor to next position, if any.
		do
			index := index + 1
		end

	back is
			-- Move cursor to previous position, if any.
		do
			index := index - 1
		end

	go_i_th (i: INTEGER) is
			-- Move cursor to `i'-th position.
		do
			index := i
		end

	go_to (p: CURSOR) is
			-- Move cursor to element remembered in `p'.
		do
			if {fl_c: ARRAYED_LIST_CURSOR} p then
				index := fl_c.index
			end
		end

feature -- Element change

	put (v: like first) is
			-- Replace current item by `v'.
			-- (Synonym for `replace')
		require else
			True
		do
			replace (v)
		end

	replace (v: like first) is
			-- Replace current item by `v'.
		do
			put_i_th (v, index)
		end

	extend (v: like item) is
			-- Add `v' to end.
			-- Move index to the current item.
		do
			count := count + 1
			index := count
			force_i_th (v, count)
		ensure then
		-- ensure then: model
			index_effect: index = old sequence.count + 1
		end

	remove is
			-- Remove current item.
			-- Move cursor to right neighbor
			-- (or `after' if no right neighbor)
		local
			i, j: INTEGER
		do
			if not off then
				from
					i := index - 1
				until
					i >= count - 1
				loop
					j := i + 1
					area.put (area.item (j), i)
					i := j
				end
				area.put_default (i)
				count := count - 1
			end
		end

feature -- Transformation

	swap (i: INTEGER) is
			-- Exchange item at `i'-th position with item
			-- at cursor position.
		local
			old_item: like item
		do
			old_item := item
			replace (i_th (i))
			put_i_th (old_item, i)
		end

feature -- Duplication

	duplicate (n: INTEGER): like Current is
			-- Copy of sub-list beginning at cursor position
			-- and having min (`n', `count' - `index' + 1) items
		local
			pos: INTEGER
		do
			create Result.make_filled (n.min (count - index + 1))
			from
				Result.start
				pos := index
			until
				Result.exhausted
			loop
				Result.replace (item)
				forth
				Result.forth
			end
			Result.start
			index := pos
		ensure then
		-- ensure: model
			index_definition: Result.index = 1
			capacity_definition: Result.capacity = n.min (sequence.count - index + 1)
			object_comparison_definition: not Result.object_comparison
		end

feature {NONE} -- Implementation

	force (v: like item) is
			-- Not used since extend is not always applicable.
		do
		end

invariant

	empty_means_storage_empty: is_empty implies all_default

-- invariant: model
	relation_is_sequence: relation.domain.as_range.lower = 1
	relation_range_head: relation.as_sequence.interval (1, count) |=| sequence
	sequence_capacity_constraint: sequence.count <= capacity

indexing
	library:	"EiffelBase: Library of reusable components for Eiffel."
	copyright:	"Copyright (c) 1984-2008, Eiffel Software and others"
	license:	"Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Eiffel Software
			 356 Storke Road, Goleta, CA 93117 USA
			 Telephone 805-685-1006, Fax 805-685-6869
			 Website http://www.eiffel.com
			 Customer support http://support.eiffel.com
		]"







end -- class FIXED_LIST



