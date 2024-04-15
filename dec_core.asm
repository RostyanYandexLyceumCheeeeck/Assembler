.include "hex_core.asm"
# fn -- first number; sn -- second number


# input: a0 -- fn
# output: a0 -- result == fn/10
Div10:
    push2 ra, s0
    push2 s1, s2
    li s2, 0
    
    bgez a0, .skip_Div10
    li s2, 1
    neg a0, a0
    # if -2^31
    bnei a0, 0x80000000, .skip_Div10
    li a0, -214748364
    j .pops_Div10
    
    .skip_Div10:
    blti a0, 10, .retZero
    
    mv   s1, a0     # x
    
    srli a0, a0, 2  # x/4
    srli s0, a0, 1  # x/8
    call Div10
    
    sub a0, s0, a0     # (x/8 - x/40)
    mv s0, a0
    MultiHexri a0, 10  # div(10) * 10

    swap a0, s0
    ble s0, s1, .end_Div10
    addi a0, a0, -1
    
    j .end_Div10
    .retZero:
        li a0, 0
    
    .end_Div10:
    beqz s2, .pops_Div10
    neg a0, a0
    
    .pops_Div10:
    pop2 s1, s2
    pop2 ra, s0
    ret


Mod10:
    push2 ra, s0
    mv s0, a0
    
    call Div10
    MultiHexri a0, 10
    sub a0, s0, a0
    
    pop2 ra, s0
    ret


udiv:
	push2 ra, s0
	push2 s1, s2
	mv   s0, a0  # res
	li   s1,  0  # ost
	
	beqz a1, .err_udiv
	beqi a1, 1, .end_udiv
	li   s0, 0
	beqz a0, .end_udiv
	
	mv   s1, a0
	bltu a0, a1, .end_udiv

	li   s2, 0  # count bits in a0
	.while_count_udiv:
		addi s2, s2, 1
		srli s1, s1, 1
		bnez s1, .while_count_udiv
	li t0, 32
	sub t0, t0, s2
	sll  a0, a0, t0
	
	addi t1, a1, -1
	.while_s2_udiv:
		srli t3, a0, 31  # bit sign
		slli s1, s1, 1
		add  s1, s1, t3
		
		sltu t0, t1, s1  # (a1 - 1) < ost
		slli s0, s0, 1
		add  s0, s0, t0
		
		beqz t0, .skip_udiv
		sub s1, s1, a1
		.skip_udiv:
		slli a0, a0, 1
		addi s2, s2, -1
		bnez s2, .while_s2_udiv
	
	.end_udiv:
	mv   a0, s0
	mv   a1, s1
	pop2 s1, s2
	pop2 ra, s0
	ret
	.err_udiv:
		error "ZeroDivisionError: division by zero!"


sdiv:
	push2 ra, s0
	push  s1
	
	xor s0, a0, a1
	srli s0, s0, 31  # sign res
	srli s1, a0, 31  # sign fn
	
	bgez a0, .skip_neg_fn
		neg a0, a0
	.skip_neg_fn:
	
	bgez a1, .skip_neg_sn
		neg a1, a1
	.skip_neg_sn:
	
	call udiv
	beqz s1, .skip_neg_ost
		neg a1, a1
	.skip_neg_ost:
	
	beqz s0, .end_sdiv
		neg a0, a0
	
	.end_sdiv:
	pop  s1
	pop2 ra, s0
	ret


# input: a0 -- fn; a1 -- sn; a2 -- char operation
# output: a0 -- result
OperDec:
    push ra
    
    beqi a2, '*', .multi
    beqi a2, '+', .summa_and_diff
    beqi a2, '-', .summa_and_diff
    
    error "the entered character is not from this set -- {+, -, *}!"
    
    .summa_and_diff:
        call OperHex
        j .tail_OperDec
    
    .multi:
        call MultiHex
    
    .tail_OperDec:
    pop ra
    ret


# output: a0 -- result
ReadDec:
    push2 ra, s0
    push2 s1, s2
    push2 s3, s4
    
    li s4, 0   # sign( 0: +; 1: -;)
    li s3, 10  # counter(10 digit). 2147483647 == max int.
    li s2, 0   # result
    readch
    beqi a0, '\n', .err_empty_input_Dec
    bnei a0, '-', .while_Read_Dec
    li s4, 1
    readch
    
    .while_Read_Dec:
        beqz s3, .error_limit
        
        mv s0, a0
        MultiHexsri s2, s2, 10
        mv a0, s0
        call getDigit
        add s2, s2, a0
        
        addi s3, s3, -1
        readch        
        bnei a0, '\n', .while_Read_Dec
    
    beqz s4, .end_ReadDecimal
    neg s2, s2
    
    .end_ReadDecimal:
    mv a0, s2
    pop2 s3, s4
    pop2 s1, s2
    pop2 ra, s0
    ret
    
    .err_empty_input_Dec:
           error "error: empty input!"


PrintDec:
    push2 ra, s0
    push2 s1, s2
    
    li   s1, 0  # counter
    bgez a0, .while_Print_Dec_toStack
    printchis '-'
    neg  a0, a0
    
    .while_Print_Dec_toStack:
        mv   s0, a0
        call Mod10
        push a0
        mv   a0, s0
        call Div10
        
        addi s1, s1, 1
        bnez a0, .while_Print_Dec_toStack
    
    .while_Print_Dec:
        pop a0
        addi a0, a0, '0'
        printch
        
        addi s1, s1, -1
        bnez s1, .while_Print_Dec
        
    pop2 s1, s2
    pop2 ra, s0
    ret
