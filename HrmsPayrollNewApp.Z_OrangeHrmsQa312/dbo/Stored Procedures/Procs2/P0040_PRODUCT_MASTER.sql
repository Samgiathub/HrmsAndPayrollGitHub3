CREATE PROCEDURE [dbo].[P0040_PRODUCT_MASTER]  
 @Product_ID AS NUMERIC output,  
 @Product_Name AS VARCHAR(100),  
 @User_Id AS NUMERIC(18,0),  
 @Cmp_ID AS NUMERIC,  
 @tran_type AS CHAR  
AS  
 SET NOCOUNT ON;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
 SET ARITHABORT ON;  
    set @Product_Name = dbo.fnc_ReverseHTMLTags(@Product_Name)  --added by Ronak 100121 
 IF @tran_type  = 'I'  
  Begin  
   IF exists (SELECT 1 FROM T0040_PRODUCT_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Product_Name = @Product_Name)  
    BEGIN  
     RAISERROR('@@ Product Name Exists @@',16,2)  
     RETURN   
    END  
   ElSE  
    BEGIN  
     INSERT INTO T0040_PRODUCT_MASTER (Cmp_ID,Login_ID,Product_Name,System_Date)   
     VALUES (@Cmp_ID,@User_Id,@Product_Name,getdate())  
     set @Product_ID = @@IDENTITY  
     return  
    END  
  End  
 ELSE IF @Tran_Type = 'U'  
  BEGIN  
   UPDATE T0040_PRODUCT_MASTER  
   SET  Product_Name = @Product_Name  
     ,Login_ID = @User_Id  
     ,System_Date = getdate()  
   WHERE Product_ID = @Product_ID and Cmp_ID = @CMP_ID  
   return   
  END  
 ELSE IF @Tran_Type = 'D'  
  BEGIN  
    IF EXISTS(SELECT 1 FROM T0040_SubProduct_Master WITH (NOLOCK) WHERE Product_ID = @Product_ID and Cmp_ID = @CMP_ID)  
     BEGIN  
      RAISERROR('@@ Reference Exits @@',16,2)  
      RETURN   
     END  
    DELETE FROM T0040_PRODUCT_MASTER WHERE Product_ID = @Product_ID and Cmp_ID = @CMP_ID      
    return   
  END   
RETURN