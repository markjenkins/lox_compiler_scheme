(define (span_w_pair_ret pred lstorig)
  (let ( (spanloopresult
	  (let spanloop ( (outlist '()) (lst lstorig))
	    (if (pair? lst)
		(if (pred (car lst))
		    (spanloop
		     (cons (car lst) outlist) ; outlist
		     (cdr lst) ) ; lst
		    (cons outlist lst) ) ; if pred fails
		(cons outlist lst) )))) ; if pair? fails
    (cons (reverse (car spanloopresult)) (cdr spanloopresult)) ))
