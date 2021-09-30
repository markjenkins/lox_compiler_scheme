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

void resetVmStack(VM * vm){
  vm->stackTop = vm->stack;
}

void initVM(VM * vm){
  vm->stack = malloc(STACK_MAX*sizeof(Value));
  Value * operands_and_result = malloc(sizeof(Value)*3);
  vm->operand1 = operands_and_result;
  /* perhaps it would make more sense to have incValuePointer(Value * v)
     to cover this common case of increment 1, would allow the
     multiplication to be skipped */
  Value * operand2 = bumpValuePointer(operands_and_result, 1);
  vm->operand2 = operand2;
  Value * result = bumpValuePointer(operand2, 1);
  vm->operationresult = result;
  resetVmStack(vm);
  vm->exit_on_return = FALSE;
}
void freeVM(VM * vm){
  free(vm->stack);
  /* freeing this also covers vm->operand2 and vm->operationresult
     see initVM */
  free(vm->operand1);
  vm->stack = NULL;
  vm->stackTop = NULL;
}

void push(VM * vm, Value * value){
  memcpy(vm->stackTop, value, sizeof(Value) );
  vm->stackTop = bumpValuePointer(vm->stackTop, 1);
}

void pop(VM * vm, Value * targetValue){
  if (vm->stackTop == vm->stack){
    fputs("stack underflow\n", stderr);
    return NULL;
  }
  Value * newStackTop = decrementValuePointer(vm->stackTop);
  memcpy(targetValue, newStackTop, sizeof(Value));
  vm->stackTop = newStackTop;
}

int run_vm(VM * vm){
  Chunk * chunk = vm->chunk;
  char * ip = chunk->code;
  char instruction;
  size_t index;
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
    else if (instruction == OP_NEGATE){
      pop(vm, vm->operand1);
      if ( (vm->operand1->type == VAL_NUMBER) ){
	vm->operationresult->type = VAL_NUMBER;
	vm->operationresult->number = -(vm->operand1->number);
	push(vm, vm->operationresult);
      }
      else {
	fputs("operand for negate not number\n", stderr);
	return INTERPRET_BYTECODE_ERROR;
      }
    }
    else if (instruction == OP_ADD){
      pop(vm, vm->operand2);
      pop(vm, vm->operand1);
      if ( (vm->operand1->type == VAL_NUMBER) &&
	   (vm->operand2->type == VAL_NUMBER) ){
	vm->operationresult->type = VAL_NUMBER;
	vm->operationresult->number =
	  vm->operand1->number + vm->operand2->number;
	push(vm, vm->operationresult);
      }
      else {
	fputs("operands for add not both number\n", stderr);
	return INTERPRET_BYTECODE_ERROR;
      }
    }
    else if (instruction == OP_SUBTRACT){
      pop(vm, vm->operand2);
      pop(vm, vm->operand1);
      if ( (vm->operand1->type == VAL_NUMBER) &&
	   (vm->operand2->type == VAL_NUMBER) ){
	vm->operationresult->type = VAL_NUMBER;
	vm->operationresult->number =
	  vm->operand1->number - vm->operand2->number;
	push(vm, vm->operationresult);
      }
      else {
	fputs("operands for subtract not both number\n", stderr);
	return INTERPRET_BYTECODE_ERROR;
      }
    }
    else if (instruction == OP_MULTIPLY){
      pop(vm, vm->operand2);
      pop(vm, vm->operand1);
      if ( (vm->operand1->type == VAL_NUMBER) &&
	   (vm->operand2->type == VAL_NUMBER) ){
	vm->operationresult->type = VAL_NUMBER;
	vm->operationresult->number =
	  vm->operand1->number * vm->operand2->number;
	push(vm, vm->operationresult);
      }
      else {
	fputs("operands for multiply not both number\n", stderr);
	return INTERPRET_BYTECODE_ERROR;
      }
    }
    else if (instruction == OP_DIVIDE){
      pop(vm, vm->operand2);
      pop(vm, vm->operand1);
      if ( (vm->operand1->type == VAL_NUMBER) &&
	   (vm->operand2->type == VAL_NUMBER) ){
	vm->operationresult->type = VAL_NUMBER;
	vm->operationresult->number =
	  vm->operand1->number / vm->operand2->number;
	push(vm, vm->operationresult);
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

void interpret(VM * vm, Chunk * chunk){
  vm->chunk = chunk;
  vm->ip = chunk->code;
  return run_vm(vm);
}