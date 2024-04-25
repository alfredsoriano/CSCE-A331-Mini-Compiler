%{
#include "compiler.tab.h"
%}

%%

"exit"              {return exit_statement;}
"print"             {return print;}
"sin"               {return sine;}
"cos"               {return cosine;} 
"tan"               {return tangent;}
[+\-*/=;\(\)^%]     {return yytext[0];}
[0-9]+              {yylval.num = atoi(yytext); return int_number;}
[0-9]+[.][0-9]+     {yylval.num = atof(yytext); return float_number;}
[a-zA-Z]+           {yylval.id = yytext; return identifier;}
[ \t\n]             ;
[.]+                {yyerror("Unrecognized character entered.");}

%%

int yywrap (void)   {return 1;}