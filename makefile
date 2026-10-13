miniC: main.c miniC.tab.c lex.yy.c listaSimbolos.c listaCodigo.c
	gcc lex.yy.c main.c miniC.tab.c listaSimbolos.c listaCodigo.c -lfl -o miniC

miniC.tab.c miniC.tab.h: miniC.y listaSimbolos.h listaCodigo.h
	bison -d -v miniC.y

lex.yy.c: miniC.l
	flex miniC.l

limpia:
	rm -f lex.yy.c miniC.tab.c miniC.tab.h miniC output