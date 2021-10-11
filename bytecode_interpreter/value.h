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

/* before this include
   <stddef.h>
   string.h
   common.h
 */
#define VAL_BOOL 0
#define VAL_NIL 1
#define VAL_NUMBER 2
#define VAL_OBJ 3
#define VAL_SINTEGER 4

struct Value_ {
  int type;
  union {
    int boolean;
    long number;
  };
};

typedef struct Value_ Value;

struct ValueArray_ {
  size_t capacity;
  size_t count;
  Value* values;
};

typedef struct ValueArray_ ValueArray;

void initValueArray(ValueArray* array);
void writeValueArray(ValueArray* array, Value * value);
void freeValueArray(ValueArray* array);
Value * incrementValuePointer(Value * value);
Value * decrementValuePointer(Value * value);
Value * bumpValuePointer(Value * value, size_t count);
int valuesEqual(Value * a, Value * b);
