# .include "core.asm"
# .include "hex_core.asm"


# input:  a0 -- address memory(str); a1 -- sumbol
strchr:
    .while_strchr:
        lb t0, 0(a0)
        beqi t0, '\0', .break_strchr
        addi a0, a0, 1
        bne a1, t0, .while_strchr
    .break_strchr:
    addi a0, a0, -1
    beq t0, a1, .end_strchr
    li   a0, 0
    
    .end_strchr:
        ret


# input:  a0 -- address str; a1 -- address search substring;
# output: a0 -- address beginning a1 in a0
strstr:
    push2 s0, s1
    
    beqz a1, .end_strstr
    lb   t0, 0(a1)
    beqz t0, .end_strstr
    lb   t0, 0(a0)
    beqz t0, .bad_end_strstr
    
    mv   s0, a0
    mv   s1, a1
    
    .loop_strstr:
        lb   t0, 0(s0)
        lb   t1, 0(s1)
        beqz t1, .end_strstr
        beq  t0, t1, .continue_strstr
        
        mv   a0, s0
        mv   s1, a1
        lb   t1, 0(s1)
        beq  t0, t1, .loop_strstr
        li   a0, 0
        
        .continue_strstr:
        addi s0, s0, 1
        addi s1, s1, 1
        bnez t0, .loop_strstr
    
    .bad_end_strstr:
    li a0, 0
    .end_strstr:
    pop2 s0, s1
    ret
    

# input:  a0 -- address buffer
# output: a0 -- count lines
CountLines:
    push2 ra, s0
    li a1, '\n'
    li s0, 0    # counter
    
    .while_CountLines:
        addi s0, s0, 1
        call strchr
        beqz a0, .break_CountLines
        lb t0, 0(a0)
        addi a0, a0, 1
        beq t0, a1, .while_CountLines
    
    .break_CountLines:
    mv   a0, s0
    pop2 ra, s0
    ret


# input:  a0 -- address buffer
# output: a0 -- address matrix; a1 -- count lines  
MatrixLines:
    push2 ra, s0
    push2 s1, s2
    push2 s3, s4
    
    mv   s0, a0  # save address buffer
    call CountLines
    mv   s1, a0  # count lines
    mv   s4, a0
    slli a0, a0, 2
    
    sbrk
    mv   s2, a0  # save address matrix str`s
    mv   s3, a0
    
    .loop_MatrixLines:
        mv   a0, s0
        li   a1, '\n'
        call StrCopyChr
        sw   a0, 0(s3)
        
        mv   a0, s0
        li   a1, '\n'
        call strchr
        addi a0, a0, 1
        mv   s0, a0
        
        addi s3, s3, 4
        addi s4, s4, -1
        bgtz s4, .loop_MatrixLines
    
    mv   a0, s2
    mv   a1, s1
    pop2 s3, s4
    pop2 s1, s2
    pop2 ra, s0
    ret


# input:  a0 -- address str
# output: a0 -- int(str)
StrToInt:
    push2 ra, s0
    push2 s1, s2
    push  s3
    
    mv   s0, a0
    li   s1, 0
    li   s3, 0  # 1 if (int(a0) < 0) else 0
    
    lb   s2, 0(s0)
    bnei s2, '-', .while_StrToInt
        li   s3, 1
        addi s1, s1, 1
    
    .while_StrToInt:
        lb   s2, 0(s0)
        beqz s2, .end_StrToInt
        
        check t0, s2, '0', 10
        beqz  t0, .err_StrToInt
        
        li   t0, '0'
        sub  s2, s2, t0
        MultiHexsri s1, s1, 10
        add  s1, s1, s2

        addi s0, s0, 1
        j .while_StrToInt
    
    beqz s3, .end_StrToInt
    neg  s1, s1
    
    .end_StrToInt:
    mv   a0, s1
    pop  s3
    pop2 s1, s2
    pop2 ra, s0
    ret
    
    .err_StrToInt:
        error "error StrToInt: invalid literal for int() with base 10!!!"


# input: a0 -- address buffer copy str; a1 -- data str; a2 -- count copy symbols
strncpy:
    beqz a2, .end_strncpy
    
    .loop_strncpy:
        lb   t0, 0(a1)
        sb   t0, 0(a0)
        addi a0, a0, 1
        
        beqi t0, '\0', .skip_new_char_strncpy
        addi a1, a1, 1
        
        .skip_new_char_strncpy:
        addi a2, a2, -1
        bgtz a2, .loop_strncpy
    
    .end_strncpy:
    ret


# input:  a0 -- address z-t str; a1 -- char end`s str
# output: a0 -- address copy z-t str
StrCopyChr:
    push ra
    push2 s0, s1
    
    mv s0, a0  # save address str
    call strchr
    
    bnez a0, .skip_find_zt_StrCopyChr  # zt -- \0
    li   a1, '\0'
    mv   a0, s0
    call strchr
    
    .skip_find_zt_StrCopyChr:  # zt -- \0
    sub  a0 a0, s0 
    addi a0, a0, 1  # len str
    mv   s1, a0
    addi a0, a0, 1  # len str + '\0'
    sbrk
    
    mv   a1, s0
    mv   a2, s1
    mv   s0, a0
    call strncpy
    
    add t0, s0, s1
    li  t1, '\0'
    sb  t1, 0(t0)
    
    mv   a0, s0
    pop2 s0, s1
    pop ra
    ret


# input:  a0 -- address first z-t str; a1 -- address second z-t str
# output: a0 -- bool(str(a0) == str(a1))
StrEqStr:
    push s0
    li   s0, 0

    .loop_StrEqStr:
        lb   t0, 0(a0)
        lb   t1, 0(a1)
        bne  t0, t1, .end_StrEqStr

        addi a0, a0, 1
        addi a1, a1, 1
        bnez t0, .loop_StrEqStr
    
    li   s0, 1
    .end_StrEqStr:
    mv   a0, s0
    pop  s0
    ret


# input:  a0 -- address find z-t str; a1 -- address matrix z-t strings; a2 -- size matrix
# output: a0 -- address str(a0) in matrix(a1) or NULL
StrInMatrix:
    push2 ra, s0
    push  s1
    blez  a2, .bad_end_StrInMatrix
    
    .loop_StrInMatrix:
        mv   s0, a0
        mv   s1, a1
        
        lw   a1, 0(a1)
        call StrEqStr
        bnez a0, .end_StrInMatrix
        
        addi a1, s1, 4
        addi a2, a2, -1
        mv   a0, s0
        bnez a2, .loop_StrInMatrix

    .bad_end_StrInMatrix:
    li   s1, 0
    .end_StrInMatrix:
    mv   a0, s1
    pop  s1
    pop2 ra, s0
    ret


# input:  a0 -- address str;
StrLower:
    mv   t4, a0
    .loop_StrLower:
        lb t0, 0(a0)
        check t1, t0, 'A', 26
        beqz t1, .skip_lower
        addi t0, t0, -65   # -'A'
        addi t0, t0, 'a'
        sb t0, 0(a0)
        
        .skip_lower:
        addi a0, a0, 1
        bnez t0, .loop_StrLower
    mv   a0, t4
    ret

