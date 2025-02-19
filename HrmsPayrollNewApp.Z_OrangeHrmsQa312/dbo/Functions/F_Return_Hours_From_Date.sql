




CREATE FUNCTION DBO.F_Return_Hours_From_Date 
	(
		@From_Date	Datetime,
		@To_Date	Datetime	
	)
RETURNS  varchar(10)
AS
	BEGIN
	
	Declare @TotSec		integer
	
	set @TotSec = datediff(s,@From_Date,@To_Date)
	
	
	declare @numHour	numeric
	declare @numMin		numeric

	declare @varHour	varchar(5)
	declare @varMin		varchar(2)
	declare @varSec		varchar(2)
	declare @Return_DurHourMinSec	varchar(20)

	IF @TotSec < 0
		set @TotSec =  @TotSec * -1

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
						while len(@varHour) <> 3
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




