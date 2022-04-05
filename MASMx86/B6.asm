.386
.model flat, stdcall
option casemap:none

include \masm32\include\kernel32.inc 
include \masm32\include\masm32.inc 
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data?

str1 db 256 dup(?)
str2 db 256 dup(?)

.code

main proc
	push 256
	push offset str1
	call StdIn

	push offset str1
	call Reverse

	push offset str1
	call StdOut
	
	push 0
	call ExitProcess

main endp

Reverse proc
	push ebp
	mov ebp,esp
	push eax
	push ecx
	mov eax, [ebp+8]
	xor edi,edi
	xor ecx,ecx

	Start_reverse:
		xor edx,edx
		mov dl,BYTE PTR [edi+eax]
		cmp dl,0
		je  Temp
		push edx
		inc edi
		inc ecx
		jmp Start_reverse

	Temp:
		xor edi,edi
	Pop_reverse:
		cmp ecx,0
		je  End_reverse
		pop edx
		mov BYTE PTR [edi+eax],dl
		inc edi
		dec ecx
		jmp Pop_reverse
		
	End_reverse:
		mov Byte ptr [edi+eax],0
		pop ecx
		pop eax
		mov esp,ebp
		pop ebp
		ret 4
Reverse endp
end main