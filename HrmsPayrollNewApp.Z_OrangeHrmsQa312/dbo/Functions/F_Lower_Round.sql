
---10/3/2021 (EDIT BY MEHUL ) (Scaler-valued function WITH NOLOCK)---
CREATE FUNCTION [dbo].[F_Lower_Round]
(
	@Value Numeric(22,8),
	@cmp_Id Numeric(22,1)
)
RETURNS Numeric(18,2)
AS
BEGIN
	Declare @Round_Value as Numeric(18,2)
	Declare @setting as numeric(18,0)
	set @setting=0
	select @setting=Setting_Value from T0040_SETTING WITH (NOLOCK) where Setting_Name ='Lower Round in leave Balance' and Cmp_ID =@cmp_id
	if (@setting=1)
	begin
	Set @Round_Value = FLOOR(@Value * 2) / 2
	end
	else
	BEGIN
		--Set @Round_Value = FLOOR(@Value * 4) / 4
		Set @Round_Value = @Value
	END

	RETURN @Round_Value

END

