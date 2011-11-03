note
	description: "Common ancestors to all STRING classes. Read-only interface."
	library: "Free implementation of ELKS library"
	copyright: "Copyright (c) 1986-2011, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	READABLE_STRING_GENERAL

inherit
	COMPARABLE
		export
			{READABLE_STRING_GENERAL} copy, standard_copy, deep_copy
		end

	HASHABLE
		export
			{READABLE_STRING_GENERAL} copy, standard_copy, deep_copy
		undefine
			is_equal
		end

	STRING_HANDLER
		export
			{READABLE_STRING_GENERAL} copy, standard_copy, deep_copy
		undefine
			is_equal
		end

feature -- Access

	code (i: INTEGER): NATURAL_32
			-- Code at position `i'
		require
			valid_index: valid_index (i)
		deferred
		end

	index_of_code (c: like code; start_index: INTEGER): INTEGER
			-- Position of first occurrence of `c' at or after `start_index';
			-- 0 if none.
		require
			start_large_enough: start_index >= 1
			start_small_enough: start_index <= count + 1
		local
			i, nb: INTEGER
		do
			nb := count
			if start_index <= nb then
				from
					i := start_index
				until
					i > nb or else code (i) = c
				loop
					i := i + 1
				end
				if i <= nb then
					Result := i
				end
			end
		ensure
			valid_result: Result = 0 or (start_index <= Result and Result <= count)
			zero_if_absent: (Result = 0) = not substring (start_index, count).has_code (c)
			found_if_present: substring (start_index, count).has_code (c) implies code (Result) = c
			none_before: substring (start_index, count).has_code (c) implies
				not substring (start_index, Result - 1).has_code (c)
		end

	false_constant: STRING_8 = "false"
			-- Constant string "false"

	true_constant: STRING_8 = "true"
			-- Constant string "true"

feature -- Status report

	is_immutable: BOOLEAN
			-- Can the character sequence of `Current' be not changed?
		do
			Result := False
		end

	count: INTEGER
			-- Number of characters in Current
		deferred
		ensure
			count_non_negative: Result >= 0
		end

	capacity: INTEGER
			-- Number of characters allocated in Current
		deferred
		ensure
			capacity_non_negative: Result >= 0
		end

	valid_index (i: INTEGER): BOOLEAN
			-- Is `i' within the bounds of the string?
		deferred
		end

	valid_code (v: like code): BOOLEAN
			-- Is `v' a valid code for Current?
		deferred
		end

	is_string_8: BOOLEAN
			-- Is `Current' a sequence of CHARACTER_8?
		deferred
		end

	is_string_32: BOOLEAN
			-- Is `Current' a sequence of CHARACTER_32?
		deferred
		end

	is_valid_as_string_8: BOOLEAN
			-- Is `Current' convertible to a sequence of CHARACTER_8 without information loss?
		deferred
		end

	is_empty: BOOLEAN
			-- Is structure empty?
		deferred
		end

	has_code (c: like code): BOOLEAN
			-- Does string include `c'?
		local
			i, nb: INTEGER
		do
			nb := count
			if nb > 0 then
				from
					i := 1
				until
					i > nb or else (code (i) = c)
				loop
					i := i + 1
				end
				Result := (i <= nb)
			end
		ensure then
			false_if_empty: count = 0 implies not Result
			true_if_first: count > 0 and then code (1) = c implies Result
			recurse: (count > 0 and then code (1) /= c) implies
				(Result = substring (2, count).has_code (c))
		end

	has_substring (other: READABLE_STRING_GENERAL): BOOLEAN
			-- Does `Current' contain `other'?
		require
			other_not_void: other /= Void
		do
			if other = Current then
				Result := True
			elseif other.count <= count then
				Result := substring_index (other, 1) > 0
			end
		ensure
			false_if_too_small: count < other.count implies not Result
			true_if_initial: (count >= other.count and then
				other.same_string (substring (1, other.count))) implies Result
			recurse: (count >= other.count and then
				not other.same_string (substring (1, other.count))) implies
				(Result = substring (2, count).has_substring (other))
		end

	same_string (a_other: READABLE_STRING_GENERAL): BOOLEAN
			-- Does `a_other' represent the same string as `Current'?
		require
			a_other_not_void: a_other /= Void
		local
			i, l_count: INTEGER
		do
			if a_other = Current then
				Result := True
			else
				l_count := count
				if l_count = a_other.count then
					from
						Result := True
						i := 1
					until
						i > l_count
					loop
						if code (i) /= a_other.code (i) then
							Result := False
							i := l_count -- Jump out of the loop
						end
						i := i + 1
					variant
						increasing_index: l_count - i + 1
					end
				end
			end
		end

	starts_with (s: READABLE_STRING_GENERAL): BOOLEAN
			-- Does string begin with `s'?
		require
			argument_not_void: s /= Void
		local
			i: INTEGER
		do
			if Current = s then
				Result := True
			else
				i := s.count
				if i <= count then
					from
						Result := True
					until
						i = 0
					loop
						if code (i) /= s.code (i) then
							Result := False
							i := 1 -- Jump out of loop
						end
						i := i - 1
					end
				end
			end
		ensure
			definition: Result = s.same_string (substring (1, s.count))
		end

	ends_with (s: READABLE_STRING_GENERAL): BOOLEAN
			-- Does string finish with `s'?
		require
			argument_not_void: s /= Void
		local
			i, j: INTEGER
		do
			if Current = s then
				Result := True
			else
				i := s.count
				j := count
				if i <= j then
					from
						Result := True
					until
						i = 0
					loop
						if code(j) /= s.code (i) then
							Result := False
							i := 1 -- Jump out of loop
						end
						i := i - 1
						j := j - 1
					end
				end
			end
		ensure
			definition: Result = s.same_string (substring (count - s.count + 1, count))
		end

	substring_index_in_bounds (other: READABLE_STRING_GENERAL; start_pos, end_pos: INTEGER): INTEGER
			-- Position of first occurrence of `other' at or after `start_pos'
			-- and to or before `end_pos';
			-- 0 if none.
		require
			other_nonvoid: other /= Void
			other_notempty: not other.is_empty
			start_pos_large_enough: start_pos >= 1
			start_pos_small_enough: start_pos <= count
			end_pos_large_enough: end_pos >= start_pos
			end_pos_small_enough: end_pos <= count
		deferred
		ensure
			correct_place: Result > 0 implies other.same_string (substring (Result, Result + other.count - 1))
			-- forall x : start_pos..Result
			--	not substring (x, x+other.count -1).is_equal (other)
		end

	substring_index (other: READABLE_STRING_GENERAL; start_index: INTEGER): INTEGER
			-- Index of first occurrence of other at or after start_index;
			-- 0 if none
		require
			other_not_void: other /= Void
			valid_start_index: start_index >= 1 and start_index <= count + 1
		deferred
		ensure
			valid_result: Result = 0 or else
				(start_index <= Result and Result <= count - other.count + 1)
			zero_if_absent: (Result = 0) =
				not substring (start_index, count).has_substring (other)
			at_this_index: Result >= start_index implies
				other.same_string (substring (Result, Result + other.count - 1))
			none_before: Result > start_index implies
				not substring (start_index, Result + other.count - 2).has_substring (other)
		end

	fuzzy_index (other: READABLE_STRING_GENERAL; start: INTEGER; fuzz: INTEGER): INTEGER
			-- Position of first occurrence of `other' at or after `start'
			-- with 0..`fuzz' mismatches between the string and `other'.
			-- 0 if there are no fuzzy matches
		require
			other_exists: other /= Void
			other_not_empty: not other.is_empty
			start_large_enough: start >= 1
			start_small_enough: start <= count
			acceptable_fuzzy: fuzz <= other.count
		deferred
		end

	is_number_sequence: BOOLEAN
			-- Does `Current' represent a number sequence?
		deferred
		ensure
			syntax_and_range:
				-- Result is true if and only if the following two
				-- conditions are satisfied:
				--
				-- In the following BNF grammar, the value of
				--	Current can be produced by "Integer_literal":
				--
				-- Integer_literal = [Space] [Sign] Integer [Space]
				-- Space 	= " " | " " Space
				-- Sign		= "+" | "-"
				-- Integer	= Digit | Digit Integer
				-- Digit	= "0"|"1"|"2"|"3"|"4"|"5"|"6"|"7"|"8"|"9"
		end

	is_real_sequence: BOOLEAN
			-- Does `Current' represent a real sequence?
		deferred
		ensure
			syntax_and_range:
				-- 'Result' is True if and only if the following condition is satisfied:
				--
				-- In the following BNF grammar, the value of
				--	'Current' can be produced by "Real_literal":
				--
				-- Real_literal	= Mantissa [Exponent_part]
				-- Exponent_part = "E" Exponent
				--				 | "e" Exponent
				-- Exponent		= Integer_literal
				-- Mantissa		= Decimal_literal
				-- Decimal_literal = Integer_literal ["." [Integer]] | "." Integer
				-- Integer_literal = [Sign] Integer
				-- Sign			= "+" | "-"
				-- Integer		= Digit | Digit Integer
				-- Digit		= "0"|"1"|"2"|"3"|"4"|"5"|"6"|"7"|"8"|"9"
				--
		end

	is_real: BOOLEAN
			-- Does `Current' represent a REAL?
		deferred
		ensure
			syntax_and_range:
				-- 'Result' is True if and only if the following two
				-- conditions are satisfied:
				--
				-- 1. In the following BNF grammar, the value of
				--	'Current' can be produced by "Real_literal":
				--
				-- Real_literal	= Mantissa [Exponent_part]
				-- Exponent_part = "E" Exponent
				--				 | "e" Exponent
				-- Exponent		= Integer_literal
				-- Mantissa		= Decimal_literal
				-- Decimal_literal = Integer_literal ["." [Integer]] | "." Integer
				-- Integer_literal = [Sign] Integer
				-- Sign			= "+" | "-"
				-- Integer		= Digit | Digit Integer
				-- Digit		= "0"|"1"|"2"|"3"|"4"|"5"|"6"|"7"|"8"|"9"
				--
				-- 2. The numerical value represented by 'Current'
				--	is within the range that can be represented
				--	by an instance of type REAL.
		end

	is_double: BOOLEAN
			-- Does `Current' represent a DOUBLE?
		deferred
		ensure
			syntax_and_range:
				-- 'Result' is True if and only if the following two
				-- conditions are satisfied:
				--
				-- 1. In the following BNF grammar, the value of
				--	'Current' can be produced by "Real_literal":
				--
				-- Real_literal	= Mantissa [Exponent_part]
				-- Exponent_part = "E" Exponent
				--				 | "e" Exponent
				-- Exponent		= Integer_literal
				-- Mantissa		= Decimal_literal
				-- Decimal_literal = Integer_literal ["." [Integer]] | "." Integer
				-- Integer_literal = [Sign] Integer
				-- Sign			= "+" | "-"
				-- Integer		= Digit | Digit Integer
				-- Digit		= "0"|"1"|"2"|"3"|"4"|"5"|"6"|"7"|"8"|"9"
				--
				-- 2. The numerical value represented by 'Current'
				--	is within the range that can be represented
				--	by an instance of type DOUBLE.
		end

	is_boolean: BOOLEAN
			-- Does `Current' represent a BOOLEAN?
		deferred
		ensure
			is_boolean: Result = (true_constant.same_string (as_lower.as_string_8) or
				false_constant.same_string (as_lower.as_string_8))
		end

	is_integer_8: BOOLEAN
			-- Does `Current' represent an INTEGER_8?
		deferred
		end

	is_integer_16: BOOLEAN
			-- Does `Current' represent an INTEGER_16?
		deferred
		end

	is_integer, is_integer_32: BOOLEAN
			-- Does `Current' represent an INTEGER_32?
		deferred
		end

	is_integer_64: BOOLEAN
			-- Does `Current' represent an INTEGER_64?
		deferred
		end

	is_natural_8: BOOLEAN
			-- Does `Current' represent a NATURAL_8?
		deferred
		end

	is_natural_16: BOOLEAN
			-- Does `Current' represent a NATURAL_16?

		deferred
		end

	is_natural, is_natural_32: BOOLEAN
			-- Does `Current' represent a NATURAL_32?
		deferred
		end

	is_natural_64: BOOLEAN
			-- Does `Current' represent a NATURAL_64?
		deferred
		end

feature -- Conversion

	frozen to_cil: SYSTEM_STRING
			-- Create an instance of SYSTEM_STRING using characters
			-- of Current between indices `1' and `count'.
		require
			is_dotnet: {PLATFORM}.is_dotnet
		do
			Result := dotnet_convertor.from_string_to_system_string (Current)
		ensure
			to_cil_not_void: Result /= Void
		end

	to_string_8: STRING_8
			-- Convert `Current' as a STRING_8.
		require
			is_valid_as_string_8: is_valid_as_string_8
		do
			Result := as_string_8
		ensure
			as_string_8_not_void: Result /= Void
			identity: (conforms_to ("") and Result = Current) or (not conforms_to ("") and Result /= Current)
		end

	as_string_8: STRING_8
			-- Convert `Current' as a STRING_8. If a code of `Current' is
			-- not a valid code for a STRING_8 it is replaced with the null
			-- character.
		local
			i, nb: INTEGER
			l_code: like code
		do
			if attached {STRING_8} Current as l_result then
				Result := l_result
			else
				nb := count
				create Result.make (nb)
				Result.set_count (nb)
				from
					i := 1
				until
					i > nb
				loop
					l_code := code (i)
					if Result.valid_code (l_code) then
						Result.put_code (l_code, i)
					else
						Result.put_code (0, i)
					end
					i := i + 1
				end
			end
		ensure
			as_string_8_not_void: Result /= Void
			identity: (conforms_to ("") and Result = Current) or (not conforms_to ("") and Result /= Current)
		end

	as_string_32, to_string_32: STRING_32
			-- Convert `Current' as a STRING_32.
		local
			i, nb: INTEGER
		do
			if attached {STRING_32} Current as l_result then
				Result := l_result
			else
				nb := count
				create Result.make (nb)
				Result.set_count (nb)
				from
					i := 1
				until
					i > nb
				loop
					Result.put_code (code (i), i)
					i := i + 1
				end
			end
		ensure
			as_string_32_not_void: Result /= Void
			identity: (conforms_to (create {STRING_32}.make_empty) and Result = Current) or (not conforms_to (create {STRING_32}.make_empty) and Result /= Current)
		end

	as_lower: like Current
			-- New object with all letters in lower case.
		require
			is_valid_as_string_8: is_valid_as_string_8
		deferred
		ensure
			as_lower_attached: Result /= Void
			length: Result.count = count
			anchor: count > 0 implies Result.code (1).to_character_8 = code (1).to_character_8.as_lower
			recurse: count > 1 implies Result.substring (2, count) ~ substring (2, count).as_lower
		end

	as_upper: like Current
			-- New object with all letters in upper case
		require
			is_valid_as_string_8: is_valid_as_string_8
		deferred
		ensure
			as_upper_attached: Result /= Void
			length: Result.count = count
			anchor: count > 0 implies Result.code (1).to_character_8 = code (1).to_character_8.as_upper
			recurse: count > 1 implies Result.substring (2, count) ~ substring (2, count).as_upper
		end

feature -- Element change

	plus alias "+" (s: READABLE_STRING_GENERAL): like Current
		require
			argument_not_void: s /= Void
			compatible_strings: is_string_8 implies s.is_valid_as_string_8
		deferred
		ensure
			plus_not_void: Result /= Void
			new_count: Result.count = count + s.count
			initial: elks_checking implies Result.substring (1, count) ~ Current
			final: elks_checking implies Result.substring (count + 1, count + s.count).same_string (s)
		end

feature -- Duplication

	substring (start_index, end_index: INTEGER): like Current
			-- Copy of substring containing all characters at indices
			-- between `start_index' and `end_index'
		deferred
		ensure
			substring_not_void: Result /= Void
			substring_count: Result.count = end_index - start_index + 1 or Result.count = 0
			first_code: Result.count > 0 implies Result.code (1) = code (start_index)
			recurse: Result.count > 0 implies
				Result.substring (2, Result.count) ~ substring (start_index + 1, end_index)
		end

feature {NONE} -- Assertion helper

	elks_checking: BOOLEAN = False
			-- Are ELKS checkings verified? Must be True when changing implementation of STRING_GENERAL or descendant.

feature {NONE} -- Implementation

	string_searcher: STRING_SEARCHER
			-- Facilities to search string in another string.
		deferred
		ensure
			string_searcher_not_void: Result /= Void
		end

	c_string_provider: C_STRING
			-- To create Eiffel strings from C string.
		once
			create Result.make_empty (0)
		ensure
			c_string_provider_not_void: Result /= Void
		end

	ctoi_convertor: STRING_TO_INTEGER_CONVERTOR
			-- Convertor used to convert string to integer or natural
		once
			create Result.make
			Result.set_leading_separators (" ")
			Result.set_trailing_separators (" ")
			Result.set_leading_separators_acceptable (True)
			Result.set_trailing_separators_acceptable (True)
		ensure
			ctoi_convertor_not_void: Result /= Void
		end

	ctor_convertor: STRING_TO_REAL_CONVERTOR
			-- Convertor used to convert string to real or double
		once
			create Result.make
			Result.set_leading_separators (" ")
			Result.set_trailing_separators (" ")
			Result.set_leading_separators_acceptable (True)
			Result.set_trailing_separators_acceptable (True)
		ensure
			ctor_convertor_not_void: Result /= Void
		end

	dotnet_convertor: SYSTEM_STRING_FACTORY
			-- Convertor used to convert from and to SYSTEM_STRING.
		once
			create Result
		ensure
			dotnet_convertor_not_void: Result /= Void
		end

feature {READABLE_STRING_GENERAL} -- Implementation

	internal_hash_code: INTEGER
			-- Cache for `hash_code'

end