


---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Rpt_Cash_Voucher_Abstract_Report]
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
	
	--Set @Cur_Earning_Compoent_Sum = 0
	Set @Cur_Basic_Salary_Sum = 0
	Set @Cur_PT_Sum = 0
	Set @Sum_Earning = 0
	Set @Sum_Deduction = 0
	--Set @Cur_Dept_ID = 0

    -- Insert statements for procedure here
	--Select * From T0100_Abstract_Report_Details --T Inner Join T0030_Report_Header_Master RM
	--On RM.Report_Id = T.Report_ID
	IF OBJECT_ID('tempdb..#Allowance_Details') Is Not NULL
		drop TABLE #Allowance_Details
	
	Create Table #Allowance_Details 
	(
		Cmp_ID Numeric(18,0),
		Report_ID Numeric(18,0),
		Employee_Type Numeric(18,0),
		Amount Numeric(18,2) default 0,
		Dept_ID Numeric(18,0), 
		To_Date Datetime,
		Flag Numeric(18,0),
		GrossAllowanceSum Numeric(18,2) default 0,
		RecoveriesSum Numeric(18,2) default 0,
		NetSum Numeric(18,2) default 0
	)
	
	Create Table #Allowance_Details_temp
	(
		Cmp_ID Numeric(18,0),
		AD_ID Numeric(18,0),
		Report_ID Numeric(18,0),
		Employee_Type Numeric(18,0)
	)
	
	Create Table #Type_ID 
	(
		Cmp_ID Numeric(18,0),
		Employee_Type Numeric(18,0)
	)
	
	Insert INTO #Type_ID(Cmp_ID,Employee_Type)
	Select DISTINCT Cmp_ID,Type_ID From T0080_EMP_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Dept_ID = @Dept_ID
	
	Insert INTO #Allowance_Details(Cmp_ID,Report_ID,Employee_Type,Amount,Dept_ID,To_Date,Flag)
	SELECT TA.Cmp_ID,Report_Id,TA.Employee_Type,0,@Dept_ID,@To_Date,TypeId 
	From T0100_Abstract_Report_Details TA WITH (NOLOCK) Inner JOIN
	#Type_ID TI ON TI.Employee_Type = TA.Employee_Type
	Where Abstract_Report_ID = 1
	
	
	Declare Cur_Rport_Head Cursor For 
	Select TA.Cmp_ID,Report_ID,TA.Employee_Type,Earning_Component_ID,Earning_Short_Name,Deduction_Component_ID,Deduction_Short_Name,Loan_ID,Loan_Short_Name 
	From T0100_Abstract_Report_Details TA WITH (NOLOCK) Inner JOIN
	#Type_ID TI on TA.Employee_Type = TI.Employee_Type
	where Abstract_Report_ID = 1
	open Cur_Rport_Head
		Fetch Next From Cur_Rport_Head into @Cur_Cmp_ID,@Cur_Report_ID,@Cur_Employee_Type,@Cur_Earning_Component_ID,@Cur_Earning_Short_Name,@Cur_Deduction_Component_ID,@Cur_Deduction_Short_Name,@Cur_Loan_ID,@Cur_Loan_Short_Name
			While @@fetch_status = 0
				Begin
					Set @Cur_Basic_Salary_Sum = 0
					Set @Cur_PT_Sum = 0
					Set @Cur_Loan_Sum = 0
					
					if @Cur_Earning_Component_ID is not null
						Begin
							INSERT INTO #Allowance_Details_temp(Cmp_ID,AD_ID,Report_ID,Employee_Type) 
							SELECT @Cur_Cmp_ID,Data,@Cur_Report_ID,@Cur_Employee_Type From dbo.Split(@Cur_Earning_Component_ID,'#')  
						End
						
					if @Cur_Deduction_Component_ID is not null
						Begin
							INSERT INTO #Allowance_Details_temp(Cmp_ID,AD_ID,Report_ID,Employee_Type)
							SELECT @Cur_Cmp_ID,Data,@Cur_Report_ID,@Cur_Employee_Type From dbo.Split(@Cur_Deduction_Component_ID,'#') 
						End 
						
					if @Cur_Loan_ID is not null
						Begin
							INSERT INTO #Allowance_Details_temp(Cmp_ID,AD_ID,Report_ID,Employee_Type) 
							SELECT @Cur_Cmp_ID,Data,@Cur_Report_ID,@Cur_Employee_Type From dbo.Split(@Cur_Loan_ID,'#') 
						End 
					
					
					if Exists(Select 1 From dbo.Split(@Cur_Earning_Component_ID,'#') Where Data = 8000)
						BEGIN
							Select @Cur_Basic_Salary_Sum = SUM(MS.Salary_Amount)
							From T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = MS.Emp_ID INNER Join
							(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
									(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
									Where Increment_effective_Date <= @To_Date AND Cmp_ID = @Cur_Cmp_ID Group by emp_ID) as new_inc
									on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								 Where TI.Increment_effective_Date <= @To_Date group by ti.emp_id) as Qry
							on I.Increment_ID = Qry.Increment_Id
							
							Where I.Dept_ID = @Dept_ID And Month(MS.Month_End_Date) = Month(@To_Date) 
							and  Year(MS.Month_End_Date) = Year(@To_Date) and I.Type_ID = @Cur_Employee_Type
						END
					
					if Exists(Select 1 From dbo.Split(@Cur_Deduction_Component_ID,'#') Where Data = 9000)
						BEGIN
							Select @Cur_PT_Sum = SUM(Isnull(MS.PT_Amount,0))
							From T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = MS.Emp_ID INNER Join
							(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
									(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
									Where Increment_effective_Date <= @to_date AND Cmp_ID = @Cur_Cmp_ID Group by emp_ID) as new_inc
									on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								 Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry
							on I.Increment_ID = Qry.Increment_Id
							Where I.Dept_ID = @Dept_ID And Month(MS.Month_End_Date) = Month(@To_Date) 
							and  Year(MS.Month_End_Date) = Year(@To_Date) and I.Type_ID = @Cur_Employee_Type
						END
					
					Select @Cur_Earning_Compoent_Sum  = SUM(MA.M_AD_Amount) From T0210_MONTHLY_AD_DETAIL MA WITH (NOLOCK) Inner join #Allowance_Details_temp AD
					ON MA.AD_ID = AD.AD_ID Inner JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = MA.Emp_ID INNER Join
							(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
									(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
									Where Increment_effective_Date <= @to_date AND Cmp_ID = @Cur_Cmp_ID Group by emp_ID) as new_inc
									on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								 Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry
							on I.Increment_ID = Qry.Increment_Id 
					Where AD.Report_ID = @Cur_Report_ID 
					and AD.Employee_Type = @Cur_Employee_Type
					And Month(MA.To_date) = Month(@To_Date) and Year(MA.To_date) = Year(@To_Date) and I.Dept_ID = @Dept_ID
					And I.Type_ID = @Cur_Employee_Type  --and AD.Flag = 1
					
					--Declare @Cur_Loan_Deduct_Amount Numeric(18,0)
					--Select @Cur_Loan_Deduct_Amount= SUM(MA.M_AD_Amount) From T0210_MONTHLY_AD_DETAIL MA Inner join #Allowance_Details_temp AD
					--ON MA.AD_ID = AD.AD_ID Inner JOIN T0095_INCREMENT I ON I.Emp_ID = MA.Emp_ID INNER Join
					--		(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI inner join
					--				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment
					--				Where Increment_effective_Date <= @to_date AND Cmp_ID = @Cur_Cmp_ID Group by emp_ID) as new_inc
					--				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
					--			 Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry
					--		on I.Increment_ID = Qry.Increment_Id 
					--Where AD.Report_ID = @Cur_Report_ID 
					--and AD.Employee_Type = @Cur_Employee_Type
					--And Month(MA.To_date) = Month(@To_Date) and Year(MA.To_date) = Year(@To_Date) and I.Dept_ID = @Dept_ID
					--And I.Type_ID = @Cur_Employee_Type and @Cur_Loan_ID is not null
					
					--if @Cur_Loan_ID is null
					--	Begin
							Update #Allowance_Details 
							Set Amount = Isnull(@Cur_Earning_Compoent_Sum,0) + Isnull(@Cur_Basic_Salary_Sum,0) + ISNULL(@Cur_PT_Sum,0)
							where Cmp_ID = @Cur_Cmp_ID and Employee_Type = @Cur_Employee_Type 
							and Report_ID = @Cur_Report_ID
						--End 
						
					 --Select SUM(Loan_Pay_Amount) as LoanPayAmount,AD_temp.Report_ID,AD_temp.Employee_Type From #Allowance_Details_temp AD_temp Inner JOIN  
						
						
					Update TDA 
					Set Amount = Amount +  LoanPayAmount
					From #Allowance_Details TDA inner join
					(Select SUM(Loan_Pay_Amount) as LoanPayAmount,AD_temp.Report_ID,AD_temp.Employee_Type From #Allowance_Details_temp AD_temp Inner JOIN  
					(Select Sum(LP.Loan_Pay_Amount) as Loan_Pay_Amount ,LA.Loan_ID as LoanID ,I.Type_ID FROM 
					 T0120_LOAN_APPROVAL LA WITH (NOLOCK) inner join T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = LA.Emp_ID INNER Join
							(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
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
					Group by LA.Loan_ID ,I.Type_ID) as qry
					on AD_temp.AD_ID = qry.LoanID and AD_temp.Employee_Type = qry.Type_ID
					Where AD_temp.Employee_Type = @Cur_Employee_Type 
					and AD_temp.Report_ID = @Cur_Report_ID
					GROUP by AD_temp.Report_ID,AD_temp.Employee_Type) As Qry1
					on TDA.Report_ID = Qry1.Report_ID and TDA.Employee_Type = Qry1.Employee_Type
					
					Update TDA 
					Set Amount = Amount +  LoanPayAmount
					From #Allowance_Details TDA inner join
					(Select SUM(Loan_Pay_Amount) as LoanPayAmount,AD_temp.Report_ID,AD_temp.Employee_Type From #Allowance_Details_temp AD_temp Inner JOIN  
					(Select Sum(Interest_Amount) as Loan_Pay_Amount ,LA.Loan_ID as LoanID ,I.Type_ID FROM 
					 T0120_LOAN_APPROVAL LA WITH (NOLOCK) inner join T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = LA.Emp_ID INNER Join
							(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
									(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
									Where Increment_effective_Date <= @to_date AND Cmp_ID = @Cur_Cmp_ID Group by emp_ID) as new_inc
									on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								 Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry
							on I.Increment_ID = Qry.Increment_Id
							inner JOIN #Type_ID TI ON TI.Employee_Type = I.Type_ID 
					Inner JOIN T0210_MONTHLY_LOAN_PAYMENT LP WITH (NOLOCK)
					On LP.Loan_Apr_ID = LA.Loan_Apr_ID INNER JOIN T0040_LOAN_MASTER LM  WITH (NOLOCK)
					On LM.Loan_ID = LA.Loan_ID 
					Where I.Dept_ID = @Dept_ID AND LA.Loan_Apr_Status = 'A' and LP.Loan_Payment_Date >= @From_Date and LP.Is_Loan_Interest_Flag = 1
					and  LP.Loan_Payment_Date <= @To_Date and LP.Sal_Tran_ID is not null
					Group by LA.Loan_ID ,I.Type_ID) as qry
					on AD_temp.AD_ID = qry.LoanID and AD_temp.Employee_Type = qry.Type_ID
					Where AD_temp.Employee_Type = @Cur_Employee_Type 
					and AD_temp.Report_ID = @Cur_Report_ID
					GROUP by AD_temp.Report_ID,AD_temp.Employee_Type) As Qry1
					on TDA.Report_ID = Qry1.Report_ID and TDA.Employee_Type = Qry1.Employee_Type
					
					--Update TDA 
					--Set Amount = Loan_Pay_Amount
					--From #Allowance_Details TDA Inner join #Allowance_Details_temp AD1 
					--ON AD1.Employee_Type = TDA.Employee_Type and AD1.Report_ID = TDA.Report_ID
					--Inner join
					--(Select Sum(LP.Loan_Pay_Amount) as Loan_Pay_Amount ,LA.Loan_ID as LoanID FROM 
					-- T0120_LOAN_APPROVAL LA inner join T0095_INCREMENT I ON I.Emp_ID = LA.Emp_ID INNER Join
					--		(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI inner join
					--				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment
					--				Where Increment_effective_Date <= @to_date AND Cmp_ID = @Cur_Cmp_ID Group by emp_ID) as new_inc
					--				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
					--			 Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry
					--		on I.Increment_ID = Qry.Increment_Id
					--Inner JOIN T0210_MONTHLY_LOAN_PAYMENT LP
					--On LP.Loan_Apr_ID = LA.Loan_Apr_ID INNER JOIN T0040_LOAN_MASTER LM 
					--On LM.Loan_ID = LA.Loan_ID 
					--Where I.Dept_ID = @Dept_ID AND LA.Loan_Apr_Status = 'A'
					--Group by LA.Loan_ID) as Qry
					--ON AD1.AD_ID = Qry.LoanID 
					--Where AD1.Employee_Type = @Cur_Employee_Type 
					--and AD1.Report_ID = @Cur_Report_ID
					
					Fetch Next From Cur_Rport_Head into @Cur_Cmp_ID,@Cur_Report_ID,@Cur_Employee_Type,@Cur_Earning_Component_ID,@Cur_Earning_Short_Name,@Cur_Deduction_Component_ID,@Cur_Deduction_Short_Name,@Cur_Loan_ID,@Cur_Loan_Short_Name 
				End
		Close Cur_Rport_Head
		deallocate Cur_Rport_Head
		
		
				
		Update #Allowance_Details
		Set GrossAllowanceSum = t.Amount
	    From 
	    (Select SUM(Amount) as Amount,Report_ID From  #Allowance_Details  Where Flag = 1 group BY Report_ID
	    ) t
	    
	    Update #Allowance_Details
		Set RecoveriesSum = t.Amount
	    From 
	    (Select SUM(Amount) as Amount From  #Allowance_Details  Where Flag = 2
	    ) t
	    
	    Update #Allowance_Details
	    Set NetSum  = t.Report_Header
	    From (Select
	    (Select SUM(Amount) as Amount From #Allowance_Details Where Flag = 1) - 
		       (Select SUM(Amount) as Amount From #Allowance_Details Where Flag = 2) 
		 as Report_Header)t
	    
		
		Select HM.Report_Header_Name,SUM(isnull(AD.Amount,0)) as Report_Header,DM.Dept_Name,AD.To_Date,AD.Report_ID,AD.Flag,AD.GrossAllowanceSum,AD.RecoveriesSum,AD.NetSum
		From #Allowance_Details AD Inner JOIN T0030_Report_Header_Master HM WITH (NOLOCK)
		ON HM.Report_Id = AD.Report_ID 
		Inner JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK)
		On DM.Dept_Id = AD.Dept_ID
		Group by HM.Report_Header_Name,DM.Dept_Name,AD.To_Date,AD.Report_ID,AD.Flag,AD.GrossAllowanceSum,AD.RecoveriesSum,AD.NetSum
		
		Union 
		
		Select 'Recoveries' as Report_Header_Name,Report_Header,Dept_Name,To_Date,100 as Report_ID,3 as Flag,GrossAllowanceSum,RecoveriesSum,NetSum  From
		(Select SUM(AD.Amount) as Report_Header,DM.Dept_Name,AD.To_Date,AD.Flag,AD.GrossAllowanceSum,AD.RecoveriesSum,AD.NetSum
		From #Allowance_Details AD Inner JOIN T0030_Report_Header_Master HM WITH (NOLOCK)
		ON HM.Report_Id = AD.Report_ID 
		Inner JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK)
		On DM.Dept_Id = AD.Dept_ID
		Where AD.Flag = 2
		Group by DM.Dept_Name,AD.To_Date,AD.Flag,AD.GrossAllowanceSum,AD.RecoveriesSum,AD.NetSum) t
		
		Union
		
		SELECT DISTINCT 'Net' as Report_Header_Name,
		(Select SUM(Amount) as Amount From #Allowance_Details Where Flag = 1) - 
		       (Select SUM(Amount) as Amount From #Allowance_Details Where Flag = 2) 
		 as Report_Header 
		 ,Dept_Name,To_Date,110 as Report_ID,4 as Flag,AD.GrossAllowanceSum,AD.RecoveriesSum,AD.NetSum
		 From #Allowance_Details AD Inner JOIN T0030_Report_Header_Master HM WITH (NOLOCK)
		ON HM.Report_Id = AD.Report_ID 
		Inner JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK)
		On DM.Dept_Id = AD.Dept_ID
		
		Order by Report_ID

END

