
CREATE PROCEDURE [dbo].[GET_EMP_PERQUISITES]
	@Cmp_id numeric(18,0),
	@Emp_id numeric(18,0),
	@Fin_Yr nvarchar(20),	
	@Gross_Sal numeric(18,2),
	@Deduction numeric(18,2),
	@Per_Total_Amount numeric(18,2) output
AS
BEGIN
	
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
	Declare @tran_id_rfa as numeric
	Declare @Acc  as tinyint
	Declare	@Leased as tinyint
	Declare	@Acc_from as datetime
	Declare	@Acc_to as datetime
	Declare	@Leased_from as datetime
	Declare	@Leased_to as datetime
	Declare @Acc_Amt as numeric(18,2)
	Declare @Furnish as numeric(18,2)
	Declare @Acc_per as numeric(18,2)
	Declare @leased_Per as numeric(18,2)
	Declare @Gross_Sal_Per_amount as numeric(18,2)
	Declare @Acc_days as numeric(18,0)
	Declare @Leased_days as numeric(18,0)
	declare @dedu_per_day as numeric(18,2)
	
	Declare @Date_Of_Join		datetime
	Declare @Left_date			datetime
	Declare @is_Left	varchar(1)
	Declare @year_days numeric(18,0)
	
	Set @tran_id_rfa = 0 
	Set @Acc = 0 
	Set @Leased = 0 
	Set @Acc_Amt = 0 
	Set @Furnish = 0 
	Set @Per_Total_Amount = 0
	set @Gross_Sal_Per_amount  = 0
	set @Acc_per = 0
	set @leased_Per = 0
	set @Acc_days = 0
	set @Leased_days = 0
	set @dedu_per_day = 0
	set @is_Left = 'N'
	set @year_days = 365
	set @Date_Of_Join = NULL	
	set @Left_date = NULL
	
	--added By Jimit 15052018-- WCL query year days are greater than 365 
	DECLARE @Fin_Start_Date DATETIME
	DECLARE @Fin_End_Date DATETIME
	
	
	SET @Fin_Start_Date = cast('01-Apr-' + Left(@Fin_Yr,4) as datetime)
	SET @Fin_End_Date = cast('31-Mar-' + Right(@Fin_Yr,4) as datetime)
	


	if Exists(Select Tran_id from T0240_Perquisites_Employee WITH (NOLOCK) where Emp_id = @Emp_id and Financial_Year = @Fin_Yr)
		Begin
		
			select	@Date_Of_Join = Date_Of_Join, @Left_date = isnull(Emp_Left_Date,NULL), @is_Left = isnull(Emp_Left,'N')  
			From	T0080_emp_Master WITH (NOLOCK) WHERE Emp_ID = @Emp_ID 
			
			IF NOT ISNULL(@Left_date, @Fin_End_Date+1) BETWEEN @Fin_Start_Date AND @Fin_End_Date
				SET @is_Left = 'N'
				
			Declare @start_date as datetime 
			--set @start_date = cast('01-Apr' + Left(@Fin_Yr,4) as datetime)
			set @start_date = @Fin_Start_Date
						
			if @is_Left = 'Y' 
				begin
					if @start_date > @Date_Of_Join  
						begin
							set @year_days = DATEDIFF(dd,@start_date ,@Left_date)	+ 1
						end
					else
						begin
							set @year_days = DATEDIFF(dd,@Date_Of_Join ,@Left_date)	+ 1
						end					
				end
			else
				begin
					if @start_date > @Date_Of_Join 
						begin
							set @year_days = DATEDIFF(dd,@start_date ,@Fin_End_Date) + 1
						end
					else
						begin
								set @year_days = DATEDIFF(dd,@Date_Of_Join ,@Fin_End_Date) + 1
						end
				end
				

			if @Deduction > 0 
				set @dedu_per_day = @Deduction/@year_days
			
			
			
			SELECT @tran_id_rfa= tran_id, @ACC= ON_RENT, @LEASED=CMP_QUARTER,@ACC_FROM= ON_RENT_FROM,@ACC_TO= ON_RENT_TO, 
						@LEASED_FROM = CMP_QUARTER_FROM, @LEASED_TO = CMP_QUARTER_TO , @Acc_per = On_Rent_Per , @leased_Per = Cmp_Quater_Per
						,@Furnish = Total_Furnish_Amt
			FROM  T0240_PERQUISITES_EMPLOYEE WITH (NOLOCK) where Emp_id = @Emp_id and Financial_Year = @Fin_Yr
			
			 
			
			if @Furnish > 0
				set @Furnish = round(@Furnish * 10/100,0)
			
			

			if @Acc = 1 and @LEASED = 1
				begin
					-- check left date condition start
					if @is_Left = 'Y'
						begin
							if @ACC_TO > @LEASED_TO
								begin
									if @Acc_to > @Left_date
										begin
											set @Acc_to = 	@Left_date
										end
								end
							else
								begin
									if @LEASED_TO > @Left_date
										begin
											set @LEASED_TO = 	@Left_date
										end
								end
						end
					-- check left date condition end
					
					set @Acc_days = DATEDIFF(d,@ACC_FROM,@ACC_TO) + 1
					set @Leased_days = DATEDIFF(d,@LEASED_FROM,@LEASED_TO) + 1
					
					
										
					SELECT @ACC_AMT = SUM(AMOUNT)  FROM T0250_PERQUISITES_EMPLOYEE_MONTHLY_RENT WITH (NOLOCK) WHERE PERQ_TRAN_ID = @TRAN_ID_RFA
					
					SET @GROSS_SAL_PER_AMOUNT = (((@GROSS_SAL/@year_days * @Leased_days) - (@dedu_per_day * @Leased_days)) * @leased_Per)/100
					
					IF @GROSS_SAL_PER_AMOUNT < @Acc_Amt
						begin
							set @Per_Total_Amount = @Gross_Sal_Per_amount 
						end
					Else
						begin	
							set @Per_Total_Amount = @Acc_Amt 
						end
					
				-----------------------		
					set @Per_Total_Amount = @Per_Total_Amount + ((((@Gross_Sal/@year_days * @Acc_days) - (@dedu_per_day * @Acc_days)) * @ACC_PER)/100)  + @Furnish
					
				end
			else if @Acc = 1 -- Accommodation Provided 
				begin	
					-- check left date condition start
					if @is_Left = 'Y'
						begin
							if @Acc_to > @Left_date
								begin
									set @Acc_to = 	@Left_date
								end														
						end
					-- check left date condition end
					
					set @Acc_days = DATEDIFF(d,@ACC_FROM,@ACC_TO) + 1
				
					set @Per_Total_Amount = (((@Gross_Sal/@year_days * @Acc_days) - (@dedu_per_day * @Acc_days)) * @ACC_PER)/100 + @Furnish					
				end
			
			else if @LEASED = 1  -- Leased Accommodation 
				begin
					-- check left date condition start
					if @is_Left = 'Y'
						begin
							if @LEASED_TO > @Left_date
								begin
									set @LEASED_TO = @Left_date
								end								
						end
					-- check left date condition end
				
					IF (SELECT Count(Month)  FROM T0250_PERQUISITES_EMPLOYEE_MONTHLY_RENT WITH (NOLOCK) WHERE PERQ_TRAN_ID = @TRAN_ID_RFA And Amount>0)<>12
						BEGIN	
							If OBJECT_ID ('tempdb..#Monthly_table') Is Not Null
								Drop Table #Monthly_table
								
							CREATE TABLE #Monthly_table
							(
								Cmp_Id Int,
								Emp_Id Numeric(18,0),
								Month_Year Varchar(25),
								[Month] int,
								[Year] int,
								Lable_Name Varchar(100), 
								Amount Numeric(18,2)
							)
							--print @Fin_Start_Date--mansi
							--print @Fin_End_Date--mansi
							--print @Emp_id --mansi
							exec SP_RPT_YEARLY_SALARY_GET_INCOME_TAX @Cmp_ID=@Cmp_id,@From_Date=@Fin_Start_Date,@To_Date=@Fin_End_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,
							@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=@Emp_id,@Constraint='',@Report_Call='RENT FREE',@With_Ctc='1',@Publish_Flag=0

							--Select * from #Monthly_table MT Inner Join T0250_PERQUISITES_EMPLOYEE_MONTHLY_RENT PEM On MT.Month=PEM.Month and MT.Year=PEM.Year 
							--Where  MT.Emp_Id = @Emp_id and PEM.Perq_Tran_Id=@TRAN_ID_RFA And PEM.Amount>0

							Select @GROSS_SAL= SUM(MT.Amount) from #Monthly_table MT Inner Join T0250_PERQUISITES_EMPLOYEE_MONTHLY_RENT PEM  WITH (NOLOCK) On MT.Month=PEM.Month and MT.Year=PEM.Year 
							Where  MT.Emp_Id = @Emp_id and PEM.Perq_Tran_Id=@TRAN_ID_RFA And PEM.Amount>0

							SELECT @ACC_AMT = SUM(AMOUNT)  FROM T0250_PERQUISITES_EMPLOYEE_MONTHLY_RENT WITH (NOLOCK) WHERE PERQ_TRAN_ID = @TRAN_ID_RFA

							SET @GROSS_SAL_PER_AMOUNT = (((@GROSS_SAL) - (@dedu_per_day * @Leased_days)) * @leased_Per)/100
						END	
					ELSE
						BEGIN
							SET @Leased_days = DATEDIFF(d,@LEASED_FROM,@LEASED_TO) + 1
							SELECT @ACC_AMT = SUM(AMOUNT)  FROM T0250_PERQUISITES_EMPLOYEE_MONTHLY_RENT WITH (NOLOCK) WHERE PERQ_TRAN_ID = @TRAN_ID_RFA
							
							IF @IS_LEFT = 'N'
								BEGIN
									SET @GROSS_SAL_PER_AMOUNT = (((@GROSS_SAL/@year_days * @Leased_days) - (@dedu_per_day * @Leased_days)) * @leased_Per)/100
								END
							ELSE
								BEGIN
									SET @GROSS_SAL_PER_AMOUNT = (((@GROSS_SAL) - (@dedu_per_day * @Leased_days)) * @leased_Per)/100
								END						
						END		
					
										
					
					IF @GROSS_SAL_PER_AMOUNT < @Acc_Amt
						begin
							set @Per_Total_Amount = @Gross_Sal_Per_amount + @Furnish
						end
					Else
						begin	
							set @Per_Total_Amount = @Acc_Amt + @Furnish
						end
					
				end
			
		End
	
	
	if Exists(Select Tran_id from T0240_Perquisites_Employee_Car WITH (NOLOCK) where Emp_id = @Emp_id and Financial_Year = @Fin_Yr)
		begin
			
			
			declare @perq_car_amt as numeric(18,2)
			set @perq_car_amt  =0
			
			Select @perq_car_amt = total_perq_amt from T0240_Perquisites_Employee_car WITH (NOLOCK) where Emp_id = @Emp_id and Financial_Year = @Fin_Yr
			
			set @Per_Total_Amount = isnull(@Per_Total_Amount,0) + isnull(@perq_car_amt,0)
			
		end
		
		
		
	declare @Perq_electricity_amount numeric(18,2)
	set @Perq_electricity_amount = 0
	
	If @Fin_Yr = '2012-2013'
		Begin
			SELECT @Perq_electricity_amount = AMOUNT  from T0100_IT_DECLARATIO N WITH (NOLOCK) where IT_ID = (SELECT it_id FROM T0070_IT_MASTER WITH (NOLOCK)  where IT_Name = 'Perquisites Value u/s 17(2)(as per From 12B)' and T0070_IT_MASTER.Cmp_ID = @Cmp_id) AND CMP_ID = @Cmp_id AND EMP_ID = @Emp_id and FINANCIAL_YEAR = @Fin_Yr
		End
	Else
		Begin
			SELECT @Perq_electricity_amount = isnull(sum(AMOUNT),0) from T0250_Perquisites_Employee_Monthly_GEW PEMG WITH (NOLOCK) inner join 
										T0240_PERQUISITES_EMPLOYEE_GEW PEG WITH (NOLOCK) On PEMG.Perq_Tran_Id = PEG.Trans_ID where Cmp_id = @Cmp_id and emp_id = @Emp_id and Financial_Year = @Fin_Yr
		End
 
	set @Per_Total_Amount = isnull(@Per_Total_Amount,0) + isnull(@Perq_electricity_amount,0)
	
		-- added by rohit For Add dynamic Perq amount in perq value on 22032016
	Declare @perq_Dynamic numeric(18,2)
	set @perq_Dynamic =0
	
	SELECT  @perq_Dynamic = isnull(sum(EP.Amount),0)  FROM T0070_IT_MASTER IM WITH (NOLOCK) 
				inner join T0240_Perquisites_Employee_Dynamic EP WITH (NOLOCK) on IM.IT_ID=EP.IT_ID
				LEFT OUTER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON Case When Isnull(IM.AD_String,'') <> '' Then Isnull(IM.AD_String,AM.AD_ID) Else AM.AD_ID END = AM.AD_ID
				where IM.IT_Is_Active =1 and IM.IT_Is_perquisite =1 and IM.cmp_id=@Cmp_id and EP.emp_id=@Emp_Id	 and Financial_Year =@Fin_Yr
					AND AM.AD_DEF_ID <> 5

	--- Added by Hardik 29/09/2020 for Wonder as If Employer PF above 7.50 Lakh then above 7.50 Lakh amount goes to Perquisites
	Declare @PF_perq_Dynamic numeric(18,2)
	set @PF_perq_Dynamic =0
	
	SELECT  @PF_perq_Dynamic = isnull(sum(EP.Amount),0)  
	FROM T0070_IT_MASTER IM WITH (NOLOCK) 
		inner join T0240_Perquisites_Employee_Dynamic EP WITH (NOLOCK) on IM.IT_ID=EP.IT_ID
		INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON Case When Isnull(IM.AD_String,'') <> '' Then Isnull(IM.AD_String,AM.AD_ID) Else AM.AD_ID END = AM.AD_ID
	WHERE IM.IT_Is_Active =1 AND IM.IT_Is_perquisite =1 AND IM.CMP_ID=@Cmp_id AND EP.EMP_ID=@Emp_Id	AND Financial_Year =@Fin_Yr AND AM.AD_DEF_ID = 5

	--select *
	--FROM T0070_IT_MASTER IM WITH (NOLOCK) 
	--	inner join T0240_Perquisites_Employee_Dynamic EP WITH (NOLOCK) on IM.IT_ID=EP.IT_ID
	--	INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON Case When Isnull(IM.AD_String,'') <> '' Then Isnull(IM.AD_String,AM.AD_ID) Else AM.AD_ID END = AM.AD_ID
	--WHERE IM.IT_Is_Active =1 AND IM.IT_Is_perquisite =1 AND IM.CMP_ID=@Cmp_id AND EP.EMP_ID=@Emp_Id	AND Financial_Year =@Fin_Yr AND AM.AD_DEF_ID = 5

		
	--- Added by Hardik 29/09/2020 for Wonder as If Employer PF above 7.50 Lakh then above 7.50 Lakh amount goes to Perquisites
	DECLARE @PF_PERQ_AMOUNT NUMERIC(18,2)
	DECLARE @MAX_PF_EXEMPT_LIMIT NUMERIC
	SET @PF_PERQ_AMOUNT = 0
	SET @MAX_PF_EXEMPT_LIMIT = 750000
	
	IF @FIN_START_DATE >= '2020-04-01' AND ISNULL(@PF_perq_Dynamic,0) = 0
		BEGIN
			SELECT @PF_PERQ_AMOUNT =  ISNULL(S.OLD_M_AD_AMOUNT,0) + ISNULL(MONTH_DIFF_AMOUNT,0)
			FROM #Salary_AD S INNER JOIN 
				T0050_AD_MASTER AM WITH (NOLOCK) ON S.AD_ID=AM.AD_ID 
			WHERE AM.AD_DEF_ID=5 AND S.EMP_ID = @EMP_ID

			IF @PF_PERQ_AMOUNT >= @MAX_PF_EXEMPT_LIMIT
				SET @PF_PERQ_AMOUNT = @PF_PERQ_AMOUNT - @MAX_PF_EXEMPT_LIMIT
			ELSE
				SET @PF_PERQ_AMOUNT = 0

		END
		
	

	set @Per_Total_Amount = isnull(@Per_Total_Amount,0) + isnull(@perq_Dynamic ,0) + ISNULL(@PF_PERQ_AMOUNT,0) + Isnull(@PF_perq_Dynamic,0)
	
	-- Ended by rohit on 22032016
	
	
	set @Per_Total_Amount = round(@Per_Total_Amount,0)
	
END




