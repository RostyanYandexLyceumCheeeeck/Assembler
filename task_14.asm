.include "./cores/all_cores.asm"
.eqv MAX_INT 0x7FFFFFFF
.data
    flag_n: .asciz "-n"
    flag_v: .asciz "-v"
    flag_i: .asciz "-i"
    flag_C_big: .asciz "-C"
    flag_c_small: .asciz "-c"
    sep_flag_C_big: .asciz "--\n"


.text
.globl main
main:
    blti a0, 2, .err_main
    bgei a0, 9, .err_main
    
    slli t0, a0, 2
    add  t0, a1, t0
    lw   s0, -8(t0)   # find str
    lw   s1, -4(t0)   # file name
    
    mv   s2, a1  # save
    li   s3, 0   # flag_n
    li   s4, 0   # flag_C_big
    li   s5, 0   # flag_v
    li   s6, 0   # flag_i
    li   s7, 0   # flag_c_small
    
    addi s11, a0, -2
    .search_flag_n:
        la   a0, flag_n
        mv   a2, s11
        call StrInMatrix
        beqz a0, .search_flag_C_big
        li   s3, 1
    
    .search_flag_C_big:
        la   a0, flag_C_big
        mv   a1, s2
        mv   a2, s11
        call StrInMatrix
        beqz a0, .search_flag_v
        lw   a0, 4(a0)
        call StrToInt
        slli s4, a0, 2  # count lines context * 4
    
    .search_flag_v:
        la   a0, flag_v
        mv   a1, s2
        mv   a2, s11
        call StrInMatrix
        beqz a0, .search_flag_i
        li   s4, 0   # cancel flag_C_big
        li   s5, 1
    
    .search_flag_i:
        la   a0, flag_i
        mv   a1, s2
        mv   a2, s11
        call StrInMatrix
        beqz a0, .search_flag_c_small
        li   s6, 1
        mv   a0, s0
        call StrLower
    
    .search_flag_c_small:
        la   a0, flag_c_small
        mv   a1, s2
        mv   a2, s11
        call StrInMatrix
        beqz a0, .end_search_flags
        li s7, 1
    
    .end_search_flags:
    mv   a0, s1
    li   a1, 0
    call fopen
    mv   s1, a0     # save file descriptor
    
    call fload
    call MatrixLines
    mv   s8, a0     # save address start matrix
    slli a1, a1, 2  # count lines * 4
    add  s9, a0, a1 # address last lines in matrix
    swap a0, s1     # save address matrix
    close
    
    ######################## DEBUG!!!
    # mv   s2, s1
    # .wil:
    #    lw   a0, 0(s1)
    #    mv   s7, a0
    #    sub  a0, s1, s8
    #    srli a0, a0, 2
    #    addi a0, a0, 1
    #    printint
    #    printchi ')'
    #    mv   a0, s7
    #    printstr
    #    addi s1, s1, 4
    #    blt  s1, s9, .wil
    
    #printchi '='
    #newstr
    #newstr
    #mv   s1, s2
    ########################
    
    li   s11, 0
    addi s10, s1, -4  # address last print string
    
    beqz s3, .loop_main  # if not flag_n
    li   s2, ':'
    slli s2, s2, 8
    addi s2, s2, '-'
    beqz s5, .loop_main  # if not flag_v
    slli s2, s2, 8
    addi s2, s2, ':'
    
    .loop_main:
        lw   a0, 0(s1)
        beqz s6, .skip_flag_i_loop
        li   a1, '\0'
        call StrCopyChr
        call StrLower
        
        .skip_flag_i_loop:
        mv   a1, s0
        call strstr
        mv   t0, a0
        
        beqz s7, .skip_flag_c_small
        sltu t1, zero, t0
        add  s7, s7, t1
        j    .continue_loop_main
        
        .skip_flag_c_small:
        bnez s5, .print_string             # if flag_v
        beqz s4, .skip_flag_C_big_loop  # if not flag_C_big
        beqz t0, .skip_update_s11_s1
        
        slt  t5, s11, s1  # if context
        
        add  s11, s1, s4
        sub  t1, s1, s4
        addi t2, s10, 4
        max  s1, t1, t2
        
        beqz t5, .skip_update_s11_s1
        j    .loop_main
        
        .skip_update_s11_s1:
        ble  s1, s11, .print_string
            
        .skip_flag_C_big_loop:
        beqz t0, .continue_loop_main
        
        .print_string:
            beqz s4, .skip_print_sep
            sub  t5, s1, s10
            blei t5, 4, .skip_print_sep
            ble  s10, s8, .skip_print_sep
            la   a0, sep_flag_C_big
            printstr
            
            .skip_print_sep:
            beqz s3, .skip_flag_n_loop
            sub  a0, s1, s8
            srli a0, a0, 2
            addi a0, a0, 1
            printint         # print number line
            
            andi a0, s2, 0xFF
            beqz t0, .skip_swap_char_loop
            srli a0, s2, 8
            .skip_swap_char_loop:
            printch         # print char (':' or '-')
            
            .skip_flag_n_loop:
            lw   a0, 0(s1)
            mv   s10, s1
            printstr       # print line
        
        .continue_loop_main:
        addi s1, s1, 4
        blt  s1, s9, .loop_main
    
    beqz s7, .end_main
    addi s7, s7, -1
    beqz s5, .skip_invert_s7
    sub  t0, s9, s8
    srli t0, t0,  2   # len matrix
    sub  s7, t0, s7
    
    .skip_invert_s7:
    printintr s7
    
    .end_main:
    exit 0
    
    .err_main:
        error "error: incorrect number of arguments!"
    
