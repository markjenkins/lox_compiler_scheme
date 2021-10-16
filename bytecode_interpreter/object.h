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

#define OBJ_BOUND_METHOD 0
#define OBJ_CLASS 1
#define OBJ_CLOSURE 2
#define OBJ_FUNCTION 3
#define OBJ_INSTANCE 4
#define OBJ_NATIVE 5
#define OBJ_STRING 6
#define OBJ_UPVALUE 7

struct Obj_ {
  /* all other Obj types needs to have these fields defined at the top
     of their struct in the same order.
   */
  int type;
  struct Obj_ * next;
};

typedef struct Obj_ Obj;

struct ObjString_ {
  /* standard field from Obj in the same order
   */
  int type;
  Obj * next;

  /* ObjString specific field */
  size_t length;
  char* chars;
};

typedef struct ObjString_ ObjString;

