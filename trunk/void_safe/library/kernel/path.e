note
	description: "[
					Objects representing a path, i.e. a way to identify a file or a directory 
					for the 4 current underlying platform.

					IMPORTANT: the implementation of this interface is temporary
					the real implementation will come shortly [2012-oct-30]

			]"
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	PATH

inherit
	ANY
		redefine
			out
		end

	DEBUG_OUTPUT
		redefine
			out
		end

create
	make_from_string,
	make_from_path,
	make_nested,
	make_nested_path

--convert
--	string_representation: {READABLE_STRING_32, STRING_32}

feature {NONE} -- Initialization

	make_from_string (a_path: READABLE_STRING_GENERAL)
			-- Initialize current from `a_path'.
		require
			a_path_not_void: a_path /= Void
			a_path_not_empty: not a_path.is_empty
		do
			create internal_storage.make (a_path.count)
			internal_storage.append_string_general (a_path)
		end

	make_from_path (a_path: PATH)
			-- Initialize current from `a_path'.
		do
			make_from_string (a_path.string_representation)
		end

	make_nested (a_path: PATH; a_child: READABLE_STRING_GENERAL)
			-- Initialize current from `a_path' as parent directory and using `a_child' as
			-- file name.
		require
			a_child_not_void: a_child /= Void
			a_child_not_empty: not a_child.is_empty
		do
			make_from_path (a_path)
			extend (a_child)
		end

	make_nested_path (a_path, a_child: PATH)
			-- Initialize current from `a_path' as parent directory and using `a_child' as
			-- file name.
		require
			a_child_not_void: a_child /= Void
			a_child_not_empty: not a_child.is_empty
		do
			make_from_path (a_path)
			extend_path (a_child)
		end

feature -- Status report

	is_empty: BOOLEAN
			-- Is current empty, i.e. no root and no sequence of names?
		do
			Result := internal_storage.is_empty
		end

feature -- Status setting

	reset (a_path: READABLE_STRING_GENERAL)
			-- Reset content with a path starting with `a_path'.
		require
			a_path_not_void: a_path /= Void
		do
			internal_storage.wipe_out
			append (a_path, False)
		end

	reset_path (a_path: PATH)
			-- Reset content with a path starting with `a_path'.
		require
			a_path_not_void: a_path /= Void
		do
			reset (a_path.string_representation)
		end

	extend (a_name: READABLE_STRING_GENERAL)
			-- Append the simple name `a_name' to the current path.
		require
			a_name_not_void: a_name /= Void
			a_name_not_empty: not a_name.is_empty
		do
			append (a_name, True)
		end

	extend_path (a_path: PATH)
			-- Append the path `a_path' to the current path.
		require
			a_path_not_void: a_path /= Void
			a_path_not_empty: not a_path.is_empty
		do
			extend (a_path.string_representation)
		end

feature -- Obsolete		

	set_filename (a_filename: READABLE_STRING_GENERAL)
			-- Set the value of the file name part of current path to `a_filename'.
		obsolete "Use extend"
		require
			a_filename_not_void: a_filename /= Void
			a_filename_not_empty: not a_filename.is_empty
		do
			append (a_filename, True)
		end


	add_extension (ext: READABLE_STRING_GENERAL)
			-- Append the extension `ext' to the file name.
		obsolete "Build yourself the filename+extension and use extend"
		require
			ext_not_void: ext /= Void
			ext_not_empty: not ext.is_empty
			ext_not_dot: ext.item (1) /= '.'
		do
			append (".", False)
			append (ext, False)
		end

feature -- Output

	out: STRING_8
		do
			Result := string_representation_8
		end

	string_representation_8: STRING_8
		obsolete "Migrate to unicode ... !!!"
		local
			utf: UTF_CONVERTER
		do
			Result := utf.string_32_to_utf_8_string_8 (internal_storage)
		end

	string_representation: STRING_32
			-- Unicode representation of the underlying filename, by default it the current path
			-- has a valid Unicode representation, it is this representation, otherwise it is
			-- a binary sequence encoded as STRING_32.
			-- It is used for display purpose in graphical application. Using this string instead
			-- of Current to create a `{FILE}' or `{DIRECTORY}' instance may not yield the desired
			-- effect if the current path doesn't have a valid Unicode representation.
		do
			create Result.make_from_string (internal_storage)
		end

feature -- Status report

	debug_output: STRING
			-- String that should be displayed in debugger to represent `Current'.
		do
			Result := string_representation_8
		end

feature {NONE} -- Implementation

	internal_storage: STRING_32

	append (other: READABLE_STRING_GENERAL; a_add_separator: BOOLEAN)
			-- Append `other' to Current
		require
			other_not_void: other /= Void
			other_not_empty: not other.is_empty
		local
			l_add_separator: BOOLEAN
			l_filename: READABLE_STRING_GENERAL
			l_name: STRING_32
		do
				-- First switch all '/' to `\' on Windows
			if {PLATFORM}.is_windows and then other.has_code (('/').natural_32_code) then
				l_name := other.as_string_32.twin
				l_name.replace_substring_all ({STRING_32} "/", {STRING_32} "\")
				l_filename := l_name
			else
				l_filename := other
			end
				-- Find out if we should add a directory separator.
			if a_add_separator then
				if {PLATFORM}.is_windows then
					l_add_separator := internal_storage.item (internal_storage.count) /= {CHARACTER_32} '\'
				else
					l_add_separator := internal_storage.item (internal_storage.count) /= {CHARACTER_32} '/'
				end
			end
			if l_add_separator then
				internal_storage.append_character (operating_environment.directory_separator)
			end
			internal_storage.append_string_general (l_filename)
		end

invariant
	string_representation /= Void

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
