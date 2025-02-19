-- exec prc_BindFamilyBindChildreanDetails
-- drop proc prc_BindFamilyBindChildreanDetails
create procedure prc_BindFamilyBindChildreanDetails
@rEmpId int,
@rRelationShipId int,
@rCmpId int
as
begin
	declare @lResult varchar(max) = ''
	select @lResult = '<option value="0"> -- Select -- </option>'
	select @lResult = @lResult + '<option value="' + convert(varchar,Row_ID) + '">' + isnull(Name,'') + '</option>'
	from T0090_EMP_CHILDRAN_DETAIL EC
	inner join T0040_Relationship_Master RM on EC.Relationship = RM.Relationship
	where EC.Cmp_ID = @rCmpId and Emp_ID = @rEmpId and Relationship_ID = @rRelationShipId

	select @lResult as Result
end