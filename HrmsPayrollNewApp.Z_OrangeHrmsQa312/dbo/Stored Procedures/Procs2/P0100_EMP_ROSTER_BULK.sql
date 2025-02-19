
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_EMP_ROSTER_BULK]	
	@Cmp_ID			NUMERIC,
	@FOR_DATE		DATETIME,
	@Shift_Detail	Varchar(Max),
	@WeekOff_Detail	Varchar(Max),
	@User_ID		Numeric
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	/*Shift Detail*/
	CREATE TABLE #TMP_SHIFT_DETAIL
	(
		EMP_ID		NUMERIC,
		FOR_DATE	DATETIME,
		SHIFT_ID	NUMERIC,
		HasShift	TinyInt
	)
	CREATE UNIQUE CLUSTERED INDEX IX_TMP_SHIFT_DETAIL ON #TMP_SHIFT_DETAIL(EMP_ID)

	INSERT	INTO #TMP_SHIFT_DETAIL(EMP_ID,FOR_DATE,SHIFT_ID)
	SELECT	EMP_ID, @FOR_DATE, SHIFT_ID
	FROM	(Select	Cast(SUBSTRING(DATA, 0, CHARINDEX(':', DATA)) AS NUMERIC) AS EMP_ID,Cast(SUBSTRING(DATA, CHARINDEX(':', DATA)+1, LEN(DATA)) AS NUMERIC) AS SHIFT_ID	
			 FROM	dbo.Split(@Shift_Detail, '#') T
			 WHERE	 CHARINDEX(':', DATA) > 0) T

	/*Deleting Records for late joinees (whose DOJ is after @For_Date)*/
	DELETE T FROM #TMP_SHIFT_DETAIL T INNER JOIN T0080_EMP_MASTER E ON T.EMP_ID=E.Emp_ID AND T.FOR_DATE < E.Date_Of_Join

	/*Deleting Records if there is no change in shift detail*/
	DELETE T FROM #TMP_SHIFT_DETAIL T WHERE T.SHIFT_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID,T.EMP_ID,@FOR_DATE)

	/*Deleting Not Dirty State Record*/
	DELETE T FROM #TMP_SHIFT_DETAIL T Where SHIFT_ID = -1

	/*
	Updating Flag	HasShift =1 for Already Assigned Temporary Shift on Same Date
					HasShift =2 for Already Assigned Regular Shift on Same Date
	*/
	UPDATE	T 
	SET		HasShift = CASE WHEN Shift_Type = 1 THEN 1 ELSE 2 END
	FROM	#TMP_SHIFT_DETAIL T 
			INNER JOIN T0100_EMP_SHIFT_DETAIL SD ON T.EMP_ID=SD.Emp_ID AND T.FOR_DATE=SD.For_Date

	/*Deleting Entry for Temporary Shift from T0100_EMP_SHIFT_DETAIL (which will be inserted later)*/
	DELETE	SD
	FROM	T0100_EMP_SHIFT_DETAIL SD 
			INNER JOIN #TMP_SHIFT_DETAIL T ON SD.Emp_ID=T.EMP_ID AND SD.For_Date=T.FOR_DATE AND SD.Shift_Type=1
	WHERE	HasShift=1

	/*Creating Table for Date + Emp_ID */
	CREATE TABLE #SHIFT_DATES
	(
		EMP_ID		NUMERIC,
		FOR_DATE	DATETIME
	)
	CREATE CLUSTERED INDEX IX_SHIFT_DATES ON #SHIFT_DATES(EMP_ID,FOR_DATE)

	INSERT	INTO #SHIFT_DATES(FOR_DATE,EMP_ID)
	SELECT	DATEADD(D, T.ROW_ID,  @FOR_DATE),S.EMP_ID
	FROM	(SELECT TOP 31 (ROW_NUMBER() OVER (ORDER BY OBJECT_ID) - 1) AS ROW_ID
			 FROM	sys.objects) t
			 CROSS JOIN (SELECT DISTINCT EMP_ID FROM #TMP_SHIFT_DETAIL) S

	/*
	Skipping/Updating For_Date in T0100_EMP_SHIFT_DETAIL for Regular Shift 
	For Example:	01-04-2018  -	Shift 1	(Regular Shift)
					02-04-2018  -	Shift 3	(Temporary Shift By Roster)

					if there is a regular shift (Shift 1) assigned on 01-04-2018 and user tries to change the shift from roster for the same date with "Shift 2". 
					then old (Shift 1) shift should be skipped to next date or on the date where there is shift is assigned.

					01-04-2018	-	Shift 2 (Temporary Shift By Roster) - newly assigned
					02-04-2018  -	Shift 3	(Temporary Shift By Roster)
					03-04-2018  -	Shift 1	(Regular Shift) - skipped to next empty date

	*/
	UPDATE	T
	SET		FOR_DATE = D.FOR_DATE
	FROM	T0100_EMP_SHIFT_DETAIL SD
			INNER JOIN #TMP_SHIFT_DETAIL T ON T.EMP_ID=SD.Emp_ID AND SD.For_Date=T.FOR_DATE
			INNER JOIN (SELECT	D.EMP_ID, MIN(ISNULL(D.FOR_DATE, @FOR_DATE + 365)) AS FOR_DATE
						FROM	#SHIFT_DATES D 
								LEFT OUTER JOIN T0100_EMP_SHIFT_DETAIL SD WITH (NOLOCK) ON SD.For_Date=D.FOR_DATE AND SD.Emp_ID=D.EMP_ID
						WHERE	SD.Emp_ID IS NULL
						GROUP BY D.EMP_ID) D ON T.EMP_ID=D.EMP_ID

	/*Finally Inserting new Temporary Shift By Roster*/
	DECLARE @SHIFT_TRAN_ID	NUMERIC
	SELECT @SHIFT_TRAN_ID = ISNULL(MAX(SHIFT_TRAN_ID),0)  FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)

	INSERT	INTO T0100_EMP_SHIFT_DETAIL(Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date,Shift_Type)
	SELECT	(ROW_NUMBER() OVER(ORDER BY EMP_ID,FOR_DATE) + 	@SHIFT_TRAN_ID) AS Shift_Tran_ID, EMP_ID, @Cmp_ID, SHIFT_ID, FOR_DATE, 1
	FROM	#TMP_SHIFT_DETAIL T
		--	VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date,@Shift_type)
	
	DECLARE @FLAG NUMERIC
	SET @FLAG = 0

	
	/*WeekOff Detail*/
	CREATE TABLE #TMP_WO_DETAIL
	(
		EMP_ID		NUMERIC,
		FOR_DATE	DATETIME,
		W_Day		SMALLINT
	)
	CREATE UNIQUE CLUSTERED INDEX IX_TMP_WO_DETAIL ON #TMP_WO_DETAIL(EMP_ID)

	INSERT	INTO #TMP_WO_DETAIL(EMP_ID,FOR_DATE,W_Day)
	SELECT	EMP_ID, @FOR_DATE, W_Day
	FROM	(Select	Cast(SUBSTRING(DATA, 0, CHARINDEX(':', DATA)) AS NUMERIC) AS EMP_ID,Cast(SUBSTRING(DATA, CHARINDEX(':', DATA)+1, LEN(DATA)) AS NUMERIC) AS W_Day	
			 FROM	dbo.Split(@WeekOff_Detail, '#') T
			 WHERE	 CHARINDEX(':', DATA) > 0) T

	
	DECLARE @CONSTRAINT VARCHAR(MAX)

	SELECT	@CONSTRAINT = ISNULL(@CONSTRAINT + '#','') + CAST(EMP_ID AS VARCHAR(10)) FROM #TMP_WO_DETAIL

	CREATE TABLE #EMP_HW_CONS
	(
		Emp_ID				NUMERIC,
		WeekOffDate			Varchar(Max),
		WeekOffCount		NUMERIC(4,1),
		CancelWeekOff		Varchar(Max),
		CancelWeekOffCount	NUMERIC(4,1),
		HolidayDate			Varchar(MAX),
		HolidayCount		NUMERIC(4,1),
		HalfHolidayDate		Varchar(MAX),
		HalfHolidayCount	NUMERIC(4,1),
		CancelHoliday		Varchar(Max),
		CancelHolidayCount	NUMERIC(4,1)
	)
	CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON #EMP_HW_CONS(Emp_ID)

	CREATE TABLE #Emp_WeekOff_Holiday
	(
		Emp_ID				NUMERIC,
		WeekOffDate			VARCHAR(Max),
		WeekOffCount		NUMERIC(4,1),
		HolidayDate			VARCHAR(Max),
		HolidayCount		NUMERIC(4,1),
		HalfHolidayDate		VARCHAR(Max),
		HalfHolidayCount	NUMERIC(4,1),
		OptHolidayDate		VARCHAR(Max),
		OptHolidayCount		NUMERIC(4,1)
	)
	CREATE UNIQUE CLUSTERED INDEX IX_Emp_WeekOff_Holiday_EMPID ON #Emp_WeekOff_Holiday(Emp_ID);


	
	CREATE TABLE #Emp_WeekOff
	(
		Row_ID			NUMERIC,
		Emp_ID			NUMERIC,
		For_Date		DATETIME,
		Weekoff_day		VARCHAR(10),
		W_Day			numeric(4,1),
		Is_Cancel		BIT
	)
	CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #Emp_WeekOff(Emp_ID, For_Date)

	EXEC SP_EMP_HOLIDAY_WEEKOFF_ALL @CONSTRAINT=@CONSTRAINT, @Cmp_ID=@Cmp_ID,@From_Date=@FOR_DATE,@To_Date=@FOR_DATE,@All_WeekOff=0

	/*If default weekoff is already assigned and Roster also have the same record then delete it*/
	DELETE	WR 
	FROM	T0100_WEEKOFF_ROSTER WR
			INNER JOIN #Emp_WeekOff W ON WR.EMP_ID=W.EMP_ID AND WR.FOR_DATE=W.FOR_DATE
	WHERE	NOT EXISTS(SELECT 1 FROM #TMP_WO_DETAIL WO WHERE WR.Emp_id=WO.EMP_ID AND WR.For_date=WO.FOR_DATE AND WO.W_Day = 1)

	DELETE	WR 
	FROM	#TMP_WO_DETAIL WR
	WHERE	EXISTS(SELECT 1 FROM #Emp_WeekOff WO WHERE WR.Emp_id=WO.EMP_ID AND WR.For_date=WO.FOR_DATE)
			AND WR.W_Day=1

	
	/*Deleting Records for late joinees (whose DOJ is after @For_Date)*/
	DELETE T FROM #TMP_WO_DETAIL T INNER JOIN T0080_EMP_MASTER E ON T.EMP_ID=E.Emp_ID AND T.FOR_DATE < E.Date_Of_Join

	/*Deleting Not Dirty State Record*/
	DELETE T FROM #TMP_WO_DETAIL T Where W_Day = -1

	/*Deleting Existing Entries*/
	DELETE R FROM T0100_WEEKOFF_ROSTER R INNER JOIN #TMP_WO_DETAIL WR ON R.Emp_id=WR.EMP_ID AND R.For_date=WR.FOR_DATE


	DECLARE @Tran_ID Numeric
	SELECT	@Tran_ID = Max(Tran_ID) FROM T0100_WEEKOFF_ROSTER WITH (NOLOCK)
	SET @Tran_ID = IsNull(@Tran_ID,0)

	INSERT INTO T0100_WEEKOFF_ROSTER(Tran_Id,Cmp_id,Emp_id,For_Date,is_Cancel_WO,User_ID, System_Date)
	SELECT	ROW_NUMBER() OVER(ORDER BY EMP_ID,FOR_DATE) + @Tran_ID,@Cmp_ID,EMP_ID,@FOR_DATE, Case When W_Day = 1 Then 0 Else 1 End, @User_ID, GETDATE()
	FROM	#TMP_WO_DETAIL
		
	RETURN




