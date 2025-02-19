-- =============================================
-- Author:		HARDIK BAROT
-- Create date: 31/12/2020
-- Description:	TO RETURN FINANCIAL YEAR FROM FOR DATE
-- =============================================
CREATE FUNCTION [DBO].[F_GET_FINANCIAL_YEAR] 
(
	@For_Date Datetime
)
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @FIN_YEAR VARCHAR(10)

		IF MONTH(@For_Date) > 3 
			BEGIN
				SET @FIN_YEAR =  cast(datename(YYYY,@For_Date)as varchar(10)) + '-' + cast(datename(YYYY,@For_Date)+ 1 as varchar(10))
			END
		ELSE
			BEGIN	
				SET @FIN_YEAR =  cast(datename(YYYY,@For_Date) - 1 as varchar(10)) + '-' + cast(datename(YYYY,@For_Date) as varchar(10))
			END 


	-- Return the result of the function
	RETURN @FIN_YEAR

END
