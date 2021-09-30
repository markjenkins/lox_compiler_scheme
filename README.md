Work in progress work-through of part III (A Bytecode Virtual Machine) of the book [Crafting Interpreters](https://craftinginterpreters.com/) by Robert Nystrom.

As a derivative work of Nystrom's [code](https://github.com/munificent/craftinginterpreters), the license here matches that used by his code, see LICENSE.

Currently compiles simple arithmetic, integer expressions to plain text opcodes (assembler) and a bytecode interpreter works through those and prints the expression value.

Git tags will indicate the book chapter that I will consider myself to be functionally on par with.

I'm implementing the Lox to bytecode compiler in a minimal dialect of [Scheme](https://en.wikipedia.org/wiki/Scheme_(programming_language))  . Development testing is done with [GNU Guile](https://www.gnu.org/software/guile/) but I expect to demonstrate compatibility with minimal implementations. Attempting to document Scheme features in use in scheme_dialect.md .

The bytecode interpreter is implemented with the minimal, bootstrappable C variant, [M2](https://github.com/oriansj/M2-Planet/) .

Mainly I'm doing this as an exercise to motivate a greater understanding of Scheme, M2, and bootstrapping programming languages.

All together, this should create a Lox implementation that's [bootstrappable](https://bootstrappable.org) . Potentially this will open up Lox as an option for bootstraping other languages. (see Ben Hoyt's [blog post](https://benhoyt.com/writings/loxlox/) and [code](https://github.com/benhoyt/loxlox))

Furthermore, this should provide a really good test case for compatible Scheme implementations.

# Dependencies for bytecode_interpreter

The expectation is that you'll build the bytecode_interpreter on GNU/Linux with [mescc-tools](https://github.com/oriansj/mescc-tools) and [M2-Planet](https://github.com/oriansj/M2-Planet) installed . For each of these, download the most recent release, build with 'make' and update PATH to include thier respective bin/ directories.

You'll also need the source files of a recent release of [M2Libc](https://github.com/oriansj/M2libc) which you should symlink into bytecode_interpreter/M2libc or unpack to that location.

These bootstrapping tools have support for several architechures. But, currently, bytecode_interpreter/Makefile only produces a 64bit ARM binary (aarch64) for GNU/Linux, as I've been doing most of my development on a Pinebook. The exprprint.bash wraper shell script includes some detection logic that will use [qemu-aarch64](https://www.qemu.org/) if you're on another architechure.

Still TODO is ensuring the bytecode_interpreter C code can be compatible with [gcc](https://www.gnu.org/software/gcc/) as well.

# Tests

The default make target 'tests' runs several tests and compares compiler and interpreter output against expected output.
```
 $ make
```
