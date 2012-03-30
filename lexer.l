%option noyywrap 
%{
#include <stdio.h>
#include <string>
#include "header.h" 
int linenumber;
std::string comment;
symtab * lookup();
symtab * ptr;
void     insertID(char*);
void 	 printSymTab();
/* You need to define for all tokens in C-- */

/* Reserved words */
#define RW_RETURN  10
#define RW_TYPEDEF 11
#define RW_IF      12
#define RW_ELSE    13
#define RW_INT     14
#define RW_FLOAT   15
#define RW_FOR     16
#define RW_STRUCT  17
#define RW_UNION   18
#define RW_VOID    19
#define RW_WHILE   20
/* Arithmetic operators */
#define OP_PLUS    21
#define OP_MINUS   22
#define OP_MUL     23
#define OP_DIV     24
/* Relational operators */
#define OP_LT      30
#define OP_ST      31
#define OP_LE      32
#define OP_SE      33
#define OP_NE      34
#define OP_EQ      35
/* Logical operators */
#define OP_OR      40
#define OP_AND     41
#define OP_NOT     42
/* assignment operator */
#define OP_ASSIGN  43
/* Separators */
#define MK_LPAREN  50
#define MK_RPAREN  51
#define MK_LBRACK  52
#define MK_RBRACK  53
#define MK_LBRACE  54
#define MK_RBRACE  55
#define MK_COMMA   56
#define MK_SEMICOL 57
#define MK_DOT     58
/* ERROR */
#define ERROR 		100 

%}

/* Comment is implement via start condition, not RE. */
      
/* Reserved words */
RWReturn  "return"
RWTypedef "typedef"
RWIf      "if"
RWElse    "else"
RWInt     "int"
RWFloat   "float"
RWFor     "for"
RWStruct  "struct"
RWUnion   "union"
RWVoid    "void"
RWWhile   "while"

/* Literals */
letter   [A-Za-z]
digit    [0-9]
ID	 {letter}({letter}|{digit}|"_")*
WS	 [ \t]+
Int_constant    {digit}+
Float_constant  {digit}+"."{digit}+
String_constant \"({letter}|{digit}|[_!@~`%&|%#()[{}.|*+?/$]|"]"|"^"|"-"|" "|"\t"|"\n"|"\\"|"\"")*\"



/* Arithmetic operators */
OP_plus    "+"
OP_minus   "-"
OP_mul     "*"
OP_div     "/"
/* Relational operators */
OP_lt "<"
OP_st ">"
OP_le ">="
OP_se "<="
OP_ne "!="
OP_eq "=="
/* Logical operators */
OP_or      "||"
OP_and     "&&"
OP_not     "!"
/* assignment operator */
OP_assign  "="

/* Separators */ 
newline  "\n"

DL_lparen  "("
DL_rparen  ")"
DL_lbrack  "["
DL_rBrack  "]"
DL_lbrace  "{"
DL_rbrace  "}"
DL_comma   ","
DL_semicol ";"
DL_dot     "."



error    .

%x CMNT

%%

"/*"        { comment = "/*"; BEGIN CMNT; }
<CMNT>.     { comment.append(1, yytext[0]); }
<CMNT>\n    { comment.append(1, '\n'); linenumber++;}
<CMNT>"*/"  { BEGIN INITIAL; comment.append("*/"); printf("%s\n", comment.c_str()); }	

{RWReturn}  { /* return RW_RETURN; */ }
{RWTypedef} { /* return RW_TYPEDEF; */ }
{RWIf}      { /* return RW_IF; */ }
{RWElse}    { /* return RW_ELSE; */ }
{RWInt}     { /* return RW_INT; */ }
{RWFloat}   { /* return RW_FLOAT; */ }
{RWFor}     { /* return RW_FOR; */ }
{RWStruct}  { /* return RW_STRUCT; */ }
{RWUnion}   { /* return RW_UNION; */ }
{RWVoid}    { /* return RW_VOID; */ }
{RWWhile}   { /* return RW_WHILE; */ }

{WS}              {}


{OP_plus}  { /* return OP_PLUS; */ }
{OP_minus} { /* return OP_MINUS; */ }
{OP_mul}   { /* return OP_MUL; */ }
{OP_div}   { /* return OP_DIV; */ }

{OP_lt}    { /* return OP_LT; */ }
{OP_st}    { /* return OP_ST; */ }
{OP_le}    { /* return OP_LE; */ }
{OP_se}    { /* return OP_SE; */ }
{OP_ne}    { /* return OP_NE; */ }
{OP_eq}    { /* return OP_EQ; */ }

{OP_or}    { /* return OP_OR; */ }
{OP_and}   { /* return OP_AND; */ }
{OP_not}   { /* return OP_NOT; */ }

{OP_assign}  { /* return OP_ASSIGN; */ }


{DL_lparen}   { /* return MK_LPAREN; */ }
{DL_rparen}   { /* return MK_RPAREN; */ }
{DL_lbrack}   { /* return MK_LBRACK; */ }
{DL_rBrack}   { /* return MK_RBRACK; */ }
{DL_lbrace}   { /* return MK_LBRACE; */ }
{DL_rbrace}   { /* return MK_RBRACE; */ }
{DL_comma}    { /* return MK_COMMA; */ }
{DL_semicol}  { /* return MK_SEMICOL; */ }
{DL_dot}      { /* return MK_DOT; */ }


{Int_constant}    { /*printf("int literal: %s\n", yytext); */ }
{Float_constant}  { /*printf("float literal: %s\n", yytext); */ }
{String_constant} { /*printf("string literal: %s\n", yytext); */ }
{ID}              { 
		      ptr = lookup(yytext);
		      if (ptr == NULL)
			insertID(yytext);	
		      else 
			ptr->counter++;
                  }


{newline}       linenumber += 1;
{error}         printf("ERR %s\n", yytext);


%%

main(int argc, char **argv)
{
 argc--; ++argv;
   if (argc > 0)
      yyin = fopen(argv[0], "r");
   else
      yyin = stdin;
   yylex();
   printf("\nThere are %d lines\n\n", linenumber);
   printSymTab();
}

