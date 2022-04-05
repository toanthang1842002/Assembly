%include 'Funcs.asm'

section .bss
string resb 32

section .text
global _start

_start:
    push 32
    push string
    call ReadCS

    push string
    call WriteCS

    call Exit