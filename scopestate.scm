;;; A derivitive work of https://craftinginterpreters.com
;;;
;;; Copyright (c) 2015 Robert Nystrom
;;; Copyright (c) 2022 Mark Jenkins <mark@markjenkins.ca>
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
;;;
;;; Ported to Scheme by
;;; @author Mark Jenkins <mark@markjenkins.ca>

(define (init_scope_state)
  (cons '() ; can_assign a null value until the place where set
	(cons 0 ; local_count
	      (cons 0 ; depth
		    '() )))) ; locals

(define scope_state_can_assign car)
(define scope_state_local_count cadr)
(define scope_state_depth caddr)
(define scope_state_locals cdddr)

(define scope_state_local_var_name car)
(define scope_state_local_depth cdr)

(define scope_state_locals_top_name caar)
(define scope_state_locals_top_depth cdar)

(define LOCAL_NON_EXIST_DEPTH -1)

(define (scope_state_change_can_assign scope_state can_assign)
  (cons can_assign (cdr scope_state)) )

(define (scope_state_change_depth scope_state new_depth)
  (cons (scope_state_can_assign scope_state)
	(cons (scope_state_local_count scope_state)
	      (cons new_depth
		    (scope_state_locals scope_state) ))))

(define (scope_state_increment_depth scope_state)
  (scope_state_change_depth scope_state
			    (+ 1 (scope_state_depth scope_state) )))

(define (scope_state_global scope_state)
  (= (scope_state_depth scope_state) 0) )

(define (depth_var_defined_loop scope_state_locals var_match)
  (cond ( (null? scope_state_locals) LOCAL_NON_EXIST_DEPTH )
	( (equal? var_match (scope_state_locals_top_name scope_state_locals))
	  (scope_state_locals_top_depth scope_state_locals) )
	(else (depth_var_defined_loop (cdr scope_state_locals) var_match) ) ) )

(define (depth_var_defined scope_state var_match)
  (depth_var_defined_loop (scope_state_locals scope_state) var_match))

(define (stack_slot_var scope_state var_match)
  (let loop ( (loop_scope_state_locals (scope_state_locals scope_state))
	      (loop_stack_position (- (scope_state_local_count scope_state) 1)))
    (cond ( (null? loop_scope_state_locals) LOCAL_NON_EXIST_DEPTH )
	  ( (equal? var_match (scope_state_locals_top_name
			       loop_scope_state_locals))
	    loop_stack_position )
	  ( else (loop (cdr loop_scope_state_locals)
		       (- loop_stack_position 1))) )))

(define (add_local_var_to_scope_state scope_state var_name)
  (cond ( (scope_state_global scope_state) scope_state) ; ignore globals
	;; ignore declarations that were not var declarations [var_name is #f]
	( (not var_name) scope_state)
	( (= (depth_var_defined scope_state var_name)
	     (scope_state_depth scope_state) )
	  (error "you can not re-define a local var in the same scope") )
	( else
	  (cons (scope_state_can_assign scope_state)
		;; do we even need to count the locals when we are planning
		;; to handle stack-depth > 256 with a different op_code
		;; later on with a second pass compiler that replaces
		;; opcodes using constants greater than 1 byte
		(cons (+ 1 (scope_state_local_count scope_state))
		      (cons (scope_state_depth scope_state)
			    (cons (cons var_name
					(- (scope_state_depth scope_state) 1))
				  (scope_state_locals scope_state) )))))))
