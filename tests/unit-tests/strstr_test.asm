j main
.include "../../cores/all_cores.asm"
.include "../testLib.asm"
.include "./strstr_lib.asm"


main:
FUNC strstr, "strstr"

OK 0 "abcde" "a"        # TRUE
OK 3 "fffwwqw" "w"        # TRUE
OK 2 "abcdef" "a"        # FALSE
NONE "abcdef" "Q"        # TRUE
NONE "" "?"             # TRUE
NONE "abcde" "e"        # FALSE

OK 0 "abcde" "abcde"                    # TRUE
OK 1 "0abcde" "abcde"                    # TRUE
OK 12 "asdaassdsasdsasdsaa" "sasdsaa"    # TRUE
DONE
