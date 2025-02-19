
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_Hrms_Training_master_Import] 
	 --@Training_id			Numeric(18,0) output
	@Training_name			varchar(200)
	,@Training_description	varchar(250)		
	,@Cmp_Id	            Numeric(18,0)
	,@Training_Category  varchar(150)
	,@Training_MCP			Numeric(18,2) =0
	,@User_Id numeric(18,0) = 0 
    ,@IP_Address varchar(30)= ''
    ,@Training_Cordinator varchar(250) = '' 
    ,@Training_Director varchar(250) = ''
    ,@Row_No int
    ,@Log_Status Int = 0 Output    
    ,@GUID Varchar(2000) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @Cat_ID as numeric(18,0)
declare @Training_id as numeric(18,0)
	
	if @Training_name =''
		begin			
			Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			Values (@Row_No,@Cmp_Id,'','Training Title is required',0,'Training Title is required',GetDate(),'Training Master Import',@GUID)						
			Set @Log_Status=1
			return
		end	 
	else
		begin
			 if exists(select Training_id from T0040_Hrms_Training_master WITH (NOLOCK) where upper(Training_name) = upper(@Training_name)  and Cmp_ID = @cmp_id)
				BEGIN					
					Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
					Values (@Row_No,@Cmp_Id,'','Training Title already exist',0,'Enter proper Training Title',GetDate(),'Training Master Import',@GUID)						
					Set @Log_Status=1
					return
				END
		end	 
		
		if @Training_Category <> ''
			begin
				 if exists(select Cat_ID from T0030_CATEGORY_MASTER WITH (NOLOCK) where upper(Cat_Name) = upper(@Training_Category)  and Cmp_ID = @cmp_id)
					BEGIN						
						Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
						Values (@Row_No,@Cmp_Id,'','Category Name not exist',0,'Enter proper Training Category',GetDate(),'Training Master Import',@GUID)						
						Set @Log_Status=1
						return
					END
				ELSE
					BEGIN
						select @Cat_ID=Cat_ID from T0030_CATEGORY_MASTER WITH (NOLOCK) where upper(Cat_Name) = upper(@Training_Category)  and Cmp_ID = @cmp_id
					END
			end	 
		
									
			select @Training_id = Isnull(max(Training_id),0) + 1 From T0040_Hrms_Training_master WITH (NOLOCK)
			
		   if @Training_name <>''
		     Begin				
					INSERT INTO T0040_Hrms_Training_master
					(Training_id,Training_name,Training_description,Cmp_Id,Training_Category_Id,Training_MCP,Training_Cordinator,Training_Director)    
				    VALUES(@Training_id,@Training_name,@Training_description,@Cmp_Id,@Cat_ID,@Training_MCP,@Training_Cordinator,@Training_Director)      
			 End		
		
RETURN
