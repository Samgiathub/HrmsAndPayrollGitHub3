
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE   PROCEDURE [dbo].[SP_RETURN_PRE_NEXT_DATE_OF_WEEKOFF]
	 @For_Date as datetime
	,@Tot_Holiday_Date as varchar(MAX)
	,@Pre_Date_WeekOff as datetime  output 
	,@Next_Date_WeekOff as datetime  output
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @Counter as numeric
	declare @Temp_For_Date as datetime	

	
	set @Temp_For_Date = @For_Date
	set @Counter = 0
	
	while @Counter = 0
		begin	
			
			if charindex(cast(@Temp_For_Date as varchar(11)),@Tot_Holiday_Date,0) = 0 
				begin
			
					set @Counter = 1
					set @Pre_Date_WeekOff = @Temp_For_Date 					
				end
			set @Temp_For_Date = dateadd(d,-1,@Temp_For_Date)
		end
		
	set @Counter = 0	
	set @Temp_For_Date = @For_Date
	
	while @Counter = 0
	begin	
		if charindex(cast(@Temp_For_Date as varchar(11)),@Tot_Holiday_Date,0) = 0 
			begin
			
				set @Counter = 1
				set @Next_Date_WeekOff = @Temp_For_Date 					
			end
		set @Temp_For_Date = dateadd(d,1,@Temp_For_Date)
	end

-- if weekoff is not include in @Tot_Holiday_Date 
	if @Next_Date_WeekOff = @Pre_Date_WeekOff
		begin
			set @Pre_Date_WeekOff = dateadd(d,-1,@Pre_Date_WeekOff)
			set @Next_Date_WeekOff =dateadd(d,1,@Next_Date_WeekOff)		
		end
	---------

		 
	RETURN 




