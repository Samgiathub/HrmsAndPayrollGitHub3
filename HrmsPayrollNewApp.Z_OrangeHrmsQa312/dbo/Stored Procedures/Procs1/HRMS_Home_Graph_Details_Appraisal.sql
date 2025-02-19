

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[HRMS_Home_Graph_Details_Appraisal]
	 @Cmp_ID    numeric(18,0)
	,@from_date datetime 
	,@to_date   datetime 	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	
	CREATE TABLE #achievement_tbl
	(
		 Achievement			varchar(200)
		,RangeId				numeric(18,0)
		,PercentageAllocated	numeric(18,2)
		,ActualAllocation		numeric(18,2)
		,TotalEmp				numeric(18,0)
	)
	
	INSERT INTO #achievement_tbl(Achievement,RangeId)
	SELECT A.Achievement_Level,A.AchievementId
	FROM  T0040_Achievement_Master A WITH (NOLOCK)
	INNER JOIN (
				 SELECT MAX(isnull(Effective_Date,C.From_Date))Effective_Date,Achievement_Level
				 FROM T0040_Achievement_Master WITH (NOLOCK)
				 INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON C.Cmp_Id= T0040_Achievement_Master.Cmp_ID
				 WHERE Achievement_Type  = 2 
					   and T0040_Achievement_Master.Cmp_ID = @Cmp_ID and isnull(Effective_Date,C.From_Date)<=@from_date
				 GROUP by Achievement_Level
			  )A1 on A1.Effective_Date = A.Effective_Date AND a1.Achievement_Level = A.Achievement_Level
	WHERE Cmp_ID = @Cmp_ID AND A.Achievement_Type = 2 
	ORDER by A.Achievement_Sort
	
	UPDATE #achievement_tbl
	SET PercentageAllocated = RA.Avg_Percent_Allocate
	FROM ( 
			SELECT SUM(Percent_Allocate) sum_Percent_Allocate,SUM(Percent_Allocate)/COUNT(1) Avg_Percent_Allocate,Range_ID
			FROM T0050_HRMS_RangeDept_Allocation RA WITH (NOLOCK)
			INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON C.Cmp_Id= RA.Cmp_ID
			INNER JOIN #achievement_tbl AT ON AT.RangeId = RA.Range_ID
			WHERE RA.Cmp_ID = @Cmp_ID	
			GROUP BY Range_ID
		)RA
	WHERE RangeId = RA.Range_ID 
	
	CREATE table #empAch_table
	(
		 emp_id		numeric(18,0)
		 ,Avg_Score numeric(18,2)
		,range_id	numeric(18,0)
		,achieveId	numeric(18,0)
		,dept_Id	numeric(18,0)
		,grd_id		numeric(18,0)
	)
	
	INSERT INTO #empAch_table(Avg_Score,emp_id,dept_Id,grd_id)
	SELECT IA.avg_score,IA.Emp_Id,I.Dept_ID,I.Grd_ID
	FROM (
			SELECT SUM(Overall_Score)Overall_Score,SUM(Overall_Score)/COUNT(1) avg_score,Emp_Id
			FROM  T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
			WHERE Cmp_ID = @Cmp_ID AND SA_Startdate >= @from_date AND SA_Startdate <= @to_date
			GROUP BY Emp_Id 
		 )IA
	INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = IA.Emp_Id
	INNER JOIN (
					SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
					FROM T0095_INCREMENT WITH (NOLOCK)
					INNER JOIN (
									SELECT MAX(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
									FROM  T0095_INCREMENT WITH (NOLOCK)
									WHERE Increment_Effective_Date <= @from_date
									GROUP by Emp_ID
								)I2 on I2.Emp_ID = T0095_INCREMENT.Emp_ID
					WHERE Cmp_ID = @Cmp_ID
					GROUP BY T0095_INCREMENT.Emp_ID
				)I1 ON I1.Increment_ID = I.Increment_ID AND I1.Emp_ID = I.Emp_ID
				
	UPDATE #empAch_table
	SET range_id = RM2.Range_ID
	   ,achieveId = RM2.AchievementId
	FROM
	(	 
		SELECT RM.Range_ID,A.AchievementId,RM.Range_From,RM.Range_To,RM.Range_Dept,RM.Range_Grade
		FROM T0040_HRMS_RangeMaster RM WITH (NOLOCK)
		INNER JOIN (
						SELECT ISNULL(MAX(Effective_Date),C.From_Date)Effective_Date,Range_ID
						FROM T0040_HRMS_RangeMaster WITH (NOLOCK)
						INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON c.Cmp_Id = T0040_HRMS_RangeMaster.Cmp_ID
						WHERE T0040_HRMS_RangeMaster.Cmp_ID = @cmp_id AND Range_Type=2
							  AND ISNULL(Effective_Date,C.From_Date) <= @from_date
						GROUP BY Range_ID,From_Date
					)RM1 ON RM1.Effective_Date = RM.Effective_Date AND RM1.Range_ID = RM.Range_ID
		INNER JOIN T0040_Achievement_Master A WITH (NOLOCK) on A.AchievementId = RM.Range_AchievementId
		WHERE RM.Range_Type = 2
	)RM2
	WHERE RM2.Range_From <= Avg_Score and RM2.Range_To >= Avg_Score
	AND CAST(dept_Id AS VARCHAR) IN (SELECT Data FROM dbo.Split(Range_Dept,'#'))
	AND CAST(grd_id AS VARCHAR) IN (SELECT Data FROM dbo.Split(Range_Grade,'#'))
	
	DECLARE @cntemp AS INT
	SELECT @cntemp = COUNT(1) FROM #empAch_table

	UPDATE #achievement_tbl
	SET ActualAllocation =ISNULL(q.actallocated,0),
	    TotalEmp = isnull(q.noofemp,0)
	FROM (
			SELECT ((count(1)*100)/@cntemp) actallocated,count(1) noofemp,achieveId
			FROM  #empAch_table	
			GROUP by achieveId
		)q
	WHERE RangeId = q.achieveId
	
	--SELECT * FROM #empAch_table
	SELECT Achievement,RangeId,ISNULL(PercentageAllocated,0)PercentageAllocated,ISNULL(ActualAllocation,0) ActualAllocation,isnull(TotalEmp,0)TotalEmp
	FROM  #achievement_tbl
	
	
	---------------for performance attributes------------------
	CREATE table #AttTable_Per
	(
		 PA_Title		varchar(1000)
		,PA_ID			numeric(18,0)
		,PA_DeptId		varchar(max)
		,AvgScoreAch	numeric(18,2)
	)
	
	INSERT INTO #AttTable_Per (PA_Title,PA_ID,PA_DeptId)
	SELECT	LEFT(dbo.RemoveCharSpecialSymbolValue(Am.PA_Title),50)PA_Title,Am.PA_ID,Am.PA_DeptId
	FROM  T0040_HRMS_AttributeMaster Am WITH (NOLOCK)
	INNER JOIN (
					SELECT MAX(ISNULL(PA_EffectiveDate,C.From_Date))PA_EffectiveDate,PA_ID
					FROM T0040_HRMS_AttributeMaster WITH (NOLOCK)
					INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON c.Cmp_Id = T0040_HRMS_AttributeMaster.Cmp_ID
					WHERE C.Cmp_Id = @Cmp_ID AND PA_Type = 'PA' AND ISNULL(PA_EffectiveDate,From_Date) <= @from_date
					GROUP BY PA_ID
			  )Am1 ON  Am.PA_ID = Am1.PA_ID
	WHERE Cmp_ID = @Cmp_ID and PA_Type = 'PA'
	
	UPDATE #AttTable_Per
	SET AvgScoreAch = cast(isnull(k.AvgScore,0) as numeric(18,2))
	FROM
	(
		SELECT ISNULL(SUM(AFF.avgscore),0)/isnull(COUNT(1),0) AvgScore,AFF.PA_ID
		FROM
		(
				SELECT DISTINCT I.Emp_Id,isnull(AF.avgscore,0)avgscore,AM.PA_ID
				FROM T0050_HRMS_InitiateAppraisal I WITH (NOLOCK)
				INNER JOIN (
								SELECT SUM(Att_Achievement)/count(1) avgscore,PA_ID,Emp_Id
								FROM  T0052_HRMS_AttributeFeedback WITH (NOLOCK)
								WHERE Att_Type ='PA'
								GROUP BY PA_ID,Emp_Id
							)AF ON AF.Emp_Id = I.Emp_Id
				INNER JOIN T0040_HRMS_AttributeMaster AM WITH (NOLOCK) ON AM.PA_ID = AF.PA_ID
				WHERE I.Cmp_ID = @Cmp_ID AND SA_Startdate >= @from_date AND SA_Startdate <= @to_date
				
		)AFF
		GROUP BY AFF.PA_ID
	)K
	WHERE k.PA_ID = #AttTable_Per.PA_ID
	
	SELECT PA_Title,PA_ID,PA_DeptId,isnull(AvgScoreAch,0) AvgScoreAch
	FROM #AttTable_Per 
	
	---------------for potential attributes------------------
	DELETE FROM #AttTable_Per
	
	INSERT INTO #AttTable_Per (PA_Title,PA_ID,PA_DeptId)
	SELECT	LEFT(dbo.RemoveCharSpecialSymbolValue(Am.PA_Title),50)PA_Title,Am.PA_ID,Am.PA_DeptId
	FROM  T0040_HRMS_AttributeMaster Am WITH (NOLOCK)
	INNER JOIN (
					SELECT MAX(ISNULL(PA_EffectiveDate,C.From_Date))PA_EffectiveDate,PA_ID
					FROM T0040_HRMS_AttributeMaster WITH (NOLOCK)
					INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON c.Cmp_Id = T0040_HRMS_AttributeMaster.Cmp_ID
					WHERE C.Cmp_Id = @Cmp_ID AND PA_Type = 'PoA' AND ISNULL(PA_EffectiveDate,From_Date) <= @from_date
					GROUP BY PA_ID
			  )Am1 ON  Am.PA_ID = Am1.PA_ID
	WHERE Cmp_ID = @Cmp_ID and PA_Type = 'PoA'
	
	UPDATE #AttTable_Per
	SET AvgScoreAch = isnull(k.AvgScore,0)
	FROM
	(
		SELECT ISNULL(SUM(AFF.avgscore),0)/isnull(COUNT(1),0) AvgScore,AFF.PA_ID
		FROM
		(
				SELECT DISTINCT I.Emp_Id,isnull(AF.avgscore,0)avgscore,AM.PA_ID
				FROM T0050_HRMS_InitiateAppraisal I WITH (NOLOCK)
				INNER JOIN (
								SELECT SUM(Att_Achievement)/count(1) avgscore,PA_ID,Emp_Id
								FROM  T0052_HRMS_AttributeFeedback WITH (NOLOCK)
								WHERE Att_Type ='PoA'
								GROUP BY PA_ID,Emp_Id
							)AF ON AF.Emp_Id = I.Emp_Id
				INNER JOIN T0040_HRMS_AttributeMaster AM WITH (NOLOCK) ON AM.PA_ID = AF.PA_ID
				WHERE I.Cmp_ID = @Cmp_ID AND SA_Startdate >= @from_date AND SA_Startdate <= @to_date
				
		)AFF
		GROUP BY AFF.PA_ID
	)K
	WHERE k.PA_ID = #AttTable_Per.PA_ID
	
	
	SELECT PA_Title,PA_ID,PA_DeptId,isnull(AvgScoreAch,0) AvgScoreAch
	FROM #AttTable_Per 
		
	
	DROP TABLE  #achievement_tbl
	DROP TABLE #empAch_table
	DROP TABLE #AttTable_Per

END

