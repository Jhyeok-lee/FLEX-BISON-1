all:
	flex c2c.l
	bison -d c2c.y
	gcc lex.yy.c c2c.tab.c print.c -o c2c -lfl -g

clean:
	rm -rf lex.yy.c c2c.tab.c c2c.tab.h c2c tree.txt table.txt
