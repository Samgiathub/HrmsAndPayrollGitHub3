


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_MAX_SHIFT_EMPLOYEE_APP]
  @Cmp_ID int,
	  @Emp_Tran_ID bigint,
	  @Branch_ID int=0	
	
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


   Declare @Max_Shift_ID as numeric
   

     Select Shift_ID from T0065_EMP_SHIFT_DETAIL_APP I1 WITH (NOLOCK) inner join
		 (Select Max(Approved_Date)Approved_Date,Emp_Tran_ID from T0065_EMP_SHIFT_DETAIL_APP  WITH (NOLOCK)
		  where Emp_Tran_ID=@Emp_Tran_ID and Shift_type=0 
		  and Approved_Date < DateAdd(d,1,getdate()) group by Emp_Tran_ID ,shift_type)I2 on
			I1.Emp_Tran_ID= I2.Emp_Tran_ID  and I1.Approved_Date =I2.Approved_Date
		
		
	
	RETURN

