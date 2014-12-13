// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 9: Your code here.
	pte_t p = uvpt[PGNUM(addr)];
	if (!(err & FEC_WR) || !(p & PTE_COW)) {
		panic("pgfault: Invalid address");
		return;
	}
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.

	if (sys_page_alloc(0, PFTEMP, PTE_W | PTE_U | PTE_P)){
		panic("pgfault: Impossible to alloc page");
	}
	void *addr2 = (void *)ROUNDDOWN(addr,PGSIZE);
	memmove(PFTEMP, addr2, PGSIZE);
	if (sys_page_map(0, PFTEMP, 0, addr2, PTE_W | PTE_P | PTE_U))
		panic("pgfault: Impossible to map new page");
	
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 9: Your code here.
	pte_t p = uvpt[pn];
	void *va = (void *)(pn<<PGSHIFT);
	if ((p & PTE_COW) || (p & PTE_W)){
		if (sys_page_map(0, va, envid, va, PTE_COW | PTE_P | PTE_U)){
			panic("duppage: Impossible to map page");
			return -E_INVAL;
		}
		if (sys_page_map(0, va, 0, va, PTE_COW | PTE_P | PTE_U)) {
			panic("duppage: Impossible to map page(change perm)");
			return -E_INVAL;
		}
	}
	else if (sys_page_map(0, va, envid, va, PTE_P | PTE_U)){
		panic("duppage: Impossible to map page");
		return -E_INVAL;
	}
	return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 9: Your code here.
	set_pgfault_handler(pgfault);
	envid_t child = sys_exofork();
	if (child < 0) {
		panic("fork: Impossible to create a child");
		return -E_INVAL;
	}
	else if (child == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	int i,j;
	for (i = 0; i != PDX(UTOP); i++){
		if (!(uvpd[i] & PTE_P)) continue;
		for (j = 0; j < NPTENTRIES; j++){
			unsigned int pgn = (i << 10) | j;
			if (pgn == PGNUM(UXSTACKTOP - PGSIZE)) {
				if (sys_page_alloc(child, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)){
					panic("fork: Impossible to allocate page");
					return -E_INVAL;
				}
				continue;
			}
			if (uvpt[pgn] & PTE_P)
				duppage(child, pgn);
		}	
	}
	if (sys_env_set_pgfault_upcall(child, thisenv->env_pgfault_upcall)) {
		panic("fork: Impossible to set pgfault upcall");
		return -E_INVAL;
	}
	if (sys_env_set_status(child, ENV_RUNNABLE)){
		panic("fork: Impossible to set status ENV_RUNNABLE");
		return -E_INVAL;
	}
	return child;
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
