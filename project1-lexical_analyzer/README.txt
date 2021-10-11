README:
Use Java to write the lexical analyzer.
First, write a mylexer.g and use antlr to produce mylexer.tokens and mylexer.java.
Second, write a testLexer.java and compile the mylexer.java and testLexer.java.
($javac -cp ../antlr-3.5.2-complete.jar testLexer.java mylexer.java)
Finally, execute it on three different testing programs.
($java -cp ../antlr-3.5.2-complete.jar:. testLexer testing_program1.c)
($java -cp ../antlr-3.5.2-complete.jar:. testLexer testing_program2.c)
($java -cp ../antlr-3.5.2-complete.jar:. testLexer testing_program3.c)