(define (init_scope_state)
  (cons #t ; can_assign
	(cons 0 ; local_count
	      (cons 0 ; depth
		    '() )))) ; locals

(define scope_state_can_assign car)
(define scope_state_local_count cadr)
(define scope_state_depth caddr)
(define scope_state_locals cdddr)
