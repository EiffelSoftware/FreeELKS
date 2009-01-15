indexing
	description: "Implementation of TUPLE"
	library: "Free implementation of ELKS library"
	copyright: "Copyright (c) 1986-2008, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class
	TUPLE

inherit
	HASHABLE
		redefine
			is_equal
		end

	MISMATCH_CORRECTOR
		redefine
			correct_mismatch, is_equal
		end

create
	default_create, make

feature -- Creation

	make is
		obsolete
			"Use no creation procedure to create a TUPLE instance"
		do
		end

feature -- Access

	item alias "[]", infix "@" (index: INTEGER): ?ANY assign put is
			-- Entry of key `index'.
		require
			valid_index: valid_index (index)
		do
			inspect eif_item_type ($Current, index)
			when boolean_code then Result := eif_boolean_item ($Current, index)
			when character_8_code then Result := eif_character_8_item ($Current, index)
			when character_32_code then Result := eif_character_32_item ($Current, index)
			when real_64_code then Result := eif_real_64_item ($Current, index)
			when real_32_code then Result := eif_real_32_item ($Current, index)
			when pointer_code then Result := eif_pointer_item ($Current, index)
			when natural_8_code then Result := eif_natural_8_item ($Current, index)
			when natural_16_code then Result := eif_natural_16_item ($Current, index)
			when natural_32_code then Result := eif_natural_32_item ($Current, index)
			when natural_64_code then Result := eif_natural_64_item ($Current, index)
			when integer_8_code then Result := eif_integer_8_item ($Current, index)
			when integer_16_code then Result := eif_integer_16_item ($Current, index)
			when integer_32_code then Result := eif_integer_32_item ($Current, index)
			when integer_64_code then Result := eif_integer_64_item ($Current, index)
			when Reference_code then Result := eif_reference_item ($Current, index)
			end
		end

	reference_item (index: INTEGER): ?ANY is
			-- Reference item at `index'.
		require
			valid_index: valid_index (index)
			is_reference: is_reference_item (index)
		do
			Result := eif_reference_item ($Current, index)
		end

	boolean_item (index: INTEGER): BOOLEAN is
			-- Boolean item at `index'.
		require
			valid_index: valid_index (index)
			is_boolean: is_boolean_item (index)
		do
			Result := eif_boolean_item ($Current, index)
		end

	character_8_item, character_item (index: INTEGER): CHARACTER_8 is
			-- Character item at `index'.
		require
			valid_index: valid_index (index)
			is_character_8: is_character_8_item (index)
		do
			Result := eif_character_8_item ($Current, index)
		end

	character_32_item, wide_character_item (index: INTEGER): CHARACTER_32 is
			-- Character item at `index'.
		require
			valid_index: valid_index (index)
			is_character_32: is_character_32_item (index)
		do
			Result := eif_character_32_item ($Current, index)
		end

	real_64_item, double_item (index: INTEGER): REAL_64 is
			-- Double item at `index'.
		require
			valid_index: valid_index (index)
			is_numeric: is_double_item (index)
		do
			Result := eif_real_64_item ($Current, index)
		end

	natural_8_item (index: INTEGER): NATURAL_8 is
			-- NATURAL_8 item at `index'.
		require
			valid_index: valid_index (index)
			is_integer: is_natural_8_item (index)
		do
			Result := eif_natural_8_item ($Current, index)
		end

	natural_16_item (index: INTEGER): NATURAL_16 is
			-- NATURAL_16 item at `index'.
		require
			valid_index: valid_index (index)
			is_integer: is_natural_16_item (index)
		do
			Result := eif_natural_16_item ($Current, index)
		end

	natural_32_item (index: INTEGER): NATURAL_32 is
			-- NATURAL_32 item at `index'.
		require
			valid_index: valid_index (index)
			is_integer: is_natural_32_item (index)
		do
			Result := eif_natural_32_item ($Current, index)
		end

	natural_64_item (index: INTEGER): NATURAL_64 is
			-- NATURAL_64 item at `index'.
		require
			valid_index: valid_index (index)
			is_integer: is_natural_64_item (index)
		do
			Result := eif_natural_64_item ($Current, index)
		end

	integer_8_item (index: INTEGER): INTEGER_8 is
			-- INTEGER_8 item at `index'.
		require
			valid_index: valid_index (index)
			is_integer: is_integer_8_item (index)
		do
			Result := eif_integer_8_item ($Current, index)
		end

	integer_16_item (index: INTEGER): INTEGER_16 is
			-- INTEGER_16 item at `index'.
		require
			valid_index: valid_index (index)
			is_integer: is_integer_16_item (index)
		do
			Result := eif_integer_16_item ($Current, index)
		end

	integer_item, integer_32_item (index: INTEGER): INTEGER_32 is
			-- INTEGER_32 item at `index'.
		require
			valid_index: valid_index (index)
			is_integer: is_integer_32_item (index)
		do
			Result := eif_integer_32_item ($Current, index)
		end

	integer_64_item (index: INTEGER): INTEGER_64 is
			-- INTEGER_64 item at `index'.
		require
			valid_index: valid_index (index)
			is_integer: is_integer_64_item (index)
		do
			Result := eif_integer_64_item ($Current, index)
		end

	pointer_item (index: INTEGER): POINTER is
			-- Pointer item at `index'.
		require
			valid_index: valid_index (index)
			is_pointer: is_pointer_item (index)
		do
			Result := eif_pointer_item ($Current, index)
		end

	real_32_item, real_item (index: INTEGER): REAL_32 is
			-- real item at `index'.
		require
			valid_index: valid_index (index)
			is_real_or_integer: is_real_item (index)
		do
			Result := eif_real_32_item ($Current, index)
		end

feature -- Comparison

	object_comparison: BOOLEAN is
			-- Must search operations use `equal' rather than `='
			-- for comparing references? (Default: no, use `='.)
		do
			Result := eif_boolean_item ($Current, 0)
		end

	is_equal (other: like Current): BOOLEAN is
			-- Is `other' attached to an object considered
			-- equal to current object?
		local
			i, nb: INTEGER
			l_object_compare: BOOLEAN
		do
			l_object_compare := object_comparison
			if l_object_compare = other.object_comparison then
				if l_object_compare then
					nb := count
					if nb = other.count then
						from
							Result := True
							i := 1
						until
							i > nb or not Result
						loop
							Result := equal (item (i), other.item (i))
							i := i + 1
						end
					end
				else
					Result := Precursor {HASHABLE} (other)
				end
			end
		end

feature -- Status setting

	compare_objects is
			-- Ensure that future search operations will use `equal'
			-- rather than `=' for comparing references.
		do
			eif_put_boolean_item ($Current, 0, True)
		ensure
			object_comparison: object_comparison
		end

	compare_references is
			-- Ensure that future search operations will use `='
			-- rather than `equal' for comparing references.
		do
			eif_put_boolean_item ($Current, 0, False)
		ensure
			reference_comparison: not object_comparison
		end

feature -- Status report

	hash_code: INTEGER is
			-- Hash code value
		local
			i, nb, l_hash: INTEGER
		do
			from
				i := 1
				nb := count
			until
				i > nb
			loop
				inspect eif_item_type($Current, i)
				when boolean_code then l_hash := eif_boolean_item ($Current, i).hash_code
				when character_8_code then l_hash := eif_character_8_item ($Current, i).hash_code
				when character_32_code then l_hash := eif_character_32_item ($Current, i).hash_code
				when real_64_code then l_hash := eif_real_64_item ($Current, i).hash_code
				when real_32_code then l_hash := eif_real_32_item ($Current, i).hash_code
				when pointer_code then l_hash := eif_pointer_item ($Current, i).hash_code
				when natural_8_code then l_hash := eif_natural_8_item ($Current, i).hash_code
				when natural_16_code then l_hash := eif_natural_16_item ($Current, i).hash_code
				when natural_32_code then l_hash := eif_natural_32_item ($Current, i).hash_code
				when natural_64_code then l_hash := eif_natural_64_item ($Current, i).hash_code
				when integer_8_code then l_hash := eif_integer_8_item ($Current, i).hash_code
				when integer_16_code then l_hash := eif_integer_16_item ($Current, i).hash_code
				when integer_32_code then l_hash := eif_integer_32_item ($Current, i).hash_code
				when integer_64_code then l_hash := eif_integer_64_item ($Current, i).hash_code
				when reference_code then
					if {l_key: HASHABLE} eif_reference_item ($Current, i) then
						l_hash := l_key.hash_code
					else
						l_hash := 0
					end
				end
				Result := Result + l_hash * internal_primes.i_th (i)
				i := i + 1
			end
				-- Ensure it is a positive value.
			Result := Result.hash_code
		end

	valid_index (k: INTEGER): BOOLEAN is
			-- Is `k' a valid key?
		do
			Result := k >= 1 and then k <= count
		end

	valid_type_for_index (v: ?ANY; index: INTEGER): BOOLEAN is
			-- Is object `v' a valid target for element at position `index'?
		require
			valid_index: valid_index (index)
		local
			l_int: INTERNAL
			l_type: INTEGER
		do
			if v = Void then
					-- A Void entry is valid only for references and as long as the expected type
					-- is detachable.
				if eif_item_type ($Current, index) = reference_code then
					create l_int
					if {ISE_RUNTIME}.is_attached_type (l_int.generic_dynamic_type (Current, index)) then
						Result := False
					else
						Result := True
					end
				end
			else
				inspect eif_item_type ($Current, index)
				when boolean_code then Result := {l_b: BOOLEAN_REF} v
				when character_8_code then Result := {l_c: CHARACTER_8_REF} v
				when character_32_code then Result := {l_wc: CHARACTER_32_REF} v
				when real_64_code then Result := {l_d: REAL_64_REF} v
				when real_32_code then Result := {l_r: REAL_32_REF} v
				when pointer_code then Result := {l_p: POINTER_REF} v
				when natural_8_code then Result := {l_ui8: NATURAL_8_REF} v
				when natural_16_code then Result := {l_ui16: NATURAL_16_REF} v
				when natural_32_code then Result := {l_ui32: NATURAL_32_REF} v
				when natural_64_code then Result := {l_ui64: NATURAL_64_REF} v
				when integer_8_code then Result := {l_i8: INTEGER_8_REF} v
				when integer_16_code then Result := {l_i16: INTEGER_16_REF} v
				when integer_32_code then Result := {l_i32: INTEGER_32_REF} v
				when integer_64_code then Result := {l_i64: INTEGER_64_REF} v
				when Reference_code then
						-- Let's check that type of `v' conforms to specified type of `index'-th
						-- arguments of current TUPLE.
					create l_int
					l_type := l_int.generic_dynamic_type (Current, index)
					if {ISE_RUNTIME}.is_attached_type (l_type) then
						l_type := {ISE_RUNTIME}.detachable_type (l_type)
					end
					Result := l_int.type_conforms_to (l_int.dynamic_type (v), l_type)
				end
			end
		end

	count: INTEGER is
			-- Number of element in Current.
		external
			"built_in"
		end

	lower: INTEGER is 1
			-- Lower bound of TUPLE.

	upper: INTEGER is
			-- Upper bound of TUPLE.
		do
			Result := count
		end

	is_empty: BOOLEAN is
			-- Is Current empty?
		do
			Result := count = 0
		end

feature -- Element change

	put (v: ?ANY; index: INTEGER) is
			-- Insert `v' at position `index'.
		require
			valid_index: valid_index (index)
			valid_type_for_index: valid_type_for_index (v, index)
		do
			inspect eif_item_type ($Current, index)
			when boolean_code then eif_put_boolean_item_with_object ($Current, index, $v)
			when character_8_code then eif_put_character_8_item_with_object ($Current, index, $v)
			when character_32_code then eif_put_character_32_item_with_object ($Current, index, $v)
			when real_64_code then eif_put_real_64_item_with_object ($Current, index, $v)
			when real_32_code then eif_put_real_32_item_with_object ($Current, index, $v)
			when pointer_code then eif_put_pointer_item_with_object ($Current, index, $v)
			when natural_8_code then eif_put_natural_8_item_with_object ($Current, index, $v)
			when natural_16_code then eif_put_natural_16_item_with_object ($Current, index, $v)
			when natural_32_code then eif_put_natural_32_item_with_object ($Current, index, $v)
			when natural_64_code then eif_put_natural_64_item_with_object ($Current, index, $v)
			when integer_8_code then eif_put_integer_8_item_with_object ($Current, index, $v)
			when integer_16_code then eif_put_integer_16_item_with_object ($Current, index, $v)
			when integer_32_code then eif_put_integer_32_item_with_object ($Current, index, $v)
			when integer_64_code then eif_put_integer_64_item_with_object ($Current, index, $v)
			when Reference_code then eif_put_reference_item_with_object ($Current, index, $v)
			end
		end

	put_reference (v: ANY; index: INTEGER) is
			-- Put `v' at position `index' in Current.
		require
			valid_index: valid_index (index)
			valid_type_for_index: valid_type_for_index (v, index)
			valid_type: is_reference_item (index)
		do
			eif_put_reference_item_with_object ($Current, index, $v)
		end

	put_boolean (v: BOOLEAN; index: INTEGER) is
			-- Put `v' at position `index' in Current.
		require
			valid_index: valid_index (index)
			valid_type: is_boolean_item (index)
		do
			eif_put_boolean_item ($Current, index, v)
		end

	put_character_8, put_character (v: CHARACTER_8; index: INTEGER) is
			-- Put `v' at position `index' in Current.
		require
			valid_index: valid_index (index)
			valid_type: is_character_8_item (index)
		do
			eif_put_character_8_item ($Current, index, v)
		end

	put_character_32, put_wide_character (v: CHARACTER_32; index: INTEGER) is
			-- Put `v' at position `index' in Current.
		require
			valid_index: valid_index (index)
			valid_type: is_character_32_item (index)
		do
			eif_put_character_32_item ($Current, index, v)
		end

	put_real_64, put_double (v: REAL_64; index: INTEGER) is
			-- Put `v' at position `index' in Current.
		require
			valid_index: valid_index (index)
			valid_type: is_double_item (index)
		do
			eif_put_real_64_item ($Current, index, v)
		end

	put_real_32, put_real (v: REAL_32; index: INTEGER) is
			-- Put `v' at position `index' in Current.
		require
			valid_index: valid_index (index)
			valid_type: is_real_item (index)
		do
			eif_put_real_32_item ($Current, index, v)
		end

	put_pointer (v: POINTER; index: INTEGER) is
			-- Put `v' at position `index' in Current.
		require
			valid_index: valid_index (index)
			valid_type: is_pointer_item (index)
		do
			eif_put_pointer_item ($Current, index, v)
		end

	put_natural_8 (v: NATURAL_8; index: INTEGER) is
			-- Put `v' at position `index' in Current.
		require
			valid_index: valid_index (index)
			valid_type: is_natural_8_item (index)
		do
			eif_put_natural_8_item ($Current, index, v)
		end

	put_natural_16 (v: NATURAL_16; index: INTEGER) is
			-- Put `v' at position `index' in Current.
		require
			valid_index: valid_index (index)
			valid_type: is_natural_16_item (index)
		do
			eif_put_natural_16_item ($Current, index, v)
		end

	put_natural_32 (v: NATURAL_32; index: INTEGER) is
			-- Put `v' at position `index' in Current.
		require
			valid_index: valid_index (index)
			valid_type: is_natural_32_item (index)
		do
			eif_put_natural_32_item ($Current, index, v)
		end

	put_natural_64 (v: NATURAL_64; index: INTEGER) is
			-- Put `v' at position `index' in Current.
		require
			valid_index: valid_index (index)
			valid_type: is_natural_64_item (index)
		do
			eif_put_natural_64_item ($Current, index, v)
		end

	put_integer, put_integer_32 (v: INTEGER_32; index: INTEGER) is
			-- Put `v' at position `index' in Current.
		require
			valid_index: valid_index (index)
			valid_type: is_integer_32_item (index)
		do
			eif_put_integer_32_item ($Current, index, v)
		end

	put_integer_8 (v: INTEGER_8; index: INTEGER) is
			-- Put `v' at position `index' in Current.
		require
			valid_index: valid_index (index)
			valid_type: is_integer_8_item (index)
		do
			eif_put_integer_8_item ($Current, index, v)
		end

	put_integer_16 (v: INTEGER_16; index: INTEGER) is
			-- Put `v' at position `index' in Current.
		require
			valid_index: valid_index (index)
			valid_type: is_integer_16_item (index)
		do
			eif_put_integer_16_item ($Current, index, v)
		end

	put_integer_64 (v: INTEGER_64; index: INTEGER) is
			-- Put `v' at position `index' in Current.
		require
			valid_index: valid_index (index)
			valid_type: is_integer_64_item (index)
		do
			eif_put_integer_64_item ($Current, index, v)
		end

feature -- Type queries

	is_boolean_item (index: INTEGER): BOOLEAN is
			-- Is item at `index' a BOOLEAN?
		require
			valid_index: valid_index (index)
		do
			Result := (eif_item_type ($Current, index) = boolean_code)
		end

	is_character_8_item, is_character_item (index: INTEGER): BOOLEAN is
			-- Is item at `index' a CHARACTER_8?
		require
			valid_index: valid_index (index)
		do
			Result := (eif_item_type ($Current, index) = character_8_code)
		end

	is_character_32_item, is_wide_character_item (index: INTEGER): BOOLEAN is
			-- Is item at `index' a CHARACTER_32?
		require
			valid_index: valid_index (index)
		do
			Result := (eif_item_type ($Current, index) = character_32_code)
		end

	is_double_item (index: INTEGER): BOOLEAN is
			-- Is item at `index' a REAL_64?
		require
			valid_index: valid_index (index)
		do
			Result := (eif_item_type ($Current, index) = real_64_code)
		end

	is_natural_8_item (index: INTEGER): BOOLEAN is
			-- Is item at `index' an NATURAL_8?
		require
			valid_index: valid_index (index)
		do
			Result := (eif_item_type ($Current, index) = natural_8_code)
		end

	is_natural_16_item (index: INTEGER): BOOLEAN is
			-- Is item at `index' an NATURAL_16?
		require
			valid_index: valid_index (index)
		do
			Result := (eif_item_type ($Current, index) = natural_16_code)
		end

	is_natural_32_item (index: INTEGER): BOOLEAN is
			-- Is item at `index' an NATURAL_32?
		require
			valid_index: valid_index (index)
		do
			Result := (eif_item_type ($Current, index) = natural_32_code)
		end

	is_natural_64_item (index: INTEGER): BOOLEAN is
			-- Is item at `index' an NATURAL_64?
		require
			valid_index: valid_index (index)
		do
			Result := (eif_item_type ($Current, index) = natural_64_code)
		end

	is_integer_8_item (index: INTEGER): BOOLEAN is
			-- Is item at `index' an INTEGER_8?
		require
			valid_index: valid_index (index)
		do
			Result := (eif_item_type ($Current, index) = integer_8_code)
		end

	is_integer_16_item (index: INTEGER): BOOLEAN is
			-- Is item at `index' an INTEGER_16?
		require
			valid_index: valid_index (index)
		do
			Result := (eif_item_type ($Current, index) = integer_16_code)
		end

	is_integer_item, is_integer_32_item (index: INTEGER): BOOLEAN is
			-- Is item at `index' an INTEGER_32?
		require
			valid_index: valid_index (index)
		do
			Result := (eif_item_type ($Current, index) = integer_32_code)
		end

	is_integer_64_item (index: INTEGER): BOOLEAN is
			-- Is item at `index' an INTEGER_64?
		require
			valid_index: valid_index (index)
		do
			Result := (eif_item_type ($Current, index) = integer_64_code)
		end

	is_pointer_item (index: INTEGER): BOOLEAN is
			-- Is item at `index' a POINTER?
		require
			valid_index: valid_index (index)
		do
			Result := (eif_item_type ($Current, index) = pointer_code)
		end

	is_real_item (index: INTEGER): BOOLEAN is
			-- Is item at `index' a REAL_32?
		require
			valid_index: valid_index (index)
		do
			Result := (eif_item_type ($Current, index) = real_32_code)
		end

	is_reference_item (index: INTEGER): BOOLEAN is
			-- Is item at `index' a REFERENCE?
		require
			valid_index: valid_index (index)
		do
			Result := (eif_item_type ($Current, index) = reference_code)
		end

	is_numeric_item (index: INTEGER): BOOLEAN is
			-- Is item at `index' a number?
		obsolete
			"Use the precise type query instead."
		require
			valid_index: valid_index (index)
		local
			tcode: like item_code
		do
			tcode := eif_item_type ($Current, index)
			inspect tcode
			when
				integer_8_code, integer_16_code, integer_32_code,
				integer_64_code, real_32_code, real_64_code
			then
				Result := True
			else
				-- Nothing to do here since Result already initialized to False.
			end
		end

	is_uniform: BOOLEAN is
			-- Are all items of the same basic type or all of reference type?
		do
			Result := is_tuple_uniform (any_code)
		ensure
			yes_if_empty: (count = 0) implies Result
		end

	is_uniform_boolean: BOOLEAN is
			-- Are all items of type BOOLEAN?
		do
			Result := is_tuple_uniform (boolean_code)
		ensure
			yes_if_empty: (count = 0) implies Result
		end

	is_uniform_character_8, is_uniform_character: BOOLEAN is
			-- Are all items of type CHARACTER_8?
		do
			Result := is_tuple_uniform (character_8_code)
		ensure
			yes_if_empty: (count = 0) implies Result
		end

	is_uniforme_character_32, is_uniform_wide_character: BOOLEAN is
			-- Are all items of type CHARACTER_32?
		do
			Result := is_tuple_uniform (character_32_code)
		ensure
			yes_if_empty: (count = 0) implies Result
		end

	is_uniform_double: BOOLEAN is
			-- Are all items of type REAL_64?
		do
			Result := is_tuple_uniform (real_64_code)
		ensure
			yes_if_empty: (count = 0) implies Result
		end

	is_uniform_natural_8: BOOLEAN is
			-- Are all items of type NATURAL_8?
		do
			Result := is_tuple_uniform (natural_8_code)
		ensure
			yes_if_empty: (count = 0) implies Result
		end

	is_uniform_natural_16: BOOLEAN is
			-- Are all items of type NATURAL_16?
		do
			Result := is_tuple_uniform (natural_16_code)
		ensure
			yes_if_empty: (count = 0) implies Result
		end

	is_uniform_natural_32: BOOLEAN is
			-- Are all items of type NATURAL_32?
		do
			Result := is_tuple_uniform (natural_32_code)
		ensure
			yes_if_empty: (count = 0) implies Result
		end

	is_uniform_natural_64: BOOLEAN is
			-- Are all items of type NATURAL_64?
		do
			Result := is_tuple_uniform (natural_64_code)
		ensure
			yes_if_empty: (count = 0) implies Result
		end

	is_uniform_integer_8: BOOLEAN is
			-- Are all items of type INTEGER_8?
		do
			Result := is_tuple_uniform (integer_8_code)
		ensure
			yes_if_empty: (count = 0) implies Result
		end

	is_uniform_integer_16: BOOLEAN is
			-- Are all items of type INTEGER_16?
		do
			Result := is_tuple_uniform (integer_16_code)
		ensure
			yes_if_empty: (count = 0) implies Result
		end

	is_uniform_integer, is_uniform_integer_32: BOOLEAN is
			-- Are all items of type INTEGER?
		do
			Result := is_tuple_uniform (integer_32_code)
		ensure
			yes_if_empty: (count = 0) implies Result
		end

	is_uniform_integer_64: BOOLEAN is
			-- Are all items of type INTEGER_64?
		do
			Result := is_tuple_uniform (integer_64_code)
		ensure
			yes_if_empty: (count = 0) implies Result
		end

	is_uniform_pointer: BOOLEAN is
			-- Are all items of type POINTER?
		do
			Result := is_tuple_uniform (pointer_code)
		ensure
			yes_if_empty: (count = 0) implies Result
		end

	is_uniform_real: BOOLEAN is
			-- Are all items of type REAL_32?
		do
			Result := is_tuple_uniform (real_32_code)
		ensure
			yes_if_empty: (count = 0) implies Result
		end

	is_uniform_reference: BOOLEAN is
			-- Are all items of reference type?
		do
			Result := is_tuple_uniform (reference_code)
		ensure
			yes_if_empty: (count = 0) implies Result
		end

feature -- Type conversion queries

	convertible_to_double: BOOLEAN is
			-- Is current convertible to an array of doubles?
		obsolete
			"Will be removed in future releases"
		local
			i, cnt: INTEGER
			tcode: like item_code
		do
			Result := True
			from
				i := 1
				cnt := count
			until
				i > cnt or else not Result
			loop
				tcode := eif_item_type ($Current, i)
				inspect tcode
				when
					integer_8_code, integer_16_code, integer_32_code,
					integer_64_code, real_32_code, real_64_code
				then
					Result := True
				else
					Result := False
				end
				i := i + 1
			end
		ensure
			yes_if_empty: (count = 0) implies Result
		end

	convertible_to_real: BOOLEAN is
			-- Is current convertible to an array of reals?
		obsolete
			"Will be removed in future releases"
		local
			i, cnt: INTEGER
			tcode: like item_code
		do
			Result := True
			from
				i := 1
				cnt := count
			until
				i > cnt or else not Result
			loop
				tcode := eif_item_type ($Current, i)
				inspect tcode
				when
					integer_8_code, integer_16_code, integer_32_code,
					integer_64_code, real_32_code
				then
					Result := True
				else
					Result := False
				end
				i := i + 1
			end
		ensure
			yes_if_empty: (count = 0) implies Result
		end

feature -- Conversion

	arrayed: ARRAY [?ANY] is
			-- Items of Current as array
		obsolete
			"Will be removed in future releases"
		local
			i, cnt: INTEGER
		do
			from
				i := 1
				cnt := count
				create Result.make (1, cnt)
			until
				i > cnt
			loop
				Result.put (item (i), i)
				i := i + 1
			end
		ensure
			exists: Result /= Void
			same_count: Result.count = count
			same_items: -- Items are the same in same order
		end

	boolean_arrayed: ARRAY [BOOLEAN] is
			-- Items of Current as array
		obsolete
			"Will be removed in future releases"
		require
			is_uniform_boolean: is_uniform_boolean
		local
			i, cnt: INTEGER
		do
			from
				i := 1
				cnt := count
				create Result.make (1, cnt)
			until
				i > cnt
			loop
				Result.put (boolean_item (i), i)
				i := i + 1
			end
		ensure
			exists: Result /= Void
			same_count: Result.count = count
			same_items: -- Items are the same in same order
		end

	character_8_arrayed, character_arrayed: ARRAY [CHARACTER_8] is
			-- Items of Current as array
		obsolete
			"Will be removed in future releases"
		require
			is_uniform_character: is_uniform_character
		local
			i, cnt: INTEGER
		do
			from
				i := 1
				cnt := count
				create Result.make (1, cnt)
			until
				i > cnt
			loop
				Result.put (character_8_item (i), i)
				i := i + 1
			end
		ensure
			exists: Result /= Void
			same_count: Result.count = count
			same_items: -- Items are the same in same order
		end

	double_arrayed: ARRAY [REAL_64] is
			-- Items of Current as array
		obsolete
			"Will be removed in future releases"
		require
			convertible: convertible_to_double
		local
			i, cnt: INTEGER
		do
			from
				i := 1
				cnt := count
				create Result.make (1, cnt)
			until
				i > cnt
			loop
				Result.put (double_item (i), i)
				i := i + 1
			end
		ensure
			exists: Result /= Void
			same_count: Result.count = count
			same_items: -- Items are the same in same order
		end

	integer_arrayed: ARRAY [INTEGER] is
			-- Items of Current as array
		obsolete
			"Will be removed in future releases"
		require
			is_uniform_integer: is_uniform_integer
		local
			i, cnt: INTEGER
		do
			from
				i := 1
				cnt := count
				create Result.make (1, cnt)
			until
				i > cnt
			loop
				Result.put (integer_32_item (i), i)
				i := i + 1
			end
		ensure
			exists: Result /= Void
			same_count: Result.count = count
			same_items: -- Items are the same in same order
		end

	pointer_arrayed: ARRAY [POINTER] is
			-- Items of Current as array
		obsolete
			"Will be removed in future releases"
		require
			is_uniform_pointer: is_uniform_pointer
		local
			i, cnt: INTEGER
		do
			from
				i := 1
				cnt := count
				create Result.make (1, cnt)
			until
				i > cnt
			loop
				Result.put (pointer_item (i), i)
				i := i + 1
			end
		ensure
			exists: Result /= Void
			same_count: Result.count = count
			same_items: -- Items are the same in same order
		end

	real_arrayed: ARRAY [REAL_32] is
			-- Items of Current as array
		obsolete
			"Will be removed in future releases"
		require
			convertible: convertible_to_real
		local
			i, cnt: INTEGER
		do
			from
				i := 1
				cnt := count
				create Result.make (1, cnt)
			until
				i > cnt
			loop
				Result.put (real_item (i), i)
				i := i + 1
			end
		ensure
			exists: Result /= Void
			same_count: Result.count = count
			same_items: -- Items are the same in same order
		end

	string_arrayed: ARRAY [?STRING] is
			-- Items of Current as array
			-- NOTE: Items with a type not cconforming to
			--       type STRING are set to Void.
		obsolete
			"Will be removed in future releases"
		local
			i, cnt: INTEGER
		do
			from
				i := 1
				cnt := count
				create Result.make (1, cnt)
			until
				i > cnt
			loop
				if {s: STRING} item (i) then
					Result.put (s, i)
				end
				i := i + 1
			end
		ensure
			exists: Result /= Void
			same_count: Result.count = count
		end

feature -- Retrieval

	correct_mismatch is
			-- Attempt to correct object mismatch using `mismatch_information'.
		local
			i, nb: INTEGER
			l_any: ANY
		do
				-- Old version of TUPLE had a SPECIAL [ANY] to store all values.
				-- If we can get access to it, then most likely we can recover this
				-- old TUPLE implementation.
			if {l_area: SPECIAL [ANY]} Mismatch_information.item (area_name) then
				from
					i := 1
					nb := l_area.count
				until
					i > nb
				loop
					l_any := l_area.item (i - 1)
					if valid_type_for_index (l_any, i) then
						put (l_any, i)
					else
							-- We found an unexpected type in old special. We cannot go on.
						Precursor {MISMATCH_CORRECTOR}
					end
					i := i + 1
				end
			else
				Precursor {MISMATCH_CORRECTOR}
			end
		end

feature -- Access

	item_code (index: INTEGER): NATURAL_8 is
			-- Type code of item at `index'. Used for
			-- argument processing in ROUTINE
		require
			valid_index: valid_index (index)
		do
			Result := eif_item_type ($Current, index)
		end

	reference_code: NATURAL_8 is 0x00
	boolean_code: NATURAL_8 is 0x01
	character_8_code, character_code: NATURAL_8 is 0x02
	real_64_code: NATURAL_8 is 0x03
	real_32_code: NATURAL_8 is 0x04
	pointer_code: NATURAL_8 is 0x05
	integer_8_code: NATURAL_8 is 0x06
	integer_16_code: NATURAL_8 is 0x07
	integer_32_code: NATURAL_8 is 0x08
	integer_64_code: NATURAL_8 is 0x09
	natural_8_code: NATURAL_8 is 0x0A
	natural_16_code: NATURAL_8 is 0x0B
	natural_32_code: NATURAL_8 is 0x0C
	natural_64_code: NATURAL_8 is 0x0D
	character_32_code, wide_character_code: NATURAL_8 is 0x0E
	any_code: NATURAL_8 is 0xFF
			-- Code used to identify type in TUPLE.

feature {NONE} -- Implementation

	area_name: STRING is "area"
			-- Name of attributes where TUPLE elements were stored.

	is_tuple_uniform (code: like item_code): BOOLEAN is
			-- Are all items of type `code'?
		local
			i, nb: INTEGER
			l_code: like item_code
		do
			Result := True
			if count > 0 then
				from
					nb := count
					if code = any_code then
							-- We take first type code and compare all the remaining ones
							-- against it.
						i := 2
						l_code := eif_item_type ($Current, 1)
					else
						i := 1
						l_code := code
					end
				until
					i > nb or not Result
				loop
					Result := l_code = eif_item_type ($Current, i)
					i := i + 1
				end
			end
		end

	internal_primes: PRIMES is
			-- For quick access to prime numbers.
		once
			create Result
		end

feature {NONE} -- Externals: Access

	eif_item_type (obj: POINTER; pos: INTEGER): NATURAL_8 is
			-- Code for generic parameter `pos' in `obj'.
		external
			"C macro use %"eif_rout_obj.h%""
		alias
			"eif_item_type"
		end

	eif_boolean_item (obj: POINTER; pos: INTEGER): BOOLEAN is
			-- Boolean item at position `pos' in tuple `obj'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_character_8_item (obj: POINTER; pos: INTEGER): CHARACTER_8 is
			-- Character item at position `pos' in tuple `obj'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_character_32_item (obj: POINTER; pos: INTEGER): CHARACTER_32 is
			-- Wide character item at position `pos' in tuple `obj'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_real_64_item (obj: POINTER; pos: INTEGER): REAL_64 is
			-- Double item at position `pos' in tuple `obj'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_real_32_item (obj: POINTER; pos: INTEGER): REAL_32 is
			-- Real item at position `pos' in tuple `obj'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_pointer_item (obj: POINTER; pos: INTEGER): POINTER is
			-- Pointer item at position `pos' in tuple `obj'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_natural_8_item (obj: POINTER; pos: INTEGER): NATURAL_8 is
			-- NATURAL_8 item at position `pos' in tuple `obj'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_natural_16_item (obj: POINTER; pos: INTEGER):  NATURAL_16 is
			-- NATURAL_16 item at position `pos' in tuple `obj'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_natural_32_item (obj: POINTER; pos: INTEGER):  NATURAL_32 is
			-- NATURAL_32 item at position `pos' in tuple `obj'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_natural_64_item (obj: POINTER; pos: INTEGER):  NATURAL_64 is
			-- NATURAL_64 item at position `pos' in tuple `obj'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_integer_8_item (obj: POINTER; pos: INTEGER): INTEGER_8 is
			-- INTEGER_8 item at position `pos' in tuple `obj'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_integer_16_item (obj: POINTER; pos: INTEGER): INTEGER_16 is
			-- INTEGER_16 item at position `pos' in tuple `obj'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_integer_32_item (obj: POINTER; pos: INTEGER): INTEGER_32 is
			-- INTEGER_32 item at position `pos' in tuple `obj'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_integer_64_item (obj: POINTER; pos: INTEGER): INTEGER_64 is
			-- INTEGER_64 item at position `pos' in tuple `obj'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_reference_item (obj: POINTER; pos: INTEGER): ?ANY is
			-- Reference item at position `pos' in tuple `obj'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

feature {NONE} -- Externals: Setting

	eif_put_boolean_item_with_object (obj: POINTER; pos: INTEGER; v: POINTER) is
			-- Set boolean item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_character_8_item_with_object (obj: POINTER; pos: INTEGER; v: POINTER) is
			-- Set character item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_character_32_item_with_object (obj: POINTER; pos: INTEGER; v: POINTER) is
			-- Set wide character item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_real_64_item_with_object (obj: POINTER; pos: INTEGER; v: POINTER) is
			-- Set double item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_real_32_item_with_object (obj: POINTER; pos: INTEGER; v: POINTER) is
			-- Set real item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_pointer_item_with_object (obj: POINTER; pos: INTEGER; v: POINTER) is
			-- Set pointer item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_natural_8_item_with_object (obj: POINTER; pos: INTEGER; v: POINTER) is
			-- Set NATURAL_8 item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_natural_16_item_with_object (obj: POINTER; pos: INTEGER; v: POINTER) is
			-- Set NATURAL_16 item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_natural_32_item_with_object (obj: POINTER; pos: INTEGER; v: POINTER) is
			-- Set NATURAL_32 item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_natural_64_item_with_object (obj: POINTER; pos: INTEGER; v: POINTER) is
			-- Set NATURAL_64 item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_integer_8_item_with_object (obj: POINTER; pos: INTEGER; v: POINTER) is
			-- Set integer_8 item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_integer_16_item_with_object (obj: POINTER; pos: INTEGER; v: POINTER) is
			-- Set integer_16 item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_integer_32_item_with_object (obj: POINTER; pos: INTEGER; v: POINTER) is
			-- Set integer_32 item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_integer_64_item_with_object (obj: POINTER; pos: INTEGER; v: POINTER) is
			-- Set integer_64 item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_reference_item_with_object (obj: POINTER; pos: INTEGER; v: POINTER) is
			-- Set reference item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_boolean_item (obj: POINTER; pos: INTEGER; v: BOOLEAN) is
			-- Set boolean item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_character_8_item (obj: POINTER; pos: INTEGER; v: CHARACTER_8) is
			-- Set character_8 item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_character_32_item (obj: POINTER; pos: INTEGER; v: CHARACTER_32) is
			-- Set character_32 item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_real_64_item (obj: POINTER; pos: INTEGER; v: REAL_64) is
			-- Set double item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_real_32_item (obj: POINTER; pos: INTEGER; v: REAL_32) is
			-- Set real item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_pointer_item (obj: POINTER; pos: INTEGER; v: POINTER) is
			-- Set pointer item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_natural_8_item (obj: POINTER; pos: INTEGER; v: NATURAL_8) is
			-- Set NATURAL_8 item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_natural_16_item (obj: POINTER; pos: INTEGER; v: NATURAL_16) is
			-- Set NATURAL_16 item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_natural_32_item (obj: POINTER; pos: INTEGER; v: NATURAL_32) is
			-- Set NATURAL_32 item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_natural_64_item (obj: POINTER; pos: INTEGER; v: NATURAL_64) is
			-- Set NATURAL_64 item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_integer_8_item (obj: POINTER; pos: INTEGER; v: INTEGER_8) is
			-- Set integer_8 item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_integer_16_item (obj: POINTER; pos: INTEGER; v: INTEGER_16) is
			-- Set integer_16 item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_integer_32_item (obj: POINTER; pos: INTEGER; v: INTEGER_32) is
			-- Set integer_32 item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

	eif_put_integer_64_item (obj: POINTER; pos: INTEGER; v: INTEGER_64) is
			-- Set integer_64 item at position `pos' in tuple `obj' with `v'.
		external
			"C macro use %"eif_rout_obj.h%""
		end

end