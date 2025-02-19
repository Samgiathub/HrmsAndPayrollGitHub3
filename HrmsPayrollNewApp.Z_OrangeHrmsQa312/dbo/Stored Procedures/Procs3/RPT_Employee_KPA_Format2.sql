

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[RPT_Employee_KPA_Format2]
	 @Cmp_ID		Numeric
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
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN   
   
	CREATE TABLE #Emp_Cons 
	(      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	) 
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 
	UPDATE #Emp_Cons  set Branch_ID = a.Branch_ID from (
		SELECT DISTINCT VE.Emp_ID,VE.branch_id,VE.Increment_ID 
					  FROM dbo.V_Emp_Cons VE INNER JOIN
					  #Emp_Cons EC on  VE.Emp_ID = EC.Emp_ID
		)a
	WHERE a.Emp_ID = #Emp_Cons.Emp_ID 
	
	CREATE Table #Table_1
	(
		 Emp_id				numeric(18,0)
		,Alpha_emp_code		varchar(50)
		,Emp_full_name		varchar(100)
		,Employee			varchar(150)
		,Branch				varchar(100)
		,Department			varchar(100)
		,Designation		varchar(100)
		,Grade				varchar(100)
		,DateOfJoin			datetime
		,TotalExperience	varchar(100)
		,From_Date			datetime
		,To_Date			datetime
		,Cmp_name			varchar(100)
		,cmp_Address		varchar(200)
		,cmp_logo			image
	)

	INSERT INTO #Table_1(Emp_id,Alpha_emp_code,Emp_full_name,Employee,Branch,Department,Designation,Grade,
				DateOfJoin,TotalExperience,From_Date,To_Date,Cmp_name,cmp_Address,cmp_logo)
	SELECT E.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,(EM.Alpha_Emp_Code +'-'+ EM.Emp_Full_Name),B.Branch_Name,
			D.Dept_Name,DG.Desig_Name,EM.Grd_ID,EM.Date_Of_Join,
			CASE WHEN cast(floor(datediff(DAY, EM.Date_Of_Join, getdate())  / 365) as varchar)<>0 then cast(floor(datediff(DAY, EM.Date_Of_Join, getdate())  / 365) as varchar) + ' years ' else '' end +
			CASE WHEN cast(floor(datediff(DAY, EM.Date_Of_Join, getdate())  % 365 / 30) as varchar)<>0 then cast(floor(datediff(DAY, EM.Date_Of_Join, getdate())  % 365 / 30) as varchar) + ' months ' else '' end +
			CASE WHEN cast(datediff(DAY, EM.Date_Of_Join, getdate())  % 30 as varchar)<>0 then cast(datediff(DAY, EM.Date_Of_Join, getdate())  % 30 as varchar) + ' days' else '' end,
			@From_Date,@To_Date,C.Cmp_Name,c.Cmp_Address,C.cmp_logo 
	FROM  #Emp_Cons E 
	INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON E.Emp_ID = EM.Emp_ID
	INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = EM.Emp_ID
	INNER JOIN (
					SELECT MAX(Increment_ID)Increment_ID, T0095_INCREMENT.Emp_ID
					FROM T0095_INCREMENT WITH (NOLOCK) 
					INNER JOIN (	
									SELECT MAX(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
									FROM T0095_INCREMENT WITH (NOLOCK)
									WHERE Increment_Effective_Date <= @From_Date
									GROUP BY Emp_ID
								)I2 ON I2.Emp_ID = T0095_INCREMENT.Emp_ID
					WHERE Cmp_ID = @Cmp_ID
					GROUP BY T0095_INCREMENT.Emp_ID
				)I1 ON I1.Increment_ID = I.Increment_ID
	LEFT JOIN T0030_BRANCH_MASTER B WITH (NOLOCK) ON B.Branch_ID = I.Branch_ID
	LEFT JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) ON D.Dept_Id = I.Dept_ID
	LEFT JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = I.Desig_Id
	LEFT JOIN T0040_GRADE_MASTER G WITH (NOLOCK) ON G.Grd_ID = I.Grd_ID
	INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON C.Cmp_Id = EM.Cmp_ID

	CREATE Table #Table_2
	(		
	   Emp_Id			numeric(18,0)
	  ,EffectiveDate	datetime
	  ,Emp_KPAId		numeric(18,0)
	  ,KPA_Content	    varchar(1000)
	  ,KPA_Target		varchar(1000)
	  ,KPA_Weightage	numeric(18,2)
	)

	INSERT INTO #Table_2
	SELECT E.Emp_ID,EKPA.Effective_Date,EKPA.Emp_KPA_Id,EKPA.KPA_Content,EKPA.KPA_Target,EKPA.KPA_Weightage
	FROM  #Emp_Cons E 
	INNER JOIN T0060_Appraisal_EmployeeKPA EKPA WITH (NOLOCK) ON EKPA.Emp_Id = E.Emp_ID
	INNER JOIN (
					SELECT MAX(Effective_Date)Effective_Date,Emp_Id
					FROM T0060_Appraisal_EmployeeKPA WITH (NOLOCK)
					WHERE Effective_Date >= @From_Date AND Effective_Date <= @To_Date AND ISNULL(status,1) = 1
					GROUP BY Emp_Id
				)EKPA1 ON EKPA.Emp_Id = EKPA1.Emp_Id AND EKPA.Effective_Date = EKPA1.Effective_Date 

	CREATE Table #Table_3
	(
		 Emp_Id				numeric(18,0)
		,InitiateId			numeric(18,0)
		,SA_StartDate		datetime
		,SA_EndDate			datetime
		,AppraisalType		Varchar(50)
		,Duration			varchar(100)
		,ReportingManager	varchar(100)
		,HODName			varchar(100)
		,GHName				varchar(100)
	)

	INSERT INTO #Table_3(Emp_Id,InitiateId,SA_StartDate,SA_EndDate,AppraisalType,Duration,ReportingManager,HODName,GHName)
	SELECT E.Emp_ID,I.InitiateId,I.SA_Startdate,I.SA_Enddate,
		   CASE WHEN isnull(I.Final_Evaluation,1) = 0 THEN 'Interim' WHEN ISNULL(i.Final_Evaluation,1)= 1 THEN 'Final' END,
		   (DateName(month, DateAdd(month,I.Duration_FromMonth,-1))+ ' - ' + DateName(month, DateAdd(month,I.Duration_ToMonth,-1))),(ERE.Alpha_Emp_Code +'-'+ ERE.Emp_Full_Name),
		   (HODE.Alpha_Emp_Code +'-'+ HODE.Emp_Full_Name),(GHE.Alpha_Emp_Code +'-'+ GHE.Emp_Full_Name)
	FROM #Emp_Cons E 
	INNER JOIN T0050_HRMS_InitiateAppraisal I WITH (NOLOCK) ON I.Emp_Id = E.Emp_ID
	INNER JOIN T0090_EMP_REPORTING_DETAIL ER WITH (NOLOCK) ON ER.Emp_ID = E.Emp_ID
	INNER JOIN (
					SELECT MAX(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID
					FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
					INNER JOIN (
									SELECT MAX(Effect_Date)Effect_Date,Emp_ID
									FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
									GROUP BY Emp_ID
							   )ER2 ON ER2.Emp_ID = T0090_EMP_REPORTING_DETAIL.Emp_ID
					GROUP BY T0090_EMP_REPORTING_DETAIL.Emp_ID
				)ER1 ON ER.Emp_ID = ER1.Emp_ID AND ER.Row_ID = ER1.Row_ID
	LEFT JOIN T0080_EMP_MASTER ERE WITH (NOLOCK) ON ERE.Emp_ID = ER.R_Emp_ID
	LEFT JOIN T0080_EMP_MASTER HODE WITH (NOLOCK) ON HODE.Emp_ID = I.HOD_Id
	LEFT JOIN T0080_EMP_MASTER GHE WITH (NOLOCK) ON GHE.Emp_ID = I.HOD_Id
	WHERE I.SA_Startdate >= @From_Date AND I.SA_Startdate <= @To_Date

	CREATE Table #Table_4
	(
		 Emp_Id				numeric(18,0)
		,InitiateId			numeric(18,0)
		,KPA_Id				numeric(18,0)
		,KPA_Content		varchar(1000)
		,KPA_Target			varchar(1000)
		,KPA_Weightage		numeric(18,2)
		,KPA_Achievement	numeric(18,2)
		,Emp_Achievement	numeric(18,2)
		,RM_Achievement		numeric(18,2)
		,KPA_Critical		varchar(1000)
	)

	INSERT INTO #Table_4(Emp_Id,InitiateId,KPA_Id,KPA_Content,KPA_Target,KPA_Weightage,KPA_Achievement,Emp_Achievement,RM_Achievement,KPA_Critical)
	SELECT I.Emp_Id,I.InitiateId,IK.KPA_ID,IK.KPA_Content,IK.KPA_Target,IK.KPA_Weightage,
		   IK.KPA_Achievement,IK.KPA_AchievementEmp,IK.KPA_AchievementRM,IK.KPA_Critical	
	FROM   #Table_3 I 
	INNER JOIN T0052_HRMS_KPA IK WITH (NOLOCK) ON IK.InitiateId = I.InitiateId AND I.Emp_Id = IK.Emp_Id


	SELECT Emp_id,Alpha_emp_code,Emp_full_name,Employee,Branch,Department,Designation,Grade,CONVERT(VARCHAR(12),DateOfJoin,103)DateOfJoin,
			TotalExperience,CONVERT(VARCHAR(12),From_Date,103)From_Date,CONVERT(VARCHAR(12),To_Date,103) To_Date,Cmp_name,cmp_Address,cmp_logo 
	FROM #Table_1
	SELECT Emp_Id,CONVERT(VARCHAR(12),EffectiveDate,103)EffectiveDate,Emp_KPAId,KPA_Content,KPA_Target,KPA_Weightage 
	FROM #Table_2	
	SELECT Emp_Id,InitiateId,CONVERT(VARCHAR(12),SA_StartDate,103)SA_StartDate,CONVERT(VARCHAR(12),SA_EndDate,103)SA_EndDate,AppraisalType,Duration,ReportingManager,isnull(HODName,'')HODName,ISNULL(GHName,'')GHName
	FROM #Table_3
	SELECT Emp_Id,InitiateId,KPA_Id,KPA_Content,KPA_Target,KPA_Weightage,KPA_Achievement,Emp_Achievement,RM_Achievement,KPA_Critical
	FROM #Table_4
	SELECT	SUM(KPA_Achievement)KPA_Achievement,#Table_4.InitiateId,#Table_4.Emp_Id
		   ,CASE WHEN AppraisalType = 'Interim' THEN AppraisalType +'-'+ CAST(ROW_NUMBER() OVER (order by #Table_4.InitiateId) AS VARCHAR)
			ELSE AppraisalType END AS AppraisalType
	FROM   #Table_4 
	INNER JOIN #Table_3 on #Table_3.InitiateId = #Table_4.InitiateId
	GROUP BY #Table_4.InitiateId,#Table_4.Emp_Id,AppraisalType
	ORDER BY InitiateId


	DROP TABLE #Table_1
	DROP TABLE #Table_2
	DROP TABLE #Table_3
	DROP TABLE #Table_4
END

