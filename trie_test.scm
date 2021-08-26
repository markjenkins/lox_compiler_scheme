(display (trie_lookup KEYWORD_TRIE (string->list "and")))
(newline)

(display (trie_lookup KEYWORD_TRIE (string->list "class")))
(newline)

(display (trie_lookup KEYWORD_TRIE (string->list "else")))
(newline)

(display (trie_lookup KEYWORD_TRIE (string->list "false")))
(newline)

(display (trie_lookup KEYWORD_TRIE (string->list "for")))
(newline)

(display (trie_lookup KEYWORD_TRIE (string->list "fun")))
(newline)

(display (trie_lookup KEYWORD_TRIE (string->list "var")))
(newline)

(display (trie_lookup KEYWORD_TRIE (string->list "true")))
(newline)

(display (trie_lookup KEYWORD_TRIE (string->list "fu")))
(newline)

(display (trie_lookup KEYWORD_TRIE (string->list "fr")))
(newline)

(display (trie_lookup KEYWORD_TRIE (string->list "r")))
(newline)

;;;(define state (trie_fold_proc #\c KEYWORD_TRIE))
;;;(display state)
;;;(newline)

;;;(define state2 (trie_fold_proc #\l state))
;;;(newline)
;;;(display state2)
;;;(newline)

;;;(define state3 (trie_fold_proc #\a state2))
;;;(display state3)
;;;(newline)

;;;(define state4 (trie_fold_proc #\s state3))
;;;(display state4)
;;;(newline)

