
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
Create PROCEDURE [dbo].[P0030_City_Master_Import_backup_sandip_11102024] 
	 @Cmp_Id		NUMERIC(18,0)
	,@City_Name   VARCHAR(100)			
	,@State   varchar(100)
	,@City_Category	varchar(200)=''	
	,@Row_No		INT = 0
	,@Log_Status	INT = 0 OUTPUT
	,@GUID  varchar(2000) = ''
	,@Entry_Type varchar(20)='Insert'
AS 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @Tran_ID	AS NUMERIC(18,0)
	DECLARE @State_ID as Numeric(18,0)		
    declare @City_Cat_ID as numeric(18,0)
    Declare @Loc_ID as numeric(18,0)
    
    Set @Tran_ID = 0
    Set @State_ID = 0	
	set @City_Cat_ID=0	
	set @Loc_ID=0
	
	if (@Entry_Type='')
		Begin
			set @Entry_Type='Insert'
		End
	
	if @City_Name = '' 
		Begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'City Name is not Provided',@State,'Enter proper City',GETDATE(),'City Master',@GUID)
			RETURN	
		End		
	
	if @State = '' 
		Begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'State Name Doesn''t exists',@State,'Enter proper State Name',GETDATE(),'City Master',@GUID)
			RETURN	
		End	
		
	
		
	select @State_ID=isnull(State_ID,0) from T0020_STATE_MASTER WITH (NOLOCK) where CMP_ID=@Cmp_Id and State_Name=@State
	select @City_Cat_ID=ISNULL(city_cat_ID,0) from T0040_City_Category_Master WITH (NOLOCK) where Cmp_ID=@Cmp_Id and City_Cat_Name=@City_Category
	
	   if ISNULL(@State_ID,0)=0
	   begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'State Name Doesn''t exists',@State,'Enter proper State Name',GETDATE(),'City Master',@GUID)
			--RAISERROR('@@State is not Exists in System@@',16,2)
			RETURN	
	   end
	   Else
		Begin
			Select @Loc_ID=Loc_ID from T0020_STATE_MASTER WITH (NOLOCK) where State_ID=@State_ID
		End
	   
	   if @City_Cat_ID=0
		begin
		 	Exec P0040_City_Category_Master 0,@Cmp_ID,0,@City_Category,'','I'
			select @City_Cat_ID=City_Cat_ID from T0040_City_Category_Master WITH (NOLOCK) where City_Cat_Name=@City_Category
			
		End
	IF EXISTS (SELECT 1 FROM T0030_CITY_MASTER WITH (NOLOCK) WHERE City_Name=@City_Name and State_id=@State_ID and @Entry_Type='Insert')
		Begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'City Name Already exists for this State',@City_Name,'Enter proper City Name',GETDATE(),'City Master',@GUID)
			--RAISERROR('@@City already Exists for this State@@',16,2)
			RETURN
		End
	Else
		Begin
			if (@Entry_Type='Update') --For Update City with City Category
				Begin
					Update T0030_CITY_MASTER set City_Cat_ID=@City_Cat_ID where City_Name=@City_Name and State_ID=@State_ID 
					and Cmp_ID=@Cmp_ID
				End
			Else
				Begin
					select @Tran_ID = isnull(max(City_ID),0) + 1 from T0030_CITY_MASTER WITH (NOLOCK)
			
					INSERT INTO T0030_CITY_MASTER
								   (City_ID,City_Name,Cmp_ID,City_cat_ID,State_id,Loc_ID,Remarks)
						VALUES     (@Tran_ID,@City_Name,@Cmp_ID,@City_Cat_ID,@State_ID,@Loc_ID,'')	
				End
		End

