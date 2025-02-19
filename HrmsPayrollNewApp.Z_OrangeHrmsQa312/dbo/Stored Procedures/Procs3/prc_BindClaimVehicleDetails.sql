-- exec prc_BindClaimVehicleDetails
-- drop proc prc_BindClaimVehicleDetails
CREATE procedure [dbo].[prc_BindClaimVehicleDetails]
@rClaimAppId int,
@rClaimAprId int = null,
@rType int = null
as
begin
	if isnull(@rType,1) = 1
	begin
		select ci_Id as Id,isnull(ci_VehicleNo,'') as VehicleNo,isnull(convert(varchar,ci_BillDate,103),'') as PremiumDate,isnull(ci_PaidAmount,0) as PaidAmount
		from T0110_Claim_Insurance_Details where ci_ClaimAppId = @rClaimAppId
	end
	else
	begin
	
		select cia_Id as Id,isnull(cia_VehicleNo,'') as VehicleNo,isnull(convert(varchar,cia_BillDate,103),'') as PremiumDate,isnull(cia_PaidAmount,0) as PaidAmount
		from T0110_Claim_Approval_Insurance_Details where cia_ClaimAppId = @rClaimAppId 
	end
end