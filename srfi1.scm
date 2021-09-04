(cond-expand
 (srfi-1) ; do nothing if srfi1 support already present
 (guile
  (use-modules (srfi srfi-1)))
 ;; else provide the subset of srfi1 support this project requires
 (else
  (define first car)
  (define second cadr)
  (define third caddr)
  ;;; a simplified version without the optional tail argument
  ;;; from the guile documentation
  (define (unfold-right p f g seed)
    (let lp ((seed seed) (lis '() ))
      (if (p seed)
	  lis
	  (lp (g seed)
	      (cons (f seed) lis)))))
  (define (unfold p f g seed)
    (reverse (unfold-right p f g seed)))
  ;;; simple version only taking one list as argument
  (define (fold proc init lst)
    (let lp ((state init) (l lst))
      (if (pair? l)
	  (lp (proc (car l) state)
	      (cdr l))
	  state)))
  ))
