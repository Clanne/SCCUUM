#include "quads.h"

static unsigned int nextQuad = 1 ;

unsigned long quad_next( void )
{
	return nextQuad ++ ;
}

QuadList ql_new( Quad q )
{
	QuadList newQl ;
	struct qlist_node *newNode = malloc( sizeof *newNode ) ;

	newNode->q = q ;
	newNode->next = NULL ;

	newQl.head = newQl.tail = newNode ;
	newQl.n = 1 ;

	return newQl ;
}

QuadList ql_add( QuadList ql , Quad q )
{
	QuadList newQl = ql ;
	struct qlist_node *newNode = malloc( sizeof *newNode ) ;

	newNode->q = q ;
	newNode->next = NULL ;

	newQl.n ++ ;
	newQl.tail = newQl.tail->next = newNode ;

	return newQl ;
}

QuadList ql_concat( QuadList ql_left , QuadList ql_right ) 
{
	QuadList qlNew ;

	qlNew.head = ql_left.head ;
	qlNew.tail = ql_right.tail ;

	qlNew.n = ql_left.n + ql_right.n ;

	ql_left.tail->next = ql_right.head ;

	return qlNew ;
}

void complete( QuadList ql , unsigned long label )
{
	struct qlist_node *iterator = ql.head ;

	while( iterator != NULL )
	{
		if( iterator->q.res.label == 0 )
			iterator->q.res.label = label ;
		
		iterator = iterator->next ;
	}
}

static void __print_quad( Quad q )
{
	printf( "addr:0x%x ,instr: %s %s %s " , q.label , instr , operandes[0] , operandes[1] ) ;

	if( quad_is_branch( q ) )
		printf( "%s" , q.res.ret_id ) ;
	else
		printf( "%x" , q.res.label ) ;

	printf( "\n" ) ;
}

void ql_print( QuadList ql )
{
	struct qlist_node *ptr = ql.head ;
	
	while( ptr != NULL )
	{
		__print_quad( ptr->q ) ;
		ptr = ptr->next ;
	}
}
