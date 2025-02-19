CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Logout_Devices]

@Aplha_Code varchar(50),
@Cmp_ID numeric = 0,
@Type Char(1),
@Result varchar(255) OUTPUT

AS
SET NOCOUNT ON		
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Emp_ID varchar(10) =''
Select @Emp_ID = ISNULL(EMP_ID,'') from T0080_EMP_MASTER where Alpha_Emp_Code = @Aplha_Code and Cmp_ID = @Cmp_ID

IF @Emp_ID = '' OR @Emp_ID = 0 
BEGIN
	SET @Result = 'False'
	RAISERROR('@@Invalid Alpha Emp Code@@',16,2)
	select @Result as Result
	Return
End
IF @Type = 'O' --- For Log Out
	BEGIN
		UPDATE T0095_Emp_IMEI_Details WITH (ROWLOCK)
		SET Is_Active = 0 WHERE Emp_ID = @Emp_ID 
		and Cmp_ID = @Cmp_ID 
		SET @Result = 'Log Out from all devices Successfully#True#'
		select @Result as Result
	END





