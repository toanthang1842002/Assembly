%include 'Functions.asm'

section .data
endl db 0ah,0
count dd 0

msg1 db "string 1: ",0ah,0
msg2 db "string 2: ",0ah,0
msg3 db "The number of occurrences: ",0ah,0
msg4 db "Position: ",0ah,0
section .bss
    str1 resb 100
    str2 resb 100
    res resb  100
    res_times resb 100
section .text

global _start:
_start:
    mov rbp,rsp
;==================================
    mov rcx,msg1
    call strlen

    mov rsi,msg1
    call writeCS

    mov rdx,100
    mov rsi,str1
    call readCS

    mov rcx,msg2
    call strlen

    mov rsi,msg2
    call writeCS

    mov rdx,100
    mov rsi,str2
    call readCS
;=============================================================
    mov rcx,str1
    mov rdx,str2
    mov r8, res
    mov r9, res_times
    call Substring

    mov rcx,msg3
    call strlen

    mov rsi,msg3
    call writeCS

    mov rax,rbx
    mov rdi,res  
    call Itoa

    mov rcx,res
    call strlen

    mov rsi,res
    call writeCS

    mov rsi,endl
    mov rdx,2
    call writeCS

    mov rcx,msg4
    call strlen

    mov rsi,msg4
    call writeCS

    mov rcx,res_times
    call strlen

    mov rsi,res_times
    call writeCS

    mov rsi,endl
    mov rdx,2
    call writeCS

    call Exit