




-- =============================================
-- Author:		Hardik Barot
-- ALTER date: 27/12/2012
-- Description:	To get NCP Days for PF Online Statement
-- =============================================

CREATE FUNCTION [DBO].[F_Get_NCP_Days]
(
	@From_Date as Datetime,
	@To_Date as Datetime,
	@Basic_Salary As Numeric(18,2),
	@Salary_Amount As Numeric(18,2),
	@Present_Days as Numeric(18,2),
	@PF_Limit as Numeric(18,2),
	@Absent_Days as Numeric(18,2),
	@Wages_Type as varchar(15),
	@Weekoff_Days as Numeric(18,0)
	
)
RETURNS Numeric(18,0)
AS
BEGIN
		Declare @NCP_Days as Numeric(18,0)
		Declare @PF_Day_Salary as Numeric(18,2)
		Declare @MonthDays as Numeric
		
		--Condition added by Hardik 16/02/2019 for Lubi, As Minus Absent day showing in ECR File.
		If @Absent_Days < 0 
			Set @Absent_Days = 0

		
		Set @NCP_Days = 0
		Set @PF_Day_Salary = 0
		Set @MonthDays = 0
		
		Set @MonthDays = DATEDIFF(d,@From_Date,@To_Date) + 1
		
		If @Wages_Type = 'Daily' And @Present_Days > 0
			Begin 
				Set @MonthDays = @MonthDays - @Weekoff_Days
				Set @Basic_Salary = (@Salary_Amount/@Present_Days) * @MonthDays
			End
		
		
		If @Salary_Amount >= @PF_Limit
			Set @NCP_Days = 0
		else If @Basic_Salary > @PF_Limit And @Salary_Amount < @PF_Limit And @PF_Limit >0
			Begin
				Set @PF_Day_Salary = @PF_Limit / @MonthDays
				Set @NCP_Days = (@PF_Limit - @Salary_Amount) / @PF_Day_Salary
			End
		Else
			Begin
				Set @NCP_Days = @Absent_Days
			End
		--set @NCP_Days = @Basic_Salary
RETURN @NCP_Days
END




