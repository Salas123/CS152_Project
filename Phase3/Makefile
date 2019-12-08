CFLAGS = -g -Wall -ansi -pedantic

parser: phase3_1.lex phase3_1.y
	bison -d -v phase3_1.y
	flex phase3_1.lex	
	g++ $(CFLAGS) -std=c++11 -o parser phase3_1.tab.c lex.yy.c -lfl

clean:
	rm -rf parser phase3_1.tab.* phase3_1.output *~ lex.yy.c output.txt 
