/*  A derivitive work of https://craftinginterpreters.com

    Copyright (c) 2015 Robert Nystrom

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to
    deal in the Software without restriction, including without limitation the
    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
    sell copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
    IN THE SOFTWARE.

    Ported to M2-Planet C variant by
    @author Mark Jenkins <mark@markjenkins.ca>
*/

/* before this include:
   chunk.h
*/

#define INTERPRET_OK 0
#define INTERPRET_BYTECODE_ERROR 1
#define INTERPRET_RUNTIME_ERROR 2

#define STACK_MAX 2048

struct VM_ {
  Chunk * chunk;
  char * ip;
  Value * stack;
  Value * stackTop;
  Value * operand1;
  Value * operand2;
  Value * operationresult;
  int exit_on_return;
};
typedef struct VM_ VM;

void resetVmStack(VM * vm);
void initVM(VM * vm);
void freeVM(VM * vm);
void push(VM * vm, Value * value);
void pop(VM * vm, Value * targetValue);
int run_vm(VM * vm);
int interpret(VM * vm, Chunk * chunk);
