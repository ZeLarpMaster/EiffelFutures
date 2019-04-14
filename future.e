note
	description: "Holds a future value"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FUTURE [G]

inherit
	AWAITABLE

create
	make

feature -- Access

	value: detachable G
			-- The return value of `Current'
			-- TODO: Do a func which returns the attached value?

	set_value(new_value: like value)
			-- Sets the new `value'
		require
			NotAlreadySet: not done
		do
			value := new_value
			set_done
		end

end
