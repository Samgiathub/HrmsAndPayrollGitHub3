
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0095_CPS_OPENING_IMPORT]
  @Alpha_Emp_Code as varchar(50)
 ,@CMP_ID as numeric(18,0)
 ,@FOR_DATE  as datetime
 ,@OPENING AS NUMERIC(18,4)
 ,@Log_Status Int = 0 Output
 ,@Row_No int = 0
 ,@GUID Varchar(2000) = '' --Added by nilesh Patel on 14062016
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		DECLARE @EMP_ID NUMERIC(18,0);		
		DECLARE @TRAN_ID NUMERIC(18,0);
		DECLARE @MODULE VARCHAR(20);
		
		SET @MODULE = 'CPS OPENING';
		
		SET @EMP_ID = NULL;
		SELECT @EMP_ID=EMP_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code=@Alpha_Emp_Code And Cmp_ID=@Cmp_Id
		
		If @OPENING Is Null
			Set @OPENING = 0	
		
		IF @FOR_DATE is null
		BEGIN
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@FOR_DATE ,'Opening Date',GETDATE(),'CPS Opening Date cannot be blank.',GetDate(),@MODULE,@GUID)
			RETURN
		END
    
		IF ISNULL(@EMP_ID,0) =0
		BEGIN
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Employee Doesn''t exists',@Alpha_Emp_Code,'Enter proper Employee Code',GetDate(),@MODULE,@GUID)			
			RETURN
		END

		DECLARE @TRAN_TYPE VARCHAR(5)
		
		SET @TRAN_ID = NULL;
		SELECT @TRAN_ID=Tran_ID FROM dbo.T0095_CPS_OPENING WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND Emp_ID=@EMP_ID AND For_Date=@FOR_DATE
		
		IF ISNULL(@TRAN_ID,0) > 0
			SET @TRAN_TYPE = 'U'
		ELSE
			SET @TRAN_TYPE = 'I'
		
		
		IF @TRAN_TYPE = 'I'
			BEGIN			
				--FOR CPS_OPENING TABLE
				SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM dbo.T0095_CPS_OPENING WITH (NOLOCK)
				
				INSERT INTO dbo.T0095_CPS_OPENING
						   (Cmp_ID, Tran_ID, Emp_ID, For_Date, CPS_Opening, SystemDate)
				VALUES     (@CMP_ID,@TRAN_ID,@EMP_ID,@FOR_DATE,@OPENING,GETDATE())	
												
			END
		ELSE IF @Tran_Type = 'U'
			BEGIN
				UPDATE	dbo.T0095_CPS_OPENING	
				SET		CPS_Opening = @OPENING,
						SystemDate  = GETDATE()
				WHERE	Tran_ID=@TRAN_ID AND Cmp_ID=@CMP_ID AND Emp_ID=@EMP_ID				
			END
		
	IF EXISTS(SELECT Im_Id FROM T0080_Import_Log WITH (NOLOCK) WHERE CONVERT(VARCHAR(50),For_Date,103) = CONVERT(VARCHAR(50),GETDATE(),103) and Import_type = @MODULE)
	BEGIN 
		SET @Log_Status = 1
	END
		
RETURN




