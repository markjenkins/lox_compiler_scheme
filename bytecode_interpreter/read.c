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
#include "M2libc/bootstrappable.h"
#include "value.h"
#include "memory.h"
#include "chunk.h"
#include "read.h"

#define INPUT_BUFFER_SIZE 4096
#define SPACE 32
#define NEWLINE 10

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
  else if ( 0==strcmp("OP_CONSTANT", inputbuffer) ){
    return OP_CONSTANT;
  }

  fputs("opcode not recognized\n", stderr);
  return EOF;
}

/* written for now just for int constants */
void read_constant(FILE* in, Value* value){
  int input_char = fgetc(in);
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
  value->number = strtoint(inputbuffer);
}

void read_file_into_chunk(FILE* in, Chunk * chunk){
  inputbuffer = malloc(INPUT_BUFFER_SIZE);
  Value * constValue = malloc(sizeof(Value));
  size_t constantIndex;
  int opcode_or_eof = read_opcode(in);
  while (opcode_or_eof != EOF){
    /* write the bytecode */
    writeChunk(chunk, opcode_or_eof);

    if (opcode_or_eof == OP_CONSTANT){
      read_constant(in, constValue);
      constantIndex = addConstant(chunk, constValue);
      writeChunk(chunk, constantIndex);
    }
    opcode_or_eof = read_opcode(in);
  }
  free_via_reallocate(constValue, sizeof(Value));
  free_via_reallocate(inputbuffer, INPUT_BUFFER_SIZE);
}
