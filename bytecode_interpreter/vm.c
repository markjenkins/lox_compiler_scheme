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
#include <string.h>
#include <stdio.h>
#include "M2libc/bootstrappable.h"
#include "object.h"
#include "value.h"
#include "chunk.h"
#include "vm.h"
#include "memory.h"
#include "copystring.h"

void resetVmStack(VM * vm){
  vm->stackTop = vm->stack;
}

void initVM(VM * vm){
  vm->stack = malloc(STACK_MAX*sizeof(Value)); /* this is freed in freeVM */
  Value * operands = malloc(sizeof(Value)*2); /* this is freed in freeVM */
  vm->operand1 = operands;
  Value * operand2 = incrementValuePointer(operands);
  vm->operand2 = operand2;
  resetVmStack(vm);
  vm->objects = NULL;
  vm->exit_on_return = FALSE;
}
void freeVM(VM * vm){
  /* malloced in initVM */
  free_via_reallocate(vm->stack, STACK_MAX*sizeof(Value));
  /* freeing this also covers vm->operand2 see initVM where malloced */
  free_via_reallocate(vm->operand1, sizeof(Value)*2);
  vm->stack = NULL;
  vm->stackTop = NULL;
  freeObjects(vm);
  vm->objects = NULL;
}

Value * soft_push(VM * vm){
  Value * return_value = vm->stackTop;
  vm->stackTop = incrementValuePointer(vm->stackTop);
  return return_value;
}

void push(VM * vm, Value * value){
  memcpy(vm->stackTop, value, sizeof(Value) );
  vm->stackTop = incrementValuePointer(vm->stackTop);
}

void pop(VM * vm, Value * targetValue){
  if (vm->stackTop == vm->stack){
    fputs("stack underflow\n", stderr);
    return;
  }
  Value * newStackTop = decrementValuePointer(vm->stackTop);
  memcpy(targetValue, newStackTop, sizeof(Value));
  vm->stackTop = newStackTop;
}

int isFalsey(Value * v){
  if (v->type == VAL_BOOL){
    return !(v->boolean);
  }
  else if (v->type == VAL_NIL ){
    return TRUE;
  }
  else {
    return FALSE;
  }
}

void concatenate(VM * vm){
  Value* operand2 = vm->operand2;
  Value* operand1 = vm->operand1;
  /* popping of two operands is already done by run_vm
     used by run_vm() to help checked the types
   */
  /* pop(vm, operand2);
     pop(vm, operand1); */

  /* run_vm has already checked these types but we'll program
     defensively just in case */
  if ( ! ( ((operand2->type)==VAL_OBJ) &&
	   ((operand1->type)==VAL_OBJ) ) ){
    fputs("concatenate called on non obj operands\n", stderr);
    /* this is where a vm panic flag should be set */
    return;
  }
  ObjString* b = operand2->obj;
  ObjString* a = operand1->obj;
  if ( ! ( ((b->type)==OBJ_STRING) &&
	   ((a->type)==OBJ_STRING) ) ){
    fputs("concatenate called on non-string objs\n", stderr);
    /* this is where a vm panic flag should be set */
    return;
  }
  size_t length = a->length + b->length;
  /* was ALLOCATE macro */
  char* chars = malloc_via_reallocate((length+1)*sizeof(char));
  strncpy(chars, a->chars, a->length);
  strncpy(chars + (a->length), b->chars, b->length);
  chars[length] = '\0';
  Value * v = soft_push(vm);
  v->type = VAL_OBJ;
  v->obj = takeString(chars, length, vm);
}

int run_vm(VM * vm, Chunk * chunk){
  /* note that originally, ip and chunk were part of the vm struct
     whereas here we just have chunk pass through as an arg from interpret
     and ip as a var local to this function
     
     But, with these not part of the vm struct, so at some point we may need
     to pass them on to functions called here with a need to know
  */
  char * ip = chunk->code;
  char instruction;
  size_t index;
  Value * operand1 = vm->operand1;
  Value * operand2 = vm->operand2;
  Value * v;

  if((chunk->code==NULL) || (chunk->count==0) ){
    fputs("chunk code is still null or count 0 before execution\n", stderr);
    return INTERPRET_BYTECODE_ERROR;
  }

  while (TRUE){
    instruction = ip[0];
    /* eventually this instruction lookup should be done with the equivilent
       of switch by nesting if statements based on range to get a binary search
       effect like a good compiler does to switch
       but, we'll need to be careful with char being signed or unsigned once
       the number of bytecodes is greater than 127
    */
    /* TODO, support for OP_RETURN will be different for vm->exit_on_return==0
       that's to be implemented when we're not just interpreting a single
       expression but functions with OP_RETURN
       until then, OP_RETURN is a no-op when vm->exit_on_return==TRUE
     */
    if ( (instruction == OP_RETURN) && (vm->exit_on_return) ){
      return INTERPRET_OK;
    }
    else if (instruction == OP_CONSTANT){
      ip = ip + sizeof(char);
      index = ip[0];
      v = accessChunkConstant(chunk, index);
      if(v==NULL){
	fputs("null value access\n", stderr);
	return INTERPRET_BYTECODE_ERROR;
      }
      push(vm, v);
      
    }
    else if (instruction == OP_NIL){
      v = soft_push(vm);
      v->type = VAL_NIL;
    }
    else if (instruction == OP_TRUE){
      v = soft_push(vm);
      v->type = VAL_BOOL;
      v->boolean = TRUE;
    }
    else if (instruction == OP_FALSE){
      v = soft_push(vm);
      v->type = VAL_BOOL;
      v->boolean = FALSE;
    }
    else if (instruction == OP_NOT){
      pop(vm, operand1);
      soft_push(vm);
      v->type = VAL_BOOL;
      v->boolean = isFalsey(operand1);
    }
    else if (instruction == OP_NEGATE){
      pop(vm, operand1);
      if ( (operand1->type == VAL_NUMBER) ){
	v = soft_push(vm);
	v->type = VAL_NUMBER;
	v->number = -(operand1->number);
      }
      else {
	fputs("operand for negate not number\n", stderr);
	return INTERPRET_BYTECODE_ERROR;
      }
    }
    else if (instruction == OP_EQUAL){
      pop(vm, operand2);
      pop(vm, operand1);
      v = soft_push(vm);
      v->type = VAL_BOOL;
      v->boolean = valuesEqual(operand1, operand2);
    }
    else if (instruction == OP_GREATER){
      pop(vm, operand2);
      pop(vm, operand1);
      if ( (operand1->type == VAL_NUMBER) &&
	   (operand2->type == VAL_NUMBER) ){
	v = soft_push(vm);
	v->type = VAL_BOOL;
	v->number = operand1->number > operand2->number;
      }
      else {
	fputs("operands for greater > not both number\n", stderr);
	return INTERPRET_BYTECODE_ERROR;
      }
    }
    else if (instruction == OP_LESS){
      pop(vm, operand2);
      pop(vm, operand1);
      if ( (operand1->type == VAL_NUMBER) &&
	   (operand2->type == VAL_NUMBER) ){
	v = soft_push(vm);
	v->type = VAL_BOOL;
	v->number = operand1->number < operand2->number;
      }
      else {
	fputs("operands for less < not both number\n", stderr);
	return INTERPRET_BYTECODE_ERROR;
      }
    }
    else if (instruction == OP_ADD){
      pop(vm, operand2);
      pop(vm, operand1);
      if ( (operand1->type == VAL_NUMBER) &&
	   (operand2->type == VAL_NUMBER) ){
	v = soft_push(vm);
	v->type = VAL_NUMBER;
	v->number = operand1->number + operand2->number;
      }
      else if ( (operand1->type == VAL_OBJ) &&
		(operand2->type == VAL_OBJ) ){
	concatenate(vm);
      }
      else {
	fputs("operands for add not both number\n", stderr);
	return INTERPRET_BYTECODE_ERROR;
      }
    }
    else if (instruction == OP_SUBTRACT){
      pop(vm, operand2);
      pop(vm, operand1);
      if ( (operand1->type == VAL_NUMBER) &&
	   (operand2->type == VAL_NUMBER) ){
	v = soft_push(vm);
	v->type = VAL_NUMBER;
	v->number = operand1->number - operand2->number;
      }
      else {
	fputs("operands for subtract not both number\n", stderr);
	return INTERPRET_BYTECODE_ERROR;
      }
    }
    else if (instruction == OP_MULTIPLY){
      pop(vm, operand2);
      pop(vm, operand1);
      if ( (operand1->type == VAL_NUMBER) &&
	   (operand2->type == VAL_NUMBER) ){
	v = soft_push(vm);
	v->type = VAL_NUMBER;
	v->number = operand1->number * operand2->number;
      }
      else {
	fputs("operands for multiply not both number\n", stderr);
	return INTERPRET_BYTECODE_ERROR;
      }
    }
    else if (instruction == OP_DIVIDE){
      pop(vm, operand2);
      pop(vm, operand1);
      if ( (operand1->type == VAL_NUMBER) &&
	   (operand2->type == VAL_NUMBER) ){
	v = soft_push(vm);
	v->type = VAL_NUMBER;
	v->number = operand1->number / operand2->number;
      }
      else {
	fputs("operands for divide not both number\n", stderr);
	return INTERPRET_BYTECODE_ERROR;
      }
    }
    /* handle unknown bytecode */
    else {
      return INTERPRET_BYTECODE_ERROR;
    }
    ip = ip+sizeof(char);
  }
}

int interpret(VM * vm, Chunk * chunk){
  return run_vm(vm, chunk);
}
