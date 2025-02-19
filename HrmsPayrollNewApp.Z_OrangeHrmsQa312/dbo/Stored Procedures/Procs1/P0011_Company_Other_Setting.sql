


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0011_Company_Other_Setting]
	@Cmp_ID Numeric,
	@Exit_Terms_Condition Varchar(max)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF Not Exists(Select 1 From T0011_Company_Other_Setting WITH (NOLOCK) Where Cmp_ID = @Cmp_ID)
		Begin
			Insert into T0011_Company_Other_Setting(Cmp_ID,Exit_Terms_Condition)
			Values(@Cmp_ID,@Exit_Terms_Condition)
		End
	Else
		Begin
			Update T0011_Company_Other_Setting
				Set Exit_Terms_Condition = @Exit_Terms_Condition
			Where Cmp_ID = @Cmp_ID
		End
END

