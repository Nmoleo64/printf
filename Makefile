all: build/test

build:
	mkdir -p build

build/test: | build
	gcc -fno-builtin-printf -o build/test test.c printf.s

clean:
	rm -rf build
