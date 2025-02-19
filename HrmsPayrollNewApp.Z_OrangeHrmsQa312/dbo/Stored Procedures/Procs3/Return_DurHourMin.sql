


---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE  PROCEDURE [dbo].[Return_DurHourMin]

 @TotSec as numeric
,@Return_DurHourMinSec as varchar(20) output
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @numHour as numeric
	declare @numMin as numeric

	declare @varHour as varchar(5)
	declare @varMin as varchar(2)
	declare @varSec as varchar(2)

	
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
	--set @varSec = @TotSec
	
	if(isnull(@TotSec,0) > 0)			
	set @varSec = @TotSec
	else
	set @varSec = 0
	
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

	RETURN 




