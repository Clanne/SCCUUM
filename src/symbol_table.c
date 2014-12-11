#include "symbol_table.h"

//returns 1 if successful and 0 otherwise
static Symbol * __dc_add( DataChain *dc , const Symbol s )
{
	if( dc->data.id != NULL ) 
	{
		DataChain *ptr = dc ;

		while( ptr != NULL )//go to the end of the list if the key doesn't exist
		{
			if( strcmp( dc->data.id , s.id ) == 0 ) 
				return NULL ;//the key already exists.
			dc = ptr ;
			ptr = ptr->next ;
		}

		dc->next = malloc ( sizeof *dc ) ;
		dc = dc->next ;
	}

	dc->data = s ;
	dc->next = NULL ;

	return &dc->data ;//the key does not exist and new data was added.
}

//returns 1 if an element was deleted and 0 otherwise
static int __dc_delete( DataChain *dc , const char *key )
{
	if( dc->data.id != NULL ) 
	{
		if(  strcmp ( dc->data.id , key ) == 0 )//check if key is the first member in the list
		{
			free( dc->data.id ) ;
			if( dc->next != NULL  ) 
			{
				DataChain *ptr = dc->next ;
				*dc = *(dc->next) ;
				free( ptr ) ;
			}
			else
				dc->data.id = NULL ;
			return 1 ;
		}

		while( dc->next != NULL && strcmp ( dc->next->data.id , key ) != 0 ) //search for key in the rest of list
			dc = dc->next ;
			
		if( dc->next != NULL )//if the key exists
		{
			DataChain *ptr = dc->next ;
			dc->next = dc->next->next ;
			free ( ptr->data.id ) ;
			free ( ptr ) ;
			return 1 ;
		}
	}
	return 0 ;
} 

//returns NULL if key doesn't exist.
static Symbol * __dc_get( DataChain *dc , const char *key )
{
	if ( dc->data.id == NULL )
		return NULL ;

	while ( dc != NULL && ( strcmp( dc->data.id , key ) != 0 ) ) 
		dc = dc->next ;
	

	return ( dc == NULL ) ? NULL : &dc->data ;
}

static void __dc_destroy( DataChain *dc )
{
	DataChain *tmp, *ptr = dc ;
	if( ptr->data.id != NULL )
	{
		free( ptr->data.id ) ;
		ptr = ptr->next ;
		while( ptr != NULL ) 
		{
			free( ptr->data.id ) ;
			tmp = ptr ;
			ptr = ptr->next ;
			free( tmp ) ;
		}
	}
}
 
SymbolTable st_init( const size_t size , const size_t (*hfunc) (const size_t,const char*) )
{
	return (SymbolTable) { 0 , size , hfunc , calloc( size , sizeof ( DataChain ) ) } ;
}

Symbol * st_add( SymbolTable *st , const Symbol s )
{
	const size_t index = st->hashfunc( st->size , s.id ) ;
	Symbol *ret = __dc_add( &st->table[index] , s ) ; 

	st->nb_elts += !ret ;

	return ret ;
}

static unsigned int __next_tmp_num = 1 ;

Symbol * st_new_temp( SymbolTable *st , struct symbol_info si )
{
	const char *tmp_prefix = "$tmp_" ;	
	
	const size_t n = strlen( tmp_prefix ) ;
	size_t tmp_length = n + ceil( log10( ++ __next_tmp_num ) )+1;

	char *tmp = malloc( tmp_length * sizeof( char ) ) ;

	tmp = strcpy( tmp , tmp_prefix ) ;
	sprintf( tmp + n  , "%u" , __next_tmp_num-1) ;

	Symbol s = (Symbol) { tmp , si } ;

	return st_add( st , s ) ;
}

int st_delete( SymbolTable *st , const char *key )
{
	const size_t index = st->hashfunc( st->size , key ) ;
	const int ret = __dc_delete( &st->table[index] , key ) ;

	st->nb_elts -= ret ;

	return ret ;
}

Symbol * st_lookup( const SymbolTable *st , const char *key )
{
	const size_t index = st->hashfunc( st->size , key ) ;

	return __dc_get( &st->table[index] , key ) ;		
}

void st_destroy( SymbolTable st ) 
{
	int i;
	for( i = 0 ; i < st.size ; ++ i )
		__dc_destroy( st.table + i ) ;
	free( st.table ) ;
}

void st_print(SymbolTable st)
{
	int i;
	printf( "nbelts: %zu\n" , st.nb_elts ) ;  
	for( i = 0 ; i < st.size ; ++ i )
	{
		DataChain *ptr = &st.table[i] ;
		printf( "h[%d] = " , i ) ;
		while( ptr != NULL )
		{
			printf( "-> %s" ,  ptr->data.id ) ;
			ptr = ptr->next ;
		}
		printf("\n");
	}
}

			
//const size_t hash( const size_t s , const char *str )
//{
//	size_t ind = 0 ;
//	while( *str != '\0' )
//		ind += *(str++) ;
//	return ind % s;
//}
//
//int main(void){
//	SymbolTable st = st_init( 2 , &hash ) ; 
//	st_add( &st , "coucou" , 1 ) ;
//	st_add( &st , "juif",1 ) ;
//	st_add( &st , "cartman" ,1) ;
//	st_add( &st , "juif" ,1) ;
////	st_delete( &st , "haha");
//	st_delete( &st , "coucou" ) ;
//	st_print( st ) ;
//	st_destroy( st ) ;
//	return 0 ;
//}
