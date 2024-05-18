j main
.include "../../cores/all_cores.asm"
.include "../testLib.asm"
.include "./strchr_lib.asm"


main:
FUNC strchr, "strchr"
OK 0 "abcde" 'a'
OK 3 "fffwwqw" 'w'
OK 2 "abcdef" 'a'
NONE "abcdef" 'Q'
NONE "" '?'
NONE "abcde" 'e'
DONE
