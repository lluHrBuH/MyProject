format PE Console 4.0
entry Start

include 'win32ax.inc'
include 'out.inc'

section '.text' code readable executable 
;-------------------------------------------------------------------------------
;			Get INPUT and OUTPUT STD HANDLE
;
;-------------------------------------------------------------------------------
proc initConsole
		invoke GetStdHandle, [STD_OUTP_HNDL]
		mov [hStdOut], eax
		invoke GetStdHandle, [STD_INP_HNDL]
		mov [hStdIn], eax
		ret
endp	

proc printfAsm
		push ebp
		mov ebp, esp
label .formatStr dword at ebp+8
	
		xor eax, eax
		mov esi, [.formatStr]
		mov edi, ebp
		add edi, 12							;%d %f %c %s
										;ECX for count %, edi - arg, al - symb
ParseFormatString:
		xor ecx, ecx 
		lodsb
		cmp al, '%'
		je Symb_%
		jmp OtherSymb
Symb_%:
		lodsb
		cmp al, '%'
		je Print_%
		cmp al, 'd'
		je Print_d
		cmp al, 'c'
		je Print_c
		cmp al, 's'
		je Print_s
		cmp al, 'b'
		je Print_b
		cmp al, 'x'
		je Print_x
		cmp al, 'p'
		je Print_p
		cmp al, 'o'
		je Print_o
		jmp OtherSymb	
Print_d:
		mov edx, [edi]
		add edi, 4
		push edx
		call outputDec
		jmp ParseFormatString
Print_c:
		mov edx, [edi]
		add edi, 4
		mov cl, [edx]
		push ecx
		call outputChar
		jmp ParseFormatString
Print_s:
		mov edx, [edi]
		add edi, 4
		push edx
		call outputString
		jmp ParseFormatString
Print_b:
		mov edx, [edi]
		add edi, 4
		push edx
		call outputBin
		jmp ParseFormatString
Print_o:
		mov edx, [edi]
		add edi, 4
		push edx
		call outputOct
		jmp ParseFormatString
Print_x:
		mov edx, [edi]
		add edi, 4
		push edx
		call outputHex
		jmp ParseFormatString
Print_p:
		mov edx, edi
		add edi, 4
		push edx
		call outputHex
		jmp ParseFormatString
Print_%:
		push '%'
		call outputChar
		jmp ParseFormatString
OtherSymb: 
		cmp al, 0
		je EndPrintfAsm
		push eax
		call outputChar
		jmp ParseFormatString
EndPrintfAsm:

		mov esp, ebp
		pop ebp
		ret
endp			    
;-------------------------------------------------------------------------------
;			Main code
;
;-------------------------------------------------------------------------------
Start:
		call initConsole
		ccall printfAsm,formatStr ,3, 123, 123
		invoke ReadConsoleA, [hStdIn], readBuf, 16, chrsRead, 0

		invoke	ExitProcess, 0

section '.data' data readable writeable 
strToOut 	db 'String ^1',0
formatStr 	db 'Number:<%c> Hex:<%x> Oct:<%o>',0
hStdIn		dd 0
hStdOut 	dd 0
chrsRead	dd 0
chrsWritten	dd 0

outBuff 	db 33 dup(0)
readBuf 	db 33 dup(0)

STD_INP_HNDL	dd -10
STD_OUTP_HNDL	dd -11

section '.idata' import data readable
 
 library kernel, 'KERNEL32.dll',\
 	 msvcrt, 'msvcrt.dll'

 import kernel,\
   GetStdHandle, 'GetStdHandle',\
   WriteConsoleA, 'WriteConsoleA',\
   ReadConsoleA, 'ReadConsoleA',\
   ExitProcess, 'ExitProcess'