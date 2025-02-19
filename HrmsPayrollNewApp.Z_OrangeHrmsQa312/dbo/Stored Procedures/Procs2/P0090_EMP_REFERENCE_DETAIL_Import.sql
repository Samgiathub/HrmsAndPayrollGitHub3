

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_REFERENCE_DETAIL_Import]

@Alpha_Emp_Code	varchar(100),
@Cmp_ID			numeric(18, 0),
@Source_Type	varchar(500),
@Reference_Date	datetime,
@Source_Name	varchar(500),
@Reference_Amount	numeric(18, 2),
@Month	numeric(18, 0)= 0,
@Year	numeric(18, 0) = 0,
@Log_Status numeric(18, 0) output,
@Row_No  numeric(18, 0),
@GUID   Varchar(2000) = '' --Added by Nilesh Patel on 16062016
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @EMP_ID NUMERIC(18,0);
	DECLARE @R_EMP_ID NUMERIC(18,0);
	DECLARE @Reference_ID Numeric(18,0);		
	DECLARE @MODULE VARCHAR(20);
	DECLARE @Source_Id as Numeric(18,0);
	DECLARE @Source_Name_Id as Numeric(18,0);
	DECLARE @Group_Company as Numeric(18,0);
		
	SET @MODULE = 'Reference Import';
		
	SET @EMP_ID = NULL;
	SET @R_EMP_ID = 0;
	SET @Source_Id = 0
	Set @Group_Company = 0
	Set @Source_Name_Id = NULL
	
	if @Month = 0 
		Set @Month = NULL
	
	if @Year = 0 
		Set @Year = NULL
	
	
	SELECT @EMP_ID=EMP_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code=@Alpha_Emp_Code And Cmp_ID=@Cmp_ID
	SELECT @Source_Id = Isnull(Source_Type_Id,0)  From T0030_Source_Type_Master WITH (NOLOCK) where Source_Type_Name = @Source_Type	
	
	IF ISNULL(@EMP_ID,0) =0
		BEGIN
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Employee Doesn''t exists',@Alpha_Emp_Code,'Enter proper Employee Code',GetDate(),@MODULE,@GUID)			
			RETURN
		END
	
	IF ISNULL(@Source_Id,0) = 0
		BEGIN
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Source Type Doesn''t exists',@Alpha_Emp_Code,'Please Enter Proper Source Type Details',GetDate(),@MODULE,@GUID)			
			RETURN
		END
	Else
		Begin
			If @Source_Id = 2 
				Begin
					SELECT @Group_Company = is_GroupOFCmp FROM T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id= @Cmp_ID
					
					if @Group_Company = 1 
						Begin
							Select @R_EMP_ID = Emp_ID  From T0080_EMP_MASTER EM WITH (NOLOCK) inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK)
							on EM.Cmp_ID = CM.Cmp_Id
							--Where Alpha_Emp_Code = @Source_Name and CM.Cmp_Id = @Cmp_ID and CM.is_GroupOFCmp = 1
							Where Alpha_Emp_Code = @Source_Name and CM.is_GroupOFCmp = 1
							
							IF ISNULL(@R_EMP_ID,0) =0
							BEGIN
								SET @Log_Status=1
								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Reference Employee Doesn''t exists',@Alpha_Emp_Code,'Enter valid Reference Employee Details',GetDate(),@MODULE,@GUID)			
								RETURN
							END
						End 
					Else
						Begin
							Select @R_EMP_ID = Emp_ID From T0080_EMP_MASTER Where Alpha_Emp_Code = @Source_Name and Cmp_ID = @Cmp_ID
					
							IF ISNULL(@R_EMP_ID,0) =0
							BEGIN
								SET @Log_Status=1
								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Reference Employee Doesn''t exists',@Alpha_Emp_Code,'Enter valid Reference Employee Details',GetDate(),@MODULE,@GUID)			
								RETURN
							END
						End 
				End
			Else
				Begin
					
					SELECT @Source_Name_Id = Source_Id FROM T0040_Source_Master WITH (NOLOCK) where Source_Name = @Source_Name AND Source_type_id = @Source_Id
					IF ISNULL(@Source_Name_Id,0) =0
							BEGIN
								SET @Log_Status=1
								INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Source Name Doesn''t exists',@Alpha_Emp_Code,'Enter valid Source Name',GetDate(),@MODULE,@GUID)			
								RETURN
							END
					--IF @Source_Name_Id = 0
					--	Set @Source_Name_Id = NULL
				End  
		End 
		
	if @Reference_Date is null
		BEGIN
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Reference Date',@Alpha_Emp_Code,'Reference Date cannot be blank',GetDate(),@MODULE,@GUID)			
			RETURN
		END
	
			
			Set @Reference_ID = 0
			Select @Reference_ID = isnull(max(Reference_ID),0) + 1 from T0090_EMP_REFERENCE_DETAIL WITH (NOLOCK)
			
			Insert Into T0090_EMP_REFERENCE_DETAIL(Reference_ID,Cmp_ID,Emp_ID,R_Emp_ID,For_Date,Ref_Description,Amount,Comments,Contact_Person,Mobile,Designation,City,Source_Type,Source_Name,Ref_Month,Ref_Year)
			Values (@Reference_ID,@Cmp_ID,isnull(@EMP_ID,0),@R_EMP_ID,@Reference_Date,NULL,@Reference_Amount,NULL,NULL,NULL,NULL,NULL,@Source_Id,isnull(@Source_Name_Id,0),@Month,@Year)
	
END


