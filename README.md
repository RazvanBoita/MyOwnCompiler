# MyOwnCompiler
A compiler built using flex, yacc and C++, that parses an input and determines if it's correct.

This application mimics a real-world compiler/interpretor that parses a given input based on my personal rules.
It checks the input code and it creates a symbol table for all the variables declared, as well as a separate file for the functions, with info about their scope, parameters, etc.
You can check the syntax in the .txt file provided. Any error (semantic or sintactic) will be explicitly thrown.

Guide for testing the application:
1. Fork this repository
2. Copy the Makefile correctly and hit 'make', this should create a new executable called 'limbaj'.
3. Now execute './limbaj prezentat.txt'.
