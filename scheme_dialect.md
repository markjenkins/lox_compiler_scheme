Types
 - pairs
 - bools
 - single characters
 - strings
 - integers

Special forms and syntax I'm using:
 - define
 - (define (functionname arg1)) instead of (define functionname (lambda arg1))
 - quote, short form for quote, and pair dots in quoted lists
 - let, let*, and named let iteration/loops
 - if, cond with else
 - and, or
 - cond-expand
 - use-modules (only when guile detected, not required)

Built-in functions with a fixed number of arguments:
 - not
 - pair? null?
 - cons, car, cdr
 - cadr, caddr, cddr, caddr
 - reverse
 - eq?, eqv?, equal?
 - symbol?
 - list->string, string->list
 - number->string
 - char>=? , char<=?
 - assv, assv-ref
 - <= < > >=
 - read-char
 - eof-object?
 - display
 - newline

Built-in functions with variable arguments
 - list, append
 - error
 - +

Library funcions
 - srfi-1: first, second, third, fold, unfold, unfold-right ; own implementation included, guile's implementation used when available, built-in srfi-1 used when defined

Features I'm avoiding using (so far)
(should write scheme to scheme transpilers if I want them)
 - macros
 - continuations
 - support for multiple return values
 - letrec, letrec*
 - modules (I'm concatinating scheme files in my Makefile instead, taking care to avoid global namespace conflicts in my code)
