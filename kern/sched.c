#include <inc/assert.h>
#include <inc/x86.h>
#include <kern/env.h>
#include <kern/monitor.h>

#include <kern/picirq.h>
#include <kern/kclock.h>

static void scheduler(void);

struct Taskstate cpu_ts;
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void) {
	struct Env *idle;
	pic_send_eoi(rtc_check_status());
	// Implement simple round-robin scheduling.
	//
	// Search through 'envs' for an ENV_RUNNABLE environment in
	// circular fashion starting just after the env was
	// last running.  Switch to the first such environment found.
	//
	// If no envs are runnable, but the environment previously
	// running is still ENV_RUNNING, it's okay to
	// choose that environment.
	//
	// If there are no runnable environments,
	// simply drop through to the code
	// below to halt the cpu.

	// LAB 3: Your code here.
	//cprintf("SCHED_YIELD\n");
	int i = (curenv) ? (curenv - envs + 1) : 1;
	int k;
	int flag = 0;
	for (k = 0; k < NENV-1; k++) {
		if (envs[i].env_status == ENV_RUNNABLE) {
			cprintf("envrun RUNNABLE: %08x\n",i);
			env_run(&envs[i]);
			flag = 1;	
		}
		i++;
		//if (!flag) cprintf("NO \n");
		if (i >= NENV || i < 0) i = 0;
	}
	if (!flag) {
		//cprintf("NOTHING ELSE");
		if (curenv)
			if (curenv->env_status == ENV_RUNNABLE || curenv->env_status == ENV_RUNNING) {
				cprintf("envrun RUNNING: %08x\n",curenv-envs);
				env_run(curenv);
			}
	}
	// sched_halt never returns
	cprintf("sched_halt\n");
	sched_halt();
}

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void) {
	int i;

	for(i = 0; i < NENV; ++i) {
		if (envs[i].env_status == ENV_NOT_RUNNABLE) {
			envs[i].env_status = ENV_RUNNABLE;
			sched_yield();
		}
	}

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
		while (1)
			monitor(NULL);
	}

	// Mark that no environment is running on CPU
	curenv = NULL;

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
		"movl $0, %%ebp\n"
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (cpu_ts.ts_esp0));
}

