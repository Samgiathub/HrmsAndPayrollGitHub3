-- select * from dbo.fnc_BindDependentExcel()  
-- drop function dbo.fnc_BindDependentExcel  
CREATE function [dbo].[fnc_BindDependentExcel](@rCmpId int,@rModuleName varchar(300))  
returns varchar(max)  
as  
begin  
 declare @lResult varchar(max) = ''  
  
 select @lResult = '<option value="0"> -- Select -- </option>'  
 select @lResult = @lResult + '<option value="' + CONVERT(varchar,Goal_ID) + '" ' + CASE WHEN Goal_Name = @rModuleName THEN 'selected="selected"' ELSE '' END + '>' + Goal_Name + '</option>'  
 from KPMS_T0020_Goal_Master where Cmp_ID = @rCmpId and IsActive < 2  
   
 return @lResult  
end