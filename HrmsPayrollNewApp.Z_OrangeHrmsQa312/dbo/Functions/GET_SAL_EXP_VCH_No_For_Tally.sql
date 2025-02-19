



---10/3/2021 (EDIT BY MEHUL ) (Scaler-valued function WITH NOLOCK)---
CREATE  FUNCTION [dbo].[GET_SAL_EXP_VCH_No_For_Tally]
	(
		@sal_exp_id AS NUMERIC =20
	)
RETURNS Varchar(8)
AS

BEGIN
	
	Declare @Vch_No As Numeric
	Declare @Vch_Char As Varchar(10)

	Select @Vch_No = Isnull(Max(Vch_No),0) 
	From T9999_Salary_Export WITH (NOLOCK) Where sal_exp_id = @sal_exp_id

	Set @Vch_Char = Cast(@Vch_No AS Varchar(8))

	While Len(@Vch_Char) < 8
	Begin
		Set @Vch_Char = '0' + @Vch_Char
	End

	RETURN @Vch_Char
END




