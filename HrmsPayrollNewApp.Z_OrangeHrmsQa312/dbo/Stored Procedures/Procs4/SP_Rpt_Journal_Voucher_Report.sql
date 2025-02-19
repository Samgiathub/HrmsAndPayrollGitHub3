

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Rpt_Journal_Voucher_Report]
	@Cmp_ID Numeric(18),
	@From_Date Datetime,
	@To_Date Datetime,
	@Dept_ID Numeric(18)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @Cur_Cmp_ID Numeric(18,0)
	Declare @Cur_Report_ID Numeric(18,0)
	Declare @Cur_Employee_Type Numeric(18,0)
	Declare @Cur_Earning_Component_ID Varchar(Max)
	Declare @Cur_Earning_Short_Name Varchar(Max)
	Declare @Cur_Deduction_Component_ID Varchar(Max)
	Declare @Cur_Deduction_Short_Name Varchar(Max)
	Declare @Cur_Loan_ID Varchar(Max)
	Declare @Cur_Loan_Short_Name Varchar(Max)
	Declare @Cur_Basic_Salary_Sum Numeric(18,2)
	Declare @Cur_PT_Sum Numeric(18,2)
	Declare @Cur_Earning_Compoent_Sum Numeric(18,2)
	Declare @Cur_Loan_Sum Numeric(18,2)
	Declare @Sum_Earning Numeric(18,2)
	Declare @Sum_Deduction Numeric(18,2)
	Declare @Cur_Type Numeric(18,0)
	Declare @Cur_Sorting_No Numeric(18,0)
	
	Set @Cur_Basic_Salary_Sum = 0
	Set @Cur_PT_Sum = 0
	Set @Sum_Earning = 0
	Set @Sum_Deduction = 0
	
	
	IF OBJECT_ID('tempdb..#Allowance_Details') Is Not NULL
		drop TABLE #Allowance_Details
	
	
	Create Table #Allowance_Details
	(
		Cmp_ID Numeric(18,0),
		Dept_ID Numeric(18,0), 
		Report_ID Numeric(18,0),
		Employee_Type Numeric(18,0),
		AD_ID Numeric(18,0),
		AD_Sort_Name Varchar(500),
		To_Date Datetime,
		Flag Numeric(18,0),
		AD_Amount Numeric(18,2)  default 0,
		Total_Amt Numeric(18,2),
		Sorting_No Numeric(5,0),
		Gross_Amt Numeric(18,2),
		Recoveries_Amt Numeric(18,2)
	)
	
	Create Table #Type_ID 
	(
		Cmp_ID Numeric(18,0),
		Employee_Type Numeric(18,0)
	)
	
	Insert INTO #Type_ID(Cmp_ID,Employee_Type)
	Select DISTINCT Cmp_ID,Type_ID From T0080_EMP_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Dept_ID = @Dept_ID
		
	Declare Cur_Rport_Head Cursor For 
	Select TA.Cmp_ID,Report_ID,TA.Employee_Type,Earning_Component_ID,Earning_Short_Name,Deduction_Component_ID,Deduction_Short_Name,Loan_ID,Loan_Short_Name,TypeId,Sorting_No 
	From T0100_Abstract_Report_Details TA WITH (NOLOCK) Inner JOIN
	#Type_ID TI on TA.Employee_Type = TI.Employee_Type
	where Abstract_Report_ID = 2
	open Cur_Rport_Head
		Fetch Next From Cur_Rport_Head into @Cur_Cmp_ID,@Cur_Report_ID,@Cur_Employee_Type,@Cur_Earning_Component_ID,@Cur_Earning_Short_Name,@Cur_Deduction_Component_ID,@Cur_Deduction_Short_Name,@Cur_Loan_ID,@Cur_Loan_Short_Name,@Cur_Type,@Cur_Sorting_No
			While @@fetch_status = 0
				Begin
					Set @Cur_Basic_Salary_Sum = 0
					Set @Cur_PT_Sum = 0
					Set @Cur_Loan_Sum = 0
					
					if @Cur_Earning_Component_ID is not null
						Begin
							INSERT INTO #Allowance_Details(Cmp_ID,Dept_ID,Report_ID,Employee_Type,AD_ID,AD_Sort_Name,To_Date,Flag,Sorting_No) 
							SELECT @Cur_Cmp_ID,@Dept_ID,@Cur_Report_ID,@Cur_Employee_Type,Data,Data1,@To_Date,@Cur_Type,@Cur_Sorting_No From dbo.Split(@Cur_Earning_Component_ID,'#') as AD
							inner JOIN (SELECT Id as Id1, Data as Data1 ,1 as Emp_ID FROM dbo.Split(@Cur_Earning_Short_Name,'#')) as qry
							ON AD.Id = qry.Id1
						End
						
					if @Cur_Deduction_Component_ID is not null
						Begin
							INSERT INTO #Allowance_Details(Cmp_ID,Dept_ID,Report_ID,Employee_Type,AD_ID,AD_Sort_Name,To_Date,Flag,Sorting_No)
							SELECT @Cur_Cmp_ID,@Dept_ID,@Cur_Report_ID,@Cur_Employee_Type,Data,Data1,@To_Date,@Cur_Type,@Cur_Sorting_No From dbo.Split(@Cur_Deduction_Component_ID,'#') as AD
							inner JOIN (SELECT Id as Id1, Data as Data1 ,1 as Emp_ID FROM dbo.Split(@Cur_Deduction_Short_Name,'#')) as qry
							ON AD.Id = qry.Id1
						End 
						
					if @Cur_Loan_ID is not null
						Begin
							INSERT INTO #Allowance_Details(Cmp_ID,Dept_ID,Report_ID,Employee_Type,AD_ID,AD_Sort_Name,To_Date,Flag,Sorting_No) 
							SELECT @Cur_Cmp_ID,@Dept_ID,@Cur_Report_ID,@Cur_Employee_Type,Data,Data1,@To_Date,@Cur_Type,@Cur_Sorting_No From dbo.Split(@Cur_Loan_ID,'#') as AD
							inner JOIN (SELECT Id as Id1, Data as Data1 ,1 as Emp_ID FROM dbo.Split(@Cur_Loan_Short_Name,'#')) as qry
							ON AD.Id = qry.Id1
						End 
					
					Fetch Next From Cur_Rport_Head into @Cur_Cmp_ID,@Cur_Report_ID,@Cur_Employee_Type,@Cur_Earning_Component_ID,@Cur_Earning_Short_Name,@Cur_Deduction_Component_ID,@Cur_Deduction_Short_Name,@Cur_Loan_ID,@Cur_Loan_Short_Name,@Cur_Type,@Cur_Sorting_No
				End
		Close Cur_Rport_Head
		deallocate Cur_Rport_Head
		
		if Exists(Select 1 From #Allowance_Details Where AD_ID = 8000)
				BEGIN
					--Set @Cur_Basic_Salary_Sum = 0
					--Select @Cur_Basic_Salary_Sum = 
					Update AD1
					SET AD_Amount = qry1.Salary_Amount
					From #Allowance_Details AD1
					Inner JOIN (Select SUM(MS.Salary_Amount) as Salary_Amount,I.Type_ID
					From T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = MS.Emp_ID INNER Join
						(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
								 Where Increment_effective_Date <= @To_Date AND Cmp_ID = @Cmp_ID Group by emp_ID) as new_inc
								 on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
					     Where TI.Increment_effective_Date <= @To_Date group by ti.emp_id) as Qry
						 on I.Increment_ID = Qry.Increment_Id
						 inner JOIN #Type_ID TI ON TI.Employee_Type = I.Type_ID
					Where I.Dept_ID = @Dept_ID And Month(MS.Month_End_Date) = Month(@To_Date) 
					and  Year(MS.Month_End_Date) = Year(@To_Date)
					group BY I.Type_ID) as qry1
					ON qry1.Type_ID = AD1.Employee_Type
					Where AD_ID = 8000
					
					--Update  #Allowance_Details 
					--Set AD_Amount = @Cur_Basic_Salary_Sum
					--Where AD_ID = 8000
				END
		if Exists(Select 1 From #Allowance_Details Where AD_ID = 9000)
				BEGIN
					SET @Cur_PT_Sum = 0
					--Select @Cur_PT_Sum = 
					Update AD1
					SET AD_Amount = qry1.PT_Amount
					From #Allowance_Details AD1
					Inner JOIN (Select SUM(Isnull(MS.PT_Amount,0)) as PT_Amount,i.Type_ID
					From T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = MS.Emp_ID INNER Join
						(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
							(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
							 Where Increment_effective_Date <= @to_date AND Cmp_ID = @Cur_Cmp_ID Group by emp_ID) as new_inc
							 on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
						 Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry
						 on I.Increment_ID = Qry.Increment_Id
						 inner JOIN #Type_ID TI ON TI.Employee_Type = I.Type_ID
					Where I.Dept_ID = @Dept_ID And Month(MS.Month_End_Date) = Month(@To_Date) 
					and  Year(MS.Month_End_Date) = Year(@To_Date) 
					Group BY i.Type_ID) as qry1
					ON qry1.Type_ID = AD1.Employee_Type
					Where AD_ID = 9000
					
					--Update  #Allowance_Details 
					--Set AD_Amount = @Cur_PT_Sum
					--Where AD_ID = 9000
				END
				
		--Select SUM(MA.M_AD_Amount) as AD_Amount_1,MA.AD_ID,I.Type_ID From T0210_MONTHLY_AD_DETAIL MA 
		--			--Inner join #Allowance_Details AD ON MA.AD_ID = AD.AD_ID 
		--			Inner JOIN T0095_INCREMENT I ON I.Emp_ID = MA.Emp_ID INNER Join
		--					(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI inner join
		--							(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment
		--							Where Increment_effective_Date <= @to_date AND Cmp_ID = @Cur_Cmp_ID Group by emp_ID) as new_inc
		--							on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
		--						 Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry
		--					on I.Increment_ID = Qry.Increment_Id
		--					--inner JOIN #Type_ID TI ON TI.Employee_Type = I.Type_ID 
		--			Where Month(MA.To_date) = Month(@To_Date) and Year(MA.To_date) = Year(@To_Date) and I.Dept_ID = @Dept_ID
		-- Group BY MA.AD_ID,I.Type_ID
			
		Update AD1
			SET AD_Amount = AD_Amount_1
		From #Allowance_Details AD1 Inner join
		(Select SUM(MA.M_AD_Amount) as AD_Amount_1,MA.AD_ID,I.Type_ID From T0210_MONTHLY_AD_DETAIL MA WITH (NOLOCK)
					--Inner join #Allowance_Details AD ON MA.AD_ID = AD.AD_ID 
					Inner JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = MA.Emp_ID INNER Join
							(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
									(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
									Where Increment_effective_Date <= @to_date AND Cmp_ID = @Cur_Cmp_ID Group by emp_ID) as new_inc
									on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								 Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry
							on I.Increment_ID = Qry.Increment_Id
							inner JOIN #Type_ID TI ON TI.Employee_Type = I.Type_ID 
					Where Month(MA.To_date) = Month(@To_Date) and Year(MA.To_date) = Year(@To_Date) and I.Dept_ID = @Dept_ID
		 Group BY MA.AD_ID,I.Type_ID) as qry1
		 on qry1.AD_ID = AD1.AD_ID --and qry1.Report_ID = AD1.Report_ID 
		 and qry1.Type_ID = AD1.Employee_Type
		 
		Update  AD
		Set AD_Amount = Loan_Pay_Amount 
		From #Allowance_Details AD
		inner JOIN
		(Select Sum(LP.Loan_Pay_Amount) as Loan_Pay_Amount ,LA.Loan_ID as LoanID , I.Type_ID FROM 
		T0120_LOAN_APPROVAL LA WITH (NOLOCK) inner join T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = LA.Emp_ID 
		INNER Join (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
									(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
									Where Increment_effective_Date <= @to_date AND Cmp_ID = @Cur_Cmp_ID Group by emp_ID) as new_inc
									on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								 Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry
							on I.Increment_ID = Qry.Increment_Id
							inner JOIN #Type_ID TI ON TI.Employee_Type = I.Type_ID 
		Inner JOIN T0210_MONTHLY_LOAN_PAYMENT LP WITH (NOLOCK)
		On LP.Loan_Apr_ID = LA.Loan_Apr_ID INNER JOIN T0040_LOAN_MASTER LM WITH (NOLOCK)
		On LM.Loan_ID = LA.Loan_ID 
		Where I.Dept_ID = @Dept_ID AND LA.Loan_Apr_Status = 'A' and LP.Loan_Payment_Date >= @From_Date 
		and  LP.Loan_Payment_Date <= @To_Date and LP.Sal_Tran_ID is not null
		Group by LA.Loan_ID,I.Type_ID) as qry
		ON qry.LoanID = AD.AD_ID and qry.Type_ID = AD.Employee_Type
		
		Update  AD
		Set AD_Amount = AD_Amount + Loan_Pay_Amount 
		From #Allowance_Details AD
		inner JOIN
		(Select Sum(LP.Interest_Amount) as Loan_Pay_Amount ,LA.Loan_ID as LoanID , I.Type_ID FROM 
		T0120_LOAN_APPROVAL LA WITH (NOLOCK) inner join T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = LA.Emp_ID 
		INNER Join (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
									(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
									Where Increment_effective_Date <= @to_date AND Cmp_ID = @Cur_Cmp_ID Group by emp_ID) as new_inc
									on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								 Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry
							on I.Increment_ID = Qry.Increment_Id
							inner JOIN #Type_ID TI ON TI.Employee_Type = I.Type_ID 
		Inner JOIN T0210_MONTHLY_LOAN_PAYMENT LP WITH (NOLOCK)
		On LP.Loan_Apr_ID = LA.Loan_Apr_ID INNER JOIN T0040_LOAN_MASTER LM WITH (NOLOCK)
		On LM.Loan_ID = LA.Loan_ID 
		Where I.Dept_ID = @Dept_ID AND LA.Loan_Apr_Status = 'A' and LP.Loan_Payment_Date >= @From_Date 
		and  LP.Loan_Payment_Date <= @To_Date and LP.Sal_Tran_ID is not null and LP.Is_Loan_Interest_Flag = 1
		Group by LA.Loan_ID,I.Type_ID) as qry
		ON qry.LoanID = AD.AD_ID and qry.Type_ID = AD.Employee_Type
		
		Update AD
		Set Total_Amt = qry.AD_Amount 
		From #Allowance_Details AD
		Inner JOIN(SELECT SUM(AD_Amount) as AD_Amount,Report_ID,Employee_Type 
				   From #Allowance_Details 
				   group BY Report_ID,Employee_Type)as qry
		ON AD.Report_ID = qry.Report_ID and AD.Employee_Type = qry.Employee_Type
		
		
		Update #Allowance_Details
		Set Gross_Amt = t.Amount
	    From 
	    (Select SUM(AD_Amount) as Amount From  #Allowance_Details  Where Flag = 1 --Group BY Report_ID
	    ) t
	    --Where Flag = 1
	    
	    Update #Allowance_Details
		Set Recoveries_Amt = t.Amount
	    From 
	    (Select SUM(AD_Amount) as Amount From  #Allowance_Details  Where Flag = 2 --Group BY Report_ID
	    ) t
	    --Where Flag = 2			

		Select DM.Dept_Name,AD.Dept_ID,AD.To_Date,SUM(AD.AD_Amount) as AD_Amount,0 as AD_ID,HM.Report_Header_Name,AD.Report_ID,'' as Employee_Type,
		AD.Flag,AD.AD_Sort_Name as Loan_Name ,AD.Total_Amt as Total_Amt From #Allowance_Details AD 
		Inner JOIN T0030_Report_Header_Master HM WITH (NOLOCK) ON AD.Report_ID = HM.Report_Id
		Inner JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON DM.Dept_Id = AD.Dept_ID	
		where AD.Flag = 1 and AD.AD_Amount <> 0
		group by AD.To_Date,AD.Dept_ID,DM.Dept_Name,HM.Report_Header_Name,AD.AD_Sort_Name,AD.Report_ID,
		AD.Flag,AD.Total_Amt,AD.Sorting_No,AD.Gross_Amt,AD.Recoveries_Amt
		
		Select DM.Dept_Name,AD.Dept_ID,AD.To_Date,SUM(AD.AD_Amount) as AD_Amount,0 as AD_ID,HM.Report_Header_Name,AD.Report_ID,'' as Employee_Type,
		AD.Flag,AD.AD_Sort_Name as Loan_Name ,AD.Total_Amt as Total_Amt From #Allowance_Details AD 
		Inner JOIN T0030_Report_Header_Master HM WITH (NOLOCK) ON AD.Report_ID = HM.Report_Id
		Inner JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON DM.Dept_Id = AD.Dept_ID	
		where AD.Flag = 2 
		group by AD.To_Date,AD.Dept_ID,DM.Dept_Name,HM.Report_Header_Name,AD.AD_Sort_Name,AD.Report_ID,
		AD.Flag,AD.Total_Amt,AD.Sorting_No,AD.Gross_Amt,AD.Recoveries_Amt

END

