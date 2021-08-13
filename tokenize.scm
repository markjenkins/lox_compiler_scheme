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

(define tokenLineNum caddr)

;;; we don't include '/' (TOKEN_SLASH) because that might be the start of
;;; a comment
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
    (#\* . TOKEN_STAR)
	) )

(define START_OF_TWO_CHAR_TOKENS
  '( (#\! . (TOKEN_BANG_EQUAL . TOKEN_BANG) )
     (#\= . (TOKEN_EQUAL_EQUAL . TOKEN_EQUAL) )
     (#\< . (TOKEN_LESS_EQUAL . TOKEN_LESS) )
     (#\> . (TOKEN_GREATER_EQUAL . TOKEN_GREATER) )
     ))

(define (isWhitespaceNotnewline c)
  (or (eqv? #\tab c)
      (eqv? #\linefeed c)
      (eqv? #\space c)) )

(define (isNewline c)
  (eqv? #\newline c))

(define (isWhitespace c)
  (or (isWhitespaceNotnewline c)
      (isNewline c)
      ))

;;; skip whitespace counting new lines, returns a pair with
;;; the car being the remaining characters after the whitespace (or empty list)
;;; and the cdr being the count of newlines found
(define (skipWhitespaceCountingNewlines origchars)
  (let skipwhitespace_loop ( (chars origchars) (count 0) )
    (if (null? chars)
	(cons chars count)
	(let ( (c (car chars)) )
	  (cond ( (isNewline c)
		  (skipwhitespace_loop (cdr chars) (+ count 1) ) )
		( (isWhitespaceNotnewline c)
		  (skipwhitespace_loop (cdr chars) count) )
		( else (cons chars count) ) ))) ))

(define (skipToNewlineOrEOF chars)
  (let ( (c (car chars) ) )
    (if (or (isNewline c) (null? c) )
	chars
	(skipToNewlineOrEOF (cdr chars)) )))

(define (accumulateStringToken origchars origlinenum)
  (let stringscan_loop ( (charbuffer '())
			 (chars origchars)
			 (linenum origlinenum) )
    (if (null? chars)
	(error "unterminated string starting on line" origlinenum
	       "and ending on line" linenum)
	(let ( (c (car chars)) )
	  (cond ( (isNewline c)
		  (stringscan_loop (cons c charbuffer)
				   (cdr chars)
				   (+ 1 linenum)))
		;; terminal case on our loop, return the string token
		;; and the remaining character buffer as a pair
		( (eqv? #\" c)
		  (cons
		   (makeToken 'TOKEN_STRING ; type
			      (list->string (reverse charbuffer)) ; chars
			      linenum)
		   (cdr chars) ) )

		;; all other characters are pre-pended to charbuffer and
		;; we keep looping
		(else (stringscan_loop (cons c charbuffer)
				       (cdr chars)
				       linenum)) )))))

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

	   (cond ( (assv c SINGLE_CHAR_TOKENS) ; if c is a single char token
		   (tokenizeloop
		    (cons (makeToken (cdr (assv c SINGLE_CHAR_TOKENS)) ; type
				     (string c) ; chars
				     linenum) ; makeToken
			  tokenslist) ; tokenslist
		    remaining_chars ; charlist
		    linenum) ; tokenize loop
		   ) ; single_character condition

		 ;; if c is potentially the start of a two char token
		 ( (assv c START_OF_TWO_CHAR_TOKENS)
		   (let ( (isTwoChar
			   (and (not (null? remaining_chars))
				(eqv? (car remaining_chars) #\= )
				)))
		     (tokenizeloop
		      (cons (makeToken
			     (if isTwoChar
				 (cadr (assv c START_OF_TWO_CHAR_TOKENS))
				 (cddr (assv c START_OF_TWO_CHAR_TOKENS))); type
			     (if isTwoChar
				 (string c (car remaining_chars))
				 (string c)) ; chars
			     linenum) ; makeToken
			    tokenslist) ; tokenslist
		      (if isTwoChar
			  (cdr remaining_chars)
			  remaining_chars) ; chars
		      linenum) ; tokenizeloop
		     ) ; let ( (isTwoChar))
		    ) ; potential two char condition

		 ;; if c is whitespace, pass the remaining characters,
		 ;; including character c into our whitespace skip and newline
		 ;; count function. (c included because it might be newline)
		 ( (isWhitespace c)
		   (let ( (whitespaceskippair
			   (skipWhitespaceCountingNewlines charlist) ) )
		     (tokenizeloop
		      tokenslist ; tokenslist
		      (car whitespaceskippair) ; remaining chars after skip
		      (+ linenum (cdr whitespaceskippair))))) ; linenum

		 ;; check for comment on remainder of line if next char is /
		 ;; if this isn't the start of //, then we have
		 ;; TOKEN_SLASH
		 ( (eqv? #\/ c)
		   (if (eqv? #\/ (car remaining_chars))
		       (tokenizeloop
			tokenslist
			(skipToNewlineOrEOF (cdr remaining_chars))
			linenum)
		       ;; case of a slash followed by something else
		       (tokenizeloop
			(cons
			 (makeToken 'TOKEN_SLASH ; type
				    (string c) ; chars
				    linenum) ; (makeToken)
			 tokenslist) ; cons, tokenslist arg to (tokenizeloop)
			remaining_chars
			linenum)))

		 ( (eqv? #\" c)
		   (let ( (stringscanpair
			   (accumulateStringToken remaining_chars linenum)) )
		     (tokenizeloop
		      (cons (car stringscanpair) tokenslist) ; tokenslist
		      (cdr stringscanpair) ; charlist
		      (tokenLineNum (car stringscanpair)) ; linenum
		      )))
		 
		 (else (tokenizeloop
			tokenslist remaining_chars linenum))
		 ) ; cond
	   ) ; let
	 ) ; if
     ) ; let tokenizeloop
   ) ; reverse
  ) ; define

