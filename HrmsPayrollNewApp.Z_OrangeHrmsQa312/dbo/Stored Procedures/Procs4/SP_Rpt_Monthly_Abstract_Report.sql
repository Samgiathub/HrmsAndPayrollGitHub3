


---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Rpt_Monthly_Abstract_Report]
	@Cmp_ID Numeric(18),
	@From_Date Datetime,
	@To_Date Datetime
	--@Dept_ID Numeric(18,0) = 0
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
	Declare @Cur_Dept_ID_1 Numeric(18,0)
	Declare @Cur_Dept_Name_1 Varchar(500)
	
	Declare @Sum_Earning Numeric(18,2)
	Declare @Sum_Deduction Numeric(18,2)
	
	
	Declare @Cur_Dept_ID Numeric(18,0)
	Declare @Cur_Dept_Name Varchar(500)
	
	Set @Cur_Basic_Salary_Sum = 0
	Set @Cur_PT_Sum = 0
	Set @Sum_Earning = 0
	Set @Sum_Deduction = 0
	Set @Cur_Dept_ID = 0
	Set @Cur_Dept_Name = ''
	Set @Cur_Dept_ID_1 = 0
	Set @Cur_Dept_Name_1 = ''

	IF OBJECT_ID('tempdb..#Allowance_Details') Is Not NULL
		drop TABLE #Allowance_Details
	
	CREATE TABLE #Allowance_Details 
	(
		Cmp_ID Numeric(18,0),
		Report_ID Numeric(18,0),
		Report_Name Varchar(500),
		Employee_Type Numeric(18,0),
		Amount Numeric(18,2) default 0,
		To_Date Datetime,
		Flag Numeric(18,0),
		Dept_ID Numeric(18,0),
		Dept_Name Varchar(500),
		GrossAllowanceSum Numeric(18,2) default 0,
		RecoveriesSum Numeric(18,2) default 0,
		NetSum Numeric(18,2) default 0
	)
	
	CREATE TABLE #Allowance_Details_temp
	(
		Cmp_ID Numeric(18,0),
		AD_ID Numeric(18,0),
		Report_ID Numeric(18,0),
		Employee_Type Numeric(18,0),
		Dept_ID Numeric(18,0)
	)
	
	Create Table #Type_ID 
	(
		Cmp_ID Numeric(18,0),
		Employee_Type Numeric(18,0),
		Dept_ID Numeric(18,0)
	)
	
	Insert INTO #Type_ID(Cmp_ID,Employee_Type,Dept_ID)
	Select DISTINCT Cmp_ID,Type_ID,@Cur_Dept_ID From T0080_EMP_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID 
				
	Declare Cur_Department Cursor For  
	Select Dept_Id,Dept_Name From T0040_DEPARTMENT_MASTER WITH (NOLOCK) Where Cmp_Id = 20 --and Dept_Id = 141
	Open Cur_Department
		Fetch Next From Cur_Department Into @Cur_Dept_ID,@Cur_Dept_Name
		 While @@fetch_Status = 0
			Begin
				
				
				Insert INTO #Allowance_Details(Cmp_ID,Report_ID,Report_Name,Employee_Type,Amount,To_Date,Flag,Dept_ID,Dept_Name)
				SELECT AD.Cmp_ID,AD.Report_Id,HM.Report_Header_Name,AD.Employee_Type,0,@To_Date,TypeId,@Cur_Dept_ID,@Cur_Dept_Name 
				From T0100_Abstract_Report_Details AD WITH (NOLOCK) Inner JOIN
				T0030_Report_Header_Master HM WITH (NOLOCK) ON HM.Report_Id = AD.Report_ID Left OUTER JOIN
				#Type_ID TI ON TI.Employee_Type = AD.Employee_Type 
				Where Abstract_Report_ID = 3 
				
				Fetch Next From Cur_Department Into @Cur_Dept_ID,@Cur_Dept_Name
			End 
	Close Cur_Department
	deallocate Cur_Department	
	
	
	--Select * From #Allowance_Details order by Dept_ID,Report_ID,Employee_Type
	
	Declare Cur_Rport_Head Cursor For 
	Select AD.Cmp_ID,AD.Report_ID,AD.Employee_Type,Earning_Component_ID,Earning_Short_Name,Deduction_Component_ID,Deduction_Short_Name,Loan_ID,Loan_Short_Name,AD.Dept_ID,AD.Dept_Name 
	From T0100_Abstract_Report_Details AR WITH (NOLOCK) Inner JOIN #Allowance_Details AD
	On AR.Report_ID = AD.Report_ID and AR.Employee_Type = AD.Employee_Type 
	Inner JOIN #Type_ID TI ON TI.Employee_Type = AD.Employee_Type
	where Abstract_Report_ID = 3 
	open Cur_Rport_Head
		Fetch Next From Cur_Rport_Head into @Cur_Cmp_ID,@Cur_Report_ID,@Cur_Employee_Type,@Cur_Earning_Component_ID,@Cur_Earning_Short_Name,@Cur_Deduction_Component_ID,@Cur_Deduction_Short_Name,@Cur_Loan_ID,@Cur_Loan_Short_Name,@Cur_Dept_ID_1,@Cur_Dept_Name_1
			While @@fetch_status = 0
				Begin
					Set @Cur_Basic_Salary_Sum = 0
					Set @Cur_PT_Sum = 0
					Set @Cur_Loan_Sum = 0
					
					if @Cur_Earning_Component_ID is not null
						Begin
							INSERT INTO #Allowance_Details_temp(Cmp_ID,AD_ID,Report_ID,Employee_Type,Dept_ID) 
							SELECT @Cur_Cmp_ID,Data,@Cur_Report_ID,@Cur_Employee_Type,@Cur_Dept_ID_1 From dbo.Split(@Cur_Earning_Component_ID,'#')  
						End
						
					if @Cur_Deduction_Component_ID is not null
						Begin
							INSERT INTO #Allowance_Details_temp(Cmp_ID,AD_ID,Report_ID,Employee_Type,Dept_ID)
							SELECT @Cur_Cmp_ID,Data,@Cur_Report_ID,@Cur_Employee_Type,@Cur_Dept_ID_1 From dbo.Split(@Cur_Deduction_Component_ID,'#') 
						End 
						
					if @Cur_Loan_ID is not null
						Begin
							INSERT INTO #Allowance_Details_temp(Cmp_ID,AD_ID,Report_ID,Employee_Type,Dept_ID) 
							SELECT @Cur_Cmp_ID,Data,@Cur_Report_ID,@Cur_Employee_Type,@Cur_Dept_ID_1 From dbo.Split(@Cur_Loan_ID,'#') 
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
							Where Month(MS.Month_End_Date) = Month(@To_Date) 
							and  Year(MS.Month_End_Date) = Year(@To_Date) 
							and I.Dept_ID = @Cur_Dept_ID_1 and I.Type_ID = @Cur_Employee_Type
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
							Where Month(MS.Month_End_Date) = Month(@To_Date) 
							and  Year(MS.Month_End_Date) = Year(@To_Date) 
							and I.Dept_ID = @Cur_Dept_ID_1 and I.Type_ID = @Cur_Employee_Type
						END
					
					Select @Cur_Earning_Compoent_Sum = SUM(MA.M_AD_Amount) From T0210_MONTHLY_AD_DETAIL MA WITH (NOLOCK) Inner join #Allowance_Details_temp AD
					ON MA.AD_ID = AD.AD_ID Inner JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = MA.Emp_ID  INNER Join
							(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
									(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
									Where Increment_effective_Date <= @to_date AND Cmp_ID = @Cur_Cmp_ID Group by emp_ID) as new_inc
									on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								 Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry
							on I.Increment_ID = Qry.Increment_Id 
					Where I.Dept_ID = @Cur_Dept_ID_1 and AD.Report_ID = @Cur_Report_ID 
					and AD.Employee_Type = @Cur_Employee_Type
					And Month(MA.To_date) = Month(@To_Date) and Year(MA.To_date) = Year(@To_Date) and I.Type_ID = @Cur_Employee_Type
					
					
					--Select @Cur_Dept_ID_1,@Cur_Basic_Salary_Sum,@Cur_Earning_Compoent_Sum
					
					
					
					--if @Cur_Loan_ID is null
					--	Begin
							Update #Allowance_Details 
							Set Amount = Isnull(@Cur_Earning_Compoent_Sum,0) + Isnull(@Cur_Basic_Salary_Sum,0) + ISNULL(@Cur_PT_Sum,0)
							where Cmp_ID = @Cur_Cmp_ID and Employee_Type = @Cur_Employee_Type 
							and Report_ID = @Cur_Report_ID and Dept_ID = @Cur_Dept_ID_1
						--End 
						
					
					--Select Sum(LP.Loan_Pay_Amount) as Loan_Pay_Amount ,LA.Loan_ID as LoanID FROM 
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
					--Where I.Dept_ID = @Cur_Dept_ID_1 AND LA.Loan_Apr_Status = 'A' and LP.Loan_Payment_Date >= @From_Date and  LP.Loan_Payment_Date <= @To_Date
					-- and I.Type_ID = @Cur_Employee_Type
					--Group by LA.Loan_ID
						
					Update TDA 
					Set Amount = Amount + LoanPayAmount
					From #Allowance_Details TDA inner join
					(Select SUM(Loan_Pay_Amount) as LoanPayAmount,AD_temp.Report_ID,AD_temp.Employee_Type,AD_temp.Dept_ID From #Allowance_Details_temp AD_temp Inner JOIN  
					(Select Sum(LP.Loan_Pay_Amount) as Loan_Pay_Amount ,LA.Loan_ID as LoanID , I.Type_ID FROM 
					 T0120_LOAN_APPROVAL LA WITH (NOLOCK) inner join T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = LA.Emp_ID  INNER Join
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
					Where I.Dept_ID = @Cur_Dept_ID_1 AND LA.Loan_Apr_Status = 'A' and LP.Loan_Payment_Date >= @From_Date and  LP.Loan_Payment_Date <= @To_Date and LP.Sal_Tran_ID is not null
					Group by LA.Loan_ID, I.Type_ID) as qry
					on AD_temp.AD_ID = qry.LoanID and AD_temp.Employee_Type = qry.Type_ID
					Where AD_temp.Employee_Type = @Cur_Employee_Type 
					and AD_temp.Report_ID = @Cur_Report_ID
					and AD_temp.Dept_ID = @Cur_Dept_ID_1
					GROUP by AD_temp.Report_ID,AD_temp.Employee_Type,AD_temp.Dept_ID) As Qry1
					on TDA.Report_ID = Qry1.Report_ID and TDA.Employee_Type = Qry1.Employee_Type 
					and Qry1.Dept_ID = TDA.Dept_ID
					
					Update TDA 
					Set Amount = Amount + LoanPayAmount
					From #Allowance_Details TDA inner join
					(Select SUM(Loan_Pay_Amount) as LoanPayAmount,AD_temp.Report_ID,AD_temp.Employee_Type,AD_temp.Dept_ID From #Allowance_Details_temp AD_temp Inner JOIN  
					(Select Sum(LP.Interest_Amount) as Loan_Pay_Amount ,LA.Loan_ID as LoanID , I.Type_ID FROM 
					 T0120_LOAN_APPROVAL LA WITH (NOLOCK) inner join T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = LA.Emp_ID  INNER Join
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
					Where I.Dept_ID = @Cur_Dept_ID_1 AND LA.Loan_Apr_Status = 'A' and LP.Loan_Payment_Date >= @From_Date 
					and  LP.Loan_Payment_Date <= @To_Date and LP.Sal_Tran_ID is not null and LP.Is_Loan_Interest_Flag = 1
					Group by LA.Loan_ID, I.Type_ID) as qry
					on AD_temp.AD_ID = qry.LoanID and AD_temp.Employee_Type = qry.Type_ID
					Where AD_temp.Employee_Type = @Cur_Employee_Type 
					and AD_temp.Report_ID = @Cur_Report_ID
					and AD_temp.Dept_ID = @Cur_Dept_ID_1
					GROUP by AD_temp.Report_ID,AD_temp.Employee_Type,AD_temp.Dept_ID) As Qry1
					on TDA.Report_ID = Qry1.Report_ID and TDA.Employee_Type = Qry1.Employee_Type 
					and Qry1.Dept_ID = TDA.Dept_ID
					
					Delete From #Allowance_Details_temp
					
					Fetch Next From Cur_Rport_Head into @Cur_Cmp_ID,@Cur_Report_ID,@Cur_Employee_Type,@Cur_Earning_Component_ID,@Cur_Earning_Short_Name,@Cur_Deduction_Component_ID,@Cur_Deduction_Short_Name,@Cur_Loan_ID,@Cur_Loan_Short_Name,@Cur_Dept_ID_1,@Cur_Dept_Name_1
				End
		Close Cur_Rport_Head
		deallocate Cur_Rport_Head
			
	Insert INTO #Allowance_Details 
	(
		Cmp_ID,
		Report_ID,
		Report_Name,
		Employee_Type,
		Amount,
		To_Date,
		Flag,
		Dept_ID,
		Dept_Name
	)
	Select DISTINCT Cmp_ID,100,'Total Recoveries' as Report_Name,3,Rec_Amount,To_Date,3,qry.Dept_ID,AD.Dept_Name
	From #Allowance_Details AD Inner Join (Select SUM(AD2.Amount) As Rec_Amount,AD2.Dept_ID From #Allowance_Details AD2
	Where Flag = 2 
	Group BY AD2.Dept_ID
	) as qry
	on AD.Dept_ID = qry.Dept_ID 
	
	
	Insert INTO #Allowance_Details 
	(
		Cmp_ID,
		Report_ID,
		Report_Name,
		Employee_Type,
		Amount,
		To_Date,
		Flag,
		Dept_ID,
		Dept_Name
	)
	Select DISTINCT Cmp_ID,110,'Net Amount' as Report_Name,4 as Employee_Type,
	    (SELECT (
				Select SUM(Amount) as Amount From #Allowance_Details AD2
				Where Flag = 1 and AD2.Dept_ID = AD.Dept_ID  GROUP BY AD2.Dept_ID) - 
		       (Select SUM(Amount) as Amount From #Allowance_Details AD2
		       Where Flag = 2 and AD2.Dept_ID = AD.Dept_ID  GROUP BY AD2.Dept_ID)) 
		 as Rec_Amount ,To_Date,4,AD.Dept_ID,AD.Dept_Name
	From #Allowance_Details AD
	
	Select  * From #Allowance_Details AD
	Left Outer JOIN (SELECT SUM(EMp_ID) as EMp_ID ,EM.Type_ID as Type_ID,AD1.Dept_ID From #Allowance_Details AD1 inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK)
	on EM.Dept_ID = AD1.Dept_ID GROUP BY Type_ID,AD1.Dept_ID) as qry_12
	on AD.Employee_Type = qry_12.Type_ID and AD.Dept_ID = qry_12.Dept_ID
		
	--Select * From #Allowance_Details AD
	--Insert INTO #Allowance_Details 
	--(
	--	Cmp_ID,
	--	Report_ID,
	--	Report_Name,
	--	Employee_Type,
	--	Amount,
	--	To_Date,
	--	Flag,
	--	Dept_ID,
	--	Dept_Name
	--)
	--Select t.Cmp_ID,100 as Report_ID,'Recoveries' as Report_Header_Name,3,Report_Header,To_Date,3 as Flag,Dept_ID, '' From
	--	(Select SUM(AD.Amount) as Report_Header,AD.To_Date,AD.Flag,AD.GrossAllowanceSum,AD.RecoveriesSum,AD.NetSum,AD.Dept_ID,AD.Cmp_ID
	--	From #Allowance_Details AD Inner JOIN (SELECT SUM(EMp_ID) as EMp_ID ,EM.Type_ID as Type_ID,AD1.Dept_ID From #Allowance_Details AD1 inner JOIN T0080_EMP_MASTER EM
	--	on EM.Dept_ID = AD1.Dept_ID GROUP BY Type_ID,AD1.Dept_ID) as qry_12
	--	on AD.Employee_Type = qry_12.Type_ID and AD.Dept_ID = qry_12.Dept_ID
	--	Inner JOIN T0030_Report_Header_Master HM
	--	ON HM.Report_Id = AD.Report_ID 
	--	Where AD.Flag = 2
	--	Group by AD.To_Date,AD.Flag,AD.GrossAllowanceSum,AD.RecoveriesSum,AD.NetSum,AD.Dept_ID,AD.Cmp_ID) t
		
	--Group by Cmp_ID,Report_ID,Report_Name,To_Date,Flag,AD.Dept_ID,Dept_Name
	--order by AD.Dept_ID,Report_ID,Employee_Type
	
	--Select Cmp_ID,Report_ID,Report_Name,'' as Employee_Type,SUM(Amount) as Amount,To_Date,Flag,Dept_ID,Dept_Name From #Allowance_Details 
	--Group by Cmp_ID,Report_ID,Report_Name,To_Date,Flag,Dept_ID,Dept_Name
	--order by Dept_ID,Report_ID,Employee_Type
	
	--	Select 'Recoveries' as Report_Header_Name,Report_Header,To_Date,100 as Report_ID,3 as Flag,GrossAllowanceSum,RecoveriesSum,NetSum  From
	--	(Select SUM(AD.Amount) as Report_Header,AD.To_Date,AD.Flag,AD.GrossAllowanceSum,AD.RecoveriesSum,AD.NetSum
	--	From #Allowance_Details AD Inner JOIN T0030_Report_Header_Master HM
	--	ON HM.Report_Id = AD.Report_ID 
	--	Where AD.Flag = 2
	--	Group by AD.To_Date,AD.Flag,AD.GrossAllowanceSum,AD.RecoveriesSum,AD.NetSum) t
		
	--	Union
		
	--	SELECT DISTINCT 'Net' as Report_Header_Name,
	--	(Select SUM(Amount) as Amount From #Allowance_Details Where Flag = 1) - 
	--	       (Select SUM(Amount) as Amount From #Allowance_Details Where Flag = 2) 
	--	 as Report_Header 
	--	 ,To_Date,110 as Report_ID,4 as Flag,AD.GrossAllowanceSum,AD.RecoveriesSum,AD.NetSum
	--	 From #Allowance_Details AD Inner JOIN T0030_Report_Header_Master HM
	--	ON HM.Report_Id = AD.Report_ID
				
	--	Update #Allowance_Details
	--	Set GrossAllowanceSum = t.Amount
	--    From 
	--    (Select SUM(Amount) as Amount,Report_ID From  #Allowance_Details  Where Flag = 1 group BY Report_ID
	--    ) t
	    
	--    Update #Allowance_Details
	--	Set RecoveriesSum = t.Amount
	--    From 
	--    (Select SUM(Amount) as Amount From  #Allowance_Details  Where Flag = 2
	--    ) t
	    
	--    Update #Allowance_Details
	--    Set NetSum  = t.Report_Header
	--    From (Select
	--    (Select SUM(Amount) as Amount From #Allowance_Details Where Flag = 1) - 
	--	       (Select SUM(Amount) as Amount From #Allowance_Details Where Flag = 2) 
	--	 as Report_Header)t
	    
		
	--	Select HM.Report_Header_Name,SUM(isnull(AD.Amount,0)) as Report_Header,AD.To_Date,AD.Report_ID,AD.Flag,AD.GrossAllowanceSum,AD.RecoveriesSum,AD.NetSum
	--	From #Allowance_Details AD Inner JOIN T0030_Report_Header_Master HM
	--	ON HM.Report_Id = AD.Report_ID 
	--	Group by HM.Report_Header_Name,AD.To_Date,AD.Report_ID,AD.Flag,AD.GrossAllowanceSum,AD.RecoveriesSum,AD.NetSum
		
	--	Union 
		
	--	Select 'Recoveries' as Report_Header_Name,Report_Header,To_Date,100 as Report_ID,3 as Flag,GrossAllowanceSum,RecoveriesSum,NetSum  From
	--	(Select SUM(AD.Amount) as Report_Header,AD.To_Date,AD.Flag,AD.GrossAllowanceSum,AD.RecoveriesSum,AD.NetSum
	--	From #Allowance_Details AD Inner JOIN T0030_Report_Header_Master HM
	--	ON HM.Report_Id = AD.Report_ID 
	--	Where AD.Flag = 2
	--	Group by AD.To_Date,AD.Flag,AD.GrossAllowanceSum,AD.RecoveriesSum,AD.NetSum) t
		
	--	Union
		
	--	SELECT DISTINCT 'Net' as Report_Header_Name,
	--	(Select SUM(Amount) as Amount From #Allowance_Details Where Flag = 1) - 
	--	       (Select SUM(Amount) as Amount From #Allowance_Details Where Flag = 2) 
	--	 as Report_Header 
	--	 ,To_Date,110 as Report_ID,4 as Flag,AD.GrossAllowanceSum,AD.RecoveriesSum,AD.NetSum
	--	 From #Allowance_Details AD Inner JOIN T0030_Report_Header_Master HM
	--	ON HM.Report_Id = AD.Report_ID
		
	--	Order by Report_ID
	
	SELECT SUM(Net_Amount) AS Net_Amount, EM.Emp_Full_Name as Bank_Name,1 as sr_no
	FROM MONTHLY_EMP_BANK_PAYMENT PP WITH (NOLOCK)
	Inner Join T0040_BANK_MASTER BM WITH (NOLOCK)
	On PP.Emp_Bank_ID = BM.Bank_ID
	INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)
	on EM.Emp_ID = PP.Emp_ID
	where PP.Cmp_ID = 20 AND For_Date >= @From_Date and For_Date <= @To_Date  and PP.Payment_Mode = 'Cheque' and EM.Emp_ID = 1000
	GROUP BY EM.Emp_Full_Name
	Union
	SELECT SUM(Net_Amount) AS Net_Amount, EM.Emp_Full_Name as Bank_Name,2 as sr_no
	FROM MONTHLY_EMP_BANK_PAYMENT PP WITH (NOLOCK)
	Inner Join T0040_BANK_MASTER BM WITH (NOLOCK)
	On PP.Emp_Bank_ID = BM.Bank_ID
	INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)
	on EM.Emp_ID = PP.Emp_ID
	where PP.Cmp_ID = 20 AND For_Date >= @From_Date and For_Date <= @To_Date and PP.Payment_Mode = 'Cheque' and EM.Emp_ID = 704
	GROUP BY EM.Emp_Full_Name
	UNION
	SELECT SUM(Net_Amount) AS Net_Amount, BM.Bank_Name as Bank_Name ,3 as sr_no
	FROM MONTHLY_EMP_BANK_PAYMENT PP WITH (NOLOCK)
	Inner Join T0040_BANK_MASTER BM WITH (NOLOCK)
	On PP.Emp_Bank_ID = BM.Bank_ID
	where PP.Cmp_ID = 20 AND For_Date >= @From_Date and For_Date <= @To_Date 
	and PP.Payment_Mode = 'Bank Transfer'
	GROUP BY BM.Bank_Name
	UNION
	SELECT SUM(Net_Amount) AS Net_Amount, EM.Emp_Full_Name as Bank_Name ,1 as sr_no
	FROM MONTHLY_EMP_BANK_PAYMENT PP WITH (NOLOCK)
	INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)
	on EM.Emp_ID = PP.Emp_ID
	where PP.Cmp_ID = 20 AND For_Date >= @From_Date and For_Date <= @To_Date 
	and PP.Payment_Mode = 'Cheque'
	GROUP BY EM.Emp_Full_Name
	Union
	SELECT SUM(Net_Amount) AS Net_Amount, 'Self Cash' as Bank_Name ,4 as sr_no
	FROM MONTHLY_EMP_BANK_PAYMENT PP WITH (NOLOCK)
	Inner Join T0040_BANK_MASTER BM  WITH (NOLOCK)
	On PP.Emp_Bank_ID = BM.Bank_ID
	where PP.Cmp_ID = 20 AND For_Date >= @From_Date and For_Date <= @To_Date and PP.Payment_Mode = 'Cash'
	ORDER BY sr_no

END


