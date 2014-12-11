#ifndef __ERROR_H__
#define __ERROR_H__

#define QUIT exit(EXIT_FAILURE);

#include "stdio.h"
#include "stdlib.h"

static inline void already_declared_error( char *id )
{
	printf( "error: %s déjà déclaré\n" , id ) ;
	QUIT
}

static inline void not_declared_error( char *id )
{
	printf( "error: %s pas déclaré\n" , id ) ;
	QUIT
}

#endif
