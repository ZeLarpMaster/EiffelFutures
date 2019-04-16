note
	description: "A task"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TASK

inherit
	AWAITABLE
		rename
			make as make_awaitable
		end
	DEBUG_OUTPUT
		redefine
			debug_output
		end

create {EVENT_LOOP}
	make

feature {NONE} -- Initialization

	make(a_coro: PROCEDURE[TUPLE])
			-- Initialization for `Current'.
		do
			make_awaitable
			coro := a_coro
			create event.make(0)
			create ready_actions
			create {WORKER_THREAD} owner_thread.make(agent do
				sleep
				coro.call
				set_done
			end)
			is_ready := False
			owner_thread.launch
		end

feature -- Access

	is_sleeping: BOOLEAN
			-- Whether or not a thread is sleeping here

	is_ready: BOOLEAN
			-- Whether or not `owner_thread' is ready

	owner_id: STRING_8
		once("OBJECT")
			Result := "T(" + owner_thread.thread_id.out + ")"
		end

	sleep
			-- Sleeps the current thread until it is awakened
		require
			NotAlreadyAsleep: not is_sleeping
		do
			is_sleeping := True
			if not is_ready then
				is_ready := True
				ready_actions.call
			end
			event.wait
		end

	awake
			-- Awakes the thread which runs `Current'
		require
			IsAlreadyAsleep: is_sleeping
		do
			is_sleeping := False
			event.post
		ensure
			StillNobodySleeping: not is_sleeping
		end

	add_ready_action(a_ready_action: PROCEDURE[TUPLE])
			-- Adds a ready action
		do
			if is_ready then
				a_ready_action.call
			else
				ready_actions.extend(a_ready_action)
			end
		end

feature -- Debugging

	debug_output: READABLE_STRING_GENERAL
		do
			Result := owner_id
		end


feature {NONE} -- Implementation

	coro: PROCEDURE[TUPLE]
			-- The coroutine ran by `Current'

	owner_thread: THREAD
			-- The thread ran by `Current'

	event: SEMAPHORE
			-- Synchronization primitive to block the current thread until task is ready to run again

	ready_actions: ACTION_SEQUENCE[TUPLE]
			-- Actions executed when `owner_thread' is ready to execute

end
