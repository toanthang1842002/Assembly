%include 'Funcs.asm'

section .data
msg1  db "So lan xuat hien: ",0ah
msg2  db "Vi tri xuat hien: ",0ah
count dd 0
time  dd 0
endl  db 0ah,0
num dd 0
section .bss
str1 resb 100
str2 resb 100
pos  resb 10
res  resb 10
res_time resb 10
section .text
global _start

_start:
    push 100
    push str1
    call ReadCS

    push 100
    push str2
    call ReadCS


    push str1
    push str2
    call Find_char

    mov esi,ebx
    push num
    push res_time
    call Itoa

    push msg1
    call WriteCS
    push res_time
    call WriteCS

    mov ecx,endl  
    call End_line

    mov ebx,esi
    push pos
    call Temp_pos

    push msg2
    call WriteCS
    push pos
    call WriteCS

    call Exit
Find_char:
    push ebp
    mov ebp,esp
    push eax
    push ecx
    push esi
    mov eax, [ebp+12]   ;str1
    mov ecx, [ebp+8]    ;str2
    xor esi,esi

    Start_find_char:
        cmp byte [eax+esi],0ah
        je  Finish_find_char
        xor edx,edx
        xor edi,edi
        mov dh,byte [eax+esi]
        mov dl,byte [ecx]
        cmp dh,dl
        je  Next_find_char
        inc esi
        jmp Start_find_char
    Next_find_char:
        xor edx,edx
        mov dh,byte [eax+esi]
        mov dl,byte [ecx+edi]
        cmp dh,dl
        jne Temp_find
        inc edi
        inc esi
        cmp byte [ecx+edi],0ah
        je  Push_site
        jmp Next_find_char
    Temp_find:
        sub esi,edi
        inc esi
        jmp Start_find_char
    Push_site:
        sub esi,edi
        mov edx,esi
        push pos
        call I_to_ascii

        inc byte[num]
        inc esi
        jmp Start_find_char
    Finish_find_char:
        pop esi
        pop ecx
        pop eax
        mov esp,ebp
        pop ebp
        ret 8

I_to_ascii:
    push ebp
    mov ebp,esp
    push eax
    push ecx
    push edi
    push esi
    mov ecx,[ebp+8]
    mov eax,edx
    xor edi,edi
    mov esi,10
    Divide_5:
        xor edx,edx
        div esi
        add dl,30h
        push edx
        inc edi
        cmp eax,0
        je  Pop_5
        jmp Divide_5
    Pop_5:
        pop edx
        mov byte [ecx+ebx],dl
        inc ebx
        dec edi
        cmp edi,0
        jz  End_5
        jmp Pop_5
    End_5:
        mov byte [ebx+ecx],20h
        inc ebx
        pop esi
        pop edi
        pop ecx
        pop eax
        mov esp,ebp
        pop ebp
        ret 4

Temp_pos:
    push ebp
    mov ebp,esp
    push eax
    mov eax,[ebp+8]
    mov byte [eax+ebx] , 0ah
    pop eax
    mov esp,ebp
    pop ebp
    ret 4