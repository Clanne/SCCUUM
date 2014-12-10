#ifndef __QUADS_H__
#define __QUADS_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "symbol.h"

/////////////////////////// Quad //////////////////////////
typedef struct quad{
	unsigned long label ;
	char *instr ;	
        Symbol *operandes[2] ;
	union{
		Symbol *ret_id ;
		unsigned long label ;
	} res ; 
} *Quad ;


static inline int quad_is_branch( Quad q )
	{ return strncmp( q->instr , "BR" , 2 ) == 0; }

unsigned long quad_next(void);

unsigned long quad_to_come( void );

Quad qop( char *op , Symbol *oper1 , Symbol *oper2 , Symbol *ret )  ;

/*Cree un quad representant une instr de branchement*/
Quad qbr( char *op , Symbol *oper1 , Symbol *oper2 , unsigned int ret ) ;

/////////////////////// Quadlists ////////////////////////

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

void complete( QuadList ql , unsigned long label ) ;

void ql_print( QuadList ql ) ;

#endif
