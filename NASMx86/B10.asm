%include 'Funcs.asm'

section .data
Odd_num dd 0
Enven_num dd 0
num dd 0
sum dd 0
endl db 0ah,0

section .bss
arr resb 100
count resd 1
temp resb 100


section .text
global _start

_start:
    push 30
    push arr
    call ReadCS

    push count
    push arr
    call Atoi
    xor ecx,ecx
    xor ebx,ebx
    Begin_arr:
        cmp byte[count],0
        je  End_arr
        dec BYTE [count]
        xor eax,eax
        push 100
        push arr
        call ReadCS

        push num
        push arr
        call Atoi

        push num
        push sum
        call Copy_int
        
        mov eax,ecx
        mov esi,2
        div esi
        cmp dl,1
        je  Push_odd
        jmp Push_even
    
    Push_odd:
        push sum
        push Odd_num
        call add_num
        jmp Begin_arr
    
    Push_even:
        push sum
        push Enven_num
        call add_num
        jmp Begin_arr
    End_arr:
        push Enven_num
        push temp
        call Itoa

        push temp
        call WriteCS

        mov ecx,endl 
        call End_line

        push Odd_num
        push temp
        call Itoa

        push temp
        call WriteCS

        call Exit
