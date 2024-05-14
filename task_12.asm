.include "./cores/all_cores.asm"


.text
.globl main
main:
    bnei a0, 1, .err_main
    
    lw a0, 0(a1)
    li   a1, 0
    call fopen
    call fload
    call CountLines
    printint
    newstr
    
    exit 0
    
    .err_main:
        error "error: incorrect number of arguments!"
