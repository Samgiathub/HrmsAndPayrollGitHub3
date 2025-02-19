

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 04-Sep-2015
-- Description:	To import cost center detail from excel sheet
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_COST_CENTER_MASTER_IMPORT] 
	-- Add the parameters for the stored procedure here
	@Cmp_ID numeric(18,0), 
	@Center_Code Varchar(50),
	@Center_Name Varchar(100),	
	@Cost_Element Varchar(50),
	@Log_Status	int =0 output,
	@Row_No int =0 Output,
	@GUID Varchar(2000)	= ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Set @Log_Status = 0;
    IF (IsNull(@Center_Name,'') = '')
		begin
			--SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Center Name is required',@Center_Name,'Enter Center Name.',GETDATE(),'Business Center',@GUID)
			--RAISERROR('@@Center Name is required@@',16,2)
			RETURN				
		end
	IF (IsNull(@Center_Code,'') = '')
		begin
			--SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Center Code is required',@Center_Code,'Enter Center Code.',GETDATE(),'Business Center',@GUID)
			--RAISERROR('@@Center Code is required@@',16,2)
			RETURN	
		end

	IF EXISTS (Select 1  from T0040_COST_CENTER_MASTER WITH (NOLOCK) Where Upper(Center_Name) = Upper(@Center_Name) and Cmp_ID = @Cmp_ID) 
		begin
			--SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Center Name already exists',@Center_Name,'Enter unique Center Name.',GETDATE(),'Business Center',@GUID)
			--RAISERROR('@@Center Name is already Exists@@',16,2)
			RETURN				
		end
	IF EXISTS (SELECT 1  from T0040_COST_CENTER_MASTER WITH (NOLOCK) Where Upper(Center_Code) = Upper(@Center_Code) and Cmp_ID = @Cmp_ID) 
		BEGIN
			--SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Center Code already exists',@Center_Code,'Enter unique Center code.',GETDATE(),'Business Center',@GUID)
			--RAISERROR('@@Center Code is already Exists@@',16,2)
			RETURN	
		END
	
	DECLARE @Center_ID NUMERIC(18,0);
	
	SELECT	@Center_ID = ISNULL(MAX(Center_ID),0) + 1 	
	FROM	T0040_COST_CENTER_MASTER WITH (NOLOCK) 
		
	INSERT INTO T0040_COST_CENTER_MASTER
	                      (Center_ID, Cmp_ID, Center_Name, Center_Code,Cost_Element)
	VALUES     (@Center_ID, @Cmp_ID, @Center_Name, @Center_Code,@Cost_Element)

END

