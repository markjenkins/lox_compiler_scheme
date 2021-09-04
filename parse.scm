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
			 ( else (error "unexpected unary token type") ))
		   "\n"))
     (cdr parseprecresult) ) ))

(define (parse_binary bin_op_token following_token remaining_tokens)
  (let* ( (bin_op_tok_type (tokenType bin_op_token))
	  (binary_opcode (cond ( (eqv? 'TOKEN_PLUS bin_op_tok_type)
			      "OP_ADD" )
			    ( (eqv? 'TOKEN_MINUS bin_op_tok_type)
			      "OP_SUBTRACT" )
			    ( (eqv? 'TOKEN_STAR bin_op_tok_type)
			      "OP_MULTIPLY" )
			    ( (eqv? 'TOKEN_SLASH bin_op_tok_type)
			      "OP_DIVIDE" )
			    (else (error "unsupported bin op"))))
	  (parseprecedence_result
	   (parse_precedence
	    (+ 1
	       (parse_getPrecedenceRule bin_op_tok_type)) ; precedence
	    following_token ; token
	    remaining_tokens)) ; remaining_tokens
	  (outputsofar (car parseprecedence_result))
	  )
    (cons (append outputsofar (list binary_opcode "\n"))
	  (cdr parseprecedence_result) ) ))

(define (parse_number number_token following_token remaining_tokens)
  ;; return value is a pair consisting of
  ;; * first half, a list of opcodes generated here
  ;; * second half, the remaining tokens
  (cons (list "OP_CONSTANT" " " (tokenChars number_token) "\n")
	(cons following_token remaining_tokens)))

(define
  PRECEDENCE_RULES
  (list (cons 'TOKEN_LEFT_PAREN  (list parse_grouping '()          PREC_NONE))
	(cons 'TOKEN_RIGHT_PAREN (list '()            '()          PREC_NONE))
	(cons 'TOKEN_MINUS       (list parse_unary    parse_binary PREC_TERM))
	(cons 'TOKEN_PLUS        (list '()            parse_binary PREC_TERM))
	(cons 'TOKEN_SLASH       (list '()            parse_binary PREC_FACTOR))
	(cons 'TOKEN_STAR        (list '()            parse_binary PREC_FACTOR))
	(cons 'TOKEN_NUMERIC     (list  parse_number  '()          PREC_NONE))
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
