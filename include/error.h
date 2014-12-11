#ifndef __ERROR_H__
#define __ERROR_H__

#include "stdio.h"
#include "stdlib.h"

static inline void already_declared_error( const char *id )
{
	printf( "error: %s déjà déclaré\n" , id ) ;
	exit(EXIT_FAILURE);
}

static inline void not_declared_error( const char *id )
{
	printf( "error: %s pas déclaré\n" , id ) ;
	exit(EXIT_FAILURE);
}

#endif
