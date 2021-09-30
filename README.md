Work in progress work-through of part III (A Bytecode Virtual Machine) of the book [Crafting Interpreters](https://craftinginterpreters.com/) by Robert Nystrom.

As a derivative work of Nystrom's [code](https://github.com/munificent/craftinginterpreters), the license here matches that used by his code, see LICENSE.

Currently compiles simple arithmetic, integer expressions to plain text opcodes (assembler) and a bytecode interpreter works through those and prints the expression value.

Git tags will indicate the book chapter that I will consider myself to be functionally on par with.

I'm implementing the Lox to bytecode compiler in a minimal dialect of [Scheme](https://en.wikipedia.org/wiki/Scheme_(programming_language))  . Development testing is done with [GNU Guile](https://www.gnu.org/software/guile/) but I expect to demonstrate compatibility with minimal implementations.

The bytecode interpreter is implemented with the minimal, bootstrappable C variant, [M2](https://github.com/oriansj/M2-Planet/) .

Mainly I'm doing this as an exercise to motivate a greater understanding of Scheme, M2, and bootstrapping programming languages.

All together, this should create a Lox implementation that's [bootstrappable](https://bootstrappable.org) . Potentially this will open up Lox as an option for bootstraping other languages. (see Ben Hoyt's [blog post](https://benhoyt.com/writings/loxlox/) and [code](https://github.com/benhoyt/loxlox))

Furthermore, this should provide a really good test case for compatible Scheme implementations.

The default make target 'tests' runs several tests and compares compiler and interpreter output against expected output.
```
 $ make
```
