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

(define (flatten_nested_list_inner l accum)
  (if (pair? l)
      (if (pair? (car l))
	  (let ( (flatl (flatten_nested_list_inner (car l) accum)) )
	    (let flatlloop ( (fl (reverse flatl) ) (innerloopaccum '() ))
	      (if (pair? fl)
		  (flatlloop (cdr fl) (cons (car fl) innerloopaccum) )
		  (flatten_nested_list_inner (cdr l) innerloopaccum))))
	  (flatten_nested_list_inner (cdr l) (cons (car l) accum)))
      accum))

(define (flatten_nested_list l)
  (reverse (flatten_nested_list_inner l '())))
