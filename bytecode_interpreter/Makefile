all: exprprint.aarch64 exprprint.gcc

chunk.o: chunk.c chunk.h memory.h value.h
exprprintmain.o: exprprintmain.c value.h chunk.h read.h vm.h
memory.o: memory.c memory.h simplerealloc.h
read.o: read.c read.h value.h memory.h chunk.h
simplerealloc.o: simplerealloc.c simplerealloc.h
value.o: value.c value.h memory.h
vm.o: vm.c vm.h

bootstrappable.o: M2libc/bootstrappable.c
	$(CC) -c M2libc/bootstrappable.c -o bootstrappable.o

exprprint.gcc: chunk.o exprprintmain.o memory.o read.o simplerealloc.o value.o vm.o bootstrappable.o
	$(CC) -o exprprint.gcc chunk.o exprprintmain.o memory.o read.o simplerealloc.o value.o vm.o bootstrappable.o

exprprint.aarch64.M1: exprprintmain.c read.c vm.c vm.h chunk.c chunk.h value.c value.h simplerealloc.c
	M2-Planet \
	--architecture aarch64 \
	-f M2libc/sys/types.h \
	-f M2libc/aarch64/Linux/fcntl.h \
	-f M2libc/aarch64/Linux/unistd.h \
	-f M2libc/stddef.h \
	-f M2libc/stdlib.c \
	-f M2libc/stdio.c \
	-f M2libc/string.c \
	-f M2libc/bootstrappable.h \
	-f M2libc/bootstrappable.c \
	-f common.h \
	-f simplerealloc.c \
	-f memory.h \
	-f memory.c \
	-f value.h \
	-f value.c \
	-f chunk.h \
	-f chunk.c \
	-f read.h \
	-f read.c \
	-f vm.h \
	-f vm.c \
	-f exprprintmain.c \
	-o exprprint.aarch64.M1

exprprint.aarch64.hex2: exprprint.aarch64.M1
	M1 \
	--architecture aarch64 \
	--little-endian \
	-f M2libc/aarch64/aarch64_defs.M1 \
	-f M2libc/aarch64/libc-full.M1 \
	-f exprprint.aarch64.M1 \
	> exprprint.aarch64.hex2

exprprint.aarch64.elf.hex2: exprprint.aarch64.hex2
	cat M2libc/aarch64/ELF-aarch64.hex2 exprprint.aarch64.hex2 \
	> exprprint.aarch64.elf.hex2

exprprint.aarch64: exprprint.aarch64.elf.hex2
	hex2 --base-address 0x400000 --little-endian --architecture aarch64 \
	-f exprprint.aarch64.elf.hex2 -o exprprint.aarch64
	chmod +x exprprint.aarch64
