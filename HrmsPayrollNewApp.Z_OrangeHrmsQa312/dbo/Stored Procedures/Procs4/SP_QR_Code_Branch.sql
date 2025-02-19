CREATE PROCEDURE SP_QR_Code_Branch
	@Cmp_ID int = 0
AS
BEGIN
	SET NOCOUNT ON;
	Select Branch_ID, Branch_Name from T0030_BRANCH_MASTER where Cmp_ID = @Cmp_ID
END
