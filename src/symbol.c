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


struct symbol_info stencil_info( unsigned int v , unsigned int n , int *init_val )
{
	struct stencil_info sti ;
	struct symbol_info si ;

	sti.voisinage = v ;
	sti.nb_dim = n ;
	sti.init_val = init_val ;

	si.type = TYPE_STENCIL ;
	si.u.sinfo = sti ;
	
	return si ;
}