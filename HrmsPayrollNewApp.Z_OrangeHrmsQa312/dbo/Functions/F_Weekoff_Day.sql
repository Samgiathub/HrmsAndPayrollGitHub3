



-- =============================================
-- Author:		Mihir R Adeshara
-- ALTER date: <ALTER Date,04-12-2011 ,>
-- Description:	<Description, Week Off having String like Sun or Sunday so to make uniqu string like Sunday  ,>
-- =============================================
CREATE FUNCTION [DBO].[F_Weekoff_Day]
(
	@Default_Holiday As Varchar(200)
)
RETURNS Varchar(200)
AS
BEGIN

	-- changed by mitesh on 06/01/2012
	
	Declare @Default_Weekoff varchar(200) 
	set @Default_Weekoff = ''
	declare @id as numeric
	declare @data as nvarchar(50)
	
	
	
	declare curAD cursor for    
		select * from dbo.split(@Default_Holiday,'#')                
	open curAD                      
	fetch next from curAD into @id,@data
	while @@fetch_status = 0                    
		begin   
		
			if LEN(@data) > 3 
				Begin
					Set @data = LEFT(@data,3)
				End
			--set @Default_Weekoff=@data
				
			if @Default_Weekoff = ''
				begin
					set @Default_Weekoff = 
						case @data 
						when 'Sun' then 'Sunday'
						when 'Mon' then 'Monday' 
						when 'Tue' then 'Tuesday' 
						when 'Wed' then 'Wednesday' 
						when 'Thu' then 'Thursday' 
						when 'Fri' then 'Friday' 
						when 'Sat' then 'Saturday' 
						else @data End 
				end
			else
				begin
					set @Default_Weekoff =  @Default_Weekoff + '#' +
						case @data 
						when 'Sun' then 'Sunday'
						when 'Mon' then 'Monday' 
						when 'Tue' then 'Tuesday' 
						when 'Wed' then 'Wednesday' 
						when 'Thu' then 'Thursday' 
						when 'Fri' then 'Friday' 
						when 'Sat' then 'Saturday' 
						else @data End 
				end
	           
       
       fetch next from curAD into @id,@data
       end                    
	close curAD                    
	deallocate curAD
	
	
	
	RETURN @Default_Weekoff
END



