CFLAGS = -g -Wall -ansi -pedantic

parser: phase3.lex phase3.y
	bison -d -v phase3.y
	flex phase3.lex	
	g++ $(CFLAGS) -std=c++11 lex.yy.c phase3.tab.c -lfl -o parser

clean:
	rm -rf parser phase3.tab.* phase3.output *~ lex.yy.c output.txt ./milFiles/*

test: parser
	./parser ./demo/custom.min > ./milFiles/custom.mil
	./parser ./demo/dowhiletest.min > ./milFiles/dowhiletest.mil
	./parser ./demo/errors.min > ./milFiles/errors.mil
	./parser ./demo/fibonacci.min > ./milFiles/fibonacci.mil
	./parser ./demo/ifelsetest.min > ./milFiles/ifelsetest.mil
	./parser ./demo/mytest.min > ./milFiles/mytest.mil
	./parser ./demo/primes.min > ./milFiles/primes.mil
