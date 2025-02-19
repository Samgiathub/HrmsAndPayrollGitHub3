

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CALCULATE_LOAN_PAYMENT_INT_PERQUISITE]
	@CMP_ID			NUMERIC ,
	@EMP_ID			NUMERIC,
	@From_Date		Datetime,
	@To_Date		DATETIME,
	@SALARY_TRAN_ID	NUMERIC ,
	@MANUAL_LOAN	NUMERIC,
	@IS_LOANDEDU	NUMERIC ,-- (0 ,1)
	@Is_FNF			int = 0
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	DECLARE @Loan_Id			as NUMERIC
	DECLARE @Pending_Loan		as NUMERIC(27,5)
	DECLARE @Loan_Inst			as NUMERIC(27,5)
	DECLARE @Loan_Inst_Amount	as NUMERIC(27,5)
	DECLARE @Loan_Payment_Id	as NUMERIC
	DECLARE @TotalInst_Amount	as NUMERIC(27,5)
	DECLARE @TotLoan_Closing	as NUMERIC(27,5)
	DECLARE @Interest_Percent	as NUMERIC(10,5)
	DECLARE @Loan_Apr_ID		as NUMERIC
	DECLARE @Loan_apr_Deduct_From_sal NUMERIC
	DECLARE @Return_Amount		as NUMERIC(27,5)
	DECLARE @Loan_Apr_Amount	as NUMERIC(27,5)
	DECLARE @Pre_Approval_Id	as NUMERIC
	DECLARE @Pre_Payment_Id		as NUMERIC
	DECLARE @Deduction_Type		as VARCHAR(20)
	Declare @Interest_Subsidy_Amount as numeric(18,0) --Added by Gadriwala Muslim 26122014
	Declare @SubSidy_Max_Limit as numeric(18,2)		  --Added by Gadriwala Muslim 26122014
	Declare @Interest_Previous_Perc numeric(18,2)	  --Added by Gadriwala Muslim 26122014
	Declare @Interest_Effective_date varchar(25)      --Added by Gadriwala Muslim 26122014
	declare @Is_Interest_Subsidy_Limit tinyint        --Added by Gadriwala Muslim 26122014
	Declare @Desig_ID numeric(18,0)					  --Added by Gadriwala Muslim 26122014
	declare @interest_Effective_Days numeric(18,0)	  --Added By Gadriwala Muslim 26122014
	Declare @Interest_Recov_Perc as numeric(18,0)     --Added By Gadriwala Muslim 26122014
	Declare @Is_First_Ded_Priciple_Amt as numeric(18,0)
	Declare @paid_Amount as numeric(18,2)
	DECLARE @Installment_Start_Date DATETIME;

	DECLARE @Loan_Interest_Amount	 NUMERIC(27,2)
	DECLARE @Interest_Type			 VARCHAR(20)
	DECLARE @Loan_Apr_Date			 DATETIME 	

	Declare @MonthDays As Numeric
	Declare @LoanDays As Numeric
	Declare @Branch_ID_Temp As Numeric
	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime   
	Declare @Month_St_Date  Datetime
	Declare @Month_End_Date  Datetime
	
	declare @Subsidy_Amount as numeric(18,2) -- rohit on 26072016
	declare @is_Subisdy_Loan as tinyint
	declare @temp_subsidy_amount as numeric(18,2)
	
	set @temp_subsidy_amount = 0
	set @Subsidy_Amount = 0
	set @is_Subisdy_Loan = 0

	Set @MonthDays = 0
	Set @LoanDays = 0
	Set @Branch_ID_Temp = 0
	

	SET @Interest_Percent		= 0.0
	set @Loan_Interest_Amount	=0.0
	set @Pending_Loan			= 0.0
	set @TotLoan_Closing		= 0.0
	set @TotalInst_Amount		= 0.0
	set @Loan_Apr_Amount		= 0.0
	set @Loan_Payment_Id		= 0

	set @Return_Amount			= 0.0
	set @Loan_Apr_Amount		=0.0
	SET @Pre_Approval_Id		= 0
	SET @Pre_Payment_Id			= 0
	SET @Loan_Inst				= 0
	SET @Deduction_Type			=''
	
	set @Interest_Subsidy_Amount = 0 --Added by Gadriwala Muslim 26122014
	set @SubSidy_Max_Limit = 0 --Added by Gadriwala Muslim 26122014
	set @Interest_Previous_Perc = 0 --Added by Gadriwala Muslim 26122014
	set @Desig_ID = 0 --Added by Gadriwala Muslim 26122014
	set @Is_Interest_Subsidy_Limit = 0 --Added by Gadriwala Muslim 26122014
	set @interest_Effective_Days = 0 --Added by Gadriwala Muslim 26122014
	set @Interest_Recov_Perc = 0 
	DECLARE @DelPayment_Id AS NUMERIC
	SET @DelPayment_Id = 0
	Set @Is_First_Ded_Priciple_Amt = 0
	Set @paid_Amount = 0
	
	--if @Is_LoanDedu = 1 
	--	BEGIN		
			SET @Loan_Payment_Id = 0
			DECLARE curLoan CURSOR FOR
			
				SELECT LA.loan_id,La.Loan_Apr_ID,
						(case when la.Paid_Amount <> 0 AND la.Loan_Apr_Intrest_Type='FIX' then isnull(Loan_Apr_Amount,0) + isnull(la.Paid_Amount,0) ELSE Loan_Apr_Amount End) as Loan_Apr_Amount,
						--Loan_Apr_Amount,
						case when isnull(Qry.Installment_Amount,0) = 0 or LM.Is_Interest_Subsidy_Limit = 0 then LA.Loan_Apr_Installment_Amount else Qry.Installment_Amount end,Loan_apr_Deduct_From_sal
						,Loan_apr_no_of_installment ,Loan_Apr_Date,la.Deduction_Type,la.Loan_Apr_Intrest_Type,Qry_3.Standard_Rates,
						isnull(LA.Loan_Apr_Intrest_Amount,0),Isnull(LM.Is_Interest_Subsidy_Limit,0),Isnull(Qry2.Effective_date,''),ISNULL(La.Subsidy_Recover_Perc,0),ISNULL(LM.Is_Principal_First_than_Int,0),la.Paid_Amount
						,Installment_Start_Date
						,La.Subsidy_Amount,Lm.Is_Subsidy_Loan
				FROM	T0120_loan_approval la WITH (NOLOCK) INNER JOIN T0040_LOAN_MASTER LM WITH (NOLOCK) ON la.Cmp_ID=LM.Cmp_ID AND la.Loan_ID = LM.Loan_ID
						left outer join  -- Changed by Gadriwala Muslim 25122014 for Interest Subsidy
							(
								select Installment_Amount,Loan_Apr_ID from dbo.T0120_Installment_Amount_Details WITH (NOLOCK)
								where Effective_date = (
															select MAX(Effective_date) from  dbo.T0120_Installment_Amount_Details WITH (NOLOCK)
															where Effective_date <= @To_Date and Emp_ID = @EMP_ID
													   )
											and Emp_ID = @EMP_ID		   
							)Qry on Qry.Loan_Apr_ID = LA.Loan_Apr_ID 					
						Left outer join
							(
								select Interest_Per_Yearly,Loan_Apr_Id,Effective_date from	[dbo].[T0120_Interest_Yearly_Details] WITH (NOLOCK)
								where Effective_date =
								 (
										select MAX(Effective_date) from  [dbo].[T0120_Interest_Yearly_Details] WITH (NOLOCK)
														where Effective_date <= @To_Date and Emp_ID = @EMP_ID
								 )
								and Emp_ID = @EMP_ID					
							) Qry2 on Qry2.Loan_Apr_ID = LA.Loan_Apr_ID  
						LEFT OUTER JOIN 
						  (
								SELECT LID.Loan_ID,LID.Standard_Rates FROM T0050_Loan_Interest_Details LID WITH (NOLOCK)
								Inner join(
									Select MAX(Effective_Date) as EffectiveDate,Loan_ID 
									From T0050_Loan_Interest_Details WITH (NOLOCK) Where Effective_Date <= @To_Date
									GROUP By Loan_ID ) as qry_2
								ON LID.Effective_Date = qry_2.EffectiveDate and LID.Loan_ID = qry_2.Loan_ID	
						  ) as Qry_3 
						  ON la.Loan_ID = Qry_3.Loan_ID
				WHERE	emp_id = @emp_id and la.Cmp_ID = @Cmp_ID
				 		and Loan_Apr_pending_amount >0 	
						--and Isnull(Installment_Start_Date,Loan_Apr_Date) <= @To_Date --Commented by Nimesh on 28-Jul-2016 (To calculate the interest only if installment start date is later.)
						and Loan_Apr_Date <= @To_Date
						and Loan_Apr_Status='A'
						and (Loan_Apr_Deduct_From_sal = 1 or Loan_Apr_Deduct_From_sal = 0 or @Is_FNF =1)  AND IsNull(LM.Is_GPF,0)=0 And ISNULL(LM.Is_Intrest_Amount_As_Perquisite_IT,0) = 1
						--order by La.Loan_apr_ID
			
			ORDER BY La.Loan_apr_ID
					
			OPEN curLoan		
			FETCH NEXT FROM curLoan INTO @Loan_Id,@Loan_Apr_ID,@Loan_Apr_Amount,@Loan_Inst_Amount,@Loan_apr_Deduct_From_sal ,@Loan_Inst,@Loan_Apr_Date,@Deduction_Type,@Interest_Type,@Interest_Percent,@Loan_Interest_Amount,@Is_Interest_Subsidy_Limit,@Interest_Effective_date,@Interest_Recov_Perc,@Is_First_Ded_Priciple_Amt,@paid_Amount,@Installment_Start_Date,@Subsidy_Amount,@is_Subisdy_Loan
			WHILE @@FETCH_STATUS = 0
				BEGIN
					SELECT	@TotLoan_Closing = isnull(sum(Loan_Pay_Amount),0) from T0210_Monthly_Loan_payment WITH (NOLOCK) where 
							Cmp_ID = @Cmp_ID and Loan_Apr_ID =@Loan_Apr_ID and Loan_payment_Date <=  @To_Date
					
					--and Loan_payment_Date in (select max(Loan_payment_Date) from T0210_Monthly_Loan_payment
					--where Loan_apr_ID = @Loan_Apr_ID  and  Cmp_ID = @Cmp_ID 
					--and Loan_Payment_Date <= @To_Date)
						
					--Hardik for Interest calculation 15/05/2012
					declare @Temp_Month_St_Date as datetime
					declare @Temp_Month_End_Date as datetime
					Declare @Temp_TotLoan_Closing As Numeric(22,0)
					Declare @Temp_Loan_Closing As Numeric(22,0)
					Declare @Pre_Loan_Interest_Amount As Numeric(22,2)
					Set @Pre_Loan_Interest_Amount = 0
			
					DECLARE curLoantest CURSOR FOR
					SELECT	Month_St_Date,Month_End_Date 
					FROM	T0200_MONTHLY_SALARY WITH (NOLOCK)
					WHERE	Month_End_Date  BETWEEN (SELECT ISNULL( MAX(Month_End_Date),@From_Date) 
														FROM	T0200_MONTHLY_SALARY WITH (NOLOCK)
														WHERE  Emp_ID = @emp_id and Loan_Amount > 0) 
							and @To_Date and Emp_ID = @emp_id And Loan_Amount = 0	
					OPEN curLoantest		
					FETCH NEXT FROM curLoantest INTO @Temp_Month_St_Date,@Temp_Month_End_Date
					WHILE @@FETCH_STATUS = 0
						BEGIN							
							Select	@Branch_ID_Temp = Branch_ID From T0095_Increment I WITH (NOLOCK) inner join     
									(select max(Increment_Id) as Increment_Id, Emp_ID from T0095_Increment  WITH (NOLOCK)   --Changed by Hardik 09/09/2014 for Same Date Increment
							where	Increment_Effective_date <= @Temp_Month_End_Date and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
									I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID = @Emp_ID   --Changed by Hardik 09/09/2014 for Same Date Increment
			  
							Select	@Sal_St_Date = Sal_st_Date 
							from	T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID_Temp    
									and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Temp_Month_End_Date and Branch_ID = @Branch_ID_Temp and Cmp_ID = @Cmp_ID)    

							

							if isnull(@Sal_St_Date,'') = ''    
								  begin    
									   set @Month_St_Date  = @Month_St_Date     
									   set @Month_End_Date = @Month_End_Date    
								  end     
							 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)= 1    
								  begin    
									   set @Month_St_Date  = @Sal_St_Date     
									   set @Month_End_Date = DATEADD(d, -1, DATEADD(mm, 1, @Month_St_Date))    
								  end     
							 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
								  begin    
									   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,@Temp_Month_St_Date) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Temp_Month_St_Date) )as varchar(10)) as smalldatetime)    
									   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 

									   Set @Month_St_Date = @Sal_St_Date
									   Set @Month_End_Date = @Sal_End_Date    
								  end

							Set @MonthDays = DATEDIFF(d,@Month_St_Date,@Month_End_Date)+1

							
					
							Select @Temp_TotLoan_Closing = isnull(sum(Loan_Pay_Amount),0) from T0210_Monthly_Loan_payment WITH (NOLOCK) where 
								Cmp_ID = @Cmp_ID and Loan_Apr_ID =@Loan_Apr_ID and Loan_payment_Date <=  @Temp_Month_End_Date
							
							Set @Temp_Loan_Closing = @Loan_Apr_Amount - @Temp_TotLoan_Closing
						
							Set @LoanDays = DATEDIFF(d,@Loan_Apr_Date,@Temp_Month_End_Date) + 1
							
							If @Interest_Type = 'Reducing'
								Begin
									If Month(@Loan_Apr_Date) = MONTH(@Temp_Month_End_Date) And YEAR(@Loan_Apr_Date) = YEAR(@Temp_Month_End_Date)
										Begin											
											Set @Pre_Loan_Interest_Amount = @Pre_Loan_Interest_Amount + ((((@Temp_Loan_Closing * @Interest_Percent / 100)/12)/@MonthDays)* @LoanDays)
										End
									Else
										Begin
											if @Is_FNF =1 -- Added by nilesh patel for Ineterest Calculation base on Fnf Days
												Set @Loan_Interest_Amount = ((isnull(@Pre_Loan_Interest_Amount + ((@Temp_Loan_Closing * @Interest_Percent / 100)/12),0))* @MonthDays)/DAY(DATEADD(DD,-1,DATEADD(MM,DATEDIFF(MM,-1,@Month_End_Date),0))) 
											else
												If @Loan_Apr_Date <= @Temp_Month_End_Date --Added by Hardik 07/03/2016 as 2 Same loan approval has problem, where 1 is completed and 1 is newly started 
													Begin
														Set @Pre_Loan_Interest_Amount = @Pre_Loan_Interest_Amount + ((@Temp_Loan_Closing * @Interest_Percent / 100)/12)
													End
										End
								End
							Else
								Begin
									If Month(@Loan_Apr_Date) = MONTH(@Temp_Month_End_Date) And YEAR(@Loan_Apr_Date) = YEAR(@Temp_Month_End_Date)
										Begin
											Set @Pre_Loan_Interest_Amount = @Pre_Loan_Interest_Amount + ((((@Loan_Apr_Amount * @Interest_Percent / 100)/12)/@MonthDays)* @LoanDays)
										End
									Else
										Begin
											if @Is_FNF =1
												Set @Loan_Interest_Amount = ((isnull(@Pre_Loan_Interest_Amount + ((@Loan_Apr_Amount * @Interest_Percent / 100)/12),0))*@MonthDays)/DAY(DATEADD(DD,-1,DATEADD(MM,DATEDIFF(MM,-1,@Month_End_Date),0))) 
											Else
												If @Loan_Apr_Date <= @Temp_Month_End_Date --Added by Hardik 07/03/2016 as 2 Same loan approval has problem, where 1 is completed and 1 is newly started 
													Begin
														Set @Pre_Loan_Interest_Amount = @Pre_Loan_Interest_Amount + ((@Loan_Apr_Amount * @Interest_Percent / 100)/12)
													END
										End
								End

							
							FETCH NEXT FROM curLoantest into @Temp_Month_St_Date,@Temp_Month_End_Date
						END 			
					CLOSE curLoantest
					DEALLOCATE curLoantest		
			
					------------end Interest Calculation
					set @Month_St_Date = @From_Date  -- Added by Gadriwala Muslim 26122014
					set @Month_End_Date = @To_Date -- Added by Gadriwala Muslim 26122014

					DECLARE @Loan_Closing as numeric(18,0)
					SET @Loan_Closing = @Loan_Apr_Amount - @TotLoan_Closing
				  
					Select @Branch_ID_Temp = Branch_ID,@desig_ID = Desig_Id From T0095_Increment I WITH (NOLOCK) inner join     
					   (select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment  WITH (NOLOCK)   --Changed by Hardik 09/09/2014 for Same Date Increment
					   where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
					   I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID = @Emp_ID  --Changed by Hardik 09/09/2014 for Same Date Increment
	  
					Select @Sal_St_Date = Sal_st_Date 
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID_Temp    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID_Temp and Cmp_ID = @Cmp_ID)    

					
					if isnull(@Sal_St_Date,'') = ''    
						  begin    
							   set @Month_St_Date  = @Month_St_Date     
							   set @Month_End_Date = @Month_End_Date    
						  end     
					 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)= 1    
						  begin    
							   set @Month_St_Date  = @Month_St_Date     
							   set @Month_End_Date = @Month_End_Date    
						  end     
					 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
						  begin    
							   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,@From_Date) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
							   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 

							   Set @Month_St_Date = @Sal_St_Date
							   Set @Month_End_Date = @Sal_End_Date    
						  end

					Set @MonthDays = DATEDIFF(d,@Month_St_Date,@Month_End_Date)+1
					
					Set @LoanDays = DATEDIFF(d,@Loan_Apr_Date,@Month_End_Date) --+ 1
					
					
					If @Interest_Type = 'Reducing'
						Begin							
							If Month(@Loan_Apr_Date) = MONTH(@Month_End_Date) And YEAR(@Loan_Apr_Date) = YEAR(@Month_End_Date)
								Begin																		
									Set @Loan_Interest_Amount = isnull(@Pre_Loan_Interest_Amount + ((((@Loan_Closing * @Interest_Percent / 100)/12)/@MonthDays)* @LoanDays),0)
									--select @Loan_Interest_Amount, @Pre_Loan_Interest_Amount, @Loan_Closing, @Interest_Percent,@MonthDays,@LoanDays
								End
							Else
								Begin									
									if @Is_FNF =1 
										Set @Loan_Interest_Amount = ((isnull(@Pre_Loan_Interest_Amount + ((@Loan_Closing * @Interest_Percent / 100)/12),0))*@MonthDays)/DAY(DATEADD(DD,-1,DATEADD(MM,DATEDIFF(MM,-1,@Month_End_Date),0))) 
									Else
										Set @Loan_Interest_Amount = isnull(@Pre_Loan_Interest_Amount + ((@Loan_Closing * @Interest_Percent / 100)/12),0)									
								End
								
						End
					Else
						Begin
							If Month(@Loan_Apr_Date) = MONTH(@Month_End_Date) And YEAR(@Loan_Apr_Date) = YEAR(@Month_End_Date)
								Begin
									Set @Loan_Interest_Amount = isnull(@Pre_Loan_Interest_Amount + ((((@Loan_Apr_Amount * @Interest_Percent / 100)/12)/@MonthDays)* @LoanDays),0)									
								End
							Else
								Begin
									-- Comment by nilesh patel on 24072015 (Calculate Left Full Month Interest Amount)
									--Set @Loan_Interest_Amount = isnull(@Pre_Loan_Interest_Amount + ((@Loan_Apr_Amount * @Interest_Percent / 100)/12),0) 
									-- Added By nilesh Patel for Calculate Interest base on Fnf day instead of Full Month.
									if @Is_FNF =1 
										Set @Loan_Interest_Amount = ((isnull(@Pre_Loan_Interest_Amount + ((@Loan_Apr_Amount * @Interest_Percent / 100)/12),0))*@MonthDays)/DAY(DATEADD(DD,-1,DATEADD(MM,DATEDIFF(MM,-1,@Month_End_Date),0))) 
									else
										Set @Loan_Interest_Amount = isnull(@Pre_Loan_Interest_Amount + ((@Loan_Apr_Amount * @Interest_Percent / 100)/12),0) 									

									
								End
						End
						
				
					If @Loan_Interest_Amount is null
						set @Loan_Interest_Amount = 0
					
					
						Begin
							
							If @MANUAL_LOAN > 0 
								Set @Loan_Inst_Amount =  @MANUAL_LOAN					
							ELSE IF @Installment_Start_Date > @Month_End_Date 
								--Set @Loan_Inst_Amount =  @Loan_Interest_Amount
								Set @Loan_Inst_Amount =  0
							
							if @Is_First_Ded_Priciple_Amt = 1 --Added by nilesh patel on 16072015
								Begin
									Set @Loan_Inst_Amount = @Loan_Inst_Amount
								End
							Else
								Begin
									Set @Loan_Inst_Amount = @Loan_Inst_Amount /*- @Loan_Interest_Amount*/
								End 
						End
								
					
					--Added by Hardik 17/09/2012
					if @paid_Amount <> 0 and @Interest_Type = 'FIX'
						BEGIN
							Select  @Return_Amount = Isnull(sum(loan_Pay_Amount),0) From T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) WHERE Loan_Apr_ID = @Loan_Apr_ID
							Set @Pending_Loan  = @Loan_Apr_Amount - (@Return_Amount + @paid_Amount)
						End 
					Else
						Begin
							Select  @Return_Amount = Isnull(sum(loan_Pay_Amount),0) From T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) WHERE Loan_Apr_ID = @Loan_Apr_ID
							Set @Pending_Loan  = @Loan_Apr_Amount - @Return_Amount 
						End 
					
					
					If @Loan_Closing > 0 
						BEGIN
							if @Is_FNF =1 
								BEGIN
									Set	@Return_Amount = 0
								
									--Select  @Return_Amount = Isnull(sum(loan_Pay_Amount),0) From T0210_MONTHLY_LOAN_PAYMENT WHERE Loan_Apr_ID = @Loan_Apr_ID
									--Set @Pending_Loan  = @Loan_Apr_Amount - @Return_Amount 
									
								
									if @Loan_Inst_Amount > @Pending_Loan and @Pending_Loan >0 
										set @Loan_Inst_Amount = @Pending_Loan
									else IF @Pending_Loan =0 
										set @Loan_Inst_Amount = 0
									
									if @Is_FNF =1 
										BEGIN
											set @Loan_Inst_Amount = @Pending_Loan
											exec P0210_MONTHLY_LOAN_PAYMENT_INSERT 0,@Loan_Apr_ID,@Cmp_Id,@Salary_Tran_ID,@Loan_Inst_Amount,'',@To_Date,'','','','',@Loan_Interest_Amount,@Interest_Percent,@Interest_Subsidy_Amount
										END
									ELSE IF (@Loan_Inst_Amount + @Loan_Interest_Amount) > 0 and @Loan_apr_Deduct_From_sal = 1
										BEGIN
											exec P0210_MONTHLY_LOAN_PAYMENT_INSERT 0,@Loan_Apr_ID,@Cmp_Id,@Salary_Tran_ID,@Loan_Inst_Amount,'',@To_Date,'','','','',@Loan_Interest_Amount,@Interest_Percent,@Interest_Subsidy_Amount
										END
								END	
							ELSE 
								BEGIN
									if @Deduction_Type = 'Quaterly' Or @Deduction_Type = 'Half Yearly' or @Deduction_Type = 'Yearly'
										BEGIN
											Declare @Is_Deduct varchar(max)
											set @Is_Deduct = DBO.F_GET_LOAN_DED_M(@To_Date,@Loan_Apr_Date,@Deduction_Type) 
										
											--Commented by Hardik 27/12/2011 and put Month Name
											--if charindex(cast(Month(@To_Date) as varchar(5)),@Is_Deduct) <> 0
											IF CHARINDEX(CAST(DATENAME(m,@To_Date) as varchar(3)),@Is_Deduct) <> 0
																														BEGIN
												--  SELECT  @Return_Amount = ISNULL(SUM(loan_Pay_Amount),0) FROM T0210_MONTHLY_LOAN_PAYMENT WHERE Loan_Apr_ID = @Loan_Apr_ID
												--SET @Pending_Loan  = @Loan_Apr_Amount - @Return_Amount 
												IF @Loan_Inst_Amount > @Pending_Loan AND @Pending_Loan >0 
													SET @Loan_Inst_Amount = @Pending_Loan
												ELSE IF @Pending_Loan =0 
													SET @Loan_Inst_Amount = 0
													
												
													
												IF @Is_FNF =1 
													BEGIN
														SET @Loan_Inst_Amount = @Pending_Loan
														EXEC P0210_MONTHLY_LOAN_PAYMENT_INSERT 0,@Loan_Apr_ID,@Cmp_Id,@Salary_Tran_ID,@Loan_Inst_Amount,'',@To_Date,'','','','',@Loan_Interest_Amount,@Interest_Percent,@Interest_Subsidy_Amount
													END
												ELSE IF @Loan_Inst_Amount > 0 AND @Loan_apr_Deduct_From_sal = 1
													BEGIN
														EXEC P0210_MONTHLY_LOAN_PAYMENT_INSERT 0,@Loan_Apr_ID,@Cmp_Id,@Salary_Tran_ID,@Loan_Inst_Amount,'',@To_Date,'','','','',@Loan_Interest_Amount,@Interest_Percent,@Interest_Subsidy_Amount
													END
											END
										END
									ELSE																																																																								
										BEGIN		
																		
											DECLARE @PAYMENT_TYPE AS VARCHAR(50)
											SET @PAYMENT_TYPE =''
											--SET		@Return_Amount = 0
											--SELECT  @Return_Amount = ISNULL(SUM(loan_Pay_Amount),0) FROM T0210_MONTHLY_LOAN_PAYMENT WHERE Loan_Apr_ID = @Loan_Apr_ID
											SELECT  @PAYMENT_TYPE = LOAN_PAYMENT_TYPE FROM T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) WHERE Loan_Apr_ID = @Loan_Apr_ID
										--	SET @Pending_Loan  = @Loan_Apr_Amount - @Return_Amount
											IF @Loan_Inst_Amount > @Pending_Loan AND @Pending_Loan >0 
												SET @Loan_Inst_Amount = @Pending_Loan
											ELSE IF @Pending_Loan =0 
												SET @Loan_Inst_Amount = 0
											
											if @IS_LOANDEDU = 0 
													Set @Loan_Inst_Amount = 0
													
											DECLARE @Request_status Varchar(10);	
											Declare @Loan_Inst_Amount_New Numeric(18,4)
											
											Set @Request_status = ''
											Set @Loan_Inst_Amount_New = 0
											
											Select @Loan_Inst_Amount_New = New_Install_Amount ,@Request_status = CRA.Request_status From T0090_Change_Request_Approval CRA WITH (NOLOCK)
												INNER JOIN T0100_Monthly_Loan_Skip_Approval MLS WITH (NOLOCK) ON CRA.Request_Apr_ID = MLS.Request_Apr_ID
											Where CRA.Emp_ID = @emp_id and CRA.Cmp_id = @Cmp_ID and Request_Type_id = 17	
												  and Loan_Month = Month(@Month_St_Date) and Loan_Year = YEAR(@Month_St_Date)
												  and MLS.Final_Approval = 1 and MLS.Loan_Apr_ID = @Loan_Apr_ID
												  
											if @Loan_Inst_Amount_New = 0 and @Request_status = 'A' 
												Begin
													Set @Loan_Inst_Amount = 0
												End
											
											IF @Is_FNF =1 
												BEGIN
													SET @Loan_Inst_Amount = @Pending_Loan
													EXEC P0210_MONTHLY_LOAN_PAYMENT_INSERT 0,@Loan_Apr_ID,@Cmp_Id,@Salary_Tran_ID,@Loan_Inst_Amount,'',@To_Date,'','','','',@Loan_Interest_Amount,@Interest_Percent,@Interest_Subsidy_Amount
												END
											ELSE IF (@Loan_Inst_Amount + @Loan_Interest_Amount) > 0 AND @Loan_apr_Deduct_From_sal = 1
												BEGIN	
													SELECT	@PAYMENT_TYPE =Loan_Payment_Type FROM T0210_Monthly_Loan_Payment WITH (NOLOCK)
													WHERE	Loan_apr_ID=@Loan_apr_ID AND cmp_id=@Cmp_ID  AND MONTH(Loan_Payment_Date)=MONTH(@To_Date)
															AND Year(Loan_Payment_Date)=Year(@To_Date)  
													
													
													If @SALARY_TRAN_ID > 0 
														SET @PAYMENT_TYPE = ''	
													IF @PAYMENT_TYPE ='Cash'
														BEGIN
															SELECT	@Return_Amount =SUM(isnull(Loan_Pay_Amount,0)) FROM T0210_Monthly_Loan_Payment WITH (NOLOCK)
															WHERE	Loan_apr_ID=@Loan_apr_ID AND cmp_id=@Cmp_ID  AND MONTH(Loan_Payment_Date)=MONTH(@To_Date)
																	AND Year(Loan_Payment_Date)=Year(@To_Date)  
													
															EXEC P0210_MONTHLY_LOAN_PAYMENT_INSERT 0,@Loan_Apr_ID,@Cmp_Id,@Salary_Tran_ID,@Return_Amount,'',@To_Date,'',@PAYMENT_TYPE,'','',@Loan_Interest_Amount,@Interest_Percent,@Interest_Subsidy_Amount
														END
													ELSE 
														BEGIN
															EXEC P0210_MONTHLY_LOAN_PAYMENT_INSERT 0,@Loan_Apr_ID,@Cmp_Id,@Salary_Tran_ID,@Loan_Inst_Amount,'',@To_Date,'','','','',@Loan_Interest_Amount,@Interest_Percent,@Interest_Subsidy_Amount,0	
														END					
												END	
										END
								END
						END		
						
												  
					SET @Interest_Previous_Perc = @Interest_Percent -- Added by Gadriwala Muslim 26122014
					FETCH NEXT FROM curLoan INTO @Loan_Id,@Loan_Apr_ID,@Loan_Apr_Amount,@Loan_Inst_Amount,@Loan_apr_Deduct_From_sal ,@Loan_Inst,@Loan_Apr_Date,@Deduction_Type,@Interest_Type,@Interest_Percent,@Loan_Interest_Amount,@Is_Interest_Subsidy_Limit,@Interest_Effective_date,@Interest_Recov_Perc,@Is_First_Ded_Priciple_Amt,@paid_Amount,@Installment_Start_Date ,@Subsidy_Amount,@is_Subisdy_Loan	
				END 			
			CLOSE curLoan
			DEALLOCATE curLoan					
		--END	
	RETURN



