all: bytecode_interpreter compile_lox_to_bytecode_concat.scm

LOX_COMPILE_AND_EVAL_TESTS = $(shell for i in `seq 4 13`; do echo test$$i.lox.output.txt; done)

tests: $(LOX_COMPILE_AND_EVAL_TESTS)

%_concat.scm:
	cat $^ > $@

compile_lox_to_bytecode_concat.scm: span_w_pair_state.scm srfi1.scm trie.scm keyword_trie.scm tokenize.scm alt_unfold.scm parse.scm flatten.scm compile.scm readstdin.scm compile_lox_to_bytecode.scm
keyword_test_trie_concat.scm: keyword_trie.scm srfi1.scm trie.scm trie_test.scm
test_tokenize_concat.scm: span_w_pair_state.scm srfi1.scm trie.scm keyword_trie.scm tokenize.scm readstdin.scm prettyprint.scm test_tokenize.scm
test_alt_unfold_concat.scm: alt_unfold.scm test_alt_unfold.scm


test1: test1.lox test_tokenize_concat.scm
	guile test_tokenize_concat.scm < test1.lox

test2: test2.lox test_tokenize_concat.scm
	guile test_tokenize_concat.scm < test2.lox

test3: test_alt_unfold_concat.scm
	guile test_alt_unfold_concat.scm


%.output.txt: %.lox
	guile compile_lox_to_bytecode_concat.scm < $< > $@
	cmp $@ $(basename $<).expected.txt

test4.output.txt: test4.lox test4.expected.txt compile_lox_to_bytecode_concat.scm
test5.output.txt: test5.lox test5.expected.txt compile_lox_to_bytecode_concat.scm
test6.output.txt: test6.lox test6.expected.txt compile_lox_to_bytecode_concat.scm
test7.output.txt: test7.lox test7.expected.txt compile_lox_to_bytecode_concat.scm
test8.output.txt: test8.lox test8.expected.txt compile_lox_to_bytecode_concat.scm
test9.output.txt: test9.lox test9.expected.txt compile_lox_to_bytecode_concat.scm
test10.output.txt: test10.lox test10.expected.txt compile_lox_to_bytecode_concat.scm
test11.output.txt: test11.lox test11.expected.txt compile_lox_to_bytecode_concat.scm
test12.output.txt: test12.lox test12.expected.txt compile_lox_to_bytecode_concat.scm
test13.output.txt: test13.lox test13.expected.txt compile_lox_to_bytecode_concat.scm

%.lox.output.txt: %.lox
	./exprprint.bash $(basename $<).output.txt > $@
	cmp $<.expected.txt $@
	bytecode_interpreter/exprprint.gcc < $(basename $<).output.txt > $<.output.gcc.txt
	cmp $<.expected.txt $<.output.gcc.txt

test4.lox.output.txt: test4.lox test4.output.txt test4.lox.expected.txt bytecode_interpreter

test5.lox.output.txt: test5.lox test5.output.txt test5.lox.expected.txt bytecode_interpreter

test6.lox.output.txt: test6.lox test6.output.txt test6.lox.expected.txt bytecode_interpreter

test7.lox.output.txt: test7.lox test7.output.txt test7.lox.expected.txt bytecode_interpreter

test8.lox.output.txt: test8.lox test8.output.txt test8.lox.expected.txt bytecode_interpreter

test9.lox.output.txt: test9.lox test9.output.txt test9.lox.expected.txt bytecode_interpreter

test10.lox.output.txt: test10.lox test10.output.txt test10.lox.expected.txt bytecode_interpreter

test11.lox.output.txt: test11.lox test11.output.txt test11.lox.expected.txt bytecode_interpreter

test12.lox.output.txt: test12.lox test12.output.txt test12.lox.expected.txt bytecode_interpreter

test13.lox.output.txt: test13.lox test13.output.txt test13.lox.expected.txt bytecode_interpreter

bytecode_interpreter:
	$(MAKE) -C $@

.PHONY: tests bytecode_interpreter
