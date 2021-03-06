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

;;; Many of our parser functions return a pair consisting of the output so far
;;; and the remaining tokens
(define parse_result_output car)
(define parse_result_remaining_tokens cdr)

;;; some functions like parse_declaration parse_var_declaration
;;; have an additional element to extract for the variable name
(define parse_declaration_result_var_name car)
(define parse_declaration_result_common_output cdr)
(define parse_declaration_result_output cadr)
(define parse_declaration_result_remaining_tokens cddr)

(define (parse_grouping scope_state bracket_token following_token
			remaining_tokens)
  (let* ( (parseexprresult (parse_expression
			    (scope_state_append_jumplab scope_state "Ge")
			    following_token
			    remaining_tokens))
	  (parseexproutput (parse_result_output parseexprresult))
	  (parseexprafttokens (parse_result_remaining_tokens parseexprresult)) )
    ;; this would be simpler if there were an EOF token
    (if (and (pair? parseexprafttokens)
	     (tokenMatch (car parseexprafttokens) 'TOKEN_RIGHT_PAREN))
	(cons parseexproutput
	      (parse_result_remaining_tokens parseexprafttokens))
	(error ") token expected") ) ) )

(define (parse_unary scope_state unary_token following_token remaining_tokens)
  (let ( (parseprecresult (parse_precedence PREC_UNARY
					    scope_state
					    following_token remaining_tokens)))
    ;; return value is a pair consisting first half, a list of the op codes
    ;; accumulated by parse_precedence + OP_NEGATE
    ;; second half of the pair is the list of remaining tokens not consumed
    (cons
     (append (parse_result_output parseprecresult)
	     (list (cond ( (eq? (tokenType unary_token) 'TOKEN_MINUS)
			   "OP_NEGATE")
			 ( (eq? (tokenType unary_token) 'TOKEN_BANG)
			   "OP_NOT")
			 ( else (error "unexpected unary token type") ))
		   "\n"))
     (parse_result_remaining_tokens parseprecresult) ) ))

(define (add_newline_after_each_helper sofar iter)
  (if (null? iter) sofar
      (add_newline_after_each_helper (cons "\n" (cons (car iter) sofar))
	    (cdr iter) )))

(define (add_newline_after_each lines)
  (reverse (add_newline_after_each_helper '() lines)))

(define (parse_binary scope_state bin_op_token following_token remaining_tokens)
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
	    scope_state
	    following_token ; token
	    remaining_tokens)) ; remaining_tokens
	  (outputsofar (parse_result_output parseprecedence_result))
	  )
    (cons (append outputsofar (add_newline_after_each binary_opcodes))
	  (parse_result_remaining_tokens parseprecedence_result) ) ))

(define (parse_string scope_state string_token following_token remaining_tokens)
  ;; return value is a pair consisting of
  ;; * first half, a list of opcodes generated here
  ;; * second half, the remaining tokens
  (cons (list "OP_CONSTANT" " " "\"" (tokenChars string_token) "\"" "\n")
	(cons following_token remaining_tokens)))

(define (parse_number scope_state number_token following_token remaining_tokens)
  ;; return value is a pair consisting of
  ;; * first half, a list of opcodes generated here
  ;; * second half, the remaining tokens
  (cons (list "OP_CONSTANT" " " (tokenChars number_token) "\n")
	(cons following_token remaining_tokens)))

(define (make_parse_literal outputstr)
  (lambda (scope_state lit_token following_token remaining_tokens)
    (cons (list outputstr "\n")
	  (cons following_token remaining_tokens))))

(define parse_false (make_parse_literal "OP_FALSE"))
(define parse_nil (make_parse_literal "OP_NIL"))
(define parse_true (make_parse_literal "OP_TRUE"))

(define (parse_identifier scope_state identifier_token
			  following_token remaining_tokens)
  (let* ( (can_assign (scope_state_can_assign scope_state))
	  (can_assign_and_eq_follows
	   (and can_assign (tokenMatch following_token 'TOKEN_EQUAL)) )
	  (var_name (tokenChars identifier_token))
	  (global_var_return_value
	   (cons
	    (list "OP_GET_GLOBAL \"" var_name "\"\n")
	    (cons following_token remaining_tokens)) ))
    (if (scope_state_global scope_state)
	(if can_assign_and_eq_follows
	    (error "re-assignment of globals not supported by this compiler")
	    global_var_return_value)
	;; else a local
	;; fixme, should actually lookup the local and
	;; otherwise do OP_GET_GLOBAL
	(let ( (local_var_stack_slot
		(stack_slot_var scope_state var_name) ) )
	  (cond ( (and can_assign_and_eq_follows (pair? remaining_tokens))
		  (let* ( (parseexprresult
			   (parse_expression
			    (scope_state_append_jumplab scope_state "Ie")
			    (car remaining_tokens) ; token
			    (cdr remaining_tokens)) )
			  (parseexproutput (parse_result_output parseexprresult))
			  (parseexprafttokens (parse_result_remaining_tokens
					       parseexprresult)) )
		    (cons
		     (append parseexproutput
			     (list "OP_SET_LOCAL "
				   (number->string local_var_stack_slot)
				   "\n") )
		     parseexprafttokens)))
		( (and can_assign_and_eq_follows (null? remaining_tokens) )
		  (error "unexpected end of stream after =") )
		( (= LOCAL_NON_EXIST_DEPTH local_var_stack_slot)
		  global_var_return_value)
		( else (cons
			(list "OP_GET_LOCAL "
			      (number->string local_var_stack_slot)
			      "\n")
			(cons following_token remaining_tokens) )))))))

(define (parse_and scope_state and_op_token following_token remaining_tokens)
  (let* ((parse_and_rhs_result
	   (parse_precedence
	    PREC_AND
	    (scope_state_append_jumplab scope_state "A")
	    following_token remaining_tokens))
	 (and_rhs_output (car parse_and_rhs_result))
	 (after_and_rhs_remaining_tokens (cdr parse_and_rhs_result))
	 (and_failed_label (string-append
			    (scope_state_jmplabprefix scope_state)
			    "AF") ) )
    (cons (append
	   (list "OP_JUMP_IF_FALSE" " " "@" and_failed_label "\n"
		 "OP_POP" "\n")
	   and_rhs_output
	   (list and_failed_label ":" "\n") )
	  after_and_rhs_remaining_tokens) ))

(define (parse_or scope_state or_op_token following_token remaining_tokens)
  (let* ((parse_or_rhs_result
	   (parse_precedence
	    PREC_OR
	    (scope_state_append_jumplab scope_state "O")
	    following_token remaining_tokens))
	 (or_rhs_output (car parse_or_rhs_result))
	 (after_or_rhs_remaining_tokens (cdr parse_or_rhs_result))
	 (or_failed_label (string-append
			   (scope_state_jmplabprefix scope_state)
			   "OF"))
	 (or_passed_label (string-append
			    (scope_state_jmplabprefix scope_state)
			    "OP") ) )
    (cons (append
	   (list "OP_JUMP_IF_FALSE" " " "@" or_failed_label "\n")
	   (list "OP_JUMP" " " "@" or_passed_label "\n")
	   (list or_failed_label ":" "\n")
	   (list "OP_POP" "\n")
	   or_rhs_output
	   (list or_passed_label ":" "\n") )
	  after_or_rhs_remaining_tokens) ))

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
	(cons 'TOKEN_EQUAL       (list '() '() PREC_NONE))
	(cons 'TOKEN_EQUAL_EQUAL (list '()          parse_binary PREC_EQUALITY))
	(cons 'TOKEN_GREATER     (list '() parse_binary PREC_COMPARISON))
	(cons 'TOKEN_GREATER_EQUAL (list '() parse_binary PREC_COMPARISON))
	(cons 'TOKEN_LESS        (list '() parse_binary PREC_COMPARISON))
	(cons 'TOKEN_LESS_EQUAL  (list '() parse_binary PREC_COMPARISON))
	(cons 'TOKEN_IDENTIFIER  (list  parse_identifier '()         PREC_NONE))
	(cons 'TOKEN_STRING      (list  parse_string  '()          PREC_NONE))
	(cons 'TOKEN_NUMERIC     (list  parse_number  '()          PREC_NONE))
	(cons 'TOKEN_AND         (list  '()             parse_and  PREC_AND))
	(cons 'TOKEN_FALSE       (list  parse_false   '()          PREC_NONE))
	(cons 'TOKEN_OR          (list  '()             parse_or   PREC_OR))
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

(define (parse_precedence_infix_loop precedence scope_state initlooptokens)
  (let precedenceloop ( (infixaccum '())
			(looptokens initlooptokens )
			(infixLoopCount 1) )
    (if (and (pair? looptokens) ; why we should have TOKEN_EOF
	     (<= precedence (parse_getPrecedenceRule (tokenType
						      (car looptokens)))) )
	(let ( (infixcallresult
		( (parse_getInfixRule (tokenType
				       (car looptokens)) )
		  (scope_state_append_n_jumplab scope_state infixLoopCount)
		  (car looptokens)
		  (second looptokens)   ; fail if we're out
		  (cddr looptokens) ) ) ) ; fail if we're out
	  (precedenceloop (cons
			   (parse_result_output infixcallresult)
			   infixaccum)
			  (parse_result_remaining_tokens infixcallresult)
			  (+ 1 infixLoopCount) ) )
	(cons (reverse infixaccum)
	      looptokens) )) )

(define (parse_precedence precedence scope_state token remaining_tokens)
  ;; the assumption here is that we're called in a context where
  ;; a prefix rule is expected to be found
  (let ( (prefixrulefunc (parse_getPrefixRule (tokenType token))) )
    (if (pair? remaining_tokens) ; perhaps having TOKEN_EOF would clean this up
	(let* ( (can_assign_adjusted_scope_state
		 (scope_state_change_can_assign scope_state
				    (<= precedence PREC_ASSIGNMENT)) )
		(prefixruleresult (prefixrulefunc
				   (scope_state_append_jumplab
				    can_assign_adjusted_scope_state
				    "Px")
				   token
				   (car remaining_tokens)
				   (cdr remaining_tokens) ))
		(prefixruleoutput (parse_result_output prefixruleresult))
		(tokensaftprefix (parse_result_remaining_tokens
				  prefixruleresult)) )
	  (if (pair? tokensaftprefix)
	      (let ( (infixresult
		      (parse_precedence_infix_loop
		       precedence
		       (scope_state_append_jumplab
			can_assign_adjusted_scope_state
			"Ix")
		       tokensaftprefix)) )
		(if (and (scope_state_can_assign
			  can_assign_adjusted_scope_state)
			 (pair? (parse_result_remaining_tokens infixresult)) ;; TOKEN_EOF would help
			 (tokenMatch
			  (car (parse_result_remaining_tokens infixresult))
			  'TOKEN_EQUAL))
		    (error "Invalid assignment target")
		    (cons (append prefixruleoutput
				  (parse_result_output infixresult))
			  (parse_result_remaining_tokens infixresult)) ) )
	      prefixruleresult))

	;; if we're out of tokens, we just call the prefix rule and we're done
	;; some of these prefix rules will fail if we're out of tokens
	;; we could probably just call prefixrulefunc as per the first
	;; case if we had TOKEN_EOF defined, as there would be a
	;; (car remaining_tokens) item to pass
	(let ( (prefixruleresult
		(prefixrulefunc scope_state ; note no change to can_assign
				token '() '())) )
	  (cons (parse_result_output prefixruleresult) '() ) ))))

(define (parse_expression scope_state token remaining_tokens)
  (parse_precedence PREC_ASSIGNMENT scope_state token remaining_tokens))

(define (toss_expected_token tokens expected_token error_msg)
  (if (and (pair? tokens)
	   (tokenMatch (car tokens) expected_token) )
      (cdr tokens)
      (error error_msg) ))

(define (check_semicolon tokens)
  (and (pair? tokens)
       (tokenMatch (car tokens) 'TOKEN_SEMICOLON)))

(define (consume_semicolon_provide_next_state tokens output_list error_msg)
  (if (check_semicolon tokens)
      (cons output_list (cdr tokens))
      (error error_msg)))

(define (parse_print_statement scope_state remaining_tokens)
  (if (not (pair? remaining_tokens))
      (error "token expected after print keyword")
      (let* ( (parseexprresult (parse_expression
				(scope_state_append_jumplab scope_state "e")
				(car remaining_tokens)
				(cdr remaining_tokens)))
	      (parseexproutput (parse_result_output parseexprresult))
	      (parseexprafttokens (parse_result_remaining_tokens
				   parseexprresult)) )
	(consume_semicolon_provide_next_state
	 parseexprafttokens
	 (append parseexproutput (list "OP_PRINT" "\n"))
	 "semi-colon expected after statement") ) ) )

(define (parse_possible_else_clause scope_state tokens_after_if_statement)
  (if (or (null? tokens_after_if_statement)
	  (not (tokenMatch (car tokens_after_if_statement) 'TOKEN_ELSE)) )
      (cons '() tokens_after_if_statement)
      (if (pair? (cdr tokens_after_if_statement))
	  (parse_statement (scope_state_append_jumplab scope_state "elS")
			   (cadr tokens_after_if_statement)  ; token
			   (cddr tokens_after_if_statement)) ; remaining_tokens
	  (error "else statement without tokens that follow") )))

(define (parse_if_statement scope_state remaining_tokens)
  (let* ( (remaining_tokens_aft_paren
	   (toss_expected_token remaining_tokens 'TOKEN_LEFT_PAREN
				"Expect ( after if.") )
	  (parseexprresult (parse_expression
			    (scope_state_append_jumplab scope_state "e")
			    (car remaining_tokens_aft_paren)
			    (cdr remaining_tokens_aft_paren) ))
	  (parseexproutput (parse_result_output parseexprresult))
	  (parseexprafttokens (parse_result_remaining_tokens
			       parseexprresult))
	  (tokens_aft_close_paren
	   (toss_expected_token parseexprafttokens 'TOKEN_RIGHT_PAREN
				"Expect ) after condition in if."))
	  (first_token_after_close_paren
	   (if (pair? tokens_aft_close_paren) ; should have TOKEN_EOF..
	       (car tokens_aft_close_paren)
	       (error "premature end of input") ))
	  ;; relying on order of operation here to be sure cdr is avail
	  (remaining_tokens_after_close_paren (cdr tokens_aft_close_paren))
	  (parsestatementresult (parse_statement
				 (scope_state_append_jumplab scope_state "S")
				 first_token_after_close_paren
				 remaining_tokens_after_close_paren))
	  (parsestatementoutput (car parsestatementresult))
	  (tokens_after_statement (cdr parsestatementresult))
	  (after_if_jump_label (string-append
				(scope_state_jmplabprefix scope_state)
				"aftS"))
	  (after_else_jump_label (string-append
				  (scope_state_jmplabprefix scope_state)
				  "postEl"))
	  (parse_else_clause_result (parse_possible_else_clause
				     scope_state tokens_after_statement))
	  (else_statement_output (car parse_else_clause_result))
	  (tokens_after_else_statement (cdr parse_else_clause_result)) )
    (cons
     (append
      parseexproutput
      (list "OP_JUMP_IF_FALSE" " " (string-append "@" after_if_jump_label) "\n")
      (list "OP_POP" "\n") ; pop if expression from stack when condition true
      parsestatementoutput
      (list "OP_JUMP" " @" after_else_jump_label "\n")
      (list (string-append after_if_jump_label ":\n"))
      (list "OP_POP" "\n") ; pop if expression from stack when condition false
      else_statement_output ; may be an empty list, but append can handle that
      (list (string-append after_else_jump_label) ":\n") )
     tokens_after_else_statement) ))

(define (parse_while_statement scope_state remaining_tokens)
  (let* ( (remaining_tokens_aft_paren
	   (toss_expected_token remaining_tokens 'TOKEN_LEFT_PAREN
				"Expect ( after while.") )
	  (parseexprresult (parse_expression
			    (scope_state_append_jumplab scope_state "e")
			    (car remaining_tokens_aft_paren)
			    (cdr remaining_tokens_aft_paren) ))
	  (parseexproutput (parse_result_output parseexprresult))
	  (parseexprafttokens (parse_result_remaining_tokens
			       parseexprresult))
	  (tokens_aft_close_paren
	   (toss_expected_token parseexprafttokens 'TOKEN_RIGHT_PAREN
				"Expect ) after condition in while."))
	  (first_token_after_close_paren
	   (if (pair? tokens_aft_close_paren) ; should have TOKEN_EOF..
	       (car tokens_aft_close_paren)
	       (error "premature end of input") ))
	  ;; relying on order of operation here to be sure cdr is avail
	  (remaining_tokens_after_close_paren (cdr tokens_aft_close_paren))
	  (parsestatementresult (parse_statement
				 (scope_state_append_jumplab scope_state "S")
				 first_token_after_close_paren
				 remaining_tokens_after_close_paren))
	  (parsestatementoutput (car parsestatementresult))
	  (tokens_after_statement (cdr parsestatementresult))
	  (start_while_jump_label (string-append
				   (scope_state_jmplabprefix scope_state)
				   "stW"))
	  (after_while_jump_label (string-append
				(scope_state_jmplabprefix scope_state)
				"aftS")) )
    (cons
     (append
      (list start_while_jump_label ":" "\n")
      parseexproutput
      (list "OP_JUMP_IF_FALSE" " "
	    (string-append "@" after_while_jump_label)
	    "\n")
      (list "OP_POP" "\n") ; pop while expression from stack when condition true
      parsestatementoutput
      (list "OP_LOOP" " " "@" start_while_jump_label "\n")
      (list (string-append after_while_jump_label ":\n"))
      (list "OP_POP" "\n") ) ; pop while expression from stack when cond false
     tokens_after_statement) ))

(define (parse_expression_statement scope_state token remaining_tokens)
  (let* ( (parseexprresult (parse_expression
			    (scope_state_append_jumplab scope_state "Ex")
			    token remaining_tokens))
	  (parseexproutput (parse_result_output parseexprresult))
	  (parseexprafttokens (parse_result_remaining_tokens parseexprresult)) )
    (consume_semicolon_provide_next_state
     parseexprafttokens
     (append parseexproutput (list "OP_POP" "\n"))
     "semi-colon expected after statement") ))

(define (parse_statement scope_state token remaining_tokens)
  (cond ( (tokenMatch token 'TOKEN_PRINT)
	  (parse_print_statement (scope_state_append_jumplab scope_state "Pr")
				 remaining_tokens) )
	( (tokenMatch token 'TOKEN_IF)
	  (parse_if_statement (scope_state_append_jumplab scope_state "I")
			      remaining_tokens) )
	( (tokenMatch token 'TOKEN_WHILE)
	  (parse_while_statement (scope_state_append_jumplab scope_state "W")
				 remaining_tokens) )
	( (tokenMatch token 'TOKEN_LEFT_BRACE)
	  (parse_block (scope_state_append_jumplab scope_state "B")
		       remaining_tokens) )
	(else (parse_expression_statement scope_state token remaining_tokens))))

(define (parse_variable scope_state expected_identifier_token error_msg)
  (if (tokenMatch expected_identifier_token 'TOKEN_IDENTIFIER)
      (tokenChars expected_identifier_token)
      (error error_msg)))

(define (parse_var_declaration scope_state remaining_tokens)
  (if (not (pair? remaining_tokens))
      (error "token expected after var keyword")
      (let ( (var_name (parse_variable
			(scope_state_append_jumplab scope_state "v")
			(car remaining_tokens)
			"Variable name expected after var declaration"))
	     (tokens_after_identifier (cdr remaining_tokens)))
	(cond ( (check_semicolon tokens_after_identifier)
		(cons var_name
		      (cons (if (scope_state_global scope_state)
				(list "OP_NIL" "\n" "OP_DEFINE_GLOBAL \""
				      var_name "\"\n")
				(list "OP_NIL" "\n") )
			    (cdr tokens_after_identifier) )))
	      ( (tokenMatch (car tokens_after_identifier) 'TOKEN_EQUAL)
		(let ( (parseexprresult
			 (parse_expression
			  (scope_state_append_jumplab scope_state "e")
			  (cadr tokens_after_identifier) ; token
			  (cddr tokens_after_identifier)
			  ))
		       )
		  (cons
		   var_name
		   (consume_semicolon_provide_next_state
		    (parse_result_remaining_tokens parseexprresult) ; tokens
		    ;; output_list
		    (if (scope_state_global scope_state)
			(append (parse_result_output parseexprresult)
				(list "OP_DEFINE_GLOBAL \"" var_name "\"\n"))
			(parse_result_output parseexprresult) )
		    "semi colon expected after var declaration and assignment"
		    ))))
	      (else (error "var form not supported")) ))))

;;; parse_declaration returns a pair that is different from
;;; many of the other parse functions
;;; car of the result is any variable name if declared (otherwise #f)
;;; cdr of the result is the more typical output of a parse function
;;;
;;; The functions
;;;   - parse_declaration_result_var_name
;;;   - parse_declaration_result_output
;;;   - parse_declaration_result_remaining_tokens
;;; are available to access all of the components from a
;;; parse_declaration output
(define (parse_declaration scope_state token remaining_tokens)
  (cond ( (tokenMatch token 'TOKEN_VAR)
	  (parse_var_declaration
	   (scope_state_append_jumplab scope_state "V")
	   remaining_tokens))
	( else (cons #f (parse_statement
			 (scope_state_append_jumplab scope_state "S")
			 token
			 remaining_tokens)))))

(define (n_op_pop n)
  (let loop ( (popaccum '()) (count 0) )
    (if (= n count)
	popaccum
	(loop (cons "OP_POP" (cons "\n" popaccum)) (+ 1 count)) )))

(define (parse_block_loop scope_state initlooptokens)
  (let blockloop ( (block_loop_scope_state scope_state)
		   (blockaccum '())
		   (looptokens initlooptokens)
		   (new_local_var_count 0)
		   (blockloopcount 1) )
    (if (and (pair? looptokens) ; why we should have TOKEN_EOF
	     (not (tokenMatch (car looptokens) 'TOKEN_RIGHT_BRACE)) )
	(let ( (parse_declaration_result
		(parse_declaration
		 (scope_state_append_n_jumplab
		  block_loop_scope_state blockloopcount)
		 (car looptokens)
		 (cdr looptokens)) ) )
	  (blockloop (add_local_var_to_scope_state
		      block_loop_scope_state
		      (parse_declaration_result_var_name
		       parse_declaration_result))
		     (cons (parse_declaration_result_output
			    parse_declaration_result)
			   blockaccum)
		     (parse_declaration_result_remaining_tokens
		      parse_declaration_result)
		     (+ new_local_var_count
			(if (parse_declaration_result_var_name
			     parse_declaration_result)
			    1
			    0))
		     (+ 1 blockloopcount) ))
	(cons (append (reverse blockaccum)
		      (n_op_pop new_local_var_count) )
	      (if (pair? looptokens)
		  (cdr looptokens) ; drop TOKEN_RIGHT_BRACE
		  (error "Expect '}' after block.") )))))

(define (parse_block scope_state remaining_tokens)
  (parse_block_loop (scope_state_increment_depth scope_state) remaining_tokens))
