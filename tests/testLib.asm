# .include "../cores/core.asm"


.data
    count_all:    .word 0
    count_false:  .word 0
    address_func: .word 0


.text
.macro FUNC %func, %func_name
.text
    printstri "Testing function "
    printstri %func_name
    printstri "...\n"
    sw zero, count_all,   t1
    sw zero, count_false, t1
    la t0, %func
    sw t0, address_func,  t1 
.end_macro


.macro DONE
    printstri "Passed: "
    subaa a0, count_all, count_false   # look core.asm !!
    printint
    printstri ", failed: "
    printinta count_false
    newstr
.end_macro