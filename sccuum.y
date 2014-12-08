%{
	#include "ast.h"
	#include "hash_table.h"
	#include "quads.h"
	int yylex();
	int yyerror( char *msg );
	QuadList ql ;
	extern FILE* yyin;

	const size_t checksum(const size_t n, const char* s)
	{
		size_t sum = 0;
		char c ;
		while( (c = *(s++)) != '\0' )
			sum += c;
		return sum % n ;
	}
	
%}

%union{
	Code code;
	int valeur;
	char* string;
	char* op;
}

%token <valeur> ENTIER
%token <string> ID
%token IF
%token ELSE
%token WHILE
%token FOR
%token OPINCR
%token OPDECR
%token MAIN
%token INT
%token BOOL_AND
%token BOOL_OR
%type <op> operation_bin
%type <code> expr
%type <code> bool_expr
%type <code> affect
%type <code> affect_list
%type <code> stmt
%type <code> stmt_list
%type <code> declaration
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

operation_bin :
	  '+'	{$$ = "OPADD";}
	| '-'	{$$ = "OPSUB";}
	| '*'	{$$ = "OPMUL";}
	| '/'	{$$ = "OPDIV";}
	;
expr : 
	  expr operation_bin expr 				
	  {
		$$.code  = ql_concat($1.code,$3.code);
		$$.result = "tmp"; //st_new_temp();
		$$.code = ql_add($$.code, qop(quad_next(),$2 , $1.result , $3.result , $$.result));
	  }
	| '(' expr ')'

	{
		$$.code= $2.code;
		$$.falseList = $2.falseList;
		$$.trueList = $2.trueList;
	}
	| '+' expr
	{
		$$.code = $2.code;
		$$.trueList = $2.trueList;
		$$.falseList = $2.falseList;
		$$.next = $2.next;
	}
	| '-' expr
	{
		$$.code  = $2.code;
		$$.result = "new_tmp"; //st_new_temp();
		$$.code = ql_add($$.code, qop(quad_next(),"OPNEG" , $2.result , NULL , $$.result));
	}
	| ID OPINCR
	{
		Quad q = qop( quad_next() , "LOADID" , NULL , NULL , $1 );
		$$.code = ql_new(q);
		$$.result = $1;
		$$.result = "new_tmp"; //st_new_temp();
		$$.code = ql_add($$.code, qop(quad_next(),"OPPINC" ,$1 , NULL , $$.result));
	}
	| OPINCR ID
	{
		Quad q = qop( quad_next() , "LOADID" , NULL , NULL , $2 );
		$$.code = ql_new(q);
		$$.result = $2;
		$$.result = "new_tmp"; //st_new_temp();
		$$.code = ql_add($$.code, qop(quad_next(),"OPPRINC" , $2 , NULL , $$.result));
	}
	| ID OPDECR
	{
		Quad q = qop( quad_next() , "LOADID" , NULL , NULL , $1 );
		$$.code = ql_new(q);
		$$.result = $1;
		$$.result = "new_tmp"; //st_new_temp();
		$$.code = ql_add($$.code, qop(quad_next(),"OPPDEC" , $1 , NULL , $$.result));
	}
	| OPDECR ID
	{
		Quad q = qop( quad_next() , "LOADID" , NULL , NULL , $2 );
		$$.code = ql_new(q);
		$$.result = $2;
		$$.result = "new_tmp"; //st_new_temp();
		$$.code = ql_add($$.code, qop(quad_next(),"OPPRDEC" , $2 , NULL , $$.result));
	}
	| ENTIER
	{
		Quad q = qop( quad_next() , "ENTIER" , NULL , NULL , NULL );
		$$.code = ql_new(q);
		$$.result = "new_tmp"; //st_new_temp();
		//st_add(st,st_new_temp(),new_symbol($1));
	}
	/*| bool_expr
	{
		$$.code= $1.code;
		$$.falselist = $1.falseList;
		$$.truelist = $1.trueList;
	}*/
	| ID
	{
		Quad q = qop( quad_next() , "LOADID" , NULL , NULL , $1 );
		$$.code = ql_new(q);
		$$.result = $1;
	}
	;
/*
bool_expr :
	  expr BOOL_AND expr
	{
		complete($1.trueList, $3.code.head->q.label);
		$$.trueList = $3.trueList;
		$$.falseList = concat($1.falselist, $3.falselist);
		// Et puis le code de $$ c’est la concaténation des
		// codes de $1 et $3
		$$.code = quad_concat($1.code, $3.code);
	}
	| expr BOOL_OR expr			
	{
		complete($1.falseList, $3.code.head->q.label);
   		$$.trueList = concat($1.trueList, $3.trueList);
   		$$.falseList = $3.falseList;
		 	// Et puis le code de $$ c’est la concaténation des
		   	 // codes de $1 et $3
    		$$.code = quad_concat($1.code, $3.code);
	}
	| expr '>' expr
	{
		$$.trueList = newList(nextQuad);
		$$.falseList = newList(nextQuad + 1);
		// gen incrémente newQuad    
		gen("if $1.result > $3.result goto ?");
		gen("goto ?");
	}
	| '!' expr					
	{	
		$$.trueList=$2.falseList;
		$$.falseList=$2.trueList;
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
		complete($3.trueList, $5.code.head->q.label);
		complete($5.falseList, $3.code.head->q.label);
		$$.next = $3.falseList;
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
	yyin = fopen(argv[1],"r");

	yyparse();
	return 0;
}
