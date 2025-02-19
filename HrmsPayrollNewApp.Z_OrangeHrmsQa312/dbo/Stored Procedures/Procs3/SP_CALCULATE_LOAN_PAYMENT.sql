
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CALCULATE_LOAN_PAYMENT]
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
	declare @manual_salary_period as numeric(18,0) -- Comment and added By rohit on 11022013

--Interest RECOVERY 
	DECLARE @Loan_Interest_Amount	 NUMERIC(27,2)
	DECLARE @Interest_Type			 VARCHAR(20)
	DECLARE @Loan_Apr_Date			 DATETIME 	

---Test Loan
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
	

	--SET @Interest_Type			='REDUCING'
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
	
	DECLARE @Round_Loan_Interest	NUMERIC(18,0)	----Ankit 24092015
	SET @Round_Loan_Interest = 0
	SELECT @Round_Loan_Interest = Setting_Value FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and Setting_Name='Round Loan Interest Amount'
	if @Is_LoanDedu = 1 
		BEGIN		
			SET @Loan_Payment_Id = 0
			DECLARE curLoan CURSOR FOR
			
				SELECT LA.loan_id,La.Loan_Apr_ID,
						(case when la.Paid_Amount <> 0 AND la.Loan_Apr_Intrest_Type='FIX' then isnull(Loan_Apr_Amount,0) + isnull(la.Paid_Amount,0) ELSE Loan_Apr_Amount End) as Loan_Apr_Amount,
						--Loan_Apr_Amount,
						case when isnull(Qry.Installment_Amount,0) = 0 or Qry3.Is_Interest_Subsidy_Limit = 0 then LA.Loan_Apr_Installment_Amount else Qry.Installment_Amount end,Loan_apr_Deduct_From_sal
						,Loan_apr_no_of_installment ,Loan_Apr_Date,la.Deduction_Type,la.Loan_Apr_Intrest_Type,case when ISNULL(Qry2.Interest_Per_Yearly,0) = 0 or Qry3.Is_Interest_Subsidy_Limit = 0   then La.Loan_Apr_Intrest_Per else Qry2.Interest_Per_Yearly end,isnull(LA.Loan_Apr_Intrest_Amount,0),Isnull(Qry3.Is_Interest_Subsidy_Limit,0),Isnull(Qry2.Effective_date,''),ISNULL(La.Subsidy_Recover_Perc,0),ISNULL(Qry3.Is_Principal_First_than_Int,0),la.Paid_Amount
						,Installment_Start_Date
						,La.Subsidy_Amount,Lm.Is_Subsidy_Loan
				FROM	T0120_loan_approval la WITH (NOLOCK) INNER JOIN T0040_LOAN_MASTER LM WITH (NOLOCK) ON la.Cmp_ID=LM.Cmp_ID AND la.Loan_ID = LM.Loan_ID
						left outer join  -- Changed by Gadriwala Muslim 25122014 for Interest Subsidy
							(
								select Installment_Amount,Loan_Apr_ID from dbo.T0120_Installment_Amount_Details  WITH (NOLOCK)
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
						inner join 
						  (
								select Loan_ID,Is_Interest_Subsidy_Limit,Is_Principal_First_than_Int from T0040_LOAN_MASTER WITH (NOLOCK) where Cmp_ID = @CMP_ID
						  ) qry3 on Qry3.Loan_ID = LA.Loan_ID 
				WHERE	emp_id = @emp_id and la.Cmp_ID = @Cmp_ID
				 		and Loan_Apr_pending_amount >0 	
						--and Isnull(Installment_Start_Date,Loan_Apr_Date) <= @To_Date --Commented by Nimesh on 28-Jul-2016 (To calculate the interest only if installment start date is later.)
						and Loan_Apr_Date <= @To_Date
						and Loan_Apr_Status='A'
						and (Loan_Apr_Deduct_From_sal = 1 or Loan_Apr_Deduct_From_sal = 0 or @Is_FNF =1)  AND IsNull(LM.Is_GPF,0)=0 And ISNULL(LM.Is_Intrest_Amount_As_Perquisite_IT,0) = 0
						--order by La.Loan_apr_ID
					
			UNION ALL
				SELECT LA.loan_id,La.Loan_Apr_ID,
						--(case when la.Paid_Amount <> 0 AND la.Loan_Apr_Intrest_Type='FIX' then isnull(Loan_Apr_Amount,0) + isnull(la.Paid_Amount,0) ELSE Loan_Apr_Amount End) as Loan_Apr_Amount,
						((case when la.Paid_Amount <> 0 AND la.Loan_Apr_Intrest_Type='FIX' then isnull(Loan_Apr_Amount,0) + isnull(la.Paid_Amount,0) ELSE Loan_Apr_Amount End) + IsNull(la.CF_Loan_Amt,0)) as Loan_Apr_Amount,
						--Loan_Apr_Amount,
						case when isnull(Qry.Installment_Amount,0) = 0 or Qry3.Is_Interest_Subsidy_Limit = 0 then LA.Loan_Apr_Installment_Amount else Qry.Installment_Amount end,Loan_apr_Deduct_From_sal
						,Loan_apr_no_of_installment ,Loan_Apr_Date,la.Deduction_Type,la.Loan_Apr_Intrest_Type,case when ISNULL(Qry2.Interest_Per_Yearly,0) = 0 or Qry3.Is_Interest_Subsidy_Limit = 0   then La.Loan_Apr_Intrest_Per else Qry2.Interest_Per_Yearly end,isnull(LA.Loan_Apr_Intrest_Amount,0),Isnull(Qry3.Is_Interest_Subsidy_Limit,0),Isnull(Qry2.Effective_date,''),ISNULL(La.Subsidy_Recover_Perc,0),ISNULL(Qry3.Is_Principal_First_than_Int,0),la.Paid_Amount
						,Installment_Start_Date
						,La.Subsidy_Amount,qry3.Is_Subsidy_Loan
				FROM	T0120_loan_approval la WITH (NOLOCK)  
						left outer join  -- Changed by Gadriwala Muslim 25122014 for Interest Subsidy
							(
									select Installment_Amount,Loan_Apr_ID from dbo.T0120_Installment_Amount_Details LD WITH (NOLOCK) INNER JOIN T0040_LOAN_MASTER LM WITH (NOLOCK) ON LD.Loan_id=LM.Loan_ID AND LD.cmp_ID=LM.Cmp_ID
									where Effective_date = (
																select MAX(Effective_date) from  dbo.T0120_Installment_Amount_Details WITH (NOLOCK)
																where Effective_date <= @To_Date and Emp_ID = @Emp_ID
														   )
												and Emp_ID = @Emp_ID AND LM.Is_GPF = 0
						
							)Qry on Qry.Loan_Apr_ID = LA.Loan_Apr_ID 
				
						Left outer join
							(
								select Interest_Per_Yearly,Loan_Apr_Id,Effective_date from	[dbo].[T0120_Interest_Yearly_Details] WITH (NOLOCK)
								where Effective_date =
									(
										select MAX(Effective_date) from  [dbo].[T0120_Interest_Yearly_Details] WITH (NOLOCK)
														where Effective_date <= @To_Date and Emp_ID = @Emp_ID
									)
									and Emp_ID = @Emp_ID
				
							) Qry2 on Qry2.Loan_Apr_ID = LA.Loan_Apr_ID  
						inner join 
							(
								select Loan_ID,Is_Interest_Subsidy_Limit,Is_Principal_First_than_Int,is_subsidy_loan from T0040_LOAN_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID 
					
							) qry3 on Qry3.Loan_ID = LA.Loan_ID 			  
			 WHERE	emp_id = @Emp_ID and la.Cmp_ID = @Cmp_ID
 					and Loan_Apr_pending_amount >0 	and Loan_Apr_Status='A'
					--and Isnull(Installment_Start_Date,Loan_Apr_Date) <= @To_Date --Commented by Nimesh on 28-Jul-2016 (To calculate the interest only if installment start date is later.)
					AND Loan_Apr_Date < @To_Date
					and (Loan_Apr_Deduct_From_sal = 1 or Loan_Apr_Deduct_From_sal = 0 or @Is_FNF =1)
					AND la.Loan_Apr_ID = (SELECT MAX(la1.Loan_Apr_ID) 
											FROM T0120_LOAN_APPROVAL LA1 WITH (NOLOCK) INNER JOIN T0040_LOAN_MASTER LM WITH (NOLOCK) ON la1.Cmp_ID=LM.Cmp_ID AND LA1.Loan_ID=LM.Loan_ID 
											WHERE IsNull(LM.Is_GPF,0)=1 AND LA1.Emp_ID=la.Emp_ID)
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
						
						Declare @lcount int =0

					--Hardik for Interest calculation 15/05/2012
					declare @Temp_Month_St_Date as datetime
					declare @Temp_Month_End_Date as datetime
					Declare @Temp_TotLoan_Closing As Numeric(22,0)
					Declare @Temp_Loan_Closing As Numeric(22,0)
					Declare @Pre_Loan_Interest_Amount As Numeric(22,2)
					Set @Pre_Loan_Interest_Amount = 0

					/* Comment by nilesh patel on 06012016 after discussion with hardik bhai 
					If Not EXISTS (Select 1 From T0210_Monthly_Loan_payment where Loan_Apr_ID = @Loan_Apr_ID)
						BEGIN
							declare curLoantest cursor for
							Select @From_Date,@To_Date
						END
					Else
						BEGIN
							declare curLoantest cursor for
								Select Month_St_Date,Month_End_Date from T0200_MONTHLY_SALARY 
								where Month_End_Date  between (select ISNULL( max(Month_End_Date),@From_Date) 
																from T0200_MONTHLY_SALARY where  Emp_ID = @emp_id and Loan_Amount > 0) and @To_Date 
								and Emp_ID = @emp_id And Loan_Amount = 0	
						END
					open curLoantest */
					
					set @Month_St_Date = @From_Date  -- Added by Gadriwala Muslim 26122014
					set @Month_End_Date = @To_Date -- Added by Gadriwala Muslim 26122014

			
					--Added by nilesh patel for Salary is exists and again generate salary 19122017
					IF NOT EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE MONTH(MONTH_END_DATE) = MONTH(@MONTH_ST_DATE) AND YEAR(MONTH_END_DATE) = YEAR(@MONTH_ST_DATE))
						BEGIN
			
							DECLARE CURLOANTEST CURSOR FOR
							SELECT	MONTH_ST_DATE,MONTH_END_DATE 
							FROM	T0200_MONTHLY_SALARY WITH (NOLOCK)
							WHERE	MONTH_END_DATE  BETWEEN (SELECT ISNULL( MAX(MONTH_END_DATE),@FROM_DATE) 
																FROM	T0200_MONTHLY_SALARY WITH (NOLOCK)
																WHERE  EMP_ID = @EMP_ID AND LOAN_AMOUNT = 0 AND MONTH_END_DATE > @TO_DATE) --AND LOAN_AMOUNT > 0 COMMENT BY NILESH ON 19122017 FOR PREVIOUSE MONTH SALARY IS NOT EXISTS
									AND @TO_DATE AND EMP_ID = @EMP_ID AND LOAN_AMOUNT = 0	
							OPEN CURLOANTEST		
							FETCH NEXT FROM CURLOANTEST INTO @TEMP_MONTH_ST_DATE,@TEMP_MONTH_END_DATE
							WHILE @@FETCH_STATUS = 0
								BEGIN		
								


									SELECT	@BRANCH_ID_TEMP = BRANCH_ID FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN     
											(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID, EMP_ID FROM T0095_INCREMENT  WITH (NOLOCK)   --CHANGED BY HARDIK 09/09/2014 FOR SAME DATE INCREMENT
									WHERE	INCREMENT_EFFECTIVE_DATE <= @TEMP_MONTH_END_DATE AND CMP_ID = @CMP_ID GROUP BY EMP_ID) QRY ON    
											I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID WHERE I.EMP_ID = @EMP_ID   --CHANGED BY HARDIK 09/09/2014 FOR SAME DATE INCREMENT
					  
									SELECT	@SAL_ST_DATE = SAL_ST_DATE 
									FROM	T0040_GENERAL_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND BRANCH_ID = @BRANCH_ID_TEMP    
											AND FOR_DATE = ( SELECT MAX(FOR_DATE) FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE FOR_DATE <=@TEMP_MONTH_END_DATE AND BRANCH_ID = @BRANCH_ID_TEMP AND CMP_ID = @CMP_ID)    

									

									IF ISNULL(@SAL_ST_DATE,'') = ''    
										  BEGIN    
											   SET @MONTH_ST_DATE  = @MONTH_ST_DATE     
											   SET @MONTH_END_DATE = @MONTH_END_DATE    
										  END     
									 ELSE IF DAY(@SAL_ST_DATE) =1 --AND MONTH(@SAL_ST_DATE)= 1    
										  BEGIN    
											   SET @MONTH_ST_DATE  = @SAL_ST_DATE     
											   SET @MONTH_END_DATE = DATEADD(D, -1, DATEADD(MM, 1, @MONTH_ST_DATE))    
										  END     
									 ELSE IF @SAL_ST_DATE <> ''  AND DAY(@SAL_ST_DATE) > 1   
										  BEGIN    
											   SET @SAL_ST_DATE =  CAST(CAST(DAY(@SAL_ST_DATE)AS VARCHAR(5)) + '-' + CAST(DATENAME(MM,@TEMP_MONTH_ST_DATE) AS VARCHAR(10)) + '-' +  CAST(YEAR(DATEADD(M,-1,@TEMP_MONTH_ST_DATE) )AS VARCHAR(10)) AS SMALLDATETIME)    
											   SET @SAL_END_DATE = DATEADD(D,-1,DATEADD(M,1,@SAL_ST_DATE)) 

											   SET @MONTH_ST_DATE = @SAL_ST_DATE
											   SET @MONTH_END_DATE = @SAL_END_DATE    
										  END

									SET @MONTHDAYS = DATEDIFF(D,@MONTH_ST_DATE,@MONTH_END_DATE)+1

									
							
									SELECT @TEMP_TOTLOAN_CLOSING = ISNULL(SUM(LOAN_PAY_AMOUNT),0) FROM T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) WHERE 
										CMP_ID = @CMP_ID AND LOAN_APR_ID =@LOAN_APR_ID AND LOAN_PAYMENT_DATE <=  @TEMP_MONTH_END_DATE
									
									SET @TEMP_LOAN_CLOSING = @LOAN_APR_AMOUNT - @TEMP_TOTLOAN_CLOSING
								
									SET @LOANDAYS = DATEDIFF(D,@LOAN_APR_DATE,@TEMP_MONTH_END_DATE) + 1

		

									IF @INTEREST_TYPE = 'REDUCING'
										BEGIN
											IF (MONTH(@LOAN_APR_DATE) = MONTH(@TEMP_MONTH_ST_DATE) AND YEAR(@LOAN_APR_DATE) = YEAR(@TEMP_MONTH_ST_DATE)) 
												BEGIN											
													SET @PRE_LOAN_INTEREST_AMOUNT = @PRE_LOAN_INTEREST_AMOUNT + ((((@TEMP_LOAN_CLOSING * @INTEREST_PERCENT / 100)/12)/@MONTHDAYS)* @LOANDAYS)
												END
											ELSE
												BEGIN
													IF @IS_FNF =1 -- ADDED BY NILESH PATEL FOR INETEREST CALCULATION BASE ON FNF DAYS
														SET @LOAN_INTEREST_AMOUNT = ((ISNULL(@PRE_LOAN_INTEREST_AMOUNT + ((@TEMP_LOAN_CLOSING * @INTEREST_PERCENT / 100)/12),0))* @MONTHDAYS)/DAY(DATEADD(DD,-1,DATEADD(MM,DATEDIFF(MM,-1,@MONTH_END_DATE),0))) 
													ELSE
														IF @LOAN_APR_DATE <= @TEMP_MONTH_END_DATE --ADDED BY HARDIK 07/03/2016 AS 2 SAME LOAN APPROVAL HAS PROBLEM, WHERE 1 IS COMPLETED AND 1 IS NEWLY STARTED 
															BEGIN
																SET @PRE_LOAN_INTEREST_AMOUNT = @PRE_LOAN_INTEREST_AMOUNT + ((@TEMP_LOAN_CLOSING * @INTEREST_PERCENT / 100)/12)
															END
												END
										END
									ELSE
										BEGIN
											IF (MONTH(@LOAN_APR_DATE) = MONTH(@TEMP_MONTH_ST_DATE) AND YEAR(@LOAN_APR_DATE) = YEAR(@TEMP_MONTH_ST_DATE)) 
												BEGIN
													SET @PRE_LOAN_INTEREST_AMOUNT = @PRE_LOAN_INTEREST_AMOUNT + ((((@LOAN_APR_AMOUNT * @INTEREST_PERCENT / 100)/12)/@MONTHDAYS)* @LOANDAYS)
												END
											ELSE
												BEGIN
													IF @IS_FNF =1
														SET @LOAN_INTEREST_AMOUNT = ((ISNULL(@PRE_LOAN_INTEREST_AMOUNT + ((@LOAN_APR_AMOUNT * @INTEREST_PERCENT / 100)/12),0))*@MONTHDAYS)/DAY(DATEADD(DD,-1,DATEADD(MM,DATEDIFF(MM,-1,@MONTH_END_DATE),0))) 
													ELSE
														IF @LOAN_APR_DATE <= @TEMP_MONTH_END_DATE --ADDED BY HARDIK 07/03/2016 AS 2 SAME LOAN APPROVAL HAS PROBLEM, WHERE 1 IS COMPLETED AND 1 IS NEWLY STARTED 
															BEGIN
																SET @PRE_LOAN_INTEREST_AMOUNT = @PRE_LOAN_INTEREST_AMOUNT + ((@LOAN_APR_AMOUNT * @INTEREST_PERCENT / 100)/12)
															END
												END
										END

										set @Lcount=@Lcount+1

									FETCH NEXT FROM CURLOANTEST INTO @TEMP_MONTH_ST_DATE,@TEMP_MONTH_END_DATE
								END 			
							CLOSE CURLOANTEST
							DEALLOCATE CURLOANTEST	
					
						END	
					--Added by nilesh patel for Salary is exists and again generate salary 19122017
					

					
					------------end Interest Calculation
					--set @Month_St_Date = @From_Date  -- Added by Gadriwala Muslim 26122014
					--set @Month_End_Date = @To_Date -- Added by Gadriwala Muslim 26122014

					DECLARE @Loan_Closing as numeric(18,0)
					SET @Loan_Closing = @Loan_Apr_Amount - @TotLoan_Closing
				  
					Select @Branch_ID_Temp = Branch_ID,@desig_ID = Desig_Id From T0095_Increment I WITH (NOLOCK) inner join     
					   (select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment  WITH (NOLOCK)   --Changed by Hardik 09/09/2014 for Same Date Increment
					   where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
					   I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID = @Emp_ID  --Changed by Hardik 09/09/2014 for Same Date Increment
	  
					Select @Sal_St_Date = Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0)
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
							   --set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,@From_Date) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
							   --set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 

							   --Set @Month_St_Date = @Sal_St_Date
							   --Set @Month_End_Date = @Sal_End_Date    
								if @manual_salary_period = 0 
									begin
										SET @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,0,@Month_St_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,0,@Month_St_Date) )as varchar(10)) as smalldatetime)    
										set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 

										Set @Month_St_Date = @Sal_St_Date
										Set @Month_End_Date = @Sal_End_Date    
								  end
								else
									begin
										select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@To_Date) and YEAR=year(@To_Date)

										SET @Month_St_Date = @Sal_St_Date
										SET @Month_End_Date = @Sal_End_Date 
									end   

						  end





					Set @MonthDays = DATEDIFF(d,@Month_St_Date,@Month_End_Date)+1
					
					Set @LoanDays = DATEDIFF(d,@Loan_Apr_Date,@Month_End_Date) --+ 1 comment by ronakk 03052023
					


					If @Interest_Type = 'Reducing'
						Begin							
							If (Month(@Loan_Apr_Date) = MONTH(@Month_St_Date) And YEAR(@Loan_Apr_Date) = YEAR(@Month_St_Date) and @LoanDays<31) or (Month(@Loan_Apr_Date) = MONTH(@Month_End_Date) And YEAR(@Loan_Apr_Date) = YEAR(@Month_End_Date))  --or (@lcount=0)
								Begin																		
									Set @Loan_Interest_Amount = isnull(@Pre_Loan_Interest_Amount + ((((@Loan_Closing * @Interest_Percent / 100)/12)/@MonthDays)* @LoanDays),0)
									--select @Loan_Interest_Amount, @Pre_Loan_Interest_Amount, @Loan_Closing, @Interest_Percent,@MonthDays,@LoanDays
								End
							Else
								Begin									
									if @Is_FNF =1 
										Set @Loan_Interest_Amount = ((isnull(@Pre_Loan_Interest_Amount + ((@Loan_Closing * @Interest_Percent / 100)/12),0))*@MonthDays)/DAY(DATEADD(DD,-1,DATEADD(MM,DATEDIFF(MM,-1,@Month_End_Date),0))) 
									Else
										--Set @Loan_Interest_Amount = isnull(@Pre_Loan_Interest_Amount + ((@Loan_Closing * @Interest_Percent / 100)/12),0)
										Set @Loan_Interest_Amount = isnull(((@Loan_Closing * @Interest_Percent / 100)/12),0)									
								End
								
						End
					Else
						Begin
							If( Month(@Loan_Apr_Date) = MONTH(@Month_St_Date) And YEAR(@Loan_Apr_Date) = YEAR(@Month_St_Date) and @LoanDays<31 )  or (Month(@Loan_Apr_Date) = MONTH(@Month_End_Date) And YEAR(@Loan_Apr_Date) = YEAR(@Month_End_Date)) --or (@lcount=0)
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
						
						
					set @lcount = @lcount + 1 
					
					--Begin
					--	If @Interest_Type = 'Fix'
					--		Set @Loan_Interest_Amount = @Pre_Loan_Interest_Amount + (Isnull(@Loan_Apr_Amount,0) * Isnull(@Interest_Percent,0) / 100)
					--	Else
					--		Set @Loan_Interest_Amount = @Pre_Loan_Interest_Amount + (Isnull(@Loan_Closing,0) * Isnull(@Interest_Percent,0) / 100)
					--End
				
					If @Loan_Interest_Amount is null
						set @Loan_Interest_Amount = 0
					
					If Isnull(@Round_Loan_Interest,0)=1
						Set @Loan_Interest_Amount = Round(@Loan_Interest_Amount,0)

					-- Added by nilesh patel for change request for skip installment 05092016
					DECLARE @Request_status Varchar(10);	
					Declare @Loan_Inst_Amount_New Numeric(18,4)
					
					Set @Request_status = ''
					Set @Loan_Inst_Amount_New = 0
					
					Select @Loan_Inst_Amount_New = New_Install_Amount ,@Request_status = CRA.Request_status From T0090_Change_Request_Approval CRA WITH (NOLOCK)
						INNER JOIN T0100_Monthly_Loan_Skip_Approval MLS WITH (NOLOCK) ON CRA.Request_Apr_ID = MLS.Request_Apr_ID
					Where CRA.Emp_ID = @emp_id and CRA.Cmp_id = @Cmp_ID and Request_Type_id = 17	
						  and Loan_Month = Month(@Month_St_Date) and Loan_Year = YEAR(@Month_St_Date)
						  and MLS.Final_Approval = 1 and MLS.Loan_Apr_ID = @Loan_Apr_ID 
					
					-- Added by nilesh patel for change request for skip installment 05092016
					if @Loan_Inst_Amount_New >= 0 and @Request_status = 'A'
						Begin
							--Set @Loan_Inst_Amount = @Loan_Inst_Amount_New
							if @Loan_Inst_Amount_New = 0
								Begin
									Set @Loan_Interest_Amount = 0
								End
							Else
								Begin
									if @Loan_Interest_Amount > @Loan_Inst_Amount_New
										BEGIN
											Set @Loan_Inst_Amount = 0
											Set @Loan_Interest_Amount = 0
										End
									Else
										Begin
											--Set @Loan_Inst_Amount = @Loan_Inst_Amount - @Loan_Interest_Amount
											-- Deduct Loan Intrest Amount from Installment For Softshift Yard -- 11-01-2019 -- After Discussion with Hardikbhai
											Set @Loan_Inst_Amount = @Loan_Inst_Amount_New - Isnull(@Loan_Interest_Amount,0)
										End
								End 
						End
					Else
						Begin
							
							If @MANUAL_LOAN > 0 
								Set @Loan_Inst_Amount =  @MANUAL_LOAN					
							ELSE IF @Installment_Start_Date > @Month_End_Date 
								Set @Loan_Inst_Amount =  @Loan_Interest_Amount
							
							if @Is_First_Ded_Priciple_Amt = 1 --Added by nilesh patel on 16072015
								Begin
									Set @Loan_Inst_Amount = @Loan_Inst_Amount
								End
							Else
								Begin
									Set @Loan_Inst_Amount = @Loan_Inst_Amount - @Loan_Interest_Amount
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
					
				  
				  		-- Added Gadriwala Muslim 26122014 -Start				
					If @Is_Interest_Subsidy_Limit = 1 
						BEGIN					
							select @SubSidy_Max_Limit = isnull(Subsidy_Max_Limit,0) from [dbo].[T0040_Subsidy_Max_Limit_Design_Wise] WITH (NOLOCK) where Design_ID = @Desig_ID and Loan_ID = @Loan_Id
							If day(@Interest_Effective_date) > 1
								set @interest_Effective_Days = day(@Interest_Effective_date) 
						--	set @Interest_Recover_Amount = ((@Pending_Loan + @Loan_Inst_Amount) * (@Interest_Recover_Perc/100))/12
						
							if @Interest_Previous_Perc > 0  and @interest_Effective_Days > 1 and @Interest_Previous_Perc <> @Interest_Percent
								begin
									set @Interest_Subsidy_Amount = (@Pending_Loan * ((@Interest_Previous_Perc - @Interest_Recov_Perc)/100))/365 * (@interest_Effective_Days -1)
									set @Interest_Subsidy_Amount =  @Interest_Subsidy_Amount +  (@Pending_Loan * ((@Interest_Percent - @Interest_Recov_Perc)/100))/365 * (@MonthDays - (@interest_Effective_Days - 1) )
								end
							else
								begin
									SET @Interest_Subsidy_Amount = (@Pending_Loan  * ((@Interest_Percent - @Interest_Recov_Perc)/100))/365 * @MonthDays
								end								
						
							 if @SubSidy_Max_Limit > 0 
								begin
									if @SubSidy_Max_Limit < @Interest_Subsidy_Amount 
										set @Interest_Subsidy_Amount = @SubSidy_Max_Limit	
								end
						END
					ELSE
						BEGIN
							SET @Interest_Subsidy_Amount = 0
						END
					-- Added Gadriwala Muslim 26122014 -End
					
					--IF @To_Date < @Installment_Start_Date AND @MANUAL_LOAN = 0
					--	Set @Loan_Inst_Amount = @Loan_Interest_Amount

					
					
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
											--ELSE IF @Loan_Inst_Amount > 0 AND @Loan_apr_Deduct_From_sal = 0
											--	BEGIN 
											    
											--	   IF @PAYMENT_TYPE ='Cash'
											--		   BEGIN
											--		       SELECT @PAYMENT_TYPE =Loan_Payment_Type FROM T0210_Monthly_Loan_Payment 
											--			WHERE Loan_apr_ID=@Loan_apr_ID AND cmp_id=@Cmp_ID  AND MONTH(Loan_Payment_Date)=MONTH(@To_Date)
											--			AND Year(Loan_Payment_Date)=Year(@To_Date) 
												  
											--			SELECT @Return_Amount =SUM(isnull(Loan_Pay_Amount,0)) FROM T0210_Monthly_Loan_Payment 
											--			WHERE Loan_apr_ID=@Loan_apr_ID AND cmp_id=@Cmp_ID  AND MONTH(Loan_Payment_Date)=MONTH(@To_Date)
											--			AND Year(Loan_Payment_Date)=Year(@To_Date) 
													 
													
											--			EXEC P0210_MONTHLY_LOAN_PAYMENT_INSERT 0,@Loan_Apr_ID,@Cmp_Id,@Salary_Tran_ID,@Return_Amount,'',@To_Date,'',@PAYMENT_TYPE,'',''	
											--		   END	
													 -- Else 
													 --    BEGIN
												
														--	--EXEC P0210_MONTHLY_LOAN_PAYMENT_INSERT 0,@Loan_Apr_ID,@Cmp_Id,@Salary_Tran_ID,@Loan_Inst_Amount,'',@To_Date,'','','',''	
														--END					
											  
												--END
										END
								END
						END		
						
						 if (isnull(@is_Subisdy_Loan,0) = 1) and ( @Pending_Loan - @Loan_Inst_Amount <= @Subsidy_Amount)
						  begin
						  
						     set @temp_subsidy_amount = @Pending_Loan - @Loan_Inst_Amount
						    -- EXEC P0210_MONTHLY_LOAN_PAYMENT_INSERT 0,@Loan_Apr_ID,@Cmp_Id,@Salary_Tran_ID,@Loan_Inst_Amount,'',@To_Date,'','','','',0,0,0,0,@temp_subsidy_amount -- For Update Subsidy flag on 26072016	
						     update T0210_MONTHLY_LOAN_PAYMENT
						     set Subsidy_Amount = @temp_subsidy_amount
						     where Loan_Apr_ID =@Loan_Apr_ID and Temp_Sal_Tran_ID = @Salary_Tran_ID and Loan_Payment_Date = @To_Date
						   --select * from  T0210_MONTHLY_LOAN_PAYMENT where  Loan_Apr_ID =@Loan_Apr_ID --and Sal_Tran_ID = @Salary_Tran_ID and Loan_Payment_Date = @To_Date
						  end
						  
					SET @Interest_Previous_Perc = @Interest_Percent -- Added by Gadriwala Muslim 26122014
					FETCH NEXT FROM curLoan INTO @Loan_Id,@Loan_Apr_ID,@Loan_Apr_Amount,@Loan_Inst_Amount,@Loan_apr_Deduct_From_sal ,@Loan_Inst,@Loan_Apr_Date,@Deduction_Type,@Interest_Type,@Interest_Percent,@Loan_Interest_Amount,@Is_Interest_Subsidy_Limit,@Interest_Effective_date,@Interest_Recov_Perc,@Is_First_Ded_Priciple_Amt,@paid_Amount,@Installment_Start_Date ,@Subsidy_Amount,@is_Subisdy_Loan	
				END 			
			CLOSE curLoan
			DEALLOCATE curLoan					
		END	
	RETURN



