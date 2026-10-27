%define ENTRY   main
%define NEWLINE 13, 10

; Reserve the stack frame used by the syscalls below.
; Args 5-9 live at +40..+79 (no return address, since we syscall directly),
; IO_STATUS_BLOCK at +80..+95. 8 + 104 = 112 keeps rsp 16-aligned.
%macro PROLOGUE 0
    sub     rsp, 104
%endmacro

; WRITE_STDOUT buffer, length  ->  NtWriteFile(stdout, 0, 0, 0, &iosb, buf, len, 0, 0)
%macro WRITE_STDOUT 2
    mov     rax, [gs:abs 0x60]          ; PEB
    mov     rax, [rax + 0x20]           ; ProcessParameters
    mov     r10, [rax + 0x28]           ; arg1: StandardOutput handle
    xor     edx, edx                    ; arg2: Event
    xor     r8d, r8d                    ; arg3: ApcRoutine
    xor     r9d, r9d                    ; arg4: ApcContext
    lea     rax, [rsp + 80]
    mov     [rsp + 40], rax             ; arg5: &IoStatusBlock
    lea     rax, [%1]
    mov     [rsp + 48], rax             ; arg6: Buffer
    mov     dword [rsp + 56], %2        ; arg7: Length
    mov     [rsp + 64], rdx             ; arg8: ByteOffset = NULL
    mov     [rsp + 72], rdx             ; arg9: Key = NULL
    mov     eax, 0x08                   ; NtWriteFile
    syscall
%endmacro

; EXIT code  ->  NtTerminateProcess(-1, code)
%macro EXIT 1
    or      r10, -1                     ; current process
  %if %1 = 0
    xor     edx, edx                    ; 2 bytes instead of 5
  %else
    mov     edx, %1
  %endif
    mov     eax, 0x2c                   ; NtTerminateProcess
    syscall
%endmacro
