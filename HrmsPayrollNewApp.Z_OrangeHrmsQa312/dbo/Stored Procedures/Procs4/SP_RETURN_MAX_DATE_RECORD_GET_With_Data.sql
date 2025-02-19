

-- Author : Hardik Barot
--Date : 09/09/2014 (For Azure)
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RETURN_MAX_DATE_RECORD_GET_With_Data]
	@CMP_ID	NUMERIC 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @CMP_ID = 0
		SET @CMP_ID = NULL
		
	
		Select D.* from T9999_DEVICE_INOUT_DETAIL D WITH (NOLOCK) Inner Join
			 (select e.Emp_ID,Enroll_No,Cmp_Id,
				isnull(case when isnull(In_Time,'01-01-1900')  > isnull(Out_Time,'01-01-1900') then  
					In_Time 
				else
					Out_Time 
				end,'01-01-1900') as Max_Date
			From T0080_Emp_Master e WITH (NOLOCK) Inner join 
			( select eir.Emp_ID ,max(In_Time)In_Time,max(Out_time)Out_Time from T0150_Emp_Inout_Record eir WITH (NOLOCK) group by emp_ID ) q on e.emp_ID = q.emp_ID
			where Cmp_ID = isnull(@Cmp_ID,Cmp_ID) and isnull(emp_Left,'N') <> 'Y') Qry 
		on D.Enroll_No = Qry.Enroll_No And D.Cmp_ID = Qry.Cmp_ID And D.IO_DateTime > Qry.Max_Date
		Order By D.Enroll_No,D.IO_DateTime
	
Return
