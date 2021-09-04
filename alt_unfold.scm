;;; an alternative aproach to unfold that only uses one
;;; next state transformation function

;;; p is the predicate , called with current item, remaining iter
;;; (p iteritem remainingiter)
;;;
;;; f the state transform fuction returns as a pair the item to add to the
;;; output list and the new state of itersource for the next iteration
;;; (f iteritem remainingiter)
(define (alt_unfold_right_internal p f itersource outputlist)
  (if (pair? itersource)
      (let ( (iteritem (car itersource))
	     (remainingiter (cdr itersource)) )
	(if (p iteritem remainingiter)
	    (let* ( (f_result (f iteritem remainingiter ))
		    (output_item (car f_result))
		    (newitersource (cdr f_result)) )
	      (alt_unfold_right_internal
	       p f newitersource (cons output_item outputlist)) )
	    outputlist)) ; terminal case for alt_unfold_right_internal recursion
      outputlist))

(define (alt_unfold_right p f itersource)
  (alt_unfold_right_internal p f itersource '()))

(define (alt_unfold p f itersource)
  (reverse (alt_unfold_right p f itersource)))

(define (alt_unfold_skip_predicate iteritem remainingiter)
  #t)

(define (alt_unfold_pairtest_p f itersource)
  (alt_unfold alt_unfold_skip_predicate f itersource) )

(define (alt_unfold_right_pairtest_p f itersource)
  (alt_unfold_right alt_unfold_skip_predicate f itersource) )
