declare dso_local i32 @printf(i8*, ...)

@.str = private unnamed_addr constant [14 x i8] c"c = %f, b = %d\00", align 1
; === prologue ====
define dso_local i32 @main()
{
%t0 = alloca float, align 4
%t1 = alloca float, align 4
%t2 = alloca i32, align 4
%t3 = alloca i32, align 4
store i32 3, i32* %t3, align 4
store i32 6, i32* %t2, align 4
store float 0x4003333340000000, float* %t1, align 4
store float 0x4016ccccc0000000, float* %t0, align 4
br label %comd4
%comd4:
%t5= load float, float* %t1, align 4
%t6= load float, float* %t0, align 4
%t7 = fcmp oge i32 %t5, %t6
br i1 %t7, label %Ltrue, label %Lend
Ltrue:
%t8= load i32, i32* %t3, align 4
%t9= load i32, i32* %t2, align 4
%t10 = add nsw i32 %t8, %t9
store i32 %t10, i32* %t3, align 4
br label %comd4
%t11= load float, float* %t1, align 4
%t12= load i32, i32* %t2, align 4
%t15 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str, i64 0, i64 0), double %t11, i32 %t12)

; === epilogue ===
ret i32 0
}
