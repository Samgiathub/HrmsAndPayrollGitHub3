CREATE FUNCTION dbo.fn_ConvertDaysToMonths( @day INT)RETURNS INT

AS
BEGIN DECLARE @month INT
SET @month = 0
WHILE (@day >= 365)
BEGIN
SET @month = @month + 12
SET @day = @day - 365
END
SET @day = @day % 365
SELECT @month = @month + CASE
WHEN @day < 31 THEN 0
WHEN @day < 59 THEN 1
WHEN @day < 90 THEN 2
WHEN @day < 120 THEN 3
WHEN @day < 151 THEN 4
WHEN @day < 181 THEN 5
WHEN @day < 212 THEN 6
WHEN @day < 243 THEN 7
WHEN @day < 273 THEN 8
WHEN @day < 304 THEN 9
WHEN @day < 334 THEN 10
WHEN @day < 365 THEN 11
WHEN @day = 0 THEN 12
END
RETURN @month
END
--select dbo.fn_ConvertDaysToMonths(426)