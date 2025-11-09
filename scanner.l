%{
#include <stdio.h>
#include <string.h>

int line_no = 1;
FILE *token_file;
FILE *error_file;

void print_token(const char *type, const char *lexeme) {
    fprintf(token_file, "Line %d: %s -> %s\n", line_no, type, lexeme);
}

void print_error(const char *lexeme) {
    fprintf(error_file, "Line %d: ERROR -> %s (unknown token)\n", line_no, lexeme);
}
%}

DIGIT    [0-9]
ID       [a-zA-Z_][a-zA-Z0-9_]*
EXP      {DIGIT}+(\.{DIGIT}+)?([eE][+-]?{DIGIT}+)?
STRING   \"(\\.|[^"\\])*\" 
CHAR     \'([^'\\]|\\.)\'
KW       (bidaya|nihaya|iza|aw|li|amal|raji3|adkhal|bayan|haqq|batil|ma_dam|ruk|silsila|taifa)

%%

\n                   { line_no++; }

"/*"[^*]*\*+([^/*][^*]*\*+)*"/"   { /* ignore block comment */ }
"//".*               { /* ignore */ }


[ \t\r]+             { /* ignore */ }


{KW}                 { print_token("KEYWORD", yytext); }


"zid"                { print_token("OPERATOR Equivalent(+)", yytext); }
"naqis"              { print_token("OPERATOR Equivalent(-)", yytext); }
"musaawi"            { print_token("OPERATOR Equivalent(==)", yytext); }
"laysa"              { print_token("OPERATOR Equivalent(!)", yytext); }


"khtm"               { print_token("PUNCTUATION(;)", yytext); }
"fat7"               { print_token("PUNCTUATION({)", yytext); }
"ighlaq"             { print_token("PUNCTUATION(})", yytext); }


"("                  { print_token("PUNCTUATION", yytext); }
")"                  { print_token("PUNCTUATION", yytext); }


{ID}                 { print_token("IDENTIFIER", yytext); }


{EXP}                { print_token("NUMBER", yytext); }


{STRING}             { print_token("STRING", yytext); }
{CHAR}               { print_token("CHAR", yytext); }


"=="                 { print_token("OPERATOR", yytext); }
"+"                  { print_token("OPERATOR", yytext); }
"-"                  { print_token("OPERATOR", yytext); }
"*"|"%"|"/"|"="|"<"|">"|"&&"|"||"|"!="  { print_token("OPERATOR", yytext); }

";"               { print_token("PUNCTUATION(;)", yytext); }
"{"               { print_token("PUNCTUATION({)", yytext); }
"}"             { print_token("PUNCTUATION(})", yytext); }



{DIGIT}+{ID}         { print_error(yytext); }

.                    { print_error(yytext); }

%%

int main(int argc, char **argv) {
    token_file = fopen("tokens.txt", "w");
    error_file = fopen("error.log", "w");

    if (!token_file || !error_file) {
        perror("fopen");
        return 1;
    }

    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) { perror("fopen input"); return 1; }
        yyin = f;
    }

    yylex();

    fclose(token_file);
    fclose(error_file);
    return 0;
}
