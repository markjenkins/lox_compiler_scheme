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

(define (string-append-number s n)
  (string-append s (number->string n)) )

(define topjumpcounter 0)

;;; This is the only place where we use set!, which adds an additional
;;; requirement for minimal implementations.
;;;
;;; Technically this is avoidable, the loops in
;;; parse_and_compile_expression_to_opcodes and
;;; parse_and_compile_to_opcodes tokens from parse.scm
;;; could keep track of the same
;;;
;;; The rest of the program (in parse.scm), we're going to build out the
;;; jump labels based on the code path and loop iterations and not rely
;;; on global state. The goal will be to ensure that all jump labels are
;;; unique. In another compiler pass we will remove the jump labels and
;;; replace the jump labels with relative offsets. Any integers put
;; in the jump labels are not intended to reflect their relative location
;;;
;;; So, getting rid of this set! may just be a small patch
(define (nexttopjumpcounter)
  (set! topjumpcounter (+ 1 topjumpcounter))
  topjumpcounter )

(define (newtopjumplab)
  (string-append-number "jmplab" (nexttopjumpcounter) ))

(define (construct_scope_state can_assign jmplabprefix local_count depth locals)
  (cons can_assign
	(cons jmplabprefix
	      (cons local_count
		    (cons depth
			  locals )))))

(define (init_scope_state)
  (construct_scope_state
   '() ; can_assign a null value until the place where set
   (newtopjumplab)
    0  ; local_count
    0  ; depth
    '() ))

(define scope_state_can_assign car)
(define scope_state_jmplabprefix cadr)
(define scope_state_local_count caddr)
(define scope_state_depth cadddr)
(define scope_state_locals cddddr)

(define scope_state_local_var_name car)
(define scope_state_local_depth cdr)

(define scope_state_locals_top_name caar)
(define scope_state_locals_top_depth cdar)

(define LOCAL_NON_EXIST_DEPTH -1)

(define (scope_state_change_can_assign scope_state can_assign)
  (cons can_assign (cdr scope_state)) )

(define (scope_state_append_jumplab scope_state strappend)
  (construct_scope_state (scope_state_can_assign scope_state)  ; can_assign
			 (string-append
			  (scope_state_jmplabprefix scope_state)
			  strappend)                           ; jmplabprefix
			 (scope_state_local_count scope_state) ; local_count
			 (scope_state_depth scope_state)       ; depth
			 (scope_state_locals scope_state) ))   ; locals

(define (scope_state_append_n_jumplab scope_state n)
  (scope_state_append_jumplab scope_state (number->string n)))

(define (scope_state_change_depth scope_state new_depth)
  (construct_scope_state
   (scope_state_can_assign scope_state)  ;; can_assign
   (scope_state_jmplabprefix scope_state) ;; jmplabprefix
   (scope_state_local_count scope_state) ;; local_count
   new_depth ;; depth
   (scope_state_locals scope_state) )) ;; locals

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

(define (scope_state_get_locals_and_add_var scope_state var_name var_depth)
  ;; outer pair is scope_state_locals being pre-pended
  ;; inner pair is variable name and its depth
  (cons
   (cons var_name var_depth)
   (scope_state_locals scope_state) ))

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
	  (construct_scope_state
	   (scope_state_can_assign scope_state) ;; can_assign
	   (scope_state_jmplabprefix scope_state) ;; jmplabprefix
	   (+ 1 (scope_state_local_count scope_state)) ;; local_count
	   (scope_state_depth scope_state) ;; depth
	   (scope_state_get_locals_and_add_var ;; locals
	    scope_state
	    var_name
	    (- (scope_state_depth scope_state) 1) ) ))))
