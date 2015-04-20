#include <stdio.h>
const char *InputFile = "password.exe";

int main()
{
	FILE *fileToCrack;
	fileToCrack = fopen("password.exe", "rb+");
	fseek(fileToCrack, 611, SEEK_SET);
	fputc(1, fileToCrack);
	fclose(fileToCrack);
}