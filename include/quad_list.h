#ifndef __QUAD_LIST_H__
#define __QUAD_LIST_H__

#include "quad.h"

struct qlist_node {
        Quad q ;
        struct qlist_node *next ;
} ;

typedef struct {
        size_t n ;
        struct qlist_node *head ;
	struct qlist_node *tail ;
} QuadList ;

QuadList ql_new( Quad q ) ;

QuadList ql_empty( void ) ;

QuadList ql_add( QuadList ql , Quad q ) ;

QuadList ql_concat( QuadList ql_left , QuadList ql_right ) ;

static inline QuadList ql_concat3( QuadList q1 , QuadList q2 , QuadList q3 ) 
	{ return ql_concat( ql_concat( q1 , q2 ) , q3 ) ; }

static inline QuadList ql_concat4( QuadList q1 , QuadList q2 , QuadList q3 , QuadList q4 )
	{ return ql_concat( ql_concat3( q1 , q2 , q3 ) , q4 ) ; }

static inline QuadList ql_concat5( QuadList q1 , QuadList q2 , QuadList q3 , QuadList q4 , QuadList q5 )
	{ return ql_concat( ql_concat4( q1 , q2 , q3 , q4 ) , q5 ) ; }

void complete( QuadList ql , unsigned long label ) ;

void ql_print( QuadList ql ) ;

#endif
