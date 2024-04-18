.include "core.asm"


.macro open
	syscall 1024
.end_macro

.macro close
	syscall 57
.end_macro

.macro closer %r
	mv a0, %r
	syscall 57
.end_macro

.macro lseek
	syscall 62
.end_macro

# s -- secure
.macro slseek
	lseek
	bltz a0, .err_slseek
.end_macro

.macro slseekii %n1, %n2
	li a1, %n1
	li a2, %n2
	slseek
.end_macro

.macro slseekrr %r1, %r2
	mv a1, %r1
	mv a2, %r2
	slseek
.end_macro


# a0 -- file name; a1 -- flag
# 0 -- read-only; 1 -- write-only; 9 -- write-append
fopen:
	open
	bltz a0, .err_fopen
	ret

flength:
	push2 s0, s1
	mv s0, a0
	
	slseekii 0, 2
	mv s1, a0
	
	mv a0, s0
	slseekii 0, 0
	
	mv a0, s1
	pop2 s0, s1
	ret
	
	
.err_slseek:
	error "error slseek!"
.err_fopen:
	error "the file could not be opened!"
	