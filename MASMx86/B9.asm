.386
.model flat, stdcall
option casemap: none

include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\kernel32.lib

.data?
	arr	db	200	dup(?)
	num_1 db  200 dup(?)
	Min_ db 200 dup(?)
	Max_ db 200 dup(?)
.data
	min		dd	0ffffffffh
	max		dd	0h
	endl	db	0ah
	count	dd	0
	temp	dd	0
.code

main proc
	push 30
	push offset arr
	call StdIn

	push offset arr
	call Atoi
	mov count , eax

	Start_cmp:
		cmp count,0
		jz  End_cmp
		dec count

		push 30
		push offset arr
		call StdIn

		push min
		push offset Min_
		call Itoa

		push  max
		push offset Max_
		call Itoa

		xor eax,eax
		xor ebx,ebx
		
	cmp_min:
		push offset arr
		push offset Min_
		call Compare_high
		
		cmp ebx,2
		je  Low_than
	cmp_max:
		xor ebx,ebx
		push offset arr
		push offset Max_
		call Compare_high

		cmp ebx,1
		je  Great_than
		jmp Start_cmp

	Low_than:
		push offset arr
		call Atoi
		mov min,eax
		jmp cmp_max
	Great_than:
		push offset arr
		call Atoi
		mov max,eax
		jmp Start_cmp

	End_cmp:
		push max
		push offset arr
		call Itoa

		push offset arr
		call StdOut

		push offset endl
		call StdOut

		push min
		push offset arr
		call Itoa

		push offset arr
		call StdOut

		push 0
		call ExitProcess
	 

main endp

Atoi proc    ; return value of eax
	push ebp
	mov ebp,esp
	push ebx
	push ecx
	mov ecx,[ebp+8]  ;num
	xor edi,edi
	xor eax,eax
	mov ebx,10
	Start_atoi:
		xor edx,edx
		mov dl, BYTE PTR [ecx+edi]
		sub dl,30h
		add eax,edx
		mul ebx
		inc edi
		cmp BYTE PTR [ecx+edi],0
		je  End_atoi
		jmp Start_atoi
	End_atoi:
		div ebx
		pop ecx
		pop ebx
		mov esp,ebp
		pop ebp
		ret 4
Atoi endp

Itoa proc
	push ebp
	mov ebp,esp
	push eax
	push ebx
	push ecx
	mov eax,[ebp+12]     ;Number
	mov ebx,[ebp+8]      ;ascii
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
		mov esp,ebp
		pop ebp
		ret 8

Itoa endp

Compare_high proc
	push ebp
	mov ebp,esp
	push eax
	push ecx
	mov eax,[ebp+12]        ;First : low
	mov ecx,[ebp+8]         ;Second: High
	xor edi,edi
	xor ebx,ebx

	Start_compare:
		cmp BYTE PTR [eax+edi],0
		jz  Check_se
		cmp BYTE PTR [ecx+edi],0
		jz  Temp_1
		inc edi
		jmp Start_compare

	Check_se:
		cmp BYTE PTR [ecx+edi],0
		jz Next_cmp
		jmp Temp_2
	
	Next_cmp:
		xor edi,edi
	Equal_cmp:
		xor edx,edx
		mov dl,BYTE PTR [eax+edi]
		mov dh,BYTE PTR [ecx+edi]
		inc edi
		cmp dl,dh
		jl  Temp_2
		cmp dl,dh
		jg  Temp_1
		cmp BYTE PTR [eax+edi],0
		jz  Temp_0
		jmp Equal_cmp
		

	Temp_1: ; first > sec
		mov ebx,1
		jmp End_compare
	Temp_2: ; fi < se
		mov ebx,2
		jmp End_compare
	Temp_0:
		mov ebx,3
	End_compare:
		pop ecx
		pop eax
		mov esp,ebp
		pop ebp
		ret 8
		
Compare_high endp

end main