CREATE PROCEDURE [dbo].[SP_IT_TAX_ALLOW_DEDU_CALCULATION]
	@Emp_Id					Numeric ,
	@cmp_ID					Numeric ,
	@Increment_ID			Numeric ,
	@From_Date				Datetime,
	@To_Date				Datetime ,
	@Month_Diff				tinyint,
	@Month_Date Datetime
	
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON 

	Declare @Left_date			datetime
	Declare @join_date			datetime
	Declare @Cont_Basic_Sal tinyint
	Declare @Cont_PT_Amount tinyint 
	set @Cont_Basic_Sal =1
	set @Cont_PT_Amount =10

	select  @Left_date = isnull(Emp_Left_Date,@To_date) ,@join_date = Date_Of_Join  From T0080_emp_Master WITH (NOLOCK) where Emp_ID = @Emp_ID 
	
	DECLARE @AD_DEF_ID  NUMERIC  
	DECLARE @IT_DEF_ID	NUMERIC
	DECLARE @PF_DEF_ID	NUMERIC 
	DECLARE @ESIC_DEF_ID	NUMERIC 
		
	SET  @IT_DEF_ID = 1
	SET  @PF_DEF_ID = 2
	SET  @ESIC_DEF_ID = 3
	
	if isnull(@Month_Date,'')=''
		set @Month_Date =@To_Date

-- Added by rohit on 11052015

		Declare @It_Estimated_Setting as Tinyint
		set @It_Estimated_Setting=0
		select @It_Estimated_Setting = isnull(Setting_Value,0) from T0040_SETTING WITH (NOLOCK) where Setting_Name ='Enable Import Option for Estimated Amount' and Cmp_ID=@cmp_ID
		declare @It_Estimated_Amount as Numeric(18,2)
		set @It_Estimated_Amount = 0

		Declare @Setting_Reim as tinyint
		set @Setting_Reim =0
		select @Setting_Reim = isnull(Setting_Value,0)  from T0040_SETTING WITH (NOLOCK) where Setting_Name ='Reimbershment Shows in IT Computation' and Cmp_ID= @cmp_id
					

-- Ended by rohit on 11052015	

		 
	declare @AD_ID						numeric
	declare @M_AD_Percentage			numeric(12,5)
	declare @M_AD_Amount				numeric(18,5)
	declare @M_AD_Flag					varchar(1)
	declare @Max_Upper					numeric(27,5)
	Declare @varCalc_On					varchar(50)
	Declare @Calc_On_Allow_Dedu			numeric(18,2) 
	Declare @Other_Allow_Amount			numeric(18,2)
	Declare @M_AD_Actual_Per_Amount		numeric(18,5)
	declare @Temp_Percentage			numeric(18,5)
	Declare @Type						varchar(20)
	Declare @M_AD_Tran_ID				numeric
	Declare @Wages_type					varchar(10)
	Declare @Basic_Salary				Numeric(25,5)
	Declare @Gross_Salary_ProRata		Numeric(25,5)
	Declare @CTC_ProRata				Numeric(25,5)
	Declare @M_AD_NOT_EFFECT_ON_PT		tinyint
	Declare @M_AD_NOT_EFFECT_SALARY		tinyint
	Declare @M_AD_EFFECT_ON_OT			tinyint 
	Declare @M_AD_EFFECT_ON_EXTRA_DAY	tinyint
	Declare @AD_Name					varchar(20)
	Declare @M_AD_effect_on_Late		tinyint
	Declare @Emp_Full_Pf				tinyint
	Declare @Emp_PT						tinyint
	Declare @PF_Limit					int
	Declare @old_M_AD_Amount			numeric 
	Declare @Branch_ID					numeric 
	Declare @ESIC_Limit					int
	Declare @PT_Calculated_Amount		numeric
	Declare @old_PT_Amount				int
	Declare @old_Salary_Amount			numeric	
	Declare @PT_Amount					int 
	Declare @AD_Effect_On_TDs			Int
	declare @temp_month_diff		numeric
	declare @cur_increment_id numeric
	Declare @AD_CAL_TYPE as varchar(10)
	Declare @Is_Round					Tinyint
	Declare @Is_Calculated_On_Imported_Value int
	Declare @Not_display_auto_credit_amount_IT int  -- Added by rohit on 09032016
	
	DECLARE @AD_Level_Temp		NUMERIC(18,0)	--Ankit 02052015
	set @AD_Level_Temp = 0
	
	set @temp_month_diff	 = @Month_Diff
	set @old_PT_Amount			=0
	set @old_Salary_Amount	=0
	set @PT_Amount =0
	set @PT_Calculated_Amount = 0
	set @Calc_On_Allow_Dedu = 0.0
	SET @varCalc_On = ''
	set @Other_Allow_Amount = 0
	set @Calc_On_Allow_Dedu = 0.0
	SET @varCalc_On = ''
	set @cur_increment_id = 0
	set @M_AD_Actual_Per_Amount = 0.0
	set @PF_Limit =0
	set @Esic_Limit =0
	Set @Is_Round = 0
	set @Is_Calculated_On_Imported_Value = 0
	set @Not_display_auto_credit_amount_IT = 0
	
	

	-- Added by rohit on 08-apr-2014
	set @Wages_Type=''
	Declare @Day_Count as numeric(18,2)
	set @Day_Count = 26
	-- Ended by rohit on 08-apr-2014		
	
	select @Basic_Salary = Basic_Salary , @Emp_Full_Pf = Emp_Full_Pf ,
			@Emp_PT = Emp_PT,@Gross_Salary_ProRata = Gross_Salary , @Branch_ID =Branch_ID
			,@Wages_Type=Wages_type  -- Added by rohit on 08-apr-2014
			,@CTC_ProRata = CTC -- added by rohit on 20052017
		From T0095_Increment WITH (NOLOCK) where Emp_ID =@Emp_ID and Increment_ID =@Increment_ID 
	
	if @Wages_Type='Daily' -- Added by rohit on 08-apr-2014	
	BEGIN
		set @Basic_Salary = (@Basic_Salary * @Day_Count)
		set @Gross_Salary_ProRata = (@Gross_Salary_ProRata * @Day_Count)
		set @CTC_ProRata = (@CTC_ProRata * @Day_Count)
	END
	
	select @PF_Limit = isnull(PF_Limit,0)  ,@ESIC_Limit	 = ESIC_Upper_Limit, @Is_Round = isnull(g.AD_Rounding,0)
		from T0040_GENERAL_SETTING g WITH (NOLOCK) Inner join T0050_General_Detail gd WITH (NOLOCK) on g.Gen_ID = Gd.gen_ID
		where g.cmp_ID = @cmp_ID	and Branch_ID = @Branch_ID
		and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)

	--if @PF_Limit =0	
	 --set @PF_Limit =6500
	
	
					
		IF EXISTS(SELECT distinct 1 from T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_Id and to_date >= @From_Date AND To_date <= @To_Date) 	
			BEGIN
				-- Added below code by Hardik, Nimesh 13/07/2018 as Import_Calc_Value allowances are not coming in Cursor Query, for Kivilabs (HMP)
				SELECT AD_ID INTO #TMP_AD
				FROM	(
							SELECT distinct ad_id from T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_Id and to_date >= @From_Date AND To_date <= @To_Date
							UNION 
							Select AD_ID From T0050_AD_MASTER WITH (NOLOCK) Where Isnull(Is_Calculated_On_Imported_Value,0) =1 And CMP_ID = @Cmp_Id
						) T
	
				--- Added below Temp Table Condition by Hardik 18/02/2021 for Manubhai, to Add Allowances which removed from Increment but in Year paid in salary, so it should show in Tax
				SELECT * INTO #SALARY_STRUCTURE FROM
				(
					SELECT EED.AD_ID,
						--Case When Qry1.E_AD_PERCENTAGE IS NULL Then eed.E_AD_PERCENTAGE Else Qry1.E_Ad_Percentage End As E_AD_Percentage,
						--Case When Qry1.E_Ad_Amount IS NULL Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End As E_AD_Amount,
						 Case When Qry1.Increment_ID >= EED.INCREMENT_ID Then
							Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_AD_PERCENTAGE End 
						 Else
							eed.E_AD_PERCENTAGE End As E_AD_PERCENTAGE,
						 Case When Qry1.Increment_ID >= EED.INCREMENT_ID Then
							Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
						 Else
							eed.e_ad_Amount End As E_Ad_Amount,
						E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,ISNULL(ADM.Allowance_Type,'A') as Allowance_Type, AD_DEF_ID ,                    
						ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,
						ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY,
						AD_Name,ISNULL(AD_effect_on_Late,0) AS AD_effect_on_Late ,ISNULL(Ad_Effect_On_TDS,0) AS Ad_Effect_On_TDS,
						EED.INCREMENT_ID,EED.It_Estimated_Amount,
						ADM.AD_LEVEL,Is_Calculated_On_Imported_Value
						,ADM.Not_display_auto_credit_amount_IT  
					FROM dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN                    
						   dbo.T0050_AD_MASTER ADM WITH (NOLOCK)  ON EEd.AD_ID = ADM.AD_ID   LEFT OUTER JOIN
							( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID
								From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
								( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
									Where Emp_Id = @Emp_Id and For_Date <= @To_Date
								 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
							) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID AND EED.FOR_DATE <= Qry1.FOR_DATE 
							INNER JOIN #TMP_AD T On EED.AD_ID = T.AD_ID          
					WHERE EED.EMP_ID = @emp_id And Adm.AD_ACTIVE = 1 
							and EED.INCREMENT_ID = @Increment_ID And EED.CMP_ID = @Cmp_ID And EED.EMP_ID = @EMP_ID--Added by Nilesh on 31012017 For Aculife  
							AND Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
							/* and eed.AD_ID in (SELECT distinct ad_id from T0210_MONTHLY_AD_DETAIL where Emp_ID = @Emp_Id and to_date >= @From_Date AND To_date <= @To_Date
												UNION ALL
												Select AD_ID From T0050_AD_MASTER Where Isnull(Is_Calculated_On_Imported_Value,0) =1 And CMP_ID = @Cmp_Id)
							*/
					UNION ALL
					
					SELECT EED.AD_ID,E_AD_Percentage,E_AD_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,ISNULL(ADM.Allowance_Type,'A') AS Allowance_Type, AD_DEF_ID ,                    
						ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,
						ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY,
						AD_Name,ISNULL(AD_effect_on_Late,0) AS AD_effect_on_Late ,ISNULL(Ad_Effect_On_TDS,0) AS Ad_Effect_On_TDS,
						0 AS INCREMENT_ID,0 AS It_Estimated_Amount,
						ADM.AD_LEVEL,Is_Calculated_On_Imported_Value
						,Not_display_auto_credit_amount_IT  
					FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
						( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
							Where Emp_Id  = @Emp_Id  and For_Date <= @To_Date
							Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
					   INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK)  ON EEd.AD_ID = ADM.AD_ID                     
					   INNER JOIN #TMP_AD T On EED.AD_ID = T.AD_ID 
					WHERE emp_id = @emp_id And Adm.AD_ACTIVE = 1
							and EED.INCREMENT_ID = @Increment_ID And EED.CMP_ID = @Cmp_ID And EED.EMP_ID = @EMP_ID --Added by Nilesh on 31012017 For Aculife  
							AND EEd.ENTRY_TYPE = 'A'
							/* AND eed.AD_ID in (SELECT distinct ad_id from T0210_MONTHLY_AD_DETAIL where Emp_ID = @Emp_Id and to_date >= @From_Date AND To_date <= @To_Date
												UNION ALL
												Select AD_ID From T0050_AD_MASTER Where Isnull(Is_Calculated_On_Imported_Value,0) =1 And CMP_ID = @Cmp_Id)
							*/					

				) QRY

				declare curAD cursor FOR
					
					--- Added below Temp Table Condition by Hardik 18/02/2021 for Manubhai, to Add Allowances which removed from Increment but in Year paid in salary, so it should show in Tax
					SELECT *
					FROM (
						SELECT * FROM #SALARY_STRUCTURE

						UNION ALL

						SELECT EED.AD_ID,
								0 As E_AD_PERCENTAGE,
								0 As E_Ad_Amount,
							ADM.AD_FLAG,ADM.AD_MAX_LIMIT,AD_Calculate_On ,ISNULL(ADM.Allowance_Type,'A') as Allowance_Type, AD_DEF_ID ,                    
							ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,
							ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY,
							AD_Name,ISNULL(AD_effect_on_Late,0) AS AD_effect_on_Late ,ISNULL(Ad_Effect_On_TDS,0) AS Ad_Effect_On_TDS,
							@Increment_ID,0 AS It_Estimated_Amount,
							ADM.AD_LEVEL,Is_Calculated_On_Imported_Value
							,ADM.Not_display_auto_credit_amount_IT  
						FROM dbo.#TMP_AD EED WITH (NOLOCK) INNER JOIN                    
							   dbo.T0050_AD_MASTER ADM WITH (NOLOCK)  ON EEd.AD_ID = ADM.AD_ID
						WHERE Adm.AD_ACTIVE = 1 AND NOT EXISTS (SELECT 1 FROM #SALARY_STRUCTURE S WHERE EED.AD_ID = S.AD_ID)
					) Qry
					ORDER BY AD_LEVEL, E_AD_Flag, INCREMENT_ID  DESC
			END
		ELSE	
			BEGIN
				
				declare curAD cursor for
				SELECT *
				FROM (
				SELECT EED.AD_ID,
					--Case When Qry1.E_AD_PERCENTAGE IS NULL Then eed.E_AD_PERCENTAGE Else Qry1.E_Ad_Percentage End As E_AD_Percentage,
					--Case When Qry1.E_Ad_Amount IS NULL Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End As E_AD_Amount,
					 Case When Qry1.Increment_ID >= EED.INCREMENT_ID Then
						Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_AD_PERCENTAGE End 
					 Else
						eed.E_AD_PERCENTAGE End As E_AD_PERCENTAGE,
					 Case When Qry1.Increment_ID >= EED.INCREMENT_ID Then
						Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
					 Else
						eed.e_ad_Amount End As E_Ad_Amount,
					E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,ISNULL(ADM.Allowance_Type,'A') as Allowance_Type, AD_DEF_ID ,                    
					ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,
					ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY,
					AD_Name,ISNULL(AD_effect_on_Late,0) AS AD_effect_on_Late ,ISNULL(Ad_Effect_On_TDS,0) AS Ad_Effect_On_TDS,
					EED.INCREMENT_ID,EED.It_Estimated_Amount,
					ADM.AD_LEVEL,Is_Calculated_On_Imported_Value
					,Not_display_auto_credit_amount_IT  
				FROM dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN                    
					   dbo.T0050_AD_MASTER ADM WITH (NOLOCK)  ON EEd.AD_ID = ADM.AD_ID   LEFT OUTER JOIN
						( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID
							From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
							( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
								Where Emp_Id = @Emp_Id  and For_Date <= @To_Date
							 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
						) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID AND EED.FOR_DATE <= Qry1.FOR_DATE
				WHERE EED.EMP_ID = @emp_id And Adm.AD_ACTIVE = 1
					    and EED.INCREMENT_ID = @Increment_ID --Added by Nilesh on 31012017 For Aculife  
						AND (Case When Qry1.E_Ad_Amount IS NULL Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End > 0 or FOR_FNF = 1 OR AD_Calculate_On = 'Import') 
						AND Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
						
				UNION ALL
				
				SELECT EED.AD_ID,E_AD_Percentage,E_AD_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,ISNULL(ADM.Allowance_Type,'A') AS Allowance_Type, AD_DEF_ID ,                    
					ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,
					ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY,
					AD_Name,ISNULL(AD_effect_on_Late,0) AS AD_effect_on_Late ,ISNULL(Ad_Effect_On_TDS,0) AS Ad_Effect_On_TDS,
					0 AS INCREMENT_ID,0 AS It_Estimated_Amount,
					ADM.AD_LEVEL,Is_Calculated_On_Imported_Value
					,Not_display_auto_credit_amount_IT  
				FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
					( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
						Where Emp_Id  = @Emp_Id  and For_Date <= @To_Date
						Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
				   INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK)  ON EEd.AD_ID = ADM.AD_ID                     
				WHERE emp_id = @emp_id And Adm.AD_ACTIVE = 1
						and EED.INCREMENT_ID = @Increment_ID --Added by Nilesh on 31012017 For Aculife  
						and (EED.E_AD_AMOUNT > 0 or FOR_FNF = 1 OR AD_Calculate_On = 'Import') 
						And EEd.ENTRY_TYPE = 'A'
						
				) Qry
				ORDER BY AD_LEVEL, E_AD_Flag, INCREMENT_ID  DESC
				
			END 
	 
	open curAD		
		fetch next from curAD into @AD_ID,@M_AD_Percentage,@M_AD_Amount,@M_AD_Flag,@Max_Upper,@varCalc_On,@AD_CAL_TYPE,@AD_DEF_ID,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY ,@AD_Name,@M_AD_effect_on_Late,@AD_Effect_On_TDs,@cur_increment_id,@It_Estimated_Amount,@AD_Level_Temp,@Is_Calculated_On_Imported_Value,@Not_display_auto_credit_amount_IT
		while @@fetch_status = 0
			Begin
			
			
			
		if @Wages_Type='Daily' -- Added by rohit on 08-apr-2014	
			BEGIN
				set @M_AD_Amount = ( @M_AD_Amount * @Day_Count )
			END
		
		
				if @cur_increment_id = @Increment_Id
					begin
					
						If @varCalc_On ='Actual Gross'	
							set @Calc_On_Allow_Dedu = @Gross_Salary_ProRata
						Else If @varCalc_On ='Basic Salary'	
							set @Calc_On_Allow_Dedu = @Basic_Salary
						Else If @varCalc_On ='CTC'	
							set @Calc_On_Allow_Dedu = @CTC_ProRata	
						Else 
							set @Calc_On_Allow_Dedu = @Basic_Salary


						if @M_AD_Percentage > 0 
							set @M_AD_Actual_Per_Amount = @M_AD_Percentage
						else
							set @M_AD_Actual_Per_Amount = @M_AD_Amount


						set @Other_Allow_Amount = 0

						--Commented by Hardik 15/10/2019 as calculation getting wrong when Effecting allowance, query raise by Nuvu Cornair client
						--select	@Other_Allow_Amount = sum(Isnull(M_AD_amount,0))  
						--from	#Salary_AD
						--where	Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID 
						--		and For_Date >=@From_Date and For_Date <=@To_Date --and Ad_effect_on_TDS = 1
						--		and AD_ID in (select AD_ID  from T0060_EFFECT_AD_MASTER  
						--						Where Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID)

					

						set @Calc_On_Allow_Dedu = isnull(@Calc_On_Allow_Dedu,0) + isnull(@Other_Allow_Amount ,0)

						if @M_AD_Flag = 'I'
							begin
								--Commented by Hardik 15/10/2019 as calculation getting wrong when Effecting allowance, query raise by Nuvu Cornair client
								--If  @M_AD_Percentage > 0
								--		begin
								--			if round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0) > @Max_Upper and @Max_Upper > 0
								--				begin
								--						set @M_AD_Amount = @Max_Upper	
								--				end	
								--			else		
								--				begin
												
								--						--set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)	
								--					If @Is_Round = 1
								--						Begin 
								--							set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)																											
								--						End
								--					else
								--						Begin
								--							set @M_AD_Amount = (@Calc_On_Allow_Dedu * @M_AD_Percentage / 100)
								--						End
														
								--				end
								--		end	
								--Else
									begin
										set @M_AD_Amount =  @M_AD_Amount 
									end
							end
						else	---- Start Deduction 
									begin
										If  @M_AD_Percentage > 0
											Begin
													If @PF_DEF_ID = @AD_DEF_ID
														Begin
															--Commented by Hardik 15/10/2019 as calculation getting wrong when Effecting allowance, query raise by Nuvu Cornair client
															--if  @Emp_Full_PF = 0 and @PF_LIMIT > 0 and @Calc_On_Allow_Dedu > @PF_LIMIT 
															--	set @Calc_On_Allow_Dedu = @PF_Limit
																
															
															--set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)
															
															Declare @PF_Arrear Numeric(18,4)
															Set @PF_Arrear = 0
															
															SELECT @PF_Arrear = SUM(Isnull(MAD.M_AD_Amount,0)) FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) 
															INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK)
															ON MAD.AD_ID = AD.AD_ID  Where EMP_ID = @Emp_Id and AD.AD_DEF_ID = 2 and AD.AD_CALCULATE_ON='Import'
															and MAD.For_Date >=@From_Date and MAD.For_Date <=@To_Date
																
														End
													--Commented by Hardik 15/10/2019 as calculation getting wrong when Effecting allowance, query raise by Nuvu Cornair client
													--else if @ESIC_DEF_ID = @AD_DEF_ID
													--	BEGIN
													--	--	if @Calc_On_Allow_Dedu > @ESIC_LIMIT AND @ESIC_LIMIT > 0 
													--	--		SET @M_AD_Amount = 0
													--	--	ELSE
													--			set @M_AD_Amount = Ceiling((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100))
													--	END
													--else If round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0) > @Max_Upper and @Max_Upper > 0
													--	begin
													--		set @M_AD_Amount = @Max_Upper	
													--	end 	
													--Else
													--	begin
													--		set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)	
													--	end
											End	
										Else
											begin
													--set @M_AD_Amount =  @M_AD_Amount
												If @Is_Round = 1
													Begin 
														--set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)	
														SET @M_AD_Amount = round(@M_AD_Amount,0) -- Added by rohit on 15052015																										
													End
												else
													Begin
													--	set @M_AD_Amount = (@Calc_On_Allow_Dedu * @M_AD_Percentage / 100)
													SET @M_AD_Amount = @M_AD_Amount -- Added by rohit on 15052015
													End	
											End	
									End
					end

				--Else
				--	Begin
				--		Set @M_AD_Amount = 0
				--		Set @M_Ad_Percentage = 0
				--	end 	

					--SET @M_AD_Amount = ROUND(@M_AD_Amount,0)
					
					If @Is_Round = 1
						Begin
							SET @M_AD_Amount = ROUND(@M_AD_Amount,0)
						End
					Else
						Begin
							SET @M_AD_Amount = @M_AD_Amount
						End
						
					set @old_M_AD_Amount = 0 
					
										
				-- commented by rohit due to inductotherm case
					--select @old_M_AD_Amount = sum(Isnull(M_AD_Amount,0)) + sum(isnull(M_AREAR_AMOUNT,0)) 
					--From T0210_Monthly_AD_Detail where Emp_ID =@Emp_ID and AD_ID =@AD_ID 
					--	and To_Date >=@From_Date and To_Date <=@Month_Date
						--and For_FNF = 0 --Comment by Ankit Due to FNF Allowance amount not calculate in tax report (WCL Email Date - Wed, Jun 1, 2016 at 2:36 PM)
						
						--- Condition added by Hardik 27/12/2017 for Havmor, Bonus case
						If EXISTS(Select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) Where Emp_ID=@Emp_Id And Month_St_Date >= @From_Date And Month_End_Date <= @Month_Date And Is_FNF=1) AND
							EXISTS(Select 1 From T0050_AD_MASTER WITH (NOLOCK) where CMP_ID=@Cmp_Id And AD_ID = @AD_Id And Allowance_Type='A' And AD_NOT_EFFECT_SALARY=1)
								BEGIN
									SELECT @old_M_AD_Amount = sum(Isnull(M_AD_Amount,0)) + sum(isnull(M_AREAR_AMOUNT,0)) + Isnull(@PF_Arrear,0)  + Isnull(Sum(M_Arear_Amount_Cutoff),0)
									FROM T0210_Monthly_AD_Detail MAD WITH (NOLOCK)  left join 
									   T0050_AD_MASTER Am WITH (NOLOCK) on mad.AD_ID=Am.ad_id   where Emp_ID =@Emp_ID and mad.AD_ID =@AD_ID 
									and To_Date >=@From_Date and To_Date <=@Month_Date
									and Am.allowance_type='A' And AM.AD_NOT_EFFECT_SALARY=1 And Isnull(MAD.FOR_FNF,0)=1
								END
							ELSE
								BEGIN
									SELECT @old_M_AD_Amount = sum(Isnull(M_AD_Amount,0)) + sum(isnull(M_AREAR_AMOUNT,0)) + Isnull(@PF_Arrear,0) + Isnull(Sum(M_Arear_Amount_Cutoff),0)
									FROM T0210_Monthly_AD_Detail MAD WITH (NOLOCK)  left join T0050_AD_MASTER Am WITH (NOLOCK) on mad.AD_ID=Am.ad_id   
									where Emp_ID =@Emp_ID and mad.AD_ID =@AD_ID 
									and To_Date >=@From_Date and To_Date <=@Month_Date
									and 1=(case when am.Allowance_Type='R' and mad.for_fnf=0 then 1 when Am.allowance_type='A' then 1 else 0 end)
									And S_Sal_Tran_Id Is Null
									--and For_FNF = 0 --Comment by Ankit Due to FNF Allowance amount not calculate in tax report (WCL Email Date - Wed, Jun 1, 2016 at 2:36 PM)

									SELECT @old_M_AD_Amount = Case when Am.Allowance_Type='R' Then SUM(Isnull(Qry.M_AD_Amount,MAD.M_AD_Amount)) Else SUM(Isnull(MAD.M_AD_Amount,0)) END + sum(isnull(M_AREAR_AMOUNT,0)) + Isnull(@PF_Arrear,0) + Isnull(Sum(M_Arear_Amount_Cutoff),0)
									FROM T0210_Monthly_AD_Detail mad WITH (NOLOCK) inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on mad.Sal_Tran_ID=ms.Sal_Tran_ID
										Left outer JOIN(
														SELECT ma.Sal_Tran_ID,ma.Emp_ID,Sum(ma.M_AD_Amount) As M_AD_Amount , MA.AD_ID 
														FROM T0210_Monthly_AD_Detail ma WITH (NOLOCK) inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on ma.Sal_Tran_ID=ms.Sal_Tran_ID
														WHERE ma.Emp_ID=@Emp_ID And AD_Id=@AD_ID
															and For_Date BETWEEN @From_Date and @Month_Date And MS.Is_FNF=1 And ma.M_AD_NOT_EFFECT_SALARY=0
														Group by ma.Sal_Tran_ID,ma.Emp_ID,MA.AD_ID)Qry 
											ON Mad.Sal_Tran_ID=qry.sal_tran_id and mad.Emp_ID=qry.emp_id And MAD.AD_ID=Qry.AD_ID
										left join T0050_AD_MASTER Am WITH (NOLOCK) on mad.AD_ID=Am.ad_id 
									where mad.Emp_ID = @Emp_ID and To_Date BETWEEN @From_Date and @Month_Date 
											And mad.M_AD_NOT_EFFECT_SALARY = Case when Am.allowance_type='A' then 0 else 1 end 
											And MAD.AD_Id=@AD_ID And S_Sal_Tran_Id Is Null
										and 1=(case when am.Allowance_Type='R' and mad.for_fnf=0 then 1 when Am.allowance_type='A' then 1 else 0 end)
									GROUP by Am.Allowance_Type
								END
						--ended by rohit
						
						--- Sum(ISNULL(M_AREAR_AMOUNT_Cutoff,0)) Added by Rajput on 28052019 Issue Was IT Tax Computation and Monthly Salary Report Does not Match ( Inductotherm Client )
						select @old_M_AD_Amount = @old_M_AD_Amount +  IsNull(sum(Isnull(M_AD_Amount,0)) + sum(isnull(M_AREAR_AMOUNT,0)) + Isnull(@PF_Arrear,0) + Sum(ISNULL(M_AREAR_AMOUNT_Cutoff,0)),0)  
						From T0210_Monthly_AD_Detail MAD WITH (NOLOCK)  left join T0050_AD_MASTER Am WITH (NOLOCK) on mad.AD_ID=Am.ad_id   where Emp_ID =@Emp_ID and mad.AD_ID =@AD_ID 
						--and To_Date >=@From_Date and To_Date <=@Month_Date
						and 1=(case when am.Allowance_Type='R' and mad.for_fnf=0 then 1 when Am.allowance_type='A' then 1 else 0 end)
						AND EXISTS(SELECT 1 FROM T0201_MONTHLY_SALARY_SETT MS1 WITH (NOLOCK) 
									WHERE ms1.S_Sal_Tran_ID=mad.S_Sal_Tran_ID
											AND mad.Emp_ID=MS1.EMP_ID and MS1.S_Eff_Date >= @FROM_DATE AND MS1.S_Eff_Date <= @TO_DATE 											
											AND EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK) WHERE MS1.Emp_ID=MS.Emp_ID AND MONTH(MS.MONTH_END_DATE)=MONTH(MS1.S_EFF_DATE) AND YEAR(MS.MONTH_END_DATE)=YEAR(MS1.S_EFF_DATE))
											)
						--and For_FNF = 0 --Comment by Ankit Due to FNF Allowance amount not calculate in tax report (WCL Email Date - Wed, Jun 1, 2016 at 2:36 PM)
						
						--ended by rohit
					
					if isnull(@Is_Calculated_On_Imported_Value,0) = 1
					begin
						select @old_M_AD_Amount = sum(Isnull(Amount,0))  From T0190_MONTHLY_AD_DETAIL_IMPORT WITH (NOLOCK) where Emp_ID =@Emp_ID and AD_ID =@AD_ID 
						and For_Date >=@From_Date and For_Date<=@Month_Date
					end

						if not exists (select EED.AD_ID From T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) inner join T0050_AD_MASTER ADM WITH (NOLOCK)  on EEd.AD_ID = ADM.AD_ID where emp_id = @emp_id and increment_id = @Increment_Id	 and EED.AD_ID = @AD_ID)
							begin								
								set @Month_Diff = 0
							end
						else
							begin																
								set @Month_Diff = @temp_month_diff
							end
							

					
					if @varCalc_On = 'Import'
						set @M_AD_Amount = 0
						
					-- Added By rohit on 11052015 	
					if @It_Estimated_Setting = 1
					begin 
					    if @varCalc_On in ('Late','Present Senario','Absent Senario','Leave Senario','Performance','Transfer OT','Import','Bonus','Present Days','Slab Wise','Reference','Shift Wise','Leave Allowance','Split Shift','Formula','Security Deposit','Present + Paid Leave Days','Night Halt')
						begin 
							if @It_Estimated_Amount > 0
								set @M_AD_Amount = @It_Estimated_Amount
						end
					end	
					
					-- Ended by rohit on 11052015
					
					if @Setting_Reim = 0 or isnull(@Not_display_auto_credit_amount_IT,0) = 1
					begin
					
						IF @AD_CAL_TYPE='R'	
						BEGIN
						
							select @old_M_AD_Amount = isnull(sum(Taxable),0) + isnull(sum(Tax_free_amount),0)  From T0210_MONTHLY_rEIM_DETAIL WITH (NOLOCK) INNER JOIN 
							T0050_AD_MASTER WITH (NOLOCK) ON T0210_MONTHLY_rEIM_DETAIL.RC_ID=T0050_AD_MASTER.AD_ID						
							where Emp_ID =@Emp_ID and RC_ID =@AD_ID AND ISNULL(AD_NOT_EFFECT_SALARY,0) = 1 AND ISNULL(Allowance_Type,'A')='R'
							and for_Date >=@From_Date and for_Date <=@Month_Date 
							--AND Sal_tran_ID > 0  -- Commneted by rohit For Approved reimbershement not Effect on Salary Shown in the report on 08092015
							AND T0050_AD_MASTER.CMP_ID=@CMP_id
							--and RC_apr_ID IS NOT NULL	--Display only Reim Approved Amount -- Ankit	24082015
							--and Amount> 0		--commeny by Ankit 24082015
							
							Set @M_AD_Amount = 0 -- Added by rohit on 12052015

						END
					end

					if not exists (SELECT @AD_ID from #Salary_AD where AD_ID = @AD_ID AND Emp_Id = @emp_id AND for_date = @From_Date )
						begin
						
						
							Insert into #Salary_AD (Emp_Id,AD_ID,For_Date,Cmp_ID,M_AD_Amount,Month_Count,Old_M_AD_Amount,AD_NOT_EFFECT_ON_PT,AD_NOT_EFFECT_ON_SAL,Ad_Effect_On_TDS,Month_Diff_Amount)
							select @Emp_ID,@AD_Id,@From_Date,@Cmp_ID,@M_AD_Amount,@Month_Diff,@old_M_AD_Amount,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@AD_Effect_On_TDs,@M_AD_Amount * @Month_Diff
							
							
														
						end	
					                    
				fetch next from curAD into @AD_ID,@M_AD_Percentage,@M_AD_Amount,@M_AD_Flag,@Max_Upper,@varCalc_On,@AD_CAL_TYPE,@AD_DEF_ID,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY ,@AD_Name,@M_AD_effect_on_Late,@AD_Effect_On_TDs,@cur_increment_id,@It_Estimated_Amount,@AD_Level_Temp,@Is_Calculated_On_Imported_Value,@Not_display_auto_credit_amount_IT
			end
	close curAD
	deallocate curAD

	/*Perquisites-Nimesh*/
	UPDATE	PD
	SET		TotalAmount = ISNULL(Old_M_AD_Amount,0) + ISNULL(Month_Diff_Amount,0)
	FROM	#Perq_Detail PD
			INNER JOIN #Salary_AD AD ON PD.AD_ID=AD.AD_ID AND PD.EMP_ID=AD.EMP_ID

	--UPDATE	PD
	--SET		Old_M_AD_Amount = 0, 
	--		Month_Diff_Amount = 0
	--FROM	#Salary_AD AD
	--		INNER JOIN #Perq_Detail PD ON PD.AD_ID=AD.AD_ID AND PD.EMP_ID=AD.EMP_ID
  
	 set @Month_Diff = @temp_month_diff
		--start  month wise pt calculation 21/05/2012
		
		declare @tempFrom_Date as datetime
		declare @tempPTCal_Amount numeric(18,2)
		declare @tempSal_Amount numeric(18,2)
		declare @tempPT_Amount numeric(18,2)
		
		set @tempFrom_Date = @From_Date
		set @tempPTCal_Amount = 0
		set @tempSal_Amount = 0
		set @tempPT_Amount = 0
			
		
		declare @flg tinyint

		set @flg = 0

		while @tempFrom_Date <= @To_Date
			Begin
			
			set @PT_Calculated_Amount = 0
			
			Select  @PT_Calculated_Amount = sum(isnull(M_AD_Amount,0)) from #Salary_AD SA 
						inner join T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) 
							on SA.ad_id = EED.AD_ID and SA.Emp_id = EED.EMP_ID
						inner join T0050_AD_MASTER AM WITH (NOLOCK) on AM.AD_ID = SA.ad_id 
					Where SA.Emp_ID = @Emp_ID and EED.E_AD_FLAG = 'I'  and AM.AD_NOT_EFFECT_SALARY = 0 and AM.AD_NOT_EFFECT_ON_PT = 0
					and EED.Increment_Id = (select max(Increment_Id) from  T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) where emp_id = @emp_id and for_date <= @tempFrom_Date)
					--Commented by Hardik 05/09/2014 for Same Date Increment
					--and EED.FOR_DATE = (select max(for_date) from  T0100_EMP_EARN_DEDUCTION where emp_id = @emp_id and for_date <= @tempFrom_Date)
					
				-- changed by rohit on 02-apr-2014	
		--set @PT_Calculated_Amount =  @PT_Calculated_Amount	 + @Basic_Salary
		
		set @PT_Calculated_Amount =  isnull(@PT_Calculated_Amount,0) + isnull(@Basic_Salary,0)
		
		If @Emp_PT = 0
			set @PT_Calculated_Amount = 0
				
				set @tempPTCal_Amount = 0
				set @tempSal_Amount = 0
				set @tempPT_Amount = 0

-- Commented by rohit on 03062016 for Pt not showing which deduct in fnf.
				--if isnull(@Left_date,0) <> 0 and @Left_date < @tempFrom_Date --and @tempFrom_Date  >= @join_date 
				--	begin
				--		break	
				--	end

					
				if (month(@tempFrom_Date)  >= month(@join_date) and year(@tempFrom_Date)  >= year(@join_date)) or @tempFrom_Date  >= @join_date
					begin
						if EXISTS ( select Sal_Tran_ID from T0200_MONTHLY_SALARY WITH (NOLOCK) where MONTH(Month_End_Date) = MONTH(@tempFrom_Date) and Year(Month_End_Date) = Year(@tempFrom_Date) and Emp_ID = @Emp_Id )
							begin
								select @tempSal_Amount= isnull(Salary_Amount,0) + isnull(Arear_Basic,0) + ISNULL(Basic_Salary_Arear_cutoff,0),
									@tempPTCal_Amount= isnull(PT_Amount,0) 
								From T0200_Monthly_Salary WITH (NOLOCK) where Emp_ID =@Emp_ID and MONTH(Month_End_Date) = MONTH(@tempFrom_Date) and Year(Month_End_Date) = Year(@tempFrom_Date) 
							end
						else
							begin
							if not EXISTS ( select Sal_Tran_ID from T0200_MONTHLY_SALARY WITH (NOLOCK) where Month_End_Date >=  @tempFrom_Date and Emp_ID = @Emp_Id  ) and @month_diff <> 0 -- Added by rohit on 02-apr-2014 , Month_Diff Condition added by Hardik 15/03/2016 as Form-16 has to display only Actual deducted figure
								begin
								-- changed by rohit on 03062016 for Pt not showing which deduct in fnf.
								if isnull(@Left_date,0) <> 0 and @Left_date < @tempFrom_Date --and @tempFrom_Date  >= @join_date
								begin
									set @tempPT_Amount = 0
								end
								else
								begin
								    exec SP_CALCULATE_PT_AMOUNT @CMP_ID,@EMP_ID,@tempFrom_Date,@PT_Calculated_Amount,@tempPT_Amount OUTPUT,'' ,@Branch_ID
								end
								-- ended by rohit on 03062016
								end
							end
				
						
						set @Old_Salary_Amount = isnull(@Old_Salary_Amount,0)   + isnull(@tempSal_Amount,0)
						Set @Old_PT_Amount = isnull(@Old_PT_Amount,0)  + isnull(@tempPTCal_Amount,0)
						set @PT_Amount = isnull(@PT_Amount,0) + isnull(@tempPT_Amount,0)
						

					end
						set @tempFrom_Date = DATEADD(MM,1,@tempFrom_Date)	
					
								
			end
		
		
		-- end
	
          
		--Select  @PT_Calculated_Amount = isnull(sum(M_AD_Amount) ,0) from #Salary_AD SA inner join T0100_EMP_EARN_DEDUCTION EED on SA.ad_id = EED.AD_ID and SA.Emp_id = EED.EMP_ID
		--			Where SA.Emp_ID = @Emp_ID and EED.E_AD_FLAG = 'I'
		
		--set @PT_Calculated_Amount =  @PT_Calculated_Amount	 + @Basic_Salary
		
		--If @Emp_PT = 0
		--	set @PT_Calculated_Amount = 0
		
		--exec SP_CALCULATE_PT_AMOUNT @CMP_ID,@EMP_ID,@To_Date,@PT_Calculated_Amount,@PT_AMOUNT OUTPUT,'' ,@Branch_ID

		--select @Old_Salary_Amount = isnull(Sum(Salary_Amount),0) ,
		--	@Old_PT_Amount = isnull(sum(PT_Amount),0) 
		--From T0200_Monthly_Salary where Emp_ID =@Emp_ID and Month_St_Date >=@From_Date and Month_St_Date <=@To_Date  and	 Month_st_Date <=@Month_Date


		Insert into #Salary_AD (Emp_Id,AD_ID,For_Date,Cmp_ID,M_AD_Amount,Month_Count,Old_M_AD_Amount,AD_NOT_EFFECT_ON_PT,AD_NOT_EFFECT_ON_SAL,Month_Diff_Amount,Default_Def_ID)
		select @Emp_ID,0,@From_Date,@Cmp_ID,@Basic_Salary,@Month_Diff,@Old_Salary_Amount,0,0,@Basic_Salary * @Month_Diff,@Cont_Basic_Sal
				
		Insert into #Salary_AD (Emp_Id,AD_ID,For_Date,Cmp_ID,M_AD_Amount,Month_Count,Old_M_AD_Amount,AD_NOT_EFFECT_ON_PT,AD_NOT_EFFECT_ON_SAL,Month_Diff_Amount,Default_Def_ID)
		select @Emp_ID,0,@From_Date,@Cmp_ID,@PT_AMOUNT,@Month_Diff,@Old_PT_Amount,0,0,@PT_AMOUNT ,@Cont_PT_Amount
		
	
	
	-- jaysukh 14-Mar-09
	if @Month_Diff = 0
	  begin
		Update #Salary_AD
		set M_AD_Amount = 0 
   	 end
	
	RETURN
