%include 'Funcs.asm'
section .bss
input_num1 resb 32
input_num2 resb 32
res resb 32
num1 resd 1
num2 resd 1
section .text
global _start

_start:
    push 32
    push input_num1
    call ReadCS

    push 32
    push input_num2
    call ReadCS

    push num1
    push input_num1
    call Atoi

    push num2
    push input_num2
    call Atoi

    push res
    push num1
    push num2
    call Print_res

    push res
    call WriteCS

    call Exit