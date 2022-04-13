%include 'Functions.asm'
section .data
endl db 0ah,0
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
    call Uppercase

    mov rcx,msg
    call strlen

    mov rsi,msg
    call writeCS

    mov rsi,endl
    mov rdx,2
    call writeCS
    
    call Exit