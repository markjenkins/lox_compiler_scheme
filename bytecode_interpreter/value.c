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

/* depends on
     memory.h
     value.h
 */

#include <string.h>
#include "memory.h"
#include "value.h"

void initValueArray(ValueArray* array) {
  array->values = NULL;
  array->capacity = 0;
  array->count = 0;
}

Value * incrementValuePointer(Value * value){
  /* without casts to void, this can be expressed as
     return value + 1;
     This whole routine was done out of a finding that the above
     kind of pointer arithmatic was not do-able with M2-Planet
  */
  void *  newValue = value;
  newValue = newValue + sizeof(Value);
  return newValue;
  /*return value + 1; // works with gcc */
}

Value * decrementValuePointer(Value * value){
  /* without casts to void, this can be expressed as
     return value - 1;
     This whole routine was done out of a finding that the above
     kind of pointer arithmatic was not do-able with M2-Planet
  */
  void *  newValue = value;
  newValue = newValue - sizeof(Value);
  return newValue;
  /*return value - 1; // works with gcc */
}

Value * bumpValuePointer(Value * value, size_t count){
  /* without casts to void, this can be expressed as
     return value + count;
     This whole routine was done because of a finding that the above
     kind of pointer arithmatic was not do-able with M2-Planet
  */
  void *  newValue = value;
  newValue = newValue + (sizeof(Value) * (count));
  return newValue;
  /*return value + count; // works with gcc */
}

void writeValueArray(ValueArray* array, Value * value) {
  if (array->capacity < array->count + 1) {
    size_t oldCapacity = array->capacity;
    /* this was originally the GROW_CAPACITY(oldCapacity) macro
       GROW_CAPACITY(capacity) ((capacity) < 8 ? 8 : (capacity) * 2)
       but M2-planet doesn't have the ternary operator */
    if (oldCapacity < DEFAULT_ARRAY_CAPACITY){
      array->capacity = DEFAULT_ARRAY_CAPACITY;
    }
    else {
      array->capacity = oldCapacity*ARRAY_CAPACITY_INT_MULTIPLIER;
    }
    /* was originally
       array->values = GROW_ARRAY(Value, array->values,
       oldCapacity, array->capacity);*/
    array->values = reallocate(array->values, sizeof(Value) * (oldCapacity),
			       sizeof(Value) * (array->capacity) );
  }
  Value * writeValue = bumpValuePointer(array->values, array->count);
  memcpy(writeValue, value, sizeof(Value));
  array->count = array->count + 1; /* was with ++ operator */
}


void freeValueArray(ValueArray* array) {
  /*was originally
    FREE_ARRAY(Value, array->values, array->capacity);*/
  size_t oldCount = array->count;
  free_via_reallocate(array->values, sizeof(Value) * (oldCount) );
  initValueArray(array);
}
