.include "./cores/all_cores.asm"
.eqv MAX_INT 0x7FFFFFFF


.text
.globl main
main:
    beqz a0, .err_main
    bgei a0, 3, .err_main
    
    li   s1, MAX_INT
    lw   s0, 0(a1)  # save name file
    
    bnei a0, 2, .skip_N_main
    lw   a0, 4(a1)
    call StrToInt
    mv   s1, a0   # N

    .skip_N_main:
    mv   a0, s0
    li   a1, 0
    call fopen
    mv   s0, a0  # save file descriptor
    
    call fload
    call MatrixLines
    mv   s2, a0  # save address matrix    
    
    blez s1, .end_main
    li   t1, 1
    sub  s1, a1, s1
    .loop_main:
        ble  t1, s1, .skip_print_main
        printintr t1
        printchi ')'
        printchi ' '
        lw  a0, 0(s2)
        printstr
        
        .skip_print_main:
        addi t1, t1, 1
        addi s2, s2, 4
        ble  t1, a1, .loop_main
    
    .end_main:
    closer s0
    exit 0
    
    .err_main:
        error "error: incorrect number of arguments!"
    
