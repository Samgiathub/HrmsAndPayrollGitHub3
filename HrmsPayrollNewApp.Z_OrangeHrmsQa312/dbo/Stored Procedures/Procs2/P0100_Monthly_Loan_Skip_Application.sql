

-- =============================================
-- Author:		Nilesh Patel
-- Create date: 29082016
-- Description:	Create For Store Skip Loan Amount Details 
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_Monthly_Loan_Skip_Application]
	-- Add the parameters for the stored procedure here
	@Tran_ID Numeric(18,0) Output,
	@Request_ID Numeric(18,0),
	@Cmp_ID Numeric(18,0),
	@Emp_ID Numeric(18,0),
	@Loan_Apr_ID Numeric(18,0),
	@Loan_ID Numeric(18,0),
	@Old_Install_Amount Numeric(18,2),
	@New_Install_Amount Numeric(18,2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Select @Tran_ID = Isnull(MAX(Tran_ID),0) + 1 From T0100_Monthly_Loan_Skip_Application WITH (NOLOCK)
	
	Insert into T0100_Monthly_Loan_Skip_Application(Tran_ID,Request_ID,Cmp_ID,Emp_ID,Loan_Apr_ID,Loan_ID,Old_Install_Amount,New_Install_Amount)
	VALUES(@Tran_ID,@Request_ID,@Cmp_ID,@Emp_ID,@Loan_Apr_ID,@Loan_ID,@Old_Install_Amount,@New_Install_Amount)
	
	
	
END

