%include 'Functions.asm'

section .data
endl db 0ah,0
count dd 0
max dd 0h 
min dd 0FFFFFFFFh

Fibo0 db "0",0ah
Fibo1 db "1",0ah
msg1 db "Input: ",0ah,0

msg2 db "The number of array: ",0ah,0
msg3 db "MIN : ",0ah,0
msg4 db "MAX : ",0ah,0
section .bss
    number resb 100
    str2 resb 100
    res resb  100
    res_times resb 100
    arr resb 100
    ch_min resb 100
    ch_max resb 100
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

    mov rdi,ch_min
    mov rax,min 
    call Itoa

    mov rdi,ch_max
    mov rax,max
    call Itoa

   
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

        mov rcx,ch_min
        call strlen

        mov rsi,ch_min
        call writeCS
        call PrintLF
;==============================================
        mov rcx,msg4
        call strlen

        mov rsi,msg4
        call writeCS
        mov rcx,ch_max
        call strlen

        mov rsi,ch_max
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
        mov rdi,res 
        call Itoa
        dec r12

    cmp_min:
        mov rax, res 
        mov rbx, ch_min
        call strcmp
        
        cmp r8, 2
        je Lower
    cmp_max:
        mov rax,res 
        mov rbx, ch_max
        call strcmp

        cmp r8, 1  
        je Higher
        jmp Check_split

    Lower:
        mov rdi,rcx
        mov rcx,res 
        mov rdx,ch_min
        call Copy
        jmp cmp_max

    Higher:
        mov rdi,rcx
        mov rcx,res 
        mov rdx,ch_max
        call Copy
    Check_split:
        cmp r12,0
        je End_split
        xor rax,rax
        mov rcx,[rbp-8]
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