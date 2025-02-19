
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0095_Emp_Salary_Cycle_Import] 
	 @Cmp_Id		NUMERIC(18,0)
	,@Emp_Code		VARCHAR(30)
	,@Month			NUMERIC(18,0)
	,@Year			NUMERIC(18,0)
	,@SalDate_name	NVARCHAR(100)
	,@Row_No		INT = 0
	,@Log_Status	INT = 0 OUTPUT
	,@GUID			Varchar(2000) = '' --Added by Nilesh Patel on 17062016
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @SalDate_ID	AS NUMERIC(18,0)
	DECLARE @Emp_ID	AS NUMERIC(18,0)
    DECLARE @Month_Start_Date AS DATETIME
    
    Set @SalDate_ID = 0
    Set @Emp_ID = 0
    
    SELECT @SalDate_ID = ISNULL(Tran_ID,0) FROM T0040_Salary_Cycle_Master WITH (NOLOCK) WHERE Name = @SalDate_name AND cmp_id = @cmp_id
    SELECT @Emp_ID = ISNULL(EMP_ID,0) FROM t0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code = @EMP_CODE AND cmp_id = @cmp_id
    SET @Month_Start_Date = dbo.GET_MONTH_ST_DATE(@Month, @Year)

    IF @SalDate_ID = 0 
	BEGIN
		SET @Log_Status=1
		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Salary Cycle Doesn''t exists',@SalDate_name,'Enter proper Salary Cycle Name',GETDATE(),'Salary Cycle',@GUID)
		--RAISERROR('@@Salary Cycle Doesn''t exists@@',16,2)
		RETURN
	END
	
	IF @Emp_ID =0
	BEGIN
		SET @Log_Status=1
		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee Doesn''t exists',@Emp_Code,'Enter proper Employee Code',GETDATE(),'Salary Cycle',@GUID)
		--RAISERROR('@@Employee Doesn''t exists@@',16,2)
		RETURN
	END
	
	IF ISNULL(@MONTH,0) = 0
	BEGIN
		SET @Log_Status=1
		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Month Detail Doesn''t exists',@Emp_Code,'Enter proper Month Detail',GETDATE(),'Salary Cycle',@GUID)
		RETURN
	END
	
	IF ISNULL(@YEAR,0) = 0
	BEGIN
		SET @Log_Status=1
		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Year Detail Doesn''t exists',@Emp_Code,'Enter proper Year Detail',GETDATE(),'Salary Cycle',@GUID)
		RETURN
	END
	
	IF EXISTS (SELECT 1 FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Effective_date = @Month_Start_Date)
		Begin
			UPDATE T0095_Emp_Salary_Cycle
				SET SalDate_id = @SalDate_id 
				Where Effective_date = @Month_Start_Date and Emp_ID = @Emp_ID
		End
	Else
		Begin
			INSERT INTO T0095_Emp_Salary_Cycle (Cmp_id, Emp_id, SalDate_id, Effective_date)
					VALUES (@Cmp_id,@Emp_id,@SalDate_id,@Month_Start_Date)
		End
		
	
