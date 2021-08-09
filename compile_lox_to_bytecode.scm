;;; with guile, import a guile specific pretty-print, otherwise just use display
(cond-expand
 (guile
  (use-modules (ice-9 pretty-print)) )
 (else
  (define pretty-print display) ) )

(define (read_all_stdin_chars)
  (reverse
   (let readnext ((charlist '() ))
     (let ( (c (read-char)) )
       (if (eof-object? c)
	   charlist
	   (readnext (cons c charlist)) )))))

(pretty-print (tokenize (read_all_stdin_chars)))
