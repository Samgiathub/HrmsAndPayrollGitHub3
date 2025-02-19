

-- =============================================
-- Author:		Nimesh
-- Create date: 20 April, 2015
-- Description:	To retrieve the shift id from Shift Rotation Master if assigned otherwise it will be taken from Employee Shift Detail table.
---10/3/2021 (EDIT BY MEHUL ) (Scaler-valued function WITH NOLOCK)---
-- =============================================
CREATE FUNCTION [dbo].[fn_get_Shift_From_Monthly_Rotation]
(
	@Cmp_ID numeric(18,0),
	@Emp_ID numeric(18,0),
	@For_Date DateTime
)
RETURNS numeric(18,0)
AS
BEGIN
	
	DECLARE @Shift_ID Numeric(18,0);

	DECLARE @HasRotation bit;
	SET @HasRotation = 0;
	
	SET @For_Date = Convert(DateTime, Convert(Char(10), @For_Date, 103), 103);

	--Modified by Nimesh 14 April 2015
	--To Fetch Record from Employee Shift Rotation Master Table.
	IF EXISTS(Select 1 FROM dbo.T0050_Emp_Monthly_Shift_Rotation R WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND R.Effective_Date <= @For_Date )
		BEGIN
			Select TOP 1 @Shift_ID=SR.ShiftID
			From T0050_Emp_Monthly_Shift_Rotation ER WITH (NOLOCK),
				(SELECT Cmp_ID,Tran_ID,DayName,ShiftID FROM 
					(SELECT Cmp_ID,Tran_ID,Day1, Day2, Day3, Day4, Day5,Day6,Day7,Day8,Day9,Day10,Day11, Day12, Day13, Day14, Day15,Day16,Day17,Day18,Day19,Day20,Day21, Day22, Day23, Day24, Day25,Day26,Day27,Day28,Day29,Day30,Day31 
					FROM T0050_Shift_Rotation_Master WITH (NOLOCK)
					WHERE	Rotation_Type=1 AND Cmp_ID=@Cmp_ID) p
				UNPIVOT
					(ShiftID FOR DayName IN 
						(Day1, Day2, Day3, Day4, Day5,Day6,Day7,Day8,Day9,Day10,Day11, Day12, Day13, Day14, Day15,Day16,Day17,Day18,Day19,Day20,Day21, Day22, Day23, Day24, Day25,Day26,Day27,Day28,Day29,Day30,Day31)
					) As unpvt
				) As SR
			Where ER.Rotation_ID=SR.Tran_ID AND ER.Cmp_ID=SR.Cmp_ID AND ER.EMP_ID=@EMP_ID 
				And ER.Cmp_ID=@Cmp_ID AND SR.DayName='Day' + Cast(DatePart(d,@For_Date) As Varchar) AND
				ER.Effective_Date <= @For_Date 
			Order By ER.Effective_Date Desc
		END
	
	
	
	--If Shift ID is not exist in Shift Rotation Master for particular employee then it will take the latest shift 
	--detail by default which can be replaced with current date shift detail defined in Shift Detail table if exist.
	IF (@Shift_ID IS NULL) 
		SELECT	@Shift_ID = ES.Shift_ID
		FROM	dbo.T0100_EMP_SHIFT_DETAIL ES WITH (NOLOCK)
				INNER JOIN (SELECT MAX(for_Date) For_date 
							FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)
							WHERE Emp_ID=@Emp_ID AND For_Date<=@For_Date AND ISNULL(Shift_type,0) <> 1)Q ON ES.For_Date=Q.for_Date AND ES.Emp_ID=@Emp_ID
		WHERE	ES.Emp_ID=@Emp_ID AND ES.Cmp_ID=@Cmp_ID
		
		
	ELSE
		SET @HasRotation = 1;
	
	
	
	--It checks if rotation is defined for this employee. if yes then it will not check whether shift type is 1 or not.
	IF (@HasRotation = 1) BEGIN
		IF EXISTS(SELECT 1 FROM dbo.T0100_EMP_SHIFT_DETAIL ES WITH (NOLOCK) INNER JOIN  dbo.T0040_SHIFT_MASTER  SM WITH (NOLOCK) ON ES.SHIFT_ID = SM.SHIFT_ID
					WHERE ES.Cmp_ID = @Cmp_ID  AND ES.Emp_Id = @emp_id AND For_Date = @For_Date) BEGIN
			SELECT @Shift_ID = ES.Shift_ID
			FROM dbo.T0100_EMP_SHIFT_DETAIL ES WITH (NOLOCK) INNER JOIN  dbo.T0040_SHIFT_MASTER  SM WITH (NOLOCK) ON ES.SHIFT_ID = SM.SHIFT_ID
			WHERE ES.Cmp_ID = @Cmp_ID  AND ES.emp_id = @emp_id AND For_Date = @For_Date 
		END 			
	END ELSE BEGIN
		IF EXISTS(SELECT 1 FROM dbo.T0100_EMP_SHIFT_DETAIL ES WITH (NOLOCK) INNER JOIN  dbo.T0040_SHIFT_MASTER  SM WITH (NOLOCK) ON ES.SHIFT_ID = SM.SHIFT_ID
					WHERE ES.Cmp_ID = @Cmp_ID  AND ES.emp_id = @emp_id AND ISNULL(Shift_type,0) =1 AND For_Date = @For_Date) BEGIN
			
			SELECT @Shift_ID = ES.Shift_ID
			FROM dbo.T0100_EMP_SHIFT_DETAIL ES WITH (NOLOCK) INNER JOIN  dbo.T0040_SHIFT_MASTER  SM WITH (NOLOCK) ON ES.SHIFT_ID = SM.SHIFT_ID
			WHERE ES.Cmp_ID = @Cmp_ID  AND ES.emp_id = @emp_id AND ISNULL(Shift_type,0) =1 AND For_Date = @For_Date
		END		
	END			
	
	
	RETURN @Shift_ID;
END


