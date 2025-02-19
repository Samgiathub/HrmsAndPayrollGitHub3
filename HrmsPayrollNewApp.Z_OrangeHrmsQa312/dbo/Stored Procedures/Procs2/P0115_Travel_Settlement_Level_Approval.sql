

--------------2015-09-21 18:57:13.448-----------------------------
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0115_Travel_Settlement_Level_Approval]  
   
   @TRAN_ID NUMERIC(18,0) OUTPUT
  ,@TRAVEL_SET_APPLICATION_ID NUMERIC(18, 0)
  ,@CMP_ID NUMERIC(18, 0)  
  ,@EMP_ID Numeric(18, 0)  
  ,@Travel_Approval_ID numeric(18, 0) =null
  ,@manager_emp_id numeric(18,0)
  ,@Pending_amount numeric(18,2)
  ,@Manager_Comments varchar(500)  
  ,@is_approved tinyint
  ,@Approval_Date datetime  
  ,@tran_type  Varchar(1)   
  ,@Advance_amount numeric(18,2) = 0
  ,@Expance_Incured numeric(18,2) = 0
  ,@Approved_Expance numeric(18,2) = 0
  ,@Amount_Differnce numeric(18,2) = 0
  ,@Adjust_Amount numeric(18,2) = 0
  ,@Amount_pay varchar(100)='Cash' 
   ,@Cheque numeric(18,0) = 0
   ,@Status varchar(20)='P'
   ,@Rpt_Level numeric(18,0)=0
   ,@EffectSalary tinyint=0
   ,@EffectSalDate datetime =null
   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

   if @EffectSalary=0
	Begin
		if @EffectSalDate='1900-01-01 00:00:00'
			Begin			
				set @EffectSalDate=null
			End
	End
   
  if @tran_type ='I'   
   begin  
		declare @app_status as varchar(1)
		
		IF Exists(Select 1 From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK) Where Emp_ID=@Emp_ID And manager_emp_id = @manager_emp_id And Rpt_Level = @Rpt_Level and Travel_Set_Application_id=@Travel_Set_Application_Id)
				Begin				
					Set @Tran_ID = 0
					Select @Tran_ID
					Return 
				End
				
		select @Tran_id = Isnull(max(Tran_id),0) + 1 From dbo.T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)

		INSERT INTO T0115_Travel_Settlement_Level_Approval
				  (Tran_id, Travel_Set_Application_id, cmp_id, emp_id, manager_emp_id, pending_amount, Manager_comment, is_apr, Approval_date,Advance_amount,Expance_Incured,Approved_Expance,Amount_Differnce,Adjust_Amount,Payment_Type,Cheque_no,Rpt_Level,status,Travel_Approval_ID,Travel_Amt_In_Salary,Effect_Salary_Date)
		VALUES     (@Tran_id,@Travel_Set_Application_Id,@cmp_id,@Emp_ID,@manager_emp_id,@Pending_amount,@Manager_Comments,@is_approved,@Approval_Date,@Advance_amount,@Expance_Incured,@Approved_Expance,@Amount_Differnce,@Adjust_Amount,@Amount_pay,@Cheque,@Rpt_Level,@Status,@travel_Approval_ID,@EffectSalary,@EffectSalDate)

		--IF @Status = 0
		--	begin	
		--		set @app_status = 'R'
		--	end
		--else
		--	begin
		--		set @app_status = 'A'
		--	end
			
		--UPDATE T0140_Travel_Settlement_Application SET status = @status where Travel_Set_Application_id = @Travel_Set_Application_Id
		
		
	END  
  
  else if @tran_type='D'
  begin 
  
  delete from T0115_Travel_Settlement_Level_Approval where Tran_id=@Tran_id and emp_id=@Emp_ID
  delete from T0115_Travel_Settlement_Level_Expense where emp_id=@Emp_ID and Travel_Settlement_Id=@Travel_Set_Application_Id
  UPDATE T0140_Travel_Settlement_Application SET status = 'P' where Travel_Set_Application_id = @Travel_Set_Application_Id
  end
  
 RETURN  
  
  
  
  
  
  

