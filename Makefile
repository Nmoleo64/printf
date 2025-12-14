all: build/test

build:
	mkdir -p build

gdb: build/test
	gdb -ex "break printf.signed_int" --args build/test

# Compile test.c
build/test.o: test.c | build
	gcc -Wall -c -fno-builtin-printf test.c -o build/test.o

# Assemble printf.s
build/printf.o: printf.s | build
	nasm -f elf64 printf.s -o build/printf.o

# Link test.o and printf.o into test
build/test: build/test.o build/printf.o | build
	gcc -Wall -fno-builtin-printf build/test.o build/printf.o -o build/test

clean:
	rm -rf build
