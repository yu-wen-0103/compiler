grammar myparser;

options{
	language = Java;
}

@header{
	//	
}

@members{
	boolean TRACEON = true;
}

program :
	(include_declarations)*  (define_declarations)* ('int' | 'void') MAIN UB main_para DB UBR declarations statements return_statement DBR {if (TRACEON) System.out.println("declarations statements");}
	| EOF
	;

include_declarations:
	(INCLUDE) => INCLUDE LT_OP LIB MT_OP {if (TRACEON) System.out.println("include_declarations: ");}
	;

define_declarations:
	(DEFINE) => DEFINE signExpr signExpr {if (TRACEON) System.out.println("define_declarations: ");}
	;

main_para:
	INT_TYPE ARGC COMMA CHAR_TYPE (DOU_MU_OP  ARGV | MU_OP ARGV ARR | ARGV ARR ARR) {if (TRACEON) System.out.println("main_para: argc, argv");}
	| {if (TRACEON) System.out.println("main_para: ");}
	;

declarations :
	(type (declaration_statement)+ SEMICOLON )+ {if (TRACEON) System.out.println("declarations: type ID SEMICOLON : declarations");}
	| {if (TRACEON) System.out.println("declarations: ");}
	;

declaration_statement:
	((ID)=>ID (ARR)* | (MU_OP)* ID) (GV_OP (signExpr | malloc_statement))? {if (TRACEON) System.out.println("declaration_statement: ID = vallue or ID or array or pointer");}
	| COMMA ((ID)=>ID (ARR)* | (MU_OP)* ID) (GV_OP (signExpr | malloc_statement))? {if (TRACEON) System.out.println("declaration_statement: , ID = value or , ID or array or pointer");}
	;

malloc_statement:
	MALLOC UB SIZ UB type DB MU_OP ID DB {if (TRACEON) System.out.println("malloc_statement: ");}
	;

type :
	(INT_TYPE)=>INT_TYPE {if (TRACEON) System.out.println("type: INT");}
	| (FLOART_TYPE)=>FLOART_TYPE {if (TRACEON) System.out.println("type: FLOAT");}
	| (CHAR_TYPE)=>CHAR_TYPE {if (TRACEON) System.out.println("type: char");}
	| (VOID_TYPE)=>VOID_TYPE {if (TRACEON) System.out.println("type: void");}
	| (DOUBLE_TYPE)=>DOUBLE_TYPE {if (TRACEON) System.out.println("type: double");}
	| (LL_INT_TYPE)=>LL_INT_TYPE {if (TRACEON) System.out.println("type: long long");}
	| (LON_INT_TYPE)=>LON_INT_TYPE {if (TRACEON) System.out.println("type: long");}
	| (SOR_INT_TYPE)=> SOR_INT_TYPE {if (TRACEON) System.out.println("type: short");}
	| (UN_TYPE)=>UN_TYPE {if (TRACEON) System.out.println("type: unsigned");}
	| (SI_TYPE)=>SI_TYPE {if (TRACEON) System.out.println("type: signed");}
	//| (INT_TYPE | CHAR_TYPE | VOID_TYPE | FLOART_TYPE | DOUBLE_TYPE | LL_INT_TYPE | LON_INT_TYPE |SOR_INT_TYPE | UN_TYPE | SI_TYPE) ( MU_OP | DOU_MU_OP) {if (TRACEON) System.out.println("type: pointer");}
	; 

return_statement:
	RETURN DEC_NUM SEMICOLON {if (TRACEON) System.out.println("return_statement: return NUM");}
	| {if (TRACEON) System.out.println("return_statement: ");}
	;

statements:
	statement statements {if (TRACEON) System.out.println("statements: statement statements");}
	| {if (TRACEON) System.out.println("statement: ");}
	;

statement:
	arith_expression op_statements  (arith_expression | malloc_statement)? SEMICOLON {if (TRACEON) System.out.println("statement: ID = arith_expression;");}//+-*/ compute
	| IF UB loop_judge ( op_statements loop_judge)*  DB loop_statements  {if (TRACEON) System.out.println("statement: if(arith_expression){if_then_statements}");}  //if then
	| ELSE loop_statements {if (TRACEON) System.out.println("statements: else{else_statements}");}
	| WHILE UB loop_judge ((AND_OP | OR_OP) loop_judge)*  DB loop_statements  {if (TRACEON) System.out.println("statement: while(arith_expression){while_loop_statements}");}  //while loop
	| FOR UB for_loop_judge DB loop_statements {if (TRACEON) System.out.println("statement: for(for_loop_judge):{for_loop_statements}");}  //for loop
	| (PRINT | SCANF) UB print_scanf_statements DB SEMICOLON {if (TRACEON) System.out.println("statement: printf(print_scanf_statements); or scanf(print_scanf_statements)");}  //print function
	| FREE UB ID DB SEMICOLON {if (TRACEON) System.out.println("statement: free(ID)");} //free 
	| SWITCH UB ID DB UBR switch_statements DBR  {if (TRACEON) System.out.println("statement: switch(ID){switch_statements}");} //switch
	//| declaration_statement SEMICOLON {if (TRACEON) System.out.println("statement: malloc");} //malloc
	;

switch_statements:
	CASE (SINGLE | STRING) ':' statements (BRK SEMICOLON)? switch_statements {if (TRACEON) System.out.println("switch_statements: case");}
	| DEFAULT ':' statements (BRK SEMICOLON)? {if (TRACEON) System.out.println("switch_statements: default");}
	;

loop_judge:
	NOT_OP arith_expression {if (TRACEON) System.out.println("loop_judge: ");}
	| arith_expression {if (TRACEON) System.out.println("loop_judge: pointer");}
	;

for_loop_judge:
	statement signExpr op_statements arith_expression SEMICOLON (op_statements)* signExpr (op_statements)* {if (TRACEON) System.out.println("for_loop_judge: ");}
	;

loop_statements:
	statement {if (TRACEON) System.out.println("loop_statements: statement");}
	| UBR statements DBR {if (TRACEON) System.out.println("loop_statements:  {statements}");}
	;

op_statements:
	PP_OP | MM_OP | GV_OP | GA_OP| GMI_OP | GMU_OP | GD_OP | GMO_OP | EQ_OP | LE_OP | GE_OP | NE_OP | LT_OP | MT_OP | AND_OP | OR_OP  {if (TRACEON) System.out.println("op_statements: ");}
	;

print_scanf_statements: 
	STRING (COMMA (arith_expression (ARR)* | (AD_OP)=>AD_OP ID ))*  {if (TRACEON) System.out.println("print_scanf_statements: ");}
	;

arith_expression:
	multExpr ( PL_OP multExpr | MI_OP multExpr | MOD_OP multExpr)* {if (TRACEON) System.out.println("arith_expression: ");}
	| MU_OP primaryExpr {if (TRACEON) System.out.println("arith_expression: pointer");}
	;

multExpr:
	signExpr( MU_OP signExpr | DI_OP signExpr )* {if (TRACEON) System.out.println("multExpr: ");}
	;

signExpr:
	primaryExpr {if (TRACEON) System.out.println("signExpr: primaryExpr");}
	| MI_OP primaryExpr {if (TRACEON) System.out.println("signExpr: -primaryExpr");}
	;

primaryExpr:
	DEC_NUM {if (TRACEON) System.out.println("primaryExpr: number");}
	| FLOAT_NUM {if (TRACEON) System.out.println("primaryExpr: float number");}
	| ID {if (TRACEON) System.out.println("primaryExpr: ID");}
	| UB arith_expression DB {if (TRACEON) System.out.println("primaryExpr: (arith_expression)");}
	| SINGLE {if (TRACEON) System.out.println("primaryExpr: 'char'");}
	;

/*basic*/
MAIN : 'main';
RETURN : 'return';
INCLUDE : '#include';
LIB : (LETTER)+'.h';
DEFINE : '#define';
ARGC : 'argc';
ARGV : 'argv';

/*reserved keyword : type*/
INT_TYPE : 'int';
CHAR_TYPE : 'char';
VOID_TYPE : 'void';
FLOART_TYPE : 'float';
DOUBLE_TYPE : 'double';
LL_INT_TYPE : 'long long';
LON_INT_TYPE : 'long';
SOR_INT_TYPE : 'short';
UN_TYPE : 'unsigned';
SI_TYPE : 'signed';
STRUCT_TYPE : 'struct';
UNION_TYPE : 'union';
PTR : '*'+(LETTER)(LETTER | DIGIT)*;
ARR : '['(DEC_NUM)*']';
//2DARR : (ID)'['(DEC_NUM)*']''['(DEC_NUM)*']';
SIZ : 'sizeof';
ENUM : 'enum';
CONST : 'const';
VOL : 'volatile';
TYPE : 'typedef';
AUTO : 'auto';
REG : 'register';
STATIC : 'static';
BOOL : 'bool';
MALLOC : 'malloc';
FREE : 'free';
NULL : 'NULL';
EOF : 'EOF';
TRUE : 'True';
FALSE : 'False';

/*reserved keyword : loop*/
WHILE : 'while';
FOR : 'for';
IF : 'if';
ELSE : 'else';
DO : 'do';
SWITCH : 'switch';
CASE : 'case';
GOTO : 'goto';
CONTI : 'continue';
BRK : 'break';
DEFAULT : 'default';
PRINT : 'printf';
SCANF : 'scanf';

/*comments*/
COMMENT1 : '//'(.)*'\n';
COMMENT2 : '/*' (options{greedy=flase;}: .)* '*/';

/*operators*/
EQ_OP : '==';
LE_OP : '<=';
GE_OP : '>=';
NE_OP : '!=';
PP_OP : '++';
MM_OP : '--';
LT_OP : '<';
MT_OP : '>';
GV_OP : '=';
RSHIFT_OP : '<<';
LSHIFT_OP : '>>';
PL_OP : '+';
MI_OP : '-';
MU_OP : '*';
DOU_MU_OP: '**';
DI_OP : '/';
MOD_OP : '%';
AND_OP : '&&';
OR_OP : '||';
NOT_OP : '!';
POW_OP : '^';
GA_OP : '+=';
GMI_OP : '-=';
GMU_OP : '*=';
GD_OP : '/=';
GMO_OP : '%=';
AD_OP : '&';

/*number*/
DEC_NUM : ('0' | ('1'..'9')(DIGIT)*);
FLOAT_NUM : FLOAT_NUM1 | FLOAT_NUM2 | FLOAT_NUM3;

fragment FLOAT_NUM1 : (DIGIT)+ '.'(DIGIT)*;
fragment FLOAT_NUM2 : '.'(DIGIT)+;
fragment FLOAT_NUM3 : (DIGIT)+;

/*string*/
ID : (LETTER)(LETTER | DIGIT)*;
STRING : '"'(.)*'"';
SINGLE : '\''(.)*'\'';


//NEW_LINE : '\n';
UB : '(';
DB : ')';
UBR : '{';
DBR : '}';
SEMICOLON : ';';
COMMA : ',';

fragment LETTER : 'a'..'z' | 'A'..'Z' | '_';
fragment DIGIT : '0'..'9';

WS : (' ' | '\r' | '\t' | '\n' )+ {skip();};


