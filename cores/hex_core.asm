.include "core.asm"

## r1 <== (r3 << offset) + (r2 - start + value); the values of registers r2 and r3 do not change.
.macro append %r1, %r2, %r3, %start, %value, %offset
        push  %r3

        addi  %r1, %r2, -%start
        addi  %r1, %r1, %value
        slli  %r3, %r3, %offset
        add   %r1, %r3, %r1

        pop   %r3
.end_macro

.macro MultiHexrr %r1, %r2
    mv a0, %r1
    mv a1, %r1
    call MultiHex
.end_macro

.macro MultiHexsrr %rs, %r1, %r2  # r -- register. s -- save. rs == register saved.
    Multihexrr %r1, %r2
    mv %rs, a0
.end_macro

.macro MultiHexri %r1, %n
    mv a0, %r1
    li a1, %n
    call MultiHex
.end_macro

.macro MultiHexsri %rs, %r1, %n
    MultiHexri %r1, %n
    mv %rs, a0
.end_macro



getDigit:
    check t0, a0, '0', 10
    beqz t0, .err_digit

    addi a0, a0, -48  # -'0'
    ret
    .err_digit:
        error "error: the entered character is not a digit!"


ReadHex:
    push2 ra, s0
    push2 s1, s2
    push2 s3, s4

    li s0, 8  # counter (8 digits + 1 '\n')
    li s1, '\n'
    li s4, 0  # result

    .while_ReadHex:
        readch
        beq a0, s1, .break_ReadHex
        beq s0, zero, .error_limit

        check s2, a0, '0', 10
        bnez s2, .digit_Hex

        check s2, a0, 'A', 6
        bnez s2, .big_char

        check s2, a0, 'a', 6
        beqz s2, .error_char_Hex

        append s2, a0, s4, 'a', 10, 4
        j .skip

        .big_char:
            append s2, a0, s4, 'A', 10, 4
        j .skip

        .digit_Hex:
            append s2, a0, s4, '0', 0, 4

        .skip:
        mv s4, s2
        addi s0, s0, -1
        bgez s0, .while_ReadHex

    .break_ReadHex:
        mv a0, s4
        pop2 s3, s4
        pop2 s1, s2
        pop2 ra, s0
        ret
    .error_limit:
        error "error: limit characters!"
    .error_char_Hex:
        error "error: the entered character is not a 16-digit number!"


# fn -- first number; sn -- second number
# input: a0 -- fn; a1 -- sn; a2 -- char operation
# output: a0 -- result
OperHex:
    push ra

    beqi a2, '+', .summa
    beqi a2, '-', .difference
    beqi a2, '&', .bitAND
    bnei a2, '|', .error_OperHex

    .bitOR:
        or a0, a0, a1
        j .tail_OperHex

    .bitAND:
        and a0, a0, a1
        j .tail_OperHex

    .difference:
        sub a0, a0, a1
        j .tail_OperHex

    .summa:
        add a0, a0, a1

    .tail_OperHex:
        pop ra
        ret
    .error_OperHex:
        error "the entered character is not from this set -- {+, -, &, |}!"


PrintHex:
    beqz a0, .printZeroHex
    mv a1, a0

    push2  ra, s0
    push2 s1, s2

    li s0, 32            # counter
    li s1, 0xf0000000    # mask

    and s2, a1, s1
    bnez s2, .while_print_hex

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
        printchi '0'
        ret


MultiHex:
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
