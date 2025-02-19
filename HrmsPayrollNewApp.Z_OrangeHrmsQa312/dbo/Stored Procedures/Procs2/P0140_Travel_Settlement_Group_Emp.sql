
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0140_Travel_Settlement_Group_Emp]  
   @Tran_id numeric(18,0) output
  ,@Travel_Application_Id numeric(18, 0)  
  ,@cmp_id numeric(18, 0)  
  ,@Emp_ID numeric(18, 0)  
  ,@Travel_Approval_Id numeric(18,0)
  ,@Branch_ID numeric(18,0)
  --,@Modify_Date datetime
  ,@selected_Emp_ID numeric(18,0)  
  ,@tran_type  Varchar(1)   
  
   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
   
  if @tran_type ='I'   
   begin  
		--declare @app_status as varchar(1)
		select @Tran_id = Isnull(max(Tran_id),0) + 1 From dbo.t0140_travel_settlement_group_emp WITH (NOLOCK)   
		if Not Exists(select 1 from T0140_Travel_Settlement_Group_Emp WITH (NOLOCK) where Cmp_ID=@cmp_id and Emp_ID=@Emp_ID and Selected_Emp_ID=@selected_Emp_ID and Branch_ID=@Branch_ID and Travel_Application_ID=@Travel_Application_Id and Travel_Approval_ID=@Travel_Approval_Id)
		begin
		
				INSERT INTO t0140_travel_settlement_group_emp
						  (Tran_id, Travel_Application_ID, cmp_id, emp_id,Travel_Approval_ID,Branch_ID,Modify_Date,Selected_Emp_ID)
				VALUES    (@Tran_id,@Travel_Application_Id,@cmp_id,@Emp_ID,@Travel_Approval_Id,@Branch_ID,GETDATE(),@selected_Emp_ID)
		End
		Else
			Begin
						RAISERROR('@@ Already Esits @@',16,2)
						RETURN
			End
		
			
		--UPDATE T0140_Travel_Settlement_Application SET status = @app_status where Travel_Set_Application_id = @Travel_Set_Application_Id
		
		
	END    
 
  else if @tran_type='D'
  begin 
  
		Delete from t0140_travel_settlement_group_emp where cmp_id=@cmp_id and Travel_Approval_ID=@Travel_Approval_Id and tran_id=@Tran_id			
					
     
  
  end
 RETURN  
  
  
  

