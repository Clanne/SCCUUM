%{
	#include "ast.h"
	int yylex();
	int yyerror( char *msg );
	extern FILE* yyin;
%}

%union{
	ast* tree;
	int valeur;
	char* string;
}

%token <valeur> ENTIER
%token <string> ID
%token IF
%token ELSE
%token WHILE
%token FOR
%token OPINCR
%token OPDECR
%type <tree> expr
%type <tree> affect
%type <tree> stmt
%type <tree> stmt_list
%start code
%left '+'
%right '='
%left '*'

%%

code: 
	stmt_list
	{
		ast_print($1,0);
		printf("Chaine reconnue !\n");
		ast_free($1);
	}
	;

expr : 
	  expr '+' expr 				{$$ = ast_new_op("OPADDI",2,$1,$3);}
	| expr '*' expr 				{$$ = ast_new_op("OPMULT",2,$1,$3);}
	| expr '-' expr 				{$$ = ast_new_op("OPSOUS",2,$1,$3);}
	| expr '/' expr 				{$$ = ast_new_op("OPDIVI",2,$1,$3);}
	| '(' expr ')' 					{$$ = $2;}
	| '+' expr 					{$$ = $2;}
	| '-' expr					{$$ = ast_new_op("OPMULT",2,ast_new_number(-1),$2);}
	| ID OPINCR					{$$ = ast_new_op("OPPOSTINC",1,ast_new_id($1));}
	| OPINCR ID					{$$ = ast_new_op("OPPREINC",1,ast_new_id($2));}
	| ID OPDECR					{$$ = ast_new_op("OPPOSTDEC",1,ast_new_id($1));}
	| OPDECR ID					{$$ = ast_new_op("OPPREDEC",1,ast_new_id($2));}
	| ENTIER 					{$$ = ast_new_number($1);}
	| ID						{$$ = ast_new_id($1);}

	;
affect :

	ID '=' expr					{$$ = ast_new_op("AFFECT",2,ast_new_id($1),$3);}
	;

stmt:
	  ';'						{$$ = ast_new_op("NOOP",0);}
	| affect ';'					{$$ = $1;}
	| expr ';'					{$$ = $1;}
	| IF '(' expr ')' stmt				{$$ = ast_new_op("IF",2,$3,$5);}
	| IF '(' expr ')' stmt ELSE stmt		{$$ = ast_new_op("IFELSE",3,$3,$5,$7);}
	| WHILE '(' expr ')' stmt			{$$ = ast_new_op("WHILE",2,$3,$5);}
	| FOR '(' affect ';' expr ';' affect ')' stmt	{$$ = ast_new_op("FOR",4,$3,$5,$7,$9);}
	| FOR '(' affect ';' expr ';' expr ')' stmt	{$$ = ast_new_op("FOR",4,$3,$5,$7,$9);}
	| '{' stmt_list '}'				{$$ = $2;}
	| stmt ';' 					{$$ = $1;}
	;
stmt_list:
	stmt						{$$ = $1;}
	|stmt_list stmt					{$$ = ast_new_op("STLIST",2,$1,$2);}
	;
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
