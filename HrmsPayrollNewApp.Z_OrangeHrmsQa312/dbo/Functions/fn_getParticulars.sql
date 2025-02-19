




-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 12-April-2017
-- Description:	To retreive the Increment/Bonus Calculation Particulars
---10/3/2021 (EDIT BY MEHUL ) (Table-valued function WITH NOLOCK)---
-- =============================================
CREATE FUNCTION [dbo].[fn_getParticulars] 
(	
	@Cmp_ID Numeric, 
	@Branch_ID Numeric,
	@For_Date DATETIME,
	@Data_For Char(1)		--'I' for Increment, 'B' for Bonus
)
RETURNS @PARTICULAR TABLE(ID NUMERIC, CAPTION Varchar(32), Flag Char(1), Selected Bit,Cal_Flag Bit)
AS
BEGIN

	IF ISNULL(@Data_For,'') = ''
		SET @Data_For = 'I'
    
    INSERT INTO @PARTICULAR(ID, CAPTION, FLAG, Selected,Cal_Flag)
    SELECT	Leave_ID, Leave_Name, 'L' As Flag, 0 As Selected,0 As Cal_Flag
    FROM	T0040_LEAVE_MASTER LM WITH (NOLOCK)
    WHERE	LM.Cmp_ID=@Cmp_ID
    
	INSERT INTO @PARTICULAR VALUES (9001, 'Present Days', 'D',0,0)
	INSERT INTO @PARTICULAR VALUES (9002, 'Absent Days', 'D',0,0)
	INSERT INTO @PARTICULAR VALUES (9003, 'WeekOff', 'D',0,0)
	INSERT INTO @PARTICULAR VALUES (9004, 'Holiday', 'D',0,0)
	INSERT INTO @PARTICULAR VALUES (9005, 'Late Deduction Days', 'D',0,0)
	INSERT INTO @PARTICULAR VALUES (9008, 'Gate pass Deduction Days', 'D',0,0)
	if @Data_For <> 'I'
		Begin
			INSERT INTO @PARTICULAR VALUES (9006, 'Leave Work Count', 'D',0,1)
			INSERT INTO @PARTICULAR VALUES (9007, 'WeekOff Work Count', 'D',0,1)
		End

	IF ISNULL(@Branch_ID,0) > 0
		BEGIN			
			DECLARE @PART_CONS VARCHAR(MAX);
			--No need to put max(For_Date) or order by statement
			--Getting first record with clustered index given on for_date desc
			IF @Data_For = 'I'
				SELECT	TOP 1 @PART_CONS = Particulars
				FROM	T0040_INCREMENT_CALC WITH (NOLOCK)
				WHERE	BRANCH_ID=@Branch_ID AND CMP_ID=@CMP_ID AND FOR_DATE <= ISNULL(@FOR_DATE, FOR_DATE)
			ELSE
				SELECT	TOP 1 @PART_CONS = Particulars
				FROM	T0040_BONUS_CALC WITH (NOLOCK)
				WHERE	BRANCH_ID=@Branch_ID AND CMP_ID=@CMP_ID AND FOR_DATE <= ISNULL(@FOR_DATE, FOR_DATE)
			
			UPDATE	P
			SET		Selected = 1
			FROM	@PARTICULAR P
					INNER JOIN (Select Cast(Data As Numeric) ID FROM dbo.Split(@PART_CONS, '#') T Where IsNumeric(Data) > 0) T 
					ON P.ID=T.ID			
			
		END
		
	RETURN 
END



