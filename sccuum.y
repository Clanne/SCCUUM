%{
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
%token INT VOID

%type <code> expr bool_expr affect affect_list stmt stmt_list declaration tag_goto
%type <instr> rel_op
%type <label> tag

%start axiom

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
	  INT MAIN '(' VOID ')' '{' stmt_list RETURN ENTIER ';' '}'
	{
		Quad q = qop( "EXIT" , NULL , NULL , NULL ) ;
		$7.code = ql_add( $7.code , q ) ;

		st_to_mips( &st , fout ) ;
		ql_to_mips( $7.code , fout ) ;
		st_print( st ) ;
		ql_print( $7.code  ) ;
	}
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
	| ENTIER
	{
		$$.code = ql_empty() ;
		$$.result = st_new_temp( &st , const_int($1) ) ; 
	}
	| ID
	{
		$$.code = ql_empty();
		$$.result = lookup( &st , $1 ) ;
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

declaration :
	  INT ID ';'
	{
		st_add( &st , s_var_int( $2 ) ) ; 
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
	| FOR '(' affect_list ';' tag bool_expr ';' tag affect_list tag_goto ')' tag stmt
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

%%

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

	fout = fopen( "output.s" , "w+" ) ;

	yyparse();
	return 0;
}
