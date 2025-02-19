CREATE function [dbo].[fnc_BindFreqTotal](@Emp_ID int,@TargetAchiveid int)                              
returns varchar(max)                              
as                              
begin                           
             
  declare @total1 varchar(max)=''                 
   declare @total2 varchar(max)=''                 
    BEGIN            
	select @total1 = Achievement from KPMS_T0110_TargetAchivement where emp_id= @Emp_ID  and TargetAchiveid = @TargetAchiveid;            
  end                      

   declare @perach varchar(max)=''
  
	select @perach = Achievement from KPMS_T0110_TargetAchivement where TargetAchiveid =@TargetAchiveid and emp_id = @Emp_ID and WeightageType = 2 

	declare @result varchar(max)=''

	if(@total1=@perach)
	begin

			select	@total2 = @total1 
		   select @result =  @total2   
	end
	else
	begin
			select @result = @total1
	end
	
	return @result
          


END  
  
