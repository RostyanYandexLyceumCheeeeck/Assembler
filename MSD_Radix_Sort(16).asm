.include "./cores/all_cores.asm"


.text
.globl main
main:
    bnei a0, 1, .err_main
    lw   s0, 0(a1)  # filename

    mv   a0, s0
    li   a1, 0
    call fopen
    mv   s3, a0     # save file descriptor 
    
    call fload
    call MatrixLines
    mv   s1, a0     # address matrixlines
    mv   s2, a1     # len matrixlines
    closer s3
    
    mv   a0, s1
    mv   a1, s2
    call MSDRadixSort
    li   s3, 1
    
    .loop_main:
        printintr s3
        printchi ')'
        lw   a0, 0(s1)
        printstr
        
        addi s1, s1, 4
        addi s3, s3, 1
        ble  s3, s2, .loop_main
        
    .end_main:
    exit 0
    
    .err_main:
        error "error: incorrect number of arguments!"
