#include "DynamicArray.h"

static inline void __increase_buffer_size( DynamicArray *array )
{
	array->cont_size *= 2 ;
	array->container = realloc( array->container , array->cont_size * array->elt_size ) ;
}

static inline void * __get_ith_elt( const DynamicArray* array , const size_t i )
{
	return ((char*)array->container) + array->elt_size * i ;
}

static inline void * __fetch_tail( const DynamicArray *array )
{
	return __get_ith_elt( array , array->nb_elts - 1 ) ;
}
 
DynamicArray array_new( const size_t elt_size , const size_t init_size )
{
	DynamicArray array ;	

	array.elt_size = elt_size ;
	array.cont_size = init_size ;
	array.nb_elts = 0 ;
	array.container = malloc( init_size * elt_size ) ;

	return array ;
}

void array_delete( DynamicArray *array )
{
	array->elt_size = 0 ;
	array->cont_size= 0 ;
	array->nb_elts = 0 ;
	free( array->container ) ;
}

void array_remove( DynamicArray *array , const size_t i )
{
	size_t m , es ;
	void *from , *to ;

	es = array->elt_size ;

	m = ( array->nb_elts - i ) * es ; /* size of the chunk we wan't to copy */

	to = __get_ith_elt( array , i ) ;
	from = (char*)to + es ;

	memmove( to , from , m ) ;
	array->nb_elts -= 1 ;
}

void array_insert( DynamicArray *array , const size_t i , const void *elt )
{
	size_t m , n , es ;
	void *from , *to ;

	es = array->elt_size ;
	n = array->nb_elts ;

	if( array->cont_size == n )
		__increase_buffer_size( array ) ;

	m = ( n - i + 1 ) * es ; /* size of the chunk we wan't to copy */

	from = __get_ith_elt( array , i ) ;
	to = (char*)from + es ;

	memmove( to , from , m ) ;
	array->nb_elts += 1 ;
}

void array_push_back( DynamicArray *array , const void *elt )
{
	size_t n , esize ;

	esize = array->elt_size ;
	n = array->nb_elts ;

	if( array->cont_size == n )
		__increase_buffer_size( array ) ;

	array->nb_elts += 1 ;

	memcpy( __fetch_tail( array ) , elt , esize ) ;
}

void array_pop_back( DynamicArray *array )
{
	array->nb_elts -= 1 ;
}

void * array_get( const DynamicArray *array , const size_t i )
{
	return __get_ith_elt( array , i ) ;
}

void array_concat(DynamicArray *array, DynamicArray *array_to_add)
{
	int i ;
	for ( i = 0 ; i < array_to_add->nb_elts ; ++i )
	{
		array_push_back( array, array_get( array_to_add, i ) );
	}
}

void array_shrink( DynamicArray *array )
{
	array->container = realloc( array->container , array->nb_elts * array->elt_size ) ;
}

