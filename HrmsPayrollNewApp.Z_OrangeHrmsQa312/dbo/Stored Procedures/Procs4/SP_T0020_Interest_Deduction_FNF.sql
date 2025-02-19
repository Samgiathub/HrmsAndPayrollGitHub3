
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_T0020_Interest_Deduction_FNF]
	-- Add the parameters for the stored procedure here
	@Tran_Id Numeric(18,0),
	@Cmp_ID Numeric(18,0),
	@Emp_ID Numeric(18,0),
	@Loan_ID Numeric(18,0),
	@Loan_Apr_ID Numeric(18,0),
	@Loan_Amount Numeric(18,2),
	@Loan_Interest_Amount Numeric(18,2),
	@Is_First_Deduction_Flag Numeric(18,0),
	@Is_Deduction_Flag Numeric(18,0),
	@tran_type varchar(10)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	DECLARE @Trans_ID Numeric(18,0)
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	if @tran_type = 'I' 
		Begin
			Select @Trans_ID = isnull(MAX(Tran_Id),0)+1 From dbo.T0020_Interest_Deduction_FNF WITH (NOLOCK)
			Insert Into T0020_Interest_Deduction_FNF
			(	Tran_Id,
				Cmp_ID,
				Emp_ID,
				Loan_ID,
				Loan_Apr_ID,
				Loan_Amount,
				Loan_Interest_Amount,
				Is_First_Deduction_Flag,
				Is_Deduction_Flag
			)
			VALUES
			(
				@Trans_ID,
				@Cmp_ID,
				@Emp_ID,
				@Loan_ID,
				@Loan_Apr_ID,
				@Loan_Amount,
				@Loan_Interest_Amount,
				@Is_First_Deduction_Flag,
				@Is_Deduction_Flag
			)
		End 
END

