-- exec prc_BindClaimPurchaseDetails
-- drop proc prc_BindClaimPurchaseDetails
CREATE procedure prc_BindClaimPurchaseDetails
@rClaimAppId int,
@rClaimAprId int = null,
@rType int = null
as
begin
	if isnull(@rType,1) = 1
	begin
		select cp_Id as Id,isnull(cp_ItemName,'') as ItemName,isnull(cp_SerialNo,'') as SerialNo,isnull(cp_VendorName,'') as VendorName,isnull(cp_BillNo,'') as BillNo,
		isnull(convert(varchar,cp_BillDate,103),'') as BillDate,isnull(cp_BillAmount,0) as BillAmount,isnull(cp_RequestedAmount,0) as RequestedAmount
		from T0110_Claim_Purchase_Details where cp_ClaimAppId = @rClaimAppId
	end
	else
	begin
		select cpa_Id as Id,isnull(cpa_ItemName,'') as ItemName,isnull(cpa_SerialNo,'') as SerialNo,isnull(cpa_VendorName,'') as VendorName,isnull(cpa_BillNo,'') as BillNo,
		isnull(convert(varchar,cpa_BillDate,103),'') as BillDate,isnull(cpa_BillAmount,0) as BillAmount,isnull(cpa_RequestedAmount,0) as RequestedAmount
		from T0110_Claim_Approval_Purchase_Details where cpa_ClaimAppId = @rClaimAppId
	end
end