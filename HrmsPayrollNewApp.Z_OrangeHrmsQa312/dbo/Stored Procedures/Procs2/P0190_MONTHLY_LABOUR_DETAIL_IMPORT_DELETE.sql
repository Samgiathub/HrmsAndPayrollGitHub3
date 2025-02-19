
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE Procedure [dbo].[P0190_MONTHLY_LABOUR_DETAIL_IMPORT_DELETE]
	@Tran_ID numeric(18,0)    
AS


SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	declare @emp_id as numeric
	declare @Month as numeric
	declare @Year as numeric

	select  @emp_id =emp_id,@Month=month,@Year=year from T0190_MONTHLY_LABOUR_DETAIL_IMPORT WITH (NOLOCK) where tran_id=@Tran_ID

	if exists(select 1 from t0200_monthly_salary WITH (NOLOCK) where emp_id=@emp_id and month(Month_End_Date) =@Month and year(Month_End_Date) =@Year  )
		begin
			RAISERROR('@@ Salary Exist for Month @@',16,2)
			return
		end
	else
				Begin
				
					Delete from T0190_MONTHLY_LABOUR_DETAIL_IMPORT where tran_id=@Tran_ID
						
				End
 RETURN    
    
  


