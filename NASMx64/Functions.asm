writeCS:
    mov rdi,1            ;STD_OUT
    mov rax,1            ;SYS_write
    syscall
    ret

readCS:
    mov rdi,0           ;STD_IN
    mov rax,0           ;SYS_READ
    syscall
    ret
Exit:
    xor rdi,rdi         ;value
    mov rax,60          ;SYS_exit
    syscall

strlen:                     ; rcx = address of string       ; rdx = length of string
    push rbp
    mov rbp,rsp
    push rsi
    xor rsi,rsi 

    Start_count:
        cmp byte [rcx+rsi],0ah
        je End_count
        inc rsi
        jmp Start_count
    End_count:
        mov rdx,rsi 
        pop rsi
        leave
        ret

Uppercase: ; rcx = address of string
    push rbp
    mov rbp,rsp
    push rsi
    push rdi
    push rdx
    xor rsi,rsi
    xor rdi,rdi
    Start_upper:
        cmp byte [rcx+rsi],0ah
        je End_upper
        mov dl, BYTE [rcx+rsi]
        cmp dl, 'a'
        jl  skip_upper  
    Next_upper:
        cmp dl, 'z'
        jg  skip_upper
        sub dl, 20h
        mov BYTE [rcx+rsi], dl
    skip_upper:
        inc rsi
        jmp Start_upper
    End_upper:
        mov byte [rcx+rsi], 0ah
        pop rdx
        pop rdi
        pop rsi
        leave 
        ret

Substring:                     ; rcx = address of string1  rdx = address of string 2
    push rbp 
    mov rbp,rsp
    sub rsp,16
    mov [rbp-8],rcx
    mov [rbp-16],rdx
    push rsi
    push rdi
    push rax
    xor rsi,rsi
    xor rdi,rdi
    xor r10,r10
    xor rbx,rbx
    Find_start:
        cmp byte [rcx+rsi],0ah
        je End_find
        mov al, BYTE [rcx+rsi]
        mov ah, BYTE [rdx]
        cmp al, ah
        je  Next_find
        inc rsi
        jmp Find_start
    Next_find:
        cmp byte [rdx+rdi],0ah
        je Push_pos
        mov al, BYTE [rcx+rsi]
        mov ah, BYTE [rdx+rdi]
        cmp al, ah
        jne Temp_find
        inc rsi
        inc rdi
        jmp Next_find
    
    Temp_find:
        sub rsi,rdi
        xor rdi,rdi
        inc rsi
        jmp Find_start

    Push_pos:
        sub rsi,rdi
        mov rax,rsi
        mov rdi,r8
        call Itoa

        mov rax,r9
        call Push_positions

        inc rbx
        inc rsi 
        xor rdi,rdi
        jmp Find_start
    End_find:
        pop rax
        pop rdi
        pop rsi
        add rsp,16
        leave
        ret

Push_positions:            ; rdi =  res        rax = res_times
    push rbp
    mov rbp,rsp
    push rsi
    push rbx
    push rdx
    xor rsi,rsi
    mov rbx,r10
    Start_push:
        cmp BYTE [rdi+rsi],0ah
        je End_push
        xor rdx,rdx
        mov dl, BYTE [rdi+rsi]
        mov BYTE [rax+rbx],dl
        inc rsi
        inc rbx
        jmp Start_push
    End_push:
        mov BYTE [rax+rbx],20h
        inc rbx
        mov BYTE [rax+rbx],0ah
        mov r10,rbx
        pop rdx
        pop rbx
        pop rsi
        leave
        ret

Itoa:             ; rax = int      rdi = string
    push rbp
    mov rbp,rsp
    push rsi
    push rbx
    push rdx
    xor rsi,rsi
    mov rbx,10
    Start_div:
        xor rdx,rdx
        div rbx
        add dl,30h
        push rdx
        inc rsi
        cmp rax,0
        jne Start_div

    xor rbx,rbx
    Pop_Itoa:
        cmp rsi,0
        je End_Itoa
        pop rdx
        mov BYTE [rdi+rbx],dl
        dec rsi
        inc rbx
        jmp Pop_Itoa
    End_Itoa:
        mov byte [rdi+rbx], 0ah
        pop rdx
        pop rbx
        pop rsi
        leave
        ret

Atoi:            ;rax = int      rdi = string
    push rbp
    mov rbp,rsp
    push rsi
    push rbx
    push rdx
    xor rsi,rsi
    mov rbx,10
    xor rax,rax
    Start_atoi:
        cmp byte [rdi+rsi],0ah
        je End_atoi
        mov dl, BYTE [rdi+rsi]
        sub dl, 30h
        add rax, rdx
        mul rbx
        inc rsi
        jmp Start_atoi
    End_atoi:
        div rbx
        pop rdx
        pop rbx
        pop rsi
        leave
        ret
Addition:              ; rcx = address of high  rdx = address of low   r8= res
    push rbp
    mov rbp,rsp
    sub rsp,32
    push rsi
    push rdi
    push rax
    push rbx
    mov [rbp-8],rcx
    mov [rbp-16],rdx
    mov [rbp-24],r8
    xor rbx,rbx           
    xor r10,r10 ;r10 = mem
    mov r9,1

    mov rcx,[rbp-8]
    call Reverse

    mov rcx,[rbp-16]
    call Reverse

    mov rcx,[rbp-8]
    call strlen
    mov rdi,rdx                ; strlen of string 1

    mov rcx,[rbp-16]
    call strlen
    mov rsi,rdx                ; strlen of string 2

    cmp rdi,rsi
    jg  Prepare_1
    cmp rdi,rsi
    jl  Prepare_2

    Prepare_1:
        mov rcx,[rbp-8]
        mov rdx,[rbp-16]
        jmp Skip_prepare
    Prepare_2:
        mov rcx,[rbp-16]
        mov rdx,[rbp-8]
        jmp Skip_prepare
    Skip_prepare:
    xor rsi,rsi
    xor rdi,rdi
    Start_add:
        cmp BYTE [rdx+rsi],0ah
        je Next_add
        xor rax,rax
        mov ah, BYTE [rcx+rsi]
        mov al, BYTE [rdx+rsi]
        inc rsi
        sub ah,30h
        sub al,30h
        add ah, al
        add ah, bl
        cmp ah,10 
        jl  low_than
        jmp great_than
    Next_add:
        mov r9,2 
        cmp BYTE [rcx+rsi],0ah
        je Check_mem  
        mov ah, BYTE [rcx+rsi]
        inc rsi  
        sub ah,30h
        add ah,bl
        cmp ah,10 
        jl  low_than
        jmp great_than
    low_than:
        xor al,al
        add ah,30h
        mov bl,0
        push rax
        cmp r9,1
        je  Start_add
        jmp Next_add
    great_than:
        xor al,al
        sub ah,10 
        add ah,30h
        mov bl,1
        push rax
        cmp r9,1
        je  Start_add
        jmp Next_add
    
    Check_mem:
        cmp r10,0 
        je  Temp_add
        mov ah,1
        add ah,30h
        push rax
        inc rsi 
    
    Temp_add:
        xor rcx,rcx
        xor rdi,rdi
        mov rcx,[rbp-24]
    Pop_st:
        cmp rsi,0 
        je End_add
        pop rax
        mov byte [rcx+rdi],ah
        inc rdi
        dec rsi 
        jmp Pop_st

    End_add:
        mov byte[rcx+rdi], 0ah
        pop rbx
        pop rax
        pop rdi
        pop rsi
        add rsp,32
        leave
        ret


Reverse:                      ; rcx = address of string
    push rbp
    mov rbp,rsp
    push rsi
    push rdi
    push rdx
    xor rsi,rsi
    xor rdi,rdi
    Start_reverse:
        xor rdx,rdx
        mov dl, BYTE [rcx+rsi]
        push rdx
        inc rsi
        cmp BYTE [rcx+rsi],0ah
        jne Start_reverse
    Pop_reverse:
        dec rsi
        pop rdx
        mov BYTE [rcx+rdi],dl
        inc rdi
        cmp rsi,0
        jne Pop_reverse
    End_reverse:
        mov byte [rcx+rdi], 0ah
        pop rdx
        pop rdi
        pop rsi
        leave
        ret

Copy:            ; rcx = source  rdx=copy
    push rbp
    mov rbp,rsp
    push rsi
    push rax
    xor rsi,rsi
    Start_copy:
        cmp BYTE [rcx+rsi],0ah
        je End_copy
        xor rax,rax
        mov al, BYTE [rcx+rsi]
        mov BYTE [rdx+rsi],al
        inc rsi
        jmp Start_copy
    End_copy:
        mov BYTE [rdx+rsi],0ah
        pop rax
        pop rsi
        leave
        ret

strcmp:                     ; rax = res           rbx= MIN or Max
    push rbp
    mov rbp,rsp
    push rsi
    push rdi
    push rcx
    push rdx
    xor rsi,rsi
    xor rdi,rdi
    Cmp_len:
        cmp BYTE [rax+rsi],0ah
        je Next_cmp
        cmp BYTE [rbx+rsi],0ah
        je Mark_1
        inc rsi
        jmp Cmp_len
    Check_second:
        cmp BYTE [rbx+rsi],0ah
        je Next_cmp
        jmp Mark_2
    Next_cmp:
        cmp BYTE [rax+rdi],0ah
        je Mark_3
        xor rdx,rdx
        mov dl, BYTE [rax+rdi]
        mov dh, BYTE [rbx+rdi]
        inc rdi
        cmp dl,dh
        jg  Mark_1
        cmp dl,dh
        jl  Mark_2
        jmp Next_cmp
    Mark_1:
        mov r8,1
        jmp End_cmp
    Mark_2:
        mov r8,2
        jmp End_cmp
    Mark_3:
        mov r8,3
        jmp End_cmp
    End_cmp:
        pop rdx
        pop rcx
        pop rdi
        pop rsi
        leave
        ret
