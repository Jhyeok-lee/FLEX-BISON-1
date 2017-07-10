%{
#include <stdlib.h>
#include <string.h>

#include "c2c.tab.h"
%}

INTNUM			[0-9]+
FLOATNUM		[0-9]+.[0-9]+
SPECIAL			[\*\/\-\+]
SPACE			[ \t\r\n]
IDENT			[a-zA-Z][a-zA-Z0-9_]*

%%

"int"				{return *yytext;}
"float"				{return *yytext;}
"for"				{return *yytext;}
"if"				{return *yytext;}
"else"				{return *yytext;}
"while"				{return *yytext;}
"do"				{return *yytext;}
"return"			{return *yytext;}
"=="				{return *yytext;}
"!="				{return *yytext;}
"<"					{return *yytext;}
">"					{return *yytext;}
"<="				{return *yytext;}
">="				{return *yytext;}
"="					{return *yytext;}
"("					{return *yytext;}
")"					{return *yytext;}
"{"					{return *yytext;}
"}"					{return *yytext;}
"["					{return *yytext;}
"]"					{return *yytext;}
";"					{return *yytext;}

{SPACE}
{
	break;
}

{INTNUM} {
	yylval.intnum = atoi(yytext);
	return INTNUM;
}

{FLOATNUM} {
	yylval.floatnum = atof(yytext);
	return FLOATNUM;
}

{SPECIAL} {
	return *yytext;
}

{IDENT} {
	yylval.ident = strdup(yytext);
	return IDENT;
}

