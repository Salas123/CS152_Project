%{
#define YY_NO_UNPUt
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <map>
#include <vector>

void yyerror(const char* msg);
extern int line;
extern int position;
char * programTitle;
extern char * programName;
std::string newtemp();
std::string newlabel();
int yylex();
FILE * yyin;

char empty[1]="";

std::map<std::string, int> variables;
 std::map<std::string, int> functions;
  std::vector<std::string> reservedWords = {"FUNCTION", "BEGIN_PARAMS", "END_PARAMS", "BEGIN_LOCALS", "END_LOCALS", "BEGIN_BODY", "END_BODY", "INTEGER",
    "ARRAY", "OF", "IF", "THEN", "ENDIF", "ELSE", "WHILE", "DO", "FOREACH", "IN", "BEGINLOOP", "ENDLOOP", "CONTINUE", "READ", "WRITE", "AND", "OR", 
    "NOT", "TRUE", "FALSE", "RETURN", "SUB", "ADD", "MULT", "DIV", "MOD", "EQ", "NEQ", "LT", "GT", "LTE", "GTE", "L_PAREN", "R_PAREN", "L_SQUARE_BRACKET",
    "R_SQUARE_BRACKET", "COLON", "SEMICOLON", "COMMA", "ASSIGN", "function", "Ident", "beginparams", "endparams", "beginlocals", "endlocals", "integer", 
    "beginbody", "endbody", "beginloop", "endloop", "if", "endif", "foreach", "continue", "while", "else", "read", "do", "write"};
%}

%union{
  char* id_val;
  int int_val;

// expression attributes
  struct E {
	char* place;
	char* code;
	bool array;
  } expr;

// statement attributes
  struct S {
	char* code;
  } stat;
}

%error-verbose
%start input
%token <id_val> IDENT
%token <int_val> NUMBER
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOREACH IN BEGINLOOP ENDLOOP CONTINUE READ WRITE
%type <expr> identifiers local function
%type <expr> declarations declaration
%type <stat> statements statement
%type <expr> expression multiplicative_expression term bool_exp relation_and_exp relation_exp comp

%left AND OR
%right NOT
%token TRUE FALSE RETURN
%left SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE ASSIGN
%token L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET COLON SEMICOLON COMMA


%%

input:           %empty
{printf("");}
		 | functions input
		 {printf("prog_start -> functions\n");}
;

function:	 FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY
{printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
		 | FUNCTION ident L_PAREN expression R_PAREN statements
		 {printf("function -> FUNCTION ident L_PAREN expression R_Parent statements");}
	         | FUNCTION ident L_PAREN expression R_PAREN SEMICOLON
                 {printf("fucntion->FUNCTION ident L_PAREN expression R_PAREN");} 
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
{$$.place = strdup($1); $$.code = strdup(empty);}
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
		 | RETURN term
		 {printf("statement -> RETURN term\n");} 
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

expression2:     %empty
{
  $$.code = strdup(empty);
  $$.place = strdup(empty);
}
		| expression COMMA expression2
		{
  	          std::string tempStr;
  		  tempStr.append($1.code);
  		  tempStr.append("param ");
  		  tempStr.append($1.place);
  		  tempStr.append("\n");
  		  tempStr.append($3.code);

  		  $$.code = strdup(tempStr.c_str());
  		  $$.place = strdup(empty);
		}
		| expression
		{
  		  std::string tempStr;
  		  tempStr.append($1.code);
  		  tempStr.append("param ");
  		  tempStr.append($1.place);
  		  tempStr.append("\n");

  		  $$.code = strdup(tempStr.c_str());
  		  $$.place = strdup(empty);
		}
;

multiplicative_expression:         term
{
  $$.code = strdup($1.code);
  $$.place = strdup($1.place);
}
                 | term MULT multiplicative_expression
		 {
		    $$.place = strdup(newTemp().c_str());
  
  		   std::string tempStr;
  		   tempStr.append(". ");
  		   tempStr.append($$.place);
  		   tempStr.append("\n");
  		   tempStr.append($1.code);
  		   tempStr.append($3.code);
  		   tempStr.append("* ");
  		   tempStr.append($$.place);
  		   tempStr.append(", ");
  		   tempStr.append($1.place);
  		   tempStr.append(", ");
  		   tempStr.append($3.place);
  		   tempStr.append("\n");

  		   $$.code = strdup(tempStr.c_str());
		 }
                 | term DIV multiplicative_expression
		 { 
		   $$.place = strdup(newTemp().c_str());

                   std::string tempStr;
                   tempStr.append(". ");
                   tempStr.append($$.place);
                   tempStr.append("\n");
                   tempStr.append($1.code);
                   tempStr.append($3.code);
                   tempStr.append("/ ");
                   tempStr.append($$.place);
                   tempStr.append(", ");
                   tempStr.append($1.place);
                   tempStr.append(", ");
                   tempStr.append($3.place);
                   tempStr.append("\n");

                   $$.code = strdup(tempStr.c_str());	
		 }
                 | term MOD multiplicative_expression
		 {
		   $$.place = strdup(newTemp().c_str());

                   std::string tempStr;
                   tempStr.append(". ");
                   tempStr.append($$.place);
                   tempStr.append("\n");
                   tempStr.append($1.code);
                   tempStr.append($3.code);
                   tempStr.append("% ");
                   tempStr.append($$.place);
                   tempStr.append(", ");
                   tempStr.append($1.place);
                   tempStr.append(", ");
                   tempStr.append($3.place);
                   tempStr.append("\n");

                   $$.code = strdup(tempStr.c_str());
		 }
;

term:            var
{
 
  if ($$.array == true) 
  {
    std::string tempStr;
    std::string tempStr2 = newTemp();
    
    
    tempStr.append($1.code);
    tempStr.append(". ");
    tempStr.append(tempStr2);
    tempStr.append("\n");
    tempStr.append("=[] ");
    tempStr.append(tempStr2);
    tempStr.append(", ");
    tempStr.append($1.place);
    tempStr.append("\n");
    
    $$.code = strdup(tempStr.c_str());
    $$.place = strdup(tempStr2.c_str());
    $$.array = false;
  }
  
  else 
  {
    $$.code = strdup($1.code);
    $$.place = strdup($1.place);
  }
}
                 | NUMBER
		 {
  		   $$.code = strdup(empty);
  		   $$.place = strdup(std::to_string($1).c_str());
		 }
                 | L_PAREN expression R_PAREN
		 {
		   $$.code = strdup($2.code);
  		   $$.place = strdup($2.place);
		 }
                 | SUB L_PAREN expression R_PAREN
		 {
		   $$.place = strdup($3.place);
  		   std::string tempStr;
  		   tempStr.append($3.code);
  		   tempStr.append("* ");
  		   tempStr.append($3.place);
  		   tempStr.append(", ");
  		   tempStr.append($3.place);
  		   tempStr.append(", -1\n");
  		   $$.code = strdup(tempStr.c_str());
		 }
		 | SUB NUMBER
		 {
		   std::string tempStr;
  		   tempStr.append("-");
  		   tempStr.append(std::to_string($2));
  		   $$.code = strdup(empty);
  		   $$.place = strdup(tempStr.c_str());
		 }
		 | SUB var
		 {
		 	$$.place = strdup(newTemp().c_str());
  			std::string tempStr;
  			tempStr.append($2.code);
  			tempStr.append(". ");
  			tempStr.append($$.place);
  			tempStr.append("\n");
  			if ($2.array) {
    				tempStr.append("=[] ");
    				tempStr.append($$.place);
    				tempStr.append(", ");
    				tempStr.append($2.place);
    				tempStr.append("\n");
  			}
  			else {
    			tempStr.append("= ");
    			tempStr.append($$.place);
    			tempStr.append(", ");
    			tempStr.append($2.place);
    			tempStr.append("\n");
  			}
  
			tempStr.append("* ");
  			tempStr.append($$.place);
  			tempStr.append(", ");
  			tempStr.append($$.place);
  			tempStr.append(", -1\n");
  
  			$$.code = strdup(temp.c_str());
  			$$.array = false;
		 }
;

bool_exp:        relation_and_exp 
{ 
  $$.place = strdup($1.place);
  $$.code = strdup($1.code);
}
                 | relation_and_exp OR bool_exp
                 {
		   std::string destination = newTemp();
  		   std::string tempStr;

  		   tempStr.append($1.code);
  		   tempStr.append($3.code);
  		   tempStr.append(". ");
  		   tempStr.append(destination);
  		   tempStr.append("\n");
  
  		   tempStr.append("|| ");
  		   tempStr.append(destination);
  		   tempStr.append(", ");
  		   tempStr.append($1.place);
  		   tempStr.append(", ");
  		   tempStr.append($3.place);
  		   tempStr.append("\n");
  
  		   $$.code = strdup(tempStr.c_str());
  		   $$.place = strdup(destination.c_str());
		 }
;

relation_and_exp:           relation_exp
{ 
  $$.place = strdup($1.place);
  $$.code = strdup($1.code);
}
                 | relation_exp AND relation_and_exp
                 {
		   std::string destination = newTemp();
  		   std::string tempStr;
		   // appending a relation_exp, relation_and_exp
  		   tempStr.append($1.code);
  		   tempStr.append($3.code);
  		   tempStr.append(". ");
  		   tempStr.append(destination);
  		   tempStr.append("\n");
  		   // && relation_and_exp	
  		   tempStr.append("&& ");
  		   tempStr.append(destination);
  		   tempStr.append(", ");
  		   tempStr.append($1.place); // appending relation_exp place
  		   tempStr.append(", ");
  		   tempStr.append($3.place);
  		   tempStr.append("\n");
  
     		   $$.code = strdup(temp.c_str());
  		   $$.place = strdup(dest.c_str());	
		 }
;

relation_exp: 	  relation_exp2
{
  $$.place = strdup($1.place);
  $$.code = strdup($1.code);
}

		  | NOT relation_exp2
		    {
			std::string destination = newTemp();
  			std::string tempStr;

  			tempStr.append($2.code);
  			tempStr.append(". ");
  			tempStr.append(destination);
  			tempStr.append("\n");
  
  			tempStr.append("! ");
  			tempStr.append(destination);
  			tempStr.append(", ");
  			tempStr.append($2.place);
  			tempStr.append("\n");
  
  			$$.code = strdup(tempStr.c_str());
  			$$.place = strdup(destination.c_str());	
		    }

relation_exp2:    expression comp expression
{ std::string destination = newTemp();
  std::string tempStr;

  tempStr.append($1.code); // append first exp(non-terminal) code to tempStr
  tempStr.append($3.code); // append second exp(non-terminal) code to tempStr
  tempStr.append(". ");
  tempStr.append(destination);
  tempStr.append("\n");
  tempStr.append($2.place);
  tempStr.append(dest);
  tempStr.append(", ");
  tempStr.append($1.place);
  tempStr.append(", ");
  tempStr.append($3.place);
  tempStr.append("\n");
  
  $$.code = strdup(tempStr.c_str());
  $$.place = strdup(destination.c_str());
}
		 | L_PAREN bool_exp R_PAREN
		 {
		   $$.place = strdup($2.place);
  	           $$.code = strdup($2.code);
		 }
		 | TRUE
                 { char tempArr[2] = "1"; // needs null terminator
                   $$.place = strdup(tempArr);
                   $$.code = strdup(empty);
                 }
                 | FALSE
                 { char tempArr[2] = "0";
                   $$.place = strdup(tempArr);
                   $$.code = strdup(empty);
                 }

;

functionIdent: 	 IDENT
{
  if (functions.find(std::string($1)) != functions.end()) 
  {
    char tempStr[128];
    snprintf(tempStr, 128, "Redeclaration of function %s", $1);
    yyerror(tempStr);
  }
  else 
  {
    functions.insert(std::pair<std::string,int>($1,0));
  }
  $$.place = strdup($1);
  $$.code = strdup(empty);;
}
;

local:		IDENT
{
  std::string variable($1);
  if (variables.find(variable) != variables.end()) {
    char tempStr[128];
    snprintf(tempStr, 128, "Redeclaration of variable %s", variable.c_str());
    yyerror(tempStr);
  }
  else {
    variables.insert(std::pair<std::string,int>(variable,0));
  }
  $$.place = strdup($1);
  $$.code = strdup(empty);;

}
;

comp:            EQ
{ std::string tempStr = "== ";
  $$.place = strdup(tempStr.c_str());
  $$.code = strdup(empty);
}
                 | NEQ
                 { std::string tempStr = "!= ";
		   $$.place = strdup(tempStr.c_str());
		   $$.code = strdup(empty);
		 }
                 | LT
                 { std::string tempStr = "> ";
		   $$.place = strdup(tempStr.c_str());
		   $$.code = strdup(empty);
		 }
                 | GT
                 { std::string tempStr = "< ";
		   $$.place = strdup(tempStr.c_str());
		   $$.code = strdup(empty); 
		 }
                 | LTE
                 { std::string tempStr = "<= ";
  		   $$.place = strdup(tempStr.c_str());
  		   $$.code = strdup(empty);
		 }
                 | GTE
                 { std::string tempStr = ">= ";
  		   $$.place = strdup(tempStr.c_str());
  		   $$.code = strdup(empty);
		 }
;
%%
int yyparse();
int yylex();

int main(int argc, char **argv) {
	if (argc > 1) {
		yyin = fopen(argv[1], "r");
		if (yyin == NULL){
			printf("syntax: %s filename\n", argv[0]);
			exit(1);
		}
	}
	else {
		yyin=stdin;
	}
	programTitle = strdup(argv[1]);

	yyparse();
	return 0;
}
		 
void yyerror(const char* msg) {
  printf("** Line %d, position %d: %s\n", line, position, msg);
}

std::string newtemp() {
	static int number = 0;
	std::string temp = "_t" + std::to_string(number++);
	return temp;
}

std::string newlabel() {
	static int number = 0;
	std::string label = 'L' + std::to_string(number++);
	return label;
}
