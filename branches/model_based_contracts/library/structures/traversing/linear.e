indexing

	description:
		"Structures whose items may be accessed sequentially, one-way"
	legal: "See notice at end of class."

	status: "See notice at end of class."
	names: sequential, traversing;
	access: membership;
	contents: generic;
	model: sequence, index, object_comparison;
	date: "$Date$"
	revision: "$Revision$"

deferred class LINEAR [G] inherit

	TRAVERSABLE [G]
		redefine
			item, do_all, do_if, there_exists, for_all
		end

feature -- Access

	item: G is
			-- Item at current position
		deferred
		ensure then
		-- ensure then: model
			definition: Result = sequence.item (index)
		end

	has (v: like item): BOOLEAN is
			-- Does structure include an occurrence of `v'?
			-- (Reference or object equality,
			-- based on `object_comparison'.)
		do
			start
			if not off then
				search (v)
			end
			Result := not exhausted
		end

	index_of (v: like item; i: INTEGER): INTEGER is
			-- Index of `i'-th occurrence of `v'.
			-- 0 if none.
			-- (Reference or object equality,
			-- based on `object_comparison'.)
		require
			positive_occurrences: i > 0
		local
			occur, pos: INTEGER
			w: like item
		do
			if object_comparison and v /= Void then
				from
					start
					pos := 1
				until
					exhausted or (occur = i)
				loop
					w := item
					if w /= Void and then v.is_equal (w) then
						occur := occur + 1
					end
					forth
					pos := pos + 1
				end
			else
				from
					start
					pos := 1
				until
					exhausted or (occur = i)
				loop
					if item = v then
						occur := occur + 1
					end
					forth
					pos := pos + 1
				end
			end
			if occur = i then
				Result := pos - 1
			end
		ensure
			non_negative_result: Result >= 0
		-- ensure: model
			definition_reference_comparison_has: not object_comparison and sequence.occurrences (v) >= i implies Result = sequence.index_of_i_th_occurrence_of (v, i)
			definition_reference_comparison_not_has: not object_comparison and sequence.occurrences (v) < i implies Result = 0
			definition_object_comparison_has: object_comparison and sequence.hold_count (agent equal_elements (v, ?)) >= i implies Result = sequence.index_of_i_th_that (agent equal_elements (v, ?), i)
			definition_object_comparison_not_has: object_comparison and sequence.hold_count (agent equal_elements (v, ?)) < i implies Result = 0
		end

	search (v: like item) is
			-- Move to first position (at or after current
			-- position) where `item' and `v' are equal.
			-- (Reference or object equality,
			-- based on `object_comparison'.)
			-- If no such position ensure that `exhausted' will be true.
		local
			i: like item
		do
			if object_comparison and v /= Void then
				if not exhausted then
					from
						i := item
					until
						exhausted or else (i /= Void and then v.is_equal (i))
					loop
						forth
						if not exhausted then
							i := item
						end
					end
				end
			else
				from
				until
					exhausted or else v = item
				loop
					forth
				end
			end
		ensure
			object_found: (not exhausted and object_comparison)
				 implies equal (v, item)
			item_found: (not exhausted and not object_comparison)
				 implies v = item
		-- ensure: model
			index_effect_reference_comparison_has: not object_comparison and sequence.interval (old index, sequence.count).is_member (v) implies index = old index + sequence.interval (old index, sequence.count).index_of_i_th_occurrence_of (v, 1) - 1
			index_effect_reference_comparison_not_has: not object_comparison and not sequence.interval (old index, sequence.count).is_member (v) implies index = sequence.count + 1
			index_effect_object_comparison_has: object_comparison and sequence.interval (old index, sequence.count).there_exists (agent equal_elements (v, ?)) implies index = old index + sequence.interval (old index, sequence.count).index_of_i_th_that (agent equal_elements (v, ?), 1) - 1
			index_effect_object_comparison_not_has: object_comparison and not sequence.interval (old index, sequence.count).there_exists (agent equal_elements (v, ?)) implies index = sequence.count + 1
		end

	index: INTEGER is
			-- Index of current position
		deferred
		end

	occurrences (v: like item): INTEGER is
			-- Number of times `v' appears.
			-- (Reference or object equality,
			-- based on `object_comparison'.)
		do
			from
				start
				search (v)
			until
				exhausted
			loop
				Result := Result + 1
				forth
				search (v)
			end
		end

	item_for_iteration: G is
			-- Item at current position
		require
			not_off: not off
		do
			Result := item
		ensure
		-- ensure: model
			definition: Result = sequence.item (index)
		end

feature -- Status report

	exhausted: BOOLEAN is
			-- Has structure been completely explored?
		do
			Result := off
		ensure
			exhausted_when_off: off implies Result
		-- ensure: model
			definition: Result /= sequence.is_defined (index)
		end

	after: BOOLEAN is
			-- Is there no valid position to the right of current one?
		deferred
		ensure
		-- ensure: model
			definition: Result = (index > sequence.count)
		end

	off: BOOLEAN is
			-- Is there no current item?
		do
			Result := is_empty or after
		ensure then
		-- ensure then: model
			definition: Result /= sequence.is_defined (index)
		end

feature -- Cursor movement
	start is
			-- Move to first position if any.
		deferred
		ensure then
		-- ensure then: model
			index_effect: not sequence.is_empty implies index = 1
		end

	finish is
			-- Move to last position.
		deferred
		ensure
		-- ensure: model
			index_effect: index = sequence.count
		end

	forth is
			-- Move to next position; if no next position,
			-- ensure that `exhausted' will be true.
		require
			not_after: not after
		deferred
		ensure
			-- moved_forth_before_end: (not after) implies index = old index + 1
		-- ensure: model
			index_effect: index = old index + 1
		end

feature -- Iteration

	do_all (action: PROCEDURE [ANY, TUPLE [G]]) is
			-- Apply `action' to every item.
			-- Semantics not guaranteed if `action' changes the structure;
			-- in such a case, apply iterator to clone of structure instead.
		local
			t: TUPLE [G]
			c: ?CURSOR
			cs: ?CURSOR_STRUCTURE [G]
		do
			if {acs: CURSOR_STRUCTURE [G]} Current then
				cs := acs
				c := acs.cursor
			end

			create t
			from
				start
			until
				after
			loop
				t.put (item, 1)
				action.call (t)
				forth
			end

			if cs /= Void and c /= Void then
				cs.go_to (c)
			end
		end

	do_if (action: PROCEDURE [ANY, TUPLE [G]]; test: FUNCTION [ANY, TUPLE [G], BOOLEAN]) is
			-- Apply `action' to every item that satisfies `test'.
			-- Semantics not guaranteed if `action' or `test' changes the structure;
			-- in such a case, apply iterator to clone of structure instead.
		local
			t: TUPLE [G]
			c: ?CURSOR
			cs: ?CURSOR_STRUCTURE [G]
		do
			if {acs: CURSOR_STRUCTURE [G]} Current then
				cs := acs
				c := acs.cursor
			end

			create t
			from
				start
			until
				after
			loop
				t.put (item, 1)
				if test.item (t) then
					action.call (t)
				end
				forth
			end

			if cs /= Void and c /= Void then
				cs.go_to (c)
			end
		end

	there_exists (test: FUNCTION [ANY, TUPLE [G], BOOLEAN]): BOOLEAN is
			-- Is `test' true for at least one item?
			-- Semantics not guaranteed if `test' changes the structure;
			-- in such a case, apply iterator to clone of structure instead.
		local
			c: ?CURSOR
			cs: ? CURSOR_STRUCTURE [G]
			t: TUPLE [G]
		do
			create t

			if {acs: CURSOR_STRUCTURE [G]} Current then
				cs := acs
				c := acs.cursor
			end

			from
				start
			until
				after or Result
			loop
				t.put (item, 1)
				Result := test.item (t)
				forth
			end

			if cs /= Void and c /=Void then
				cs.go_to (c)
			end
		end

	for_all (test: FUNCTION [ANY, TUPLE [G], BOOLEAN]): BOOLEAN is
			-- Is `test' true for all items?
			-- Semantics not guaranteed if `test' changes the structure;
			-- in such a case, apply iterator to clone of structure instead.
		local
			c: ?CURSOR
			cs: ? CURSOR_STRUCTURE [G]
			t: TUPLE [G]
		do
			create t

			if {acs: CURSOR_STRUCTURE [G]} Current then
				cs := acs
				c := acs.cursor
			end

			from
				start
				Result := True
			until
				after or not Result
			loop
				t.put (item, 1)
				Result := test.item (t)
				forth
			end

			if cs /= Void and c /= Void then
				cs.go_to (c)
			end
		ensure then
			empty: is_empty implies Result
		end

feature -- Conversion

	linear_representation: LINEAR [G] is
			-- Representation as a linear structure
		do
			Result := Current
		ensure then
		-- ensure then: model
			same_sequence: Result.sequence |=| sequence
		end

feature -- Model
	sequence: MML_SEQUENCE [G] is
			-- Contents of traversable structure
		local
			linear: LINEAR [G]
		do
			create {MML_DEFAULT_SEQUENCE [G]} Result
			linear := linear_representation.twin
			from
				linear.start
			until
				linear.off
			loop
				Result := Result.extended (linear.item)
				linear.forth
			end
		end

invariant

	after_constraint: after implies off

-- invariant: model
	sequnece_bag_constraint: bag |=| sequence.to_bag
	index_not_too_small: index >= 0
	index_not_too_large: index <= sequence.count + 1

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







end -- class LINEAR



