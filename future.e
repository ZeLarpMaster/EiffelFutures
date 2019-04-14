note
	description: "Holds a future value"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FUTURE [G]

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			create done_actions
			done := False
		end

feature -- Access

	value: detachable G
			-- The return value of `Current'
			-- TODO: Do a func which returns the attached value?

	done: BOOLEAN
			-- Is `Current' already done?

	add_done_action(action: PROCEDURE[TUPLE])
			-- Adds a new callback to `done_actions'
		do
			done_actions.extend(action)
		end

	set_value(new_value: like value)
			-- Sets the new `value'
		require
			NotAlreadySet: not done
		do
			value := new_value
			done := True
			done_actions.call(value)
		end

feature {NONE} -- Implementation

	done_actions: ACTION_SEQUENCE[TUPLE]
			-- Actions to execute when `Current' receives a value

end
