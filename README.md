Work in progress work-through of part III (A Bytecode Virtual Machine) of the book [Crafting Interpreters](https://craftinginterpreters.com/) by Robert Nystrom.

As a derivative work of Nystrom's [code](https://github.com/munificent/craftinginterpreters), the license here matches that used by his code, see LICENSE.

Currently compiles these features to plain text opcodes (assembler):
 * integers
 * arithmetic operators
 * negation
 * parentheses
 * strings
 * nil
 * true, false
 * equality, inequality, comparison operators

A bytecode interpreter works through those and prints the expression value.

Git tags will indicate the book chapter that I will consider myself to be functionally on par with.

I'm implementing the Lox to bytecode compiler in a minimal dialect of [Scheme](https://en.wikipedia.org/wiki/Scheme_(programming_language))  . Development testing is done with [GNU Guile](https://www.gnu.org/software/guile/) but I expect to demonstrate compatibility with minimal implementations. Attempting to document Scheme features in use in scheme_dialect.md .

The bytecode interpreter is implemented with the minimal, bootstrappable C variant and subset [M2](https://github.com/oriansj/M2-Planet/) .

Mainly I'm doing this as an exercise to motivate a greater understanding of Scheme, M2, and bootstrapping programming languages.

All together, this should create a Lox implementation that's [bootstrappable](https://bootstrappable.org) . Potentially this will open up Lox as an option for bootstraping other languages. (see Ben Hoyt's [blog post](https://benhoyt.com/writings/loxlox/) and [code](https://github.com/benhoyt/loxlox))

Furthermore, this should provide a really good test case for compatible Scheme implementations.

# Dependencies for bytecode_interpreter

The expectation is that you'll build the bytecode_interpreter on GNU/Linux with [mescc-tools](https://github.com/oriansj/mescc-tools) and [M2-Planet](https://github.com/oriansj/M2-Planet) installed . For each of these, either
 * download the most recent release, build with 'make' and update PATH to include thier respective bin/ directories
or
 * clone the M2-Planet and mescc-tools git submodules in bytecode_interpreter
 ```
 $ cd bytecode_interpreter
 git submodule update --init M2Planet
 git submodule update --init mescc-tools
```
run make in each of them, and from this top level directory source devpath.sh into your bash shell.
```
$ cd ../; . devpath.sh
```

You'll also need the source files of a recent release of [M2Libc](https://github.com/oriansj/M2libc) which you should symlink into bytecode_interpreter/M2libc, unpack to that location, or use the git submodule
```
$ cd bytecode_interpreter; git submodule update --init M2libc
```

All sub-modules can be cloned at once with
```
$ git submodule update --init --recursive
```

These bootstrapping tools have support for several architechures. Currently, bytecode_interpreter/Makefile produces GNU/Linux binaries for 64bit ARM (aarch64), x86 and x86_64 (amd64). The exprprint.bash wraper shell script includes some detection logic that uses a best match and will otherwise use use [qemu-aarch64](https://www.qemu.org/) if you're on another architechure.

There is also a [gcc](https://www.gnu.org/software/gcc/) build that should work on any system with gcc or compatible equivilent.
```
 $ cd bytecode_interpreter; make exprprint.gcc
```

It would be a mistake to rely on just gcc for development though, as the M2-Planet bootstrappable C variant lacks several C features.

# Tests

The make target 'tests' runs several tests and compares compiler and interpreter output against expected output. Both your matching M2-Planet arch build and the gcc build are tested.
```
 $ make tests
```
