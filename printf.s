global printf                   ; make the printf symbol visible to the linker
global read_buffer

printf:
    mov [rel read_index], rdi                   ; save value of RDI (first argument) into memory
    mov [rel additional_args], rsi              ; save value of RSI (second argument) into memory
    mov [rel additional_args + 8], rdx          ; save value of RDX (third argument) into memory
    mov [rel additional_args + 16], rcx         ; save value of RCX (fourth argument) into memory
    mov [rel additional_args + 24], r8          ; save value of R8 (fifth argument) into memory
    mov [rel additional_args + 32], r9          ; save value of R9 (sixth argument) into memory

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

        ; increment read_index
        mov r11, qword [rel read_index]         ; copy mem[read_index] into R11
        inc r11                                 ; increment R11
        mov [rel read_index], qword r11         ; save incremented value in memory

        call get_next_arg                       ; copies next argument into R12
        mov [rel string_index], qword r12       ; save this into memory

        .string_loop:
            ; copy current character into R12B
            mov r11, qword [rel string_index]       ; copy mem[string_index] into R11
            mov r12b, byte [r11]                    ; copy mem[R11] into R12B

            ; check for null byte
            test r12b, r12b                         ; check if R12B = x00 (NUL)
            jz .string_done                         ; if yes, we're done - go back to reading

            ; write character to buffer
            call write_char

            ; increment string_index
            mov r11, qword [rel string_index]       ; copy mem[string_index] into R11
            inc r11                                 ; increment R11
            mov [rel string_index], qword r11       ; save incremented value in memory

            jmp .string_loop                        ; return to beginning of loop

        .string_done:
            jmp .read_loop                          ; return to main loop

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

    ret                                     ; return to caller function

;
; Subroutine to get the next argument supplied to the function
; and then increment the counter
;
; Outputs:
;  - R12 = the value of the next argument
;
get_next_arg:
    movzx r11, byte [rel arg_offset]            ; R11 = byte offset for additional_args
    lea r12, [rel additional_args]              ; R12 = additional_args
    add r12, r11                                ; R12 = additional_args + mem[args_offset]
    mov r12, [r12]                              ; dereference R12, now R12 = value of current argument

    ; increment arg_offset by 8
    mov r10b, byte [rel arg_offset]             ; copy mem[arg_offset] into R10B
    add r10b, 8                                 ; add 8
    cmp r10b, 32                                ; check if R10B > 32
    ja .skip_arg_offset                         ; if yes, skip this next line:
    mov [rel arg_offset], r10b                  ; save R10B to mem[arg_offset]

    ; TODO: address case where we have >6 arguments supplied
    .skip_arg_offset:

    ret                                         ; return to caller function

;
; Memory here *will not* be zeroed by the OS
;
section .data
    read_buffer: times 1024 db 0                ; reserve a 1KB buffer so we don't have to syscall
                                                ; for every character and initialize it to zeros
;
; Memory here *will* be zeroed by the OS
;
section .bss
    read_index: resb 8                          ; reserve 8 bytes for the memory address of the current
                                                ; character as we iterate through the main string

    string_index: resb 8                        ; reserve 8 bytes for the memory address of the current
                                                ; character as we iterate through a %s string

    additional_args: resq 5                     ; reserve 8 bytes for each additional argument
    arg_offset: resb 1                          ; counter to keep track of which argument we are on
