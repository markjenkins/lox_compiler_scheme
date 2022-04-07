;;; A derivitive work of https://craftinginterpreters.com
;;;
;;; Copyright (c) 2015 Robert Nystrom
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
;;;
;;; Ported to Scheme by
;;; @author Mark Jenkins <mark@markjenkins.ca>

;;; this file requires
;;;  - srfi1.scm

(define PREC_NONE 0)
(define PREC_ASSIGNMENT 1)  ; =
(define PREC_OR 2)         ; or
(define PREC_AND 3)        ; and
(define PREC_EQUALITY 4)   ; == !=
(define PREC_COMPARISON 5) ; < > <= >=
(define PREC_TERM 6)       ; + -
(define PREC_FACTOR 7)     ; * /
(define PREC_UNARY 8)      ; ! -
(define PREC_CALL 9)       ; . ()
(define PREC_PRIMARY 10)

(define (tokenMatch token type)
  (eq? (tokenType token) type))

(define (parse_grouping bracket_token following_token remaining_tokens)
  (let* ( (parseexprresult (parse_expression following_token
					     remaining_tokens))
	  (parseexproutput (car parseexprresult))
	  (parseexprafttokens (cdr parseexprresult)) )
    ;; this would be simpler if there were an EOF token
    (if (and (pair? parseexprafttokens)
	     (tokenMatch (car parseexprafttokens) 'TOKEN_RIGHT_PAREN))
	(cons parseexproutput
	      (cdr parseexprafttokens))
	(error ") token expected") ) ) )

(define (parse_unary unary_token following_token remaining_tokens)
  (let ( (parseprecresult (parse_precedence PREC_UNARY
					    following_token remaining_tokens)))
    ;; return value is a pair consisting first half, a list of the op codes
    ;; accumulated by parse_precedence + OP_NEGATE
    ;; second half of the pair is the list of remaining tokens not consumed
    (cons
     (append (car parseprecresult)
	     (list (cond ( (eq? (tokenType unary_token) 'TOKEN_MINUS)
			   "OP_NEGATE")
			 ( (eq? (tokenType unary_token) 'TOKEN_BANG)
			   "OP_NOT")
			 ( else (error "unexpected unary token type") ))
		   "\n"))
     (cdr parseprecresult) ) ))

(define (add_newline_after_each_helper sofar iter)
  (if (null? iter) sofar
      (add_newline_after_each_helper (cons "\n" (cons (car iter) sofar))
	    (cdr iter) )))

(define (add_newline_after_each lines)
  (reverse (add_newline_after_each_helper '() lines)))

(define (parse_binary bin_op_token following_token remaining_tokens)
  (let* ( (bin_op_tok_type (tokenType bin_op_token))
	  (binary_opcodes
	   (cond
	    ( (eqv? 'TOKEN_BANG_EQUAL bin_op_tok_type)
	      '("OP_EQUAL" "OP_NOT") )
	    ( (eqv? 'TOKEN_EQUAL_EQUAL bin_op_tok_type)
	      '("OP_EQUAL") )
	    ( (eqv? 'TOKEN_GREATER bin_op_tok_type)
	      '("OP_GREATER") )
	    ( (eqv? 'TOKEN_GREATER_EQUAL bin_op_tok_type)
	      '("OP_LESS" "OP_NOT") )
	    ( (eqv? 'TOKEN_LESS bin_op_tok_type)
	      '("OP_LESS") )
	    ( (eqv? 'TOKEN_LESS_EQUAL bin_op_tok_type)
	      '("OP_GREATER" "OP_NOT") )
	    ( (eqv? 'TOKEN_PLUS bin_op_tok_type)
	      '("OP_ADD") )
	    ( (eqv? 'TOKEN_MINUS bin_op_tok_type)
	      '("OP_SUBTRACT") )
	    ( (eqv? 'TOKEN_STAR bin_op_tok_type)
	      '("OP_MULTIPLY") )
	    ( (eqv? 'TOKEN_SLASH bin_op_tok_type)
	      '("OP_DIVIDE") )
	    (else (error "unsupported bin op"))))
	  (parseprecedence_result
	   (parse_precedence
	    (+ 1
	       (parse_getPrecedenceRule bin_op_tok_type)) ; precedence
	    following_token ; token
	    remaining_tokens)) ; remaining_tokens
	  (outputsofar (car parseprecedence_result))
	  )
    (cons (append outputsofar (add_newline_after_each binary_opcodes))
	  (cdr parseprecedence_result) ) ))

(define (parse_string string_token following_token remaining_tokens)
  ;; return value is a pair consisting of
  ;; * first half, a list of opcodes generated here
  ;; * second half, the remaining tokens
  (cons (list "OP_CONSTANT" " " "\"" (tokenChars string_token) "\"" "\n")
	(cons following_token remaining_tokens)))

(define (parse_number number_token following_token remaining_tokens)
  ;; return value is a pair consisting of
  ;; * first half, a list of opcodes generated here
  ;; * second half, the remaining tokens
  (cons (list "OP_CONSTANT" " " (tokenChars number_token) "\n")
	(cons following_token remaining_tokens)))

(define (make_parse_literal outputstr)
  (lambda (lit_token following_token remaining_tokens)
    (cons (list outputstr "\n")
	  (cons following_token remaining_tokens))))

(define parse_false (make_parse_literal "OP_FALSE"))
(define parse_nil (make_parse_literal "OP_NIL"))
(define parse_true (make_parse_literal "OP_TRUE"))

(define
  PRECEDENCE_RULES
  (list (cons 'TOKEN_LEFT_PAREN  (list parse_grouping '()          PREC_NONE))
	(cons 'TOKEN_RIGHT_PAREN (list '()            '()          PREC_NONE))
	(cons 'TOKEN_MINUS       (list parse_unary    parse_binary PREC_TERM))
	(cons 'TOKEN_PLUS        (list '()            parse_binary PREC_TERM))
	(cons 'TOKEN_SEMICOLON   (list '()            '()          PREC_NONE))
	(cons 'TOKEN_SLASH       (list '()            parse_binary PREC_FACTOR))
	(cons 'TOKEN_STAR        (list '()            parse_binary PREC_FACTOR))
	(cons 'TOKEN_BANG        (list parse_unary    '()          PREC_NONE))
	(cons 'TOKEN_BANG_EQUAL  (list '()          parse_binary PREC_EQUALITY))
	(cons 'TOKEN_EQUAL_EQUAL (list '()          parse_binary PREC_EQUALITY))
	(cons 'TOKEN_GREATER     (list '() parse_binary PREC_COMPARISON))
	(cons 'TOKEN_GREATER_EQUAL (list '() parse_binary PREC_COMPARISON))
	(cons 'TOKEN_LESS        (list '() parse_binary PREC_COMPARISON))
	(cons 'TOKEN_LESS_EQUAL  (list '() parse_binary PREC_COMPARISON))
	(cons 'TOKEN_STRING      (list  parse_string  '()          PREC_NONE))
	(cons 'TOKEN_NUMERIC     (list  parse_number  '()          PREC_NONE))
	(cons 'TOKEN_FALSE       (list  parse_false   '()          PREC_NONE))
	(cons 'TOKEN_NIL         (list  parse_nil     '()          PREC_NONE))
	(cons 'TOKEN_TRUE        (list  parse_true    '()          PREC_NONE))
	))

(define (parse_getPrefixRule type)
  (let ( (assqref_result (assv-ref PRECEDENCE_RULES type)))
    (if assqref_result
	(first assqref_result)
	(error "parse prefix rule lookup failure") ; should't happen
	)))

(define (parse_getInfixRule type)
  (let ( (assqref_result (assv-ref PRECEDENCE_RULES type)))
    (if assqref_result
	(second assqref_result)
	(error "parse infix rule lookup failure") ; should't happen
	)))

;;; parse_getPrecedenceRule looks up the precedence rule (third column)
;;; because we need to compare precedence rules, the actual integer
;;; from the define is returned and not a symbol like 'PREC_TERM
(define (parse_getPrecedenceRule type)
  (let ( (assqref_result (assv-ref PRECEDENCE_RULES type)))
    (if assqref_result
	(third assqref_result)
	(error "parse precedence rule lookup failure") ; should't happen
	)))

(define (parse_precedence_infix_loop precedence initlooptokens)
  (let precedenceloop ( (infixaccum '())
			(looptokens initlooptokens ))
    (if (and (pair? looptokens) ; why we should have TOKEN_EOF
	     (<= precedence (parse_getPrecedenceRule (tokenType
						      (car looptokens)))) )
	(let ( (infixcallresult
		( (parse_getInfixRule (tokenType
				       (car looptokens)) )
		  (car looptokens)
		  (second looptokens)   ; fail if we're out
		  (cddr looptokens) ) ) ) ; fail if we're out
	  (precedenceloop (cons
			   (car infixcallresult)
			   infixaccum)
			  (cdr infixcallresult) ) )
	(cons (reverse infixaccum)
	      looptokens) )) )

(define (parse_precedence precedence token remaining_tokens)
  ;; the assumption here is that we're called in a context where
  ;; a prefix rule is expected to be found
  (let ( (prefixrulefunc (parse_getPrefixRule (tokenType token))) )
    (if (pair? remaining_tokens) ; perhaps having TOKEN_EOF would clean this up
	(let* ( (prefixruleresult (prefixrulefunc
				   token
				   (car remaining_tokens)
				   (cdr remaining_tokens) ))
		(prefixruleoutput (car prefixruleresult))
		(tokensaftprefix (cdr prefixruleresult)) )
	  (if (pair? tokensaftprefix)
	      (let ( (infixresult
		      (parse_precedence_infix_loop
		       precedence tokensaftprefix)) )
		(cons (append prefixruleoutput (car infixresult))
		      (cdr infixresult) ))
	      prefixruleresult))

	;; if we're out of tokens, we just call the prefix rule and we're done
	;; some of these prefix rules will fail if we're out of tokens
	;; we could probably just call prefixrulefunc as per the first
	;; case if we had TOKEN_EOF defined, as there would be a
	;; (car remaining_tokens) item to pass
	(let ( (prefixruleresult
		(prefixrulefunc token '() '())) )
	  (cons (car prefixruleresult) '() ) ))))

(define (parse_expression token remaining_tokens)
  (parse_precedence PREC_ASSIGNMENT token remaining_tokens))

(define (check_semicolon tokens)
  (and (pair? tokens)
       (tokenMatch (car tokens) 'TOKEN_SEMICOLON)))

(define (consume_semicolon_provide_next_state tokens output_list error_msg)
  (if (check_semicolon tokens)
      (cons output_list (cdr tokens))
      (error error_msg)))

(define (parse_print_statement remaining_tokens)
  (if (not (pair? remaining_tokens))
      (error "token expected after print keyword")
      (let* ( (parseexprresult (parse_expression (car remaining_tokens)
						 (cdr remaining_tokens)))
	      (parseexproutput (car parseexprresult))
	      (parseexprafttokens (cdr parseexprresult)) )
	(consume_semicolon_provide_next_state
	 parseexprafttokens
	 (append parseexproutput (list "OP_PRINT" "\n"))
	 "semi-colon expected after statement") ) ) )

(define (parse_expression_statement token remaining_tokens)
  (let* ( (parseexprresult (parse_expression token remaining_tokens))
	  (parseexproutput (car parseexprresult))
	  (parseexprafttokens (cdr parseexprresult)) )
    (consume_semicolon_provide_next_state
     parseexprafttokens
     (append parseexproutput (list "OP_POP" "\n"))
     "semi-colon expected after statement") ))

(define (parse_statement token remaining_tokens)
  (cond ( (tokenMatch token 'TOKEN_PRINT)
	  (parse_print_statement remaining_tokens) )
	(else (parse_expression_statement token remaining_tokens))))

(define (parse_variable expected_identifier_token error_msg)
  (if (tokenMatch expected_identifier_token 'TOKEN_IDENTIFIER)
      (tokenChars expected_identifier_token)
      (error error_msg)))

(define (parse_var_declaration remaining_tokens)
  (if (not (pair? remaining_tokens))
      (error "token expected after print keyword")
      (let ( (var_name (parse_variable
			(car remaining_tokens)
			"Variable name expected after var declaration"))
	     (tokens_after_identifier (cdr remaining_tokens)))
	(cond ( (check_semicolon tokens_after_identifier)
		(cons
		 (list "OP_NIL" "\n" "OP_DEFINE_GLOBAL \"" var_name "\"\n")
		 (cdr tokens_after_identifier)))
	      ( (tokenMatch (car tokens_after_identifier) 'TOKEN_EQUAL)
		(let ( (parseexprresult
			 (parse_expression
			  (cadr tokens_after_identifier) ; token
			  (cddr tokens_after_identifier)
			  ))
			)
		  (consume_semicolon_provide_next_state
		   (cdr parseexprresult) ; tokens
		   ;; output_list
		   (append (car parseexprresult)
			   (list "OP_DEFINE_GLOBAL \"" var_name "\"\n"))
		   "semi colon expected after var declaration and assignment")))
	      (else (error "var form not supported")) ))))

(define (parse_declaration token remaining_tokens)
  (cond ( (tokenMatch token 'TOKEN_VAR)
	  (parse_var_declaration remaining_tokens))
	( else (parse_statement token remaining_tokens))))
