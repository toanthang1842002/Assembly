%include 'Functions.asm'

section .data
endl db 0ah,0
count dd 0
max dd 0h 
min dd 0FFFFFFFFh

Fibo0 db "0",0ah
Fibo1 db "1",0ah
msg1 db "Input: ",0ah,0
zero db "0",0ah

msg2 db "The number of array: ",0ah,0
msg3 db "Sum of Odd number : ",0ah,0
msg4 db "Sum of Even number : ",0ah,0
section .bss
    number resb 100
    str2 resb 100
    res resb  100
    res_times resb 100
    arr resb 100
    SumOdd resb 1000  
    SumEven resb 1000  
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

    mov rcx,msg2
    call strlen

    mov rsi,msg2
    call writeCS

    mov rdi,number
    call Atoi

    mov r12,rax                   ; r12 = number of array

    mov rcx,zero ;
    mov rdx,zero ; 
    mov r8,SumOdd
    call Addition

    mov rcx,zero ;
    mov rdx,zero ; 
    mov r8,SumEven
    call Addition

   
;=============================================================
    Start_array: 
        mov rdx,100
        mov rsi,arr
        call readCS

        mov rcx,arr 
        call Split_str


        cmp r12,0
        je End_array
        jmp Start_array
    
    End_array:
        mov rcx,msg3
        call strlen

        mov rsi,msg3
        call writeCS

        mov rcx,SumOdd
        call strlen

        mov rsi,SumOdd
        call writeCS
        call PrintLF
;==============================================
        mov rcx,msg4
        call strlen

        mov rsi,msg4
        call writeCS
        mov rcx,SumEven
        call strlen

        mov rsi,SumEven
        call writeCS

        call PrintLF

        call Exit


Split_str:
    push rbp
    mov rbp,rsp
    sub rsp,32
    push rsi
    push rdi
    push rax
    push rbx
    push rdx
    mov [rbp-8],rcx
    xor rsi,rsi 
    xor rdi,rdi
    xor rax,rax
    mov rbx,10
    check_space:
		cmp byte [rcx+rsi],0ah
		je End_split
		cmp byte [rcx+rsi],20h
		jne  Start_split
		inc rsi
		jmp check_space
    Start_split:
        cmp byte[rcx+rsi],0ah
        je change_str
        cmp byte[rcx+rsi],20h
        je change_str
        xor rdx,rdx
        mov dl, byte [rcx+rsi]
        sub dl,30h
        add rax,rdx
        mul rbx
        inc rsi
        jmp Start_split

    change_str:
        div rbx
        mov r10,rax
        mov rdi,res 
        call Itoa
        dec r12

        mov rax,r10
        mov r8,2 
        xor rdx,rdx
        div r8
        cmp dl,0 
        je Even_num
        jmp Odd_num

    Even_num:
        mov rcx,res
        mov rdx,SumEven
        mov r8,SumEven
        call Addition
        jmp Check_split
    Odd_num:
        mov rcx,res
        mov rdx,SumOdd
        mov r8,SumOdd
        call Addition
        jmp Check_split

    Check_split:
        cmp r12,0 
        je End_split
        mov rcx,[rbp-8]
        xor rax,rax
    Next_check_split:
        inc rsi
        cmp byte [rcx+rsi],0ah
        je End_split
        cmp byte [rcx+rsi],20h
        je Next_check_split
        jmp Start_split
    End_split:
        pop rdx
        pop rbx
        pop rax
        pop rdi
        pop rsi
        add rsp,32
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