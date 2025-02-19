create function [dbo].[fnc_BindModule](@DModule_Name varchar)                          
returns varchar(max)                          
as                          
begin                       
         
  	declare @lResult varchar(max) = '<option value="0"> -- Select -- </option>'
	select @lResult = @lResult + '<option>' + @DModule_Name + '</option>'

	return @lResult
END


