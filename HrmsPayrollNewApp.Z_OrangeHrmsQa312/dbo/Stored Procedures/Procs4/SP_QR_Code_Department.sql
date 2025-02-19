CREATE PROCEDURE [dbo].[SP_QR_Code_Department]
	@Cmp_ID int = 0
AS
BEGIN
	SET NOCOUNT ON;
	Select Dept_ID, Dept_Name from T0040_DEPARTMENT_MASTER where Cmp_ID = @Cmp_ID
END
