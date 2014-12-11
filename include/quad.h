#ifndef __QUAD_H__
#define __QUAD_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "symbol.h"

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

static inline Quad qoto( unsigned int label )
	{ return qbr( "BRGOTO" , NULL , NULL , label ) ; }

#endif
