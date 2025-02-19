


CREATE FUNCTION [DBO].[udf_DayOfWeek](@DTDATE DATETIME)
RETURNS VARCHAR(10)
AS
BEGIN
DECLARE @rtDayofWeek VARCHAR(10)
SELECT @rtDayofWeek = CASE DATEPART(weekday,@dtDate)
WHEN 1 THEN 'Sunday'
WHEN 2 THEN 'Monday'
WHEN 3 THEN 'Tuesday'
WHEN 4 THEN 'Wednesday'
WHEN 5 THEN 'Thursday'
WHEN 6 THEN 'Friday'
WHEN 7 THEN 'Saturday'
END
RETURN (@rtDayofWeek)
END



