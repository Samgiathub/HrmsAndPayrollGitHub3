-- exec prc_BindGradeDropdown
-- drop proc prc_BindGradeDropdown
CREATE procedure [dbo].[prc_BindGradeDropdown]
@rCmpId int
as
begin
	declare @lResult varchar(max) = ''
	select @lResult = @lResult + '<option value="0"> -- SELECT -- </option>'
	select @lResult = @lResult + '<option value="' + CONVERT(varchar,Grd_ID) + '">' + isnull(Grd_Name,'') + '</option>'
	from T0040_GRADE_MASTER where Cmp_ID = @rCmpId

	select @lResult as Result
end