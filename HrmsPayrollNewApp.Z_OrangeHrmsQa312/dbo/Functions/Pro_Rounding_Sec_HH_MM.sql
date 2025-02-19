




CREATE FUNCTION [DBO].[Pro_Rounding_Sec_HH_MM]
	(
	@Totalsec as integer,
	@RoundingValue as numeric(18,2)
	)
RETURNS Numeric
AS
	-- @RoundingValue is for upper rounding half hour or full hour
	
	BEGIN
		Declare @Minute as numeric
		Declare @Second as numeric
		declare @hours as int
		declare @Round_TotalSec as Numeric
		declare @Round_Value_Sec as Numeric
		
		if @RoundingValue > 0
			Begin
				
				if @RoundingValue = 0.5
					begin 
						SET @Round_Value_Sec  = 1800
					end
				else if @RoundingValue = 1 	
					begin
						SET @Round_Value_Sec  = 3600
					end
					
				set @minute = 0
				set @Second = 0
				set @hours = 0
				
				if @Totalsec > 0 
					begin
						set @hours = @Totalsec / @Round_Value_Sec 
						
						set @second = @Totalsec % @Round_Value_Sec
						
						if @Second > 0
							begin															
								
								set @Round_TotalSec = @Totalsec - @second
								set @Round_TotalSec = @Round_TotalSec + @Round_Value_Sec 
								
							end
						else
							begin
								set @Round_TotalSec = @Totalsec
							end
					end			
			End		
		Else
			Begin				
				
				Set @Round_TotalSec = @Totalsec
				
			End
			
		RETURN @Round_TotalSec
	END




