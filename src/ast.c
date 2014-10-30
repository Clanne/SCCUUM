#include "ast.h"


ast* ast_new_op(char* type, ast* left, ast* right)
{
	ast* new = malloc(sizeof(ast));
	new->type = type;
	new->u.operation.left = left;
	new->u.operation.right = right;
	return new;
}

void ast_free(ast* tree)
{
	if(tree != NULL )
	{
		if ( strcmp(tree->type,"ENTIER") != 0)
			if  ( strcmp(tree->type,"ID") != 0)
			{
				ast_free(tree->u.operation.left);
				ast_free(tree->u.operation.right);
			}
			else
				free(tree->u.id);
		free(tree);
	}
}

ast* ast_new_number(int val)
{
	ast* new = malloc(sizeof(ast));
	new->type = "ENTIER";
	new->u.number = val;
	return new;
}


ast* ast_new_id(char* val)
{
	ast* new = malloc(sizeof(ast));
	new->type = "ID";
	new->u.id = strdup(val);
	return new;
}

void ast_print(ast* tree, int indent)
{
	int i;
	for (i = 0; i < indent; i++)
		printf("\t");
	if(tree != NULL)
	{
		printf("%s : \n",tree->type);
		if ( strcmp(tree->type,"ENTIER") == 0 )
			printf("%d \n", tree->u.number);
		else if ( strcmp(tree->type,"ID") == 0 )
			printf("%s \n", tree->u.id);			
		else
		{
			ast_print(tree->u.operation.left, indent + 1 );
			ast_print(tree->u.operation.right, indent + 1 );
		}
	}
}

