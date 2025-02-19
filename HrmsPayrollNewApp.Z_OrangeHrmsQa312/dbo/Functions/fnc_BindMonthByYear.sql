-- select * from dbo.fnc_BindMonthByYear()
-- drop function dbo.fnc_BindMonthByYear
create function [dbo].[fnc_BindMonthByYear](@rCmpId int)
returns varchar(max)
as
begin
	declare @lResult varchar(max) = '<option value="0"> -- Select -- </option>'
	select @lResult = @lResult + '<option value="' + convert(varchar,Month(DATEADD(MONTH, x.number, From_Date))) + '">' + DATENAME(MONTH, DATEADD(MONTH, x.number, From_Date)) + '</option>'
	from master.dbo.spt_values x,KPMS_T0020_BatchYear_Detail	
	WHERE x.type = 'P' AND x.number <= DATEDIFF(MONTH, From_Date, To_Date)
	and IsActive = 1 and Cmp_Id = @rCmpId and IsDefault = 1
		
	return @lResult
end