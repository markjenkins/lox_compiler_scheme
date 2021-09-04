(define (read_all_stdin_chars)
  (reverse
   (let readnext ((charlist '() ))
     (let ( (c (read-char)) )
       (if (eof-object? c)
	   charlist
	   (readnext (cons c charlist)) )))))
