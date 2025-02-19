CREATE PROCEDURE [dbo].[SP_QR_Code_POS]
	@Cmp_ID int = 0
AS
BEGIN
	SET NOCOUNT ON;
	Select POS_ID, POS_Name from POS_Master where Cmp_ID = @Cmp_ID
END
