

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_Loan_Master_Details]
	-- Add the parameters for the stored procedure here
	@Loan_ID Numeric(18,0),
	@Cmp_ID	 Numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN

    -- Insert statements for procedure here
	if Exists(Select 1 From T0050_Loan_Interest_Details WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Loan_ID = @Loan_ID)
		BEGIN
			select LM.Loan_ID, Loan_Name, Loan_Max_Limit, Loan_Comments,isnull(Company_Loan,0) as Company_Loan,Max_Limit_on_Basic_Gross,Allowance_Id_String_Max_Limit, No_Of_Times,isnull(Loan_Guarantor,0) as Loan_Guarantor,isnull(Desig_max_limit,0)as Desig_max_limit,Is_Interest_Subsidy_Limit,Interest_Recovery_Per,isnull(Subsidy_Desig_Id_String,'') as Subsidy_Desig_Id_String,isnull(Loan_Interest_Type,'') as Loan_Interest_Type ,Loan_Interest_Per,Is_Attachment,Is_Eligible,Eligible_Days,Subsidy_Bond_Days,Is_GPF,GPF_Eligible_Month,GPF_days_diff_application,GPF_Max_Loan_per,Is_Principal_First_than_Int,Loan_Guarantor2,Is_Grade_Wise,Grade_Details,Loan_Short_Name,is_subsidy_loan,Subsidy_bond_month,Is_Intrest_Amount_As_Perquisite_IT,LD.Effective_Date,Standard_Rates,LM.Hide_Loan_Max_Amount 
			,Loan_Application_Reason_Required,Max_Installment --Added By Jimit 16102018
			,isnull(IsContractDue,0) IsContractDue,isnull(ContractDueDays,0) ContractDueDays  --Added by ronakk 27032023
			From T0040_LOAN_MASTER LM WITH (NOLOCK)
			LEFT OUTER JOIN T0050_Loan_Interest_Details LD WITH (NOLOCK)
			ON LM.Loan_ID = LD.Loan_ID 
			INNER JOIN(
					   SELECT MAX(Effective_Date) as Effective_Date,Loan_ID,Cmp_ID 
					   FROM T0050_Loan_Interest_Details WITH (NOLOCK) group by Loan_ID,Cmp_ID 
					  ) As Qry 
			ON Qry.Loan_ID = LD.Loan_ID and Qry.Effective_Date = LD.Effective_Date 
			where LM.Loan_ID = @Loan_ID and LM.Cmp_ID = @Cmp_ID
		End
	Else
		Begin
			select LM.Loan_ID, Loan_Name, Loan_Max_Limit, Loan_Comments,isnull(Company_Loan,0) as Company_Loan,Max_Limit_on_Basic_Gross,Allowance_Id_String_Max_Limit, No_Of_Times,isnull(Loan_Guarantor,0) as Loan_Guarantor,isnull(Desig_max_limit,0)as Desig_max_limit,Is_Interest_Subsidy_Limit,Interest_Recovery_Per,isnull(Subsidy_Desig_Id_String,'') as Subsidy_Desig_Id_String,isnull(Loan_Interest_Type,'') as Loan_Interest_Type ,Loan_Interest_Per,Is_Attachment,Is_Eligible,Eligible_Days,Subsidy_Bond_Days,Is_GPF,GPF_Eligible_Month,GPF_days_diff_application,GPF_Max_Loan_per,Is_Principal_First_than_Int,Loan_Guarantor2,Is_Grade_Wise,Grade_Details,Loan_Short_Name,is_subsidy_loan,Subsidy_bond_month,0 as Is_Intrest_Amount_As_Perquisite_IT,'' AS Effective_Date, 0 As Standard_Rates,LM.Hide_Loan_Max_Amount 
				   ,Loan_Application_Reason_Required,Max_Installment  --Added By Jimit 16102018
				   ,isnull(IsContractDue,0) IsContractDue,isnull(ContractDueDays,0) ContractDueDays --Added by ronakk 27032023
			From T0040_LOAN_MASTER LM WITH (NOLOCK) where LM.Loan_ID = @Loan_ID and LM.Cmp_ID = @Cmp_ID
		End
END

