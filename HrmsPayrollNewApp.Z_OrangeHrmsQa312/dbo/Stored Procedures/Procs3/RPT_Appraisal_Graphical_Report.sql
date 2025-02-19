

-- =============================================
-- Author:		MUKTI CHAUHAN	
-- Create date: 14-05-2018
-- Description: RPT_Appraisal_Graphical_Report
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[RPT_Appraisal_Graphical_Report]
	 @Cmp_ID		Numeric 
	,@From_Date		Datetime 
	,@To_Date		Datetime
	,@Grd_ID		varchar(Max)='' 	
	,@Dept_ID		varchar(Max)=''
	,@Branch_ID		varchar(Max)=''
	,@Desig_ID		varchar(Max)=''
	,@Constraint	varchar(MAX)=''		
	,@flag			varchar(50)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @columns VARCHAR(8000)
	DECLARE @query VARCHAR(MAX)
	
	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )  
	 
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,'',@Grd_ID,'',@Dept_ID,@Desig_ID,0,@constraint,0,0,'','','','',0,0,0,'0',0,0 
	
	DELETE FROM #Emp_Cons
	WHERE NOT EXISTS (
					select	 E.Emp_ID 
					from	#Emp_Cons as  E Inner JOIN T0095_INCREMENT as i WITH (NOLOCK) ON i.Increment_ID = E.Increment_ID
					where	 #Emp_Cons.Increment_ID = E.Increment_ID
					  --and EXISTS (select Data from dbo.Split(@PBranch_ID, ',') PB Where cast(PB.data as numeric)=Isnull(I.Branch_ID,0))
					  --and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))
					  --and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))
					  --AND  EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0))  					  
				)
	
	
	Update #Emp_Cons  set Branch_ID = a.Branch_ID from (
		SELECT DISTINCT VE.Emp_ID,VE.branch_id,VE.Increment_ID 
					  FROM dbo.V_Emp_Cons VE inner join
					  #Emp_Cons EC on  VE.Emp_ID = EC.Emp_ID
		)a
	where a.Emp_ID = #Emp_Cons.Emp_ID   	
	
	IF @FLAG=0  --GOAL_INITITION
		BEGIN		
			CREATE TABLE #GOAL_INITITION
			(
				[STATUS]  varchar(100),
				[TOTAL_EMPLOYEE] INT
			)
			
			INSERT INTO #GOAL_INITITION
			SELECT 'Not Initiated',count(1)
			FROM    #Emp_Cons
			WHERE Emp_ID NOT IN(SELECT Emp_ID FROM T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) WHERE KPA_StartDate <=@To_Date)
			
			INSERT INTO #GOAL_INITITION
			SELECT 'Initiated',count(1)
			FROM    #Emp_Cons
			WHERE Emp_ID IN(SELECT Emp_ID FROM T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) WHERE KPA_StartDate <=@To_Date)

			--INSERT INTO #GOAL_INITITION
			--SELECT 'Total Employee',COUNT(1)
			--FROM    #Emp_Cons
			
			SELECT * FROM #GOAL_INITITION
		END
	ELSE IF @flag=1
		BEGIN	
			CREATE TABLE #GOAL_STATUS
			(
			[SR.NO] INT,
			[STATUS] VARCHAR(100),
			[TOTAL_EMPLOYEE] INT			 
			)
			
			INSERT #GOAL_STATUS([SR.NO],[STATUS],[TOTAL_EMPLOYEE])
			VALUES (1,'Not Submitted',0)
			INSERT #GOAL_STATUS([SR.NO],[STATUS],[TOTAL_EMPLOYEE])
			VALUES (2,'Draft',0)
			INSERT #GOAL_STATUS([SR.NO],[STATUS],[TOTAL_EMPLOYEE])
			VALUES (3,'Submitted By Employee',0) 
			INSERT #GOAL_STATUS([SR.NO],[STATUS],[TOTAL_EMPLOYEE])
			VALUES (4,'Approved By Manager',0) 
			INSERT #GOAL_STATUS([SR.NO],[STATUS],[TOTAL_EMPLOYEE])
			VALUES (5,'Final Approved',0) 
			
			UPDATE #GOAL_STATUS 
					SET [TOTAL_EMPLOYEE]=(SELECT COUNT(KPA_InitiateId) FROM T0055_Hrms_Initiate_KPASetting HK WITH (NOLOCK)
					INNER JOIN #Emp_Cons EC ON HK.Emp_Id=EC.Emp_ID
					WHERE KPA_StartDate >= @From_Date and  KPA_StartDate <=@To_Date and Initiate_Status=4 
					)
			WHERE [SR.NO]=1
			
			UPDATE #GOAL_STATUS 
					SET [TOTAL_EMPLOYEE]=(SELECT COUNT(KPA_InitiateId) FROM T0055_Hrms_Initiate_KPASetting HK WITH (NOLOCK)
					INNER JOIN #Emp_Cons EC ON HK.Emp_Id=EC.Emp_ID
					WHERE KPA_StartDate >= @From_Date and  KPA_StartDate <=@To_Date and Initiate_Status=0
					)
			WHERE [SR.NO]=2
			
			UPDATE #GOAL_STATUS 
					SET [TOTAL_EMPLOYEE]=(SELECT COUNT(KPA_InitiateId) FROM T0055_Hrms_Initiate_KPASetting HK WITH (NOLOCK)
					INNER JOIN #Emp_Cons EC ON HK.Emp_Id=EC.Emp_ID
					WHERE KPA_StartDate >= @From_Date and  KPA_StartDate <=@To_Date and Initiate_Status=2
					)
			WHERE [SR.NO]=3
			
			UPDATE #GOAL_STATUS 
					SET [TOTAL_EMPLOYEE]=(SELECT COUNT(KPA_InitiateId) FROM T0055_Hrms_Initiate_KPASetting HK WITH (NOLOCK)
					INNER JOIN #Emp_Cons EC ON HK.Emp_Id=EC.Emp_ID
					WHERE KPA_StartDate >= @From_Date and  KPA_StartDate <=@To_Date and Initiate_Status=5
					)
			WHERE [SR.NO]=4
			
			UPDATE #GOAL_STATUS 
					SET [TOTAL_EMPLOYEE]=(SELECT COUNT(KPA_InitiateId) FROM T0055_Hrms_Initiate_KPASetting HK WITH (NOLOCK)
					INNER JOIN #Emp_Cons EC ON HK.Emp_Id=EC.Emp_ID
					WHERE KPA_StartDate >= @From_Date and  KPA_StartDate <=@To_Date and Initiate_Status=1
					)
			WHERE [SR.NO]=5
			
			SELECT * FROM #GOAL_STATUS			
		END
	ELSE IF @flag=3
		BEGIN	
			CREATE TABLE #PERFORMANCE_STATUS
			(
			[SR.NO] INT,
			[STATUS] VARCHAR(500),
			[TOTAL_EMPLOYEE]	 INT			 
			)
			
			INSERT #PERFORMANCE_STATUS([SR.NO],[STATUS],[TOTAL_EMPLOYEE])
			VALUES (1,'NOT SUBMITTED',0)
			INSERT #PERFORMANCE_STATUS([SR.NO],[STATUS],[TOTAL_EMPLOYEE])
			VALUES (2,'DRAFT BY EMPLOYEE',0)
			INSERT #PERFORMANCE_STATUS([SR.NO],[STATUS],[TOTAL_EMPLOYEE])
			VALUES (3,'SUBMITTED',0)
			INSERT #PERFORMANCE_STATUS([SR.NO],[STATUS],[TOTAL_EMPLOYEE])
			VALUES (4,'APPROVED BY MANAGER',0)			
			INSERT #PERFORMANCE_STATUS([SR.NO],[STATUS],[TOTAL_EMPLOYEE])
			VALUES (5,'FINAL APPROVED',0) 
			
			UPDATE #PERFORMANCE_STATUS 
					SET [TOTAL_EMPLOYEE]=(SELECT COUNT(InitiateId) FROM T0050_HRMS_INITIATEAPPRAISAL HI WITH (NOLOCK)
					INNER JOIN #Emp_Cons EC ON HI.Emp_Id=EC.Emp_ID
					WHERE SA_STARTDATE >= @From_Date and  SA_STARTDATE <=@To_Date and SA_Status=4
					)
			WHERE [SR.NO]=1
			
			UPDATE #PERFORMANCE_STATUS 
					SET [TOTAL_EMPLOYEE]=(SELECT COUNT(InitiateId) FROM T0050_HRMS_INITIATEAPPRAISAL HI WITH (NOLOCK)
					INNER JOIN #Emp_Cons EC ON HI.Emp_Id=EC.Emp_ID
					WHERE SA_STARTDATE >= @From_Date and  SA_STARTDATE <=@To_Date and SA_Status=3
					)
			WHERE [SR.NO]=2
			
			UPDATE #PERFORMANCE_STATUS 
					SET [TOTAL_EMPLOYEE]=(SELECT COUNT(InitiateId) FROM T0050_HRMS_INITIATEAPPRAISAL HI WITH (NOLOCK)
					INNER JOIN #Emp_Cons EC ON HI.Emp_Id=EC.Emp_ID
					WHERE SA_STARTDATE >= @From_Date and  SA_STARTDATE <=@To_Date and SA_Status=0
					)
			WHERE [SR.NO]=3
			
			UPDATE #PERFORMANCE_STATUS 
					SET [TOTAL_EMPLOYEE]=(SELECT COUNT(InitiateId) FROM T0050_HRMS_INITIATEAPPRAISAL HI WITH (NOLOCK)
					INNER JOIN #Emp_Cons EC ON HI.Emp_Id=EC.Emp_ID
					WHERE SA_STARTDATE >= @From_Date and  SA_STARTDATE <=@To_Date and SA_Status=1 and Overall_Status=0
					)
			WHERE [SR.NO]=4
			
			UPDATE #PERFORMANCE_STATUS 
					SET [TOTAL_EMPLOYEE]=(SELECT COUNT(InitiateId) FROM T0050_HRMS_INITIATEAPPRAISAL HI WITH (NOLOCK)
					INNER JOIN #Emp_Cons EC ON HI.Emp_Id=EC.Emp_ID
					WHERE SA_STARTDATE >= @From_Date and  SA_STARTDATE <=@To_Date and SA_Status=1 and Overall_Status=5
					)
			WHERE [SR.NO]=5
			
			SELECT * FROM #PERFORMANCE_STATUS			
		END
	ELSE IF @flag=2 or @flag=4
		BEGIN	
			CREATE TABLE #achievement_tbl
			(
				 ACHIEVEMENT			varchar(200)
				,RangeId				numeric(18,0)
				,PERCENTAGE_ALLOCATED	numeric(18,2)
				,ACTUAL_ALLOCATION		numeric(18,2)
				,[TOTAL_EMPLOYEE]		numeric(18,0)
			)
			
			INSERT INTO #achievement_tbl(Achievement,RangeId)
			SELECT A.Achievement_Level,A.AchievementId
			FROM  T0040_Achievement_Master A  WITH (NOLOCK)
			INNER JOIN (
						 SELECT MAX(isnull(Effective_Date,C.From_Date))Effective_Date,Achievement_Level
						 FROM T0040_Achievement_Master  WITH (NOLOCK)
						 INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON C.Cmp_Id= T0040_Achievement_Master.Cmp_ID
						 WHERE Achievement_Type  = 2 
							   and T0040_Achievement_Master.Cmp_ID = @Cmp_ID and isnull(Effective_Date,C.From_Date)<=@from_date
						 GROUP by Achievement_Level
					  )A1 on A1.Effective_Date = A.Effective_Date AND a1.Achievement_Level = A.Achievement_Level
			WHERE Cmp_ID = @Cmp_ID AND A.Achievement_Type = 2 
			ORDER by A.Achievement_Sort
			
			UPDATE #achievement_tbl
			SET PERCENTAGE_ALLOCATED = RA.Avg_Percent_Allocate
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
					SELECT SUM(Overall_Score)Overall_Score,SUM(Overall_Score)/COUNT(1) avg_score,EC.Emp_ID
					FROM  T0050_HRMS_InitiateAppraisal HI WITH (NOLOCK)
					INNER JOIN #Emp_Cons EC ON HI.Emp_Id=EC.Emp_ID
					WHERE Cmp_ID = @Cmp_ID AND SA_Startdate >= @from_date AND SA_Startdate <= @to_date
					GROUP BY EC.Emp_ID 
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
									FROM T0040_HRMS_RangeMaster  WITH (NOLOCK)
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
				SET ACTUAL_ALLOCATION =ISNULL(q.actallocated,0),
					[TOTAL_EMPLOYEE] = isnull(q.noofemp,0)
				FROM (
						SELECT ((count(1)*100)/@cntemp) actallocated,count(1) noofemp,achieveId
						FROM  #empAch_table	
						GROUP by achieveId
					)q
				WHERE RangeId = q.achieveId
				
			SELECT ACHIEVEMENT,isnull([TOTAL_EMPLOYEE],0)[TOTAL_EMPLOYEE] FROM  #achievement_tbl
			
			SELECT ACHIEVEMENT,ISNULL(PERCENTAGE_ALLOCATED,0)PERCENTAGE_ALLOCATED,ISNULL(ACTUAL_ALLOCATION,0)ACTUAL_ALLOCATION,isnull([TOTAL_EMPLOYEE],0)[TOTAL_EMPLOYEE]
			FROM  #achievement_tbl
		END
--select * from #Emp_Cons
END
