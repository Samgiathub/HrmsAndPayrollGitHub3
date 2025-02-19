



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RETURN_MAX_DATE_RECORD_GET]
	@CMP_ID	NUMERIC 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @CMP_ID = 0
		SET @CMP_ID = NULL
		
	Declare @Emp_Cons Table
	 ( 
		Emp_ID numeric ,
		For_Date Datetime
	  )
	  
	Insert into @Emp_Cons (Emp_ID,For_Date)
	select e.Emp_ID,
		isnull(case when isnull(In_Time,'01-01-1900')  > isnull(Out_Time,'01-01-1900') then  
			In_Time 
		else
			Out_Time 
		end,'01-01-1900')
	From T0080_Emp_Master e WITH (NOLOCK) Inner join 
	( select eir.Emp_ID ,max(In_Time)In_Time,max(Out_time)Out_Time from T0150_Emp_Inout_Record eir WITH (NOLOCK) group by emp_ID ) q on e.emp_ID = q.emp_ID
	where Cmp_ID = isnull(@Cmp_ID,Cmp_ID) and isnull(emp_Left,'N') <> 'Y'
		
	
	select * from @Emp_Cons
	
	
	RETURN




