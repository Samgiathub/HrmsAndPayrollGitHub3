
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Uniform_History]
	@Cmp_ID numeric(18,0),
	@Uni_Name Varchar(200)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


    SELECT     UMD.Tran_ID, UM.Uni_ID, UM.Uni_Name, UMD.Uni_Effective_Date, UMD.Uni_Rate, UMD.Uni_Deduct_Installment, UMD.Uni_Refund_Installment
    FROM         dbo.T0040_Uniform_Master AS UM WITH (NOLOCK) INNER JOIN
             dbo.T0050_Uniform_Master_Detail AS UMD WITH (NOLOCK) ON UM.Uni_ID = UMD.Uni_ID
   Where Upper(UM.Uni_Name) = UPPER(@Uni_Name) and UM.Cmp_Id = @Cmp_ID
END
