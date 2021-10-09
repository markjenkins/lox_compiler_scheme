all: bytecode_interpreter compile_lox_to_bytecode_concat.scm

tests: compile_lox_to_bytecode_concat.scm
	$(MAKE) -C tests tests
	$(MAKE) -C bytecode_interpreter tests

include scm_concat_rule.mk

compile_lox_to_bytecode_concat.scm: span_w_pair_state.scm srfi1.scm trie.scm keyword_trie.scm tokenize.scm alt_unfold.scm parse.scm flatten.scm compile.scm readstdin.scm compile_lox_to_bytecode.scm
keyword_test_trie_concat.scm: keyword_trie.scm srfi1.scm trie.scm trie_test.scm
test_tokenize_concat.scm: span_w_pair_state.scm srfi1.scm trie.scm keyword_trie.scm tokenize.scm readstdin.scm prettyprint.scm test_tokenize.scm
test_alt_unfold_concat.scm: alt_unfold.scm test_alt_unfold.scm

bytecode_interpreter:
	$(MAKE) -C $@

.PHONY: tests bytecode_interpreter
