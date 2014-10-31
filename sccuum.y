%{
	#include "ast.h"
	int yylex();
	int yyerror( char *msg );
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
%type <tree> expr
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
		printf("Chaine reconnue !\n");
		ast_print($1,0);
	}
	;

expr : 
	  expr '+' expr 	{$$ = ast_new_op("OPADDI",$1,$3);}
	| expr '*' expr 	{$$ = ast_new_op("OPMULT",$1,$3);}
	| expr '-' expr 	{$$ = ast_new_op("OPSOUS",$1,$3);}
	| expr '/' expr 	{$$ = ast_new_op("OPDIVI",$1,$3);}
	| '(' expr ')' 		{$$ = $2;}
	| '+' expr 		{$$ = $2;}
	| '-' expr		{$$ = ast_new_op("OPMULT",ast_new_number(-1),$2);}
	| ID '+' '+'		{$$ = ast_new_op("OPPOSTINC",ast_new_id($1),NULL);}
	| '+' '+' ID		{$$ = ast_new_op("OPPREINC",ast_new_id($3),NULL);}
	| ID '-' '-'		{$$ = ast_new_op("OPPOSTDEC",ast_new_id($1),NULL);}
	| '-' '-' ID		{$$ = ast_new_op("OPPREDEC",ast_new_id($3),NULL);}
	| ENTIER 		{$$ = ast_new_number($1);}
	| ID			{$$ = ast_new_id($1);}
	;

stmt:
	  ';'			{$$ = ast_new_op("NOOP",NULL,NULL);}
	| ID '=' expr ';'	{$$ = ast_new_op("AFFECT",ast_new_id($1),$3);}
	| expr ';'		{$$ = $1;}
	| IF '(' expr ')' stmt	{$$ = ast_new_op("IF",$3,$5);}
	| '{' stmt_list '}'	{$$ = $2;}
	;
stmt_list:
	stmt ';'		{$$ = $1;}
	|stmt stmt_list		{$$ = ast_new_op("NOOP",$1,$2);}
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
	
	yyin = fopen(argv[1]);

	yyparse();
	return 0;
}
