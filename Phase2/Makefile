CFLAGS = -g -Wall -ansi -pedantic

parser:  phase2.lex phase2.y
	bison -d -v phase2.y
	flex phase2.lex	
	gcc -o parser phase2.tab.c lex.yy.c -lfl

clean:
	rm -rf parser phase2.tab.* phase2.output *~ lex.yy.c output.txt 
