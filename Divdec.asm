.include "./cores/all_cores.asm"


.text
.globl main
main:
    call ReadDec
    push a0
    call ReadDec
    mv a1, a0
    pop a0
    
    call sdiv
    mv t3, a1
    newstr
    call PrintDec  # res
    mv a0, t3
    newstr
    call PrintDec  # ost
    exit 0
    
    
