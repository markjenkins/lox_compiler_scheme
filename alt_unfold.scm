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
