;;; Single-character tokens.
(define TOKEN_LEFT_PAREN 0)
(define TOKEN_RIGHT_PAREN 1)
(define TOKEN_LEFT_BRACE 2)
(define TOKEN_RIGHT_BRACE 3)
(define TOKEN_COMMA 4)
(define TOKEN_DOT 5)
(define TOKEN_MINUS 6)
(define TOKEN_PLUS 7)
(define TOKEN_SEMICOLON 8)
(define TOKEN_SLASH 9)
(define TOKEN_STAR 10)

;;; One or two character tokens.
(define TOKEN_BANG 11)
(define TOKEN_BANG_EQUAL 12)
(define TOKEN_EQUAL 13)
(define TOKEN_EQUAL_EQUAL 14)
(define TOKEN_GREATER 15)
(define TOKEN_GREATER_EQUAL 16)
(define TOKEN_LESS 17)
(define TOKEN_LESS_EQUAL 18)

;;; Literals.
(define TOKEN_IDENTIFIER 19)
(define TOKEN_STRING 20)
(define TOKEN_NUMBER 21)

;;; Keywords.
(define TOKEN_AND 22)
(define TOKEN_CLASS 23)
(define TOKEN_ELSE 24)
(define TOKEN_FALSE 25)
(define TOKEN_FOR 26)
(define TOKEN_FUN 27)
(define TOKEN_IF 28)
(define TOKEN_NIL 29)
(define TOKEN_OR 30)
(define TOKEN_PRINT 31)
(define TOKEN_RETURN 32)
(define TOKEN_SUPER 33)
(define TOKEN_THIS 34)
(define TOKEN_TRUE 35)
(define TOKEN_VAR 36)
(define TOKEN_WHILE 37)

;;; utility tokens
(define TOKEN_ERROR 38)
;;; TOKEN EOF won't be needed becaue out token list is going to be a
;;; standard scheme list that ends with '()
;;;(define TOKEN_EOF 39)

(define (makeToken type chars linenum)
  (list type chars linenum) )

(define SINGLE_CHAR_TOKENS
 '( (#\( . TOKEN_LEFT_PAREN)
    (#\) . TOKEN_RIGHT_PAREN)
    (#\{ . TOKEN_LEFT_BRACE)
    (#\} . TOKEN_RIGHT_BRACE)
    (#\; . TOKEN_SEMICOLON)
    (#\, . TOKEN_COMMA)
    (#\. . TOKEN_DOT)
    (#\- . TOKEN_MINUS)
    (#\+ . TOKEN_PLUS)
    (#\/ . TOKEN_SLASH)
    (#\* . TOKEN_STAR)
	) )

(define (tokenize fullcharlist)
  (reverse
   (let tokenizeloop ( (tokenslist '())
		       (charlist fullcharlist)
		       (linenum 1) )
     (if (null? charlist)
	 tokenslist
	 (let ( (c (car charlist))
		(remaining_chars (cdr charlist))
		) ; end of let variables
	   (cond ( (assv c SINGLE_CHAR_TOKENS)
		   (tokenizeloop
		    (cons (makeToken (cdr (assv c SINGLE_CHAR_TOKENS)) ; type
				     (list c) ; chars
				     linenum) ; makeToken
			  tokenslist) ; tokenslist
		    remaining_chars ; charlist
		    linenum) ; tokenize loop
		   ) ; single_character condition
		 
		 (else (tokenizeloop
			tokenslist remaining_chars linenum))
		 ) ; cond
	   ) ; let
	 ) ; if
     ) ; let tokenizeloop
   ) ; reverse
  ) ; define

