


-- =============================================
-- Author:		Nilesh Patel 
-- Create date: 08-11-2016 
-- Description:	Interest Amount Consider As Perquisites 
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Interest_Calculation_As_Perquisites_IT]
	-- Add the parameters for the stored procedure here
	@Cmp_ID Numeric(18,0),
	@Emp_id Numeric(18,0),
	@Fin_Year VarChar(10),
	@Interest_Amt Numeric(18,4) Output
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	Declare @From_Year as nvarchar(10) 
	Declare @To_Year as nvarchar(10)
	Declare @From_Date Datetime
	Declare @To_Date Datetime
	Declare @Loan_Apr_ID Numeric(18,0)
	Declare @Loan_ID Numeric(18,0)
	Declare @Loan_Apr_Date DateTime
	Declare @Loan_Max_Limit Numeric(18,4)
	Declare @Loan_Apr_Amount Numeric(18,4)
	Declare @Loan_Interest_Type varchar(10)
	Declare @Standard_Rates Numeric(10,4)
	Declare @Loan_Apr_No_of_Installment Numeric(5,0)
	Declare @Loan_Apr_Installment_Amount Numeric(18,4)
	Declare @Installment_Start_Date DateTime
	Declare @Deduction_Type varchar(10)
	Declare @Effective_Date DateTime
	Declare @Effective_Date_1 DateTime
	
	if object_ID('tempdb..#Emp_Loan') is not null
		Begin
			drop table #Emp_Loan
		End
	
	Create Table #Emp_Loan
	(
		Cmp_ID Numeric(18,0),
		Emp_ID Numeric(18,0),
		Loan_Apr_ID Numeric(18,0),
		Loan_ID Numeric(18,0)
	)	  
	
	Set @From_Year = left(@Fin_Year,4);
	Set @To_Year = right(@Fin_Year,4);
	Set @From_Date = CAST('01-Apr-' + @From_Year AS smalldatetime);
	Set @To_Date   = CAST('31-Mar-' + @To_Year AS smalldatetime);
	
	if object_ID('tempdb..#Temp_Interest_Amount') is not null
		BEGIN
			drop table #Temp_Interest_Amount
		End
		
	Create Table #Temp_Interest_Amount
	(
		Cmp_ID Numeric(18,0),
		Loan_ID Numeric(18,0),
		Loan_Apr_ID Numeric(18,0),
		Emp_ID Numeric(18,0),
		Interest_Amount Numeric(18,4),
		Standard_Rates Numeric(18,4),
		Effective_Date Datetime,
		Loan_Balance Numeric(18,2),
		Loan_Inst_Amt Numeric(18,2)
	)
	
	Declare @Month_End_Date Datetime
	Set @Month_End_Date = ''
	
	While @From_Date <= @To_Date
		BEGIN
			Set @Month_End_Date = dbo.GET_MONTH_END_DATE(MONTH(DATEADD(M,0,@From_Date)),Year(DATEADD(M,0,@From_Date)))
			Insert INTO #Temp_Interest_Amount
				Select LP.Cmp_ID,LP.Loan_ID,LP.Loan_Apr_ID,LP.Emp_ID,0,Qry_1.Standard_Rates,@Month_End_Date,LP.Loan_Apr_Pending_Amount,0 --- Added Loan_Apr_Pending_Amount column by Hardik 28/01/2021 for SLS client for Redmine issue # 16277
				From T0120_LOAN_APPROVAL LP WITH (NOLOCK) inner JOIN T0040_LOAN_MASTER LM WITH (NOLOCK) 
				ON LM.Loan_ID = LP.Loan_ID
				Inner JOIN
					(
						Select LD.Standard_Rates,LD.Effective_Date,LD.Loan_ID From T0050_Loan_Interest_Details LD WITH (NOLOCK) INNER JOIN
						(Select MAX(LDS.Effective_Date) as EffectiveDate,LDS.Loan_ID 
							From T0050_Loan_Interest_Details LDS WITH (NOLOCK)
							WHERE LDS.Effective_Date <= @Month_End_Date
						 GROUP By LDS.Loan_ID
						 ) as Qry
						 ON Qry.Loan_ID = LD.Loan_ID and Qry.EffectiveDate = LD.Effective_Date
					) as Qry_1 
					ON LP.Loan_ID = Qry_1.Loan_ID
				Where LM.Is_Intrest_Amount_As_Perquisite_IT = 1 
				and LP.Emp_ID =  @Emp_id 
				and LP.Cmp_ID =  @Cmp_ID
				And LP.Loan_Apr_Date <= @Month_End_Date
					
			Set @From_Date = DATEADD(M,1,@From_Date);
		End
	
	Update TIA
		SET Interest_Amount = LP.Interest_Amount
	From #Temp_Interest_Amount TIA inner join T0210_MONTHLY_LOAN_PAYMENT LP
	ON LP.Loan_Payment_Date = TIA.Effective_Date and LP.Loan_Apr_ID = TIA.Loan_Apr_ID
	
	--Select * From #Temp_Interest_Amount order by Loan_ID,Effective_Date
	
	if object_ID('tempdb..#Loan_Statement_Interest') is not null
		Begin
			drop table #Loan_Statement_Interest
		End
	
	Create Table #Loan_Statement_Interest
	(
		Emp_Id numeric(18,0),
		Loan_Id numeric(18,0),
		Loan_Application varchar(25),
		Loan_Amount numeric(18,2),
		Deduction_Type varchar(20),
		No_Of_Installment numeric(18,0),
		Installment_Amount numeric(18,2),
		Interest_Type varchar(20),
		Interest_Per numeric(18,4),
		Interest_Amount numeric(18,2),
		Installment_Start_Date varchar(25),
		Balance_Loan_Amount numeric(18,2),
		Pending_Loan numeric(18,2)
	)

	
	Declare Cur_Loan Cursor for
	Select LA.Loan_Apr_ID, LA.Loan_ID,LA.Loan_Apr_Date,LM.Loan_Max_Limit,LA.Loan_Apr_Amount,LA.Loan_Apr_Intrest_Type,0,LA.Loan_Apr_No_of_Installment,LA.Loan_Apr_Installment_Amount,LA.Installment_Start_Date,LA.Deduction_Type
	From T0120_LOAN_APPROVAL LA WITH (NOLOCK) INNER JOIN T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA.Loan_ID = LM.Loan_ID
	Where LA.Emp_ID = @Emp_id AND LM.Is_Intrest_Amount_As_Perquisite_IT = 1 
	Open Cur_Loan
	fetch next from Cur_Loan into @Loan_Apr_ID,@Loan_ID,@Loan_Apr_Date,@Loan_Max_Limit,@Loan_Apr_Amount,@Loan_Interest_Type,@Standard_Rates,@Loan_Apr_No_of_Installment,@Loan_Apr_Installment_Amount,@Installment_Start_Date,@Deduction_Type
	while @@fetch_status = 0
		Begin	
			exec Loan_Statement_Download @Cmp_ID=@Cmp_ID,@Emp_ID=@Emp_id,@Loan_ID=@Loan_ID,@Loan_Application=@Loan_Apr_Date,@Loan_Max_Limit=@Loan_Max_Limit,@Loan_Amount=@Loan_Apr_Amount,@Interest_Type=@Loan_Interest_Type,@Interest_Per=@Standard_Rates,@No_Of_Installment=@Loan_Apr_No_of_Installment,@Installment_Amount=@Loan_Apr_Installment_Amount,@Installment_Start_Date=@Installment_Start_Date,@Deduction_Type=@Deduction_Type,@Is_Intrest_Amount_As_Perquisite_IT = 1,@Loan_Apr_ID = @Loan_Apr_ID
			fetch next from Cur_Loan into @Loan_Apr_ID,@Loan_ID,@Loan_Apr_Date,@Loan_Max_Limit,@Loan_Apr_Amount,@Loan_Interest_Type,@Standard_Rates,@Loan_Apr_No_of_Installment,@Loan_Apr_Installment_Amount,@Installment_Start_Date,@Deduction_Type
		End 
	Close Cur_Loan
	deallocate Cur_Loan
	
	
	
	Update #Temp_Interest_Amount
		Set Interest_Amount = LSI.Interest_Amount
	From #Temp_Interest_Amount TIA  Inner Join #Loan_Statement_Interest LSI
	ON TIA.Loan_Id = LSI.Loan_ID and Convert(smalldatetime,LSI.Installment_Start_Date,103) = Convert(smalldatetime,TIA.Effective_Date,103)
	Where TIA.Interest_Amount = 0
		And TIA.Loan_Balance > 0 --- Added Loan_Balance condition by Hardik 28/01/2021 for SLS client for Redmine issue # 16277
	
	--Select * From   #Temp_Interest_Amount
	
	Select @Interest_Amt = SUM(Isnull(Interest_Amount,0)) From #Temp_Interest_Amount --order by Loan_ID,Effective_Date
	
END

