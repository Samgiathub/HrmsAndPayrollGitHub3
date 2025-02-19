
-- Created By rohit for mobile Login page on 09092015
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0011_Mobile_login_Check]
	@Cmp_ID numeric(18,0)
   ,@Emp_ID numeric(18,0)
   ,@For_Date varchar(18)
	as
   begin

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @error as table
(
	error varchar(100)
)

	select INC.in_time,inc.emp_id,IR.io_tran_id,IR.Out_Time  from t0150_emp_inout_record IR  WITH (NOLOCK) inner join 
	( select MAX(in_time) in_time,Emp_ID,for_date from t0150_emp_inout_record WITH (NOLOCK) where Emp_ID = @Emp_ID and 
	For_Date = @For_Date group by Emp_ID,for_date ) INC on IR.Emp_ID= INC.emp_id and ir.For_Date = INC.for_date and IR.in_time =INC.in_time 

	if exists(select 1 from T0080_EMP_MASTER WITH (NOLOCK) where emp_id = @Emp_ID and isnull(is_for_mobile_Access,0) = 0 )
	begin
		select 'User is Not Applicable For mobile Access.'  as error  -- Showing Error in mobile login
		return
	end
		select * from @error
   end

	RETURN




