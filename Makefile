compile_lox_to_bytecode_concat.scm: tokenize.scm compile_lox_to_bytecode.scm
	cat tokenize.scm compile_lox_to_bytecode.scm > compile_lox_to_bytecode_concat.scm
