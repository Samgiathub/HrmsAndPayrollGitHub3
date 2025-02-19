

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_EMP_COMPANY_LOAN_TRANSFER]
	 @Row_ID 		Numeric output
	,@Loan_Tran_ID 	Numeric
	,@Tran_Id		Numeric
	,@Cmp_ID		Numeric
	,@Emp_ID		Numeric
	,@Loan_Id		Numeric
	,@Old_Balance   Numeric
	,@Curr_Emp_ID	Numeric
	,@Curr_Cmp_ID	Numeric
	,@Curr_Loan_Id  Numeric
	,@New_Balance	Numeric
	,@For_Date		DateTime
	,@Loan_Row_ID	Numeric
	,@New_Loan_Apr_Id Numeric
	,@Tran_Type		varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	--Old Detail
	Declare @Loan_Apr_ID		Numeric
	Declare @Loan_App_ID		Numeric
	Declare @Loan_Apr_Date		Datetime
	Declare @Loan_Apr_Code		varchar(20)
	Declare @Loan_Apr_Amount	Numeric
	Declare @Loan_Apr_No_of_Installment		Numeric
	Declare @Loan_Apr_Installment_Amount	Numeric(18,2)
	Declare @Loan_Apr_Intrest_Type		Varchar(20)
	Declare @Loan_Apr_Intrest_Per		Numeric(12,2)
	Declare @Loan_Apr_Intrest_Amount	Numeric(18,2)
	Declare @Loan_Apr_Deduct_From_Sal	Numeric
	Declare @Loan_Apr_Pending_Amount	Numeric(18,2)
	Declare @Loan_apr_By				varchar(100)
	Declare @Loan_Apr_Payment_Date		Datetime 
	Declare @Loan_Apr_Payment_Type		Varchar(20)
	Declare @Bank_ID					Numeric
	Declare @Loan_Apr_Cheque_No			Varchar(10)
	Declare @Loan_Mode					char
	Declare @Loan_Number				varchar(50)
	Declare @Deduction_Type				varchar(20)
	Declare @Loan_Attachment			varchar(200)
	Declare @Loan_Dedu_Start_Date       Datetime 
	
	Set @Loan_Attachment  =null
	Set @Loan_Dedu_Start_Date = null 
	Set @Loan_Apr_Payment_Date = null
	
	Select @Loan_Apr_ID = Loan_Apr_ID ,@Loan_Apr_No_of_Installment =  Loan_Apr_No_of_Installment,@Loan_Apr_Installment_Amount = Loan_Apr_Installment_Amount,@Loan_Apr_Intrest_Type=Loan_Apr_Intrest_Type,
		   @Loan_Apr_Intrest_Per = Loan_Apr_Intrest_Per ,@Loan_Apr_Intrest_Amount = Loan_Apr_Installment_Amount,@Loan_Apr_Deduct_From_Sal = Loan_Apr_Deduct_From_Sal,@Loan_Apr_Pending_Amount = Loan_Apr_Pending_Amount,@Loan_apr_By = Loan_Apr_By,
		   @Loan_Apr_Payment_Date = Loan_Apr_Payment_Date,@Loan_Apr_Payment_Type = Loan_Apr_Payment_Type , @Loan_Mode = Loan_Apr_Status,@Loan_Number = Loan_Number,@Deduction_Type = Deduction_Type, 
		   @Loan_Apr_Cheque_No = Loan_Apr_Cheque_No
	From   T0120_LOAN_APPROVAL WITH (NOLOCK)
	Where  Emp_id = @Curr_Emp_ID AND Cmp_ID = @Curr_Cmp_ID And Loan_ID =@Curr_Loan_Id
	
	
	
	Declare @Count_Total Numeric
	Declare @Diff_Installment_No Numeric
	
	SELECT @Count_Total = COUNT(Loan_Apr_ID) FROM T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) Where Loan_Apr_ID = @Loan_Apr_ID
	
	IF @Count_Total > 0
		Begin
			Set @Diff_Installment_No = 	@Loan_Apr_No_of_Installment - @Count_Total
			Set @Loan_Apr_No_of_Installment = @Diff_Installment_No
		End	
	IF @Loan_Apr_No_of_Installment > 0
		Set @Loan_Apr_Installment_Amount = @New_Balance / @Loan_Apr_No_of_Installment
		
	
	IF @Loan_Apr_Payment_Date = ''
		SET @Loan_Apr_Payment_Date = NULL
		
	IF @Loan_App_ID  =0 
		SET @Loan_App_ID  = NULL
		
	IF  @Bank_ID = 0
		SET @Bank_ID = NULL
	
	Set @Loan_Apr_Date = @For_Date
	set @Loan_Apr_Payment_Date = @For_Date
	
	--Old Detail
	
	If @Tran_Type ='I' 
			Begin
				
				SELECT @New_Loan_Apr_Id = ISNULL(MAX(Loan_Apr_ID),0) + 1 	FROM T0120_LOAN_APPROVAL WITH (NOLOCK)
				
				SET @Loan_Apr_Code = cast(@New_Loan_Apr_Id as varchar(20))
				
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
					 )

				VALUES   
					(@New_Loan_Apr_Id
					,@Cmp_ID
					,@Loan_App_ID
					,@Emp_ID
					,@Loan_Apr_Date
					,@Loan_Apr_Code
					,@Loan_ID
					,@New_Balance
					,@Loan_Apr_No_of_Installment
					,@Loan_Apr_Installment_Amount
					,@Loan_Apr_Intrest_Type
					,@Loan_Apr_Intrest_Per
					,@Loan_Apr_Intrest_Amount
					,@Loan_Apr_Deduct_From_Sal
					,@Loan_Apr_Pending_Amount
					,@Loan_apr_By
					,@Loan_Apr_Payment_Date
					,@Loan_Apr_Payment_Type
					,@Bank_ID
					,@Loan_Apr_Cheque_No
					,@Loan_Mode
					,@Loan_Number
					,@Deduction_Type
					 )

		
					IF Exists(Select 1 From T0140_LOAN_TRANSACTION WITH (NOLOCK) where  Emp_id = @Curr_Emp_ID AND Cmp_ID = @Curr_Cmp_ID And Loan_ID = @Curr_Loan_Id
								   AND For_date = (SELECT MAX(for_date) FROM T0140_LOAN_TRANSACTION WITH (NOLOCK)
													WHERE emp_id = @Curr_Emp_ID AND Cmp_ID = @Curr_Cmp_ID And Loan_ID = @Curr_Loan_Id))
						Begin
							Update T0140_LOAN_TRANSACTION
							Set    Loan_Closing = 0
							where  Emp_id = @Curr_Emp_ID AND Cmp_ID = @Curr_Cmp_ID And Loan_ID = @Curr_Loan_Id
								   AND For_date = (SELECT MAX(for_date) FROM T0140_LOAN_TRANSACTION WITH (NOLOCK)
												WHERE emp_id = @Curr_Emp_ID AND Cmp_ID = @Curr_Cmp_ID And Loan_ID = @Curr_Loan_Id)
						End
				
				--Select @Loan_Tran_ID = Isnull(max(Loan_Tran_ID),0) + 1 	From T0140_LOAN_TRANSACTION		
																
				--		INSERT INTO T0140_LOAN_TRANSACTION
				--			(Loan_Tran_ID
				--			,Cmp_ID
				--			,Loan_ID
				--			,Emp_ID
				--			,For_Date
				--			,Loan_Opening
				--			,Loan_Issue,Loan_Return,Loan_Closing
				--			)
				--		VALUES   
				--			(@Loan_Tran_ID
				--			,@Cmp_ID
				--			,@Loan_Id
				--			,@Emp_ID
				--			,@For_Date
				--			,@New_Balance
				--			,0,0,@New_Balance
				--			)
				
				Select @Row_Id = Isnull(max(Row_Id),0) + 1 	From T0100_EMP_COMPANY_LOAN_TRANSFER WITH (NOLOCK)
																
						INSERT INTO T0100_EMP_COMPANY_LOAN_TRANSFER
							(Row_Id
							,Tran_Id
							,Cmp_ID
							,Emp_Id
							,Loan_Id
							,Old_Balance
							,New_Cmp_Id
							,New_Emp_Id
							,New_Loan_Id
							,New_Balance
							,Loan_Row_Id
							,New_Loan_Apr_Id
							)
						VALUES   
							(@Row_Id
							,@Tran_Id
							,@Curr_Cmp_ID
							,@Curr_Emp_ID
							,@Curr_Loan_Id
							,@Old_Balance
							,@Cmp_ID
							,@Emp_ID
							,@Loan_Id
							,@New_Balance
							,@Loan_Row_ID
							,@New_Loan_Apr_Id
							)	
			END
	else if @Tran_Type ='U' 
			begin
				--DELETE FROM T0140_LOAN_TRANSACTION WHERE Loan_Tran_ID = @Loan_Tran_ID
				DELETE FROM T0100_EMP_COMPANY_LOAN_TRANSFER WHERE Tran_Id=@Tran_ID
				
				Select @Row_Id = Isnull(max(Row_Id),0) + 1 	From T0100_EMP_COMPANY_LOAN_TRANSFER WITH (NOLOCK)
				--Select @Loan_Tran_ID = Isnull(max(Loan_Tran_ID),0) + 1 	From T0140_LOAN_TRANSACTION
				
					--INSERT INTO T0140_LOAN_TRANSACTION
					--		(Loan_Tran_ID
					--		,Cmp_ID
					--		,Loan_ID
					--		,Emp_ID
					--		,For_Date
					--		,Loan_Opening
					--		,Loan_Issue,Loan_Return,Loan_Closing
					--		)
					--VALUES   
					--		(@Loan_Tran_ID
					--		,@Cmp_ID
					--		,@Loan_Id
					--		,@Emp_ID
					--		,@For_Date
					--		,@New_Balance
					--		,0,0,@New_Balance
					--		)
					
					INSERT INTO T0100_EMP_COMPANY_LOAN_TRANSFER
						(Row_Id
						,Tran_Id
						,Cmp_ID
						,Emp_Id
						,Loan_Id
						,Old_Balance
						,New_Cmp_Id
						,New_Emp_Id
						,New_Loan_Id
						,New_Balance
						,Loan_Row_Id
						,New_Loan_Apr_Id
						)
					VALUES   
						(@Row_Id
						,@Tran_Id
						,@Curr_Cmp_ID
						,@Curr_Emp_ID
						,@Curr_Loan_Id
						,@Old_Balance
						,@Cmp_ID
						,@Emp_ID
						,@Loan_Id
						,@New_Balance
						,@Loan_Row_ID
						,@New_Loan_Apr_Id
						)	
					
					UPDATE   T0120_LOAN_APPROVAL
					SET		 Loan_Apr_Amount = @New_Balance,
							 Loan_Apr_No_of_Installment=@Loan_Apr_No_of_Installment,
							 Loan_Apr_Installment_Amount = @Loan_Apr_Installment_Amount
					Where    Loan_Apr_ID = @New_Loan_Apr_Id And Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID
					
					--UPDATE T0100_EMP_COMPANY_LOAN_TRANSFER
					--SET    New_Loan_Id = @Loan_Id,
					--	   New_Balance = @New_Balance
					--WHERE  Tran_Id = @Tran_Id AND New_Emp_Id = @Emp_ID AND New_Cmp_Id = @Cmp_ID
					
			End
	Else If @Tran_Type ='D'
			Begin
				DELETE FROM T0140_LOAN_TRANSACTION where Loan_Tran_ID = @Loan_Tran_ID
				DELETE FROM T0100_EMP_COMPANY_LOAN_TRANSFER WHERE Row_Id = @Row_Id And Tran_Id=@Tran_Id
			End
			
RETURN
