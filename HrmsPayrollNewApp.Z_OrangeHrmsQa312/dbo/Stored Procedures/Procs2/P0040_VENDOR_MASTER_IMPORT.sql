
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_VENDOR_MASTER_IMPORT]
 @Vendor_Id		NUMERIC OUTPUT
,@Cmp_ID		NUMERIC
,@Vendor_Name	VARCHAR(50)
,@Address	VARCHAR(150)
,@City	VARCHAR(150)
,@Contact_Person	VARCHAR(150)
,@Contact_Number	VARCHAR(150)
,@User_Id numeric(18,0) = 0
,@IP_Address varchar(30)= ''
,@Log_Status Int = 0 Output
,@Row_No Int
,@GUID Varchar(2000) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	BEGIN
		if @Vendor_Name = ''
			Begin
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Enter Valid Vendor Details',0,'Enter Valid Vendor Details',GetDate(),'Vendor Master',@GUID)						
				SET @Log_Status=1
				return
			End 
		if exists(select Vendor_Id from t0040_vendor_master WITH (NOLOCK) where upper(Vendor_Name) = upper(@Vendor_Name) and Cmp_id = @Cmp_id	)
			Begin
			
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Already Exist Vendor Name',0,'Enter Proper Vendor Name',GetDate(),'Vendor Master',@GUID)						
				SET @Log_Status=1
				return
			End
								
		select @Vendor_Id = isnull(max(Vendor_Id),0) + 1  from t0040_vendor_master	WITH (NOLOCK)
	    
		insert into t0040_vendor_master (Vendor_Id,Vendor_Name,[Address],City,Contact_Person,Contact_Number,Cmp_ID)
		Values(@Vendor_Id,@Vendor_Name,@Address,@City,@Contact_Person,@Contact_Number,@Cmp_ID)
				
	END		

RETURN




