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

int main(int argc, char** argv){
  Chunk * chunk = malloc(sizeof(Chunk));
  initChunk(chunk);
  read_file_into_chunk(stdin, chunk);

  VM * vm = malloc(sizeof(VM));
  initVM(vm);
  /* needed when we're just doing one expression ending with OP_RETURN */
  vm->exit_on_return = TRUE;
  int result = interpret(vm, chunk);
  if (result!=INTERPRET_OK){
    return EXIT_FAILURE;
  }
  pop(vm, vm->operationresult);
  if( vm->operationresult->type != VAL_NUMBER ){
    fputs("top of stack is not a number\n", stderr);
    return EXIT_FAILURE;
  }
  /* int2str isn't really compatible with long type of number */
  fputs( int2str(vm->operationresult->number, 10, 1), stdout);
  fputs("\n", stdout);

  freeVM(vm);
  freeChunk(chunk);
  return EXIT_SUCCESS;

}