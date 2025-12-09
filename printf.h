/**
 * C header file - specifies the function signature so printf can be called from C
 */

#ifndef PRINTF_H                    // Verify that printf.h has not already been imported
#define PRINTF_H
void printf(const char* s, ...);    // Ellipsis tells the compiler to accept a variable number of
                                    // arguments of unknown type
#endif
