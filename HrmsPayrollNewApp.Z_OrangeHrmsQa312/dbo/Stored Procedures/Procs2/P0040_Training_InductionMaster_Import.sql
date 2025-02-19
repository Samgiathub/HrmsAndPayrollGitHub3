

CREATE  PROCEDURE [dbo].[P0040_Training_InductionMaster_Import] 	
	 @Department		varchar(200)
	,@Training_Topic	varchar(300)		
	,@Cmp_Id	        Numeric(18,0)
	,@Contact_Person	varchar(200)
	,@User_Id			numeric(18,0) = 0
    ,@IP_Address		varchar(30)= ''
    ,@Row_No int
    ,@Log_Status Int = 0 Output    
    ,@GUID Varchar(2000) = ''
AS
		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

declare @Dept_ID as numeric(18,0)
declare @Training_Induction_ID as numeric(18,0)	
declare @Emp_ID as numeric(18,0)
declare @Training_id as numeric(18,0)

	if @Training_Topic =''
		begin			
			Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			Values (@Row_No,@Cmp_Id,'','Training Topic is required',0,'Training Topic is required',GetDate(),'Training Induction Master Import',@GUID)						
			Set @Log_Status=1
			return
		end	 
	ELSE	
		BEGIN
			if NOT EXISTS(select Training_id from T0040_Hrms_Training_master WITH (NOLOCK) where UPPER(Training_name)=UPPER(@Training_Topic) and Cmp_Id=@Cmp_Id)
				BEGIN
					Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
					Values (@Row_No,@Cmp_Id,'','Enter proper Training Topic',0,'Training Topic not exist',GetDate(),'Training Induction Master Import',@GUID)						
					Set @Log_Status=1
					return
				END
			else
				BEGIN
					select @Training_id=Training_id from T0040_Hrms_Training_master WITH (NOLOCK) where UPPER(Training_name)=UPPER(@Training_Topic) and Cmp_Id=@Cmp_Id
				END			
		END		
		
	if @Contact_Person =''
		begin			
			Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			Values (@Row_No,@Cmp_Id,'','Contact Person is required',0,'Contact Person is required',GetDate(),'Training Induction Master Import',@GUID)						
			Set @Log_Status=1
			return
		end	 
	ELSE	
		BEGIN
			if NOT EXISTS(select Emp_ID from T0080_EMP_MASTER WITH (NOLOCK) where UPPER(Alpha_Emp_Code)=UPPER(@Contact_Person) and Cmp_Id=@Cmp_Id)
				BEGIN
					Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
					Values (@Row_No,@Cmp_Id,'','Enter proper employee code for contact person',0,'Enter proper employee code for contact person',GetDate(),'Training Induction Master Import',@GUID)						
					Set @Log_Status=1
					return
				END
			else
				BEGIN
					select @Emp_ID=Emp_ID from T0080_EMP_MASTER WITH (NOLOCK) where UPPER(Alpha_Emp_Code)=UPPER(@Contact_Person) and Cmp_Id=@Cmp_Id
				END			
		END		
			
	if @Department =''
		begin			
			Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			Values (@Row_No,@Cmp_Id,'','Department is required',0,'Department is required',GetDate(),'Training Induction Master Import',@GUID)						
			Set @Log_Status=1
			return
		end	 
	ELSE	
		BEGIN
			if NOT EXISTS(select Dept_Id from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where UPPER(Dept_Name)=UPPER(@Department) and Cmp_Id=@Cmp_Id)
				BEGIN
					Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
					Values (@Row_No,@Cmp_Id,'','Department not exist',0,'Department not exist',GetDate(),'Training Induction Master Import',@GUID)						
					Set @Log_Status=1
					return
				END
			else
				BEGIN
					select @Dept_ID=Dept_Id from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where UPPER(Dept_Name)=UPPER(@Department) and Cmp_Id=@Cmp_Id
				END			
		END		
	
		
		If Exists(select Training_Induction_ID From T0040_Training_Induction_Master WITH (NOLOCK) Where Training_id = @Training_id and  Dept_ID=@Dept_ID and Contact_Person_ID=@Emp_ID and Cmp_Id = @Cmp_Id)
				Begin
					Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
					Values (@Row_No,@Cmp_Id,'','Record already exist',0,'Record already exist',GetDate(),'Training Induction Master Import',@GUID)						
					Set @Log_Status=1
					return
				End
				
		    select @Training_Induction_ID = Isnull(max(Training_Induction_ID),0) + 1 From T0040_Training_Induction_Master WITH (NOLOCK) 
			INSERT INTO T0040_Training_Induction_Master
					(Training_Induction_ID,Cmp_ID,Dept_ID,Training_id,Contact_Person_ID)    
		    VALUES(@Training_Induction_ID,@Cmp_ID,@Dept_ID,@Training_id,@Emp_ID)   

RETURN
