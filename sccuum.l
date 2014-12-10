%{
	#include "ast.h"
	#include "quads.h"
	#include "y.tab.h"
%}

id [_A-Za-z][_A-Za-z0-9]*
entier [1-9][0-9]*
syntaxe [+*()-\=<>{};.]

%%

"main()"		{return MAIN;}

"if" 			{return IF;}
"else" 			{return ELSE;}
"while"			{return WHILE;}
"for" 			{return FOR;}

"&&"			{return BOOL_AND;}
"||"			{return BOOL_OR;}

"int"			{return INT;}

"++"			{return OPINCR;}
"--"			{return OPDECR;}

{entier} 		{ yylval.valeur = atoi(yytext); return ENTIER; }
{id} 			{ yylval.id = strdup(yytext);return ID; }
{syntaxe} 		{ return yytext[0]; }


[ \t\n] 		{}
. 			{ printf("wtf? Are you drunk ?????\n"); }

%%
