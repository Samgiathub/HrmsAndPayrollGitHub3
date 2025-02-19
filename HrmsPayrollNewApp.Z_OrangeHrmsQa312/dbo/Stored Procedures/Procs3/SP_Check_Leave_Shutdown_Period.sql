-- =============================================
-- Author:		<Jaina>
-- Create date: <12-05-2017>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Check_Leave_Shutdown_Period]
	@Cmp_Id numeric(18,0),
	@Emp_Id numeric(18,0),
	@Leave_Id numeric(18,0),
	@From_date datetime,
	@To_date datetime
AS
BEGIN
	
	SET NOCOUNT ON;
	Declare @Notice_Period numeric(18,2)
	DECLARE @SHUT_DOWN_FROM DATETIME
	DECLARE @SHUT_DOWN_TO DATETIME
	DECLARE @NOTICE_DATE DATETIME
	DECLARE @Month_Start_date DATETIME
	DECLARE @Month_End_date DATETIME
	declare @CONSTRAINT  varchar(100)
	DECLARE @FIX_DAYS BIGINT
	Declare @Pre_S_Date datetime
	Declare @Pre_E_Date datetime
	Declare @Post_S_Date datetime
	Declare @Post_E_Date datetime
	declare @WITHIN_SHUTDOWN_PERIOD bit
	
	SET @FIX_DAYS = 1
	
	set @CONSTRAINT = @Emp_Id
	
	SELECT @NOTICE_PERIOD = NOTICE_PERIOD,@SHUT_DOWN_FROM = FROM_DATE,@SHUT_DOWN_TO = TO_DATE 
	FROM T0045_LEAVE_SHUTDOWN_PERIOD WITH (NOLOCK)
	WHERE LEAVE_ID = @LEAVE_ID --and From_Date > @From_date and @To_date < To_Date
		 and @From_date between From_Date AND To_Date
		 and @To_date between From_Date and To_Date
	
	--select @SHUT_DOWN_FROM,@SHUT_DOWN_TO	
	IF @SHUT_DOWN_FROM BETWEEN @FROM_DATE AND @TO_DATE OR @SHUT_DOWN_TO BETWEEN @FROM_DATE AND @TO_DATE
		OR @FROM_DATE BETWEEN @SHUT_DOWN_FROM AND @SHUT_DOWN_TO OR @TO_DATE BETWEEN @SHUT_DOWN_FROM AND @SHUT_DOWN_TO
	BEgin
			SELECT 'Can''t take leave on this dates' As Status
			return
	END
	
	
	CREATE TABLE #EMP_HOLIDAY
	(
		EMP_ID NUMERIC,
	    FOR_DATE DATETIME,
	    IS_CANCEL BIT, 
	    Is_Half tinyint, 
	    Is_P_Comp tinyint, 
	    H_DAY numeric(4,1)
	 );

	CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);

	CREATE TABLE #Emp_WeekOff
	(
		Row_ID			NUMERIC,
		Emp_ID			NUMERIC,
		For_Date		DATETIME,
		Weekoff_day		VARCHAR(10),
		W_Day			numeric(4,1),
		Is_Cancel		BIT
	)
	CREATE CLUSTERED INDEX IX_Emp_WeekOff_EMPID_FORDATE ON #Emp_WeekOff(Emp_ID,For_Date);

	set @Month_Start_date = dbo.GET_MONTH_ST_DATE(MONTH(@From_date),year(@From_date))
	set @Month_End_date = dbo.GET_MONTH_END_DATE(MONTH(@From_date),year(@From_date))
	
	--select @Month_Start_date
	EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@Month_Start_date, @TO_DATE=@Month_End_date, @All_Weekoff = 0, @Exec_Mode=0	
	
	CREATE TABLE #DATES
	(
		ID INT ,
		FOR_DATE DATETIME
	)

	INSERT INTO #DATES
	SELECT	ROW_ID, DATEADD(D, ROW_ID-1, @Month_Start_date) 
	FROM	(SELECT TOP 40 ROW_NUMBER() OVER (ORDER BY OBJECT_ID) ROW_ID FROM SYS.OBJECTS ) T 
	WHERE DATEADD(D, ROW_ID-1, @Month_Start_date)  <= @Month_End_date

	--SELECT D.* FROM #DATES D
	--WHERE EXISTS (SELECT  1 FROM #EMP_HOLIDAY H WHERE H.FOR_DATE=D.FOR_DATE)
	--		OR EXISTS (SELECT  1 FROM #Emp_WeekOff W WHERE W.FOR_DATE=D.FOR_DATE)
	
	DELETE D FROM #DATES D
	WHERE EXISTS (SELECT  1 FROM #EMP_HOLIDAY H WHERE H.FOR_DATE=D.FOR_DATE)
		OR EXISTS (SELECT  1 FROM #Emp_WeekOff W WHERE W.FOR_DATE=D.FOR_DATE)
	
	--select * from #DATES
	
	SET ROWCOUNT @FIX_DAYS

	SELECT FOR_DATE INTO #NEW_DATES FROM #DATES WHERE FOR_DATE < @SHUT_DOWN_FROM ORDER BY FOR_DATE DESC

	SELECT @Pre_S_Date = MIN(FOR_DATE) ,@Pre_E_Date = MAX(FOR_DATE)  
	FROM #NEW_DATES
	
	IF @FROM_DATE BETWEEN  @PRE_S_DATE AND @PRE_E_DATE OR @TO_DATE BETWEEN @PRE_S_DATE AND @PRE_E_DATE
		OR @PRE_S_DATE BETWEEN @FROM_DATE AND @TO_DATE OR @PRE_E_DATE BETWEEN @FROM_DATE AND @TO_DATE
			SET @WITHIN_SHUTDOWN_PERIOD = 1
	
	TRUNCATE TABLE #NEW_DATES

	INSERT INTO #NEW_DATES
	SELECT FOR_DATE  FROM #DATES WHERE FOR_DATE > @SHUT_DOWN_TO

	SELECT @Post_S_Date =  MIN(FOR_DATE) ,@Post_E_Date = MAX(FOR_DATE)  
	FROM #NEW_DATES

	IF @FROM_DATE BETWEEN  @Post_S_Date AND @Post_E_Date OR @TO_DATE BETWEEN @Post_S_Date AND @Post_E_Date
		OR @Post_S_Date BETWEEN @FROM_DATE AND @TO_DATE OR @Post_E_Date BETWEEN @FROM_DATE AND @TO_DATE
	SET @WITHIN_SHUTDOWN_PERIOD = 1
	
	
	SET ROWCOUNT 0
	
	--SET @NOTICE_DATE = DATEADD(D,-@NOTICE_PERIOD,@F_DATE)
	--select @PRE_S_DATE
	--select DATEDIFF(dd, getdate(), @PRE_S_DATE),@NOTICE_PERIOD
	IF @WITHIN_SHUTDOWN_PERIOD = 1 AND 
		( DATEDIFF(dd, getdate(), @PRE_S_DATE) < @NOTICE_PERIOD
		  or DATEDIFF(dd, getdate(), @Post_S_Date) < @NOTICE_PERIOD)
	--OR @FROM_DATE BETWEN
	BEGIN
		SELECT 'Can''t take leave on this dates' As Status
		RETURN
	END
    
END

