note
	description: "[
		Operating system signal failure
		]"
	library: "Free implementation of ELKS library"
	status: "See notice at end of class."
	legal: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	OPERATING_SYSTEM_SIGNAL_FAILURE

inherit
	OPERATING_SYSTEM_EXCEPTION

feature -- Access

	frozen code: INTEGER
			-- Exception code
		do
			Result := {EXCEP_CONST}.signal_exception
		end

	signal_code: INTEGER
			-- Signal code

feature {EXCEPTION_MANAGER} -- Status setting

	set_signal_code (a_code: like signal_code)
			-- Set `signal_code' with `a_code'
		do
			signal_code := a_code
		end

feature {NONE} -- Accesss

	frozen internal_meaning: STRING = "Operating system signal.";

note
	copyright: "Copyright (c) 1984-2012, Eiffel Software and others"
	license:   "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"

end
