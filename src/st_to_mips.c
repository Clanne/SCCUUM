#include "st_to_mips.h"

void __int_to_mips( Symbol *s , FILE *out )
{
	fprintf( out , "\t%s: \t\t.word %d\n" , s->id , s->info.u.const_val ) ;
}

void __tab_to_mips( Symbol *s , FILE *out )
{
}

void __symbol_to_mips( Symbol *s , FILE *out )
{
	switch( s->info.type )
	{
		case TYPE_VAR_INT:
		case TYPE_CONST_INT:
			__int_to_mips( s , out ) ;
			break ;
		default:
			;
	}
}

void st_to_mips( SymbolTable *st , FILE *out )
{
	int i ;

	fprintf( out , ".data\n\n" ) ;

	for( i = 0 ; i < st->size ; ++ i )
	{
		DataChain dc = st->table[i] ;
		
		if( dc.data.id != NULL )
		{
			__symbol_to_mips( &dc.data , out ) ;

			DataChain *it = dc.next ;

			while( it != NULL )
			{
				__symbol_to_mips( &it->data , out ) ;
				it = it->next ;
			}
		}
	}
}
