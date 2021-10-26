archs=amd64 x86 aarch64
EXPRPRINT_BIN=$(foreach arch,$(archs),exprprint.$(arch))

bin: $(EXPRPRINT_BIN) exprprint.gcc

# excludes M2lib/bootstrappable.c as we won't be changing it during dev of
# this project
#
# excludes exprprintmain.c as there is no exprprintmain.h
sourceswh = chunk.c memory.c read.c simplerealloc.c value.c vm.c object.c commonmain.c

# add exprprintmain.c to the list of c sources
exprprint_sources = $(sourceswh) exprprintmain.c

additional_headers = common.h printobject.h copystring.h freeobjects.h

# all .c and .h files with common.h added as there is no common.c 
exprprint_source_n_headers = $(exprprint_sources) $(sourceswh:.c=.h) $(additional_headers)

exprprint.%.M1: $(exprprint_source_n_headers)
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

# use gcc -MM to discover .h depends of our $(exprprint_sources) .c files
%.d: %.c
	@set -e; rm -f $@; $(CC) -MM $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

# import .d rules created above
include $(exprprint_sources:.c=.d)

# be more explicit in building M2libc/bootstrappable.c to bootstrappable.o
# we don't want to make M2libc/bootstrappable.o as that would conflict
# with rules in that dir, so we make our own bootstappable.o for this
# build
bootstrappable.o: M2libc/bootstrappable.c
	$(CC) -c M2libc/bootstrappable.c -o bootstrappable.o

# and we append bootstrapple.o to this object list
exprprint.gcc: $(exprprint_sources:.c=.o) bootstrappable.o
	$(CC) -o $@ $^

tests: bin
	$(MAKE) -C $@ tests
