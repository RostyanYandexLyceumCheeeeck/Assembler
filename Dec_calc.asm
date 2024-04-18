.include "./cores/dec_core.asm"


.text
.globl main
main:
    push s0

    call ReadDec
    mv s0, a0
    call ReadDec

    mv a1, a0
    readch
    mv a2, a0
    mv a0, s0
    call OperDec
    newstr
    call PrintDec

    pop s0
    exit 0
