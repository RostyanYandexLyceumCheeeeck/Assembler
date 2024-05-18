# .include "../cores/core.asm"


.macro copy_paste_OK_and_NONE_strchr %expected, %str, %chr, %skip_lose_label, %end_lose_label, %flag_OK   # not flag_OK ==> NONE; else OK; 
.data
    inp_copy_paste: .asciz %str
.text
    la   a0, inp_copy_paste
    li   a1, %chr
    jalra address_func                           # look core.asm !!
    la   tr, inp_copy_paste
    
    mv   s0, a0
    li   t0, %flag_OK
    beqz t0, .skip_flag
    sub  s0, a0, tr
    
    .skip_flag:
    aaddia count_all, count_all, 1             # look core.asm !!
    beqi s0, %expected, %skip_lose_label

    aaddia count_false, count_false, 1
    printstri "Test falied: strchr(\""
    printstra inp_copy_paste                # look core.asm !!
    printstri "\", \'"
    printchi  %chr
    printstri "\') results in OK("
    printintr s0
    printstri "), expected "
    j    %end_lose_label
.end_macro


.macro OK %int, %str, %chr
    copy_paste_OK_and_NONE_strchr %int, %str, %chr, .skip_lose_ok, .end_lose_label_ok, 1
    .end_lose_label_ok:
    printstri "OK("
    printinti %int
    printstri ")\n"
    .skip_lose_ok:
.end_macro

.macro NONE %str, %chr
    copy_paste_OK_and_NONE_strchr 0, %str, %chr, .skip_lose_none, .end_lose_label_none, 0
    .end_lose_label_none:
    printstri "NONE\n"
    .skip_lose_none:
.end_macro
