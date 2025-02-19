
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0190_MONTHLY_PRESENT_IMPORT_Delete]    
	@Tran_ID numeric(18,0)    
AS  

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @emp_id as numeric
	declare @Month as numeric
	declare @Year as numeric

	select  @emp_id =emp_id,@Month=month,@Year=year from T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) where tran_id=@Tran_ID

	if exists(select 1 from t0200_monthly_salary WITH (NOLOCK) where emp_id=@emp_id and month(Month_End_Date) =@Month and year(Month_End_Date) =@Year  )
		begin
			RAISERROR('@@ Salary Exist for Month @@',16,2)
			return
		end
	else
		begin
			If not exists (select * from T0140_BACK_DATED_ARREAR_LEAVE WITH (NOLOCK) where Present_import_tran_id=@Tran_ID and Leave_approval_id > 0)
				Begin	
					Delete from T0190_MONTHLY_PRESENT_IMPORT where Tran_ID=@Tran_ID 
				End
			Else
				Begin
					Update T0190_MONTHLY_PRESENT_IMPORT Set Extra_Days = 0,P_Days=0,
							Over_Time = 0 , WO_OT_Hour = 0 , HO_OT_Hour = 0 --Ankit 07012015
							,Backdated_Leave_Days=0,Cancel_Holiday=0,Cancel_Weekoff_Day=0,Payble_Amount=0
					where Tran_ID = @Tran_ID		
					--RAISERROR('@@ Leave Arear Entry exists @@',16,2)
					--Return
				End
		End
 RETURN    
    
  


