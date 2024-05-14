.eqv tr, t6  # temp register


.macro syscall %n
    li a7, %n # a7 holds syscall number
    ecall
.end_macro

.macro exit %ecode
    li a0, %ecode
    syscall 93
.end_macro

.macro printch
    syscall 11
.end_macro

.macro printchi %c
    li a0, %c
    printch
.end_macro

.macro printchis %c  # s - save a0.
    push a0
    printchi %c
    pop  a0
.end_macro

.macro printchr %r
    mv a0, %r
    printch
.end_macro

.macro printchrs %r  # s - save a0.
    push a0
    printchr %r
    pop a0
.end_macro

.macro readch
    syscall 12
.end_macro

.macro printint
    syscall 1
.end_macro

.macro printinti %n
    li a0, %n
    printint
.end_macro

.macro printintr %r
    mv a0, %r
    printint
.end_macro

.macro printintis %n
    push a0
    printinti %n
    pop  a0
.end_macro

.macro printintrs %r
    push a0
    printintr %r
    pop  a0
.end_macro


.macro newstr # Print char \n. Using a0 register and stack.
    printchis '\n'
.end_macro

.macro printstr
    syscall 4
.end_macro

.macro error %str
    .data
        str: .asciz %str
    .text
        newstr
        la a0, str
        printstr # PrintString
        exit 1
.end_macro

.macro push %r
    addi sp, sp, -4
    sw   %r, 0(sp)
.end_macro

.macro pop %r
    lw   %r, 0(sp)
    addi sp, sp, 4
.end_macro

.macro push2 %r1, %r2
    addi sp, sp, -8
    sw   %r1, 0(sp)
    sw   %r2, 4(sp)
.end_macro

.macro pop2 %r1, %r2
    lw   %r1, 0(sp)
    lw   %r2, 4(sp)
    addi sp, sp, 8
.end_macro

.macro swap %r1, %r2
    xor  %r1, %r1, %r2
    xor  %r2, %r2, %r1
    xor  %r1, %r1, %r2
.end_macro

.macro beqi %r, %n, %label
    li   tr, %n
    beq  %r, tr, %label
.end_macro

.macro bnei %r, %n, %label
    li   tr, %n
    bne  %r, tr,  %label
.end_macro

.macro bgei %r, %n, %label
    li   tr, %n
    bge  %r, tr, %label
.end_macro

.macro bgeui %r, %n, %label
    li   tr, %n
    bgeu %r, tr, %label
.end_macro

.macro blti %r, %n, %label
    li   tr, %n
    blt  %r, tr, %label
.end_macro

.macro bltui %r, %n, %label
    li   tr, %n
    bltu %r, tr, %label
.end_macro

.macro blei %r, %n, %label
    li   tr, %n
    ble  %r, tr, %label
.end_macro

.macro bleui %r, %n, %label
    li   tr, %n
    bleu %r, tr, %label
.end_macro

## checking a character in a given range. rd -- output(bool); r1 -- input;
.macro check %rd, %r1, %start, %len
    andi %rd, %r1, 0xff
    addi %rd, %rd, -%start
    sltiu %rd, %rd, %len
.end_macro

.macro min %rd, %r1, %r2
    mv   tr,  %r2
    mv   %rd, %r1
    blt  %rd, tr, .end_min
    mv   %rd, %r2
    .end_min:
.end_macro

.macro max %rd, %r1, %r2
    mv  tr,  %r2
    mv  %rd, %r1
    bge %rd, tr, .end_max
    mv  %rd, %r2
    .end_max:
.end_macro
