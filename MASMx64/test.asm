.data
string db "Hello, World!", 0ah, 0h
fWrite db "WriteConsole",0
fGStdh db "GetStdHandle", 0
fExit db "ExitProcess", 0

.data?
aKernelBase dq 1 dup (?)
vaXedTb dq 1 dup (?)
vaXedDir dq 1 dup (?)

written dq 1 dup (?)
STD_OUT_HANDLE dq 1 dup (?)

afWrite dq 1 dup (?)
afGetStdHandle dq 1 dup (?)
afExit dq 1 dup (?)

.code
main proc
	call GetBaseAddress
	call GetXTableAddress

    lea rcx, afWrite     ;
    lea rdx, fWrite      ; Find address of WriteConsole()
    call FindAddr        ;
	lea rcx, afGetStdHandle
	lea rdx, fGStdh
	call FindAddr
	lea rcx, afExit
	lea rdx, fExit
	call FindAddr

	mov rax, afGetStdHandle
	mov rcx, -11
	call rax
	mov STD_OUT_HANDLE, rax

	mov rax, afWrite
	mov rcx, STD_OUT_HANDLE
	lea rdx, string
	mov r8, 13
	lea r9, written
	push 0
	call rax

	mov rax, afExit
	mov rcx, 0
	call rax
main endp

GetBaseAddress proc
	push rbp
	mov rbp, rsp
	xor rax, rax
	mov rax, gs:[rax + 60h] ;rax = peb
	mov rax, [rax + 18h]	;rax = peb->ldr
	mov rsi, [rax + 20h]	;rax = peb->ldr.InMemoryOrderModuleList
	lodsq					
	xchg rax, rsi			
	lodsq					
	mov rax, [rax + 20h]	;kernel32 base
	mov aKernelBase, rax
	leave
	ret
GetBaseAddress endp
GetXTableAddress proc 
	push rbp
	mov rbp, rsp
	mov ebx, [rbx + 3ch]	;RVA PE signature
	add rbx, aKernelBase	;VA signature
	mov ebx, [rbx + 88h]	;RVA Exported Dir
	add rbx, aKernelBase	;VA of Exported Dir
	mov vaXedDir, rbx		;Save
	mov esi, [rbx + 20h]	;RVA of exported function name table
	add rsi, aKernelBase	;VA of efnt
	mov vaXedTb, rsi
	leave
	ret
GetXTableAddress endp

FindAddr proc
    push rbp
    mov rbp, rsp
	sub rsp, 16
	mov [rbp-8], rdx
	mov [rbp-16], rcx
	push rbx
    xor rcx, rcx
    xor rbx, rbx
    push aKernelBase
    mov rsi, vaXedTb
    l1:
    pop rax
    inc rcx
    lodsd                           ; Load RVA to EAX, ESI = *nextRVA
    add rax, aKernelBase            ; VA of function name
	mov rdx, [rbp-8]				; Load string address to compare
    push rax                        ; save eax value (Current function address name)
    cmploop:                        ;
    mov bl, [rax]                   ; Use ebx to hold compare value
    mov bh, [rdx]                   ;
    inc rax                         ; Next value to compare
    inc rdx                         ;
    cmp bh, 0                       ; Check if compare done or not
    je endcmp                       ; If done jump to end
    cmp bh, bl                      ; Compare value
    je cmploop                      ; If Yes, check next value
    jmp l1                          ; Else, check next element
    endcmp:                         ;
    pop rax                         ; Restore current func address name
    mov rbx, vaXedDir              ; Move RVA exported directory to ebx (calculate real function address)
    mov esi, [rbx + 24h]            ; ESI = RVA of function ordinal table
    add rsi, aKernelBase                ; ESI = VA of function ordinal table
    mov cx, [rsi + rcx *2]          ; get function biased_ordinal
    dec cx                         ; get function ordinal ()
    mov esi, [rbx + 1ch]            ; RVA of address function = exported addr table
    add rsi, aKernelBase            ; VA of exported addr table
    mov edi, [rsi + rcx *4]         ; RVA of function
    add rdi, aKernelBase            ; VA of funtion
	mov rcx, [rbp-16]
    mov [rcx], rdi                  ; save value
	pop rbx                         ;
	add rsp, 16
    leave                           ;
    ret                             
FindAddr endp

end