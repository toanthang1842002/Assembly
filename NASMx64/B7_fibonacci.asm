%include 'Functions.asm'

section .data
endl db 0ah,0
count dd 0

Fibo0 db "0",0ah
Fibo1 db "1",0ah
msg1 db "Input: ",0ah,0

msg3 db "The number of occurrences: ",0ah,0
msg4 db "Position: ",0ah,0
section .bss
    number resb 100
    str2 resb 100
    res resb  100
    res_times resb 100
    arr resb 100
    fi0 resb 100
    fi1 resb 100
    fi2 resb 100
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
    mov rsi,number
    call readCS

    mov rdi,number
    call Atoi

    mov r12,rax

    call Prepare
   
;=============================================================
    cmp al,0
    je Zero
    xor rsi,rsi
    xor r13,r13
    Start_fibo: 
        cmp r13,0
        je First
        cmp r12,r13
        je End_fibo

        mov rcx,fi1
        mov rdx,fi0
        mov r8,fi2
        call Addition

        mov rcx,fi1  
        call Reverse

        ; Print FIbo
        mov rcx,fi2
        call strlen
        mov rsi,fi2
        call writeCS
        call PrintLF

        ; Copy FIbo1 to FIbo0
        mov rcx,fi1
        mov rdx,fi0
        call Copy

        mov rcx,fi2
        mov rdx,fi1
        call Copy

        inc r13
        jmp Start_fibo
    First: 
        mov rsi,Fibo1
        mov rdx,2
        call writeCS

        inc r13
        jmp Start_fibo
    Zero:
        mov rsi,Fibo0
        mov rdx,2
        call writeCS
    End_fibo:
        call Exit

Prepare: 
    push rbp
    mov rbp,rsp
    mov rcx,Fibo0
    mov rdx,Fibo0
    mov r8,fi0 
    call Addition

    mov rcx,Fibo1
    mov rdx,Fibo0
    mov r8,fi1
    call Addition

    leave 
    ret

PrintLF:
    push rbp
    mov rbp,rsp

    mov rsi,endl
    mov rdx,2
    call writeCS

    leave
    ret