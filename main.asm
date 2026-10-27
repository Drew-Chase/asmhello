bits 64
default rel

%ifidn __?OUTPUT_FORMAT?__, win64
    %include "win64.asm"
%elifidn __?OUTPUT_FORMAT?__, elf64
    %include "linux.asm"
%else
    %error "Unsupported output format: use -f win64 or -f elf64"
%endif

section .text
global ENTRY

msg     db "Hello World", NEWLINE
msg_len equ $ - msg

ENTRY:
    PROLOGUE
    WRITE_STDOUT msg, msg_len
    EXIT 0