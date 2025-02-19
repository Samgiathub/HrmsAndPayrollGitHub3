


-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 06-May-2017
-- Description:	To get the all leave detail between given date period
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_GET_LEAVE_DETAIL] 
	@Cmp_ID		Numeric, 
	@Emp_ID		Numeric, 
	@From_Date	DateTime,
	@To_Date	DateTime,
	@WITH_HW	BIT = 0
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN	
	DECLARE @HasTable BIT
	SET @HasTable = 0
	
	
	
	IF OBJECT_ID('tempdb..#Employee_Leave') IS NOT NULL
		SET @HasTable = 1
	ELSE
		CREATE table #Employee_Leave
		(
			Emp_Id numeric(18,0),
			For_Date datetime,
			Leave_Id numeric(18,0),
			Leave_Period numeric(18,2),
			Leave_Type varchar(50),
			Application_Id numeric(18,0),
			Approval_Id numeric(18,0),
			Leave_Start_Time DateTime,
			Leave_End_Time DateTime
		)
	
	DECLARE @TEMP_DATE DATETIME
	DECLARE @TEMP_LEAVE_PERIOD NUMERIC(9,2)
	DECLARE @TEMP_LEAVE_TYPE VARCHAR(32)
	DECLARE @TEMP_FROM_TIME DATETIME
	DECLARE @TEMP_TO_TIME DATETIME
	DECLARE @TEMP_LEAVE_APP_ID NUMERIC
	
	DECLARE @TEMP_HALF_LEAVE_DATE DATETIME

	DECLARE @LEAVE_ID NUMERIC
	DECLARE @SHIFT_ID NUMERIC
	

	SET @TEMP_DATE = @From_Date
	WHILE @TEMP_DATE <= @To_Date
		BEGIN 
			
			--GETTING ALL APPROVED LEAVE DETAIL
			DECLARE curLeave Cursor Fast_Forward For 
			SELECT	LEAVE_ID, CASE WHEN CompOff_Used > 0 THEN CompOff_Used ELSE Leave_Used END
			FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
			WHERE	FOR_DATE = @TEMP_DATE AND Emp_ID=@Emp_ID AND (CompOff_Used > 0 OR Leave_Used > 0)

			OPEN curLeave
			Fetch Next From curLEave INTO @LEAVE_ID, @TEMP_LEAVE_PERIOD
			WHILE @@FETCH_STATUS = 0
				BEGIN				
					--select @TEMP_LEAVE_PERIOD	
					IF @TEMP_LEAVE_PERIOD = 1
						BEGIN							
							INSERT	INTO #Employee_Leave(Emp_ID,FOR_DATE,LEAVE_ID,Leave_Period,Application_Id,Approval_Id,Leave_Type)
							SELECT	@Emp_ID, @TEMP_DATE, @Leave_ID, @TEMP_LEAVE_PERIOD,LA.Leave_Application_ID,LA.Leave_Approval_ID,'Full Day'
							FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID
							WHERE	NOT EXISTS(SELECT 1 FROM T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) WHERE LC.Leave_Approval_id=LA.Leave_Approval_ID AND LC.For_date=@TEMP_DATE AND lc.Is_Approve=1)
									AND LA.Emp_ID=@Emp_ID AND LAD.Leave_ID=@LEAVE_ID AND @TEMP_DATE BETWEEN LAD.From_Date AND LAD.To_Date
									AND LA.Approval_Status = 'A'
						END
					ELSE 
						BEGIN
							

							INSERT	INTO #Employee_Leave(Emp_ID,FOR_DATE,LEAVE_ID,Leave_Period,Application_Id,Approval_Id,Leave_Type,Leave_Start_Time,Leave_End_Time)
							SELECT	@Emp_ID, @TEMP_DATE, @Leave_ID, @TEMP_LEAVE_PERIOD,LA.Leave_Application_ID,LA.Leave_Approval_ID,CASE WHEN @TEMP_LEAVE_PERIOD > 0.5 THEN 'Full Day' Else IsNull(LC.Day_Type, LAD.Leave_Assign_As) END, Lad.Leave_In_Time, lad.Leave_out_time
							FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK) INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID
									LEFT OUTER JOIN (SELECT LC.Leave_Approval_ID,(CASE LC.Day_type WHEN 'First Half' Then 'Second Half' WHEN 'Second Half' THEN 'First Half' Else LC.Day_Type End) As Day_Type
													FROM	T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)
													WHERE	LC.Emp_Id=@Emp_ID AND LC.For_date=@TEMP_DATE AND LC.Leave_id=@LEAVE_ID  AND lc.Is_Approve=1) LC ON La.Leave_Approval_ID=LC.Leave_Approval_id
							WHERE	LA.Emp_ID=@Emp_ID AND LAD.Leave_ID=@LEAVE_ID AND @TEMP_DATE BETWEEN LAD.From_Date AND LAD.To_Date
									AND LA.Approval_Status = 'A'
						END
					Fetch Next From curLEave INTO @LEAVE_ID, @TEMP_LEAVE_PERIOD
				END
			CLOSE curLeave 
			DEALLOCATE curLeave 
			
				
			DECLARE curLeaveApp CURSOR FAST_FORWARD For  
			SELECT	LEAVE_ID, LEAVE_PERIOD, Leave_Assign_As, Half_Leave_Date,LA.Leave_Application_ID FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK) INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID=LAD.Leave_Application_ID 
			WHERE	NOT EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA1 WITH (NOLOCK) WHERE LA.LEAVE_APPLICATION_ID=LA1.LEAVE_APPLICATION_ID)
					AND LA.EMP_ID=@EMP_ID AND @TEMP_DATE BETWEEN LAD.From_Date AND LAD.To_Date
					AND LA.Application_Status='P'
			OPEN curLeaveApp
			Fetch Next From curLeaveApp INTO @LEAVE_ID, @TEMP_LEAVE_PERIOD, @TEMP_LEAVE_TYPE, @TEMP_HALF_LEAVE_DATE,@TEMP_LEAVE_APP_ID
			WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @TEMP_HALF_LEAVE_DATE = ISNULL(@TEMP_HALF_LEAVE_DATE, '1900-01-01');

					IF @TEMP_LEAVE_PERIOD >= 1 AND @TEMP_HALF_LEAVE_DATE <> @TEMP_DATE
						BEGIN
							SET @TEMP_LEAVE_PERIOD = 1
							SET @TEMP_LEAVE_TYPE = 'Full Day'   --Added by Jaina 26-05-2017
						END
					ELSE IF  @TEMP_HALF_LEAVE_DATE = @TEMP_DATE AND @TEMP_LEAVE_PERIOD % 1 = 0.5
						SET @TEMP_LEAVE_PERIOD = 0.5
					ELSE IF @TEMP_LEAVE_TYPE = 'Part Day'
						SET @TEMP_LEAVE_PERIOD = @TEMP_LEAVE_PERIOD * 0.125

					INSERT	INTO #Employee_Leave(Emp_ID,FOR_DATE,LEAVE_ID,Leave_Period,Application_Id,Approval_Id,Leave_Type,Leave_Start_Time,Leave_End_Time)
					SELECT	@Emp_ID, @TEMP_DATE, @Leave_ID, @TEMP_LEAVE_PERIOD,@TEMP_LEAVE_APP_ID,0,@TEMP_LEAVE_TYPE,LAD.leave_In_time, LAD.leave_Out_time
					FROM	T0100_LEAVE_APPLICATION LA WITH (NOLOCK) INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID=LAD.Leave_Application_ID
					WHERE	LA.Emp_ID=@Emp_ID AND LA.Leave_Application_ID = @TEMP_LEAVE_APP_ID

					Fetch Next From curLeaveApp INTO @LEAVE_ID, @TEMP_LEAVE_PERIOD, @TEMP_LEAVE_TYPE, @TEMP_HALF_LEAVE_DATE,@TEMP_LEAVE_APP_ID
				END
			CLOSE curLeaveApp 
			DEALLOCATE curLeaveApp 
				
			IF EXISTS(SELECT 1 FROM #Employee_Leave WHERE Leave_Id=@LEAVE_ID AND For_Date = @TEMP_DATE AND Emp_Id=@Emp_ID AND Leave_Type = 'Part Day')
				BEGIN
					SET @SHIFT_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID, @Emp_ID, @TEMP_DATE)

					UPDATE	EL
					SET		Leave_Type = CASE WHEN ABS(DATEDIFF(hh, CONVERT(VARCHAR(5), getdate(), 108), '19:00')) > 1 THEN 'Second Half' ELSE 'First Half' END
					FROM	#Employee_Leave EL INNER JOIN T0040_SHIFT_MASTER SM ON SM.Shift_ID=@Shift_ID AND SM.Cmp_ID=@Cmp_ID 
				END

														
			SET @TEMP_DATE = DATEADD(d,1,@TEMP_DATE);
		END

	UPDATE	#Employee_Leave 
	SET		Leave_Start_Time = NULL
	WHERE	Leave_Start_Time = '1900-01-01'

	UPDATE	#Employee_Leave 
	SET		Leave_End_Time = NULL
	WHERE	Leave_End_Time = '1900-01-01'
	
	
	IF @WITH_HW = 1
		BEGIN
			DECLARE @CONSTRAINT VARCHAR(MAX)	
			SET @CONSTRAINT  =CAST (@Emp_Id AS varchar(10))
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
							
			DECLARE @hwFromDate DATETIME
			DECLARE @hwToDate DATETIME
			SET @hwFromDate = DateAdd(d, -20, @From_Date)
			SET @hwToDate = DateAdd(d, 20, @To_Date)
			
			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT ,@CMP_ID=@Cmp_ID, @FROM_DATE=@hwFromDate, @TO_DATE=@hwToDate, @All_Weekoff = 0, @Exec_Mode=0	
			
			INSERT INTO #Employee_Leave
			SELECT	@Emp_Id,ISNULL(W.For_Date,H.FOR_DATE),0,0,CASE WHEN W.For_Date IS NULL THEN 'H' ELSE 'W' END,0,0,NULL, NULL
			FROM	#Emp_WeekOff W FULL OUTER JOIN #EMP_HOLIDAY H ON W.Emp_ID=H.EMP_ID AND W.For_Date=H.FOR_DATE
			
			
		END


	IF (@HasTable = 0 )
		SELECT * FROM  #Employee_Leave
END


