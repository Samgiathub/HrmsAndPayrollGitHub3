

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 09-Feb-2018
-- Description:	For Previous 2nd Year Leave Carry Forward Laps Policy
---10/3/2021 (EDIT BY MEHUL ) (Table-valued function WITH NOLOCK)---
-- =============================================
CREATE FUNCTION [dbo].[fn_getLastYearCFDays] 
(	
	-- Add the parameters for the function here
	@Emp_ID		Numeric, 
	@For_Date	DateTime,
	@Leave_ID	Numeric
)
RETURNS @EmpInc TABLE 
(	
	Row_ID			Numeric,
	Emp_ID			Numeric,
	Leave_Tran_ID	Numeric,
	For_Date		DateTime,
	Leave_ID		Numeric,
	CF_Days			Numeric(9,4),
	Leave_Used		Numeric(9,4),
	Laps			Numeric(9,4)
)
AS
BEGIN

	DECLARE @PeriodOfYear INT 
	SELECT	@PeriodOfYear = No_Of_Allowed_Leave_CF_Yrs
	FROM	T0040_LEAVE_MASTER WITH (NOLOCK)
	WHERE	Leave_ID=@Leave_ID

	IF @PeriodOfYear = 0
		RETURN
	
	DECLARE @FROM_DATE DATETIME
	DECLARE @TO_DATE DATETIME

	SET @TO_DATE = DATEADD(D, -1, @For_Date)

	SELECT	@FROM_DATE = MIN(FOR_DATE)
	FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
	WHERE	EMP_ID=@Emp_ID AND For_Date BETWEEN DATEADD(YYYY,@PeriodOfYear * -1, @For_Date) AND @TO_DATE AND Leave_Credit > 0 AND Leave_ID=@Leave_ID
	
	

	INSERT INTO @EmpInc(Row_ID,Emp_ID,Leave_Tran_ID,For_Date,Leave_ID,CF_Days)
	SELECT	TOP 1 1, Emp_ID, 1, For_Date, @Leave_ID, Leave_Closing  
	FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
	WHERE	For_date = @FROM_DATE  AND Leave_ID=@Leave_ID AND Emp_ID=@Emp_ID
	ORDER BY FOR_DATE DESC

	
	
	DECLARE @OPENING_LASTYEAR NUMERIC(18,5)

	SELECT	@OPENING_LASTYEAR = Leave_Opening - Isnull(CF_Laps_Days,0)
	FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
	Where	For_Date = @FROM_DATE AND Leave_Credit > 0 AND Emp_ID=@Emp_ID AND Leave_ID=@Leave_ID


	DECLARE @CREDIT_LASTYEAR AS NUMERIC(18,5)

	SELECT	@CREDIT_LASTYEAR = Sum(Leave_Credit)
	FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
	Where	For_Date BETWEEN @FROM_DATE AND @TO_DATE AND Emp_ID=@Emp_ID AND Leave_ID=@Leave_ID	

	
	DECLARE @USED_LASTYEAR AS NUMERIC(18,5)

	SELECT	@USED_LASTYEAR = SUM(Leave_Used)
	FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
	Where	FOR_DATE BETWEEN @FROM_DATE AND @TO_DATE AND Emp_ID=@Emp_ID AND Leave_ID=@Leave_ID

	

	IF @OPENING_LASTYEAR - @USED_LASTYEAR < 0
		BEGIN
			SET @USED_LASTYEAR =  @USED_LASTYEAR - @OPENING_LASTYEAR
			SET @OPENING_LASTYEAR = 0
		END
	ELSE
		BEGIN
			SET @OPENING_LASTYEAR = @OPENING_LASTYEAR - @USED_LASTYEAR
			SET @USED_LASTYEAR = 0
		END

	
	update	EI
	set		CF_Days = IsNull(@CREDIT_LASTYEAR  - @USED_LASTYEAR, 0),
			Leave_Used = @USED_LASTYEAR,
			Laps = @OPENING_LASTYEAR
	FROM	@EmpInc EI		

	

	if not  exists(select 1 from @EmpInc)
		INSERT INTO @EmpInc(Row_ID,Emp_ID,Leave_Tran_ID,For_Date,Leave_ID,CF_Days,Leave_Used,Laps )
		Values(1, @Emp_ID, 1, @For_date, @Leave_ID, 0,0,0)
	
	
	RETURN;
END
