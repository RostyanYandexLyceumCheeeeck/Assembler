.include "hex_core.asm"


.text
.globl main
main:
    push s0

    call ReadHex
    mv s0, a0
    call ReadHex

    mv a1, a0
    mv a0, s0
    call MultiHex
    call PrintHex

    pop s0
    exit 0
