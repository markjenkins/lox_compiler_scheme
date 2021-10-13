#!/bin/bash

arch=$1

set -x

M2-Planet \
    --architecture $arch \
    -f M2libc/sys/types.h \
    -f M2libc/$arch/Linux/fcntl.h \
    -f M2libc/$arch/Linux/unistd.h \
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
    -f object.h \
    -f value.h \
    -f printobject.h \
    -f object.c \
    -f value.c \
    -f chunk.h \
    -f chunk.c \
    -f read.h \
    -f read.c \
    -f vm.h \
    -f vm.c \
    -f exprprintmain.c \
    -o exprprint.$arch.M1
