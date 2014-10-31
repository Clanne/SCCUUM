#include "ast.h"


ast* ast_new_op(char* type, unsigned int arrite_op , ... )
{
	
	assert( arrite_op <= 4 );
	
	va_list arg_list ;

	ast* new = malloc(sizeof(ast));
	new->type = type;
	new->n = arrite_op ;

	va_start( arg_list , arrite_op );
	
	int i;
	for( i = 0 ; i < arrite_op ; ++ i )
		new->u.fils[i] = va_arg( arg_list , ast* );  

	va_end( arg_list ) ;
	return new;
}


void ast_free(ast* tree)
{
	if(tree != NULL )
	{
		int i;
		for( i=0 ; i<tree->n ; i++ )
			ast_free(tree->u.fils[i]);
		free(tree);
	}
}

ast* ast_new_number(int val)
{
	ast* new = malloc(sizeof(ast));
	new->type = "ENTIER";
	new->n = 0;
	new->u.number = val;
	return new;
}


ast* ast_new_id(char* val)
{
	ast* new = malloc(sizeof(ast));
	new->type = "ID";
	new->n = 0;
	new->u.id = val;
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
			int i;
			for ( i=0 ; i < tree->n ; i++ )
				ast_print(tree->u.fils[i], indent + 1 );
		}
	}
}

