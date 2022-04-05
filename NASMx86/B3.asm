%include 'Funcs.asm'
section .bss
input resb 32
mem resd 0
section .text
global _start
_start:
	push 32
	push input
	call ReadCS

	push input
	call uppercase

	push input
	call WriteCS

	call Exit