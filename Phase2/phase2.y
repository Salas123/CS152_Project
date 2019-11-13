%{
#include <stdio.h>
#include <stdlib.h>
void yyerror(const char* msg);
extern int line;
extern int position;
FILE * yyin;
%}

%union{
  char* id_val;
  int int_val;
 }

%error-verbose
%start input
%token <id_val> IDENT
%token <int_val> NUMBER
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOREACH IN BEGINLOOP ENDLOOP CONTINUE READ WRITE
%left AND
%left OR
%right NOT
%token TRUE FALSE RETURN
%left SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE
%token L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET COLON SEMICOLON COMMA
%left ASSIGN


%%

input:           %empty
{printf("");}
		 | functions input
		 {printf("prog_start -> functions\n");}
;

function:	 FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY
{printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
;

functions:	 %empty
{printf("functions -> epsilon\n");}
		 | function functions
		 {printf("functions -> function functions\n");}
;

declaration:     identifiers COLON INTEGER
{printf("declaration -> identifiers COLON INTEGER\n");}
		 | identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
		 {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");}
;

declarations:    %empty
{printf("declarations -> epsilon\n");}
                 | declaration SEMICOLON declarations
		 {printf("declarations -> declaration SEMICOLON declarations\n");}
;

ident:		 IDENT
{printf("ident -> IDENT %s\n", $1);}
;

identifiers:     ident
{printf("identifiers -> ident\n");}
                 | ident COMMA identifiers
		 {printf("identifiers -> ident COMMA identifiers\n");}
;

statements:      %empty
{printf("statements -> epsilon\n");}
		 | statement SEMICOLON statements
		 {printf("statements -> statement SEMICOLON statements\n");}
;

statement:      var ASSIGN expression
{printf("statement -> var ASSIGN expression\n");}
                 | IF L_PAREN bool_exp R_PAREN THEN statements ENDIF
		 {printf("statement -> IF bool_exp THEN statements ENDIF\n");}
		 | IF bool_exp THEN statements ELSE statements ENDIF
		 {printf("statement -> IF bool_exp THEN statements ELSE statements ENDIF\n");}
                 | IF bool_exp AND bool_exp THEN statements ENDIF
		 {printf("statement -> IF bool_exp THEN statements ENDIF\n");}
                 | IF bool_exp AND bool_exp THEN statements ELSE statements ENDIF
		 {printf("statement -> IF bool_exp THEN statements ELSE statements ENDIF\n");}
                 | WHILE bool_exp BEGINLOOP statements ENDLOOP
		 {printf("statement -> WHILE bool_exp BEGINLOOP statements ENDLOOP\n");}
                 | DO BEGINLOOP statements ENDLOOP WHILE bool_exp
		 {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp\n");}
                 | READ vars
		 {printf("statement -> READ vars\n");}
                 | WRITE vars
		 {printf("statement -> WRITE vars\n");}
                 | CONTINUE
		 {printf("statement -> CONTINUE\n");}
		 | RETURN expression
		 {printf("statement -> RETURN expression\n");}
;

var:             ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET
{printf("var -> ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}
                 | ident
		 {printf("var -> ident\n");}
;

vars:            var
{printf("vars -> var\n");}
                 | var COMMA vars
		 {printf("vars -> var COMMA vars\n");}
;

expression:      multiplicative_expression
{printf("expression -> multiplicative_expression\n");}
                 | multiplicative_expression ADD expression
		 {printf("expression -> multiplicative_expression ADD multiplicative_expression\n");}
                 | multiplicative_expression SUB expression
		 {printf("expression -> multiplicative_expression SUB multiplicative_expression\n");}
;

multiplicative_expression:         term
{printf("multiplicative_expression -> term\n");}
                 | term MULT term
		 {printf("multiplicative_expression -> term MULT term\n");}
                 | term DIV term
		 {printf("multiplicative_expression -> term DIV term\n");}
                 | term MOD term
		 {printf("multiplicative_expression -> term MOD term\n");}
;

term:            var
{printf("term -> var\n");}
                 | NUMBER
		 {printf("term -> NUMBER\n");}
                 | L_PAREN expression R_PAREN
		 {printf("term -> L_PAREN expression R_PAREN\n");}			
                 | SUB L_PAREN expression R_PAREN
		 {printf("term -> SUB L_PAREN expression R_PAREN\n");}
		 | ident L_PAREN expression R_PAREN
		 {printf("term -> ident L_PAREN expression R_PAREN\n");}
;

bool_exp:         relation_and_exp 
{printf("bool_exp -> relation_and_exp\n");}
                 | relation_and_exp OR bool_exp
                 {printf("bool_exp -> relation_and_exp OR relation_and_exp\n");}
;

relation_and_exp:           relation_exp
{printf("relation_and_exp -> relation_exp\n");}
                 | relation_exp AND relation_exp
                 {printf("relation_and_exp -> relation_exp AND relation_exp\n");}
;

relation_exp:    expression comp expression
{printf("relation_exp -> expression comp expression\n");}
                 | TRUE
		 {printf("relation_exp -> TRUE\n");}
                 | FALSE
		 {printf("relation_exp -> FALSE\n");}
;

comp:            EQ
{printf("comp -> EQ\n");}
                 | NEQ
                 {printf("comp -> NEQ\n");}
                 | LT
                 {printf("comp -> LT\n");}
                 | GT
                 {printf("comp -> GT\n");}
                 | LTE
                 {printf("comp -> LTE\n");}
                 | GTE
                 {printf("comp -> GTE\n");}
;
%%

int main(int argc, char **argv) {
	if (argc > 1) {
		yyin = fopen(argv[1], "r");
		if (yyin == NULL){
			printf("syntax: %s filename\n", argv[0]);
		}
	}
	yyparse();
	return 0;
}
		 
void yyerror(const char* msg) {
  printf("** Line %d, position %d: %s\n", line, position, msg);
}
