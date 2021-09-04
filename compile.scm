;;; this file requires
;;;  - alt_unfold.scm
;;;  - parse.scm
;;;  - flatten.scm

(define (parse_and_compile_expression_to_opcodes tokens)
  (flatten_nested_list
   (reverse (cons (list "OP_RETURN" "\n")
		  (alt_unfold_right_pairtest_p parse_expression tokens)))))

(define (parse_and_compile_to_opcodes tokens)
  (parse_and_compile_expression_to_opcodes tokens))
