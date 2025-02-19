



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_MAX_SHIFT_EMPLOYEE] 
	
	  @Cmp_ID numeric,
	  @Emp_ID numeric,
	  @Branch_ID numeric=0	
	
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

   Declare @Max_Shift_ID as numeric
   

     Select Shift_ID from T0100_Emp_shift_Detail I1 WITH (NOLOCK) inner join
		 (Select Max(For_Date)for_Date,Emp_ID from T0100_Emp_shift_Detail WITH (NOLOCK) where Emp_ID=@Emp_ID and Shift_type=0 and for_date < DateAdd(d,1,getdate()) group by emp_ID ,shift_type)I2 on
			I1.Emp_ID= I2.Emp_ID  and I1.For_Date =I2.For_Date
		
		
	
	RETURN




