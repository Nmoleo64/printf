.intel_syntax noprefix          # switch to Intel syntax
.globl printf                   # make the printf symbol visible to the linker
.type  printf, @function        # mark the printf symbol as a function

printf:
    ret                         # return to caller function

.size printf, .-printf          # tells the assembler the size of the strlwr function
