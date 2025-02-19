
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Rpt_Increment_Utility_CTC_EmployeeWise]
	@Cmp_ID			Numeric
	,@From_Date			Datetime 
	,@To_Date			Datetime
	,@Branch_ID			varchar(Max) 
	,@Cat_ID			varchar(Max)
	,@Grd_ID			varchar(Max) 
	,@Type_ID			varchar(Max) 
	,@Dept_ID			varchar(Max) 
	,@Desig_ID			varchar(Max)
	,@Emp_ID			Numeric
	,@Constraint		varchar(MAX)=''
	,@Utility_Date		Datetime
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID		numeric , 
	   Branch_id	NUMERIC,
	   Increment_ID numeric    
	 ) 
	 
	IF @Constraint =''
		BEGIN
			EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 
		END
	ELSE
		BEGIN
			INSERT INTO #Emp_Cons
			SELECT Emp_id,Branch_ID,Increment_ID
			FROM  V0080_EMP_MASTER_INCREMENT_GET
			WHERE Cmp_ID = @Cmp_Id	AND Emp_ID IN (SELECT data FROM dbo.Split(@Constraint,'#'))
		END

	CREATE TABLE #Emp_CTC_Report
	(
		 Emp_Id		    NUMERIC(18,0)
		,Emp_Full_Name	VARCHAR(200)
		,Doj			DATETIME
		,Desig_Id		NUMERIC(18,0)
		,Desig_Name		VARCHAR(100)
		,Dept_Id		NUMERIC(18,0)
		,Dept_Name		VARCHAR(100)
		,Branch_Id		NUMERIC(18,0)
		,Branch_Name	VARCHAR(100)
		,Grd_Id			NUMERIC(18,0)
		,Grd_Name		VARCHAR(100)
		,Segment_Id		NUMERIC(18,0)
		,Segment_Name	VARCHAR(100)
		,Qualification  VARCHAR(800)
		,Current_CTC    NUMERIC(18,2)
		,Probable_CTC	NUMERIC(18,2)
		,Achivemnet_Id	NUMERIC(18,2)
		,Achivement_Name VARCHAR(100)
		,IncrementAmt	NUMERIC(18,2)
	)
	
	
	
	INSERT INTO #Emp_CTC_Report(Emp_Id,Emp_Full_Name,Doj,Desig_Id,Desig_Name,Dept_Id,Dept_Name,Branch_Id,Branch_Name,
						Segment_Id,Segment_Name,Qualification,Current_CTC,Grd_Id,Grd_Name)
	SELECT e.Emp_ID,(EM.Alpha_Emp_Code +'-'+ EM.Emp_Full_Name),EM.Date_Of_Join,I.Desig_Id,DG.Desig_Name,I.Dept_Id,D.Dept_Name,I.Branch_ID,I.Branch_Name,
					I.Segment_ID,BS.Segment_Name,EQ.Qual_Name,I.CTC,I.Grd_ID,G.Grd_Name
	FROM   #Emp_Cons E INNER JOIN
		   T0080_EMP_MASTER EM WITH (NOLOCK) on Em.Emp_ID = E.Emp_ID INNER JOIN
		   V0080_EMP_MASTER_INCREMENT_GET I on I.Increment_ID = E.Increment_ID LEFT JOIN
		   T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = I.Desig_Id LEFT JOIN
		   T0030_BRANCH_MASTER B WITH (NOLOCK)  on B.Branch_ID = I.Branch_ID LEFT JOIN
		   T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on D.Dept_Id = I.Dept_ID LEFT JOIN
		   T0040_Business_Segment BS WITH (NOLOCK) on BS.Segment_ID = I.Segment_ID LEFT JOIN
		   T0040_GRADE_MASTER G WITH (NOLOCK) on g.Grd_ID = I.Grd_ID LEFT JOIN
				  (
					SELECT a.Emp_ID, Qual_Name = 
						STUFF((SELECT ', ' + cast(Q.Qual_Name as VARCHAR)
							   FROM T0090_EMP_QUALIFICATION_DETAIL b WITH (NOLOCK) LEFT JOIN
								    T0040_QUALIFICATION_MASTER Q WITH (NOLOCK) on Q.Qual_ID = b.qual_id
							   WHERE b.Emp_ID = a.Emp_ID 
							  FOR XML PATH('')), 1, 2, '')
					FROM T0090_EMP_QUALIFICATION_DETAIL a WITH (NOLOCK)
					WHERE a.Cmp_ID =   cast(@Cmp_ID as VARCHAR)
					GROUP BY a.Emp_ID
				  )	EQ ON eq.Emp_ID = E.Emp_ID
	
	
	
	UPDATE #Emp_CTC_Report
	SET Probable_CTC = e.ProbableAmount
		,Achivemnet_Id = e.Achivement_Id
		,Achivement_Name = e.Achievement_Level
		,IncrementAmt = E.Amount
	FROM (
			SELECT EC.Emp_Id,(EC.Current_CTC + IU.Amount)ProbableAmount,IA.Achivement_Id,A.Range_Level as Achievement_Level,IU.Amount
			FROM #Emp_CTC_Report EC INNER JOIN
				 T0052_Increment_Utility IU WITH (NOLOCK) on IU.Segment_ID = EC.Segment_Id AND 
												IU.Grd_Id = EC.Grd_Id INNER JOIN
				 T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON EC.Emp_Id = IA.Emp_Id INNER JOIN
				 (
					SELECT MAX(SA_Startdate)SA_Startdate,Emp_Id
					FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
					WHERE SA_Startdate <= @Utility_Date
					GROUP BY Emp_Id
				 )IA1 ON IA.SA_Startdate = IA.SA_Startdate and IA.Emp_Id = IA1.Emp_Id INNER JOIN
				 T0040_HRMS_RangeMaster A WITH (NOLOCK) on A.Range_ID = iA.Achivement_Id
			WHERE IU.EffectiveDate = @Utility_Date and A.Range_AchievementId = IU.Achivement_Id
				and EC.Segment_Id is not null and EC.Grd_Id is NOT NULL AND IA.Achivement_Id is NOT NULL
		)E  
	WHERE	#Emp_CTC_Report.Emp_Id = E.Emp_Id
		
		
		
	SELECT Emp_Full_Name	as 'Employee Name'
		   ,Branch_Name		as 'Branch'
		   ,CONVERT(varchar(15), Doj,106) as 'Doj'
		   ,Grd_Name		as 'Grade'
	       ,Desig_Name		as 'Designation'
	       ,Dept_Name		as 'Department'	
	       ,Qualification
	       ,Achivement_Name as 'Achievement'
	       ,Segment_Name	as 'Segment'
	       ,Current_CTC     as 'Current CTC'
	       ,Probable_CTC    as 'Probable CTC'
	       ,IncrementAmt	as 'Increment Amount'
	FROM  #Emp_CTC_Report		   
	--WHERE	   Segment_Id is not null and Grd_Id is NOT NULL 	
	
	DROP TABLE #Emp_CTC_Report
END
