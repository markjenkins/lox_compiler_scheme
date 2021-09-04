;(define (testf iteritem remainingiter)
;  (cons iteritem remainingiter) )
(define testf cons)

(display (alt_unfold_pairtest_p testf (list 1 2 3 4)) )
(newline)
