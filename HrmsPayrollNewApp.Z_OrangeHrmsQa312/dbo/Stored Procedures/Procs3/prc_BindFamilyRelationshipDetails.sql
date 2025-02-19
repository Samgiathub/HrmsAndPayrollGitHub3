-- exec prc_BindFamilyRelationshipDetails
-- drop proc prc_BindFamilyRelationshipDetails
CREATE procedure [dbo].[prc_BindFamilyRelationshipDetails]
@rEmpId int,
@rCmpId int
as
begin
	declare @lResult varchar(max) = ''
	select @lResult = '<option value="0"> -- Select -- </option>'
	select @lResult = @lResult + '<option value="' + convert(varchar,Relationship_ID) + '">' + isnull(Relationship,'') + '</option>'
	from T0040_Relationship_Master where Cmp_Id = @rCmpId AND Relationship NOT IN ('Father','Mother','Brother','Sister','Spouse','Self')

	select @lResult as Result
end