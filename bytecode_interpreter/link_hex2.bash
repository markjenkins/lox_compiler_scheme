#!/bin/bash

arch=$1
. endianflag.bash
input=$2
output=$3

if test Z$arch = Zaarch64; then \
    baseaddr="0x400000"
elif test Z$arch = Zx86; then \
    baseaddr="0x08048000";
else \
    echo unknown arch $arch
    exit 1
fi

set -x

hex2 \
    --base-address $baseaddr \
    $endianflag \
    --architecture $arch \
    -f $input -o $output

#--little-endian --architecture aarch64 \
#	-f exprprint.aarch64.elf.hex2 -o exprprint.aarch64
#	chmod +x exprprint.aarch64
