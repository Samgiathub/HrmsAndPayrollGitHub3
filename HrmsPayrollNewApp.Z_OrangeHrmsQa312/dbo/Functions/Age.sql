

CREATE FUNCTION [DBO].[Age](@DAYOFBIRTH DATETIME, @TODAY DATETIME,@GETDMY VARCHAR ='')
   RETURNS varchar(100)
AS

Begin
DECLARE @thisYearBirthDay datetime
DECLARE @years int, @months int, @days int

Declare @Value as varchar(50)

set @thisYearBirthDay = DATEADD(year, DATEDIFF(year, @dayOfBirth, @today), @dayOfBirth)
set @years = DATEDIFF(year, @dayOfBirth, @today) - (CASE WHEN @thisYearBirthDay > @today THEN 1 ELSE 0 END)
set @months = MONTH(@today - @thisYearBirthDay) - 1
set @days = DAY(@today - @thisYearBirthDay) - 1


if @GetDMY = '' 
	begin
		set @Value = cast(@years as varchar(2)) + ' years,' + cast(@months as varchar(2)) + ' months,' + cast(@days as varchar(3)) + ' days'
	end
else if @GetDMY = 'D'
	begin
		set @Value =case when @days <10 then '0'+ cast(@days as varchar(3)) else cast(@days as varchar(3)) end
	end
else if @GetDMY = 'M'
	begin
		set @Value =case when @months <10 then '0'+ cast(@months as varchar(3)) else cast(@months as varchar(3)) end
	end
else if @GetDMY = 'Y'
	begin
		set @Value= case when @years <10 then '0'+ cast(@years as varchar(3)) else cast(@years as varchar(3)) end
	end	
	
	return  @Value
end

