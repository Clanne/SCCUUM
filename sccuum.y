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
	Code code;
	int valeur;
	char* string;
	char* op;
}

%token <valeur> ENTIER
%token <string> ID
%token IF ELSE
%token WHILE FOR
%token OPINCR OPDECR
%token BOOL_OR BOOL_AND
%token MAIN
%token INT
%type <code> expr bool_expr affect affect_list stmt stmt_list declaration

%start fichiercode

%nonassoc ')'
%nonassoc ELSE
%right '='
%left '+' '-'
%left '*' '/'
%nonassoc OPINCR OPDECR

%%

fichiercode: 
	  expr	{ ql_print($1.code);}
	;

expr : 
	  expr '+' expr 				
	{
		$$.code  = ql_concat($1.code,$3.code);
		$$.result = st_new_temp( &st , s_var_int() ) ; //st_new_temp();
		$$.code = ql_add( $$.code, qop( "OPADD" , $1.result , $3.result , $$.result));
	}
	| expr '-' expr 				
	{
		$$.code  = ql_concat($1.code,$3.code);
		$$.result = st_new_temp( &st , s_var_int() ) ; //st_new_temp();
		$$.code = ql_add( $$.code, qop( "OPSUB" , $1.result , $3.result , $$.result));
	}
	| expr '*' expr 				
	{
		$$.code  = ql_concat($1.code,$3.code);
		$$.result = st_new_temp( &st , s_var_int() ) ; //st_new_temp();
		$$.code = ql_add( $$.code, qop( "OPMUL" , $1.result , $3.result , $$.result));
	}
	| expr '/' expr 				
	{
		$$.code  = ql_concat($1.code,$3.code);
		$$.result = st_new_temp( &st , s_var_int() ) ; //st_new_temp();
		$$.code = ql_add( $$.code, qop( "OPDIV" , $1.result , $3.result , $$.result));
	}
	| '(' expr ')'

	{
		$$.code= $2.code;
		$$.result = $2.result ;
		$$.false_list = $2.false_list;
		$$.true_list = $2.true_list;
	}
	| '+' expr
	{
		$$.code = $2.code;
		$$.result = $2.result ;
		$$.true_list = $2.true_list;
		$$.false_list = $2.false_list;
		$$.next = $2.next;
	}
	| '-' expr
	{
		$$.code  = $2.code;
		$$.result = "new_tmp"; //st_new_temp();
		$$.code = ql_add($$.code, qop( "OPNEG" , $2.result , NULL , $$.result));
	}
	| ID OPINCR
	{
		$$.result = "new_tmp"; //st_new_temp();
		$$.code = ql_new( qop( "OPPOSTINC" , $1 , NULL , $$.result ) );
	}
	| OPINCR ID
	{
		$$.result = "new_tmp"; //st_new_temp();
		$$.code = ql_new( qop( "OPPREINC" , $2 , NULL , $$.result ) );
	}
	| ID OPDECR
	{
		$$.result = "new_tmp"; //st_new_temp();
		$$.code = ql_new( qop( "OPPOSTDEC" , $1 , NULL , $$.result ) );
	}
	| OPDECR ID
	{
		$$.result = "new_tmp"; //st_new_temp();
		$$.code = ql_new( qop( "OPPREDEC" , $2 , NULL , $$.result ) );
	}
	| ENTIER
	{
		$$.code = ql_empty() ;
		$$.result = st_new_temp( &st , s_const_int($1) ) ; 
	}

	/*| bool_expr
	{
		$$.code= $1.code;
		$$.falselist = $1.false_list;
		$$.truelist = $1.true_list;
	}*/
	| ID
	{
		$$.code = ql_empty();
		$$.result = $1;
	}
	;
/*
bool_expr :
	  expr BOOL_AND expr
	{
		complete($1.true_list, $3.code.head->q.label);
		$$.true_list = $3.true_list;
		$$.false_list = concat($1.falselist, $3.falselist);
		// Et puis le code de $$ c’est la concaténation des
		// codes de $1 et $3
		$$.code = quad_concat($1.code, $3.code);
	}
	| expr BOOL_OR expr			
	{
		complete($1.false_list, $3.code.head->q.label);
   		$$.true_list = concat($1.true_list, $3.true_list);
   		$$.false_list = $3.false_list;
		 	// Et puis le code de $$ c’est la concaténation des
		   	 // codes de $1 et $3
    		$$.code = quad_concat($1.code, $3.code);
	}
	| expr '>' expr
	{
		$$.true_list = newList(nextQuad);
		$$.false_list = newList(nextQuad + 1);
		// gen incrémente newQuad    
		gen("if $1.result > $3.result goto ?");
		gen("goto ?");
	}
	| '!' expr					
	{	
		$$.true_list=$2.false_list;
		$$.false_list=$2.true_list;
		$$.code=$2.code;
	}
	;

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
