  
  
 ---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
create PROCEDURE [dbo].[P0040_Geo_Location_Master_Aswini_04/11/2023]  
 @Geo_Location_ID NUMERIC(18,0) OUTPUT,  
 @Cmp_ID NUMERIC(18,0),  
 @Geo_Location VARCHAR(MAX),  
 @Latitude VARCHAR(50),  
 @Longitude VARCHAR(50),  
 @Meter INT,  
 @Login_ID NUMERIC(18,0),  
 @Trans_Type varchar(1)      
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  

set @Latitude = Rtrim(Replace(REPLACE(@Latitude,'&deg;',''),'N',''))
set @Longitude = Rtrim(Replace(REPLACE(@Longitude,'&deg;',''),'E',''))


   set @Geo_Location = dbo.fnc_ReverseHTMLTags(@Geo_Location)  --added by Ronak 081021
IF @Trans_Type  = 'I'  
 BEGIN  
  IF EXISTS (SELECT Geo_Location_ID FROM T0040_Geo_Location_Master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND UPPER(Geo_Location) = UPPER(@Geo_Location) and lower(Geo_Location) = lower(@Geo_Location)AND Latitude = @Latitude AND Longitude = @Longitude)  
   
   BEGIN      
    SET @Geo_Location_ID = 0      
    RETURN      
   END  
  SELECT @Geo_Location_ID = ISNULL(MAX(Geo_Location_ID), 0) + 1 FROM T0040_Geo_Location_Master WITH (NOLOCK)  
  INSERT INTO T0040_Geo_Location_Master(Geo_Location_ID,Cmp_ID,Geo_Location,Latitude,Longitude,Meter,Login_ID,System_Date)  
  VALUES(@Geo_Location_ID,@Cmp_ID,@Geo_Location,@Latitude,@Longitude,@Meter,@Login_ID,GETDATE())  
 END  
  
ELSE IF @Trans_Type  = 'U'  
 BEGIN  
  IF EXISTS (SELECT Geo_Location_ID FROM T0040_Geo_Location_Master WITH (NOLOCK) WHERE Geo_Location_ID <> @Geo_Location_ID AND Cmp_ID = @Cmp_ID AND UPPER(Geo_Location) = UPPER(@Geo_Location) AND Latitude = @Latitude AND Longitude = @Longitude)  
   BEGIN      
    SET @Geo_Location_ID = 0      
    RETURN      
   END  
  UPDATE T0040_Geo_Location_Master SET Cmp_ID = @Cmp_ID,Geo_Location = @Geo_Location,Latitude = @Latitude,  
  Longitude = @Longitude,Meter = @Meter,System_Date = GETDATE()  
  WHERE Geo_Location_ID = @Geo_Location_ID  
  END  
ELSE IF @Trans_Type  = 'D'  
 BEGIN  
  DELETE FROM T0040_Geo_Location_Master WHERE Geo_Location_ID = @Geo_Location_ID  
 END  