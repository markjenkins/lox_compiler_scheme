LOX_COMPILE_AND_EXPR_EVAL_TEST_NUMS = $(shell seq 4 39)
LOX_COMPILE_AND_EXPR_EVAL_TESTS = $(foreach i,$(LOX_COMPILE_AND_EXPR_EVAL_TEST_NUMS),test$(i).lox.output.txt)
LOX_COMPILE_AND_EXPR_EVAL_TESTS_GCC = $(foreach i,$(LOX_COMPILE_AND_EXPR_EVAL_TEST_NUMS),test$(i).output.gcc.txt)

LOX_COMPILE_AND_DECL_EVAL_TEST_NUMS = $(shell seq 40 57)
LOX_COMPILE_AND_DECL_EVAL_TESTS = $(foreach i,$(LOX_COMPILE_AND_DECL_EVAL_TEST_NUMS),test$(i).lox.decl_output.txt)
LOX_COMPILE_AND_DECL_EVAL_TESTS_GCC = $(foreach i,$(LOX_COMPILE_AND_DECL_EVAL_TEST_NUMS),test$(i).decl_output.gcc.txt)

tests: $(LOX_COMPILE_AND_EXPR_EVAL_TESTS) $(LOX_COMPILE_AND_EXPR_EVAL_TESTS_GCC) $(LOX_COMPILE_AND_DECL_EVAL_TESTS) $(LOX_COMPILE_AND_DECL_EVAL_TESTS_GCC)

%.lox.output.txt.d:
	echo $(@:lox.output.txt.d=lox.output.txt) $@: ../../tests/$(@:lox.output.txt.d=expected.txt) $(@:output.txt.d=expected.txt) ../exprprint.x86 > $@

%.lox.decl_output.txt.d:
	echo $(@:lox.decl_output.txt.d=lox.decl_output.txt) $@: ../../tests/$(@:lox.decl_output.txt.d=expected.txt) $(@:decl_output.txt.d=expected.txt) ../declprint.x86 > $@

%.output.gcc.txt.d:
	echo $(@:txt.d=txt) $@: ../../tests/$(@:output.gcc.txt.d=expected.txt) $(@:output.gcc.txt.d=lox.expected.txt) ../exprprint.gcc > $@

%.decl_output.gcc.txt.d:
	echo $(@:txt.d=txt) $@: ../../tests/$(@:decl_output.gcc.txt.d=expected.txt) $(@:decl_output.gcc.txt.d=lox.expected.txt) ../declprint.gcc > $@

%.lox.output.txt: ../../tests/%.expected.txt
	../../exprprint.bash $< > $@
	cmp $(subst .output.txt,,$@).expected.txt $@

%.lox.decl_output.txt: ../../tests/%.expected.txt
	../../declprint.bash $< > $@
	cmp $(subst .decl_output.txt,,$@).expected.txt $@

%.output.gcc.txt: ../../tests/%.expected.txt
	../exprprint.gcc < $< > $@
	cmp $(subst .output.gcc.txt,,$@).lox.expected.txt $@

%.decl_output.gcc.txt: ../../tests/%.expected.txt
	../declprint.gcc < $< > $@
	cmp $(subst .decl_output.gcc.txt,,$@).lox.expected.txt $@

include $(LOX_COMPILE_AND_EXPR_EVAL_TESTS:.txt=.txt.d)
include $(LOX_COMPILE_AND_EXPR_EVAL_TESTS_GCC:.txt=.txt.d)
include $(LOX_COMPILE_AND_DECL_EVAL_TESTS:.txt=.txt.d)
include $(LOX_COMPILE_AND_DECL_EVAL_TESTS_GCC:.txt=.txt.d)
