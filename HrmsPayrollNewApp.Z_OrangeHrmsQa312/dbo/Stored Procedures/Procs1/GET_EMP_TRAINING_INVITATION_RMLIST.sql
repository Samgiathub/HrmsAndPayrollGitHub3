

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[GET_EMP_TRAINING_INVITATION_RMLIST]
@TRAINING_APP_ID AS NUMERIC(18,0),
@Cmp_ID AS NUMERIC(18,0),
@Emp_id as varchar(1000)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	-- SET NOCOUNT ON ADDED TO PREVENT EXTRA RESULT SETS FROM
	-- INTERFERING WITH SELECT STATEMENTS.
	
	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	Insert Into @Emp_Cons
	select  cast(data  as numeric) from dbo.Split (@Emp_id,'#') 
	
	select DISTINCT td.Emp_ID,rm.R_Emp_ID,RM.Effect_Date,EM.Alpha_Emp_Code,EM.Emp_Full_Name
		,EM1.Alpha_Emp_Code as RM_Emp_Code,EM1.Emp_Full_Name as RM_Emp_Name,EM1.Work_Email
		from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL TD WITH (NOLOCK) INNER JOIN 
		T0090_EMP_REPORTING_DETAIL RM WITH (NOLOCK) on rm.Emp_ID = td.Emp_ID INNER JOIN
		T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID = RM.EMP_ID INNER JOIN 
		@Emp_Cons ec on TD.Emp_ID = ec.Emp_ID INNER JOIN	
		T0080_EMP_MASTER EM1 WITH (NOLOCK) ON EM1.EMP_ID = RM.R_Emp_ID INNER JOIN
		(
			SELECT   MAX(Row_ID) AS Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID 
			from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) inner JOIN
			(
				SELECT   MAX(Effect_Date)Effect_Date,Emp_Id	
				from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
				group by Emp_ID
			)RM2 on RM2.Effect_Date = T0090_EMP_REPORTING_DETAIL.Effect_Date and RM2.Emp_ID = RM2.Emp_ID
			group by T0090_EMP_REPORTING_DETAIL.Emp_ID
		)RM1 on rm1.Row_ID = rm.Row_ID
		WHERE TD.TRAINING_APP_ID = @TRAINING_APP_ID and td.cmp_id=@Cmp_ID 
		and cast(TD.Emp_ID as varchar(500)) in(select Emp_ID From @Emp_Cons)
   
   select DISTINCT td.Emp_ID,rm.R_Emp_ID
		from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL TD WITH (NOLOCK) INNER JOIN 
		@Emp_Cons ec on TD.Emp_ID = ec.Emp_ID INNER JOIN
		T0090_EMP_REPORTING_DETAIL RM WITH (NOLOCK) on rm.Emp_ID = td.Emp_ID INNER JOIN		
		(
			SELECT   MAX(Row_ID) AS Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID 
			from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) inner JOIN
			(
				SELECT   MAX(Effect_Date)Effect_Date,Emp_Id	
				from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
				group by Emp_ID
			)RM2 on RM2.Effect_Date = T0090_EMP_REPORTING_DETAIL.Effect_Date and RM2.Emp_ID = RM2.Emp_ID
			group by T0090_EMP_REPORTING_DETAIL.Emp_ID
		)RM1 on rm1.Row_ID = rm.Row_ID
		WHERE TD.TRAINING_APP_ID = @TRAINING_APP_ID and td.cmp_id=@Cmp_ID 
		and cast(TD.Emp_ID as varchar(500)) in(select Emp_ID From @Emp_Cons)
		--and cast(TD.Emp_ID as varchar(500)) in(select Emp_ID From @Emp_Cons)
 END

