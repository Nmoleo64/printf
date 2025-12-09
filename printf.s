global printf                   ; make the printf symbol visible to the linker
global read_buffer
global write_char

printf:
    mov [rel read_index], rdi                   ; save value of RDI (first argument) into memory

    ;
    ; Main loop for the program - iterates over the string character by character
    ;
    .read_loop:
        ; copy current character into R12B
        mov r11, qword [rel read_index]         ; copy mem[read_index] into R11
        mov r12b, byte [r11]                    ; copy mem[R11] into R12B

        ; check for null byte
        test r12b, r12b                         ; check if R12B = x00 (NUL)
        jz .done_reading                        ; if it is a null byte, we've reached the end of the string

        cmp r12b, 37                            ; check if R12B = x25 ('%')
        je .format_specifier                    ; if yes, we found a format specifier and need to parse it

        ; add character to buffer
        call write_char

        ; increment read_index
        mov r11, qword [rel read_index]         ; copy mem[read_index] into R11
        inc r11                                 ; increment R11
        mov [rel read_index], qword r11         ; save incremented value in memory

        ; return to beginning of loop
        jmp .read_loop

    ;
    ; Called when we encounter a '%' character in .read_loop
    ;
    .format_specifier:
        ; increment read_index
        mov r11, qword [rel read_index]         ; copy mem[read_index] into R11
        inc r11                                 ; increment R11
        mov [rel read_index], qword r11         ; save incremented value in memory

        ; copy next character into r12b
        mov r11, qword [rel read_index]         ; copy mem[read_index] into R11
        mov r12b, byte [r11]                    ; copy mem[R11] into r12b

        cmp r12b, 37                            ; check if r12b = x25 ('%')
        je .escaped_percent                     ; if yes, print a '%' character

        cmp r12b, 115                           ; check if r12b = x73 ('s')
        je .string                              ; if yes, print string from user argument

        jmp .read_loop

    ;
    ; Called when '%%' is encountered within the string
    ; Writes a '%' character to the buffer
    ;
    .escaped_percent:
        mov r12b, 37                            ; set R12B = x41 ('%')
        call write_char                         ; write character to buffer

        jmp .read_loop

    ;
    ; Called when '%s' is encountered within the string
    ;
    .string:
        ; TODO
        jmp .read_loop

    ;
    ; Called after reading to the end of the string
    ;
    .done_reading:
        ret                                     ; return to caller function

;
; Subroutine to write a single character to the buffer
; If the buffer reaches maximum capacity, it will automatically print the entire buffer to the console
;
; Inputs:
;  - R12B = char that should be written to the buffer
;
write_char:
    ; TODO - make this actually use the buffer instead of going 1 char at a time

    mov byte [rel read_buffer], r12b        ; copy byte from r12b into read_buffer[0]
    mov rax, 1                              ; syscall number = 1 (write)
    mov rdi, 1                              ; file descriptor = 1 (stdout)
    lea rsi, [rel read_buffer]              ; rsi = pointer to read_buffer
    mov rdx, 1                              ; rdx = number of characters to write (1)
    syscall                                 ; run syscall 1

    ret

;
; Memory here will not be zeroed by the OS
;
section .data
    read_buffer: times 1024 db 0                ; reserve a 1KB buffer so we don't have to syscall
                                                ; for every character and initialize it to zeros

section .bss
    read_index: resb 8                          ; reserve 8 bytes for the memory address of the current
                                                ; character as we iterate through the string
