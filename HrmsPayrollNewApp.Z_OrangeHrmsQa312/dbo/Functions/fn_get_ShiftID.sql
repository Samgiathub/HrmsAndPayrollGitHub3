

---10/3/2021 (EDIT BY MEHUL ) (Scaler-valued function WITH NOLOCK)---
CREATE FUNCTION [dbo].[fn_get_ShiftID] 
(
	@Shift_Name		varchar(100),
	@Cmp_ID			int
)
RETURNS NUMERIC
AS
BEGIN
	DECLARE @SHIFT_ID	NUMERIC
	SET @SHIFT_ID = 0
	
	SELECT	@SHIFT_ID = ISNULL(SHIFT_ID,0)
	FROM	T0040_SHIFT_MASTER WITH (NOLOCK)
	WHERE	SHIFT_NAME = @Shift_Name AND CMP_ID = @CMP_ID
	
	-- Return the result of the function
	RETURN @SHIFT_ID

END

