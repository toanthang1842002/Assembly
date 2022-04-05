.data
fWrite db "WriteConsole",0
fRead db "ReadConsole", 0
fGetStdHandle db "GetStdHandle", 0
fExit db "ExitProcess", 0
mem dd 0

.data?
str1 db 32 dup(?)
str2 db 32 dup(?)
res db 32 dup(?)
num1 db 10 dup(?)
num2 db 10 dup(?)
len_res dq 1 dup(?)

vaxTb dq 2 dup(?)
vaxDir dq 2 dup(?)
KernelBase dq 2 dup(?)

read dq 2 dup(?)
write dq 2 dup(?)
STD_OUT dq 2 dup(?)
STD_IN  dq 2 dup(?)

iWrite dq 2 dup(?)
iRead  dq 2 dup(?)
iGetStdHandle dq 2 dup(?)
iExit dq 2 dup(?)

.code

main proc
	call GetBaseAddr
	call GetTableAddr

	lea rcx , iWrite
	lea rdx , fWrite
	call FindAddr

	lea rcx , iRead
	lea rdx , fRead
	call FindAddr

	lea rcx , iGetStdHandle
	lea rdx , fGetStdHandle
	call FindAddr

	lea rcx , iExit
	lea rdx , fExit
	call FindAddr

	mov rax, iGetStdHandle
	mov rcx,-11
	call rax
	mov STD_OUT , rax

	mov rax, iGetStdHandle
	mov rcx,-10
	call rax
	mov STD_IN, rax

	mov rax, iRead
	mov rcx, STD_IN
	lea rdx, str1
	mov r8, 32
	lea r9, read
	push 0
	call rax

	mov rax, iRead
	mov rcx, STD_IN
	lea rdx, str2
	mov r8, 32
	lea r9, read
	push 0
	call rax

	

	lea rcx,str1
	call Strlen
	mov rax,rdx
	lea rcx,str2
	call Strlen
	mov rbx,rdx

	cmp rbx,rax
	jg  Begin_add_2

	Begin_add_1:
		lea rcx,str1    ;high
		lea rdx,str2    ;low
		lea r8, res
		call Addition
		jmp Finished

	Begin_add_2:
		lea rcx,str2   ;high
		lea rdx,str1   ;low
		lea r8, res
		call Addition

	Finished:
		lea rcx,res
		call Strlen
		mov len_res,rdx
		mov rax, iWrite
		mov rcx, STD_OUT
		lea rdx, res
		mov r8, len_res
		lea r9, write
		push 0
		call rax

		mov rax, iExit
		mov rcx,0
		call rax


main endp

GetBaseAddr proc
	push rbp
	mov rbp,rsp
	xor rax,rax
	mov rax, gs: [rax + 60h]    ; rax = peb
	mov rax, [rax + 18h]		  ; rax = peb -> ldr
	mov rsi, [rax + 20h]        ; rax = peb -> ldr.InMemoryOrderModuleList
	lodsq
	xchg rax,rsi
	lodsq
	mov rax, [rax + 20h]			;kernel32 base
	mov KernelBase, rax           ; save kernel
	leave 
	ret
GetBaseAddr endp

GetTableAddr proc
	push rbp
	mov rbp,rsp
	xor rbx,rbx
	mov ebx, [rax + 3ch]         ; RVA of PE signature
	add rbx, KernelBase          ; VA of PE signature
	mov ebx, [rbx + 88h]         ; RVA of Export Dir
	add rbx, KernelBase          ; VA of Export Dir
	mov vaxDir , rbx             ; save
	mov esi, [rbx + 20h]         ; RVA of Export funtion name table
	add rsi, rax                 ; VA of Export funtion name table
	mov vaxTb , rsi
	leave 
	ret
GetTableAddr endp

FindAddr proc
	push rbp
	mov rbp,rsp
	sub rsp, 16
	push rbx
	mov [rbp - 8] , rcx
	mov [rbp -16] , rdx
	xor rbx,rbx
	xor rcx,rcx
	xor rdx,rdx
	mov rsi,vaxTb
	
	Start:
		pop rax							
		inc rcx
		lodsd							; load str ESI -> EAX (RSI = VA of Export funtion name table)
		add rax, KernelBase				;
		mov rdx, [rbp-16]
		push rax
	Cmp_begin:
		mov bl, [rax]                  
		mov bh, [rdx]
		inc rax
		inc rdx
		cmp bh,0
		je  Cmp_finish
		cmp bh,bl
		je  Cmp_begin
		jmp Start
	Cmp_finish:
		pop rax						; restore current func address name
		mov rbx, vaxDir
		mov esi, [rbx + 24h]        ; esi = RVA of function ordinal table
		add rsi, KernelBase			; esi = VA of function ordinal table
		mov cx, [rsi + rcx*2]       ; get func biased ordinal
		dec cx						; get func biased 
		mov esi, [rbx + 1ch]        ; RVA of address func
		add rsi, KernelBase         ; VA of Export Address Table
		mov edi, [rsi + rcx*4]      ; RVA of func
		add rdi, KernelBase         ; VA of func
		mov rcx, [rbp - 8]
		mov [rcx], rdi
		pop rbx
		add rsp,16
		leave
		ret
FindAddr endp

Addition proc
	push rbp
	mov rbp,rsp
	sub rsp,48
	mov [rbp-8],rcx           ; high
	mov [rbp-16], rdx         ; low
	mov [rbp-24], r8          ; res
	push rax
	push rbx
	xor rax,rax
	xor rsi,rsi
	xor rdi,rdi
	mov r9,1
	mov rcx,[rbp-8]
	call Reverse
	mov rcx,[rbp-16]
	call Reverse
	mov rcx,[rbp-8]
	Start_add:
		cmp BYTE PTR [rdx+rsi],0dh
		je  Next
		xor rax,rax
		mov ah, BYTE PTR [rcx+rsi]
		mov al, BYTE PTR [rdx+rsi]
		inc rsi
		sub al,30h
		sub ah,30h
		add ah,al
		add ah, BYTE PTR [mem]
		cmp ah,10
		jl Low_than
		jmp  Great_than
	Next:
		mov r9,2
		cmp BYTE PTR [rcx+rsi],0dh
		je  Check_mem
		xor rax,rax
		mov ah, BYTE PTR [rcx+rsi]
		inc rsi
		sub ah,30h
		add ah,BYTE PTR [mem]
		cmp ah,10
		jl	Low_than
		jmp Great_than

	Great_than:
		xor al,al
		sub ah,10
		add ah,30h
		push rax
		mov BYTE PTR [mem],1
		cmp r9,1
		je  Start_add
		jmp Next
	Low_than:
		xor al,al
		add ah,30h
		push rax
		mov BYTE PTR [mem],0
		cmp r9,1
		je  Start_add
		jmp Next
	Check_mem:
		cmp BYTE PTR [mem],0
		jz  Temp
		mov ah,BYTE PTR [mem]
		add ah,30h
		push rax
		inc rsi
		mov BYTE PTR [mem],0
	Temp:
		xor rcx,rcx
		mov rcx,[rbp-24]
	Pop_st:
		cmp rsi,0
		je  End_add
		pop rax
		mov BYTE PTR [rcx+rdi],ah
		inc rdi
		dec rsi
		jmp Pop_st
	End_add:
		MOV BYTE PTR [rcx+rdi],0dh
		mov BYTE PTR [mem],0
		add rsp,48
		pop rbx
		pop rax
		mov rsp,rbp
		pop rbp
		ret
Addition endp

Reverse proc
	push rbp
	mov rbp,rsp
	xor rsi,rsi
	xor rdi,rdi
	push rdx
	Start_reverse:
		xor rdx,rdx
		mov dl, BYTE PTR [rcx+rsi]
		inc rsi
		push rdx
		cmp BYTE PTR [rcx+rsi],0dh
		jnz Start_reverse
	Pop_st:
		cmp rsi,0
		je  End_reverse
		pop rdx
		mov BYTE PTR [rcx+rdi], dl
		inc rdi
		dec rsi
		jmp Pop_st
	End_reverse:
		mov BYTE PTR [rcx+rdi], 0dh
		pop rdx
		mov rsp,rbp
		pop rbp
		ret
Reverse endp

Strlen PROC
	push	rbp
	mov		rbp,rsp
	xor		rsi,rsi
	xor		rdx,rdx
	count_char:
		cmp	byte ptr [rcx+rsi],0dh
		jz finished
		inc rsi
		jmp count_char

	finished:
		mov rdx,rsi
		mov rsp,rbp
		pop rbp
		ret 
Strlen endp

end