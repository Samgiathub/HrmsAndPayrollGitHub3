
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_Change_Password_Import]
	@Cmp_Id Numeric(18,0),
	@Alpha_Emp_Code Varchar(100),
	@Password Varchar(100),
	@Login_ID Numeric(18,0),
	@Ip_Address Varchar(100),
	@Log_Status INT = 0 OUTPUT,
	@GUID Varchar(2000) = '' --Added By Nilesh Patel on 17062016
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @Sr_No Numeric(18,0)
Declare @Emp_ID Numeric(18,0)
Set @Sr_No = 0
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	if @Password = ''
		Set @Password = NULL
    -- Insert statements for procedure here
    
    Select @Sr_No = isnull(Max(Sr_No),0) + 1 From T0050_Change_Password_Import WITH (NOLOCK)
    Select @Emp_ID = Emp_ID From T0080_EMP_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_Id and Alpha_Emp_Code = @Alpha_Emp_Code
    
    IF isnull(@Emp_ID,0) =0
	BEGIN
		SET @Log_Status=1
		INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Employee Doesn''t exists',@Alpha_Emp_Code,'Enter proper Employee Code',GETDATE(),'Change Password',@GUID)
		RETURN
	END
	
	if @Password IS NULL 
	Begin
		SET @Log_Status=1
		INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Employee Password Doesn''t exists',@Alpha_Emp_Code,'Enter proper Employee Password',GETDATE(),'Change Password',@GUID)
		RETURN
	End
    
	Insert into T0050_Change_Password_Import(Sr_No,Emp_Code,Cmp_ID,Password,Login_ID,Change_Date,IP_Address)
	VALUES(@Sr_No,@Alpha_Emp_Code,@Cmp_Id,@Password,@Login_ID,GETDATE(),@Ip_Address)
	
	Update T0011_LOGIN Set Login_Password = @Password where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_Id
	
	
END

