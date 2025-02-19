-- exec prc_BindClaimFamilyMembers 1154,0,1
-- drop proc prc_BindClaimFamilyMembers
CREATE procedure [dbo].[prc_BindClaimFamilyMembers]
@rClaimAppId int,
@rClaimAprId int = null,
@rType int = null
as
begin
	declare @lClaimId int,@lTotalAmount float = 0,@lFlag int = 0
	select @lClaimId = Claim_ID from T0100_CLAIM_APPLICATION where Claim_App_ID = @rClaimAppId

	if exists (select 1 from T0040_CLAIM_MASTER where Claim_ID = @lClaimId and Claim_For = 2)
	begin
		select @lTotalAmount = @lTotalAmount + Claim_App_Amount,@lFlag = 1 from T0100_CLAIM_APPLICATION where Claim_App_ID = @rClaimAppId		
	end
	else
	begin
		select @lTotalAmount = 0,@lFlag = 0
	end


	if isnull(@rType,1) = 1
	begin
		if @lFlag = 1
		begin
			select @lTotalAmount = @lTotalAmount + t.Amt from
			(
				select sum(Claim_Amount) as Amt from T0110_Claim_FamilyDetails where claim_AppId = @rClaimAppId
			) t
		end

		select isnull(Claim_FamilyMemberId,0) as Id,isnull(Claim_FamilyMemberName,'') as Title,isnull(Claim_FamilyRelation,'') as Relation,isnull(Claim_Age,0) as Age,
		isnull(Claim_Limit,0) as Limit,isnull(convert(varchar,Claim_Amount),'') as Amount,isnull(convert(varchar,cf_BirthDate,103),'') as BirthDate,isnull(cf_BillNumber,'') as BillNo,
		isnull(convert(varchar,cf_BillDate,103),'') as BillDate,isnull(convert(varchar,cf_BillAmount),'') as BillAmount,isnull(@lTotalAmount,0) as TotalAmount,isnull(@lFlag,0) as Flag
		from T0110_Claim_FamilyDetails where Claim_AppId = @rClaimAppId		
	end
	else
	
	begin
		if @lFlag = 1
		begin
		
			select @lTotalAmount = @lTotalAmount + t.Amt from
			(
				select sum(Claim_Amount) as Amt from T0110_Claim_Approval_FamilyDetails where claim_AppId = @rClaimAppId
			) t
		end

		select isnull(Claim_FamilyMemberId,0) as Id,isnull(Claim_FamilyMemberName,'') as Title,isnull(Claim_FamilyRelation,'') as Relation,isnull(Claim_Age,0) as Age,
		isnull(Claim_Limit,0) as Limit,isnull(convert(varchar,Claim_Amount),'') as Amount,isnull(convert(varchar,cfa_BirthDate,103),'') as BirthDate,isnull(cfa_BillNumber,'') as BillNo,
		isnull(convert(varchar,cfa_BillDate,103),'') as BillDate,isnull(convert(varchar,cfa_BillAmount),'') as BillAmount,isnull(@lTotalAmount,0) as TotalAmount,isnull(@lFlag,0) as Flag
		from T0110_Claim_Approval_FamilyDetails where Claim_AppId = @rClaimAppId --and Claim_AprId = @rClaimAprId
	end
end