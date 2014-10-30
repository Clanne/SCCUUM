%{
	#include "ast.h"
	#include "y.tab.h"
%}

id [_A-Za-z][_A-Za-z0-9]*
entier [1-9][0-9]*
syntaxe [+*()-\=<>{};.]

%%

{entier} { yylval.valeur = atoi(yytext); return ENTIER; }
{id} { yylval.string = yytext; return ID; }
{syntaxe} { return yytext[0]; }
[\n] {return yytext[0];}
. { printf("wtf? Are you drunk ?????\n"); }

%%
