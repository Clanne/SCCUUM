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

QuadList ql_empty( void )
{
	QuadList newQl ;

	newQl.head = newQl.tail = NULL ;
	newQl.n = 0 ;

	return newQl ;
}

QuadList ql_add( QuadList ql , Quad q )
{
	QuadList newQl = ql ;
	struct qlist_node *newNode = malloc( sizeof *newNode ) ;

	newNode->q = q ;
	newNode->next = NULL ;

	newQl.n = ql.n + 1 ;

	if( ql.tail != NULL )
		newQl.tail = newQl.tail->next = newNode ;
	else{
		newQl.tail = newNode ;
		newQl.head = newNode ;
	}

	return newQl ;
}

QuadList ql_concat( QuadList ql_left , QuadList ql_right ) 
{
	QuadList qlNew ;

	if( ql_left.head != NULL )
	{
		qlNew.head = ql_left.head ;
		ql_left.tail->next = ql_right.head ;
	}
	else 
		qlNew.head = ql_right.head ;

	if( ql_right.tail != NULL )
		qlNew.tail = ql_right.tail ;
	else 
		qlNew.tail = ql_left.tail ;

	qlNew.n = ql_left.n + ql_right.n ;

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
	printf( "addr:0x%lx,  instr: %s, op1:%s, op2:%s, " , q.label , q.instr , q.operandes[0] , q.operandes[1] ) ;

	if( quad_is_branch( q ) )
		printf( "res:%s" , q.res.ret_id ) ;
	else
		printf( "goto:%lx" , q.res.label ) ;

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
