

-- created by rohit for Weekend get on 01032016
CREATE FUNCTION [DBO].[fnc_NumberOfWeekEnds](@DAY VARCHAR(100),@DFROM DATETIME, @DTO   DATETIME)

RETURNS INT AS

BEGIN


Declare @weekends int
Declare @noday int
Declare @data as varchar(500)
declare @id as numeric
Declare @tempdate Datetime
Set @weekends = 0

declare curAD cursor for    
		select * from dbo.split(@Day,'#')                
	open curAD                      
	fetch next from curAD into @id,@data
	while @@fetch_status = 0                    
		begin   
		
		
		
			if LEN(@data) > 3 
				Begin
					Set @data = LEFT(@data,3)
				End
			
				begin
					set @noday =  
						case @data 
						when 'Sun' then 1
						when 'Mon' then 2 
						when 'Tue' then 3
						when 'Wed' then 4
						when 'Thu' then 5
						when 'Fri' then 6
						when 'Sat' then 7
						
						else 1 End 
				end
	           
       set @tempdate = @dFrom
       
				While @tempdate <= @dTo Begin
					 If ((datepart(dw, @tempdate) = @noday))    
					  Set @weekends = @weekends + 1
					  Set @tempdate = DateAdd(d, 1, @tempdate)
				End
       
       fetch next from curAD into @id,@data
       end                    
	close curAD                    
	deallocate curAD
	
	Return (@weekends)

END
