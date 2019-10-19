/* Miguel Rojas - Jesus Salas
   CS 152 - Fall 2019
   Phase 1 */

%{
// Definitions
int line = 1, position = 1;
%}

%%

"function" {printf("FUNCTION\n"); position += yyleng;}
"beginparams" {printf("BEGIN_PARAMS\n"); position += yyleng;}
"endparams" {printf("END_PARAMS\n"); position += yyleng;}
"integer" {printf("INTEGER\n"); position += yyleng;}
"array" {printf("ARRAY\n"); position += yyleng;}
"beginlocals" {printf("BEGIN_LOCALS\n"); position += yyleng;}
"endlocals" {printf("END_LOCALS\n"); position += yyleng;}
"beginbody" {printf("BEGIN_BODY\n"); position += yyleng;}
"endbody" {printf("END_BODY\n"); position += yyleng;}
"if" {printf("IF\n"); position += yyleng;}
"of" {printf("OF\n"); position += yyleng;}
"else" {printf("ELSE\n"); position += yyleng;}
"while" {printf("WHILE\n"); position += yyleng;}
"do" {printf("DO\n"); position += yyleng;}
"beginloop" {printf("BEGINLOOP\n"); position += yyleng;}
"endloop" {printf("ENDLOOP\n"); position += yyleng;}
"then" {printf("THEN\n"); position += yyleng;}
"return" {printf("RETURN\n"); position += yyleng;}
"endif" {printf("ENDIF\n"); position += yyleng;}
"continue" {printf("CONTINUE\n"); position += yyleng;}
"and" {printf("AND\n"); position += yyleng;}
"or" {printf("OR\n"); position += yyleng;}
"not" {printf("NOT\n"); position += yyleng;}
"true" {printf("TRUE\n"); position += yyleng;}
"false" {printf("FALSE\n"); position += yyleng;}
"read" {printf("READ\n"); position += yyleng;}
"write" {printf("WRITE\n"); position += yyleng;}

[a-z]*"_"?[a-z]+([0-9]*)? {printf("IDENT %s\n", yytext); position += yyleng;}

([0-9]+[a-zA-Z_][0-9a-zA-Z_]*)|("_"[0-9a-zA-Z_]+) {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n",line, --position, yytext); exit(1);}

[a-zA-Z]([0-9a-zA-Z_]*[0-9a-zA-Z]+)?"_" {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n",line, --position, yytext); exit(1);}

":=" {printf("ASSIGN\n"); position += yyleng;}
";" {printf("SEMICOLON\n"); position += yyleng;}
":" {printf("COLON\n"); position += yyleng;}
"," {printf("COMMA\n"); position += yyleng;}
"-" {printf("SUB\n"); position += yyleng;}
"+" {printf("ADD\n"); position += yyleng;}
"*" {printf("MULT\n"); position += yyleng;}
"/" {printf("DIV\n"); position += yyleng;}
"%" {printf("MOD\n"); position += yyleng;}
"==" {printf("EQ\n"); position += yyleng;}
"[" {printf("L_SQUARE_BRACKET\n"); position += yyleng;}
"]" {printf("R_SQUARE_BRACKET\n"); position += yyleng;}
"(" {printf("L_PAREN\n"); position += yyleng;}
")" {printf("R_PAREN\n"); position += yyleng;}
"<>" {printf("NEQ\n"); position += yyleng;}
"<" {printf("LT\n"); position += yyleng;}
">" {printf("GT\n"); position += yyleng;}
"<=" {printf("LTE\n"); position += yyleng;}
">=" {printf("GTE\n"); position += yyleng;}
"##".* {line++; position = 1;}

[0-9]+"."?[0-9]*[eE][+-]?[0-9]+ {printf("SCIENTIFIC NUMBER %s\n", yytext); position += yyleng;}
[0-9]*"."?[0-9]+ {printf("NUMBER %s\n", yytext); position += yyleng;}

[ \t]+ {position += yyleng;}

. {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", line, --position, yytext); exit(0);}

"\n" {line++; position = 1;}

%%

int yywrap(){}
int main(int argc, char ** argv)
{
yylex();
return 0;
}                                                          

