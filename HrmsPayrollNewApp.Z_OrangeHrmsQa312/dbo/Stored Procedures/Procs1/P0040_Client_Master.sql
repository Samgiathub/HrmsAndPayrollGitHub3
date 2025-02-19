  
  
 ---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_Client_Master]      
@Client_ID NUMERIC output,      
@Client_Name VARCHAR(50),       
@Client_Address VARCHAR(MAX),       
@Contact_Person VARCHAR(50),  
@Phone_No VARCHAR(50),  
@Mobile_No VARCHAR(50),  
@Email VARCHAR(50),  
@Cmp_ID numeric(18,0),       
@Created_By numeric(18,0),       
@Trans_Type varchar(1)      
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
   set @Client_Name = dbo.fnc_ReverseHTMLTags(@Client_Name) --Ronak_060121  
   set @Client_Address = dbo.fnc_ReverseHTMLTags(@Client_Address) --Ronak_060121   
     set @Contact_Person = dbo.fnc_ReverseHTMLTags(@Contact_Person) --Ronak_060121   
 If @Trans_Type  = 'I'      
  Begin      
   If Exists (SELECT Client_ID FROM T0040_Client_Master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND UPPER(Client_Name) = UPPER(@Client_Name))      
    BEGIN      
     SET @Client_ID = 0      
     RETURN      
    END      
   SELECT @Client_ID = ISNULL(MAX(Client_ID), 0) + 1 FROM T0040_Client_Master WITH (NOLOCK)     
   INSERT INTO T0040_Client_Master(Client_ID,Client_Name,Client_Address,Contact_Person,Phone_No,Mobile_No,Email,Cmp_ID,Created_By,Created_Date)VALUES      
   (@Client_ID,@Client_Name,@Client_Address,@Contact_Person,@Phone_No,@Mobile_No,@Email,@Cmp_ID,@Created_By,GETDATE() )      
  End      
 Else if @Trans_Type = 'U'      
  BEGIN     
   If Exists (SELECT Client_ID FROM T0040_Client_Master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND UPPER(Client_Name) = UPPER(@Client_Name) AND Client_ID <> @Client_ID)      
    BEGIN       
     SET @Client_ID = 0      
     Return      
    END      
   UPDATE T0040_Client_Master SET Client_Name = @Client_Name,Client_Address = @Client_Address,  
   Contact_Person =@Contact_Person,Phone_No = @Phone_No,Mobile_No=@Mobile_No,Email = @Email,  
   Cmp_ID = @Cmp_ID,Modify_By = @Created_By,Modify_Date = GETDATE()       
   WHERE Client_ID = @Client_ID  
  END      
    Else if @Trans_Type = 'D'      
  BEGIN      
   DELETE FROM T0040_Client_Master WHERE Client_ID = @Client_ID  
  END  
    
    
    
  