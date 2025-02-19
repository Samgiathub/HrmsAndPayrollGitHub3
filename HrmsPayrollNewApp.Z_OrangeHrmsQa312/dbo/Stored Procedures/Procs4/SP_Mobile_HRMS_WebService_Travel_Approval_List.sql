    
CREATE  PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Travel_Approval_List]                   
 @Cmp_Id int,    
 @Emp_ID Numeric(18,0),    
 @Rpt_level Numeric(18,0),    
 @StrType char,    
 @Constrains Nvarchar(max)=N'Application_Status = ''P''',    
 @Type Numeric(18,0) = 0,    
 @OrderBy varchar(500) = 'Order by Application_Date desc'    
AS                        
BEGIN      
    
DECLARE @VAL INT    
     
 Select @VAL = Setting_Value from T0040_SETTING where Setting_Name = 'Enable Travel Type in Travel Module / Travel Expense' and Cmp_ID = @Cmp_ID    
    
 IF(@VAL = 0)    
     
   BEGIN    
       
     EXEC SP_Mobile_HRMS_WebService_Travel_Approval_List_wITHOUT_TYPE @Emp_Id=@Emp_ID ,@Cmp_Id=@Cmp_Id ,@StrType=@StrType ,@Rpt_level = @Rpt_level,@Type=@Type    
   END    
 ELSE     
     
   BEGIN    
     
     EXEC SP_Mobile_HRMS_WebService_Travel_Approval_List_wITH_TYPE @Emp_Id=@Emp_ID ,@Cmp_Id=@Cmp_Id ,@StrType=@StrType ,@Rpt_level = @Rpt_level,@Type= @Type    
   END    
     
END 