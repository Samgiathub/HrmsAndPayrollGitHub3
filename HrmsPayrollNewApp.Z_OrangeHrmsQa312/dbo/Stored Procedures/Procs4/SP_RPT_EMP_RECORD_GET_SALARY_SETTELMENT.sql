
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_RECORD_GET_SALARY_SETTELMENT]
	@Cmp_ID	numeric
	,@From_Date	datetime
	,@To_Date	datetime
	,@Branch_ID	varchar(Max)
	,@Cat_ID	varchar(Max)
	,@Grd_ID	varchar(Max)
	,@Type_ID	varchar(Max)
	,@Dept_ID	varchar(Max)
	,@Desig_ID	varchar(Max)
	,@Emp_ID	numeric = 0
	,@Constraint	varchar(max) = ''
	,@New_Join_emp	numeric = 0
	,@Left_Emp	Numeric = 0
	,@CPS_Flag Numeric = 0
	,@Format Numeric = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @Show_Left_Employee_for_Salary AS TINYINT
	SET @Show_Left_Employee_for_Salary = 0
	
	SELECT @Show_Left_Employee_for_Salary = ISNULL(Setting_Value,0)
	FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Show Left Employee for Salary'
	
		CREATE TABLE #Emp_Cons
		(
			Emp_ID numeric ,
			Branch_ID numeric,
			Increment_ID numeric
		)
-- Added by nilesh patel on 06092014
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,NULL,'','','','',@New_Join_emp,@Left_Emp,0,'',0,0
		
	if @Format = 0 or @Format = 4 --Added By Jimit 11052018 Format4
		Begin
			Select Distinct EM.Alpha_Emp_Code,Emp_Full_Name,EM.Emp_ID,EM.Mobile_No From #Emp_Cons	EC
			Inner Join T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK)
			ON EC.Emp_ID = MS.Emp_ID
			Inner Join T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = EC.Emp_ID
			Where MS.S_Eff_Date Between @From_Date and @To_Date
		End
	Else if @Format = 1
		Begin
			if @CPS_Flag = 1
				Begin
					Select Distinct EM.Alpha_Emp_Code,Emp_Full_Name,EM.Emp_ID,EM.Mobile_No From #Emp_Cons	EC
					Inner Join T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK)
					ON EC.Emp_ID = MS.Emp_ID
					Inner Join T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = EC.Emp_ID
					Inner JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = MS.Increment_ID
					Where MS.S_Eff_Date Between @From_Date and @To_Date	and EM.Date_Of_Join >= '2005-01-01 00:00.000' and I.Reason_Name='DA Arrear'
				End
			Else
				Begin
					Select Distinct EM.Alpha_Emp_Code,Emp_Full_Name,EM.Emp_ID,EM.Mobile_No From #Emp_Cons	EC
					Inner Join T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK)
					ON EC.Emp_ID = MS.Emp_ID
					Inner Join T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = EC.Emp_ID
					Inner JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = MS.Increment_ID
					Where MS.S_Eff_Date Between @From_Date and @To_Date	and EM.Date_Of_Join < '2005-01-01 00:00.000' and I.Reason_Name='DA Arrear'
				End
		End
	Else if @Format = 2
		Begin
			if @CPS_Flag = 1
				Begin
					Select Distinct EM.Alpha_Emp_Code,Emp_Full_Name,EM.Emp_ID,EM.Mobile_No From #Emp_Cons	EC
					Inner Join T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK)
					ON EC.Emp_ID = MS.Emp_ID
					Inner Join T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = EC.Emp_ID
					Inner JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = MS.Increment_ID
					Where MS.S_Eff_Date Between @From_Date and @To_Date	and EM.Date_Of_Join >= '2005-01-01 00:00.000' and I.Reason_Name='Increment Supplementary'
				End
			Else
				Begin
					Select Distinct EM.Alpha_Emp_Code,Emp_Full_Name,EM.Emp_ID,EM.Mobile_No From #Emp_Cons	EC
					Inner Join T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK) 
					ON EC.Emp_ID = MS.Emp_ID
					Inner Join T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = EC.Emp_ID
					Inner JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = MS.Increment_ID
					Where MS.S_Eff_Date Between @From_Date and @To_Date	and EM.Date_Of_Join < '2005-01-01 00:00.000' and I.Reason_Name='Increment Supplementary'
				End
		End
	ELSE IF @FORMAT = 3  --Added by Jaina 26-07-2017
		BEGIN
			Select Distinct EM.Alpha_Emp_Code,Emp_Full_Name,EM.Emp_ID,EM.Mobile_No From #Emp_Cons	EC
			Inner Join T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK)
			ON EC.Emp_ID = MS.Emp_ID
			Inner Join T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = EC.Emp_ID
			Where MS.S_Month_End_Date Between @From_Date and @To_Date
		END
