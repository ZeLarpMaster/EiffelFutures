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
			-- Whether or not `Current' is running a {TASK}
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
			-- Runs `a_future' until it completes and returns `a_future'
		require
			HasTaskRunning: is_running
		do
			if attached current_task as la_task then
				a_future.add_done_action(agent call_soon(la_task))
				if not ready.is_empty then
					execute_next
				end
				la_task.sleep
			end
			Result := a_future
		ensure
			ResultIsDone: Result.done
		end

	call_soon(a_task: TASK)
			-- Puts `a_task' onto the ready queue
		do
			ready.extend(a_task)
			if not is_running then
				execute_next
			end
		end

feature {NONE} -- Implementation

	current_task: detachable TASK
			-- The {TASK} which is currently executing

	ready: QUEUE[TASK]
			-- {QUEUE} of tasks ready to run

	execute_next
			-- Takes the next `ready' {TASK} and starts it
		require
			TasksReady: not ready.is_empty
		local
			l_task: TASK
		do
			l_task := ready.item
			ready.remove
			current_task := l_task
			l_task.awake
		ensure
			CurrentTask: is_running
			OneLessReadyTask: ready.count = old ready.count - 1
		end

end
