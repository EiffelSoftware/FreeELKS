note

	description: "[
		Basic mathematical constants.
		This class may be used as ancestor by classes needing its facilities.
		]"

	library: "Free implementation of ELKS library"
	copyright: "Copyright (c) 2005, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class
	MATH_CONST

feature -- Access

	Pi: REAL_64 = 3.1415926535897932384626433832795029

	Sqrt2: REAL_64 = 1.4142135623730950488016887242096981
			-- Square root of 2

	Euler: REAL_64 = 2.7182818284590452353602874713526625
			-- Logarithm base

end