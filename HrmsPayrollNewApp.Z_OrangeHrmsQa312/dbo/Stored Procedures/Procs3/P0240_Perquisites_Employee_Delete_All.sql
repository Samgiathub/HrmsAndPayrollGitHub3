
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0240_Perquisites_Employee_Delete_All]
	@Cmp_id as numeric
	,@Emp_ID as numeric
	,@Financial_Year as varchar(50)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
		
		Declare @TranId as numeric

		Delete from T0240_Perquisites_Employee_Car where emp_id = @Emp_ID And cmp_id = @Cmp_id 
		and Financial_Year = @Financial_Year
		
		
		Set @TranId = 0		
		Select @TranId = Tran_id from T0240_Perquisites_Employee WITH (NOLOCK) where emp_id = @Emp_ID And cmp_id = @Cmp_id 
		and Financial_Year = @Financial_Year 
		
		Delete from T0250_Perquisites_Employee_Monthly_Rent where Perq_Tran_Id = @TranId
		Delete from  T0240_Perquisites_Employee where emp_id = @Emp_ID And cmp_id = @Cmp_id and Financial_Year = @Financial_Year and Tran_id = @TranId		
		
		
		
		Set @TranId = 0		
		Select @TranId = Trans_ID from T0240_PERQUISITES_EMPLOYEE_GEW WITH (NOLOCK) where emp_id = @Emp_ID And cmp_id = @Cmp_id 
		and Financial_Year = @Financial_Year 
		
		Delete from T0250_Perquisites_Employee_Monthly_GEW where Perq_Tran_Id = @TranId
		Delete from  T0240_PERQUISITES_EMPLOYEE_GEW where Emp_id = @Emp_ID And Cmp_id = @Cmp_id and Financial_Year = @Financial_Year and Trans_ID = @TranId	
		
		delete from T0240_Perquisites_Employee_Dynamic  where emp_id = @Emp_ID And cmp_id = @Cmp_id 
		and Financial_Year = @Financial_Year
		
END

