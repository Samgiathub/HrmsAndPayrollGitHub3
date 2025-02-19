
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0210_MONTHLY_LOAN_PAYMENT_INSERT]
	 @Loan_Pay_ID			Numeric output
	,@Loan_Apr_ID			Numeric
	,@Cmp_ID				Numeric
	,@Sal_Tran_ID			Numeric 
	,@Loan_Pay_Amount		Numeric(18,2)
	,@Loan_Pay_Comments		Varchar(250)
	,@Loan_Payment_Date		datetime
	,@Loan_Pay_Code			varchar(20)
	,@Loan_Payment_Type		varchar(20)
	,@Bank_Name				varchar(50)
	,@Loan_Cheque_No		varchar(50)
	,@Interest_Amount		Numeric(18,2)=0--Hardik 29/12/2011
	,@Interest_Percent		Numeric(18,2)=0--Hardik 29/12/2011
	,@Interest_Subsidy_Amount Numeric(18,2) = 0 -- Added by Gadriwala Muslim 26122014
	,@Is_Loan_Interest_Flag Numeric(18,2) = 0 --Added by Nilesh Patel on 22072015
	,@Subsidy_Amount Numeric(18,2) = 0
	,@Pay_Tran_ID Numeric(18,0) = 0 -- Added by Nilesh patel on 02012017
	,@Temp_Loan_Tran_ID Numeric(18,2) = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	Declare @Emp_Code numeric 
	Declare @Emp_ID numeric 
	declare @str_Emp_Code varchar(20)
	Declare @Fix_Code varchar(4)

	Declare @Pre_Loan_Pay_Amount numeric 
	set @Pre_Loan_Pay_Amount = 0


	if @Sal_Tran_ID = 0
		set @Sal_Tran_ID = null

				
	if isnull(@Sal_Tran_ID ,0)= 0
		set @Fix_code = 'LMR'
	else
		set @Fix_code = 'LMS'
	
	-- Changed by Hasmuskh on 04-FEB-2011 Loan_Pay_Amount NULL	
	If @Loan_Pay_Amount is null
		set @Loan_Pay_Amount = 0
		
	If @Interest_Subsidy_Amount is null -- Added by Gadriwala Muslim 26122014
		set @Interest_Subsidy_Amount = 0
		
		
	if @Loan_Pay_ID = 0 
		begin
				/*select @Emp_Code = EMP_CODE ,@Emp_ID= Emp_ID From T0080_EMP_MASTER WHERE 
						EMP_ID  = (Select Emp_ID From T0120_Loan_Approval Where Loan_Apr_ID= @Loan_apr_ID)
			
				
				SELECT @str_Emp_Code =DATA  FROM dbo.F_Format('0000',@Emp_Code) 
			
				select @Loan_Pay_Code =   cast(isnull(max(substring(Loan_Pay_Code,10,len(Loan_Pay_Code))),0) + 1 as varchar)  
						from T0210_MONTHLY_LOAN_PAYMENT 
						where Loan_Apr_ID  in (select Loan_Apr_ID From T0120_Loan_Approval Where Emp_ID = @Emp_ID)
				
				If charindex(':',@Loan_Pay_Code) > 0 
					Select @Loan_Pay_Code = right(@Loan_Pay_Code,len(@Loan_Pay_Code) - charindex(':',@Loan_Pay_Code))
				
				if @Loan_Pay_Code is not null
					begin
						while len(@Loan_Pay_Code) <> 4
							begin
								set @Loan_Pay_Code = '0' + @Loan_Pay_Code
							end
						set @Loan_Pay_Code = @Fix_code + @str_Emp_Code +':'+ @Loan_Pay_Code  
					end
				else
					SET @Loan_Pay_Code = @Fix_code + @str_Emp_Code + ':' + '0001' 					
		*/
		
	--	if @Loan_Payment_Type <> 'Cash'
	--	  Begin
			If @Sal_Tran_ID > 0
				Begin
					if Not exists (Select Loan_Pay_ID  from T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) Where Loan_Payment_Date = @Loan_Payment_Date and Cmp_ID = @Cmp_ID and Loan_Apr_ID=@Loan_Apr_ID And Sal_Tran_ID = @Sal_Tran_ID)
						Begin
							--begin			
							--	set @Loan_Pay_ID=0
							--end
				
							SET @Loan_Pay_Code = cast(@Loan_Pay_ID as varchar(20))
							if isnull(@Sal_Tran_ID,0) > 0 set @Loan_Payment_Type = ''
							select @Loan_Pay_ID = isnull(max(Loan_Pay_ID),0) +1  from T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK)
							insert into T0210_MONTHLY_LOAN_PAYMENT
							(Loan_Pay_ID,Loan_Apr_ID,Cmp_ID,Temp_Sal_Tran_ID,Loan_Pay_Amount,Loan_Pay_Comments,Loan_Payment_Date,Loan_Payment_Type,Bank_Name,Loan_Cheque_No,Loan_Pay_Code,Interest_Amount,Interest_Percent,Interest_Subsidy_Amount,Is_Loan_Interest_Flag,Subsidy_Amount,Temp_Loan_Pay_ID)
							 values	(@Loan_Pay_ID,@Loan_Apr_ID,@Cmp_ID,@Sal_Tran_ID,@Loan_Pay_Amount,@Loan_Pay_Comments,@Loan_Payment_Date,@Loan_Payment_Type,@Bank_Name,@Loan_Cheque_No,@Loan_Pay_Code,@Interest_Amount,@Interest_Percent,@Interest_Subsidy_Amount,@Is_Loan_Interest_Flag,@Subsidy_Amount,@Temp_Loan_Tran_ID) -- Added by Gadriwala Muslim 26122014
						End
					Else
   						Begin					
   							Update T0210_MONTHLY_LOAN_PAYMENT 
									set Loan_Pay_Amount = Loan_Pay_Amount + @Loan_Pay_Amount,
									Loan_Pay_Comments = @Loan_Pay_Comments,
									Loan_Payment_Date = @Loan_Payment_Date,
									Loan_Payment_Type = @Loan_Payment_Type,
									Bank_Name = @Bank_Name,
									Loan_Cheque_No = @Loan_Cheque_No,
									Temp_Sal_Tran_ID = @Sal_Tran_ID,
									Interest_Amount = @Interest_Amount,
									Interest_Percent = @Interest_Percent,
									Interest_Subsidy_Amount = @Interest_Subsidy_Amount, -- Added by Gadriwala Muslim 26122014
									Is_Loan_Interest_Flag = @Is_Loan_Interest_Flag -- Added by Nilesh Patel on 22072015
									,Subsidy_Amount=@Subsidy_Amount
									where Loan_Apr_ID = @Loan_Apr_ID and CMP_ID = CMP_ID 
										And Sal_Tran_ID = @Sal_Tran_ID
   						End		 
				End	
	       else 
		       begin
					if Not exists (Select Loan_Pay_ID  from T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) Where Loan_Payment_Date = @Loan_Payment_Date and Cmp_ID = @Cmp_ID and Loan_Apr_ID=@Loan_Apr_ID And Sal_Tran_ID = @Sal_Tran_ID)
						Begin	
							SET @Loan_Pay_Code = cast(@Loan_Pay_ID as varchar(20))
							if isnull(@Sal_Tran_ID,0) > 0 set @Loan_Payment_Type = ''
							select @Loan_Pay_ID = isnull(max(Loan_Pay_ID),0) +1  from T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK)
							insert into T0210_MONTHLY_LOAN_PAYMENT
							(Loan_Pay_ID,Loan_Apr_ID,Cmp_ID,Temp_Sal_Tran_ID,Loan_Pay_Amount,Loan_Pay_Comments,Loan_Payment_Date,Loan_Payment_Type,Bank_Name,Loan_Cheque_No,Loan_Pay_Code,Interest_Amount,Interest_Percent,Interest_Subsidy_Amount,Is_Loan_Interest_Flag,Subsidy_Amount,Temp_Loan_Pay_ID)
							values	(@Loan_Pay_ID,@Loan_Apr_ID,@Cmp_ID,@Sal_Tran_ID,@Loan_Pay_Amount,@Loan_Pay_Comments,@Loan_Payment_Date,@Loan_Payment_Type,@Bank_Name,@Loan_Cheque_No,@Loan_Pay_Code,@Interest_Amount,@Interest_Percent,@Interest_Subsidy_Amount,@Is_Loan_Interest_Flag,@Subsidy_Amount,@Temp_Loan_Tran_ID) -- Added by Gadriwala Muslim 26122014
						End
					Else
						Begin
							Update T0210_MONTHLY_LOAN_PAYMENT 
							set Loan_Pay_Amount = Loan_Pay_Amount + @Loan_Pay_Amount,
							Loan_Pay_Comments = @Loan_Pay_Comments,
							Loan_Payment_Date = @Loan_Payment_Date,
							Loan_Payment_Type = @Loan_Payment_Type,
							Bank_Name = @Bank_Name,
							Loan_Cheque_No = @Loan_Cheque_No,
							Temp_Sal_Tran_ID = @Sal_Tran_ID,
							Interest_Amount = @Interest_Amount,
							Interest_Percent = @Interest_Percent,
							Interest_Subsidy_Amount = @Interest_Subsidy_Amount, -- Added by Gadriwala Muslim 26122014
							Is_Loan_Interest_Flag = @Is_Loan_Interest_Flag -- Added by Nilesh Patel on 22072015
									where Loan_Apr_ID = @Loan_Apr_ID and CMP_ID = CMP_ID 
										And Sal_Tran_ID = @Sal_Tran_ID
						End
		        End
		END
	 Else
		Begin
							Update T0210_MONTHLY_LOAN_PAYMENT 
							set Loan_Pay_Amount = Loan_Pay_Amount + @Loan_Pay_Amount,
							Loan_Pay_Comments = @Loan_Pay_Comments,
							Loan_Payment_Date = @Loan_Payment_Date,
							Loan_Payment_Type = @Loan_Payment_Type,
							Bank_Name = @Bank_Name,
							Loan_Cheque_No = @Loan_Cheque_No,
							Temp_Sal_Tran_ID = @Sal_Tran_ID,
							Interest_Amount = @Interest_Amount,
							Interest_Percent = @Interest_Percent,
							Interest_Subsidy_Amount = @Interest_Subsidy_Amount, -- Added by Gadriwala Muslim 26122014
							Is_Loan_Interest_Flag = @Is_Loan_Interest_Flag -- Added by Nilesh Patel on 22072015
							,Subsidy_Amount=@Subsidy_Amount
							where Loan_Pay_ID = @Loan_Pay_ID and CMP_ID = CMP_ID
		End
	RETURN


