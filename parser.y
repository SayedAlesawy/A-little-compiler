%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	extern FILE *yyin;
	extern FILE *yyout;

	extern int line_num;
	extern int yylex();
	void yyerror();
	void print_quad();
	void print_tuple();
	void print_declration();
%}

%union {
	char* token;
}

%token <token> IDENTIFIER INT DOUBLE CHAR STRING
%token <token> INT_VAL DOUBLE_VAL CHAR_VAL STRING_VAL
%token <token> SEMICOLON DOT MINUS_OP ADD_OP ASSIGNMENT_OP

%type <token> type

%start statements

// grammar rules
%%
statements: statements statement | statement;

statement: declarations | assignments

declarations: declarations declaration | declaration;

declaration: type IDENTIFIER SEMICOLON { print_declration($1, $2); }

type: INT | DOUBLE | CHAR | STRING;

assignments: assignments assignment | assignment;

assignment: IDENTIFIER ASSIGNMENT_OP IDENTIFIER ADD_OP IDENTIFIER SEMICOLON   { print_quad($1, $3, "+", $5); }
					| IDENTIFIER ASSIGNMENT_OP IDENTIFIER MINUS_OP IDENTIFIER SEMICOLON { print_quad($1, $3, "-", $5); }
					| IDENTIFIER ASSIGNMENT_OP IDENTIFIER SEMICOLON                     { print_tuple($1, $3); }
					| IDENTIFIER ASSIGNMENT_OP INT_VAL SEMICOLON                      	{ print_tuple($1, $3); }
					| IDENTIFIER ASSIGNMENT_OP DOUBLE_VAL SEMICOLON                     { print_tuple($1, $3); }
					| IDENTIFIER ASSIGNMENT_OP CHAR_VAL SEMICOLON                       { print_tuple($1, $3); }
					| IDENTIFIER ASSIGNMENT_OP STRING_VAL SEMICOLON                     { print_tuple($1, $3); }
					;
%%

void print_declration(char* type, char* name)
{
	printf("\nline: %d\n", line_num);
	printf("type: %s\n", type);
	printf("name: %s\n", name);
}

void print_quad(char* dst, char* src1, char* op, char* src2)
{
	printf("\nline: %d\n", line_num);
	printf("destination: %s\n", dst);
	printf("source1: %s\n", src1);
	printf("operation: %s\n", op);
	printf("source2: %s\n", src2);
}

void print_tuple(char* dst, char* src)
{
	printf("\nline: %d\n", line_num);
	printf("destination: %s\n", dst);
	printf("source: %s\n", src);
}

void yyerror()
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
