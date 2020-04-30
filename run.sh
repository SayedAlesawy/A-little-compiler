bison -d parser.y &&
flex lexer.l &&
gcc -o compiler parser.tab.c lex.yy.c &&
./compiler $1
