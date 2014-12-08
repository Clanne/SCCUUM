#include "symbol_table.h"

//returns 1 if successful and 0 otherwise
static Symbol * __dc_add( DataChain *dc , char *key  , const Symbol d )
{
	if( dc->key != NULL ) 
	{
		DataChain *ptr = dc ;

		while( ptr != NULL )//go to the end of the list if the key doesn't exist
		{
			if( strcmp( dc->key , key ) == 0 ) 
				return NULL ;//the key already exists.
			dc = ptr ;
			ptr = ptr->next ;
		}

		dc->next = malloc ( sizeof *dc ) ;
		dc = dc->next ;
	}

	dc->key =  key ;
	dc->data = d ;
	dc->next = NULL ;

	return &dc->data ;//the key does not exist and new data was added.
}

//returns 1 if an element was deleted and 0 otherwise
static int __dc_delete( DataChain *dc , const char *key )
{
	if( dc->key != NULL ) 
	{
		if(  strcmp ( dc->key , key ) == 0 )//check if key is the first member in the list
		{
			free( dc->key ) ;
			if( dc->next != NULL  ) 
			{
				DataChain *ptr = dc->next ;
				*dc = *(dc->next) ;
				free( ptr ) ;
			}
			else
				dc->key = NULL ;
			return 1 ;
		}

		while( dc->next != NULL && strcmp ( dc->next->key , key ) != 0 ) //search for key in the rest of list
			dc = dc->next ;
			
		if( dc->next != NULL )//if the key exists
		{
			DataChain *ptr = dc->next ;
			dc->next = dc->next->next ;
			free ( ptr->key ) ;
			free ( ptr ) ;
			return 1 ;
		}
	}
	return 0 ;
} 

//returns NULL if key doesn't exist.
static const Symbol * __dc_get( const DataChain *dc , const char *key )
{
	if ( dc->key == NULL )
		return NULL ;

	while ( dc != NULL && strcmp( dc->key , key ) != 0 ) ;
		dc = dc->next ;

	return ( dc == NULL ) ? NULL : &dc->data ;
}

static void __dc_destroy( DataChain *dc )
{
	DataChain *tmp, *ptr = dc ;
	if( ptr->key != NULL )
	{
		free( ptr->key ) ;
		ptr = ptr->next ;
		while( ptr != NULL ) 
		{
			free( ptr->key ) ;
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

static Symbol * __st_add_no_alloc( SymbolTable *st , char *key , const Symbol d )
{
	const size_t index = st->hashfunc( st->size , key ) ;
	Symbol *ret = __dc_add( &st->table[index] , key , d ) ; 

	st->nb_elts += !ret ;

	return ret ;
}

int st_add( SymbolTable *st , const char *key , const Symbol s )
{
	char *new_key = strdup( key ) ;

	Symbol *ptr = __st_add_no_alloc( st , new_key , s ) ;

	if( ptr == NULL )
		free( new_key ) ;

	return !ptr ;
}

static unsigned int __next_tmp_num = 1 ;

char * st_new_temp( SymbolTable *st , Symbol s )
{
	const char *tmp_prefix = "$tmp_" ;	
	
	unsigned int tmp_length = strlen( tmp_prefix ) + ceil( log( __next_tmp_num ) ) + 1 ;

	char *tmp = malloc( tmp_length * sizeof( char ) ) ;

	strcpy( tmp , tmp_prefix ) ;
	sprintf( tmp , "%u" , __next_tmp_num ) ;

	__st_add_no_alloc( st , tmp , s ) ;
	__next_tmp_num ++ ;
	
	return tmp ; 
}

int st_delete( SymbolTable *st , const char *key )
{
	const size_t index = st->hashfunc( st->size , key ) ;
	const int ret = __dc_delete( &st->table[index] , key ) ;

	st->nb_elts -= ret ;

	return ret ;
}

const Symbol * st_lookup( const SymbolTable *st , const char *key )
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
			printf( "-> %s" ,  ptr->key ) ;
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
