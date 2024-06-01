j    main
.include "./cores/all_cores.asm"
.data
        file_extension: .asciz ".sorted"


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
    
    mv   a0, s0
    la   a1, file_extension
    call StrConc    # filename.sorted
    li   a1, 1
    call fopen
    mv   s0, a0    # descriptor filename.sorted
    
    .loop_main:
        lw   a0, 0(s1)
        call strlen
        mv   a2, a0
        lw   a1, 0(s1)
        mv   a0, s0
        write
        
        addi s1, s1, 4
        addi s3, s3, 1
        ble  s3, s2, .loop_main
    
    closer s0
    .end_main:
    exit 0
    
    .err_main:
        error "error: incorrect number of arguments!"
