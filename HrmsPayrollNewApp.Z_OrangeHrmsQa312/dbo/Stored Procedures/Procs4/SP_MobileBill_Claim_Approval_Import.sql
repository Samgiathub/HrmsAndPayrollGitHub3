-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MobileBill_Claim_Approval_Import]
	@CMP_ID NUMERIC(18,0),
	@ALPHA_EMP_CODE VARCHAR(250),
	@CLAIM_NAME VARCHAR(500),
	@CLAIM_APR_DATE DATETIME,
	@CLAIM_APR_AMOUNT NUMERIC(18,2),
	@TRAN_TYPE AS VARCHAR(1),
    @ROW_NO INT = 0,
    @LOG_STATUS INT = 0 OUTPUT,
	@GUID VARCHAR(2000) = '' ,
	@User_Id numeric(18,0)
AS
BEGIN
	 	SET NOCOUNT ON	
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
		SET ANSI_WARNINGS OFF;

		DECLARE @CLAIM_ID  NUMERIC(18,0)=0
		DECLARE @EMP_ID NUMERIC(18,0) = 0
		Declare @Claim_Deduct_From_Salary tinyint
		Declare @Claim_Apr_ID numeric(18,0) = 0
		Declare @Desig_ID numeric(18,0)
		Declare @Desig_Wise_Limit tinyint = 0
		Declare @Max_Limit_Km numeric(18,2)
		Declare @Claim_Allow_Beyond_Limit tinyint = 0
		Declare @Grade_Wise_Limit tinyint = 0
		Declare @Branch_Wise_Limit tinyint = 0
		Declare @Branch_ID numeric(18,0)
		Declare @Grade_ID numeric(18,0)
		DECLARE @Exceed_Claim_Amount Numeric(18,2) = 0
		DECLARE @Applicable_Once TINYINT
		SELECT @EMP_ID = EMP_ID 
		FROM T0080_EMP_MASTER WITH(NOLOCK)
		WHERE ALPHA_EMP_CODE=@ALPHA_EMP_CODE AND CMP_ID = @CMP_ID

		SELECT @CLAIM_ID = CLAIM_ID, @CLAIM_DEDUCT_FROM_SALARY= CLAIM_APR_DEDUCT_FROM_SAL,@Desig_Wise_Limit = Desig_Wise_Limit,
			   @Claim_Allow_Beyond_Limit=Claim_Allow_Beyond_Limit,@Grade_Wise_Limit=Grade_Wise_Limit,@Branch_Wise_Limit=Branch_Wise_Limit,@Applicable_Once=Applicable_Once
		FROM T0040_CLAIM_MASTER WITH(NOLOCK)
		WHERE CLAIM_NAME=@CLAIM_NAME  AND CMP_ID =@CMP_ID

		select @Desig_ID =I.Desig_Id,@Branch_ID=I.Branch_ID ,@Grade_ID=I.Grd_id
		FROM T0095_INCREMENT I WITH(NOLOCK)  INNER JOIN
		( SELECT * FROM dbo.fn_getEmpIncrement(@cmp_id,@EMP_ID,GETDATE()))As GI on GI.Increment_ID = I.Increment_ID

		if @Desig_Wise_Limit = 1
		Begin
			SELECT @Max_Limit_Km = Max_Limit_Km
			FROM T0040_Claim_master CM WITH(NOLOCK) INNER JOIN 
				 T0041_Claim_Maxlimit_Design CMD WITH(NOLOCK) ON CM.Claim_ID = CMD.Claim_ID 
			WHERE CM.Desig_Wise_Limit = @Desig_Wise_Limit AND Desig_ID = @Desig_ID AND CM.Cmp_ID = @CMP_ID AND CM.claim_ID = @CLAIM_ID
		END

		if @Grade_Wise_Limit = 1
		Begin
			SELECT @Max_Limit_Km = Max_Limit_Km
			FROM T0040_Claim_master CM WITH(NOLOCK) INNER JOIN 
				 T0041_Claim_Maxlimit_Design CMD WITH(NOLOCK) ON CM.Claim_ID = CMD.Claim_ID 
			WHERE CM.Grade_Wise_Limit = @Grade_Wise_Limit AND Grade_ID = @Desig_ID AND CM.Cmp_ID = @CMP_ID AND CM.claim_ID = @CLAIM_ID
		END
		
		if @Branch_Wise_Limit = 1
		Begin
			SELECT @Max_Limit_Km = Max_Limit_Km
			FROM T0040_Claim_master CM WITH(NOLOCK) INNER JOIN 
				 T0041_Claim_Maxlimit_Design CMD WITH(NOLOCK) ON CM.Claim_ID = CMD.Claim_ID 
			WHERE CM.Branch_Wise_Limit = @Branch_Wise_Limit AND Branch_ID = @Desig_ID AND CM.Cmp_ID = @CMP_ID AND CM.claim_ID = @CLAIM_ID
		END

		IF @EMP_ID =0
		BEGIN
			SET @LOG_STATUS=1
			INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@ALPHA_EMP_CODE,'Employee Doesn''t exists',@ALPHA_EMP_CODE,'Enter proper Employee Code',GetDate(),'Mobile Bill Upload',@GUID)						
			RETURN
		END

		if @CLAIM_ID =0
		BEGIN
			SET @LOG_STATUS=1
			INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@ALPHA_EMP_CODE,'Claim Type Doesn''t exists',@Claim_Name,'Enter proper Claim Name',GetDate(),'Mobile Bill Upload',@GUID)
			RETURN
		END
    
		IF @CLAIM_APR_DATE IS NULL
		BEGIN
			SET @LOG_STATUS=1
			INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@ALPHA_EMP_CODE,'Approval Date Does not Exists',@ALPHA_EMP_CODE,'Please Enter Claim Approval Date',GetDate(),'Mobile Bill Upload',@GUID)			
			RETURN
		END
		
		IF @CLAIM_APR_DATE > GETDATE()
		BEGIN
			SET @LOG_STATUS=1
			INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@ALPHA_EMP_CODE,'Approval Date Should Be Less Or Equal To Current Date' ,@ALPHA_EMP_CODE,'Please Enter Claim Approval Amount',GetDate(),'Mobile Bill Upload',@GUID)			
			RETURN
		END

		IF @CLAIM_APR_AMOUNT =0
		BEGIN
			SET @LOG_STATUS=1
			INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@ALPHA_EMP_CODE,'Claim Approval Amount Does not Exists',@ALPHA_EMP_CODE,'Please Enter Claim Approval Amount',GetDate(),'Mobile Bill Upload',@GUID)			
			RETURN
		END
		
		--SELECT @Applicable_Once,* from T0100_CLAIM_APPLICATION  WHERE Cmp_ID =@CMP_ID and EMP_ID=@EMP_ID AND claim_ID =@CLAIM_ID
		IF @Applicable_Once =1
		BEGIN
			IF EXISTS(SELECT 1 from T0130_CLAIM_APPROVAL_DETAIL  WHERE Cmp_ID =@CMP_ID and EMP_ID=@EMP_ID AND claim_ID =@CLAIM_ID)
				BEGIN			
					SET @LOG_STATUS=1
					INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@ALPHA_EMP_CODE,'This Claim is applicable Once in Life Time',@ALPHA_EMP_CODE,'This Claim is applicable Once in Life Time',GetDate(),'Mobile Bill Upload',@GUID)			
					RETURN
				END
		END
		
		IF @CLAIM_ALLOW_BEYOND_LIMIT = 0
		BEGIN
			IF @CLAIM_APR_AMOUNT > @MAX_LIMIT_KM
			BEGIN
				
				SET @LOG_STATUS=1
				INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,@ALPHA_EMP_CODE,'Approval Amount is exceeds then Max Limit' ,@ALPHA_EMP_CODE,'Please Enter Claim Approval Amount',GetDate(),'Mobile Bill Upload',@GUID)			
				RETURN
			END
		END
		ELSE
		BEGIN
			IF @CLAIM_APR_AMOUNT > @Max_Limit_Km
			BEGIN
				SET  @Exceed_Claim_Amount = @CLAIM_APR_AMOUNT - @Max_Limit_Km
			END
		END
		exec P0120_CLAIM_APPROVAL @Claim_Apr_ID=@Claim_Apr_ID output,@Cmp_ID=@Cmp_ID,@Claim_App_ID=NULL,@Emp_ID=@EMP_ID,@Claim_ID=0,@Claim_Apr_Date=@Claim_Apr_Date,@Claim_Apr_Code='Import',@Claim_Apr_Comments='',@Claim_apr_By='Admin',@Claim_Apr_Amount=0,@Claim_Apr_Deduct_From_Sal=@Claim_Deduct_From_Salary,@Claim_Apr_Pending_Amount=0,@Claim_App_Status='A',@Claim_App_Date=NULL,@Claim_App_Amount=0,@Curr_ID=0,@Curr_Rate=0,@Purpose=N'',@Claim_App_Total_Amount=0,@tran_type=@TRAN_TYPE,@S_Emp_ID=0,@Petrol_KM=0,@User_Id=@User_Id
				
		exec P0130_Claim_APPROVAL_DETAIL @Claim_Apr_Dtl_ID=0,@Claim_Apr_ID=@Claim_Apr_ID,@Cmp_ID=@Cmp_ID,@Emp_ID=@EMP_ID,@Claim_ID=@CLAIM_ID,@Claim_Apr_Date=@Claim_Apr_Date,@Claim_App_ID=0,@Claim_Apr_Code='0',@Claim_Apr_Amount=@Claim_Apr_Amount,@Claim_App_Status='A',@Claim_App_Amount=@Claim_Apr_Amount,@Curr_ID=0,@Curr_Rate=0,@Purpose=N'',@Claim_App_Total_Amount=@Claim_Apr_Amount,@S_Emp_ID=0,@Petrol_KM=0,@tran_type=@TRAN_TYPE,@User_Id=@User_Id,@Claim_Limit=@Max_Limit_Km,@Claim_Exceed_Amount=@Exceed_Claim_Amount
END
