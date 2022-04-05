.386
.model flat, stdcall
option casemap: none

include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\kernel32.lib

.data?
	x	db	20	dup(?)
	y	db	20	dup(?)
	res	db	20	dup(?)
	opt db  ?
.data

Operator db "Select operator:", 0Ah, "1. Addition", 0Ah, "2. Subtraction", 0Ah, "3. Multiply", 0Ah, "4. Division", 0Ah,0
Option_  db "Your option: ",0
msg1 db "Number 1: ",0
msg2 db "Number 2: ",0
msg3 db "Result: ",0
endl dd 0ah


.code

main proc
	push offset Operator
	call StdOut

	push offset Option_
	call StdOut

	push 5
	push offset opt
	call StdIn

	push offset msg1
	call StdOut

	push 20
	push offset y
	call StdIn

	push offset endl
	call StdOut

	push offset msg2
	call StdOut

	push 20
	push offset x
	call StdIn

	push offset endl
	call StdOut

	push offset x
	call Atoi
	mov ebx,eax

	push offset y
	call Atoi

	sub opt,30h
	cmp opt,1
	je  Add_num

	cmp opt,2
	je  Sub_num

	cmp opt,3
	je  Mul_num

	cmp opt,4
	je  Div_num

	Add_num:
		add eax,ebx
		jmp Finished
	
	Sub_num:
		sub eax,ebx
		jmp Finished
	Mul_num:
		mul ebx
		jmp Finished
	Div_num:
		div ebx
		jmp Finished
	Finished:
		push eax
		push offset res
		call Itoa

		push offset msg3
		call StdOut
		
		push offset res
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