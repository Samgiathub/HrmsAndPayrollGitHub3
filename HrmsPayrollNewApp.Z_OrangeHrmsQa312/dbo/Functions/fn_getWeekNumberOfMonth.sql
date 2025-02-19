

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 01-Jun-2015
-- Description:	To get the week number of given date in month
-- =============================================
CREATE FUNCTION fn_getWeekNumberOfMonth 
(
	@date DateTime
)
RETURNS INT
AS
BEGIN		
	DECLARE @VAL NUMERIC(5,2),
				@NUMBER INT;
		
	SET @VAL = Cast(DAY(@date) As Numeric) / 7;
	
	SET @NUMBER = ROUND(@VAL,5,0);
	IF ((@VAL - @NUMBER) > 0)
		SET @NUMBER = @NUMBER + 1;
	
	RETURN @NUMBER;

END

