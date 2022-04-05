.386
.model flat, stdcall
option casemap:none

include \masm32\include\kernel32.inc 
include \masm32\include\masm32.inc 
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data	
	str1	db 100 dup(?)
	str2	db 10 dup(?)
	pos	db 5 dup(?)
	res	db 100 dup(?)
	count		dd 0
	times	dd 0
	res_times db 10 dup(?)
	msg1 db "So lan xuat hien : ",0
	msg2 db "Vi tri xuat hien : ",0
	msg3 db 0ah,0
.code
main PROC
	push	100
	push	offset str1
	call	StdIn

	push	10
	push	offset str2
	call	StdIn

	push	offset str1
	push	offset str2
	call	Find_string

	push	offset msg1
	call	StdOut

	push	times
	push	offset res_times
	call	Itoa

	push	offset res_times
	call	StdOut

	push	offset msg3
	call	StdOut

	push	offset msg2
	call	StdOut

	push	offset res
	call	StdOut

	push	0
	call	ExitProcess

main ENDP

Find_string PROC
	push	ebp
	mov		ebp, esp
	push	eax
	push	ebx
	push	ecx
	mov		eax, [ebp+12]          ; eax = address of str1
	mov		ecx, [ebp+8]            ; ecx = address of str2
	xor		esi, esi
	xor		ebx,ebx

	Start_find:
		xor edx,edx
		xor edi,edi
		mov dh, BYTE PTR [eax+esi]
		mov dl, BYTE PTR [ecx]
		cmp dl,dh
		jz  Next_find
		inc ebx
		inc esi
		cmp BYTE PTR [eax+esi],0
		jz  End_find
		jmp Start_find

	Next_find:
		xor edx,edx
		mov dl,BYTE PTR [edi+ecx]
		mov dh,BYTE PTR [eax+ebx]
		inc ebx
		inc edi
		cmp dh,dl
		jnz Ret_temp
		cmp BYTE PTR [edi+ecx],0
		jz  Print_pos
		jmp Next_find

	Ret_temp:
		sub ebx,edi
		inc ebx
		inc esi
		jmp Start_find

	Print_pos:
		sub ebx,edi
		push ebx
		push offset pos
		call Itoa

		push count
		push OFFSET pos
		push OFFSET res
		call Push_position

		inc times

		inc esi
		inc ebx
		jmp Start_find

	End_find:
		pop ecx
		pop ebx
		pop eax
		mov esp,ebp
		pop ebp
		ret 8
Find_string ENDP

Itoa PROC
	push ebp
	mov ebp,esp
	push eax
	push ebx
	push ecx
	mov eax, [ebp+12]
	mov ecx, [ebp+8]
	mov edi,10
	xor ebx,ebx

	Start_itoa:
		xor edx,edx
		div edi
		add dl,30h
		push edx
		inc ebx
		cmp eax,0
		jz  Temp
		jmp Start_itoa

	Temp:
		xor edi,edi
	Pop_itoa:
		cmp ebx,0
		jz  End_itoa
		pop edx
		mov BYTE PTR [edi+ecx],dl
		inc edi
		dec ebx
		jmp Pop_itoa

	End_itoa:
		mov BYTE PTR [edi+ecx],0
		pop ecx
		pop ebx
		pop eax
		mov esp,ebp
		pop ebp
		ret 8
Itoa ENDP

Push_position PROC
	push ebp
	mov ebp,esp
	push eax
	push ebx
	push ecx
	xor edi,edi
	mov eax,[ebp+16]      ; count
	mov ebx,[ebp+12]      ; pos
	mov ecx,[ebp+8]       ; res

	Start_push:
		xor edx,edx
		cmp BYTE PTR [ebx+edi],0
		je  End_push
		mov dl,BYTE PTR [ebx+edi]
		mov BYTE PTR [eax+ecx],dl
		inc edi
		inc eax
		jmp Start_push

	End_push:
		mov BYTE PTR [eax+ecx],20h
		inc eax
		mov BYTE PTR [eax+ecx],0
		mov count,eax
		xor edi,edi
		pop ecx
		pop ebx
		pop eax
		mov esp,ebp
		pop ebp
		ret 12

Push_position ENDP
END main