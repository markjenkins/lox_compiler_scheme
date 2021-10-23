#!/bin/bash

actualarch=$(uname -m)
QEMUPREFIX=''
SCRIPT_PATH=$(dirname $0)

m2planetarch=$actualarch

# replace x86_64 with amd64 and i386, i486, i586, i686, and i686-pae with x86
# this is more or less the substition that get_machine from mescc-tools
# performs... perhaps I should just use get_machine here instead, but
# I wanted to reduce that as a runtime requirement..
# (mescc-tools needed for build time)
# though in some cases the use of grep here becomes an
# excessive runtime requirement
if test $actualarch '=' 'x86_64'; then \
    m2planetarch='amd64'
elif echo $m2planetarch | grep '^i[3456]86\(-pae\)*$' > /dev/null; then
    m2planetarch='x86'
fi
actualm2planetarch=$m2planetarch

# search through a list of architechures that are being built of our
# bytecode interpreter with M2-Planet
# if our current arch matches one of our build arches, then qemu will not
# be required and we stop the loop
#
# otherwise, plan to use qemu with the last arch in the for list
for buildarch in amd64 x86 aarch64; do \
    if test $actualm2planetarch '=' $buildarch; then \
	QEMUPREFIX=''
	m2planetarch=$buildarch
	break;
    else \
	QEMUPREFIX="qemu-$buildarch"
	m2planetarch=$buildarch
    fi
done

if test z$QEMUPREFIX = "zqemu-x86"; then \
    QEMUPREFIX=qemu-i386
elif test z$QEMUPREFIX = "zqemu-amd64"; then \
    QEMUPREFIX=qemu-x86_64
fi

$QEMUPREFIX $SCRIPT_PATH/bytecode_interpreter/exprprint.$m2planetarch < $1
