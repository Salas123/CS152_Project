/* Miguel Rojas - Jesus Salas
   CS 152 - Fall 2019
   Phase 3 */

%{
// Definitions
#include "phase3.tab.h"
#include <string>

int line = 1, position = 1;
char * programTitle;
%}

%%

"function" {return FUNCTION; position += yyleng;}
"beginparams" {return BEGIN_PARAMS; position += yyleng;}
"endparams" {return END_PARAMS; position += yyleng;}
"integer" {return INTEGER; position += yyleng;}
"array" {return ARRAY; position += yyleng;}
"beginlocals" {return BEGIN_LOCALS; position += yyleng;}
"endlocals" {return END_LOCALS; position += yyleng;}
"beginbody" {return BEGIN_BODY; position += yyleng;}
"endbody" {return END_BODY; position += yyleng;}
"if" {return IF; position += yyleng;}
"of" {return OF; position += yyleng;}
"else" {return ELSE; position += yyleng;}
"while" {return WHILE; position += yyleng;}
"do" {return DO; position += yyleng;}
"beginloop" {return BEGINLOOP; position += yyleng;}
"endloop" {return ENDLOOP; position += yyleng;}
"then" {return THEN; position += yyleng;}
"return" {return RETURN; position += yyleng;}
"endif" {return ENDIF; position += yyleng;}
"continue" {return CONTINUE; position += yyleng;}
"and" {return AND; position += yyleng;}
"or" {return OR; position += yyleng;}
"not" {return NOT; position += yyleng;}
"true" {return TRUE; position += yyleng;}
"false" {return FALSE; position += yyleng;}
"read" {return READ; position += yyleng;}
"write" {return WRITE; position += yyleng;}

[a-zA-Z]([0-9a-zA-Z_]*[0-9a-zA-Z]+)? {yylval.id_val = yytext; return IDENT; position += yyleng;}

([0-9]+[a-zA-Z_][0-9a-zA-Z_]*)|("_"[0-9a-zA-Z_]+) {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n",line, position, yytext); exit(1);}

[a-zA-Z]([0-9a-zA-Z_]*[0-9a-zA-Z]+)?"_" {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n",line, position, yytext); exit(1);}

":=" {return ASSIGN; position += yyleng;}
";" {return SEMICOLON; position += yyleng;}
":" {return COLON; position += yyleng;}
"," {return COMMA; position += yyleng;}
"-" {return SUB; position += yyleng;}
"+" {return ADD; position += yyleng;}
"*" {return MULT; position += yyleng;}
"/" {return DIV; position += yyleng;}
"%" {return MOD; position += yyleng;}
"==" {return EQ; position += yyleng;}
"[" {return L_SQUARE_BRACKET; position += yyleng;}
"]" {return R_SQUARE_BRACKET; position += yyleng;}
"(" {return L_PAREN; position += yyleng;}
")" {return R_PAREN; position += yyleng;}
"<>" {return NEQ; position += yyleng;}
"<" {return LT; position += yyleng;}
">" {return GT; position += yyleng;}
"<=" {return LTE; position += yyleng;}
">=" {return GTE; position += yyleng;}
"##".* {line++; position = 1;}

[0-9]+"."?[0-9]*[eE][+-]?[0-9]+ {printf("SCIENTIFIC NUMBER %s\n", yytext); position += yyleng;}
[0-9]*"."?[0-9]+ {yylval.int_val = atoi(yytext); return NUMBER; position += yyleng;}

[ \t]+ {position += yyleng;}

. {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", line, position, yytext); exit(0);}

"\n" {line++; position = 1;}

%%                                                     
int yyparse();
int yylex();

int main(int argc, char* argv[]) {
  if (argc == 2) {
    yyin = fopen(argv[1], "r");
    if (yyin == 0) {
      printf("Error opening file: %s\n", argv[1]);
      exit(1);
    }
  }
  else {
    yyin = stdin;
  }
  programTitle = strdup(argv[1]);
  
  yyparse();
  
  return 0;
}
