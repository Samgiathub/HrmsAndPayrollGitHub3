CREATE function [dbo].[Fnc_Depend](@GSG_Depend_Goal_Id int)          
returns varchar(max)          
as          
BEGIN        
 declare @lResult3 varchar(max) =''        

    select @lResult3 = @lResult3 + 
  Goal_Name from KPMS_T0020_Goal_Master where Goal_ID = @GSG_Depend_Goal_Id

   Return @lResult3;        
END   

