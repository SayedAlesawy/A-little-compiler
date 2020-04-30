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
	void semantic_failure();
	void semantic_failure_param();
	void print_quad();
	void print_tuple();
	void insert_declration();
	void insert_quad_assign();
	void insert_tuple_assign();
	void intialize_variable_expression();
	void intialize_variable();
	void insert_in_sym_tab();

	struct statment {
		int lino, ty;
		char type[50], name[50], dst[50], src1[50], src2[50], op[50];
	};

	struct sym_tab_entry {
		char type[50], name[50], value[50];
		bool intialized;
	};
%}

%union {
	char* token;
}

%token <token> IDENTIFIER INT DOUBLE CHAR STRING
%token <token> INT_VAL DOUBLE_VAL CHAR_VAL STRING_VAL
%token <token> SEMICOLON DOT MINUS_OP ADD_OP ASSIGNMENT_OP

%type <token> type variable operator

%start statements

// grammar rules
%%
statements: statements statement | statement;

statement: declarations | assignments

declarations: declarations declaration | declaration;

declaration: type IDENTIFIER SEMICOLON { insert_in_sym_tab($1, $2); insert_declration($1, $2); }

type: INT | DOUBLE | CHAR | STRING;

assignments: assignments assignment | assignment;

assignment: IDENTIFIER ASSIGNMENT_OP variable operator variable SEMICOLON   { insert_quad_assign($1, $3, $4, $5); intialize_variable_expression($1, $3, $5);}
					| IDENTIFIER ASSIGNMENT_OP variable SEMICOLON                     { insert_tuple_assign($1, $3); intialize_variable($1, $3); }
					;

variable: IDENTIFIER | INT_VAL | DOUBLE_VAL | CHAR_VAL | STRING_VAL;

operator: ADD_OP | MINUS_OP;
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

char* get_value_from_sym_tab(char* name)
{
	for(int i = 0; i < sym_tab_idx; i++) {
		int eq = strcmp(name, sym_table[i].name);

		if(eq == 0) return sym_table[i].value;
	}
}


bool is_intialized(char* name)
{
	for(int i = 0; i < sym_tab_idx; i++) {
		int eq = strcmp(name, sym_table[i].name);

		if(eq == 0) return sym_table[i].intialized;
	}
	return false;
}

void insert_in_sym_tab(char* type, char* name)
{
	if(in_sym_table(name)) { semantic_failure_param("Redeclaration of already declared variable"); return; }

	struct sym_tab_entry sym_entry;

	strcpy(sym_entry.type, type);
	strcpy(sym_entry.name, name);

	sym_table[sym_tab_idx++] = sym_entry;
}

void set_intialized_state_for_var(char* name, char * value)
{
	for(int i = 0; i < sym_tab_idx; i++) {
		int eq = strcmp(name, sym_table[i].name);

		if(eq == 0) 
		{
			sym_table[i].intialized = 1;
			strcpy(sym_table[i].value, value);
		}
	}
}

bool check_type_match(char* required_type, char* var_type)
{
	if(strlen(required_type) != strlen(var_type)) return false;
	for(int i = 0; i < strlen(required_type); i += 1)
	{
		if(required_type[i] != var_type[i]) return false;
	}
	return true;
}
int check_val_type(char* val)
{
	if(val[0] == '\''){
		return 0;
	}
	if(val[0] == '"'){
		return 1;
	}
	if(val[0] >= '0' && val[0] <= '9'){
		return 2;
	}
	return 3;
}
int convert_name_type(char * var_type)
{
	if(check_type_match(var_type, "int") || check_type_match(var_type, "double")){
		return 2;
	}
	if(check_type_match(var_type, "string")){
		return 1;
	}
	if(check_type_match(var_type, "char")){
		return 0;
	}
	return -1;
}

void intialize_variable(char * name, char * value)
{
	if(!in_sym_table(name)) { semantic_failure_param("First operand not declared"); return; }
	char* var_type = get_type_from_sym_tab(name);
	if( var_type == NULL) { semantic_failure(); return; }
	int var_type_int = convert_name_type(var_type);
	int val_type = check_val_type(value);
	if(val_type != 3){
		if(var_type_int != val_type){ semantic_failure_param("Operand and value are of different non castable types"); return; }
		set_intialized_state_for_var(name, value);
	}
	else{
		if(!in_sym_table(value)) { semantic_failure_param("Second operand not declared"); return; }
		if(!is_intialized(value)) { semantic_failure_param("Second operand not intialized"); return; }

		char* v_type = get_type_from_sym_tab(value);
		if( v_type == NULL) { semantic_failure(); return; }
		int v_type_int = convert_name_type(v_type);

		if(v_type_int != var_type_int){ semantic_failure_param("Two operands are of different non castable types"); return; }
		set_intialized_state_for_var(name, get_value_from_sym_tab(value));
	}
}

void intialize_variable_expression(char * v1_name, char * v2_name, char * v3_name)
{
	intialize_variable(v1_name, v2_name);
	intialize_variable(v1_name, v3_name);
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

void semantic_failure()
{
	fprintf(stderr, "Semantic error at line %d\n", line_num);
}

void semantic_failure_param(char * err)
{
	fprintf(stderr, "Semantic error at line %d | %s\n", line_num, err);
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
	
	if(!flag) print_quadruples();

	print_sym_tab();

	return flag;
}
