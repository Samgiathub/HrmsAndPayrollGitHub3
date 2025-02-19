

-- =============================================
-- Author:		Shaikh Ramiz
-- Create date: 24-Jan-2018
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_MACHINE_ALLOCATION]
	@Allocation_ID		NUMERIC	OUTPUT,
	@Cmp_ID				NUMERIC,
	@Emp_ID				NUMERIC,
	@Shift_ID			NUMERIC,
	@Machine_ID			VARCHAR(500),
	@Effective_Date		DATETIME,
	@Tran_type			CHAR(1)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	/*
		Here We need to Add a Validation that on Same Date , Same Machine Should not be Allocated to any Employee.
		But that Validation will work for Single Machine. For Reliever and Asst. Tackler same Machine Can be Allocated.
	*/
	
	IF @Tran_type = 'I'
		BEGIN
			IF EXISTS(SELECT 1 FROM T0040_Machine_Allocation_Master WITH (NOLOCK) WHERE Shift_ID = @Shift_ID AND Effective_Date = @Effective_Date and Machine_ID = @Machine_ID and CHARINDEX('#' , @Machine_ID) = 0)	
				BEGIN
					RAISERROR('@@Machine Already Assigned on Same Date and Same Shift@@',16,2)  
					RETURN 
				END
			ELSE
				BEGIN
					INSERT INTO T0040_MACHINE_ALLOCATION_MASTER 
						(Cmp_ID , Emp_ID ,  Shift_ID , Effective_Date , Machine_ID)
					VALUES 
						(@Cmp_ID, @Emp_ID , @Shift_ID , @Effective_Date , @Machine_ID )
				END
		END
	ELSE IF @Tran_type = 'U'
		BEGIN
			
			UPDATE T0040_MACHINE_ALLOCATION_MASTER
			SET		Shift_ID	= @Shift_ID,
					Effective_Date = @Effective_Date ,
					Machine_ID	=	@Machine_ID
			WHERE	Allocation_ID = ISNULL(@Allocation_ID,0) AND Emp_ID = ISNULL(@Emp_ID , 0)
					
		END
	ELSE IF @Tran_type = 'D'
		BEGIN	
			IF EXISTS (SELECT 1 FROM T0100_MACHINE_DAILY_EFFICIENCY WITH (NOLOCK) WHERE Machine_ID = @Machine_ID AND Alternate_Emp_ID = @Emp_ID)
				BEGIN
					SET @Allocation_ID = 0  
					RAISERROR('@@Cannot Delete Allocation, Daily Efficiency Exits for this Employee@@',16,2)  
					RETURN 
				END
			
			DELETE FROM T0040_MACHINE_ALLOCATION_MASTER WHERE Allocation_ID = ISNULL(@Allocation_ID,0) and Emp_ID = ISNULL(@Emp_ID , 0)
		END
		
END


