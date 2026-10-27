%define ENTRY   _start
%define NEWLINE 10

; Linux syscalls take args in registers only: no stack frame needed.
%macro PROLOGUE 0
%endmacro

; WRITE_STDOUT buffer, length  ->  write(1, buf, len)
%macro WRITE_STDOUT 2
    mov     eax, 1                      ; sys_write
    mov     edi, eax                    ; fd 1 = stdout (eax is already 1)
    lea     rsi, [%1]
    mov     edx, %2
    syscall
%endmacro

; EXIT code  ->  exit(code)
%macro EXIT 1
    mov     eax, 60                     ; sys_exit
  %if %1 = 0
    xor     edi, edi
  %else
    mov     edi, %1
  %endif
    syscall
%endmacro
