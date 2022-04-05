%include 'Funcs.asm'

section .data
F0 db "0",0ah
F1 db "1",0ah
endl db 0ah,0
section .bss

arr resb 100
count resd 1
f0 resb 100
f1 resb 100
f2 resb 100
section .text
global _start

_start:
    push 5
    push arr
    call ReadCS

    push count
    push arr
    call Atoi

    push f1
    push F0
    push F1
    call Add_str

    push f0
    push F0
    push F0
    call Add_str
    xor esi,esi

    cmp byte [count],0
    je  Zero_fibo

    Start_fibonacci:
        cmp esi,0
        jz  First_fibo
        dec Byte[count]
        cmp BYTE [count],0
        je  End_fibonacci

        push f2
        push f1
        push f0
        call Add_str

        push f2
	    call WriteCS

	    mov ecx,endl
        call End_line

        push f1 
        call Reverse

        push f1
        push f0
        call Copy_str

        push f2
        push f1
        call Copy_str

        jmp Start_fibonacci

    Zero_fibo:
        push f0
        call WriteCS

	    mov ecx,endl
        call End_line
        jmp End_fibonacci
    First_fibo:
        push f1
        call WriteCS

	    mov ecx,endl
        call End_line
        inc esi
        jmp Start_fibonacci

    End_fibonacci:
        call Exit

