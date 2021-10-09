all: bytecode_interpreter compile_lox_to_bytecode_concat.scm

tests: compile_lox_to_bytecode_concat.scm
	$(MAKE) -C tests tests
	$(MAKE) -C bytecode_interpreter tests

include scm_concat_rule.mk

compile_lox_to_bytecode_concat.scm: span_w_pair_state.scm srfi1.scm trie.scm keyword_trie.scm tokenize.scm alt_unfold.scm parse.scm flatten.scm compile.scm readstdin.scm compile_lox_to_bytecode.scm

bytecode_interpreter:
	$(MAKE) -C $@

.PHONY: tests bytecode_interpreter
