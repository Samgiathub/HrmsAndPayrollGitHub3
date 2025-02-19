-- exec prc_SaveApprovalPruchaseDetails
-- drop proc prc_SaveApprovalPruchaseDetails
create procedure prc_SaveApprovalPruchaseDetails
@rClaimAppId int,
@rEmpId int,
@rPermissionStr varchar(max)
as
begin
	DECLARE @lXML XML,@lClaimId int
	SET @lXML = CAST(@rPermissionStr AS xml)

	select @lClaimId = Claim_ID from T0100_CLAIM_APPLICATION where Claim_App_ID = @rClaimAppId

	DECLARE @tbltmp TABLE(tid INT IDENTITY(1,1),t_ItemName varchar(200),t_SerialNo varchar(50),t_VendorName varchar(50),t_BillNo varchar(50),t_BillDate varchar(50),t_BillAmount float,t_RequetedAmount float)
	INSERT INTO @tbltmp
	SELECT T.c.value('@ItemName','varchar(200)') AS ItemName,
	T.c.value('@SerialNo','varchar(50)') AS SerialNo,
	T.c.value('@VendorName','varchar(50)') AS VendorName,
	T.c.value('@BillNo','varchar(100)') AS BillNo,
	T.c.value('@BillDate','varchar(50)') AS BillDate,
	T.c.value('@BillAmount','float') AS BillAmount,
	T.c.value('@RequestedAmount','float') AS RequestedAmount	
	FROM @lXML.nodes('/PurchaseDetails/Purchase') AS T(c)

	delete from T0110_Claim_Approval_Purchase_Details where cpa_ClaimAppId = @rClaimAppId

	insert into T0110_Claim_Approval_Purchase_Details
	(
		cpa_ClaimAppId,cpa_EmpId,cpa_ClaimId,cpa_ItemName,cpa_SerialNo,cpa_VendorName,cpa_BillNo,cpa_BillDate,cpa_BillAmount,cpa_RequestedAmount
	)
	select @rClaimAppId,@rEmpId,@lClaimId,t_ItemName,t_SerialNo,t_VendorName,t_BillNo,t_BillDate,t_BillAmount,t_RequetedAmount from @tbltmp
end