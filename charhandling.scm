;;; Copyright (c) 2021-2022 Mark Jenkins <mark@markjenkins.ca>
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
;;;  - span_w_pair_state.scm

(define (isWhitespaceNotnewline c)
  (or (eqv? #\tab c)
      (eqv? #\linefeed c)
      (eqv? #\space c)) )

(define (isNewline c)
  (eqv? #\newline c))

(define (isNotNewline c)
  (not (isNewline c)))

(define (isWhitespace c)
  (or (isWhitespaceNotnewline c)
      (isNewline c)
      ))

(define (isNotWhitespace c)
  (not (isWhitespace c)))

(define (scan_non_whitespace_chars chars)
  (span_w_pair_ret isNotWhitespace chars))

;; assumption when calling this is that there are non-whitespace characters
;; at the start
;; worth fixing at some point...
;;
;; argument chars is a list of chars
;; returned is a list of strings
(define (whitespace_split chars)
  (reverse
   (let loop ( (scanresult (scan_non_whitespace_chars chars))
	       (accum '()) )
     (let* ( (foundstring (list->string (car scanresult)))
	     (remainingchars (cdr scanresult))
	     (exitresult (cons foundstring accum)) )
       (if (null? remainingchars)
	   exitresult ; terminal case
	   ;; otherwise we're skiping whitespace chars
	   (let whitespaceloop ( (afterwhitechars (cdr remainingchars)) )
	     (if (null? afterwhitechars)
		 exitresult ;; 
		 (if (isWhitespace (car afterwhitechars))
		     (whitespaceloop (cdr afterwhitechars))
		     (loop (scan_non_whitespace_chars afterwhitechars)
			   exitresult)))))))))

(define (newline_split_bottom_up chars)
  (let ( (initialspan (span_w_pair_ret isNotNewline chars)) )
    (if (null? (cdr initialspan))
	'() ; return empty list for empty input
	(let loop ( (spanresult initialspan)
		    (accum '()) )
	  (let* ((current_line (list->string (car spanresult) ))
		 (new_accum (cons current_line accum))
		 (remaining_chars (cdr spanresult)) )
	    (let newlineloop
		((remaining_chars_w_newline remaining_chars))
	      (cond ( (null? remaining_chars_w_newline)
		      new_accum ) ; base case, no more input chars
		    ( (isNewline (car remaining_chars_w_newline) )
		      (newlineloop (cdr remaining_chars_w_newline)) )
		    ( else (loop (span_w_pair_ret
				  isNotNewline
				  remaining_chars_w_newline)
				 new_accum )))))))))

(define (newline_split chars)
  (reverse (newline_split_bottom_up chars)))

(define (endswithchar teststr testchr)
  (eqv? (car (reverse (string->list teststr))) ; reverse and get the first char
	testchr))

(define (drop_trailing_char strtomod)
  (list->string (reverse (cdr (reverse (string->list strtomod))))))
