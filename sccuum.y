%{
	#include "DynamicArray.h"
	#include "backpatch.h"
	#include "st_to_mips.h"
	#include "ql_to_mips.h"

	int yylex();
	int yyerror( char *msg );

	FILE *fout ;
	extern FILE *yyin ;

	SymbolTable st ;
%}

%union{
	struct {
		QuadList code ;
		QuadList true_list , false_list ;
		QuadList next ;
		Symbol *result ;
	} code;

	struct {
		QuadList code ; 
		QuadList backpatch ;
		Symbol *result ;
	} brack_op ;

	struct {
		int size;
		DynamicArray *tab;
	} intlist;

	struct {
		int taille;
		int nb_dim;
		int nb_val;
		DynamicArray *dim;
		DynamicArray *tab;
	} tablist;

	struct {
		int nb_dim;
		int nb_val;
		DynamicArray *dim;
		DynamicArray *tab;
	} tabinfo;

	struct {
		int nb_dim;
		DynamicArray *dim;
	} dim_info ;

	Symbol *symbol ;

	unsigned int label ;
	int valeur;
	char *id;
	char *instr ;
}

%token <valeur> ENTIER
%token <id> ID
%token IF ELSE
%token WHILE FOR
%token OPINCR OPDECR
%token BOOL_OR BOOL_AND
%token EQ GEQ LEQ
%token MAIN PRINTI RETURN
%token INT VOID STENCIL

%type <code> expr bool_expr affect affect_list affect_or_expr stmt stmt_list declaration declaration_list tag_goto tab_read tab_write tab_declaration operation_stencil
%type <intlist> liste_entier
%type <tablist> liste_tableau
%type <tabinfo> tableau
%type <dim_info> dimensions
%type <symbol> id_or_num
%type <brack_op> brackets_op
%type <instr> rel_op
%type <label> tag

%start declaration_stencil

%nonassoc ')'
%nonassoc ELSE
%right '='
%left '+' '-'
%left '*' '/'
%nonassoc OPINCR OPDECR
%right '!'
%left BOOL_AND BOOL_OR
%left '>' '<' EQ GEQ LEQ

%%

axiom :
	  INT MAIN '(' VOID ')' '{' stmt_list RETURN expr ';' '}'
	{
		Quad q = qop( "EXIT" , NULL , NULL , NULL ) ;
		$7.code = ql_add( ql_concat( $7.code , $9.code ) , q ) ;

		st_to_mips( &st , fout ) ;
		ql_to_mips( $7.code , fout ) ;
		st_print( st ) ;
		ql_print( $7.code  ) ;
	}
	;

id_or_num :
	  ENTIER	{ $$ = st_new_temp( &st , const_int( $1 ) ) ; }
	| ID		{ $$ = lookup( &st , $1 ) ; }
	;

expr : 
	  expr '+' expr 				
	{
		$$.code  = ql_concat($1.code,$3.code);
		$$.result = st_new_temp( &st , var_int() ) ; //st_new_temp();
		$$.code = ql_add( $$.code, qop( "OPADD" , $1.result , $3.result , $$.result));
	}
	| expr '-' expr 				
	{
		$$.code  = ql_concat($1.code,$3.code);
		$$.result = st_new_temp( &st , var_int() ) ; //st_new_temp();
		$$.code = ql_add( $$.code, qop( "OPSUB" , $1.result , $3.result , $$.result));
	}
	| expr '*' expr 				
	{
		$$.code  = ql_concat($1.code,$3.code);
		$$.result = st_new_temp( &st , var_int() ) ; //st_new_temp();
		$$.code = ql_add( $$.code, qop( "OPMUL" , $1.result , $3.result , $$.result));
	}
	| expr '/' expr 				
	{
		$$.code  = ql_concat($1.code,$3.code);
		$$.result = st_new_temp( &st , var_int() ) ; //st_new_temp();
		$$.code = ql_add( $$.code, qop( "OPDIV" , $1.result , $3.result , $$.result));
	}
	| '(' expr ')'
	{
		$$.code= $2.code;
		$$.result = $2.result ;
	}
	| '+' expr
	{
		$$.code = $2.code;
		$$.result = $2.result ;
	}
	| '-' expr
	{
		$$.code  = $2.code;
		$$.result = st_new_temp( &st , var_int() ) ; //st_new_temp();
		$$.code = ql_add($$.code, qop( "OPNEG" , $2.result , NULL , $$.result));
	}
	| ID OPINCR
	{
		$$.result = st_new_temp( &st , var_int() ) ; //st_new_temp();
		$$.code = ql_new( qop( "OPPOSTINC" , lookup( &st , $1 ) , NULL , $$.result ) );
	}
	| OPINCR ID
	{
		Symbol *s = lookup( &st , $2 ) ;
		$$.result = s ; //st_new_temp();
		$$.code = ql_new( qop( "OPPREINC" , s , NULL , s ) );
	}
	| ID OPDECR
	{
		$$.result = st_new_temp( &st , var_int() ) ; //st_new_temp();
		$$.code = ql_new( qop( "OPPOSTDEC" , lookup( &st ,$1 ) , NULL , $$.result ) );
	}
	| OPDECR ID
	{
		Symbol *s = lookup( &st , $2 ) ;
		$$.result = s ; //st_new_temp();
		$$.code = ql_new( qop( "OPPREDEC" , s , NULL , s ) );
	}
	| id_or_num
	{
		$$.code = ql_empty();
		$$.result = $1 ;
	}
	| tab_read
	{
		$$.code = $1.code ;
		$$.result = $1.result ;
	}
	;

tag :
	 /* vide */	{ $$ = quad_to_come() ; }
	;

rel_op :
	  '>'		{ $$ = "BRGT" ; } 
	| '<'		{ $$ = "BRLT" ; }
	| EQ		{ $$ = "BREQ" ; }
	| GEQ 		{ $$ = "BRGEQ" ; }
	| LEQ		{ $$ = "BRLEQ" ; }
	;

declaration_list :
	  ID ',' declaration_list
	{
		st_add( &st , s_var_int( $1 ) ) ; 
		$$ = $3 ;
	}
	| ID '=' expr ',' declaration_list
	{
		Symbol *s = st_add( &st , s_var_int( $1 ) ) ;
		$$.code = ql_add( ql_concat( $3.code , $5.code ) ,  qop( "OPMOVE" , $3.result , NULL , s ) ) ;
	}
	| ID
	{
		st_add( &st , s_var_int( $1 ) ) ; 
	}
	| ID '=' expr
	{
		Symbol *s = st_add( &st , s_var_int( $1 ) ) ;
		$$.code = ql_add( $3.code , qop( "OPMOVE" , $3.result , NULL , s ) ) ;
	}
	;

declaration :
	  INT declaration_list ';'
	{
		$$ = $2 ;
	}
	| tab_declaration 
	{
		$$ = $1 ;
	}
	;

bool_expr :
	  bool_expr BOOL_AND tag bool_expr
	{
		complete($1.true_list, $3 );
		$$.true_list = $4.true_list;
		$$.false_list = ql_concat($1.false_list, $4.false_list);
		$$.code = ql_concat($1.code, $4.code);
	}
	| bool_expr BOOL_OR tag bool_expr
	{
		complete( $1.false_list , $3 ) ;
		$$.true_list = ql_concat( $1.true_list , $4.true_list ) ;
		$$.false_list = $4.false_list ;
		$$.code = ql_concat( $1.code , $4.code ) ;
	}
	| '!' bool_expr
	{
		$$.true_list = $2.false_list ;
		$$.false_list = $2.true_list ;
		$$.code = $2.code ;
	}
	| expr rel_op expr
	{
		Quad tq = qbr( $2 , $1.result , $3.result , 0 ) ;
		Quad fq = qbr( "BRGOTO" , NULL , NULL , 0 ) ;
		$$.true_list = ql_new( tq ) ;
		$$.false_list = ql_new( fq ) ;

		$$.code = ql_add( ql_add( ql_concat( $1.code , $3.code ) , tq ) , fq ) ;
	}
	| '(' bool_expr ')'
	{
		$$ = $2 ;
	}
	;

tag_goto :
	  /* vide */
	{
		Quad q = qoto( 0 ) ;
		$$.code = ql_new( q ) ;
		$$.next = ql_new( q ) ;
	}
	;

affect :
	  ID '=' expr
	{
		Quad q = qop( "OPMOVE" , $3.result , NULL , lookup( &st , $1 ) ) ;
		$$.code = ql_concat( $3.code , ql_new( q ) ) ;
	}
	;

affect_list :
	  affect ',' affect_list
	{
		$$.code = ql_concat( $1.code , $3.code ) ;
	}
	| affect
	{
		$$ = $1 ;
	}
	;

affect_or_expr :
	  affect_list	{ $$ = $1 ; }
	| expr		{ $$ = $1 ; }
	;

stmt :
	  IF '(' bool_expr ')' tag stmt 
	{
		complete( $3.true_list , $5 ) ;
		$$.next = ql_concat( $3.false_list , $6.next ) ;
		$$.code = ql_concat( $3.code , $6.code );
	}
	| IF '(' bool_expr ')' tag stmt ELSE tag stmt
	{
		Quad q = qoto( 0 ) ; /* goto vers fin du else_stmt */

		complete( $3.true_list , $5 ) ;
		complete( $3.false_list , $8 ) ;

		$$.next = ql_concat( ql_new( q ) , $9.next ) ;
		$$.code = ql_concat4( $3.code , $6.code , ql_new( q ) , $9.code ) ;
	}
	| WHILE tag '(' bool_expr ')' tag stmt
	{
		complete( $4.true_list , $6 ) ;
		complete( $7.false_list , $2 ) ;
		complete( $7.next , $2 ) ;

		$$.next = $4.false_list ;
		$$.code = ql_add( ql_concat( $4.code , $7.code ) , qoto( $2 ) ) ;
	}
	| FOR '(' affect_list ';' tag bool_expr ';' tag affect_or_expr tag_goto ')' tag stmt
	{
		complete( $6.true_list , $12 ) ;
		complete( $10.next , $5 ) ;
		complete( $13.false_list , $5 ) ;
		complete( $13.next , $8 ) ;

		$$.next = $6.false_list ;
		$$.code = ql_add( ql_concat5( $3.code , $6.code , $9.code , $10.code , $13.code ) , qoto( $8 ) ) ;
	}
	| affect ';'
	{ 
		$$ = $1 ;
	}
	| expr ';' 
	{
		$$ = $1 ;
	}
	| declaration
	{
		$$ = $1 ;
	}
	| PRINTI '(' ID ')' ';'
	{
		$$.code = ql_new( qop( "PRINTI" , NULL , NULL , lookup( &st , $3 ) ) ) ;
	}
	| '{' stmt_list '}'
	{
		$$ = $2 ;
	}
	;

stmt_list :
	  stmt tag
	{
		complete( $1.next , $2 ) ;/* pour str de controle */
		$$ = $1 ;
	}
	| stmt tag stmt_list
	{
		complete( $1.next , $2 ) ;
		$$.code = ql_concat( $1.code , $3.code ) ;
		$$.true_list = ql_concat( $1.true_list , $3.true_list ) ;
		$$.false_list = ql_concat( $1.false_list , $3.false_list ) ;
		$$.next = ql_concat( $1.next , $3.next ) ;
	}
	;

tab_read :
	  ID brackets_op
	{
		unsigned int tmp[2] = { 4 , 3 } ;
		//TODO complete by passing ID data to backpatch
		backpatch_tab_accessor_op( &st , $2.backpatch , 2 , tmp ) ;

		Symbol *res = st_new_temp( &st , var_int() ) ;
		Quad q = qop( "TABREAD" , lookup( &st , $1 ) , $2.result ,  res ) ; /* fetch tab indice res */

		$$.code = ql_add( $2.code , q ) ;
		$$.result = res ;
	}
	;

tab_write :
	  ID brackets_op '=' id_or_num
	{
		unsigned int tmp[2] = { 4 , 3 } ;
		//TODO complete by passing ID data to backpatch
		backpatch_tab_accessor_op( &st , $2.backpatch , 2 , tmp ) ;

		Symbol *data = $4  ;
		Quad q = qop( "TABWRITE" , lookup( &st , $1 ) , $2.result , data ) ; /* fetch tab indice res */

		$$.code = ql_add( $2.code , q ) ;
	}
	;

brackets_op :
	  brackets_op '[' id_or_num ']'
	{
		Symbol *tmp = st_new_temp( &st , var_int() ) ;
		Quad q1 = qop( "OPMUL" , NULL , $3 , tmp ) ; /* doit être backpatché dès qu'on connait les dims du tableau */
		Quad q2 = qop( "OPADD" , $1.result , tmp , $1.result ) ;

		$$.code = ql_concat( $$.code , ql_add( ql_new( q1 ) , q2 ) ) ;
		$$.backpatch = ql_add( $1.backpatch , q1 ) ;
		$$.result = $1.result ;
	}
	| '[' id_or_num ']'
	{
		Symbol *res = st_new_temp( &st , var_int() ) ;
		Quad q1 = qop( "OPMOVE" , st_new_temp( &st , const_int( 0 ) ) , NULL , res ) ;
		Quad q2 = qop( "OPADD" , $2 , res , res ) ;

		$$.code = ql_add( ql_new( q1 ) , q2 ) ;
		$$.backpatch = ql_empty() ;
		$$.result = res ;
	}
	;

tab_declaration :
	  INT ID dimensions'['ENTIER']' ';'
	{
		int nbdim = 1 + $3.nb_dim ;
		array_push_back( $3.dim, &($5) ) ;
		if(st_add( &st, s_tab_info( $2,nbdim, $3.dim->container, NULL ) ) == NULL )
			already_declared_error( $2 ) ;
	}
	| INT ID dimensions '['ENTIER']' '=' tableau ';'
	{
		if ( $8.nb_dim != $3.nb_dim + 1)
			yyerror("Mauvaise dimensions de tableau");
		if(st_add( &st, s_tab_info( $2,$8.nb_dim, $8.dim->container, $8.tab->container ) ) == NULL )
			already_declared_error( $2 ) ;
	}
	;


liste_entier :
	liste_entier ENTIER ','
	{
		$$.size = 1 + $1.size ;
		$$.tab = $1.tab ;

		array_push_back( $$.tab, &($2) ) ;
	}
	| /* vide */
	{
		$$.size = 0 ;
		$$.tab = malloc( sizeof(DynamicArray) ) ;

		*($$.tab) = array_new( sizeof(int), 1 ) ;
	}
	;

tableau :
	  '{' liste_tableau tableau  '}'
	{
		$$.nb_dim = 1 + $2.nb_dim ;
		$$.nb_val = $2.nb_val + $3.nb_val ;
		$$.dim = $2.dim ;
		$$.tab = $2.tab ;
		int taille_dim = 1 + $2.taille ;
		array_push_back( $$.dim, &taille_dim) ;
		array_concat($$.tab,$3.tab);
	}
	| '{'liste_entier ENTIER  '}'
	{
		$$.nb_dim = 1 ;
		$$.nb_val = 1+$2.size ;
		$$.tab = $2.tab ;
		$$.dim = malloc( sizeof(DynamicArray) ) ;
		*($$.dim) = array_new( sizeof(int), 1 ) ;

		int taille_dim = 1 + $2.size ;
		int val_int = $3 ;
		array_push_back( $$.dim, &taille_dim ) ;
		array_push_back( $$.tab, &val_int) ;
	}
	;

liste_tableau :
	  liste_tableau tableau ','
	{
		$$.nb_dim = $1.nb_dim ;
		$$.dim = $2.dim ;
		$$.taille = 1 + $1.taille ;
		$$.nb_val = $2.nb_val + $1.nb_val ;
		$$.tab = $2.tab ;

		array_concat( $$.tab, $1.tab ) ;
	}
	| /* vide */
	{
		$$.nb_dim = 1 ;
		$$.tab = malloc( sizeof(DynamicArray) ) ;
		$$.dim = malloc( sizeof(DynamicArray) ) ;
		$$.taille = 0 ;
		$$.nb_val = 0 ;

		*($$.tab) = array_new( sizeof(int), 1 ) ;
		*($$.dim) = array_new( sizeof(int), 1 ) ;
	}
	;

dimensions :
	  dimensions'[' ENTIER ']' 
	{
		$$.nb_dim = 1 + $1.nb_dim ;
		$$.dim = $1.dim ;
		array_push_back( $$.dim, &($3) ) ;
	}
	| /* vide */ 
	{
		$$.nb_dim = 0 ;
		$$.dim = malloc( sizeof(DynamicArray) ) ;
		*($$.dim) = array_new( sizeof(int), 1 ) ;
	}

declaration_stencil :
	  STENCIL	ID	'{'	ENTIER 	','	 ENTIER 	'}'	 '=' 	tableau ';'
	{

		if (  $9.nb_dim == $6 )
		{
			int good = 1;
			int i;
			int val_per_dim = ($4 * 2) +1;
			for ( i = 0; i < $6 && good ; ++i)
			{
				good += (*(int*)array_get($9.dim,i) == val_per_dim);
			}
			if (good)
			{	if(st_add( &st, s_stencil_info( $2,$4, $6, $9.tab->container ) ) == NULL )
					already_declared_error( $2 ) ;	}
			else
				yyerror("invalid stencil");
		}
		else
			yyerror("invalid stencil");
	}
	;
operation_stencil :
	  ID brackets_op '$' ID
	{
		Symbol* tab = lookup(&st,$1) ;
		Symbol* sten = lookup(&st,$7) ;
		if (tab->info.type == TYPE_TAB  &&  sten->info.type == TYPE_STENCIL)
		{
			int sten_voisin = sten->info.u.sinfo.voisinage ;
			int* sten_val_tab = ten->info.u.sinfo.init_val ;
			int sten_nb_dim = sten->info.u.sinfo.nb_dim ;

			int tab_nb_dim = tab->info.u.tinfo.nb_dim ;
			int* tab_dim = tab->info.u.tinfo.dim ;
			int* tab_val = tab->info.u.tinfo.init_val ;

			Symbol *indice_centre = $2.result;
			int taille_stencil = pow((sten_voisin * 2) +1),sten_nb_dim;
			int indice_centre_stencil = taille_stencil / 2 + 1 ;
			
			int n =0;
			int res = 0;
			int i;
			while(n != sten_nb_dim)
			{
				for ( i = -sten_voisin; i =< sten_voisin; ++i)
				{
					a
				}
			}
		}
		else
			yyerror("Use of stencil operator :\n \t tab[int] $ stencil \n \t stencil $ tab[int]")
	}

%%

char * new_fname( char *old_name )
{
	int i = 0 ;
	static char buf[256] ;
	
	while( old_name[i] != '.' && old_name[i] != '\0' )
	{ 
		buf[i] = old_name[i] ;
		++ i ;
	}

	strcpy( buf + i , ".s" ) ;

	return buf ;
}

int yyerror (char *s) 
{
	printf("\n%s\n", s);
	return 0;
}

int main(int argc, char** argv)
{
	if (argc != 2)
	{
		printf("usage : %s filename",argv[0]);
		exit(0);
	}
	st = st_init( 10, &checksum ) ;
	yyin = fopen(argv[1],"r");

	fout = fopen( new_fname( argv[1] ) , "w+" ) ;

	yyparse();
	return 0;
}
