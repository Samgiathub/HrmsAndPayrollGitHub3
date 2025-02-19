

-- =============================================
-- Author:		Nilesh Patel 
-- Create date: 07-11-2016
-- Description:	Create Sp For Interest Calculation As perquitsite in Income Tax
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_LOAN_INTEREST_DETAILS]
	-- Add the parameters for the stored procedure here
	@Cmp_ID Numeric(18,0),
	@Loan_ID Numeric(18,0),
	@Standard_Rates Numeric(18,4),
	@Effective_Date DateTime
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	Declare @Trans_ID Numeric(18,0)
    -- Insert statements for procedure here
	if not Exists(Select 1 From T0050_Loan_Interest_Details WITH (NOLOCK) Where Loan_ID = @Loan_ID and Cmp_ID = @Cmp_ID and Effective_Date = @Effective_Date)
		BEGIN
			SELECT @Trans_ID = Isnull(Max(Trans_ID),0) + 1 From T0050_Loan_Interest_Details WITH (NOLOCK)
			Insert into T0050_Loan_Interest_Details VALUES(@Trans_ID,@Cmp_ID,@Loan_ID,@Standard_Rates,@Effective_Date);
		End
	Else
		Begin
			Update T0050_Loan_Interest_Details
				Set Standard_Rates = @Standard_Rates
			Where Loan_ID = @Loan_ID and Cmp_ID = @Cmp_ID and Effective_Date = @Effective_Date
		End 
END

