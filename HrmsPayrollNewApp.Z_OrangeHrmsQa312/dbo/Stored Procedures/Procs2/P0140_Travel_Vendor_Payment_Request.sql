
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0140_Travel_Vendor_Payment_Request]     
   @Tran_Id numeric(18, 0) OUTPUT  
  ,@Travel_Approval_ID numeric(18, 0) 
  ,@cmp_id numeric(18, 0)  
  ,@Emp_ID numeric(18, 0)  
  ,@Project_ID numeric(18,0)
  ,@Vendor_ID numeric(18,0)
  ,@Description varchar(max)  
  ,@Quantity numeric(18,2) = 0
  ,@Rate numeric(18,2) = 0
  ,@Tax_Component numeric(18,2) = 0
  ,@Tax_Per numeric(18,2) = 0  
  ,@Total_Amount Numeric(18,2)
  ,@Remarks varchar(max)
  ,@SelfPay tinyint=0  
  ,@OrderTypeID numeric(18,0)=0  
  ,@tran_type  Varchar(1)     
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
     
  if @tran_type ='I'   
   begin  
   
  select @Tran_Id  = Isnull(max(Tran_Id ),0) + 1 From T0140_Travel_Vendor_Expense_Request  WITH (NOLOCK)          
   if Not Exists(select Travel_approval_id from T0140_Travel_Vendor_Expense_Request WITH (NOLOCK) where Travel_Approval_ID=@Travel_Approval_ID and emp_id=@Emp_ID and Project_ID=@Project_ID and Vendor_ID=@Vendor_ID and Total_Amount=@Total_Amount and Order_Type_ID=@OrderTypeID)
	Begin     
		INSERT INTO T0140_Travel_Vendor_Expense_Request  
			(  
			Tran_ID,Travel_Approval_Id,Emp_ID,Cmp_ID,Project_ID,Vendor_ID,Tax_Components,
			Description,Quantity,Rate,Tax_Percentage,Total_Amount,Remarks,Self_Pay,
			Order_Type_ID,Modify_Date)  
			  VALUES        
			  (@Tran_Id  
			   ,@Travel_Approval_ID  
			   ,@Emp_ID 
			   ,@Cmp_ID 
			   ,@Project_ID
			   ,@Vendor_ID
			   ,@Tax_Component
			   ,@Description
			   ,@Quantity
			   ,@Rate
			   ,@Tax_Per
			   ,@Total_Amount
			   ,@Remarks
			   ,@SelfPay  			   
			   ,@OrderTypeID
			   ,GETDATE()
			   )  
       
	End
 END  
 else if @tran_type ='U'   
    begin  
     
     update T0140_Travel_Vendor_Expense_Request   
     set  
     Project_ID = @Project_ID,
     Vendor_ID=@Vendor_ID,
     Tax_Components=@Tax_Component,
     Description=@Description,
     Quantity=@Quantity,
     Rate=@Rate,
     Tax_Percentage=@Tax_Per,
     Total_Amount=@Total_Amount,
     Remarks=@Remarks,
     Self_Pay=@SelfPay, 
     Order_Type_ID=@OrderTypeID,
     modify_date=GETDATE()   
     where   
     emp_id=@Emp_ID and Travel_Approval_ID = @Travel_Approval_ID  and Tran_ID=@Tran_Id
    end  
  else if @tran_type ='D'  
  begin  
	delete from T0140_Travel_Vendor_Expense_Request where emp_id=@Emp_ID and Travel_Approval_ID = @Travel_Approval_ID  and Tran_ID=@Tran_Id  
  end
  
 RETURN  
  
  
  

