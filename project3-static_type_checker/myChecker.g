grammar myChecker;

options{
	language = Java;
}

@header{
	import java.util.HashMap;
}

@members{
	boolean TRACEON = false;
    boolean condition = true;
    HashMap<String,Integer> symtab = new HashMap<String,Integer>();
    HashMap<String,Integer> lintab = new HashMap<String,Integer>();
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

declarations
@init{int id_line;}
	: type {
        //System.out.println("type: " + $type.attr_type);
        if($type.attr_type == -2){
            System.out.println("Error: " + $type.start.getLine() + ": The name of type is not legal.");
        }
    } ID ';' declarations {
            if (symtab.containsKey($ID.text)) {
                id_line = lintab.get($ID.text);
                System.out.println("Error: " + id_line + ": Redeclared identifier.");
                lintab.put($ID.text, $ID.getLine());
            } else {
                symtab.put($ID.text, $type.attr_type);	 
                lintab.put($ID.text, $ID.getLine());  
            }
            if (TRACEON) System.out.println("declarations: type ID SEMICOLON : declarations");}
	| {if (TRACEON) System.out.println("declarations: ");}
	;
/* 
declaration_statement returns [int attr_type, string id_num]
	: ((ID)=>a = ID (ARR)* {
            id_num.append($a.text);
        }
      | (MU_OP)* b =ID){
            id_num = $b.text;
        }
      (GV_OP (e = signExpr {
            if($e.attr_type != $type_num){
                System.out.println("Error: " + $e.start.getLine() + ": Redeclared identifier.");
                $attr_type = -2;
            }
        }
      | malloc_statement))? {if (TRACEON) System.out.println("declaration_statement: ID = vallue or ID or array or pointer");}
	| COMMA ((ID)=>c = ID (ARR)* {
            if(symtab.containsKey($c.text)){
                System.out.println("Error: " + $c.getLine() + ": Redeclared identifier.");
                $attr_type = -2;
            }
            else{
                symtab.put($c.text, $type_num);
            }
        }
      | (MU_OP)* d = ID){
            if(symtab.containsKey($d.text)){
                System.out.println("Error: " + $d.getLine() + ": Redeclared identifier.");
                $attr_type = -2;
            }
            else{
                symtab.put($d.text, $type_num);
            }
        }
      (GV_OP (f = signExpr {
            if($f.attr_type != $type_num){
                System.out.println("Error: " + $f.start.getLine() + ": Redeclared identifier.");
                $attr_type = -2;
            }
        }
      | malloc_statement))? {if (TRACEON) System.out.println("declaration_statement: , ID = value or , ID or array or pointer");}
	;

malloc_statement:
	MALLOC UB SIZ UB type DB MU_OP ID DB {if (TRACEON) System.out.println("malloc_statement: ");}
	;
*/
type returns [int attr_type]
	: (INT_TYPE)=>INT_TYPE {if (TRACEON) System.out.println("type: INT"); $attr_type = 1;}
	| (FLOART_TYPE)=>FLOART_TYPE {if (TRACEON) System.out.println("type: FLOAT"); $attr_type = 2;}
	| (CHAR_TYPE)=>CHAR_TYPE {if (TRACEON) System.out.println("type: char"); $attr_type = 3;}
	| (VOID_TYPE)=>VOID_TYPE {if (TRACEON) System.out.println("type: void"); $attr_type = 4;}
	| (DOUBLE_TYPE)=>DOUBLE_TYPE {if (TRACEON) System.out.println("type: double"); $attr_type = 5;}
	| (LL_INT_TYPE)=>LL_INT_TYPE {if (TRACEON) System.out.println("type: long long"); $attr_type = 6;}
	| (LON_INT_TYPE)=>LON_INT_TYPE {if (TRACEON) System.out.println("type: long"); $attr_type = 7;}
	| (SOR_INT_TYPE)=> SOR_INT_TYPE {if (TRACEON) System.out.println("type: short"); $attr_type = 8;}
	| (UN_TYPE)=>UN_TYPE {if (TRACEON) System.out.println("type: unsigned"); $attr_type = 9;}
	| (SI_TYPE)=>SI_TYPE {if (TRACEON) System.out.println("type: signed"); $attr_type = 10;}
	//| (INT_TYPE | CHAR_TYPE | VOID_TYPE | FLOART_TYPE | DOUBLE_TYPE | LL_INT_TYPE | LON_INT_TYPE |SOR_INT_TYPE | UN_TYPE | SI_TYPE) ( MU_OP | DOU_MU_OP) {if (TRACEON) System.out.println("type: pointer");}
	|{$attr_type = -2;}
    ; 

return_statement:
	RETURN DEC_NUM SEMICOLON {if (TRACEON) System.out.println("return_statement: return NUM");}
	| {if (TRACEON) System.out.println("return_statement: ");}
	;

statements:
	statement statements {if (TRACEON) System.out.println("statements: statement statements");}
	| {if (TRACEON) System.out.println("statement: ");}
	;

statement returns [int attr_type]
	//arith_expression op_statements  (arith_expression | malloc_statement)? SEMICOLON {if (TRACEON) System.out.println("statement: ID = arith_expression;");}//+-*/ compute
    : a = arith_expression op_statements  (b = arith_expression )? SEMICOLON {     
        if (($a.attr_type != $b.attr_type) && $a.attr_type != 0) {
            System.out.println("Error: " + $a.start.getLine() + ": Type mismatch for the two silde operands in an assignment statement.");
            $attr_type = -2;
            }
        }
    | IF UB c = loop_judge q = op_statements d = loop_judge {   
            if($c.attr_type != $d.attr_type){
                System.out.println("Error: " + $c.start.getLine() + ": Type mismatch for the two silde operands in an comparison statement.");
                System.out.println("Error: " + $c.start.getLine() + ": The return in if-loop condition is not boolean.");
            }
            if($q.op == 9 || $q.op == 10 || $q.op == 11 || $q.op == 12 || $q.op == 13 || $q.op == 16){
            }
            else{
                System.out.println("Error: " + $c.start.getLine() + ": The return in if-loop condition is not boolean.");
            }
            //System.out.println($c.num + " " + $d.num + " " + $q.op);
        } DB loop_statements  {if (TRACEON) System.out.println("statement: if(arith_expression){if_then_statements}");}  //if then
	| ELSE loop_statements {if (TRACEON) System.out.println("statements: else{else_statements}");}
	| WHILE UB e = loop_judge (r = op_statements f = loop_judge)* {
            if($e.attr_type != $f.attr_type){
                System.out.println("Error: " + $e.start.getLine() + ": Type mismatch for the two silde operands in an comparison statement.");
                System.out.println("Error: " + $e.start.getLine() + ": The return in while-loop condition is not boolean.");
            }
            if( $r.op == 9 || $r.op == 10 || $r.op == 11 || $r.op == 12 || $r.op == 13 || $r.op == 16){
            }
            else{
                System.out.println("Error: " + $e.start.getLine() + ": The return in while-loop condition is not boolean.");
            }
        } DB loop_statements  {if (TRACEON) System.out.println("statement: while(arith_expression){while_loop_statements}");}  //while loop
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

loop_judge returns [int attr_type, int num]
	: NOT_OP q = signExpr {
        $attr_type = $q.attr_type;
        $num = $q.num;
        if (TRACEON) System.out.println("loop_judge: ");}
	| z = signExpr {
        $attr_type = $z.attr_type;
        $num = $z.num;
        if (TRACEON) System.out.println("loop_judge: pointer");}
	;

for_loop_judge:
	statement a = signExpr s = op_statements c = arith_expression{
            if($a.attr_type != $c.attr_type){
                System.out.println("Error: " + $a.start.getLine() + ": Type mismatch for the two silde operands in an comparison statement.");
            }
            if($s.op != 9 && $s.op != 10 && $s.op != 11 && $s.op != 12 && $s.op != 13 && $s.op != 16){

                System.out.println("Error: " + $s.start.getLine() + ": The return in for-loop condition is not boolean.");
            }
        } SEMICOLON (t = op_statements)* v = signExpr {
            if($a.attr_type != $v.attr_type){
                System.out.println("Error: " + $a.start.getLine() + ": Type mismatch for the for-loop.");
            }
        }(g = op_statements)* {
            
            //System.out.println("t: " + $t.op + "g: " + $g.op);
            if($g.op != 0 && $g.op != 1 && $g.op != 2 && $t.op !=0 && $t.op !=1 && $t.op!=2){
                System.out.println("Error: " + $t.start.getLine() + ": Operator mismatch for the for-loop.");
            }
            else if(($g.op == 1 ||$g.op == 2) &&( $t.op ==1 || $t.op==2)){
                System.out.println("Error: " + $t.start.getLine() + ": The return in for-loop condition is not boolean.");
            }
        
            if (TRACEON) System.out.println("for_loop_judge: ");
        } 
	;

loop_statements:
	statement {if (TRACEON) System.out.println("loop_statements: statement");}
	| UBR statements DBR {if (TRACEON) System.out.println("loop_statements:  {statements}");}
	;

op_statements returns [int op]
	: PP_OP {$op = 1;} | MM_OP {
        $op = 2;} | GV_OP {
        $op = 3;} | GA_OP {
        $op = 4;} | GMI_OP {
        $op = 5;} | GMU_OP {
        $op = 6;} | GD_OP {
        $op = 7;} | GMO_OP {
        $op = 8;} | EQ_OP {
        $op = 9;} | LE_OP {
        $op = 10;} | GE_OP{
        $op = 11;}  | NE_OP {
        $op = 12;} | LT_OP {
        //System.out.println("LT: " + $LT_OP.text);
        $op = 13;} | MT_OP {
            //System.out.println("MT: " + $MT_OP.text);
            $op = 16;} | AND_OP {
        $op = 14;} | OR_OP {
        $op = 15;}  {
        if (TRACEON) System.out.println("op_statements: ");}
    ;

print_scanf_statements: 
	STRING (COMMA (arith_expression (ARR)* | (AD_OP)=>AD_OP ID ))*  {if (TRACEON) System.out.println("print_scanf_statements: ");}
	;

arith_expression returns [int attr_type, int num]
	: a = multExpr {
            $attr_type = $a.attr_type;
            $num = $a.num;
        } 
      ( PL_OP b = multExpr {
            if($a.attr_type != $b.attr_type){
                System.out.println("Error: " + $a.start.getLine() + ": Type mismatch for the operator + in an expression.");
                $attr_type = -2;
            }
            else{$num = $b.num;}
        }
      | MI_OP c = multExpr {
            if($a.attr_type != $c.attr_type){
                System.out.println("Error: " + $a.start.getLine() + ": Type mismatch for the operator - in an expression.");
                $attr_type = -2;
            }
            else{$num = $c.num;}
        }
      | MOD_OP d = multExpr{
            if($a.attr_type != $d.attr_type){
                System.out.println("Error: " + $a.start.getLine() + ": Type mismatch for the operator  in an expression.");
                $attr_type = -2;
            }
            else{$num = $d.num;}
        }
      )*{
            if (TRACEON) System.out.println("arith_expression: ");
        }
	| MU_OP primaryExpr {
            if(symtab.containsKey($primaryExpr.text)){
                $attr_type = symtab.get($primaryExpr.text);
                $num = $a.num;
            }
            else{
                System.out.println("Error: " + $primaryExpr.start.getLine() + ": Undeclared identifier.");
                $attr_type = 0;
            }
            if (TRACEON) System.out.println("arith_expression: pointer");}
	;

multExpr returns [int attr_type, int num]
	: a = signExpr {
            $attr_type = $a.attr_type;
            $num = $a.num;
        }
      ( MU_OP b = signExpr{
            if($a.attr_type != $b.attr_type){
                System.out.println("Error: " + $a.start.getLine() + ": Type mismatch for the operator * in an expression.");
                $attr_type = -2;
            }
            else{$num = $b.num;}
        }
      | DI_OP c = signExpr {
            if($a.attr_type != $c.attr_type){
                System.out.println("Error: " + $a.start.getLine() + ": Type mismatch for the operator / in an expression.");
                $attr_type = -2;
            }
            else{$num = $c.num;}
        }
      )* {if (TRACEON) System.out.println("multExpr: ");}
	;

signExpr returns [int attr_type, int num]
	: a = primaryExpr {
            $attr_type = $a.attr_type;
            $num = $a.num;
            if (TRACEON) System.out.println("signExpr: primaryExpr");
        }
	| MI_OP b = primaryExpr {
            $attr_type = $b.attr_type;
            $num = $b.num;
            if (TRACEON) System.out.println("signExpr: -primaryExpr");
        }
	;

primaryExpr returns [int attr_type, int num]
	: DEC_NUM {
            $attr_type = 1;
            //System.out.println("DEC: " + $);
            $num = Integer.parseInt($DEC_NUM.text);
            if (TRACEON) System.out.println("primaryExpr: number");}
	| FLOAT_NUM {
            $attr_type = 2;
            if (TRACEON) System.out.println("primaryExpr: float number");}
	| ID {
            if(symtab.containsKey($ID.text)){
               $attr_type = symtab.get($ID.text); 
            }
            else{
                System.out.println("Error: " + $ID.getLine() + ": Undeclared identifier.");
                $attr_type = 0;
            }
            
            if (TRACEON) System.out.println("primaryExpr: ID");}
	| UB arith_expression DB {
            $attr_type = $arith_expression.attr_type;
            if (TRACEON) System.out.println("primaryExpr: (arith_expression)");}
	| SINGLE {
            $attr_type = 3;
            if (TRACEON) System.out.println("primaryExpr: 'char'");}
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


