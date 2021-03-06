.data
fWrite db "WriteConsole",0
fRead db "ReadConsole", 0
fGetStdHandle db "GetStdHandle", 0
fExit db "ExitProcess", 0
msgLF db 0dh,0ah,0
mem dd 0
amount dd 0
count dd 0
time dd 0
msg1 db "Input: " ,0dh
msg2 db "Sum of EVEN number: " ,0dh
msg3 db "The number of array: ",0dh
msg4 db "Sum of Odd number: " ,0dh
min		dq	0ffffffffh
max		dq	0h
checkd   dd  0
zero  db '0',0dh

.data?
str1 db 1000 dup(?)
str2 db 1000 dup(?)
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
SumOdd db 1000 dup(?)
SumEven db 1000 dup(?)

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

	lea rcx,msg3
	call Strlen
	mov len_msg,rdx

	lea rdx, msg3
	mov r8, len_msg
	call Print

	lea rdi,str1
	call Atoi
	mov amount,eax

	lea rcx,zero
	lea rdx,zero
	lea r8,SumOdd
	call Addition

	lea rcx,zero
	lea rdx,zero
	lea r8,SumEven
	call Addition

	mov esi,amount
	Start_array:
		mov rax, iRead
		mov rcx, STD_IN
		lea rdx, str1
		mov r8, 100
		lea r9, read
		push 0
		call rax

		lea rcx,str1
		call Split_str
		
		cmp esi,0
		je  End_Array
		jmp Start_array
	
	
	End_Array:
		; Print even
		lea rcx,msg2
		call Strlen
		mov len_msg,rdx

		lea rdx, msg2
		mov r8, len_msg
		call Print

		lea rcx,SumEven
		call Strlen
		mov len_msg,rdx

		lea rdx, SumEven
		mov r8, len_msg
		call Print
		call endl

		; Print odd
		lea rcx,msg4
		call Strlen
		mov len_msg,rdx

		lea rdx, msg4
		mov r8, len_msg
		call Print

		lea rcx, SumOdd
		call Strlen
		mov len_msg,rdx

		lea rdx, SumOdd
		mov r8, len_msg
		call Print
	Exit:
		mov rax, iExit
		mov rcx,0
		call rax


main endp

;=================================================================================================================================================================

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

	;=================================================================================================================================================================


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
		pop rsi
		pop rdx
		pop rbx
		mov rsp,rbp
		pop rbp
		ret
Atoi endp

Split_str proc
	push rbp
	mov rbp,rsp
	sub rsp,16
	mov [rbp-8],rcx          ;str
	push rax
	push rbx
	push rdx
	push rdi
	push r8
	push r9
	xor rax,rax
	xor rdi,rdi
	mov rbx,10
	check_space:
		cmp byte ptr [rcx+rdi],0dh
		je End_split
		cmp byte ptr [rcx+rdi],20h
		jne  Start_split
		inc rdi
		jmp check_space
	Start_split:
		cmp BYTE PTR [rcx+rdi],0dh
		je  change_str
		cmp BYTE ptr [rcx+rdi],20h
		je  change_str
		xor rdx,rdx
		mov dl,BYTE PTR [rcx+rdi]
		sub dl,30h
		add rax,rdx
		mul rbx
		inc rdi
		jmp Start_split

	change_str:
		div rbx
		mov r8,rdi
		mov r9,rax
		lea rdi,str2
		dec rsi
		call Itoa
		mov rdi,r8
		mov rax,r9
		mov r8,2
		xor rdx,rdx
		div r8
		cmp dl,0
		je  Even_num
		cmp dl,1
		je  Odd_num

	Even_num:
		lea rcx,str2
		lea rdx,SumEven
		lea r8,SumEven
		CALL Addition
		jmp Check_split
	Odd_num:
		lea rcx,str2
		lea rdx,SumOdd
		lea r8,SumOdd
		CALL Addition
		jmp Check_split

	Check_split:
		cmp esi,0
		je  End_split
		xor rax,rax
		mov rcx,[rbp-8]

	Next_check_split:
		inc edi
		cmp BYTE PTR [rdi+rcx],0dh
		je  End_split
		cmp BYTE PTR [rdi+rcx],20h
		je  Next_check_split
		jmp Start_split

	End_split:
		pop r9
		pop r8
		pop rdi
		pop rdx
		pop rbx
		pop rax
		add rsp,16
		mov rsp,rbp
		pop rbp
		ret

Split_str endp


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
	push r9
	mov r9,1
	mov rcx,[rbp-8]
	call Reverse
	mov rcx,[rbp-16]
	call Reverse
	mov rcx,[rbp-8]
	call Strlen
	mov rsi,rdx                          ; strlen of string 1
	mov rcx,[rbp-16]
	call Strlen
	mov rdi, rdx                       ; strlen of string 2

	cmp rsi,rdi
	jg  Prepare_1
	
	Prepare_2:
		mov rcx,[rbp-16]
		mov rdx,[rbp-8]
		jmp Skip
	Prepare_1:
		mov rcx,[rbp-8]
		mov rdx,[rbp-16]
		jmp Skip

	Skip:
	xor rax,rax
	xor rsi,rsi
	xor rdi,rdi
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
		pop r9
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
end
