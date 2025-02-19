


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	exec Rpt_EmployeeSelfAssessment_Score @Cmp_ID=9,@From_Date='2016-01-01 00:00:00',@To_Date='2017-03-30 00:00:00',@Branch_ID='0',@Cat_ID='0',@Grd_ID='0',@Type_ID='0',@Dept_ID='0',@Desig_ID='0',@Emp_ID=0,@Constraint=''
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Rpt_EmployeeSelfAssessment_Score]
	 @cmp_id        numeric(18,0)
	,@From_Date     datetime 
	,@To_Date       datetime = getdate
	,@Branch_ID		varchar(Max) 
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max) 
	,@Type_ID		varchar(Max) 
	,@Dept_ID		varchar(Max)
	,@Desig_ID		varchar(Max)
	,@Emp_ID		Numeric(18,0)
	,@Constraint	varchar(MAX)=''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
   
    CREATE TABLE #Emp_Cons 
	 (      
		   Emp_ID numeric ,  
		   Branch_ID numeric, 
		   Increment_ID numeric    
	 )  
	 
	 IF @Constraint <> ''
		BEGIN
			Insert Into #Emp_Cons(Emp_ID)
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		END
	 ELSE
		EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 
		
	CREATE TABLE #Final_Table
	(
		 Emp_Id					NUMERIC(18,0)
		,EmpCode				VARCHAR(100)
		,Emp_Full_Name			VARCHAR(100)
		,AppraisalDate			DATETIME
		,SelfAssessmentContent	VARCHAR(Max)
		,Emp_Score				NUMERIC(18,2)
		,Manager_Score			NUMERIC(18,2)
		,Weightage				NUMERIC(18,2)
		,Answer					VARCHAR(2500)
	)
	
	--check whether criteria is activated or not
	DECLARE @criteria_flag AS INT =1
	
	SELECT @criteria_flag= isnull(L.SA_SubCriteria,0)
	FROM  T0050_AppraisalLimit_Setting L WITH (NOLOCK) INNER JOIN
		  (
			SELECT	max(L2.Limit_Id)Limit_Id
			FROM T0050_AppraisalLimit_Setting WITH (NOLOCK) INNER JOIN
				 (
					SELECT max(Effective_Date)Effective_Date,Limit_Id
					from T0050_AppraisalLimit_Setting WITH (NOLOCK)
					WHERE Cmp_ID = @cmp_id	 and Effective_Date >= @From_Date and Effective_Date <= @To_Date
					GROUP by Limit_Id
				 )L2 on l2.Limit_Id = T0050_AppraisalLimit_Setting.Limit_Id
			WHERE Cmp_ID = @cmp_id	  
		  )L1 on L1.Limit_Id = L.Limit_Id
	WHERE L.Cmp_ID = @cmp_id
	
	--print @criteria_flag
	
	IF @criteria_flag = 1
		BEGIN	
			INSERT INTO #Final_Table
			(Emp_Id,EmpCode,Emp_Full_Name,AppraisalDate,SelfAssessmentContent,Emp_Score,Manager_Score,Weightage,Answer)
			(
				 SELECT E.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,IE.SA_Startdate,SA.SApparisal_Content,SE.Emp_Score,SE.Manager_Score,SE.Weightage,isnull(SE.Answer,'')
				 FROM   #Emp_Cons E INNER JOIN
						T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = E.Emp_ID INNER JOIN
						T0050_HRMS_InitiateAppraisal IE WITH (NOLOCK) on IE.Emp_Id = E.Emp_ID INNER JOIN
						(
							SELECT MAX(Weightage)Weightage,MAX(Emp_Score)Emp_Score,MAX(Manager_Score)Manager_Score,SAppraisal_ID,InitiateId,Answer
							FROM   T0052_Emp_SelfAppraisal WITH (NOLOCK)
							WHERE  Cmp_ID = @cmp_id
							GROUP by SAppraisal_ID,InitiateId,Answer
						)SE on SE.InitiateId = IE.InitiateId INNER JOIN
						T0040_SelfAppraisal_Master SA WITH (NOLOCK) on SA.SApparisal_ID  = SE.SAppraisal_ID
				 WHERE  IE.SA_Startdate >= @From_Date and IE.SA_Startdate <= @To_Date
						AND EM.Cmp_ID = @cmp_id
			 )
		END
	ELSE
		BEGIN
			INSERT INTO #Final_Table
			(Emp_Id,EmpCode,Emp_Full_Name,AppraisalDate,SelfAssessmentContent,Emp_Score,Manager_Score,Weightage,Answer)
			(
				 SELECT E.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,IE.SA_Startdate,SA.SApparisal_Content,SE.Emp_Score,SE.Manager_Score,SE.Weightage,isnull(SE.Answer,'')
				 FROM   #Emp_Cons E INNER JOIN
						T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = E.Emp_ID INNER JOIN
						T0050_HRMS_InitiateAppraisal IE WITH (NOLOCK) on IE.Emp_Id = E.Emp_ID INNER JOIN
						(
							SELECT Weightage,Emp_Score,Manager_Score,SAppraisal_ID,InitiateId,Answer
							FROM   T0052_Emp_SelfAppraisal WITH (NOLOCK)
							WHERE  Cmp_ID = @cmp_id
							--GROUP by SAppraisal_ID,InitiateId
						)SE on SE.InitiateId = IE.InitiateId INNER JOIN
						T0040_SelfAppraisal_Master SA WITH (NOLOCK) on SA.SApparisal_ID  = SE.SAppraisal_ID 
				 WHERE  IE.SA_Startdate >= @From_Date and IE.SA_Startdate <= @To_Date
						AND EM.Cmp_ID = @cmp_id
			 )
		END
	
	
	--DECLARE @columns as VARCHAR(max)
	--SELECT @columns  = COALESCE(@columns + ',[' + SApparisal_Content + ']','[' + SApparisal_Content + ']')
	--FROM  (
	--				SELECT DISTINCT SApparisal_Content
	--				FROM T0040_SelfAppraisal_Master
	--			)t
	
	
	SELECT	[Employee Code], [Employee Name], [Appraisal Date], 
			DENSE_RANK() OVER (PARTITION BY Emp_ID ORDER BY  EmpCode, [Employee Code] DESC,SelfAssessmentContent)AS [Sr. No],
			SelfAssessmentContent,Answer,[Employee Score],[Manager Score],Weightage		
	FROM	(
				SELECT  CASE WHEN ROW_NUMBER() OVER (PARTITION BY EmpCode ORDER BY EmpCode)=1 then EmpCode else '' END as [Employee Code]
						,CASE WHEN ROW_NUMBER() OVER (PARTITION BY EmpCode ORDER BY EmpCode)=1 then Emp_Full_Name else '' END as [Employee Name]
						,CASE WHEN ROW_NUMBER() OVER (PARTITION BY EmpCode ORDER BY EmpCode)=1 then CONVERT(VARCHAR(12),AppraisalDate,105) else '' END as [Appraisal Date]
						,SelfAssessmentContent	
						,Answer
						,Emp_Score		as 'Employee Score'			
						,Manager_Score	as 'Manager Score'			
						,Weightage	
						,Emp_ID		
						,EmpCode	
				FROM  #Final_Table	
			) t
	--ORDER BY  EmpCode, [Employee Code] DESC
	DROP TABLE #Final_Table
END

