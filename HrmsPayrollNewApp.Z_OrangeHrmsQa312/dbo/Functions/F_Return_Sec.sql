


CREATE FUNCTION [dbo].[F_Return_Sec]
	(
		@Duration as varchar(20) = 28800
	)
RETURNS  NUMERIC
AS
	BEGIN	
	IF LEN(@Duration) = 5 AND CHARINDEX('.', @Duration) > 0 OR LEN(@Duration) = 6 AND CHARINDEX('.', @Duration) > 0 OR LEN(@Duration) = 7 AND CHARINDEX('.', @Duration) > 0  
		SET @Duration = REPLACE(@Duration, '.',':');

		
	If isnull(@Duration,'') = '' or @Duration ='0' or @Duration ='0:' or @Duration ='00:' or @Duration ='00'
		set @Duration = '0000:00'		
	
	declare @intHours 	numeric
	declare @intMin 	numeric
	declare @intSec 	numeric
	Declare @DurationInSec 	numeric 

	set @intHours = 0
	set @intSec = 0
	set @intMin = 0
	set @DurationInSec = 0

		
	    set @intHours = cast(substring(@Duration, 1, charindex(':',@Duration,0)-1) as numeric)
	    set @intMin = cast( substring(@Duration,charindex(':',@Duration,0) +1 ,2) as numeric)
		
	    if charindex(':',@Duration,4) > 0
		    set @intSec = cast(substring(@Duration,charindex(':',@Duration,4) + 1 ,2) as numeric)
	
	    set @DurationInSec = (@intHours * 3600)
	    set @DurationInSec = @DurationInSec + (@intMin * 60)
	    set @DurationInSec = @DurationInSec + @intSec
	
		if (LEFT(@Duration, 1) = '-')
			SET @DurationInSec = ABS(@DurationInSec) * -1;	 
	
	RETURN @DurationInSec
	end




