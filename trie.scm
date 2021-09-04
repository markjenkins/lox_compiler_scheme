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

