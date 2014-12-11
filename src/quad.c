#include "quad.h"

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
