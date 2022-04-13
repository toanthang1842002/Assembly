%include 'Functions.asm'

section .data
    msg db 'Hello World',0ah

section .text

global _start:
_start:
    mov rdx,12
    mov rsi,msg  
    call writeCS

    call Exit