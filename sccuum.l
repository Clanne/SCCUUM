%{
	#include "DynamicArray.h"
	#include "quad_list.h"
	#include "symbol_table.h"
	#include "y.tab.h"

	extern SymbolTable st ;
%}

id [_A-Za-z][_A-Za-z0-9]*
entier -?[0-9][0-9]*
syntaxe [+*()-\=<>{};.!\[\]]

%%

"main"			{return MAIN;}
"printi"		{return PRINTI;}
"return "		{return RETURN;}

"if" 			{return IF;}
"else" 			{return ELSE;}
"while"			{return WHILE;}
"for" 			{return FOR;}

">="			{return GEQ ;}
"<="			{return LEQ ; }
"=="			{return EQ ;}

"&&"			{return BOOL_AND;}
"||"			{return BOOL_OR;}

"int"			{return INT;}
"void"			{return VOID;}

"++"			{return OPINCR;}
"--"			{return OPDECR;}

{entier} 		{ yylval.valeur = atoi(yytext); return ENTIER; }
{id} 			{ 
				Symbol *s = st_lookup( &st , yytext ) ; 

				if( s == NULL )
					yylval.id = strdup(yytext);
				else 
					yylval.id = s->id ;

				return ID; 
			}

{syntaxe} 		{ return yytext[0]; }


[ \t\n] 		{}
. 			{ printf("wtf? Are you drunk ?????\n"); }

%%
