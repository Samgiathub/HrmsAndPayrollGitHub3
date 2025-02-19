



---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0210_Monthly_Loan_Payment_NIIT]
	@Cmp_ID						numeric(18,0)
	,@Emp_Code					numeric(18,0)	
    ,@Loan_Apr_ID				Numeric
     ,@Loan_Payment_Date		datetime
     ,@Loan_Pay_Amount			Numeric
     
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	 
	Declare @Loan_Pay_ID	Numeric 
	Declare @Sal_Tran_ID	Numeric 
	Declare @Loan_Pay_Comments		Varchar(250)
	Declare @Loan_Payment_Type		varchar(20)
	Declare @Bank_Name				varchar(50)
	Declare @Loan_Cheque_No		varchar(50)
	Declare @tran_type				char(1)
	 
	 set @Loan_Pay_ID = 0
	 set @Loan_Pay_ID = 0
	 set @Loan_Pay_Comments = ''
	 set @Loan_Payment_Type = ''
	 set @Bank_Name = ''
	 set @Loan_Cheque_No = ''
	 set @tran_type = 'I'
	 if @Sal_Tran_ID = 0
		set @Sal_Tran_ID = null
	
	set @Loan_Apr_ID = 1
	Declare @Pre_Loan_Pay_Amount numeric 
	set @Pre_Loan_Pay_Amount = 0

	if @tran_type ='I' 
	begin
		
			if exists (Select Loan_Pay_ID  from T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) Where Loan_Payment_Date = @Loan_Payment_Date and Cmp_ID = @Cmp_ID and Loan_Apr_ID=@Loan_Apr_ID) 
				begin
					set @Loan_Pay_ID=0
				end
			else
				Begin
					
					select @Loan_Pay_ID = isnull(max(Loan_Pay_ID),0) +1  from T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) 
								
					Insert into T0210_MONTHLY_LOAN_PAYMENT
					(Loan_Pay_ID,Loan_Apr_ID,Cmp_ID,Sal_Tran_ID,Loan_Pay_Amount,Loan_Pay_Comments,Loan_Payment_Date,Loan_Payment_Type,Bank_Name,Loan_Cheque_No)
					Values	(@Loan_Pay_ID,@Loan_Apr_ID,@Cmp_ID,@Sal_Tran_ID,@Loan_Pay_Amount,@Loan_Pay_Comments,@Loan_Payment_Date,@Loan_Payment_Type,@Bank_Name,@Loan_Cheque_No)
				
		end 
	end
	else if @tran_type ='U' 
		begin
					select @Pre_Loan_Pay_Amount = Loan_Pay_Amount from T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK)
							Where Loan_Pay_ID = @Loan_Pay_ID 
		
			--		update T0120_LOAN_APPROVAL
			 --		set Loan_Apr_Pending_Amount = (Loan_Apr_Pending_Amount - @Loan_Pay_Amount) + @Pre_Loan_Pay_Amount
			--		where  Loan_Apr_ID = @Loan_Apr_ID


					Update T0210_MONTHLY_LOAN_PAYMENT 
						set Loan_Pay_Amount = @Loan_Pay_Amount,
						Loan_Pay_Comments = @Loan_Pay_Comments,
						Loan_Payment_Date = @Loan_Payment_Date,
						Loan_Payment_Type = @Loan_Payment_Type,
						Bank_Name = @Bank_Name,
						Loan_Cheque_No = @Loan_Cheque_No
						where Loan_Pay_ID = @Loan_Pay_ID and CMP_ID = CMP_ID
		end	
	else if @tran_type ='d' 
		Begin
				select @Pre_Loan_Pay_Amount = Loan_Pay_Amount from T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK)
						Where Loan_Pay_ID = @Loan_Pay_ID 
		
			--		update T0120_LOAN_APPROVAL
			 --		set Loan_Apr_Pending_Amount = Loan_Apr_Pending_Amount - @Pre_Loan_Pay_Amount
			--		where  Loan_Apr_ID = @Loan_Apr_ID
		
				
			delete  from T0210_MONTHLY_LOAN_PAYMENT where Loan_Pay_ID=@Loan_Pay_ID 
		End
			
	
	RETURN




