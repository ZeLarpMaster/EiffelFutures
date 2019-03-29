note
	description: "A basic event loop for async programming"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	EVENT_LOOP

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			create {LINKED_QUEUE[TASK]} ready.make
		end

feature -- Access

	is_stopping: BOOLEAN
			-- Whether or not `Current' is stopping

	is_running: BOOLEAN
			-- Whether or not `Current' is running
		do
			Result := attached current_task
		end

	stop
			-- Stops `Current's execution
		do
			is_stopping := True
		end

feature -- Execution

	await alias "@" (a_future: FUTURE[ANY]): FUTURE[ANY]
			-- Runs `a_future' until it completes and returns its value
		require
			HasTaskRunning: is_running
		do
			if attached current_task as la_task then
				a_future.add_done_action(agent call_soon(la_task))
			end
			-- TODO: Passer le baton
			-- TODO: Sleep the current_task
			Result := a_future
		ensure
			ResultIsDone: Result.done
		end

	call_soon(a_task: TASK)
			-- Puts `a_task' onto the ready queue
		do
			ready.extend(a_task)
		end

feature {NONE} -- Implementation

	current_task: detachable TASK
			-- The {TASK} which is currently executing

	ready: QUEUE[TASK]
			-- {QUEUE} of tasks ready to run

end
