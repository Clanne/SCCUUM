#ifndef __SYMBOL_H__
#define __SYMBOL_H__

enum symbol_type{
	TYPE_VAR_INT ,
	TYPE_CONST_INT
} ;

struct symbol_info {
	enum symbol_type type ;
	int const_val ;
} ;

typedef struct{
	char *id ;
	struct symbol_info info ;
} Symbol ;

static inline struct symbol_info var_int()
	{ return ( struct symbol_info ) { TYPE_VAR_INT  } ; }

static inline struct symbol_info const_int( int valeur )
	{ return ( struct symbol_info ) { TYPE_CONST_INT , valeur } ; }

static inline Symbol s_var_int( char *id )
	{ return (Symbol){ id , { TYPE_VAR_INT } } ; }
	
static inline Symbol s_const_int( char *id , int val )
	{ return (Symbol){ id, const_int(val) } ; }

#endif
