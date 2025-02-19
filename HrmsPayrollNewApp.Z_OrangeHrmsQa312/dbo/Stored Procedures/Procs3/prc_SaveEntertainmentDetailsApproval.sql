-- exec prc_SaveEntertainmentDetailsApproval
-- drop proc prc_SaveEntertainmentDetailsApproval
create procedure prc_SaveEntertainmentDetailsApproval
@rClaimAppId int,
@rEmpId int,
@rPermissionStr varchar(max)
as
begin
	DECLARE @lXML XML,@lClaimId int
	SET @lXML = CAST(@rPermissionStr AS xml)

	select @lClaimId = Claim_ID from T0100_CLAIM_APPLICATION where Claim_App_ID = @rClaimAppId

	DECLARE @tbltmp TABLE(tid INT IDENTITY(1,1),t_Date varchar(100),t_Person varchar(max),t_RequestedAmount float)
	INSERT INTO @tbltmp
	SELECT T.c.value('@Date','varchar(100)') AS Date,
	T.c.value('@Person','varchar(max)') AS Person,	
	T.c.value('@RequestedAmount','float') AS RequestedAmount	
	FROM @lXML.nodes('/Entertainments/Entertain') AS T(c)

	delete from T0110_Claim_Approval_Entertainment where eca_ClaimAppId = @rClaimAppId

	insert into T0110_Claim_Approval_Entertainment
	(
		eca_ClaimAppId,eca_ClaimId,eca_Date,eca_NoOfEntertained,eca_Amount
	)
	select @rClaimAppId,@lClaimId,t_Date,t_Person,t_RequestedAmount from @tbltmp
end