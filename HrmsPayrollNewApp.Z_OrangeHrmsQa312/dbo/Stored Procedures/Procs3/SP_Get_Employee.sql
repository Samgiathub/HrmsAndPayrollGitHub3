--drop table #Emp_Cons
--drop table #TMP
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Get_Employee]
	@Cmp_ID numeric(18,0),  
	@Emp_ID numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @From_Date  DATETIME = NULL
	DECLARE @To_Date  DATETIME = NULL
	DECLARE @ExecuteFor VARCHAR(32) = ''
	DECLARE @EMP_SEARCH INT = 0
	
	if @From_Date IS NULL
		set @From_Date=GETDATE()
	if @To_Date IS NULL
		set @To_Date=GETDATE()	
		
	--IF @ExecuteFor NOT IN ('DIRECT' , 'INDIRECT', 'BOTH')
	--	SET @ExecuteFor = ''
	


	Select E.R_Emp_ID,T.emp_id,I.Increment_ID,I.Branch_ID,E.Reporting_Method,I.Sales_Code,T.Date_Of_Join,I.CTC--Added Date_Of_Join field by Mukti(19122017)
	INTO #Emp_Cons
	FROM T0080_EMP_MASTER  T WITH (NOLOCK)
			INNER JOIN (
						SELECT	Cmp_ID,Emp_ID,R_Emp_ID,Reporting_Method,MAX(Effect_Date) As Effect_Date 
						FROM	T0090_EMP_REPORTING_DETAIL E WITH (NOLOCK)
						WHERE	Effect_Date<=GetDate() 
						GROUP	BY Cmp_ID,Emp_ID,R_Emp_ID,Reporting_Method
						) E ON E.Emp_ID=T.Emp_ID And E.Cmp_ID=T.Cmp_ID 
			INNER JOIN (
						SELECT	INCREMENT_ID,I.Emp_ID,I.Cmp_ID,I.Branch_ID , I.Sales_Code,I.CTC
						FROM	T0095_INCREMENT I WITH (NOLOCK)
						WHERE	I.Increment_ID = (
													SELECT	TOP 1 I1.Increment_ID
													FROM	T0095_INCREMENT I1 WITH (NOLOCK)
													WHERE	I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID 
													ORDER	BY I1.Increment_Effective_Date DESC, I1.Increment_ID DESC
													)
						) I ON  T.Emp_ID=I.Emp_ID AND T.Cmp_ID=I.Cmp_ID
	Where E.Effect_Date=(Select MAX(Effect_Date) FROM T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK)
						WHERE ED.Emp_ID=E.Emp_ID And Effect_Date<=GetDate())
	and (Emp_Left = 'N' or
	
	(Emp_Left = 'Y' and Emp_Left_Date >= @To_Date)) 
	AND E.R_Emp_ID=@Emp_ID
	AND (E.Cmp_ID=@Cmp_ID OR E.Reporting_Method='InDirect') 
	
	Select	E.R_Emp_ID,T.emp_id,emp_full_name,Alpha_Emp_Code,cast(Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name as Emp_Name_Code,E.Reporting_Method,
			E.branch_id,T.Dept_ID,BM.branch_name,DEPT.dept_name,
	case @Emp_Search                
			when 0
				then cast( T.Alpha_Emp_Code as varchar) + ' - '+ T.Emp_Full_Name
			when 1
				then  cast( T.Alpha_Emp_Code as varchar) + ' - '+ T.Emp_First_Name+SPACE(1)+T.Emp_Second_Name+SPACE(2)+T.Emp_Last_Name
			when 2
				then  cast( T.Alpha_Emp_Code as varchar)
			when 3
				then  T.Initial+SPACE(1)+ T.Emp_First_Name+SPACE(1)+T.Emp_Second_Name+SPACE(2)+T.Emp_Last_Name
			when 4
				then  T.Emp_First_Name+SPACE(1)+T.Emp_Second_Name+SPACE(2)+T.Emp_Last_Name + ' - ' + cast( T.Alpha_Emp_Code as varchar)	
			end as Emp_Full_Name1 
			,Dm.Desig_Name , E.Sales_Code,T.Date_Of_Join,T.Cmp_ID,co.Cmp_Name,I.CTC 
			,I.Desig_Id  
	INTO #TMP
	FROM T0080_EMP_MASTER T WITH (NOLOCK) INNER JOIN #EMP_CONS E ON T.Emp_ID=E.EMP_ID 
		INNER JOIN (
						SELECT	INCREMENT_ID,I.Emp_ID,I.Cmp_ID,I.Branch_ID, I.Dept_ID,I.Desig_Id,I.CTC
						FROM	T0095_INCREMENT I WITH (NOLOCK)
						WHERE	I.Increment_ID = (
													SELECT	TOP 1 I1.Increment_ID
													FROM	T0095_INCREMENT I1 WITH (NOLOCK)
													WHERE	I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID 
													ORDER	BY I1.Increment_Effective_Date DESC, I1.Increment_ID DESC
													)
						) I ON  T.Emp_ID=I.Emp_ID AND T.Cmp_ID=I.Cmp_ID
		INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I.CMP_ID=BM.CMP_ID AND I.Branch_ID=BM.Branch_ID
		LEFT OUTER JOIN  T0040_DEPARTMENT_MASTER DEPT WITH (NOLOCK) ON I.Cmp_ID=DEPT.Cmp_Id AND I.Dept_ID=DEPT.Dept_Id
		LEFT OUTER JOIN  T0040_DESIGNATION_MASTER DM WITH (NOLOCK) On Dm.Desig_ID = I.Desig_Id AND I.Cmp_ID = DM.Cmp_ID	
		INNER JOIN T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=T.Cmp_ID		
		ORDER BY 
				Case @Emp_Search 
				When 3 Then
					t.Emp_First_Name
				When 4 Then
					t.Emp_First_Name
				Else
					Case When IsNumeric(t.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + t.Alpha_Emp_Code, 20)
			When IsNumeric(t.Alpha_Emp_Code) = 0 then Left(t.Alpha_Emp_Code + Replicate('',21), 20)
				Else t.Alpha_Emp_Code
			End
		End
	
		IF @ExecuteFor  IN ('', 'BOTH', 'DIRECT')
			SELECT 111,R_Emp_ID,Emp_id,Emp_Full_Name,Alpha_Emp_Code,Emp_Name_Code,Branch_ID,Dept_ID,branch_name,dept_name,Emp_Full_Name1
					,Desig_Id ,Desig_Name	, Sales_Code,Date_Of_Join,CMP.cmp_id,
					Cmp.Cmp_Name,
					CTC		
				FROM #TMP TMP
			INNER JOIN T0010_COMPANY_MASTER CMP WITH (NOLOCK) on CMP.Cmp_Id=TMP.Cmp_ID
			WHERE Reporting_Method = 'Direct'
END




