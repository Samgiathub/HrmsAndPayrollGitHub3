

-- =============================================
-- Author:		MUKTI CHAUHAN	
-- Create date: 14-05-2018
-- Description: RPT_Training_Graphical_Report
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[RPT_Training_Graphical_Report]
	-- @Cmp_ID		Numeric
	--,@From_Date		Datetime 
	--,@To_Date		Datetime
	--,@Branch_ID		varchar(Max)='' 
	--,@Cat_ID		varchar(Max)
	--,@Grd_ID		varchar(Max) 
	--,@Type_ID		varchar(Max) 
	--,@Dept_ID		varchar(Max)='' 
	--,@Desig_ID		varchar(Max)
	--,@Emp_ID		Numeric
	--,@Constraint	varchar(MAX)
	--,@Report_Type	tinyint = 0
	--,@Training_id   numeric(18,0)
	--,@PBranch_ID	varchar(max)= ''
	--,@PVertical_ID	varchar(max)= '' 
	--,@PSubVertical_ID	varchar(max)= '' 
	--,@PDept_ID varchar(max)=''  
	--,@flag			int = 0 
	
	 @Cmp_ID		Numeric 
	,@From_Date		Datetime 
	,@To_Date		Datetime
	,@Grd_ID		varchar(Max)='' 	
	,@Dept_ID		varchar(Max)=''
	,@Constraint	varchar(MAX)=''		
	--,@ReportType	int = 0 
	,@Training_id   numeric(18,0)
	,@flag			varchar(50)
	--,@Group_Id		int
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	declare @ctr_not_attented as NUMERIC(18)
	declare @ctr_attented as NUMERIC(18)
	declare @total_Employee as NUMERIC(18)		
	DECLARE @TEMP_FROM_DATE DATETIME
	DECLARE @columns VARCHAR(8000)
	DECLARE @query VARCHAR(MAX)
	
	IF @Training_id =0
		SET @Training_id= NULL	
	--Added By Jaina 07-10-2015 Start		
	
	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )  
	 
	--exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 
	
	--DELETE FROM #Emp_Cons
	--WHERE NOT EXISTS (
	--				select	 E.Emp_ID 
	--				from	#Emp_Cons as  E Inner JOIN T0095_INCREMENT as i ON i.Increment_ID = E.Increment_ID
	--				where	 #Emp_Cons.Increment_ID = E.Increment_ID
	--				  and EXISTS (select Data from dbo.Split(@PBranch_ID, ',') PB Where cast(PB.data as numeric)=Isnull(I.Branch_ID,0))
	--				  and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))
	--				  and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))
	--				  AND  EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0))  
					  
	--			)
	
	--Added By Jaina 7-10-2015 End
	
	--Update #Emp_Cons  set Branch_ID = a.Branch_ID from (
	--	SELECT DISTINCT VE.Emp_ID,VE.branch_id,VE.Increment_ID 
	--				  FROM dbo.V_Emp_Cons VE inner join
	--				  #Emp_Cons EC on  VE.Emp_ID = EC.Emp_ID
	--	)a
	--where a.Emp_ID = #Emp_Cons.Emp_ID   	
	
	Declare @Cur_Emp_ID numeric(18,0)
	Declare @Cur_Branch_ID numeric(18,0)
	Declare @Prev_Branch_ID numeric(18,0)
	Declare @Cur_For_Date datetime
	Declare @Cur_Tran_ID numeric(18,0)
	
	 set @Cur_Emp_ID = 0
	 set @Cur_Branch_ID = 0
	 set @Prev_Branch_ID = 0
	 set @Cur_Tran_ID = 0	
	 
	 CREATE TABLE #TRAINING_SCHEDULE
	 (
		 From_date DATETIME,
		 To_date DATETIME,
		 duration FLOAT,
		 Nodays FLOAT,
		 Training_Apr_ID INT,
		 Training_App_ID INT
	 )
	 

	INSERT INTO #TRAINING_SCHEDULE 
	SELECT TS.From_date,TS.To_date,TS.duration,ISNULL(TS.Nodays,0),TA.Training_Apr_ID,TS.Training_App_ID FROM T0120_HRMS_TRAINING_APPROVAL TA  WITH (NOLOCK)
	left JOIN
	   (				   
			SELECT MIN(From_date)From_date,MAX(To_date)To_date,Training_App_ID,sum(ISNULL(S.Nodays,0))Nodays,sum(S.duration)duration
			FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK) INNER JOIN
			(
				SELECT To_Time,From_Time,
					   DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) AS duration,
					   CASE 
					   WHEN (DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) > 0 and DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) <= 2) THEN 0.25 
					   WHEN (DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) > 2 and DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) <= 4) THEN 0.5
					   WHEN (DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) > 4 and DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) <= 6) THEN 0.75
					   ELSE 1 END AS Nodays,Schedule_ID
				FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK) where Cmp_Id=@CMP_ID					
			)S ON s.Schedule_ID = T0120_HRMS_TRAINING_Schedule.Schedule_ID 
			GROUP BY Training_App_ID
	   )TS ON TS.Training_App_ID = TA.Training_App_ID 
	  WHERE TA.Training_Apr_ID =ISNULL(@Training_ID,TA.Training_Apr_ID)
		
	IF @FLAG=0 --Monthwise Training 
			BEGIN
			--select * from #TRAINING_SCHEDULE
			CREATE table #Training_Details
			(      
				Training_Code VARCHAR(150),
				Month_Name VARCHAR(100),
				Training_Month NUMERIC,
				Training_Year NUMERIC,
				Training_Apr_ID NUMERIC,
				Training_ID NUMERIC,
				Training_Name VARCHAR(500),
				Training_From_Date DATETIME,
				Count_Emp numeric				
			)
	
				SET @TEMP_FROM_DATE = @FROM_DATE
				WHILE @TO_DATE >= @TEMP_FROM_DATE
					BEGIN
						INSERT	INTO #Training_Details
						SELECT DISTINCT  Training_Code,CAST(DATENAME(MONTH,@TEMP_FROM_DATE) AS VARCHAR(3)),
								MONTH(@TEMP_FROM_DATE),YEAR(@TEMP_FROM_DATE),TA.Training_Apr_ID,
								TA.Training_id,TM.Training_name,TA.Training_Date,0
						FROM	V0120_HRMS_TRAINING_APPROVAL TA  
				   INNER JOIN T0040_Hrms_Training_master TM WITH (NOLOCK) ON TM.Training_id = TA.Training_id 
				   --LEFT JOIN #TRAINING_SCHEDULE TS ON TS.Training_App_ID = TA.Training_App_ID 					   
			WHERE TA.Cmp_ID = @Cmp_ID AND TA.Training_Apr_ID = ISNULL(@Training_ID,TA.Training_Apr_ID) AND 			
			TA.Training_Date BETWEEN @FROM_DATE AND @TO_DATE and TA.Apr_Status = 1
						
						SET @TEMP_FROM_DATE = DATEADD(MM,1,@TEMP_FROM_DATE)
					END
				--SELECT * FROM #Training_Details
					
				UPDATE	#Training_Details 
				SET		Count_Emp =ISNULL(T1.Count_Emp,0)
				FROM	  
				(
							SELECT	COUNT(TE.Emp_ID)Count_Emp,TE.Training_Apr_ID
							FROM T0130_HRMS_TRAINING_EMPLOYEE_DETAIL TE  WITH (NOLOCK)	
								 INNER JOIN 	#Training_Details TA ON TA.Training_Apr_ID=TE.Training_Apr_ID						
							WHERE TE.CMP_ID = @CMP_ID 
							GROUP BY TE.Training_Apr_ID,TA.Training_Month
							) AS T1
				where MONTH(Training_From_Date)=Training_Month and YEAR(Training_From_Date)=Training_Year
				
				SELECT @columns = COALESCE(@columns + ',[' + CAST(MONTH_NAME AS VARCHAR(1000)) + ']',
					'[' + CAST(MONTH_NAME AS VARCHAR(1000))+ ']')
				FROM	(SELECT ROW_NUMBER() OVER(ORDER BY Training_Month) AS ROW_ID,MONTH_NAME
					FROM	#Training_Details GROUP BY Training_Month,MONTH_NAME)T
				PRINT @columns
			
				SELECT Month_Name,Training_Month,Training_Year,ED.Training_Name,Count_Emp FROM #Training_Details ED
				INNER JOIN t0010_company_master cm WITH (NOLOCK) ON cm.cmp_id=@cmp_id 
				WHERE ED.Training_Name <> '' --AND ED.COUNT_EMP >0	
				
				--select * from #Training_Details
				SET @query = 'SELECT Training_Code as[Training Code],Training_Name as[Training Title],'+ @columns +'										
									FROM (
										SELECT Training_Name,ISNULL(Count_Emp,0)Count_Emp,Month_Name,Training_Code
										FROM #Training_Details EC WHERE Training_Name<>''''																																																																
										) as s
									PIVOT	
									(				 
										MAX(Count_Emp)	
										FOR [MONTH_NAME] IN (' + @columns + ')  														 				
									)AS T
									 '
						print @query
						EXEC(@query)	
				DROP TABLE #Training_Details
			END		
	else if @flag=1 --Attendance Graph
		BEGIN			
		DECLARE @TRAINING_TITLE as VARCHAR(MAX)
		DECLARE @CTR_ATTENDED as INT
		DECLARE @CTR_NOT_ATTENDED as INT
		DECLARE @Total_Emp as INT
		
		SET @CTR_ATTENDED=0
		SET @CTR_NOT_ATTENDED=0
		
		
		SELECT @CTR_ATTENDED=SUM(ISNULL(ED.CTR_ATTENDED,0)),@CTR_NOT_ATTENDED=SUM(ISNULL(EDN.CTR_NOT_ATTENDED,0)),
			  @Total_Emp=SUM((ISNULL(ED.CTR_ATTENDED,0) + ISNULL(EDN.CTR_NOT_ATTENDED,0)))		
		FROM  V0120_HRMS_TRAINING_APPROVAL TA
		INNER JOIN T0040_Hrms_Training_master TM WITH (NOLOCK) ON TM.Training_id = TA.Training_id
		LEFT JOIN(
			SELECT COUNT(ISNULL(EGP.Emp_ID,0))AS CTR_ATTENDED,Training_Apr_ID
			FROM T0130_HRMS_TRAINING_EMPLOYEE_DETAIL EGP WITH (NOLOCK)				
			WHERE EGP.Emp_ID IN(SELECT EMP_ID FROM T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK)
								WHERE Training_Apr_Id=ISNULL(@Training_ID,EGP.Training_Apr_ID))
			AND Training_Apr_Id=ISNULL(@Training_ID,EGP.Training_Apr_ID) 
			GROUP BY Training_Apr_ID)ED ON TA.Training_Apr_ID=ED.Training_Apr_ID
		LEFT JOIN(
			SELECT COUNT(ISNULL(EGP.Emp_ID,0))AS CTR_NOT_ATTENDED,Training_Apr_ID
			FROM T0130_HRMS_TRAINING_EMPLOYEE_DETAIL EGP WITH (NOLOCK)				
			WHERE EGP.Emp_ID NOT IN(SELECT EMP_ID FROM T0150_EMP_Training_INOUT_RECORD  WITH (NOLOCK)
								WHERE Training_Apr_Id=ISNULL(@Training_ID,EGP.Training_Apr_ID))
			AND Training_Apr_Id=ISNULL(@Training_ID,EGP.Training_Apr_ID)
			GROUP BY Training_Apr_ID)EDN ON TA.Training_Apr_ID=EDN.Training_Apr_ID
		--LEFT JOIN #TRAINING_SCHEDULE TS ON TS.Training_Apr_ID=TA.Training_Apr_ID AND TS.From_date BETWEEN @From_Date AND @TO_Date
		WHERE TA.Training_Apr_ID=ISNULL(@Training_ID,TA.Training_Apr_ID) and ta.Training_Date BETWEEN @From_Date AND @TO_Date
		
		
		create table #TrainingCount
		(			
			Attendance_Type   VARCHAR(25)
			,Participant_Count INT			
		)

		INSERT INTO #TrainingCount
		VALUES ('Attended',@CTR_ATTENDED)
		INSERT INTO #TrainingCount
		VALUES ('Not Attended',@CTR_NOT_ATTENDED)

		SELECT * FROM #TrainingCount
		
		SELECT Training_Code as[Training Code],TM.Training_name as [Training Title],CONVERT(VARCHAR(15),TA.Training_Date,103) as[From Date],
			  CONVERT(VARCHAR(15),TA.Training_End_Date,103)[To Date],
			  SUM(ISNULL(ED.CTR_ATTENDED,0))as[Total Attended Employees],
			  SUM(ISNULL(EDN.CTR_NOT_ATTENDED,0))as[Total Not Attended Employees],
			  SUM(ISNULL(ED.CTR_ATTENDED,0) + ISNULL(EDN.CTR_NOT_ATTENDED,0))as[Total of Employees]		
		FROM  V0120_HRMS_TRAINING_APPROVAL TA
		INNER JOIN T0040_Hrms_Training_master TM WITH (NOLOCK) ON TM.Training_id = TA.Training_id
		LEFT JOIN(
			SELECT COUNT(ISNULL(EGP.Emp_ID,0))AS CTR_ATTENDED,Training_Apr_ID
			FROM T0130_HRMS_TRAINING_EMPLOYEE_DETAIL EGP WITH (NOLOCK)				
			WHERE EGP.Emp_ID IN(SELECT EMP_ID FROM T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK)
								WHERE Training_Apr_Id=ISNULL(@Training_ID,EGP.Training_Apr_ID))
			AND Training_Apr_Id=ISNULL(@Training_ID,EGP.Training_Apr_ID) 
			GROUP BY Training_Apr_ID)ED ON TA.Training_Apr_ID=ED.Training_Apr_ID
		LEFT JOIN(
			SELECT COUNT(ISNULL(EGP.Emp_ID,0))AS CTR_NOT_ATTENDED,Training_Apr_ID
			FROM T0130_HRMS_TRAINING_EMPLOYEE_DETAIL EGP WITH (NOLOCK)				
			WHERE EGP.Emp_ID NOT IN(SELECT EMP_ID FROM T0150_EMP_Training_INOUT_RECORD  WITH (NOLOCK)
								WHERE Training_Apr_Id=ISNULL(@Training_ID,EGP.Training_Apr_ID))
			AND Training_Apr_Id=ISNULL(@Training_ID,EGP.Training_Apr_ID)
			GROUP BY Training_Apr_ID)EDN ON TA.Training_Apr_ID=EDN.Training_Apr_ID
		--LEFT JOIN #TRAINING_SCHEDULE TS ON TS.Training_Apr_ID=TA.Training_Apr_ID AND TS.From_date BETWEEN @From_Date AND @TO_Date
		WHERE TA.Training_Apr_ID=ISNULL(@Training_ID,TA.Training_Apr_ID) and ta.Training_Date BETWEEN @From_Date AND @TO_Date
		GROUP BY TM.Training_name,Training_Code,Training_Date,Training_End_Date				
		
			DROP TABLE #TrainingCount
		END	
	ELSE IF @FLAG=2  --Training TypeWise Details
		BEGIN
			SELECT [Type] as Training_Type,count(1)Count_Training
					FROM V0120_HRMS_TRAINING_APPROVAL  
			WHERE Training_Date BETWEEN @FROM_dATE AND @TO_DATE and Apr_Status =1 
				 --and  EXISTS (SELECT 1 FROM T0150_EMP_Training_INOUT_RECORD 
			 --WHERE Training_Apr_Id =V0120_HRMS_TRAINING_APPROVAL.training_apr_id)
			GROUP BY [Type]
			
			SELECT DISTINCT TD.[Type] AS[Training Type],
				   TD.Count_Training as[Total Training] 
			FROM V0120_HRMS_TRAINING_APPROVAL TA INNER JOIN 
			(SELECT [Type],count(1)Count_Training
					FROM V0120_HRMS_TRAINING_APPROVAL  
			WHERE Training_Date BETWEEN @FROM_dATE AND @TO_DATE and Apr_Status =1 --and Training_Apr_ID=ISNULL(@Training_ID,Training_Apr_ID) AND
				  --and EXISTS (SELECT 1 FROM T0150_EMP_Training_INOUT_RECORD WHERE Training_Apr_Id =V0120_HRMS_TRAINING_APPROVAL.training_apr_id)
   		    GROUP BY [Type])TD ON TA.[TYPE]=TD.TYPE
			WHERE Training_Date BETWEEN @FROM_dATE AND @TO_DATE and Apr_Status =1 --AND Training_Apr_ID=ISNULL(@Training_ID,TA.Training_Apr_ID)
		END		
	ELSE IF @FLAG=3  --Training Execution
		BEGIN		
			CREATE TABLE #Training_Plan
			(
				Training_Type  varchar(200)
				,No_Of_Training INT
			)

			INSERT INTO #Training_Plan
			SELECT 'Planned',count(*)
			FROM    V0120_HRMS_TRAINING_APPROVAL 
			WHERE Cmp_Id = @cmp_id and Training_Date BETWEEN @From_Date and @to_date

			INSERT INTO #Training_Plan
			SELECT 'Executed',COUNT(*)
			FROM  V0120_HRMS_TRAINING_APPROVAL  
			where Cmp_ID = @cmp_id and Training_Date BETWEEN @From_Date and @to_date and Apr_Status = 1
				and exists (SELECT 1 FROM T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) WHERE Training_Apr_Id =V0120_HRMS_TRAINING_APPROVAL.training_apr_id)
			
			SELECT * FROM #Training_Plan
			
			--SELECT 'Planned' as[Type],count(Training_Apr_ID)ctr--,Training_Code
			--FROM    V0120_HRMS_TRAINING_APPROVAL 
			--WHERE Cmp_Id = @cmp_id and year(Training_date) = YEAR(@From_Date) and MONTH(Training_date) = MONTH(@From_Date)
			----GROUP by Training_Code
			--UNION
			--SELECT 'Executed' as[Type],COUNT(Training_Apr_ID)ctr--,Training_Code
			--FROM  V0120_HRMS_TRAINING_APPROVAL  
			--where Cmp_ID = @cmp_id and datepart(yyyy,Training_Date)=YEAR(@From_Date)
			--	and datepart(MONTH,Training_Date)=MONTH(@From_Date) and Apr_Status = 1
			--	and exists (SELECT 1 FROM T0150_EMP_Training_INOUT_RECORD WHERE Training_Apr_Id =V0120_HRMS_TRAINING_APPROVAL.training_apr_id)
			--GROUP by Training_Code
			
			DROP TABLE #Training_Plan			
		END	
	else if @flag=4  --ManDays Report
		BEGIN
			CREATE TABLE #Training_Table
			(
				Training_Apr_ID			NUMERIC(18,0)
				,TrainingName			VARCHAR(100)
				,Training_Code			VARCHAR(50)
				,From_date				DATETIME
				,To_date				DATETIME
				,Training_id			NUMERIC(18,0)		
				,Noofdays				NUMERIC(18,2)
				,Duration				Varchar(15)
				,cmp_id					NUMERIC(18,0)				
			)
	
			INSERT INTO #Training_Table 
			SELECT  TA.Training_Apr_ID,TA.Training_name,Training_Code,TS.From_date,TS.To_date,
					Training_id,TS.Nodays,TS.duration,TA.Cmp_ID
			FROM  V0120_HRMS_TRAINING_APPROVAL TA 
				   LEFT JOIN #TRAINING_SCHEDULE TS ON TS.Training_App_ID = TA.Training_App_ID 	
				   INNER JOIN T0130_HRMS_TRAINING_EMPLOYEE_DETAIL EGP WITH (NOLOCK) on EGP.Training_Apr_ID=TA.Training_Apr_ID				    
			WHERE TA.Cmp_ID = @Cmp_ID AND TA.Training_Apr_ID = ISNULL(@Training_ID,TA.Training_Apr_ID)
				  and TA.Training_Date BETWEEN @from_date and @To_Date
	--select * from #Training_Table
			CREATE TABLE #Second_Table
			(
				Training_Apr_ID	NUMERIC(18,0),
				Dept_Id			NUMERIC(18,0),
				Dept_Name		VARCHAR(100),
				Cat_Id			NUMERIC(18,0),
				Cat_Name		VARCHAR(100),
				NoofEmployee	INT,
				ManDay			NUMERIC(18,2),
				Cmp_Name		varchar(200),
				cmp_address		varchar(500),
				Noofdays				NUMERIC(18,2)				
			)
			
			DECLARE @trainingaprid NUMERIC(18,0)
			DECLARE @Noofdays NUMERIC(18,2)
			
			DECLARE cur CURSOR
			FOR
				SELECT Training_Apr_ID,Noofdays FROM #Training_Table
			OPEN cur
				FETCH NEXT FROM cur INTO @trainingaprid,@Noofdays
				WHILE @@fetch_status =0
					BEGIN
					print @trainingaprid
						INSERT INTO #Second_Table(Training_Apr_ID,Dept_Id,Dept_Name,Cat_Id,Cat_Name,NoofEmployee,ManDay,Cmp_Name,cmp_address,Noofdays)
						SELECT @trainingaprid,i.Dept_ID,D.Dept_Name,I.Cat_ID,c.Cat_Name,ISNULL(COUNT(Tran_emp_Detail_ID),0)PartCount,0,CM.Cmp_Name,CM.Cmp_Address,@Noofdays
						--FROM  T0150_EMP_Training_INOUT_RECORD TI INNER JOIN
						FROM  T0130_HRMS_TRAINING_EMPLOYEE_DETAIL TI WITH (NOLOCK)
						INNER JOIN --Mukti(20072017)
							  T0080_EMP_MASTER E WITH (NOLOCK) ON E.Emp_ID = TI.emp_id INNER JOIN
							  (
									SELECT T0095_INCREMENT.Emp_ID,T0095_INCREMENT.Increment_ID,Desig_Id,Cat_ID,Dept_ID
									FROM   T0095_INCREMENT WITH (NOLOCK) INNER JOIN
									(
										SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
										FROM   T0095_INCREMENT WITH (NOLOCK) INNER JOIN
										(
											SELECT MAX(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
											FROM   T0095_INCREMENT WITH (NOLOCK)
											WHERE  Cmp_ID = @cmp_id
											GROUP BY Emp_ID 
										)I2 ON I2.Emp_ID = T0095_INCREMENT.Emp_ID
										WHERE  Cmp_ID = @cmp_id
										GROUP BY T0095_INCREMENT.Emp_ID 
									)I1 ON I1.Emp_ID = T0095_INCREMENT.Emp_ID AND I1.Increment_ID = T0095_INCREMENT.Increment_ID
									WHERE Cmp_ID = @cmp_id
							  )I ON I.Emp_ID = E.Emp_ID LEFT JOIN
							  T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on d.Dept_Id = i.Dept_ID LEFT JOIN
							  T0030_CATEGORY_MASTER c WITH (NOLOCK) on c.Cat_ID = i.Cat_ID INNER JOIN
							  T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id=TI.Cmp_ID 
						WHERE TI.Training_Apr_Id = @trainingaprid and (TI.Emp_tran_status = 1 OR ti.Emp_tran_status =4) 
						and TI.Emp_ID IN(SELECT EMP_ID FROM T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) WHERE Training_Apr_Id=ISNULL(@Training_ID,Training_Apr_ID))
						GROUP BY I.Cat_ID,i.Dept_ID,c.Cat_Name,D.Dept_Name,cm.Cmp_Name,CM.Cmp_Address
														
						FETCH NEXT FROM cur INTO @trainingaprid,@Noofdays
					END
			CLOSE cur
			DEALLOCATE cur		
			--select * from #Second_Table	
			UPDATE #Second_Table
			SET ManDay = k.manday
			FROM (
					SELECT (ST.NoofEmployee*TT.Noofdays)manday,ST.Dept_Id,ST.Cat_Id,ST.Training_Apr_ID
					FROM #Second_Table ST INNER JOIN
						 #Training_Table TT ON TT.Training_Apr_ID = ST.Training_Apr_ID
				 )k		
			WHERE #Second_Table.Training_Apr_ID = k.Training_Apr_ID	and isnull(k.Dept_Id,0) = isnull(#Second_Table.Dept_Id,0) 
				 and isnull(k.Cat_Id,0) = isnull(#Second_Table.Cat_Id,0)
			
			
			SELECT  isnull(Dept_Name,'')as [Department],					
					sum(NoofEmployee)as[Total Participants],
					sum(ManDay)ManDays
					--sum(Noofdays)Noofdays
			FROM #Second_Table where isnull(Dept_Name,'') <> ''	
			GROUP by Dept_Name		
			--ORDER BY Dept_Id,Cat_name
			
			DROP TABLE #Second_Table
			DROP TABLE #Training_Table
		
		END	
	ELSE IF @flag=5 --Training TypeWise Participant Details
			BEGIN
				create table #TrainingPlan
				(
					Training_Type  varchar(200)
					,No_Of_Training INT	
					,No_Of_Participnat INT
				)
				
				declare @Training_Type_ID INT
				declare @Training_TypeName  varchar(150)
				declare @cnt  int
				declare @rescnt  int
				set @rescnt =0

				set @Training_Type_ID = 0
				set @Training_TypeName = ''

				DECLARE cur CURSOR
				FOR
					SELECT Training_Type_ID,Training_TypeName FROM T0030_Hrms_Training_Type WITH (NOLOCK) WHERE Cmp_Id=@cmp_id
				OPEN cur
					FETCH NEXT FROM cur INTO @Training_Type_ID,@Training_TypeName
					WHILE @@fetch_status = 0
						BEGIN 
							
							INSERT INTO #TrainingPlan (Training_Type,No_Of_Training,No_Of_Participnat)
							SELECT @Training_TypeName,count(*),0
							FROM V0120_HRMS_TRAINING_APPROVAL  
							WHERE Training_Type = @Training_Type_ID and Training_Date BETWEEN @From_Date and @to_date  and Apr_Status =1 and 
									EXISTS (SELECT 1 FROM T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) WHERE Training_Apr_Id =V0120_HRMS_TRAINING_APPROVAL.training_apr_id)
							
							SET @rescnt = 0
							DECLARE cur1 CURSOR
							FOR
								SELECT Training_Apr_ID
								FROM V0120_HRMS_TRAINING_APPROVAL  
								WHERE Training_Type = @Training_Type_ID and Training_Date BETWEEN @From_Date and @to_date and Apr_Status =1 and
										EXISTS (SELECT 1 FROM T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) WHERE Training_Apr_Id =V0120_HRMS_TRAINING_APPROVAL.training_apr_id)
							OPEN cur1
								FETCH NEXT FROM cur1 INTO @trainingaprid
								WHILE @@fetch_status = 0
									BEGIN
										
										SELECT @cnt = COUNT(DISTINCT emp_id)
										FROM T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) WHERE Training_Apr_Id = @trainingaprid
										FETCH NEXT FROM cur1 INTO @trainingaprid
										
										SET @rescnt = @rescnt + @cnt						
									END
							CLOSE cur1
							DEALLOCATE cur1	
							
							UPDATE #TrainingPlan
							SET No_Of_Participnat = @rescnt WHERE Training_Type = @Training_TypeName
														
							FETCH NEXT FROM cur INTO @Training_Type_ID,@Training_TypeName
						END
				CLOSE cur
				DEALLOCATE cur

				select * from #TrainingPlan
				drop table #TrainingPlan
		END	

END
