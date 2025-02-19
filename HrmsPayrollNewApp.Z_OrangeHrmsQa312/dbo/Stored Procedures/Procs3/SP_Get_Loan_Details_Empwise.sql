

-- =============================================
-- Author:		Nilesh Patel
-- Create date: 04-01-2017 
-- Description:	Create Procedure for Get Employee Wise Loan Details
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_Loan_Details_Empwise]
	-- Add the parameters for the stored procedure here
	@Cmp_ID Numeric(18,0),
	--@Emp_ID Numeric(18,0),
	@AD_ID Numeric(18,0),
	@For_Date Datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Month_St_Date Datetime
	Set @Month_St_Date = dbo.GET_MONTH_END_DATE(Month(@For_Date),Year(@For_Date))

 --   Select LA.Loan_Apr_ID,LM.Loan_Name,
	--(Case When Isnull(qry.New_Install_Amount,0) > 0 Then Isnull(qry.New_Install_Amount,0)
	--	Else
	--	Case When LA.Loan_Apr_Pending_Amount > LA.Loan_Apr_Installment_Amount THEN LA.Loan_Apr_Installment_Amount ELSE LA.Loan_Apr_Pending_Amount END 
	--End) as Loan_Amount, 

	Select LA.Loan_Apr_ID,LM.Loan_Name,
		Cast(		
			(Case When isnull(qry.New_Install_Amount,0) > 0 Then Isnull(qry.New_Install_Amount,0)
						Else
							Case When LA.Loan_Apr_Pending_Amount > LA.Loan_Apr_Installment_Amount 
									THEN LA.Loan_Apr_Installment_Amount 
								ELSE 
									--Isnull(LA.Loan_Apr_Pending_Amount,0)
									(Case When LA.Loan_Apr_Intrest_Type = 'REDUCING' 
											Then 
												(case when ((LA.Loan_Apr_Pending_Amount * LA.Loan_Apr_Intrest_Per)/1200) + Isnull(LA.Loan_Apr_Pending_Amount,0) > isnull(LA.Loan_Apr_Installment_Amount,0) 
													then isnull(LA.Loan_Apr_Installment_Amount,0)
												Else
													((LA.Loan_Apr_Pending_Amount * LA.Loan_Apr_Intrest_Per)/1200) + Isnull(LA.Loan_Apr_Pending_Amount,0)
												End)
										  When LA.Loan_Apr_Intrest_Type = 'FIX' 
											Then 
												(Case When ((LA.Loan_Apr_Amount * LA.Loan_Apr_Intrest_Per)/1200) + Isnull(LA.Loan_Apr_Pending_Amount,0) > isnull(LA.Loan_Apr_Installment_Amount,0) 
													then isnull(LA.Loan_Apr_Installment_Amount,0) 
												Else
													((LA.Loan_Apr_Amount * LA.Loan_Apr_Intrest_Per)/1200) + Isnull(LA.Loan_Apr_Pending_Amount,0)
												End)
									END)
								END
						End) As numeric(18,2)	
			) as Loan_Amount,

	LA.Emp_ID,
	--(Case When Isnull(qry.New_Install_Amount,0) > 0 Then Isnull(qry.New_Install_Amount,0)
	--	Else
	--		Case When LA.Loan_Apr_Pending_Amount > LA.Loan_Apr_Installment_Amount THEN LA.Loan_Apr_Installment_Amount ELSE LA.Loan_Apr_Pending_Amount END 
	--End) as Final_Loan_Amount
	Cast(
			(Case When isnull(qry.New_Install_Amount,0) > 0 Then Isnull(qry.New_Install_Amount,0)
						Else
							Case When LA.Loan_Apr_Pending_Amount > LA.Loan_Apr_Installment_Amount 
									THEN LA.Loan_Apr_Installment_Amount 
								ELSE 
									--Isnull(LA.Loan_Apr_Pending_Amount,0)
									(Case When LA.Loan_Apr_Intrest_Type = 'REDUCING' 
											Then 
												(case when ((LA.Loan_Apr_Pending_Amount * LA.Loan_Apr_Intrest_Per)/1200) + Isnull(LA.Loan_Apr_Pending_Amount,0) > isnull(LA.Loan_Apr_Installment_Amount,0) 
													then isnull(LA.Loan_Apr_Installment_Amount,0)
												Else
													((LA.Loan_Apr_Pending_Amount * LA.Loan_Apr_Intrest_Per)/1200) + Isnull(LA.Loan_Apr_Pending_Amount,0)
												End)
										  When LA.Loan_Apr_Intrest_Type = 'FIX' 
											Then 
												(Case When ((LA.Loan_Apr_Amount * LA.Loan_Apr_Intrest_Per)/1200) + Isnull(LA.Loan_Apr_Pending_Amount,0) > isnull(LA.Loan_Apr_Installment_Amount,0) 
													then isnull(LA.Loan_Apr_Installment_Amount,0) 
												Else
													((LA.Loan_Apr_Amount * LA.Loan_Apr_Intrest_Per)/1200) + Isnull(LA.Loan_Apr_Pending_Amount,0)
												End)
									END)
								END
						End) As numeric(18,2)
		)	as Final_Loan_Amount
	From T0120_LOAN_APPROVAL LA WITH (NOLOCK) INNER JOIN T0040_LOAN_MASTER LM WITH (NOLOCK)
	ON LM.Loan_ID = LA.Loan_ID
	Left Outer join 
						(
							Select MLS.Emp_ID,Loan_Apr_ID,New_Install_Amount From T0090_Change_Request_Approval CRA WITH (NOLOCK)
							INNER JOIN T0100_Monthly_Loan_Skip_Approval MLS WITH (NOLOCK) ON CRA.Request_Apr_ID = MLS.Request_Apr_ID
							Where CRA.Cmp_id = @Cmp_ID and Request_Type_id = 17	
								  and Loan_Month = Month(@Month_St_Date) and Loan_Year = YEAR(@Month_St_Date)
								  and MLS.Final_Approval = 1
						) as qry ON LA.Emp_ID = qry.Emp_ID and LA.Loan_Apr_ID = qry.Loan_Apr_ID
	Where LA.Loan_Apr_Pending_Amount > 0  AND LA.Loan_Apr_Deduct_From_Sal = 2 and LA.Loan_Apr_Status = 'A'
	and LA.AD_ID = @AD_ID AND LA.Loan_Apr_Date <= @For_Date --AND LA.Emp_ID = @Emp_ID
	and LA.Cmp_ID = @Cmp_ID
END

