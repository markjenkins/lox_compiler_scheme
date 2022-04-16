all: bytecode_interpreter compiler

compiler: compile_lox_expr_to_bytecode_concat.scm compile_lox_to_bytecode_concat.scm

compiler_tests: compiler
	$(MAKE) -C tests tests

bytecode_interpreter_tests: bytecode_interpreter
	$(MAKE) -C bytecode_interpreter tests

tests: compiler_tests bytecode_interpreter_tests

include scm_concat_rule.mk

compile_lox_to_bytecode_concat.scm: span_w_pair_state.scm srfi1.scm trie.scm keyword_trie.scm tokenize.scm alt_unfold.scm scopestate.scm parse.scm flatten.scm compile.scm readstdin.scm compile_lox_to_bytecode.scm

compile_lox_expr_to_bytecode_concat.scm: span_w_pair_state.scm srfi1.scm trie.scm keyword_trie.scm tokenize.scm alt_unfold.scm scopestate.scm parse.scm flatten.scm compile.scm readstdin.scm compile_lox_expr_to_bytecode.scm

bytecode_interpreter:
	$(MAKE) -C $@

.PHONY: tests bytecode_interpreter compiler compiler_tests bytecode_interpreter_tests
