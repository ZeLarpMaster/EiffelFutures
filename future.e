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
		end

feature -- Access

	value: detachable G

	done: BOOLEAN
			-- Is `Current' already done?
		do
			Result := attached value
		end

	add_done_action(action: PROCEDURE[TUPLE[like value]])
			-- Adds a new callback to `done_actions'
		do
			done_actions.extend(action)
		end

	set_value(new_value: attached like value)
			-- Sets the new `value'
		require
			NotAlreadySet: not done
		do
			value := new_value
			done_actions.call(value)
		end

feature {NONE} -- Implementation

	done_actions: ACTION_SEQUENCE[TUPLE[like value]]
			-- Actions to execute when `Current' receives a value

end
