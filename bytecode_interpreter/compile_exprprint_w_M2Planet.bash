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
    -f common.h \
    -f simplerealloc.c \
    -f object.h \
    -f value.h \
    -f chunk.h \
    -f linkedstack.h \
    -f vm.h \
    -f memory.h \
    -f memory.c \
    -f printobject.h \
    -f object.c \
    -f str2long.c \
    -f value.c \
    -f chunk.c \
    -f copystring.h \
    -f read.h \
    -f read.c \
    -f freeobjects.h \
    -f linkedstack.c \
    -f vm.c \
    -f commonmain.h \
    -f commonmain.c \
    -f exprprintmain.c \
    -o exprprint.$arch.M1
