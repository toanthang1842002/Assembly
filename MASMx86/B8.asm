.386
.model flat, stdcall
option casemap: none

include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\kernel32.lib

.data?
x db 30 dup(?)
y db 30 dup(?)

res db 30 dup(?)

.data
lenX dd 0
lenY dd 0
mem dd 0
endl dd 0ah
.code 

main proc
	push 30
	push offset x
	call StdIn

	push 30
	push offset y
	call StdIn
	
	push offset x
	call strlen
	mov ebx,eax
	mov lenX,eax

	push offset y
	call strlen
	mov lenY,eax

	cmp ebx,eax
	jg  Begin_add_2

	Begin_add_1:
		push offset x
		push offset y
		push offset res
		call Addnumber
		jmp Finished

	Begin_add_2:
		push offset y
		push offset x
		push offset res
		call Addnumber
		jmp Finished

	Finished:
		push offset res
		call StdOut

		push 0
		call ExitProcess
main endp

strlen PROC
	push	ebp
	mov		ebp,esp
	mov		ecx,[ebp+08h]
	xor		esi,esi
	xor		eax,eax

	count_char:
		cmp	byte ptr [ecx+esi],0
		jz finished
		inc esi
		jmp count_char

	finished:
		mov eax,esi
		pop ebp
		ret 4
strlen endp


Copy proc
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
		pop edi
		pop ebx
		pop eax
		pop ebp
		ret 8
		
Copy endp

Addnumber proc
	push ebp
	mov ebp,esp
	push esi
	push edi
	push eax
	push ebx
	push ecx
	mov eax, [ebp+16] ;low
	mov ebx, [ebp+12] ;high
	mov ecx, [ebp+8]  ;res

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
		pop ebp
		ret 12
		
Addnumber endp

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
		pop ebp
		ret 4
Reverse endp

end main