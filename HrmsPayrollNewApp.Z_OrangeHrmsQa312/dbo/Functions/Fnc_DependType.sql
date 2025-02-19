CREATE function [dbo].[Fnc_DependType](@GSG_Depend_Type_Id int,@GSG_Depend_Goal_Id int)          
returns varchar(max)          
as          
BEGIN        
 declare @lResult3 varchar(max) =''        
 declare @lResult4 varchar(max) =''     

    select @lResult3 = GSG_Depend_Type_Id from KPMS_T0110_Goal_Setting_Goal 
	--inner join KPMS_T0020_Goal_Master on Goal_ID = GSG_Goal_Id 
	where GSG_Depend_Goal_Id = @GSG_Depend_Goal_Id and GSG_Depend_Type_Id = @GSG_Depend_Type_Id

	--select @lResult3
	
	select @lResult4 =@lResult4 + case @lResult3 when 2 then 'Achievement' else 'Target' END
   --select @lResult4

   Return @lResult4;        
END   

