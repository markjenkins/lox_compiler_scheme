#!/bin/bash

arch=$1
. endianflag.bash
archdefs=M2libc/$arch/"$arch"_defs.M1
archlibc=M2libc/$arch/libc-full.M1
input=$2
output=$3

set -x

M1 \
    --architecture $arch \
    $endianflag \
    -f $archdefs \
    -f $archlibc \
    -f $input \
    > $output
