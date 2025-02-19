
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0230_MONTHLY_CLAIM_PAYMENT_DETAIL]
   @Claim_Pay_Detail_ID numeric(18, 0) output
  ,@Claim_Pay_ID numeric(18, 0)
  ,@Cmp_ID numeric(18, 0)  
  ,@Claim_Apr_ID numeric(18, 0)
  ,@Claim_Apr_Dtl_ID numeric(18, 0)
  ,@Sal_Tran_ID numeric(18,0)
  ,@Claim_Status varchar(25)
  ,@Claim_ID numeric(18, 0)  
  ,@Claim_Apr_Date datetime  
  ,@Claim_PetrolKM	NUMERIC(18,2)--Ankit 05022015
  ,@Claim_Apr_Amount numeric(18, 3)  
  ,@Claim_Purpose as nvarchar(250)
  ,@Emp_ID numeric(18, 0)  
  ,@S_Emp_ID numeric(18,0) 
  ,@Claim_App_Amnt numeric(18,3)
   --,@Claim_App_ID numeric(18, 0)  
  --,@Claim_App_Amount as numeric(18,3)
  --,@Curr_ID as numeric(18,0)
  --,@Curr_Rate as numeric(18,3)
  --,@Claim_App_Total_Amount as numeric(18,3)
  ,@tran_type char  
  ,@User_Id numeric(18,0) = 0 -- Add By Mukti 08072016
  ,@IP_Address varchar(30)= '' -- Add By Mukti 08072016
  
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

If @Claim_ID  =0   
  set @Claim_ID  = null  
  
If @S_Emp_ID=0
set @S_Emp_ID=null  
 
-- Add By Mukti 08072016(start)
	declare @OldValue as  varchar(max)
	Declare @String as varchar(max)
	set @String=''
	set @OldValue =''
-- Add By Mukti 08072016(end)
  
   
  If UPPER(@Tran_Type) = 'I'
	  begin
		  select @Claim_Pay_Detail_ID = Isnull(max(Claim_Pay_Dtl_ID),0) + 1  From T0230_MONTHLY_CLAIM_PAYMENT_DETAIL WITH (NOLOCK)
		  
		  Insert Into T0230_MONTHLY_CLAIM_PAYMENT_DETAIL
		  (Claim_Pay_Dtl_ID,Claim_Pay_Id,Cmp_ID,Claim_Apr_Id,Claim_Apr_Dtl_ID,Sal_Tran_Id,Claim_Status,Claim_ID,Claim_Apr_Date,Claim_PetrolKM,Claim_Apr_Amnt,Claim_Purpose,Emp_ID,S_Emp_ID,Claim_App_Amount)
		  values
		  (@Claim_Pay_Detail_ID,@Claim_Pay_ID,@Cmp_ID,@Claim_Apr_ID,@Claim_Apr_Dtl_ID,@Sal_Tran_ID,@Claim_Status,@Claim_ID,@Claim_Apr_Date,@Claim_PetrolKM,@Claim_Apr_Amount,@Claim_Purpose,@Emp_ID,@S_Emp_ID,@Claim_App_Amnt)
	  
			 -- Add By Mukti 05072016(start)
				exec P9999_Audit_get @table = 'T0230_MONTHLY_CLAIM_PAYMENT_DETAIL' ,@key_column='Claim_Pay_Dtl_ID',@key_Values=@Claim_Pay_Detail_ID,@String=@String output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
			 -- Add By Mukti 05072016(end)	
	  end
 else if UPPER(@Tran_Type) = 'U'
		begin
			select @Claim_Pay_Detail_ID = Isnull(max(Claim_Pay_Dtl_ID),0) + 1  From T0230_MONTHLY_CLAIM_PAYMENT_DETAIL WITH (NOLOCK)
			Insert Into T0230_MONTHLY_CLAIM_PAYMENT_DETAIL
		  (Claim_Pay_Dtl_ID,Claim_Pay_Id,Cmp_ID,Claim_Apr_Id,Claim_Apr_Dtl_ID,Sal_Tran_Id,Claim_Status,Claim_ID,Claim_Apr_Date,Claim_PetrolKM,Claim_Apr_Amnt,Claim_Purpose,Emp_ID,S_Emp_ID,Claim_App_Amount)
		  values
		  (@Claim_Pay_Detail_ID,@Claim_Pay_ID,@Cmp_ID,@Claim_Apr_ID,@Claim_Apr_Dtl_ID,@Sal_Tran_ID,@Claim_Status,@Claim_ID,@Claim_Apr_Date,@Claim_PetrolKM,@Claim_Apr_Amount,@Claim_Purpose,@Emp_ID,@S_Emp_ID,@Claim_App_Amnt)
		  
		   -- Add By Mukti 05072016(start)
				exec P9999_Audit_get @table = 'T0230_MONTHLY_CLAIM_PAYMENT_DETAIL' ,@key_column='Claim_Pay_Dtl_ID',@key_Values=@Claim_Pay_Detail_ID,@String=@String output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
		   -- Add By Mukti 05072016(end)	
		End
	exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Claim Payment Details',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
return

