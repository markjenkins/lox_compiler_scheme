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
#include "M2libc/bootstrappable.h"
#include "memory.h"
#include "object.h"
#include "value.h"
#include "chunk.h"
#include "vm.h"
#include "read.h"

int main(int argc, char** argv){
  /* matching free at bottom of main() */
  VM * vm = malloc_via_reallocate(sizeof(VM));
  initVM(vm);

  /* matching free at bottom of main() */
  Chunk * chunk = malloc_via_reallocate(sizeof(Chunk));
  initChunk(chunk);
  if (!read_file_into_chunk(stdin, chunk, vm)){
    fputs("reading input file failed\n", stderr);
    return EXIT_FAILURE;    
  }

  /* needed when we're just doing one expression ending with OP_RETURN */
  vm->exit_on_return = TRUE;
  int result = interpret(vm, chunk);
  if (result!=INTERPRET_OK){
    return EXIT_FAILURE;
  }
  pop(vm, vm->operand1);

  printValue(vm->operand1);
  fputs("\n", stdout);

  freeVM(vm);
  free_via_reallocate(vm, sizeof(VM)); /* malloc at top of main() */
  freeChunk(chunk);
  free_via_reallocate(chunk, sizeof(Chunk)); /* malloc at top of main() */
  return EXIT_SUCCESS;

}
