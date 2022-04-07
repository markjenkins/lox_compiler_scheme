SCM=guile

LOX_COMPILE_AND_EXPR_EVAL_TEST_NUMS = $(shell seq 4 39)
LOX_EXPR_COMPILE_TESTS = $(foreach i,$(LOX_COMPILE_AND_EXPR_EVAL_TEST_NUMS),test$(i).output.txt)

LOX_COMPILE_AND_DECL_EVAL_TEST_NUMS = $(shell seq 40 45)
LOX_DECL_COMPILE_TESTS = $(foreach i,$(LOX_COMPILE_AND_DECL_EVAL_TEST_NUMS),test$(i).decl_output.txt)

tests: $(LOX_EXPR_COMPILE_TESTS) $(LOX_DECL_COMPILE_TESTS)

include ../scm_concat_rule.mk

keyword_test_trie_concat.scm: ../keyword_trie.scm ../srfi1.scm ../trie.scm trie_test.scm
test_tokenize_concat.scm: ../span_w_pair_state.scm ../srfi1.scm ../trie.scm ../keyword_trie.scm ../tokenize.scm ../readstdin.scm ../prettyprint.scm test_tokenize.scm
test_alt_unfold_concat.scm: ../alt_unfold.scm test_alt_unfold.scm

# test1-3 and test_trie are not part of the main test suite, there's
# no checking of their output
test_trie: keyword_test_trie_concat.scm
	$(SCM) $<
test1: test1.lox test_tokenize_concat.scm
	$(SCM) test_tokenize_concat.scm < $<
test2: test2.lox test_tokenize_concat.scm
	$(SCM) test_tokenize_concat.scm < $<
test3: test_alt_unfold_concat.scm
	$(SCM) $<

%.output.txt.d:
	echo $(@:txt.d=txt) $@: $(@:output.txt.d=lox) $(@:output.txt.d=expected.txt) ../compile_lox_expr_to_bytecode_concat.scm > $@

%.decl_output.txt.d:
	echo $(@:txt.d=txt) $@: $(@:decl_output.txt.d=lox) $(@:decl_output.txt.d=expected.txt) ../compile_lox_to_bytecode_concat.scm > $@

include $(LOX_EXPR_COMPILE_TESTS:.output.txt=.output.txt.d)
include $(LOX_DECL_COMPILE_TESTS:.decl_output.txt=.decl_output.txt.d)

%.output.txt:
	$(SCM) ../compile_lox_expr_to_bytecode_concat.scm < $< > $@
	cmp $@ $(basename $<).expected.txt

%.decl_output.txt:
	$(SCM) ../compile_lox_to_bytecode_concat.scm < $< > $@
	cmp $@ $(basename $<).expected.txt
