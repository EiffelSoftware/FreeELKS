note
	description: "[
			Platform specific encoding of Unicode strings. By default, UTF-8 on unix or UTF-16 on Windows.

			Mixed-encoding consideration
			============================

			Most operating systems have conventions for strings that are incompatible with Unicode.
			On UNIX, a string is just a null-terminated byte sequence, it does not follow any
			specific encoding. Usually the locale setting enables you to see the string the way
			you expect.
			On Windows, the sequence of names is made of null-terminated UTF-16 code unit sequence. Windows
			does not guarantee that the sequence is actually a valid UTF-16 sequence.

			In other words, when there is an invalid UTF-8 encoding on UNIX, or an invalid UTF-16 encoding
			on Windows, the string is not directly representable as a Unicode string. To make it possible
			to create and store strings in a textually representable form, the query `string' will create
			an encoded representation that can be then later used in `make' to create a NATIVE_STRING
			equivalent to the original string. The encoding is described in UTF_CONVERTER's note clause
			and is a fourth variant of the recommended practice for replacement characters in Unicode
			(see http://www.unicode.org/review/pr-121.html).

			]"
	date: "$Date$"
	revision: "$Revision$"

class
	NATIVE_STRING

inherit
	NATIVE_STRING_HANDLER

create
	make, make_empty, make_from_pointer, make_from_raw_string

feature {NONE} -- Initialization

	make (a_string: READABLE_STRING_GENERAL)
			-- Initialize an instance of Current using `a_string' treated as a sequence
			-- of Unicode characters.
		require
			a_string_not_void: a_string /= Void
		do
			make_empty (a_string.count)
			set_string (a_string)
		end

	make_empty (a_length: INTEGER)
			-- Initialize an empty instance of Current that will accomodate `a_length' characters.
			-- The memory area is not initialized.
		require
			a_length_positive: a_length >= 0
		do
				-- Allocate for `a_length' code units and the null character.
			create managed_data.make (a_length * unit_size + unit_size)
		end

	make_from_pointer (a_pointer: POINTER)
			-- Initialize current from `a_pointer', a platform system specific null-terminated string.
		require
			a_path_pointer_not_null: a_pointer /= default_pointer
		local
			l_count: INTEGER
		do
				-- Calculate the length of the string pointed by `a_pointer'.
			l_count := pointer_length_in_bytes (a_pointer)
				-- Make a copy of `a_pointer' including the null character.
			create managed_data.make_from_pointer (a_pointer, l_count + unit_size)
		end

	make_from_raw_string (a_raw_string: like raw_string)
			-- Initialize current from `a_raw_string'.
		require
			a_raw_string_not_void: a_raw_string /= Void
		local
			i: INTEGER
		do
				-- Create the memory area including the null-terminating character.
			create managed_data.make (a_raw_string.count + unit_size)
			across a_raw_string as l_c loop
				managed_data.put_character (l_c.item, i)
				i := i + 1
			end
				-- Write null terminator
			if {PLATFORM}.is_windows then
				managed_data.put_natural_16 (0, i)
			else
				managed_data.put_natural_8 (0, i)
			end
		ensure
			set: raw_string.same_string (a_raw_string)
		end

feature -- Access

	raw_string: STRING_8
			-- Sequence of bytes representing `Current'.
		local
			l_cstr: C_STRING
		do
				-- Alias `managed_data' to be a C string so that we copy the raw sequence
				-- of bytes into a STRING_8 but we do not include the null-terminating character.
			create l_cstr.make_shared_from_pointer_and_count (managed_data.item, managed_data.count)
			Result := l_cstr.substring (1, managed_data.count - unit_size)
		end

	string: STRING_32
			-- Representation of Current.
		local
			u: UTF_CONVERTER
		do
				-- Taking the `raw_string' representation of Current, we decode it as a Unicode string.
			if {PLATFORM}.is_windows then
				Result := u.utf_16le_string_8_to_escaped_string_32 (raw_string)
			else
				Result := u.utf_8_string_8_to_escaped_string_32 (raw_string)
			end
		end

	item: POINTER
			-- Get pointer to allocated area.
		do
			Result := managed_data.item
		ensure
			item_not_null: Result /= default_pointer
		end

	managed_data: MANAGED_POINTER
			-- Hold data of Current.

feature -- Element change

	set_string (a_string: READABLE_STRING_GENERAL)
			-- Set `string' with `a_string'	treated as a sequence of Unicode characters.
		require
			a_string_not_void: a_string /= Void
		local
			u: UTF_CONVERTER
			l_storage: STRING_8
		do
				-- Convert `a_string' into a raw byte sequence.
			if {PLATFORM}.is_windows then
				l_storage := u.escaped_utf_32_string_to_utf_16le_string_8 (a_string)
			else
				l_storage := u.escaped_utf_32_string_to_utf_8_string_8 (a_string)
			end

			make_from_raw_string (l_storage)
		end

feature {NONE} -- Implementation

	unit_size: INTEGER
			-- Size in bytes of a unit for `storage'.
		do
			if {PLATFORM}.is_windows then
				Result := 2
			else
				Result := 1
			end
		end

	platform: PLATFORM
			-- Access underlying platform info, used to satisfy invariant below.
		once
			create Result
		end

invariant
	little_endian_windows: {PLATFORM}.is_windows implies platform.is_little_endian
	even_count_on_windows: {PLATFORM}.is_windows implies managed_data.count \\ unit_size = 0

note
	copyright: "Copyright (c) 1984-2012, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
