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

;;; this file requires srfi1.scm to come before it

(define (trie_fold_proc c state)
  (cond   ( (not state) #f ) ; propagate false if encounted

	  ;; if the current state of the trie structure is a list of lists
	  ;; we see if the current sub-list is a character match
	  ( (and (pair? state) (pair? (car state)))
	    (if (eqv? c (car (car state)))
		(cdr (car state))
		(trie_fold_proc c (cdr state)) ) )

	  ;; if the current state of the trie structure is a list with
	  ;; the next element not a symbol (which terminates the search)
	  ;; then it's a list of characters
	  ( (and (pair? state)
		 (not (symbol? (car state))) )
	    ;; if the character in the list is matching, then we pass on
	    ;; the remainder of the list as the next fold state
	    ;; otherwise, the character matching has failed and so has the
	    ;; search
	    (if (eqv? c (car state))
		(cdr state)
		#f))

	  ;; otherwise the search has failed, for example
	  ;; (and (pair? state) (symbol? (car state)))
	  ;; is a failure state because we've reached a terminal symbol
	  ;; but are still trying to match a character
	  (else #f) ))

(define (trie_lookup t chars)
  (let ( (foldresult
	  (fold trie_fold_proc t chars)))
    (if (and (pair? foldresult) (symbol? (car foldresult)))
	(car foldresult)
	#f) ))

