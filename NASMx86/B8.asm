%include 'Funcs.asm'

section .data
mem dd 0
section .bss
    num1 resb 100
    num2 resb 100
    res resb 100
section .text
global _start

_start:
    push 100
    push num1
    call ReadCS

    push 100
    push num2
    call ReadCS

    push num1
    push num2
    call Cmp_len

    cmp ebx,2
    je Begin_2

    Begin_1:
        push res
        push num1
        push num2
        call Add_str
        jmp Finish_b8
    Begin_2:
        push res
        push num2
        push num1
        call Add_str
        jmp Finish_b8
    Finish_b8:
        push res
        call WriteCS

        call Exit

