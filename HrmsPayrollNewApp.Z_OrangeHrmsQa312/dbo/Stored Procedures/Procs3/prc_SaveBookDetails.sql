-- exec prc_SaveBookDetails
-- drop proc prc_SaveBookDetails
create procedure prc_SaveBookDetails
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

	delete from T0110_Claim_BookDetails where cb_AppId = @rClaimAppId and cb_EmpId = @rEmpId

	insert into T0110_Claim_BookDetails
	(
		[cb_AppId],[cb_ClaimId],[cb_EmpId],[cb_BookName],[cb_Subject],[cb_ActualPrice],[cb_DiscountedPrice],[cb_Amount]
	)
	select @rClaimAppId,@lClaimId,@rEmpId,t_BookName,t_Subject,t_ActualPrice,t_DiscountedPrice,t_ActualPaid from @tbltmp
end