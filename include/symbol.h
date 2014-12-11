#ifndef __SYMBOL_H__
#define __SYMBOL_H__

#define MAX_TAB_DIMENSIONS 100 

enum symbol_type{
	TYPE_TAB ,
	TYPE_VAR_INT ,
	TYPE_CONST_INT
} ;

struct tab_info {
	unsigned int nb_dim ;
	unsigned int dim[MAX_TAB_DIMENSIONS] ;
	int *init_val ;
} ;

struct symbol_info {
	enum symbol_type type ;
	union{
		int const_val ;
		struct tab_info tinfo ;
	} u ;
} ;

typedef struct{
	char *id ;
	struct symbol_info info ;
} Symbol ;

static inline struct symbol_info var_int()
	{ return ( struct symbol_info ) { TYPE_VAR_INT  } ; }

static inline struct symbol_info const_int( int valeur )
	{ return ( struct symbol_info ) { TYPE_CONST_INT , .u.const_val = valeur } ; }

struct symbol_info tab_info( unsigned int n , unsigned int *dim , int *init_val ) ;

static inline Symbol s_var_int( char *id )
	{ return (Symbol){ id , { TYPE_VAR_INT } } ; }
	
static inline Symbol s_const_int( char *id , int val )
	{ return (Symbol){ id, const_int(val) } ; }

#endif
