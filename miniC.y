 %{
#include <stdio.h>
#include <stdlib.h>
#include "listaSimbolos.h"
#include "string.h"
extern int yylex();
extern char *yytext;
extern int yylineno;
void yyerror(const char *s);
Lista tablaSimb;
int contCadenas = 1;
int contEtiquetas = 1;
int tablaReg[10];
void inicTablaReg();
int posTablaReg();
char *obtenerEtiqueta();
char *obtenerRegistro();
void liberaReg(char *reg);
char *obtenerCadena(int n);
char *obtenerID(char* id);
extern int error;
%}
%code requires {
#include "listaCodigo.h"
}
%union{
char *lexema;
ListaC codigo;
}
%expect 1
%token INT VAR
%token CONST IFOP ELSEOP WHILE DO PRINT READ FOR
%token PLUSOP MINUSOP MULTOP DIVOP ASSIGNOP
%token LESSOP GREATEROP LESSEQOP GREATEREQOP EQOP NOTEQOP
%token LPAREN RPAREN LCORCHET RCORCHET SEMICOLON COMMA Q COLON
%token <lexema> STRING ID NUM
%type<codigo> statement_list expression statement print_list print_item read_list const_list declarations
%left LESSOP GREATEROP LESSEQOP GREATEREQOP EQOP NOTEQOP
%left PLUSOP MINUSOP
%left MULTOP DIVOP
%left UMENOS

%%

program : {tablaSimb = creaLS();} ID LPAREN RPAREN LCORCHET declarations statement_list RCORCHET{if(error == 0){concatenaLC($6,$7);imprimirLS(tablaSimb);imprimirLC($6);}liberaLS(tablaSimb);};
        ;
declarations : declarations VAR tipo var_list SEMICOLON
            {
                $$ = $1;
            }
             | declarations CONST tipo const_list SEMICOLON
             {
                concatenaLC($1, $4);
                $$ = $1;
             }
             | /* aqui iria lambda */
                {$$ = creaLC();}
             ;
tipo	     : INT
             ;
var_list : ID {
            if (buscaLS(tablaSimb, $1) == finalLS(tablaSimb)) { 
    
            Simbolo s = {.nombre = $1,.tipo = VARIABLE}; insertaLS(tablaSimb, finalLS(tablaSimb), s);
            }
            else {
                    fprintf(stderr, "Variable %s ya declarada en la línea %d\n",$1,yylineno);
                    error = 2;
            }
            }
         | var_list COMMA ID {if (buscaLS(tablaSimb, $3) == finalLS(tablaSimb)) { Simbolo s = {.nombre = $3,.tipo = VARIABLE}; insertaLS(tablaSimb, finalLS(tablaSimb), s);}
                else {
                    fprintf(stderr, "Variable %s ya declarada en la línea %d\n",$3,yylineno);
                    error = 2;
                    }
                }
         ;
const_list : ID ASSIGNOP expression {
                if (buscaLS(tablaSimb, $1) == finalLS(tablaSimb)) 
                {
                    Simbolo s = {.nombre = $1,.tipo = CONSTANTE}; 
                    insertaLS(tablaSimb, finalLS(tablaSimb), s);
                }
                else 
                {
                    fprintf(stderr, "Variable %s ya declarada en la línea %d\n",$1,yylineno);
                    error = 2;
                }
                ListaC l = $3;
                Operacion o = {.op = "sw", .res = recuperaResLC($3), .arg1 = obtenerID($1)};
                PosicionListaC pc = finalLC(l);
                insertaLC(l, pc, o);
                $$ = l;
                inicTablaReg();
                }
           | const_list COMMA ID ASSIGNOP expression {
                if (buscaLS(tablaSimb, $3) == finalLS(tablaSimb))
                {
                    Simbolo s = {.nombre = $3,.tipo = CONSTANTE};
                    insertaLS(tablaSimb, finalLS(tablaSimb), s);
                }
                else 
                {
                    fprintf(stderr, "Variable %s ya declarada en la línea %d\n",$3,yylineno);
                    error = 2;
                }
                ListaC l = $1;
                concatenaLC(l,$5);
                Operacion o = {.op = "sw", .res = recuperaResLC($5), .arg1 = obtenerID($3)};
                PosicionListaC pc = finalLC(l);
                insertaLC(l, pc, o);
                $$ = l;
                inicTablaReg();
                }
           ;
statement_list : statement_list statement
                {
                    ListaC l = creaLC();
                    concatenaLC(l, $1);
                    concatenaLC(l, $2);
                    $$ = l;
                }
               |/*aqui iria lambda*/
               {
                    $$ = creaLC();
               }
               ;
statement : ID ASSIGNOP expression SEMICOLON 
            { 
                PosicionLista pl = buscaLS(tablaSimb, $1);
                if(pl == finalLS(tablaSimb))
                {
                    fprintf(stderr, "Variable %s no declarada en la línea %d\n",$1, yylineno);
                    error = 2;
                }
                else if(recuperaLS(tablaSimb, pl).tipo == CONSTANTE)
                {
                    fprintf(stderr, "Asignación a constante en la línea %d\n", yylineno);
                    error = 2;
                }
                ListaC l = $3;
                Operacion o = {.op = "sw", .res = recuperaResLC($3), .arg1 = obtenerID($1)};
                free($1);
                PosicionListaC pc = finalLC(l);
                insertaLC(l, pc, o);
                $$ = l;
                inicTablaReg();
            }
          | LCORCHET statement_list RCORCHET
          {
                $$ = $2;
          }
          | IFOP LPAREN expression liberaif RPAREN statement ELSEOP statement
          {
                char *etiq1 = obtenerEtiqueta();
                Operacion o1 = {.op = "beqz", .res = recuperaResLC($3), .arg1 = etiq1};
                ListaC l = $3;
                PosicionListaC p = finalLC(l);
                insertaLC(l, p, o1);
                concatenaLC(l, $6);
                char *etiq2 = obtenerEtiqueta();
                Operacion o2 = {.op = "b", .res = etiq2};
                p = finalLC(l);
                insertaLC(l, p, o2);
                char salto1[32];
                sprintf(salto1,"%s:",etiq1);
                Operacion o3 = {.op = strdup(salto1)};
                p = finalLC(l);
                insertaLC(l, p, o3);
                concatenaLC(l, $8);
                char salto2[32];
                sprintf(salto2,"%s:",etiq2);
                Operacion o4 = {.op = strdup(salto2)};
                p = finalLC(l);
                insertaLC(l, p, o4);
                $$ = l;
          }
          | IFOP LPAREN expression liberaif RPAREN statement
          {
                char *etiq1 = obtenerEtiqueta();
                ListaC l = $3;
                Operacion p1 = { .op = "beqz", .res = recuperaResLC(l),.arg1 = etiq1};
                PosicionListaC p = finalLC(l);
                insertaLC(l, p, p1);
                concatenaLC(l, $6);
                char etiq2[32];
                sprintf(etiq2, "%s:", etiq1);
                Operacion o2 = {.op = strdup(etiq2)};
                p = finalLC(l);
                insertaLC(l, p, o2);
                $$ = l;
          }
          | WHILE LPAREN expression {liberaReg(recuperaResLC($3));} RPAREN statement
          {
                char *while1 = obtenerEtiqueta();
                char *fin_while = obtenerEtiqueta();
                char etiq1[32];
                sprintf(etiq1, "%s:", while1);
                Operacion o1 = {.op = strdup(etiq1)};
                ListaC l = creaLC();
                PosicionListaC p = inicioLC(l);
                insertaLC(l, p, o1);
                concatenaLC(l, $3);
                Operacion o2 = {.op = "beqz",.res = recuperaResLC($3), .arg1 = fin_while}; 
                p = finalLC(l);
                insertaLC(l, p, o2);
                liberaReg(recuperaResLC($3));
                concatenaLC(l, $6);
                Operacion o3 = { .op = "b", .res = strdup(while1) };
                p = finalLC(l);
                insertaLC(l, p, o3);
                char etiq2[32];
                sprintf(etiq2, "%s:", fin_while);
                Operacion o4 = {.op = strdup(etiq2)};
                p = finalLC(l);
                insertaLC(l, p, o4);
                $$ = l;
          }
          | DO statement WHILE LPAREN expression{liberaReg(recuperaResLC($5));} RPAREN SEMICOLON
          {
                ListaC l = creaLC();
                char *etiq = obtenerEtiqueta();
                char salto[32];
                sprintf(salto, "%s:", etiq);
                Operacion o1 = {.op = strdup(salto)};
                PosicionListaC p = finalLC(l);
                insertaLC(l, p, o1);
                concatenaLC(l, $2);
                concatenaLC(l, $5);
                Operacion o2 = {.op = "bnez", .res = recuperaResLC($5), .arg1 = etiq};
                p = finalLC(l);
                insertaLC(l, p, o2);
                $$ = l;
          }
          | FOR LPAREN ID ASSIGNOP expression{liberaReg(recuperaResLC($5));} SEMICOLON expression{liberaReg(recuperaResLC($8));} SEMICOLON ID ASSIGNOP expression{liberaReg(recuperaResLC($13));} RPAREN statement
          {
                PosicionLista pl1 = buscaLS(tablaSimb, $3);
                PosicionLista pl2 = buscaLS(tablaSimb, $11);
                if(pl1 == finalLS(tablaSimb))
                {
                    fprintf(stderr, "Variable %s no declarada en la línea %d\n",$3, yylineno);
                    error = 2;
                }
                else if(recuperaLS(tablaSimb, pl1).tipo == CONSTANTE)
                {
                    fprintf(stderr, "Asignación a constante en la línea %d\n", yylineno);
                    error = 2;
                }
                if(pl2 == finalLS(tablaSimb))
                {
                    fprintf(stderr, "Variable %s no declarada en la línea %d\n",$11, yylineno);
                    error = 2;
                }
                else if(recuperaLS(tablaSimb, pl2).tipo == CONSTANTE)
                {
                    fprintf(stderr, "Asignación a constante en la línea %d\n", yylineno);
                    error = 2;
                }
                ListaC l = $5;
                Operacion o1 = {.op = "sw", .res = recuperaResLC($5), .arg1 = obtenerID($3)};
                PosicionListaC p = finalLC(l);
                insertaLC(l, p, o1);
                char *for1 = obtenerEtiqueta();
                char *fin_for = obtenerEtiqueta();
                char etiq1[32];
                sprintf(etiq1, "%s:", for1);
                Operacion o2 = {.op = strdup(etiq1)};
                p = finalLC(l);
                insertaLC(l, p, o2);
                concatenaLC(l,$8);
                Operacion o3 = {.op = "beqz",.res = recuperaResLC($8), .arg1 = fin_for};
                p = finalLC(l);
                insertaLC(l, p, o3);
                concatenaLC(l,$16);
                concatenaLC(l,$13);
                Operacion o4 = {.op = "sw", .res = recuperaResLC($13), .arg1 = obtenerID($11)};
                p = finalLC(l);
                insertaLC(l, p, o4);
                Operacion o5 = { .op = "b", .res = strdup(for1)};
                p = finalLC(l);
                insertaLC(l, p, o5);
                char etiq2[32];
                sprintf(etiq2, "%s:", fin_for);
                Operacion o6 = {.op = strdup(etiq2)};
                p = finalLC(l);
                insertaLC(l, p, o6);
                $$ = l;
          }
          | PRINT LPAREN print_list RPAREN SEMICOLON
          {
                $$ = $3;
          }
          | READ LPAREN read_list RPAREN SEMICOLON
          {
                $$ = $3;
          }
          ;
liberaif : 
        {
            inicTablaReg();
        }
print_list : print_item
            {
                $$ = $1;
            }
           | print_list COMMA print_item
            {
                concatenaLC($1, $3);
                $$ = $1;
            }
           ;
print_item : expression
            {
                ListaC l = $1;
                PosicionListaC p = finalLC(l);
                Operacion o1 = {.op = "move", .res = "$a0", .arg1 = recuperaResLC($1)};
                insertaLC(l, p, o1);
                p = finalLC(l);
                Operacion o2 = {.op = "li", .res = "$v0", .arg1 = "1"};
                insertaLC(l, p, o2);
                Operacion o3 = {.op = "syscall"};
                p = finalLC(l);
                insertaLC(l, p, o3);
                $$ = l;
                liberaReg(recuperaResLC($1));
            }
           | STRING 
            {
                Simbolo s = {.nombre = $1, .tipo = CADENA, .valor = contCadenas++};
                insertaLS(tablaSimb, finalLS(tablaSimb), s);
                ListaC l = creaLC();
                PosicionListaC p = inicioLC(l);
                Operacion o1 = {.op = "la", .res = "$a0", .arg1 = obtenerCadena(contCadenas - 1)};
                insertaLC(l, p, o1);
                p = finalLC(l);
                Operacion o2 = {.op = "li", .res = "$v0", .arg1 = "4"};
                insertaLC(l, p, o2);
                Operacion o3 = {.op = "syscall"};
                p = finalLC(l);
                insertaLC(l, p, o3);
                $$ = l;
            }
           ;
read_list : ID 
            {
                PosicionLista pl = buscaLS(tablaSimb, $1);
                if(pl == finalLS(tablaSimb))
                {
                    fprintf(stderr, "Variable %s no declarada en la línea %d\n",$1,yylineno);
                    error = 2;
                }
                else if(recuperaLS(tablaSimb, pl).tipo == CONSTANTE)
                {
                    fprintf(stderr, "Asignación a constante en la línea %d\n", yylineno);
                    error = 2;
                }
                ListaC l = creaLC();
                Operacion o1 = {.op = "li", .res = "$v0", .arg1 = "5"};
                PosicionListaC pc = finalLC(l);
                insertaLC(l, pc, o1);
                Operacion o2 = {.op = "syscall"};
                pc = finalLC(l);
                insertaLC(l, pc, o2);
                Operacion o3 = {.op = "sw", .res = "$v0", .arg1 = obtenerID($1)};
                free($1);
                pc = finalLC(l);
                insertaLC(l, pc, o3);
                $$ = l;
            }
          | read_list COMMA ID 
            {
                PosicionLista pl = buscaLS(tablaSimb, $3);
                if(pl == finalLS(tablaSimb))
                {
                    fprintf(stderr, "Variable %s no declarada en la línea %d\n",$3,yylineno);
                    error = 2;
                }
                else if(recuperaLS(tablaSimb, pl).tipo == CONSTANTE)
                {
                    fprintf(stderr, "Asignación a constante en la línea %d\n", yylineno);
                    error = 2;
                }
                ListaC l = $1;
                Operacion o1 = {.op = "li", .res = "$v0", .arg1 = "5"};
                PosicionListaC pc = finalLC(l);
                insertaLC(l, pc, o1);
                Operacion o2 = {.op = "syscall"};
                pc = finalLC(l);
                insertaLC(l, pc, o2);
                Operacion o3 = {.op = "sw", .res = "$v0", .arg1 = obtenerID($3)};
                free($3);
                pc = finalLC(l);
                insertaLC(l, pc, o3);
                $$ = l;
            }
          ;
expression : expression NOTEQOP expression
            {
                char *reg = obtenerRegistro();
                Operacion o = {.op = "sne", .res = reg, .arg1 = recuperaResLC($1), .arg2 = recuperaResLC($3)};
                concatenaLC($1, $3);
                ListaC l = $1;
                PosicionListaC p = finalLC(l);
                insertaLC(l, p, o);
                guardaResLC(l, o.res);
                $$ = l;
                liberaReg(o.arg1);
                liberaReg(o.arg2);
            }
            | expression EQOP expression
            {
                char *reg = obtenerRegistro();
                Operacion o = {.op = "seq", .res = reg, .arg1 = recuperaResLC($1), .arg2 = recuperaResLC($3)};
                concatenaLC($1, $3);
                ListaC l = $1;
                PosicionListaC p = finalLC(l);
                insertaLC(l, p, o);
                guardaResLC(l, o.res);
                $$ = l;
                liberaReg(o.arg1);
                liberaReg(o.arg2);
            }
            | expression GREATEREQOP expression
            {
                char *reg = obtenerRegistro();
                Operacion o = {.op = "sge", .res = reg, .arg1 = recuperaResLC($1), .arg2 = recuperaResLC($3)};
                concatenaLC($1, $3);
                ListaC l = $1;
                PosicionListaC p = finalLC(l);
                insertaLC(l, p, o);
                guardaResLC(l, o.res);
                $$ = l;
                liberaReg(o.arg1);
                liberaReg(o.arg2);
            }
            | expression LESSEQOP expression
            {
                char *reg = obtenerRegistro();
                Operacion o = {.op = "sle", .res = reg, .arg1 = recuperaResLC($1), .arg2 = recuperaResLC($3)};
                concatenaLC($1, $3);
                ListaC l = $1;
                PosicionListaC p = finalLC(l);
                insertaLC(l, p, o);
                guardaResLC(l, o.res);
                $$ = l;
                liberaReg(o.arg1);
                liberaReg(o.arg2);
            }
            | expression GREATEROP expression
            {
                char *reg = obtenerRegistro();
                Operacion o = {.op = "sgt", .res = reg, .arg1 = recuperaResLC($1), .arg2 = recuperaResLC($3)};
                concatenaLC($1, $3);
                ListaC l = $1;
                PosicionListaC p = finalLC(l);
                insertaLC(l, p, o);
                guardaResLC(l, o.res);
                $$ = l;
                liberaReg(o.arg1);
                liberaReg(o.arg2);
            }
            | expression LESSOP expression
            {
                char *reg = obtenerRegistro();
                Operacion o = {.op = "slt", .res = reg, .arg1 = recuperaResLC($1), .arg2 = recuperaResLC($3)};
                concatenaLC($1, $3);
                ListaC l = $1;
                PosicionListaC p = finalLC(l);
                insertaLC(l, p, o);
                guardaResLC(l, o.res);
                $$ = l;
                liberaReg(o.arg1);
                liberaReg(o.arg2);
            }
            | expression PLUSOP expression
            {
                char *regsum = obtenerRegistro();
                Operacion o = {.op = "add", .res = regsum, .arg1 = recuperaResLC($1), .arg2 = recuperaResLC($3)};
                concatenaLC($1, $3);
                ListaC l = $1;
                PosicionListaC p = finalLC(l);
                insertaLC(l, p, o);
                guardaResLC(l, o.res);
                $$ = l;
                liberaReg(o.arg1);
                liberaReg(o.arg2);
           }
           | expression MINUSOP expression
           {
                char *regsub = obtenerRegistro();
                Operacion o = {.op = "sub", .res = regsub, .arg1 = recuperaResLC($1), .arg2 = recuperaResLC($3)};
                concatenaLC($1, $3);
                ListaC l = $1;
                PosicionListaC p = finalLC(l);
                insertaLC(l, p, o);
                guardaResLC(l, o.res);
                $$ = l;
                liberaReg(o.arg1);
                liberaReg(o.arg2);
           }
           | expression MULTOP expression
           {
                char *regmult = obtenerRegistro();
                Operacion o = {.op = "mul", .res = regmult, .arg1 = recuperaResLC($1), .arg2 = recuperaResLC($3)};
                concatenaLC($1, $3);
                ListaC l = $1;
                PosicionListaC p = finalLC(l);
                insertaLC(l, p, o);
                guardaResLC(l, o.res);
                $$ = l;
                liberaReg(o.arg1);
                liberaReg(o.arg2);
           }
           | expression DIVOP expression
           {
                char *regdiv = obtenerRegistro();
                Operacion o = {.op = "div", .res = regdiv, .arg1 = recuperaResLC($1), .arg2 = recuperaResLC($3)};
                concatenaLC($1, $3);
                ListaC l = $1;
                PosicionListaC p = finalLC(l);
                insertaLC(l, p, o);
                guardaResLC(l, o.res);
                $$ = l;
                liberaReg(o.arg1);
                liberaReg(o.arg2);

           }
           | LPAREN expression Q expression COLON expression RPAREN
           {
                char *etiq1 = obtenerEtiqueta();
                Operacion o = {.op = "beqz", .res = recuperaResLC($2), .arg1 = etiq1};
                ListaC l = $2;
                PosicionListaC p = finalLC(l);
                insertaLC(l, p, o);
                concatenaLC($2, $4);
                Operacion o1 = {.op = "move", .res = recuperaResLC($2), .arg1 = recuperaResLC($4)};
                p = finalLC(l);
                insertaLC(l, p, o1);
                char *etiq2 = obtenerEtiqueta();
                Operacion o2 = {.op = "b", .res = etiq2};
                p = finalLC(l);
                insertaLC(l, p, o2);
                char salto1[32];
                sprintf(salto1,"%s:",etiq1);
                Operacion o3 = {.op = strdup(salto1)};
                p = finalLC(l);
                insertaLC(l, p, o3);
                concatenaLC($2, $6);
                Operacion o4 = {.op = "move", .res = recuperaResLC($2), .arg1 = recuperaResLC($6)};
                p = finalLC(l);
                insertaLC(l, p, o4);
                char salto2[32];
                sprintf(salto2,"%s:",etiq2);
                Operacion o5 = {.op = strdup(salto2)};
                p = finalLC(l);
                insertaLC(l, p, o5);
                $$ = l;
                liberaReg(recuperaResLC($4));
                liberaReg(recuperaResLC($6));
           }
           | MINUSOP expression %prec UMENOS
           {
                ListaC l = $2;
                PosicionListaC p = finalLC(l);
                Operacion o = {.op = "neg", .res = recuperaResLC(l), .arg1 = recuperaResLC(l)};
                insertaLC(l, p, o);
                $$ = l;
           }
           | LPAREN expression RPAREN 
           {
                $$ = $2;
           }
           | ID 
           {
                  if (buscaLS(tablaSimb, $1) == finalLS(tablaSimb))
                  {
                    fprintf(stderr, "Variable %s no declarada en la línea %d\n", $1, yylineno);
                    error = 2;
                  } 
                  ListaC l = creaLC();
                  PosicionListaC p = inicioLC(l);
                  char *regid = obtenerRegistro();
                  Operacion o = {.op = "lw", .arg1 = obtenerID($1), .res = regid};
                  free($1);
                  insertaLC(l, p , o);
                  guardaResLC(l, regid);
                  $$ = l;
           }
           | NUM 
           {
                  ListaC l = creaLC();
                  PosicionListaC p = inicioLC(l);
                  char *reg = obtenerRegistro();
                  Operacion o = {.op = "li", .arg1 = $1, .res =  reg};
                  insertaLC(l, p , o);
                  guardaResLC(l, reg);
                  $$ = l;
           }
           ;
%%

void yyerror(const char *s) {
    fprintf(stderr, "Error sintáctico en el token %s, línea %d: %s\n", yytext, yylineno, s);
    error = 3;
}

void inicTablaReg()
{
    for(int i = 0; i < 10; i++)
    {
        tablaReg[i] = 0;
    }
}

int posTablaReg()
{
    int i = 0;
    while(i < 10 && tablaReg[i] == 1)
    {
        i++;
    }
    if(i != 10)
    {
        tablaReg[i] = 1;
    }
    else
    {
        fprintf(stderr, "Error en la traducción, no quedan registros disponibles.");
        error = 3;
    }
    return i;
}

char *obtenerEtiqueta()
{
    char aux[32];
    sprintf(aux, "$l%d", contEtiquetas++);
    return strdup(aux);
}
char *obtenerRegistro()
{
    char aux[32];
    sprintf(aux, "$t%d", posTablaReg());
    return strdup(aux);
}
char *obtenerCadena(int n)
{
    char aux[32];
    sprintf(aux,"$str%d", n);
    return strdup(aux);
}
char *obtenerID(char* id)
{
    char aux[32];
    sprintf(aux,"_%s", id);
    return strdup(aux);
}
void liberaReg(char *reg)
{
    tablaReg[atoi(reg+2)] = 0;
}