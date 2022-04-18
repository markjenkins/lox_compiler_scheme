;;; Copyright (c) 2021 Mark Jenkins <mark@markjenkins.ca>
;;;
;;; Permission is hereby granted, free of charge, to any person obtaining a copy
;;; of this software and associated documentation files (the "Software"), to
;;; deal in the Software without restriction, including without limitation the
;;; rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
;;; sell copies of the Software, and to permit persons to whom the Software is
;;; furnished to do so, subject to the following conditions:
;;;
;;; The above copyright notice and this permission notice shall be included in
;;; all copies or substantial portions of the Software.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
;;; IN THE SOFTWARE.

;;; this file requires
;;;  - alt_unfold.scm
;;;  - scopestate.scm
;;;  - parse.scm
;;;  - flatten.scm

(define (parse_expression_top_level token remaining_tokens)
  (parse_expression (init_scope_state) token remaining_tokens) )

(define (parse_and_compile_expression_to_opcodes tokens)
  (flatten_nested_list
   (reverse (cons (list "OP_RETURN" "\n")
		  (alt_unfold_right_pairtest_p
		   parse_expression_top_level tokens)))))

(define (parse_declaration_top_level token remaining_tokens)
  (parse_declaration_result_common_output
   (parse_declaration (init_scope_state) token remaining_tokens) ))

(define (parse_and_compile_to_opcodes tokens)
  (append
   (flatten_nested_list (alt_unfold_pairtest_p
			 parse_declaration_top_level tokens))
   (list "OP_RETURN" "\n")))
