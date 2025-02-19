




--ALTER BY NILAY : 05 -MAR-2010  
--INSER THE THE TABLE T0110_TRAINING_APPLICATION_DETAIL  
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[p0110_training_application_detail]  
@Training_App_detail_Id numeric(18,0)   
,@Training_App_Id numeric(18,0)  
,@Emp_ID numeric(18,0)  
,@tran_type varchar(1)  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
--change on 18-mar-2010 falak


if @tran_type = 'I'  
 Begin  
      if Not Exists ( select Tran_App_detail_ID from t0110_training_application_detail WITH (NOLOCK) where Emp_Id = @Emp_ID and Training_App_Id =@Training_App_Id)  
        Begin  
           
          select @Training_App_detail_Id = Isnull(max(Tran_App_detail_ID),0) + 1  From t0110_training_application_detail WITH (NOLOCK) 

	 if  @Training_App_Id = 0
            Begin
		select @Training_App_Id = Isnull(max(Training_App_Id),0) + 1  From T0100_Training_Application WITH (NOLOCK)
                             
		   INSERT INTO t0110_training_application_detail  
                        (Tran_App_detail_ID,Training_App_Id,Emp_ID)  
         		VALUES     (@Training_App_detail_Id,@Training_App_Id,@Emp_ID)  

            End
         else
            Begin 
 
		 INSERT INTO t0110_training_application_detail  
                        (Tran_App_detail_ID,Training_App_Id,Emp_ID)  
         		VALUES     (@Training_App_detail_Id,@Training_App_Id,@Emp_ID)  

            End
      End   
 End  
   
else if @tran_type = 'U'  
 Begin  
   
     
     if Not Exists ( select Tran_App_detail_ID from t0110_training_application_detail WITH (NOLOCK) where Emp_Id = @Emp_ID and Training_App_Id =@Training_App_Id)  
      Begin  
        select @Training_App_detail_Id = Isnull(max(Tran_App_detail_ID),0) + 1  From t0110_training_application_detail  WITH (NOLOCK)
      
        INSERT INTO t0110_training_application_detail  
                          (Tran_App_detail_ID,Training_App_Id,Emp_ID)  
        VALUES     (@Training_App_detail_Id,@Training_App_Id,@Emp_ID)  
      End        
      
     
 End  
   
else if @tran_type = 'D'  
 Begin  
      
      Delete from t0110_training_application_detail Where Training_App_Id=@Training_App_Id and Emp_ID=@Emp_ID  
            
 End  
RETURN  
  
  


