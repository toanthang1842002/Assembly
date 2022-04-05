.data
fWrite db "WriteConsole",0
fRead db "ReadConsole", 0
fGetStdHandle db "GetStdHandle", 0
fExit db "ExitProcess", 0
mem dd 0
count dd 0
time dd 0
msg1 db "Input: " ,0dh
msg2 db " " ,0dh
msg3 db "The number of occurrences: ",0dh
msg4 db "Position: ",0dh
msgLF db 0dh,0ah,0
FI1 db '1',0dh
FI0 db '0',0dh

.data?
str1 db 100 dup(?)
str2 db 32 dup(?)
res db 32 dup(?)
len_res dq 1 dup(?)
len_time dq 1 dup(?)
ch_time db 1 dup(?)
len_msg dq 2 dup(?)
len_fibo dq 2 dup(?)

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


res_times db 1 dup(?)
fibo0 db 1000 dup(?)
fibo1 db 1000 dup(?)
fibo2 db 1000 dup(?)

.code

main proc
	;==========================================================================================================================as=======================================
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
	;=================================================================================================================================================================
	
	lea rcx,msg1
	call Strlen
	mov len_msg,rdx

	lea rdx, msg1
	mov r8, len_msg
	call Print

	mov rax, iRead
	mov rcx, STD_IN
	lea rdx, str1
	mov r8, 100
	lea r9, read
	push 0
	call rax

	lea rdi,str1
	call Atoi
	
	cmp rax,0
	je  Zero
	xor esi,esi
	call Begin
	Start_fibo:
		cmp esi,count
		je  End_fibo
		cmp esi,0
		je  First


		lea rcx,fibo1
		lea rdx,fibo0
		lea r8, fibo2
		call Addition

		lea rcx,fibo2
		call Strlen
		mov len_fibo,rdx

		lea rdx,fibo2
		mov r8,len_fibo
		call Print
		call endl

		lea rcx,fibo1
		call Reverse

		lea rcx,fibo1
		lea rdx,fibo0
		call Copy

		lea rcx,fibo2
		lea rdx,fibo1
		call Copy

		inc esi
		jmp Start_fibo

	Zero:
		lea rcx,FI0
		call Strlen
		mov r8,rdx
		lea rdx,FI0
		call Print
		jmp End_fibo
	First:
		lea rcx,FI1
		call Strlen
		mov r8,rdx
		lea rdx,FI1
		call Print
		call endl
		inc esi
		jmp Start_fibo
	End_fibo:
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


Strlen PROC
	push	rbp
	mov		rbp,rsp
	push    rsi
	xor		rsi,rsi
	xor		rdx,rdx
	count_char:
		cmp	byte ptr [rcx+rsi],0dh
		jz finished
		inc rsi
		jmp count_char

	finished:
		mov rdx,rsi
		pop rsi
		mov rsp,rbp
		pop rbp
		ret 
Strlen endp


Itoa proc                     ;rax = int     rdi = str
	push rbp
	mov rbp,rsp
	sub rsp,16
	push rbx
	push rdx
	push rsi
	xor rsi,rsi
	mov rbx,10
	Start_div:
		xor rdx,rdx
		div rbx
		add dl,30h
		push rdx
		inc rsi
		cmp rax,0
		je Tmp
		jmp Start_div
	Tmp:
		xor rbx,rbx
		
	Pop_Itoa:
		cmp rsi,0
		je  End_Itoa
		pop rdx
		mov BYTE PTR [rdi+rbx],dl
		inc rbx
		dec rsi
		jmp Pop_Itoa
	End_Itoa:
		mov BYTE PTR [rdi+rbx],0dh
		pop	rsi
		pop rdx
		pop rbx
		add rsp,16
		mov rsp,rbp
		pop rbp
		ret
Itoa endp

endl proc				
	push rbp
	mov rbp, rsp
	mov rax, iWrite
	push 0
	lea r9, write
	mov r8, 2
	lea rdx, msgLF
	mov rcx, STD_OUT
	call rax
	leave
	ret
endl endp

Print proc				; print new line
	push rbp
	mov rbp, rsp
	mov rax, iWrite
	push 0
	lea r9, write
	mov rcx, STD_OUT
	call rax
	leave
	ret
Print endp

Atoi proc              ; rax = int       rdi = str
	push rbp
	mov rbp,rsp
	push rbx
	push rdx
	push rsi
	xor rsi,rsi
	xor rax,rax
	mov rbx,10
	Start_mul:
		cmp BYTE PTR [rdi + rsi],0dh
		je  End_mul
		xor rdx,rdx
		mov dl,BYTE PTR [rdi+rsi]
		sub dl,30h
		add rax,rdx                    ; s=s*10+a
		mul rbx
		inc rsi
		jmp Start_mul
		
	End_mul:
		div rbx
		mov count , eax
		pop rsi
		pop rdx
		pop rbx
		mov rsp,rbp
		pop rbp
		ret
Atoi endp

Addition proc
	push rbp
	mov rbp,rsp
	sub rsp,48
	mov [rbp-8],rcx           ; high
	mov [rbp-16], rdx         ; low
	mov [rbp-24], r8          ; res
	push rax
	push rbx
	push rsi
	push rdi
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
		xor rdi,rdi
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
		pop rdi
		pop rsi
		pop rbx
		pop rax
		add rsp,48
		mov rsp,rbp
		pop rbp
		ret
Addition endp

Reverse proc
	push rbp
	mov rbp,rsp
	push rsi
	push rdx
	xor rsi,rsi
	xor rdi,rdi
	Start_reverse:
		xor rdx,rdx
		mov dl, BYTE PTR [rcx+rsi]
		inc rsi
		push rdx
		cmp BYTE PTR [rcx+rsi],0dh
		jne Start_reverse
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
		pop rsi
		mov rsp,rbp
		pop rbp
		ret
Reverse endp

Begin proc
	push rbp
	mov rbp,rsp
	lea rcx,FI0      ;F0
	lea rdx,FI0      ;F0
	lea r8, fibo0    ;f0 = 0
	call Addition

	lea rcx,FI0    ;F0
	lea rdx,FI1    ;F1
	lea r8, fibo1    ;f1 = 1
	call Addition

	mov rsp,rbp
	pop rbp
	ret

Begin endp

Copy proc
	push rbp
	mov rbp,rsp
	push rsi
	push rax
	xor rsi,rsi
	Start_copy:
		xor rax,rax
		mov al,BYTE PTR [rsi+rcx]
		mov BYTE PTR [rsi+rdx],al
		inc rsi
		cmp BYTE PTR [rsi+rcx],0dh
		je  End_copy
		jmp Start_copy
	End_copy:
		mov BYTE PTR [rsi+rdx],0dh
		pop rax
		pop rsi
		mov rsp,rbp
		pop rbp
		ret
Copy endp
end