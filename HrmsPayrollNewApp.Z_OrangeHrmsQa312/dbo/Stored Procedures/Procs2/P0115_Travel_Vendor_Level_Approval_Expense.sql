
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0115_Travel_Vendor_Level_Approval_Expense]  
   @Tran_Id numeric(18,0) output 
  ,@cmp_id numeric(18, 0)    
  ,@Emp_ID numeric(18, 0)  
  ,@Travel_Approval_ID numeric(18, 0) 
  ,@Project_ID numeric(18, 0) 
  ,@Vendor_ID numeric(18, 0) 
  ,@Description varchar(max)  
  ,@Travel_Settlement_Id numeric(18, 0) 
  ,@Approved_Amount numeric(18,2)
  ,@Quantity Numeric(18,0)
  ,@Rate Numeric(18,0)
  ,@Tax_Cmnt_ID numeric(18,0)
  ,@Total_Amount numeric(18,2)  
  ,@Tax_Per numeric(18,2)
  ,@Self_Pay tinyint
  ,@Remarks varchar(max)
  ,@OrderTypeID numeric(18,0)=0
  ,@RptLevel numeric(18,0)=0
  ,@Manager_Emp_ID numeric(18,0)=0
  ,@tran_type  Varchar(1)   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
   
  if @tran_type ='I'   
   begin  
  select @Tran_Id  = Isnull(max(Tran_Id ),0) + 1 From T0115_Travel_Vendor_Level_Approval_Expense WITH (NOLOCK) --and cmp_ID=@Cmp_ID
           
   if Not Exists(select Travel_Approval_ID from T0115_Travel_Vendor_Level_Approval_Expense WITH (NOLOCK) where Travel_Approval_ID=@Travel_Approval_ID and Travel_Settlement_ID=@Travel_Settlement_Id and Project_ID=@Project_ID and Vendor_ID=@Vendor_ID and Item_Description=@Description and Quantity=@Quantity and Rate=@Rate and Amount=@Total_Amount and Approved_Amount=@Approved_Amount and Emp_ID=@Emp_ID and Order_Type_ID=@OrderTypeID and Rpt_Level=@RptLevel)
   Begin
	INSERT INTO T0115_Travel_Vendor_Level_Approval_Expense  
      (  
    Tran_ID,Cmp_ID,Emp_ID,Travel_Approval_Id,Project_ID,Vendor_ID,Item_Description,
    Travel_Settlement_Id,Quantity,rate,Tax_Component_ID,Tax_Per,
    Amount,Approved_Amount,Self_Pay,Remarks,
    Order_Type_ID,Modify_Date,Rpt_Level,Manager_Emp_ID
    
    
      )  
      VALUES        
      (@Tran_Id
       ,@cmp_id
       ,@Emp_ID
       ,@Travel_Approval_ID
       ,@Project_ID
       ,@Vendor_ID
       ,@Description
       ,@Travel_Settlement_Id
       ,@Quantity
       ,@Rate
       ,@Tax_Cmnt_ID
       ,@Tax_Per
       ,@Total_Amount
       ,@Approved_Amount
       ,@Self_Pay
       ,@Remarks
       ,@OrderTypeID
       ,GETDATE()
       ,@RptLevel
       ,@Manager_Emp_ID
       )         
   End   
       
   
 END  
 
  else if @tran_type ='D'  
  begin  
  
  delete from T0115_Travel_Vendor_Level_Approval_Expense where emp_id=@Emp_ID and Travel_Approval_ID = @Travel_Approval_ID  and Tran_ID=@Tran_Id 
  
  end
  
 RETURN  
  
  
  

