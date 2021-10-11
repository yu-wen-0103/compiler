lexer grammar mylexer;

options {
	language = Java;
}


/*basic*/
MAIN : 'main';
RETURN : 'return';
INCLUDE : '#include';
LIB : (LETTER)+'.h';
DEFINE : '#define';

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
ARR : '['(.)*']';
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

/*comments*/
COMMENT1 : '//'(.)*'\n';
COMMENT2 : '/*' (options{greedy=flase;}: .)* '*/';

NEW_LINE : '\n';
UB : '(';
DB : ')';
UBR : '{';
DBR : '}';
SEMICOLON : ';';
COMMA : ',';

fragment LETTER : 'a'..'z' | 'A'..'Z' | '_';
fragment DIGIT : '0'..'9';

WS : (' ' | '\r' | '\t' )+ {skip();};





