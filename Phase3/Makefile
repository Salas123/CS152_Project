CFLAGS = -g -Wall -ansi -pedantic

parser: phase3.lex phase3.y
	bison -d -v phase3.y
	flex phase3.lex	
	g++ $(CFLAGS) -std=c++11 lex.yy.c phase3.tab.c -lfl -o parser

clean:
	rm -rf parser phase3.tab.* phase3.output *~ lex.yy.c output.txt

test: parser
	./parser fibonacci.min > ./milFiles/fibonacci.mil
	./parser primes.min > ./milFiles/primes.mil
