#include "ql_to_mips.h"

enum instr{
	NOP,
	ADD, SUB , MUL , DIV ,
	POSTINC, POSTDEC , PREINC , PREDEC ,
	MOVE,
	GOTO , BREQ, BRGT , BRLT , BRGEQ , BRLEQ ,
	PRINTI , EXIT
} ;

struct {
	char *name ;
	enum instr op_code ;
} op_tab[] = { 
	{ "NOP"   , NOP } ,
	{ "OPADD" , ADD } , { "OPSUB" , SUB } , { "OPMUL" , MUL } , { "OPDIV" , DIV } ,
	{ "OPPOSTINC" , POSTINC } , { "OPPOSTDEC" , POSTDEC } , { "OPPREINC" , PREINC } , { "OPPREDEC" , PREDEC } ,
	{ "OPMOVE" , MOVE } ,
	{ "BRGOTO" , GOTO } , { "BREQ" , BREQ }, { "BRGT" , BRGT } , { "BRLT" , BRLT } , { "BRGEQ" , BRGEQ } , { "BRLEQ" , BRLEQ } ,
	{ "PRINTI" , PRINTI } , { "EXIT" , EXIT }
} ;
	
enum instr __get_op_code( char *instr )
{
	int i ;
	size_t n = sizeof op_tab / sizeof op_tab[0] ;

	for( i = 0 ; i < n ; ++ i )
	{
		if( strcmp( op_tab[i].name , instr ) == 0 )
			return op_tab[i].op_code ;
	}
	return NOP ;
}

void __bin_op( char *op  , char *ret , FILE *out)
{
	fprintf( out , "\t%s \t$t2, $t0, $t1\n" , op ) ;
	fprintf( out , "\tsw \t$t2, %s\n" , ret  ) ;
}

void __br_op( char *op , unsigned int label , FILE *out )
{
	fprintf( out , "\t%s \t$t0, $t1, label%u\n" , op , label ) ;
}

void __goto( unsigned int label , FILE *out )
{
	fprintf( out , "\tj \tlabel%u\n" , label ) ;
}

void __instr_to_mips( char *instr , char *op1 , char *ret , FILE *out )
{
	char *opname  = "nop" ;

	switch( __get_op_code( instr ) )
	{
	case ADD: opname = "add" ; __bin_op( opname , ret , out ) ; break ;
	case SUB: opname = "sub" ; __bin_op( opname , ret , out ) ; break ;
	case MUL: opname = "mul" ; __bin_op( opname , ret , out ) ; break ;
	case DIV: opname = "div" ; __bin_op( opname , ret , out ) ; break ;
	case POSTINC: fprintf( out , "\tli \t$t1, 1\n\tadd \t$t2, $t0, $t1\n\tsw \t$t0, %s\n\tsw \t$t2, %s\n" , ret , op1 ) ; break ;
	case POSTDEC: fprintf( out , "\tli \t$t1, -1\n\tadd \t$t2, $t0, $t1\n\tsw \t$t0, %s\n\tsw \t$t2, %s\n" , ret , op1 ) ; break ;
	case PREINC: fprintf( out , "\tli \t$t1, 1\n\tadd \t$t2, $t0, $t1\n\tsw \t$t2, %s\n" , ret ) ; break ;
	case PREDEC: fprintf( out , "\tli \t$t1, -1\n\tadd \t$t2, $t0, $t1\n\tsw \t$t2, %s\n" , ret ) ; break ;
	case MOVE: fprintf( out , "\tsw \t$t0, %s\n" , ret )   ; break ;
	case PRINTI: fprintf( out , "\tlw \t$a0, %s\n\tli \t$v0, 1\n\tsyscall\n" , ret ) ; break ;
	case EXIT: fprintf( out , "\tli \t$v0, 10\n\tsyscall\n" ) ; break ;
	default:
		;
	}
}

void __branch_to_mips( char *instr  , unsigned int label , FILE *out )
{
	char *opname  = "j" ;

	switch( __get_op_code( instr ) )
	{
	case GOTO: __goto( label , out ) ; break ;
	case BREQ: opname = "beq" ; __br_op( opname , label , out ) ; break ;
	case BRGT: opname = "bgt" ; __br_op( opname , label , out ) ; break ;
	case BRLT: opname = "blt" ; __br_op( opname , label , out ) ; break ;
	case BRGEQ: opname = "bge" ; __br_op( opname , label , out ) ; break ;
	case BRLEQ: opname = "ble" ; __br_op( opname , label , out ) ; break ;
	default:
		;
	}
}

void __quad_to_mips( Quad q , FILE *out ) 
{
	char *op1 = NULL ;
	fprintf( out , "label%lu:\n" , q->label ) ;

	if( q->operandes[0] != NULL )
	{
		op1 = q->operandes[0]->id ;
		fprintf( out , "\tlw\t$t0, %s\n" ,  op1 ) ;
	}

	if( q->operandes[1] != NULL )
		fprintf( out , "\tlw\t$t1, %s\n" , q->operandes[1]->id ) ;

	if( quad_is_branch( q ) )
		__branch_to_mips( q->instr , q->res.label , out ) ;
	else
	{
		char *ret = q->res.ret_id == NULL ? NULL : q->res.ret_id->id ;
		__instr_to_mips( q->instr , op1 ,  ret , out ) ;
	}

}

void ql_to_mips( QuadList ql , FILE *out )
{
	struct qlist_node *it = ql.head ;

	fprintf( out , ".text\n\nmain:\n" ) ;
	while( it != NULL )
	{
		__quad_to_mips( it->q , out ) ;
		it = it->next ;
	}
}
