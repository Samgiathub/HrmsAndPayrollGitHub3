
---10/3/2021 (EDIT BY MEHUL ) (Table-valued function WITH NOLOCK)---
CREATE FUNCTION [dbo].[F_Get_Curr_Shift]
(
	@Emp_ID		numeric,
	@For_Date	datetime
)  
RETURNS @RtnValue table 
(
	Shift_ID numeric,
	Shift_Name nvarchar(100)
) 
AS  
BEGIN 
	
	Insert into @RtnValue 
	select ESD.Shift_ID,Shift_Name from T0100_emp_shift_Detail ESD WITH (NOLOCK) Inner join
		T0040_Shift_MAster SM WITH (NOLOCK) on ESD.shift_ID = SM.shift_ID inner join 
		( select Emp_ID ,Max(For_DAte) For_DAte From T0100_emp_shift_Detail WITH (NOLOCK) 
			Where Emp_ID =@emp_ID  and For_Date <=@For_Date 
			Group by Emp_ID ) Q on 
			ESD.emp_ID = Q.emp_ID and ESD.For_Date = Q.for_Date 
	

	Return
END




