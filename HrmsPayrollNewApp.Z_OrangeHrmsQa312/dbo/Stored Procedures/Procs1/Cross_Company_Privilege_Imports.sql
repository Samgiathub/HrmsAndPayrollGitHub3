


-- =============================================
-- Author:		<Gadriwala Muslim>
-- Create date: <18/05/2015>
-- Description:	<Cross Company Privilege Imports for Employee>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Cross_Company_Privilege_Imports]
	@cmp_ID  numeric(18,0),
	@Alpha_Emp_Code  nvarchar(50),
	@other_Cmp_Name  nvarchar(500),
	@Other_Privilege_Name  nvarchar(200),
	@Row_No			 numeric,
	@Log_Status		 numeric = 0 output,
	@GUID			 Varchar(2000) = '' --Added by nilesh patel on 16062016
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	Declare @Emp_ID as numeric(18,0)
	Declare @Other_Privilege_ID as numeric(18,0)
	Declare @Other_Cmp_ID as numeric(18,0)
	Declare @Is_Admin as numeric(18,0)
	
	set @Is_Admin = 1
	set @Emp_ID = 0
	set @Other_Privilege_ID = 0
	set @Other_Cmp_ID = 0
	
	select @Emp_ID = Emp_ID from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Alpha_Emp_Code and Cmp_ID = @cmp_ID and Emp_Left = 'N'
	select @Other_Cmp_ID = cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Name like @other_Cmp_Name
	
	select @Other_Privilege_ID = Privilege_ID,@Is_Admin = Privilege_Type from T0020_PRIVILEGE_MASTER WITH (NOLOCK)
	where Privilege_Name = @Other_Privilege_Name and cmp_ID = @Other_Cmp_ID and Is_Active = 1	
		
	

	If isnull(@Emp_ID,0) = 0
		begin
				INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Employee Code is not Match',@Alpha_Emp_Code,'Please Enter Correct Code',GETDATE(),'Cross Company Privilege',@GUID)  
				set @Log_Status = 1
			    return
		end
	If isnull(@Other_Cmp_ID,0) = 0
		begin
				INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Other Company Name is not Match',@other_Cmp_Name,'Please Enter Proper Other Company Name ',GETDATE(),'Cross Company Privilege',@GUID)  
				set @Log_Status = 1
			    return
		end
	If isnull(@Other_Privilege_ID,0) = 0 
		begin
				INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Privilege Name is not Match',@other_Cmp_Name,'Please Enter Proper Privilege Name ',GETDATE(),'Cross Company Privilege',@GUID)  
				set @Log_Status = 1
			    return
		end	
	if isnull(@Is_Admin,1) = 1
		begin
				INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Privilege Name is not Admin Type',@other_Cmp_Name,'Please Enter only Admin Privilege Name',GETDATE(),'Cross Company Privilege',@GUID)  
				set @Log_Status = 1
			    return
		end
		
	IF exists( select 1 from T0095_EMP_PRIVILEGE_OTHER_CMP WITH (NOLOCK) where Cmp_id = @cmp_ID and Emp_id = @Emp_ID and O_Cmp_id = @Other_Cmp_ID)
		begin
			Update  T0095_EMP_PRIVILEGE_OTHER_CMP  set  O_Privilege_id = @Other_Privilege_ID , Last_Updated = GETDATE() WHERE 
			Cmp_id = @cmp_ID and Emp_id = @Emp_ID and O_Cmp_id = @Other_Cmp_ID 		
		end
	else
		begin
			
			insert into T0095_EMP_PRIVILEGE_OTHER_CMP
			(
				 Cmp_id,
				 Emp_id,
				 O_Cmp_id,
				 O_Privilege_id,
				 is_active,
				 System_Date,
				 Last_Updated
			)  
			values
			(
				 @cmp_ID,
				 @Emp_ID,
				 @Other_Cmp_ID,
				 @Other_Privilege_ID,
				 1,
				 getdate(),
				 null
			)
			
		end
	 
		
		
END

