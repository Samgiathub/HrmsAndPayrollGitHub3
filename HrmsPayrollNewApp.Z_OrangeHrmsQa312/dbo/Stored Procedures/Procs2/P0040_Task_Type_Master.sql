  
  
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE  PROCEDURE [dbo].[P0040_Task_Type_Master]      
@Task_Type_ID NUMERIC output,      
@TaskType_Name VARCHAR(50),       
@TaskType_Description VARCHAR(MAX),       
@Cmp_ID numeric(18,0),       
@Created_By numeric(18,0),       
@Trans_Type varchar(1)      
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  

   set @TaskType_Name = dbo.fnc_ReverseHTMLTags(@TaskType_Name) --Ronak_060121
   set @TaskType_Description = dbo.fnc_ReverseHTMLTags(@TaskType_Description) --Ronak_060121
 If @Trans_Type  = 'I'      
  Begin      
   If Exists (SELECT Task_Type_ID FROM T0040_Task_Type_Master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND UPPER(TaskType_Name) = UPPER(@TaskType_Name))      
    BEGIN      
     SET @Task_Type_ID = 0      
     RETURN      
    END      
   SELECT @Task_Type_ID = ISNULL(MAX(Task_Type_ID), 0) + 1 FROM T0040_Task_Type_Master WITH (NOLOCK)     
   INSERT INTO T0040_Task_Type_Master(Task_Type_ID, TaskType_Name, TaskType_Description,Cmp_ID,Created_By,Created_Date)VALUES      
   (@Task_Type_ID,@TaskType_Name,@TaskType_Description,@Cmp_ID,@Created_By,GETDATE() )      
  End      
 Else if @Trans_Type = 'U'      
  BEGIN     
   If Exists (SELECT Task_Type_ID FROM T0040_Task_Type_Master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND UPPER(TaskType_Name) = UPPER(@TaskType_Name) AND Task_Type_ID <> @Task_Type_ID)      
    BEGIN       
     SET @Task_Type_ID = 0      
     Return      
    END      
   UPDATE T0040_Task_Type_Master SET TaskType_Name = @TaskType_Name,TaskType_Description = @TaskType_Description,  
   Cmp_ID = @Cmp_ID,Modify_By = @Created_By,Modify_Date = GETDATE()       
   WHERE Task_Type_ID = @Task_Type_ID  
  END      
    Else if @Trans_Type = 'D'      
  BEGIN      
   DELETE FROM T0040_Task_Type_Master WHERE Task_Type_ID = @Task_Type_ID  
  END  
    
    
    
  