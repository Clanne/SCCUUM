SRC=src
IDIR=include
ODIR=obj
CC=gcc
CFLAGS= -g -Wall -I$(IDIR)

# list of dependencies for main target
OBJFILES=ast.o y.tab.o lex.yy.o
OBJ=$(patsubst %,$(ODIR)/%,$(OBJFILES))

sccuum: $(OBJ) | obj
	$(CC) $(CFLAGS) -o $@ $^ -lfl

$(ODIR)/%.o: $(SRC)/%.c | obj
	$(CC) $(CFLAGS) -o $@ -c $<

$(SRC)/y.tab.c:
	yacc -d sccuum.y 
	mv y.tab.c $(SRC)
	mv y.tab.h $(IDIR)

$(SRC)/lex.yy.c:
	lex sccuum.l
	mv lex.yy.c $(SRC)

obj:
	mkdir $(ODIR)

clean :
	rm obj/* $(SRC)/lex.yy.c $(SRC)/y.tab.c $(IDIR)/y.tab.h

cleanall : clean
	rm sccuum
