CREATE PROCEDURE [dbo].[SP_IT_TAX_PREPARATION_ALLOWANCE_EXEMPT_GET]
	@Emp_ID				numeric ,
	@Cmp_ID				numeric ,
	@Increment_id		numeric,
	@From_Date			datetime ,
	@To_date			datetime,
	@Month_Count		numeric ,
	@Allow_Exempt		numeric output,
	@IT_Declaration_Calc_On Varchar(30) = 'On_Regular'   --Added by Hardik 06/03/2019 --- 3 Types : "On_Regular", "On_Provisional", "On_Approved"	
AS
	
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON 
	
		Declare @Cont_HRA_Exemp		tinyint 
		Declare @Cont_Conv_Exemp	tinyint 
		Declare @Cont_Edu_Exemp		tinyint 
		Declare @Cont_Medical_Exemp	tinyint 
		
		---Nilay18062014---
		Declare @Cont_Petrol_Exem	   tinyint
		Declare @Cont_Telephone_Exem	tinyint
		Declare @Cont_BNP_Exem		   tinyint
		Declare @Cont_Meal_Exem	       tinyint
		Declare @Cont_Vehical_Exem	   tinyint
		Declare @Cont_Uniform_Exem	    tinyint
		---Nilay18062014---
		
		---Nilay18062014---
		Declare @Cont_LTA_Exemp	tinyint 
		---Nilay18062014---
		
		set @Cont_HRA_Exemp		=7
		set @Cont_Conv_Exemp	=9
		set @Cont_Edu_Exemp		= 8
		set @Cont_Medical_Exemp	= 11
		---Nilay18062014---
		set @Cont_LTA_Exemp	= 151
		set @Cont_Petrol_Exem	    = 160
		set @Cont_Telephone_Exem	= 161
		set @Cont_BNP_Exem		    = 162
		set @Cont_Meal_Exem	        = 163
		set @Cont_Vehical_Exem	    = 164
		set @Cont_Uniform_Exem	    = 165
		---Nilay18062014---
		
		Declare @Cont_Hostel_Exem As TINYINT
		Set @Cont_Hostel_Exem = 167
		
		Declare @AD_DEF_ID_Hostel As TINYINT
		Set @AD_DEF_ID_Hostel = 31
		
		Declare @Hostel_Exemption As Numeric(18,2)
		Set @Hostel_Exemption = 0
		
		Declare @Hostel_Monthly_Exempted_Amt As NUMERIC --- Mothly Hostel Exempted Amount For One Child
		Set @Hostel_Monthly_Exempted_Amt = 300
	
		DECLARE @EMP_CHILDRAN		numeric(18,2)
		DECLARE @HRA_AMOUNT			numeric(18,2) 
		DECLARE @CURRENT_HRA_AMOUNT numeric(18,2)
		
		Declare @Actual_Month		numeric(18,2) 
		Declare @MA_Exempted_Amount numeric(18,2)
		Declare @IT_MAX_LIMIT		numeric(18,2)
		Declare @Total_Conv_Amount  numeric(18,2)
		Declare @Settlement_Amount  numeric(18,2)		
		DECLARE @Conv_Exemption		numeric(18,2)
		Declare @IT_D_Amount		numeric(18,2)
		Declare @HRA_Exemption		numeric(18,2)
		Declare @Edu_Exemption		numeric(18,2)
		---Nilay18062014---
		Declare @LTA_Amount		numeric(18,2)
		DECLARE @CURRENT_LTA_AMOUNT numeric(18,2)
		Declare @Petrol_Exem_Amount	   numeric(18,2)
		Declare @Telephone_Exem_Amount	numeric(18,2)
		Declare @BNP_Exem_amount		   numeric(18,2)
		Declare @Meal_Exem_amount	       numeric(18,2)
		Declare @Vehical_Exem_Amount	   numeric(18,2)
		Declare @Uniform_Exem_Amount	    numeric(18,2)
		set @Petrol_Exem_Amount		  =0
		set @Telephone_Exem_Amount  	=0
		set @BNP_Exem_amount		   =0
		set @Meal_Exem_amount	       =0
		set @Vehical_Exem_Amount	   =0
		set @Uniform_Exem_Amount	    =0
		
		---Nilay18062014---
		Declare @Total_MA_Amount	numeric
		Declare @total_Educa		numeric(18,2)
		Declare @Date_Of_Join		datetime
		Declare @Left_date			datetime
		Declare @Left_date_Conv		datetime --Hardik 12/08/2014
		
		set @Edu_Exemption= 0
		set @Total_Conv_Amount =0
		set @Conv_Exemption =0
		set @MA_Exempted_Amount =0
		set @Total_MA_Amount = 0
		set @LTA_Amount =0
		
		
	-- Added by rohit on 08-apr-2014
	declare @Wages_Type as varchar(50)
	set @Wages_Type=''
	Declare @Day_Count as numeric(18,2)
	set @Day_Count = 1

	DECLARE @fin_year AS NVARCHAR(20)  
	Set @fin_year = ''
	SET @fin_year = CAST(YEAR(@From_Date) AS NVARCHAR) + '-' + CAST(YEAR(@To_Date) AS NVARCHAR)


	select 
	@wages_type=wages_type  	-- Added by rohit on 08-apr-2014
	from T0095_INCREMENT 
		where emp_id = @emp_id and 
		increment_id = @increment_id
	
	if @wages_type='Daily'
	begin 
	set @Day_Count = 26
	end
	-- Ended by rohit on 08-apr-2014
		
		select @Date_Of_Join = Date_Of_Join, @Left_date = isnull(Emp_Left_Date,@To_date),@Left_date_Conv = Emp_Left_Date
		From T0080_emp_Master where Emp_ID = @Emp_ID 								
		
							
		select @Actual_Month = Count(emp_Id) from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @Emp_ID and Month_End_Date  >=@From_Date and Month_End_Date <=@To_date
			--and Present_Days >=15
		
		------For Revice Allowance -- ******************************************
					
		CREATE TABLE #tblAllow_Revice
			(
				Cmp_ID			Numeric(18,0),
				Emp_ID			Numeric(18,0),
				Increment_ID    Numeric(18,0),
				AD_ID			Numeric(18,0),
				For_Date		DATETIME,
				E_AD_AMOUNT		NUMERIC(18,2),
				It_Estimated_Amount	NUMERIC(18,2)
				
			)
		
		INSERT INTO #tblAllow_Revice (Cmp_ID,Emp_ID,Increment_ID,AD_ID,For_Date,E_AD_AMOUNT,It_Estimated_Amount)
		SELECT CMP_ID, Emp_ID,Increment_ID,AD_ID,For_Date,E_AD_AMOUNT,It_Estimated_Amount
		FROM (
			SELECT EED.CMP_ID, EED.Emp_ID,EED.INCREMENT_ID,EED.AD_ID,ADM.AD_IT_DEF_ID, 
				--Case When Qry1.FOR_DATE IS NULL Then eed.FOR_DATE Else Qry1.FOR_DATE End As For_Date,
				--Case When Qry1.E_Ad_Amount IS NULL Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End As E_AD_Amount,
				 Case When Qry1.Increment_ID >= EED.INCREMENT_ID Then
					Case When Qry1.FOR_DATE IS null Then eed.FOR_DATE Else Qry1.FOR_DATE End 
				 Else
					eed.FOR_DATE End As For_Date,
				 Case When Qry1.Increment_ID >= EED.INCREMENT_ID  Then
					Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
				 Else
				 eed.e_ad_Amount End As E_Ad_Amount,
				 EED.It_Estimated_Amount,
				 ADM.AD_LEVEL
			FROM dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN                    
				   dbo.T0050_AD_MASTER ADM WITH (NOLOCK)  ON EEd.AD_ID = ADM.AD_ID   LEFT OUTER JOIN
					( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID	
						From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
						( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
							Where Emp_Id = @Emp_Id  and For_Date <= @To_Date
						 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
					) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID                  
			WHERE EED.EMP_ID = @emp_id And Adm.AD_ACTIVE = 1
					AND Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
					AND EED.increment_id = @increment_id And EED.CMP_ID = @Cmp_ID And EED.EMP_ID = @EMP_ID
					
			UNION ALL
			
			SELECT EED.CMP_ID, EED.EMP_ID, EED.Increment_ID , EED.AD_ID,ADM.AD_IT_DEF_ID , EED.FOR_DATE ,E_AD_Amount,
				0 AS It_Estimated_Amount,
				ADM.AD_LEVEL
			FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
				( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
					Where Emp_Id  = @Emp_Id  and For_Date <= @To_Date
					Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
			   INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK)  ON EEd.AD_ID = ADM.AD_ID                     
			WHERE emp_id = @emp_id And Adm.AD_ACTIVE = 1
					And EEd.ENTRY_TYPE = 'A'
					AND EED.increment_id = @increment_id And EED.CMP_ID = @Cmp_ID And EED.EMP_ID = @EMP_ID
					
		) Qry
		ORDER BY AD_LEVEL, INCREMENT_ID  DESC	
		
		
		--SELECT * FROM  #tblAllow_Revice
		
		--DROP TABLE #tblAllow_Revice
		
		------For Revice Allowance -- ******************************************
					
				
		

		if exists( select Emp_ID from #tblAllow_Revice eed inner join
					T0050_AD_MAster am WITH (NOLOCK) on eed.AD_ID= am.AD_ID and eed.CMP_ID =am.CMP_ID
					and AD_IT_DEF_ID = @Cont_Edu_Exemp where Emp_Id = @Emp_Id and Increment_id = @Increment_id )
			begin
				select @EMP_CHILDRAN = ISNULL(EMP_CHILDRAN,0) From T0095_INCREMENT WITH (NOLOCK) where Emp_ID= @Emp_ID and Increment_ID =@Increment_id
				
				select @total_Educa = isnull(sum(M_AD_Amount),0) from T0210_monthLy_AD_Detail mad WITH (NOLOCK) inner join T0050_AD_MASTER am WITH (NOLOCK) on mad.AD_ID = am.AD_ID 
					Where emp_ID = @Emp_ID and To_date >= @From_Date and To_date <= @To_Date and AD_IT_DEF_ID =@Cont_Edu_Exemp
				
				
				declare @Total_Edu_Ex as numeric  -- Added by rohit on 15052015
				--select @Total_Edu_Ex= SUM(E_AD_AMOUNT) from T0100_Emp_earn_Deduction eed inner join
				--	T0050_AD_MAster am on eed.AD_ID= am.AD_ID and eed.CMP_ID =am.CMP_ID
				--	and AD_IT_DEF_ID = @Cont_Edu_Exemp where Emp_Id = @Emp_Id and Increment_id = @Increment_id 
				
				Select @Total_Edu_Ex= SUM(E_AD_AMOUNT) From #tblAllow_Revice eed inner join
					T0050_AD_MAster am WITH (NOLOCK) on eed.AD_ID= am.AD_ID and eed.CMP_ID =am.CMP_ID
					and AD_IT_DEF_ID = @Cont_Edu_Exemp Where Emp_Id = @Emp_Id and Increment_id = @Increment_id
				

				If @EMP_CHILDRAN > 2
					SET @Edu_Exemption = 100 * (2 * (@Actual_Month + @Month_Count)  ) 
				else
					SET @Edu_Exemption = 100 * (@EMP_CHILDRAN * (@Actual_Month + @Month_Count)  ) 

			    if ((@Total_Edu_Ex * @Month_Count) + @total_Educa) > 0 -- Added by rohit on 14052015 
					begin
						if ((@Total_Edu_Ex * @Month_Count) + @total_Educa) < @Edu_Exemption   
							set @Edu_Exemption = ((@Total_Edu_Ex * @Month_Count) + @total_Educa) 
					end
			end
			

			

			if exists( select eed.Emp_ID from #Salary_AD eed inner join
					T0050_AD_MAster am WITH (NOLOCK) on eed.AD_ID= am.AD_ID and eed.CMP_ID =am.CMP_ID
					and AD_DEF_ID = @AD_DEF_ID_Hostel Inner Join
					#Tax_Report TR ON Tr.Ad_Id = eed.AD_ID	where eed.Emp_Id = @Emp_Id )
				begin
				
				    Declare @Hostel_Amount NUMERIC(18,2)
				    select @Hostel_Amount = Isnull(eed.Old_M_AD_Amount,0) + Isnull(eed.Month_Diff_Amount,0) 
						From #Salary_AD eed 
						inner join	T0050_AD_MAster am WITH (NOLOCK) on eed.AD_ID= am.AD_ID and eed.CMP_ID =am.CMP_ID
						Inner Join	#Tax_Report TR ON Tr.Ad_Id = eed.AD_ID
					where eed.Emp_Id = @Emp_Id and AD_DEF_ID = @AD_DEF_ID_Hostel
					
									
					Declare @IT_Declaration_Amount Numeric(18,2)			
					
					
					Select @IT_Declaration_Amount = Isnull(Amount,0)
					From T0070_IT_MASTER IM WITH (NOLOCK) 
						INNER JOIN T0100_IT_DECLARATION IED WITH (NOLOCK) ON IM.IT_ID = IED.IT_ID
					WHERE IED.EMP_ID = @EMP_ID AND IED.Financial_Year = @fin_year
						AND IM.IT_Def_ID = @Cont_Hostel_Exem
								
					if @Hostel_Amount > 0 and @IT_Declaration_Amount <> 0
						begin
							if @Hostel_Amount > @IT_Declaration_Amount
								Set @Hostel_Exemption = @IT_Declaration_Amount
							ELSE
								Set @Hostel_Exemption = @Hostel_Amount
						end
				End
			---Added by Hardik 12/08/2014 for Conveyance Exemption
		
			declare @St_date datetime
			declare @en_date datetime
			declare @m_st_date datetime
			declare @days numeric
			declare @month_days numeric
			Declare @Conv_on_Prorata tinyint --Hardik 11/08/2014
			Declare @Conv_Amount Numeric(18,2)
			Declare @Temp_From_Date as datetime
			Declare @Temp_To_Date as datetime
			Declare @Conv_Given_Amount Numeric(18,2)
			Declare @condition as tinyint
			Declare @E_ad_amount_Conv as numeric(18,2)
			Declare @Conv_Excempution_Limit as numeric(18,2)
			
			
			Declare @E_ad_amount_Conv_Estimated as numeric(18,2) -- Added by rohit on 14052015 
			Set @E_ad_amount_Conv_Estimated=0
			
			Select @Conv_on_Prorata = Setting_Value from T0040_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Setting_Name='Conveyance Tax Exemption based on prorate'
			--Set @Conv_on_Prorata = 1
			
			--Added condition by Hardik 23/04/2015 as Convence Exemption is changed from 1-Apr-2015
			If @From_Date < '01-Apr-2015'
				BEGIN
					Set @Conv_Amount = 800
					Set @Conv_Excempution_Limit = 9600
				End
			Else
				BEGIN
					Set @Conv_Amount = 1600
					Set @Conv_Excempution_Limit = 19200
				END
			
			Set @Conv_Given_Amount = 0
			Set @Temp_From_Date = @From_Date
			Set @condition = 0
			Set @E_ad_amount_Conv = 0
			Set @Days = 0
			Set @month_days = 0
			
			If (@From_Date <= @Date_Of_Join And @To_date >= @Date_Of_Join) And (@From_Date <= @Left_date_Conv And @To_date >= @Left_date_Conv)
				Set @condition = 1
			Else If (@From_Date <= @Date_Of_Join And @To_date >= @Date_Of_Join)
				Set @condition = 2
			Else If (@From_Date <= @Left_date_Conv And @To_date >= @Left_date_Conv)
				Set @condition = 3
		
		
		---Change Condition by Hardik 13/07/2017 as discussed with Chintan, as if employee recovered Car amount then only conveyance exemption will not given
		--'' Nirma : If Car Perq Amount then Not Calculate Convyance Exemption - Ankit 22072016 ''
		
		DECLARE @Flag_Perq_Car TINYINT
		SET @Flag_Perq_Car  = 0
		
		  
		
		IF EXISTS(SELECT 1 FROM T0240_Perquisites_Employee_Car WITH (NOLOCK) WHERE Emp_id = @Emp_id AND Financial_Year = @fin_year AND isnull(amount_recovered,0) > 0) --total_perq_amt <> 0) -- Change Condition by Hardik 13/07/2017
			BEGIN 
				SET @Flag_Perq_Car  = 1
			END	
		--''
		
		if exists( select Emp_ID from #tblAllow_Revice eed inner join
					T0050_AD_MAster am WITH (NOLOCK) on eed.AD_ID= am.AD_ID and eed.CMP_ID =am.CMP_ID
					and AD_IT_DEF_ID = @Cont_Conv_Exemp where Emp_Id = @Emp_Id and Increment_id = @Increment_id ) and @Flag_Perq_Car  = 0
			Begin
			
			
					If @From_Date < @Date_Of_Join 
						Set @Temp_From_Date = dbo.GET_MONTH_ST_DATE(Month(@Date_Of_Join),Year(@Date_Of_Join))
					
					If @Left_date_Conv < @To_date
						Set @To_date = dbo.GET_MONTH_END_DATE(Month(@Left_date_Conv),YEAR(@Left_date_Conv))
										
					
										
					While @Temp_From_Date <= @To_date
						Begin
						
						
							Set @Temp_To_Date = dbo.GET_MONTH_END_DATE(MONTH(@Temp_From_Date),Year(@Temp_From_Date))
							
							If exists(Select 1 from T0210_MONTHLY_AD_DETAIL mad WITH (NOLOCK) inner join T0050_AD_MASTER am WITH (NOLOCK) on mad.AD_ID = am.AD_ID 
										and mad.CMP_ID=  am.CMP_ID
										Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp  )
								Begin
									If @Conv_on_Prorata = 0
										Begin
											If @condition = 1
												Begin
													If exists(Select 1 From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Emp_ID = @Emp_ID And Month(Month_End_Date) = Month(@Temp_From_Date) And Year(Month_End_Date) = Year(@Temp_From_Date))
														Begin
															If Month(@Temp_From_Date) = MONTH(@Date_Of_Join) And YEAR(@Temp_From_Date) = YEAR(@Date_Of_Join)
																Begin
																	Select @Conv_Given_Amount = isnull(sum(Case When M_AD_Amount + ISNULL(M_Arear_Amount,0) > @Conv_Amount Then @Conv_Amount Else M_AD_Amount + ISNULL(M_Arear_Amount,0) End),0) 
																		From T0210_MONTHLY_AD_DETAIL mad WITH (NOLOCK) inner join T0050_AD_MASTER am WITH (NOLOCK) on mad.AD_ID = am.AD_ID 
																	and mad.CMP_ID=  am.CMP_ID
																	Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
																		and DAY(@Date_Of_Join) <= 15
																End
															else If Month(@Temp_From_Date) = MONTH(@Left_date_Conv) And YEAR(@Temp_From_Date) = YEAR(@Left_date_Conv)
																Begin
																	Select @Conv_Given_Amount = Case When isnull(sum(M_AD_Amount),0) + ISNULL(Sum(M_Arear_Amount),0)  > @Conv_Amount then @Conv_Amount Else isnull(sum(M_AD_Amount ),0) + + ISNULL(Sum(M_Arear_Amount),0) End
																		From T0210_MONTHLY_AD_DETAIL mad WITH (NOLOCK) inner join T0050_AD_MASTER am WITH (NOLOCK) on mad.AD_ID = am.AD_ID 
																	and mad.CMP_ID=  am.CMP_ID
																	Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
																		and DAY(@Date_Of_Join) > 15
																End
															Else
																Begin
																	Select @Conv_Given_Amount = isnull(sum(Case When M_AD_Amount + ISNULL(M_Arear_Amount,0) > @Conv_Amount Then @Conv_Amount Else M_AD_Amount + ISNULL(M_Arear_Amount,0) End),0) 
																		From T0210_MONTHLY_AD_DETAIL mad WITH (NOLOCK) inner join T0050_AD_MASTER am WITH (NOLOCK) on mad.AD_ID = am.AD_ID 
																	and mad.CMP_ID=  am.CMP_ID
																	Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
																End
														End
													
													Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
												End
											Else If @condition = 2
												Begin
													If exists(Select 1 From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Emp_ID = @Emp_ID And Month(Month_End_Date) = Month(@Temp_From_Date) And Year(Month_End_Date) = Year(@Temp_From_Date))
														Begin
															If Month(@Temp_From_Date) = MONTH(@Date_Of_Join) And YEAR(@Temp_From_Date) = YEAR(@Date_Of_Join)
																Begin
																	Select @Conv_Given_Amount = Case When isnull(sum(M_AD_Amount ),0) + ISNULL(Sum(M_Arear_Amount),0) > @Conv_Amount then @Conv_Amount Else isnull(sum(M_AD_Amount ),0) + ISNULL(Sum(M_Arear_Amount),0) End
																		From T0210_MONTHLY_AD_DETAIL mad WITH (NOLOCK) inner join T0050_AD_MASTER am WITH (NOLOCK) on mad.AD_ID = am.AD_ID 
																	and mad.CMP_ID=  am.CMP_ID
																	Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
																		and DAY(@Date_Of_Join) <= 15
																End
															Else
																Begin
																	Select @Conv_Given_Amount = Case When isnull(sum(M_AD_Amount ),0) + ISNULL(Sum(M_Arear_Amount),0) > @Conv_Amount then @Conv_Amount Else isnull(sum(M_AD_Amount ),0)+ ISNULL(Sum(M_Arear_Amount),0) End
																		From T0210_MONTHLY_AD_DETAIL mad WITH (NOLOCK) inner join T0050_AD_MASTER am WITH (NOLOCK) on mad.AD_ID = am.AD_ID 
																	and mad.CMP_ID=  am.CMP_ID
																	Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
																End
														End
													
													Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
												End
											Else If @condition = 3
												Begin
													If exists(Select 1 From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Emp_ID = @Emp_ID And Month(Month_End_Date) = Month(@Temp_From_Date) And Year(Month_End_Date) = Year(@Temp_From_Date))
														Begin
															If Month(@Temp_From_Date) = MONTH(@Left_date_Conv) And YEAR(@Temp_From_Date) = YEAR(@Left_date_Conv)
																Begin
																	Select @Conv_Given_Amount = Case When isnull(sum(M_AD_Amount ),0) + ISNULL(Sum(M_Arear_Amount),0)> @Conv_Amount then @Conv_Amount Else isnull(sum(M_AD_Amount ),0)+ ISNULL(Sum(M_Arear_Amount),0) End
																		From T0210_MONTHLY_AD_DETAIL mad WITH (NOLOCK) inner join T0050_AD_MASTER am WITH (NOLOCK) on mad.AD_ID = am.AD_ID 
																	and mad.CMP_ID=  am.CMP_ID
																	Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
																		and DAY(@Left_date_Conv) > 15
																End
															Else
																Begin
																
																	Select @Conv_Given_Amount = Case When isnull(sum(M_AD_Amount ),0)+ ISNULL(Sum(M_Arear_Amount),0) > @Conv_Amount then @Conv_Amount Else isnull(sum(M_AD_Amount ),0)+ ISNULL(Sum(M_Arear_Amount),0) End
																		From T0210_MONTHLY_AD_DETAIL mad WITH (NOLOCK) inner join T0050_AD_MASTER am WITH (NOLOCK) on mad.AD_ID = am.AD_ID 
																	and mad.CMP_ID=  am.CMP_ID
																	Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
																	
																End
														End
													
													Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
												End
											Else
												Begin
													If exists(Select 1 From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Emp_ID = @Emp_ID And Month(Month_End_Date) = Month(@Temp_From_Date) And Year(Month_End_Date) = Year(@Temp_From_Date))
														Begin
															Select @Conv_Given_Amount = Case When isnull(sum(M_AD_Amount ),0)+ ISNULL(Sum(M_Arear_Amount),0) > @Conv_Amount then @Conv_Amount Else isnull(sum(M_AD_Amount ),0)+ ISNULL(Sum(M_Arear_Amount),0) End
																From T0210_MONTHLY_AD_DETAIL mad WITH (NOLOCK) inner join T0050_AD_MASTER am WITH (NOLOCK) on mad.AD_ID = am.AD_ID 
															and mad.CMP_ID=  am.CMP_ID
															Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
														End
													
													Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
												End											
										End
									Else  -- below condition for Prorata
										Begin
											If exists(Select 1 From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Emp_ID = @Emp_ID And Month(Month_End_Date) = Month(@Temp_From_Date) And Year(Month_End_Date) = Year(@Temp_From_Date))
												Begin
													Select @Conv_Given_Amount = Case When isnull(sum(M_AD_Amount ),0)+ ISNULL(Sum(M_Arear_Amount),0) > @Conv_Amount then @Conv_Amount Else isnull(sum(M_AD_Amount ),0)+ ISNULL(Sum(M_Arear_Amount),0) End
														From T0210_MONTHLY_AD_DETAIL mad WITH (NOLOCK) inner join T0050_AD_MASTER am WITH (NOLOCK) on mad.AD_ID = am.AD_ID 
													and mad.CMP_ID=  am.CMP_ID
													Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
													
												End
												
											Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
										End
								End
							Else
								Begin
								
								
									If @Conv_on_Prorata = 0
										Begin
												--Select @E_ad_amount_Conv = Case When (E_AD_AMOUNT * @Day_Count) > @Conv_Amount then @Conv_Amount Else (E_AD_AMOUNT * @Day_Count) End
												Select @E_ad_amount_Conv = Case When (ISNULL(SUM(E_AD_AMOUNT),0) * @Day_Count) > @Conv_Amount then @Conv_Amount Else (ISNULL(SUM(E_AD_AMOUNT),0) * @Day_Count) End
													,@E_ad_amount_Conv_Estimated = Case When ( ISNULL(SUM(It_Estimated_Amount),0) * @Day_Count) > @Conv_Amount then @Conv_Amount Else (ISNULL(SUM(It_Estimated_Amount),0) * @Day_Count) End
											    From #tblAllow_Revice ED inner join T0050_AD_MASTER AD WITH (NOLOCK) on AD.AD_ID =  ed.AD_ID 
												where ad.AD_IT_DEF_ID = @Cont_Conv_Exemp  
												-- change by rohit because increment id already in set in parameter on 31052016 
												and ed.Increment_Id = @increment_id
													--and ed.Increment_Id = (select max(EED.Increment_Id) from T0100_EMP_EARN_DEDUCTION EED inner join 
													--					T0050_AD_MASTER AD on EED.AD_ID =  AD.AD_ID 
													--					where ad.AD_IT_DEF_ID = @Cont_Conv_Exemp and EMP_ID = @EMP_id and For_Date <= @Temp_To_Date)
												and emp_ID = @Emp_ID and For_Date <= @Temp_To_Date								
																							
												
												if @E_ad_amount_Conv_Estimated > @E_ad_amount_Conv
												begin
													set @E_ad_amount_Conv = @E_ad_amount_Conv_Estimated
												end	
													
												If @condition = 1
													Begin
														If Month(@Temp_From_Date) = MONTH(@Date_Of_Join) And YEAR(@Temp_From_Date) = YEAR(@Date_Of_Join) And DAY(@Date_Of_Join) <= 15
															Begin
																Set @Conv_Given_Amount = @E_ad_amount_Conv
															End
														else If Month(@Temp_From_Date) = MONTH(@Left_date_Conv) And YEAR(@Temp_From_Date) = YEAR(@Left_date_Conv) and DAY(@Left_date_Conv) > 15
															Begin
																Set @Conv_Given_Amount = @E_ad_amount_Conv
															End
														Else
															Begin
																Set @Conv_Given_Amount = @E_ad_amount_Conv
															End           
															

														Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
													End
												Else If @condition = 2
													Begin
														If Month(@Temp_From_Date) = MONTH(@Date_Of_Join) And YEAR(@Temp_From_Date) = YEAR(@Date_Of_Join)and DAY(@Date_Of_Join) <= 15
															Begin
																Set @Conv_Given_Amount = @E_ad_amount_Conv
															End           
														else if Month(@Temp_From_Date) = MONTH(@Date_Of_Join) And YEAR(@Temp_From_Date) = YEAR(@Date_Of_Join)and DAY(@Date_Of_Join) > 15
															Begin
																Set @Conv_Given_Amount = 0
															End           
														Else
															Begin
																Set @Conv_Given_Amount = @E_ad_amount_Conv
															End           
														Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
													End
												Else If @condition = 3
													Begin
														If Month(@Temp_From_Date) = MONTH(@Left_date_Conv) And YEAR(@Temp_From_Date) = YEAR(@Left_date_Conv)and DAY(@Left_date_Conv) > 15
															Begin
																Set @Conv_Given_Amount = @E_ad_amount_Conv
															End
														Else if Month(@Temp_From_Date) = MONTH(@Left_date_Conv) And YEAR(@Temp_From_Date) = YEAR(@Left_date_Conv)and DAY(@Left_date_Conv) <= 15
															Begin
																Set @Conv_Given_Amount =0
															End
														Else
															Begin
																Set @Conv_Given_Amount = @E_ad_amount_Conv
															End           
														
														Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
													End
												Else
													Begin
														Set @Conv_Given_Amount = @E_ad_amount_Conv
														Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
													End
											End

									Else -- below condition for Prorata
										Begin
											Set @month_days = DATEDIFF(d,@Temp_From_Date,@Temp_To_Date)+1										
											
											Select @E_ad_amount_Conv = Case When (E_AD_AMOUNT * @Day_Count) > @Conv_Amount then @Conv_Amount Else (E_AD_AMOUNT * @Day_Count) End
											From #tblAllow_Revice ED inner join T0050_AD_MASTER AD WITH (NOLOCK) on AD.AD_ID =  ed.AD_ID 
											where ad.AD_IT_DEF_ID = @Cont_Conv_Exemp  
											-- changed by rohit on 31052016 
												--and ed.INCREMENT_ID = (select max(EED.INCREMENT_ID) from #tblAllow_Revice EED inner join  
												--					T0050_AD_MASTER AD on EED.AD_ID =  AD.AD_ID 
												--					where ad.AD_IT_DEF_ID = @Cont_Conv_Exemp and EMP_ID = @EMP_id and For_Date <= @Temp_To_Date)
												and ed.INCREMENT_ID =@increment_id
												and emp_ID = @Emp_ID and For_Date <= @Temp_To_Date								
												
												If @condition = 1
													Begin
														If Month(@Temp_From_Date) = MONTH(@Date_Of_Join) And YEAR(@Temp_From_Date) = YEAR(@Date_Of_Join)
															Begin
																Set @days = DATEDIFF(d,@Temp_From_Date,@Date_Of_Join) + 1
																Set @Conv_Given_Amount = Round((@E_ad_amount_Conv / @month_days) * @days,0)
															End
														else If Month(@Temp_From_Date) = MONTH(@Left_date_Conv) And YEAR(@Temp_From_Date) = YEAR(@Left_date_Conv)
															Begin
																Set @days = DATEDIFF(d,@Temp_From_Date,@Left_date_Conv) + 1
																Set @Conv_Given_Amount = Round((@E_ad_amount_Conv / @month_days) * @days,0)
															End
														Else
															Begin
																Set @Conv_Given_Amount = @E_ad_amount_Conv
															End           
															

														Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
													End
												Else If @condition = 2
													Begin
														If Month(@Temp_From_Date) = MONTH(@Date_Of_Join) And YEAR(@Temp_From_Date) = YEAR(@Date_Of_Join)
															Begin
																Set @days = DATEDIFF(d,@Temp_From_Date,@Date_Of_Join) + 1
																Set @Conv_Given_Amount = Round((@E_ad_amount_Conv / @month_days) * @days,0)
															End           
														Else
															Begin
																Set @Conv_Given_Amount = @E_ad_amount_Conv
															End           
														Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
													End
												Else If @condition = 3
													Begin
														If Month(@Temp_From_Date) = MONTH(@Left_date_Conv) And YEAR(@Temp_From_Date) = YEAR(@Left_date_Conv)
															Begin
																Set @days = DATEDIFF(d,@Temp_From_Date,@Left_date_Conv) + 1
																Set @Conv_Given_Amount = Round((@E_ad_amount_Conv / @month_days) * @days,0)
															End
														Else
															Begin
																Set @Conv_Given_Amount = @E_ad_amount_Conv
															End           
														
														Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
													End
												Else
													Begin
														Set @Conv_Given_Amount = @E_ad_amount_Conv
														Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
													End
										End
								End

							Set @Conv_Given_Amount = 0
							Set @Days = 0
							Set @Month_Days = 0
							Set @E_ad_amount_Conv = 0
							Set @Temp_From_Date = DATEADD(MM,1,@Temp_From_Date)
						End
			End
			
			
			If @Total_Conv_Amount > @Conv_Excempution_Limit
				Set @Total_Conv_Amount = @Conv_Excempution_Limit
		
			Set @Conv_Exemption = @Total_Conv_Amount
			
		----START----Commented By Ankit For Allowance Amount get From Revice allowance	on 02062015-------------	
				
			--if exists( select Emp_ID from T0100_Emp_earn_Deduction eed inner join
			--		T0050_AD_MAster am on eed.AD_ID= am.AD_ID and eed.CMP_ID =am.CMP_ID
			--		and AD_IT_DEF_ID = @Cont_Conv_Exemp where Emp_Id = @Emp_Id and Increment_id = @Increment_id )
			--Begin
			
			
			--		If @From_Date < @Date_Of_Join 
			--			Set @Temp_From_Date = dbo.GET_MONTH_ST_DATE(Month(@Date_Of_Join),Year(@Date_Of_Join))
					
			--		If @Left_date_Conv < @To_date
			--			Set @To_date = dbo.GET_MONTH_END_DATE(Month(@Left_date_Conv),YEAR(@Left_date_Conv))
										
					
										
			--		While @Temp_From_Date <= @To_date
			--			Begin
						
						
			--				Set @Temp_To_Date = dbo.GET_MONTH_END_DATE(MONTH(@Temp_From_Date),Year(@Temp_From_Date))
							
			--				If exists(Select 1 from T0210_MONTHLY_AD_DETAIL mad inner join T0050_AD_MASTER am on mad.AD_ID = am.AD_ID 
			--							and mad.CMP_ID=  am.CMP_ID
			--							Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp  )
			--					Begin
			--						If @Conv_on_Prorata = 0
			--							Begin
			--								If @condition = 1
			--									Begin
			--										If exists(Select 1 From T0200_MONTHLY_SALARY Where Emp_ID = @Emp_ID And Month(Month_End_Date) = Month(@Temp_From_Date) And Year(Month_End_Date) = Year(@Temp_From_Date))
			--											Begin
			--												If Month(@Temp_From_Date) = MONTH(@Date_Of_Join) And YEAR(@Temp_From_Date) = YEAR(@Date_Of_Join)
			--													Begin
			--														Select @Conv_Given_Amount = isnull(sum(Case When M_AD_Amount + ISNULL(M_Arear_Amount,0) > @Conv_Amount Then @Conv_Amount Else M_AD_Amount + ISNULL(M_Arear_Amount,0) End),0) 
			--															From T0210_MONTHLY_AD_DETAIL mad inner join T0050_AD_MASTER am on mad.AD_ID = am.AD_ID 
			--														and mad.CMP_ID=  am.CMP_ID
			--														Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
			--															and DAY(@Date_Of_Join) <= 15
			--													End
			--												else If Month(@Temp_From_Date) = MONTH(@Left_date_Conv) And YEAR(@Temp_From_Date) = YEAR(@Left_date_Conv)
			--													Begin
			--														Select @Conv_Given_Amount = Case When isnull(sum(M_AD_Amount),0) + ISNULL(Sum(M_Arear_Amount),0)  > @Conv_Amount then @Conv_Amount Else isnull(sum(M_AD_Amount ),0) + + ISNULL(Sum(M_Arear_Amount),0) End
			--															From T0210_MONTHLY_AD_DETAIL mad inner join T0050_AD_MASTER am on mad.AD_ID = am.AD_ID 
			--														and mad.CMP_ID=  am.CMP_ID
			--														Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
			--															and DAY(@Date_Of_Join) > 15
			--													End
			--												Else
			--													Begin
			--														Select @Conv_Given_Amount = isnull(sum(Case When M_AD_Amount + ISNULL(M_Arear_Amount,0) > @Conv_Amount Then @Conv_Amount Else M_AD_Amount + ISNULL(M_Arear_Amount,0) End),0) 
			--															From T0210_MONTHLY_AD_DETAIL mad inner join T0050_AD_MASTER am on mad.AD_ID = am.AD_ID 
			--														and mad.CMP_ID=  am.CMP_ID
			--														Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
			--													End
			--											End
													
			--										Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
			--									End
			--								Else If @condition = 2
			--									Begin
			--										If exists(Select 1 From T0200_MONTHLY_SALARY Where Emp_ID = @Emp_ID And Month(Month_End_Date) = Month(@Temp_From_Date) And Year(Month_End_Date) = Year(@Temp_From_Date))
			--											Begin
			--												If Month(@Temp_From_Date) = MONTH(@Date_Of_Join) And YEAR(@Temp_From_Date) = YEAR(@Date_Of_Join)
			--													Begin
			--														Select @Conv_Given_Amount = Case When isnull(sum(M_AD_Amount ),0) + ISNULL(Sum(M_Arear_Amount),0) > @Conv_Amount then @Conv_Amount Else isnull(sum(M_AD_Amount ),0) + ISNULL(Sum(M_Arear_Amount),0) End
			--															From T0210_MONTHLY_AD_DETAIL mad inner join T0050_AD_MASTER am on mad.AD_ID = am.AD_ID 
			--														and mad.CMP_ID=  am.CMP_ID
			--														Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
			--															and DAY(@Date_Of_Join) <= 15
			--													End
			--												Else
			--													Begin
			--														Select @Conv_Given_Amount = Case When isnull(sum(M_AD_Amount ),0) + ISNULL(Sum(M_Arear_Amount),0) > @Conv_Amount then @Conv_Amount Else isnull(sum(M_AD_Amount ),0)+ ISNULL(Sum(M_Arear_Amount),0) End
			--															From T0210_MONTHLY_AD_DETAIL mad inner join T0050_AD_MASTER am on mad.AD_ID = am.AD_ID 
			--														and mad.CMP_ID=  am.CMP_ID
			--														Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
			--													End
			--											End
													
			--										Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
			--									End
			--								Else If @condition = 3
			--									Begin
			--										If exists(Select 1 From T0200_MONTHLY_SALARY Where Emp_ID = @Emp_ID And Month(Month_End_Date) = Month(@Temp_From_Date) And Year(Month_End_Date) = Year(@Temp_From_Date))
			--											Begin
			--												If Month(@Temp_From_Date) = MONTH(@Left_date_Conv) And YEAR(@Temp_From_Date) = YEAR(@Left_date_Conv)
			--													Begin
			--														Select @Conv_Given_Amount = Case When isnull(sum(M_AD_Amount ),0) + ISNULL(Sum(M_Arear_Amount),0)> @Conv_Amount then @Conv_Amount Else isnull(sum(M_AD_Amount ),0)+ ISNULL(Sum(M_Arear_Amount),0) End
			--															From T0210_MONTHLY_AD_DETAIL mad inner join T0050_AD_MASTER am on mad.AD_ID = am.AD_ID 
			--														and mad.CMP_ID=  am.CMP_ID
			--														Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
			--															and DAY(@Left_date_Conv) > 15
			--													End
			--												Else
			--													Begin
																
			--														Select @Conv_Given_Amount = Case When isnull(sum(M_AD_Amount ),0)+ ISNULL(Sum(M_Arear_Amount),0) > @Conv_Amount then @Conv_Amount Else isnull(sum(M_AD_Amount ),0)+ ISNULL(Sum(M_Arear_Amount),0) End
			--															From T0210_MONTHLY_AD_DETAIL mad inner join T0050_AD_MASTER am on mad.AD_ID = am.AD_ID 
			--														and mad.CMP_ID=  am.CMP_ID
			--														Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
																	
			--													End
			--											End
													
			--										Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
			--									End
			--								Else
			--									Begin
			--										If exists(Select 1 From T0200_MONTHLY_SALARY Where Emp_ID = @Emp_ID And Month(Month_End_Date) = Month(@Temp_From_Date) And Year(Month_End_Date) = Year(@Temp_From_Date))
			--											Begin
			--												Select @Conv_Given_Amount = Case When isnull(sum(M_AD_Amount ),0)+ ISNULL(Sum(M_Arear_Amount),0) > @Conv_Amount then @Conv_Amount Else isnull(sum(M_AD_Amount ),0)+ ISNULL(Sum(M_Arear_Amount),0) End
			--													From T0210_MONTHLY_AD_DETAIL mad inner join T0050_AD_MASTER am on mad.AD_ID = am.AD_ID 
			--												and mad.CMP_ID=  am.CMP_ID
			--												Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
			--											End
													
			--										Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
			--									End											
			--							End
			--						Else  -- below condition for Prorata
			--							Begin
			--								If exists(Select 1 From T0200_MONTHLY_SALARY Where Emp_ID = @Emp_ID And Month(Month_End_Date) = Month(@Temp_From_Date) And Year(Month_End_Date) = Year(@Temp_From_Date))
			--									Begin
			--										Select @Conv_Given_Amount = Case When isnull(sum(M_AD_Amount ),0)+ ISNULL(Sum(M_Arear_Amount),0) > @Conv_Amount then @Conv_Amount Else isnull(sum(M_AD_Amount ),0)+ ISNULL(Sum(M_Arear_Amount),0) End
			--											From T0210_MONTHLY_AD_DETAIL mad inner join T0050_AD_MASTER am on mad.AD_ID = am.AD_ID 
			--										and mad.CMP_ID=  am.CMP_ID
			--										Where emp_ID = @Emp_ID and To_date >= @Temp_From_Date and To_date <= @Temp_To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
													
			--									End
												
			--								Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
			--							End
			--					End
			--				Else
			--					Begin
								
								
			--						If @Conv_on_Prorata = 0
			--							Begin
			--									--Select @E_ad_amount_Conv = Case When (E_AD_AMOUNT * @Day_Count) > @Conv_Amount then @Conv_Amount Else (E_AD_AMOUNT * @Day_Count) End
			--									Select @E_ad_amount_Conv = Case When (ISNULL(SUM(E_AD_AMOUNT),0) * @Day_Count) > @Conv_Amount then @Conv_Amount Else (ISNULL(SUM(E_AD_AMOUNT),0) * @Day_Count) End
			--										,@E_ad_amount_Conv_Estimated = Case When ( ISNULL(SUM(It_Estimated_Amount),0) * @Day_Count) > @Conv_Amount then @Conv_Amount Else (ISNULL(SUM(It_Estimated_Amount),0) * @Day_Count) End
			--								    From T0100_EMP_EARN_DEDUCTION ED inner join T0050_AD_MASTER AD on AD.AD_ID =  ed.AD_ID 
			--									where ad.AD_IT_DEF_ID = @Cont_Conv_Exemp  
			--										and ed.Increment_Id = (select max(EED.Increment_Id) from T0100_EMP_EARN_DEDUCTION EED inner join -- Changed by Hardik 05/09/2014 for Same Date Increment
			--															T0050_AD_MASTER AD on EED.AD_ID =  AD.AD_ID 
			--															where ad.AD_IT_DEF_ID = @Cont_Conv_Exemp and EMP_ID = @EMP_id and For_Date <= @Temp_To_Date)
			--										and emp_ID = @Emp_ID and For_Date <= @Temp_To_Date								
																							
												
			--									if @E_ad_amount_Conv_Estimated > @E_ad_amount_Conv
			--									begin
			--										set @E_ad_amount_Conv = @E_ad_amount_Conv_Estimated
			--									end	
													
			--									If @condition = 1
			--										Begin
			--											If Month(@Temp_From_Date) = MONTH(@Date_Of_Join) And YEAR(@Temp_From_Date) = YEAR(@Date_Of_Join) And DAY(@Date_Of_Join) <= 15
			--												Begin
			--													Set @Conv_Given_Amount = @E_ad_amount_Conv
			--												End
			--											else If Month(@Temp_From_Date) = MONTH(@Left_date_Conv) And YEAR(@Temp_From_Date) = YEAR(@Left_date_Conv) and DAY(@Left_date_Conv) > 15
			--												Begin
			--													Set @Conv_Given_Amount = @E_ad_amount_Conv
			--												End
			--											Else
			--												Begin
			--													Set @Conv_Given_Amount = @E_ad_amount_Conv
			--												End           
															

			--											Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
			--										End
			--									Else If @condition = 2
			--										Begin
			--											If Month(@Temp_From_Date) = MONTH(@Date_Of_Join) And YEAR(@Temp_From_Date) = YEAR(@Date_Of_Join)and DAY(@Date_Of_Join) <= 15
			--												Begin
			--													Set @Conv_Given_Amount = @E_ad_amount_Conv
			--												End           
			--											else if Month(@Temp_From_Date) = MONTH(@Date_Of_Join) And YEAR(@Temp_From_Date) = YEAR(@Date_Of_Join)and DAY(@Date_Of_Join) > 15
			--												Begin
			--													Set @Conv_Given_Amount = 0
			--												End           
			--											Else
			--												Begin
			--													Set @Conv_Given_Amount = @E_ad_amount_Conv
			--												End           
			--											Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
			--										End
			--									Else If @condition = 3
			--										Begin
			--											If Month(@Temp_From_Date) = MONTH(@Left_date_Conv) And YEAR(@Temp_From_Date) = YEAR(@Left_date_Conv)and DAY(@Left_date_Conv) > 15
			--												Begin
			--													Set @Conv_Given_Amount = @E_ad_amount_Conv
			--												End
			--											Else if Month(@Temp_From_Date) = MONTH(@Left_date_Conv) And YEAR(@Temp_From_Date) = YEAR(@Left_date_Conv)and DAY(@Left_date_Conv) <= 15
			--												Begin
			--													Set @Conv_Given_Amount =0
			--												End
			--											Else
			--												Begin
			--													Set @Conv_Given_Amount = @E_ad_amount_Conv
			--												End           
														
			--											Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
			--										End
			--									Else
			--										Begin
			--											Set @Conv_Given_Amount = @E_ad_amount_Conv
			--											Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
			--										End
			--								End

			--						Else -- below condition for Prorata
			--							Begin
			--								Set @month_days = DATEDIFF(d,@Temp_From_Date,@Temp_To_Date)+1										
											
			--								Select @E_ad_amount_Conv = Case When (E_AD_AMOUNT * @Day_Count) > @Conv_Amount then @Conv_Amount Else (E_AD_AMOUNT * @Day_Count) End
			--								From T0100_EMP_EARN_DEDUCTION ED inner join T0050_AD_MASTER AD on AD.AD_ID =  ed.AD_ID 
			--								where ad.AD_IT_DEF_ID = @Cont_Conv_Exemp  
			--									and ed.INCREMENT_ID = (select max(EED.INCREMENT_ID) from T0100_EMP_EARN_DEDUCTION EED inner join  -- changed by Hardik 05/09/2014 for Same Date Increment
			--														T0050_AD_MASTER AD on EED.AD_ID =  AD.AD_ID 
			--														where ad.AD_IT_DEF_ID = @Cont_Conv_Exemp and EMP_ID = @EMP_id and For_Date <= @Temp_To_Date)
			--									and emp_ID = @Emp_ID and For_Date <= @Temp_To_Date								
												
			--									If @condition = 1
			--										Begin
			--											If Month(@Temp_From_Date) = MONTH(@Date_Of_Join) And YEAR(@Temp_From_Date) = YEAR(@Date_Of_Join)
			--												Begin
			--													Set @days = DATEDIFF(d,@Temp_From_Date,@Date_Of_Join) + 1
			--													Set @Conv_Given_Amount = Round((@E_ad_amount_Conv / @month_days) * @days,0)
			--												End
			--											else If Month(@Temp_From_Date) = MONTH(@Left_date_Conv) And YEAR(@Temp_From_Date) = YEAR(@Left_date_Conv)
			--												Begin
			--													Set @days = DATEDIFF(d,@Temp_From_Date,@Left_date_Conv) + 1
			--													Set @Conv_Given_Amount = Round((@E_ad_amount_Conv / @month_days) * @days,0)
			--												End
			--											Else
			--												Begin
			--													Set @Conv_Given_Amount = @E_ad_amount_Conv
			--												End           
															

			--											Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
			--										End
			--									Else If @condition = 2
			--										Begin
			--											If Month(@Temp_From_Date) = MONTH(@Date_Of_Join) And YEAR(@Temp_From_Date) = YEAR(@Date_Of_Join)
			--												Begin
			--													Set @days = DATEDIFF(d,@Temp_From_Date,@Date_Of_Join) + 1
			--													Set @Conv_Given_Amount = Round((@E_ad_amount_Conv / @month_days) * @days,0)
			--												End           
			--											Else
			--												Begin
			--													Set @Conv_Given_Amount = @E_ad_amount_Conv
			--												End           
			--											Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
			--										End
			--									Else If @condition = 3
			--										Begin
			--											If Month(@Temp_From_Date) = MONTH(@Left_date_Conv) And YEAR(@Temp_From_Date) = YEAR(@Left_date_Conv)
			--												Begin
			--													Set @days = DATEDIFF(d,@Temp_From_Date,@Left_date_Conv) + 1
			--													Set @Conv_Given_Amount = Round((@E_ad_amount_Conv / @month_days) * @days,0)
			--												End
			--											Else
			--												Begin
			--													Set @Conv_Given_Amount = @E_ad_amount_Conv
			--												End           
														
			--											Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
			--										End
			--									Else
			--										Begin
			--											Set @Conv_Given_Amount = @E_ad_amount_Conv
			--											Set @Total_Conv_Amount = @Total_Conv_Amount + @Conv_Given_Amount
			--										End
			--							End
			--					End

			--				Set @Conv_Given_Amount = 0
			--				Set @Days = 0
			--				Set @Month_Days = 0
			--				Set @E_ad_amount_Conv = 0
			--				Set @Temp_From_Date = DATEADD(MM,1,@Temp_From_Date)
			--			End
			--End
			
			
			--If @Total_Conv_Amount > @Conv_Excempution_Limit
			--	Set @Total_Conv_Amount = @Conv_Excempution_Limit
		
			--Set @Conv_Exemption = @Total_Conv_Amount
				
		----End----Commented By Ankit For Allowance Amount get From Revice allowance	on 02062015-------------			
	
		---Commented by Hardik and make new Calculation for Conveyance on 11/08/2014
			
		--if exists( select Emp_ID from T0100_Emp_earn_Deduction eed inner join
		--			T0050_AD_MAster am on eed.AD_ID= am.AD_ID and eed.CMP_ID =am.CMP_ID
		--			and AD_IT_DEF_ID = @Cont_Conv_Exemp where Emp_Id = @Emp_Id and Increment_id = @Increment_id )
		--	begin
			
		--	   declare @E_ad_amount_Conv numeric(18,2)
		--	   set @E_ad_amount_Conv = 0
			
		--		--select @Total_Conv_Amount = isnull(sum(M_AD_Amount),0) from T0210_monthLy_AD_Detail mad inner join T0050_AD_MASTER am on mad.AD_ID = am.AD_ID 
		--		--			and mad.CMP_ID=  am.CMP_ID
		--		--	Where emp_ID = @Emp_ID and To_date >= @From_Date and To_date <= @To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
				
		--		--Hardik 11/08/2014
		--		select @Total_Conv_Amount = isnull(sum(Case When M_AD_Amount > 800 Then 800 Else M_AD_Amount End),0) from T0210_monthLy_AD_Detail mad inner join T0050_AD_MASTER am on mad.AD_ID = am.AD_ID 
		--					and mad.CMP_ID=  am.CMP_ID
		--			Where emp_ID = @Emp_ID and To_date >= @From_Date and To_date <= @To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp

				
  --      select @E_ad_amount_Conv = (E_AD_AMOUNT * @Day_Count) from T0100_EMP_EARN_DEDUCTION ED inner join T0050_AD_MASTER AD on AD.AD_ID =  ed.AD_ID 
  --              where ad.AD_IT_DEF_ID = @Cont_Conv_Exemp  
		--			and ed.FOR_DATE = (select max(EED.FOR_DATE) from T0100_EMP_EARN_DEDUCTION EED inner join 
		--								T0050_AD_MASTER AD on EED.AD_ID =  AD.AD_ID 
		--								where ad.AD_IT_DEF_ID = @Cont_Conv_Exemp and EMP_ID = @EMP_id and For_Date <= @To_Date)
		--			and emp_ID = @Emp_ID and For_Date <= @To_Date			
				
				
				
		--		declare @St_date datetime
		--		declare @en_date datetime
		--		declare @m_st_date datetime
		--		declare @days numeric
		--		declare @month_days numeric
		--		Declare @Conv_on_Prorata tinyint --Hardik 11/08/2014
				
		--		Set @Conv_on_Prorata = 1 --Hardik 11/08/2014
				
		--		Declare @Month_Count_temp as numeric --Hardik 11/08/2014
		--		Set @Month_Count_temp = 0 --Hardik 11/08/2014

		--		If @Conv_on_Prorata = 0
		--			Begin
		--				if DAY(@Left_date) < 15 and @Month_Count > 0
		--					begin
		--						set @Month_Count_temp = 1
		--					end
		--			End

				
				
		--				if @E_ad_amount_Conv > 800
		--				  set @E_ad_amount_Conv = 800
						
		--				if @Date_Of_Join > @From_Date
		--					begin
		--						set @Conv_Exemption = @Total_Conv_Amount --+ (@E_ad_amount_Conv * (@Month_Count - 1))
		--						 --+ (@E_ad_amount_Conv * (@Month_Count))
																								
		--						set @St_date  = @Date_Of_Join
		--						set @en_date = dbo.GET_MONTH_END_DATE(month(@Date_Of_Join),year(@Date_Of_Join))
		--						set @m_st_date= dbo.GET_MONTH_ST_DATE(month(@Date_Of_Join),year(@Date_Of_Join))
		--						set @month_days = DATEDIFF(d,@m_St_date,@en_date) + 1
		--						set @days = DATEDIFF(d,@St_date,@en_date) + 1
								
		--						 declare @conv_prodata as numeric(18,2)
		--						 set @conv_prodata = isnull(((@E_ad_amount_Conv/@month_days) * @days),0)

								 
		--						if not exists (SELECT 1 from T0200_MONTHLY_SALARY where month(Month_end_Date) = month(@St_date) and year(Month_end_Date) = year(@St_date) and Emp_ID = @Emp_ID  )
		--							begin
									 
		--								set @Conv_Exemption = @Conv_Exemption + (@E_ad_amount_Conv * (@Month_Count - 1))  
										
		--								If @Conv_on_Prorata = 1
		--									Begin
		--										set @Conv_Exemption = @Conv_Exemption + @conv_prodata
		--									End
		--								Else
		--									Begin
		--										if @Date_Of_Join > @From_Date 	and DAY(@Date_Of_Join) <> 1  and DAY(@Date_Of_Join)  < 15 
		--											begin
		--												set @Conv_Exemption = @Conv_Exemption + 800
		--											end
		--										else if  @Date_Of_Join > @From_Date and DAY(@Date_Of_Join) <> 1  and DAY(@Date_Of_Join)  > 15 
		--											begin
														
		--												set @Conv_Exemption = @Conv_Exemption 
		--											end	
		--										else
		--											begin
		--												set @Conv_Exemption = @Conv_Exemption
		--											end										
		--									End
										
		--							end
		--						else	
		--							BEGIN
		--								Declare @month_convence numeric(18,2)
		--								set @month_convence = 0

		--								select @month_convence = isnull((Case When Isnull(M_AD_Amount,0) >800 Then 800 Else Isnull(M_AD_Amount,0)end),0) from T0210_monthLy_AD_Detail mad inner join T0050_AD_MASTER am on mad.AD_ID = am.AD_ID 
		--										and mad.CMP_ID=  am.CMP_ID
		--								Where emp_ID = @Emp_ID and  month(To_date) = month(@St_date) and year(To_date) = year(@St_date)  and AD_IT_DEF_ID =@Cont_Conv_Exemp
									
		--								If @Conv_on_Prorata = 1
		--									Begin
		--										if @month_convence > @conv_prodata
		--											begin													
		--												set @Conv_Exemption = @Conv_Exemption + (@E_ad_amount_Conv * (@Month_Count)) - @month_convence + @conv_prodata														
		--											end
		--										else
		--											begin
		--												set @Conv_Exemption = @Conv_Exemption + (@E_ad_amount_Conv * (@Month_Count))
		--											end
		--									End
		--								Else
		--									Begin
											
		--										if @Date_Of_Join > @From_Date 	and DAY(@Date_Of_Join) <> 1  and DAY(@Date_Of_Join)  < 15 
		--											begin
		--												set @Conv_Exemption = @Conv_Exemption + 800
		--											end
		--										else if  @Date_Of_Join > @From_Date and DAY(@Date_Of_Join) <> 1  and DAY(@Date_Of_Join)  > 15 
		--											begin
		--												set @Conv_Exemption = @Conv_Exemption - @month_convence
		--											end	
		--										else
		--											begin
		--												set @Conv_Exemption = @Conv_Exemption
		--											end										
		--									End
		--							end
		--					end
		--				else
		--					begin
		--						set @Conv_Exemption = @Total_Conv_Amount + (@E_ad_amount_Conv * (@Month_Count - @Month_Count_temp))
		--					End
					 
						
		--				if @Conv_Exemption > 9600 and @Left_date = @To_date
		--					begin
		--						set @Conv_Exemption = 9600
		--					end
		--				--else if @Conv_Exemption > (@Total_Conv_Amount + (@E_ad_amount_Conv * @Month_Count)) and @Left_date <  @To_date
		--				--else if (@Conv_Exemption >= (@Total_Conv_Amount + (@E_ad_amount_Conv * @Month_Count)) or @Month_Count = 0) and @Left_date <  @To_date
		--				else if @Left_date <  @To_date --Hardik 11/08/2014
		--					begin									 
		--							declare @last_month_amt numeric(18,2)
		--							set @last_month_amt = 0
									
		--							set @en_date  = @Left_date
		--							set @st_date = dbo.GET_MONTH_ST_DATE(month(@Left_date),year(@Left_date))
		--							set @m_st_date= dbo.GET_MONTH_END_DATE(month(@Left_date),year(@Left_date))
		--							set @month_days = DATEDIFF(d,@st_date,@m_st_date) + 1
		--							set @days = DATEDIFF(d,@St_date,@en_date) + 1
								
		--						 --declare @conv_prodata as numeric(18,2)
		--						 set @conv_prodata = isnull(round(((@E_ad_amount_Conv/@month_days) * @days),0),0)
								
		--								select @last_month_amt = isnull(sum(Case When M_AD_Amount > 800 Then 800 Else M_AD_Amount End),0) from T0210_monthLy_AD_Detail mad inner join 
		--									T0050_AD_MASTER am on mad.AD_ID = am.AD_ID inner join
		--									T0200_MONTHLY_SALARY ms on ms.Sal_Tran_ID = mad.Sal_Tran_ID
		--								and mad.CMP_ID=  am.CMP_ID
		--							Where mad.emp_ID = @Emp_ID and month(To_date) = month(@Left_date) and year(to_Date) = year(@Left_date) and AD_IT_DEF_ID =@Cont_Conv_Exemp
		--									--and ms.Sal_Cal_Days > 15 --Hardik 11/08/2014


		--								If @Conv_on_Prorata = 1
		--									Begin
		--										if @last_month_amt > @conv_prodata
		--											begin
		--												set @Conv_Exemption = @Conv_Exemption + (@E_ad_amount_Conv * (@Month_Count - @Month_Count_temp)) - @last_month_amt + @conv_prodata
		--											end
		--										else
		--											begin																										
		--												set @Conv_Exemption = @Conv_Exemption + (@E_ad_amount_Conv * (@Month_Count - @Month_Count_temp))
		--											end
		--									End
		--								Else
		--									Begin
		--										if DAY(@Left_date) < 15 
		--											begin
		--												set @Conv_Exemption = @Conv_Exemption - @last_month_amt
		--											end
		--										else if  DAY(@Left_date) > 15 
		--											begin
		--												set @Conv_Exemption = @Conv_Exemption 
		--											end	
		--										else
		--											begin
		--												set @Conv_Exemption = @Conv_Exemption
		--											end										
		--									End

		--							--declare @actual_month_temp numeric(18,2)
									
		--							--set @actual_month_temp = @Actual_Month

		--							--if @actual_month_temp  > 0 and @Month_Count = 0
		--							--   set @actual_month_temp = @actual_month_temp - 1	
							   
		--							--   if @last_month_amt = 0
		--							--	begin	
											
		--							--		set @St_date  = dbo.GET_MONTH_ST_DATE(month(@Left_date),year(@Left_date))
		--							--		set @en_date = dbo.GET_MONTH_END_DATE(month(@Left_date),year(@Left_date))
											
		--							--		set @month_days = DATEDIFF(d,@St_date,@en_date) + 1
		--							--		set @days = DATEDIFF(d,@St_date,@Left_date) + 1
											
		--							--		If @days > 15
		--							--			Begin 
		--							--				set @last_month_amt =  ((@E_ad_amount_Conv/@month_days) * @days)
		--							--			End
		--							--		Else
		--							--			Begin
		--							--				Set @last_month_amt = 0
		--							--			End
		--							--	end
		--							--set @Conv_Exemption = (@E_ad_amount_Conv * (@actual_month_temp) ) + @last_month_amt
		--					end
							
		--					if  @Conv_Exemption > (@E_ad_amount_Conv * (@Actual_Month + (@Month_Count - @Month_Count_temp) ))
		--								set @Conv_Exemption = (@E_ad_amount_Conv * (@Actual_Month + (@Month_Count - @Month_Count_temp) ))
									
 								
		--	end
			
		if exists( select Emp_ID from #tblAllow_Revice eed inner join
					T0050_AD_MAster am WITH (NOLOCK) on eed.AD_ID= am.AD_ID and eed.CMP_ID =am.CMP_ID
					and AD_IT_DEF_ID = @Cont_Medical_Exemp where Emp_Id = @Emp_Id and Increment_id = @Increment_id )
			begin
				
				Declare @E_ad_amount_Medical numeric(18,2)
			    set @E_ad_amount_Medical = 0
				select @Total_MA_Amount = isnull(sum(M_AD_Amount),0) from T0210_monthLy_AD_Detail mad WITH (NOLOCK) inner join T0050_AD_MASTER am WITH (NOLOCK) on mad.AD_ID = am.AD_ID 
							and mad.CMP_ID=  am.CMP_ID
					Where emp_ID = @Emp_ID and To_date >= @From_Date and To_date <= @To_Date and AD_IT_DEF_ID =@Cont_Medical_Exemp		
				
				
				
				--select @E_ad_amount_Medical = (E_AD_AMOUNT * @Day_count)
				--from T0100_EMP_EARN_DEDUCTION ED inner join
				--	T0050_AD_MASTER AD on AD.AD_ID =  ed.AD_ID 
				--            where ad.AD_IT_DEF_ID = @Cont_Medical_Exemp
				--	and ed.INCREMENT_ID = (select max(EED.INCREMENT_ID) from T0100_EMP_EARN_DEDUCTION EED inner join  --Chaged by Hardik 05/09/2014 for Same Date Increment
				--						T0050_AD_MASTER AD on EED.AD_ID =  AD.AD_ID 
				--						where ad.AD_IT_DEF_ID = @Cont_Medical_Exemp and EMP_ID = @EMP_id and For_Date <= @To_Date)
				--	and emp_ID = @Emp_ID and For_Date <= @To_Date	
				
				
				Select @E_ad_amount_Medical = (E_AD_AMOUNT * @Day_count)
				From #tblAllow_Revice ED inner join
					T0050_AD_MASTER AD WITH (NOLOCK) on AD.AD_ID =  ed.AD_ID 
                Where ad.AD_IT_DEF_ID = @Cont_Medical_Exemp
					and ed.INCREMENT_ID = (select max(EED.INCREMENT_ID) from T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) inner join  --Chaged by Hardik 05/09/2014 for Same Date Increment
										T0050_AD_MASTER AD WITH (NOLOCK) on EED.AD_ID =  AD.AD_ID 
										where ad.AD_IT_DEF_ID = @Cont_Medical_Exemp and EMP_ID = @EMP_id and For_Date <= @To_Date)
					and emp_ID = @Emp_ID and For_Date <= @To_Date	
				 
				if @E_ad_amount_Medical > 1250
				  set @E_ad_amount_Medical = 1250
				
				
					if @Date_Of_Join > @From_Date
							begin
								
								set @MA_Exempted_Amount = @Total_MA_Amount --+ (@E_ad_amount_Medical * (@Month_Count -1))
								
								declare @St_date_Med datetime
								declare @en_date_Med datetime
								declare @m_st_date_Med datetime
								declare @days_Med numeric
								declare @month_days_Med numeric
								
								set @St_date_Med  = @Date_Of_Join
								set @en_date_Med = dbo.GET_MONTH_END_DATE(month(@Date_Of_Join),year(@Date_Of_Join))
								set @m_st_date_Med= dbo.GET_MONTH_ST_DATE(month(@Date_Of_Join),year(@Date_Of_Join))
								set @month_days_Med = DATEDIFF(d,@m_St_date,@en_date) + 1
								set @days_Med = DATEDIFF(d,@St_date,@en_date) + 1
								
								declare @medi_prodata numeric(18,2)	
								
								set @medi_prodata = ((@E_ad_amount_Medical/@month_days_Med) * @days)
								
								--set @MA_Exempted_Amount = @MA_Exempted_Amount + @medi_prodata
								
								 
								if not exists (SELECT 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where month(Month_end_Date) = month(@St_date) and year(Month_end_Date) = year(@St_date) and Emp_ID = @Emp_ID  )
									begin
										set @MA_Exempted_Amount = @MA_Exempted_Amount + (@E_ad_amount_Medical * (@Month_Count -1))
										set @MA_Exempted_Amount = @MA_Exempted_Amount + @medi_prodata
									end
								else
									begin
									
										Declare @month_medical numeric(18,2)
										set @month_medical = 0
										
										select @month_medical = isnull((M_AD_Amount),0) from T0210_monthLy_AD_Detail mad WITH (NOLOCK) inner join T0050_AD_MASTER am WITH (NOLOCK) on mad.AD_ID = am.AD_ID 
												and mad.CMP_ID=  am.CMP_ID
										Where emp_ID = @Emp_ID and  month(To_date) = month(@St_date) and year(To_date) = year(@St_date)  and AD_IT_DEF_ID = @Cont_Medical_Exemp
										
										if @month_medical > @medi_prodata
											begin
												set @MA_Exempted_Amount = @Total_MA_Amount + (@E_ad_amount_Medical * (@Month_Count)) - @month_medical + @medi_prodata
											end
										else
											begin												 
												set @MA_Exempted_Amount = @Total_MA_Amount + (@E_ad_amount_Medical * (@Month_Count))
											end
									end
												 
							end
						else
							begin							
								set @MA_Exempted_Amount = @Total_MA_Amount + (@E_ad_amount_Medical * @Month_Count)
							end

						 
					 
					if @MA_Exempted_Amount > 15000 and @Left_date = @To_date
						begin
							set @MA_Exempted_Amount = 15000	
						end
					else if @MA_Exempted_Amount > (@E_ad_amount_Medical * @Month_Count)  and @Left_date <  @To_date
						begin  
						
							declare @last_month_amt_med numeric(18,2)
							set @last_month_amt_med = 0
							
							select @last_month_amt_med = isnull(sum(M_AD_Amount),0) from T0210_monthLy_AD_Detail mad WITH (NOLOCK) inner join T0050_AD_MASTER am WITH (NOLOCK) on mad.AD_ID = am.AD_ID 
							and mad.CMP_ID=  am.CMP_ID
							Where emp_ID = @Emp_ID and month(To_date) = month(@Left_date) and year(to_Date) = year(@Left_date) and AD_IT_DEF_ID =@Cont_Medical_Exemp
		
								declare @actual_month_med_temp numeric(18,2)
									
								set @actual_month_med_temp = @Actual_Month

								if @actual_month_med_temp  > 0 and @Month_Count = 0
								   set @actual_month_med_temp = @actual_month_med_temp - 1	


								     if @last_month_amt_med = 0
										begin	
											
											set @St_date  = dbo.GET_MONTH_ST_DATE(month(@Left_date),year(@Left_date))
											set @en_date = dbo.GET_MONTH_END_DATE(month(@Left_date),year(@Left_date))
											
											set @month_days = DATEDIFF(d,@St_date,@en_date) + 1
											set @days = DATEDIFF(d,@St_date,@Left_date) + 1
											
											set @last_month_amt_med =  ((@E_ad_amount_Medical/@month_days) * @days)
											
										end
							
							set @MA_Exempted_Amount = (@E_ad_amount_Medical * (@actual_month_med_temp) ) + @last_month_amt_med
							

							
						end		
						
						if  @MA_Exempted_Amount > (@E_ad_amount_Medical * (@Actual_Month + @Month_Count )) 
								set @MA_Exempted_Amount = (@E_ad_amount_Medical * (@Actual_Month + @Month_Count )) 	
			
			end		
			
			
			

		Select @HRA_Amount = isnull(sum(M_AD_Amount),0)  from T0210_monthLy_AD_Detail mad WITH (NOLOCK) inner join
					T0050_AD_MASTER am WITH (NOLOCK) on mad.AD_ID= am.AD_ID and mad.CMP_ID =am.CMP_ID
					and AD_IT_DEF_ID = @Cont_HRA_Exemp
		Where Emp_ID =@Emp_ID and To_Date >=@From_Date and To_date <=@To_Date
			
		----Commented By Ankit For Allowance Amount get From Revice allowance	on 02062015						  		
		--select @Current_HRA_Amount = (isnull(E_AD_AMOUNT,0) * @Day_Count) from T0100_Emp_earn_Deduction eed inner join
		--			T0050_AD_MASTER am on eed.AD_ID= am.AD_ID and
		--			eed.CMP_ID =am.CMP_ID and AD_IT_DEF_ID = @Cont_HRA_Exemp
		--			where eed.Emp_Id = @Emp_Id and Increment_id = @Increment_id 
		
		Select @Current_HRA_Amount = (isnull(E_AD_AMOUNT,0) * @Day_Count) 
		From #tblAllow_Revice eed inner join
				T0050_AD_MASTER am WITH (NOLOCK) on eed.AD_ID= am.AD_ID and
				eed.CMP_ID =am.CMP_ID and AD_IT_DEF_ID = @Cont_HRA_Exemp
		where eed.Emp_Id = @Emp_Id and Increment_id = @Increment_id 
		and am.AD_CALCULATE_ON <> 'Import' --Added by nilesh for HRA_IT_Arr in Acculife on 29122016 (Set DEF_ID HRA Exception)
							
				--	select @From_Date,@To_Date,@Cont_LTA_Exemp
			
		--if exists(select 1 from dbo.#Tax_Report where Default_Def_ID =@Cont_Medical_Exemp and reim		
		
		
				
		---Nilay18062014---			
		Select @LTA_Amount = isnull(sum(Tax_Free_Amount),0)  from T0210_Monthly_Reim_Detail mad WITH (NOLOCK) inner join
					T0050_AD_MASTER am WITH (NOLOCK) on mad.RC_ID= am.AD_ID and mad.CMP_ID =am.CMP_ID
					and AD_IT_DEF_ID = @Cont_LTA_Exemp
		Where Emp_ID =@Emp_ID and mad.for_Date >=@From_Date and for_Date <=@To_Date
		
		----Commented By Ankit For Allowance Amount get From Revice allowance	on 02062015			  		
		--select @CURRENT_LTA_AMOUNT = (isnull(E_AD_AMOUNT,0) * @Day_Count) from T0100_Emp_earn_Deduction eed inner join
		--			T0050_AD_MASTER am on eed.AD_ID= am.AD_ID and
		--			eed.CMP_ID =am.CMP_ID and AD_IT_DEF_ID = @Cont_LTA_Exemp
		--			where eed.Emp_Id = @Emp_Id and Increment_id = @Increment_id 
				
		select @CURRENT_LTA_AMOUNT = (isnull(E_AD_AMOUNT,0) * @Day_Count) from #tblAllow_Revice eed inner join
					T0050_AD_MASTER am WITH (NOLOCK) on eed.AD_ID= am.AD_ID and
					eed.CMP_ID =am.CMP_ID and AD_IT_DEF_ID = @Cont_LTA_Exemp
					where eed.Emp_Id = @Emp_Id and Increment_id = @Increment_id 
					
		Select @Petrol_Exem_Amount = isnull(sum(Tax_Free_Amount),0)  from T0210_Monthly_Reim_Detail mad WITH (NOLOCK) inner join
					T0050_AD_MASTER am WITH (NOLOCK) on mad.RC_ID= am.AD_ID and mad.CMP_ID =am.CMP_ID
					and AD_IT_DEF_ID = @Cont_Petrol_Exem
		Where Emp_ID =@Emp_ID and mad.for_Date >=@From_Date and for_Date <=@To_Date			
		
		
		
		Select @Telephone_Exem_Amount = isnull(sum(Tax_Free_Amount),0)  from T0210_Monthly_Reim_Detail mad WITH (NOLOCK) inner join
					T0050_AD_MASTER am WITH (NOLOCK) on mad.RC_ID= am.AD_ID and mad.CMP_ID =am.CMP_ID
					and AD_IT_DEF_ID = @Cont_Telephone_Exem
		Where Emp_ID =@Emp_ID and mad.for_Date >=@From_Date and for_Date <=@To_Date		
		
		Select @BNP_Exem_amount = isnull(sum(Tax_Free_Amount),0)  from T0210_Monthly_Reim_Detail mad WITH (NOLOCK) inner join
					T0050_AD_MASTER am WITH (NOLOCK) on mad.RC_ID= am.AD_ID and mad.CMP_ID =am.CMP_ID
					and AD_IT_DEF_ID = @Cont_BNP_Exem
		Where Emp_ID =@Emp_ID and mad.for_Date >=@From_Date and for_Date <=@To_Date	
		
		Select @Meal_Exem_amount = isnull(sum(Tax_Free_Amount),0)  from T0210_Monthly_Reim_Detail mad WITH (NOLOCK) inner join
					T0050_AD_MASTER am WITH (NOLOCK) on mad.RC_ID= am.AD_ID and mad.CMP_ID =am.CMP_ID
					and AD_IT_DEF_ID = @Cont_Meal_Exem
		Where Emp_ID =@Emp_ID and mad.for_Date >=@From_Date and for_Date <=@To_Date	
		
		Select @Vehical_Exem_Amount = isnull(sum(Tax_Free_Amount),0)  from T0210_Monthly_Reim_Detail mad WITH (NOLOCK) inner join
					T0050_AD_MASTER am WITH (NOLOCK) on mad.RC_ID= am.AD_ID and mad.CMP_ID =am.CMP_ID
					and AD_IT_DEF_ID = @Cont_Vehical_Exem
		Where Emp_ID =@Emp_ID and mad.for_Date >=@From_Date and for_Date <=@To_Date	
								
		Select @Uniform_Exem_Amount = isnull(sum(Tax_Free_Amount),0)  from T0210_Monthly_Reim_Detail mad WITH (NOLOCK) inner join
					T0050_AD_MASTER am WITH (NOLOCK) on mad.RC_ID= am.AD_ID and mad.CMP_ID =am.CMP_ID
					and AD_IT_DEF_ID = @Cont_Uniform_Exem
		Where Emp_ID =@Emp_ID and mad.for_Date >=@From_Date and for_Date <=@To_Date							
					
					
		---Nilay18062014---
		
		

		Exec dbo.SP_IT_TAX_HOUSING_EXEMPTION @Emp_ID,@From_Date,@To_Date,@Increment_ID,@HRA_Amount output,0,@HRA_Exemption output ,0,0,0,0,@Month_Count,@IT_Declaration_Calc_On
								
		set @Allow_Exempt = @Allow_Exempt + isnull(@IT_D_Amount,0)
		set @Allow_Exempt = @Edu_Exemption + @HRA_Exemption + @Conv_Exemption + @MA_Exempted_Amount + @Hostel_Exemption
		
		
		
		IF EXISTS(SELECT 1 from dbo.#Tax_Report where emp_ID=@emp_ID and default_Def_ID=@Cont_Medical_Exemp and Rimb_ID > 0)
		BEGIN
		
	
	
		---Nilay18062014---
				select @Total_MA_Amount = isnull(sum(Tax_Free_amount),0) from T0210_Monthly_Reim_Detail mad WITH (NOLOCK) inner join T0050_AD_MASTER am WITH (NOLOCK) on mad.RC_ID = am.AD_ID 
							and mad.CMP_ID=  am.CMP_ID and ISNULL(am.AD_NOT_EFFECT_SALARY,0) = 1 and isnull(am.Allowance_Type,'A')='R'
					Where emp_ID = @Emp_ID and mad.for_Date >= @From_Date and for_Date <= @To_Date and AD_IT_DEF_ID =@Cont_Medical_Exemp	
						
					
					
			SET @MA_Exempted_Amount=@Total_MA_Amount	
		
		
				---Nilay18062014---
			
		END
		
		----Start---Gratuity Exemption------Ankit 05052016
		DECLARE @Cont_Gratuity_Exemp	NUMERIC
		DECLARE @Gratuity_Exemp_Amount	NUMERIC(18,2) 
		DECLARE @Gratuity_Amount		NUMERIC(18,2) 
		
		SET @Cont_Gratuity_Exemp = 166
		SET @Gratuity_Amount = 0
		SET @Gratuity_Exemp_Amount = 0

		IF EXISTS(SELECT 1 FROM dbo.#Tax_Report WHERE emp_ID = @emp_ID AND default_Def_ID = @Cont_Gratuity_Exemp)
			BEGIN
				EXEC dbo.SP_IT_TAX_GRATUITY_EXEMPTION @Emp_ID,@Cmp_ID,@From_Date,@To_Date,@Increment_ID,@Gratuity_Amount OUTPUT,@Gratuity_Exemp_Amount OUTPUT 
			END
		
		UPDATE dbo.#Tax_Report SET Amount_Col_Final = @Gratuity_Exemp_Amount 
		WHERE Emp_ID =@Emp_ID AND Default_Def_ID = @Cont_Gratuity_Exemp
		
		----END  ---Gratuity Exemption------
		
		----Start---Leave Exemption-----Ankit 11082016
		
		DECLARE @Cont_Leave_Exemp		NUMERIC
		DECLARE @Leave_Exemp_Amount		NUMERIC(18,2) 
		
		SET @Cont_Leave_Exemp = 6
		SET @Leave_Exemp_Amount = 0
		
		IF EXISTS( SELECT 1 FROM  T0100_LEFT_EMP WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Is_Retire = 1 )
					AND EXISTS(SELECT 1 FROM dbo.#Tax_Report WHERE emp_ID = @emp_ID AND default_Def_ID = @Cont_Leave_Exemp and Is_Exempted = 1)
			BEGIN
				EXEC dbo.SP_IT_TAX_GRATUITY_EXEMPTION @Emp_ID,@Cmp_ID,@From_Date,@To_Date,@Increment_ID,@Leave_Exemp_Amount OUTPUT,@Leave_Exemp_Amount OUTPUT ,'LEAVE EXEMPTION'
				
				UPDATE dbo.#Tax_Report SET Amount_Col_Final = @Leave_Exemp_Amount 
				WHERE Emp_ID =@Emp_ID AND Default_Def_ID = @Cont_Leave_Exemp and Is_Exempted = 1
			END
			
		----End  ---Leave Exemption------
		
		Update dbo.#Tax_Report Set Amount_Col_Final = @MA_Exempted_Amount 
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Medical_Exemp
		
		

		Update dbo.#Tax_Report Set Amount_Col_Final =  @Conv_Exemption
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Conv_Exemp
		
		Update dbo.#Tax_Report Set Amount_Col_Final = @Edu_Exemption 
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Edu_Exemp
		
		
			
		--Added by Nilesh Patel on 15052019 For Hostel Exempted Ampunt 
		Update TR 
			SET TR.Amount_Col_Final = @Hostel_Exemption
		From dbo.#Tax_Report TR 
		Inner Join T0070_IT_MASTER IM ON TR.IT_ID = IM.IT_ID 
		Where Emp_ID =@Emp_ID and IM.IT_Def_ID = @Cont_Hostel_Exem
		--Added by Nilesh Patel on 15052019 For Hostel Exempted Ampunt
		
		---Nilay18062014---
		Update dbo.#Tax_Report Set Amount_Col_Final = @LTA_Amount 
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_LTA_Exemp


		

		Update dbo.#Tax_Report Set Amount_Col_Final = @Petrol_Exem_Amount 
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Petrol_Exem
		
		Update dbo.#Tax_Report Set Amount_Col_Final = @Telephone_Exem_Amount 
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Telephone_Exem
		
		Update dbo.#Tax_Report Set Amount_Col_Final = @BNP_Exem_amount 
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_BNP_Exem
		
		Update dbo.#Tax_Report Set Amount_Col_Final = @Meal_Exem_amount 
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Meal_Exem
		
		Update dbo.#Tax_Report Set Amount_Col_Final = @Vehical_Exem_Amount 
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Vehical_Exem
		
		Update dbo.#Tax_Report Set Amount_Col_Final = @Uniform_Exem_Amount 
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Uniform_Exem

 	    ---Nilay18062014---
 	  
		Declare @Setting_Val as tinyint
		Set @Setting_Val = 0
		
		SELECT @Setting_Val = Isnull(Setting_Value,0) 
		FROM T0040_SETTING WITH (NOLOCK) Where Setting_Name ='Enable Quarterly Reimburstment Process.' and Cmp_ID = @Cmp_ID
  		--- Added by Hardik 12/02/2016 for Exempt Amount for Reimbursement with out Def Id
		Update dbo.#Tax_Report Set Amount_Col_Final = Tax_Free_amount From #Tax_Report Tr Inner join (
		Select isnull(sum(Tax_Free_Amount),0) As Tax_Free_Amount,T.Rimb_Id
		from T0210_Monthly_Reim_Detail mad WITH (NOLOCK) inner join
			T0050_AD_MASTER am WITH (NOLOCK) on mad.RC_ID= am.AD_ID and mad.CMP_ID =am.CMP_ID Inner JOIN
			#Tax_Report T on Mad.RC_ID= T.Rimb_Id  and mad.Emp_ID=t.emp_id And Isnull(Is_Exempted,0)=1 And Isnull(Exem_Againt_Row_ID,0)=0  
		Where mad.Emp_ID =@Emp_ID and mad.for_Date >=@From_Date and mad.for_Date <=@To_Date and isnull(T.Default_Def_Id,0) = 0 AND 1 = (Case WHEN @Setting_Val = 1 AND Isnull(AM.IS_Quarterly_Reim,0) = 1  Then Isnull(AM.IS_Quarterly_Reim,0) ELSE 1 END) 
		Group by T.Rimb_Id)Qry  on Tr.Rimb_Id = Qry.Rimb_Id and Tr.Emp_Id = @Emp_Id And Isnull(Is_Exempted,0)=1

		
		-- CONDITION ADDED BY RAJPUT ON 22032018 ( INDUCTOTHERM CLIENT ISSUE - MEDICAL AMOUNT WAS COME WRONG PROBLEM WAS "IT_Row_no" ADD TO CLIENT SIDE BUT NOT ADD IN LIVE/VERSION PROJECT WITH CONDITION IN STORE PROCEDURE BY "ROHIT PATEL" HE WAS ADDED ON 20032017 AT CLIENT SIDE.
		-- Code is comment by nilesh patel on 17092018 -- After Discussion with Hardik bhai And Rohit Rajput -- if we found any case we will check it 
		/*
		Update dbo.#Tax_Report Set Amount_Col_Final = Apr_amount From #Tax_Report Tr Inner join (
		select SUM(RDD.Apr_Amount) as Apr_amount,MRD.RC_ID,RDD.AD_Exp_Master_ID,MRD.Emp_ID,AELM.IT_Row_no 
		from dbo.T0210_Monthly_Reim_Detail MRD
		inner JOIN T0120_RC_Approval RA ON MRD.RC_apr_ID = RA.RC_APR_ID
		inner JOIN  T0110_RC_Dependant_Detail RDD on RA.RC_App_ID = RDD.RC_APP_ID
		INNER JOIN T0050_AD_Expense_Limit_Master AELM ON RDD.AD_Exp_Master_ID = AELM.AD_Exp_Master_ID
		where MRD.for_Date >=@from_date and MRD.for_Date <=@to_date
		 and MRD.Emp_ID=@emp_id
		-- and RDD.AD_Exp_Master_ID = 16
		GROUP BY MRD.RC_ID,RDD.AD_Exp_Master_ID,MRD.Emp_ID ,AELM.IT_Row_no 
		)Qry  on Tr.Row_id= Qry.it_row_no and Tr.Emp_Id = @Emp_Id And Isnull(Is_Exempted,0)=1 
		*/
		
		IF @Setting_Val = 1 -- Added By Nilesh Patel on 20092018
			Begin
				if Object_ID('tempdb..#Quarterly_Carry_Fwd') is not null
					Drop TABLE #Quarterly_Carry_Fwd
					
					Create Table #Quarterly_Carry_Fwd
					(
						Row_ID Numeric(18,0),
						Cmp_ID Numeric(18,0),
						Emp_ID Numeric(18,0),
						AD_ID Numeric(18,0),
						Reim_Quar_ID Numeric,
						Q_From_Date Datetime,
						Q_To_Date Datetime,
						Earning_Amt Numeric(18,2),
						Claim_Amt Numeric(18,2),
						Exception_Amt Numeric(18,2),
						Carry_Fwd Numeric(18,2),
						Is_Taxable_Quarter tinyint,
						Max_Monthly_Limit Numeric(18,2)
					)
					
					DECLARE @GRD_ID NUMERIC
					SET @GRD_ID = 0
					
					SELECT @GRD_ID = GRD_ID 
						FROM T0095_INCREMENT WITH (NOLOCK) 
					WHERE EMP_ID = @EMP_ID AND INCREMENT_ID = @INCREMENT_ID
					Insert Into #Quarterly_Carry_Fwd
					Select ROW_NUMBER() OVER (ORDER BY TR.EMP_ID,QR.AD_ID,QR.Reim_Quar_ID), AM.CMP_ID,TR.EMP_ID,AM.AD_ID,QR.Reim_Quar_ID,QR.From_Date,QR.To_Date,0,0,0,0,Isnull(QR.Is_Taxable_Quarter,0),(CASE WHEN ISNULL(GA.AD_NON_TAX_LIMIT,0) = 0 THEN 0 ELSE ISNULL(GA.AD_NON_TAX_LIMIT,0)/12 END)
						From #Tax_Report TR 
					Inner JOIN T0050_AD_MASTER AM WITH (NOLOCK) 
						ON TR.Rimb_ID = AM.AD_ID 
					Inner JOIN T0060_Reim_Quarter_Period QR 
						ON AM.AD_ID = QR.AD_ID and QR.Fin_Year = CAST(YEAR(@From_Date) AS NVARCHAR) + '-' + CAST(YEAR(@To_Date) AS NVARCHAR)
					Left Outer JOIN T0120_GRADEWISE_ALLOWANCE GA WITH (NOLOCK) ON GA.AD_ID = AM.AD_ID AND GA.GRD_ID = @GRD_ID
					Where AM.IS_Quarterly_Reim = 1 and TR.Emp_Id = @Emp_Id And Isnull(TR.Is_Exempted,0)=1 --and Isnull(QR.Is_Taxable_Quarter,0) = 1
					Order BY AM.AD_ID,QR.Reim_Quar_ID
					
					--For Earning Amount 13092018 -- Start
					Update QRT
						SET QRT.Earning_Amt = Qry.ReimAmount
					From #Quarterly_Carry_Fwd QRT
					Inner Join(
								Select SUM(
										    (CASE WHEN ISNULL(MAD.REIMAMOUNT,0) > ISNULL(QR.MAX_MONTHLY_LIMIT,0) AND ISNULL(QR.MAX_MONTHLY_LIMIT,0) <> 0 THEN
												    ISNULL(QR.MAX_MONTHLY_LIMIT,0)  
												  ELSE ISNULL(MAD.REIMAMOUNT,0) 
											 END)
											) as ReimAmount,
								MAD.Emp_ID,MAD.AD_ID,QR.Reim_Quar_ID
									From #Quarterly_Carry_Fwd QR 
								INNER JOIN T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) 
								ON QR.AD_ID = MAD.AD_ID and QR.Emp_ID = MAD.Emp_ID
									WHERE MAD.For_Date >= QR.Q_From_Date AND MAD.To_date <= QR.Q_To_Date AND QR.Cmp_ID = @Cmp_ID
								Group BY MAD.Emp_ID,MAD.AD_ID,QR.Reim_Quar_ID
							  ) as Qry
					ON QRT.Emp_ID = Qry.Emp_ID and QRT.AD_ID = Qry.AD_ID and QRT.Reim_Quar_ID = Qry.Reim_Quar_ID and Isnull(QRT.Is_Taxable_Quarter,0) = 1
					--For Earning Amount 13092018 -- End
					
					Update QRT
						SET QRT.Claim_Amt = Qry.ReimAmount
					From #Quarterly_Carry_Fwd QRT
					Inner Join(
								Select SUM(Isnull(MRD.Tax_Free_amount,0)) as ReimAmount,MRD.Emp_ID,MRD.RC_ID,QR.Reim_Quar_ID
									From #Quarterly_Carry_Fwd QR 
								INNER JOIN T0210_Monthly_Reim_Detail MRD WITH (NOLOCK) 
								ON QR.AD_ID = MRD.RC_ID and QR.Emp_ID = MRD.Emp_ID
								INNER JOIN T0120_RC_Approval RA WITH (NOLOCK) ON RA.RC_APR_ID = MRD.RC_APR_ID
									WHERE RA.Reim_Quar_ID = QR.Reim_Quar_ID AND QR.Cmp_ID = @Cmp_ID
								Group BY MRD.Emp_ID,MRD.RC_ID,QR.Reim_Quar_ID
							  ) as Qry
					ON QRT.Emp_ID = Qry.Emp_ID and QRT.AD_ID = Qry.RC_ID and QRT.Reim_Quar_ID = Qry.Reim_Quar_ID and Isnull(QRT.Is_Taxable_Quarter,0) = 1
					
					
					UPDATE QR
						SET QR.Exception_Amt = (CASE WHEN Isnull(TR.E_AD_AMOUNT,0) > ISNULL(QR.MAX_MONTHLY_LIMIT,0) THEN ISNULL(QR.MAX_MONTHLY_LIMIT,0) ELSE Isnull(TR.E_AD_AMOUNT,0) END) * ISNULL((DATEDIFF(MM,QR.Q_From_Date,QR.Q_To_Date) + 1),0)
					From #Quarterly_Carry_Fwd QR 
					INNER JOIN #tblAllow_Revice TR 
					ON QR.Emp_ID = TR.Emp_ID AND QR.AD_ID = TR.AD_ID --and Isnull(QR.Is_Taxable_Quarter,0) = 0
					
					--Select * From #Quarterly_Carry_Fwd Where AD_ID = 782
					
					--UPDATE QR
					--	SET QR.Carry_Fwd = (Case When QR.Claim_Amt > QR.Earning_Amt Then QR.Claim_Amt - QR.Earning_Amt Else 0 END)--,
					--		--QR.Exception_Amt = (CASE WHEN QR.Claim_Amt = 0 THEN QR.Earning_Amt ELSE (Case When QR.Claim_Amt > QR.Earning_Amt Then QR.Earning_Amt ELSE QR.Claim_Amt END) END)
					--		--QR.Exception_Amt = (Case When QR.Claim_Amt > QR.Earning_Amt Then QR.Earning_Amt ELSE (Case When QR.Claim_Amt = 0 THEN QR.Exception_Amt ELSE QR.Claim_Amt END)  END)
					--From #Quarterly_Carry_Fwd QR 
					--Where Isnull(QR.Is_Taxable_Quarter,0) = 1
					
					
					Declare @Qur_Emp_ID Numeric
					Set @Qur_Emp_ID = 0
					
					Declare @Qur_AD_ID Numeric
					Set @Qur_AD_ID = 0
					
					Declare @Qur_Reim_ID Numeric
					Set @Qur_Reim_ID = 0
					
					Declare @Carry_FWD Numeric(18,2)
					Set @Carry_FWD = 0
					
					Declare @Row_ID Numeric(18,0)
					Set @Row_ID = 0
					
					Declare @Prev_AD_ID Numeric(18,0)
					Set @Prev_AD_ID = 0
					
					DECLARE Cur_Quarterly CURSOR FOR 
						Select Emp_ID,AD_ID,Reim_Quar_ID,Row_ID From #Quarterly_Carry_Fwd Order BY Emp_ID,Reim_Quar_ID,Row_ID  --Where AD_ID = 781
					Open Cur_Quarterly 
					fetch next from Cur_Quarterly into @Qur_Emp_ID,@Qur_AD_ID,@Qur_Reim_ID,@Row_ID
						While @@fetch_Status = 0
							Begin
								
								If @Prev_AD_ID = @Qur_AD_ID
									Begin
										Update QR
											Set 
												QR.Claim_Amt = QR.Claim_Amt + @Carry_FWD
										From #Quarterly_Carry_Fwd QR 
										Where Emp_ID = @Qur_Emp_ID and Reim_Quar_ID = @Qur_Reim_ID and AD_ID = @Qur_AD_ID
									End
								
								IF @Month_Count = 0 -- For Form-16 
									Begin
										Update QR
											Set 
												QR.Exception_Amt = 
														(Case When QR.Claim_Amt > QR.Earning_Amt and QR.Claim_Amt <> 0 Then 
																QR.Earning_Amt 
															 Else
																QR.Claim_Amt
														 End),
												QR.Carry_Fwd = 
														(Case When QR.Claim_Amt > QR.Earning_Amt Then 
																QR.Claim_Amt - QR.Earning_Amt
															  Else
																0
														 End)
										From #Quarterly_Carry_Fwd QR 
										Where Emp_ID = @Qur_Emp_ID and Reim_Quar_ID = @Qur_Reim_ID and AD_ID = @Qur_AD_ID AND QR.Is_Taxable_Quarter = 1
									End
								Else  -- For IT Computation with Exception Amount
									Begin
										Update QR
											Set 
												QR.Exception_Amt = 
														(Case When QR.Claim_Amt > QR.Exception_Amt and QR.Claim_Amt <> 0 Then 
																QR.Exception_Amt 
															 Else
																QR.Claim_Amt
														 End),
												QR.Carry_Fwd = 
														(Case When QR.Claim_Amt > QR.Exception_Amt Then 
																QR.Claim_Amt - QR.Exception_Amt
															  Else
																0
														 End)
										From #Quarterly_Carry_Fwd QR 
										Where Emp_ID = @Qur_Emp_ID and Reim_Quar_ID = @Qur_Reim_ID and AD_ID = @Qur_AD_ID AND QR.Is_Taxable_Quarter = 1
									End
								
								Select @Carry_FWD = Carry_Fwd From #Quarterly_Carry_Fwd Where Emp_ID = @Qur_Emp_ID and Reim_Quar_ID = @Qur_Reim_ID and AD_ID = @Qur_AD_ID
								
								Set @Prev_AD_ID = @Qur_AD_ID
								
								fetch next from Cur_Quarterly into @Qur_Emp_ID,@Qur_AD_ID,@Qur_Reim_ID,@Row_ID
							End
					Close Cur_Quarterly
					Deallocate Cur_Quarterly
					
					Update TR
						SET TR.Amount_Col_Final = Exc_Amt
					From #Tax_Report TR 
						INNER JOIN 
						(
							Select SUM(Isnull(QR.Exception_Amt,0)) as Exc_Amt,QR.AD_ID,QR.Emp_ID
								FROM #Quarterly_Carry_Fwd QR
								WHERE QR.Is_Taxable_Quarter <> (CASE WHEN @Month_Count = 0 THEN 0 ELSE 2 END)
							GROUP BY QR.AD_ID,QR.Emp_ID
						) as Qry
					ON TR.Emp_ID = Qry.Emp_ID and TR.Rimb_ID = Qry.AD_ID 
					WHERE  Isnull(TR.Is_Exempted,0)=1 
					
			End
 	  	
 	  	DROP TABLE #tblAllow_Revice
 	  	
	RETURN
