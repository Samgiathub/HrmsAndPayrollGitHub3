


---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_ASSET_MASTER_IMPORT]
 @Asset_ID		NUMERIC OUTPUT
,@Cmp_ID		NUMERIC
,@Asset_Name	VARCHAR(50)
,@Asset_Desc	VARCHAR(150)
,@Tran_type	CHAR(1)
,@User_Id numeric(18,0) = 0
,@IP_Address varchar(30)= ''
,@Asset_Code	VARCHAR(10)
,@Log_Status Int = 0 Output
,@Row_No Int
,@GUID Varchar(2000) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


IF @Tran_type = 'I'
	BEGIN
		if @Asset_Name = ''
			Begin
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Enter Valid details of Asset Name',0,'Enter Valid details of Asset Name',GetDate(),'Asset Master',@GUID)
				return						
			End
		if @Asset_Code = ''
			Begin
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Enter Valid details of Asset Code',0,'Enter Valid details of Asset Code',GetDate(),'Asset Master',@GUID)
				return						
			End
		if exists(select Asset_ID from t0040_Asset_master WITH (NOLOCK) where upper(Asset_Name) = upper(@Asset_name) and Cmp_id = @Cmp_id	)
			Begin
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Already Exist Asset Name',0,'Enter Proper Asset Name',GetDate(),'Asset Master',@GUID)						
				--SET @Log_Status=1
			return
			End
		if exists(select Asset_ID from t0040_Asset_master WITH (NOLOCK) where upper(Code) = upper(@Asset_Code) and Cmp_id = @Cmp_id)
			Begin
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Already Exist Asset Code',0,'Enter Proper Asset Code',GetDate(),'Asset Master',@GUID)						
				--SET @Log_Status=1
				return
			End
		select @Asset_ID = isnull(max(Asset_ID),0) + 1  from t0040_Asset_Master	WITH (NOLOCK)
			
		insert into T0040_ASSET_MASTER (Asset_ID,Cmp_ID,Asset_Name,Asset_Desc,Code)
		Values(@Asset_ID,@Cmp_ID,@Asset_Name,@Asset_Desc,@Asset_Code)
				
	END		

RETURN




