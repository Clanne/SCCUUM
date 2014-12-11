#ifndef __DYNAMIC_ARRAY_H__
#define __DYNAMIC_ARRAY_H__

#include <stdlib.h>
#include <string.h>

typedef struct {
	size_t elt_size ;
	size_t cont_size ;
	size_t nb_elts ;
	void *container ;
} DynamicArray ;


DynamicArray array_new( const size_t elt_size , const size_t init_size );

void array_delete( DynamicArray *array ) ;

void array_remove( DynamicArray *array , const size_t i ) ;

void array_insert( DynamicArray *array , const size_t i , const void *elt ) ;


void array_push_back( DynamicArray *array , const void *elt ) ;

void array_pop_back( DynamicArray *array ) ;

void * array_get( const DynamicArray *array , const size_t i ) ;

void array_shrink( DynamicArray *array ) ;

#endif
