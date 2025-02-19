-- exec prc_BindClaimEntertainedDetails
-- drop proc prc_BindClaimEntertainedDetails
CREATE procedure prc_BindClaimEntertainedDetails
@rClaimAppId int,
@rClaimAprId int = null,
@rType int = null
as
begin
	if isnull(@rType,1) = 1
	begin
		select ec_Id as Id,convert(varchar,ec_Date,103) as eDate,ec_NoOfEntertained as PersonEntertained,
		ec_Amount as RequestedAmount
		from T0110_Claim_Entertainment where ec_ClaimAppId = @rClaimAppId	
	end
	else
	begin
		select eca_Id as Id,convert(varchar,eca_Date,103) as eDate,eca_NoOfEntertained as PersonEntertained,
		eca_Amount as RequestedAmount
		from T0110_Claim_Approval_Entertainment where eca_ClaimAppId = @rClaimAppId
	end
end