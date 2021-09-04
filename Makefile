tests: test4.output.txt test5.output.txt test6.output.txt test7.output.txt test8.output.txt test9.output.txt test10.output.txt test11.output.txt test12.output.txt

compile_lox_to_bytecode_concat.scm: span_w_pair_state.scm srfi1.scm trie.scm keyword_trie.scm tokenize.scm alt_unfold.scm parse.scm flatten.scm compile.scm readstdin.scm compile_lox_to_bytecode.scm
	cat span_w_pair_state.scm srfi1.scm trie.scm keyword_trie.scm tokenize.scm alt_unfold.scm parse.scm flatten.scm compile.scm readstdin.scm compile_lox_to_bytecode.scm > compile_lox_to_bytecode_concat.scm

keyword_test_trie_concat.scm: keyword_trie.scm srfi1.scm trie.scm trie_test.scm
	cat keyword_trie.scm srfi1.scm trie.scm trie_test.scm > keyword_test_trie_concat.scm

test_tokenize_concat.scm: span_w_pair_state.scm srfi1.scm trie.scm keyword_trie.scm tokenize.scm readstdin.scm prettyprint.scm test_tokenize.scm
	cat span_w_pair_state.scm srfi1.scm trie.scm keyword_trie.scm tokenize.scm readstdin.scm prettyprint.scm test_tokenize.scm > test_tokenize_concat.scm

test_alt_unfold_concat.scm: alt_unfold.scm test_alt_unfold.scm
	cat alt_unfold.scm test_alt_unfold.scm > test_alt_unfold_concat.scm

test1: test1.lox test_tokenize_concat.scm
	guile test_tokenize_concat.scm < test1.lox

test2: test2.lox test_tokenize_concat.scm
	guile test_tokenize_concat.scm < test2.lox

test3: test_alt_unfold_concat.scm
	guile test_alt_unfold_concat.scm

test4.output.txt: test4.lox test4.expected.txt compile_lox_to_bytecode_concat.scm
	guile compile_lox_to_bytecode_concat.scm < test4.lox > test4.output.txt
	cmp test4.output.txt test4.expected.txt

test5.output.txt: test5.lox test5.expected.txt compile_lox_to_bytecode_concat.scm
	guile compile_lox_to_bytecode_concat.scm < test5.lox > test5.output.txt
	cmp test5.output.txt test5.expected.txt

test6.output.txt: test6.lox test6.expected.txt compile_lox_to_bytecode_concat.scm
	guile compile_lox_to_bytecode_concat.scm < test6.lox > test6.output.txt
	cmp test6.output.txt test6.expected.txt

test7.output.txt: test7.lox test7.expected.txt compile_lox_to_bytecode_concat.scm
	guile compile_lox_to_bytecode_concat.scm < test7.lox > test7.output.txt
	cmp test7.output.txt test7.expected.txt

test8.output.txt: test8.lox test8.expected.txt compile_lox_to_bytecode_concat.scm
	guile compile_lox_to_bytecode_concat.scm < test8.lox > test8.output.txt
	cmp test8.output.txt test8.expected.txt

test9.output.txt: test9.lox test9.expected.txt compile_lox_to_bytecode_concat.scm
	guile compile_lox_to_bytecode_concat.scm < test9.lox > test9.output.txt
	cmp test9.output.txt test9.expected.txt

test10.output.txt: test10.lox test10.expected.txt compile_lox_to_bytecode_concat.scm
	guile compile_lox_to_bytecode_concat.scm < test10.lox > test10.output.txt
	cmp test10.output.txt test10.expected.txt

test11.output.txt: test11.lox test11.expected.txt compile_lox_to_bytecode_concat.scm
	guile compile_lox_to_bytecode_concat.scm < test11.lox > test11.output.txt
	cmp test11.output.txt test11.expected.txt

test12.output.txt: test12.lox test12.expected.txt compile_lox_to_bytecode_concat.scm
	guile compile_lox_to_bytecode_concat.scm < test12.lox > test12.output.txt
	cmp test12.output.txt test12.expected.txt
