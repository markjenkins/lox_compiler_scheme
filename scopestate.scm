(define (init_scope_state)
  (cons '() ; can_assign a null value until the place where set
	(cons 0 ; local_count
	      (cons 0 ; depth
		    '() )))) ; locals

(define scope_state_can_assign car)
(define scope_state_local_count cadr)
(define scope_state_depth caddr)
(define scope_state_locals cdddr)

(define (scope_state_change_can_assign scope_state can_assign)
  (cons can_assign (cdr scope_state)) )

(define (scope_state_change_depth scope_state new_depth)
  (cons (scope_state_can_assign scope_state)
	(cons (scope_state_local_count scope_state)
	      (cons new_depth
		    (scope_state_locals scope_state) ))))

(define (scope_state_increment_depth scope_state)
  (scope_state_change_depth scope_state
			    (+ 1 (scope_state_depth scope_state) )))
