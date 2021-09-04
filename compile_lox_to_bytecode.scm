;;; this file requires
;;;  - readstdin.scm
;;;  - tokenize.scm
;;;  - compile.scm

(for-each display
	  (parse_and_compile_to_opcodes (tokenize (read_all_stdin_chars))))
