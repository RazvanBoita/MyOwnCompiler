%{
#include <iostream>
#include <vector>
#include <cstring>
#include "IdList.h"
#include <sstream>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
extern int yylex();
string scope;
string comma_decl_type;
char buffer[256];
char func_id_name[25][51];
char func_param_name[25][51];
char func_param_type[25][51];
int call_param_index=0;
int func_index=0;
int param_index=0;
void yyerror(const char * s);
class IdList ids;
class FunctionInfo fds;
class Classes classes;
class Errors errors;
vector<ParamInfo> paramsToAdd;
int getTypeCode(const char* dataType) {
    if (strcmp(dataType, "int")==0)
        return 2;
    else if (strcmp(dataType, "float") == 0)
        return 3;
    else if (strcmp(dataType, "string") == 0)
        return 4;
    else if (strcmp(dataType, "char") == 0)
        return 5;
     else if (strcmp(dataType,"bool")==0)
          return 6;
    else
        return -1;
}
%}
%union {
     char* data_type;
     char* new_type;
     char* nume_variabila;
     int num_val;
     float float_val;
     int arr[25];
}
%token  BGIN END ASSIGN  CLASS_ACCESS PUBLIC PRIVATE CONSTANT BGIN_CLASS END_CLASS BGIN_VARS END_VARS BGIN_FNC END_FNC IF WHILE FOR EQUAL LE GE LT GT NEQUAL EVAL TYPEOF
%token ADV FAKE CUVANT LBRACKET RBRACKET AND OR LITERA RETURN NIMIC INIT INIT_CALL
%token <data_type> INT FLOAT CHAR STRING BOOL
%token <new_type> CLASS
%token <num_val> NR
%token <float_val> NR_ZECIMAL

%token <nume_variabila> ID_VAR ID_CLASA ID_FUNC
%left '+' '-'
%left '*' ':'
%left AND OR


%start progr
%type <data_type> tip_data
%type <new_type> tip_clasa
%type <num_val> expresie_aritmetica
%type <num_val> value
%type <arr> call_list
%type <num_val> possible_param
/* %type <nume_variabila> clasa */
%%
tip_data
          : INT {comma_decl_type=$1;}
          | FLOAT {comma_decl_type=$1;}
          | STRING {comma_decl_type=$1;}
          | BOOL {comma_decl_type=$1;}
          | CHAR {comma_decl_type=$1;}
     	;

tip_clasa : CLASS
          ;
progr: class_declarations_full {scope="class";} var_declarations_full {scope="global";} {scope = "global";} func_declarations_full block{scope = "main";} {printf("The programme is correct!\n");}
     ;

//TODO: Sectiune pentru declarare clase

class_declarations_full : BGIN_CLASS class_declarations END_CLASS
                        ;

var_declarations_full   : BGIN_VARS var_declarations END_VARS
                        ;

func_declarations_full : BGIN_FNC func_declarations END_FNC
                       ;  

class_declarations : cl_decl
                   | class_declarations cl_decl
                   ;

cl_decl            : tip_clasa ID_CLASA {scope=$2; classes.addClass(scope.c_str());} '{' clasa_content class_constructor '}' ';'
                   ;     


class_constructor : INIT ':' INIT_CALL ';' | //epsilon;

clasa_content       : clasa_camp ';'
                    | clasa_content clasa_camp ';'
                    ;

clasa_camp : tip_data id_list
          | PUBLIC tip_data ID_VAR {
               classes.addMember(scope.c_str(),$2,$3);
               classes.modifyMemberVisibility(scope.c_str(),$3,"Public");
          }
          | PRIVATE tip_data ID_VAR{
               classes.addMember(scope.c_str(),$2,$3);
               classes.modifyMemberVisibility(scope.c_str(),$3,"Private");
          }
          | PUBLIC tip_data ID_FUNC '(' list_param ')'
          | PRIVATE tip_data ID_FUNC '(' list_param ')'
          | CONSTANT tip_data ID_VAR{
               classes.addMember(scope.c_str(),$2,$3);
               classes.modifyMemberConstancy(scope.c_str(),$3,"Yes");
          }
          | arr_declaration_clasa
          | func_decl
          ;


arr_declaration_clasa :  tip_data ID_VAR LBRACKET NR RBRACKET{
     snprintf(buffer,256,"*%s",$2);
     classes.addMember(scope.c_str(),$1,buffer);
};

//TODO: Sectiune pentru declarare clase


//TODO: Sectiune pentru declarare variabile
var_declarations :  decl ';'          
	      |  var_declarations decl ';'   
	      ;

decl       :  tip_data id_list
           | decl_var_constant            
           | arr_declaration_global
           | ID_CLASA ASSIGN INIT ID_CLASA{
               ids.copyVariables(classes,$4,$1);
           }
           ;

id_list : id_member
        | id_list ',' id_member
        ;

id_member : ID_VAR{
      if(!ids.existsVar($1)){
          if(scope.at(0)!='@'){
               ids.addVar(comma_decl_type.c_str(),$1);
               ids.changeScope($1,"global");
          }
          else if(scope.at(0)=='@'){
               classes.addMember(scope.c_str(),comma_decl_type.c_str(),$1);
          }
          // ids.changeVisibility($1,scope.c_str());
     }
     else errors.throwVarAlreadyDeclared(yylineno);
}
          | ID_VAR ASSIGN value{
           if(!ids.existsVar($1)){
               ids.addVar(comma_decl_type.c_str(),$1);
               ids.changeScope($1,"global");
               // ids.changeVisibility($1,"global");
               // ids.modifyValue($3,$1); Nu merge
          }    
          else errors.throwVarAlreadyDeclared(yylineno);
     }

arr_declaration_global : tip_data ID_VAR LBRACKET NR RBRACKET{
     snprintf(buffer,512,"*%s",$2);
     ids.addVar($1,buffer);
     ids.changeScope(buffer,"global");
};

decl_var_constant : CONSTANT tip_data ID_VAR { if(!ids.existsVar($3)) {
                          ids.addVar($2,$3);
                          ids.changeScope($3,"global");
                          ids.changeConst($3,"Yes");
                     }
                    else errors.throwVarAlreadyDeclared(yylineno);
                    } ;



func_declarations : func_decl ';'
                  | func_declarations func_decl ';'  
                  ;


func_decl : tip_data ID_FUNC '(' list_param ')' {if(scope.at(0)!='@') scope=$2;} func_block{
     if(!fds.existsFunc($2)){
          fds.addFunc($1,$2);
          // printf("Adaugat functie cu numele %s\n",$2);
          if(scope.at(0)=='@')
               fds.functions.back().changeScope(scope);
          else fds.functions.back().changeScope("global");
          for(int i=0;i<param_index;i++)
               fds.functions.back().addParameter(func_param_type[i],func_param_name[i]);     
          param_index=0;
     }
     else{
          // errors.throwFuncAlreadyDeclared(yylineno);
          // if(scope!=fds.getScope($2)){
          //      fds.addFunc($1,$2);
          //      fds.functions.back().changeScope(scope);
          // }    
          errors.throwFuncAlreadyDeclared(yylineno);
     } 
}
          | tip_data ID_FUNC '(' ')' {if(scope.at(0)!='@') scope=$2;} func_block{
               if(!fds.existsFunc($2)){
                    fds.addFunc($1,$2);
               }
               else errors.throwFuncAlreadyDeclared(yylineno);
          }
          ; 

list_param : param
            | list_param ','  param 
            ;
            
param : tip_data ID_VAR{
     strcpy(func_param_type[param_index],$1);
     strcpy(func_param_name[param_index++],$2);
}
      ; 
      
func_block : '{' func_continut '}'
           | '{' func_continut  func_return ';' '}'
           | '{' func_return ';' '}'
           ;

func_continut: func_line ';'
             | func_continut func_line ';'  
             ;

func_line : statement2 | func_var_decl ;

func_var_decl : tip_data ID_VAR
              | CONSTANT tip_data ID_VAR{
                    if(ids.existsVar($3)) errors.throwVarAlreadyDeclared(yylineno);
              }
              | arr_declaration_func 
              ;  

arr_declaration_func :  tip_data ID_VAR LBRACKET NR RBRACKET{
     snprintf(buffer,256,"*%s",$2);
     if(ids.existsVar(buffer)) errors.throwVarAlreadyDeclared(yylineno);
     
};

func_return : RETURN ID_VAR | RETURN NR | RETURN CUVANT | RETURN NIMIC | RETURN NR_ZECIMAL ;

block : BGIN list END  
     ;
     

list :  statement ';' 
     | list statement ';'
     ;

statement : statement2
          | '(' statement2 ')'
          ;

statement2: asignare
         | ID_FUNC '(' call_list ')'{
               if(fds.verifyParams($1,$3,call_param_index)==0)
                    errors.throwFailedParams(yylineno);
               call_param_index=0;
         }
         | ID_FUNC '(' ')'
         | if_statement
         | for_statement
         | while_statement
         | eval_statement
         | typeof_statement
         ;

eval_statement: EVAL '(' expresie_aritmetica ')' //expresie_aritmetica
              | EVAL '(' boolean_value ')' 
              | EVAL '(' ID_CLASA CLASS_ACCESS ID_VAR ')'{
                snprintf(buffer,512,"%s->%s",$3,$5);
               if(!ids.existsVar(buffer)) errors.throwNoVar(yylineno);
               }
              ;
              
typeof_statement : TYPEOF '(' ID_CLASA CLASS_ACCESS ID_VAR ')'{
                    snprintf(buffer,1024,"%s->%s",$3,$5);
                    if(!ids.existsVar(buffer)) errors.throwNoVar(yylineno);
                    else printf("Tipul variabilei %s este: %s\n",buffer,ids.getVarType(buffer));
                 } 
                 | TYPEOF '(' expresie_aritmetica ')'{
                    if($3==2) printf("Expresia de la linia %d e de tip int\n",yylineno);
                    if($3==3) printf("Expresia de la linia %d e de tip float\n",yylineno);
                    if($3==4) printf("Expresia de la linia %d e de tip string\n",yylineno);
                    if($3==5) printf("Expresia de la linia %d e de tip char\n",yylineno);
                 }
                 | TYPEOF '(' boolean_value ')'{
                    printf("Expresia de la linia %d e de tip bool\n",yylineno);
                 }
                 ;

asignare : ID_VAR ASSIGN expresie_aritmetica {
          if(!ids.existsVar($1)) errors.throwNoVar(yylineno);
          else if($3!=getTypeCode(ids.getVarType($1))) errors.throwTypeConflict(yylineno);
         }  		 
         | ID_CLASA CLASS_ACCESS ID_VAR ASSIGN expresie_aritmetica {
               snprintf(buffer,1024,"%s->%s",$1,$3);
               if(!ids.existsVar(buffer)) errors.throwNoVar(yylineno);
         }
         | ID_VAR ASSIGN boolean_value{
          if(!ids.existsVar($1)) errors.throwNoVar(yylineno);
          if(strcmp(ids.getVarType($1),"bool")!=0) errors.throwTypeConflict(yylineno);
         }
         | ID_CLASA CLASS_ACCESS ID_VAR ASSIGN boolean_value{
          snprintf(buffer,1024,"%s->%s",$1,$3);
          if(!ids.existsVar(buffer)) errors.throwNoVar(yylineno);
          if(strcmp(ids.getVarType(buffer),"bool")) errors.throwTypeConflict(yylineno);
         }
         | ID_VAR ASSIGN CUVANT
         | ID_VAR ASSIGN LITERA
         | ID_VAR LBRACKET NR RBRACKET ASSIGN expresie_aritmetica
         ;


boolean_value : conditie
              | boolean_value AND boolean_value
              | boolean_value OR boolean_value
              | '(' boolean_value ')'
              ;

expresie_aritmetica:  ID_VAR {
          if(!ids.existsVar($1)){
               errors.throwNoVar(yylineno);
          }
          else{
               if(strcmp(ids.getVarType($1),"int")==0) $$=2;
               else if(strcmp(ids.getVarType($1),"float")==0) $$=3;
               else if(strcmp(ids.getVarType($1),"string")==0) $$=4;   
               else if(strcmp(ids.getVarType($1),"char")==0) $$=5;   
          }
}
        | NR {
          $$=2;
        }
        | NR_ZECIMAL {
          // strcpy($$,"float");
          $$=3;
        }
        | STRING {
          // strcpy($$,"string");
          $$=4;
        }
        | CHAR {
          // strcpy($$,"char");
          $$=5;
        }
        | expresie_aritmetica '+' expresie_aritmetica {
               if($1!=$3){
                    errors.throwTypeConflict(yylineno);
               }
               if($1==$3){
                    if($1==4) errors.throwAddStrings(yylineno);
                    else if($1==6) errors.throwAddBools(yylineno);
               } 
          }
        | expresie_aritmetica '-' expresie_aritmetica {
               if($1!=$3){
                    errors.throwTypeConflict(yylineno);
               }
        }
        | expresie_aritmetica '*' expresie_aritmetica {
               if($1!=$3){
                    errors.throwTypeConflict(yylineno);
               }
        }
        | expresie_aritmetica ':' expresie_aritmetica {
               if($1!=$3){
                    errors.throwTypeConflict(yylineno);
               }
        } 
        | '(' expresie_aritmetica ')' {$$=$2;}
        | ID_FUNC '(' call_list ')'{
          if(!fds.existsFunc($1)) errors.throwNoFunc(yylineno);
          $$=getTypeCode(fds.getFuncType($1));
          if(fds.verifyParams($1,$3,call_param_index)==0)
               errors.throwFailedParams(yylineno);
          call_param_index=0;
        }
        | ID_CLASA CLASS_ACCESS ID_VAR{
          snprintf(buffer,512,"%s->%s",$1,$3);
          if(!ids.existsVar(buffer)) errors.throwNoVar(yylineno);
          else{
               $$=getTypeCode(ids.getVarType(buffer));
          }
        }
        | ID_VAR LBRACKET NR RBRACKET{
          snprintf(buffer,512,"*%s",$1);
          if(!ids.existsVar(buffer)) errors.throwNoVar(yylineno);
          else $$=getTypeCode(ids.getVarType(buffer));
        }
        | ID_FUNC '(' ')'{
          if(!fds.existsFunc($1)) errors.throwNoFunc(yylineno);
          $$=getTypeCode(fds.getFuncType($1));
        }
        //TODO - De luat valorile si calculat expresii
        ;  


while_statement : WHILE '(' conditie ')' '{' continut '}'
                ;

for_statement : FOR '(' asignare ';' conditie ';' asignare ')' '{' continut '}' //inlocuire cea de a doua asignare cu o expresie_aritmetica aritmetica
              ;


if_statement: IF '(' pre_conditie ')' '{' continut '}'
            ;  

continut : statement ';'
         | continut statement ';' 
         ;            

pre_conditie : conditie
             | '(' conditie ')'
             ;  

conditie : expresie_aritmetica EQUAL expresie_aritmetica{
               if($1!=$3)
                    errors.throwTypeConflict(yylineno);
         }
         | expresie_aritmetica NEQUAL expresie_aritmetica{
               if($1!=$3)
                    errors.throwTypeConflict(yylineno);
         }
         | expresie_aritmetica GT expresie_aritmetica{
               if($1!=$3)
                    errors.throwTypeConflict(yylineno);
         }
         | expresie_aritmetica LT expresie_aritmetica{
               if($1!=$3)
                    errors.throwTypeConflict(yylineno);
         }
         | expresie_aritmetica GE expresie_aritmetica{
               if($1!=$3)
                    errors.throwTypeConflict(yylineno);
         }
         | expresie_aritmetica LE expresie_aritmetica{
               if($1!=$3)
                    errors.throwTypeConflict(yylineno);
         }
         | ADV | FAKE
         ;




value : NR  {$$=2;}
      | NR_ZECIMAL {$$=3;} 
      | LITERA {$$=5;}
      | CUVANT {$$=4;}
      | ADV {$$=6;}
      | FAKE {$$=6;}
      ; 

call_list : possible_param {$$[call_param_index++]=$1;}
          | call_list ',' possible_param {$$[call_param_index++]=$3;}
          ;

possible_param : NR {$$=2;}
               | ID_VAR {
                    if(!ids.existsVar($1)) errors.throwNoVar(yylineno);
                    else $$=getTypeCode(ids.getVarType($1));
               }
               | ID_FUNC {
                    if(!fds.existsFunc($1)) errors.throwNoFunc(yylineno);
                    else $$=getTypeCode(fds.getFuncType($1));
               }
               | NR_ZECIMAL {$$=3;}
               | CUVANT {$$=4;}
               | LITERA {$$=5;}
               | ADV {$$=6;}
               | FAKE {$$=6;}
               ;

//TODO: Sectiunea programului efectiv
%%
void yyerror(const char * s){
printf("error: %s at line:%d\n",s,yylineno);
}

int main(int argc, char** argv){
     yyin=fopen(argv[1],"r");
     yyparse();
     cout << "Variables can be found in file 'vars.txt', and functions can be found in 'funcs.txt'!" <<endl;
     ids.printVars();
     fds.printFuncs();
     /* classes.printProgress(); */
} 