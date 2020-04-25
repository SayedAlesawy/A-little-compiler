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

"int"	    { return INT; }
"double"	{ return DOUBLE; }
"char"    { return CHAR; }

";"   { return SEMICOLON; }
","		{ return COMMA; }
"."		{ return DOT; }
"-"   { return NEG_OP; }
"="		{ return ASSIGNMENT_OP; }
"*"		{ return ASTERISK_OP; }

{IDENTIFIER}    { return IDENTIFIER; }
{INT_VAL} 		  { return INT_VAL; }
{DOUBLE_VAL} 		{ return DOUBLE_VAL; }
{CHAR_VAL} 		  { return CHAR_VAL; }
{STRING_VAL}    { return STRING_VAL; }

"\n"	{ line_num += 1; }
[ \t\r\f]+
.			{ yyerror("Parsing encountered an unkown character"); }

%%
