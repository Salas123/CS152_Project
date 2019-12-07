CFLAGS = -g -Wall -ansi -pedantic

parser:  phase2.lex phase2.y
	bison -d -v phase2.y
	flex phase2.lex	
	gcc -o parser phase2.tab.c lex.yy.c -lfl

clean:
	rm -rf minil mini_1.tab.* mini_1.output *~ lex.yy.c output.txt 
