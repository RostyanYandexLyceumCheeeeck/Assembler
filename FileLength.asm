.include "./cores/file_core.asm"


.globl main
main:
	bnei a0, 1, .err_main
	lw a0, 0(a1)
	printstr
	newstr
	
	li a1, 0
	call fopen
	
	mv s0, a0
	call flength
	printint
	newstr
	
	closer s0
	exit 0
	.err_main:
		error "error: incorrect number of arguments!"
