.386
.model flat, stdcall
option casemap: none

include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\kernel32.lib

.data?
arr db 30 dup(?)
odd_num db 30 dup(?)
even_num db 30 dup(?)

.data
odd_sum dd 0
even_sum dd 0
endl dd 0ah
count dd 0
.code

main proc
	push 30
	push offset arr
	call StdIn

	push offset arr
	call Atoi
	mov count , eax
	mov esi,2
	xor eax,eax
	Find_type:
		cmp count,0
		je  Print_sum
		push 30
		push offset arr
		call StdIn
		xor ebx,ebx
		push offset arr
		call Atoi
		mov ebx,eax
		dec count
		div esi
		cmp dl,1
		je  Odd_sum
		jmp Even_sum

	Odd_sum:
		add odd_sum,ebx
		jmp Find_type
	Even_sum:
		add even_sum,ebx
		jmp Find_type

	Print_sum:
		push even_sum
		push offset even_num
		call Itoa

		push offset even_num
		call StdOut

		push offset endl
		call StdOut

		push odd_sum
		push offset odd_num
		call Itoa

		push offset odd_num
		call StdOut

		push 0
		call ExitProcess
	
main endp

Atoi proc
	push ebp
	mov ebp,esp
	push ebx
	push ecx
	mov ebx,[ebp+8]
	xor eax,eax
	xor edi,edi
	mov ecx,10

	Start_mul:
		xor edx,edx
		mov dl,BYTE PTR [edi+ebx]
		sub dl,30h
		add eax,edx
		mul ecx
		inc edi
		cmp BYTE PTR [edi+ebx],0
		jz  Finished
		jmp Start_mul

	Finished:
		div ecx
		pop ecx
		pop ebx
		pop ebp
		ret 4
Atoi endp

Itoa proc
	push ebp
	mov ebp,esp
	push eax
	push ebx
	push ecx
	mov eax,[ebp+12]     ;number
	mov ebx,[ebp+8]      ;arr
	mov edi,10
	xor ecx,ecx
	Start_div:
		xor edx,edx
		div edi
		add dl,30h
		push edx
		inc ecx
		cmp eax,0
		je  Temp
		jmp Start_div
	
	Temp:
		xor edi,edi
	Pop_arr:
		pop edx
		mov BYTE PTR [ebx+edi],dl
		dec ecx
		inc edi
		cmp ecx,0
		je  Finished
		jmp Pop_arr

	Finished:
		mov BYTE PTR [ebx+edi],0
		pop ecx
		pop ebx
		pop eax
		pop ebp
		ret 8

Itoa endp

end main
