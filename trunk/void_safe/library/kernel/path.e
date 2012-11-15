note
	description: "[
			Objects representing a path, i.e. a way to identify a file or a directory for the
			current underlying platform. A path is made of two components:
			1 - an optional root which can either be:
				a - a drive letter followed by colon on Windows, i.e. "C:"
				b - "/" for UNIX root directory.
				c - "\\server\share" for Microsoft UNC path.
			2 - a sequence of zero or more names.
			
			A path is absolute if it has a root, and on windows if the root is a drive, then it should
			be followed by "\". Otherwise a path is relative.


			Validity
			========
			
			The current class will not check the validity of filenames. Check your file
			system for your operating system manual for the list of invalid characters.


			Windows consideration
			=====================
			
			When the root of a Windows path is a drive, be aware of the following behavior:
			1 - "C:filename.txt" refers to the file name "filename.txt" in the current directory 
			    on drive "C:".
			2 - "C:sub\filename.txt" refers to the file name "filename.txt" in a subdirectory "sub"
			    of the current directory on drive "C:".
			3 - "C:\sub\filename.txt" refers to the file name "filename.txt" in a subdirectory "sub"
			    located at the root of the drive "C:".
			
			Both forward and backslashes are accepted, but forward slashes are internally converted
			to backward slashes whenever they are used to construct a path.
			
			On Windows, there is a limit of 259 characters for a path. If you need to create a larger
			path, you can do so by using the following conventions which will let you have paths of
			about 32,767 characters:
			1 - Use \\?\ for non-UNC path and let the rest unchanged.
			2 - Use \\?\UNC\server\share for UNC path and let the rest unchanged.
			The above path cannot be used to specify a relative path.
			
			To know more about Windows paths, read the "Naming Files, Paths, and Namespaces"
			document located at:
			  http://msdn.microsoft.com/en-us/library/windows/desktop/aa365247(v=vs.85).aspx


			Unicode consideration
			=====================
			
			The PATH class treats strings as sequence of Unicode characters, i.e. an instance of 
			a READABLE_STRING_8 or descendant will be treated as if characters in the range
			128 .. 255 were Unicode code points.
			This contrasts to the FILE/DIRECTORY classes where to preserve backward compatibility, those
			characters are treated as is.
			
			
			Mixed-encoding consideration
			============================
			
			Most operating systems have conventions for paths that are incompatible with Unicode.
			On UNIX, in a sequence of names, each name is just a null-terminated byte sequence, it
			does not follow any specific encoding. Usually the locale setting enables you to see
			the filename the way you expect.
			On Windows, the sequence of names is made of null-terminated UTF-16 code unit sequence. Windows
			does not guarantee that the sequence is actually a valid UTF-16 sequence.
			
			In other words, when there is an invalid UTF-8 encoding on UNIX, or an invalid UTF-16 encoding
			on Windows, the filename is not directly representable as a Unicode string. To make it possible
			to create and store paths in a textually representable form, the query `name' will create
			an encoded representation that can be then later used in `make_from_string' to create a PATH
			equivalent to the original path. The encoding is described in UTF_CONVERTER's note clause
			and is a fourth variant of the recommended practice for replacement characters in Unicode
			(see http://www.unicode.org/review/pr-121.html).

						
			Immutability
			============
			
			Instances of the current class are immutable.
		]"

	library: "Free implementation of ELKS library"
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	PATH

inherit
	HASHABLE
		redefine
			out, is_equal, copy
		end

	COMPARABLE
		redefine
			out, is_equal, copy
		end

	PATH_HANDLER
		redefine
			out, is_equal, copy
		end

	DEBUG_OUTPUT
		redefine
			out, is_equal, copy
		end

create {PATH_HANDLER}
	make_from_pointer

create {PATH}
	make_from_storage

create
	make_empty,
	make_current,
	make_from_string,
	make_from_path

feature {NONE} -- Initialization

	make_empty
			-- Initialize current as an empty path.
		do
			create storage.make_empty
		ensure
			is_empty: is_empty
		end

	make_current
			-- Initialize current as the symbolic representation of the current working directory
		do
			create storage.make (unit_size)
			storage.append_character ('.')
			if {PLATFORM}.is_windows then
				storage.append_character ('%U')
			end
		end

	make_from_string (a_path: READABLE_STRING_GENERAL)
			-- Initialize current from `a_path' treated as a sequence of Unicode characters.
			-- If `a_path' is trying to represent a mixed-encoded path, then `a_path' should use
			-- the escaped representation as described in UTF_CONVERTER.
		require
			a_path_not_void: a_path /= Void
		do
			create storage.make (a_path.count * unit_size)
			if not a_path.is_empty then
					-- We start from nothing, so we do not add a directory separator regardless.
				internal_append_into (storage, a_path, False)
			end
		ensure
			roundtrip: name.same_string_general (a_path)
		end

	make_from_path (a_path: PATH)
			-- Initialize current from `a_path'.
		require
			a_path_not_void: a_path /= Void
		do
			storage := a_path.storage.twin
		ensure
			same_path: same_as (a_path)
		end

	make_from_storage (a_path: STRING_8)
			-- Initialize current from `a_path'.
		require
			a_path_not_void: a_path /= Void
		do
			storage := a_path
		ensure
			shared: storage = a_path
		end

	make_from_pointer (a_path_pointer: POINTER)
			-- Initialize current from `a_path_pointer', a platform system specific encoding of
			-- a path.
		require
			a_path_pointer_not_null: a_path_pointer /= default_pointer
		local
			l_cstr: C_STRING
			l_count: INTEGER
		do
				-- Let's be safe here, we take the min between the recorded size and the actual size.
			l_count := file_info.pointer_length_in_bytes (a_path_pointer)
			create l_cstr.make_shared_from_pointer_and_count (a_path_pointer, l_count)
			storage := l_cstr.substring (1, l_count)
			if {PLATFORM}.is_windows then
					-- If we got a PATH that had "/", we need to replace them by "\".
				storage.replace_substring_all ("/%U", directory_separator_symbol)
			end
		end

feature -- Status report

	is_current_symbol: BOOLEAN
			-- Is Current a representation of "."?
		do
			if storage.count = unit_size then
				Result := storage.item (1) = '.'
				if {PLATFORM}.is_windows and Result then
					Result := storage.item (2) = '%U'
				end
			end
		end

	is_parent_symbol: BOOLEAN
			-- Is Current Representation of ".."?
		do
			if storage.count = 2 * unit_size then
				Result := storage.item (1) = '.' and storage.item (1 + unit_size) = '.'
				if {PLATFORM}.is_windows and Result then
					Result := storage.item (2) = '%U' and storage.item (2 + unit_size) = '%U'
				end
			end
		end

	is_representable: BOOLEAN
			-- Is current representable as a Unicode character sequence?
		local
			u: UTF_CONVERTER
		do
			if {PLATFORM}.is_windows then
				Result := u.is_valid_utf_16le_string_8 (storage)
			else
				Result := u.is_valid_utf_8_string_8 (storage)
			end
		end

	has_root: BOOLEAN
			-- Does current have a root?
		do
			Result := root_end_position /= 0
		end

	is_empty: BOOLEAN
			-- Is current empty, i.e. no root and no sequence of names?
		do
			Result := storage.is_empty
		end

	is_relative: BOOLEAN
			-- Is current path relative?
		do
			Result := not is_absolute
		end

	is_absolute: BOOLEAN
			-- Is current path absolute?
		do
			Result := has_root
			if Result and {PLATFORM}.is_windows then
					-- If this is a drive letter root, verify that the third letter is "\".
				Result := storage.count >= 6 and then storage.item (3) = ':' and then storage.item (5) = '\' and then
					storage.item (6) = '%U'
			end
		end

	is_simple: BOOLEAN
			-- Is current path made of only one name and no root?
			-- I.e. readme.txt, usr.
		do
			if not has_root then
				if {PLATFORM}.is_windows then
					Result := storage.substring_index (directory_separator_symbol, 1) = 0
				else
					Result := storage.index_of ('/', 1) = 0
				end
			end
		end

	is_same_file_as (a_path: PATH): BOOLEAN
			-- Does `Current' and `a_path' points to the same file on disk? It is different from path equality
			-- as it will take into account symbolic links.
			-- If `Current' or/and `a_path' do not exists, it will yield false, otherwise it will compare
			-- the file at the file system level.
		local
			l_p1, l_p2: MANAGED_POINTER
		do
			l_p1 := to_pointer (Void)
			l_p2 := a_path.to_pointer (Void)
			Result := c_same_files (l_p1.item, l_p2.item)
		end

feature -- Access

	root: detachable PATH
			-- Root if any of current path.
		local
			l_pos: INTEGER
		do
			l_pos := root_end_position
			if l_pos /= 0 then
				if l_pos = storage.count then
					create Result.make_from_storage (storage)
				else
					create Result.make_from_storage (storage.substring (1, l_pos))
				end
			end
		ensure
			has_root_implies_not_void: has_root implies Result /= Void
		end

	parent: detachable PATH
			-- Parent directory if any.
			-- The parent of a path consists of `root' if any, and of each
			-- simple names in the current sequence except for the last.
		local
			l_pos: INTEGER
		do
			l_pos := position_of_last_directory_separator (True)
				-- Only create
			if l_pos = 0 and {PLATFORM}.is_windows then
				if attached root as l_root then
						-- Case of a path like "C:abc.txt", the parent is "C:"
					Result := l_root
				end
			elseif l_pos = 1 then
					-- Case where we have "/usr" or "\Windows", the parent is just the root "/" or "\"
				create Result.make_from_storage (storage.substring (1, unit_size))
			elseif l_pos > 1 then
				if l_pos <= root_end_position then
						-- Case where we have "\\server\share", we cannot cut this path into just "\\server".
					check is_windows: {PLATFORM}.is_windows end
					Result := root
				else
					create Result.make_from_storage (storage.substring (1, l_pos - 1))
				end
			end
		end

	entry: detachable PATH
			-- Name of file or directory denoted by Current if any.
			-- This is the last name in the current sequence.
		local
			l_pos: INTEGER
			l_end_root: INTEGER
		do
			l_pos := position_of_last_directory_separator (False)
			if l_pos = 0 then
				l_end_root := root_end_position
				if l_end_root > 0 then
						-- We have a root, case of "C:abc" on Windows or "/" on UNIX.
						-- On Windows, we return just "abc" and no entry on UNIX.
					if l_end_root < storage.count then
						create Result.make_from_storage (storage.substring (l_end_root + 1, storage.count))
					end
				else
						-- There is no directory separator, or just a trailing one, so current is a simple path
					Result := Current
				end
			else
					-- We go after the directory separator
				l_end_root := root_end_position
				if l_pos <= l_end_root then
						-- We clearly have "\\server\share" for Windows or "/xxx" for Unix. Thus there is
						-- only an entry on UNIX if there is something after the / (i.e. "xxx" in the case of "/xxx").
					if l_end_root < storage.count then
						create Result.make_from_storage (storage.substring (l_end_root + 1, storage.count))
					end
				else
					create Result.make_from_storage (storage.substring (l_pos + unit_size, storage.count))
				end
			end
		end

	components: ARRAYED_LIST [PATH]
			-- Sequence of simple paths making up Current, including `root' if any.
		local
			l_parent: detachable PATH
		do
			create Result.make (10)
			if attached root as l_root then
				Result.extend (l_root)
				Result.forth
			end
			if attached entry as l_entry then
				Result.put_right (l_entry)
				from
					l_parent := parent
				until
					l_parent = Void
				loop
					if attached l_parent.entry as l_parent_entry then
						Result.put_right (l_parent_entry)
						l_parent := l_parent.parent
					else
						l_parent := Void
					end
				end
			end
		end

	absolute_path: PATH
			-- Absolute path of Current.
			-- If Current is already absolute, then return Current.
			-- If Current is empty, then return the current workding directory.
			-- Otherwise resolve the current path in a platform specific way:
			-- * On UNIX, resolve against the current working directory
			-- * On Windows:
			--    a) if current has a drive letter which is not followed by "\"
			--       resolve against the current working directory for that drive letter,
			--       otherwise resolve against the current working directory.
			--    b) if current path starts with "\", not a double "\\", then resolve
			--       against the root of the current working directory (i.e. a drive
			--       letter "C:\" or a UNC path "\\server\share\".)
		do
			if storage.is_empty then
				Result := env.current_working_path
			else
				if is_absolute then
					Result := Current
				else
					if {PLATFORM}.is_windows then
						if attached root as l_root then
								-- Path is not absolute but has a root, it can only be a drive letter.
								-- Now we have to resolve "c:something\file.txt" using the current working
								-- directory of the "c:" drive.
							if attached env.current_working_path as l_env_root and then l_env_root.same_as (l_root) then
									-- Same root so we simply append.
								Result := l_env_root
							else
									-- There is no way we can figure this out, so we simply append to the current root.
								Result := l_root
							end
						else
								-- Case of either "abc\dev" or "\abc\def"	
							if storage.item (1) = '\' and storage.item (2) = '%U' then
								Result := env.current_working_path
								if attached Result.root as l_root then
									Result := l_root
								else
										-- The current working path as no root? It is hard to believe.
								end
							else
								Result := env.current_working_path
							end
						end
					else
						Result := env.current_working_path
					end
						-- Now that we have built a valid path, we just append the relative one.
					internal_path_append_into (Result.storage, storage, True)
				end
			end
		ensure
			has_root: Result.has_root
		end

	canonical_path: PATH
			-- Canonical path of Current.
			-- Similar to `absolute_path' except that sequences containing "." or ".." are
			-- resolved.
		local
			l_components: like components
			l_absolute_path: like absolute_path
			l_storage: like storage
		do
			l_absolute_path := absolute_path
			if attached l_absolute_path.root as l_root then
				create l_storage.make (l_absolute_path.storage.count)
					-- Extract all components of the path, and if we encounter ".", we simply remove it,
					-- if we encounter "..", we remove the previous element and the current element.
				l_components := l_absolute_path.components
				check
					l_components_has_root: l_components.count >= 1
					l_components_first_is_root: l_components.first.same_as (l_root)
				end
				from
					l_components.start
						-- Record `root' and move to the next item in the list
					internal_path_append_into (l_storage, l_components.item.storage, True)
					l_components.remove
				until
					l_components.after
				loop
					if l_components.item.is_current_symbol then
							-- Our simple name is just ".", we skip it.
						l_components.remove
					elseif l_components.item.is_parent_symbol then
							-- If our simple name is "..", we skip it and remove the previous
							-- elements as well. If there is no previous element, then there is
							-- not much we can do so we ignore it.
						if not l_components.isfirst then
							l_components.back
							l_components.remove
						end
						l_components.remove
					else
						l_components.forth
					end
				end
				across l_components as l_component loop
					internal_path_append_into (l_storage, l_component.item.storage, True)
				end
				create Result.make_from_storage (l_storage)
			else
				check False end
				Result := l_absolute_path
			end
		end

	hash_code: INTEGER
			-- Hash code value
		do
			if {OPERATING_ENVIRONMENT}.case_sensitive_path_names then
				Result := storage.hash_code
			else
				Result := internal_hash_code
				if internal_hash_code = -1  then
					Result := name.as_lower.hash_code
					internal_hash_code := Result
				end
			end
		end

feature -- Status setting

	extended (a_name: READABLE_STRING_GENERAL): PATH
			-- New path instance of current extended with path `a_name'.
			-- If current is not empty, then `a_path' cannot have a root.
			-- Note that `a_name' can be an encoding of a mixed-encoding simple name and it will
			-- be decoded accordingly (see note clause for the class for more details.)
		require
			a_name_not_void: a_name /= Void
			a_name_not_empty: not a_name.is_empty
			a_name_has_no_root: not is_empty implies not (create {PATH}.make_from_string (a_name)).has_root
		do
			Result := extended_path (create {PATH}.make_from_string (a_name))
		ensure
			not_empty: not Result.is_empty
		end

	extended_path alias "+" (a_path: PATH): PATH
			-- New path instance of current extended with simple path `a_path'.
			-- If current is not empty, then `a_path' cannot have a root.
		require
			a_path_not_void: a_path /= Void
			a_path_not_empty: not a_path.is_empty
			a_path_has_no_root: not is_empty implies not a_path.has_root
		local
			l_storage: like storage
		do
				-- Pre-allocate all the bytes necessary to store the combination of `Current', `a_path' and
				-- the directory separator.
			create l_storage.make (storage.count + a_path.storage.count + unit_size)
				-- Get a copy of `storage' from Current'
			l_storage.append (storage)
				-- Append `a_path.storage' to `l_storage'.
			internal_path_append_into (l_storage, a_path.storage, True)
				-- Create a new PATH instance.
			create Result.make_from_storage (l_storage)
		ensure
			not_empty: not Result.is_empty
		end

	appended (a_extra: READABLE_STRING_GENERAL): PATH
			-- New path instance of current where `entry' is extended with `a_extra'.
		require
			a_extra_not_void: a_extra /= Void
			a_extra_not_empty: not a_extra.is_empty
			has_entry: entry /= Void
		local
			l_storage: like storage
		do
				-- Pre-allocate all the bytes necessary to store the combination of `Current'
				-- and `a_extra'.
			create l_storage.make (storage.count + a_extra.count * unit_size)
				-- Get a copy of `storage' from Current'
			l_storage.append (storage)
				-- Append `a_extra'.
			internal_append_into (l_storage, a_extra, False)
				-- Create a new PATH instance.
			create Result.make_from_storage (l_storage)
		ensure
			not_empty: not Result.is_empty
		end

feature -- Comparison

	same_as (other: PATH): BOOLEAN
			-- Is Current the same path as `other'?
			-- Note that no canonicalization is being performed to compare paths,
			-- paths are compared using the OS-specific convention for letter case.
		do
			if other = Current then
				Result := True
			else
					-- Depending on the OS specific setting.
				if {OPERATING_ENVIRONMENT}.case_sensitive_path_names then
					Result := is_case_sensitive_equal (other)
				else
					Result := is_case_insensitive_equal (other)
				end
			end
		end

	is_less alias "<" (other: like Current): BOOLEAN
			-- <Precursor>
		do
			if {OPERATING_ENVIRONMENT}.case_sensitive_path_names then
				Result := storage < other.storage
			else
					-- FIXME: the implementation of `is_less' is suboptimal since
					-- it creates 4 new, potentially big, objects
				Result := name.as_lower < other.name.as_lower
			end
		end

	is_equal (other: like Current): BOOLEAN
			-- <Precursor>
		do
			Result := same_as (other)
		end

	is_case_sensitive_equal (other: PATH): BOOLEAN
			-- Compare path and paying attention to case.
		do
			if other = Current then
				Result := True
			else
				Result := storage.is_equal (other.storage)
			end
		end

	is_case_insensitive_equal (other: PATH): BOOLEAN
			-- Compare path without paying attention to case. If the path is containing some mixed-encoding
			-- we might ignore many characters when doing the case comparison.
		do
			if other = Current then
				Result := True
			else
				Result := name.is_case_insensitive_equal (other.name)
			end
		end

feature -- Duplication

	copy (other: like Current)
			-- <Precursor>
		do
			if other /= Current then
					-- Duplicate storage
				storage := other.storage.twin
			end
		end

feature -- Output

	out: STRING_8
			-- ASCII representation of the underlying filename, by default if the current path
			-- has a valid Unicode representation, it is the associated UTF-8 version, otherwise
			-- the raw sequence.
		local
			u: UTF_CONVERTER
		do
			Result := u.utf_32_string_to_utf_8_string_8 (name)
		end

	name: STRING_32
			-- If current is representable in Unicode, the Unicode representation.
			-- Otherwise all non-valid sequences for the current platform in the path are escaped
			-- as mentioned in the note clause of the class.
			-- To ensure roundtrip, you cannot use `name' directly to create a `FILE', you have to
			-- create a `PATH' instance using `make_from_string' before passing it to the creation
			-- procedure of `FILE' taking an instance of `PATH'.
		local
			u: UTF_CONVERTER
		do
			if {PLATFORM}.is_windows then
				Result := u.utf_16le_string_8_to_escaped_string_32 (storage)
			else
				Result := u.utf_8_string_8_to_escaped_string_32 (storage)
			end
		ensure
			roundtrip: same_as (create {PATH}.make_from_string (Result))
		end

	string_representation: STRING_32
		obsolete
			"Use `name' instead."
		do
			Result := name
		end

	string_representation_8: STRING_8
		obsolete
			"Use `name' instead."
		require
			is_representable: is_representable
			is_valid_extended_ascii: string_representation.is_valid_as_string_8
		do
			Result := string_representation.as_string_8
		end

feature {NONE} -- Output

	debug_output: STRING
			-- String that should be displayed in debugger to represent `Current'.
		do
			Result := out
		end

feature {PATH_HANDLER}

	to_pointer (an_existing_storage: detachable MANAGED_POINTER): MANAGED_POINTER
			-- Platform specific representation of Current using `an_existing_storage' if any, otherwise
			-- a brand new instance.
		local
			l_cstr: C_STRING
		do
				-- FIXME: We need to optimize using `an_existing_storage'.
				-- A `C_STRING' instance is zeroed out, we just need to verify we have an extra `character'
				-- that is the null character at the end, thus the `+ unit_size'.
			create l_cstr.make_empty (storage.count + unit_size)
			l_cstr.set_string (storage)
			Result := l_cstr.managed_data
		end

feature {PATH} -- Implementation

	storage: STRING_8
			-- Internal storage for Current.
			-- On UNIX, it is a binary sequence encoded in UTF-8 by default.
			-- On Windows, it is a binary sequence encoded in UTF-16LE by default.

feature {NONE} -- Implementation

	internal_hash_code: INTEGER
			-- Cache for `hash_code'.

	file_info: FILE_INFO
			-- Access underlying file system.
		once
			create Result.make
		end

	platform: PLATFORM
			-- Access underlying platform info.
		once
			create Result
		end

	env: EXECUTION_ENVIRONMENT
			-- Access to underlying execution environment.
		once
			create Result
		end

	root_end_position: INTEGER
			-- Position of the last character of `root' if any, 0 otherwise.
		local
			l_drive_letter: CHARACTER
			l_pos: INTEGER
		do
			if not storage.is_empty then
				if {PLATFORM}.is_windows and storage.count >= 4 then
						-- On Windows it has a root if it starts with "X:" or "\\server\share".
					if storage.item (2) = '%U' and storage.item (4) = '%U' then
						l_drive_letter := storage.item (1).as_lower
						if l_drive_letter >= 'a' and l_drive_letter <= 'z' and storage.item (3) = ':' then
								-- We found a drive letter.
							Result := 4
						elseif
							storage.count >= min_unc_path_count and
							l_drive_letter = windows_separator and storage.item (3) = windows_separator and
							storage.item (5) /= windows_separator
						then
								-- We found a path that is of the form "\\X" where X is not "\".
								-- Let's find the next directory separator to build the server name of the UNC path.
							l_pos := storage.substring_index (directory_separator_symbol, 7)
								-- Find out if we have if we have a directory separator which does not repeat itself
								-- until the last character of the path.
							if l_pos > 0 then
									-- We found a path of the form "\\dd\....", where .... could be anything.
									-- Search for the next directory separator forward.
								l_pos := next_contiguous_separator (l_pos, True)
									-- Check that we have at least "\\dd\\\\\b"
								if l_pos + unit_size <= storage.count then
										-- Find the next directory separator if any.
									l_pos := storage.substring_index (directory_separator_symbol, l_pos + unit_size)
									if l_pos = 0 then
											-- No directory separator was found, simply return `storage.count'.
										Result := storage.count
									else
											-- We found a path of the form "\\dd\\\\ss\....." where .... could be anything.
										Result := l_pos - 1
									end
								end
							end
						end
					else
							-- Case of non-ASCII characters, clearly not a root.
					end
				else
					if storage.item (1) = '/' then
						Result := 1
					end
				end
			end
		ensure
			non_negative: Result >= 0
		end

	position_of_last_directory_separator (a_from_beginning: BOOLEAN): INTEGER
			-- Position of the last directory separator in Current, not including the trailing ones if any, 0 if none.
			-- If `a_from_beginning' the index of the first occurrence of directory_separator, otherwise the index
			-- of the last occurrence. Useful to cut the following path in `parent' and `entry': "abc///////cde".
		local
			l_done: BOOLEAN
		do
			if not storage.is_empty then
					-- First ignore the trailing directory separator.
				Result := storage.count - unit_size + 1
				if
					storage.item (Result) = directory_separator and then
					(not {PLATFORM}.is_windows or else storage.item (Result + 1) = '%U')
				then
						-- We found a trailing directory separator, we ignore it and find its beginning.
					Result := next_contiguous_separator (Result, False)
						-- We now go one character beyond to the left.
					Result := Result - unit_size
				end
					-- We are not past the beginning of the path.
				if Result >= 1 then
						-- We have a character that is not a directory separator
					check storage.item (Result) /= directory_separator and ({PLATFORM}.is_windows implies storage.item (Result + 1) = '%U') end
						-- Search for the directory separator now.
					from
					until
						Result < 1 or l_done
					loop
						if storage.item (Result) = directory_separator then
							l_done := not {PLATFORM}.is_windows or else storage.item (Result + 1) = '%U'
						else
							Result := Result - unit_size
						end
					end
					if l_done and a_from_beginning then
						Result := next_contiguous_separator (Result, False)
					end
				end
					-- Uniformize invalid result to 0.
				if Result < 0 then
					Result := 0
				end
			end
		end

	last_contiguous_separator (a_starting_pos: INTEGER): INTEGER
			-- Starting at a position `a_starting_pos' that has a directory separator, continue to the right until we
			-- reach the end of the string match a character that is not a directory separator.
		require
			a_starting_pos_valid: a_starting_pos >= 1 and a_starting_pos <= storage.count
			a_starting_pos_is_well_positionned: a_starting_pos \\ unit_size = 1
			storage_has_separator: storage.item (a_starting_pos) = directory_separator
			valid_windows_separator: {PLATFORM}.is_windows implies storage.item (a_starting_pos + 1) = '%U'
		local
			nb: INTEGER
			l_done: BOOLEAN
		do
			from
				Result := a_starting_pos + unit_size
				nb := storage.count
			until
				Result > nb or l_done
			loop
				if storage.item (Result) = directory_separator then
					if {PLATFORM}.is_windows then
						if storage.item (Result + 1) = '%U' then
							Result := Result + unit_size
						else
							l_done := True
						end
					else
						Result := Result + unit_size
					end
				else
					l_done := True
				end
			end
			Result := Result - unit_size
		end

	next_contiguous_separator (a_starting_pos: INTEGER; a_forward: BOOLEAN): INTEGER
			-- Starting at a position `a_starting_pos' that is a directory separator, compute the position
			-- to the right if `a_forward', to the left otherwise, of the last contiguous directory separator.
			-- If there is only one directory separator, then return value is `a_starting_pos'.
		require
			a_starting_pos_valid: a_starting_pos >= 1 and a_starting_pos <= storage.count
			a_starting_pos_is_well_positionned: {PLATFORM}.is_windows implies a_starting_pos \\ unit_size = 1
			storage_has_separator: storage.item (a_starting_pos) = directory_separator
			valid_windows_separator: {PLATFORM}.is_windows implies storage.item (a_starting_pos + 1) = '%U'
		local
			nb: INTEGER
			l_done: BOOLEAN
			l_step: INTEGER
		do
			if a_forward then
				l_step := unit_size
			else
				l_step := -unit_size
			end
			from
				Result := a_starting_pos + l_step
				nb := storage.count
			until
				Result < 1 or Result > nb or l_done
			loop
				if storage.item (Result) = directory_separator then
					if {PLATFORM}.is_windows then
						if storage.item (Result + 1) = '%U' then
							Result := Result + l_step
						else
							l_done := True
						end
					else
						Result := Result + l_step
					end
				else
					l_done := True
				end
			end
			Result := Result - l_step
		ensure
			valid_position: Result >= 1 and Result <= storage.count
			well_positionned: {PLATFORM}.is_windows implies Result \\ unit_size = 1
			has_separator: storage.item (Result) = directory_separator
			valid_windows_separator: {PLATFORM}.is_windows implies storage.item (Result + 1) = '%U'
		end

	internal_append_into (a_storage: STRING_8; other: READABLE_STRING_GENERAL; a_add_separator: BOOLEAN)
			-- Append `other' to Current, and add a separator if `a_add_separator'.
		require
			other_not_void: other /= Void
			other_not_empty: not other.is_empty
		local
			l_extra_storage: STRING_8
			l_name: detachable STRING_32
			l_other: detachable READABLE_STRING_GENERAL
			l_char: CHARACTER_32
			i, nb: INTEGER
			u: UTF_CONVERTER
		do
			l_other := other
			if {PLATFORM}.is_windows then
					-- Replace all `/' into `\'. Since this case is rare,
					-- it will only allocate a new string if one encounters a `/'.
				from
					i := 1
					l_other := other
					nb := other.count
				until
					i > nb
				loop
					l_char := other.item (i)
					if l_char = unix_separator then
						if l_name = Void then
								-- We need to duplicate our string now.
							create l_name.make (other.count)
							l_name.append_string_general (other)
							l_other := l_name
						end
						l_name.put (windows_separator, i)
					end
					i := i + 1
				end
			end

				-- Remove all the trailing directory separator
			if l_other.item (l_other.count) = directory_separator then
				from
					i := l_other.count
				until
					i = 0 or l_other.item (i) /= directory_separator
				loop
					i := i - 1
				end
				if l_name /= Void then
						-- We already duplicated `other' so we can work on that copy directly.
					check l_name = l_other end
					l_name.keep_head (i)
				else
						-- Create a new copy
					l_other := l_other.substring (1, i)
				end
			end

			if not l_other.is_empty then
				if {PLATFORM}.is_windows then
					l_extra_storage := u.escaped_utf_32_string_to_utf_16le_string_8 (l_other)
				else
					l_extra_storage := u.escaped_utf_32_string_to_utf_8_string_8 (l_other)
				end
				internal_hash_code := -1
				internal_path_append_into (a_storage, l_extra_storage, a_add_separator)
			end
		end

	internal_path_append_into (a_storage, other: STRING_8; a_add_separator: BOOLEAN)
			-- Append `other' in the same format as `a_storage' to `a_storage',
			-- and add a separator if `a_add_separator'.	
		require
			other_not_void: other /= Void
			other_not_empty: not other.is_empty
			other_has_not_trailing_directory_separator: other.item (other.count) /= unix_separator or else ({PLATFORM}.is_windows implies other.item (other.count - 1) /= windows_separator)
		local
			l_add_separator: BOOLEAN
		do
			l_add_separator := a_add_separator
			if l_add_separator and not a_storage.is_empty then
				if {PLATFORM}.is_windows then
					l_add_separator := not (a_storage.item (a_storage.count - 1) = windows_separator and a_storage.item (a_storage.count) = '%U')
				else
					l_add_separator := a_storage.item (a_storage.count) /= unix_separator
				end
				if l_add_separator then
					a_storage.extend (directory_separator)
					if {PLATFORM}.is_windows then
						a_storage.extend ('%U')
					end
				end
			end
			a_storage.append (other)
		end

	unix_separator: CHARACTER = '/'
	windows_separator: CHARACTER = '\'
			-- Platform specific directory separator.

	directory_separator: CHARACTER
			-- Default directory separator for the current platform.
		do
			if {PLATFORM}.is_windows then
				Result := windows_separator
			else
				Result := unix_separator
			end
		end

	unit_size: INTEGER
			-- Size in bytes of a unit for `storage'.
		do
			if {PLATFORM}.is_windows then
				Result := 2
			else
				Result := 1
			end
		end

	directory_separator_symbol: STRING_8
			-- Default directory separator for the current platform.
		once
			if {PLATFORM}.is_windows then
				Result := "\%U"
			else
				Result := "/"
			end
		end

	min_unc_path_count: INTEGER = 10
			-- Number of characters in `storage' to make up a valid UNC path: \\a\c whic is 5 Unicode characters, thus 10 bytes.

feature {NONE} -- Externals

	c_same_files (a_path1, a_path2: POINTER): BOOLEAN
			-- Do C paths `a_path1' and `a_path2' represent the same file?
		require
			a_path1_not_null: a_path1 /= default_pointer
			a_path2_not_null: a_path2 /= default_pointer
		external
			"C inline use %"eif_eiffel.h%""
		alias
			"[
			EIF_BOOLEAN Result = EIF_FALSE;
			#ifdef EIF_WINDOWS
					/* To check this, we use `CreateFileW' to open both file, and then using the information
					 * returned by `GetFileInformationByHandle' we can check whether or not they are indeed
					 * the same.
					 * Note: it is important to use the W version of CreateFileW because arguments
					 * are Unicode, not ASCII. */
				BY_HANDLE_FILE_INFORMATION l_path1_info, l_path2_info;
				HANDLE l_path2_file = CreateFileW ((LPCWSTR) $a_path2, GENERIC_READ, FILE_SHARE_READ, NULL,
					OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
				HANDLE l_path1_file = CreateFileW ((LPCWSTR) $a_path1, GENERIC_READ, FILE_SHARE_READ, NULL,
						OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
			
				if ((l_path2_file == INVALID_HANDLE_VALUE) || (l_path1_file == INVALID_HANDLE_VALUE)) {
						/* We do not need the handles anymore, simply close them. Since Microsoft
						 * API accepts INVALID_HANDLE_VALUE we don't check the validity of arguments. */
					CloseHandle(l_path2_file);
					CloseHandle(l_path1_file);
				} else {
					BOOL success = GetFileInformationByHandle (l_path2_file, &l_path2_info);
					success = success && GetFileInformationByHandle (l_path1_file, &l_path1_info);
						/* We do not need the handles anymore, simply close them. */
					CloseHandle(l_path2_file);
					CloseHandle(l_path1_file);
					if (success) {
							/* Check that `path2' and `path1' do not represent the same file. */
						if
							((l_path2_info.dwVolumeSerialNumber == l_path1_info.dwVolumeSerialNumber) &&
							(l_path2_info.nFileIndexLow == l_path1_info.nFileIndexLow) &&
							(l_path2_info.nFileIndexHigh == l_path1_info.nFileIndexHigh))
						{
							Result = EIF_TRUE;
						}
					}
				}
			#else
				struct stat buf1, buf2;
				int status;
				#ifdef HAS_LSTAT
					status = lstat($a_path1, &buf1);
					if (status == 0) {
							/* We found a file, now let's check if it is not a symbolic link. If it is, we use `stat'
						 	 * to ensure the validity of the link. */
						if ((buf1.st_mode & S_IFLNK) == S_IFLNK) {
							status = stat ($a_path1, &buf1);
						}
					}
					
					if (status == 0) {
						status = lstat($a_path2, &buf2);
						if (status == 0) {
								/* We found a file, now let's check if it is not a symbolic link. If it is, we use `stat'
							 	 * to ensure the validity of the link. */
							if ((buf2.st_mode & S_IFLNK) == S_IFLNK) {
								status = stat ($a_path2, &buf2);
							}
						}
					}
				#else
					status = stat ($a_path1, &buf1);
					if (status == 0) {
						status = stat ($a_path2, &buf2);
					}
				#endif
				if (status == 0) {
						/* Both files are present, check they represent the same one. */
					if ((buf1.st_dev == buf2.st_dev) && (buf1.st_ino == buf2.st_ino)) {
						Result = EIF_TRUE;
					}
				}
			#endif
			return Result;
			]"
		end

invariant
	little_endian_windows: {PLATFORM}.is_windows implies platform.is_little_endian
	even_count_on_windows: {PLATFORM}.is_windows implies storage.count \\ unit_size = 0
	no_forward_slash_on_windows: {PLATFORM}.is_windows implies not storage.has_substring ("/%U")

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
