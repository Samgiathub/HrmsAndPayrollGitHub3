-- exec prc_BindClaimBookDetails
-- drop proc prc_BindClaimBookDetails
CREATE procedure prc_BindClaimBookDetails
@rClaimAppId int,
@rClaimAprId int = null,
@rType int = null
as
begin
	if isnull(@rType,1) = 1
	begin
		select [cb_MainId] as Id,[cb_BookName] as BookName,[cb_Subject] as Subject,
		[cb_ActualPrice] as ActualPrice,[cb_DiscountedPrice] as DiscountedPrice,[cb_Amount] as ActualPaid
		from T0110_Claim_BookDetails where cb_AppId = @rClaimAppId
	end
	else
	begin
		select [cba_MainId] as Id,[cba_BookName] as BookName,[cba_Subject] as Subject,
		[cba_ActualPrice] as ActualPrice,[cba_DiscountedPrice] as DiscountedPrice,[cba_Amount] as ActualPaid
		from T0110_Claim_Approval_BookDetails where cba_AppId = @rClaimAppId
	end
end
