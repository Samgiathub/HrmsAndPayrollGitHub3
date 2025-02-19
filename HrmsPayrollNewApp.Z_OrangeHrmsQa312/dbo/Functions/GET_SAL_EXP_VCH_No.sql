
---10/3/2021 (EDIT BY MEHUL ) (Scaler-valued function WITH NOLOCK)---
CREATE FUNCTION [dbo].[GET_SAL_EXP_VCH_No]
	(
		@Cmp_Id AS NUMERIC
	)
RETURNS Varchar(3)
AS

BEGIN
	
	Declare @Vch_No As Numeric
	Declare @Vch_Char As Varchar(10)

	Select @Vch_No = Isnull(Max(Vch_No),0) + 1
	From T9999_Salary_Export WITH (NOLOCK) Where Cmp_Id = @Cmp_Id

	Set @Vch_Char = Cast(@Vch_No AS Varchar(3))

	While Len(@Vch_Char) < 3
	Begin
		Set @Vch_Char = '0' + @Vch_Char
	End

	RETURN @Vch_Char
END




