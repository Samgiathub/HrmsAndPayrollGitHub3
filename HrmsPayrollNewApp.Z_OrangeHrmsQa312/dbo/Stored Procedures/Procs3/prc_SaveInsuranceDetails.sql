-- exec prc_SaveInsuranceDetails
-- drop proc prc_SaveInsuranceDetails
CREATE procedure prc_SaveInsuranceDetails
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

	delete from T0110_Claim_Insurance_Details where ci_ClaimAppId = @rClaimAppId

	insert into T0110_Claim_Insurance_Details
	(
		ci_ClaimAppId,ci_EmpId,ci_ClaimId,ci_VehicleNo,ci_BillDate,ci_PaidAmount
	)
	select @rClaimAppId,@rEmpId,@lClaimId,t_VehicleNo,t_PremiumDate,t_PaidAmount from @tbltmp
end