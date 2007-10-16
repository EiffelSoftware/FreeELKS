indexing

	description: "Objects identified, uniquely during any session, by an integer"
	library: "Free implementation of ELKS library"
	copyright: "Copyright (c) 1986-2004, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class IDENTIFIED_ROUTINES

feature -- Basic operations

	eif_id_object (an_id: INTEGER): ANY is
			-- Object associated with `an_id'
		external
			"built_in"
		end

	eif_object_id (an_object: ANY): INTEGER is
			-- New identifier for `an_object'
		external
			"built_in"
		end

	eif_object_id_free (an_id: INTEGER) is
			-- Free the entry `an_id'
		external
			"built_in"
		end

end
