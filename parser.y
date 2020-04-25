%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	extern FILE *yyin;
	extern FILE *yyout;
	extern int line_num;
	extern int yylex();
	void yyerror();
%}

// parser tokens
%token IDENTIFIER INT DOUBLE CHAR
%token INT_VAL DOUBLE_VAL CHAR_VAL STRING_VAL
%token SEMICOLON COMMA DOT NEG_OP ASSIGNMENT_OP AMPERSAND_OP ASTERISK_OP

%start program

// grammar rules
%%
program: declarations assignments;

declarations: declarations declaration | declaration;

declaration: type name SEMICOLON;

type: INT | DOUBLE | CHAR;

name: variable | name COMMA variable;

variable: IDENTIFIER | ASTERISK_OP IDENTIFIER;

assignments: assigment assigment | assigment;

expression: variable | sign value;

sign: NEG_OP | /* empty */; 

value: INT_VAL | DOUBLE_VAL | CHAR_VAL;

assigment: reference variable ASSIGNMENT_OP expression SEMICOLON; 

reference: AMPERSAND_OP | /* empty */;

%%

void yyerror ()
{
  fprintf(stderr, "Syntax error at line %d\n", line_num);
  exit(1);
}

int main (int argc, char *argv[]){
	// parsing
	int flag;
	yyin = fopen(argv[1], "r");
	flag = yyparse();
	fclose(yyin);
	
	return flag;
}
