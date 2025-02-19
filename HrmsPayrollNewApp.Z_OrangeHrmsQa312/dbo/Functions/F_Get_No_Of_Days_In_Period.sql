




-- =============================================
-- Author:		Hardik Barot
-- ALTER date: 10/01/2012
-- Description:	To get Number of Sunday, Monday, etc in selected period
-- =============================================

CREATE FUNCTION [DBO].[F_Get_No_Of_Days_In_Period]
(
	@From_Date As Datetime,
	@To_Date As Datetime,
	@Day_Name As varchar(20)  -- 1 for Sunday, 2 for Monday, 3 for tue, etc... 0 for all days in selected periods
	
)
RETURNS Numeric(18,1)
AS
BEGIN
	
	Declare @Total_Days As Numeric(18,1)
	Declare @Day_No as Numeric
	
	If Upper(@Day_Name) = Upper('Sunday')
		Set @Day_No = 1
	else if Upper(@Day_Name) = Upper('Monday')
		Set @Day_No = 2
	else if Upper(@Day_Name) = Upper('Tuesday')
		Set @Day_No = 3
	else if Upper(@Day_Name) = Upper('Wednesday')
		Set @Day_No = 4
	else if Upper(@Day_Name) = Upper('Thursday')
		Set @Day_No = 5
	else if Upper(@Day_Name) = Upper('Friday')
		Set @Day_No = 6
	else if Upper(@Day_Name) = Upper('Saturday')
		Set @Day_No = 7
	Else
		Set @Day_No = 0
		
		
	If @Day_No = 0 or @Day_No > 7 
		Begin
			SELECT @Total_Days = count(*) FROM  
				(SELECT TOP (datediff(DAY,@From_Date,@To_Date) + 1)
								[Date] = dateadd(DAY,ROW_NUMBER()
						  OVER(ORDER BY c1.name),
						  DATEADD(DD,-1,@From_Date))
				FROM [master].[dbo].[spt_values] c1) As Qry
		End
	Else
		Begin
			SELECT @Total_Days = count(*) FROM  
				(SELECT TOP (datediff(DAY,@From_Date,@To_Date) + 1)
								[Date] = dateadd(DAY,ROW_NUMBER()
						  OVER(ORDER BY c1.name),
						  DATEADD(DD,-1,@From_Date))
				FROM [master].[dbo].[spt_values] c1) As Qry
			WHERE  datepart(dw,[Date]) = @Day_No;
		End
		
RETURN @Total_Days
END




