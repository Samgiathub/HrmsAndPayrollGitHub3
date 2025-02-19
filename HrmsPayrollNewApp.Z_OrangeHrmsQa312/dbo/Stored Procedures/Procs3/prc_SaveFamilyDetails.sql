-- exec prc_SaveFamilyDetails
-- drop proc prc_SaveFamilyDetails
CREATE procedure prc_SaveFamilyDetails
@rClaimAppId numeric,
@rEmpId numeric,
@rPermissionStr varchar(max)
as
begin
	DECLARE @lXML XML,@lClaimId int
	SET @lXML = CAST(@rPermissionStr AS xml)

	select @lClaimId = Claim_ID from T0100_CLAIM_APPLICATION where Claim_App_ID = @rClaimAppId

	DECLARE @tbltmp TABLE
	(
		tid INT IDENTITY(1,1),t_FamilyMemberId INT,t_FamilyMemberName varchar(200),t_Relation varchar(50),t_Age float,t_Limit float,t_BirthDate varchar(50),t_BillNo varchar(50),t_BillDate varchar(50),t_BillAmount float,t_Amount float
	)
	INSERT INTO @tbltmp
	SELECT T.c.value('@FamilyMemberId','INT') AS FamilyMemberId,
	T.c.value('@FamilyMemberName','varchar(200)') AS FamilyMemberName,
	T.c.value('@Relation','varchar(50)') AS Relation,
	T.c.value('@Age','float') AS Age,
	T.c.value('@Limit','float') AS Limit,	
	T.c.value('@BirthDate','varchar(50)') AS BirthDate,
	T.c.value('@BillNo','varchar(50)') AS BillNo,
	case when  T.c.value('@BillDate','varchar(50)') = '' then null else T.c.value('@BillDate','varchar(50)') end AS BillDate,
	case when T.c.value('@BillAmount','float') = '' then 0 else T.c.value('@BillAmount','float') end AS BillAmount,
	T.c.value('@Amount','float') AS Amount
	FROM @lXML.nodes('/FamilyDetails/Family') AS T(c)

	delete from T0110_Claim_FamilyDetails where Claim_AppId = @rClaimAppId and Claim_EmpId = @rEmpId

	insert into T0110_Claim_FamilyDetails
	(
		Claim_FamilyMemberId,Claim_AppId,ClaimId,Claim_EmpId,Claim_FamilyMemberName,Claim_FamilyRelation,Claim_Age,Claim_Limit,Claim_Amount,cf_BirthDate,cf_BillNumber,cf_BillDate,cf_BillAmount
	)
	select t_FamilyMemberId,@rClaimAppId,@lClaimId,@rEmpId,t_FamilyMemberName,t_Relation,t_Age,t_Limit,t_Amount,t_BirthDate,t_BillNo,t_BillDate,t_BillAmount from @tbltmp
end