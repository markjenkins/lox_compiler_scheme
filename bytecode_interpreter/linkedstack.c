#include <stddef.h>
#include "memory.h"
#include "object.h"
#include "value.h"
#include "linkedstack.h"

void free_linked_stack_values(LinkedEntry * stacktop){
  LinkedEntry * next = stacktop;
  LinkedEntry * prev = NULL;
  while(next!=NULL){
    prev = next;
    next = prev->next;
    free_via_reallocate(prev->value, sizeof(Value));
    free_via_reallocate(prev, sizeof(LinkedEntry));
  }
}

LinkedEntry * get_matching_linked_entry(LinkedEntry * stacktop,
					ObjString * key){
  LinkedEntry * next = stacktop;
  LinkedEntry * prev = NULL;
  while(next!=NULL){
    prev = next;
    next = prev->next;
    if( stringEqual(key, prev->key) ){
      return prev;
    }
  }
  return NULL;
}
