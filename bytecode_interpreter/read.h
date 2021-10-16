/*  Copyright (c) 2021 Mark Jenkins <mark@markjenkins.ca>

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
*/

/* We're not using #ifndef guards to allow for the safe inclusion of headers
   inside headers because M2-Planet doesn't support that, all we do
   with M2-Planet is tell the compiler a list of .h and .c files in a workable
   order.

   So instead, we list here the headers this one depends on:
   <stddef.h>
   <stdio.h>
   "object.h"
   "chunk.h"
   "value.h"
   "vm.h"
 */

int read_opcode(FILE* in);
void read_constant(FILE* in, Value* value, VM * vm);
int read_file_into_chunk(FILE* in, Chunk * chunk, VM * vm);
