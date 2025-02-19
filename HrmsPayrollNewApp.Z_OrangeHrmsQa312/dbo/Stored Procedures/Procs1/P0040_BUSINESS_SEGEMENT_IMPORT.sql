

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 04-Sep-2015
-- Description:	To Import Business Segment Detail from Excel Sheet
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_BUSINESS_SEGEMENT_IMPORT]
	@Cmp_ID numeric(18,0), 
	@Segment_Code varchar(50),
	@Segment_Name varchar(100),
	@Segment_Description varchar(250),
	@Log_Status	int =0 output,
	@Row_No int =0 Output,
	@GUID Varchar(2000) --Added by Nilesh patel on 13062016
AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	IF (IsNull(@Segment_Name,'') = '')
	
		begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Segment Name is required',@Segment_Name,'Enter segment Name.',GETDATE(),'Business Segment',@GUID)
			--RAISERROR('@@Segment Name is required@@',16,2)
			RETURN				
		end
	IF (IsNull(@Segment_Code,'') = '')
	
		begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Segment Code is required',@Segment_Code,'Enter segment Code.',GETDATE(),'Business Segment',@GUID)
			--RAISERROR('@@Segment Code is required@@',16,2)
			RETURN	
		end

	IF EXISTS (Select Segment_ID  from T0040_business_Segment WITH (NOLOCK) Where Upper(Segment_Name) = Upper(@Segment_Name) and Cmp_ID = @Cmp_ID) 
		begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Segment Name already exists',@Segment_Name,'Enter unique segment Name.',GETDATE(),'Business Segment',@GUID)
			--RAISERROR('@@Segment Name is already Exists@@',16,2)
			RETURN				
		end
	IF EXISTS (SELECT Segment_ID  from T0040_business_Segment WITH (NOLOCK) Where Upper(Segment_Code) = Upper(@Segment_Code) and Cmp_ID = @Cmp_ID) 
		BEGIN
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Segment Code already exists',@Segment_Code,'Enter unique segment code.',GETDATE(),'Business Segment',@GUID)
			--RAISERROR('@@Segment Code is already Exists@@',16,2)
			RETURN	
		END
    
    DECLARE @Segment_ID NUMERIC(18,0);
    
    SELECT @Segment_ID = isnull(max(Segment_ID),0) + 1 from T0040_business_Segment WITH (NOLOCK)
    
    INSERT INTO T0040_business_Segment
	                      (Segment_Id, Cmp_Id, Segment_Code, Segment_Name, Segment_Description)
	VALUES     (@Segment_ID,@Cmp_Id,@Segment_code,@Segment_Name, Isnull(@Segment_Description,''))
END

