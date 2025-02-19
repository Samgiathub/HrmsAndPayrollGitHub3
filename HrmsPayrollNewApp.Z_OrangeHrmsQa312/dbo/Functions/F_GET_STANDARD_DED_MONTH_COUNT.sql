

-- =============================================
-- Author:		<HARDIK BAROT>
-- Create date: <16/04/2018>
-- Description:	<FOR GET START DATE AND END DATE FOR STANDARD DEDUCTION IN INCOME TAX W.E.F. FY- 2018-2019 >
---10/3/2021 (EDIT BY MEHUL ) (Scaler-valued function WITH NOLOCK)---
-- =============================================
CREATE FUNCTION [dbo].[F_GET_STANDARD_DED_MONTH_COUNT]
(
	@Emp_Id Numeric,
	@From_Date Datetime,
	@To_Date Datetime
)
RETURNS Int 
AS
BEGIN
	Declare @Month_Count int
	DECLARE @Join_Date datetime
	DECLARE @Left_Date Datetime
	DECLARE @FY_Start Datetime
	DECLARE @FY_End	Datetime

	SET @FY_Start = @From_Date
	SET @FY_End	= @To_Date

	SELECT @Join_Date = Date_Of_Join, @Left_Date = Emp_Left_Date FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID=@Emp_Id

	IF @Join_Date Between @From_Date And @To_Date
		SET @FY_Start = CASE WHEN Day(@Join_Date)<=15 THEN @Join_Date ELSE dbo.GET_MONTH_ST_DATE(Month(DATEADD(mm,1,@Join_Date)),Year(DATEADD(mm,1,@Join_Date))) END

	IF Not @Left_Date Is Null And @Left_Date Between @From_Date And @To_Date
		SET @FY_End = CASE WHEN Day(@Left_Date)>=15 THEN @Left_Date ELSE dbo.GET_MONTH_END_DATE(Month(DATEADD(mm,-1,@Left_Date)),Year(DATEADD(mm,-1,@Left_Date))) END

	SET @Month_Count = DATEDIFF(MM,@FY_Start,@FY_End)+1	

	--- Uncomment below line for Those client who don't want to give Standard Deduction Prorata, Added by Hardik 28/11/2019
	--Set @Month_Count = 12
	
	-- Return the result of the function
	RETURN @Month_Count

END

