CREATE FUNCTION [dbo].[F_Return_Hours_D] 
(
    @TotSec as integer
)
RETURNS varchar(2000)
AS
BEGIN
    DECLARE @numHour AS numeric
    DECLARE @numMin AS numeric
    DECLARE @varHour AS varchar(5)
    DECLARE @varMin AS varchar(2)
    DECLARE @varSec AS varchar(2)
    DECLARE @Return_DurHourMinSec AS varchar(20)

    IF ISNULL(@TotSec, 0) <= 0 
        SET @TotSec = 0  

    IF @TotSec >= 3600
        SET @numHour = FLOOR(@TotSec / 3600)
    ELSE
        SET @numHour = 0
    
    SET @TotSec = @TotSec - (@numHour * 3600)
    
    IF @TotSec >= 60
        SET @numMin = FLOOR(@TotSec / 60)
    ELSE
        SET @numMin = 0
        
    SET @TotSec = @TotSec - (@numMin * 60)

    SET @varHour = CAST(@numHour AS varchar(5))
    SET @varMin = CAST(@numMin AS varchar(2))
    SET @varSec = CAST(@TotSec AS varchar(2))

    -- Ensure the minute and second values have two digits
    IF LEN(@varMin) = 1 
        SET @varMin = '0' + @varMin
    
    IF LEN(@varSec) = 1 
        SET @varSec = '0' + @varSec

    -- Construct the final result without forcing a leading zero on the hours part
    SET @Return_DurHourMinSec = @varHour + ':' + @varMin

    RETURN @Return_DurHourMinSec
END
