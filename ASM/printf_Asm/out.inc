;-------------------------------------------------------------------------------
;			Output Binary number
;
;-------------------------------------------------------------------------------
proc outputBin, number
		pusha
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
		popa
		ret
endp
;-------------------------------------------------------------------------------
;			Output Octal number
;
;-------------------------------------------------------------------------------
proc outputOct, number
		pusha
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
		popa
		ret
endp
;-------------------------------------------------------------------------------
;			Output Decimal number
;
;-------------------------------------------------------------------------------
	       
proc outputDec, number
		pusha
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
		popa
		ret		
endp
;-------------------------------------------------------------------------------
;			Output Hexadenimal number
;
;-------------------------------------------------------------------------------
proc outputHex, number
		pusha
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
		popa
		ret		
endp
;-------------------------------------------------------------------------------
;			Output Char 
;
;-------------------------------------------------------------------------------
proc outputChar, char
		pusha
		mov eax, [char]
		mov [outBuff], al
		invoke WriteConsoleA, [hStdOut], outBuff, 1, chrsWritten, 0
		popa
		ret		
endp
;-------------------------------------------------------------------------------
;			Output String 
;
;-------------------------------------------------------------------------------
proc outputString, string
		pusha
		mov esi, [string]
		xor ebx, ebx
		xor eax, eax
OutChar:
		lodsb
		cmp al, 0
		je ExitOutStr

		push eax
		call outputChar
		jmp OutChar
ExitOutStr:
		popa
		ret		
endp
