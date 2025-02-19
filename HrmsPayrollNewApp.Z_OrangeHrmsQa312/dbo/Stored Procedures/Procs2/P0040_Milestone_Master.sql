  
  
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE  PROCEDURE [dbo].[P0040_Milestone_Master]      
@Milestone_ID NUMERIC output,      
@Milestone_Name VARCHAR(50),       
@Milestone_Description VARCHAR(MAX),       
@Cmp_ID numeric(18,0),       
@Created_By numeric(18,0),       
@Trans_Type varchar(1)      
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
   set @Milestone_Name = dbo.fnc_ReverseHTMLTags(@Milestone_Name) --Ronak_060121  
   set @Milestone_Description = dbo.fnc_ReverseHTMLTags(@Milestone_Description) --Ronak_060121  
 If @Trans_Type  = 'I'      
  Begin      
   If Exists (SELECT Milestone_ID FROM T0040_Milestone_Master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND UPPER(Milestone_Name) = UPPER(@Milestone_Name))      
    BEGIN      
     SET @Milestone_ID = 0      
     RETURN      
    END      
   SELECT @Milestone_ID = ISNULL(MAX(Milestone_ID), 0) + 1 FROM T0040_Milestone_Master WITH (NOLOCK)     
   INSERT INTO T0040_Milestone_Master(Milestone_ID,Milestone_Name,Milestone_Description,Cmp_ID,Created_By,Created_Date)VALUES      
   (@Milestone_ID,@Milestone_Name,@Milestone_Description,@Cmp_ID,@Created_By,GETDATE() )      
  End      
 Else if @Trans_Type = 'U'      
  BEGIN     
   If Exists (SELECT Milestone_ID FROM T0040_Milestone_Master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND UPPER(Milestone_Name) = UPPER(@Milestone_Name) AND Milestone_ID <> @Milestone_ID)      
    BEGIN       
     SET @Milestone_ID = 0      
     Return      
    END      
   UPDATE T0040_Milestone_Master SET Milestone_Name = @Milestone_Name,Milestone_Description = @Milestone_Description,  
   Cmp_ID = @Cmp_ID,Modify_By = @Created_By,Modify_Date = GETDATE()       
   WHERE Milestone_ID = @Milestone_ID  
  END      
    Else if @Trans_Type = 'D'      
  BEGIN      
   DELETE FROM T0040_Milestone_Master WHERE Milestone_ID = @Milestone_ID      
  END  
    
    
    
  