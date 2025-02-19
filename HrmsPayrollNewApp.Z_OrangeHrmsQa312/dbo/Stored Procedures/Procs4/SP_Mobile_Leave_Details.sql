

CREATE PROCEDURE [dbo].[SP_Mobile_Leave_Details]

	@Emp_ID numeric(18,0),
	@Cmp_ID numeric(18,0),
	@Leave_ID numeric(18,0),
	@PeriodDays numeric(18,2),
	@From_Date datetime
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


BEGIN

DECLARE @ForDate datetime
DECLARE @To_Date datetime
DECLARE @From_DateFE datetime
DECLARE @To_DateFE datetime
DECLARE @From_DateLE datetime
DECLARE @To_DateLE datetime

DECLARE @Leave_Min numeric(18,2)
DECLARE @Leave_Max numeric(18,2)
DECLARE @Leave_Closing numeric(18,2)
DECLARE @Leave_Negative_Allow int
DECLARE @Can_Apply_Fraction int
DECLARE @Leave_Negative_Max_Limit numeric(18,0)
DECLARE @IS_Leave_Clubbed int
DECLARE @ErrorMsg varchar(MAX)
DECLARE @LeaveScheme_ID numeric(18,0)
DECLARE @Days numeric(18,2)
DECLARE @LeaveDays numeric(18,2)
DECLARE @Leave_Dates varchar(MAX) 

SET @Days = CEILING(@PeriodDays)
SET @LeaveDays = @Days - @PeriodDays

SET @ForDate = CONVERT(varchar(11),GETDATE())

CREATE TABLE #LeaveBalanceData
(
	Leave_Opening numeric(18,2),
	Leave_Used numeric(18,2),
	Leave_Creadit numeric(18,2),
	Leave_Closing numeric(18,2),
	Leave_Code varchar(50),
	Leave_Name varchar(50),
	Leave_ID numeric(18,0),
	Display_Leave_Balance numeric(18,0),
	Actual_Leave_Closing numeric(18,0)
)
CREATE TABLE #LeaveDetails
(
	Leave_Min numeric(18,2),
	Leave_Max numeric(18,2),
	Leave_Notice_Period int,
	Leave_Applicable int,
	Leave_Nagative_Allow int,
	Leave_Paid_Unpaid varchar(20),
	Is_Document_required int,
	Apply_Hourly int,
	Can_Apply_Fraction int,
	Default_Short_Name varchar(50),
	Leave_Name varchar(50),
	AllowNightHalt int,
	Half_Paid int,
	Leave_Negative_Max_Limit numeric(18,2)
)
CREATE TABLE #LeaveClubbDetails
(
	Emp_ID numeric(18,2),
	Cmp_ID numeric(18,2),
	Emp_Full_Name varchar(50),
	Leave_ID numeric(18,0),
	Leave_Code varchar(20),
	Leave_Name varchar(50),
	Leave_Type varchar(50),
	IS_Leave_Clubbed int,
	Application_Date datetime,
	Application_Status varchar(5),
	From_Date datetime,
	To_Date datetime,
	Leave_Assign_AS varchar(50),
	Half_Leave_Date datetime
)
CREATE TABLE #LeaveToDate
(
	From_Date datetime,
	To_Date datetime,
	Period numeric(18,2),
	Leave_date varchar(MAX),
	Weekoff_date varchar(MAX),
	Holiday_Date varchar(MAX)
)

SELECT @LeaveScheme_ID = ISNULL(ES.Tran_ID,0)  FROM T0095_EMP_SCHEME  ES WITH (NOLOCK)
INNER JOIN 
(
	SELECT Data AS 'Leave_ID',Scheme_ID FROM T0050_Scheme_Detail SE WITH (NOLOCK) CROSS APPLY dbo.Split(SE.Leave, '#')
) SD ON ES.Scheme_ID = SD.Scheme_Id
WHERE Type = 'Leave' AND Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND SD.Leave_ID = @Leave_ID

INSERT INTO #LeaveBalanceData EXEC SP_LEAVE_CLOSING_AS_ON_DATE_ALL @CMP_ID = @Cmp_ID,@EMP_ID = @Emp_ID,@FOR_DATE = @From_Date,@Leave_Application = 0,@Leave_Encash_App_ID = 0,@Leave_ID = @Leave_ID


INSERT INTO #LeaveDetails EXEC P0050_Leave_Details_Get @Cmp_Id = @Cmp_ID,@Emp_Id = @Emp_ID,@Leave_Id = @Leave_ID

INSERT INTO #LeaveToDate 
EXEC Calculate_Leave_End_Date @CMP_ID = @Cmp_ID,@Emp_Id = @Emp_ID,@Leave_id = @Leave_ID,@From_Date = @From_Date,@Period = @PeriodDays,@Type = 'E',@M_Cancel_weekoff_holiday = 0,@Leave_Assign_As = 'Full Day'


 	 
SELECT @Leave_Closing = Leave_Closing  FROM #LeaveBalanceData
SELECT @Leave_Min = Leave_Min,@Leave_Max = Leave_Max,@Leave_Negative_Allow =Leave_Nagative_Allow, @Can_Apply_Fraction = Can_Apply_Fraction,@Leave_Negative_Max_Limit=Leave_Negative_Max_Limit  FROM #LeaveDetails
SELECT @To_Date = To_Date ,@Leave_Dates = Leave_date FROM #LeaveToDate


SET @From_DateFE = (@From_Date - 1)
SET @To_DateFE = (@From_Date - 1)
SET @From_DateLE = (@To_Date - 1)
SET @To_DateLE = (@To_Date - 1)

INSERT INTO #LeaveClubbDetails EXEC Check_Leave_Clubbing @Emp_ID,@Cmp_Id,@From_DateFE,@To_DateFE,@From_DateLE,@To_DateLE,'LA',@Leave_ID     

SELECT @IS_Leave_Clubbed = IS_Leave_Clubbed  FROM #LeaveClubbDetails
	
	
	
	IF @LeaveScheme_ID IS NULL
		BEGIN
			SELECT 'Scheme is not Assigned to Employee'
			RETURN 
		END
	
	IF @LeaveDays <> 0
		BEGIN
			IF @Can_Apply_Fraction <> 1
				BEGIN
					SELECT 'You Cannot Enter Fraction Value'
					RETURN 
				END
		END
	IF  @PeriodDays < @Leave_Min AND @Leave_Min <> '0.0'
		BEGIN 
			SET @ErrorMsg = 'You have to take Min' + @Leave_Min + 'leave for selected leave Type'
			SELECT @ErrorMsg
			RETURN 
		END
	IF  @PeriodDays > @Leave_Max AND @Leave_Max <> '0.0'
		BEGIN 
			SET @ErrorMsg ='You have to take Max' + @Leave_Max + 'leave for selected leave Type'
			SELECT @ErrorMsg
			RETURN 
		END
	IF  @PeriodDays >= @Leave_Closing
		BEGIN 
			IF @Leave_Negative_Allow = 0
				BEGIN
					SELECT 'You have not take more leave for selected leave Type'
					RETURN 
				END
		END
	IF @IS_Leave_Clubbed = 1
		BEGIN
			SELECT 'Selected Leave Cannot Club with Previous Leave Approved'
			RETURN 
		END
		--SELECT STUFF(CONVERT(varchar(11),CAST(data as datetime),103), 1, Len(Data) +1- CHARINDEX(' ',Reverse(Data)), '') FROM dbo.Split(SUBSTRING(@Leave_Dates,3,LEN(@Leave_Dates) ),'; ') --FOR XML PATH('')), 1, 1, ''
		 
		--SELECT CONVERT(varchar(11),CAST(data as datetime),103) FROM dbo.Split(@Leave_Dates,' ; ')
		--SELECT REPLACE(@Leave_Dates,' ;',';')
		
		
	SET @ErrorMsg = 'OK : '  + CONVERT(varchar(11), @To_Date,103) +  @Leave_Dates 
	--SET @ErrorMsg = 'OK : ' + CONVERT(varchar(11), @To_Date,103)
	SELECT @ErrorMsg
	RETURN 	
	--EXEC SP_Emp_Scheme_Details @Cmp_id=@Cmp_ID,@Emp_id=@Emp_ID,@Loan_ID='Leave',@Leave_Type=@Leave_ID,@From_Date = @ForDate
	--EXEC SP_LEAVE_CLOSING_AS_ON_DATE_ALL @CMP_ID = @Cmp_ID,@EMP_ID = @Emp_ID,@FOR_DATE = @From_Date,@Leave_Application = 0,@Leave_Encash_App_ID = 0,@Leave_ID = @Leave_ID
	--EXEC P0050_Leave_Details_Get @Cmp_Id = @Cmp_ID,@Emp_Id = @Emp_ID,@Leave_Id = @Leave_ID
END

