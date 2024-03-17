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

.text
main:
    push s1
    call readNumBCD
    mv s1, a0
    call readNumBCD

    mv a1, a0
    mv a0, s1
    call oper

    call printBCDnumber

    pop s1
    exit 0


checkSignMinus: # return a0/a1 = 1/11 if '-' else 0/10
    li a1, 10
    check a0, a0, '-', 1
    beqz a0, .end
    li a1, 11
    .end:
        ret


getDigitBCD:
    check t0, a0, '0', 10
    beqz t0, .err_digit

    addi a0, a0, -48  # -'0'
    ret
    .err_digit:
        error "error: the entered character is not a digit!"


readNumBCD:
    push2 ra, s1
    push2 s2, s3
    push2 s4, s5
    li s2, 8     # counter (7 digit + 1 '\n')
    li s4, 0     # result
    li s5, '\n'  # end input
    readch
    beq a0, s5, .err_empty_input

    mv s1, a0
    call checkSignMinus
    mv s3, a1  # save sign
    swap s1, a0
    beqz s1, .start  # if the entered character is a digit
    readch

    .start:
        call getDigitBCD
        add s4, s4, a0
        slli s4, s4, 4
        addi s2, s2, -1
        readch
        beqz s2, .err_limit
        bne a0, s5, .start

    add s4, s4, s3
    mv a0, s4
    pop2 s4, s5
    pop2 s2, s3
    pop2 ra, s1
    ret
    .err_limit:
        error "error: limit characters!"
    .err_empty_input:
        error "error: empty input!"


oper:
    push2 ra, s1
    mv s1, a0  # save first number

    readch
    check t0, a0, '+', 1
    bnez t0, .sum

    check t0, a0, '-', 1
    xori a1, a1, 1  # changing the sign to the opposite one
    bnez t0, .sum
    error "error: the entered character is not a '+' or '-'!"

    .sum:
        mv a0, s1
        call additionBCD

    pop2 ra, s1
    ret


additionBCD: # sum(a0, a1): return a0 + a1
    push ra
    push2 s1, s2

    andi a2, a0, 15 # save sign first number
    andi a3, a1, 15  # save sign second number

    srli a0, a0, 4  # save abs(first number)
    srli a1, a1, 4  # save abs(second number)

    blt a1, a0, .L1  # abs(first number) >= abs(second number)
    swap a0, a1
    swap a2, a3

    .L1:
        beq a2, a3, .summary
        call algo_sub_bcd
        j .end_add
    .summary:
        call algo_sum_bcd
        ## 6168199
        ## 3034102
        ## 91a22a1
        ## незнаю, как написать, но приведу пример, мб понятно буит)) 91a22a1 --> 9202301
        srli a0, a0, 4
        mv a1, zero
        call algo_sum_bcd

    .end_add:
    pop2 s1, s2
    pop ra
    ret


## algorithm sum decimal numbers. fn -- first number; sn -- second number;
## input: a0 -- abs(fn); a1 -- abs(sn); a2 -- sign(fn); a3 -- sign(sn);
## output: a0 -- result
algo_sum_bcd:
    li t0, 6  # control sum
    li t1, 7  # counter
    li t2, 15 # mask
    li t5, 10  # limit digit

    .while_sum:
        and t3, a0, t2
        and t4, a1, t2
        add t3, t3, t4
        blt t3, t5, .skip_sum
        add a0, a0, t0
         .skip_sum:
             slli t0, t0, 4
             addi t1, t1, -1
             slli t2, t2, 4
            slli t5, t5, 4
            blt zero, t1, .while_sum
    add a0, a0, a1

    ## overflow [-9 999 999; 9 999 999]
    srli t3, a0, 28
    beqz t3, .end_sum
    li t3, 0x09999999
    li t4, 0x0fffffff

    and t4, a0, t4
    sub a0, t3, t4

    xori a2, a2, 1
    .end_sum:
        slli a0, a0, 4
        add a0, a0, a2
        ret


## algorithm sub decimal numbers. fn -- first number; sn -- second number;
## input: a0 -- abs(fn); a1 -- abs(sn); a2 -- sign(fn); a3 -- sign(sn);
## output: a0 -- result
algo_sub_bcd:
    li t0, -6  # control sum
    li t1, 7  # counter
    li t2, 15 # mask

    .while_sub:
        and t3, a0, t2  # digit fn
        and t4, a1, t2  # digit sn
        bge t3, t4, .skip_sub
        add a0, a0, t0
         .skip_sub:
             slli t0, t0, 4
             addi t1, t1, -1
             slli t2, t2, 4
            blt zero, t1, .while_sub

    sub a0, a0, a1

    slli a0, a0, 4
    add a0, a0, a2
    ret


printBCDnumber:
    push s0
    mv s0, a0
    newstr

    andi t5, s0, 15  # check sign

    srli s0, s0, 4
    beqz s0, .printZero
    # print sign(if '-')
    li t0, 10
    beq t5, t0, .skip_sign
    li a0, '-'
    printch

    .skip_sign:
    li t0, 0xf0000000 # mask
    li t1, 32         # counter

    .cycle:  # clipping non-essential zeros
        srli t0, t0, 4
        addi t1, t1, -4
        and a0, s0, t0
        beqz a0, .cycle

    .print_cycle:  # print BCD number
        addi t1, t1, -4
        and a0, s0, t0
        srl a0, a0, t1
        addi a0, a0, '0'
        printch
        srli t0, t0, 4
        bnez t1, .print_cycle

    j .end_print_BCD_Number
    .printZero:
        li a0, '0'
        printch
    .end_print_BCD_Number:
        pop s0
        ret
