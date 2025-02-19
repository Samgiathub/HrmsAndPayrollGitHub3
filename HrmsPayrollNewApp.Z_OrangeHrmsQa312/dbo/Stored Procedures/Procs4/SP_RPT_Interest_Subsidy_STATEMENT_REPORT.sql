



CREATE PROCEDURE [dbo].[SP_RPT_Interest_Subsidy_STATEMENT_REPORT]
 @Cmp_ID 		numeric
,@From_Date 	datetime
,@To_Date 		datetime
,@Branch_ID 	numeric
,@Cat_ID 		numeric 
,@Grd_ID 		numeric
,@Type_ID 		numeric
,@Dept_ID 		numeric
,@Desig_ID 		numeric
,@Emp_ID 		numeric
,@constraint 	varchar(MAX)
,@Loan_Name		varchar(100)
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

 
	 
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null

	
	
	Declare @Loan_Id As Numeric
	Declare @Loan_Apr_Id As Numeric 
	Declare @Loan_Apr_Code As Numeric 
	Declare @Loan_Apr_Date As Datetime
	Declare @Loan_Amount As Numeric(18,2) 
	Declare @Loan_No_Of_Installment As Numeric 
	Declare @Loan_Installment_Amt As Numeric(18,2)
	Declare @Interest_Type as varchar(20)
	Declare @Interest_Percent As Numeric(18,2)
	Declare @Interest_Amount As Numeric(18,2)
	Declare @Pending_Loan_Amt as Numeric(18,0)
	Declare @Balance_Loan_Amt as Numeric(18,0)
	Declare @Installment_Date As Datetime
	Declare @Paid_Amount as Numeric(18,0)
	Declare @Max_Payment_Date as datetime
	Declare @Sal_Tran_Id As Numeric
	Declare @Salary_Interest_Amt As Numeric(18,0)
	Declare @Deduction_Type As varchar(30)
	Declare @Pending_Loan_AsOn_Date As Numeric(18,0)
	Declare @Payment_Amount As Numeric(18,0)
	Declare @Payment_Date as datetime
	Declare @Pre_Installment_Date as Datetime
	Declare @MonthDays As Numeric
	Declare @LoanDays As Numeric
	Declare @Branch_ID_Temp As Numeric
	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime   
	Declare @Month_St_Date  Datetime
	Declare @Month_End_Date  Datetime
	Declare @Interest_Recover_Perc as numeric(18,0)
	Declare @Main_Installement_Amount As numeric(18,2) 
	Declare @Installment_Start_Date as Datetime
	Declare @Design_ID as numeric(18,2)
	Declare @SubSidy_Max_Limit as numeric(18,2)
	Declare @Interest_Previous_Perc numeric(18,2)
	Declare @Interest_Effective_date datetime
	Set @Balance_Loan_Amt = 0	
	Set @Payment_Amount = 0		
	Set @Pre_Installment_Date = Null
	Set @MonthDays = 0
	Set @LoanDays = 0
	Set @Branch_ID_Temp = 0
	Set @Main_Installement_Amount = 0
	set @Interest_Recover_Perc = 0 
	set @Desig_ID = 0
	set @SubSidy_Max_Limit = 0
	set @Interest_Previous_Perc = 0
	
	Select @Loan_Id = Loan_Id From T0040_LOAN_MASTER WITH (NOLOCK) Where Loan_Name = @Loan_Name And Cmp_ID = @Cmp_ID
	
CREATE table #Emp_Cons 
 (      
   Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric    
 )      

	if @Constraint <> ''
		begin
			Insert Into #Emp_Cons
			Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
		end
	else 
		Begin
			Insert Into #Emp_Cons      
			  select distinct emp_id,branch_id,Increment_ID from dbo.V_Emp_Cons where 
			  cmp_id=@Cmp_ID 
			   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
			  and Increment_Effective_Date <= @To_Date 
			  and 
					  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)      
						or (@To_Date >= left_date  and  @From_Date <= left_date )) 
						order by Emp_ID
						
				Delete From #Emp_Cons Where Increment_ID Not In
				(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
				Where Increment_effective_Date <= @to_date) 
		End	

		
	
	Declare @Loan Table
	(
		Emp_Id Numeric,
		Loan_Id Numeric,
		Loan_Apr_Id Numeric,
		Loan_Apr_Code Numeric,
		Loan_Apr_Date Datetime,
		Loan_Amount Numeric(18,0),
		Deduction_Type Varchar(30),
		Loan_No_Of_Installment Numeric,
		Loan_Installment_Amt Numeric(18,0),
		Interest_Type varchar(20),
		Interest_Percent Numeric(18,2),
		Interest_Amount Numeric(18,0),
		Installment_Date datetime,
		Paid_Date varchar(Max),
		Paid_Amount Numeric(18,0),
		Loan_Balance Numeric(18,0),
		Pending_Loan_AsOn_Date Numeric(18,0),
		Interest_Recover_Perc Numeric(18,0),
		Interest_Recovery_Amount Numeric(18,0),
		Interest_Recovery_Subsidy numeric(18,0),
		Loan_Apr_Installment_Amount numeric(18,0)
	)

/*	Insert Into @Loan 
	(Emp_Id,Loan_Id,Loan_Apr_Id,Loan_Apr_Date,Loan_Amount,Loan_No_Of_Installment,Loan_Installment_Amt,
		Interest_Percent,Interest_Amount)
	Select LA.Emp_ID,Loan_Id,Loan_Apr_ID,Loan_Apr_Date,Loan_Apr_Amount,Loan_Apr_No_of_Installment,Loan_Apr_Installment_Amount,
		Loan_Apr_Intrest_Per,Loan_Apr_Intrest_Amount
	From T0120_LOAN_APPROVAL LA Inner Join #Emp_Cons EC On LA.Emp_ID = EC.Emp_ID
	Where LA.Emp_ID = @Emp_ID And Loan_ID = @Loan_Id
*/

declare @count as int
Set @count = 1
	
	
	Declare Cur_Loan cursor for 
		Select LA.Emp_ID,Loan_Id,LA.Loan_Apr_ID,Loan_Apr_Code,Loan_Apr_Date,Loan_Apr_Amount,Deduction_Type,Loan_Apr_No_of_Installment, Loan_Apr_Installment_Amount,
			Loan_Apr_Intrest_Type,  Loan_Apr_Intrest_Per,Loan_Apr_Intrest_Amount,Loan_Apr_Pending_Amount,Isnull(Installment_Start_Date,Loan_Apr_Date),isnull(Subsidy_Recover_Perc,0)
		From T0120_LOAN_APPROVAL LA WITH (NOLOCK)
		 Inner Join #Emp_Cons EC On LA.Emp_ID = EC.Emp_ID 
		Where Loan_ID = @Loan_Id And Loan_Apr_Date >= @From_Date And Loan_Apr_Date <= @To_Date 
	open Cur_Loan
	fetch next from Cur_Loan into @Emp_Id,@Loan_Id,@Loan_Apr_Id,@Loan_Apr_Code,@Loan_Apr_Date,@Loan_Amount,@Deduction_Type,@Loan_No_Of_Installment,@Loan_Installment_Amt,
								@Interest_Type,@Interest_Percent,@Interest_Amount,@Pending_Loan_AsOn_Date,@Installment_Start_Date,@Interest_Recover_Perc
	while @@fetch_Status = 0
		begin 
		
				Select @Branch_ID_Temp = Branch_ID,@Desig_ID = Desig_Id From T0095_Increment I WITH (NOLOCK) inner join     
				   (select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)    -- Ankit 08092014 for Same Date Increment
				   where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
				   I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID Where I.Emp_ID = @Emp_ID 
  
				Select @Sal_St_Date = Sal_st_Date 
				  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID_Temp    
				  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID_Temp and Cmp_ID = @Cmp_ID)    

				

				if isnull(@Sal_St_Date,'') = ''  or day(@Sal_St_Date) =1
					  begin    
						   --set @Sal_St_Date  = @From_Date     
						   --set @Sal_End_Date = @To_Date 
						   set @Sal_St_Date  = cast('1-' + cast(datename(mm,@Loan_Apr_Date) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Loan_Apr_Date) )as varchar(10)) as smalldatetime)    
						   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
						   
						   Set @Month_St_Date = @Sal_St_Date
						   Set @Month_End_Date = @Sal_End_Date      
					  end     
				 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
					  begin    
						   --set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
						   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,@Loan_Apr_Date) as varchar(10)) + '-' +  cast(year(@Loan_Apr_Date)as varchar(10)) as smalldatetime)    
						   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 

						   Set @Month_St_Date = @Sal_St_Date
						   Set @Month_End_Date = @Sal_End_Date    
					  end


				Set @Pending_Loan_Amt = @Loan_Amount
				Set @Balance_Loan_Amt = @Loan_Amount
				--Set @Installment_Date = dbo.GET_MONTH_END_DATE(Month(@Loan_Apr_Date),YEAR(@Loan_Apr_Date))


				--Set @Installment_Date = cast(cast(day(@Sal_End_Date)as varchar(5)) + '-' + Left(cast(datename(mm,@Loan_Apr_Date) as varchar(10)),3) + '-' +  cast(year(@Loan_Apr_Date)as varchar(10)) as smalldatetime)
				Set @Installment_Date = @Installment_Start_Date
				
				
				
				Set @MonthDays = DATEDIFF(d,@Month_St_Date,@Month_End_Date)+1
				If @Loan_Apr_Date <> @Installment_Date
					Set @LoanDays = DATEDIFF(d,@Loan_Apr_Date,@Installment_Date) + 1
				Else
					Set @LoanDays = @MonthDays
					
				--select @Installment_Date as Installment_Date , @MonthDays as MonthDays , @LoanDays as  LoanDays
				
				Select @Max_Payment_Date = MAX(Loan_Payment_Date) From T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) Where Loan_Apr_ID = @Loan_Apr_Id
					
				select @SubSidy_Max_Limit = isnull(Subsidy_Max_Limit,0) from [dbo].[T0040_Subsidy_Max_Limit_Design_Wise] WITH (NOLOCK) where Design_ID = @Desig_ID and Loan_ID = @Loan_Id
				
			
				
				While @Pending_Loan_Amt > 0
					Begin 
						--print @Pending_Loan_Amt
						If not @Pre_Installment_Date Is Null --And @Pre_Installment_Date <> @Loan_Apr_Date
							Begin
								Set @Pre_Installment_Date = DATEADD(D,1,@Pre_Installment_Date)
							end
						Else
							Begin
								Set @Pre_Installment_Date = @Loan_Apr_Date
							end					
							
							select @Loan_Installment_Amt =  Installment_Amount from [dbo].[T0120_Installment_Amount_Details] WITH (NOLOCK) where 
				Effective_date = (
									select MAX(Effective_date) from [dbo].[T0120_Installment_Amount_Details] WITH (NOLOCK)
									where Loan_Apr_ID = @Loan_Apr_Id and Emp_ID = @Emp_ID  and  Effective_date <=@Installment_Date
								  )
							and Loan_Apr_ID = @Loan_Apr_Id and Emp_ID = @Emp_ID 
									  
				set @Interest_Previous_Perc = @Interest_Percent
				select @Interest_Percent = Interest_Per_Yearly , @Interest_Effective_date = Effective_date from [dbo].[T0120_Interest_Yearly_Details] WITH (NOLOCK) where 
				Effective_date = (
									select MAX(Effective_date) from [dbo].[T0120_Interest_Yearly_Details] WITH (NOLOCK) 
									where Loan_Apr_ID = @Loan_Apr_Id and Emp_ID = @Emp_ID and  Effective_date <= @Installment_Date
								  )
						 and Loan_Apr_ID = @Loan_Apr_Id and Emp_ID = @Emp_ID 
						 
					Set @Main_Installement_Amount = @Loan_Installment_Amt
						If @Interest_Type = 'Reducing'
							Begin
								If Month(@Loan_Apr_Date) = Month(@Installment_Date) And Year(@Loan_Apr_Date) = Year(@Installment_Date)
									Begin
										Set @Interest_Amount = round((((@Pending_Loan_Amt * @Interest_Percent / 100)/12)/@MonthDays)* @LoanDays,0)

										If @Deduction_Type = 'Quaterly'
											Set @Interest_Amount = @Interest_Amount + ((@Pending_Loan_Amt * @Interest_Percent / 100)/12) * 3
										Else If @Deduction_Type = 'Half Yearly'
											Set @Interest_Amount = @Interest_Amount + ((@Pending_Loan_Amt * @Interest_Percent / 100)/12) * 5
										Else If @Deduction_Type = 'Yearly'
											Set @Interest_Amount = @Interest_Amount + ((@Pending_Loan_Amt * @Interest_Percent / 100)/12) * 11
									End									
								Else
									Begin
										If @Deduction_Type = 'Quaterly'
											Set @Interest_Amount = ((@Pending_Loan_Amt * @Interest_Percent / 100)/12) * 4
										Else If @Deduction_Type = 'Half Yearly'
											Set @Interest_Amount = ((@Pending_Loan_Amt * @Interest_Percent / 100)/12) * 6
										Else If @Deduction_Type = 'Yearly'
											Set @Interest_Amount = ((@Pending_Loan_Amt * @Interest_Percent / 100)/12) * 12
										Else If @Deduction_Type = 'Monthly'
											Set @Interest_Amount = (@Pending_Loan_Amt * @Interest_Percent / 100)/12							
									End			
							End
						Else
							Begin
								
								If @Deduction_Type = 'Quaterly'
									Set @Interest_Amount = ((@Loan_Amount * @Interest_Percent / 100)/12) * 4
								Else If @Deduction_Type = 'Half Yearly'
									Set @Interest_Amount = ((@Loan_Amount * @Interest_Percent / 100)/12) * 6
								Else If @Deduction_Type = 'Yearly'
									Set @Interest_Amount = ((@Loan_Amount * @Interest_Percent / 100)/12) * 12
								Else If @Deduction_Type = 'Monthly'
									Set @Interest_Amount = (@Loan_Amount * @Interest_Percent / 100)/12
								
							End
							
							--if day(@Installment_Start_Date) > 0 
							--	begin
							if @Installment_Date = @Installment_Start_Date
								begin
							-- Added by Gadriwala Muslim 23042015 for  day rate interest - Start
									DECLARE @dtDate DATETIME
									DECLARE @Month_Days as integer
									Declare @Interest_Days as integer
									SET @dtDate = @Installment_Date
									SET @dtDate= dateadd(mm,datediff(mm,0,@dtDate),0)
									SET @Month_Days =  datediff(dd,@dtDate,dateadd(mm,1,@dtDate))
									
									set @Interest_Days = @MonthDays   - day(@Installment_Date) + 1
									set @Interest_Amount = (isnull(@Interest_Amount,0) * isnull(@Interest_Days,0)) / isnull(@Month_Days,0)						
								 End
							-- Added by Gadriwala Muslim 23042015 for  day rate interest - End
								--end
							
							 
							
						If @Pending_Loan_Amt <= @Main_Installement_Amount
							Begin
								Set @Loan_Installment_Amt = @Pending_Loan_Amt --+ Isnull(@Interest_Amount,0)
								Set @Balance_Loan_Amt = @Balance_Loan_Amt - (@Loan_Installment_Amt)
								
							End
						Else
							Begin
								Set @Loan_Installment_Amt = @Main_Installement_Amount - Isnull(@Interest_Amount,0)
								Set @Balance_Loan_Amt = @Balance_Loan_Amt - (@Main_Installement_Amount - Isnull(@Interest_Amount,0))
								
							End
						
						Declare @Interest_Recover_Amount as numeric(18,0)
						Declare @Interest_Recover_Subsidy as numeric(18,0)
						Declare @interest_Effective_Days as numeric
						
						
						If day(@Interest_Effective_date) > 1
							set @interest_Effective_Days = day(@Interest_Effective_date) 
						
						If @Interest_Type = 'Reducing'
						 begin
							set @Interest_Recover_Amount = ((@Balance_Loan_Amt + @Loan_Installment_Amt) * (@Interest_Recover_Perc/100))/12
							
							if @Interest_Previous_Perc > 0  and @interest_Effective_Days > 1 and @Interest_Previous_Perc <> @Interest_Percent
								begin
									set @Interest_Recover_Subsidy = ((@Balance_Loan_Amt + @Loan_Installment_Amt) * ((@Interest_Previous_Perc - @Interest_Recover_Perc)/100))/365 * (@interest_Effective_Days -1)
									set @Interest_Recover_Subsidy =  @Interest_Recover_Subsidy +  ((@Balance_Loan_Amt + @Loan_Installment_Amt) * ((@Interest_Percent - @Interest_Recover_Perc)/100))/365 * (@MonthDays - (@interest_Effective_Days - 1) )
								end
							else
								begin
								set @Interest_Recover_Subsidy = ((@Balance_Loan_Amt + @Loan_Installment_Amt) * ((@Interest_Percent - @Interest_Recover_Perc)/100))/365 * @MonthDays
								end								
						 end
						else
						 begin
							set @Interest_Recover_Amount = ((@Loan_Amount) * (@Interest_Recover_Perc/100))/12
							
							if @Interest_Previous_Perc > 0  and @interest_Effective_Days > 1 and @Interest_Previous_Perc <> @Interest_Percent
								begin
									set @Interest_Recover_Subsidy = ((@Loan_Amount) * ((@Interest_Previous_Perc - @Interest_Recover_Perc)/100))/365 * (@interest_Effective_Days -1)
									set @Interest_Recover_Subsidy =  @Interest_Recover_Subsidy +  ((@Loan_Amount) * ((@Interest_Percent - @Interest_Recover_Perc)/100))/365 * (@MonthDays - (@interest_Effective_Days - 1) )
								end
							else
								begin
								set @Interest_Recover_Subsidy = ((@Loan_Amount) * ((@Interest_Percent - @Interest_Recover_Perc)/100))/365 * @MonthDays
								end								
						 end
						
						
						
						 if @SubSidy_Max_Limit > 0 
							begin
									if @SubSidy_Max_Limit < @Interest_Recover_Subsidy 
										set @Interest_Recover_Subsidy = @SubSidy_Max_Limit	
							end
							
						Insert Into @Loan
							(Emp_Id,Loan_Id,Loan_Apr_Id,Loan_Apr_Code,Loan_Apr_Date,Loan_Amount,Deduction_Type,Loan_No_Of_Installment,Loan_Installment_Amt,
							Interest_Type, Interest_Percent,Interest_Amount,Installment_Date,Loan_Balance,Pending_Loan_AsOn_Date,Interest_Recover_Perc,Interest_Recovery_Amount,Interest_Recovery_Subsidy,Loan_Apr_Installment_Amount)
						Values
							(@Emp_Id,@Loan_Id,@Loan_Apr_Id,@Loan_Apr_Code,@Loan_Apr_Date,@Loan_Amount,@Deduction_Type,@Loan_No_Of_Installment,@Loan_Installment_Amt,
								@Interest_Type,@Interest_Percent,@Interest_Amount,@Installment_Date,@Balance_Loan_Amt,@Pending_Loan_AsOn_Date,@Interest_Recover_Perc,@Interest_Recover_Amount,@Interest_Recover_Subsidy,@Main_Installement_Amount)


						If Exists (Select 1 From T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) Where Loan_Apr_ID = @Loan_Apr_Id And Loan_Payment_Date >= @Pre_Installment_Date And Loan_Payment_Date <= @Installment_Date)
							Begin
								Declare @Loan_Payment_Date As Varchar(Max)
								Select @Loan_Payment_Date =COALESCE(@Loan_Payment_Date + ', ', '') + convert(varchar(20), Loan_Payment_Date, 103) From T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) Where Loan_Apr_ID = @Loan_Apr_Id And Loan_Payment_Date >= @Pre_Installment_Date And Loan_Payment_Date <= @Installment_Date Order By Loan_Payment_Date
--								Select @Sal_Tran_Id = Sal_Tran_ID From T0210_MONTHLY_LOAN_PAYMENT Where Loan_Apr_ID = @Loan_Apr_Id And Month(Loan_Payment_Date) = Month(@Installment_Date) And Year(Loan_Payment_Date) = Year(@Installment_Date) Order By Loan_Payment_Date
--								Select @Salary_Interest_Amt = Isnull(Loan_Intrest_Amount,0) From T0200_MONTHLY_SALARY Where Sal_Tran_ID = @Sal_Tran_Id And Emp_ID = @Emp_ID

								Select @Paid_Amount = SUM(Isnull(Loan_Pay_Amount,0)),
									   @Salary_Interest_Amt = SUM(Isnull(Interest_Amount,0)) 
							    From T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK)
							    Where Loan_Apr_ID = @Loan_Apr_Id 
							    And Loan_Payment_Date >= @Pre_Installment_Date 
							    And Loan_Payment_Date <= @Installment_Date
								
								
								Update @Loan 
								Set Paid_Amount = @Paid_Amount + @Salary_Interest_Amt ,
								Loan_Balance = @Pending_Loan_Amt - @Paid_Amount, 
								Paid_Date = @Loan_Payment_Date, 
								Interest_Amount = Case When @Salary_Interest_Amt = 0 OR @Salary_Interest_Amt IS null Then 
														Interest_Amount 
												  Else 
														@Salary_Interest_Amt 
												  End
								Where Loan_Apr_ID = @Loan_Apr_Id And Month(Installment_Date) = Month(@Installment_Date) And Year(Installment_Date) = Year(@Installment_Date)
							End
							
							If Isnull(@Paid_Amount,0) > 0
								Set @Pending_Loan_Amt = @Pending_Loan_Amt - @Paid_Amount
							Else
								If not @Max_Payment_Date Is null
									Begin
										If (Month(@Max_Payment_Date) <= MONTH(@Installment_Date) And YEAR(@Max_Payment_Date) <= YEAR(@Installment_Date)) Or (YEAR(@Max_Payment_Date) < YEAR(@Installment_Date))
											Begin
												
												Set @Pending_Loan_Amt = @Pending_Loan_Amt - @Loan_Installment_Amt
												Update @Loan Set Loan_Balance = @Pending_Loan_Amt
												Where Loan_Apr_ID = @Loan_Apr_Id And Month(Installment_Date) = Month(@Installment_Date) And Year(Installment_Date) = Year(@Installment_Date)
												
											End
										Else
											Begin
												
												Update @Loan Set Loan_Balance = @Pending_Loan_Amt
												Where Loan_Apr_ID = @Loan_Apr_Id And Month(Installment_Date) = Month(@Installment_Date) And Year(Installment_Date) = Year(@Installment_Date)
												Set @Balance_Loan_Amt = @Pending_Loan_Amt
											
											End
									End
								Else
									Begin
									
										Set @Balance_Loan_Amt = @Pending_Loan_Amt - @Loan_Installment_Amt
										Set	@Pending_Loan_Amt = @Pending_Loan_Amt - @Loan_Installment_Amt
									End
						
						Set @Paid_Amount = 0
						Set @Loan_Payment_Date = Null
						Set @count = @count + 1
						
						Set @Pre_Installment_Date = @Installment_Date
						If @Deduction_Type = 'Quaterly'
							--Set @Installment_Date = dbo.GET_MONTH_END_DATE(Month(DATEADD(m,3,@Installment_Date)),YEAR(DATEADD(m,3,@Installment_Date))) 
								If day(@Sal_St_Date) = 1 
									Set @Installment_Date = dbo.GET_MONTH_END_DATE (Month(DATEADD(m,3,@Installment_Date)),YEAR(DATEADD(m,3,@Installment_Date)))
								else
									Set @Installment_Date = cast(cast(day(@Installment_Date)as varchar(5)) + '-' + cast(datename(mm,DATEADD(m,3,@Installment_Date)) as varchar(10)) + '-' +  cast(year(DATEADD(m,3,@Installment_Date) )as varchar(10)) as smalldatetime)
						Else If @Deduction_Type = 'Half Yearly'
							--Set @Installment_Date = dbo.GET_MONTH_END_DATE(Month(DATEADD(m,6,@Installment_Date)),YEAR(DATEADD(m,6,@Installment_Date))) 
								If day(@Sal_St_Date) = 1 
									Set @Installment_Date = dbo.GET_MONTH_END_DATE (Month(DATEADD(m,6,@Installment_Date)),YEAR(DATEADD(m,6,@Installment_Date)))
								else
									Set @Installment_Date = cast(cast(day(@Installment_Date)as varchar(5)) + '-' + cast(datename(mm,DATEADD(m,6,@Installment_Date)) as varchar(10)) + '-' +  cast(year(DATEADD(m,6,@Installment_Date))as varchar(10)) as smalldatetime)
						Else If @Deduction_Type = 'Yearly'
							--Set @Installment_Date = dbo.GET_MONTH_END_DATE(Month(DATEADD(YY,1,@Installment_Date)),YEAR(DATEADD(YY,1,@Installment_Date))) 
								If day(@Sal_St_Date) = 1 
									Set @Installment_Date = dbo.GET_MONTH_END_DATE (Month(DATEADD(YY,1,@Installment_Date)),YEAR(DATEADD(YY,1,@Installment_Date)))
								else
									Set @Installment_Date = cast(cast(day(@Installment_Date)as varchar(5)) + '-' + cast(datename(mm,DATEADD(YY,1,@Installment_Date)) as varchar(10)) + '-' +  cast(year(DATEADD(YY,1,@Installment_Date))as varchar(10)) as smalldatetime)
						Else If @Deduction_Type = 'Monthly'
							--Set @Installment_Date = dbo.GET_MONTH_END_DATE(Month(DATEADD(m,1,@Installment_Date)),YEAR(DATEADD(m,1,@Installment_Date))) 
								If day(@Sal_St_Date) = 1 
									--Set @Installment_Date = cast(cast(day(dateadd(m,1,@Installment_Date))as varchar(5)) + '-' + cast(datename(mm,DATEADD(m,1,@Installment_Date)) as varchar(10)) + '-' +  cast(year(DATEADD(m,1,@Installment_Date))as varchar(10)) as smalldatetime)
									Set @Installment_Date = dbo.GET_MONTH_END_DATE (Month(DATEADD(m,1,@Installment_Date)),YEAR(DATEADD(m,1,@Installment_Date)))
								else
									--Set @Installment_Date = cast(cast(day(@Installment_Date)as varchar(5)) + '-' + cast(datename(mm,DATEADD(m,1,@Installment_Date)) as varchar(10)) + '-' +  cast(year(DATEADD(m,1,@Installment_Date))as varchar(10)) as smalldatetime)
									Set @Installment_Date = cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,DATEADD(m,1,@Installment_Date)) as varchar(10)) + '-' +  cast(year(DATEADD(m,1,@Installment_Date))as varchar(10)) as smalldatetime)
					
					End
				Set @Balance_Loan_Amt = 0
				Set @Pending_Loan_Amt = 0
				Set @Pre_Installment_Date = Null
			fetch next from Cur_Loan into @Emp_Id,@Loan_Id,@Loan_Apr_Id,@Loan_Apr_Code,@Loan_Apr_Date,@Loan_Amount,@Deduction_Type,@Loan_No_Of_Installment,@Loan_Installment_Amt,
								@Interest_Type,@Interest_Percent,@Interest_Amount,@Pending_Loan_AsOn_Date,@Installment_Start_Date,@Interest_Recover_Perc
		End
	close Cur_Loan
	Deallocate Cur_Loan

	
	Select L.*,E.Emp_code,E.Alpha_Emp_Code, E.Emp_full_Name, Branch_Name, Dept_Name, Grd_Name, Desig_Name,Type_Name, 
		Branch_Address, Comp_Name,Loan_Name,Cmp_Name,Cmp_Address,@From_Date As From_Date,@To_Date As To_Date,
		Loan_Apr_Payment_Date,Loan_Apr_Payment_Type,LA.Bank_ID,Loan_Apr_Cheque_No,Bank_Name,BM.BRANCH_ID
		 
	From @Loan L Inner join T0080_EMP_MASTER E WITH (NOLOCK) ON L.EMP_ID = E.EMP_ID
	INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.Type_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK)	-- Ankit 08092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
		E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
		T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
		T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID LEFT OUTER JOIN 
		T0040_TYPE_MASTER TM WITH (NOLOCK) ON Q_I.TYPE_ID = TM.TYPE_ID Inner Join
		T0040_LOAN_MASTER LM WITH (NOLOCK) On L.Loan_Id = LM.Loan_ID Inner Join
		T0010_COMPANY_MASTER C WITH (NOLOCK) On E.Cmp_ID = C.Cmp_Id Inner Join
		T0120_LOAN_APPROVAL LA WITH (NOLOCK) On L.Loan_Apr_Id = LA.Loan_Apr_ID Left Outer Join
		T0040_BANK_MASTER BMM WITH (NOLOCK) On LA.Bank_ID = BMM.Bank_Id
	order by Loan_apr_id,Installment_Date
					
	RETURN 




