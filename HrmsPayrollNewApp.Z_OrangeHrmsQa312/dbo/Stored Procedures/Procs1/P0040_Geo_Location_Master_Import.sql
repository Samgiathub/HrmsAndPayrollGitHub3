  
  
 ---21/11/2023 (create BY Aswini ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_Geo_Location_Master_Import]  
 @Geo_Location_ID NUMERIC(18,0) OUTPUT,  
 @Cmp_ID NUMERIC(18,0),  
 @Geo_Location VARCHAR(MAX),  
 @Latitude VARCHAR(50),  
 @Longitude VARCHAR(50),  
 @Meter INT,  
 @Login_ID NUMERIC(18,0), 
 @Log_Status	int =0 output,
 @Row_No int =0 Output,
 @GUID Varchar(2000),   
 @Trans_Type varchar(1)      
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  

set @Latitude = Rtrim(Replace(REPLACE(@Latitude,'&deg;',''),'N',''))
set @Longitude = Rtrim(Replace(REPLACE(@Longitude,'&deg;',''),'E',''))


   set @Geo_Location = dbo.fnc_ReverseHTMLTags(@Geo_Location)  --added by Ronak 081021
   
   IF (@Geo_Location = '')
	
		begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Geo Location Name is required',@Geo_Location,'Enter Geo Location.',GETDATE(),'Geo Location Master',@GUID)
			
			RETURN				
		end
		IF (@Latitude = '')
	
		begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Latitude is required',@Latitude,'Enter Latitude.',GETDATE(),'Geo Location Master',@GUID)
			
			RETURN				
		end
		IF (@Longitude = '')
	
		begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Longitude is required',@Longitude,'Enter Longitude.',GETDATE(),'Geo Location Master',@GUID)
			
			RETURN				
		end



--IF EXISTS (SELECT Geo_Location_ID FROM T0040_Geo_Location_Master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND UPPER(Geo_Location) = UPPER(@Geo_Location) or lower(Geo_Location) = lower(@Geo_Location)AND Latitude = @Latitude AND Longitude = @Longitude) 
--		BEGIN
--			SET @Log_Status=1
--			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Geo location already exists',@Geo_Location,'Enter unique Geo Location.',GETDATE(),'Geo Location Master',@GUID)
--			--RAISERROR('@@Segment Code is already Exists@@',16,2)
--			RETURN	
--		END
--

IF @Trans_Type  = 'I'  
 BEGIN  
  IF EXISTS (SELECT Geo_Location_ID FROM T0040_Geo_Location_Master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND UPPER(Geo_Location) = UPPER(@Geo_Location) or lower(Geo_Location) = lower(@Geo_Location)AND Latitude = @Latitude AND Longitude = @Longitude)  
   
   BEGIN
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Geo location already exists',@Geo_Location,'Enter unique Geo Location.',GETDATE(),'Geo Location Master',@GUID)
			--RAISERROR('@@Segment Code is already Exists@@',16,2)
			RETURN     
   END  
 -- SELECT @Geo_Location_ID = ISNULL(MAX(Geo_Location_ID), 0) + 1 FROM T0040_Geo_Location_Master WITH (NOLOCK)  
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