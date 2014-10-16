#include <inc/lib.h>

int (* volatile cprintf) (const char *fmt, ...);
void (* volatile sys_yield)(void);

void
umain( int argc, char **argv )
{
	int i=1;
	int j;

	cprintf( "TEST3\n" );
	for(;;i++){
		//if (i%1000 == 0) sys_yield();
	}
}

