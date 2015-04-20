format PE console 4.0
entry Start 

include 'win32ax.inc'

section '.text' code readable executable
proc initConsole
		invoke GetStdHandle, [STD_OUTP_HNDL]	
		mov [hStdOut], eax
		invoke GetStdHandle, [STD_INP_HNDL]
		mov [hStdIn], eax
		invoke WriteConsoleA, [hStdOut], helloMsg, 16, chrsWritten, 0
		ret
endp
proc hackerFriendlyFunc
		call ebx
		ret
endp
proc inputPassword
		push ebx
		enter 4, 0
		mov ebx, ebp
		sub ebx, 8
		invoke ReadConsoleA, [hStdIn], ebx, 100, chrsRead, 0		;Buffer Overflow is possible 
		mov ecx, [chrsRead]
		sub ecx, 2 							;Remove CR and LF
		mov esi, ebx
		mov edi, inputBuff
CopyPassToBuff:	
		movsb
		loop CopyPassToBuff 

		leave
		pop ebx
		ret
endp
proc checkPassword
		mov eax, 1
		mov ecx, pwdLen
		mov edi, inputBuff
		mov esi, password
CheckPwd:
		cmpsb 
		jne IncorrectPwd
		loop CheckPwd
		ret
IncorrectPwd:	mov eax, 0
		ret
endp
correctPswd:
		invoke WriteConsoleA, [hStdOut], corrPswdStr, 19, chrsWritten, 0
		invoke ReadConsoleA, [hStdIn], 0, 0, chrsRead, 0		
		jmp Exit

proc incorrectPswd
		invoke WriteConsoleA, [hStdOut], incorrPswdStr, 17, chrsWritten, 0
		ret
endp

jmp hackerFriendlyFunc								;DIRTY HACK FOR  HACKER
Start:
		call initConsole
		call inputPassword
		call checkPassword
		cmp eax, 1
		je Correct
		jmp InCorrect
Correct:
		jmp correctPswd
InCorrect:
		call incorrectPswd
		jmp Start
Exit:	
		invoke ExitProcess, 0

section '.data' data readable writeable

password 	db "Password"
pwdLen		= $ - password
inputBuff	db 100 dup(0)

helloMsg	db "Input Password: "
corrPswdStr	db "Correct password!",0dh,0ah
incorrPswdStr 	db "Incorrect Pass!",0dh,0ah

hStdIn		dd 0
hStdOut 	dd 0
chrsRead	dd 0
chrsWritten	dd 0

STD_INP_HNDL	dd -10
STD_OUTP_HNDL	dd -11

section '.idata' import data readable

  library kernel, 'KERNEL32.DLL'

  import kernel,\
    GetStdHandle, 'GetStdHandle',\
    WriteConsoleA, 'WriteConsoleA',\
    ReadConsoleA, 'ReadConsoleA',\
    ExitProcess, 'ExitProcess'	