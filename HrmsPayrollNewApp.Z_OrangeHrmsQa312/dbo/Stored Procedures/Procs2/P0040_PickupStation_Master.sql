  
  
   
 ---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_PickupStation_Master]  
  
 @Pickup_ID numeric(18,0) OUTPUT,  
 @Pickup_Name varchar(50),   
 @Route_ID numeric(18,0),   
 @Pickup_KM numeric(18,2),  
 @Effective_Date datetime,  
 @Cmp_ID numeric(18,0),  
 @Login_ID numeric(18,0),  
 @Trans_Type char(1)  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  

   set @Pickup_Name = dbo.fnc_ReverseHTMLTags(@Pickup_Name)  --added by Ronak 021121  

IF @Trans_Type  = 'I'  
 BEGIN  
  IF EXISTS(SELECT Pickup_ID FROM T0040_PickupStation_Master WITH (NOLOCK) WHERE UPPER(Pickup_Name) = UPPER(@Pickup_Name) AND Route_ID = @Route_ID)   
   BEGIN    
    SET @Pickup_ID = 0    
    RETURN    
   END  
  SELECT @Pickup_ID = ISNULL(MAX(Pickup_ID),0)+1 FROM T0040_PickupStation_Master WITH (NOLOCK)  
    
  INSERT INTO T0040_PickupStation_Master(Pickup_ID,Pickup_Name,Route_ID,Pickup_KM,Effective_Date,Cmp_ID,Created_By,Created_Date)  
  VALUES(@Pickup_ID,@Pickup_Name,@Route_ID,@Pickup_KM,@Effective_Date,@Cmp_ID,@Login_ID,GETDATE())  
 END  
ELSE IF @Trans_Type  = 'U'  
 BEGIN  
  IF EXISTS(SELECT Pickup_ID FROM T0040_PickupStation_Master WITH (NOLOCK) WHERE Pickup_ID <> @Pickup_ID AND UPPER(Pickup_Name) = UPPER(@Pickup_Name) AND Route_ID = @Route_ID)   
   BEGIN    
    SET @Pickup_ID = 0    
    RETURN    
   END  
    
  UPDATE T0040_PickupStation_Master SET Pickup_Name = @Pickup_Name,Route_ID = @Route_ID,Pickup_KM = @Pickup_KM,  
  Effective_Date = @Effective_Date,Cmp_ID = @Cmp_ID,Modified_By = @Login_ID,Modified_Date = GETDATE()  
  WHERE Pickup_ID = @Pickup_ID  
 END  
ELSE IF @Trans_Type  = 'D'  
 BEGIN  
  DELETE FROM T0040_PickupStation_Master WHERE Pickup_ID = @Pickup_ID  
 END  