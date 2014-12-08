#include "hash_table.h"

//returns 1 if successful and 0 otherwise
static int dc_add( DataChain *dc , const char *key  , const DATATYPE d )
{
	if( dc->key != NULL ) 
	{
		DataChain *ptr = dc ;

		while( ptr != NULL )//go to the end of the list if the key doesn't exist
		{
			if( strcmp( dc->key , key ) == 0 ) 
				return 0 ;//the key already exists.
			dc = ptr ;
			ptr = ptr->next ;
		}

		dc->next = malloc ( sizeof *dc ) ;
		dc = dc->next ;
	}

	dc->key = strdup ( key ) ;
	dc->data = d ;
	dc->next = NULL ;

	return 1 ;//the key does not exist and new data was added.
}

//returns 1 if an element was deleted and 0 otherwise
static int dc_delete( DataChain *dc , const char *key )
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
static const DATATYPE * dc_get( const DataChain *dc , const char *key )
{
	if ( dc->key == NULL )
		return NULL ;

	while ( dc != NULL && strcmp( dc->key , key ) != 0 ) ;
		dc = dc->next ;

	return ( dc == NULL ) ? NULL : &dc->data ;
}

static void dc_destroy( DataChain *dc )
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
 
HashTable ht_init( const size_t size , const size_t (*hfunc) (const size_t,const char*) )
{
	return (HashTable) { 0 , size , hfunc , calloc( size , sizeof ( DataChain ) ) } ;
}

int ht_add( HashTable *ht , const char *key , const DATATYPE d )
{
	const size_t index = ht->hashfunc( ht->size , key ) ;
	const int ret = dc_add( &ht->table[index] , key , d ) ; 

	ht->nb_elts += ret ;

	return ret ;
}

int ht_delete( HashTable *ht , const char *key )
{
	const size_t index = ht->hashfunc( ht->size , key ) ;
	const int ret = dc_delete( &ht->table[index] , key ) ;

	ht->nb_elts -= ret ;

	return ret ;
}

const DATATYPE * ht_get( const HashTable *ht , const char *key )
{
	const size_t index = ht->hashfunc( ht->size , key ) ;
	return dc_get( &ht->table[index] , key ) ;		
}

void ht_destroy( HashTable ht ) 
{
	int i;
	for( i = 0 ; i < ht.size ; ++ i )
		dc_destroy( ht.table + i ) ;
	free( ht.table ) ;
}

void ht_print(HashTable ht)
{
	int i;
	printf( "nbelts: %zu\n" , ht.nb_elts ) ;  
	for( i = 0 ; i < ht.size ; ++ i )
	{
		DataChain *ptr = &ht.table[i] ;
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
//	HashTable ht = ht_init( 2 , &hash ) ; 
//	ht_add( &ht , "coucou" , 1 ) ;
//	ht_add( &ht , "juif",1 ) ;
//	ht_add( &ht , "cartman" ,1) ;
//	ht_add( &ht , "juif" ,1) ;
////	ht_delete( &ht , "haha");
//	ht_delete( &ht , "coucou" ) ;
//	ht_print( ht ) ;
//	ht_destroy( ht ) ;
//	return 0 ;
//}
