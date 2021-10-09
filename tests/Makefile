LOX_COMPILE_AND_EVAL_TEST_NUMS = $(shell seq 4 13)
LOX_COMPILE_TESTS = $(foreach i,$(LOX_COMPILE_AND_EVAL_TEST_NUMS),test$(i).output.txt)

tests: $(LOX_COMPILE_TESTS)

# test1-3 are not part of the main test suite, there's checking of their
# output
test1: ../test1.lox ../test_tokenize_concat.scm
	guile ../test_tokenize_concat.scm < $<
test2: ../test2.lox ../test_tokenize_concat.scm
	guile ../test_tokenize_concat.scm < $<
test3: ../test_alt_unfold_concat.scm
	guile $<

%.output.txt.d:
	echo $(@:txt.d=txt) $@: ../$(@:output.txt.d=lox) ../$(@:output.txt.d=expected.txt) ../compile_lox_to_bytecode_concat.scm > $@

include $(LOX_COMPILE_TESTS:.output.txt=.output.txt.d)

%.output.txt:
	guile ../compile_lox_to_bytecode_concat.scm < $< > $@
	cmp $@ $(basename $<).expected.txt
