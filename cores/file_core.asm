# .include "core.asm"

.macro open
    syscall 1024
.end_macro

.macro close
    syscall 57
.end_macro

.macro closer %r
    mv a0, %r
    close
.end_macro

.macro lseek
    syscall 62
.end_macro

# s -- secure
.macro slseek
    lseek
    beqi a0, -1, .err_slseek
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

.macro read
    syscall 63
.end_macro

.macro write
    syscall 64
.end_macro

.macro sbrk
    syscall 9
.end_macro

.macro sbrki %n
    li a0, %n
    sbrk
.end_macro

.macro sbrkr %r
    mv a0, %r
    sbrk
.end_macro


# input:  a0 -- file name; a1 -- flag
# flags:  0 -- read-only; 1 -- write-only; 9 -- write-append
# output: a0 -- file descriptor
fopen:
    open
    beqi a0, -1, .err_fopen
    ret


# input:  a0 -- descriptor; 
# output: a0 -- size file;
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


# input: a0 -- descriptor; a1 -- address memory(buffer); a2 -- size buffer;
fread:
    read
    beqi a0, -1, .err_fread
    ret


# input:  a0 -- descriptor;
# output: a0 -- address memory; 
fload:
    push2 ra, s0
    push2 s1, s2
    
    mv s0, a0  # save descriptor
    call flength
    mv s1, a0  # save size file 
    addi a0, a0, 1
    
    sbrk
    mv s2, a0
    
    mv a1, a0
    mv a0, s0
    mv a2, s1
    call fread
    
    add t0, s2, s1
    li  t1, '\0'
    sb  t1, 0(t0)
    
    mv a0, s2
    pop2 s1, s2
    pop2 ra, s0
    ret



.err_fread:
    error "error fread!"
.err_slseek:
    error "error slseek!"
.err_fopen:
    error "the file could not be opened!"
    
