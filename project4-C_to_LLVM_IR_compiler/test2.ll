declare dso_local i32 @printf(i8*, ...)

@.str = private unnamed_addr constant [6 x i8] c"a = %d\00", align 1
; === prologue ====
define dso_local i32 @main()
{
%t0 = alloca i32, align 4
%t1 = alloca i32, align 4
%t2 = alloca i32, align 4
store i32 0, i32* %t0, align 4
store i32 0, i32* %t2, align 4
%t3= load i32, i32* %t2, align 4
%t4 = add nsw i32 100, 123
%t6 = mul nsw i32 %t3, 223
store i32 %t6, i32* %t1, align 4
store i32 1, i32* %t0, align 4
br label %t7
%t7:
%t8= load i32, i32* %t0, align 4
%t9 = icmp slt i32 %t8, 10
br i1 %t9, label %t10, label %Lend
%t10:
%t14= load i32, i32* %t1, align 4
%t15 = add nsw i32 %t14, 10
store i32 %t15, i32* %t2, align 4
br label %t11
%t11:
%t12 = load i32, i32* %t0, align 4
%t13 = add nsw i32 %t12, 1
store i32 %t13, i32* %t0, align 4
br label %t7
store i32 14, i32* %t0, align 4
br label %t16
%t16:
%t17= load i32, i32* %t0, align 4
%t18 = icmp sge i32 %t17, 4
br i1 %t18, label %t19, label %Lend
%t19:
%t23= load i32, i32* %t2, align 4
%t24 = sub nsw i32 0, %t23
store i32 %t24, i32* %t2, align 4
%t25= load i32, i32* %t1, align 4
%t26= load i32, i32* %t2, align 4
%t27 = sub nsw i32 %t25, %t26
store i32 %t27, i32* %t1, align 4
br label %t20
%t20:
%t21 = load i32, i32* %t0, align 4
%t22 = add nsw i32 %t21, -1
store i32 %t22, i32* %t0, align 4
br label %t16
%t28= load i32, i32* %t2, align 4
%t30 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str, i64 0, i64 0), i32 %t28)

; === epilogue ===
ret i32 0
}
