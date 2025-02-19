
-- =============================================
-- Author:		Gadriwala Muslim
-- ALTER date: <01/09/2014>
-- Description:	GET EMPLOYEE COMP OFF DETAILS 
--	WITH HOLIDAY,WEEKDAY,WEEKOFF COMPOFF LIMIT
-- =============================================
CREATE PROCEDURE [dbo].[GET_COMPOFF_DETAILS] 
     @For_Date DATETIME
	,@Cmp_ID NUMERIC(18, 0)
	,@Emp_ID NUMERIC(18, 0)
	,@leave_ID NUMERIC(18, 0)
	,@Leave_Application_ID NUMERIC(18, 0) = 0
	,@Leave_Encash_App_ID NUMERIC(18, 0) = 0
	,@Exec_For NUMERIC(18, 0) = 0
	,@Leave_Period NUMERIC(18, 2) = 0 
AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	CREATE TABLE #Weekday_OT (
		Weekday_OT_Trans NUMERIC
		,Cmp_ID NUMERIC
		,Emp_ID NUMERIC
		,For_Date DATETIME
		,CompOff_Credit NUMERIC(18, 2)
		,CompOff_Debit NUMERIC(18, 2)
		,CompOff_balance NUMERIC(18, 2)
		,Branch_ID NUMERIC
		,Is_CompOff NUMERIC
		,CompOff_Days_Limit NUMERIC
		,CompOff_Type VARCHAR(2)
		)

	CREATE TABLE #WeekOff_OT (
		WeekOff_OT_Trans NUMERIC
		,Cmp_ID NUMERIC
		,Emp_ID NUMERIC
		,For_Date DATETIME
		,CompOff_Credit NUMERIC(18, 2)
		,CompOff_Debit NUMERIC(18, 2)
		,CompOff_balance NUMERIC(18, 2)
		,Branch_ID NUMERIC
		,Is_CompOff NUMERIC
		,CompOff_Days_Limit NUMERIC
		,CompOff_Type VARCHAR(2)
		)

	CREATE TABLE #Holiday_OT (
		Holiday_OT_Trans NUMERIC
		,Cmp_ID NUMERIC
		,Emp_ID NUMERIC
		,For_Date DATETIME
		,CompOff_Credit NUMERIC(18, 2)
		,CompOff_Debit NUMERIC(18, 2)
		,CompOff_balance NUMERIC(18, 2)
		,Branch_ID NUMERIC
		,Is_CompOff NUMERIC
		,CompOff_Days_Limit NUMERIC
		,CompOff_Type VARCHAR(2)
		)

	CREATE TABLE #General_OT (
		Leave_Tran_ID NUMERIC
		,Cmp_ID NUMERIC
		,Emp_ID NUMERIC
		,For_Date DATETIME
		,CompOff_Credit NUMERIC(18, 2)
		,CompOff_Debit NUMERIC(18, 2)
		,CompOff_balance NUMERIC(18, 2)
		,Branch_ID NUMERIC
		,Is_CompOff NUMERIC
		,CompOff_Days_Limit NUMERIC
		,CompOff_Type VARCHAR(2)
		)

	CREATE TABLE #Emp_Holiday (
		Emp_Id NUMERIC
		,Cmp_ID NUMERIC
		,For_Date DATETIME
		,H_Day NUMERIC(3, 1)
		,is_Half_day TINYINT
		)

	DECLARE @branch_id AS NUMERIC
	DECLARE @Holiday_CompOff_Limit AS NUMERIC
	DECLARE @Holiday_From_Date AS VARCHAR(11)
	DECLARE @Weekoff_CompOff_Limit AS NUMERIC
	DECLARE @Weekoff_From_Date AS VARCHAR(11)
	DECLARE @Weekday_CompOff_Limit AS NUMERIC
	DECLARE @Weekday_From_Date AS VARCHAR(11)
	DECLARE @HolidayCompOffAvail_After_Days AS NUMERIC
	DECLARE @HolidayCompOffAvail_After_From_Date AS VARCHAR(11)
	DECLARE @WeekOffCompOffAvail_After_Days AS NUMERIC
	DECLARE @WeekOffCompOffAvail_After_Days_From_Date AS VARCHAR(11)
	DECLARE @WeekdayCompOffAvail_After_Days AS NUMERIC
	DECLARE @WeekdayCompOffAvail_After_Days_From_Date AS VARCHAR(11)
	DECLARE @Weekday_CompOff_Limit_BranchWise AS NUMERIC
	DECLARE @Holiday_CompOff_Limit_BranchWise AS NUMERIC
	DECLARE @Weekoff_CompOff_Limit_BranchWise AS NUMERIC
	DECLARE @HolidayCompOffAvail_After_Days_BranchWise AS NUMERIC
	DECLARE @WeekOffCompOffAvail_After_Days_BranchWise AS NUMERIC
	DECLARE @WeekdayCompOffAvail_After_Days_BranchWise AS NUMERIC
	DECLARE @CompOff_with_Current_Date AS TINYINT

	SET @CompOff_with_Current_Date = 0

	SELECT @CompOff_with_Current_Date = Setting_Value
	FROM T0040_SETTING WITH (NOLOCK)
	WHERE Cmp_ID = @Cmp_ID
		AND Setting_Name = 'Comp-off Balance show as on date wise'

	IF @CompOff_with_Current_Date = 1
		SET @For_Date = GETDATE()

	-- Added by Gadriwala Muslim 13052015 - End
	SELECT @branch_id = branch_id
	FROM dbo.T0095_INCREMENT WITH (NOLOCK)
	WHERE Emp_ID = @Emp_ID
		AND Increment_ID = (
			SELECT MAX(Increment_ID)
			FROM dbo.T0095_INCREMENT WITH (NOLOCK)
			WHERE Emp_ID = @Emp_ID
				AND cmp_ID = @cmp_ID
				AND Increment_Effective_Date <= @For_Date
			)

	SELECT @Weekday_CompOff_Limit = CompOff_WD_Avail_Days
		,@Weekoff_CompOff_Limit = CompOff_WO_Avail_Days
		,@Holiday_CompOff_Limit = CompOff_HO_Avail_Days
		,@HolidayCompOffAvail_After_Days = HolidayCompOffAvail_After_Days
		,@WeekOffCompOffAvail_After_Days = WeekOffCompOffAvail_After_Days
		,@WeekdayCompOffAvail_After_Days = WeekdayCompOffAvail_After_Days 
	FROM dbo.T0080_EMP_MASTER WITH (NOLOCK)
	WHERE Emp_ID = @Emp_ID
		AND Cmp_ID = @Cmp_ID

	DECLARE @Emp_Week_Detail NUMERIC(18, 0)
	DECLARE @Is_Cancel_Weekoff NUMERIC(1, 0)
	DECLARE @Weekoff_Days NUMERIC(12, 1)
	DECLARE @StrHoliday_Date VARCHAR(Max)
	DECLARE @StrWeekoff_Date VARCHAR(Max)
	DECLARE @Is_Cancel_Holiday INT
	DECLARE @strweekoff VARCHAR(max)
	DECLARE @Cancel_Weekoff NUMERIC(12, 1)
	DECLARE @Holiday_days NUMERIC(18, 2)
	DECLARE @Cancel_Holiday NUMERIC(18, 2)
	DECLARE @Week_oF_Branch NUMERIC(18, 0)
	DECLARE @tras_week_ot TINYINT
	DECLARE @Auto_OT TINYINT
	DECLARE @OT_Present TINYINT
	DECLARE @Is_Compoff NUMERIC
	DECLARE @Is_WD NUMERIC
	DECLARE @Is_WOHO NUMERIC
	DECLARE @Is_HO_CompOff NUMERIC
	DECLARE @Is_W_CompOff NUMERIC

	SELECT @Is_Cancel_weekoff = Is_Cancel_weekoff
		,@tras_week_ot = isnull(tras_week_ot, 0)
		,@Auto_OT = Is_OT_Auto_Calc
		,@OT_Present = OT_Present_days
		,@Is_Compoff = ISNULL(Is_CompOff, 0)
		,@Is_WD = ISNULL(Is_CompOff_WD, 0)
		,@Is_WOHO = ISNULL(Is_CompOff_WOHO, 0)
		,@Is_Cancel_Holiday = Is_Cancel_Holiday
		,@Is_HO_CompOff = Is_HO_CompOff
		,@Is_W_CompOff = Is_W_CompOff
		,@Weekday_CompOff_Limit_BranchWise = isnull(CompOff_Avail_Days, 0)
		,@Holiday_CompOff_Limit_BranchWise = isnull(H_CompOff_Avail_Days, 0)
		,@Weekoff_CompOff_Limit_BranchWise = isnull(W_CompOff_Avail_Days, 0)
		,@HolidayCompOffAvail_After_Days_BranchWise = isnull(Holiday_CompOff_Avail_After_Days, 0)
		,@WeekOffCompOffAvail_After_Days_BranchWise = isnull(WeekOff_CompOff_Avail_After_Days, 0)
		,@WeekdayCompOffAvail_After_Days_BranchWise = isnull(WeekDay_CompOff_Avail_After_Days, 0) --added binal 0302020
	FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
	WHERE cmp_ID = @cmp_ID
		AND Branch_ID = @branch_id
		AND For_Date = (
			SELECT max(For_Date)
			FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
			WHERE For_Date <= @For_Date
				AND Branch_ID = @branch_id
				AND Cmp_ID = @Cmp_ID
			)

	IF @Weekday_CompOff_Limit = 0
		SET @Weekday_CompOff_Limit = isnull(@Weekday_CompOff_Limit_BranchWise, 0)

	IF @Holiday_CompOff_Limit = 0
		SET @Holiday_CompOff_Limit = isnull(@Holiday_CompOff_Limit_BranchWise, 0)

	IF @Weekoff_CompOff_Limit = 0
		SET @Weekoff_CompOff_Limit = isnull(@Weekoff_CompOff_Limit_BranchWise, 0)

	IF IsNull(@HolidayCompOffAvail_After_Days, 0) = 0
		SET @HolidayCompOffAvail_After_Days = 0

	IF IsNull(@WeekOffCompOffAvail_After_Days, 0) = 0
		SET @WeekOffCompOffAvail_After_Days = 0

	IF IsNull(@WeekdayCompOffAvail_After_Days, 0) = 0
		SET @WeekdayCompOffAvail_After_Days = 0

	IF @HolidayCompOffAvail_After_Days = 0
		SET @HolidayCompOffAvail_After_Days = isnull(@HolidayCompOffAvail_After_Days_BranchWise, 0)

	IF @WeekOffCompOffAvail_After_Days = 0
		SET @WeekOffCompOffAvail_After_Days = isnull(@WeekOffCompOffAvail_After_Days_BranchWise, 0)

	IF @WeekdayCompOffAvail_After_Days = 0
		SET @WeekdayCompOffAvail_After_Days = isnull(@WeekdayCompOffAvail_After_Days_BranchWise, 0)

	IF @Weekday_CompOff_Limit = 0
		SET @Weekday_CompOff_Limit = 60

	IF @Holiday_CompOff_Limit = 0
		SET @Holiday_CompOff_Limit = 60

	IF @Weekoff_CompOff_Limit = 0
		SET @Weekoff_CompOff_Limit = 60
	SET @Holiday_From_Date = Convert(VARCHAR(25), DATEADD(D, (@Holiday_CompOff_Limit + @HolidayCompOffAvail_After_Days) * - 1, @For_Date))
	SET @Weekoff_From_Date = Convert(VARCHAR(25), DATEADD(D, (@Weekoff_CompOff_Limit + @WeekOffCompOffAvail_After_Days) * - 1, @For_Date))
	SET @Weekday_From_Date = Convert(VARCHAR(25), DATEADD(D, (@Weekday_CompOff_Limit + @WeekdayCompOffAvail_After_Days) * - 1, @For_Date))
	SET @HolidayCompOffAvail_After_From_Date = Convert(VARCHAR(25), DATEADD(D, @HolidayCompOffAvail_After_Days, @For_Date))
	SET @WeekOffCompOffAvail_After_Days_From_Date = Convert(VARCHAR(25), DATEADD(D, @WeekOffCompOffAvail_After_Days, @For_Date))
	SET @WeekdayCompOffAvail_After_Days_From_Date = Convert(VARCHAR(25), DATEADD(D, @WeekdayCompOffAvail_After_Days, @For_Date))

	
	IF @Exec_For = 55 /* 55 : Auto CarryForward SQL Job : SP--P_JOB_GET_COMPOFF_BALANCE_AUTOCREDIT */ ---- Auto CarryFoward Compoff Leave --Ankit 01022016
	BEGIN
		SET @For_Date = @Weekoff_From_Date
		SET @Weekoff_From_Date = Convert(VARCHAR(25), DATEADD(D, @Weekoff_CompOff_Limit * - 1, @Weekoff_From_Date))
	END

	SET @StrWeekoff_Date = ''
	SET @Weekoff_Days = 0
	SET @Cancel_Weekoff = 0
	SET @StrHoliday_Date = ''
	SET @Holiday_days = 0
	SET @Cancel_Holiday = 0

	IF @Is_WD = 1
	BEGIN
		EXEC dbo.SP_EMP_HOLIDAY_DATE_GET @emp_ID
			,@Cmp_ID
			,@Weekday_From_Date
			,@For_Date
			,NULL
			,NULL
			,@Is_Cancel_Holiday
			,@StrHoliday_Date OUTPUT
			,@Holiday_days OUTPUT
			,@Cancel_Holiday OUTPUT
			,0
			,@Branch_ID
			,@StrWeekoff_Date

		EXEC dbo.SP_EMP_WEEKOFF_DATE_GET @emp_ID
			,@Cmp_ID
			,@Weekday_From_Date
			,@For_Date
			,NULL
			,NULL
			,@Is_Cancel_weekoff
			,''
			,@StrWeekoff_Date OUTPUT
			,@Weekoff_Days OUTPUT
			,@Cancel_Weekoff OUTPUT

		INSERT INTO #Weekday_OT (
			Weekday_OT_Trans
			,cmp_ID
			,Emp_ID
			,For_Date
			,CompOff_Credit
			,CompOff_Debit
			,CompOff_Balance
			,Branch_ID
			,Is_CompOFF
			,CompOFF_Days_Limit
			,CompOff_Type
			)
		SELECT Leave_Tran_ID
			,@Cmp_ID
			,@Emp_ID
			,For_Date
			,Compoff_Credit
			,CompOFf_Debit
			,CompOFF_Balance
			,@branch_id
			,Comoff_Flag
			,@Weekday_CompOff_Limit
			,'WD'
		FROM dbo.T0140_LEAVE_TRANSACTION WITH (NOLOCK)
		WHERE Leave_ID = @leave_ID
			AND DATEADD(day, @WeekdayCompOffAvail_After_Days, For_Date) + 1 BETWEEN for_date
				AND @For_Date -- Getdate() --Commented Getdate() and added @For_Date by Hardik 20/10/2020 for WCL as if compoff on 2nd Oct 2020 and employee can apply on 1st Oct 2020 which is wrong
			AND DATEADD(day, @Weekday_CompOff_Limit + @WeekdayCompOffAvail_After_Days, For_Date) >= @For_Date -- Getdate() --Commented Getdate() and added @For_Date by Hardik 20/10/2020 for WCL as if compoff on 2nd Oct 2020 and employee can apply on 1st Oct 2020 which is wrong
			AND Cmp_ID = @Cmp_ID
			AND Emp_ID = @Emp_ID
			AND Comoff_Flag = 1
			AND For_Date NOT IN (
				SELECT Data
				FROM dbo.Split(@StrWeekoff_Date, ';')
				WHERE Data <> ''
				)
			AND For_Date NOT IN (
				SELECT Data
				FROM dbo.Split(@StrHoliday_Date, ';')
				WHERE Data <> ''
				)
	END

	IF @Is_HO_CompOff = 1
		AND (
			@Weekday_CompOff_Limit <> @Holiday_CompOff_Limit
			OR @Is_WD = 0
			)
	BEGIN
		EXEC dbo.SP_EMP_HOLIDAY_DATE_GET @emp_ID
			,@Cmp_ID
			,@Holiday_From_Date
			,@For_Date
			,NULL
			,NULL
			,9
			,@StrHoliday_Date OUTPUT
			,@Holiday_days OUTPUT
			,@Cancel_Holiday OUTPUT
			,0
			,@Branch_ID
			,@StrWeekoff_Date
	END

	IF @Is_W_CompOff = 1
		AND (
			@Weekday_CompOff_Limit <> @Weekoff_CompOff_Limit
			OR @Is_WD = 0
			)
	BEGIN
		EXEC dbo.SP_EMP_WEEKOFF_DATE_GET @emp_ID
			,@Cmp_ID
			,@Weekoff_From_Date
			,@For_Date
			,NULL
			,NULL
			,9
			,''
			,@StrWeekoff_Date OUTPUT
			,@Weekoff_Days OUTPUT
			,@Cancel_Weekoff OUTPUT
	END

	IF @StrHoliday_Date <> ''
		AND @Is_HO_CompOff = 1
	BEGIN
		BEGIN
			INSERT INTO #Holiday_OT (
				Holiday_OT_Trans
				,cmp_ID
				,Emp_ID
				,For_Date
				,CompOff_Credit
				,CompOff_Debit
				,CompOff_Balance
				,Branch_ID
				,Is_CompOFF
				,CompOFF_Days_Limit
				,CompOff_Type
				)
			SELECT Leave_Tran_ID
				,@Cmp_ID
				,@Emp_ID
				,For_Date
				,Compoff_Credit
				,CompOFf_Debit
				,CompOFF_Balance
				,@branch_id
				,Comoff_Flag
				,@Holiday_CompOff_Limit
				,'HO'
			FROM dbo.T0140_LEAVE_TRANSACTION WITH (NOLOCK)
			WHERE Leave_ID = @leave_ID
				AND DATEADD(day, @HolidayCompOffAvail_After_Days, For_Date) + 1 BETWEEN for_date
					AND @For_Date 
				AND DATEADD(day, @Holiday_CompOff_Limit + @HolidayCompOffAvail_After_Days, For_Date) >= @For_Date 
				AND Cmp_ID = @Cmp_ID
				AND Emp_ID = @Emp_ID
				AND NOT EXISTS (
					SELECT Weekday_OT_Trans
					FROM #Weekday_OT AS A
					WHERE A.Weekday_OT_Trans = T0140_LEAVE_TRANSACTION.Leave_Tran_ID
					)
				AND For_Date IN (
					SELECT Data
					FROM dbo.Split(@StrHoliday_Date, ';')
					WHERE Data <> ''
					)
		END
	END

	IF @StrWeekoff_Date <> ''
		AND @Is_W_CompOff = 1
	BEGIN
		INSERT INTO #WeekOff_OT (
			WeekOff_OT_Trans
			,cmp_ID
			,Emp_ID
			,For_Date
			,CompOff_Credit
			,CompOff_Debit
			,CompOff_Balance
			,Branch_ID
			,Is_CompOFF
			,CompOFF_Days_Limit
			,CompOff_Type
			)
		SELECT Leave_Tran_ID
			,@Cmp_ID
			,@Emp_ID
			,For_Date
			,Compoff_Credit
			,CompOFf_Debit
			,CompOFF_Balance
			,@branch_id
			,Comoff_Flag
			,@Weekoff_CompOff_Limit
			,'WO'
		FROM dbo.T0140_LEAVE_TRANSACTION WITH (NOLOCK)
		WHERE Leave_ID = @leave_ID
			AND DATEADD(day, @WeekOffCompOffAvail_After_Days, For_Date) + 1 BETWEEN for_date
				AND @For_Date
			AND DATEADD(day, @Weekoff_CompOff_Limit + @WeekOffCompOffAvail_After_Days, For_Date) >= @For_Date 
			AND Cmp_ID = @Cmp_ID
			AND Emp_ID = @Emp_ID
			AND NOT EXISTS (
				SELECT Holiday_OT_Trans
				FROM #Holiday_OT AS A
				WHERE A.Holiday_OT_Trans = T0140_LEAVE_TRANSACTION.Leave_Tran_ID
				)
			AND NOT EXISTS (
				SELECT Weekday_OT_Trans
				FROM #Weekday_OT AS A
				WHERE A.Weekday_OT_Trans = T0140_LEAVE_TRANSACTION.Leave_Tran_ID
				)
			AND For_Date IN (
				SELECT Data
				FROM dbo.Split(@StrWeekoff_Date, ';')
				WHERE Data <> ''
				)
	END

	CREATE TABLE #Leave_Applied (
		Leave_Date DATETIME
		,Leave_Period NUMERIC(18, 2)
		)

	CREATE TABLE #Leave_Approved (
		Leave_Appr_Date DATETIME
		,Leave_Period NUMERIC(18, 2)
		)

	CREATE TABLE #Leave_Level_Approved (
		Leave_Appr_Date DATETIME
		,Leave_Period NUMERIC(18, 2)
		)

	DECLARE @strLeave_CompOff_dates VARCHAR(max)

	SET @strLeave_CompOff_dates = ''

	IF @Leave_Application_ID = 0
	BEGIN
		SELECT @strLeave_CompOff_dates = @strLeave_CompOff_dates + '#' + Leave_CompOff_Dates
		FROM dbo.V0110_LEAVE_APPLICATION_DETAIL VLAD
		LEFT JOIN (
			SELECT Leave_Application_ID
			FROM dbo.T0115_Leave_Level_Approval LLA WITH (NOLOCK)
			INNER JOIN (
				SELECT max(Tran_ID) AS Tran_ID
				FROM dbo.T0115_Leave_Level_Approval LLA WITH (NOLOCK)
				INNER JOIN dbo.T0100_LEAVE_APPLICATION LA WITH (NOLOCK) ON LLA.Leave_Application_ID = LA.Leave_Application_ID
					AND LLA.Emp_ID = La.Emp_ID
					AND Application_Status = 'P'
				WHERE LLA.Emp_ID = @Emp_ID
					AND Approval_Status = 'A'
					AND Leave_ID = @Leave_ID
					AND LLA.cmp_ID = @cmp_ID
				GROUP BY LLA.Leave_Application_ID
				) sub_Qry ON Sub_Qry.Tran_ID = LLA.Tran_ID
			) Qry ON Qry.Leave_Application_ID = VLAD.LEave_Application_ID
		WHERE Cmp_ID = @Cmp_ID
			AND Emp_ID = @Emp_ID
			AND Application_Status = 'P'
			AND Leave_ID = @leave_ID
			AND isnull(Leave_CompOff_Dates, '') <> ''
			AND isnull(Qry.Leave_Application_ID, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strLeave_CompOff_dates = @strLeave_CompOff_dates + '#' + Leave_CompOff_Dates
		FROM dbo.V0110_LEAVE_APPLICATION_DETAIL VLAD
		LEFT OUTER JOIN (
			SELECT Leave_Application_ID
			FROM dbo.T0115_Leave_Level_Approval LLA WITH (NOLOCK)
			INNER JOIN (
				SELECT max(Tran_ID) AS Tran_ID
				FROM dbo.T0115_Leave_Level_Approval LLA WITH (NOLOCK)
				INNER JOIN dbo.T0100_LEAVE_APPLICATION LA WITH (NOLOCK) ON LLA.Leave_Application_ID = LA.Leave_Application_ID
					AND LLA.Emp_ID = La.Emp_ID
					AND Application_Status = 'P'
				WHERE LLA.Emp_ID = @Emp_ID
					AND Approval_Status = 'A'
					AND Leave_ID = @Leave_ID
					AND LLA.cmp_ID = @cmp_ID
				GROUP BY LLA.Leave_Application_ID
				) sub_Qry ON Sub_Qry.Tran_ID = LLA.Tran_ID
			) Qry ON Qry.Leave_Application_ID <> VLAD.LEave_Application_ID
		WHERE Cmp_ID = @Cmp_ID
			AND Emp_ID = @Emp_ID
			AND Application_Status = 'P'
			AND Leave_ID = @leave_ID
			AND isnull(Leave_CompOff_Dates, '') <> ''
			AND VLAD.Leave_Application_ID <> @Leave_Application_ID
	END

	IF @Leave_Encash_App_ID = 0
	BEGIN
		SELECT @strLeave_CompOff_dates = @strLeave_CompOff_dates + '#' + Leave_CompOff_Dates
		FROM dbo.T0100_Leave_Encash_Application WITH (NOLOCK)
		WHERE Cmp_ID = @Cmp_ID
			AND Emp_ID = @Emp_ID
			AND Lv_Encash_App_Status = 'P'
			AND Leave_ID = @leave_ID
			AND isnull(Leave_CompOff_Dates, '') <> ''
	END
	ELSE
	BEGIN
		SELECT @strLeave_CompOff_dates = @strLeave_CompOff_dates + '#' + Leave_CompOff_Dates
		FROM dbo.T0100_Leave_Encash_Application WITH (NOLOCK)
		WHERE Cmp_ID = @Cmp_ID
			AND Emp_ID = @Emp_ID
			AND Lv_Encash_App_Status = 'P'
			AND Leave_ID = @leave_ID
			AND Lv_Encash_App_ID <> @Leave_Encash_App_ID
			AND isnull(Leave_CompOff_Dates, '') <> ''
	END

	INSERT INTO #Leave_Applied (
		Leave_date
		,Leave_Period
		)
	--SELECT Left(DATA, CHARINDEX(';', DATA) - 1)
	--	,SUBSTRING(DATA, CHARINDEX(';', DATA) + 1, 10)
	--FROM dbo.SPlit(@strLeave_CompOff_dates, '#')
	--WHERE Data <> ''
	--ronakb Support #32829
		SELECT CONVERT(DATE, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(splitDate, 'Jan', 'January'), 'Feb', 'February'), 'Mar', 'March'), 'Apr', 'April'), 'May', 'May'), 'Jun', 'June'), 'Jul', 'July'), 'Aug', 'August'), 'Sept', 'September'), 'Oct', 'October'), 'Nov', 'November'), 'Dec', 'December'), 113)
		, splitType
		from (
			select  Left(DATA,CHARINDEX(';',DATA)-1)  as splitDate ,SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10)  as splitType
			from dbo.SPlit(@strLeave_CompOff_dates,'#') where Data <> ''
		) a
	  -----ronakb   
	DECLARE @Leave_Approve_ID AS NUMERIC(18, 0)
	DECLARE @Leave_Encash_Approve_ID AS NUMERIC(18, 0)

	SET @Leave_Approve_ID = 0
	SET @Leave_Encash_Approve_ID = 0
	SET @strLeave_CompOff_dates = ''

	IF @Leave_Application_ID > 0
	BEGIN
		SELECT @strLeave_CompOff_dates = @strLeave_CompOff_dates + '#' + isnull(Leave_CompOff_Dates, '')
		FROM dbo.V0130_Leave_Approval_Details
		WHERE Leave_Application_ID = @Leave_Application_ID
			AND Approval_Status = 'A'
			AND Cmp_ID = @Cmp_ID
	END

	IF @Leave_Encash_App_ID > 0
	BEGIN
		SELECT @strLeave_CompOff_dates = @strLeave_CompOff_dates + '#' + isnull(Leave_CompOff_Dates, '')
		FROM dbo.V0120_LEAVE_Encash_Approval
		WHERE Lv_Encash_App_ID = @Leave_Encash_App_ID
			AND Lv_Encash_App_Status = 'A'
			AND Cmp_ID = @Cmp_ID
	END

	INSERT INTO #Leave_Approved (
		Leave_Appr_Date
		,Leave_Period
		)
	SELECT Left(DATA, CHARINDEX(';', DATA) - 1)
		,SUBSTRING(DATA, CHARINDEX(';', DATA) + 1, 10)
	FROM dbo.SPlit(@strLeave_CompOff_dates, '#')
	WHERE Data <> ''

	SET @strLeave_CompOff_dates = ''

	IF @Leave_Application_ID > 0
	BEGIN
		SELECT @strLeave_CompOff_dates = @strLeave_CompOff_dates + '#' + isnull(Leave_CompOff_dates, '')
		FROM dbo.T0115_Leave_Level_Approval LLA WITH (NOLOCK)
		INNER JOIN (
			SELECT max(Tran_ID) AS Tran_ID
			FROM dbo.T0115_Leave_Level_Approval LLA WITH (NOLOCK)
			INNER JOIN dbo.T0100_LEAVE_APPLICATION LA WITH (NOLOCK) ON LLA.Leave_Application_ID = LA.Leave_Application_ID
				AND LLA.Emp_ID = LA.Emp_ID
				AND LA.Application_Status = 'P'
			WHERE LA.Emp_ID = @Emp_ID
				AND Approval_Status = 'A'
				AND Leave_ID = @Leave_ID
				AND LA.cmp_ID = @Cmp_ID
			GROUP BY LLA.Leave_Application_ID
			) Qry ON Qry.Tran_ID = LLA.Tran_ID
		WHERE Leave_Application_ID <> @Leave_Application_ID
	END
	ELSE
	BEGIN
		SELECT @strLeave_CompOff_dates = @strLeave_CompOff_dates + '#' + isnull(Leave_CompOff_dates, '')
		FROM dbo.T0115_Leave_Level_Approval LLA WITH (NOLOCK)
		INNER JOIN (
			SELECT max(Tran_ID) AS Tran_ID
			FROM dbo.T0115_Leave_Level_Approval LLA WITH (NOLOCK)
			INNER JOIN dbo.T0100_LEAVE_APPLICATION LA WITH (NOLOCK) ON LA.Leave_Application_ID = LLA.Leave_Application_ID
				AND LA.Emp_ID = LLA.Emp_ID
				AND Application_Status = 'P'
			WHERE LLA.Emp_ID = @Emp_ID
				AND Approval_Status = 'A'
				AND Leave_ID = @Leave_ID
				AND LLA.Cmp_ID = @Cmp_ID
			GROUP BY LLA.Leave_Application_ID
			) Qry ON Qry.Tran_ID = LLA.Tran_ID
	END

	INSERT INTO #Leave_Level_Approved (
		Leave_Appr_Date
		,Leave_Period
		)
	SELECT Left(DATA, CHARINDEX(';', DATA) - 1)
		,SUBSTRING(DATA, CHARINDEX(';', DATA) + 1, 10)
	FROM dbo.SPlit(@strLeave_CompOff_dates, '#')
	WHERE Data <> ''

	UPDATE #Weekday_OT
	SET CompOff_Type = 'WO'
	WHERE For_Date IN (
			SELECT Data
			FROM dbo.Split(@StrWeekoff_Date, ';')
			WHERE Data <> ''
			)

	UPDATE #Weekday_OT
	SET CompOff_Type = 'HO'
	WHERE For_Date IN (
			SELECT Data
			FROM dbo.Split(@StrHoliday_Date, ';')
			WHERE Data <> ''
			)

	INSERT INTO #General_OT
	SELECT *
	FROM #Weekday_OT
	UNION ALL
	SELECT *
	FROM #WeekOff_OT
	UNION ALL
	SELECT *
	FROM #Holiday_OT

	UPDATE #General_OT
	SET CompOff_Debit = Compoff_Debit + Qry.Leave_Period
		,CompOff_balance = CompOff_balance - Qry.Leave_Period
	FROM #General_OT GOT
	INNER JOIN (
		SELECT isnull(SUM(leave_Period), 0) AS Leave_Period
			,Leave_Date
		FROM #Leave_Applied LA
		GROUP BY Leave_Date
		) Qry ON Qry.Leave_Date = For_Date

	UPDATE #General_OT
	SET CompOff_Debit = Compoff_Debit + Qry.Leave_Period
		,CompOff_balance = CompOff_balance - Qry.Leave_Period
	FROM #General_OT GOT
	INNER JOIN (
		SELECT isnull(SUM(leave_Period), 0) AS Leave_Period
			,Leave_Appr_Date
		FROM #Leave_Level_Approved LA
		GROUP BY Leave_Appr_Date
		) Qry ON Qry.Leave_Appr_Date = For_Date

	UPDATE #General_OT
	SET CompOff_Debit = Compoff_Debit - Qry.Leave_Period
		,CompOff_balance = CompOff_balance + Qry.Leave_Period
	FROM #General_OT GOT
	INNER JOIN (
		SELECT isnull(SUM(leave_Period), 0) AS Leave_Period
			,Leave_Appr_Date
		FROM #Leave_Approved LA
		GROUP BY Leave_Appr_Date
		) Qry ON Qry.Leave_Appr_Date = For_Date

	DELETE
	FROM #General_OT
	WHERE CompOff_balance < 0

	DECLARE @Total_Balance AS NUMERIC(18, 2)

	SET @Total_Balance = 0

	DECLARE @Leave_Code AS VARCHAR(max)
	DECLARE @Leave_Name AS VARCHAR(max)
	DECLARE @Leave_Display AS TINYINT
	DECLARE @CompOff_Balance AS NUMERIC(18, 2)
	DECLARE @Cur_CompOff_balance NUMERIC(18, 2)
	DECLARE @Cur_For_Date DATETIME
	DECLARE @CompOff_String NVARCHAR(max)
	DECLARE @Cur_Total_Balance NUMERIC(18, 2)

	IF @Exec_For = 0
	BEGIN
		SELECT @Total_Balance = isnull(SUM(CompOff_balance), 0)
		FROM #General_OT
		WHERE CompOff_balance > 0
		GROUP BY Emp_ID

		SELECT *
			,@Total_Balance AS Total_Balance
		FROM #General_OT
		WHERE CompOff_balance > 0
		ORDER BY For_Date
	END
	ELSE IF @Exec_For = 1 -- Only Show Data IF Leave_Display 1 of leave
	BEGIN
		SET @CompOff_Balance = 0
		SET @Leave_Display = 0

		SELECT @Leave_Code = Leave_Code
			,@Leave_Name = Leave_Name
			,@Leave_Display = isnull(Display_leave_balance, 0)
		FROM dbo.T0040_Leave_Master WITH (NOLOCK)
		WHERE Leave_ID = @Leave_ID

		IF @Leave_Display = 1
		BEGIN
			SELECT @CompOff_Balance = isnull(sum(CompOff_Balance), 0)
			FROM #General_OT
			IF @CompOff_Balance > 0
			BEGIN
				INSERT INTO #temp_CompOff
				SELECT isnull(sum(CompOff_credit), 0)
					,isnull(Sum(CompOFf_Debit), 0)
					,isnull(sum(CompOff_Balance), 0)
					,@Leave_Code
					,@Leave_Name
					,@Leave_ID
					,''
				FROM #General_OT
			END
		END
	END
	ELSE IF @Exec_For = 2 OR @Exec_For = 55 -- Show All Data
	BEGIN
		SELECT @Total_Balance = isnull(SUM(CompOff_balance), 0)
		FROM #General_OT
		WHERE CompOff_balance > 0
		GROUP BY Emp_ID

		SET @Leave_Display = 0

		SELECT @Leave_Code = Leave_Code
			,@Leave_Name = Leave_Name
		FROM dbo.T0040_Leave_Master WITH (NOLOCK)
		WHERE Leave_ID = @Leave_ID
			AND cmp_ID = @cmp_ID

		IF @Total_Balance > 0
		BEGIN
			SET @CompOff_String = ''
			DECLARE Cur_CompOff CURSOR
			FOR
			SELECT For_Date
				,CompOff_balance
				,@Total_Balance
			FROM #General_OT
			OPEN Cur_CompOff

			FETCH NEXT
			FROM Cur_CompOff
			INTO @Cur_For_Date
				,@Cur_CompOff_balance
				,@Cur_Total_Balance

			WHILE @@Fetch_Status = 0
			BEGIN
				IF @CompOff_String = ''
					SET @CompOff_String = replace(CONVERT(VARCHAR(11), @Cur_For_Date, 106), ' ', '-') + ';' + cast(@Cur_CompOff_balance AS VARCHAR(15))
				ELSE
					SET @CompOff_String = @CompOff_String + '#' + replace(CONVERT(VARCHAR(11), @Cur_For_Date, 106), ' ', '-') + ';' + cast(@Cur_CompOff_balance AS VARCHAR(15))

				FETCH NEXT
				FROM Cur_CompOff
				INTO @Cur_For_Date
					,@Cur_CompOff_balance
					,@Cur_Total_Balance
			END

			CLOSE Cur_CompOff
			DEALLOCATE Cur_CompOff
			INSERT INTO #temp_CompOff
			SELECT isnull(sum(CompOff_credit), 0) AS CompOff_credit
				,isnull(Sum(CompOFf_Debit), 0) AS CompOFf_Debit
				,isnull(sum(CompOff_Balance), 0) AS CompOff_Balance
				,@Leave_Code AS Leave_Code
				,@Leave_Name AS Leave_Name
				,@Leave_ID AS Leave_ID
				,@CompOff_String AS CompOff_String
			FROM #General_OT
		END
	END
	ELSE IF @Exec_For = 3 -- CompOff Leave Approval Using Import
	BEGIN
		SELECT @Total_Balance = isnull(SUM(CompOff_balance), 0)
		FROM #General_OT
		WHERE CompOff_balance > 0
		GROUP BY Emp_ID

		SET @Leave_Display = 0

		SELECT @Leave_Code = Leave_Code
			,@Leave_Name = Leave_Name
		FROM dbo.T0040_Leave_Master WITH (NOLOCK)
		WHERE Leave_ID = @Leave_ID
			AND Cmp_ID = @Cmp_ID

		IF @Total_Balance >= @Leave_Period
		BEGIN
			DECLARE @Temp_Leave_Period NUMERIC(18, 2)

			SET @Temp_Leave_Period = @Leave_Period
			SET @CompOff_String = ''

			DECLARE Cur_CompOff CURSOR
			FOR
			SELECT For_Date
				,CompOff_balance
				,@Total_Balance
			FROM #General_OT

			OPEN Cur_CompOff

			FETCH NEXT
			FROM Cur_CompOff
			INTO @Cur_For_Date
				,@Cur_CompOff_balance
				,@Cur_Total_Balance

			WHILE @@Fetch_Status = 0
			BEGIN
				IF @Temp_Leave_Period > 0
				BEGIN
					IF @Cur_CompOff_balance < = @Temp_Leave_Period
					BEGIN
						SET @Temp_Leave_Period = @Temp_Leave_Period - @Cur_CompOff_balance

						IF @CompOff_String = ''
							SET @CompOff_String = replace(CONVERT(VARCHAR(11), @Cur_For_Date, 106), ' ', '-') + ';' + cast(@Cur_CompOff_balance AS VARCHAR(15))
						ELSE
							SET @CompOff_String = @CompOff_String + '#' + replace(CONVERT(VARCHAR(11), @Cur_For_Date, 106), ' ', '-') + ';' + cast(@Cur_CompOff_balance AS VARCHAR(15))
					END
					ELSE
					BEGIN
						IF @CompOff_String = ''
							SET @CompOff_String = replace(CONVERT(VARCHAR(11), @Cur_For_Date, 106), ' ', '-') + ';' + cast(@Temp_Leave_Period AS VARCHAR(15))
						ELSE
							SET @CompOff_String = @CompOff_String + '#' + replace(CONVERT(VARCHAR(11), @Cur_For_Date, 106), ' ', '-') + ';' + cast(@Temp_Leave_Period AS VARCHAR(15))

						SET @Temp_Leave_Period = 0
					END
				END

				FETCH NEXT
				FROM Cur_CompOff
				INTO @Cur_For_Date
					,@Cur_CompOff_balance
					,@Cur_Total_Balance
			END

			CLOSE Cur_CompOff

			DEALLOCATE Cur_CompOff

			INSERT INTO #temp_CompOff
			SELECT 0 AS CompOff_credit
				,0 AS CompOFf_Debit
				,0 AS CompOff_Balance
				,@Leave_Code AS Leave_Code
				,@Leave_Name AS Leave_Name
				,@Leave_ID AS Leave_ID
				,@CompOff_String AS CompOff_String
			FROM #General_OT
		END
	END
END
