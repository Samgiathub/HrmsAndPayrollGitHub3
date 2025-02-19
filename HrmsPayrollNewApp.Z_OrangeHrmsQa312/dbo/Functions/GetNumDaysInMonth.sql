

CREATE FUNCTION [DBO].[GetNumDaysInMonth] ( @MYDATETIME DATETIME )
RETURNS INT
AS
	BEGIN
		DECLARE @rtDate INT

SET @rtDate =
	CASE
		WHEN MONTH(@myDateTime)
		IN (1, 3, 5, 7, 8, 10, 12) THEN 31
		WHEN MONTH(@myDateTime) IN (4, 6, 9, 11) THEN 30
		ELSE CASE
			WHEN (YEAR(@myDateTime) % 4 = 0 AND
			YEAR(@myDateTime) % 100 != 0) OR
			(YEAR(@myDateTime) % 400 = 0) THEN 29
			ELSE 28
		END
	END
RETURN @rtDate
END
