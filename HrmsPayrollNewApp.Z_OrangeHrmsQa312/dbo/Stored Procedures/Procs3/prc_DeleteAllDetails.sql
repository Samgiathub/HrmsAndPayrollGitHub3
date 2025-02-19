-- exec prc_DeleteAllDetails
-- drop proc prc_DeleteAllDetails
create procedure prc_DeleteAllDetails
@rClaimAppIds varchar(max)
as
begin
	delete from T0110_Claim_Approval_BookDetails where cba_AppId in (select data from dbo.Split(@rClaimAppIds,',') where Data <> '')
	delete from T0110_Claim_BookDetails where cb_AppId in (select data from dbo.Split(@rClaimAppIds,',') where Data <> '')

	delete from T0110_Claim_Approval_EducationDetails where caed_ClaimAppId in (select data from dbo.Split(@rClaimAppIds,',') where Data <> '')
	delete from T0110_Claim_EducationDetails where ced_ClaimAppId in (select data from dbo.Split(@rClaimAppIds,',') where Data <> '')

	delete from T0110_Claim_Approval_Entertainment where eca_ClaimAppId in (select data from dbo.Split(@rClaimAppIds,',') where Data <> '')
	delete from T0110_Claim_Entertainment where ec_ClaimAppId in (select data from dbo.Split(@rClaimAppIds,',') where Data <> '')

	delete from T0110_Claim_Approval_FamilyDetails where Claim_AppId in (select data from dbo.Split(@rClaimAppIds,',') where Data <> '')
	delete from T0110_Claim_FamilyDetails where Claim_AppId in (select data from dbo.Split(@rClaimAppIds,',') where Data <> '')

	delete from T0110_Claim_Approval_Purchase_Details where cpa_ClaimAppId in (select data from dbo.Split(@rClaimAppIds,',') where Data <> '')
	delete from T0110_Claim_Purchase_Details where cp_ClaimAppId in (select data from dbo.Split(@rClaimAppIds,',') where Data <> '')
end