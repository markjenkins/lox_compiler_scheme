(cond-expand
 (guile
  (use-modules (ice-9 pretty-print)) )
 (else
  (define pretty-print display) ) )

(pretty-print (tokenize (read_all_stdin_chars)))
