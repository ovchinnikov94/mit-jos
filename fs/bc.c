
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
		panic("bad block number %08x in diskaddr", blockno);
	return (char*) (DISKMAP + blockno * BLKSIZE);
}

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
}

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
}

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
		panic("reading non-existent block %08x\n", blockno);

	// Allocate a page in the disk map region, read the contents
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 10: you code here:
	void *addr_rounded = ROUNDDOWN(addr, BLKSIZE);
	if (sys_page_alloc(0, addr_rounded, PTE_U | PTE_P | PTE_W))
		panic("bc_pgfault: Error in page allocating");
	uint32_t sn = blockno * BLKSECTS;
	
	if (ide_read(sn, addr_rounded, BLKSECTS))
		panic("bc_pgfault: Can't do ide_read");
	
	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr_rounded, 0, addr_rounded, uvpt[PGNUM(addr_rounded)] & PTE_SYSCALL)) < 0)
		panic("in bc_pgfault, sys_page_map: %e", r);
	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
		panic("reading free block %08x\n", blockno);
}

// Flush the contents of the block containing VA out to disk if
// necessary, then clear the PTE_D bit using sys_page_map.
// If the block is not in the block cache or is not dirty, does
// nothing.
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("flush_block of bad va %08x", addr);
	/*
	// LAB 10: Your code here.
	void *addr2 = ROUNDDOWN(addr, BLKSIZE);
	pte_t pte = uvpt[PGNUM(addr2)];
	if (va_is_mapped(addr2) && va_is_dirty(addr2)) {
		uint32_t sn = BLKSECTS * blockno;
		cprintf("%d\n", blockno);
		if (ide_write(sn, addr2, BLKSECTS))
			panic("flush_block: Error in ide_write");
		if (sys_page_map(0, addr2, 0, addr2, pte & PTE_SYSCALL))
			panic("flush_block: Error in sys_page_map");
	}*/
	void *pgva = ROUNDDOWN(addr, BLKSIZE);
	pte_t pte = uvpt[PGNUM(pgva)];
	if (!va_is_mapped(pgva) || !va_is_dirty(pgva))
		return;
	uint32_t secno = blockno * BLKSECTS;
	if (ide_write(secno, pgva, BLKSECTS))
		panic("flush_block: ide write error");
	if (sys_page_map(0, pgva, 0, pgva, pte & PTE_SYSCALL))
		panic("flush_block: map error");
}

// Test that the block cache works, by smashing the superblock and
// reading it back.
static void
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
	flush_block(diskaddr(1));
	assert(va_is_mapped(diskaddr(1)));
	assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
	assert(!va_is_mapped(diskaddr(1)));

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
	flush_block(diskaddr(1));

	cprintf("block cache is good\n");
}

void
bc_init(void)
{
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
}

