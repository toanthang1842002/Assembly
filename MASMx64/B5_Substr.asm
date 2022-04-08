.data
fWrite db "WriteConsole",0
fRead db "ReadConsole", 0
fGetStdHandle db "GetStdHandle", 0
fExit db "ExitProcess", 0
mem dd 0
count dd 0
time dd 0
msg1 db "String 1: " ,0dh
msg2 db "String 2: " ,0dh
msg3 db "The number of occurrences: ",0dh
msg4 db "Position: ",0dh
msgLF db 0dh,0ah,0

.data?
str1 db 100 dup(?)
str2 db 32 dup(?)
res db 32 dup(?)
num1 db 10 dup(?)
num2 db 10 dup(?)
len_res dq 1 dup(?)
len_time dq 1 dup(?)
ch_time db 1 dup(?)
len_msg dq 2 dup(?)

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

	call endl

	lea rcx,msg2
	call Strlen
	mov len_msg,rdx

	lea rdx, msg2
	mov r8, len_msg
	call Print

	mov rax, iRead
	mov rcx, STD_IN
	lea rdx, str2
	mov r8, 32
	lea r9, read
	push 0
	call rax

	lea rcx, str1
	lea rdx, str2
	call Substring
	

	Finished:
		lea rcx,msg3
		call Strlen
		mov len_msg,rdx

		lea rdx, msg3
		mov r8, len_msg
		call Print

		mov al,BYTE PTR [time]
		lea rdi,ch_time
		call Itoa

		lea rcx,ch_time
		call Strlen
		mov len_res,rdx

		mov rax, iWrite
		mov rcx, STD_OUT
		lea rdx, ch_time
		mov r8, len_res
		lea r9, write
		push 0
		call rax

		call endl

		lea rcx,msg4
		call Strlen
		mov len_msg,rdx

		lea rdx, msg4
		mov r8, len_msg
		call Print

		lea rcx,res_times
		call Strlen
		mov len_res,rdx
		mov rax, iWrite
		mov rcx, STD_OUT
		lea rdx, res_times
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

Substring proc
	push rbp
	mov rbp,rsp
	sub rsp,16
	mov [rbp-8],rcx       ;str1
	mov [rbp-16],rdx		;str2
	push rax
	push rbx
	xor rsi,rsi
	xor rdi,rdi

	First_find:
		cmp BYTE PTR [rcx+rsi],0dh
		je  End_find
		xor rax,rax
		mov al, BYTE PTR [rcx+rsi]      
		mov ah, BYTE PTR [rdx]
		cmp al,ah
		je	Next_find
		inc rsi
		jmp First_find
	Next_find:
		mov al,BYTE PTR [RCX+rsi]
		mov ah,BYTE PTR [rdx+rdi]
		cmp al,ah
		jne  temp
		inc rdi
		inc rsi
		cmp BYTE PTR [rdx+rdi],0dh
		je  Push_position
		jmp Next_find
	temp:
		sub rsi,rdi
		inc rsi
		xor rdi,rdi
		jmp First_find

	Push_position:
		sub rsi,rdi
		mov rax,rsi
		lea rdi,res
		call Itoa
		
		lea rdi, res
		lea rax, res_times
		call Push_pos

		inc time
		inc rsi
		xor rdi,rdi
		jmp First_find
		
	End_find:
		pop rbx
		pop rax
		add rsp,16
		mov rsp,rbp
		pop rbp
		ret
Substring endp

Itoa proc
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

Push_pos proc
	push rbp
	mov rbp,rsp
	sub rsp,32
	mov [rbp-8], rax        ; res_time
	mov [rbp-16], rdi       ; res
	push rbx
	push rdx
	push rsi
	mov ebx,count
	xor rsi,rsi
		Start_push:
			xor rdx,rdx
			mov dl,BYTE PTR [rdi+rsi]
			mov BYTE PTR [rax+rbx],dl
			inc rsi
			inc rbx
			cmp BYTE PTR [rdi+rsi],0dh
			je  End_push
			jmp Start_push

		End_push:
			MOV BYTE PTR [rax+rbx],20h
			inc rbx
			mov BYTE PTR [rax+rbx],0dh
			mov count, ebx
			pop rsi
			pop rdx
			pop rbx
			add rsp,32
			mov rsp,rbp
			pop rbp
			ret
			
Push_pos endp

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

end
