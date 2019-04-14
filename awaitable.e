note
	description: "Summary description for {AWAITABLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	AWAITABLE

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			create done_actions
			done := False
		end

feature -- Access

	done: BOOLEAN
			-- Is `Current' already done?

	add_done_action(action: PROCEDURE[TUPLE])
			-- Adds a new callback to `done_actions'
		do
			done_actions.extend(action)
		end

feature {NONE} -- Implementation

	done_actions: ACTION_SEQUENCE[TUPLE]
			-- Actions to execute when `Current' is set to done

	set_done
			-- Sets `Current' to the done state
		require
			NotAlreadyDone: not done
		do
			done := True
			done_actions.call
		end

end
