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
#include "M2libc/bootstrappable.h"
#include "memory.h"
#include "object.h"
#include "value.h"
#include "chunk.h"
#include "vm.h"
#include "read.h"

/* caller is just responsible for malloc of vm and chunk */
int common_vm_chunk_init_and_run(VM * vm, Chunk * chunk,
				     int exit_on_return){
    initVM(vm);
    initChunk(chunk);
    if (!read_file_into_chunk(stdin, chunk, vm)){
      fputs("reading input file failed\n", stderr);
      return EXIT_FAILURE;
    }

    /* needed when we're just doing one expression or set of declarations
       ending with OP_RETURN */
    if(exit_on_return){
      vm->exit_on_return = TRUE;
    }
    int result = interpret(vm, chunk);
    if (result!=INTERPRET_OK){
      return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
