# file directories 
SRC=src
IDIR=include
ODIR=obj

# project name
MAIN=sccuum

# libraries
LIB=-lfl -lm

# C compiler options
CC=gcc
CFLAGS= -g -Wall -I$(IDIR) 

# list of dependencies for main target
OBJFILES=y.tab.o lex.yy.o symbol.o symbol_table.o quad.o quad_list.o DynamicArray.o st_to_mips.o ql_to_mips.o backpatch.o

# prepend directory prefix to .o files
OBJ=$(addprefix $(ODIR)/,$(OBJFILES))

# linker
$(MAIN): $(OBJ) | $(addprefix $(SRC)/,lex.yy.c y.tab.c)
	$(CC) $(CFLAGS) -o $@ $^ $(LIB)

# compiler
$(ODIR)/%.o: $(SRC)/%.c | obj
	$(CC) $(CFLAGS) -o $@ -c $<

# yacc
$(SRC)/y.tab.c:
	yacc -d -v sccuum.y
	mv y.tab.c $(SRC)
	mv y.tab.h $(IDIR)

# lex
$(SRC)/lex.yy.c:
	lex sccuum.l
	mv lex.yy.c $(SRC)

obj:
	mkdir $(ODIR)

clean :
	rm -v -rf $(ODIR) $(SRC)/lex.yy.c $(SRC)/y.tab.c $(IDIR)/y.tab.h

cleanall : clean
	rm -vf $(MAIN)
