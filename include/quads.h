#ifndef __QUADS_H__
#define __QUADS_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct quad{
	unsigned long label ;
	char *instr ;	
        char *operandes[2] ;
	union{
		char *ret_id ;
		unsigned long label ;
	} res ; 
} Quad ;

 
struct qlist_node {
        Quad q ;
        struct qlist_node *next ;
} ;

typedef struct {
        size_t n ;
        struct qlist_node *head ;
	struct qlist_node *tail ;
} QuadList ;

//Quad quad_new_op( unsigned int label , char *op , char *oper1 , char *oper2 , char *ret ) ;
//
//Quad quad_new_branch( unsigned int label , char *op , char *oper1 , char *oper2 , unsigned int ret ) ; 

static inline int quad_is_branch( Quad q )
	{ return strncmp( q.instr , "BR" , 2 ) ; }

unsigned long quad_next(void);

QuadList ql_new( Quad q ) ;

QuadList ql_add( QuadList ql , Quad q ) ;

QuadList ql_concat( QuadList ql_left , QuadList ql_right ) ;

void complete( QuadList ql , unsigned long label ) ;

#endif
