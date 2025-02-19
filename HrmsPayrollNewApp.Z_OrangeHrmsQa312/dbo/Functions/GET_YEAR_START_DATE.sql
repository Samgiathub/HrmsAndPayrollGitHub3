


--Created by Gadriwala Muslim 18112015
CREATE FUNCTION [DBO].[GET_YEAR_START_DATE]
	(
		@YEAR AS NUMERIC,
		@Month  as numeric,
		@Type as tinyint
	)
RETURNS DATETIME
AS
	
	BEGIN
		DECLARE @YEAR_ST_DATE AS DATETIME	

		if @Type = 1 -- Calendar Year
			begin
					SET @YEAR_ST_DATE = CAST('01' + '/' + '01' + '/' + CAST(@YEAR AS VARCHAR(5)) AS SMALLDATETIME)
			end
		else  -- Financial year
			begin
				if @Month > 3 
					SET @YEAR_ST_DATE = CAST('04' + '/' + '01' + '/' + CAST(@YEAR AS VARCHAR(5)) AS SMALLDATETIME)
				else
					SET @YEAR_ST_DATE = CAST('04' + '/' + '01' + '/' + CAST(@YEAR - 1 AS VARCHAR(5)) AS SMALLDATETIME)
			end
			
		RETURN @YEAR_ST_DATE
	END




