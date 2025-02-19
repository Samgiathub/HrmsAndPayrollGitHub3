
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_GPF_REQUEST_IMPORT]
  @Alpha_Emp_Code as varchar(50)
 ,@CMP_ID as numeric(18,0)
 ,@Effective_Date  as datetime
 ,@AD_Name as Varchar(500)
 ,@Amount AS NUMERIC(18,2)
 ,@Log_Status Int = 0 Output
 ,@Row_No int = 0
 ,@GUID  Varchar(2000) = '' --Added by nilesh patel on 15062016
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		DECLARE @EMP_ID NUMERIC(18,0);		
		DECLARE @TRAN_ID NUMERIC(18,0);
		DECLARE @MODULE VARCHAR(100);
		DECLARE @AD_ID Numeric(18,0);
		
		Set @Tran_ID = 0
		
		SET @MODULE = 'GPF Addtional Amount Import';
		
		SET @EMP_ID = NULL;
		SELECT @EMP_ID=EMP_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code=@Alpha_Emp_Code And Cmp_ID=@Cmp_Id
		
		Set @AD_ID = 0
		Select @AD_ID = AD_ID From T0050_AD_MASTER WITH (NOLOCK) Where AD_NAME = @AD_Name and CMP_ID = @Cmp_Id
		
		 
		IF @Effective_Date is null
		BEGIN
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Effective_Date ,'Effective Date',GETDATE(),'GPF Effective Date cannot be blank.',GetDate(),@MODULE,@GUID)
			RETURN
		END
    
		IF ISNULL(@EMP_ID,0) =0
		BEGIN
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Employee Doesn''t exists',@Alpha_Emp_Code,'Enter proper Employee Code',GetDate(),@MODULE,@GUID)			
			RETURN
		END
		
		If ISNULL(@AD_ID,0) = 0
		Begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Allowance details Doesn''t exists',@Alpha_Emp_Code,'Enter valid allowance details',GetDate(),@MODULE,@GUID)			
			RETURN 
		End
		
		If isnull(@Amount,0) = 0 
		Begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Allowance Amount',@Alpha_Emp_Code,'Allowance Amount Cannot be zero',GetDate(),@MODULE,@GUID)			
			RETURN
		End

		DECLARE @TRAN_TYPE Numeric(18,0)
		
		SET @TRAN_ID = NULL;
		SELECT @TRAN_ID=Tran_ID FROM dbo.T0090_EMP_GPF_REQUEST WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND Emp_ID=@EMP_ID AND Effective_Date = @Effective_Date
		
		IF ISNULL(@TRAN_ID,0) > 0
			SET @TRAN_TYPE = 1
		ELSE
			SET @TRAN_TYPE = 0
		
		if @Log_Status = 0
			Begin
				EXEC P0090_EMP_GPF_REQUEST @CMP_ID,0,@EMP_ID,@AD_ID,@Effective_Date,@Amount,@TRAN_TYPE
			End
		
RETURN




