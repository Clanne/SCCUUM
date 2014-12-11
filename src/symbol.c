#include "symbol.h"

struct symbol_info tab_info( unsigned int n , unsigned int *dim , int *init_val ) 
{
	int i ;
	struct tab_info ti ;
	struct symbol_info si ;

	ti.nb_dim = n ;
	ti.init_val = init_val ;

	for( i = 0 ; i < n ; ++i )
		ti.dim[i] = dim[i] ;

	si.type = TYPE_TAB ;
	si.u.tinfo = ti ;
	
	return si ;
}
