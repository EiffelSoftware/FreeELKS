indexing
	description: "[
		Objects representing delayed calls to a function, with some arguments possibly still open.
		]"
	note: "[
		Features are the same as those of ROUTINE, with `apply' made effective, and the addition
		of `last_result' and `item'.
		]"
	library: "Free implementation of ELKS library"
	copyright: "Copyright (c) 1986-2004, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class
	FUNCTION [BASE_TYPE, OPEN_ARGS -> TUPLE create default_create end, RESULT_TYPE]

inherit
	ROUTINE [BASE_TYPE, OPEN_ARGS]
		redefine
			is_equal, copy
		end

feature -- Access
	
	last_result: RESULT_TYPE
			-- Result of last call, if any.

	item (args: OPEN_ARGS): RESULT_TYPE is
			-- Result of calling function with `args' as operands.
		require
			valid_operands: valid_operands (args)
			callable: callable
		do
			set_operands (args)
			Result := rout_obj_call_function (rout_disp, $internal_operands)
			last_result := Result
			if is_cleanup_needed then
				remove_gc_reference
			end
		end

feature -- Comparison

	is_equal (other: like Current): BOOLEAN is
			-- Is associated function the same as the one
			-- associated with `other'?
		do
			Result := Precursor (other) and then
					 equal (last_result, other.last_result)
		end

feature -- Duplication

	copy (other: like Current) is
			-- Use same function as `other'.
		do
			Precursor (other)
			last_result := other.last_result
		end

feature -- Basic operations

	apply is
			-- Call function with `operands' as last set.
		do
			last_result := rout_obj_call_function (rout_disp, $internal_operands)
		end

feature -- Obsolete

	eval (args: OPEN_ARGS): RESULT_TYPE is
			-- Result of evaluating function for `args'.
		obsolete
			"Please use `item' instead"
		require
			valid_operands: valid_operands (args)
			callable: callable
		do
			Result := item (args)
		end

feature {NONE} -- Implementation

	rout_obj_call_function (rout, args: POINTER): RESULT_TYPE is
			-- Perform call to `rout' with `args' as operands.
		external
			"C inline use %"eif_rout_obj.h%""
		alias
			"rout_obj_call_agent($rout, $args, $$_result_type)"
		end

end
