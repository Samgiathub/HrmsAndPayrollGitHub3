
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[GET_EMP_PERQUISITES_12BA]
	@Cmp_id numeric(18,0),
	@Emp_id numeric(18,0),
	@Fin_Yr nvarchar(20),	
	@Gross_Sal numeric(18,2),
	@Deduction numeric(18,2),
	@Per_Total_Amount numeric(18,2) ,
	@Output_Type nvarchar(1) = 'R',
	@Constraint nvarchar(MAX) = ''
AS
BEGIN
	 
SET NOCOUNT ON 
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

	DECLARE @Fin_Start_Date DATETIME
	DECLARE @Fin_End_Date DATETIME
	
	
	SET @Fin_Start_Date = cast('01-Apr-' + Left(@Fin_Yr,4) as datetime)
	SET @Fin_End_Date = cast('31-Mar-' + Right(@Fin_Yr,4) as datetime)

	
	--Added By Mukti(start)25112015
	declare @srno as numeric(18,0)
	declare @It_Name as varchar(250)
	declare @Amount as numeric(18,2)
	set @srno=3
	--Added By Mukti(end)25112015
	
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
	
		
			
			insert into #perquisites_Details
				SELECT 1,@cmp_id,@emp_id,@Fin_Yr,'Accommodation',0,0,0  UNION ALL
				SELECT 2,@cmp_id,@emp_id,@Fin_Yr,'Cars / Other automotive',0,0,0  UNION ALL
				SELECT 3,@cmp_id,@emp_id,@Fin_Yr,'Sweeper, gardener, watchman or personal attendant',0,0,0  UNION ALL
				SELECT 4,@cmp_id,@emp_id,@Fin_Yr,'Gas, electricity, water',0,0,0  --UNION ALL
				--Commented By Mukti(start)25112015 because fill Perquisite details dynamically 
				--SELECT 5,@cmp_id,@emp_id,@Fin_Yr,'Interest free or concessional Loans',0,0,0  UNION ALL
				--SELECT 6,@cmp_id,@emp_id,@Fin_Yr,'Holiday expenses',0,0,0  UNION ALL
				--SELECT 7,@cmp_id,@emp_id,@Fin_Yr,'Free or concessional travel',0,0,0  UNION ALL
				--SELECT 8,@cmp_id,@emp_id,@Fin_Yr,'Free meals',0,0,0  UNION ALL
				--SELECT 9,@cmp_id,@emp_id,@Fin_Yr,'Free Education',0,0,0  UNION ALL
				--SELECT 10,@cmp_id,@emp_id,@Fin_Yr,'Gifts, vouchers etc.',0,0,0  UNION ALL
				--SELECT 11,@cmp_id,@emp_id,@Fin_Yr,'Credit card expenses',0,0,0  UNION ALL
				--SELECT 12,@cmp_id,@emp_id,@Fin_Yr,'Club expenses',0,0,0  UNION ALL
				--SELECT 13,@cmp_id,@emp_id,@Fin_Yr,'Use of movable assets by employees',0,0,0  UNION ALL
				--SELECT 14,@cmp_id,@emp_id,@Fin_Yr,'Transfer of assets to employees',0,0,0  UNION ALL
				--SELECT 15,@cmp_id,@emp_id,@Fin_Yr,'Value of any other benefit / amenity / service / privilege',0,0,0  UNION ALL
				--SELECT 16,@cmp_id,@emp_id,@Fin_Yr,'Stock options (non-qualified options)',0,0,0  UNION ALL
				--SELECT 17,@cmp_id,@emp_id,@Fin_Yr,'Other benefits or amenities',0,0,0  UNION ALL
				--SELECT 18,@cmp_id,@emp_id,@Fin_Yr,'Total value of perquisites',0,0,0  UNION ALL
				--SELECT 19,@cmp_id,@emp_id,@Fin_Yr,'Total value of profits in lieu of salary as per 17(3)',0,0,0 
				--Commented By Mukti(end)25112015
					
			--SELECT * from #perquisites_Details
			
			--return
			DECLARE @HasPerqTable BIT
			SET @HasPerqTable = 0
			IF OBJECT_ID('tempdb..#Perq_Detail') is not null
				begin
					SET @HasPerqTable = 1
				end

			DECLARE @TotalAmount Numeric(18,2)
			DECLARE @ExemptedAmount Numeric(18,2)
			DECLARE @FinalAmount Numeric(18,2)
			DECLARE @IT_ID INT

	
	 	--Added By Mukti(start)25112015 for to fill Perquisite details dynamically
			DECLARE CUR_Perquisite CURSOR FOR 
			SELECT  IM.IT_ID,IM.It_Name,IsNull(EP.Amount,0)
			FROM	T0070_IT_MASTER IM WITH (NOLOCK) 
					LEFT OUTER JOIN T0240_Perquisites_Employee_Dynamic EP WITH (NOLOCK) on IM.IT_ID=EP.IT_ID and EP.emp_id=@Emp_Id
			WHERE	IM.IT_Is_Active =1 and IM.IT_Is_perquisite =1 and IM.cmp_id=@Cmp_id --and EP.emp_id=@Emp_Id
					AND ISNULL(Financial_Year,@Fin_Yr) = @Fin_Yr	--Ankit 11052016
			ORDER BY IM.IT_LEVEL
			OPEN CUR_Perquisite 
			FETCH NEXT FROM CUR_Perquisite INTO @IT_ID, @It_Name,@Amount
			WHILE @@FETCH_STATUS =0
				BEGIN
					IF @HasPerqTable = 1
						BEGIN							
							SELECT	@TotalAmount = ISNULL(SUM(TotalAmount),0) + @Amount,
									@ExemptedAmount = ISNULL(SUM(TaxFreeAmount),0) ,
									@FinalAmount = ISNULL(SUM(FinalAmount),0) + @Amount
							FROM	#Perq_Detail PD
							WHERE	Emp_ID = @emp_id AND IT_ID=@IT_ID						
						END

					SELECT	@srno= Isnull(max(sr_no),0) + 1 	
					From	#perquisites_Details  
					WHERE	emp_id = @emp_id	--Emp_ID Condition Added by Ankit B'cos Sorting Number change if open report for multi employee
					insert into #perquisites_Details
					VALUES(@srno,@cmp_id,@emp_id,@Fin_Yr,@It_Name,@TotalAmount,@ExemptedAmount,@FinalAmount)	
				
					FETCH NEXT FROM CUR_Perquisite INTO @IT_ID, @It_Name,@Amount
				END
			CLOSE CUR_Perquisite
			DEALLOCATE CUR_Perquisite 
		
		if NOT EXISTS(select 1 from T0070_IT_MASTER WITH (NOLOCK) where IT_Name='Total value of perquisites' and Cmp_ID=@cmp_id and IT_Is_Active=1) --Mukti(30122016) becoz of duplicate entry found
		begin
			insert into #perquisites_Details
			values(0,@cmp_id,@emp_id,@Fin_Yr,'Total value of perquisites',0,0,0)
		end
	--Added By Mukti(end)25112015 for to fill Perquisite details dynamically
		
	if Exists(Select Tran_id from T0240_Perquisites_Employee WITH (NOLOCK) where Emp_id = @Emp_id and Financial_Year = @Fin_Yr)
		Begin
		 
			select @Date_Of_Join = Date_Of_Join, @Left_date = isnull(Emp_Left_Date,NULL), @is_Left = isnull(Emp_Left,'N')  From T0080_emp_Master WITH (NOLOCK) where Emp_ID = @Emp_ID 
			
			Declare @start_date as datetime 
			Declare @End_date as datetime 
			set @start_date = cast('01-Apr' + Left(@Fin_Yr,4) as datetime)
			Set @End_date = cast('31-Mar' + Right(@Fin_Yr,4) as datetime)
						
			if @is_Left = 'Y' And @End_date > @Left_date
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
							set @year_days = DATEDIFF(dd,@start_date ,@End_date) + 1
						end
					else
						begin
								set @year_days = DATEDIFF(dd,@Date_Of_Join ,@End_date) + 1
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

							exec SP_RPT_YEARLY_SALARY_GET_INCOME_TAX @Cmp_ID=@Cmp_id,@From_Date=@Fin_Start_Date,@To_Date=@Fin_End_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,
							@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=@Emp_id,@Constraint='',@Report_Call='RENT FREE',@With_Ctc='1',@Publish_Flag=0

							--Select * from #Monthly_table MT Inner Join T0250_PERQUISITES_EMPLOYEE_MONTHLY_RENT PEM On MT.Month=PEM.Month and MT.Year=PEM.Year 
							--Where  MT.Emp_Id = @Emp_id and PEM.Perq_Tran_Id=@TRAN_ID_RFA And PEM.Amount>0

							Select @GROSS_SAL= SUM(MT.Amount) from #Monthly_table MT Inner Join T0250_PERQUISITES_EMPLOYEE_MONTHLY_RENT PEM WITH (NOLOCK) On MT.Month=PEM.Month and MT.Year=PEM.Year 
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
	
	
	declare @perq_car_amt as numeric(18,2)
	declare @Amount_Recoverd as numeric(18,2) --Added by Hardik 13/07/2017 For Mediscribe Client
	if Exists(Select Tran_id from T0240_Perquisites_Employee_Car WITH (NOLOCK) where Emp_id = @Emp_id and Financial_Year = @Fin_Yr)
		begin

			set @perq_car_amt  =0
			Set @Amount_Recoverd=0
			
			Select @perq_car_amt = total_perq_amt,@Amount_Recoverd = amount_recovered from T0240_Perquisites_Employee_car WITH (NOLOCK) where Emp_id = @Emp_id and Financial_Year = @Fin_Yr
			
			--set @Per_Total_Amount = isnull(@Per_Total_Amount,0) + isnull(@perq_car_amt,0)
			
		end
	
	
	set @Per_Total_Amount = round(@Per_Total_Amount,0)
	
	declare @Perq_electricity_amount numeric(18,2)
	set @Perq_electricity_amount = 0
	
	If @Fin_Yr = '2012-2013'
		Begin
			SELECT @Perq_electricity_amount = AMOUNT  from T0100_IT_DECLARATION WITH (NOLOCK) where IT_ID = (SELECT it_id FROM T0070_IT_MASTER WITH (NOLOCK)  where IT_Name = 'Perquisites Value u/s 17(2)(as per From 12B)' and T0070_IT_MASTER.Cmp_ID = @Cmp_id) AND CMP_ID = @Cmp_id AND EMP_ID = @Emp_id and FINANCIAL_YEAR = @Fin_Yr
		End
	Else
		Begin
			SELECT @Perq_electricity_amount = isnull(sum(AMOUNT),0) from T0250_Perquisites_Employee_Monthly_GEW PEMG WITH (NOLOCK) inner join 
										T0240_PERQUISITES_EMPLOYEE_GEW PEG WITH (NOLOCK) On PEMG.Perq_Tran_Id = PEG.Trans_ID where Cmp_id = @Cmp_id and emp_id = @Emp_id and Financial_Year = @Fin_Yr
		End
 
	 
		update #perquisites_Details SET value_of_perq = isnull(@Per_Total_Amount,0), Final_Amount = isnull(@Per_Total_Amount,0) where Sr_NO = 1 and Emp_id = @Emp_id
		update #perquisites_Details SET value_of_perq = isnull(@perq_car_amt,0)+ isnull(@Amount_Recoverd,0) , Amount_Recoverd = isnull(@Amount_Recoverd,0), Final_Amount = isnull(@perq_car_amt,0)  where Sr_NO = 2 and Emp_id = @Emp_id
		update #perquisites_Details SET value_of_perq = isnull(@Perq_electricity_amount,0) , Final_Amount = isnull(@Perq_electricity_amount,0)  where Sr_NO = 4 and Emp_id = @Emp_id
		
		--update #perquisites_Details SET value_of_perq = isnull(@Per_Total_Amount,0) + isnull(@perq_car_amt,0) + isnull(@Perq_electricity_amount,0), Final_Amount = isnull(@Per_Total_Amount,0) + isnull(@perq_car_amt,0) + isnull(@Perq_electricity_amount,0) where Sr_NO = 18 and Emp_id = @Emp_id --commented by Mukti 25112015
		
	--Added By Mukti(start)25112015 for to fill Perquisite details dynamically
		declare @last_sr_no as numeric(18,0)
		declare @Tot_perq as numeric(18,2)
		declare @Tot_Amount_Recovered as numeric(18,2) --Added by Hardik 13/07/2017
		declare @Tot_Final_Amount as numeric(18,2) --Added by Hardik 13/07/2017
		
		SET @last_sr_no = 0
		SET @Tot_perq = 0
		Set @Tot_Amount_Recovered=0
		Set @Tot_Final_Amount = 0
		
		select @last_sr_no= Isnull(max(sr_no),0) + 1,@Tot_perq=sum(value_of_perq),@Tot_Amount_Recovered= sum(Amount_Recoverd), @Tot_Final_Amount= Sum(Final_Amount)
		From #perquisites_Details  WHERE Emp_id = @Emp_id	--Condition Added by Ankit 11052016
		
		update #perquisites_Details SET sr_no=@last_sr_no,value_of_perq=@Tot_perq,Final_Amount=@Tot_Final_Amount,Amount_Recoverd=@Tot_Amount_Recovered 
		where Nature_of_Perq= 'Total value of perquisites' and Emp_id = @Emp_id
	--Added By Mukti(start)25112015 for to fill Perquisite details dynamically
	
		--select * from #perquisites_Details
			
		--	drop TABLE #perquisites_Details
			
		 
	
END




