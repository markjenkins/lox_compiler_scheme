;;; Copyright (c) 2021 Mark Jenkins <mark@markjenkins.ca>
;;;
;;; Permission is hereby granted, free of charge, to any person obtaining a copy
;;; of this software and associated documentation files (the "Software"), to
;;; deal in the Software without restriction, including without limitation the
;;; rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
;;; sell copies of the Software, and to permit persons to whom the Software is
;;; furnished to do so, subject to the following conditions:
;;;
;;; The above copyright notice and this permission notice shall be included in
;;; all copies or substantial portions of the Software.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
;;; IN THE SOFTWARE.

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

