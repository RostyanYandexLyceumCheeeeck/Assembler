.macro syscall %n
    li a7, %n # a7 holds syscall number
    ecall
.end_macro

.macro exit %ecode
    li a0, %ecode
    syscall 93
.end_macro

.macro error %str
	.data
		str: .asciz %str
	.text
		call newstr
    	la a0, str
    	syscall 4 # PrintString
    	exit 1
.end_macro

.macro push %r
    addi sp, sp, -4
    sw %r, 0(sp)
.end_macro

.macro pop %r
    lw %r, 0(sp)
    addi sp, sp, 4
.end_macro

.macro push2 %r1, %r2
    addi sp, sp, -8
    sw %r1, 0(sp)
    sw %r2, 4(sp)
.end_macro

.macro pop2 %r1, %r2
    lw %r1, 0(sp)
    lw %r2, 4(sp)
    addi sp, sp, 8
.end_macro

.macro printch 
    syscall 11
.end_macro

.macro readch
    syscall 12
.end_macro

.macro check_start %n %p
	push ra
	li a1, %n
	li a2, %p
	call check
	pop ra
.end_macro

.macro body_start %d %p %k
	push ra
	li a1, %d
	li a2, %p
	li a3, %k
	call body
	pop ra
.end_macro

.macro one
	push a0
    check_start '+', 1
    beq a0, zero, .end

    add t0, t5, t6
    .end:
       pop a0
.end_macro

.macro two
	push a0
    check_start '-', 1
    beq a0, zero, .end
    sub t0, t5, t6
    .end:
       pop a0
.end_macro

.macro three
	push a0
    check_start '&', 1
    beq a0, zero, .end
    and t0, t5, t6
    .end:
       pop a0
.end_macro

.macro four
	push a0
    check_start '|', 1
    beq a0, zero, .end
    or t0, t5, t6
    .end:
       pop a0
.end_macro

  
.text
main:
   call scan
   mv t5, a0
   call scan
   mv t6, a0
   readch
   
   one    # check +
   two    # check -
   three  # check &
   four   # check |
   
   mv a0, t0
   call write
   exit 0

  
newstr: # Print char \n. Using s1 and a0 registers.
	push s1
    mv s1, a0
    li a0, '\n'
    printch
    mv a0, s1
    pop s1
    ret


check: # %n %p
    andi a0, a0, 0xff
    sub a0, a0, a1
    sltu a0, a0, a2
	ret


body: # %n %p %k %res
	push2 ra, s1
	mv s1, a0
    call check # %n, %p
    beq a0, zero, .end
    
    sub a0, s1, a1
    add a0, a0, a3
    slli a4, a4, 4
    add a0, a4, a0
    mv a4, a0
    mv s1, a0
    
    .end:
    	mv a0, s1
        pop2 ra, s1
        ret


scan:
	push2 a4, s1
	push2 s2, s3
    li a4, 268435456 # result
    li s1, 8  # counter
    li s2, '\n'
    readch
    beq a0, s2, .err3
    
    .start:
		mv s3, a4
       	body_start '0', 10, 0
       	body_start 'A', 6, 10
       	body_start 'a', 6, 10

       	beq a4, s3, .err1
       	beq s1, zero, .err2
       	addi s1, s1, -1
        readch
        bne a0, s2, .start
    
    mv a0, a4    
    pop2 s2, s3
    pop2 a4, s1
    ret
    .err1:
    	error "error: the entered character is not included in the 16-bit system!"
	.err2:
		error "error: limit characters!"
	.err3:
		error "error: empty input!"

  
write:
	push ra
	push2 s1, s2
    call newstr
    
    mv s1, a0
    li s2, 8 # counter
    beq s1, zero, .end_func

    .prep:
       srli a0, s1, 28
       addi s2, s2, -1
       slli s1, s1, 4
       beq a0, zero, .prep  
    
    .start_while:
       li a4, 0
       body_start 0, 10, '0'
       body_start 0, 16, 55 # 'A'-10
       printch
       srli a0, s1, 28
       addi s2, s2, -1
       slli s1, s1, 4
       bge s2, zero, .start_while
    
    pop2 s1, s2
    pop ra
    ret
    
    .end_func:
    	li a0, '0'
        printch
        pop2 s1, s2
        pop ra
		ret

