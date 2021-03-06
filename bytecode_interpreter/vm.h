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

/* We're not using #ifndef guards to allow for the safe inclusion of headers
   inside headers because M2-Planet doesn't support that, all we do
   with M2-Planet is tell the compiler a list of .h and .c files in a workable
   order.

   So instead, we list here the headers this one depends on:
   <stddef.h>
   "object.h"
   "value.h"
   "linkedstack.h"
 */

#define INTERPRET_OK 0
#define INTERPRET_BYTECODE_ERROR 1
#define INTERPRET_RUNTIME_ERROR 2

#define STACK_MAX 2048

struct VM_ {
  Value * stack;
  Value * stackTop;
  Value * operand1;
  Value * operand2;
  int exit_on_return;
  Obj * objects;

  /* a stack/linked list is the wrong data structure for tracking globals
     but we're planning to replace that later.
   */
  LinkedEntry * globals;
};
typedef struct VM_ VM;

void resetVmStack(VM * vm);
void initVM(VM * vm);
void freeVM(VM * vm);
Value * soft_push(VM * vm);
void push(VM * vm, Value * value);
void toss_pop(VM * vm);
void pop(VM * vm, Value * targetValue);
int run_vm(VM * vm, Chunk * chunk);
int interpret(VM * vm, Chunk * chunk);
