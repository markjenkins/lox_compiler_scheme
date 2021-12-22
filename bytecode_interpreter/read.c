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

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "object.h"
#include "value.h"
#include "chunk.h"
#include "vm.h"
#include "memory.h"
#include "read.h"
#include "copystring.h"
#include "str2long.h"
#include "common.h"

#define INPUT_BUFFER_SIZE 4096
#define SPACE 32
#define NEWLINE 10
#define DOUBLE_QUOTE 34

char * inputbuffer;

int read_opcode(FILE* in){
  int input_char = fgetc(in);
  size_t index = 0;
  while( ( (input_char!=EOF) &&
	   (input_char!=SPACE) &&
	   (input_char!=NEWLINE) ) ){
    if( index == INPUT_BUFFER_SIZE ){
      fputs("input buffer overrun\n", stderr);
    }
    inputbuffer[index] = input_char;
    index = index + 1;
    input_char = fgetc(in);
  }
  if (input_char==EOF){
    return EOF;
  }
  inputbuffer[index] = 0;
  if ( 0==strcmp("OP_RETURN", inputbuffer) ){
    return OP_RETURN;
  }
  else if ( 0==strcmp("OP_EQUAL", inputbuffer) ){
    return OP_EQUAL;
  }
  else if ( 0==strcmp("OP_GREATER", inputbuffer) ){
    return OP_GREATER;
  }
  else if ( 0==strcmp("OP_LESS", inputbuffer) ){
    return OP_LESS;
  }
  else if ( 0==strcmp("OP_ADD", inputbuffer) ){
    return OP_ADD;
  }
  else if ( 0==strcmp("OP_SUBTRACT", inputbuffer) ){
    return OP_SUBTRACT;
  }
  else if ( 0==strcmp("OP_MULTIPLY", inputbuffer) ){
    return OP_MULTIPLY;
  }
  else if ( 0==strcmp("OP_DIVIDE", inputbuffer) ){
    return OP_DIVIDE;
  }
  else if ( 0==strcmp("OP_NEGATE", inputbuffer) ){
    return OP_NEGATE;
  }
  else if ( 0==strcmp("OP_PRINT", inputbuffer) ){
    return OP_PRINT;
  }
  else if ( 0==strcmp("OP_CONSTANT", inputbuffer) ){
    return OP_CONSTANT;
  }
  else if ( 0==strcmp("OP_NIL", inputbuffer) ){
    return OP_NIL;
  }
  else if ( 0==strcmp("OP_TRUE", inputbuffer) ){
    return OP_TRUE;
  }
  else if ( 0==strcmp("OP_FALSE", inputbuffer) ){
    return OP_FALSE;
  }
  else if ( 0==strcmp("OP_POP", inputbuffer) ){
    return OP_POP;
  }
  else if ( 0==strcmp("OP_NOT", inputbuffer) ){
    return OP_NOT;
  }

  fputs("opcode not recognized\n", stderr);
  return EOF;
}

void read_string_constant(FILE* in, Value* value, VM * vm){
  int input_char = fgetc(in);
  size_t index = 0;
  while(input_char!=DOUBLE_QUOTE){
    inputbuffer[index] = input_char;
    index = index + 1;
    input_char = fgetc(in);
    if(input_char==EOF){
      value->type = VAL_NIL;
      fputs("unterminated string constant\n", stderr);
      return;
    }
  }
  
  value->type = VAL_OBJ;
  value->obj = copyString(inputbuffer, index, vm);
  input_char = fgetc(in);
  if (input_char!=NEWLINE){
    fputs("newline expected after string constant closing double quote. ",
	  stderr);
    if (input_char==EOF){
      fputs("EOF hit instead\n", stderr);
    }
    else{
      fputs("\n", stderr);
    }
    value->type = VAL_NIL;
  }
}

/* written for now just for int constants */
void read_constant(FILE* in, Value* value, VM * vm){
  int input_char = fgetc(in);

  /* delegate to another function for string constant in "" */
  if (input_char==DOUBLE_QUOTE){ /* '"' */
    read_string_constant(in, value, vm);
    return;
  }

  /* otherwise read number constant */
  size_t index = 0;
  while( (input_char!=EOF) &&
	 (input_char!=SPACE) &&
	 (input_char!=NEWLINE) &&
	 (input_char>=48) && /* >= '0' */
	 (input_char<=57) ) {
    if( index == INPUT_BUFFER_SIZE ){
      fputs("input buffer overrun\n", stderr);
    }
    inputbuffer[index] = input_char;
    index = index + 1;
    input_char = fgetc(in);
  }

  if (input_char==EOF){
    fputs("end of input before expected constant\n", stderr);
    return;
  }
  else if ( (input_char!=SPACE) &&
	    (input_char!=NEWLINE) &&
	    ( (input_char < 48) ||
	      (input_char > 57) ) ){
    fputs("non-numeric character found in int const\n", stderr);
    return;
  }
  inputbuffer[index] = 0;
  value->type = VAL_NUMBER;
  value->number = str2long(inputbuffer);
}

int read_file_into_chunk(FILE* in, Chunk * chunk, VM * vm){
  /* free for those mallocs at the bottom  of this function */
  inputbuffer = malloc_via_reallocate(INPUT_BUFFER_SIZE);
  Value * constValue = malloc_via_reallocate(sizeof(Value));
  size_t constantIndex;
  int opcode_or_eof = read_opcode(in);
  while (opcode_or_eof != EOF){
    /* write the bytecode */
    writeChunk(chunk, opcode_or_eof);

    if (opcode_or_eof == OP_CONSTANT){
      read_constant(in, constValue, vm);
      if(constValue->type == VAL_NIL){
	return FALSE;
      }
      constantIndex = addConstant(chunk, constValue);
      writeChunk(chunk, constantIndex);
    }
    opcode_or_eof = read_opcode(in);
  }
  free_via_reallocate(constValue, sizeof(Value));
  free_via_reallocate(inputbuffer, INPUT_BUFFER_SIZE);
  return TRUE;
}
