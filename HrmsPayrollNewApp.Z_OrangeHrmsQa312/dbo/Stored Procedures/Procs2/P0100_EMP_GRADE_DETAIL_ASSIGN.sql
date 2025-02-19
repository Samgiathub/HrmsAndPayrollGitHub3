

CREATE PROCEDURE [dbo].[P0100_EMP_GRADE_DETAIL_ASSIGN]			---\\** CREATED BY RAMIZ **\\---
	@Cmp_ID 			numeric
	,@From_Date			datetime
	,@To_Date 			datetime 
	,@Branch_ID			numeric
	,@Cat_ID 			numeric 
	,@Grd_ID 			numeric
	,@Type_ID 			numeric
	,@Dept_ID 			numeric
	,@Desig_ID 			numeric
	,@Emp_ID 			numeric
	,@Shift_ID          varchar(100)
	,@constraint 		varchar(MAX)
	,@Record_Type		varchar(20) = 'All Records'	
	,@Datewise_Records	TinyInt = 0
	
AS 

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
		set ANSI_WARNINGS OFF;
	
	--SET @To_Date = @From_Date;

	IF @Branch_ID = 0  
		Set @Branch_ID = null		
	IF @Cat_ID = 0  
		Set @Cat_ID = null
	IF @Grd_ID = 0  
		Set @Grd_ID = null
	IF @Type_ID = 0  
		Set @Type_ID = null
	IF @Dept_ID = 0  
		Set @Dept_ID = null
	IF @Desig_ID = 0  
		Set @Desig_ID = null
	IF @Emp_ID = 0  
		Set @Emp_ID = null
	If @Shift_ID = '' or @Shift_ID = 0
		set @Shift_ID = null
	If @Cmp_ID = 0
		Set @Cmp_ID = Null
	
	IF OBJECT_ID('tempdb..#Emp_Cons') IS NULL
		BEGIN	
			CREATE TABLE #Emp_Cons 
			(      
				Emp_ID numeric ,     
				Branch_ID numeric,
				Increment_ID numeric    
			)
		END 	
	
		
	EXEC dbo.SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint
  	
  	CREATE TABLE #Data         
	  (         
	   Emp_Id   numeric ,         
	   For_date datetime,        
	   Duration_in_sec numeric,        
	   Shift_ID numeric ,        
	   Shift_Type numeric ,        
	   Emp_OT  numeric ,        
	   Emp_OT_min_Limit numeric,        
	   Emp_OT_max_Limit numeric,        
	   P_days  numeric(12,3) default 0,
	   OT_Sec  numeric default 0  ,
	   In_Time datetime,
	   Shift_Start_Time datetime,
	   OT_Start_Time numeric default 0,
	   Shift_Change tinyint default 0,
	   Flag int default 0,
	   Weekoff_OT_Sec  numeric default 0,
	   Holiday_OT_Sec  numeric default 0,   
	   Chk_By_Superior numeric default 0,
	   IO_Tran_Id	   numeric default 0,
	   OUT_Time datetime,
	   Shift_End_Time datetime,
	   OT_End_Time numeric default 0,
	   Working_Hrs_St_Time tinyint default 0,
	   Working_Hrs_End_Time tinyint default 0,
	   GatePass_Deduct_Days numeric(18,2) default 0
	)     	
	
	CREATE NONCLUSTERED INDEX IX_DATA_EMPID_FORDATE_HA ON #Data (EMP_ID,FOR_DATE) INCLUDE (SHIFT_ID);
   
	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
		BEGIN
			CREATE TABLE #Emp_WeekOff
			(
				Row_ID			NUMERIC,
				Emp_ID			NUMERIC,
				For_Date		DATETIME,
				Weekoff_day		VARCHAR(10),
				W_Day			numeric(3,1),
				Is_Cancel		BIT
			)
			CREATE CLUSTERED INDEX IX_Emp_WeekOff_EMPID_FORDATE ON #Emp_WeekOff(Emp_ID,For_Date);
		END
	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
		END
		
	IF OBJECT_ID('tempdb..#PRESENT') IS NULL
		BEGIN
			CREATE TABLE #PRESENT
			(  
				EMP_ID			NUMERIC,  
				ALPHA_EMP_CODE		varchar(100),  
				EMP_FULL_NAME	VARCHAR(100),  
				IN_TIME			DATETIME,
				OUT_TIME		DATETIME,
				STATUS			varchar(2),
				SHIFT_ID		numeric,
				BRANCH_ID		numeric,
				DEPT_ID			numeric,
				DESIG_ID		Numeric,
				GRD_ID			Numeric,
				GRD_NAME		varchar(50),
				TYPE_ID			Numeric,
				Vertical_id		Numeric,
				Subvertical_id	Numeric,
				For_date		Datetime,
				OT_Sec			numeric default 0  ,			
			)  
			CREATE NONCLUSTERED INDEX IX_PRESENT_EMPID_INTIME ON #PRESENT (EMP_ID,IN_TIME) INCLUDE (SHIFT_ID);
		END
		
	EXEC dbo.SP_CALCULATE_PRESENT_DAYS @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID,@constraint=@constraint,@Return_Record_set=4
	
		--select * from #EMP_HOLIDAY
	
	DECLARE @Current AS DATE = @From_Date;
	IF OBJECT_ID('tempdb..#tmpDates') IS NULL
		BEGIN
			CREATE TABLE #tmpDates
			(	
				EMP_ID NUMERIC, FOR_DATE DATE
			)
		END

	WHILE @Current <= @To_Date
		BEGIN
			INSERT INTO #tmpDates
				(EMP_ID ,  FOR_DATE)
			VALUES
				(@Emp_ID, @Current);
			SET @Current = DATEADD(DD, 1, @Current)
		END
		
		
	IF @Record_Type = 'Attendance'
		BEGIN
		
			IF (CONVERT(VARCHAR(10) , @From_Date  , 111) = CONVERT(VARCHAR(10) , GETDATE(), 111) 
					AND CONVERT(VARCHAR(10) , @To_Date  , 111) = CONVERT(VARCHAR(10) , GETDATE(), 111))	--FOR CURRENT DAY , WE WILL CONSIDER SINGLE PUNCH PRESENT
				BEGIN
					INSERT INTO #PRESENT 
						(EMP_ID,ALPHA_EMP_CODE,EMP_FULL_NAME,IN_TIME,OUT_TIME,STATUS,SHIFT_ID,BRANCH_ID,DEPT_ID,DESIG_ID,GRD_ID,GRD_NAME,TYPE_ID,Vertical_id,Subvertical_id,For_date)
					SELECT D.Emp_Id , EM.Alpha_Emp_Code , EM.Emp_Full_Name , D.In_Time , D.OUT_Time , 
					'P',0 , I.Branch_ID , I.Dept_ID , i.Desig_Id , i.Grd_ID , GM.Grd_Name, i.Type_ID , I.Vertical_ID , I.SubVertical_ID , D.For_date
					FROM T0150_EMP_INOUT_RECORD D WITH (NOLOCK)
					INNER JOIN #Emp_Cons E ON E.Emp_ID = D.Emp_Id
					INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = D.Emp_Id
					INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = E.Increment_ID AND E.Emp_ID = i.Emp_ID
					INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.Grd_ID = I.Grd_ID
					WHERE D.For_Date = @From_Date
					
					UPDATE	#PRESENT 
					SET SHIFT_ID = Shf.Shift_ID
					FROM	#PRESENT  P
						INNER JOIN (
									SELECT esd.Shift_ID, esd.Emp_ID 
									FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK)
										INNER JOIN  
											(
											 SELECT MAX(For_Date) AS For_Date,Emp_ID 
											 FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) 
											 WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date <= @To_Date GROUP BY Emp_ID
											) S ON ESD.EMP_ID = S.EMP_ID AND ESD.FOR_DATE=S.FOR_DATE
									) Shf ON Shf.Emp_ID = p.EMP_ID
				END
			ELSE
				BEGIN
					INSERT INTO #PRESENT 
						(EMP_ID,ALPHA_EMP_CODE,EMP_FULL_NAME,IN_TIME,OUT_TIME,STATUS,SHIFT_ID,BRANCH_ID,DEPT_ID,DESIG_ID,GRD_ID,GRD_NAME,TYPE_ID,Vertical_id,Subvertical_id,For_date , OT_Sec)
					SELECT D.Emp_Id , EM.Alpha_Emp_Code , EM.Emp_Full_Name , D.In_Time , D.OUT_Time , 
					CASE WHEN D.P_days = 1 THEN 'P' WHEN D.P_days = 0.50 THEN 'HF' ELSE  'A' END,D.Shift_ID , I.Branch_ID , I.Dept_ID , i.Desig_Id , i.Grd_ID , GM.Grd_Name, i.Type_ID , I.Vertical_ID , I.SubVertical_ID , D.For_date , (D.OT_Sec + D.Weekoff_OT_Sec + D.Holiday_OT_Sec) 
					FROM #DATA D
					INNER JOIN #Emp_Cons E ON E.Emp_ID = D.Emp_Id
					INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = D.Emp_Id
					INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = E.Increment_ID AND E.Emp_ID = i.Emp_ID
					INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.Grd_ID = I.Grd_ID
					WHERE D.P_days <> 0
				END

			
			UPDATE #PRESENT 
			SET STATUS = 'W' 
			FROM #PRESENT P 
			INNER JOIN #Emp_Weekoff T on P.EMP_ID = T.Emp_ID AND T.For_Date = P.For_date
			INNER JOIN #Data D ON D.Emp_Id = P.EMP_ID
			
			UPDATE #PRESENT 
			SET STATUS = 'H' 
			FROM #PRESENT P 
			INNER JOIN #EMP_HOLIDAY H on P.EMP_ID = H.Emp_ID AND H.For_Date = P.For_date
			INNER JOIN #Emp_Cons E ON E.Emp_Id = P.EMP_ID
					
			IF ISNULL(@SHIFT_ID,'') = ''
				SELECT * FROM #PRESENT Where STATUS <> 'A'
			ELSE
				SELECT * FROM #PRESENT WHERE SHIFT_ID = @Shift_ID AND STATUS <> 'A'
			
		END
	ELSE IF  @Record_Type = 'All Records'
		BEGIN
			IF @Datewise_Records = 1
				BEGIN
					INSERT INTO #PRESENT
						(EMP_ID,ALPHA_EMP_CODE,EMP_FULL_NAME,BRANCH_ID,DEPT_ID,DESIG_ID,GRD_ID,Grd_Name,TYPE_ID,Vertical_id,Subvertical_id,For_date)
					SELECT T.Emp_Id , EM.Alpha_Emp_Code , EM.Emp_Full_Name , I.Branch_ID , I.Dept_ID , i.Desig_Id , i.Grd_ID ,GM.Grd_Name, i.Type_ID , I.Vertical_ID , 
					I.SubVertical_ID , T.FOR_DATE
					FROM #tmpDates T
					INNER JOIN #Emp_Cons E ON E.Emp_ID = T.Emp_Id
					INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = T.Emp_Id
					INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = E.Increment_ID AND E.Emp_ID = i.Emp_ID
					INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.Grd_ID = I.Grd_ID
					
					Update #PRESENT 
					SET STATUS = 'W' 
					FROM #PRESENT P 
					INNER JOIN #Emp_Weekoff W on P.EMP_ID = W.Emp_ID AND W.For_Date = P.For_date
					INNER JOIN #Emp_Cons E ON E.Emp_Id = P.EMP_ID
					
					Update #PRESENT 
					SET STATUS = 'H' 
					FROM #PRESENT P 
					INNER JOIN #EMP_HOLIDAY H on P.EMP_ID = H.Emp_ID AND H.For_Date = P.For_date
					INNER JOIN #Emp_Cons E ON E.Emp_Id = P.EMP_ID
				END
			ELSE
				BEGIN
					INSERT INTO #PRESENT
						(EMP_ID,ALPHA_EMP_CODE,EMP_FULL_NAME,BRANCH_ID,DEPT_ID,DESIG_ID,GRD_ID,Grd_Name,TYPE_ID,Vertical_id,Subvertical_id,For_date)
					SELECT T.Emp_Id , EM.Alpha_Emp_Code , EM.Emp_Full_Name , I.Branch_ID , I.Dept_ID , i.Desig_Id , i.Grd_ID ,GM.Grd_Name, i.Type_ID , I.Vertical_ID , I.SubVertical_ID , @From_Date
					FROM #Emp_Cons T
					INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = T.Emp_Id
					INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = t.Increment_ID AND EM.Emp_ID = t.Emp_ID
					INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.Grd_ID = I.Grd_ID
				END
				
				--UPDATING SHIFT
				UPDATE	#PRESENT 
				SET SHIFT_ID = Shf.Shift_ID
				FROM	#PRESENT  P
					INNER JOIN (
								SELECT esd.Shift_ID, esd.Emp_ID 
								FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) 
									INNER JOIN  
										(
										 SELECT MAX(For_Date) AS For_Date,Emp_ID 
										 FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) 
										 WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date <= @To_Date GROUP BY Emp_ID
										) S ON ESD.EMP_ID = S.EMP_ID AND ESD.FOR_DATE=S.FOR_DATE
								) Shf ON Shf.Emp_ID = p.EMP_ID
								
				IF ISNULL(@SHIFT_ID,'') = ''
					SELECT * FROM #PRESENT
				ELSE
					SELECT * FROM #PRESENT WHERE SHIFT_ID = @Shift_ID
		END
	
	
	
