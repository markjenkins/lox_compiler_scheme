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
#include "object.h"
#include "value.h"
#include "linkedstack.h"
#include "chunk.h"
#include "vm.h"
#include "memory.h"
#include "copystring.h"
#include "common.h"

void resetVmStack(VM * vm){
  vm->stackTop = vm->stack;
}

void initVM(VM * vm){
  vm->stack = malloc_via_reallocate(STACK_MAX*sizeof(Value)); /* this is freed in freeVM */
  Value * operands = malloc_via_reallocate(sizeof(Value)*2); /* this is freed in freeVM */
  vm->operand1 = operands;
  Value * operand2 = incrementValuePointer(operands);
  vm->operand2 = operand2;
  resetVmStack(vm);
  vm->objects = NULL;
  vm->exit_on_return = FALSE;

  /* empty linked list just like objects, a poor data structure choice.
     We'll replace this with a hash table malloc and init later */
  vm->globals = NULL;
}
void freeVM(VM * vm){
  /* malloced in initVM */
  free_via_reallocate(vm->stack, STACK_MAX*sizeof(Value));
  /* freeing this also covers vm->operand2 see initVM where malloced */
  free_via_reallocate(vm->operand1, sizeof(Value)*2);
  vm->stack = NULL;
  vm->stackTop = NULL;
  /* just unallocate the values and not the string keys or
     underlying object values, because freeObjects() below iw responsible for */
  free_linked_stack_values(vm->globals);
  vm->globals = NULL;

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

Value * peek_top(VM * vm){
  return decrementValuePointer(vm->stackTop);
}

void toss_pop(VM * vm){
  if (vm->stackTop == vm->stack){
    fputs("stack underflow\n", stderr);
    return;
  }
  Value * newStackTop = peek_top(vm);
  vm->stackTop = newStackTop;
}

void pop(VM * vm, Value * targetValue){
  if (vm->stackTop == vm->stack){
    fputs("stack underflow\n", stderr);
    return;
  }
  Value * newStackTop = peek_top(vm);
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

int global_var_error_handle(Value * v){
  if(v==NULL){
    fputs("null value access\n", stderr);
    return INTERPRET_BYTECODE_ERROR;
  }
  else if ( (v->type != VAL_OBJ) ){
    fputs("StrObj expected as constant for OP_*_GLOBAL found non-obj\n", stderr);
    return INTERPRET_BYTECODE_ERROR;
  }
  else if( (v->obj->type != OBJ_STRING) ){
    fputs("StrObj expected as constant for OP_*_GLOBAL found non-str obj\n", stderr);
    return INTERPRET_BYTECODE_ERROR;
  }

  return INTERPRET_OK;
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
  LinkedEntry * linked_entry;
  int error_check = INTERPRET_OK;
  ObjString * ident_string;

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
    else if (instruction == OP_POP){
      toss_pop(vm);
    }
    else if (instruction == OP_GET_LOCAL){
      ip = ip + sizeof(char);
      index = ip[0];
      v = bumpValuePointer(vm->stack, index);
      push(vm, v);
    }
    else if (instruction == OP_SET_LOCAL){
      ip = ip + sizeof(char);
      index = ip[0];
      v = bumpValuePointer(vm->stack, index);
      memcpy(v, peek_top(vm), sizeof(Value));
    }
    else if (instruction ==  OP_DEFINE_GLOBAL){
      ip = ip + sizeof(char);
      index = ip[0];
      v = accessChunkConstant(chunk, index);
      error_check = global_var_error_handle(v);
      if (error_check != INTERPRET_OK){
	return error_check;
      }

      /* this pair of mallocs will be freed by free_linked_stack_values()
	 which will be called by freevm */
      linked_entry = malloc_via_reallocate(sizeof(LinkedEntry));
      linked_entry->value = malloc_via_reallocate(sizeof(Value));
      linked_entry->key = v->obj;
      pop(vm, linked_entry->value);

      /* add this global the linkedstack LinkedEntry
	 which should be replaced sometime with a hash table
	 for now, we're being so lazy that we're not even searching
	 for an entry with the same key?
       */
      linked_entry->next = vm->globals;
      vm->globals = linked_entry;
    }
    else if (instruction ==  OP_GET_GLOBAL){
      ip = ip + sizeof(char);
      index = ip[0];
      v = accessChunkConstant(chunk, index);
      error_check = global_var_error_handle(v);
      if (error_check != INTERPRET_OK){
	return error_check;
      }

      ident_string = v->obj;
      linked_entry = get_matching_linked_entry(vm->globals, ident_string);
      if(NULL==linked_entry){
	fputs("unknown global \"", stderr);
	fputs(ident_string->chars, stderr);
	fputs("\"\n", stderr);
	return INTERPRET_RUNTIME_ERROR;
      }
      push(vm, linked_entry->value);
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
    else if (instruction == OP_PRINT){
      pop(vm, operand1);
      printValue(operand1);
      fputs("\n", stdout);
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
