
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_IT_TAX_HOUSING_EXEMPTION]
	 @Emp_ID				numeric
	,@From_Date				datetime
	,@To_Date				datetime 
	,@Increment_ID			numeric
	,@HRA_Amount			numeric(18,2) output 
	,@Current_HRA_Amount	numeric(18,2) 
	,@HRA_Exemption			numeric(18,2) output 
	,@Less_Salary_Amount	numeric(18,2) output
	,@Two_Fifth_Salary		numeric(18,2) output
	,@Housing_Amount		numeric(18,2) output
	,@House_Rent_Amount		numeric(18,2) output
	,@Month_Count			tinyint =0
	,@IT_Declaration_Calc_On Varchar(30) = 'On_Regular'   --Added by Hardik 06/03/2019 --- 3 Types : "On_Regular", "On_Provisional", "On_Approved"
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @Cont_Annual_Salary	tinyint 
	Declare @Cont_HRA			tinyint 
	Declare @Cont_Actual_Rent_paid	tinyint 
	Declare @Cont_Less_Salary	tinyint 
	Declare @Cont_Diff_Amount	tinyint 
	Declare @Cont_Two_Fifth	tinyint 
	Declare @Cont_One_Half	tinyint 
	Declare @Cont_HRA_Exemption	tinyint
	
	Declare @One_Half_Amount	Numeric(18,2)
	Declare @Is_Metro_city Tinyint

	set @Cont_Annual_Salary =109
	set @Cont_HRA			=110
	set @Cont_Actual_Rent_paid	= 112
	set @Cont_Less_Salary	=113
	set @Cont_Diff_Amount	=114
	set @Cont_Two_Fifth		=115
	set @Cont_One_Half		=116
	set @Cont_HRA_Exemption	=7

	
	Declare @Annual_Basic_Salary	numeric(18,2)
	Declare @Actual_Rent_Paid		numeric(18,2)
	Declare @Rent_Amount			numeric(18,2)
	
	
--	Declare @Less_Salary_Amount		numeric(27,2)
--	Declare @Two_fifth_Salary		numeric(27,2)
--	Declare @House_Rent_Amount		numeric 
--	Declare @Housing_Amount			numeric	
	Declare @Rent_Paid_Count		numeric	
	declare @Basic_Salary			numeric(18,2)
	declare @Arear_Basic_month		numeric
	
	set @Arear_Basic_month = 0
	set @Actual_Rent_Paid   = 0
	set @Less_Salary_Amount = 0
	set @Two_fifth_Salary   = 0
	set @HRA_Exemption		= 0
	set @House_Rent_Amount  = 0
	set @Housing_Amount = 0
	set @Rent_Paid_Count = 0
	set @Rent_Amount = 0
	set @Annual_Basic_Salary = 0
	set @One_Half_Amount = 0
	
	declare @Temp_For_Date as datetime
	declare @Dedu_HRA_Amount as numeric
	Declare @Temp_join_date as datetime
	Declare @Temp_left_date as datetime
	
		
		-- Added by rohit on 08-apr-2014
	declare @Wages_Type as varchar(50)
	set @Wages_Type=''
	Declare @Day_Count as numeric(18,2)
	set @Day_Count = 1
	-- Added by rohit on 08-apr-2014
	
	select @Temp_join_date = date_of_join,@Temp_left_date = isnull(emp_left_date,@To_Date) from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
	
	If @Temp_join_date > @From_Date
		set @From_Date = @Temp_join_date
	else
		set @From_Date = @From_Date
		
	
	set @Temp_For_Date  = @From_Date
	
	--Modified By Nimesh 24-Jul-2015 (Retrieving City Type from IT Declaration Table)
	DECLARE @FIN_YEAR AS NVARCHAR(20)  	
	SET @FIN_YEAR = CAST(YEAR(@From_Date) AS NVARCHAR) + '-' + CAST(YEAR(@To_Date) AS NVARCHAR)  
	
	SET @Is_Metro_city = NULL;	
	
	SELECT	TOP 1 @Is_Metro_city = CASE WHEN IT.Is_Metro_NonMetro = 'Metro' Then 1 WHEN IT.Is_Metro_NonMetro = 'Non-Metro' THEN 0 ELSE NULL END 
	FROM	T0100_IT_DECLARATION IT WITH (NOLOCK)
	WHERE	IT.EMP_ID=@EMP_ID AND IT.FINANCIAL_YEAR = @FIN_YEAR AND Is_Metro_NonMetro IS NOT NULL
	
	IF @Is_Metro_city IS NULL 
	BEGIN
		SELECT	@Is_Metro_city = Is_Metro_city 
		FROM	T0095_INCREMENT WITH (NOLOCK)
		WHERE	emp_id = @emp_id and Increment_id = @Increment_Id 
				--Commented by Hardik 05/09/2014 for Same Date Increment
				--	Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT
				--where emp_id = @emp_id and Increment_Effective_Date <=	@To_Date)
		IF @Is_Metro_city IS NULL 
			SET	@Is_Metro_city = 0
	END
	
	SELECT	@wages_type=wages_type  	-- Added by rohit on 08-apr-2014
	FROM	T0095_INCREMENT WITH (NOLOCK)
	WHERE	emp_id = @emp_id and Increment_id = @Increment_Id 
	--End Modification : Nimesh

	if @Wages_Type='Daily' -- Added by rohit on 08-apr-2014	
	begin
		set @Day_Count = 26
	end
	
	--select @Current_HRA_Amount = (E_AD_Amount * @Day_Count)  From  T0100_EMP_EARN_DEDUCTION eed inner join
	--			T0050_AD_Master Am on eed.AD_ID = am.AD_ID and
	--			eed.cmp_id = am.cmp_id and AD_IT_DEF_ID =7
	--WHERE INCREMENT_ID =@INCREMENT_ID
	
	SELECT @Current_HRA_Amount = (E_AD_Amount * @Day_Count)  From  #tblAllow_Revice eed inner join
				T0050_AD_Master Am WITH (NOLOCK) on eed.AD_ID = am.AD_ID and
				eed.cmp_id = am.cmp_id and AD_IT_DEF_ID =7
	WHERE INCREMENT_ID =@INCREMENT_ID
	
	if @HRA_Amount is  null
      set @HRA_Amount =0
   
      set @HRA_Amount =0 
 --   set @HRA_Amount  = @HRA_Amount  + (@Current_HRA_Amount * @Month_Count)
		
	 


	--Update #Tax_Report 
	--set Amount_Col_Final = @HRA_Amount 
	--where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_HRA

    declare @Month_count_hra_declaration numeric(18,0)
	set @Month_count_hra_declaration = 0

	while  @Temp_For_DAte <= @To_Date
		begin
			
			declare @inc_id_w numeric 
			set @inc_id_w = 0
			
				select @inc_id_w = Increment_ID from T0095_INCREMENT WITH (NOLOCK)
					where emp_id = @emp_id and 
					Increment_ID = (select max(Increment_id) from T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 05/09/2014 for Same Date Increment
				where emp_id = @emp_id and Increment_Effective_Date <=	@Temp_For_Date And Increment_Type<>'Transfer' And Increment_Type<>'Deputation')
			
		 
			
			set @Arear_Basic_month = 0 
			set @Basic_Salary = 0
			set @Rent_Amount = 0 
			set @Dedu_HRA_Amount = 0
			
			 
			 
			--select @Rent_Amount = isnull(sum (Amount),0) ,@Rent_Paid_Count = count(*)  from T0100_IT_DECLARATION  ID INNER JOIN
			--	T0070_IT_MASTER AM ON ID.IT_ID = AM.IT_ID AND IT_DEF_ID =1
			--where Emp_ID  = @Emp_ID and Month(For_Date)= Month(@Temp_For_Date) and Year(For_Date)  = Year(@Temp_For_Date) 
			--and (For_Date <= @Temp_left_date)
			--and (For_Date >= dbo.GET_MONTH_ST_DATE(month(@Temp_join_date),year(@Temp_join_date)))
			--and Amount > 0 
			

				-- if @Temp_For_Date > '31-Mar-2014' -- open if condition for wonder - mitesh on 13052014
				--begin
				
						select @Rent_Amount = CASE @IT_Declaration_Calc_On 
											WHEN 'On_Regular' THEN
												CASE WHEN ISNULL(AM.Exempt_Percent,0) > 0 THEN (ISNULL(SUM(ID.AMOUNT),0) * ISNULL(AM.Exempt_Percent,0))/100 ELSE ISNULL(SUM(ID.AMOUNT),0) END 
											WHEN 'On_Provisional' THEN
												CASE WHEN ISNULL(AM.Exempt_Percent,0) > 0 THEN (ISNULL(SUM(ID.AMOUNT_ESS),0) * ISNULL(AM.Exempt_Percent,0))/100 ELSE ISNULL(SUM(ID.AMOUNT_ESS),0) END 
											WHEN 'On_Approved' THEN
												CASE WHEN ISNULL(ID.Is_Lock,0) = 1 THEN
													CASE WHEN ISNULL(AM.Exempt_Percent,0) > 0 THEN (ISNULL(SUM(ID.AMOUNT),0) * ISNULL(AM.Exempt_Percent,0))/100 ELSE ISNULL(SUM(ID.AMOUNT),0) END 
												ELSE 0 END
											END
								,@Rent_Paid_Count = count(1)  from T0100_IT_DECLARATION  ID WITH (NOLOCK) INNER JOIN
						T0070_IT_MASTER AM WITH (NOLOCK) ON ID.IT_ID = AM.IT_ID AND IT_DEF_ID =1 and am.Cmp_ID=ID.CMP_ID
					where Emp_ID  = @Emp_ID and Month(For_Date)= Month(@Temp_For_Date) and Year(For_Date)  = Year(@Temp_For_Date) 
					and (For_Date <= @Temp_left_date)
					and (For_Date >= dbo.GET_MONTH_ST_DATE(month(@Temp_join_date),year(@Temp_join_date)))
					and Amount > 0 
					Group by AM.Exempt_Percent,Is_Lock
			--	end 
			--else	
			--	begin
			--			select @Rent_Amount = isnull(sum (Amount),0) ,@Rent_Paid_Count = count(*)  from T0100_IT_DECLARATION  ID INNER JOIN
			--			T0070_IT_MASTER AM ON ID.IT_ID = AM.IT_ID AND IT_DEF_ID =1
			--		where Emp_ID  = @Emp_ID and Month(For_Date)= Month(@Temp_For_Date) and Year(For_Date)  = Year(@Temp_For_Date) 
			--		and (For_Date <= @Temp_left_date)
			--		and (For_Date >= @Temp_join_date)
			--		and Amount > 0 
					
			--	end
			

			if @Temp_For_Date = @Temp_join_date and DAY(@Temp_For_Date) > 1
				begin
				
					Declare @temp_Sum numeric
					declare @temp_dt_end datetime
					SET @TEMP_DT_END = DBO.GET_MONTH_END_DATE(MONTH(@TEMP_FOR_DATE),YEAR(@TEMP_FOR_DATE))
					SET @TEMP_SUM = @RENT_AMOUNT/DAY(@TEMP_DT_END) * (DAY(@TEMP_DT_END) - (DAY(@TEMP_FOR_DATE) - 1))
					set @RENT_AMOUNT = @TEMP_SUM
				end
		
			if exists (select Salary_Amount from T0200_MONTHLY_SALARY WITH (NOLOCK) where emp_ID = @Emp_ID and MONTH(month_end_Date) = Month(@Temp_For_Date) and Year(month_end_Date) = Year(@Temp_For_Date))  
				begin
					
						if exists (select EED.AD_ID From T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) inner join T0050_AD_MASTER ADM WITH (NOLOCK)  on EEd.AD_ID = ADM.AD_ID where emp_id = @emp_id and increment_id = @inc_id_w	 and ADM.AD_IT_DEF_ID =7)  And Isnull(@Rent_Amount,0) > 0 -- Added Rent Amount Condition by Hardik 15/06/2016 as if Rent not paid by Employee that month's Basic should not calculate in HRA Exemption
							begin
								 
								select @Basic_Salary = Salary_Amount + isnull(Q.S_Salary_Amount,0) + isnull(Basic_Salary_Arear_cutoff,0) , @Arear_Basic_month = isnull(Arear_Basic,0) from T0200_MONTHLY_SALARY MSS WITH (NOLOCK)
										left outer JOIN (SELECT MS.EMP_ID ,SUM(MS.S_Salary_Amount) S_Salary_Amount FROM 
											T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK)
											WHERE  MONTH(MS.S_Month_End_Date) = Month(@Temp_For_Date) and Year(MS.S_Month_End_Date) = Year(@Temp_For_Date) AND MS.Emp_ID = @Emp_ID
											and Ms.S_Month_St_Date <= @Temp_For_Date
										GROUP BY MS.EMP_ID ) Q ON MSS.EMP_ID =Q.EMP_ID
								where MSS.emp_ID = @Emp_ID and MONTH(MSS.Month_End_Date) = Month(@Temp_For_Date) and Year(MSS.Month_End_Date) = Year(@Temp_For_Date)

								--- Added by Hardik on 09/07/2014  for Add DA for SSI
								--Select @Basic_Salary = @Basic_Salary + ISNULL(M_AD_Amount,0) , @Arear_Basic_month = @Arear_Basic_month + ISNULL(M_AREAR_AMOUNT,0) 
								--	from T0210_MONTHLY_AD_DETAIL MSS Inner Join T0050_AD_MASTER A on MSS.AD_ID = A.AD_ID 
								--where MSS.emp_ID = @Emp_ID and MONTH(MSS.To_date) = Month(@Temp_For_Date) and Year(MSS.To_date) = Year(@Temp_For_Date)
								--	And AD_DEF_ID = 11 -- Def Id 11 for DA
							end
						else	
							begin
								set @Basic_Salary = 0
								set @Arear_Basic_month = 0
								set @Rent_Amount = 0
							end


				end
			else
				begin
						if exists (select EED.AD_ID From T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) inner join T0050_AD_MASTER ADM  WITH (NOLOCK) on EEd.AD_ID = ADM.AD_ID where emp_id = @emp_id and increment_id = @inc_id_w	 and ADM.AD_IT_DEF_ID =7) And Isnull(@Rent_Amount,0) > 0 -- Added Rent Amount Condition by Hardik 15/06/2016 as if Rent not paid by Employee that month's Basic should not calculate in HRA Exemption
							begin
								select @Basic_Salary = (Basic_Salary * @Day_count) , @Arear_Basic_month = 0 from T0095_Increment WITH (NOLOCK)
								where emp_id = @emp_id and 
								Increment_Id = (select max(Increment_Id) from T0095_Increment WITH (NOLOCK) --Changed by Hardik 05/09/2014 for Same Date Increment
								where emp_id = @emp_id and Increment_Effective_Date <=	@Temp_For_DAte)

								
								--- Added by Hardik on 09/07/2014  for Add DA for SSI
								
								--Select @Basic_Salary = @Basic_Salary + (ISNULL(E_AD_AMOUNT,0)* @Day_count) From T0100_EMP_EARN_DEDUCTION E Inner Join T0050_AD_MASTER A on E.AD_ID = A.AD_ID
								--	Where EMP_ID = @Emp_ID And AD_DEF_ID = 11 And  --- Def Id 11 for DA
								--	INCREMENT_ID = (Select Increment_Id From T0095_Increment I Where Emp_Id = @Emp_Id 
								--					And Increment_Id = (select max(Increment_Id) from T0095_Increment --Changed by Hardik 05/09/2014 for Same Date Increment
								--					where emp_id = @emp_id and Increment_Effective_Date <=	@Temp_For_DAte))
								
								--Commented by Hardik 29/01/2016 As no need to Add DA allowance in Basic, it will showing wrong amount of Basic on TDS Calculation for Housing Exempt
								
								--Select @Basic_Salary = @Basic_Salary + (ISNULL(E_AD_AMOUNT,0)* @Day_count) From #tblAllow_Revice E Inner Join T0050_AD_MASTER A on E.AD_ID = A.AD_ID
								--	Where EMP_ID = @Emp_ID And AD_DEF_ID = 11 And  --- Def Id 11 for DA
								--	INCREMENT_ID = (Select Increment_Id From T0095_Increment I Where Emp_Id = @Emp_Id 
								--					And Increment_Id = (select max(Increment_Id) from T0095_Increment --Changed by Hardik 05/09/2014 for Same Date Increment
								--					where emp_id = @emp_id and Increment_Effective_Date <=	@Temp_For_DAte))
							end
						else
							begin
								
								set @Basic_Salary = 0
								set @Arear_Basic_month = 0
								set @Rent_Amount = 0
							end	
				end

			--Condition Changed by Hardik 29/01/2016 for Rent Paid option as if employee not paid House Rent then that months HRA and Basic not adding in TDS at Last
			if @Rent_Paid_Count = 0 
				begin		
					IF isnull(@Temp_left_date,0) <> 0
						begin		
							--if (month(@Temp_left_date) = month(@Temp_For_DAte) and year(@Temp_left_date)  >= year(@Temp_For_DAte) ) or (year(@Temp_left_date) <= year(@Temp_For_DAte))
							if @Temp_For_DAte > dbo.GET_MONTH_END_DATE(Month(@Temp_left_date), Year(@Temp_left_date))
								begin												
									set @Basic_Salary = 0
									set @Arear_Basic_month = 0		
									set @Rent_Amount = 0
								end
						end
					ELSE
						BEGIN
							set @Rent_Amount = 0
						END
				end

			---Condition Added by Hardik 24/03/2017 
			if Isnull(@Rent_Amount,0) = 0
				begin												
					set @Basic_Salary = 0
					set @Arear_Basic_month = 0		
				end
			
			
			--set @Month_count_hra_declaration = @Month_count_hra_declaration + @Rent_Paid_Count 
			 
			set @Actual_Rent_Paid = @Actual_Rent_Paid + @Rent_Amount 
			 
			--Commented by Hardik 29/01/2016 for Rent Paid option as if employee not paid House Rent then that months HRA and Basic not adding in TDS at Last
			--if @Actual_Rent_Paid > 0 
			--	begin		 
					set @Annual_Basic_Salary = isnull(@Annual_Basic_Salary,0) + isnull(@Basic_Salary,0) + isnull(@Arear_Basic_month,0)
									
			--	end 
			--else
			--	begin
			--		if exists (Select M_AD_Amount from T0210_monthLy_AD_Detail mad inner join T0050_AD_MASTER am on 
			--				mad.AD_ID = am.AD_ID and mad.CMP_ID = am.CMP_ID
			--				Where emp_ID = @Emp_ID and Month(For_date) = Month(@Temp_For_Date) and Year(For_date)  = Year(@Temp_For_Date) and AD_IT_DEF_ID = 7 )
					
			--			begin
						
			--				IF isnull(@Temp_left_date,0) <> 0
			--					begin										
			--						if (month(@Temp_left_date) = month(@Temp_For_DAte) and year(@Temp_left_date)  >= year(@Temp_For_DAte) ) or (year(@Temp_left_date) <= year(@Temp_For_DAte))
			--							begin												
			--								break 
			--							end
			--					end
									
			--				Select @Dedu_HRA_Amount = Sum(isnull(M_AD_Amount,0) + isnull(M_AREAR_AMOUNT,0))  from T0210_monthLy_AD_Detail mad inner join T0050_AD_MASTER am on 
			--					mad.AD_ID = am.AD_ID and mad.CMP_ID = am.CMP_ID
			--				Where emp_ID = @Emp_ID and Month(To_date) = Month(@Temp_For_Date) and Year(To_date)  = Year(@Temp_For_Date) and AD_IT_DEF_ID = 7


			--			end
			--		else
			--			begin
			--				set @Dedu_HRA_Amount = @Current_HRA_Amount
			--			end
				
			
						--set @HRA_Amount = @HRA_Amount - @Dedu_HRA_Amount				
			--	end		
					
				 

				declare @hra_Assume numeric(18,2)
				declare @hra_Salary_dedu numeric(18,2)
				declare @hra_final_cal numeric(18,2)
				set @hra_Assume  = 0
				set @hra_Salary_dedu  = 0
				set @hra_final_cal  = 0

				Select @hra_Salary_dedu = Sum(isnull(M_AD_Amount,0) + isnull(M_AREAR_AMOUNT,0) + Isnull(M_Arear_Amount_Cutoff,0))  from T0210_monthLy_AD_Detail mad WITH (NOLOCK) inner join T0050_AD_MASTER am WITH (NOLOCK) on 
						mad.AD_ID = am.AD_ID and mad.CMP_ID = am.CMP_ID
					Where emp_ID = @Emp_ID and Month(To_date) = Month(@Temp_For_Date) and Year(To_date)  = Year(@Temp_For_Date) and AD_IT_DEF_ID = 7
						And am.AD_CALCULATE_ON <> 'Import' --Added by nilesh patel on 29122016 For Aculife HRA_IT_Arr(Set Def ID HRA Execption)
						And Isnull(@Rent_Amount,0) > 0 -- Added Rent Amount Condition by Hardik 15/06/2016 as if Rent not paid by Employee that month's Basic should not calculate in HRA Exemption


						
				--Select @hra_Assume = (E_AD_AMOUNT * @Day_Count) from T0100_EMP_EARN_DEDUCTION mad inner join T0050_AD_MASTER am on 
				--				mad.AD_ID = am.AD_ID and mad.CMP_ID = am.CMP_ID
				--			Where emp_ID = @Emp_ID and AD_IT_DEF_ID = 7 and INCREMENT_ID = @INCREMENT_ID
				--			--and Month(For_date) = Month(@Temp_For_Date) and Year(For_date)  = Year(@Temp_For_Date) 
				
					Select @hra_Assume = (sum(E_AD_AMOUNT) * @Day_Count) from #tblAllow_Revice mad inner join T0050_AD_MASTER am WITH (NOLOCK) on 
						mad.AD_ID = am.AD_ID and mad.CMP_ID = am.CMP_ID
					Where emp_ID = @Emp_ID and AD_IT_DEF_ID = 7 and INCREMENT_ID = @INCREMENT_ID And Isnull(@Rent_Amount,0) > 0
					

				
			
			--if @Rent_Paid_Count  =1 
				begin
					
					--Commented below condition by Hardik 28/07/2017 and added below mentioned condition, because if Salary Generated with 0 amount for some month then HRA should not assume, BMA Case 
					--if @hra_Salary_dedu > 0
					if exists (select Salary_Amount from T0200_MONTHLY_SALARY WITH (NOLOCK) where emp_ID = @Emp_ID and MONTH(month_end_Date) = Month(@Temp_For_Date) and Year(month_end_Date) = Year(@Temp_For_Date))  
						begin 
							set @hra_final_cal  = isnull(@hra_Salary_dedu,0)
						end
					else
					if @Rent_Paid_Count  =1 
						begin	
							set @hra_final_cal  = isnull(@hra_Assume,0)
						end
					  
					set @HRA_Amount  = isnull(@HRA_Amount,0)  + @hra_final_cal
				end

			set @Temp_For_Date  =dateadd(m,1, @Temp_For_Date)
		end
		
		
		
   
		 
	Update #Tax_Report 
	set Amount_Col_Final = @HRA_Amount 
	where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_HRA
	  
	IF @HRA_Amount < 0
		SET @HRA_Amount = 0 
	
	set @Less_Salary_Amount  = 	@Annual_Basic_Salary * 0.1
	
	If @Is_Metro_city = 0
		set @Two_fifth_Salary = @Annual_Basic_Salary * 0.4
	else
		set @One_Half_Amount = @Annual_Basic_Salary * 0.5
	
	if @Actual_Rent_Paid > 0 and @Actual_Rent_Paid - @Less_Salary_Amount  > 0
		set @Housing_Amount = @Actual_Rent_Paid - @Less_Salary_Amount 
	else if @Actual_Rent_Paid > 0 	
		set @Housing_Amount = @Less_Salary_Amount - @Actual_Rent_Paid
	   	
	if @Housing_Amount < @HRA_Amount 
		begin
			if @Housing_Amount = 0
				set @HRA_Exemption =@Actual_Rent_Paid
			else if @Housing_Amount < @Two_Fifth_Salary 
				begin
					set @HRA_Exemption = @Housing_Amount
				end
			else if @Housing_Amount < @One_Half_Amount 
				begin
					set @HRA_Exemption = @Housing_Amount
				end
			else
				begin
					if @One_Half_Amount <=0
						set @HRA_Exemption =  @Two_Fifth_Salary
					else
						set @HRA_Exemption =  @One_Half_Amount
				end		
		end  
	else if @HRA_Amount < @Two_Fifth_Salary 
		begin
			set @HRA_Exemption =  @HRA_Amount
		end
	else if @HRA_Amount < @One_Half_Amount 
		begin
			set @HRA_Exemption =  @HRA_Amount
		end
	else 
		begin
			if @One_Half_Amount <=0
				set @HRA_Exemption =  @Two_Fifth_Salary
			else
				set @HRA_Exemption =  @One_Half_Amount
		end 
		
		Declare @Row_ID as numeric
		
		IF @HRA_Exemption < 0
			SET @HRA_Exemption = 0
		
		
		set @House_Rent_Amount =@Actual_Rent_Paid 
	
		 

		Update #Tax_Report 
		set Amount_Col_Final = @Annual_Basic_Salary 
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Annual_Salary
		
		Update #Tax_Report 
		set Amount_Col_Final = @House_Rent_Amount 
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Actual_Rent_paid

		Update #Tax_Report 
		set Amount_Col_Final = @Less_Salary_Amount 
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Less_Salary

		Update #Tax_Report 
		set Amount_Col_Final = @House_Rent_Amount - @Less_Salary_Amount --@HRA_Amount 
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Diff_Amount
		
		Update #Tax_Report 
		set Amount_Col_Final = @Two_Fifth_Salary --@Housing_Amount  
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Two_Fifth

		Update #Tax_Report 
		set Amount_Col_Final = @One_Half_Amount --@Housing_Amount  
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_One_Half

		
		
		Update #Tax_Report 
		set Amount_Col_Final = @HRA_Exemption 
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_HRA_Exemption 
				
		If @House_Rent_Amount - @Less_Salary_Amount < 0
			Begin
				Update #Tax_Report 
				set Amount_Col_Final = 0
				where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_HRA_Exemption
			End	
		
	RETURN
























