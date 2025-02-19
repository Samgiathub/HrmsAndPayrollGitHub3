-- exec prc_SaveApprovalInsuranceDetails
-- drop proc prc_SaveApprovalInsuranceDetails
CREATE procedure prc_SaveApprovalInsuranceDetails
@rClaimAppId int,
@rEmpId int,
@rPermissionStr varchar(max)
as
begin
	DECLARE @lXML XML,@lClaimId int
	SET @lXML = CAST(@rPermissionStr AS xml)

	select @lClaimId = Claim_ID from T0100_CLAIM_APPLICATION where Claim_App_ID = @rClaimAppId

	DECLARE @tbltmp TABLE(tid INT IDENTITY(1,1),t_VehicleNo varchar(200),t_PremiumDate varchar(50),t_PaidAmount float)
	INSERT INTO @tbltmp
	SELECT T.c.value('@VehicleNo','varchar(200)') AS VehicleNo,
	T.c.value('@PremiumDate','varchar(50)') AS PremiumDate,	
	T.c.value('@PaidAmount','float') AS PaidAmount
	FROM @lXML.nodes('/InsuranceDetails/Insurance') AS T(c)

	delete from T0110_Claim_Approval_Insurance_Details where cia_ClaimAppId = @rClaimAppId

	insert into T0110_Claim_Approval_Insurance_Details
	(
		cia_ClaimAppId,cia_EmpId,cia_ClaimId,cia_VehicleNo,cia_BillDate,cia_PaidAmount
	)
	select @rClaimAppId,@rEmpId,@lClaimId,t_VehicleNo,t_PremiumDate,t_PaidAmount from @tbltmp
end