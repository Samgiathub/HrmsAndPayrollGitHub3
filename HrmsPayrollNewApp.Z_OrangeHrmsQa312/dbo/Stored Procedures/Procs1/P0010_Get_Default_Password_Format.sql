

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0010_Get_Default_Password_Format] 
	@Cmp_ID Numeric(18,0)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
    -- Insert statements for procedure here
	SELECT * From T0010_Default_Password_Format TDPF WITH (NOLOCK)
	Inner JOIN(
				SELECT MAX(EffectiveDate) as Effective_Date From T0010_Default_Password_Format WITH (NOLOCK)
				Where EffectiveDate <= GETDATE() AND Cmp_ID = @Cmp_ID
			  ) as qry
	ON TDPF.EffectiveDate = qry.Effective_Date
END

