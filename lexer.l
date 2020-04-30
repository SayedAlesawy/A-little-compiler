%option noyywrap

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "parser.tab.h"

	extern FILE *yyin;
	extern FILE *yyout;
	
	int line_num = 1;
	void yyerror();

	void save_token();
%}

%x LINE

alpha             [a-zA-Z]
digit             [0-9]
alnum             {alpha}|{digit}
printable_ascii	  [ -~]

IDENTIFIER  {alpha}+{alnum}*
INT_VAL     "0"|[0-9]{digit}*
DOUBLE_VAL  "0"|{digit}*"."{digit}+
CHAR_VAL		(\'{printable_ascii}\')|(\'\\[nftrbv]\')
STRING_VAL	\"{printable_ascii}*\"

%%
	
<LINE>"\n"		{ line_num += 1; }

"int"	    { save_token(); return INT; }
"double"	{ save_token(); return DOUBLE; }
"char"    { save_token(); return CHAR; }
"string"  { save_token(); return STRING; }

";"   { save_token(); return SEMICOLON; }
"."		{ save_token(); return DOT; }
"-"   { save_token(); return MINUS_OP; }
"+"   { save_token(); return ADD_OP; }
"="		{ save_token(); return ASSIGNMENT_OP; }

{IDENTIFIER}    { save_token(); return IDENTIFIER; }
{INT_VAL} 		  { save_token(); return INT_VAL; }
{DOUBLE_VAL} 		{ save_token(); return DOUBLE_VAL; }
{CHAR_VAL} 		  { save_token(); return CHAR_VAL; }
{STRING_VAL}    { save_token(); return STRING_VAL; }

"\n"	{ line_num += 1; }
[ \t\r\f]+
.			{ yyerror("Parsing encountered an unkown character"); }

%%

void save_token()
{
	yylval.token = strndup(yytext, yyleng + 1);
	yylval.token[yyleng] = '\0';
}
