#ifndef __SYMBOL_TABLE_H__
#define __SYMBOL_TABLE_H__

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

enum symbol_type{
	TYPE_VAR_INT ,
	TYPE_CONST_INT
} ;

typedef struct symbol{
	enum symbol_type type ;
	int const_val ;
} Symbol ;

typedef struct data_chain{
	char *key ;
	Symbol data ;		
	struct data_chain *next ;
} DataChain;

typedef struct {
	size_t nb_elts ;
	size_t size ;
	const size_t (*hashfunc) (const size_t , const char*) ;
	DataChain *table ;
} SymbolTable ;

/**
	creates a SymbolTable
	@param size The new SymbolTable's size, that is the maximum number of elements it can hold before adding an element will inevitably cause a collision
	@param hfunc A pointer on a hash function whose parameters are the tables size and a key
	@return The new SymbolTable
*/
SymbolTable st_init( const size_t size , const size_t (*hfunc) (const size_t,const char*) ) ;
	
/**
	adds new data to the SymbolTable
	@param st The table in which we are inserting the data
	@param key The key matched to the data we would like to insert
	@param d The inserted data
	@return 1 if insertion was successful and 0 otherwise
*/
int st_add( SymbolTable *st , const char *key , const Symbol d ) ;

/**
 * TODO: doc
 */
char * st_new_temp( SymbolTable *st , Symbol s ) ;

/**
	deletes a key and its associate data
	@param st The table in which we are deleting data
	@param key The key we wan't to be deleted
	@return 1 if deletion was successful and 0 otherwise.
*/
int st_delete( SymbolTable *st , const char *key ) ;

/**
	fetches a pointer to the data linked to the key
	@param st The table where we are looking for the data
	@param key The key that will give us its associated data
	@return NULL if the key could not be found, otherwise returns a pointer to the data
*/
const Symbol * st_lookup( const SymbolTable *st , const char *key ) ;

/**
	deletes the hashtable and all the data its holding
	@param st The hashtable to delete
*/
void st_destroy( SymbolTable st ) ;

/**
	prints the hashtable (for debugging purposes)
	@param st The hashtable to print	
*/
void st_print(SymbolTable st) ;

#endif 
