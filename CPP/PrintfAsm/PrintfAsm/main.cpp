#include <stdio.h>
#include <consoleapi.h>
unsigned int __cdecl printfAsm(const char *format, ...);

int main()
{
	int a = 12123;
	printfAsm("Dec:<%d> Oct:<%o> Bin:<%b Hex:<%x>", a, a, a, a);

	return 0;
}