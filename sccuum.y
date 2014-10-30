%{
	#include "ast.h"
	int yylex();
%}

%union{
	ast* tree;
	int valeur;
	char* string;
}

%token <valeur> ENTIER
%token <string> ID
%type <tree> expr
%type <tree> stmt
%start ligne
%left '+'
%right '='
%left '*'
%%

ligne: 
	stmt '\n'
	{
		printf("Chaine reconnue !\n");
		ast_print($1,0);
	}
	;

expr : 
	expr '+' expr 		{$$ = ast_new_op("OPADDI",$1,$3);}
	| expr '*' expr 	{$$ = ast_new_op("OPMULT",$1,$3);}
	| expr '-' expr 	{$$ = ast_new_op("OPSOUS",$1,$3);}
	| expr '/' expr 	{$$ = ast_new_op("OPDIVI",$1,$3);}
	| '(' expr ')' 		{$$ = $2;}
	| '+' expr 		{$$ = $2;}
	| '-' expr		{$$ = ast_new_op("OPMULT",ast_new_number(-1),$2);}
	| ENTIER 		{$$ = ast_new_number($1);}
	| ID '+' '+'		{$$ = ast_new_op("OPPOSTINC",ast_new_id($1),NULL);}
	| '+' '+' ID		{$$ = ast_new_op("OPPREINC",ast_new_id($3),NULL);}
	| ID '-' '-'		{$$ = ast_new_op("OPPOSTDEC",ast_new_id($1),NULL);}
	| '-' '-' ID		{$$ = ast_new_op("OPPREDEC",ast_new_id($3),NULL);}
	| ID			{$$ = ast_new_id($1);}
	;

stmt:
	';'			{$$ = ast_new_op("NOOP",NULL,NULL);}
	| ID '=' expr ';'	{$$ = ast_new_op("AFFECT",ast_new_id($1),$3);}
	| expr ';'
	;
%%

int yyerror (char *s) {
	printf("\n%s\n", s);
	return 0;
}

int main(void){
	printf("BALANCE TON CALCUL SALOPE\n");
	yyparse();
	return 0;
}
