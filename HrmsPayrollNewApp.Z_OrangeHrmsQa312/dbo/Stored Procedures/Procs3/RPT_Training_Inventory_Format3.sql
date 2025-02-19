

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[RPT_Training_Inventory_Format3]
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
	,@Training_ID		numeric(18,0)
	,@Training_TypeId	numeric(18,0)  
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
		
	
	 CREATE table #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	  Branch_ID numeric,
	  Increment_ID numeric    
	 )     
	 
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 
	
	--select * FROM #Emp_Cons
	CREATE TABLE #TrainingTable
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
	
	IF @Training_ID =0
		BEGIN
			IF @Training_TypeId = 0
				BEGIN
					INSERT INTO #TrainingTable 
					SELECT  Training_Apr_ID,Training_name,Training_Code,			
						TS.From_date,
						TS.To_date,T0040_Hrms_Training_master.Training_id,TS.Nodays,TS.duration,
						T0120_HRMS_TRAINING_APPROVAL.Cmp_ID
					FROM  T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) INNER JOIN
						   T0040_Hrms_Training_master WITH (NOLOCK) ON T0040_Hrms_Training_master.Training_id = T0120_HRMS_TRAINING_APPROVAL.Training_id INNER JOIN
						   (
								SELECT MIN(From_date)From_date,MAX(To_date)To_date,Training_App_ID,sum(S.Nodays)Nodays,sum(S.duration)duration
								FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK) INNER JOIN
								(
									SELECT To_Time,From_Time,
										   DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) as duration,
										    CASE 
											   WHEN (DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) > 0 and DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) <= 2) THEN 0.25 
											   WHEN (DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) > 2 and DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) <= 4) THEN 0.5
											   WHEN (DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) > 4 and DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) <= 6) THEN 0.75
											   ELSE 1
											END AS Nodays,
										   Schedule_ID
									FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)							
								)S On s.Schedule_ID = T0120_HRMS_TRAINING_Schedule.Schedule_ID
								GROUP BY Training_App_ID
						   )TS ON TS.Training_App_ID = T0120_HRMS_TRAINING_APPROVAL.Training_App_ID
					WHERE T0120_HRMS_TRAINING_APPROVAL.Cmp_ID = @Cmp_ID AND TS.From_date >= @From_Date AND TS.From_date <= @To_Date
				END
			Else
				BEGIN
					INSERT INTO #TrainingTable 
					SELECT  Training_Apr_ID,Training_name,Training_Code,			
						TS.From_date,
						TS.To_date,T0040_Hrms_Training_master.Training_id,TS.Nodays,TS.duration,
						T0120_HRMS_TRAINING_APPROVAL.Cmp_ID
					FROM  T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) INNER JOIN
						   T0040_Hrms_Training_master WITH (NOLOCK) ON T0040_Hrms_Training_master.Training_id = T0120_HRMS_TRAINING_APPROVAL.Training_id INNER JOIN
						   (
								SELECT MIN(From_date)From_date,MAX(To_date)To_date,Training_App_ID,sum(S.Nodays)Nodays,sum(S.duration)duration
								FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK) INNER JOIN
								(
									SELECT To_Time,From_Time,
										   DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) as duration,
										    CASE 
											   WHEN (DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) > 0 and DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) <= 2) THEN 0.25 
											   WHEN (DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) > 2 and DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) <= 4) THEN 0.5
											   WHEN (DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) > 4 and DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) <= 6) THEN 0.75
											   ELSE 1
											END AS Nodays,
										   Schedule_ID
									FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)							
								)S On s.Schedule_ID = T0120_HRMS_TRAINING_Schedule.Schedule_ID
								GROUP BY Training_App_ID
						   )TS ON TS.Training_App_ID = T0120_HRMS_TRAINING_APPROVAL.Training_App_ID
					WHERE T0120_HRMS_TRAINING_APPROVAL.Cmp_ID = @Cmp_ID AND TS.From_date >= @From_Date AND TS.From_date <= @To_Date and T0120_HRMS_TRAINING_APPROVAL.Training_Type = @Training_TypeId
				END			
		END
	ELSE
		BEGIN
			INSERT INTO #TrainingTable 
			SELECT  Training_Apr_ID,Training_name,Training_Code,			
				TS.From_date,
				TS.To_date,T0040_Hrms_Training_master.Training_id,TS.Nodays,TS.duration,
				T0120_HRMS_TRAINING_APPROVAL.Cmp_ID
			FROM  T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) INNER JOIN
				   T0040_Hrms_Training_master WITH (NOLOCK) ON T0040_Hrms_Training_master.Training_id = T0120_HRMS_TRAINING_APPROVAL.Training_id INNER JOIN
				   (
						SELECT MIN(From_date)From_date,MAX(To_date)To_date,Training_App_ID,sum(S.Nodays)Nodays,sum(S.duration)duration
						FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK) INNER JOIN
						(
							SELECT To_Time,From_Time,
								   DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) AS duration,
								   CASE 
								   WHEN (DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) > 0 and DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) <= 2) THEN 0.25 
								   WHEN (DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) > 2 and DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) <= 4) THEN 0.5
								   WHEN (DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) > 4 and DATEDIFF(HOUR, CONVERT(DATETIME, From_Time, 109),CONVERT(DATETIME, To_Time, 109)) <= 6) THEN 0.75
								   ELSE 1
								   END AS Nodays,
								   Schedule_ID
							FROM T0120_HRMS_TRAINING_Schedule	WITH (NOLOCK)						
						)S ON s.Schedule_ID = T0120_HRMS_TRAINING_Schedule.Schedule_ID
						GROUP BY Training_App_ID
				   )TS ON TS.Training_App_ID = T0120_HRMS_TRAINING_APPROVAL.Training_App_ID
			WHERE T0120_HRMS_TRAINING_APPROVAL.Cmp_ID = @Cmp_ID AND Training_Apr_ID = @Training_ID
		END
	--select * from #TrainingTable
	SELECT Training_Apr_ID,TrainingName,Training_Code,
			CONVERT(VARCHAR(25),#TrainingTable.From_date,103)From_date,
			CONVERT(VARCHAR(25),#TrainingTable.To_date,103)To_date,Training_id,
			Noofdays,Duration
			,C.Cmp_Name,
			C.Cmp_Address,C.cmp_logo 
			,CONVERT(VARCHAR(25),@From_Date,103) AS ProviderFrom			
			,CONVERT(VARCHAR(25),@To_Date,103) AS ProviderTo
	FROM #TrainingTable INNER JOIN
		T0010_COMPANY_MASTER C WITH (NOLOCK) ON C.Cmp_Id = #TrainingTable.cmp_id
	
	CREATE TABLE #Second_Table
	(
		Training_Apr_ID	NUMERIC(18,0),
		Dept_Id			NUMERIC(18,0),
		Dept_Name		VARCHAR(100),
		Cat_Id			NUMERIC(18,0),
		Cat_Name		VARCHAR(100),
		NoofEmployee	INT,
		ManDay			NUMERIC(18,2)
	)	
	
	DECLARE @trainingaprid NUMERIC(18,0)
	
	DECLARE cur CURSOR
	FOR
		SELECT Training_Apr_ID FROM #TrainingTable
	OPEN cur
		FETCH NEXT FROM cur INTO @trainingaprid
		WHILE @@fetch_status =0
			BEGIN
			print @trainingaprid
				INSERT INTO #Second_Table(NoofEmployee,Training_Apr_ID,Cat_Id,Dept_Id,Cat_Name,Dept_Name)
				SELECT ISNULL(COUNT(Tran_emp_Detail_ID),0)PartCount,@trainingaprid,I.Cat_ID,i.Dept_ID,c.Cat_Name,D.Dept_Name
				--FROM  T0150_EMP_Training_INOUT_RECORD TI INNER JOIN
				FROM  T0130_HRMS_TRAINING_EMPLOYEE_DETAIL TI WITH (NOLOCK) INNER JOIN --Mukti(20072017)
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
					  T0030_CATEGORY_MASTER c WITH (NOLOCK) on c.Cat_ID = i.Cat_ID inner join
					  #Emp_Cons EC on EC.Emp_ID=E.Emp_ID
				WHERE TI.Training_Apr_Id = @trainingaprid and (TI.Emp_tran_status = 1 OR ti.Emp_tran_status =4)
				GROUP BY I.Cat_ID,i.Dept_ID,c.Cat_Name,D.Dept_Name
												
				FETCH NEXT FROM cur INTO @trainingaprid
			END
	CLOSE cur
	DEALLOCATE cur		
	--select * from #Second_Table	
	UPDATE #Second_Table
	SET ManDay = k.manday
	FROM (
			SELECT (ST.NoofEmployee*TT.Noofdays)manday,ST.Dept_Id,ST.Cat_Id,ST.Training_Apr_ID
			FROM #Second_Table ST INNER JOIN
			     #TrainingTable TT ON TT.Training_Apr_ID = ST.Training_Apr_ID
		 )k		
	WHERE #Second_Table.Training_Apr_ID = k.Training_Apr_ID	and isnull(k.Dept_Id,0) = isnull(#Second_Table.Dept_Id,0) 
		 and isnull(k.Cat_Id,0) = isnull(#Second_Table.Cat_Id,0)
	
	--SELECT * from #Second_Table
	--order by Dept_name,Cat_Name
	
	
	--SELECT CASE WHEN ROW_NUMBER() OVER ( PARTITION BY Dept_Id ORDER BY Dept_Name,Cat_Name) = 1 
	--		THEN isnull(Dept_Name,'')  ELSE '' END AS 'Dept_Name',
	--		isnull(Cat_Id,0)Cat_Id,
	--		Training_Apr_ID,
	--		isnull(Dept_Id,0)Dept_Id,
	--		isnull(Cat_Name,'')Cat_Name,
	--		NoofEmployee,
	--		ManDay
	--FROM #Second_Table
	--ORDER BY Dept_Id,Cat_name
	
	SELECT  isnull(Dept_Name,'')Dept_Name,
			isnull(Cat_Id,0)Cat_Id,
			Training_Apr_ID,
			isnull(Dept_Id,0)Dept_Id,
			isnull(Cat_Name,'')Cat_Name,
			NoofEmployee,
			ManDay
	FROM #Second_Table
	ORDER BY Dept_Id,Cat_name
	
	DROP TABLE #Second_Table
	DROP TABLE #TrainingTable
END

