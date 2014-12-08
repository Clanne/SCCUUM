#ifndef __HASH_TABLE_H__
#define __HASH_TABLE_H__

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define DATATYPE int

//enum symbol_type{
//	TYPE_INT
//}
//
//typedef struct symbol{
//
//
//}

typedef struct data_chain{
	char *key ;
	DATATYPE data ;		
	struct data_chain *next ;
} DataChain;

typedef struct htable {
	size_t nb_elts ;
	const size_t size ;
	const size_t (*hashfunc) (const size_t , const char*) ;
	DataChain *table ;
} HashTable ;

/**
	creates a HashTable
	@param size The new HashTable's size, that is the maximum number of elements it can hold before adding an element will inevitably cause a collision
	@param hfunc A pointer on a hash function whose parameters are the tables size and a key
	@return The new HashTable
*/
HashTable ht_init( const size_t size , const size_t (*hfunc) (const size_t,const char*) ) ;
	
/**
	adds new data to the HashTable
	@param ht The table in which we are inserting the data
	@param key The key matched to the data we would like to insert
	@param d The inserted data
	@return 1 if insertion was successful and 0 otherwise
*/
int ht_add( HashTable *ht , const char *key , const DATATYPE d ) ;

/**
	deletes a key and its associate data
	@param ht The table in which we are deleting data
	@param key The key we wan't to be deleted
	@return 1 if deletion was successful and 0 otherwise.
*/
int ht_delete( HashTable *ht , const char *key ) ;

/**
	fetches a pointer to the data linked to the key
	@param ht The table where we are looking for the data
	@param key The key that will give us its associated data
	@return NULL if the key could not be found, otherwise returns a pointer to the data
*/
const DATATYPE * ht_get( const HashTable *ht , const char *key ) ;

/**
	deletes the hashtable and all the data its holding
	@param ht The hashtable to delete
*/
void ht_destroy( HashTable ht ) ;

/**
	prints the hashtable (for debugging purposes)
	@param ht The hashtable to print	
*/
void ht_print(HashTable ht) ;

#endif 
