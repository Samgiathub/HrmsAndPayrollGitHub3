



---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[get_Emp_In_our_record]
 
   @for_date  datetime,
   @emp_id    numeric ,
   @cmp_id   numeric	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		Declare @max_date as datetime
	Begin
	
			
	set @max_date = (Select Max(For_date) as For_date from T0150_Emp_InOut_Record lt  WITH (NOLOCK) where emp_id=@emp_id and cmp_id=@cmp_id and for_date < @for_date and Skip_count =2)
		
		
	select count(*) as count_rec from (Select Distinct(For_date) from T0150_Emp_InOut_Record WITH (NOLOCK) where emp_id=@emp_id and for_date > @max_date and for_Date < @for_date)c
   end	
 
   
 RETURN 




