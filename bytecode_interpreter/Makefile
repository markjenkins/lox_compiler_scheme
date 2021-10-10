archs=amd64 x86 aarch64
EXPRPRINT_BIN=$(foreach arch,$(archs),exprprint.$(arch))

bin: $(EXPRPRINT_BIN) exprprint.gcc

chunk.o: chunk.c chunk.h memory.h value.h
exprprintmain.o: exprprintmain.c value.h chunk.h read.h vm.h
memory.o: memory.c memory.h simplerealloc.h
read.o: read.c read.h value.h memory.h chunk.h
simplerealloc.o: simplerealloc.c simplerealloc.h
value.o: value.c value.h memory.h
vm.o: vm.c vm.h memory.h value.h chunk.h

bootstrappable.o: M2libc/bootstrappable.c
	$(CC) -c M2libc/bootstrappable.c -o bootstrappable.o

exprprint.gcc: chunk.o exprprintmain.o memory.o read.o simplerealloc.o value.o vm.o bootstrappable.o
	$(CC) -o exprprint.gcc chunk.o exprprintmain.o memory.o read.o simplerealloc.o value.o vm.o bootstrappable.o

exprprint.%.M1: exprprintmain.c read.c vm.c vm.h chunk.c chunk.h value.c value.h simplerealloc.c
	./compile_exprprint_w_M2Planet.bash $(subst .,,$(suffix $(basename $@)))

%.hex2: %.M1
	./assemble_multiarch_M1.bash \
	$(subst .,,$(suffix $(basename $@))) \
	$< $@

%.elf.hex2: %.hex2
	cat M2libc/$(subst .,,$(suffix $(basename $<)))/ELF-$(subst .,,$(suffix $(basename $<))).hex2 $< > $@

%: %.elf.hex2
	./link_hex2.bash $(subst .,,$(suffix $@)) $< $@
	chmod +x $@

exprprint.d:
	rm -f exprprint.d
	for arch in $(archs); do \
		echo -n exprprint.$$arch exprprint.d: ' '>> $@; \
		echo exprprint.$$arch.elf.hex2 >> $@; \
	done

include exprprint.d

tests: bin
	$(MAKE) -C $@ tests
