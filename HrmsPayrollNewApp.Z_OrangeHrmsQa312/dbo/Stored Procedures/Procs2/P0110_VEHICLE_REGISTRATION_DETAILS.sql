
CREATE PROCEDURE [dbo].[P0110_VEHICLE_REGISTRATION_DETAILS]
	@Vehicle_Registration_ID int OUTPUT,
	@Vehicle_App_ID int,
	@Cmp_ID numeric(18, 0),
	@Emp_ID numeric(18, 0),
	@Vehicle_ID int,
	@Engine_No VARCHAR(50),	
	@Chasis_No VARCHAR(50),
	@Road_Tax FLOAT,
	@Registration_Charges FLOAT,
	@Insurance_Charges FLOAT,
	@Invoice_No VARCHAR(50),
	@Invoice_Amount FLOAT,
	@Vehicle_Docs VARCHAR(MAX),
	@Invoice_Date DATETIME,
	@Payment_Ack_Details VARCHAR(1000),
	@User_Id numeric(18,0) = 0,
    @IP_Address varchar(30)= '',
	@Tran_Type char
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN	
	If UPPER(@Tran_Type) = 'I'
		Begin	
			DECLARE @Loan_Apr_ID AS NUMERIC(18,0)
			DECLARE @Loan_Apr_Code AS VARCHAR(25)
			DECLARE @Loan_ID AS INT
			DECLARE @MAX_LIMIT AS FLOAT
			DECLARE @LOAN_AMOUNT AS FLOAT
			DECLARE @Emp_Contribution AS FLOAT
			DECLARE @Emp_Share AS FLOAT
			DECLARE @Deduction_Percentage AS FLOAT

				SET @Deduction_Percentage=0
				SELECT @Loan_ID=Loan_ID FROM T0040_LOAN_MASTER WHERE Loan_Name='Own Your Vehicle'
				SELECT @Deduction_Percentage=Deduction_Percentage FROM T0040_VEHICLE_TYPE_MASTER WHERE Vehicle_ID=@Vehicle_ID

			IF Exists(Select 1 From T0110_VEHICLE_REGISTRATION_DETAILS WITH (NOLOCK) Where CMP_ID=@Cmp_ID AND Emp_ID=@Emp_ID and Vehicle_App_ID=@Vehicle_App_ID)			
				Begin						
					select @Loan_Apr_ID=Loan_Apr_ID from T0120_LOAN_APPROVAL WHERE Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID AND Loan_ID=@Loan_ID

					--IF Exists(Select 1 From T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) Where Loan_Apr_ID = @Loan_Apr_ID AND Cmp_ID=@Cmp_ID)
					--Begin	
					--	RAISERROR('Month Salary Exists',16,2)
					--	Return -1
					--End
					UPDATE T0110_VEHICLE_REGISTRATION_DETAILS
					SET Engine_No=@Engine_No,Chasis_No=@Chasis_No,Road_Tax=@Road_Tax,Registration_Charges=@Registration_Charges,
						Insurance_Charges=@Insurance_Charges,Invoice_No=@Invoice_No,Invoice_Amount=@Invoice_Amount,Vehicle_Docs=@Vehicle_Docs,
						Transaction_By=@User_Id,Transaction_Date=GETDATE(),Invoice_Date=@Invoice_Date,Payment_Ack_Details=@Payment_Ack_Details
					WHERE CMP_ID=@Cmp_ID AND Emp_ID=@Emp_ID and Vehicle_App_ID=@Vehicle_App_ID AND Vehicle_ID=@Vehicle_ID

					SELECT @MAX_LIMIT=Max_Limit,@Emp_Share=Employee_Share,@Emp_Contribution=Initial_Emp_Contribution FROM T0120_VEHICLE_APPROVAL WHERE Cmp_ID=@Cmp_ID AND Vehicle_App_ID=@Vehicle_App_ID
					IF @Deduction_Percentage > 0
					BEGIN
						SET @LOAN_AMOUNT =((@MAX_LIMIT + @Road_Tax + @Registration_Charges + @Insurance_Charges)-(@Emp_Share + @Emp_Contribution))*@Deduction_Percentage/100

						UPDATE T0120_LOAN_APPROVAL
						SET Loan_Apr_Amount=@LOAN_AMOUNT,
							Loan_Apr_Installment_Amount=ROUND(@LOAN_AMOUNT/60,2),
							Loan_Apr_Pending_Amount=ROUND(@LOAN_AMOUNT,2),
							Loan_Apr_Payment_Date=GETDATE(),
							Installment_Start_Date=DBO.GET_MONTH_ST_DATE(MONTH(GETDATE())+1,YEAR(GETDATE()))
						WHERE CMP_ID=@Cmp_ID AND Emp_ID=@Emp_ID and Loan_Apr_ID=@Loan_Apr_ID
					END
				End		
			ELSE
				BEGIN
					Insert Into T0110_VEHICLE_REGISTRATION_DETAILS
					(Vehicle_App_ID, Cmp_ID,  Emp_ID, Vehicle_ID, Engine_No,Chasis_No,Road_Tax,Registration_Charges,Insurance_Charges,Invoice_No,Invoice_Amount,Vehicle_Docs,Transaction_By,Transaction_Date,Invoice_Date,Payment_Ack_Details)
					Values 
					(@Vehicle_App_ID, @Cmp_ID, @Emp_ID, @Vehicle_ID,@Engine_No,@Chasis_No,@Road_Tax,@Registration_Charges,@Insurance_Charges,@Invoice_No,@Invoice_Amount,@Vehicle_Docs,@User_Id,GETDATE(),@Invoice_Date,@Payment_Ack_Details)
			
					set @Vehicle_Registration_ID = @@IDENTITY	

					
					SELECT @MAX_LIMIT=Max_Limit,@Emp_Share=Employee_Share,@Emp_Contribution=Initial_Emp_Contribution FROM T0120_VEHICLE_APPROVAL WHERE Cmp_ID=@Cmp_ID AND Vehicle_App_ID=@Vehicle_App_ID
					IF  @Deduction_Percentage >0
					BEGIN
						SET @LOAN_AMOUNT =((@MAX_LIMIT + @Road_Tax + @Registration_Charges + @Insurance_Charges)-(@Emp_Share + @Emp_Contribution))*@Deduction_Percentage/100

						SELECT @Loan_Apr_ID = ISNULL(MAX(Loan_Apr_ID),0) + 1 	FROM T0120_LOAN_APPROVAL WITH (NOLOCK)
						SET @Loan_Apr_Code = cast(@Loan_Apr_ID as varchar(20))				
						INSERT INTO T0120_LOAN_APPROVAL			
						(Loan_Apr_ID
						,Cmp_ID
						,Loan_App_ID
						,Emp_ID
						,Loan_Apr_Date
						,Loan_Apr_Code
						,Loan_ID
						,Loan_Apr_Amount
						,Loan_Apr_No_of_Installment
						,Loan_Apr_Installment_Amount
						,Loan_Apr_Intrest_Type
						,Loan_Apr_Intrest_Per
						,Loan_Apr_Intrest_Amount
						,Loan_Apr_Deduct_From_Sal
						,Loan_Apr_Pending_Amount
						,Loan_apr_By
						,Loan_Apr_Payment_Date
						,Loan_Apr_Payment_Type
						,Bank_ID
						,Loan_Apr_Cheque_No
						,Loan_Apr_Status
						,Loan_Number
						,Deduction_Type
						,Guarantor_Emp_ID
						,Installment_Start_Date
						,Loan_Approval_Remarks		
						)
						VALUES   
						(@Loan_Apr_ID
						,@Cmp_ID
						,NULL
						,@Emp_ID
						,GETDATE()
						,@Loan_Apr_Code
						,@Loan_ID
						,ROUND(@LOAN_AMOUNT,2)
						,60
						,ROUND(@LOAN_AMOUNT/60,2)
						,'Fix'
						,0
						,0
						,1
						,ROUND(@LOAN_AMOUNT,2)--@Loan_Apr_Pending_Amount
						,'admin'
						,GETDATE()
						,'Monthly'
						,NULL
						,''
						,'A'--@Loan_Mode
						,NULL--@Loan_Number
						,'Monthly'
						,NULL
						,DBO.GET_MONTH_ST_DATE(MONTH(GETDATE())+1,YEAR(GETDATE()))
						,''			
						)			
						return
					END
			End	
		END
	ELSE If UPPER(@Tran_Type) = 'D'
		Begin			
			--IF Exists(Select 1 From T0110_VEHICLE_REGISTRATION_DETAILS WITH (NOLOCK) Where CMP_ID=@Cmp_ID AND Emp_ID=@Emp_ID and Vehicle_App_ID=@Vehicle_App_ID)			
			--	Begin
			--		Set @Vehicle_Registration_ID = 0
			--		Return 
			--	End		
			DELETE FROM T0110_VEHICLE_REGISTRATION_DETAILS WHERE CMP_ID=@Cmp_ID AND Emp_ID=@Emp_ID and Vehicle_App_ID=@Vehicle_App_ID
			return
		End	
END


