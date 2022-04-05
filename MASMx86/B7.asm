.386
.386
.model flat, stdcall
option casemap: none

include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\kernel32.lib

.data?
num db 5 dup(?)
f0 db 1000 dup(?)
f1 db 1000 dup(?)
f2 db 1000 dup(?)

res db 100 dup(?)

.data
F1 db '1',0
F0 db '0',0
count dd 0
count_num dd 0
mem dd 0
endl db 0ah
	

.code

main proc
	push 5
	push offset num
	call StdIn

	push offset num
	call Atoi

	push offset F0
	push offset F1
	push offset f0
	push offset f1
	call Begin

	cmp count_num,0
	je  Zero
	xor esi,esi
	Start_print:
		; Print fibonacci n
		cmp esi,0
		je  First
		cmp esi,count_num
		je  End_print
		push offset f0
		push offset f1
		push offset f2
		call Fibonacci

		push offset f2
		call Print_number

		push offset f1
		call Reverse

		push offset f1
		push offset f0
		call Copyfibo

		push offset f2
		push offset f1
		call Copyfibo

		inc esi
		jmp Start_print

	Zero:
		push offset f0
		call Print_number
		jmp  End_print

	First:
		inc esi
		push offset f1
		call Print_number
		jmp Start_print

	End_print:
		push 0
		call ExitProcess

main endp

Print_number proc
	push ebp
	mov ebp,esp
	push [ebp+8]
	call StdOut

	push offset endl
	call StdOut

	mov esp,ebp
	pop ebp
	ret 4
Print_number endp

Begin proc
	push ebp
	mov ebp,esp
	push [ebp + 20] ;F0
	push [ebp + 20] ;F0
	push [ebp + 12] ;f0
	call Fibonacci  ;f0=0

	push [ebp + 20]
	push [ebp + 16]
	push [ebp + 8]
	call Fibonacci  ;f1=1

	mov esp,ebp
	pop ebp
	ret 16
Begin endp

Fibonacci proc
	push ebp
	mov ebp,esp
	push esi
	push edi
	push eax
	push ebx
	push ecx
	mov eax, [ebp+16] ;f0 8
	mov ebx, [ebp+12] ;f1 13
	mov ecx, [ebp+8]  ;f2 21

	; Reverse to addnum
	push eax
	call Reverse
	push ebx
	call Reverse
	xor edi,edi
	xor esi,esi

	Start_fibo:
		cmp BYTE PTR [edi+eax],0
		jz  Next_fibo
		xor edx,edx
		mov dl,BYTE PTR [edi+eax]
		mov dh,BYTE PTR [edi+ebx]
		inc edi
		sub dl,30h
		sub dh,30h
		add dh,dl
		add dh,BYTE PTR [mem]
		cmp dh,10
		jl	 Low_1
		jmp  Great_1

	Great_1:
		sub dh,10
		mov BYTE PTR [mem],1
		xor dl,dl
		add dh,30h
		push edx
		jmp Start_fibo

	Low_1:
		mov BYTE PTR [mem],0
		xor dl,dl
		add dh,30h
		push edx
		jmp Start_fibo

	Next_fibo:
		xor dl,dl
		cmp BYTE PTR [ebx+edi],0
		jz  Check_mem
		mov dh,BYTE PTR [ebx+edi]
		add dh,BYTE PTR [mem]
		inc edi
		sub dh,30h
		cmp dh,10
		jl   Low_2
		jmp  Great_2

	Great_2:
		sub dh,10
		mov BYTE PTR [mem],1
		add dh,30h
		push edx
		jmp Next_fibo

	Low_2:
		mov BYTE PTR [mem],0
		add dh,30h
		push edx
		jmp Next_fibo

	Check_mem:
		cmp BYTE PTR [mem],0
		jz  Pop_fibo
		mov dh,BYTE PTR [mem]
		add dh,30h
		push edx
		inc edi
		mov BYTE PTR [mem],0
		
	Pop_fibo:
		cmp edi,0
		jz  End_fibo
		pop edx
		mov BYTE PTR [esi+ecx],dh
		inc esi
		dec edi
		jmp Pop_fibo

	End_fibo:
		mov BYTE PTR [esi+ecx],0
		mov BYTE PTR [mem],0
		pop ebx
		pop ecx
		pop eax
		pop edi
		pop esi
		mov esp,ebp
		pop ebp
		ret 12
		
		
Fibonacci endp

Reverse proc
	push ebp
	mov ebp,esp
	push eax
	push ebx
	xor edi,edi
	mov eax,[ebp+8]
	xor ebx,ebx
	Start_reverse:
		cmp BYTE PTR [eax+edi],0
		jz  Temp
		xor edx,edx
		mov dl, BYTE PTR [edi+eax]
		push edx
		inc edi
		inc ebx
		jmp Start_reverse
	Temp:
		xor edi,edi
	Pop_reverse:
		cmp ebx,0
		je  End_reverse
		pop edx
		mov BYTE PTR [edi+eax],dl
		inc edi
		dec ebx
		jmp Pop_reverse

	End_reverse:
		mov BYTE PTR [edi+eax],0
		xor edi,edi
		pop ebx
		pop eax
		mov esp,ebp
		pop ebp
		ret 4
Reverse endp

Atoi proc
	push ebp
	mov ebp,esp
	push eax
	push ebx
	push ecx
	mov ecx,[ebp+8]  ;num
	xor edi,edi
	xor eax,eax
	mov ebx,10
	Start_atoi:
		xor edx,edx
		cmp BYTE PTR [ecx+edi],0
		je  End_atoi
		mov dl, BYTE PTR [ecx+edi]
		sub dl,30h
		add eax,edx
		mul ebx
		inc edi
		jmp Start_atoi
	End_atoi:
		div ebx
		mov count_num,eax
		pop ecx
		pop ebx
		pop eax
		mov esp,ebp
		pop ebp
		ret 4
Atoi endp

Copyfibo proc
	push ebp
	mov ebp,esp
	push eax
	push ebx
	push edi
	mov eax,[ebp+12] ;source
	mov ebx,[ebp+8] ; copy source
	xor edi,edi
	Start_copy:
		xor edx,edx
		mov dl,BYTE PTR [eax+edi]
		mov BYTE PTR [ebx+edi],dl
		inc edi
		cmp BYTE PTR [eax+edi],0
		je  End_copy
		jmp Start_copy

	End_copy:
		mov BYTE PTR [ebx+edi],0
		pop edi
		pop ebx
		pop eax
		mov esp,ebp
		pop ebp
		ret 8
		
Copyfibo endp
end main