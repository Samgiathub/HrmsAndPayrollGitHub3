
CREATE FUNCTION [dbo].[F_Return_Hours_RB031224] 
	(
		@TotSec as integer
	)
RETURNS  varchar(2000)
AS
	BEGIN

	
	
	declare @numHour as numeric
	declare @numMin as numeric

	declare @varHour as varchar(5)
	declare @varMin as varchar(2)
	declare @varSec as varchar(2)
	declare @Return_DurHourMinSec as varchar(20)

	if isnull(@TotSec,0) <= 0 
		set @TotSec =0  


	if @TotSec >= 3600
		set @numHour = floor((@TotSec / 3600))
	else
		set @numHour = 0
	
	set @TotSec = @TotSec - (@numHour * 3600)
	
	if @TotSec >= 60
		set @numMin = floor(@TotSec /60)
	else
		set @numMin = 0
		
	set @TotSec = @TotSec - (@numMin * 60)
	
	--set @varHour = cast(@numHour as varchar(5))
	
	--set @varMin = cast (@numMin	 as varchar(50))			
	--set @varSec = cast (@TotSec as varchar(50))
	set @varHour = @numHour
	set @varMin = @numMin
	set @varSec = @TotSec
	
		if @numHour > 0  
			begin
				if @numHour < 100
					begin
						while len(@varHour) <> 2
							begin
								set @varHour = '0' + @varHour
							end
					end
				else
					begin
						while len(@varHour) < 4
							begin
								set @varHour = '0' + @varHour
							end
					end
				
			end
		
		else
			SET @varHour= '00'
		
		if @numMin > 0  
			begin
				while len(@varMin) <> 2
					begin
						set @varMin = '0' + @varMin
					end
			end
		else
			SET @varMin= '00'

		if @TotSec > 0  
			begin
				while len(@varSec) <> 2
				begin
						set @varSec = '0' + @varSec
					end
			end
		else
			SET @varSec= '00'

	
		set @Return_DurHourMinSec = @varHour + ':' + @varMin 

	
	RETURN @Return_DurHourMinSec
	end




