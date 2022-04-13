%include 'Functions.asm'

section .bss
    msg resb 100

section .text

global _start:
_start:
    mov rbp,rsp

    mov rdx,100
    mov rsi,msg
    call readCS

    mov rcx,msg
    call strlen

    mov rsi,msg
    call writeCS
    
    call Exit