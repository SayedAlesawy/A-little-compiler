%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <stdbool.h>

	extern FILE *yyin;
	extern FILE *yyout;

	extern int line_num;
	extern int yylex();
	void yyerror();

	void print_quad();
	void print_tuple();
	void insert_declration();
	void insert_quad_assign();
	void insert_tuple_assign();

	void insert_in_sym_tab();

	struct statment {
		int lino, ty;
		char type[50], name[50], dst[50], src1[50], src2[50], op[50];
	};

	struct sym_tab_entry {
		char type[50], name[50], value[50];
	};
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

declaration: type IDENTIFIER SEMICOLON { insert_in_sym_tab($1, $2); insert_declration($1, $2); }

type: INT | DOUBLE | CHAR | STRING;

assignments: assignments assignment | assignment;

assignment: IDENTIFIER ASSIGNMENT_OP IDENTIFIER ADD_OP IDENTIFIER SEMICOLON   { insert_quad_assign($1, $3, "+", $5); }
					| IDENTIFIER ASSIGNMENT_OP IDENTIFIER MINUS_OP IDENTIFIER SEMICOLON { insert_quad_assign($1, $3, "-", $5); }
					| IDENTIFIER ASSIGNMENT_OP IDENTIFIER SEMICOLON                     { insert_tuple_assign($1, $3); }
					| IDENTIFIER ASSIGNMENT_OP INT_VAL SEMICOLON                      	{ insert_tuple_assign($1, $3); }
					| IDENTIFIER ASSIGNMENT_OP DOUBLE_VAL SEMICOLON                     { insert_tuple_assign($1, $3); }
					| IDENTIFIER ASSIGNMENT_OP CHAR_VAL SEMICOLON                       { insert_tuple_assign($1, $3); }
					| IDENTIFIER ASSIGNMENT_OP STRING_VAL SEMICOLON                     { insert_tuple_assign($1, $3); }
					;
%%

struct sym_tab_entry sym_table[100];
int sym_tab_idx = 0;

bool in_sym_table(char* name) {
	for(int i = 0; i < sym_tab_idx; i++) {
		int eq = strcmp(name, sym_table[i].name);

		if(eq == 0) return true;
	}

	return false;
}

char* get_type_from_sym_tab(char* name)
{
	for(int i = 0; i < sym_tab_idx; i++) {
		int eq = strcmp(name, sym_table[i].name);

		if(eq == 0) return sym_table[i].type;
	}
}

void insert_in_sym_tab(char* type, char* name)
{
	if(in_sym_table(name)) yyerror();

	struct sym_tab_entry sym_entry;

	strcpy(sym_entry.type, type);
	strcpy(sym_entry.name, name);

	sym_table[sym_tab_idx++] = sym_entry;
}

void print_sym_tab() {
	for(int i = 0; i < sym_tab_idx; i++) {
		printf("[%d] type: %s\t name: %s\t value: %s\n", i+1, sym_table[i].type, sym_table[i].name, sym_table[i].value);
	}
}

struct statment stmts[100];
int stmts_idx = 0;

void insert_declration(char* type, char* name)
{
	struct statment stmt;

	stmt.lino = line_num;
	stmt.ty = 0;
	strcpy(stmt.type, type);
	strcpy(stmt.name, name);
	
	stmts[stmts_idx++] = stmt;
}

void insert_quad_assign(char* dst, char* src1, char* op, char* src2)
{
	struct statment stmt;

	stmt.lino = line_num;
	stmt.ty = 1;
	strcpy(stmt.dst, dst);
	strcpy(stmt.src1, src1);
	strcpy(stmt.src2, src2);
	strcpy(stmt.op, op);

	stmts[stmts_idx++] = stmt;
}

void insert_tuple_assign(char* dst, char* src)
{
	struct statment stmt;

	stmt.lino = line_num;
	stmt.ty = 2;
	strcpy(stmt.dst, dst);
	strcpy(stmt.src1, src);

	stmts[stmts_idx++] = stmt;
}

void print_declrations(struct statment stmt)
{
	printf("\nline: %d\n", stmt.lino);
	printf("type: %s\n", stmt.type);
	printf("name: %s\n", stmt.name);
}

void print_quad_assigns(struct statment stmt)
{
	printf("\nline: %d\n", stmt.lino);
	printf("destination: %s\n", stmt.dst);
	printf("source1: %s\n", stmt.src1);
	printf("operation: %s\n", stmt.op);
	printf("source2: %s\n", stmt.src2);
}

void print_tuple_assigns(struct statment stmt)
{
	printf("\nline: %d\n", stmt.lino);
	printf("destination: %s\n", stmt.dst);
	printf("source: %s\n", stmt.src1);
}

void print_quadruples()
{
	for(int i = 0; i < stmts_idx; i++){
		if(stmts[i].ty == 0) print_declrations(stmts[i]);
		if(stmts[i].ty == 1) print_quad_assigns(stmts[i]);
		if(stmts[i].ty == 2) print_tuple_assigns(stmts[i]);
	}
}

// void semantic_failure(char* msg)
// {
// 	fprintf(stderr, msg);
//   exit(1);
// }

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
	
	if(!flag) print_quadruples();

	print_sym_tab();

	return flag;
}
