  
  
 ---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_Route_Master]  
  
 @Route_ID numeric(18,0) OUTPUT,  
 @Route_Name varchar(50),  
 @Route_No varchar(50),  
 @Route_KM numeric(18,2),  
 @Fuel_Place varchar(50),  
 @Vehicle_ID numeric(18,0),  
 @Effective_Date datetime,  
 @Cmp_ID numeric(18,0),  
 @Login_ID numeric(18,0),  
 @Trans_Type char(1)  
  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  

   set @Route_Name = dbo.fnc_ReverseHTMLTags(@Route_Name)  --added by Ronak 021121  
    set @Route_No = dbo.fnc_ReverseHTMLTags(@Route_No)  --added by Ronak 021121  
	  set @Fuel_Place = dbo.fnc_ReverseHTMLTags(@Fuel_Place)  --added by Ronak 021121  
IF @Trans_Type  = 'I'  
 BEGIN  
  IF EXISTS(SELECT Route_ID FROM T0040_Route_Master WITH (NOLOCK) WHERE UPPER(Route_Name) = UPPER(@Route_Name) AND UPPER(Route_No) = UPPER(@Route_No))    
   BEGIN    
    SET @Route_ID = 0    
    RETURN    
   END  
  SELECT @Route_ID = ISNULL(MAX(Route_ID),0)+1 FROM T0040_Route_Master WITH (NOLOCK)  
  INSERT INTO T0040_Route_Master(Route_ID,Route_Name,Route_No,Route_KM,Fuel_Place,Vehicle_ID,Effective_Date,Cmp_ID,Created_By,Created_Date)  
  VALUES(@Route_ID,@Route_Name,@Route_No,@Route_KM,@Fuel_Place,@Vehicle_ID,@Effective_Date,@Cmp_ID,@Login_ID,GETDATE())  
 END  
ELSE IF @Trans_Type  = 'U'  
 BEGIN  
  IF EXISTS(SELECT Route_ID FROM T0040_Route_Master WITH (NOLOCK) WHERE Route_ID <> @Route_ID AND UPPER(Route_Name) = UPPER(@Route_Name) AND UPPER(Route_No) = UPPER(@Route_No))   
   BEGIN    
    SET @Route_ID = 0    
    RETURN    
   END  
  UPDATE T0040_Route_Master SET Route_Name = @Route_Name,Route_No = @Route_No,Route_KM = @Route_KM,Fuel_Place = @Fuel_Place,Vehicle_ID = @Vehicle_ID,  
  Effective_Date = @Effective_Date,Cmp_ID = @Cmp_ID,Modified_By = @Login_ID,Modified_Date = GETDATE()  
  WHERE Route_ID = @Route_ID   
 END  
ELSE IF @Trans_Type  = 'D'  
 BEGIN  
  DELETE FROM T0040_Route_Master WHERE Route_ID = @Route_ID   
 END  