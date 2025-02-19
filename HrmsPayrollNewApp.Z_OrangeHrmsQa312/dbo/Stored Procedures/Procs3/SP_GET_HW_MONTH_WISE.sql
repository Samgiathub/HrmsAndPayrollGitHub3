

-- =============================================
-- Author:		Nilesh Patel
-- Create date: 11/07/2017
-- Description:	GET WEEKOFF AND HOLIDAY MONTH WISE FOR DISPLAY IN CALENDAR CONTROL
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_GET_HW_MONTH_WISE]
	-- Add the parameters for the stored procedure here
	@EMP_ID NUMERIC
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    IF OBJECT_ID('tempdb..#EMP_CONS') IS NULL
	BEGIN
		CREATE TABLE #EMP_CONS(EMP_ID NUMERIC, BRANCH_ID NUMERIC, INCREMENT_ID NUMERIC);
	END

	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
		BEGIN
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
		END

	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
		END
			
	IF OBJECT_ID('tempdb..#Emp_WeekOff_Holiday') IS NULL
		BEGIN	
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
		END
	
	IF (OBJECT_ID('tempdb..#EMP_HW_CONS') IS NULL)
		CREATE TABLE #EMP_HW_CONS
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
		
		DECLARE @FROM_DATE DATETIME
		DECLARE @TO_DATE DATETIME
		
		SET @FROM_DATE = ''
		SET @TO_DATE = ''
		
		SET @FROM_DATE = CAST(Convert(varchar(11),DATEADD(MM,-3,GETDATE()),101) AS datetime)
		SET @TO_DATE = CAST(Convert(varchar(11),DATEADD(MM,3,GETDATE()),101) AS datetime)
		
		DECLARE @CMP_ID NUMERIC
		SELECT @CMP_ID = Cmp_ID FROM T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @EMP_ID
		
		EXEC dbo.SP_EMP_HOLIDAY_WEEKOFF_ALL  @CMP_ID,@FROM_DATE,@TO_DATE, 0, @EMP_ID

		SELECT CONVERT(varchar(11),For_Date,103) as ForDate FROM #EMP_HOLIDAY  
		
		Select Replace(CONVERT(varchar(11),For_Date,102),'.','') as ForDate,Weekoff_Day,Alt_W_Name,Alt_W_Full_Day_Cont From T0100_WEEKOFF_ADJ WITH (NOLOCK) Where Emp_ID = @EMP_ID order by For_Date DESC
		
END

