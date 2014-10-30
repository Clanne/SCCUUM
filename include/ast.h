#ifndef AST_H
#define AST_h


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct ast{
	char* type;
	union{
		struct{
			struct ast* left;
			struct ast* right;
		} operation;
		int number;
		char* id;
	} u;
} ast;

ast* ast_new_op(char* type, ast*left, ast* right);
ast* ast_new_number(int val);
ast* ast_new_id(char* val);
void ast_free(ast* tree);
void ast_print(ast* tree, int indent);

#endif
