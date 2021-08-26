compile_lox_to_bytecode_concat.scm: span_w_pair_state.scm trie.scm keyword_trie.scm tokenize.scm compile_lox_to_bytecode.scm
	cat span_w_pair_state.scm trie.scm keyword_trie.scm tokenize.scm compile_lox_to_bytecode.scm > compile_lox_to_bytecode_concat.scm

keyword_test_trie_concat.scm: keyword_trie.scm trie.scm trie_test.scm
	cat keyword_trie.scm trie.scm trie_test.scm > keyword_test_trie_concat.scm

test1: compile_lox_to_bytecode_concat.scm
	guile compile_lox_to_bytecode_concat.scm < test1.lox

test2: compile_lox_to_bytecode_concat.scm
	guile compile_lox_to_bytecode_concat.scm < test2.lox
