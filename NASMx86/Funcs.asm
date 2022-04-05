
ReadCS:
    push ebp
    mov  ebp,esp
    push ebx
    push ecx
    push edx

    mov ecx, [ebp+8]  ;source
    mov edx, [ebp+12] ;size
    mov ebx,0
    mov eax,3
    int 80h

    pop edx
    pop ecx
    pop ebx
    mov esp,ebp
    pop ebp
    ret 8

WriteCS:
    push ebp
	mov ebp, esp
	push ecx
	push ebx

	mov ecx, [ebp+8]

	push ecx
	call strlen
	mov edx, eax

	mov ebx, 1
	mov eax, 4
	int 80h		;sys_write

	pop ebx
	pop ecx
	leave
	ret

strlen:
    push ebp
    mov ebp,esp
    push ecx
    xor eax,eax
    mov ecx,[ebp+8]
    _LOOP:
        cmp BYTE [ecx],0ah
        je  Finished
        inc eax
        inc ecx
        jmp _LOOP
    Finished:
        pop ecx
        mov esp,ebp
        pop ebp
        ret 4

Exit:
    mov eax,1
    mov ebx,0
    int 80h
    ret

uppercase:
    push ebp
    mov ebp,esp
    push ecx
    mov ecx,[ebp+8]  ;source
    xor edi,edi
    Start_check:
        xor edx,edx
        mov dl,BYTE [ecx+edi]
        cmp dl,'a'
        jge  Next_check
    Skip:
        mov byte[ecx+edi],dl
        inc edi
        cmp byte [ecx+edi],0
        jz  End_check
        jmp Start_check
    Next_check:
        cmp dl,'z'
        jg  Skip
        sub dl,20h
        jmp Skip
    End_check:
        pop ecx
        mov esp,ebp
        pop ebp
        ret 4

Atoi:
    push ebp
    mov ebp,esp
    push ebx
    push ecx
    mov ecx,[ebp+8] ;source
    xor edi,edi
    xor eax,eax
    mov ebx,10
    Multi:
        xor edx,edx
        mov dl, BYTE [ecx+edi]
        sub dl,30h
        add eax,edx
        mul ebx
        inc edi
        cmp byte [ecx+edi],0ah
        je  End_atoi
        jmp Multi
    End_atoi:
        div ebx
        mov edi,[ebp+12]
        mov [edi],eax
        pop ecx
        pop ebx
        mov esp,ebp
        pop ebp
        ret 8

Itoa:
    push ebp
    mov ebp,esp
    push eax
    push ebx
    push ecx
    push esi
    mov esi,[ebp+12]   ; number
    mov ecx,[ebp+8]   ; copy
    mov eax,[esi]
    mov edi,10
    xor ebx,ebx
    Divide:
        xor edx,edx
        div edi
        add dl,30h
        push edx
        inc ebx
        cmp eax,0
        jnz Divide

    xor edi,edi
    Push_itoa:
        pop edx
        mov byte [ecx],dl
        inc ecx
        dec ebx
        cmp ebx,0
        jnz Push_itoa
    End_itoa:
        mov byte [ecx],0ah
        pop esi
        pop ecx
        pop ebx
        pop eax
        mov esp,ebp
        pop ebp
        ret 8
        

Print_res:  ; Add num1,num2
    push ebp
    mov ebp,esp
    push ebx
    push ecx
    push esi
    xor eax,eax
    xor esi,esi
    mov esi, [ebp+8]
	add eax, [esi]
	mov esi, [ebp+12]
	add eax, [esi]
	mov ecx, [ebp+16]
    mov edi,10
    xor ebx,ebx
    _Divide:
        xor edx,edx
        div edi
        add edx,30h
        push edx
        inc ebx
        cmp eax,0
        je  Pop_st
        jmp _Divide
    Pop_st:
        cmp ebx,0
        je  Finish_res
        dec ebx
        pop edx
        mov byte[ecx],dl
        inc ecx
        jmp Pop_st
    Finish_res:
        mov BYTE[ecx],0
        pop esi
        pop ecx
        pop ebx
        mov esp,ebp
        pop ebp
        ret 12

Reverse:
    push ebp
    mov ebp,esp
    push ebx
    push ecx
    xor edi,edi
    xor ebx,ebx
    mov ecx,[ebp+8]

    Start_re:
        xor edx,edx
        mov dl, byte[ecx+edi]
        push edx
        inc edi
        inc ebx
        cmp byte[ecx+edi],0ah
        jnz Start_re

    xor edi,edi
    Pop_re:
        pop edx
        mov BYTE [ecx+edi],dl
        inc edi
        dec ebx
        cmp ebx,0
        jnz Pop_re
    End_re:
        mov BYTE[ecx+edi],0ah
        pop ecx
        pop ebx
        mov esp,ebp
        pop ebp
        ret 4

Compare_high:
    push ebp
    mov ebp,esp
    push eax
    push ecx
    mov eax,[ebp+12]   ; First
    mov ecx,[ebp+8]    ; Second
    xor edi,edi
    xor ebx,ebx
    Start_compare:
        cmp byte [eax+edi],0ah
        je  Check_se
        cmp BYTE [ecx+edi],0ah
        je  Check_fi
        inc edi
        jmp Start_compare
    Check_se:
        cmp byte [ecx+edi],0ah
        je  Next_compare
        jmp Ret_se
    Check_fi:
        cmp byte [eax+edi],0ah
        je  Next_compare
        jmp Ret_fi

    Ret_fi:
        mov ebx,1
        jmp End_compare
    Ret_se:
        mov ebx,2
        jmp End_compare
    Next_compare:
        xor edi,edi
    Equal_compare:
        xor edx,edx
        mov dl,byte [eax+edi]   ; first
        mov dh,byte [ecx+edi]   ; second
        cmp dl,dh
        jg  Ret_fi
        cmp dl,dh
        jl  Ret_se
        inc edi
        cmp byte [eax+edi],0ah
        je  End_compare
        jmp Equal_compare
    End_compare:
        pop ecx
        pop eax
        mov esp,ebp
        pop ebp
        ret 8

Cmp_len:
    push ebp
    mov ebp,esp
    push eax
    push ecx
    mov eax,[ebp+12]   ; First
    mov ecx,[ebp+8]    ; Second
    xor edi,edi
    xor ebx,ebx
    Start_compare_len:
        cmp byte [eax+edi],0ah
        je  Check_se_len
        cmp BYTE [ecx+edi],0ah
        je  Check_fi_len
        inc edi
        jmp Start_compare_len
    Check_se_len:
        cmp byte [ecx+edi],0ah
        je  End_compare_len
        jmp Ret_se_len
    Check_fi_len:
        cmp byte [eax+edi],0ah
        je  End_compare_len
        jmp Ret_fi_len

    Ret_fi_len:
        mov ebx,1
        jmp End_compare_len
    Ret_se_len:
        mov ebx,2
        jmp End_compare_len
    End_compare_len:
        pop ecx
        pop eax
        mov esp,ebp
        pop ebp
        ret 8

End_line:
    mov edx,1
    mov ebx,1
    mov eax,4
    int 80h
    ret

add_num:
    push ebp
    mov ebp,esp
    push eax
    push esi
    mov esi,[ebp+12]    ; sum
    mov eax,[esi]
    mov esi,[ebp+8]
    add [esi],eax
    mov ecx,eax
    pop eax
    mov esp,ebp
    pop ebp
    ret 8

Copy_int:
    push ebp
    mov ebp,esp
    push eax
    push esi
    mov esi,[ebp+12]    ; sum
    mov eax,[esi]
    mov esi,[ebp+8]
    mov [esi],eax
    mov ecx,eax
    pop eax
    mov esp,ebp
    pop ebp
    ret 8

Copy_str:
    push ebp
    mov ebp,esp
    push eax
    push ecx
    mov eax, [ebp+12]      ; source
    mov ecx, [ebp+8]       ; copy
    xor edi,edi
    Start_copy_str:
        xor edx,edx
        mov dl, Byte[eax+edi]
        mov Byte[ecx+edi], dl
        inc edi
        cmp BYTE[eax+edi],0ah
        je  End_copy_str
        jmp Start_copy_str
    End_copy_str:
        mov BYTE [ecx+edi],0ah
        pop ecx
        pop eax
        mov esp,ebp
        pop ebp
        ret 8

Add_str:
    push ebp
    mov ebp,esp
    push eax
    push ebx
    push ecx
    push esi
    push edi
    mov eax,[ebp+12]   ; High
    mov ecx,[ebp+8]    ; Low
    xor edi,edi
    xor ebx,ebx         ; ebx=mem

    ; Reverse to add
    push eax
    call Reverse
    push ecx
    call Reverse
    xor edi,edi
    xor esi,esi
    Start_add_str:
        cmp byte [edi+ecx],0ah
        je  Next_add_str
        xor edx,edx
        mov dh,byte [edi+eax]
        mov dl,byte [edi+ecx]
        inc edi
        sub dh,30h
        sub dl,30h
        add dh,dl
        add dh,bl
        cmp dh,10
        jl  Low_than_1
        jmp  Great_than_1
    
    Low_than_1:
        mov bl,0
        add dh,30h
        xor dl,dl
        push edx
        jmp Start_add_str
    Great_than_1:
        mov bl,1
        sub dh,10
        add dh,30h
        xor dl,dl
        push edx
        jmp Start_add_str

    Next_add_str:
        cmp byte[edi+eax],0ah
        je  Check_mem
        xor edx,edx
        mov dh, byte [edi+eax]
        inc edi
        sub dh,30h
        add dh,bl
        cmp dh,10
        jl  Low_than_2
        jmp Great_than_2
    Low_than_2:
        mov bl,0
        add dh,30h
        push edx
        jmp Next_add_str
    Great_than_2:
        mov bl,1
        sub dh,10
        add dh,30h
        push edx
        jmp Next_add_str
    Check_mem:
        cmp bl,0
        jz  Pop_res_tmp
        xor edx,edx
        mov dh,31h
        push edx
        inc edi
    Pop_res_tmp:
    mov ecx,[ebp+16]
    Pop_res:
        cmp edi,0
        je  End_add_str
        pop edx
		mov BYTE [esi+ecx],dh
		inc esi
		dec edi
		jmp Pop_res
    End_add_str:
        mov Byte[esi+ecx],0ah
        pop edi
        pop esi
        pop ecx
        pop ebx
        pop eax
        mov esp,ebp
        pop ebp
        ret 12
