#include "quads.h"

static unsigned int nextQuad = 1 ;

unsigned long quad_next( void )
{
	return nextQuad ++ ;
}

unsigned long quad_to_come( void )
{
	return nextQuad ;
}

Quad qop( char *op , Symbol *oper1 , Symbol *oper2 , Symbol *ret )
{ 
	Quad q = malloc( sizeof *q ) ;

	q->label = quad_next() ;
	q->instr = op ;
	q->operandes[0] = oper1 ;
	q->operandes[1] = oper2 ;
	q->res.ret_id = ret ;

	return q ;
}

Quad qbr( char *op , Symbol *oper1 , Symbol *oper2 , unsigned int ret ) 
{ 
	Quad q = malloc( sizeof *q ) ;

	q->label = quad_next() ;
	q->instr = op ;
	q->operandes[0] = oper1 ;
	q->operandes[1] = oper2 ;
	q->res.label = ret ;

	return q ;
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
		if( iterator->q->res.label == 0 )
			iterator->q->res.label = label ;
		
		iterator = iterator->next ;
	}
}

static void __print_quad( Quad q )
{
	printf( "addr:0x%lx,  instr: %s," , q->label , q->instr ) ;

	if( q->operandes[0] != NULL )
		printf("\top1:%s," , q->operandes[0]->id ) ;

	if( q->operandes[1] != NULL )
		printf("\top2:%s," , q->operandes[1]->id ) ;

	if( quad_is_branch( q ) )
		printf( "\tgoto:%lx" , q->res.label ) ;
	else
		printf( "\tres:%s" , q->res.ret_id->id ) ;

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
