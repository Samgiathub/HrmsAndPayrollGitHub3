CREATE PROCEDURE [dbo].[P0040_SUBPRODUCT_MASTER]  
 @SubProduct_ID AS NUMERIC output,  
 @Product_ID AS NUMERIC ,  
 @Cmp_ID AS NUMERIC,  
 @User_Id AS NUMERIC(18,0),  
 @SubProduct_Name AS VARCHAR(100),  
 @Unit AS VARCHAR(100),  
 @tran_type AS CHAR  
AS  
 SET NOCOUNT ON;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
 SET ARITHABORT ON;  
   set @SubProduct_Name = dbo.fnc_ReverseHTMLTags(@SubProduct_Name)  --added by Ronak 100121 
 IF @tran_type  = 'I'  
  Begin  
   IF exists (SELECT 1 FROM T0040_SUBPRODUCT_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND SubProduct_Name = @SubProduct_Name)  
    BEGIN  
     RAISERROR('@@ SubProduct Name Exists @@',16,2)  
     RETURN   
    END  
   ElSE  
    BEGIN  
     INSERT INTO T0040_SUBPRODUCT_MASTER (Product_ID,Cmp_ID,Login_ID,SubProduct_Name,Unit,System_Date)   
     VALUES (@Product_ID,@Cmp_ID,@User_Id,@SubProduct_Name,@Unit,getdate())  
     SET @SubProduct_ID = @@IDENTITY  
     RETURN  
    END  
  End  
 ELSE IF @Tran_Type = 'U'  
  BEGIN  
   UPDATE T0040_SUBPRODUCT_MASTER  
   SET  Product_ID = @Product_ID  
     ,SubProduct_Name = @SubProduct_Name  
     ,Login_ID = @User_Id  
     ,System_Date = getdate()  
     ,Unit = @Unit  
   WHERE SubProduct_ID = @SubProduct_ID and Cmp_ID = @CMP_ID  
   RETURN   
  END  
 ELSE IF @Tran_Type = 'D'  
  BEGIN  
    IF EXISTS(SELECT 1 FROM T0040_SubProduct_Master WITH (NOLOCK) WHERE Product_ID = @Product_ID and Cmp_ID = @CMP_ID)  
     BEGIN  
      RAISERROR('@@ Reference Exists @@',16,2)  
      RETURN   
     END  
    DELETE FROM T0040_SUBPRODUCT_MASTER WHERE SubProduct_ID = @SubProduct_ID and Cmp_ID = @CMP_ID   
    --SET @Product_ID = @@IDENTITY  
    RETURN   
  END   
RETURN