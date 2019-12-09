%{
#define YY_NO_UNPUT
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <map>
#include <vector>

void yyerror(const char* msg);
int yylex();
extern int line;
extern int position;
extern char* yytext;
extern char * programTitle;
std::string newtemp();
std::string newlabel();

char empty[1]="";

std::map<std::string, int> variables;
std::map<std::string, int> functions;
std::vector<std::string> reserved = {"FUNCTION", "BEGIN_PARAMS", "END_PARAMS", "BEGIN_LOCALS", "END_LOCALS", "BEGIN_BODY", "END_BODY", "INTEGER",
    "ARRAY", "OF", "IF", "THEN", "ENDIF", "ELSE", "WHILE", "DO", "FOREACH", "IN", "BEGINLOOP", "ENDLOOP", "CONTINUE", "READ", "WRITE", "AND", "OR", 
    "NOT", "TRUE", "FALSE", "RETURN", "SUB", "ADD", "MULT", "DIV", "MOD", "EQ", "NEQ", "LT", "GT", "LTE", "GTE", "L_PAREN", "R_PAREN", "L_SQUARE_BRACKET",
    "R_SQUARE_BRACKET", "COLON", "SEMICOLON", "COMMA", "ASSIGN", "function", "ident", "beginparams", "endparams", "beginlocals", "endlocals", "integer", 
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

%type <expr> ident local functionIdent
%type <expr> declarations declaration identifiers var vars
%type <stat> statements statement elsestatement
%type <expr> expression expression2 multiplicative_expression term bool_exp relation_and_exp relation_exp relation_exp2 comp

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOREACH IN BEGINLOOP ENDLOOP CONTINUE READ WRITE
%left AND OR
%right NOT
%token TRUE FALSE RETURN
%left SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE ASSIGN
%token L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET COLON SEMICOLON COMMA


%%

input:           %empty
{
  std::string tempString = "main";
  if ( functions.find(tempString) == functions.end()) {
    char temp[128];
    snprintf(temp, 128, "Function main not declared"); // a main function was not found within the program.
    yyerror(temp);
  }
  
  if (variables.find(std::string(programTitle)) != variables.end()) {
    char temp[128];
    snprintf(temp, 128, "Program name is the same as a variable.");
    yyerror(temp);
  }
}
| function input
{}
;

function:	 FUNCTION functionIdent SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY
{
  std::string tempString = "func ";
  tempString.append($2.place);
  tempString.append("\n");
  tempString.append($2.code);
  tempString.append($5.code);

  std::string initial = $5.code;
  int p_num = 0;
  while (initial.find(".") != std::string::npos) {
    size_t position = initial.find(".");
    initial.replace(position, 1, "=");
    std::string para = ", $";
    para.append(std::to_string(p_num++));
    para.append("\n");
    initial.replace(initial.find("\n", position), 1, para);
  }
  tempString.append(initial);
  tempString.append($8.code);
  std::string statements($11.code);
  
if (statements.find("continue") != std::string::npos) {
    printf("ERROR: Continue outside loop in function %s\n", $2.place);
  }
  tempString.append(statements);
  tempString.append("endfunc\n");
  
  printf("%s", tempString.c_str());
}
;

declaration:     identifiers COLON INTEGER
{
  std::string localvars($1.place);
  std::string tempS;
  std::string vari;
  bool proceed = true;

  size_t previous = 0;
  size_t current = 0;
  bool res = false;
  while (proceed) {
    current = localvars.find("|", previous);
    if (current == std::string::npos) {
      tempS.append(". ");
      vari = localvars.substr(previous,current);
      tempS.append(vari);
      tempS.append("\n");
      proceed = false;
    }
    else {
      size_t diff = current - previous;
      tempS.append(". ");
      vari = localvars.substr(previous, diff);
      tempS.append(vari);
      tempS.append("\n");
    }
    for (unsigned int i = 0; i < reserved.size(); ++i) {
      if (reserved.at(i) == vari) {
        res = true; //if word is reserved set to true
      }
    } 
    if (variables.find(vari) != variables.end()) {
      char temp[128];
      snprintf(temp, 128, "Redeclaration of variable %s", vari.c_str());
      yyerror(temp);
    }
    else if (res){
      char temp[128];
      snprintf(temp, 128, "Invalid declaration of reserved words %s", vari.c_str());
      yyerror(temp);
    }
    else {
      variables.insert(std::pair<std::string,int>(vari,0));
    }
    
    previous = current + 1;
  }
  
  $$.code = strdup(tempS.c_str());
  $$.place = strdup(empty);	
}		 
| identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
{
  if ($5 <= 0) {
    char temp[128];
    snprintf(temp, 128, "Array size can't be less than or equal to 0.");
    yyerror(temp);
  }
  
  std::string localvars($1.place);
  std::string tempS;
  std::string vari;
  bool proceed = true;

  size_t previous = 0;
  size_t current = 0;
  while (proceed) {
    current = localvars.find("|", previous);
    if (current == std::string::npos) {
      tempS.append(".[] ");
      vari = localvars.substr(previous, current);
      tempS.append(vari);
      tempS.append(", ");
      tempS.append(std::to_string($5));
      tempS.append("\n");
      proceed = false;
    }
    else {
      size_t diff = current - previous;
      tempS.append(".[] ");
      vari = localvars.substr(previous, diff);
      tempS.append(vari);
      tempS.append(", ");
      tempS.append(std::to_string($5));
      tempS.append("\n");
    }
    if (variables.find(vari) != variables.end()) {
      char temp[128];
      snprintf(temp, 128, "Redeclaration of variable %s", vari.c_str());
      yyerror(temp);
    }
    else {
      variables.insert(std::pair<std::string,int>(vari,$5));
    }
      
    previous = current + 1;  
  }
  
  $$.code = strdup(tempS.c_str());
  $$.place = strdup(empty);
}
;

declarations:    %empty
{
  $$.code = strdup(empty);
  $$.place = strdup(empty);
}                 
| declaration SEMICOLON declarations
{
  std::string tempString;
  tempString.append($1.code);
  tempString.append($3.code);
  
  $$.code = strdup(tempString.c_str());
  $$.place = strdup(empty);
}
;

identifiers:     ident
{
  $$.place = strdup($1.place);
  $$.code = strdup(empty);
}                 
| ident COMMA identifiers
{
  std::string tempString;
  tempString.append($1.place);
  tempString.append("|");
  tempString.append($3.place);
  
  $$.place = strdup(tempString.c_str());
  $$.code = strdup(empty);
}
;

statements:      statement SEMICOLON statements
{
  std::string tempS;
  tempS.append($1.code);
  tempS.append($3.code);

  $$.code = strdup(tempS.c_str());
}
| statement SEMICOLON
{
  std::string tempS;
  tempS.append($1.code);

  $$.code = strdup(tempS.c_str());
}
;

statement:      var ASSIGN expression
{
  std::string tempString;
  tempString.append($1.code);
  tempString.append($3.code);
  std::string im = $3.place;
  if ($1.array && $3.array) {
    im = newtemp();
    tempString.append(". ");
    tempString.append(im);
    tempString.append("\n");
    tempString.append("=[] ");
    tempString.append(im);
    tempString.append(", ");
    tempString.append($3.place);
    tempString.append("\n");
    tempString.append("[]= ");
  }
  else if ($1.array) {
    tempString.append("[]= ");
  }
  else if ($3.array) {
    tempString.append("=[] ");
  }
  else {
    tempString.append("= ");
  }
  tempString.append($1.place);
  tempString.append(", ");
  tempString.append(im);
  tempString.append("\n");

  $$.code = strdup(tempString.c_str());
}                 
| IF bool_exp THEN statements elsestatement ENDIF
{
  std::string then = newlabel();
  std::string later = newlabel();
  std::string tempS;

  // evaluate expression
  tempS.append($2.code);
  // if true goto then label
  tempS.append("?:= ");
  tempS.append(then);
  tempS.append(", ");
  tempS.append($2.place);
  tempS.append("\n");
  // else code
  tempS.append($5.code);
  // goto after
  tempS.append(":= ");
  tempS.append(later);
  tempS.append("\n");
  // then label
  tempS.append(": ");
  tempS.append(then);
  tempS.append("\n");
  // then code
  tempS.append($4.code);
  // after label
  tempS.append(": ");
  tempS.append(later);
  tempS.append("\n");
  
  $$.code = strdup(tempS.c_str());
}                 
| WHILE bool_exp BEGINLOOP statements ENDLOOP
{
  std::string tempS;
  std::string While = newlabel();
  std::string loop = newlabel();
  std::string end = newlabel();
  // replace continue
  std::string stmnt = $4.code;
  std::string skip;
  skip.append(":= ");
  skip.append(While);
  while (stmnt.find("continue") != std::string::npos) {
    stmnt.replace(stmnt.find("continue"), 8, skip);
  }
  
  tempS.append(": ");
  tempS.append(While);
  tempS.append("\n");
  tempS.append($2.code);
  tempS.append("?:= ");
  tempS.append(loop);
  tempS.append(", ");
  tempS.append($2.place);
  tempS.append("\n");
  tempS.append(":= ");
  tempS.append(end);
  tempS.append("\n");
  tempS.append(": ");
  tempS.append(loop);
  tempS.append("\n");
  tempS.append(stmnt);
  tempS.append(":= ");
  tempS.append(While);
  tempS.append("\n");
  tempS.append(": ");
  tempS.append(end);
  tempS.append("\n");

  $$.code = strdup(tempS.c_str());
}                 
| DO BEGINLOOP statements ENDLOOP WHILE bool_exp
{
  std::string tempS;
  std::string loop = newlabel();
  std::string While = newlabel();
  std::string stmnt = $3.code;
  std::string skip;
  skip.append(":= ");
  skip.append(While);
  while (stmnt.find("continue") != std::string::npos) {
    stmnt.replace(stmnt.find("continue"), 8, skip);
  }
  
  tempS.append(": ");
  tempS.append(loop);
  tempS.append("\n");
  tempS.append(stmnt);
  tempS.append(": ");
  tempS.append(While);
  tempS.append("\n");
  tempS.append($6.code);
  tempS.append("?:= ");
  tempS.append(loop);
  tempS.append(", ");
  tempS.append($6.place);
  tempS.append("\n");
  
  $$.code = strdup(tempS.c_str());
}                 
| FOREACH local IN ident BEGINLOOP statements ENDLOOP
{
  std::string tempS;
  std::string counter = newtemp();
  std::string check = newtemp();
  std::string begin = newlabel();
  std::string loop = newlabel();
  std::string increase = newlabel();
  std::string end = newlabel();
  std::string stmnt = $6.code;
  std::string skip;
  skip.append(":= ");
  skip.append(increase);
  while (stmnt.find("continue") != std::string::npos) {
    stmnt.replace(stmnt.find("continue"), 8, skip);
  }
  
  if (variables.find(std::string($4.place)) == variables.end()) {
    char temp[128];
    snprintf(temp, 128, "Undeclared variable %s", $4.place);
    yyerror(temp);
  }
  else if (variables.find(std::string($4.place))->second == 0) {
    char temp[128];
    snprintf(temp, 128, "Variable %s in foreach", $4.place);
    yyerror(temp);
  }

  tempS.append(". ");
  tempS.append($2.place);
  tempS.append("\n");
  tempS.append(". ");
  tempS.append(check);
  tempS.append("\n");
  tempS.append(". ");
  tempS.append(counter);
  tempS.append("\n");
  tempS.append("= ");
  tempS.append(counter);
  tempS.append(", 0");
  tempS.append("\n");
  tempS.append(": ");
  tempS.append(begin);
  tempS.append("\n");
  tempS.append("< ");
  tempS.append(check);
  tempS.append(", ");
  tempS.append(counter);
  tempS.append(", ");
  tempS.append(std::to_string(variables.find(std::string($4.place))->second));
  tempS.append("\n");
  tempS.append("?:= ");
  tempS.append(loop);
  tempS.append(", ");
  tempS.append(check);
  tempS.append("\n");
  tempS.append(":= ");
  tempS.append(end);
  tempS.append("\n");
  tempS.append(": ");
  tempS.append(loop);
  tempS.append("\n");
  tempS.append("=[] ");
  tempS.append($2.place);
  tempS.append(", ");
  tempS.append($4.place);
  tempS.append(", ");
  tempS.append(counter);
  tempS.append("\n");
  tempS.append(stmnt);
  tempS.append(": ");
  tempS.append(increase);
  tempS.append("\n");
  tempS.append("+ ");
  tempS.append(counter);
  tempS.append(", ");
  tempS.append(counter);
  tempS.append(", 1\n");
  tempS.append(":= ");
  tempS.append(begin);
  tempS.append("\n");
  tempS.append(": ");
  tempS.append(end);
  tempS.append("\n");
  
  $$.code = strdup(tempS.c_str());
}
| READ vars
{
  std::string tempS = $2.code;
  size_t current = 0;
  do {
    current = tempS.find("|", current);
    if (current == std::string::npos)
      break;
    tempS.replace(current, 1, "<");
  } while (true);

  $$.code = strdup(tempS.c_str());
}                 
| WRITE vars
{
  std::string tempS = $2.code;
  size_t current = 0;
  do {
    current = tempS.find("|", current);
    if (current == std::string::npos)
      break;
    tempS.replace(current, 1, ">");
  } while (true);

  $$.code = strdup(tempS.c_str());
}                 
| CONTINUE
{
  std::string tempS = "continue\n";
  $$.code = strdup(tempS.c_str());
}		 
| RETURN expression
{
  std::string tempS;
  tempS.append($2.code);
  tempS.append("ret ");
  tempS.append($2.place);
  tempS.append("\n");
  $$.code = strdup(tempS.c_str());
};

elsestatement: %empty
{
	$$.code = strdup(empty);
}
| ELSE statements
{
	$$.code = strdup($2.code);
};

var:             ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET
{
  if (variables.find(std::string($1.place)) == variables.end()) {
    char temp[128];
    snprintf(temp, 128, "Undeclared variable %s", $1.place);
    yyerror(temp);
  }
  else if (variables.find(std::string($1.place))->second == 0) {
    char temp[128];
    snprintf(temp, 128, "Indexing non-array variable %s", $1.place);
    yyerror(temp);
  }

  std::string tempS;
  tempS.append($1.place);
  tempS.append(", ");
  tempS.append($3.place);

  $$.code = strdup($3.code);
  $$.place = strdup(tempS.c_str());
  $$.array = true;
}
| ident
{
  if (variables.find(std::string($1.place)) == variables.end()) {
    char temp[128];
    snprintf(temp, 128, "Undeclared variable %s", $1.place);
    yyerror(temp);
  }
  else if (variables.find(std::string($1.place))->second > 0) {
    char temp[128];
    snprintf(temp, 128, "No index for variable %s", $1.place);
    yyerror(temp);
  }

  $$.code = strdup(empty);
  $$.place = strdup($1.place);
  $$.array = false;
}
;

vars:            var
{
  std::string tempS;
  tempS.append($1.code);
  if ($1.array)
    tempS.append(".[]| ");
  else
    tempS.append(".| ");
  
  tempS.append($1.place);
  tempS.append("\n");

  $$.code = strdup(tempS.c_str());
  $$.place = strdup(empty);
}
| var COMMA vars
{
  std::string tempS;
  tempS.append($1.code);
  if ($1.array)
    tempS.append(".[]| ");
  else
    tempS.append(".| ");
  
  tempS.append($1.place);
  tempS.append("\n");
  tempS.append($3.code);
  
  $$.code = strdup(tempS.c_str());
  $$.place = strdup(empty);
}
;

expression:      multiplicative_expression
{
  $$.code = strdup($1.code);
  $$.place = strdup($1.place);
}
| multiplicative_expression ADD expression
{
  $$.place = strdup(newtemp().c_str());
  
  std::string tempS;
  tempS.append($1.code);
  tempS.append($3.code);
  tempS.append(". ");
  tempS.append($$.place);
  tempS.append("\n");
  tempS.append("+ ");
  tempS.append($$.place);
  tempS.append(", ");
  tempS.append($1.place);
  tempS.append(", ");
  tempS.append($3.place);
  tempS.append("\n");

  $$.code = strdup(tempS.c_str());
}
| multiplicative_expression SUB expression
{
  $$.place = strdup(newtemp().c_str());
  
  std::string tempS;
  tempS.append($1.code);
  tempS.append($3.code);
  tempS.append(". ");
  tempS.append($$.place);
  tempS.append("\n");
  tempS.append("- ");
  tempS.append($$.place);
  tempS.append(", ");
  tempS.append($1.place);
  tempS.append(", ");
  tempS.append($3.place);
  tempS.append("\n");

  $$.code = strdup(tempS.c_str());
}
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
		    $$.place = strdup(newtemp().c_str());
  
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
		   $$.place = strdup(newtemp().c_str());

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
		   $$.place = strdup(newtemp().c_str());

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
    std::string tempStr2 = newtemp();
    
    
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
		 	$$.place = strdup(newtemp().c_str());
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
  
  			$$.code = strdup(tempStr.c_str());
  			$$.array = false;
		 }
		 | ident L_PAREN expression2 R_PAREN
		 {
			  if (functions.find(std::string($1.place)) == functions.end()) {
    				char temp[128];
				snprintf(temp, 128, "Use of undeclared function %s", $1.place);
				yyerror(temp);
			  }

			  $$.place = strdup(newtemp().c_str());

			  std::string temp;
			  temp.append($3.code);
			  temp.append(". ");
			  temp.append($$.place);
			  temp.append("\n");
			  temp.append("call ");
			  temp.append($1.place);
			  temp.append(", ");
			  temp.append($$.place);
			  temp.append("\n");
  
			  $$.code = strdup(temp.c_str());	
		 }
;

bool_exp:        relation_and_exp 
{ 
  $$.place = strdup($1.place);
  $$.code = strdup($1.code);
}
                 | relation_and_exp OR bool_exp
                 {
		   std::string destination = newtemp();
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
		   std::string destination = newtemp();
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
  
     	   $$.code = strdup(tempStr.c_str());
  		   $$.place = strdup(destination.c_str());	
		 }
;

relation_exp: 	  relation_exp2
{
  $$.place = strdup($1.place);
  $$.code = strdup($1.code);
}

		  | NOT relation_exp2
		    {
			std::string destination = newtemp();
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
{ std::string destination = newtemp();
  std::string tempStr;

  tempStr.append($1.code); // append first exp(non-terminal) code to tempStr
  tempStr.append($3.code); // append second exp(non-terminal) code to tempStr
  tempStr.append(". ");
  tempStr.append(destination);
  tempStr.append("\n");
  tempStr.append($2.place);
  tempStr.append(destination);
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

ident:      IDENT
{
  $$.place = strdup($1);
  $$.code = strdup(empty);;
};
local:      IDENT
{
  // Check for redeclaration (test 04) TODO same name as program
  std::string vari($1);
  if (variables.find(vari) != variables.end()) {
    char temp[128];
    snprintf(temp, 128, "Redeclaration of variable %s", vari.c_str());
    yyerror(temp);
  }
  else {
    variables.insert(std::pair<std::string,int>(vari,0));
  }
  $$.place = strdup($1);
  $$.code = strdup(empty);;
};
functionIdent: IDENT
{
  if (functions.find(std::string($1)) != functions.end()) {
    char temp[128];
    snprintf(temp, 128, "Redeclaration of function %s", $1);
    yyerror(temp);
  }
  else {
    functions.insert(std::pair<std::string,int>($1,0));
  }
  $$.place = strdup($1);
  $$.code = strdup(empty);;
}
%%
		 
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
