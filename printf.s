global printf                   ; make the printf symbol visible to the linker
global read_buffer

printf:
    mov [rel read_index], rdi                   ; save value of RDI (first argument) into memory

    ;
    ; Main loop for the program - iterates over the string character by character
    ;
    .read_loop:
        ;
        ; copy current character into R10B and check if null
        ;
        mov r11, qword [rel read_index]         ; copy mem[read_index] into R11
        mov r10b, byte [r11]                    ; copy mem[R11] into R10B
        test r10b, r10b                         ; check if R10B = x00 (NUL)
        jz .done_reading                        ; if it is a null byte, we've reached the end of the string

        ;
        ; print current character to screen
        ;
        mov byte [rel read_buffer], r10b        ; copy byte from R10B into read_buffer[0]
        mov rax, 1                              ; syscall number = 1 (write)
        mov rdi, 1                              ; file descriptor = 1 (stdout)
        lea rsi, [rel read_buffer]              ; rsi = pointer to read_buffer
        mov rdx, 1                              ; rdx = number of characters to write
        syscall                                 ; run syscall 1

        ;
        ; increment read_index
        ;
        mov r11, qword [rel read_index]         ; copy mem[read_index] into R11
        inc r11                                 ; increment R11
        mov [rel read_index], qword r11         ; save incremented value in memory

        jmp .read_loop                          ; return to beginning of loop

    ;
    ; We jump here after reading to the end of the string
    ;
    .done_reading:
        ret                                     ; return to caller function

;
; Memory here will not be zeroed by the OS
;
section .data
    read_buffer: times 1024 db 0                ; reserve a 1KB buffer so we don't have to syscall
                                                ; for every character and initialize it to zeros

section .bss
    read_index: resb 8                          ; reserve 8 bytes for the memory address of the current
                                                ; character as we iterate through the string
