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

#include <stdlib.h>
#include <stdio.h>
#include "simplerealloc.h"
#include "object.h"
#include "value.h"
#include "chunk.h"
#include "vm.h"
#include "memory.h"

void* reallocate(void* pointer, size_t oldSize, size_t newSize) {
  if (newSize == 0) {
    free(pointer);
    return NULL;
  }

  void* result = simple_realloc(pointer, oldSize, newSize);
  if (result == NULL){
    fputs("simple_realloc_fail due to out of memory", stderr);
    exit(EXIT_FAILURE);
  }
  return result;
}

/* call reallocate with last arg (newSize) 0 to trigger free
   an important operation down the line for garbage collection purposes
 */
void free_via_reallocate(void * pointer, size_t memsize){
  reallocate(pointer, memsize, 0);
}

void freeObject(Obj* object){
  if(object->type==OBJ_STRING){
    ObjString * string = object;
    free_via_reallocate(string->chars, (string->length)+1);
    free_via_reallocate(string, sizeof(ObjString));
  }
  else{
    fputs("free attempted on unsupported object type\n", stderr);
  }
}

void freeObjects(VM * vm){
  Obj* object = vm->objects;
  Obj* next = NULL;
  while (object != NULL) {
    next = object->next;
    freeObject(object);
    object = next;
  }
}
