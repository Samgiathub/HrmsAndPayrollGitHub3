


---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[RPT_Training_MonthlyDetails]
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
		,@flag			Numeric(18,0)=0
		,@Condition		varchar(MAX) --Mukti(10072017)
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	declare @query as varchar(max) 
	set @query =''
	
	CREATE TABLE #Emp_Cons 
	 (      
		   Emp_ID numeric ,  
		   Branch_ID numeric, 
		   Increment_ID numeric    
	 )  
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 
	
	UPDATE #Emp_Cons  SET Branch_ID = a.Branch_ID FROM (
		SELECT DISTINCT VE.Emp_ID,VE.Branch_ID,VE.Increment_ID 
					  FROM dbo.V_Emp_Cons VE inner join
					  #Emp_Cons EC on  VE.Emp_ID = EC.Emp_ID
		)a
	WHERE a.Emp_ID = #Emp_Cons.Emp_ID 
	
	CREATE TABLE #Training_Detail
	(
		 Emp_Code			VARCHAR(100)
		,Emp_Name			VARCHAR(100)	
		,Cmp_Name			VARCHAR(200)
		,Dept_Name			VARCHAR(100)
		,Grade_Name			VARCHAR(100)
		,Training_Name		VARCHAR(100)
		,TrainingType		VARCHAR(250)
		,Training_Category	VARCHAR(250)--Mukti(21032018)
		,TrainingSkill		VARCHAR(800)
		,Faculty			VARCHAR(500)
		,TrainingDays		NUMERIC(18,2)
		,Training_StDate	DATETIME
		,Training_EndDate	DATETIME
		,DurationDays		NUMERIC(18,3)
		,TotalDuration		NUMERIC(18,3)
		,Training_ManDays	NUMERIC(18,3)
		,Training_Venue		VARCHAR(200)
		,TrainingFee		NUMERIC(18,2)	
		,AdminCost			NUMERIC(18,2)	
		,TrainingEffective	INT
		,Training_ID		NUMERIC(18,0)	
	)
	
	--Added by Mukti(06072017)start
	CREATE TABLE #Monthly_Training_Detail
	(
		Training_Name		VARCHAR(100)		
		,Faculty			VARCHAR(500)
		,TrainingDays		NUMERIC(18,2)
		,Training_StDate	DATETIME
		,Training_EndDate	DATETIME
		,Training_Code      VARCHAR(100) 
		,Training_Cordinator VARCHAR(250) 
		,Training_Director   VARCHAR(250) 	
		,Targeted_Group     VARCHAR(500)  
		,Training_ID		NUMERIC(18,0)	
		,TrainingType		VARCHAR(250)
		,Training_Category	VARCHAR(250)
		,Total_Participants	INT
		,Training_Mandays	NUMERIC(18,2)
		)
	--Added by Mukti(06072017)end	
	print 1
	if @flag = 0
		BEGIN	
			INSERT INTO #Training_Detail(Emp_Code,Emp_Name,Cmp_Name,Dept_Name,Grade_Name,Training_Name,TrainingType,Training_Category,
					TrainingSkill,Faculty,TrainingDays,Training_StDate,Training_EndDate,DurationDays,TotalDuration,Training_ManDays,Training_Venue,
					TrainingFee,AdminCost,TrainingEffective,Training_ID)	
			SELECT DISTINCT EM.Alpha_Emp_Code,EM.Emp_Full_Name,B.Branch_Name,D.Dept_Name,G.Grd_Name,TM.Training_name,TT.Training_TypeName,ht.Training_Category_Name,
					ISNULL(SK.Skill_Name,''),TA.Faculty,((DATEDIFF(DAY,TST.From_date,TST.To_date))+1),TST.From_date,TST.To_date,TS.duration,(((DATEDIFF(DAY,tst.From_date,tst.To_date))+1) * TS.duration),(((DATEDIFF(DAY,tst.From_date,tst.To_date))+1) * TS.duration)/8,TA.Place,NULL,NULL,TA.Manager_FeedbackDays,TM.Training_id
			FROM	T0120_HRMS_TRAINING_APPROVAL TA WITH (NOLOCK) LEFT JOIN
					(
						SELECT T0120_HRMS_TRAINING_Schedule.Training_App_ID,SUM(nodays)nodays,SUM(CONVERT(numeric(18,2),(TS1.duration)))duration
						FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK) INNER JOIN
						(
							SELECT (DATEDIFF(DAY,From_date,To_date))+1 nodays,To_date,From_date,Training_App_ID,
									(REPLACE(CONVERT(varchar(5),(SELECT CONVERT(DATETIME, ISNULL(to_time,'')))-(SELECT CONVERT(DATETIME,ISNULL(from_time,''))),114),':','.'))duration,
								From_Time,To_Time
							FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
							GROUP BY Training_App_ID,To_date,From_date,From_Time,To_Time
						)TS1 on T0120_HRMS_TRAINING_Schedule.Training_App_ID = TS1.Training_App_ID and 
						T0120_HRMS_TRAINING_Schedule.From_date = ts1.From_date and 
						T0120_HRMS_TRAINING_Schedule.To_date = ts1.To_date
						GROUP BY T0120_HRMS_TRAINING_Schedule.Training_App_ID
					)TS	ON TA.Training_App_ID = TS.Training_App_ID LEFT JOIN
					(
						SELECT MIN(From_date)From_date,MAX(To_date)To_date,Training_App_ID
						FROM   T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
						GROUP  BY Training_App_ID
					)TST on TST.Training_App_ID = TA.Training_App_ID INNER JOIN
					T0130_HRMS_TRAINING_EMPLOYEE_DETAIL TE WITH (NOLOCK) ON TE.Training_Apr_ID = TA.Training_Apr_ID left JOIN
					(
						SELECT Training_Apr_Id,emp_id
						FROM T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK)
						GROUP BY Training_Apr_Id,emp_id	
					)TI ON TI.Training_Apr_Id = TA.Training_Apr_ID AND TI.emp_id = TE.Emp_ID INNER JOIN			 
					#Emp_Cons E ON E.Emp_ID = TE.Emp_ID INNER JOIN
					T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = E.Emp_ID INNER JOIN
					(
						SELECT I.Branch_ID,I.Dept_ID,I.Grd_ID,I.Desig_Id,I.Type_ID,I.Emp_ID
						FROM	T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
							 (
								SELECT max(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
								FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
								(
									SELECT max(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
									FROM T0095_INCREMENT WITH (NOLOCK)
									WHERE Cmp_ID = @Cmp_ID
									GROUP BY Emp_ID
								)I3 ON i3.Emp_ID = T0095_INCREMENT.Emp_ID
								WHERE Cmp_ID = @Cmp_ID
								GROUP BY T0095_INCREMENT.Emp_ID
							 )I2 ON I2.Increment_ID = I.Increment_ID AND I.Emp_ID = I2.Emp_ID
						WHERE	I.Cmp_ID = @Cmp_ID
					)I1 ON I1.Emp_ID = EM.Emp_ID LEFT JOIN 
					T0040_DEPARTMENT_MASTER D WITH (NOLOCK) ON D.Dept_Id = I1.Dept_ID LEFT JOIN
					T0040_GRADE_MASTER G WITH (NOLOCK) ON G.Grd_ID = I1.Grd_ID LEFT JOIN
					T0040_Hrms_Training_master TM WITH (NOLOCK) ON TM.Training_id = TA.Training_id INNER JOIN
					T0010_COMPANY_MASTER C WITH (NOLOCK) ON C.Cmp_Id = EM.Cmp_ID INNER JOIN
					T0030_Hrms_Training_Type TT WITH (NOLOCK) ON TT.Training_Type_ID = TA.Training_Type INNER JOIN
					T0100_HRMS_TRAINING_APPLICATION T WITH (NOLOCK) ON T.Training_App_ID = TA.Training_App_ID LEFT JOIN
					T0040_SKILL_MASTER SK WITH (NOLOCK) ON SK.Skill_ID = T.Skill_ID LEFT JOIN
					T0030_BRANCH_MASTER B WITH (NOLOCK) on B.Branch_ID = I1.Branch_ID left JOIN
					T0030_Hrms_Training_Category HT WITH (NOLOCK) on ht.Training_Category_ID=TM.Training_Category_Id
			WHERE	(TE.Emp_tran_status = 1 or TE.Emp_tran_status=4) and TA.Apr_Status = 1 			
					and TST.From_date >= @From_Date and TST.From_date <= @To_Date
				
			set @query='SELECT ROW_NUMBER() OVER(ORDER BY Training_Name ASC) AS SrNo
					,Emp_Code			''Employee Code''	
					,Emp_Name			''Employee Name''					
					,Cmp_Name			''Location''		
					,Dept_Name			''Department''	
					,Grade_Name			''Grade''
					,Training_Name		''Name of Program''
					,TrainingType		''Training Type''
					,Training_Category	''Training Category''		
					,TrainingSkill		''Training Skills''	
					,Faculty			''Training Faculty / Institution''	
					,TrainingDays		''Total No. of Training Days''	
					,CONVERT(VARCHAR(11),Training_StDate,105)	''From''	
					,CONVERT(VARCHAR(11),Training_EndDate,105)	''To''
					,DurationDays		''Training Duration (No.of hrs/day)''
					,TotalDuration		''Total Program Duration''	
					,Training_ManDays	''Training Mandays''
					,Training_Venue		''Training Venue''	
					,TrainingFee		''Training Fee''	
					,AdminCost			''Admin Cost''		
					,TrainingEffective	''Training Effectiveness Evaluation (days)''
			FROM #Training_Detail
			where 1=1 '+  @Condition + '
			order by Training_Name'
			
			exec(@query)
			DROP TABLE #Training_Detail
		END
	ELSE
		BEGIN
		
			INSERT INTO #Monthly_Training_Detail(Training_Name,Faculty,TrainingDays,Training_StDate,Training_EndDate
			,Training_Code,Training_Cordinator,Training_Director,Targeted_Group,Training_ID,TrainingType,Training_Category,Total_Participants,Training_Mandays)
			SELECT DISTINCT TM.Training_name,TA.Faculty,TS.nodays,TST.From_date,TST.To_date,TA.Training_Code,TM.Training_Cordinator,TM.Training_Director,
			CASE WHEN TA.category_id IS NOT NULL 
				  THEN
					  (SELECT     CM.Cat_Name + ','
						FROM          T0030_CATEGORY_MASTER CM WITH (NOLOCK)
						WHERE      CM.Cat_ID IN
												   (SELECT     cast(data AS numeric(18, 0))
													 FROM          dbo.Split(ISNULL(TA.category_id, '0'), '#')
													 WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END,TM.Training_id,TT.Training_TypeName,HT.Training_Category_Name
	    	,TED.total_participants,TED.total_participants
			FROM	T0120_HRMS_TRAINING_APPROVAL TA WITH (NOLOCK) LEFT JOIN
					(
						SELECT T0120_HRMS_TRAINING_Schedule.Training_App_ID,SUM(Nodays)nodays,SUM(CONVERT(numeric(18,2),(TS1.duration)))duration
						FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK) INNER JOIN
						(
							SELECT --(DATEDIFF(DAY,From_date,To_date))+1 nodays
								To_date,From_date,Training_App_ID,
									(REPLACE(CONVERT(varchar(5),(SELECT CONVERT(DATETIME, ISNULL(to_time,'')))-(SELECT CONVERT(DATETIME,ISNULL(from_time,''))),114),':','.'))duration,
								From_Time,To_Time,
								CASE 
								   WHEN (DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) > 0 and DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) <= 2) THEN 0.25 
								   WHEN (DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) > 2 and DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) <= 4) THEN 0.5
								   WHEN (DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) > 4 and DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) <= 6) THEN 0.75
								   ELSE 1
								END AS Nodays
							FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
							GROUP BY Training_App_ID,To_date,From_date,From_Time,To_Time
						)TS1 on T0120_HRMS_TRAINING_Schedule.Training_App_ID = TS1.Training_App_ID and 
						T0120_HRMS_TRAINING_Schedule.From_date = ts1.From_date and 
						T0120_HRMS_TRAINING_Schedule.To_date = ts1.To_date
						GROUP BY T0120_HRMS_TRAINING_Schedule.Training_App_ID
					)TS	ON TA.Training_App_ID = TS.Training_App_ID LEFT JOIN
					(
						SELECT MIN(From_date)From_date,MAX(To_date)To_date,Training_App_ID
						FROM   T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
						GROUP  BY Training_App_ID
					)TST on TST.Training_App_ID = TA.Training_App_ID INNER JOIN
					T0130_HRMS_TRAINING_EMPLOYEE_DETAIL TE WITH (NOLOCK) ON TE.Training_Apr_ID = TA.Training_Apr_ID left JOIN
					(
						SELECT Training_Apr_Id,emp_id
						FROM T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK)
						GROUP BY Training_Apr_Id,emp_id	
					)TI ON TI.Training_Apr_Id = TA.Training_Apr_ID AND TI.emp_id = TE.Emp_ID INNER JOIN			 
					#Emp_Cons E ON E.Emp_ID = TE.Emp_ID LEFT JOIN 
				T0040_Hrms_Training_master TM WITH (NOLOCK) ON TM.Training_id = TA.Training_id LEFT JOIN 
				T0030_Hrms_Training_Type TT WITH (NOLOCK) ON TT.Training_Type_ID = TA.Training_Type LEFT JOIN 	
				T0030_Hrms_Training_Category HT WITH (NOLOCK) on ht.Training_Category_ID=TM.Training_Category_Id LEFT JOIN
					(
						SELECT ISNULL(COUNT(Tran_emp_Detail_ID),0)as total_participants,Training_Apr_Id
						FROM   T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK)
						GROUP  BY Training_Apr_Id
					)TED on TED.Training_Apr_Id=TA.Training_Apr_ID 
			WHERE	(TE.Emp_tran_status = 1 or TE.Emp_tran_status=4) and TA.Apr_Status = 1 			
				and TST.From_date >= @From_Date and TST.From_date <= @To_Date 
			
						
			set @query='SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY Training_Name ASC) AS SrNo
						,Training_Code ''Training Code''
						,Training_Name		''Training Title''	
						,CONVERT(VARCHAR(11),Training_StDate,105)	''From Date''
						,CONVERT(VARCHAR(11),Training_EndDate,105)	''To Date''
						,TrainingType		''Training Type''	
						,Training_Category		''Training Category''	
						,Total_Participants		''No of Participants''	
						,TrainingDays		''No.of Days''						
						,(Training_Mandays*TrainingDays) ''Training ManDays''	
						,Training_Cordinator ''Training Coordinator''
						,Training_Director   ''Training Director''
						,Faculty			 ''Training Provider''
						,Targeted_Group      ''Targeted Group''					
				FROM #Monthly_Training_Detail
				where 1=1 '+  @Condition + '
				order by Training_Name'
				
				exec(@query)
				DROP TABLE #Monthly_Training_Detail
		END
END


