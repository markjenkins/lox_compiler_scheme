/* depends on
   <stddef.h>
   object.h
   value.h
 */

struct LinkedEntry_ {
  ObjString* key;
  Value* value;
  struct LinkedEntry_ * next;
};

typedef struct LinkedEntry_ LinkedEntry;

void free_linked_stack_values(LinkedEntry *);
