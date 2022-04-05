%include 'Funcs.asm'

section .bss
input resb 32

section .text
global _start

_start:
    push 32
    push input
    call ReadCS

    push input
    call Reverse

    push input
    call WriteCS

    call Exit