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

create {EVENT_LOOP}
	make

feature {NONE} -- Initialization

	make(a_coro: PROCEDURE[TUPLE])
			-- Initialization for `Current'.
		do
			create ready_event.make(0)
			make_awaitable
			coro := a_coro
			create event.make(0)
			create {WORKER_THREAD} owner_thread.make(agent do
				sleep
				coro.call
				set_done
			end)
			owner_thread.launch
			ready_event.wait
		end

feature -- Access

	is_sleeping: BOOLEAN
			-- Whether or not a thread is sleeping here

	sleep
			-- Sleeps the current thread until it is awakened
		require
			NotAlreadyAsleep: not is_sleeping
		do
			is_sleeping := True
			ready_event.post
			event.wait
			is_sleeping := False
		ensure
			StillNobodySleeping: not is_sleeping
		end

	awake
			-- Awakes the thread which runs `Current'
		require
			IsAlreadyAsleep: is_sleeping
		do
			event.post
		end

feature {NONE} -- Implementation

	coro: PROCEDURE[TUPLE]
			-- The coroutine ran by `Current'

	owner_thread: THREAD
			-- The thread ran by `Current'

	event: SEMAPHORE
			-- Synchronization primitive to block the current thread until task is ready to run again

	ready_event: SEMAPHORE
			-- Synchronization primitive to block the main thread until the `owner_thread' is ready

end
