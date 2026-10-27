bits 64                                 ; This tells the compiler its a 64 bit program
default rel                             ; This tells the compiler to make memory references relative to the current instruction.

section .text
msg     db "Hello World", 13, 10        ; 13 = \r and 10 = \n
msg_len equ $ - msg
global main

main:
    sub     rsp, 104                    ; 32 shadow + 8 realigns to a multiple of 16

    mov     rax, [gs:abs 0x60]          ; Gets the Process Environment Block
    mov     rax, [rax + 0x20]           ; PEB->ProcessParameters
    mov     rcx, [rax+0x28]             ; ProcessParameters->StandardOutput handle - put handle into arg1

    xor     edx, edx                    ; Sets the 2nd argument (Event) = NULL
    xor     r8d, r8d                    ; Sets the 3rd argument (ApcRoutine) to Null
    xor     r9d, r9d                    ; Sets the 4th argument (ApcContext) to Null
    lea     rax, [rsp + 72]
    mov     [rsp + 32], rax             ; Sets the 5th argument (IOStatusBlock)
    lea     rax, [msg]                  ; Moves the pointer of message into rax
    mov     [rsp + 40], rax             ; Sets the 6th argument (buffer)
    mov     qword [rsp + 48], msg_len         ; Sets the 7th argument (Length)
    mov     qword [rsp + 56], 0         ; Sets the 8th (bytes offset)
    mov     qword [rsp + 64], 0         ; Sets the 9th argument (key) to Null

    ; NtWriteFile
    mov     r10, rcx
    mov     eax, 0x08
    syscall


    ; Exit the application with exit code 0
    or      r10, -1                     ; argument 1 is -1 meaning the current process.
    xor     edx, edx                    ; Sets argument 2 to null or 0 which will set the exit code to 0
    mov     eax, 0x2c                   ; NtTerminateProcess
    syscall
