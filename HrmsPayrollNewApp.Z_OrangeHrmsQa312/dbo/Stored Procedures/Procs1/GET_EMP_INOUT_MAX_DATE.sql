



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[GET_EMP_INOUT_MAX_DATE]
	@CMP_ID as numeric
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	select emp_id,cmp_id,cast(max(for_date) as datetime) as for_date  from T0150_EMP_INOUT_RECORD  WITH (NOLOCK) where Cmp_ID= @CMP_ID  group by emp_id,cmp_id --and month(for_date) < 7
		
	--select emp_id,cmp_id,'18-Aug-2011' as for_date  from T0150_EMP_INOUT_RECORD  where Cmp_ID= @CMP_ID  group by emp_id,cmp_id --and month(for_date) < 7	
		
	RETURN




