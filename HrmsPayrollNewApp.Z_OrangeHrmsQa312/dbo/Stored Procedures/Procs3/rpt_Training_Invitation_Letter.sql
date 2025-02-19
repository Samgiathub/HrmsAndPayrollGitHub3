
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[rpt_Training_Invitation_Letter]
		 @Cmp_ID		Numeric(18,0)
		,@From_Date		Datetime 
		,@To_Date		Datetime
		,@Branch_ID		varchar(Max) 
		,@Cat_ID		varchar(Max)
		,@Grd_ID		varchar(Max) 
		,@Type_ID		varchar(Max) 
		,@Dept_ID		varchar(Max)
		,@Desig_ID		varchar(Max)
		,@Emp_ID		Numeric
		,@Constraint	varchar(MAX)	
		,@Training_ID	Numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN	
	declare @query as varchar(max) 
	set @query =''
	if @Training_ID =0
		set @Training_ID = NULL
	CREATE TABLE #Emp_Cons 
	 (      
		   Emp_ID numeric ,  
		   Branch_ID numeric, 
		   Increment_ID numeric 
	 )  
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 

	select EI.Alpha_Emp_Code,EI.Emp_Full_Name,TM.Training_name,EI.Dept_Name,EI.Dept_Name,
		EI.Desig_Name,EI.Branch_Name,((DATEDIFF(DAY,TST.From_date,TST.To_date))+1)NO_Of_days,Training_Code,
		TP.Provider_Name,TP.Training_InstituteCode,TP.Training_InstituteName,TP.Institute_LocationCode,
		TP.Faculty_Name,TP.Provider_Type,TM.Training_Cordinator,TM.Training_Director,TE.Emp_ID,
		TM.Training_description,TST.From_date,TST.To_date,TA.Training_App_ID
	from T0120_HRMS_TRAINING_APPROVAL TA WITH (NOLOCK)
		INNER JOIN T0040_Hrms_Training_master TM WITH (NOLOCK) on TA.Training_ID=TM.Training_id
		INNER JOIN T0130_HRMS_TRAINING_EMPLOYEE_DETAIL TE WITH (NOLOCK) ON TE.Training_Apr_ID = TA.Training_Apr_ID
		INNER JOIN #Emp_Cons EC on TE.Emp_ID=EC.Emp_ID 
		INNER join V0080_EMP_MASTER_INCREMENT_GET EI on EI.Emp_ID=EC.Emp_ID 
		LEFT JOIN
		(
			SELECT MIN(From_date)From_date,MAX(To_date)To_date,Training_App_ID
			FROM   T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
			GROUP  BY Training_App_ID
		)TST on TST.Training_App_ID = TA.Training_App_ID
	left join V0050_HRMS_Training_Provider_master TP on TA.Training_Pro_ID=TP.Training_Pro_ID	
	where TA.Cmp_Id=@Cmp_ID and TST.From_date >=@From_Date and TST.To_date <= @To_Date
		And Isnull(TA.Training_Apr_ID,0) = isnull(@Training_ID ,Isnull(TA.Training_Apr_ID,0))
	
	select TS.From_date,TS.To_date,TS.From_Time,TS.To_Time,TS.Training_App_ID from T0120_HRMS_TRAINING_Schedule TS WITH (NOLOCK)
	inner join T0120_HRMS_TRAINING_APPROVAL TA WITH (NOLOCK) on TA.Training_App_ID=TS.Training_App_ID
	where TS.Cmp_Id=@Cmp_ID and TS.From_date >=@From_Date and TS.To_date <= @To_Date
		And Isnull(TA.Training_Apr_ID,0) = isnull(@Training_ID ,Isnull(TA.Training_Apr_ID,0))
END

