#!/bin/bash

actualarch=$(uname -i)
arch=$actualarch
QEMUPREFIX=''

# search through a list of architechures that are being built of our
# bytecode interpreter with M2-Planet
# if our current arch matches one of our build arches, then qemu will not
# be required and we stop the loop
#
# otherwise, plan to use qemu with the last arch in the for list
for buildarch in aarch64; do \
    if test $actualarch '=' $buildarch; then \
	QEMUPREFIX=''
	arch=$buildarch
	break;
    else \
	QEMUPREFIX="qemu-$buildarch"
	arch=$buildarch
    fi
done


$QEMUPREFIX ./bytecode_interpreter/exprprint.$arch < $1
