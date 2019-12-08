%{
#include "heading.h"
#include <vector>
#include <map>
#include <stack>
#include <list>
#include <iterator>


string newTemp();
string newLabel();
vector <string> functionTable;
vector <string> paramTable;
vector <string> symbolTable;
vector <string> ops;
vector <string> statements;
vector <string> symbolType;


void yyerror(const char* msg);

extern int yylex(void);
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
{}
		 | functions input
		 {}
;

function:	 FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY
                 { 
 
		 }
		 | FUNCTION ident L_PAREN expression R_PAREN statements
		 {}
	         | FUNCTION ident L_PAREN expression R_PAREN SEMICOLON
                 {} 
;

functions:	 %empty
{}
		 | function functions
		 {}
;

declaration:     identifiers COLON INTEGER
{}
		 | identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
		 {}
;

declarations:    %empty
{}
                 | declaration SEMICOLON declarations
		 {}
;

ident:		 IDENT
{}
;

identifiers:     ident
{}
                 | ident COMMA identifiers
		 {}
;

statements:      %empty
{}
		 | statement SEMICOLON statements
		 {}
;

statement:      var ASSIGN expression
{}
                 | IF L_PAREN bool_exp R_PAREN THEN statements ENDIF
		 {}
		 | IF bool_exp THEN statements ELSE statements ENDIF
		 {}
                 | IF bool_exp AND bool_exp THEN statements ENDIF
		 {}
                 | IF bool_exp AND bool_exp THEN statements ELSE statements ENDIF
		 {}
                 | WHILE bool_exp BEGINLOOP statements ENDLOOP
		 {}
                 | DO BEGINLOOP statements ENDLOOP WHILE bool_exp
		 {}
                 | READ vars
		 {}
                 | WRITE vars
		 {}
                 | CONTINUE
		 {}
		 | RETURN term
		 {} 
;

var:             ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET
{}
                 | ident
		 {}
;

vars:            var
{}
                 | var COMMA vars
		 {}
;

expression:      multiplicative_expression
{}
                 | multiplicative_expression ADD expression
		 {}
                 | multiplicative_expression SUB expression
		 {}
;

multiplicative_expression:         term
{}
                 | term MULT term
		 {}
                 | term DIV term
		 {}
                 | term MOD term
		 {}
;

term:            var
{}
                 | NUMBER
		 {}
                 | L_PAREN expression R_PAREN
		 {}
                 | SUB L_PAREN expression R_PAREN
		 {}
;

bool_exp:        relation_and_exp 
{}
                 | relation_and_exp OR bool_exp
                 {}
;

relation_and_exp:           relation_exp
{}
                 | relation_exp AND relation_exp
                 {}
;

relation_exp:    expression comp expression
{}
                 | TRUE
		 {}
                 | FALSE
		 {}
;

comp:            EQ
{printf("==");}
                 | NEQ
                 {printf("!=");}
                 | LT
                 {printf(">");}
                 | GT
                 {printf("<");}
                 | LTE
                 {printf(">=");}
                 | GTE
                 {printf("<=");}
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
