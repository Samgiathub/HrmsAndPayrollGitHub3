-- select * from dbo.fnc_BindGrade()
-- drop function dbo.fnc_BindGrade
create function [dbo].[fnc_BindGrade](@rCmpId int,@rGradeId INT)
returns varchar(max)
as
begin
	declare @lResult varchar(max) = ''
	select @lResult = @lResult + '<option value="0"> -- ALL -- </option>'
	select @lResult = @lResult + '<option value="' + CONVERT(varchar,Grd_ID) + '" ' + case when @rGradeId = Grd_ID then 'selected="selected"' else '' end + '>' + isnull(Grd_Name,'') + '</option>'
	from T0040_GRADE_MASTER where Cmp_ID = @rCmpId
	
	return @lResult
end