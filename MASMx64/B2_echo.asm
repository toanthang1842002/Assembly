.data
fWrite db "WriteConsole",0
fRead db "ReadConsole", 0
fGetStdHandle db "GetStdHandle", 0
fExit db "ExitProcess", 0

.data?
string db 32 dup(?)

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
	lea rdx, string
	mov r8, 32
	lea r9, read
	push 0
	call rax
	
	mov rax, iWrite
	mov rcx, STD_OUT
	lea rdx, string
	mov r8, read
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

end