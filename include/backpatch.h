#ifndef __BACKPATCH_H__
#define __BACKPATCH_H__

#include "quad_list.h"
#include "symbol_table.h"

void backpatch_tab_accessor_op( SymbolTable *st , QuadList code , unsigned int ndim , unsigned int *dim ) ;

#endif
