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

/* before this include
   <stddef.h>
   <stdlib.h>
   chunk.h
   value.h
   memory.h
 */

#include <stddef.h>
#include <stdlib.h>
#include "memory.h"
#include "value.h"
#include "chunk.h"

void clearChunk(Chunk* chunk){
  chunk->count = 0;
  chunk->capacity = 0;
  chunk->code = NULL;
  chunk->constants = NULL;
}

void initChunk(Chunk* chunk) {
  clearChunk(chunk);
  chunk->constants = malloc( sizeof(ValueArray) );
  initValueArray(chunk->constants);
}

void freeChunk(Chunk* chunk) {
  /* FREE_ARRAY(char, chunk->code, chunk->capacity); */
  free_via_reallocate(chunk->code, sizeof(char) * (chunk->capacity));

  freeValueArray(chunk->constants);
  clearChunk(chunk);
}

void writeChunk(Chunk* chunk, char byte) {
  if (chunk->capacity < chunk->count + 1) {
    size_t oldCapacity = chunk->capacity;
    /* this was originally the GROW_CAPACITY(oldCapacity) macro
       GROW_CAPACITY(capacity) ((capacity) < 8 ? 8 : (capacity) * 2)
       but M2-planet doesn't have the ternary operator */
    if (oldCapacity < DEFAULT_ARRAY_CAPACITY){
      chunk->capacity = DEFAULT_ARRAY_CAPACITY;
    }
    else {
      chunk->capacity = oldCapacity*ARRAY_CAPACITY_INT_MULTIPLIER;
    }
    /*chunk->code = GROW_ARRAY(char, chunk->code,
      oldCapacity, chunk->capacity);*/
    chunk->code = reallocate(chunk->code, sizeof(char) * (oldCapacity),
			     sizeof(char) * (chunk->capacity));
  }

  /*char * target_char = chunk->code + (chunk->count)*sizeof(char);
    should this perhaps be memcopy based
  target_char[0] = byte;*/
    
  /* supported?*/
  char * chunk_code = chunk->code;
  chunk_code[chunk->count] = byte;
  
  chunk->count = chunk->count + 1;
}


size_t addConstant(Chunk* chunk, Value * value) {
  ValueArray * chunk_constants = chunk->constants;
  writeValueArray(chunk_constants, value);  
  return chunk_constants->count - 1;
}

Value * accessChunkConstant(Chunk * chunk, size_t index){
  ValueArray * va = chunk->constants;
  if (index >= va->count){
    return NULL;
  }
  return bumpValuePointer(va->values, index);
}
