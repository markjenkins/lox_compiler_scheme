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

/* 
 <stdlib.h>
 */

void free_via_reallocate(void * pointer, size_t memsize);
void* reallocate(void* pointer, size_t oldSize, size_t newSize);

/*
#define FREE(type, pointer) reallocate(pointer, sizeof(type), 0)
*/
#define DEFAULT_ARRAY_CAPACITY 8
#define ARRAY_CAPACITY_INT_MULTIPLIER 2

/* GROW_CAPACITY macro relies on ternary operator, not defined in M2-Planet
   see alternative code where DEFAULT_ARRAY_CAPACITY and 
   ARRAY_CAPACITY_INT_MULTIPLIER are used in an if {} else {}
   define GROW_CAPACITY(capacity)		\
    ((capacity) < 8 ? 8 : (capacity) * 2)
 */
/* These macros can't be used because the error is
   "Unknown type reallocate"
#define GROW_ARRAY(type, pointer, oldCount, newCount) \
    reallocate(pointer, sizeof(type) * (oldCount), \
        sizeof(type) * (newCount))

#define FREE_ARRAY(type, pointer, oldCount) \
    reallocate(pointer, sizeof(type) * (oldCount), 0)
*/
