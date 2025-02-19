  
  
  
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0150_Travel_Settlement_Approval]    
   @Tran_id numeric(18,0) output  
  ,@Travel_Set_Application_Id numeric(18, 0)  
  ,@cmp_id numeric(18, 0)    
  ,@Emp_ID numeric(18, 0)    
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
  ,@EffectSalary tinyint=0  
  ,@EffectSalDate datetime =null  
  ,@User_Id numeric(18,0) = 0 -- Add By Mukti 11072016  
  ,@IP_Address varchar(30)= '' -- Add By Mukti 11072016   
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
     
    -- Add By Mukti 11072016(start)  
 declare @OldValue as  varchar(max)  
 Declare @String_val as varchar(max)  
 set @String_val=''  
 set @OldValue =''  
 -- Add By Mukti 11072016(end)  

       set @Manager_Comments = dbo.fnc_ReverseHTMLTags(@Manager_Comments) --Ronak_070121    

  if @tran_type ='I'     
   begin    
  declare @app_status as varchar(1)  
  select @Tran_id = Isnull(max(Tran_id),0) + 1 From dbo.T0150_Travel_Settlement_Approval WITH (NOLOCK)   
  
  INSERT INTO T0150_Travel_Settlement_Approval  
      (Tran_id, Travel_Set_Application_id, cmp_id, emp_id, manager_emp_id, pending_amount, Manager_comment, is_apr, Approval_date,Advance_amount,Expance_Incured,Approved_Expance,Amount_Differnce,Adjust_Amount,Payment_Type,Cheque_no,Travel_Amt_In_Salary,Effect_Salary_date)  
  VALUES     (@Tran_id,@Travel_Set_Application_Id,@cmp_id,@Emp_ID,@manager_emp_id,@Pending_amount,@Manager_Comments,@is_approved,@Approval_Date,@Advance_amount,@Expance_Incured,@Approved_Expance,@Amount_Differnce,@Adjust_Amount,@Amount_pay,@Cheque,@EffectSalary,@EffectSalDate)  
  
  IF @is_approved = 0  
   begin   
    set @app_status = 'R'  
   end  
  else  
   begin  
    set @app_status = 'A'  
   end  
     
  UPDATE T0140_Travel_Settlement_Application SET status = @app_status where Travel_Set_Application_id = @Travel_Set_Application_Id  
  -- Add By Mukti 11072016(start)  
    exec P9999_Audit_get @table = 'T0150_Travel_Settlement_Approval' ,@key_column='Tran_id',@key_Values=@Tran_id,@String=@String_val output  
    set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))    
    -- Add By Mukti 11072016(end)    
 END    
    
  --else if @tran_type='D'  
  --begin   
    
  --delete from T0150_Travel_Settlement_Approval where Tran_id=@Tran_id and emp_id=@Emp_ID  
  --delete from T0150_Travel_Settlement_Approval_Expense where emp_id=@Emp_ID and Travel_Settlement_Id=@Travel_Set_Application_Id  
  --UPDATE T0140_Travel_Settlement_Application SET status = 'P' where Travel_Set_Application_id = @Travel_Set_Application_Id  
  --end  
  else if @tran_type='D'  
  begin     
  DECLARE @SalEffect as tinyint=0  
  DECLARE @EffectDate as datetime  
    
  select @SalEffect=isnull(Travel_Amt_In_salary,0),@EffectDate=isnull(Effect_Salary_date,GETDATE()) from T0150_Travel_Settlement_Approval WITH (NOLOCK) where cmp_id=@cmp_id and Tran_id=@Tran_id and emp_id=@Emp_ID  
    
  if(@SalEffect=1)  
   Begin  
    if exists(select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where Cmp_ID=@cmp_id and Emp_ID=@Emp_ID   
        --and Month(Month_End_Date)=Month(@EffectDate) and Year(Month_End_Date) = Year(@EffectDate)  
         and @EffectDate between Month_st_Date and Month_End_Date  ---Changed By Jimit 03042019 if salary cycle is different from 1 to 31 then error is raised though the effect date is not in the salary range Bug No. 8906  
        )  
     Begin  
      Raiserror('@@Salary Exists. You can''t delete@@',16,0)  
      return  
     End  
   End   
    
	

	select @Travel_Set_Application_Id
  --Added by Jaina 29-12-2017  
  IF EXISTS (SELECT 1 FROM T0302_PAYMENT_PROCESS_TRAVEL_DETAILS PT WITH (NOLOCK) INNER JOIN   
         MONTHLY_EMP_BANK_PAYMENT ME WITH (NOLOCK) ON PT.PAYMENT_PROCESS_ID = ME.PAYMENT_PROCESS_ID INNER JOIN  
         T0150_Travel_Settlement_Approval TA WITH (NOLOCK) ON TA.Travel_Set_Application_id = PT.Travel_Set_Approval_Id  
       WHERE PT.CMP_ID=@CMP_ID AND PT.Travel_Set_Approval_Id=@Travel_Set_Application_Id AND PT.EMP_ID = @EMP_ID)  
    BEGIN  
     Raiserror('@@Reference Exists in Payment Process@@',18,2)  
     Return -1  
    END  
       
  -- Add By Mukti 11072016(start)  
    exec P9999_Audit_get @table='T0150_Travel_Settlement_Approval' ,@key_column='Tran_id',@key_Values=@Tran_id,@String=@String_val output  
    set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))  
  -- Add By Mukti 11072016(end)  
    
  delete from T0150_Travel_Settlement_Approval where emp_id=@Emp_ID and Travel_Set_Application_id=@Travel_Set_Application_Id --Tran_id=@Tran_id  
  delete from T0150_Travel_Settlement_Approval_Expense where emp_id=@Emp_ID and Travel_Settlement_Id=@Travel_Set_Application_Id  
  delete from T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE where Travel_Settlement_Id=@Travel_Set_Application_Id  
    
  UPDATE T0140_Travel_Settlement_Application SET status = 'P' where Travel_Set_Application_id = @Travel_Set_Application_Id  
 --declare @Tran_id as numeric(18,0)  
  declare @Rm_emp_id as numeric(18,0)  
  set @Rm_emp_id = 0  
  set @Tran_id = 0  
   
 Select @Rm_emp_id = manager_Emp_ID,@Tran_id = Tran_ID from T0115_Travel_Settlement_Level_Approval WITH (NOLOCK) where  Travel_Set_Application_id= @Travel_Set_Application_Id AND Rpt_Level IN (SELECT max(Rpt_Level) from T0115_Travel_Settlement_Level_Approval WITH (NOLOCK) where travel_set_application_id=@Travel_Set_Application_Id)  
   
 
  
 CREATE TABLE #T0115_TRAVEL_SETTLEMENT_LEVEL_MODE_EXPENSE_DELETE  
 (  
  INT_EXP_ID NUMERIC(18,0)  
 )  
   
 If @Rm_emp_id = @manager_emp_id   
      BEGIN         
        
         
      IF EXISTS(  
      SELECT 1  
      FROM T0115_Travel_Settlement_Level_Expense WITH (NOLOCK)  
      WHERE TRAVEL_SETTLEMENT_ID= @Travel_Set_Application_Id and manager_Emp_ID=@manager_emp_id)  
       BEGIN  
          
         INSERT INTO #T0115_TRAVEL_SETTLEMENT_LEVEL_MODE_EXPENSE_DELETE  
         SELECT INT_EXP_ID  
         FROM T0115_Travel_Settlement_Level_Expense WITH (NOLOCK)  
         WHERE Travel_Settlement_ID= @Travel_Set_Application_Id and manager_Emp_ID=@manager_emp_id  
         
       END  
         
       DELETE FROM T0115_TRAVEL_SETTLEMENT_LEVEL_APPROVAL WHERE TRAVEL_SET_APPLICATION_ID= @TRAVEL_SET_APPLICATION_ID AND MANAGER_EMP_ID=@MANAGER_EMP_ID  
       DELETE FROM T0115_TRAVEL_SETTLEMENT_LEVEL_EXPENSE WHERE TRAVEL_SETTLEMENT_ID=@TRAVEL_SET_APPLICATION_ID AND MANAGER_EMP_ID=@MANAGER_EMP_ID  
         
       IF EXISTS(SELECT 1 FROM #T0115_TRAVEL_SETTLEMENT_LEVEL_MODE_EXPENSE_DELETE)  
        BEGIN  
         DELETE  T  
         FROM  T0115_TRAVEL_SETTLEMENT_LEVEL_MODE_EXPENSE T   
         INNER JOIN  #T0115_TRAVEL_SETTLEMENT_LEVEL_MODE_EXPENSE_DELETE D ON T.INT_EXP_ID = D.INT_EXP_ID  
         WHERE  T.TRAVEL_SETTLEMENT_ID=@TRAVEL_SET_APPLICATION_ID AND T.INT_EXP_ID = D.INT_EXP_ID  
        END  
      End  
 Else if @manager_emp_id=0  
      begin  
       Delete from T0115_Travel_Settlement_Level_Approval Where Travel_Set_Application_id= @Travel_Set_Application_Id --and manager_Emp_ID=@manager_emp_id  
       delete from T0115_Travel_Settlement_Level_Expense where Travel_Settlement_ID=@Travel_Set_Application_Id --and Manager_Emp_ID=@manager_emp_id  
       delete from T0115_Travel_Settlement_Level_Mode_Expense where Travel_Settlement_ID=@Travel_Set_Application_Id   
      end  
 Else  
      Begin       
         
       IF EXISTS(  
       SELECT 1  
       FROM T0115_Travel_Settlement_Level_Expense WITH (NOLOCK)  
       WHERE Travel_Settlement_ID= @Travel_Set_Application_Id and manager_Emp_ID=@manager_emp_id)  
        BEGIN  
           
          INSERT INTO #T0115_TRAVEL_SETTLEMENT_LEVEL_MODE_EXPENSE_DELETE  
          SELECT INT_EXP_ID  
          FROM T0115_Travel_Settlement_Level_Expense WITH (NOLOCK)  
          WHERE Travel_Settlement_ID= @Travel_Set_Application_Id and manager_Emp_ID=@manager_emp_id  
          
        END  
         
       delete from T0115_Travel_Settlement_Level_Expense where Travel_Settlement_ID=@Travel_Set_Application_Id and Manager_Emp_ID=@manager_emp_id  
       Delete from T0115_Travel_Settlement_Level_Approval Where Travel_Set_Application_id= @Travel_Set_Application_Id and manager_Emp_ID=@manager_emp_id  
         
         
       IF EXISTS(SELECT 1 FROM #T0115_TRAVEL_SETTLEMENT_LEVEL_MODE_EXPENSE_DELETE)  
        BEGIN  
         DELETE  T  
         FROM  T0115_TRAVEL_SETTLEMENT_LEVEL_MODE_EXPENSE T   
         INNER JOIN  #T0115_TRAVEL_SETTLEMENT_LEVEL_MODE_EXPENSE_DELETE D ON T.INT_EXP_ID = D.INT_EXP_ID  
         WHERE  T.TRAVEL_SETTLEMENT_ID=@TRAVEL_SET_APPLICATION_ID AND T.INT_EXP_ID = D.INT_EXP_ID  
        END  
          
         
      End    
        
       DROP TABLE #T0115_TRAVEL_SETTLEMENT_LEVEL_MODE_EXPENSE_DELETE   
  end  
    
   
  exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Travel Settlement Approval',@OldValue,@Emp_ID,@User_Id,@IP_Address,1  
RETURN    
    
    
    
  