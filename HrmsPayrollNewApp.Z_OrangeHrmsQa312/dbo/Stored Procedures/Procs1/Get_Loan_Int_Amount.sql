


---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Loan_Int_Amount]
	@Cmp_ID			numeric,
	@Loan_Id		numeric,
	@Emp_Id			numeric,
	@Loan_Apr_ID	numeric = 0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	Declare @Loan_Apr_Date Datetime
	Declare @Loan_Int_Flag Numeric
	Set @Loan_Int_Flag = 0
	If Exists(Select 1 From T0120_LOAN_APPROVAL WITH (NOLOCK) Where Emp_ID = @Emp_Id and Loan_ID = @Loan_Id and Cmp_ID = @Cmp_ID and Loan_Apr_ID = @Loan_Apr_ID)
		BEGIN
			Select @Loan_Apr_Date = Loan_Apr_Date From T0120_LOAN_APPROVAL WITH (NOLOCK) Where Emp_ID = @Emp_Id and Loan_ID = @Loan_Id and Cmp_ID = @Cmp_ID and Loan_Apr_ID = @Loan_Apr_ID
			
			If not Exists(SELECT 1 FROM T0140_LOAN_TRANSACTION LT WITH (NOLOCK) Inner join 
				(Select Min(For_Date) as For_Date From T0140_LOAN_TRANSACTION WITH (NOLOCK)
					where Emp_ID = @Emp_Id and Loan_ID = @Loan_Id AND For_Date >= @Loan_Apr_Date
					and Is_Loan_Interest_Flag = 1 AND Loan_Return <> 0) as qry
			   on qry.For_Date = LT.For_Date
			   where Emp_ID = @Emp_Id and Loan_ID = @Loan_Id AND Is_Loan_Interest_Flag = 1 AND Loan_Return <> 0)
		    
		    BEGIN
				SELECT @Loan_Int_Flag = LT.Emp_ID FROM T0140_LOAN_TRANSACTION LT WITH (NOLOCK) Inner join 
					(Select Min(For_Date) as For_Date From T0140_LOAN_TRANSACTION WITH (NOLOCK) 
						where Emp_ID = @Emp_Id and Loan_ID = @Loan_Id AND For_Date >= @Loan_Apr_Date
						and Is_Loan_Interest_Flag = 1) as qry
				on qry.For_Date = LT.For_Date
				where Emp_ID = @Emp_Id and Loan_ID = @Loan_Id AND Is_Loan_Interest_Flag = 1
		    End
		    select @Loan_Int_Flag as int_flag
		End
END

