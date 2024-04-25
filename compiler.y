/* C declarations */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

void yyerror (const char *s)           {fprintf(stderr, "Error: %s\n", s);}
int yyparse();
int yylex();

typedef struct symbol {
    char* identifier = "\0";
    double value = 9;
    struct symbol* next;
} symbol;
struct symbol* head = NULL;
void update_table(char* identifier, double value);
double get_value(char* identifier);
void print_result(double num);           
%}

/* yacc definitions */
%union {double num; char* id;}
%start statement
%token exit_statement print
%token sine cosine tangent
%type<num> expr term
%type<id> assign
%token<num> int_number float_number
%token<id> identifier
%left '+' '-' '*' '/' '^' '%'
%left '(' ')'
%right '='

%%

statement: print expr ';'                {print_result($2);}
        | exit_statement ';'             {exit(0);}
        | assign ';'                     {;}
        /* recursive statement allow for multiple inputs*/
        | statement print expr ';'       {print_result($3);}
        | statement exit_statement ';'   {exit(0);}
        | statement assign ';'           {;}
;

expr: term                              {$$ = $1;}
    | '(' expr ')'                      {$$ = $2;}
    /*simple calculator functions*/
    | expr '+' term                     {$$ = $1 + $3;}
    | expr '-' term                     {$$ = $1 - $3;}
    | expr '*' term                     {$$ = $1 * $3;}
    | expr '/' term                     {if ($3 == 0) {yyerror("Cannot divide by 0.");} else {$$ = $1 / $3;}}
    | expr '^' term                     {$$ = pow($1, $3);}
    | expr '%' term                     {$$ = fmod($1, $3);}
    /*trigonometry functions*/
    | sine '(' term ')'                 {$$ = sin((double)$3);}
    | cosine '(' term ')'               {$$ = cos((double)$3);}
    | tangent '(' term ')'              {$$ = tan((double)$3);}
;

assign: identifier '=' expr             {update_table($1, $3);}

term: int_number                        {$$ = $1;}
    | float_number                      {$$ = $1;}
    | identifier                        {$$ = get_value($1);}
;

%%

/*linked list helper functions*/
void update_table(char* identifier, double value) {
    //checks if symbol already in linked list,
    struct symbol* curr = head;
    while (curr != NULL) {
        if (strcmp(curr->identifier, identifier) == 0) {
            curr->value = value;
            return;
        }
        curr = curr->next;
    }

    //if symbol doesn't exist, creates a new symbol
    struct symbol* new_symbol = (struct symbol*)malloc(sizeof(struct symbol));
    new_symbol->identifier = strdup(identifier);
    new_symbol->value = value;
    new_symbol->next = head;
    head = new_symbol;
}

double get_value(char* identifier) {
    struct symbol* curr = head;
    while (curr != NULL) {
        if (strcmp(curr->identifier, identifier) == 0) {
            return curr->value;
        }
        curr = curr->next;
    }
}

void print_result(double num) {
    if (floor(num) == num) {
        printf("%d\n\n", (int)num);
    }
    else {
        printf("%f\n\n", num);
    }
}

int main() {
    yyparse();
    return 0;
}
