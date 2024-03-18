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

.macro readch
    syscall 12
.end_macro

.macro newstr # Print char \n. Using s1 and a0 registers.
    push a0
    li a0, '\n'
    printch
    pop a0
.end_macro

.macro error %str
    .data
        str: .asciz %str
    .text
        newstr
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

.macro swap %r1, %r2
    xor %r1, %r1, %r2
    xor %r2, %r2, %r1
    xor %r1, %r1, %r2
.end_macro

## checking a character in a given range. r1 -- output(bool); r2 -- input;
.macro check %r1, %r2, %start, %end
    andi %r1, %r2, 0xff
    addi %r1, %r1, -%start
    sltiu %r1, %r1, %end
.end_macro

## r1 <== (r3 << offset) + (r2 - start + value); the values of registers r2 and r3 do not change.
.macro append %r1, %r2, %r3, %start, %value, %offset
        push  %r3

        addi  %r1, %r2, -%start
        addi  %r1, %r1, %value
        slli  %r3, %r3, %offset
        add   %r1, %r3, %r1

        pop   %r3
.end_macro


.text
.main:
    push s0

    call ReadHex
    mv s0, a0
    call ReadHex

    mv a1, a0
    mv a0, s0
    call Div
    call PrintHex

    pop s0
    exit 0


ReadHex:
    push2 ra, s0
    push2 s1, s2
    push2 s3, s4

    li s0, 8  # counter (8 digits + 1 '\n')
    li s1, '\n'
    li s4, 0  # result

    .while_read:
        readch
        beq a0, s1, .break
        beq s0, zero, .error_limit

        check s2, a0, '0', 10
        bnez s2, .digit

        check s2, a0, 'A', 6
        bnez s2, .big_char

        check s2, a0, 'a', 6
        beqz s2, .error_char

        append s2, a0, s4, 'a', 10, 4
        j .skip

        .big_char:
            append s2, a0, s4, 'A', 10, 4
        j .skip

        .digit:
            append s2, a0, s4, '0', 0, 4

        .skip:
        mv s4, s2
        addi s0, s0, -1
        bgez s0, .while_read

    .break:
        mv a0, s4
        pop2 s3, s4
        pop2 s1, s2
        pop2 ra, s0
        ret
    .error_limit:
        error "error: limit characters!"
    .error_char:
        error "error: the entered character is not a 16-digit number!"


OperHex:
    push2 s0, ra
    mv s0, a0

    readch
    check t0, a0, '+', 1
    bnez t0, .summa

    check t0, a0, '-', 1
    bnez t0, .difference

    check t0, a0, '&', 1
    bnez t0, .bitAND

    check t0, a0, '|', 1
    bnez t0, .error_oper

    .bitOR:
        or a0, s0, a1
        j .tail

    .bitAND:
        and a0, s0, a1
        j .tail

    .difference:
        sub a0, s0, a1
        j .tail

    .summa:
        add a0, s0, a1

    .tail:
        pop2, s0, ra
        ret
    .error_oper:
        error "the entered character is not from this set -- {+, -, &, |}!"


PrintHex:
    beqz a0, .printZeroHex
    mv a1, a0
    newstr

    push2  ra, s0
    push2 s1, s2

    li s0, 32            # counter
    li s1, 0xf0000000   # mask

    .cycle:  # clipping non-essential zeros
        srli s1, s1,  4
        addi s0, s0, -4
        and  s2, a1, s1
        beqz s2, .cycle

    .while_print_hex:
        addi s0, s0, -4
        and  s2, a1, s1
        srl  s2, s2, s0
        srli s1, s1,  4

        check t0, s2, 0, 10
        bnez  t0, .pr_digit

        check t0, s2, 0, 16

        .pr_char:
            addi  a0, s2, 87  # 87 == 'a' - 10
            j .pr

        .pr_digit:
            addi a0, s2, '0'

        .pr:
            printch
        bnez s0, .while_print_hex

    pop2 s1, s2
    pop2 ra, s0
    ret
    .printZeroHex:
        li a0, '0'
        printch
        ret


Div:
    push2 ra, s0
    push2 s1, s2
    push2 s3, s4

    li s0,  0 # counter
    li s1, 32 # lim counter
    li s4, 0  # result

    .while_s0:
        andi s2, a1, 1
        beqz s2, .skip_div
        sll  s3, a0, s0
        add  s4, s4, s3

        .skip_div:
            srli a1, a1, 1
            addi s0, s0, 1
            blt  s0, s1, .while_s0

    mv a0, s4
    pop2 s3, s4
    pop2 s1, s2
    pop2 ra, s0
    ret
