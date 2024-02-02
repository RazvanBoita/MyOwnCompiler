%{
#include <stdio.h>
#include "limbaj.tab.h"
%}
%option noyywrap
%%
"int" {yylval.data_type = strdup(yytext);return INT;}
"float" {yylval.data_type = strdup(yytext);return FLOAT;}
"char" {yylval.data_type = strdup(yytext);return CHAR;}
"string" {yylval.data_type = strdup(yytext);return STRING;}
"bool" {yylval.data_type = strdup(yytext);return BOOL;}
"class" {yylval.new_type = strdup(yytext); return CLASS;}
"!begin_progr" {return BGIN;}
"!end_progr" {return END;}
"!begin_classes" {return BGIN_CLASS;}
"!end_classes" {return END_CLASS;}
"!begin_vars" {return BGIN_VARS;}
"!end_vars" {return END_VARS;}
"!begin_functions" {return BGIN_FNC;}
"!end_functions" {return END_FNC;}
$[a-zA-Z][a-zA-Z0-9]* {yylval.nume_variabila = strdup(yytext); return ID_VAR;}
@[_a-zA-Z][_a-zA-Z0-9]* {yylval.nume_variabila = strdup(yytext); return ID_CLASA;} 
#[_a-zA-Z][_a-zA-Z0-9]* {yylval.nume_variabila = strdup(yytext); return ID_FUNC;}
\"[^\"]*\" {return CUVANT;}
":=" {return ASSIGN;}
"if" { return IF; }
"while" { return WHILE; }
"for" { return FOR; }
"==" { return EQUAL; }
"!=" {return NEQUAL;}
"<<" {return LT;}
">>" {return GT;}
"<=" { return LE; }
">=" { return GE; }
"Eval" {return EVAL;}
"TypeOf" {return TYPEOF;}
"->" {return CLASS_ACCESS;}
"public" {return PUBLIC;}
"private" {return PRIVATE;}
"constant" {return CONSTANT;}
"true" {return ADV;}
"false" {return FAKE;}
"&&" {return AND;}
"||" {return OR;}
"return" {return RETURN;}
"null" {return NIMIC;}
"Init" {return INIT;}
"init()" {return INIT_CALL;}
'.' {return LITERA;}
[0-9]+ {return NR;}
[0-9]+([.,][0-9]+)? {return NR_ZECIMAL;}
"[" {return LBRACKET;}
"]" {return RBRACKET;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

 
