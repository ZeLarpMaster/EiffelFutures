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
			create mutex.make
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

feature -- Start

	run_until_complete(a_task: TASK)
			-- Runs `Current' until `a_task' is complete
		require
			TaskNotAlreadyDone: not a_task.done
		local
			l_sem: SEMAPHORE
		do
			create l_sem.make(0)
			a_task.add_done_action(agent l_sem.post)
			call_soon(a_task)
			l_sem.wait
		ensure
			TaskDone: a_task.done
		end

feature -- Execution

	await(a_awaitable: AWAITABLE)
			-- Runs until `a_awaitable' completes
		require
			HasTaskRunning: is_running
		do
			if not a_awaitable.done and attached current_task as la_task then
				a_awaitable.add_done_action(agent call_soon(la_task))
				execute_next(False)
				la_task.sleep
			end
		ensure
			AwaitableIsDone: a_awaitable.done
		end

	call_soon(a_task: TASK)
			-- Puts `a_task' onto the ready queue
		do
			ready.extend(a_task)
			execute_next(True)
		end

feature -- Creation

	create_task(a_coro: PROCEDURE[TUPLE]): TASK
			-- Creates a new {TASK} and registers it
		do
			create Result.make(a_coro)
			Result.add_done_action(agent execute_next(False))
		end

	gather(a_tasks: LIST[TASK]): TASK
			-- Gathers a bunch of {TASK}s and returns a {TASK} which completes once they're all complete
		do
			Result := create_task(agent gather_coro(a_tasks))
		end

feature {NONE} -- Implementation

	current_task: detachable TASK
			-- The {TASK} which is currently executing

	ready: QUEUE[TASK]
			-- {QUEUE} of tasks ready to run

	mutex: MUTEX
			-- {MUTEX} which prevents multithreaded access to `ready' and `current_task'

	execute_next(a_check_running: BOOLEAN)
			-- Executes another {TASK} if `ready' isn't empty
		local
			l_task: TASK
		do
			mutex.lock
			if a_check_running implies not is_running then
				if not ready.is_empty then
					l_task := ready.item
					ready.remove
					current_task := l_task
					l_task.awake
				else
					current_task := Void
				end
			end
			mutex.unlock
		ensure
			RunTaskIfPossible: not is_running implies ready.is_empty
		end

	gather_coro(a_tasks: LIST[TASK])
		do
			across a_tasks as la_task loop
				await(la_task.item)
			end
		end

end
