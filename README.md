Work in progress work-through of part III (A Bytecode Virtual Machine) of the book Crafting Interpreters by Robert Nystrom. https://craftinginterpreters.com/ https://github.com/munificent/craftinginterpreters.

As a derivative work of Nystrom's code, the license here matches that used by his code, see LICENSE.

Currently compiles simple arithmetic expressions to plain text opcodes (tests 4-12), so this is a long way from finished.

I'm implementing a Lox to bytecode compiler in a minimal dialect of Scheme https://en.wikipedia.org/wiki/Scheme_(programming_language) . Development testing is done with GNU Guile (https://www.gnu.org/software/guile/) but I expect to demonstrate compatibility with minimal implementations.

The plan is to implement the bytecode interpreter with the minimal, bootstrappable C variant, M2 (https://github.com/oriansj/M2-Planet/) .

Mainly I'm doing this as an exercise to motivate a greater understanding of Scheme, M2, and bootstrapping programming languages.

All together, this should create a Lox implementation that's bootstrappable (see https://bootstrappable.org . Potentially this will open up Lox as an option for bootstraping other languages. (see https://github.com/benhoyt/loxlox https://benhoyt.com/writings/loxlox/)

Furthermore, this should provide a really good test case for compatible Scheme implementations.

The default make target tests runs tests 4-12 and compares them against expected output.
 $ make
