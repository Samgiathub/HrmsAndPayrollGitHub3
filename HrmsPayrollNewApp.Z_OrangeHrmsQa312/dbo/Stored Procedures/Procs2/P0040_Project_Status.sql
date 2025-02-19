  
  
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE   PROCEDURE [dbo].[P0040_Project_Status]      
@Project_Status_ID NUMERIC output,      
@Project_Status VARCHAR(50),       
@Remarks VARCHAR(MAX),  
@Color nvarchar(50),       
@Cmp_ID numeric(18,0),       
@Created_By numeric(18,0),       
@Trans_Type varchar(1),
@Status_Type numeric =0
AS    
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
    set @Project_Status = dbo.fnc_ReverseHTMLTags(@Project_Status)  --added by ronak 120122    
	 set @Remarks = dbo.fnc_ReverseHTMLTags(@Remarks)  --added by ronak 120122    

 If @Trans_Type  = 'I'      
  Begin      
   If Exists (SELECT Project_Status_ID FROM T0040_Project_Status WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND UPPER(Project_Status) = UPPER(@Project_Status))      
    BEGIN      
     SET @Project_Status_ID = 0      
     RETURN      
    END      
   SELECT @Project_Status_ID = ISNULL(MAX(Project_Status_ID), 0) + 1 FROM T0040_Project_Status WITH (NOLOCK)     
   INSERT INTO T0040_Project_Status(Project_Status_ID,Project_Status,Remarks,Color,Cmp_ID,Created_By,Created_Date,Status_Type)VALUES      
   (@Project_Status_ID,@Project_Status,@Remarks,@Color,@Cmp_ID,@Created_By,GETDATE(),@Status_Type )      
  End      
 Else if @Trans_Type = 'U'      
  BEGIN     
   If Exists (SELECT Project_Status_ID FROM T0040_Project_Status WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND UPPER(Project_Status) = UPPER(@Project_Status) AND Project_Status_ID <> @Project_Status_ID)      
    BEGIN       
     SET @Project_Status_ID = 0      
     Return      
    END      
   UPDATE T0040_Project_Status SET Project_Status = @Project_Status,Remarks = @Remarks,Color=@Color,  
   Cmp_ID = @Cmp_ID,Modify_By = @Created_By,Modify_Date = GETDATE(), Status_Type = @Status_Type       
   WHERE Project_Status_ID = @Project_Status_ID  
  END      
    Else if @Trans_Type = 'D'      
  BEGIN      
   DELETE FROM T0040_Project_Status WHERE Project_Status_ID = @Project_Status_ID  
  END  
    
    
    
  