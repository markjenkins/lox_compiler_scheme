SCM=guile

LOX_COMPILE_AND_EXPR_EVAL_TEST_NUMS = $(shell seq 4 39) 82
LOX_EXPR_COMPILE_TESTS = $(foreach i,$(LOX_COMPILE_AND_EXPR_EVAL_TEST_NUMS),test$(i).output.txt)

LOX_COMPILE_AND_DECL_EVAL_TEST_NUMS = $(shell seq 40 55) $(shell seq 67 79) 81
LOX_DECL_COMPILE_TESTS = $(foreach i,$(LOX_COMPILE_AND_DECL_EVAL_TEST_NUMS),test$(i).decl_output.txt)

LOX_COMPILE_LINK_AND_DECL_EVAL_TEST_NUMS = $(shell seq 56 66) $(shell seq 80 80)
LOX_DECL_LINK_COMPILE_INTERMEDIATES = $(foreach i,$(LOX_COMPILE_LINK_AND_DECL_EVAL_TEST_NUMS),test$(i).intermed_output.txt)
LOX_DECL_LINK_COMPILE_TESTS = $(foreach i,$(LOX_COMPILE_LINK_AND_DECL_EVAL_TEST_NUMS),test$(i).linked_output.txt)

tests: $(LOX_EXPR_COMPILE_TESTS) $(LOX_DECL_COMPILE_TESTS) \
       $(LOX_DECL_LINK_COMPILE_TESTS)
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

%.intermed_output.txt.d:
	echo $(@:txt.d=txt) $@: $(@:intermed_output.txt.d=lox) ../compile_lox_to_bytecode_concat.scm > $@

%.linked_output.txt.d:
	echo $(@:txt.d=txt) $@: $(@:linked_output.txt.d=intermed_output.txt) $(@:linked_output.txt.d=expected.txt) ../jump_resolve_concat.scm > $@

include $(LOX_EXPR_COMPILE_TESTS:.output.txt=.output.txt.d)
include $(LOX_DECL_COMPILE_TESTS:.decl_output.txt=.decl_output.txt.d)
include $(LOX_DECL_LINK_COMPILE_INTERMEDIATES:.intermed_output.txt=.intermed_output.txt.d)
include $(LOX_DECL_LINK_COMPILE_TESTS:.linked_output.txt=.linked_output.txt.d)

%.output.txt:
	$(SCM) ../compile_lox_expr_to_bytecode_concat.scm < $< > $@
	cmp $@ $(basename $<).expected.txt

%.decl_output.txt:
	$(SCM) ../compile_lox_to_bytecode_concat.scm < $< > $@
	cmp $@ $(basename $<).expected.txt

## FIXME, we should figure out how to share this invocation with
## %.decl_output.txt, but without the testing of the intermediate output
%.intermed_output.txt:
	$(SCM) ../compile_lox_to_bytecode_concat.scm < $< > $@

%.linked_output.txt:
	$(SCM) ../jump_resolve_concat.scm < $< > $@
	cmp $@ $(@:.linked_output.txt=.expected.txt)
