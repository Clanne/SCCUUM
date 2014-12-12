#include "backpatch.h"


void backpatch_tab_accessor_op( SymbolTable *st , QuadList code , unsigned int ndim , unsigned int *dim ) 
{
	int i , multiplier = dim[0] ;
	struct qlist_node *it = code.head ;

	for( i = 1 ; i < ndim && it != NULL ; ++ i , it = it->next )
	{
		it->q->operandes[0] = st_new_temp( st , const_int( multiplier ) ) ;
		multiplier *= dim[i] ;
	}
}
