#ifndef __AST_H__
#define __AST_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <assert.h>


typedef struct ast{
	char* type;
	size_t n;
	union{
		struct ast* fils[4];
		int number;
		char* id;
	} u;
} ast;

ast* ast_new_op(char* type, unsigned int arrite_op , ... );
ast* ast_new_number(int val);
ast* ast_new_id(char* val);
void ast_free(ast* tree);
void ast_print(ast* tree, int indent);

#endif
