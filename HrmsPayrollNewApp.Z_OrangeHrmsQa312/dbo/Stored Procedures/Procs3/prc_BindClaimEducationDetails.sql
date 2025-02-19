-- exec prc_BindClaimEducationDetails
-- drop proc prc_BindClaimEducationDetails
CREATE procedure [dbo].[prc_BindClaimEducationDetails]
@rClaimAppId int,
@rClaimAprId int = null,
@rType int = null
as
begin

	if isnull(@rType,1) = 1
	begin
		select ced_Id as Id,isnull(ced_RowId,0) as ChildId,isnull(ced_Name,'') as ChildName,isnull(ced_RelationId,0) as RelationId,isnull(ced_RelationName,0) as RelationName,isnull(ced_SchoolCollegeName,'') as SchoolCollegeName,
		isnull(ced_ClassName,'') as ClassName,isnull(ced_EducatinLevel,'') as EducationLevel,isnull(ced_RequestedAmount,0) as RequetedAmount,isnull(ced_QuarterId,0) as QuarterId,isnull(ced_Quarter,'') as Quarter
		from T0110_Claim_EducationDetails where ced_ClaimAppId = @rClaimAppId
	end
	else
	begin
		select caed_Id as Id,isnull(caed_RowId,0) as ChildId,isnull(caed_Name,'') as ChildName,isnull(caed_RelationId,0) as RelationId,isnull(caed_RelationName,0) as RelationName,isnull(caed_SchoolCollegeName,'') as SchoolCollegeName,
		isnull(caed_ClassName,'') as ClassName,isnull(caed_EducatinLevel,'') as EducationLevel,isnull(caed_RequestedAmount,0) as RequetedAmount,isnull(caed_QuarterId,0) as QuarterId,isnull(caed_Quarter,'') as Quarter
		from T0110_Claim_Approval_EducationDetails where caed_ClaimAppId = @rClaimAppId
	end
end