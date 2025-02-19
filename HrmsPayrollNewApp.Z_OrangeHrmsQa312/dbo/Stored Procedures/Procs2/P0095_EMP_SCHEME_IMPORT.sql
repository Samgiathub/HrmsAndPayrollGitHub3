

-- =============================================
-- Author:		<Gadriwala Muslim>
-- Create date: <03/04/2015>
-- Description:	<Employee Scheme Imports>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================

CREATE PROCEDURE [dbo].[P0095_EMP_SCHEME_IMPORT] 
	 @Cmp_Id		NUMERIC(18,0)
	,@Emp_Code		VARCHAR(30)
	,@Effect_Date	Datetime
	,@Scheme_Type   VARCHAR(100)
	,@Scheme_Name   VARCHAR(200)
	,@Row_No		INT = 0
	,@Log_Status	INT = 0 OUTPUT
	,@GUID			Varchar(2000) = '' --Added by nilesh patel on 17062016
AS 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	DECLARE @Tran_ID	AS NUMERIC(18,0)
	DECLARE @Scheme_ID as Numeric(18,0)
	DECLARE @Emp_ID	AS NUMERIC(18,0)
    DECLARE @TYPE_CHK as Varchar(50)
    
    Set @Tran_ID = 0
    Set @Emp_ID = 0
   
    SELECT @Scheme_ID = ISNULL(Scheme_Id,0) FROM T0040_Scheme_Master WITH (NOLOCK) WHERE Scheme_Name = @Scheme_Name and Scheme_Type = @Scheme_Type AND cmp_id = @cmp_id
    SELECT @Emp_ID = ISNULL(EMP_ID,0) FROM t0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code = @EMP_CODE AND cmp_id = @cmp_id
    
	

    IF isnull(@Scheme_ID,0) = 0 
	BEGIN
		SET @Log_Status=1
		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Scheme Name Doesn''t exists',@Scheme_Name,'Enter proper Scheme Name',GETDATE(),'Employee Scheme',@GUID)
		--RAISERROR('@@Scheme Name Doesn''t exists@@',16,2)
		RETURN
	END
	
	IF @Effect_Date IS NULL
	BEGIN
		SET @Log_Status=1
		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Scheme Effective Date Doesn''t exists',@Scheme_Name,'Enter proper Scheme Effective Date',GETDATE(),'Employee Scheme',@GUID)
		RETURN
	END
	
	IF isnull(@Emp_ID,0) =0
	BEGIN
		SET @Log_Status=1
		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee Doesn''t exists',@Emp_Code,'Enter proper Employee Code',GETDATE(),'Employee Scheme',@GUID)
		--RAISERROR('@@Employee Doesn''t exists@@',16,2)
		RETURN
	END

	
	Select @TYPE_CHK = isnull(Type,'') from T0095_EMP_SCHEME where Emp_ID = @Emp_ID and Type = @Scheme_Type  and Effective_date = @Effect_Date

	if @TYPE_CHK = 'Travel' or @TYPE_CHK = 'Travel Settlement' or @TYPE_CHK = 'Claim'
	Begin
		select @Tran_ID = isnull(max(tran_ID),0) + 1 from T0095_EMP_SCHEME WITH (NOLOCK)
			INSERT INTO T0095_EMP_SCHEME (tran_ID,Cmp_id, Emp_id,Scheme_ID,Type, Effective_date)
					VALUES (@Tran_ID,@Cmp_id,@Emp_id,@Scheme_ID,@Scheme_Type,@Effect_Date)
	End
	Else
	Begin 
		IF EXISTS (SELECT 1 FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_ID and Type = @Scheme_Type  and Effective_date = @Effect_Date)
			Begin
				UPDATE T0095_EMP_SCHEME
					SET Scheme_ID = @Scheme_ID 
					Where Effective_date = @Effect_Date and Type = @Scheme_Type and Emp_ID = @Emp_ID
			End
	Else
			Begin
				select @Tran_ID = isnull(max(tran_ID),0) + 1 from T0095_EMP_SCHEME WITH (NOLOCK)
				INSERT INTO T0095_EMP_SCHEME (tran_ID,Cmp_id, Emp_id,Scheme_ID,Type, Effective_date)
					VALUES (@Tran_ID,@Cmp_id,@Emp_id,@Scheme_ID,@Scheme_Type,@Effect_Date)
			End

	End



