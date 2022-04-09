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
