#include "hash_table.h"

//returns 1 if the key already exists and 0 otherwise.
static int dc_add( DataChain *dc , char *key  , const DATATYPE d )
{
	if( dc->key != NULL ) {

		DataChain *ptr = dc ;

		while( ptr != NULL )//go to the end of the list if the key doesn't exist
		{
			if( strcmp( dc->key , key ) == 0 ) 
				return 1 ;//the key already exists.
			dc = ptr ;
			ptr = ptr->next ;
		}

		dc->next = malloc ( sizeof *dc ) ;
	}

	dc->key = key ;
	dc->data = d ;

	return 0 ;//the key does not exist.
}

static void dc_delete( DataChain *dc , const char *key )
{
	if( !dc->key ) 
		return ;

	if( dc->next == NULL  && strcmp ( dc->key , key ) != 0 )
		dc->key = NULL ;

	while( dc->next != NULL && strcmp ( dc->next->key , key ) != 0 )
		dc = dc->next ;
		
	if( dc->next != NULL )
	{
		DataChain *ptr = dc->next ;
		*dc->next = *dc->next->next ;
		free ( ptr ) ;
	}
} 

//returns NULL if key doesn't exist.
static DATATYPE * dc_get( DataChain *dc , const char *key )
{
	if ( dc->key == NULL )
		return NULL ;

	while( dc != NULL && strcmp( dc->key , key ) != 0 ) ;
		dc = dc->next ;

	return ( dc == NULL ) ? NULL : &dc->data ;
}
 
HashTable init( const size_t size , size_t (*hfunc) (const size_t,const char*) )
{
	return (HashTable) { 0 , size , hfunc , calloc( size , sizeof ( DataChain ) ) } ;
}

int ht_add( HashTable *ht , char *key , const DATATYPE d )
{
	size_t index = ht->hashfunc( ht->size , key ) ;
	return dc_add( &ht->table[index] , key , d ) ; 
}

void ht_delete( HashTable *ht , const char *key )
{
	size_t index = ht->hashfunc( ht->size , key ) ;
	dc_delete( &ht->table[index] , key ) ;
}

DATATYPE * ht_get( HashTable *ht , const char *key )
{
	size_t index = ht->hashfunc( ht->size , key ) ;
	return dc_get( &ht->table[index] , key ) ;		
}
