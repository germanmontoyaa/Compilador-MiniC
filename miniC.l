%{
#include "miniC.tab.h"
#define INT_MAX 2147483648
#define LEN_MAX 32
void error_lexico();
int comprueba_rango();
int comprueba_cadena();
int string;
void debug();
int error = 0;
%}
digito              [0-9]
letra               [a-zA-Z]
entero              {digito}+
car_invalido	    [^a-zA-Z0-9_\*{}()=;,\+\-\/\?\:\n\"><!]
%x COMENT
%option yylineno
%%
\/\/(.*)$							;
[ \n\t\r]+							;
"/*" 								BEGIN COMENT;
<COMENT>[^*]* 						;
<COMENT>[*]+[/]						BEGIN 0;
<COMENT>[*]+[^/*]*					;
"{"									return LCORCHET;
"}"									return RCORCHET;
print								return PRINT;
int									return INT;
read								return READ;
var									return VAR;
const								return CONST;
if									return IFOP;
else								return ELSEOP;
while								return WHILE;
do                                  return DO;
for									return FOR;
\"([^\"\\\n\r]|\\.)*\"				    { yylval.lexema=strdup(yytext);return STRING;};
({letra}|_)({letra}|{digito}|_)*    return comprueba_cadena();
{entero}                            return comprueba_rango();
"("                                 return LPAREN;		
")"                                 return RPAREN;
";"                                 return SEMICOLON;
","                                 return COMMA;
"="                                	return ASSIGNOP;
"+"                                 return PLUSOP;
"-"                                 return MINUSOP;
"*"                                 return MULTOP;
"/"                                 return DIVOP;
"?"                                 return Q;
":"				    				return COLON;
"<"				    				return LESSOP;
">"				    				return GREATEROP;
"<="								return LESSEQOP;
"=<"								return LESSEQOP;
">="								return GREATEREQOP;
"=>"								return GREATEREQOP;
"!="								return NOTEQOP;
"=="								return EQOP;

({car_invalido})*  		    		error_lexico();
%%

void error_lexico()
{
  printf("ERROR LEXICO: símbolo no reconocido en la línea %d: %s\n", yylineno,yytext);
  error = 1;
}

int comprueba_rango()
{
	if(atoll(yytext) < INT_MAX)
	{
		yylval.lexema=strdup(yytext);
		return NUM;
	}
	else
	{
		printf("ERROR LEXICO: Entero fuera de rango en la línea %d: %s\n", yylineno,yytext);
		error = 1;
		yylval.lexema=strdup(yytext);
		return NUM;
	}
}

int comprueba_cadena()
{
	if(yyleng <= LEN_MAX)
	{
		yylval.lexema=strdup(yytext);
		return ID;
	}
	else
	{
		printf("ERROR LEXICO: El identificador excede los %d carácteres en la línea %d: %s\n",LEN_MAX, yylineno,yytext);
		error = 1;
		yylval.lexema=strdup(yytext);
		return ID;
	}
}

void debug() {
    int i;
    while (i=yylex())
        printf("%d %s\n",i,yytext);
    printf("FIN DE ANALISIS LEXICO\n");
}