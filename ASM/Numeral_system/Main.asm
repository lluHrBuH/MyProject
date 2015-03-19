format PE Console 4.0
entry Start

include 'win32ax.inc'

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
;-------------------------------------------------------------------------------
;			Input Binary number
;
;-------------------------------------------------------------------------------
proc inputBin 
		invoke ReadConsoleA, [hStdIn], readBuf, 34, chrsRead, 0 						
		xor ecx, ecx
		xor eax, eax
		xor edx, edx
		mov cl, byte [chrsRead]
		sub cl, 2							;Remove CR and LF symb
	SetBit_AL:		

		mov ebx, readBuf - 1
		add ebx, ecx
		cmp [ebx],byte '1'
		je SetBit_1
		jmp SetBit_0
	SetBit_1:	    
		mov edx, ecx
		neg edx
		add dl, byte [chrsRead]
		sub edx, 2							;Remove CR and LF symb
		bts eax, edx

	SetBit_0: 
		loop SetBit_AL
		ret
endp
;-------------------------------------------------------------------------------
;			Output Binary number
;
;-------------------------------------------------------------------------------
proc outputBin, number
		mov eax, [number]
		xor ecx, ecx
		mov cl, 32
ConvertBinToASCII:
		dec ecx
		bt eax, ecx
		inc ecx
		jc WriteBit_1 
WriteBit_0:
		neg ecx
		mov [outBuff + ecx + 32], '0'
		neg ecx
		jmp EndBin_loop

WriteBit_1:
		neg ecx
		mov [outBuff + ecx + 32 ], '1'
		neg ecx
EndBin_loop:
		loop ConvertBinToASCII
		invoke WriteConsoleA, [hStdOut], outBuff, 32, chrsWritten, 0
		ret
endp
;-------------------------------------------------------------------------------
;			Input Octal number
;
;-------------------------------------------------------------------------------
	       
proc inputOct								      
		invoke ReadConsoleA, [hStdIn], readBuf, 13, chrsRead, 0
		sub [chrsRead], 2
		xor eax, eax
		xor ecx, ecx
		mov ecx, [chrsRead]
ConvertASCIItoOct:   
		cmp [readBuf + ecx - 1], '9'
		ja ERROR_INP  
		cmp [readBuf + ecx - 1], '0'					;Check number '0-9'
		jb ERROR_INP

		sub [readBuf + ecx - 1], '0'					;Convert '0-9' to 0x0 - 0x9

		xor ebx, ebx
		mov bl, [readBuf + ecx - 1]

		xor edx, edx
		mov dl, byte [chrsRead] 
		sub edx, ecx
		imul edx, edx, 3

		xchg edx, ecx
		shl ebx, cl
		xchg edx, ecx
		
		add eax, ebx
		loop ConvertASCIItoOct
		ret
endp
;-------------------------------------------------------------------------------
;			Output Octal number
;
;-------------------------------------------------------------------------------
proc outputOct, number
		mov eax, [number]
		mov ecx, 11
ConvertOCTtoASCII:
		xor edx, edx
		shld edx, eax, 3
		rol eax, 3		
		neg ecx
		mov [outBuff + ecx + 8], dl
		add [outBuff + ecx + 8], '0'
		neg ecx

		loop ConvertOCTtoASCII

		invoke WriteConsoleA, [hStdOut], outBuff, 11, chrsWritten, 0
		ret
endp
;-------------------------------------------------------------------------------
;			Input Decimal number
;
;-------------------------------------------------------------------------------
	       
proc inputDec
		invoke ReadConsoleA, [hStdIn], readBuf, 13, chrsRead, 0
		sub [chrsRead], 2
		mov eax, 1
		xor ebx, ebx
		xor ecx, ecx
		mov ecx, [chrsRead]
		xor edx, edx
ConvertASCIItoDec:
		cmp [readBuf + ecx - 1], '9'
		ja ERROR_INP
		cmp [readBuf + ecx - 1], '0'					;Check if Input number is '0-9'
		jb ERROR_INP
		sub [readBuf + ecx - 1], '0'					;Convert '0-9' to 0x0 - 0x9
 		mov edi, eax
		mov bl, [readBuf + ecx - 1]
		mov esi, edx 
 		mul ebx
 		mov edx, esi
 		add edx, eax 
 		mov eax, edi 
 		imul eax, 10
		loop ConvertASCIItoDec	
		xchg eax, edx					
		ret		
endp
;-------------------------------------------------------------------------------
;			Output Decimal number
;
;-------------------------------------------------------------------------------
	       
proc outputDec, number
		mov eax, [number]
		mov ecx, 11
		mov ebx, 10
ConvertDECtoASCII:
		xor edx, edx
		div ebx
		mov [outBuff + ecx - 1], dl
		add [outBuff + ecx - 1], '0'
		loop ConvertDECtoASCII
		invoke WriteConsoleA, [hStdOut], outBuff, 11, chrsWritten, 0
		ret		
endp
;-------------------------------------------------------------------------------
;			Input Hexadenimal number
;
;-------------------------------------------------------------------------------
proc inputHex								      
		invoke ReadConsoleA, [hStdIn], readBuf, 10, chrsRead, 0 
		sub [chrsRead], 2
		xor eax, eax
		xor ecx, ecx
		mov ecx, [chrsRead]
ConvertASCIItoHEX:   
		cmp [readBuf + ecx - 1], '9'
		jbe IsNumber		    
IsHex:		
		cmp [readBuf + ecx - 1], 'A'					;Check number 'A-F'
		jb ERROR_INP
		cmp [readBuf + ecx - 1], 'F'
		ja IsLowHex

		sub [readBuf + ecx - 1], 55					;Convert 'A-F' to 0xA - 0xF
		jmp IdentNumb

IsLowHex:
		cmp [readBuf + ecx - 1], 'a'					;Check number 'a-f'
		jb ERROR_INP
		cmp [readBuf + ecx - 1], 'f'
		ja ERROR_INP 

		sub [readBuf + ecx - 1], 87					;Convert 'a-f' to 0xA - 0xF
		jmp IdentNumb
		    
IsNumber:  
		cmp [readBuf + ecx - 1], '0'					;Check number '0-9'
		jb ERROR_INP

		sub [readBuf + ecx - 1], '0'					;Convert '0-9' to 0x0 - 0x9
		jmp IdentNumb
IdentNumb:	
		xor ebx, ebx
		mov bl, [readBuf + ecx - 1]
		xor edx, edx
		mov dl, byte [chrsRead] 
		sub edx, ecx
		imul edx, edx, 4
		xchg edx, ecx
		shl ebx, cl
		xchg edx, ecx
		add eax, ebx
		loop ConvertASCIItoHEX
		ret		
endp

;-------------------------------------------------------------------------------
;			Output Hexadenimal number
;
;-------------------------------------------------------------------------------
proc outputHex, number
		mov eax, [number]
		mov ecx, 8
ConvertHEXtoASCII:
		xor edx, edx
		shld edx, eax, 4
		rol eax, 4		
		neg ecx
		mov [outBuff + ecx + 8], dl
		cmp [outBuff + ecx + 8], 9
		ja hexToASCII
numberToASCII:
		add [outBuff + ecx + 8], '0'
		jmp outputHexLoop
hexToASCII:	
		add [outBuff + ecx + 8], 55

outputHexLoop:
		neg ecx
		loop ConvertHEXtoASCII
		invoke WriteConsoleA, [hStdOut], outBuff, 8, chrsWritten, 0
		ret		
endp
;-------------------------------------------------------------------------------
;	Case Input number type
;
;-------------------------------------------------------------------------------
proc inputType
		invoke WriteConsoleA, [hStdOut], 'Print input number type: ', 25, chrsWritten, 0
		invoke ReadConsoleA, [hStdIn], readBuf, 30, chrsRead, 0
		mov bl, [readBuf]
		cmp bl, 'B'
		je CallInpBin
		cmp bl, 'b'
		je CallInpBin
		cmp bl, 'O'
		je CallInpOct
		cmp bl, 'o'
		je CallInpOct
		cmp bl, 'D'
		je CallInpDec
		cmp bl, 'd'
		je CallInpDec
		cmp bl, 'H'
		je CallInpHex
		cmp bl, 'h'
		je CallInpHex
		jmp ERROR_INP
CallInpBin:
		invoke WriteConsoleA, [hStdOut], 'Input number: ', 14, chrsWritten, 0
		call inputBin
		jmp ExitInp
CallInpOct:
		invoke WriteConsoleA, [hStdOut], 'Input number: ', 14, chrsWritten, 0
		call inputOct
		jmp ExitInp
CallInpDec:	
		invoke WriteConsoleA, [hStdOut], 'Input number: ', 14, chrsWritten, 0
		call inputDec
		jmp ExitInp
CallInpHex:
		invoke WriteConsoleA, [hStdOut], 'Input number: ', 14, chrsWritten, 0
		call inputHex
		jmp ExitInp
ExitInp:
		ret
endp
;-------------------------------------------------------------------------------
;	Case Input number type
;
;-------------------------------------------------------------------------------
proc outputType, number
		invoke WriteConsoleA, [hStdOut], 'Print output number type: ', 26, chrsWritten, 0
		invoke ReadConsoleA, [hStdIn], readBuf, 3, chrsRead, 0
		mov bl, [readBuf]
		push [number]
		cmp bl, 'B'
		je CallOutpBin
		cmp bl, 'b'
		je CallOutpBin
		cmp bl, 'O'
		je CallOutpOct
		cmp bl, 'o'
		je CallOutpOct
		cmp bl, 'D'
		je CallOutpDec
		cmp bl, 'd'
		je CallOutpDec
		cmp bl, 'H'
		je CallOutpHex
		cmp bl, 'h'
		je CallOutpHex
		jmp ERROR_INP
CallOutpBin:
		invoke WriteConsoleA, [hStdOut], 'Output number: ', 15, chrsWritten, 0
		call outputBin
		jmp ExitOut
CallOutpOct:
		invoke WriteConsoleA, [hStdOut], 'Output number: ', 15, chrsWritten, 0
		call outputOct
		jmp ExitOut
CallOutpDec:
		invoke WriteConsoleA, [hStdOut], 'Output number: ', 15, chrsWritten, 0
		call outputDec
		jmp ExitOut
CallOutpHex:
		invoke WriteConsoleA, [hStdOut], 'Output number: ', 15, chrsWritten, 0
		call outputOct
		jmp ExitOut
ExitOut:
		ret
endp
;-------------------------------------------------------------------------------
;	Write 'ERROR INPUT NUMB' and reStart
;
;-------------------------------------------------------------------------------
ERROR_INP:
		pop eax 							;Remove return address from stack
		invoke WriteConsoleA, [hStdOut], errMsg, errLen, chrsWritten, 0
		jmp Start
;-------------------------------------------------------------------------------
;	Main code
;
;-------------------------------------------------------------------------------

Start:
		call initConsole
		call inputType
		push eax
		call outputType
		invoke ReadConsoleA, [hStdIn], readBuf, 16, chrsRead, 0
Exit:
		invoke	ExitProcess, 0
	

section '.data' data readable writeable
errMsg		 db 'ERROR INPUT NUMBER',10
errLen		= $ - errMsg

hStdIn		dd 0
hStdOut 	dd 0
chrsRead	dd 0
chrsWritten	dd 0

STD_INP_HNDL	dd -10
STD_OUTP_HNDL	dd -11

outBuff 	db 33 dup(0)
readBuf 	db ?
buff		db ?

section '.idata' import data readable

  library kernel, 'KERNEL32.DLL'

  import kernel,\
    GetStdHandle, 'GetStdHandle',\
    WriteConsoleA, 'WriteConsoleA',\
    ReadConsoleA, 'ReadConsoleA',\
    ExitProcess, 'ExitProcess'