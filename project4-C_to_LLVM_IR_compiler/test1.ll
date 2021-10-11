declare dso_local i32 @printf(i8*, ...)

@.str = private unnamed_addr constant [14 x i8] c"c = %f, d = %c\00", align 1
; === prologue ====
define dso_local i32 @main()
{
%t0 = alloca i8, align 1
%t1 = alloca float, align 4
%t2 = alloca i32, align 4
%t3 = alloca i32, align 4
%t4= load i32, i32* %t3, align 4
%t5 = sub nsw i32 %t4, 10
store i32 %t5, i32* %t3, align 4
%t6= load i32, i32* %t3, align 4
%t7 = mul nsw i32 %t6, 3
store i32 %t7, i32* %t3, align 4
%t8= load i32, i32* %t3, align 4
%t9 = sdiv nsw i32 %t8, 5
store i32 %t9, i32* %t3, align 4
store i8 115, i8* %t0, align 1
store float 0x4002b851e0000000, float* %t1, align 4
store i32 0, i32* %t3, align 4
%t10= load i32, i32* %t3, align 4
%t11 = add nsw i32 %t10, 100
store i32 %t11, i32* %t2, align 4
%t12= load float, float* %t1, align 4
%t13 = fneg float %t12
%t14= load i32, i32* %t3, align 4
%t15= load i32, i32* %t2, align 4
%t16 = icmp ne i32 %t14, %t15
br i1 %t16, label %Ltrue, label %Lfalse
Ltrue:
%t17= load i32, i32* %t3, align 4
%t18 = add nsw i32 %t17, 20
store i32 %t18, i32* %t2, align 4
Lfalse:
store float 0x401accccc0000000, float* %t1, align 4
br label %Lend
%t19= load float, float* %t1, align 4
%t20 = load i8, i8* %t0, align 1
%t22 = sext i8 %t20 to i32
%t23 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str, i64 0, i64 0), double %t19, i32 %t22)

; === epilogue ===
ret i32 0
}
