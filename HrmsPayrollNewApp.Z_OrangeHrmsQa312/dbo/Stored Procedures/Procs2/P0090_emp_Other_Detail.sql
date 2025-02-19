



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_emp_Other_Detail]   
 @Emp_Other_ID  numeric(18,0) output,  
 @Cmp_ID numeric(18,0),  
 @Emp_ID numeric(18,0),  
 @Salary_Acc_No varchar(50),  
 @Pan_No varchar(50),  
 @K11_Certifies numeric(18,0),  
 @Sales_Training numeric(18,0),  
 @Account_Training numeric(18,0),  
 @FCM_ID numeric(18,0),  
 @Induction_Training numeric(18,0),  
 @Uniform_Given numeric(18,0),  
 @CCM_ID numeric(18,0),  
 @Computer_Literacy numeric(18,0),
 @Interview_comments varchar(1000),
 
 @Tran_type   char(1)  
  
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  if  @Tran_type ='I'  
     Begin
     if exists(Select Emp_ID from T0090_emp_Other_Detail WITH (NOLOCK) where Emp_ID= @Emp_ID and Cmp_ID=@Cmp_ID)
	  Begin 
		set  @Emp_Other_ID=0
		return -1
	  end
     
     select @Emp_Other_ID = isnull(max(Emp_Other_ID),0) + 1 from T0090_Emp_Other_Detail  WITH (NOLOCK) 
  
      Insert Into T0090_Emp_Other_Detail  
       (Emp_Other_ID,Emp_ID,Cmp_ID,Salary_Acc_No,Pan_No,K11_Certifies,Sales_Training,Account_Training,Induction_Training  
    ,FCM_ID,CCM_ID,Uniform_Given,Compurter_Litercy,Interview_Comments)    
             values (@Emp_Other_ID,@Emp_ID,@Cmp_ID,@Salary_Acc_No,@Pan_No,@K11_Certifies,@Sales_Training,@Account_Training,@Induction_Training  
       ,@FCM_ID,@CCM_ID,@Uniform_Given,@Computer_Literacy,@Interview_comments)  
            
   end           
    
     
 Else if @Tran_type ='U'  
  Begin   
   Update T0090_Emp_Other_Detail set  
     
    Emp_Other_ID=@Emp_Other_ID,  
    Emp_ID=@Emp_ID,  
    Cmp_ID=@Cmp_ID,  
    Salary_Acc_No=@Salary_Acc_No,  
    Pan_No=@Pan_No,  
    K11_Certifies=@K11_Certifies,  
    Sales_Training=@Sales_Training,  
    Account_Training=@Account_Training,  
    Induction_Training=@Induction_Training,  
    FCM_ID=@FCM_ID,  
    CCM_ID=@CCM_ID,  
    Uniform_Given=@Uniform_Given,
    Compurter_Litercy=@Computer_Literacy,
    Interview_Comments=@Interview_comments
    
     where Emp_Other_ID=@Emp_Other_ID and Cmp_ID=@Cmp_ID  
  End    
   
Else if @Tran_type ='D'

   Delete from T0090_emp_Other_Detail where Emp_Other_ID=@Emp_Other_ID
   
  
 RETURN  
  
  
  

