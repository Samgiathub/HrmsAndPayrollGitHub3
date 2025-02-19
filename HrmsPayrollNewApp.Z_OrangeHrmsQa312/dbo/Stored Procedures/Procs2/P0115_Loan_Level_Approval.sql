




-- =============================================
-- Author:		<Ankit>
-- Create date: <01052014,,>
-- Description:	<Description,,>
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================

CREATE PROCEDURE [dbo].[P0115_Loan_Level_Approval]
	 @Tran_ID				Numeric output
	,@Loan_Apr_ID			Numeric 
	,@Cmp_ID				Numeric
	,@Loan_App_ID			Numeric
	,@Emp_ID				Numeric
	,@Loan_ID				Numeric
	,@Loan_Apr_Date			Datetime
	,@Loan_Apr_Code			varchar(20)
	,@Loan_Apr_Amount				Numeric
	,@Loan_Apr_No_of_Installment	Numeric
	,@Loan_Apr_Installment_Amount	Numeric(18,2)
	,@Loan_Apr_Intrest_Type			Varchar(20)
	,@Loan_Apr_Intrest_Per			Numeric(12,2)
	,@Loan_Apr_Intrest_Amount		Numeric(18,2)
	,@Loan_Apr_Deduct_From_Sal		Numeric
	,@Loan_Apr_Pending_Amount		Numeric(18,2)
	,@Loan_apr_By					varchar(100)
	,@Loan_Apr_Payment_Date			Datetime = null
	,@Loan_Apr_Payment_Type			Varchar(20)
	,@Bank_ID						Numeric
	,@Loan_Apr_Cheque_No			Varchar(10)
	,@Loan_Number					varchar(50)
	,@Deduction_Type				varchar(20)
	,@S_Emp_Id						Numeric
	,@Approval_Status				Char(1)
	,@Rpt_Level						TinyInt
	,@tran_type						varchar(1)
	,@Loan_Approval_Remarks			Varchar(250)
	,@No_of_Inst_Loan_Amt			Numeric(18,0)
	,@Total_Loan_Int_Amount			Numeric(18,2)
	,@Loan_Int_Installment_Amount	Numeric(18,2)
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	If Upper(@Tran_Type) = 'I'
		Begin
		
			IF Exists(Select 1 From T0115_Loan_Level_Approval WITH (NOLOCK) Where Emp_ID=@Emp_ID and Loan_App_ID=@Loan_App_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level)
				Begin
					Set @Tran_ID = 0
					Select @Tran_ID
					Return
				End
			
			Select @Tran_ID = isnull(max(Tran_ID),0) + 1 from T0115_Loan_Level_Approval WITH (NOLOCK)
			
			Insert Into T0115_Loan_Level_Approval
					(Tran_Id ,Loan_Apr_ID,Cmp_ID,Loan_App_ID,Emp_ID,Loan_Apr_Date,Loan_Apr_Code,Loan_ID,Loan_Apr_Amount,Loan_Apr_No_of_Installment,Loan_Apr_Installment_Amount
					,Loan_Apr_Intrest_Type,Loan_Apr_Intrest_Per,Loan_Apr_Intrest_Amount,Loan_Apr_Deduct_From_Sal,Loan_Apr_Pending_Amount,Loan_apr_By,Loan_Apr_Payment_Date,Loan_Apr_Payment_Type
					,Bank_ID,Loan_Apr_Cheque_No,Loan_Number,Deduction_Type,S_Emp_Id,Loan_Apr_Status,Rpt_Level,System_Date,Loan_Approval_Remarks,No_of_Inst_Loan_Amt,Total_Loan_Int_Amount,Loan_Int_Installment_Amount
					)
					
			Values
					(@Tran_Id,@Loan_Apr_ID,@Cmp_ID,@Loan_App_ID,@Emp_ID,@Loan_Apr_Date,@Loan_Apr_Code,@Loan_ID,@Loan_Apr_Amount,@Loan_Apr_No_of_Installment,@Loan_Apr_Installment_Amount
					,@Loan_Apr_Intrest_Type,@Loan_Apr_Intrest_Per,@Loan_Apr_Intrest_Amount,@Loan_Apr_Deduct_From_Sal,@Loan_Apr_Pending_Amount,@Loan_apr_By,@Loan_Apr_Payment_Date,@Loan_Apr_Payment_Type
					,@Bank_ID,@Loan_Apr_Cheque_No,@Loan_Number,@Deduction_Type,@S_Emp_Id,@Approval_Status,@Rpt_Level, GetDate(),@Loan_Approval_Remarks,@No_of_Inst_Loan_Amt,@Total_Loan_Int_Amount,@Loan_Int_Installment_Amount)
		End
END




