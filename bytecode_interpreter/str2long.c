#include <stddef.h>
#include <stdlib.h>

size_t long2str(long input, char * outputbuffer, size_t outmax){
  char * c = outputbuffer + (outmax-1);
  long digit;
  size_t length = 0;
  size_t i;
  if(input < 0){
    return -1; /* error return for negative input */
  }
  if (input==0){
    outputbuffer[0] = '0';
    outputbuffer = outputbuffer + 1;
    outputbuffer[0] = 0; /* NULL terminator */
    return 1;
  }
  else{
    c[0] = 0;
    c = c - 1;
    while ( (input!=0) && (length<outmax) ){
      digit = input % 10;
      c[0] = digit + '0'; /* '0' is decimal 48, hex 0x30 */
      input = (input - digit) / 10;
      length = length + 1;
      c = c - 1;
    }
    if (input!=0){
      return 0;
    }
    c = c + 1;
    for(i=0; i<length; i = i + 1){
      outputbuffer[0] = c[0];
      outputbuffer = outputbuffer + 1;
      c = c + 1;
    }
    outputbuffer[0] = 0;
    return length+1;
  }
}

/* convert a series of integer characters between ascii 48 (0x30) and
   ascii 57 to (0x39) to a long
   no error handling for invalid characters
   no conversion where a negative sign is present, only positive integers
   supported
*/
long str2long(char * input){
  size_t length = 0;
  char * c = input;
  size_t i = 0;
  long output = 0;
  long multiplier = 1;
  /* find the string length and get the pointer c to the null byte*/
  while ( c[0] ){
    length = length + 1;
    c = c + 1;
  }
  /* Alternative approach, this caused a segfault when building with M2-Planet
    length = strlen(input);
    c = &(input[length]);
  */

  /* go backwards from least significant digit to most significant */
  for (i=0; i < length;i = i+1){
    c = c - 1;
    output = output + ((c[0] - 48)*multiplier);
    multiplier = multiplier * 10;
  }

  return output;
}
