  
CREATE function [dbo].[fnc_Enable/Dis_Month]()  
returns varchar(max)  
as  
begin  
 declare @lResult1 varchar(max),@lResult varchar(max)   
  select @lResult1 = dateadd(day,10,EOMONTH(DATEADD(day, -1, getdate())))

  if(GETDATE()< @lResult1)
	BEGIN
		select @lResult = 'disable'
	END
	ELSE
	BEGIN
		select @lResult = 'disable'
	END
return @lResult 
end



