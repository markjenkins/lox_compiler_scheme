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

(cond-expand
 (srfi-1) ; do nothing if srfi1 support already present
 (guile
  (use-modules (srfi srfi-1)))
 ;; else provide the subset of srfi1 support this project requires
 (else
  (define first car)
  (define second cadr)
  (define third caddr)
  ;;; a simplified version without the optional tail argument
  ;;; from the guile documentation
  (define (unfold-right p f g seed)
    (let lp ((seed seed) (lis '() ))
      (if (p seed)
	  lis
	  (lp (g seed)
	      (cons (f seed) lis)))))
  (define (unfold p f g seed)
    (reverse (unfold-right p f g seed)))
  ;;; simple version only taking one list as argument
  (define (fold proc init lst)
    (let lp ((state init) (l lst))
      (if (pair? l)
	  (lp (proc (car l) state)
	      (cdr l))
	  state)))
  ))
