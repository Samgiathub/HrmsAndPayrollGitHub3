  
CREATE PROCEDURE [dbo].[KPMS_SP0020_Insert_ApprovalStatusResult_Master]  
(  
@Status int,  
@Emp_ID int,   
@Cmp_ID int,
@rmid int  
)  
as  
  
BEGIN  
 IF NOT EXISTS(Select 1 From kpms_Approval_Result WHERE emp_id = @Emp_ID)
 BEGIN
	INSERT INTO [kpms_Approval_Result]  
    (      
     [apprr_Result],  
     [emp_id],  
     [rm_id],  
	 [cmp_id]
      )  
   VALUES  
      (      
     @Status,  
     @Emp_ID,  
     @rmid,
	 @Cmp_ID
    )  

 END
 ELSE
 BEGIN
 
		UPDATE [kpms_Approval_Result] SET 
				[apprr_Result] = @Status,  
			   [emp_id] = @Emp_ID,  
			   [rm_id] = @rmid
			   ,[cmp_id]=@Cmp_ID
 END
END



