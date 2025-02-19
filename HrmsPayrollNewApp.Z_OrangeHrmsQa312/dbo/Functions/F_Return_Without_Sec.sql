


CREATE FUNCTION [DBO].[F_Return_Without_Sec] 
	(
		@TotSec as Numeric
	)
RETURNS  Numeric
AS
	BEGIN
	
	declare @intHour as numeric
	declare @intMin as numeric
	declare @intSec as numeric
	declare @Return_Without_Sec as numeric

	set @intHour = 0
	set @intSec = 0

	if @TotSec >= 3600
		set @intHour = floor((@TotSec / 3600))
	else
		set @intHour = 0
	
	set @TotSec = @TotSec - (@intHour * 3600)
	
	if @TotSec >= 60
		set @intMin = floor(@TotSec /60)
	else
		set @intMin = 0

   
    
    set @Return_Without_Sec = (@intHour * 3600)
    set @Return_Without_Sec = @Return_Without_Sec + (@intMin * 60)

	
	RETURN @Return_Without_Sec
End



