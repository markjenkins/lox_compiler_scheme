(cond-expand
 (guile
  (use-modules (ice-9 pretty-print)) )
 (else
  (define pretty-print display) ) )
