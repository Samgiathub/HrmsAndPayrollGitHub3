-- exec prc_SaveApprovalEducationDetails
-- drop proc prc_SaveApprovalEducationDetails
CREATE procedure [dbo].[prc_SaveApprovalEducationDetails]
@rClaimAppId int,
@rEmpId int,
@rPermissionStr varchar(max)
as
begin
	DECLARE @lXML XML,@lClaimId int
	SET @lXML = CAST(@rPermissionStr AS xml)

	select @lClaimId = Claim_ID from T0100_CLAIM_APPLICATION where Claim_App_ID = @rClaimAppId

	DECLARE @tbltmp TABLE
	(
		tid INT IDENTITY(1,1),t_RowId int,t_Name varchar(100),t_RelationId int,t_RelationName varchar(100),t_SchoolCollegeName varchar(300),t_ClassName varchar(300),t_EducationLevel varchar(100),
		t_RequetedAmount float,t_QuarterId int,t_Quarter varchar(50)
	)
	INSERT INTO @tbltmp
	SELECT T.c.value('@RowId','int') AS RowId,
	T.c.value('@Name','varchar(100)') AS Name,	
	T.c.value('@RelationId','int') AS RelationId,
	T.c.value('@RelationName','varchar(100)') AS RelationName,
	T.c.value('@SchoolCollegeName','varchar(300)') AS SchoolCollegeName,
	T.c.value('@ClassName','varchar(300)') AS ClassName,
	T.c.value('@EducationLevel','varchar(100)') AS EducationLevel,
	T.c.value('@RequetedAmount','float') AS RequetedAmount,
	T.c.value('@QuarterId','int') AS QuarterId,
	T.c.value('@Quarter','varchar(50)') AS Quarter
	FROM @lXML.nodes('/EducationDetails/Education') AS T(c)

	delete from T0110_Claim_Approval_EducationDetails where caed_ClaimAppId = @rClaimAppId

	declare @lcnt int
	select @lcnt = count(1) from @tbltmp
	if @lcnt > 0
	begin
	insert into T0110_Claim_Approval_EducationDetails
	(
		caed_ClaimAppId,caed_EmpId,caed_RowId,caed_Name,caed_RelationId,caed_RelationName,caed_SchoolCollegeName,caed_ClassName,caed_EducatinLevel,caed_RequestedAmount,caed_QuarterId,caed_Quarter
	)
	select @rClaimAppId,@rEmpId,t_RowId,t_Name,t_RelationId,t_RelationName,t_SchoolCollegeName,t_ClassName,t_EducationLevel,t_RequetedAmount,t_QuarterId,t_Quarter from @tbltmp
	end
	else
	begin
		insert into T0110_Claim_Approval_EducationDetails
	(
		caed_ClaimAppId,caed_EmpId,caed_RowId,caed_Name,caed_RelationId,caed_RelationName,caed_SchoolCollegeName,caed_ClassName,caed_EducatinLevel,caed_RequestedAmount,caed_QuarterId,caed_Quarter
	)
	select @rClaimAppId,@rEmpId,ced_RowId,ced_Name,ced_RelationId,ced_RelationName,ced_SchoolCollegeName,ced_ClassName,ced_EducatinLevel,ced_RequestedAmount,ced_QuarterId,ced_Quarter
	from T0110_Claim_EducationDetails
	end
end