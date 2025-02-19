CREATE PROCEDURE SP_Mobile_HRMS_ADMIN_SETTINGS
	@Cmp_ID INT
AS
BEGIN
	------------------------ CLAIM -------------------------------

	DECLARE @SINGLE_CLAIM_Enable_Month INT
	DECLARE @ALLOW_SINGLE_CLAIM INT

	SELECT @SINGLE_CLAIM_Enable_Month = ISNULL(Setting_Value,0) FROM T0040_SETTING WHERE SETTING_NAME = 'Enable Month End Date Selection in Claim' and Cmp_ID = @Cmp_ID
	SELECT @ALLOW_SINGLE_CLAIM = ISNULL(Setting_Value,0) FROM T0040_SETTING WHERE SETTING_NAME = 'Single Claim Type allow in single Claim Application' and Cmp_ID = @Cmp_ID

	SELECT ISnull(@SINGLE_CLAIM_Enable_Month,0) AS SINGLE_CLAIM_Enable_Month,ISnull(@ALLOW_SINGLE_CLAIM,0) AS ALLOW_SINGLE_CLAIM

END
