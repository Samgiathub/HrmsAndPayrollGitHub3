-- exec prc_BindFamilyDetailsById
-- drop proc prc_BindFamilyDetailsById
CREATE procedure prc_BindFamilyDetailsById
@rEmpId int,
@rRowId int,
@rLimit varchar(50),
@rRowIndex int
as
begin
	DECLARE @lFamilyResult varchar(max) = ''
	select @lFamilyResult = @lFamilyResult + '<tr attrRowIndex="' + CONVERT(varchar,@rRowIndex) + '" attrEmpId="' + CONVERT(varchar,@rEmpId) + '" attrRowId="' + CONVERT(varchar,@rRowId) + '">
	<td>' + ISNULL(Name,'') + '</td><td>' + ISNULL(Relationship,'') + '</td><td>' + CONVERT(varchar,isnull(C_Age,0)) + '</td><td class="tdlimit">' + @rLimit + '</td></tr>'
	from T0090_EMP_CHILDRAN_DETAIL
	where Emp_ID = @rEmpId and Row_ID = @rRowId

	select isnull(@lFamilyResult,'') as FamilyDetails
end