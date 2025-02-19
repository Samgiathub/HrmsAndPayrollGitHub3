-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE P0045_Claim_FNF_Deduction_Slab_Delete
	@Cmp_ID Numeric(18,0),
	@Claim_ID Numeric(18,0)
AS
BEGIN
	
	SET NOCOUNT ON;

    Delete From T0045_Claim_FNF_Deduction_Slab where Claim_Id = @Claim_ID and Cmp_Id = @Cmp_ID
END
