grammar myCompiler;

options {
   language = Java;
}

@header {
    // import packages here.
    import java.util.HashMap;
    import java.util.ArrayList;
}

@members {
    boolean TRACEON = false;
    boolean isprint = false;

    // Type information.
    public enum Type{
       ERR, BOOL, INT, FLOAT, CHAR, CONST_INT, CONST_FLOAT;
    }

    // This structure is used to record the information of a variable or a constant.
    class tVar {
	   int   varIndex; // temporary variable's index. Ex: t1, t2, ..., etc.
	   int   iValue;   // value of constant integer. Ex: 123.
	   float fValue;   // value of constant floating point. Ex: 2.314.
      char  cValue;
	};

    class Info {
       Type theType;  // type information.
       tVar theVar;
	   
	   Info() {
          theType = Type.ERR;
		  theVar = new tVar();
	   }
    };

	
    // ============================================
    // Create a symbol table.
	// ArrayList is easy to extend to add more info. into symbol table.
	//
	// The structure of symbol table:
	// <variable ID, [Type, [varIndex or iValue, or fValue]]>
	//    - type: the variable type   (please check "enum Type")
	//    - varIndex: the variable's index, ex: t1, t2, ...
	//    - iValue: value of integer constant.
	//    - fValue: value of floating-point constant.
    // ============================================

    HashMap<String, Info> symtab = new HashMap<String, Info>();

    // labelCount is used to represent temporary label.
    // The first index is 0.
    int labelCount = 0;
	
    // varCount is used to represent temporary variables.
    // The first index is 0.
    int varCount = 0;
    int num  = 0;
    int num2 = 0;
    String str1 = "";
    String str2;
    String str3;

    // Record all assembly instructions.
    List<String> TextCode = new ArrayList<String>();


   void print(){
      if(isprint == true){
         //System.out.println("declare dso_local i32 @printf(i8*, ...)\n");
         //System.out.println("@.str = private unnamed_addr constant [" + );
      }
   }

    /*
     * Output prologue.
     */
    void prologue()
    {
       TextCode.add("; === prologue ====");
       //TextCode.add("declare dso_local i32 @printf(i8*, ...)\n");
	   TextCode.add("define dso_local i32 @main()");
	   TextCode.add("{");
    }
    
	
    /*
     * Output epilogue.
     */
    void epilogue()
    {
       /* handle epilogue */
       TextCode.add("\n; === epilogue ===");
	   TextCode.add("ret i32 0");
       TextCode.add("}");
    }
    
    
    /* Generate a new label */
    String newLabel()
    {
       labelCount ++;
       return (new String("L")) + Integer.toString(labelCount);
    } 
    
    
    public List<String> getTextCode()
    {
       return TextCode;
    }
}

program: VOID MAIN '(' ')'
        {
           /* Output function prologue */
           prologue();
        }

        '{' 
           declarations
           statements
        '}'
        {
	   if (TRACEON)
	      System.out.println("VOID MAIN () {declarations statements}");

           /* output function epilogue */	  
           epilogue();
        }
        ;


declarations: type Identifier ';' declarations
        {
           if (TRACEON){
              System.out.println("declarations: type Identifier : declarations");
           }
            if($type.attr_type == Type.ERR){
            System.out.println("Error: " + $type.start.getLine() + ": The name of type is not legal.");
            System.exit(0);
        }
           if (symtab.containsKey($Identifier.text)) {
              // variable re-declared.
              System.out.println("Type Error: " + 
                                  $Identifier.getLine() + 
                                 ": Redeclared identifier.");
              //System.exit(0);
           }
                 
           /* Add ID and its info into the symbol table. */
	       Info the_entry = new Info();
		   the_entry.theType = $type.attr_type;
		   the_entry.theVar.varIndex = varCount;
		   varCount ++;
		   symtab.put($Identifier.text, the_entry);

           // issue the instruction.
		   // Ex: \%a = alloca i32, align 4
           if ($type.attr_type == Type.INT) { 
              TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca i32, align 4");
           }
           else if ($type.attr_type == Type.FLOAT) {
              TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca float, align 4");
           }
           else if ($type.attr_type == Type.CHAR) {
              TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca i8, align 1");
           }
        }
        | 
        {
           if (TRACEON)
              System.out.println("declarations: ");
        }
        ;


type
returns [Type attr_type]
    : INT { if (TRACEON) System.out.println("type: INT"); $attr_type=Type.INT; }
    | CHAR { if (TRACEON) System.out.println("type: CHAR"); $attr_type=Type.CHAR; }
    | FLOAT {if (TRACEON) System.out.println("type: FLOAT"); $attr_type=Type.FLOAT; }
	;


statements:statement statements  {if (TRACEON) System.out.println("statements: statement statements");}
          | {if (TRACEON) System.out.println("statement: ");}
          ;


statement: assign_stmt ';'
         | if_stmt
         | func_no_return_stmt ';'
         | for_stmt
         | print_stmt
         | while_stmt
         ;



print_stmt        
         : PRINTF '(' STRING_LITERAL ((',') => ')'
            {
               String sub_str = $STRING_LITERAL.text.substring(0, $STRING_LITERAL.text.length()-1);
               int len = (sub_str.length() - 1);
               System.out.println("declare dso_local i32 @printf(i8*, ...)\n");
               System.out.println("@.str = private unnamed_addr constant [" + len + " x i8] c" + sub_str + "\\00\"" + ", align 1");
               StringBuilder  str = new StringBuilder("\%t");
               str.append(varCount);
               varCount ++;
               str.append(" = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([");
               str.append(len);
               str.append(" x i8], [");
               str.append(len);
               str.append(" x i8]* @.str, i64 0, i64 0)");
               str.append(")");
               String appendStr = str.toString();
               TextCode.add(appendStr);
            
            }
            | (',' arith_expression ',') => ',' a = arith_expression ',' b = arith_expression ')'
            {
               if($a.theInfo.theType == Type.CHAR){
                  //Info the_entry = new Info();
		            //the_entry.theType = $type.attr_type;
		            //the_entry.theVar.varIndex = varCount;
                  
                  
                  TextCode.add("\%t" + varCount + " = sext i8 \%t" + $a.theInfo.theVar.varIndex + " to i32");
               }
               int a_num  = varCount;
		         varCount ++;
               if($b.theInfo.theType == Type.CHAR){
                  //Info the_entry2 = new Info();
		            //the_entry2.theType = $type.attr_type;
		            //the_entry2.theVar.varIndex = varCount;
                  
                  TextCode.add("\%t" + varCount + " = sext i8 \%t" + $b.theInfo.theVar.varIndex + " to i32");
               }
               int b_num  = varCount; 
		            varCount ++;
               String sub_str = $STRING_LITERAL.text.substring(0, $STRING_LITERAL.text.length()-1);
               int len = (sub_str.length() - 1);
               System.out.println("declare dso_local i32 @printf(i8*, ...)\n");
               System.out.println("@.str = private unnamed_addr constant [" + len + " x i8] c" + sub_str + "\\00\"" + ", align 1");
               StringBuilder  str = new StringBuilder("\%t");
               str.append(varCount);
               varCount ++;
               str.append(" = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([");
               str.append(len);
               str.append(" x i8], [");
               str.append(len);
               str.append(" x i8]* @.str, i64 0, i64 0)");
               str.append(", ");
               if($a.theInfo.theType == Type.INT || $a.theInfo.theType == Type.CHAR){
                  str.append("i32 \%t");
               }
               else if($a.theInfo.theType == Type.FLOAT){
                  str.append("double \%t");
               }
               if($a.theInfo.theType == Type.CHAR){
                  str.append(a_num);
               }
               else{
                  str.append($a.theInfo.theVar.varIndex);
               }
               str.append(", ");
               if($b.theInfo.theType == Type.INT || $b.theInfo.theType == Type.CHAR){
                  str.append("i32 \%t");
               }
               else if($b.theInfo.theType == Type.FLOAT){
                  str.append("double \%t");
               }
               if($b.theInfo.theType == Type.CHAR){
                  str.append(b_num);
               }
               else{
                  str.append($b.theInfo.theVar.varIndex);
               }
               str.append(")");
               String appendStr = str.toString();
               TextCode.add(appendStr);
            }

            | (',' arith_expression ')') =>',' c = arith_expression ')'
            
            {
               if($c.theInfo.theType == Type.CHAR){
                  //Info the_entry = new Info();
		            //the_entry.theType = $type.attr_type;
		            //the_entry.theVar.varIndex = varCount;
                  
                  
                  TextCode.add("\%t" + varCount + " = sext i8 \%t" + $c.theInfo.theVar.varIndex + " to i32");
               }
               int c_num  = varCount;
		         varCount ++;
               String sub_str = $STRING_LITERAL.text.substring(0, $STRING_LITERAL.text.length()-1);
               int len = (sub_str.length() - 1);
               System.out.println("declare dso_local i32 @printf(i8*, ...)\n");
               System.out.println("@.str = private unnamed_addr constant [" + len + " x i8] c" + sub_str + "\\00\"" + ", align 1");
               StringBuilder  str = new StringBuilder("\%t");
               str.append(varCount);
               varCount ++;
               str.append(" = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([");
               str.append(len);
               str.append(" x i8], [");
               str.append(len);
               str.append(" x i8]* @.str, i64 0, i64 0)");
               str.append(", ");
               if($c.theInfo.theType == Type.INT || $c.theInfo.theType == Type.CHAR){
                  str.append("i32 \%t");
               }
               else if($c.theInfo.theType == Type.FLOAT){
                  str.append("double \%t");
               }
               if($c.theInfo.theType == Type.CHAR){
                  str.append(c_num);
               }
               else{
                  str.append($c.theInfo.theVar.varIndex);
               }
               str.append(")");
               String appendStr = str.toString();
               TextCode.add(appendStr);
            } 
            ) ';'
          ;

for_stmt: FOR '(' assign_stmt 
               {
                  TextCode.add("br label \%t" + varCount);
                  TextCode.add("\%t" + varCount + ":");
                  num = varCount;
                  varCount++;
               }
               ';'
                  cond_expression 
                  {
                           
                     if($cond_expression.theInfo.theType != Type.BOOL){
                        System.out.println("Error: " + $cond_expression.start.getLine() + ": The return in if-loop condition is not boolean.");
                        if($cond_expression.theInfo.theType == Type.ERR){
                           System.out.println("Error: " + $cond_expression.start.getLine() + ": Type mismatch for the two silde operands in an comparison statement.");
                        }
                     }else{
                        if (TRACEON) System.out.println("statement: if(arith_expression){if_then_statements}");
                        TextCode.add("br i1 \%t" + $cond_expression.theInfo.theVar.varIndex + ", label \%t" + varCount + ", label \%Lend");
                        TextCode.add("\%t" + varCount + ":");
                        varCount++;
                        num2 = varCount;
                        varCount++;
                     }
            
                  }';'
                  assign_stmt
              ')'
                  block_stmt
                  {
                     TextCode.add("br label \%t" + num2);
                     TextCode.add("\%t" + num2 + ":");
                     //System.out.println("str: " + str1);
                     TextCode.add(str1);
                     TextCode.add(str2);
                     TextCode.add(str3);
                     TextCode.add("br label \%t" + num);
                  }
        ;
		 
while_stmt :WHILE '('
            {
               
               TextCode.add("br label \%comd" + varCount);
               TextCode.add("\%comd" + varCount + ":");
               num = varCount;
               varCount++;
            } 
            cond_expression ')'
            {
               if($cond_expression.theInfo.theType != Type.BOOL){
                  System.out.println("Error: " + $cond_expression.start.getLine() + ": The return in if-loop condition is not boolean.");
                  if($cond_expression.theInfo.theType == Type.ERR){
                     System.out.println("Error: " + $cond_expression.start.getLine() + ": Type mismatch for the two silde operands in an comparison statement.");
                  }
               }else{
                  if (TRACEON) System.out.println("statement: if(arith_expression){if_then_statements}");
                  TextCode.add("br i1 \%t" + $cond_expression.theInfo.theVar.varIndex + ", label \%Ltrue, label \%Lend");
                  TextCode.add("Ltrue:");
               }
            }
            block_stmt
            {
               TextCode.add("br label \%comd" + num);
            }
            ;	

if_stmt
            :if_then_stmt if_else_stmt
            ;

	
if_then_stmt
            : IF '(' cond_expression ')'
            {
               if($cond_expression.theInfo.theType != Type.BOOL){
                  System.out.println("Error: " + $cond_expression.start.getLine() + ": The return in if-loop condition is not boolean.");
                  if($cond_expression.theInfo.theType == Type.ERR){
                     System.out.println("Error: " + $cond_expression.start.getLine() + ": Type mismatch for the two silde operands in an comparison statement.");
                  }
               }else{
                  if (TRACEON) System.out.println("statement: if(arith_expression){if_then_statements}");
                  TextCode.add("br i1 \%t" + $cond_expression.theInfo.theVar.varIndex + ", label \%Ltrue, label \%Lfalse");
                  TextCode.add("Ltrue:");
               }
            }
            block_stmt
            ;


if_else_stmt
            : ELSE 
            {
               if (TRACEON) System.out.println("statements: else{else_statements}");
               TextCode.add("Lfalse:");
            }
            block_stmt
            {
               TextCode.add("br label \%Lend");
            } 
            |
            ;

				  
block_stmt: 
            
            '{' statements '}'
            
	  ;


assign_stmt
returns [Info theInfo]
@init {$theInfo = new Info(); }
            : Identifier ('=' arith_expression
             {
                Info theRHS = $arith_expression.theInfo;
				    Info theLHS = symtab.get($Identifier.text); 
		   
                if ((theLHS.theType == Type.INT) &&
                    (theRHS.theType == Type.INT)) {		   
                   // issue store insruction.
                   // Ex: store i32 \%tx, i32* \%ty
                   TextCode.add("store i32 \%t" + theRHS.theVar.varIndex + ", i32* \%t" + theLHS.theVar.varIndex + ", align 4");
				} else if ((theLHS.theType == Type.INT) &&
				    (theRHS.theType == Type.CONST_INT)) {
                   // issue store insruction.
                   // Ex: store i32 value, i32* \%ty
                   TextCode.add("store i32 " + theRHS.theVar.iValue + ", i32* \%t" + theLHS.theVar.varIndex + ", align 4");				
				} else if((theLHS.theType == Type.FLOAT) &&
                     (theRHS.theType == Type.FLOAT)) {
                     Float ans1 = Float.parseFloat($arith_expression.text);
                     double tmp = ans1.doubleValue();
                     long ans2 = Double.doubleToLongBits(tmp);
                     TextCode.add("store float \%t" + theRHS.theVar.varIndex + ", float* \%t" + theLHS.theVar.varIndex + ", align 4");
                     
            } else if((theLHS.theType == Type.FLOAT) &&
                     (theRHS.theType == Type.CONST_FLOAT)){

                     Float ans = Float.parseFloat($arith_expression.text);
                     double tmp = ans.doubleValue();
                     long ans2 = Double.doubleToLongBits(tmp);
                     TextCode.add("store float 0x" + Long.toHexString(ans2) + ", float* \%t" + theLHS.theVar.varIndex + ", align 4");
            }else if ((theLHS.theType == Type.CHAR) &&
				    (theRHS.theType == Type.CHAR)) {
                   
                     char myChar = theRHS.theVar.cValue;
                   int asciival = (int)myChar;
                   TextCode.add("store i8 " + asciival + ", i8* \%t" + theLHS.theVar.varIndex + ", align 1");				
				}else{
               //System.out.println("Error: " + $arith_expression.start.getLine() + ": Type mismatch for the two silde operands in an assignment statement.");
            }
			 }
          | '++'
          {

                     $theInfo.theType = symtab.get($Identifier.text).theType;
                     int vIndex = symtab.get($Identifier.text).theVar.varIndex;
                     StringBuilder  str_1 = new StringBuilder("\%t");
                     str_1.append(varCount);
                     str_1.append(" = load i32, i32* \%t");
                     str_1.append(vIndex);
                     str_1.append(", align 4");
                     $theInfo.theVar.varIndex = varCount;
                     varCount ++;
                     str1 = str_1.toString();

                     StringBuilder  str_2 = new StringBuilder("\%t");
                     str_2.append(varCount);
                     str_2.append(" = add nsw i32 \%t");
                     str_2.append($theInfo.theVar.varIndex);
                     str_2.append(", 1");
					      $theInfo.theType = Type.INT;
					      $theInfo.theVar.varIndex = varCount;
					      varCount ++;
                     str2 = str_2.toString();

                     StringBuilder  str_3 = new StringBuilder("store i32 \%t");
                     str_3.append($theInfo.theVar.varIndex);
                     str_3.append(", i32* \%t");
                     str_3.append(vIndex);
                     str_3.append(", align 4");
                     str3 = str_3.toString();

          }
          | '--'
          {
             $theInfo.theType = symtab.get($Identifier.text).theType;
                     int vIndex = symtab.get($Identifier.text).theVar.varIndex;
                     StringBuilder  str_1 = new StringBuilder("\%t");
                     str_1.append(varCount);
                     str_1.append(" = load i32, i32* \%t");
                     str_1.append(vIndex);
                     str_1.append(", align 4");
                     $theInfo.theVar.varIndex = varCount;
                     varCount ++;
                     str1 = str_1.toString();

                     StringBuilder  str_2 = new StringBuilder("\%t");
                     str_2.append(varCount);
                     str_2.append(" = add nsw i32 \%t");
                     str_2.append($theInfo.theVar.varIndex);
                     str_2.append(", -1");
					      $theInfo.theType = Type.INT;
					      $theInfo.theVar.varIndex = varCount;
					      varCount ++;
                     str2 = str_2.toString();

                     StringBuilder  str_3 = new StringBuilder("store i32 \%t");
                     str_3.append($theInfo.theVar.varIndex);
                     str_3.append(", i32* \%t");
                     str_3.append(vIndex);
                     str_3.append(", align 4");
                     str3 = str_3.toString();
          }
            )
             ;

		   
func_no_return_stmt: Identifier '(' argument ')'
                   ;


argument: arg (',' arg)*
        ;

arg: arith_expression
   | STRING_LITERAL
   ;
		   
cond_expression
returns [Info theInfo]
@init {$theInfo = new Info();}
               : a=arith_expression (RelationOP b=arith_expression)*
               {
                  Info a1 = $a.theInfo;
                  Info a2 = $b.theInfo;
                  String cp = $RelationOP.text;
                  if((a1.theType == Type.INT)&&
                     (a2.theType == Type.INT)){
                        if(cp.equals(">")){
                           TextCode.add("\%t" + varCount + " = icmp sgt i32 \%t" + a1.theVar.varIndex + ", \%t" + a2.theVar.varIndex);
                        }
                        else if(cp.equals("<")){
                           TextCode.add("\%t" + varCount + " = icmp slt i32 \%t" + a1.theVar.varIndex + ", \%t" + a2.theVar.varIndex);
                        }
                        else if(cp.equals("==")){
                           TextCode.add("\%t" + varCount + " = icmp eq i32 \%t" + a1.theVar.varIndex + ", \%t" + a2.theVar.varIndex);
                        }
                        else if(cp.equals("!=")){
                           TextCode.add("\%t" + varCount + " = icmp ne i32 \%t" + a1.theVar.varIndex + ", \%t" + a2.theVar.varIndex);
                        }
                        else if(cp.equals("<=")){
                           TextCode.add("\%t" + varCount + " = icmp sle i32 \%t" + a1.theVar.varIndex + ", \%t" + a2.theVar.varIndex);
                        }
                        else if(cp.equals(">=")){
                           TextCode.add("\%t" + varCount + " = icmp sge i32 \%t" + a1.theVar.varIndex + ", \%t" + a2.theVar.varIndex);
                        }
                        $theInfo.theType = Type.BOOL;
					         $theInfo.theVar.varIndex = varCount;
					         varCount ++;
                  }
                  else if((a1.theType == Type.INT) &&
                     (a2.theType == Type.CONST_INT)){
                        if(cp.equals(">")){
                           TextCode.add("\%t" + varCount + " = icmp sgt i32 \%t" + a1.theVar.varIndex + ", " + a2.theVar.iValue);
                        }
                        else if(cp.equals("<")){
                           TextCode.add("\%t" + varCount + " = icmp slt i32 \%t" + a1.theVar.varIndex + ", " + a2.theVar.iValue);
                        }
                        else if(cp.equals("==")){
                           TextCode.add("\%t" + varCount + " = icmp eq i32 \%t" + a1.theVar.varIndex + ", " + a2.theVar.iValue);
                        }
                        else if(cp.equals("!=")){
                           TextCode.add("\%t" + varCount + " = icmp ne i32 \%t" + a1.theVar.varIndex + ", " + a2.theVar.iValue);
                        }
                        else if(cp.equals("<=")){
                           TextCode.add("\%t" + varCount + " = icmp sle i32 \%t" + a1.theVar.varIndex + ", " + a2.theVar.iValue);
                        }
                        else if(cp.equals(">=")){
                           TextCode.add("\%t" + varCount + " = icmp sge i32 \%t" + a1.theVar.varIndex + ", " + a2.theVar.iValue);
                        }
                        $theInfo.theType = Type.BOOL;
					         $theInfo.theVar.varIndex = varCount;
					         varCount ++;
                  }
                  else if((a1.theType == Type.FLOAT)&&
                     (a2.theType == Type.FLOAT)){
                        if(cp.equals(">")){
                           TextCode.add("\%t" + varCount + " = fcmp ogt i32 \%t" + a1.theVar.varIndex + ", \%t" + a2.theVar.varIndex);
                        }
                        else if(cp.equals("<")){
                           TextCode.add("\%t = fcmp olt i32 \%t" + a1.theVar.varIndex + ", \%t" + a2.theVar.varIndex);
                        }
                        else if(cp.equals("==")){
                           TextCode.add("\%t" + varCount + " = fcmp oeq i32 \%t" + a1.theVar.varIndex + ", \%t" + a2.theVar.varIndex);
                        }
                        else if(cp.equals("!=")){
                           TextCode.add("\%t" + varCount + " = fcmp une i32 \%t" + a1.theVar.varIndex + ", \%t" + a2.theVar.varIndex);
                        }
                        else if(cp.equals("<=")){
                           TextCode.add("\%t" + varCount + " = fcmp ole i32 \%t" + a1.theVar.varIndex + ", \%t" + a2.theVar.varIndex);
                        }
                        else if(cp.equals(">=")){
                           TextCode.add("\%t" + varCount + " = fcmp oge i32 \%t" + a1.theVar.varIndex + ", \%t" + a2.theVar.varIndex);
                        }
                        $theInfo.theType = Type.BOOL;
					         $theInfo.theVar.varIndex = varCount;
					         varCount ++;
                  }
                  else if((a1.theType == Type.FLOAT) &&
                     (a2.theType == Type.CONST_FLOAT)){
                        Float ans_a2 = Float.parseFloat($b.text);
                        double tmp_a2 = ans_a2.doubleValue();
                        long ans2_a2 = Double.doubleToLongBits(tmp_a2);
                        
                        if(cp.equals(">")){
                           TextCode.add("\%t" + varCount + " = fcmp ogt i32 \%t" + a1.theVar.varIndex + ", 0x" + Long.toHexString(ans2_a2));
                        }
                        else if(cp.equals("<")){
                           TextCode.add("\%t" + varCount + " = fcmp olt i32 \%t" + a1.theVar.varIndex + ", 0x" +  Long.toHexString(ans2_a2));
                        }
                        else if(cp.equals("==")){
                           TextCode.add("\%t" + varCount + " = fcmp oeq i32 \%t" + a1.theVar.varIndex + ", 0x" + Long.toHexString(ans2_a2));
                        }
                        else if(cp.equals("!=")){
                           TextCode.add("\%t" + varCount + " = fcmp une i32 \%t" + a1.theVar.varIndex + ", 0x" + Long.toHexString(ans2_a2));
                        }
                        else if(cp.equals("<=")){
                           TextCode.add("\%t" + varCount + " = fcmp ole i32 \%t" + a1.theVar.varIndex + ", 0x" + Long.toHexString(ans2_a2));
                        }
                        else if(cp.equals(">=")){
                           TextCode.add("\%t" + varCount + " = fcmp oge i32 \%t" + a1.theVar.varIndex + ", 0x" + Long.toHexString(ans2_a2));
                        }
                        $theInfo.theType = Type.BOOL;
					         $theInfo.theVar.varIndex = varCount;
					         varCount ++;
                  }else {
                     //System.out.println("Error: " + $a.start.getLine() + ": Type mismatch for the two silde operands in an assignment statement.");
                     $theInfo.theType = Type.ERR;
					      $theInfo.theVar.varIndex = varCount;
					      varCount ++;
                  }
                  
               }
               ;
			   
arith_expression
returns [Info theInfo]
@init {$theInfo = new Info();}
                : a=multExpr { $theInfo=$a.theInfo; }
                 ( '+' b=multExpr
                    {
                       // We need to do type checking first.
                       // ..
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&
                           ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
					            // Update arith_expression's theInfo.
					            $theInfo.theType = Type.INT;
					            $theInfo.theVar.varIndex = varCount;
					            varCount ++;
                           if (TRACEON) System.out.println("arith_expression: ");
                       } else if (($a.theInfo.theType == Type.INT) &&
					                  ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
					   
					            // Update arith_expression's theInfo.
					            $theInfo.theType = Type.INT;
					            $theInfo.theVar.varIndex = varCount;
					            varCount ++;
                           if (TRACEON) System.out.println("arith_expression: ");
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&
					                  ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = add nsw i32 " + $a.theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
                           $a.theInfo.theVar.iValue = $a.theInfo.theVar.iValue + $b.theInfo.theVar.iValue;
					            // Update arith_expression's theInfo.
					            $theInfo.theType = Type.CONST_INT;
					            $theInfo.theVar.varIndex = varCount;
                           $theInfo.theVar.iValue = $a.theInfo.theVar.iValue;
                           //$theInfo.
					            varCount ++;
                           if (TRACEON) System.out.println("arith_expression: ");
                       }
                       else if (($a.theInfo.theType == Type.FLOAT) &&
                           ($b.theInfo.theType == Type.FLOAT)) {
                           TextCode.add("\%t" + varCount + " = fadd float \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
					            // Update arith_expression's theInfo.
					            $theInfo.theType = Type.FLOAT;
					            $theInfo.theVar.varIndex = varCount;
					            varCount ++;
                           if (TRACEON) System.out.println("arith_expression: ");
                       }
                       else if (($a.theInfo.theType == Type.FLOAT) &&
					                  ($b.theInfo.theType == Type.CONST_FLOAT)) {
                              Float a3 = Float.parseFloat($b.text);
                              //Float a3 = $b.theInfo.theVar.fValue;
                              //System.out.println("float: " + $b.theInfo.theVar.fValue);
                              double tmp = a3.doubleValue();
                              long ans = Double.doubleToLongBits(tmp);
                           TextCode.add("\%t" + varCount + " = fadd float \%t" + $theInfo.theVar.varIndex + ", 0x" + Long.toHexString(ans));
					   
					            // Update arith_expression's theInfo.
					            $theInfo.theType = Type.FLOAT;
					            $theInfo.theVar.varIndex = varCount;
					            varCount ++;
                           if (TRACEON) System.out.println("arith_expression: ");
                       }else{
                          System.out.println("Error: " + $a.start.getLine() + ": Type mismatch for the operator + in an expression.");
                       }
                    }
                 | '-' c=multExpr
                     {
                        if (($a.theInfo.theType == Type.INT) &&
                           ($c.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex);
					   
                           // Update arith_expression's theInfo.
                           $theInfo.theType = Type.INT;
                           $theInfo.theVar.varIndex = varCount;
                           varCount ++;
                           if (TRACEON) System.out.println("arith_expression: ");
                        } else if (($a.theInfo.theType == Type.INT) &&
					                     ($c.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $c.theInfo.theVar.iValue);
                        
                           // Update arith_expression's theInfo.
                           $theInfo.theType = Type.INT;
                           $theInfo.theVar.varIndex = varCount;
                           varCount ++;
                           if (TRACEON) System.out.println("arith_expression: ");
                        }else if (($a.theInfo.theType == Type.CONST_INT) &&
					                     ($c.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = sub nsw i32 " + $a.theInfo.theVar.iValue + ", " + $c.theInfo.theVar.iValue);
                           $a.theInfo.theVar.iValue = $a.theInfo.theVar.iValue - $c.theInfo.theVar.iValue;
                           // Update arith_expression's theInfo.
                           $theInfo.theType = Type.CONST_INT;
                           $theInfo.theVar.varIndex = varCount;
                           $theInfo.theVar.iValue = $a.theInfo.theVar.iValue;
                           varCount ++;
                           if (TRACEON) System.out.println("arith_expression: ");
                        }else if (($a.theInfo.theType == Type.FLOAT) &&
                           ($b.theInfo.theType == Type.FLOAT)) {
                           TextCode.add("\%t" + varCount + " = fsub float \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
					            // Update arith_expression's theInfo.
					            $theInfo.theType = Type.FLOAT;
					            $theInfo.theVar.varIndex = varCount;
					            varCount ++;
                           if (TRACEON) System.out.println("arith_expression: ");
                       }
                       else if (($a.theInfo.theType == Type.FLOAT) &&
					                  ($b.theInfo.theType == Type.CONST_FLOAT)) {
                              Float a4 = Float.parseFloat($b.text);
                              double tmp = a4.doubleValue();
                              long ans = Double.doubleToLongBits(tmp);
                           TextCode.add("\%t" + varCount + " = fsub float \%t" + $theInfo.theVar.varIndex + ", 0x" + Long.toHexString(ans));
					   
					            // Update arith_expression's theInfo.
					            $theInfo.theType = Type.FLOAT;
					            $theInfo.theVar.varIndex = varCount;
					            varCount ++;
                           if (TRACEON) System.out.println("arith_expression: ");
                       }else{
                          System.out.println("Error: " + $a.start.getLine() + ": Type mismatch for the operator - in an expression.");
                       }
                     }
                 )*
                 ;
                 

multExpr
returns [Info theInfo]
@init {$theInfo = new Info();}
          : a=signExpr { $theInfo=$a.theInfo; }
          ( '*' b = signExpr
            {
               if (($a.theInfo.theType == Type.INT) &&
                  ($b.theInfo.theType == Type.INT)) {
                  TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
                  // Update arith_expression's theInfo.
                  $theInfo.theType = Type.INT;
                  $theInfo.theVar.varIndex = varCount;
                  varCount ++;
                  if (TRACEON) System.out.println("multExpr: ");
               } else if (($a.theInfo.theType == Type.INT) &&
					      ($b.theInfo.theType == Type.CONST_INT)) {
                  TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
                        
                  // Update arith_expression's theInfo.
                  $theInfo.theType = Type.INT;
                  $theInfo.theVar.varIndex = varCount;
                  varCount ++;
                  if (TRACEON) System.out.println("multExpr: ");
               }else if (($a.theInfo.theType == Type.CONST_INT) &&
					      ($b.theInfo.theType == Type.CONST_INT)) {
                  TextCode.add("\%t" + varCount + " = mul nsw i32 " + $a.theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
                        $a.theInfo.theVar.iValue = $a.theInfo.theVar.iValue * $b.theInfo.theVar.iValue;
                  // Update arith_expression's theInfo.
                  $theInfo.theType = Type.CONST_INT;
                  $theInfo.theVar.varIndex = varCount;
                  $theInfo.theVar.iValue = $a.theInfo.theVar.iValue;
                  varCount ++;
                  if (TRACEON) System.out.println("multExpr: ");
               }else if (($a.theInfo.theType == Type.FLOAT) &&
                  ($b.theInfo.theType == Type.FLOAT)) {
                  TextCode.add("\%t" + varCount + " = fmul float \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
					   // Update arith_expression's theInfo.
					   $theInfo.theType = Type.FLOAT;
					   $theInfo.theVar.varIndex = varCount;
					   varCount ++;
                  if (TRACEON) System.out.println("multExpr: ");
               }
               else if (($a.theInfo.theType == Type.FLOAT) &&
					         ($b.theInfo.theType == Type.CONST_FLOAT)) {
                  Float a1 = Float.parseFloat($b.text);
                  double tmp = a1.doubleValue();
                  long ans = Double.doubleToLongBits(tmp);
                  TextCode.add("\%t" + varCount + " = fmul float \%t" + $theInfo.theVar.varIndex + ", 0x" + Long.toHexString(ans));
					   
					   // Update arith_expression's theInfo.
					   $theInfo.theType = Type.FLOAT;
					   $theInfo.theVar.varIndex = varCount;
					   varCount ++;
                  if (TRACEON) System.out.println("multExpr: ");
               }else{
                  System.out.println("Error: " + $a.start.getLine() + ": Type mismatch for the operator * in an expression.");
               }
            }
          | '/' c = signExpr
            {
               if (($a.theInfo.theType == Type.INT) &&
                  ($c.theInfo.theType == Type.INT)) {
                  TextCode.add("\%t" + varCount + " = sdiv nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex);
					   
                  // Update arith_expression's theInfo.
                  $theInfo.theType = Type.INT;
                  $theInfo.theVar.varIndex = varCount;
                  varCount ++;
                  if (TRACEON) System.out.println("multExpr: ");
               } else if (($a.theInfo.theType == Type.INT) &&
					         ($c.theInfo.theType == Type.CONST_INT)) {
                  TextCode.add("\%t" + varCount + " = sdiv nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $c.theInfo.theVar.iValue);
                        
                  // Update arith_expression's theInfo.
                  $theInfo.theType = Type.INT;
                  $theInfo.theVar.varIndex = varCount;
                  //$theInfo.theVar.iValue = $a.theInfo.theVar.iValue;
                  varCount ++;
                  if (TRACEON) System.out.println("multExpr: ");
               } else if (($a.theInfo.theType == Type.CONST_INT) &&
					         ($c.theInfo.theType == Type.CONST_INT)) {
                  TextCode.add("\%t" + varCount + " = sdiv nsw i32 " + $a.theInfo.theVar.iValue + ", " + $c.theInfo.theVar.iValue);
                        $a.theInfo.theVar.iValue = $a.theInfo.theVar.iValue / $c.theInfo.theVar.iValue;
                  // Update arith_expression's theInfo.
                  $theInfo.theType = Type.CONST_INT;
                  $theInfo.theVar.varIndex = varCount;
                  $theInfo.theVar.iValue = $a.theInfo.theVar.iValue;
                  varCount ++;
                  if (TRACEON) System.out.println("multExpr: ");
               }else if (($a.theInfo.theType == Type.FLOAT) &&
                  ($b.theInfo.theType == Type.FLOAT)) {
                  TextCode.add("\%t" + varCount + " = fdiv float \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
					   // Update arith_expression's theInfo.
					   $theInfo.theType = Type.FLOAT;
					   $theInfo.theVar.varIndex = varCount;
					   varCount ++;
                  if (TRACEON) System.out.println("multExpr: ");
               }
               else if (($a.theInfo.theType == Type.FLOAT) &&
					         ($b.theInfo.theType == Type.CONST_FLOAT)) {
                  Float a2 = Float.parseFloat($b.text);
                  //System.out.println($b.text);
                  double tmp = a2.doubleValue();
                  long ans = Double.doubleToLongBits(tmp);
                  TextCode.add("\%t" + varCount + " = fdiv float \%t" + $theInfo.theVar.varIndex + ", 0x" + Long.toHexString(ans));
					   
					   // Update arith_expression's theInfo.
					   $theInfo.theType = Type.FLOAT;
					   $theInfo.theVar.varIndex = varCount;
					   varCount ++;
                  if (TRACEON) System.out.println("multExpr: ");
               }
               else{
                  System.out.println("Error: " + $a.start.getLine() + ": Type mismatch for the operator / in an expression.");
               }
            }
	  )*
	  ;

signExpr
returns [Info theInfo]
@init {$theInfo = new Info();}
        : a=primaryExpr { 
           $theInfo=$a.theInfo; 
            if (TRACEON) System.out.println("signExpr: primaryExpr");
        } 
        | '-' b = primaryExpr
        {
            if (($b.theInfo.theType == Type.INT)) {
               TextCode.add("\%t" + varCount + " = sub nsw i32 0, \%t" + $b.theInfo.theVar.varIndex);
			   
               // Update arith_expression's theInfo.
               $theInfo.theType = Type.INT;
               $theInfo.theVar.varIndex = varCount;
               varCount ++;
            } else if (($b.theInfo.theType == Type.FLOAT)) {
               TextCode.add("\%t" + varCount + " = fneg float \%t" + $b.theInfo.theVar.varIndex);
			   
               // Update arith_expression's theInfo.
               $theInfo.theType = Type.INT;
               $theInfo.theVar.varIndex = varCount;
               varCount ++;
            } 
            if (TRACEON) System.out.println("signExpr: primaryExpr");
         }
	;
		  
primaryExpr
returns [Info theInfo]
@init {$theInfo = new Info();}
           : Integer_constant
	     {
            $theInfo.theType = Type.CONST_INT;
			   $theInfo.theVar.iValue = Integer.parseInt($Integer_constant.text);
            if (TRACEON) System.out.println("primaryExpr: number");
         }
           | Floating_point_constant
         {
            $theInfo.theType = Type.CONST_FLOAT;
			   $theInfo.theVar.fValue = Float.parseFloat($Floating_point_constant.text);
            if (TRACEON) System.out.println("primaryExpr: float number");
         }
           | Identifier
              {
                 if(symtab.containsKey($Identifier.text)){
                     // get type information from symtab.
                     Type the_type = symtab.get($Identifier.text).theType;
                     $theInfo.theType = the_type;

                     // get variable index from symtab.
                     int vIndex = symtab.get($Identifier.text).theVar.varIndex;
                  
                     switch (the_type) {
                     case INT: 
                              // get a new temporary variable and
                              // load the variable into the temporary variable.
                                    
                              // Ex: \%tx = load i32, i32* \%ty.
                              TextCode.add("\%t" + varCount + "= load i32, i32* \%t" + vIndex + ", align 4");
                                 
                              // Now, Identifier's value is at the temporary variable \%t[varCount].
                              // Therefore, update it.
                              $theInfo.theVar.varIndex = varCount;
                              varCount ++;
                              break;
                     case FLOAT:
                              TextCode.add("\%t" + varCount + "= load float, float* \%t" + vIndex + ", align 4");
                              $theInfo.theVar.varIndex = varCount;
                              varCount ++;
                              break;
                     case CHAR:
                              TextCode.add("\%t" + varCount + " = load i8, i8* \%t" + vIndex + ", align 1");
                              $theInfo.theVar.varIndex = varCount;
                              varCount ++;
                              break;
                     }
                 }else{
                    System.out.println("Error: " + $Identifier.getLine() + ": Undeclared identifier.");
                 }
              }
	   | '&' Identifier
	   | '(' arith_expression ')'
      {
         $theInfo.theType = $arith_expression.theInfo.theType;
         $theInfo.theVar.varIndex = varCount;
         if($theInfo.theType == Type.CONST_INT){
            //System.out.println("aaatext: " + $arith_expression.theInfo.theVar.iValue);
            $theInfo.theVar.iValue = $arith_expression.theInfo.theVar.iValue;
         }
         else if($theInfo.theType == Type.CONST_FLOAT){
            $theInfo.theVar.fValue = $arith_expression.theInfo.theVar.fValue;
         }
         varCount++;
      }
      | LETTER
         {
            $theInfo.theType = Type.CHAR;
			   $theInfo.theVar.cValue =  $LETTER.text.charAt(1);
            if (TRACEON) System.out.println("primaryExpr: char");
         }
           ;

	   
/* description of the tokens */
FLOAT:'float';
INT:'int';
CHAR: 'char';

MAIN: 'main';
VOID: 'void';
IF: 'if';
ELSE: 'else';
WHILE: 'while';
FOR: 'for';

PRINTF:'printf';

RelationOP: '>' |'>=' | '<' | '<=' | '==' | '!=';

LETTER : ('\'')('a'..'z' | 'A'..'Z' | '_')('\'');
Identifier:('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
Integer_constant:('-')* '0'..'9'+;
Floating_point_constant:'0'..'9'+ '.' '0'..'9'+ 'f';

STRING_LITERAL
    :  '"' ( EscapeSequence | ~('\\'|'"') )* '"'
    ;

WS:( ' ' | '\t' | '\r' | '\n' ) {$channel=HIDDEN;};
COMMENT:'/*' .* '*/' {$channel=HIDDEN;};


fragment
EscapeSequence
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    ;
