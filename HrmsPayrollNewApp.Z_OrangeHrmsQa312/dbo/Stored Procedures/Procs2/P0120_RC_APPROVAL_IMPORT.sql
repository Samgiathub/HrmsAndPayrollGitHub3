

-- =============================================
-- Author:		<Author,,Ankit>
-- Create date: <Create Date,,04112015>
-- Description:	<Description,,Reimbursement Import Approval>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0120_RC_APPROVAL_IMPORT]
	 @Cmp_ID			NUMERIC(18,0)
	,@Alpha_Emp_Code	VARCHAR(100)
	,@Apr_Date			DATETIME
	,@Reim_Allow_Name	VARCHAR(100)
	,@Apr_Amount		NUMERIC(18,2)
	,@Tax_Free_Amount	NUMERIC(18,2)
	,@RC_Apr_Effect_In_Salary	NUMERIC(18,2)
	,@Payment_date		DATETIME
	,@Payment_Type		VARCHAR(15)	  = ''
	,@Apr_Comments		NVARCHAR(MAX) = ''
	,@User_ID			NUMERIC(18,0) = 0 
	,@Row_No			NUMERIC(18,0) = 0 
	,@Log_Status		NUMERIC(18,0) = 0 OUTPUT
	,@GUID				Varchar(2000) = '' --Added by nilesh patel on 15062016
	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	

    DECLARE @RC_APR_ID	NUMERIC(18,0)
	DECLARE @RC_APP_ID	NUMERIC(18,0)
	DECLARE @Emp_ID		NUMERIC(18,0)
    DECLARE @RC_ID		NUMERIC(18,0)
    DECLARE @St_date	AS DATETIME
	DECLARE @End_Date	AS DATETIME
	DECLARE @Taxable_limit		AS DECIMAL
	DECLARE @Non_Taxable_limit	AS DECIMAL
	DECLARE @Taxable_Count		AS DECIMAL   
	DECLARE @Non_Taxable_Count	AS DECIMAL	  
	DECLARE @Monthly_Limit		AS INT
    DECLARE @Monthly_LimitCount AS INT
	DECLARE @MnthSt_date	AS DATETIME
	DECLARE @MnthEnd_Date	AS DATETIME
	DECLARE @Taxable		TINYINT
	DECLARE @Total_Paid_Amount NUMERIC(18,2) 
	DECLARE @Date_of_join	DATETIME
	DECLARE @Non_Taxable	NUMERIC(18,2)
    DECLARE @Grd_ID		NUMERIC(18,0)
    DECLARE @For_date	DATETIME
    DECLARE @Negative_Balance NUMERIC
    
    
    SET @For_date = GETDATE()
    SET @Total_Paid_Amount = 0.0
	SET @Taxable_limit =0.0
	SET @Non_Taxable_limit =0.0
	SET @Taxable_Count =0
	SET @Non_Taxable_Count =0
	SET @RC_APP_ID  = 0
    SET @Emp_ID		= 0 
    SET @RC_ID		= 0 
    SET @Date_of_join = NULL
    SET @Non_Taxable = 0
    SET @Grd_ID = 0
    SET @Negative_Balance = 0
    
    IF ISNULL(@Payment_Type,'') = '' OR ( ISNULL(@Payment_Type,'') <> 'Cash' AND ISNULL(@Payment_Type,'') <> 'Cheque' AND ISNULL(@Payment_Type,'') <> 'Bank Transfer' )
		SET @Payment_Type = 'Cash'
    
    IF @Tax_Free_Amount = 0
		SET @Taxable    = 0
	ELSE	
		SET @Taxable    = 1
    
    SET @Alpha_Emp_Code = RTRIM(@Alpha_Emp_Code)
    SET @Alpha_Emp_Code = LTRIM(@Alpha_Emp_Code)
    SET @Reim_Allow_Name = RTRIM(@Reim_Allow_Name)				
	SET @Reim_Allow_Name = LTRIM(@Reim_Allow_Name)
    
    SELECT @Emp_ID = Emp_ID, @Date_of_join = Date_Of_Join FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code = @Alpha_Emp_Code AND Cmp_ID = @Cmp_Id
    
    IF ISNULL(@EMP_ID,0) =0
		BEGIN			
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Employee Doesn''t exists',@Alpha_Emp_Code,'Enter proper Employee Code',GETDATE(),'Reimbursement Approval Import',@GUID)			
			RETURN -1
		END
		
	SELECT @RC_ID = AD_ID , @Negative_Balance = ISNULL(Negative_Balance,0) FROM T0050_AD_MASTER WITH (NOLOCK) WHERE AD_NAME = @Reim_Allow_Name AND Cmp_ID = @Cmp_Id
	
    IF @RC_ID = 0 
		BEGIN
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Employee reimbursment Allowance Name Doesn''t exists',@Alpha_Emp_Code,'Enter proper Employee Reimbursment Allowance Name',GETDATE(),'Reimbursement Approval Import',@GUID)			
			RETURN -1
		END
	
	if @Apr_Date is null
		Begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Approval Date Doesn''t exists',@Alpha_Emp_Code,'Enter proper Approval Date',GETDATE(),'Reimbursement Approval Import',@GUID)			
			RETURN -1
		End
	
	if @Payment_date is null
		Begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Payment Date Doesn''t exists',@Alpha_Emp_Code,'Enter proper Payment Date',GETDATE(),'Reimbursement Approval Import',@GUID)			
			RETURN -1
		End
    
    IF @RC_Apr_Effect_In_Salary = 1
		BEGIN
			IF EXISTS(SELECT Sal_tran_Id FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID AND @Payment_date >= Month_St_Date AND @Payment_date <= Month_End_Date)
				BEGIN
					SET @Log_Status=1
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'This Months Salary Exists.So You Cant Add/Update This Record.',@Alpha_Emp_Code,'This Months Salary Exists.So You Cant Add/Update This Record.',GETDATE(),'Reimbursement Approval Import',@GUID)			
					RETURN -1
				END
		END
		
    IF MONTH(@Apr_Date) >= 4
		BEGIN
			SET @St_date =  '01/April/'+CAST(YEAR(@Apr_Date) AS VARCHAR(4)) 
			SET @End_Date = '31/March/'+CAST( (YEAR(@Apr_Date)+1) AS VARCHAR(4)) 
		END
	ELSE
		BEGIN
			SET @St_date =  '01/April/'+CAST( (YEAR(@Apr_Date)-1) AS VARCHAR(4)) 
			SET @End_Date = '31/March/'+CAST(YEAR(@Apr_Date) AS VARCHAR(4))
		END

	SELECT @Taxable_limit = Taxable_limit,@Non_Taxable_limit =Non_Taxable_limit FROM t0040_ReimClaim_Setting WITH (NOLOCK) WHERE AD_ID = @RC_ID AND cmp_ID=@Cmp_ID
				
	SELECT	@Taxable_Count =COUNT(*) FROM T0100_RC_Application A WITH (NOLOCK)
	WHERE	APP_Date BETWEEN @St_date AND @End_Date AND A.Cmp_ID=@cmp_ID AND A.Emp_ID=@emp_ID AND APP_Status=1 AND 
			ISNULL(A.Tax_Exception,0) = 0 AND RC_ID = @RC_ID							
		
	SELECT @Non_Taxable_Count =COUNT(*) 
	FROM T0100_RC_Application A WITH (NOLOCK)
	WHERE  APP_Date BETWEEN @St_date AND @End_Date AND A.Cmp_ID=@cmp_ID AND A.Emp_ID=@emp_ID AND APP_Status=1 AND 
		ISNULL(A.Tax_Exception,0) = 1 AND RC_ID = @RC_ID
		
	IF ISNULL(@Taxable,0) = 1
		BEGIN
			IF ISNULL(@Non_Taxable_limit,0) <> 0
				BEGIN				    			   			 					
					IF @Non_Taxable_limit <= @Non_Taxable_Count
						BEGIN							
							--RAISERROR('@@Tax free application is exceed in year.@@',16,2)
							SET @Log_Status=1
							INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Tax free application is exceed in year.',@Alpha_Emp_Code,'Tax free application is exceed in year.',GETDATE(),'Reimbursement Approval Import',@GUID)			
							
							RETURN -1
						END
				END		
		END
	ELSE
		BEGIN
			IF ISNULL(@Taxable_limit,0) <> 0
				BEGIN
					IF @Taxable_limit <= @Taxable_Count
						BEGIN					
							--RAISERROR('@@Taxable application is exceed in year@@',16,2)	
							SET @Log_Status=1
							INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Taxable application is exceed in year.',@Alpha_Emp_Code,'Taxable application is exceed in year.',GETDATE(),'Reimbursement Approval Import',@GUID)			
										
							RETURN -1				
						END
				END
		END
	
	SET @MnthSt_date = '01/'+ DATENAME(mm,@Apr_Date) +'/'+ CAST(YEAR(@Apr_Date) AS VARCHAR(10))
	SET @MnthEnd_Date =DATEDIFF(DD,1,DATEADD(mm, 1, @MnthSt_date))
	
	SELECT @Monthly_Limit = Monthly_Limit FROM t0050_Ad_Master WITH (NOLOCK) WHERE  Ad_ID = @RC_ID
	
	IF @Monthly_Limit <> 0
		BEGIN
			SELECT @Monthly_LimitCount = COUNT(*) FROM T0100_RC_Application A WITH (NOLOCK)
			WHERE  APP_Date BETWEEN @MnthSt_date AND @MnthEnd_Date AND A.Cmp_ID=@cmp_ID AND A.Emp_ID=@emp_ID  AND APP_Status=1 AND RC_ID = @RC_ID
			
			IF @Monthly_Limit <= @Monthly_LimitCount
				BEGIN
					--RAISERROR('@@Application limit is exceed in this month.@@',16,2)				
					SET @Log_Status=1
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Application limit is exceed in this month',@Alpha_Emp_Code,'Application limit is exceed in this month.',GETDATE(),'Reimbursement Approval Import',@GUID)			
							
					RETURN -1
				END
		END
    
    
    
 --   SELECT @Total_Paid_Amount=ISNULL(SUM(RCA.Apr_Amount),0) FROM T0140_ReimClaim_Transacation I INNER JOIN
	--		T0120_RC_Approval RCA ON RCA.RC_APR_ID = I.RC_apr_ID
	--WHERE I.For_Date >= @St_date AND I.For_Date <=@For_date
	--		AND I.Cmp_ID = @Cmp_ID AND I.Emp_ID=@EMP_ID AND RCA.RC_ID = @RC_ID
				
	SELECT @Total_Paid_Amount= @Total_Paid_Amount + ISNULL(SUM(MRD.Tax_Free_amount),0) FROM T0210_monthly_Reim_Detail MRD WITH (NOLOCK)
	WHERE For_Date >= @St_date AND For_Date <=@For_date
			AND Cmp_ID = @Cmp_ID AND Emp_ID=@EMP_ID AND MRD.RC_ID = @RC_ID  
	
    SELECT @Grd_ID=I.Grd_ID FROM T0095_Increment I WITH (NOLOCK) INNER JOIN 
			( SELECT MAX(Increment_effective_Date) AS For_Date , Emp_ID FROM T0095_Increment WITH (NOLOCK)
				WHERE Increment_Effective_date <= @For_date AND Cmp_ID = @Cmp_ID AND Emp_ID=@EMP_ID GROUP BY emp_ID  
			) Qry ON I.Emp_ID = Qry.Emp_ID	AND I.Increment_effective_Date = Qry.For_Date
	WHERE Cmp_ID = @Cmp_ID AND I.Emp_ID = @Emp_ID
    
    SELECT @Non_Taxable =  ((ISNULL(AD_NON_TAX_LIMIT,0))/12) * CASE WHEN DATEDIFF(MONTH, @Date_of_join, @End_Date) + 1 < 12 THEN DATEDIFF(MONTH, @Date_of_join, @End_Date) + 1 ELSE 12 END
	FROM T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) WHERE Grd_ID = @Grd_ID AND Ad_ID=@RC_ID AND cmp_ID=@cmp_ID		
    
    IF ISNULL(@Negative_Balance,0) = 0 AND (ISNULL(@Non_Taxable,0) - ISNULL(@Total_Paid_Amount,0)) < @Tax_Free_Amount
		BEGIN
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code ,'Tax free amount is more than limit',@Alpha_Emp_Code,'Tax free amount is more than limit',GETDATE(),'Reimbursement Approval Import',@GUID)			
					
			RETURN -1
		END
    
    
    SET @RC_APR_ID  = 0 
	SELECT @RC_APR_ID = ISNULL(MAX(RC_APR_ID),0) + 1  FROM T0120_RC_Approval WITH (NOLOCK)

	INSERT INTO T0120_RC_Approval(RC_APR_ID,Cmp_ID,RC_APP_ID,Emp_ID,RC_ID,Apr_Date,Apr_Amount,Taxable_Exemption_amount,APr_Comments,APR_Status,RC_Apr_Effect_In_Salary
			,RC_Apr_Cheque_No,Payment_Mode,CreateBy,DateCreated,ModifyBy,ModifyDate,S_emp_ID,Payment_date,Direct_Approval)
	VALUES(@RC_APR_ID,@Cmp_ID,@RC_APP_ID,@Emp_ID,@RC_ID,@Apr_Date,@Tax_Free_Amount,@Apr_Amount,@APr_Comments,1,@RC_Apr_Effect_In_Salary
			,'',@Payment_Type,@User_ID,GETDATE(),@User_ID,GETDATE(),0,@Payment_date,1)
	
	
	DECLARE @FY  VARCHAR(255)	--As per Reim Approval Page
	--SET @FY = '2014-2017'
	SET @FY = '' + cast(YEAR(@St_date) as VARCHAR(5)) + '-'+ cast(YEAR(@End_Date) as varchar(5)) + ''
	
	EXEC P0100_RC_Application @RC_APP_ID OUTPUT,@Cmp_ID,@Emp_ID,@RC_ID,@Apr_Date,@Tax_Free_Amount,@APr_Comments,1,@Apr_Date ,@Apr_Date,0,@FY,1,'I','',@RC_APR_ID,1,0,@Apr_Amount,0
	
	ALTER TABLE T0120_RC_Approval DISABLE TRIGGER Tri_T0120_RC_APPROVAL 
	
	UPDATE T0120_RC_Approval SET RC_App_ID = @RC_APP_ID WHERE RC_APR_ID =@RC_APR_ID AND cmp_ID=@Cmp_ID
	
	ALTER TABLE T0120_RC_Approval ENABLE TRIGGER Tri_T0120_RC_APPROVAL 
		
    
END


