

CREATE PROCEDURE [dbo].[SP_Holiday_Weekoff_Calendar]
	@CMP_ID				NUMERIC,
	@EFFECTIVE_DATE		DATETIME,
	@CONSTRAINT			VARCHAR(MAX) = '',
	@BRANCH_ID			NUMERIC = 0,
	@GRD_ID				NUMERIC = 0,
	@VERTICAL_ID		NUMERIC = 0,
	@SUBVERTICAL		NUMERIC = 0,
	@EMP_ID				NUMERIC = 0,
	@MODE				TINYINT = 0	-- 0: For Calendar, 1: For Upcoming Holiday, 2: For Both
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
         
    
	DECLARE @FROM_DATE DATETIME
	DECLARE @TO_DATE DATETIME
	DECLARE @MONTH_END_DATE DATETIME
	DECLARE @TEMP_CONSTRAINT VARCHAR(MAX);
	DECLARE @OUTOF_DAYS			NUMERIC        
	
	SET @FROM_DATE = dbo.GET_MONTH_ST_DATE(MONTH(@EFFECTIVE_DATE) , YEAR(@EFFECTIVE_DATE))
	--SET @TO_DATE = @EFFECTIVE_DATE
	SET @TO_DATE = dbo.GET_MONTH_END_DATE(MONTH(@EFFECTIVE_DATE) , YEAR(@EFFECTIVE_DATE))

	SET @OUTOF_DAYS = DATEDIFF(D,@FROM_DATE,@MONTH_END_DATE) + 1  

	--	THIS LOGIC IS IMPORTANT , THIS WILL BE USED , IF DATA IS TAKING TOO MUCH TO LOAD , ON CLIENT SIDE , THEN WE WILL SAVE THE DATA WHEN LOADED FIRST TIME , THEN IT WILL NOT BE LOADED FOR THAT DATA

	--SELECT	@TEMP_CONSTRAINT = COALESCE(@TEMP_CONSTRAINT + '#','') + CAST(EMP_ID AS VARCHAR(10))
	--FROM	dbo.Split(@CONSTRAINT,'#') T1 LEFT OUTER JOIN T0100_ADVANCE_PRESENT_DAYS T ON T.Emp_ID=Cast(T1.Data As numeric)
	--Where	T1.Data <> '' AND T.Emp_Id Is NUll

	CREATE TABLE #EMP_CONS 
	(      
		EMP_ID NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC    
	)  


	EXEC SP_RPT_FILL_EMP_CONS  @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,0,@GRD_ID,0,0,0,@EMP_ID,@CONSTRAINT ,0 ,0 ,0,@VERTICAL_ID,@SUBVERTICAL,0,0,0,0,0,0,0
	
	CREATE NONCLUSTERED INDEX IX_EMPCONS ON #EMP_CONS (EMP_ID)

	CREATE TABLE #DATA         
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
	CREATE NONCLUSTERED INDEX IX_DATA ON #DATA (EMP_ID, FOR_DATE)

	DECLARE @Required_Execution BIT;
	SET @Required_Execution = 0;

	
	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
			SET @Required_Execution = 1
		END

	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
		BEGIN
			CREATE TABLE #EMP_WEEKOFF
			(
				Row_ID			NUMERIC,
				Emp_ID			NUMERIC,
				For_Date		DATETIME,
				Weekoff_day		VARCHAR(10),
				W_Day			numeric(4,1),
				Is_Cancel		BIT
			)
			CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #EMP_WEEKOFF(Emp_ID, For_Date)		
			SET @Required_Execution = 1
		END

	IF (@MODE = 0 OR @MODE = 2)
		BEGIN 
			IF @Required_Execution = 1 
				BEGIN
					EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0
				END 


			Select 'Weekoff' as title,REPLACE(CONVERT(VARCHAR(10), EW.For_Date, 102), '.', '-') As [start],REPLACE(CONVERT(VARCHAR(10), EW.For_Date, 102), '.', '-') As [end],'Weekoff' As [type],'fc-day-grid-event fc-h-event fc-event fc-start fc-end bg-success fc-draggable' as className   From #EMP_WEEKOFF EW
			Union ALL
				Select Distinct HD.Hday_Name as title,convert(varchar(11), dateadd(yy,(year(@From_Date) - year(HD.H_From_Date) ),HD.H_From_Date), 106) as St_Date,
				convert(varchar(11), dateadd(yy,(year(@to_date) - year(HD.H_To_Date)),HD.H_To_Date), 106) as St_End,'Holiday' As Type,'fc-day-grid-event fc-h-event fc-event fc-start fc-end bg-danger fc-draggable' as className 
				From #EMP_HOLIDAY EH inner Join T0040_HOLIDAY_MASTER HD WITH (NOLOCK)
				ON Month(EH.FOR_DATE) = Month(HD.H_From_Date) and Day(EH.FOR_DATE) = Day(HD.H_To_Date) and Isnull(HD.Is_Fix,'N') = 'Y' and cmp_Id = @Cmp_ID
			Union ALL
				Select Distinct HD.Hday_Name as title,REPLACE(CONVERT(VARCHAR(10), HD.H_From_Date, 102), '.', '-') As [start],REPLACE(CONVERT(VARCHAR(10), HD.H_From_Date, 102), '.', '-') As [end],'Holiday' As [type],'fc-day-grid-event fc-h-event fc-event fc-start fc-end bg-danger fc-draggable' as className  
				From #EMP_HOLIDAY EH inner Join T0040_HOLIDAY_MASTER HD WITH (NOLOCK)
				ON EH.FOR_DATE >= HD.H_From_Date and EH.FOR_DATE <= HD.H_To_Date and Isnull(HD.Is_Fix,'N') = 'N' and cmp_Id = @Cmp_ID
		END
	/**************************************************************************************************/
	/************************************For Upcoming Holiday******************************************/
	/**************************************************************************************************/
	IF (@MODE = 1 OR @MODE = 2)
		BEGIN	
			DECLARE		@YEAR_START_DATE DATETIME
			SET @YEAR_START_DATE = DATEADD(YYYY, YEAR(@FROM_DATE) - 1900, '1900-01-01')
			
			DECLARE		@YEAR_END_DATE DATETIME
			SET @YEAR_END_DATE = DATEADD(YYYY, YEAR(@TO_DATE) - 1900, '1900-12-31')
			

			CREATE TABLE #DATES(FOR_DATE DATETIME, FOR_MD numeric);
			CREATE UNIQUE CLUSTERED INDEX IX_DATES_H_FORDATE ON #DATES(For_Date, FOR_MD);

			INSERT INTO #DATES
			SELECT FOR_DATE, CAST(RIGHT(CONVERT(VARCHAR(10), T.FOR_DATE, 112), 4) AS numeric) AS FOR_MD		
			FROM (SELECT DATEADD(d, ROW_NUMBER() OVER(ORDER BY object_id) -1, @YEAR_START_DATE ) AS FOR_DATE FROM sys.all_objects) T 
			WHERE FOR_DATE <= @YEAR_END_DATE

			

			SELECT	DISTINCT ROW_NUMBER() OVER(ORDER BY H.Branch_ID, D.FOR_DATE) AS ROW_ID, H.Branch_ID, H.H_From_Date, H.H_To_Date , D.FOR_DATE, H.Is_Fix, H.Is_Half_Day, H.Is_P_Comp,0 AS Is_Opt, Hday_Name
			INTO	#TMP_HOLIDAY					
			FROM	(
						SELECT	CASE WHEN  Is_Fix = 'Y' Then	
									DATEADD(YYYY, DATEDIFF(YYYY, H_From_Date, GETDATE()), H_From_Date) 
								ELSE 
									H_From_Date 
								END AS H_From_Date,
								CASE WHEN  Is_Fix = 'Y' Then	
									DATEADD(YYYY, DATEDIFF(YYYY, H_To_Date,GETDATE()), H_To_Date)
								ELSE 
									H_To_Date 
								END AS H_To_Date,											
								H.Branch_ID, Is_Fix Collate SQL_Latin1_General_CP1_CI_AS as Is_Fix, H.Is_P_Comp, H.Is_Half As Is_Half_Day,
								H.Hday_Name
						FROM	T0040_HOLIDAY_MASTER H WITH (NOLOCK) --INNER JOIN #EMP_BRANCH B ON H.Branch_ID=B.BRANCH_ID OR H.Branch_ID IS NULL
								--INNER JOIN (SELECT DISTINCT BRANCH_ID FROM  #EMP_CONS E) E ON H.Branch_ID=E.BRANCH_ID
						WHERE	H.cmp_Id=@Cmp_ID AND IsNull(H.Is_Optional, 0)=0  And ISNULL(H.Is_P_Comp,0) = 0
								--AND EXISTS (SELECT 1 FROM  #EMP_CONS E WHERE E.BRANCH_ID = ISNULL(H.Branch_ID, E.BRANCH_ID))
					) H INNER JOIN #DATES D ON D.FOR_DATE BETWEEN H.H_From_Date AND H.H_To_Date 

	
			/*
			SELECT	DISTINCT ROW_NUMBER() OVER(ORDER BY H.Branch_ID, H.FOR_DATE) AS ROW_ID, H.Branch_ID, H.H_From_Date, H.H_To_Date , H.FOR_DATE, H.Is_Fix, H.Is_Half_Day, H.Is_P_Comp,Is_Opt, Hday_Name
			INTO	#TMP_HOLIDAY
			FROM	(
						SELECT 	H.Branch_ID, H.H_From_Date, H.H_To_Date , D.FOR_DATE, H.Is_Fix, H.Is_Half_Day, H.Is_P_Comp,0 As Is_Opt, Hday_Name
						FROM	(
									SELECT	CAST(RIGHT(CONVERT(VARCHAR(10), H_From_Date, 112), 4) AS NUMERIC) AS FROM_MD,
											CAST(RIGHT(CONVERT(VARCHAR(10), H_To_Date, 112), 4) AS NUMERIC) AS TO_MD,
											H.Branch_ID, H.H_From_Date, H.H_To_Date,Is_Fix Collate SQL_Latin1_General_CP1_CI_AS as Is_Fix, H.Is_P_Comp, H.Is_Half As Is_Half_Day,
											H.Hday_Name
									FROM	T0040_HOLIDAY_MASTER H --INNER JOIN #EMP_BRANCH B ON H.Branch_ID=B.BRANCH_ID OR H.Branch_ID IS NULL
											INNER JOIN (SELECT DISTINCT BRANCH_ID FROM  #EMP_CONS E) E ON H.Branch_ID=E.BRANCH_ID
									WHERE	H.cmp_Id=@Cmp_ID AND IsNull(H.Is_Optional, 0)=0  And ISNULL(H.Is_P_Comp,0) = 0
								) H
								INNER JOIN #DATES D ON (D.FOR_DATE BETWEEN h.H_From_Date AND H.H_To_Date AND H.Is_Fix='N') OR (D.For_MD BETWEEN h.FROM_MD AND H.TO_MD AND H.Is_Fix='Y')							
					) H
			*/
			DROP TABLE #DATES

			CREATE TABLE #HDATES (Branch_ID numeric, H_From_Date DATETIME, H_To_Date DATETIME, FOR_DATE datetime, IS_FIX CHAR(1), Is_Half_Day tinyint , Is_P_Comp tinyint, Is_Opt bit, HDay_Name Varchar(64));
			CREATE UNIQUE CLUSTERED INDEX IX_HDATES_H_BRANCHID_FOR_DATE ON #HDATES(BRANCH_ID, FOR_DATE);

			INSERT	INTO #HDATES
			SELECT	Branch_ID, H_From_Date, H_To_Date , FOR_DATE, Is_Fix, Is_Half_Day, Is_P_Comp,Is_Opt, Hday_Name
			FROM	#TMP_HOLIDAY T
			WHERE	ROW_ID = (SELECT TOP 1 ROW_ID FROM #TMP_HOLIDAY T1 WHERE T.FOR_DATE=T1.FOR_DATE AND (T.BRANCH_ID=T1.BRANCH_ID OR T1.BRANCH_ID IS NULL))
	
			SELECT	DISTINCT E.EMP_ID, H.FOR_DATE,Is_Half_Day,Is_P_Comp, HDay_Name
			INTO	#UC_EMP_HOLIDAY
			FROM	#HDATES H INNER JOIN #EMP_CONS E ON H.Branch_ID=E.BRANCH_ID OR H.Branch_ID IS NULL

			SELECT	Day(FOR_DATE) As [Day], DateName(MM, FOR_DATE) As [Month],YEAR(FOR_DATE) As [Year],
					DATENAME(WEEKDAY, For_Date) As [DayName],
					(Case When Len(HDay_Name) > 20 Then RTRIM(LEFT(HDay_Name,20)) + '...' ELSE HDay_Name END) As HolidayName  
			FROM	#UC_EMP_HOLIDAY
		END
END


