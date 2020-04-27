bison -d parser.y &&
flex lexer.l &&
gcc -o little-faggot parser.tab.c lex.yy.c &&
./little-faggot input.c
