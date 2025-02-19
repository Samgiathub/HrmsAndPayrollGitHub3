

-- =============================================
-- Author:		NIMESH PARMAR
-- Create date: 19-Jul-2017
-- Description:	To get auto shift id
---10/3/2021 (EDIT BY MEHUL ) (Scaler-valued function WITH NOLOCK)---
-- =============================================
CREATE FUNCTION [dbo].[fn_get_AutoShiftID] 
(
	@Emp_ID			NUMERIC,
	@In_Date_Time	DATETIME
)
RETURNS NUMERIC
AS
BEGIN
	DECLARE @SHIFT_ID	NUMERIC
	DECLARE @Cmp_Id		NUMERIC

	SELECT @Cmp_Id = Cmp_ID FROM T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID=@Emp_ID
	SET @SHIFT_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_Id, @Emp_ID, @In_Date_Time);

	IF EXISTS(SELECT 1 FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Shift_ID=@Shift_ID AND Inc_Auto_Shift=1)
		AND @In_Date_Time IS NOT NULL
		BEGIN			
			SELECT	TOP 1 
					@Shift_ID = ISNULL(SHIFT_ID,@Shift_ID)
			FROM	T0040_SHIFT_MASTER T WITH (NOLOCK)
			WHERE	Inc_Auto_Shift=1
			ORDER BY ABS(DATEDIFF(S, @In_Date_Time, CONVERT(DATETIME,CONVERT(CHAR(10),@In_Date_Time,103) + ' ' + SHIFT_ST_TIME, 103))) ASC
		END

	-- Return the result of the function
	RETURN @SHIFT_ID

END

