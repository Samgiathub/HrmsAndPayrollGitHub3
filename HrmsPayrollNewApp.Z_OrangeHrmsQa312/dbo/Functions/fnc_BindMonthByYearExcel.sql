-- select dbo.fnc_BindMonthByYearExcel(119,7)    
-- drop function dbo.fnc_BindMonthByYearExcel    
CREATE function [dbo].[fnc_BindMonthByYearExcel](@rCmpId int,@rMonth varchar(10))    
returns varchar(max)    
as    
begin    
 declare @lResult varchar(max) = '<option value="0">  Select </option>'    
 select @lResult = @lResult + '<option value="' + convert(varchar,Month(DATEADD(MONTH, x.number, From_Date))) + '"    
 ' + case when DATENAME(MONTH, DATEADD(MONTH, x.number, From_Date)) = @rMonth then 'selected="selected"' when isnumeric(@rMonth) = 1 then case when Month(DATEADD(MONTH, x.number, From_Date)) = @rMonth then 'selected="selected"' else '' end else '' end + '
  
>' + DATENAME(MONTH, DATEADD(MONTH, x.number, From_Date)) + '</option>'    
 from master.dbo.spt_values x,KPMS_T0020_BatchYear_Detail     
 WHERE x.type = 'P' AND x.number <= DATEDIFF(MONTH, From_Date, To_Date)    
-- and IsActive = 1 and Cmp_Id = @rCmpId and IsDefault = 1    
  and IsActive = 1 and IsDefault = 1    
      
 return @lResult    
end