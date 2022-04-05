%include 'Funcs.asm'

section .data
max dd 0h 
min dd 0FFFFFFFFh
endl db 0ah,0

section .bss
str_max resb 100
str_min resb 100
arr resb 100
count resd 1


section .text
global _start

_start:
    push 100
    push arr
    call ReadCS

    push count
    push arr
    call Atoi

    Prepare:
        cmp byte[count],0
        jz  End_cmp
        dec byte [count]

        push 100
        push arr
        call ReadCS

        push min
        push str_min
        call Itoa

        push max
        push str_max
        call Itoa
        
    cmp_min:
        push arr
        push str_min
        call Compare_high

        cmp ebx,2
        je Low_than
    cmp_max:
        push arr
        push str_max
        call Compare_high

        cmp ebx,1
        je  Great_than
        jmp Prepare
    
    Low_than:
        push min
        push arr
        call Atoi
        jmp cmp_max
    Great_than:
        push max
        push arr
        call Atoi
        jmp Prepare

    End_cmp:
        push min
        push str_min
        call Itoa

        push max
        push str_max
        call Itoa

        push str_max
        call WriteCS

        mov ecx,endl
        call End_line

        push str_min
        call WriteCS

        call Exit

        
    
        