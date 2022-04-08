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

#include <stdio.h>
#include <string.h>

#include "memory.h"
#include "object.h"
#include "value.h"
#include "chunk.h"
#include "linkedstack.h"
#include "vm.h"
#include "common.h"

Obj* allocateObject(size_t size, int type, VM * vm){
  Obj* object = malloc_via_reallocate(size);
  object->type = type;
  object->next = vm->objects;
  vm->objects = object;
  return object;
}

ObjString * allocateString(char * chars, size_t length, VM * vm){
  ObjString* string = allocateObject(sizeof(ObjString), OBJ_STRING, vm);
  string->length = length;
  string->chars = chars;
  return string;
}

ObjString* takeString(char* chars, size_t length, VM * vm){
  return allocateString(chars, length, vm);
}

ObjString* copyString(char* chars, size_t length, VM * vm) {
  /* was ALLOCATE macro */
  char* heapChars = malloc_via_reallocate(sizeof(char)* (length+1));
  memcpy(heapChars, chars, length);
  heapChars[length] = '\0';
  return allocateString(heapChars, length, vm);
}

void printObject(Value * value){
  if( value->obj->type == OBJ_STRING){
    ObjString * s = value->obj;
    fputs("\"", stdout);
    fputs(s->chars, stdout);
    fputs("\"", stdout);
  }
  else{
    fputs("unsupported object type print request\n", stderr);
  }
}

int stringEqual(ObjString* aString, ObjString* bString){
    if ( (aString->type != OBJ_STRING) || (bString->type != OBJ_STRING) ){
      fputs("stringEqual called with incompatible one or more not string\n",
	    stderr);
      return FALSE;
    }
    return ( ((aString->length) == (bString->length)) &&
	     (strncmp(aString->chars, bString->chars, aString->length)==0) );
}
