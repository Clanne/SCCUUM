%{
	#include "symbol_table.h"
	#include "quads.h"

	int yylex();
	int yyerror( char *msg );

	extern FILE* yyin;

	const size_t checksum(const size_t s, const char *str)
	{
		size_t ind = 0 ;
		while( *str != '\0' )
			ind += *(str++) ;
		return ind % s;
	}

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
}

%token <valeur> ENTIER
%token <id> ID
%token IF ELSE
%token WHILE FOR
%token OPINCR OPDECR
%token BOOL_OR BOOL_AND
%token MAIN
%token INT

%type <code> expr bool_expr affect affect_list stmt stmt_list declaration
%type <label> tag

%start test

%nonassoc ')'
%nonassoc ELSE
%right '='
%left '+' '-'
%left '*' '/'
%nonassoc OPINCR OPDECR
%left BOOL_AND

%%

fichiercode: 
	  expr	{ ql_print($1.code);}
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
		$$.code = ql_new( qop( "OPPOSTINC" , st_lookup( &st , $1 ) , NULL , $$.result ) );
	}
	| OPINCR ID
	{
		$$.result = st_new_temp( &st , var_int() ) ; //st_new_temp();
		$$.code = ql_new( qop( "OPPREINC" , st_lookup( &st ,$2 ) , NULL , $$.result ) );
	}
	| ID OPDECR
	{
		$$.result = st_new_temp( &st , var_int() ) ; //st_new_temp();
		$$.code = ql_new( qop( "OPPOSTDEC" , st_lookup( &st ,$1 ) , NULL , $$.result ) );
	}
	| OPDECR ID
	{
		$$.result = st_new_temp( &st , var_int() ) ; //st_new_temp();
		$$.code = ql_new( qop( "OPPREDEC" , st_lookup( &st ,$2 ) , NULL , $$.result ) );
	}
	| ENTIER
	{
		$$.code = ql_empty() ;
		$$.result = st_new_temp( &st , const_int($1) ) ; 
	}

	| ID
	{
		$$.code = ql_empty();
		$$.result = st_add( &st , s_var_int( $1 ) ) ;
	}
	;

tag:
	 /* vide */	{ $$ = quad_to_come() ; }
	;

test:
	  bool_expr 
	{
		ql_print( $1.code ) ;
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
		$$.false_list = $1.false_list ;
		$$.code = ql_concat( $1.code , $4.code ) ;
	}
	| expr '>' expr
	{
		Quad tq = qbr( "BRGT" , $1.result , $3.result , 0 ) ;
		Quad fq = qbr( "BRGOTO" , NULL , NULL , 0 ) ;
		$$.true_list = ql_new( tq ) ;
		$$.false_list = ql_new( fq ) ;

		$$.code = ql_add( ql_add( ql_concat( $1.code , $3.code ) , tq ) , fq ) ;
	}
	;

 /*
declaration :
	  INT ID					{$$ = ast_new_id($2);}
	| INT affect_list				{$$ = $2;}
	;
affect :

	  ID '=' expr					{$$ = ast_new_op("AFFECT",2,ast_new_id($1),$3);}
	;

affect_list:
	  affect					{$$ = $1;}
	| affect_list ',' affect			{$$ = ast_new_op("AFLIST",2,$1,$3);}
	;
stmt:
	  ';'						{$$ = ast_new_op("NOOP",0);}
	| '{' stmt_list '}'				{$$ = $2;}
	| affect_list					{$$ = $1;}
	| declaration					{$$ = $1;}
	| expr ';'					{$$ = $1;}

	| IF '(' expr ')' stmt 				{$$ = ast_new_op("IF",2,$3,$5);}
	{
		complete($3.truelist, $5;label_premier_quad);
		$$;next= concat($3.falselist,$5.next);
	}

	| IF '(' expr ')' stmt ELSE stmt		{$$ = ast_new_op("IFELSE",3,$3,$5,$7);}
	| WHILE '(' expr ')' stmt			
	{    
		complete($3.true_list, $5.code.head->q.label);
		complete($5.false_list, $3.code.head->q.label);
		$$.next = $3.false_list;
		gen(“goto $3.code.head->q.label”);
	}
	| FOR '(' affect_list ';' expr ';' affect_list ')' stmt	{$$ = ast_new_op("FOR",4,$3,$5,$7,$9);}
	| FOR '(' affect_list ';' expr ';' expr ')' stmt	{$$ = ast_new_op("FOR",4,$3,$5,$7,$9);}
	;

stmt_list:
	  stmt						{$$ = $1;}
	| stmt_list stmt				{$$ = ast_new_op("STLIST",2,$1,$2);}
	; 
 */

%%

int yyerror (char *s) {

	printf("\n%s\n", s);
	return 0;
}

int main(int argc, char** argv){
	if (argc != 2)
	{
		printf("usage : %s filename",argv[0]);
		exit(0);
	}
	st = st_init( 4096 , &checksum ) ;
	yyin = fopen(argv[1],"r");

	yyparse();
	return 0;
}
