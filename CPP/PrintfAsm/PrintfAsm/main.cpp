#include <stdio.h>
#include <consoleapi.h>
unsigned int __cdecl printfAsm(const char *format, ...);

int main()
{
	printfAsm("Dec:<%d> Oct:<%o> Bin:<%b> Hex:<%x> and %s %c %x %d times %c", 3802, 03702, 13, 0xeda, "I", 3, 0xeda, 100, '!');
	
	return 0;
}

