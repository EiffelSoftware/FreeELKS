indexing
	description: "[
		Objects representing delayed calls to a procedure.
		with some operands possibly still open.
		
		Note: Features are the same as those of ROUTINE,
		with `apply' made effective, and no further
		redefinition of `is_equal' and `copy'.
		]"
	library: "Free implementation of ELKS library"
	copyright: "Copyright (c) 1986-2004, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class
	PROCEDURE [BASE_TYPE, OPEN_ARGS -> TUPLE create default_create end]

inherit
	ROUTINE [BASE_TYPE, OPEN_ARGS]

feature -- Calls

	apply is
			-- Call procedure with `args' as last set.
		do
			rout_obj_call_procedure (rout_disp, $internal_operands)
		end

feature {NONE} -- Implementation

	rout_obj_call_procedure (rout: POINTER; args: POINTER) is
			-- Perform call to `rout' with `args'.
		external
			"C inline use %"eif_rout_obj.h%""
		alias
			"rout_obj_call_agent($rout, $args, $$_result_type)"
		end

end
