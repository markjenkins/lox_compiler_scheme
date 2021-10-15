#include <stdio.h>
#include <string.h>

#include "memory.h"
#include "object.h"
#include "value.h"
#include "chunk.h"
#include "vm.h"

Obj* allocateObject(size_t size, int type, VM * vm){
  Obj* object = reallocate(NULL, 0, size);
  object->type = type;
  object->next = vm->objects;
  vm->objects = object;
  return object;
}

ObjString * allocateString(char * chars, int length, VM * vm){
  ObjString* string = allocateObject(sizeof(ObjString), OBJ_STRING, vm);
  string->length = length;
  string->chars = chars;
  return string;
}

ObjString* takeString(char* chars, int length, VM * vm){
  return allocateString(chars, length, vm);
}

ObjString* copyString(char* chars, int length, VM * vm) {
  /* was ALLOCATE macro */
  char* heapChars = reallocate(NULL, 0, sizeof(char)* (length+1));
  memcpy(heapChars, chars, length);
  heapChars[length] = '\0';
  return allocateString(heapChars, length, vm);
}

void printObject(Value * value){
  if( value->obj->type == OBJ_STRING){
    ObjString * s = value->obj;
    fputs("\"", stdout);
    fputs(s->chars, stdout);
    fputs("\"\n", stdout);
  }
  else{
    fputs("unsupported object type print request\n", stderr);
  }
}
