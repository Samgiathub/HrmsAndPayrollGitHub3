
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[rpt_Performance_Improvement_Letter]
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
		,@Achievement_ID varchar(MAX)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN	

	declare @query as varchar(max) 
	set @query =''
	--if @Achievement_ID =0
	--	set @Achievement_ID = NULL
	CREATE TABLE #Emp_Cons 
	 (      
		   Emp_ID numeric ,  
		   Branch_ID numeric, 
		   Increment_ID numeric 
	 )  
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 

	select EI.Alpha_Emp_Code,EI.Emp_Full_Name,EI.Dept_Name,EI.Dept_Name,
		EI.Desig_Name,EI.Branch_Name,HA.AppraiserId,HA.Emp_Id,HA.Achivement_Id,
		HA.SA_Startdate,ELR2.Reference_No,ELR2.Issue_Date,EI.Increment_Effective_Date
	from T0050_HRMS_InitiateAppraisal HA WITH (NOLOCK) INNER JOIN
			(
				SELECT MAX(AppraiserId)AppraiserId,Emp_ID
				FROM  T0050_HRMS_InitiateAppraisal WITH (NOLOCK) GROUP BY Emp_Id
			)HA1 on HA.AppraiserId=HA1.AppraiserId and HA.Emp_Id=HA1.Emp_Id
		INNER JOIN #Emp_Cons EC on HA.Emp_ID=EC.Emp_ID 
		INNER join V0080_EMP_MASTER_INCREMENT_GET EI on EI.Emp_ID=EC.Emp_ID Left Outer join
	 (SELECT ELR1.EMP_ID,MAX(ELR1.Tran_Id)Tran_Id,ELR1.Reference_No,ELR1.Issue_Date  
		 FROM		T0081_Emp_LetterRef_Details ELR1 WITH (NOLOCK) INNER JOIN
		(SELECT  MAX(Issue_Date) Issue_Date,EMP_ID  
			 FROM	 T0081_Emp_LetterRef_Details WITH (NOLOCK)
			 WHERE	 Issue_Date <= @To_Date AND CMP_ID =@CMP_ID and Letter_Name='Performance Improvement Letter'
			 GROUP BY EMP_ID)ELR ON ELR.EMP_ID = ELR1.EMP_ID and Letter_Name='Performance Improvement Letter' AND ELR.Issue_Date = ELR1.Issue_Date								 
		GROUP BY ELR1.EMP_ID,ELR1.Reference_No,ELR1.Issue_Date)ELR2 ON ELR2.Emp_ID = HA.Emp_ID
	where HA.Cmp_Id=@Cmp_ID and HA.SA_Startdate >=@From_Date and HA.SA_Enddate <= @To_Date and ISNULL(HA.Final_Evaluation,0)=1
	and ISNULL(HA.Achivement_Id,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (@Achievement_ID,'#'))
		
	--select TS.From_date,TS.To_date,TS.From_Time,TS.To_Time,TS.Training_App_ID from T0120_HRMS_TRAINING_Schedule TS
	--inner join T0120_HRMS_TRAINING_APPROVAL TA on TA.Training_App_ID=TS.Training_App_ID
	--where TS.Cmp_Id=@Cmp_ID and TS.From_date >=@From_Date and TS.To_date <= @To_Date
	--	And Isnull(TA.Training_Apr_ID,0) = isnull(@Training_ID ,Isnull(TA.Training_Apr_ID,0))
END

