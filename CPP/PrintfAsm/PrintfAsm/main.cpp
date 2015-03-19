#include <stdio.h>
#include <consoleapi.h>
unsigned int __cdecl printfAsm(const char *format, ...);

int main()
{
	int a = 123;
	printfAsm("Address: %x %% Hex:<%b>", a, a);
	return 0;
}