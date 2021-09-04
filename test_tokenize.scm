;;; this file requires
;;;  - tokenize.scm
;;;  - readstdin.scm
;;;  - prettyprint.scm
;;; and the files they require
(pretty-print (tokenize (read_all_stdin_chars)))
