

CREATE PROCEDURE [dbo].[SP_Emp_Shift_Change_Get]
	@Emp_ID numeric,
	@Cmp_ID numeric
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
	
	Declare @For_Date  as dateTime
	Select @For_Date =Max(For_Date) from T0100_emp_Shift_Detail WITH (NOLOCK) where cmp_id=@Cmp_ID and emp_ID=@Emp_ID
	Select * from T0100_emp_Shift_Detail WITH (NOLOCK) where cmp_ID=@Cmp_ID and For_Date=@For_Date and emp_ID=@Emp_ID
	

	RETURN




