note
	description: "A task"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TASK

create
	make

feature {NONE} -- Initialization

	make(a_coro: PROCEDURE[TUPLE])
			-- Initialization for `Current'.
		do
			create {WORKER_THREAD} owner_thread.make (a_coro)
			create event.make(0)
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
			-- TODO: Launch owner_thread if not already started instead of doing a post
			event.post
		end

feature {NONE} -- Implementation

	owner_thread: THREAD
			-- The thread ran by `Current'

	event: SEMAPHORE
			-- Synchronization primitive to block the current thread until task is ready to run again

end
