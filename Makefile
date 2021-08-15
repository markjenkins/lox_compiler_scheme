compile_lox_to_bytecode_concat.scm: span_w_pair_state.scm tokenize.scm compile_lox_to_bytecode.scm
	cat span_w_pair_state.scm tokenize.scm compile_lox_to_bytecode.scm > compile_lox_to_bytecode_concat.scm

test1: compile_lox_to_bytecode_concat.scm
	guile compile_lox_to_bytecode_concat.scm < test1.lox
