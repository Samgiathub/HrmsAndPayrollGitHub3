
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Check_Leave_Clubbing]
    @Emp_Id NUMERIC ,
    @Cmp_Id NUMERIC ,
    @From_DateFE DATETIME ,
    @To_DateFE DATETIME ,
    @From_DateLE DATETIME ,
    @To_DateLE DATETIME ,
    @Tag VARCHAR(5) ,
    @Leave_Id NUMERIC = 0,
    @Leave_App_Id as numeric = 0,		-- Added By Ali 050302014
    @Leave_Period as numeric(18,2) = 0,	-- Added By Ali 050302014
    @Leave_Day as varchar(50) = '',		-- Added By Ali 050302014
    @Leave_Half_Date Datetime =  null 	-- Added By Ali 050302014
   
AS 
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		--IF EXISTS(SELECT 1 FROM T0040_LEAVE_MASTER WHERE Leave_ID = @Leave_Id and Working_Days > 0)
		--BEGIN
		--	SET @From_DateFE = DATEADD(day,-(SELECT Working_Days FROM T0040_LEAVE_MASTER WHERE Leave_ID = @Leave_Id) + 1,@From_DateFE)
		--END
		--ELSE IF EXISTS(SELECT 1 FROM T0040_LEAVE_MASTER WHERE Leave_ID = @Leave_Id and Consecutive_Days > 0)
		--BEGIN
		--	SET @From_DateFE = DATEADD(day,-(SELECT Consecutive_Days FROM T0040_LEAVE_MASTER WHERE Leave_ID = @Leave_Id) + 1,@From_DateFE)
		--END
		
		CREATE TABLE #LEAVE_CLUB
		(					
			LEAVE_ID			NUMERIC,
			FOR_DATE			DATETIME,
			APP_ID				NUMERIC,
			APR_ID				NUMERIC,
			AssignAs			Varchar(20)
		)
		 
        IF EXISTS(SELECT 1 FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE Is_Leave_Clubbed=1 AND LEAVE_ID=@LEAVE_ID)
            BEGIN 				
				/*******************************************************
				Added by Jaina on 20-11-2015 
				(To skip previsou next holiday/weekoff)
				
				If employee has taken leave for 14/Nov/2015 then takes
				another leave on 16/Nov/2015 then it should check 
				leave clubbing.because there is a weekoff on 15/Nov/2015.
				*******************************************************/
				--Added By Jaina 20-11-2015 Start
				DECLARE @From_Date DateTime --= DateAdd(d,-9,@From_DateFE)
				DECLARE @To_Date DateTime --= DateAdd(d,11,@From_DateFE)	
				DECLARE @FROM_DIFF AS INT;
				DECLARE @TO_DIFF AS INT;
				
				SET @From_Date = DateAdd(d,-9,@From_DateFE)  --added jimit 18042016
				SET	@To_Date = DateAdd(d,11,@From_DateFE)	--added jimit 18042016

				DECLARE @Required_Execution BIT;
				SET @Required_Execution = 0;
				
				IF OBJECT_ID('tempdb..#EMP_HW_CONS') IS NULL
					BEGIN					
						SET @Required_Execution = 1;
						CREATE table #EMP_HW_CONS
						(
							Emp_ID				NUMERIC,
							WeekOffDate			Varchar(Max),
							WeekOffCount		NUMERIC(3,1),
							CancelWeekOff		Varchar(Max),
							CancelWeekOffCount	NUMERIC(3,1),
							HolidayDate			Varchar(MAX),
							HolidayCount		NUMERIC(3,1),
							HalfHolidayDate		Varchar(MAX),
							HalfHolidayCount	NUMERIC(3,1),
							CancelHoliday		Varchar(Max),
							CancelHolidayCount	NUMERIC(3,1)
						)
						CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON #EMP_HW_CONS(Emp_ID)
					END

				IF OBJECT_ID('tempdb..#Emp_WeekOff_Holiday') IS NULL
					BEGIN	
						CREATE table #Emp_WeekOff_Holiday
						(
							Emp_ID				NUMERIC,
							WeekOffDate			VARCHAR(Max),
							WeekOffCount		NUMERIC(3,1),
							HolidayDate			VARCHAR(Max),
							HolidayCount		NUMERIC(3,1),
							HalfHolidayDate		VARCHAR(Max),
							HalfHolidayCount	NUMERIC(3,1),
							OptHolidayDate		VARCHAR(Max),
							OptHolidayCount		NUMERIC(3,1)
						)
						CREATE UNIQUE CLUSTERED INDEX IX_Emp_WeekOff_Holiday_EMPID ON #Emp_WeekOff_Holiday(Emp_ID);
						SET @Required_Execution = 1;
					END
				
				/*FOLLOWING CODE ADDED BY NIMESH ON 18-SEP-2017 (WE ARE TRYING TO REMOVE THE OLD METHOD SP_EMP_WEEKOFF_DATE_GET AND SP_EMP_HOLIDAY_DATE_GET*/
				IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
				BEGIN	
					CREATE TABLE #EMP_HOLIDAY
					(
						EMP_ID NUMERIC, 
						FOR_DATE DATETIME, 
						IS_CANCEL BIT, 
						Is_Half tinyint, 
						Is_P_Comp tinyint, 
						H_DAY numeric(4,1)
					)
					CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE)
					SET @Required_Execution = 1;
				END
		
				IF OBJECT_ID('tempdb..#EMP_WEEKOFF') IS NULL
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
					SET @Required_Execution = 1;
				END
				
				IF @Required_Execution = 1
					EXEC SP_GET_HW_ALL @Cmp_ID=@Cmp_ID,@Constraint=@Emp_ID, @From_Date=@From_Date, @To_Date=@To_Date, @All_Weekoff=0, @Is_FNF=0, @Exec_Mode=0
								
				DECLARE @HW_DATES VARCHAR(MAX);
				SELECT @HW_DATES = IsNUll(WeekOffDate,'') + IsNull(HolidayDate,'') + IsNull(HalfHolidayDate,'') from #Emp_WeekOff_Holiday

				--SELECT * FROM dbo.Split(@HW_DATES, ';')  where Data <> ''
				--Added by Jaina 01-01-2017
				SELECT	@HW_DATES = REPLACE(@HW_DATES, CAST(FOR_DATE AS VARCHAR(11)), '')
				FROM	T0140_LEAVE_TRANSACTION T WITH (NOLOCK)
				WHERE	For_Date BETWEEN @From_Date AND @To_Date AND Emp_ID=@Emp_Id
				
				DECLARE @TEMP_DATE DATETIME;
				SET @TEMP_DATE  = @From_DateFE;

				WHILE (CHARINDEX(Cast(@TEMP_DATE As Varchar(11)), @HW_DATES) > 0)
						SET @TEMP_DATE = DATEADD(d, -1, @TEMP_DATE);
						
				SET @FROM_DIFF = DATEDIFF(d,@TEMP_DATE,@From_DateFE ) + 1   --It is use in case of First/Second Half Leave
				
				SET @From_DateFE = @TEMP_DATE
				
				
				--SET @TEMP_TO_DATE  = @To_DateFE;  --Commented by Hardik 01/09/2016 as this condition not working in Aculife case, like on 13-08-2016 there is CL and now employee taking leave on 11-08-2016 to 12-08-2016 for SL then it should not club.
				SET @TEMP_DATE  = @To_DateLE;   --Added by Hardik 01/09/2016 as this condition not working in Aculife case, like on 13-08-2016 there is CL and now employee taking leave on 11-08-2016 to 12-08-2016 for SL then it should not club.
					
				WHILE (CHARINDEX(Cast(@TEMP_DATE As Varchar(11)), @HW_DATES) > 0)
						SET @TEMP_DATE = DATEADD(d, +1, @TEMP_DATE);
						
				SET @TO_DIFF = DATEDIFF(d,@To_DateLE,@TEMP_DATE) -1  --It is use in case of First/Second Half Leave
				SET @To_DateLE = @TEMP_DATE
				
				
				
				/**************************************************************/
				--Added By Jaina 20-11-2015 End
				
				CREATE TABLE #Leave_Cons ( Leave_ID NUMERIC )
			
				DECLARE @Leave_Club_With VARCHAR(5000)
				
				SELECT  @Leave_Club_With = ISNULL(LEAVE_CLUB_WITH, '')
				FROM    T0040_LEAVE_MASTER WITH (NOLOCK)
				WHERE   Cmp_ID = @Cmp_Id
						AND Leave_Id = @Leave_Id
		                
				
				
				INSERT  INTO #Leave_Cons
				SELECT	LEAVE_ID FROM T0040_LEAVE_MASTER LM  WITH (NOLOCK)
				WHERE	NOT EXISTS(SELECT 1 FROM    dbo.Split(@Leave_Club_With, '#') T 
								WHERE DATA <> '' AND CAST(DATA AS NUMERIC) = LM.LEAVE_ID)
						AND LM.LEAVE_ID<>@LEAVE_ID
						AND LM.CMP_ID=@CMP_ID
				
				
				CREATE TABLE #EMP_LEAVES
				(					
					LEAVE_ID			NUMERIC,
					FOR_DATE			DATETIME,
					APP_ID				NUMERIC,
					APR_ID				NUMERIC,
					AssignAs			Varchar(20)
				)
				
				--select TOP 0 * INTO #LEAVE_CLUB FROM #EMP_LEAVES
				--select * from #Leave_Cons 
				--select @TEMP_DATE,@From_DateFE
				SET @TEMP_DATE = @From_DateFE
				WHILE @TEMP_DATE <= @To_DateLE
					BEGIN 
						
						--Getting All First Half AND Second Half Pending Leave Application Between Dates
						INSERT	INTO #EMP_LEAVES(LEAVE_ID,FOR_DATE,APP_ID,APR_ID,AssignAs)
						SELECT	LAD.Leave_ID,@TEMP_DATE,LA.Leave_Application_ID,0,LAD.LEAVE_ASSIGN_AS
						FROM	T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
								INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.LEAVE_APPLICATION_ID=LAD.LEAVE_APPLICATION_ID								
								INNER JOIN #Leave_Cons L ON LAD.LEAVE_ID=L.LEAVE_ID
						WHERE	LA.APPLICATION_STATUS = 'P' AND Half_Leave_Date=@TEMP_DATE								
								AND LAD.LEAVE_ASSIGN_AS IN ('First Half', 'Second Half')
								AND LA.EMP_ID=@EMP_ID
						
						
						--Getting All Full Day Pending Leave Application Between Dates
						INSERT	INTO #EMP_LEAVES(LEAVE_ID,FOR_DATE,APP_ID,APR_ID,AssignAs)
						SELECT	LAD.Leave_ID,@TEMP_DATE,LA.Leave_Application_ID,0,LAD.LEAVE_ASSIGN_AS
						FROM	T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
								INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.LEAVE_APPLICATION_ID=LAD.LEAVE_APPLICATION_ID								
								INNER JOIN #Leave_Cons L ON LAD.LEAVE_ID=L.LEAVE_ID
						WHERE	LA.APPLICATION_STATUS = 'P' AND (CASE WHEN  LAD.Leave_Period % 1 > 0 AND Half_Leave_Date=@TEMP_DATE THEN 0 ELSE 1 END) = 1
								AND (@TEMP_DATE BETWEEN LAD.From_Date AND LAD.To_Date)
								--AND LAD.LEAVE_ASSIGN_AS = 'Full Day'
								AND IsNull(LAD.Half_Leave_Date, '1900-01-01') <> @TEMP_DATE
								AND LA.EMP_ID=@EMP_ID
						
						
						--Getting All First Half AND Second Half Approved Leave Between Dates
						INSERT	INTO #EMP_LEAVES(LEAVE_ID,FOR_DATE,APP_ID,APR_ID,AssignAs)
						SELECT	LAD.Leave_ID,@TEMP_DATE,LA.Leave_Application_ID,LA.Leave_Approval_ID,LAD.LEAVE_ASSIGN_AS
						FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
								INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID
								INNER JOIN #Leave_Cons L ON LAD.LEAVE_ID=L.LEAVE_ID
						WHERE	Half_Leave_Date=@TEMP_DATE									
								AND LAD.LEAVE_ASSIGN_AS IN ('First Half', 'Second Half')
								AND LA.EMP_ID=@EMP_ID AND LA.Approval_Status = 'A'
								AND NOT EXISTS(	SELECT 1 FROM T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)
												WHERE	LC.FOR_DATE=@TEMP_DATE AND LA.Leave_Approval_ID=LC.Leave_Approval_ID
														AND LC.Day_Type IN ('First Half', 'Second Half') AND Is_Approve=1)		
							
						--Getting All Full Day Approved Leave Between Dates
						INSERT	INTO #EMP_LEAVES(LEAVE_ID,FOR_DATE,APP_ID,APR_ID,AssignAs)
						SELECT	LAD.Leave_ID,@TEMP_DATE,LA.Leave_Application_ID,LA.Leave_Approval_ID,IsNull(LC.Day_Type,'Full Day')
						FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
								INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID
								INNER JOIN #Leave_Cons L ON LAD.LEAVE_ID=L.LEAVE_ID
								LEFT OUTER JOIN (SELECT Leave_Approval_ID, CASE IsNull(LC.Day_Type,'') WHEN 'First Half' Then 'Second Half' When 'Second Half' Then 'First Half' Else IsNull(LC.Day_Type,'') END As Day_Type 
												 FROM T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)
												 WHERE	EMP_ID=@Emp_ID  AND Is_Approve=1) LC ON LA.Leave_Approval_ID=LC.Leave_Approval_ID
						WHERE	(CASE WHEN  LAD.Leave_Period % 1 > 0 AND Half_Leave_Date=@TEMP_DATE THEN 0 ELSE 1 END) = 1
								AND (@TEMP_DATE BETWEEN LAD.From_Date AND LAD.To_Date)
								--AND LAD.LEAVE_ASSIGN_AS = 'Full Day' AND IsNull(LC.Day_Type,'') <> 'Full Day'
								AND LAD.Half_Leave_Date <> @TEMP_DATE AND IsNull(LC.Day_Type,'') <> 'Full Day'
								AND LA.EMP_ID=@EMP_ID  AND LA.Approval_Status = 'A'
								
												
						SET @TEMP_DATE = DATEADD(d,1,@TEMP_DATE);
						--select * from #EMP_LEAVES
					END
				
				
				IF @Leave_Day = 'First Half'
					BEGIN 
						INSERT INTO #LEAVE_CLUB
						SELECT	* 						
						FROM	#EMP_LEAVES EL
						WHERE	(EL.FOR_DATE = @From_DateFE OR EL.FOR_DATE=@Leave_Half_Date)
								AND EL.AssignAs IN ('Full Day', 'Second Half')
					END
				ELSE IF @Leave_Day = 'Second Half'
					BEGIN 		
						INSERT INTO #LEAVE_CLUB				
						SELECT	* 
						FROM	#EMP_LEAVES EL
						WHERE	(EL.FOR_DATE = @To_DateLE OR EL.FOR_DATE=@Leave_Half_Date)
								AND EL.AssignAs IN ('Full Day', 'First Half')
					END
				ELSE IF @Leave_Day = 'Full Day'
					BEGIN 			
						INSERT INTO #LEAVE_CLUB
						SELECT	* 
						FROM	#EMP_LEAVES EL
						WHERE	(EL.FOR_DATE = @To_DateLE AND EL.AssignAs IN ('Full Day', 'First Half'))
								OR (EL.FOR_DATE = @From_DateFE AND EL.AssignAs IN ('Full Day', 'Second Half'))
					END
							
				
			END
			
			--Added by Jaina 19-04-2017
			IF EXISTS(SELECT 1 FROM #LEAVE_CLUB )
				SELECT * FROM #LEAVE_CLUB
			ELSE
				BEGIN
					DECLARE @MAX_CLUB_DAY NUMERIC
					SELECT @MAX_CLUB_DAY = SETTING_VALUE FROM T0040_SETTING WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND SETTING_NAME = 'Maximum days allowed for leave clubbing'
					if @Max_Club_Day > 0
					BEGIN
						--select @MAX_CLUB_DAY
						IF @LEAVE_DAY NOT IN ('First Half','Second Half')
							SET @LEAVE_HALF_DATE = '1900-01-01'
								
						EXEC P_Check_MaxLeave_Clubbing @Emp_Id=@Emp_Id,@Cmp_Id=@Cmp_Id,@From_Date=@From_DateFE,@To_Date=@To_DateLE,@Leave_Id=@Leave_Id,@Leave_Period=@Leave_Period,@Leave_Assign_As=@Leave_Day,@Leave_Half_Date=@Leave_Half_Date
					END
				END
			
			--Added by Jaina 25-05-2017
			Declare @F_date as datetime
			declare @E_date as datetime
							
			if exists (SELECT 1 FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE LEAVE_ID=@LEAVE_ID AND CMP_ID = @CMP_ID AND Working_Club_Days > 0 AND Consecutive_Club_Days > 0)
				BEGIN
				
					--SET @F_date = DateAdd(d, 1, @From_DateFE) 
					--set @E_date = DateAdd(d, -1, @To_DateLE)

					SET @F_date =  DateAdd(d, -1, @To_DateFE)
					set @E_date = DateAdd(d, 1, @From_DateLE)
					
					exec P_Check_WD_Between_Cons_Club @Emp_Id=@Emp_Id,@Cmp_Id=@Cmp_Id,@Leave_ID=@Leave_ID,@From_Date=@F_date,@To_Date=@E_date,@Leave_Period=@Leave_Period,@Leave_Application_ID=@Leave_App_Id,@Leave_Approval_ID=0,@Leave_Assign_As=@Leave_Day,@Half_Leave_Date=@Leave_Half_Date,@Is_Club=1
					
				END
			
			if exists (SELECT 1 FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE LEAVE_ID=@LEAVE_ID AND CMP_ID = @CMP_ID AND Working_Days > 0 AND Consecutive_Days > 0)
				BEGIN
				
					SET @F_date =  DateAdd(d, -1, @To_DateFE)
					set @E_date = DateAdd(d, 1, @From_DateLE)
				
					--select @F_date,@E_date,@Leave_App_Id
					exec P_Check_WD_Between_Cons_Club @Emp_Id=@Emp_Id,@Cmp_Id=@Cmp_Id,@Leave_ID=@Leave_ID,@From_Date=@F_date,@To_Date=@E_date,@Leave_Period=@Leave_Period,@Leave_Application_ID=@Leave_App_Id,@Leave_Approval_ID=0,@Leave_Assign_As=@Leave_Day,@Half_Leave_Date=@Leave_Half_Date,@Is_Club=0
				END
END