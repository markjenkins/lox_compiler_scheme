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
   <stddef.h>
   common.h
   value.h
*/

#define OP_CONSTANT 0
#define OP_NIL 1
#define OP_TRUE 2
#define OP_FALSE 3
#define OP_POP 4
#define OP_GET_LOCAL 5
#define OP_SET_LOCAL 6
#define OP_GET_GLOBAL 7
#define OP_DEFINE_GLOBAL 8
#define OP_SET_GLOBAL 9
#define OP_GET_UPVALUE 10
#define OP_SET_UPVALUE 11
#define OP_GET_PROPERTY 12
#define OP_SET_PROPERTY 13
#define OP_GET_SUPER 14
#define OP_EQUAL 15
#define OP_GREATER 16
#define OP_LESS 17
#define OP_ADD 18
#define OP_SUBTRACT 19
#define OP_MULTIPLY 20
#define OP_DIVIDE 21
#define OP_NOT 22
#define OP_NEGATE 23
#define OP_PRINT 24
#define OP_JUMP 25
#define OP_JUMP_IF_FALSE 26
#define OP_LOOP 27
#define OP_CALL 28
#define OP_INVOKE 29
#define OP_SUPER_INVOKE 30
#define OP_CLOSURE 31
#define OP_CLOSE_UPVALUE 32
#define OP_RETURN 33
#define OP_CLASS 34
#define OP_INHERIT 35
#define OP_METHOD 36

struct Chunk_ {
  size_t count;
  size_t capacity;
  /* be careful, signed/unsigned char is implementation dependant
     M2-planet defines it as signed
     other combinations of C compiler and arch will do unsigned
   */
  char* code;

  ValueArray * constants;
};

typedef struct Chunk_ Chunk;

void initChunk(Chunk* chunk);
void freeChunk(Chunk* chunk);
/* see Chunk_ definition re char* code as relevant to byte param */
void writeChunk(Chunk* chunk, char byte);
size_t addConstant(Chunk* chunk, Value * value);

Value * accessChunkConstant(Chunk * chunk, size_t index);
