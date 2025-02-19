-- exec prc_SaveBookDetailsApproval
-- drop proc prc_SaveBookDetailsApproval
create procedure prc_SaveBookDetailsApproval
@rClaimAppId int,
@rEmpId int,
@rPermissionStr varchar(max)
as
begin
	DECLARE @lXML XML,@lClaimId int
	SET @lXML = CAST(@rPermissionStr AS xml)

	select @lClaimId = Claim_ID from T0100_CLAIM_APPLICATION where Claim_App_ID = @rClaimAppId

	DECLARE @tbltmp TABLE(tid INT IDENTITY(1,1),t_BookName varchar(100),t_Subject varchar(50),t_ActualPrice float,t_DiscountedPrice float,t_ActualPaid float)
	INSERT INTO @tbltmp
	SELECT T.c.value('@BookName','varchar(100)') AS BookName,
	T.c.value('@Subject','varchar(50)') AS Subject,	
	T.c.value('@ActualPrice','float') AS ActualPrice,
	T.c.value('@DiscountedPrice','float') AS DiscountedPrice,
	T.c.value('@ActualPaid','float') AS ActualPaid
	FROM @lXML.nodes('/BookDetails/Books') AS T(c)

	delete from T0110_Claim_Approval_BookDetails where cba_AppId = @rClaimAppId and cba_EmpId = @rEmpId

	insert into T0110_Claim_Approval_BookDetails
	(
		[cba_AppId],[cba_ClaimId],[cba_EmpId],[cba_BookName],[cba_Subject],[cba_ActualPrice],[cba_DiscountedPrice],[cba_Amount]
	)
	select @rClaimAppId,@lClaimId,@rEmpId,t_BookName,t_Subject,t_ActualPrice,t_DiscountedPrice,t_ActualPaid from @tbltmp
end