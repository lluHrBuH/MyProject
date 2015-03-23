;-------------------------------------------------------------------------------
;			Output Binary number
;
;-------------------------------------------------------------------------------

proc outputBin, number
		pusha
		mov eax, [number]
		xor ecx, ecx
		mov cl, 32
		xor esi, esi
ConvertBinToASCII:
		shr eax, 1
		jc WriteBit_1 
WriteBit_0:
		inc esi
		mov [outBuff + ecx - 1], '0'
		jmp EndBin_loop

WriteBit_1:
		xor esi, esi
		mov [outBuff + ecx - 1], '1'
EndBin_loop:
		loop ConvertBinToASCII
		mov edi, 32
		sub edi, esi
		add esi, outBuff
		mov ebx, [WriteConsoleA]
		stdcall ebx, [hStdOut], esi, edi, chrsWritten, 0
		popa
		ret
endp
;-------------------------------------------------------------------------------
;			Output Octal number
;
;-------------------------------------------------------------------------------
proc outputOct, number
		pusha
		xor esi, esi
		mov eax, [number]
		mov ecx, 11
ConvertOCTtoASCII:
		xor edx, edx
		shrd edx, eax, 3
		shr eax, 3
		shr edx, 29		
		mov [outBuff + ecx - 1], dl
		add [outBuff + ecx - 1], '0'
		cmp dl, 0
		jne IsNotZeroOct
IsZeroOct:
		inc esi
		jmp ContConvertOct
IsNotZeroOct:
		xor esi, esi
ContConvertOct:
		loop ConvertOCTtoASCII

		mov ebx, [WriteConsoleA]
		mov edi, 11
		sub edi, esi
		add esi, outBuff
		stdcall ebx, [hStdOut], esi, edi, chrsWritten, 0
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
		xor esi, esi
		mov ebx, 10
ConvertDECtoASCII:
		xor edx, edx
		div ebx
		mov [outBuff + ecx - 1], dl
		cmp eax, 0
		jne IsNotZeroDec
IsZeroDec:
		inc esi
		jmp ContConvertDec
IsNotZeroDec:
		xor esi, esi
ContConvertDec:
		add [outBuff + ecx - 1], '0'
		loop ConvertDECtoASCII
		mov ebx, [WriteConsoleA]
		dec esi
		mov edi, 11
		sub edi, esi
		add esi, outBuff
		stdcall ebx, [hStdOut], esi, edi, chrsWritten, 0
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
		mov ebx, [WriteConsoleA]
		stdcall ebx, [hStdOut], outBuff, 8, chrsWritten, 0
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
		mov ebx, [WriteConsoleA]
		stdcall ebx, [hStdOut], outBuff, 1, chrsWritten, 0
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
