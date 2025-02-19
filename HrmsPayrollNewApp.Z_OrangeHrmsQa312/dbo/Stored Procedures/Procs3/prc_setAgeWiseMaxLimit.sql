-- exec prc_setAgeWiseMaxLimit
-- drop proc prc_setAgeWiseMaxLimit
CREATE procedure [dbo].[prc_setAgeWiseMaxLimit]
@rClaimId int,
@rXMLStr varchar(max)
as
begin
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;

	DECLARE @lXML XML
	SET @lXML = CAST(@rXMLStr AS xml)
	
	DELETE FROM T0041_Claim_Maxlimit_Age where Claim_id = @rClaimId
	
	INSERT INTO T0041_Claim_Maxlimit_Age
	(
		Claim_Id,Age_Min,Age_Max,Age_Amount
	)
	SELECT @rClaimId,T.c.value('@MinAge','float') AS MinAge,
	T.c.value('@MaxAge','float') AS MaxAge,
	T.c.value('@Amount','FLOAT') AS Amount
	FROM @lXML.nodes('/Permissions/Permission') AS T(c)
end