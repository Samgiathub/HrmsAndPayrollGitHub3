CREATE FUNCTION GetQuarterLastdate
(
	@Todate Date
)
RETURNS DATE
AS
BEGIN
	DECLARE @LASTDATEOFQUARTERMONTH AS DATE
	;with dates as
	(
	    select  [date] = convert(date, @Todate)
	    union all
	    select  [date] = dateadd(month, 1, [date])
	    from    dates
	    where   [date]  < @Todate
	)
	SELECT  --[date],
	        @LASTDATEOFQUARTERMONTH = DATEADD(QUARTER, DATEDIFF(QUARTER, 0, [DATE]) + 1, -1) 
	        --dateadd(quarter, datediff(quarter, 0, [date]) / 2 * 2 + 2, -1) as [Last Day of Half Year],
	        --dateadd(year, datediff(year, 0, [date]) + 1, -1) as [Last Day of Year]
	FROM DATES
		
	RETURN @LastDateofQuarterMonth
END
