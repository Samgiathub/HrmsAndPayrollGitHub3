

CREATE PROCEDURE [dbo].[P0100_EMP_EARN_DEDUCTION]
	 @AD_TRAN_ID	Numeric OUTPUT
	,@EMP_ID		Numeric
	,@CMP_ID		Numeric
	,@AD_ID			Numeric
	,@INCREMENT_ID	Numeric(18,0)
	,@FOR_DATE		DateTime
	,@E_AD_FLAG		Char(1)
	,@E_AD_MODE		Varchar(10)
	,@E_AD_PERCENTAGE	numeric(18,5) -- Changed by Gadriwala Muslim 19032015
	,@E_AD_AMOUNT		numeric(18,2)
	,@E_AD_MAX_LIMIT	numeric
	,@tran_type			varchar(1)
	,@AD_Calculate_on_Grade_Branch Varchar(100) = ''
	,@User_Id numeric(18,0) = 0   --Added By Mukti 01072016
	,@IP_Address varchar(30)= '' --Added By Mukti 01072016
AS
		
	SET NOCOUNT ON	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

		
		Declare @AD_Calculate_On varchar(20)
		Declare @AD_Other_Amount	numeric (18,2)
		Declare @Calculated_Amount	numeric (18,2)
		Declare @AD_DEF_ID			int
		Declare @Emp_Full_PF		int
		Declare @Company_Full_PF	int --Hardik 25/06/2014
		Declare @Emp_PT				int
		Declare @Basic_Salary		numeric(18,2)
		declare @PT_Amount			numeric 
		Declare @Branch_ID			numeric
		Declare @AD_Amount as numeric(18,2)
		Declare @Gross_Salary		numeric
		Declare @CTC				Numeric
		Declare @Temp_Amount		Numeric(18,2)  --Added by Mukti (18,2)171222015
		Declare @ESIC_Limit			numeric	
		Declare @Is_Yearly			numeric	
		Declare @E_AD_AMOUNT_YEARLY		numeric(18,2)		
		Declare @Current_Date datetime
		Declare @AD_Other_Amount_ESIC	numeric(18,2) 
		Declare @ESIC_limit_Calculated_Amount Numeric (18,2)

		Declare @Grd_Id as Numeric
		
		set @Current_Date = getdate()
		
		Set @CTC = 0
		Set @Temp_Amount = 0
		set @ESIC_Limit = 0
		set @Is_Yearly = 0
		set @E_AD_AMOUNT_YEARLY = 0
		set @AD_Other_Amount_ESIC = 0
		set @ESIC_limit_Calculated_Amount = 0
		Set @Grd_Id = 0
		Set @Company_Full_PF = 0 --Hardik 25/06/2014
		
		--Added By Mukti 01-07-2016(Start)			
		declare @OldValue as  varchar(max)
		Declare @String as varchar(max)
		set @String=''
		set @OldValue =''
		--Added By Mukti 01-07-2016(End)	
				
		if @E_AD_AMOUNT is null
			set @AD_Other_Amount = 0
			
		set @Emp_Full_PF =0 
		set @PT_Amount =0
		--CHANGE BY NILAY - 25 -JAN-2011--------
		---set @E_AD_AMOUNT=0
		--set @AD_Amount =0
		
		
		Declare @AC_2_3 as Numeric(18,3)
		Declare @AC_22_3 as Numeric(18,3)
		Declare @AC_21_1 as Numeric(18,3)
		Declare @PF_Limit as Numeric(18,2)
		Declare @AC_2_3_Amount as Numeric(18,2)
		Declare @AC_22_3_Amount as Numeric(18,2)
		Declare @AC_21_1_Amount as Numeric(18,2)
		Declare @AD_Rounding  INT	
		Declare @Max_Bonus_Salary_Amount as Numeric(18,2)	--Ankit 01042016

		Declare @DA_Amount Numeric(18,4)
		Declare @DA_DEF_ID Tinyint
		Set @DA_Amount = 0
		Set @DA_DEF_ID = 11

		Set @AC_2_3 = 0
		Set @AC_22_3 = 0
		Set @AC_21_1 = 0
		Set @PF_Limit = 0
		Set @AC_2_3_Amount = 0
		Set @AC_22_3_Amount = 0
		Set @AC_21_1_Amount = 0
		set @Max_Bonus_Salary_Amount = 0
		
		DECLARE @Error				VARCHAR(250)
		DECLARE @E_AD_AMOUNT_AREARS NUMERIC(18,2)
		SET @Error = ''
		SET @E_AD_AMOUNT_AREARS = 0

		Declare @Ad_Level NUMERIC(18,0)	--Hardikbhai 02122015	/*For Special allowance calcualte wrong while Earn deduction upload in New/Update Case.*/
		SET @Ad_Level = 0
		declare @IS_ROUNDING_Allowance int --Added By Ramiz on 03/09/2017 ( This Logic was already Added in P0100_EMP_EARN_DEDUCTION_INC_DISPLAY)
		
		SELECT @AD_DEF_ID = AD_DEF_ID ,@AD_Calculate_On = AD_CALCULATE_ON,@AD_Amount =Ad_Amount,@Is_Yearly = Is_Yearly, @Ad_Level = AD_LEVEL --,@E_AD_MAX_LIMIT = AD_MAX_LIMIT
		 , @IS_ROUNDING_Allowance = is_rounding --Added By Ramiz on 03/09/2017
		FROM T0050_AD_MASTER WITH (NOLOCK) WHERE AD_ID =@AD_ID
					--select @Calculated_Amount,@E_AD_AMOUNT,@AD_ID,@AD_DEF_ID

		SELECT  @Branch_ID		= Branch_ID , @Emp_PT =Emp_PT, @Emp_Full_PF = Emp_Full_PF 
		,@Basic_Salary = isnull(Basic_Salary,0) ,@Calculated_Amount = isnull(Basic_Salary,0) 
				-- , @For_Date		= Increment_Effective_Date -- comented by mitesh on 12072012
		, @Gross_Salary = Isnull(Gross_Salary,0), @CTC = Isnull(CTC,0),@Grd_Id = Grd_ID, @Company_Full_PF = Isnull(Emp_Auto_VPF,0)
		FROM	T0095_Increment WITH (NOLOCK) WHERE Increment_ID =@Increment_ID

		Select Top 1 @AC_2_3 =ACC_2_3, @AC_22_3 = ACC_22_3,
			@AC_21_1 =ACC_21_1, @PF_Limit = PF_LIMIT, @AD_Rounding = AD_Rounding, @ESIC_Limit = ISNULL(ESIC_Upper_Limit,0) ,@Max_Bonus_Salary_Amount = ISNULL(Max_Bonus_Salary_Amount,0)
		from T0040_General_setting gs WITH (NOLOCK) Left outer join     
			T0050_General_Detail gd WITH (NOLOCK) on gs.gen_Id =gd.gen_ID     
		where gs.Cmp_Id=@cmp_Id and Branch_ID = isnull(@Branch_ID,Branch_ID)    
		and For_Date = (SELECT MAX(For_Date) FROM dbo.T0040_GENERAL_SETTING  WITH (NOLOCK) WHERE Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID And For_Date <= @FOR_DATE)

		Declare @Special_Allo_Cal_Setting INT
		SET @Special_Allo_Cal_Setting = 0
		SELECT @Special_Allo_Cal_Setting = ISNULL(Setting_Value,0) FROM dbo.T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @CMP_ID AND Setting_Name = 'Special Allowance Calculate From Employee Allowance/Deduction Revise'
		
		
		Select @E_AD_MAX_LIMIT = isnull(AD_MAX_LIMIT,0) from T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) where Ad_ID = @AD_ID And Grd_ID = @Grd_Id
		set @AD_Rounding =  isnull(@IS_ROUNDING_Allowance,@AD_Rounding)				


		
		--Hardik 25/06/2014 for Upper Rouding for Employer ESIC
		Declare @Upper_Round_Employer_ESIC as int
		Select  @Upper_Round_Employer_ESIC = (Select Setting_ID from dbo.T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name='Upper Round for Employer ESIC')

		
	
		IF @AD_Calculate_On = 'Actual Gross' -- Added by Falak on 03-MAY-2011 
			set @Calculated_Amount = @Gross_Salary 
		Else IF @AD_Calculate_On = 'CTC' 
			set @Calculated_Amount = @CTC 
		Else if @AD_Calculate_On = 'Extra OT' -- Added by Jaina 03-09-2016
			set @Calculated_Amount = 0
		Else
			Set @Calculated_Amount = @Basic_Salary 

		
		
		IF @E_AD_PERCENTAGE >  0
			BEGIN
			
				If @AD_DEF_ID = 2 or @AD_DEF_ID = 5 or @AD_DEF_ID = 4
					SELECT @AD_Other_Amount = ISNULL(SUM(E_AD_Amount),0) FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) inner join 
						T0050_ad_master AM WITH (NOLOCK) on eed.ad_id = am.ad_id WHERE Increment_ID=@Increment_ID  
							AND eed.AD_ID IN (SELECT AD_ID FROM T0060_EFFECT_AD_MASTER WITH (NOLOCK) WHERE Effect_AD_ID =@AD_ID)
							AND AD_DEF_ID <> @DA_DEF_ID
				Else
					SELECT @AD_Other_Amount = ISNULL(SUM(E_AD_Amount),0) FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) inner join 
						T0050_ad_master AM  WITH (NOLOCK) on eed.ad_id = am.ad_id WHERE Increment_ID=@Increment_ID  
							AND eed.AD_ID IN (SELECT AD_ID FROM T0060_EFFECT_AD_MASTER WITH (NOLOCK) WHERE Effect_AD_ID =@AD_ID)



			----------import condition added by hasmukh 13042013----------------

				SELECT @AD_Other_Amount_esic = ISNULL(SUM(E_AD_Amount),0) FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) inner join 
					T0050_ad_master AM WITH (NOLOCK) on eed.ad_id = am.ad_id WHERE Increment_ID=@Increment_ID and am.AD_CALCULATE_ON <> 'Import'   
						AND eed.AD_ID IN (SELECT AD_ID FROM T0060_EFFECT_AD_MASTER WITH (NOLOCK) WHERE Effect_AD_ID =@AD_ID)
											
			---------------End---------------------------------------------------
				If @AD_DEF_ID = 2 or @AD_DEF_ID = 5 or @AD_DEF_ID = 4
					SELECT @DA_Amount = ISNULL(SUM(E_AD_Amount),0) FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) inner join 
						T0050_ad_master AM WITH (NOLOCK) on eed.ad_id = am.ad_id WHERE Increment_ID=@Increment_ID and am.AD_CALCULATE_ON <> 'Import'   
							AND eed.AD_ID IN (SELECT AD_ID FROM T0060_EFFECT_AD_MASTER WITH (NOLOCK) WHERE Effect_AD_ID =@AD_ID)
							AND AD_DEF_ID = @DA_DEF_ID
						
				set @ESIC_limit_Calculated_Amount = @Calculated_Amount   ---Added by Hasmukh 18042013 for esic limit not check on import type allowance 
				--Hardik 29/03/2019 As per New PF Rule
				--If (@AD_DEF_ID=2 or @AD_DEF_ID = 5 or @AD_DEF_ID = 4) And @Basic_Salary >= @PF_Limit
				--		Set @AD_Other_Amount = 0

					Declare @Calculate_Full_PF_evenif_Basic_is_above_PF_Limit As bit
					Declare @Calculate_Full_PF_evenif_Basic_is_less_PF_Limit As bit --Added By Hardik 27/07/2020 for GIFT City
					
					SEt @Calculate_Full_PF_evenif_Basic_is_above_PF_Limit = 0
					select @Calculate_Full_PF_evenif_Basic_is_above_PF_Limit = setting_value from T0040_SETTING WITH (NOLOCK) --Added By Jimit 20052019 for Corona new PF Rules
					Where Cmp_Id = @Cmp_ID and Setting_Name = 'Calculate Full PF, evenif Basic is above PF Limit'
					
					SET @Calculate_Full_PF_evenif_Basic_is_less_PF_Limit = 0

					select @Calculate_Full_PF_evenif_Basic_is_less_PF_Limit = setting_value from T0040_SETTING WITH (NOLOCK) --Added By Hardik 27/07/2020 for GIFT City
					Where Cmp_Id = @Cmp_ID and Setting_Name = 'Calculate Full PF, Evenif Basic is Less than PF Limit'
				
					If (@AD_DEF_ID=2 or @AD_DEF_ID = 5 or @AD_DEF_ID = 4) And @Basic_Salary + @DA_Amount >= @PF_Limit
						ANd IsNull(@Calculate_Full_PF_evenif_Basic_is_above_PF_Limit,0) = 0 
						BEGIN			
							Set @AD_Other_Amount = 0
						END
					--Ended
				
				SET @Calculated_Amount = @Calculated_Amount + @AD_Other_Amount + @DA_Amount

				Set @ESIC_limit_Calculated_Amount = @ESIC_limit_Calculated_Amount + @AD_Other_Amount_esic  ---Added by Hasmukh 18042013 for esic limit not check on import type allowance 
				
								
				if @AD_DEF_ID =3 or @AD_DEF_ID = 6 
					BEGIN
						IF @ESIC_Limit <> 0  
							BEGIN
								--IF @Calculated_Amount <= @ESIC_Limit --Deepal Comment as per chintan done in iconic and TOTO :- 04012022 
								--	BEGIN
										If @AD_DEF_ID = 3
											SET @E_AD_Amount = CEILING((@Calculated_Amount * @E_AD_PERCENTAGE / 100)) 
										Else
											If @AD_DEF_ID = 6 And @Upper_Round_Employer_ESIC = 0  --Added by Hardik 25/06/2014
												SET @E_AD_Amount = Round(@Calculated_Amount * @E_AD_PERCENTAGE / 100,0) 
											Else
												SET @E_AD_Amount = CEILING((@Calculated_Amount * @E_AD_PERCENTAGE / 100)) 
								--	END	
								--Else
								--	Begin
								--		SET @E_AD_Amount = 0 --Deepal Comment as per chintan done in iconic and TOTO :- 04012022 
								--	End						
							END	
							

							--Added by  dpal 04072024 Bug #29316 Gov. Rule Gross greater the 21000 then ESIC AMT Should be 0
							If @Gross_Salary >= 21000
							Begin

								set @E_AD_Amount = 0

							End
						--ELSE
						--	BEGIN
						--		SET @E_AD_AMOUNT = 0  --Deepal Comment as per chintan done in iconic and TOTO :- 04012022 
						--	END
					END
				--Else if @AD_DEF_ID = 5  --For company PF  added by hasmukh 03012012
				--	SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)	
				--Else if @AD_DEF_ID = 6  --For company ESIC added by hasmukh 03012012
				--	SET @E_AD_Amount = CEILING((@Calculated_Amount * @E_AD_PERCENTAGE / 100))	
				ELSE IF @AD_DEF_ID = 2
					BEGIN
						

						--Hardik 29/03/2019 As per New PF Rule
						If @Basic_Salary + @DA_Amount <= @PF_Limit And @Emp_Full_Pf =1 And @Calculate_Full_PF_evenif_Basic_is_less_PF_Limit = 0
							Begin
								Set @Emp_Full_Pf=0
							End

						IF @Emp_Full_PF = 0
							Begin 
							 
								IF @Calculated_Amount > @PF_Limit
									Begin 
									
										SET @Calculated_Amount = @PF_Limit
										SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
										
									End
								Else
									--Hardik 07/08/2012
									Begin
										SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
									End
							
							End
						Else
							Begin							
								-- Alpesh 20-Jul-2011 Changed for Rounding 
								--IF @AD_Rounding = 1
								--	SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
								--ELSE
								--	SET @E_AD_AMOUNT = @Calculated_Amount * @E_AD_PERCENTAGE/100
								SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)	
							End

						If @E_AD_AMOUNT > @E_AD_MAX_LIMIT and @E_AD_MAX_LIMIT > 0          ---Add by hasmukh for check max limit for % type allowance 23082011
							set @E_AD_AMOUNT = @E_AD_MAX_LIMIT
							
					End
				ELSE IF @AD_DEF_ID = 5	--or  @AD_DEF_ID = 38	 --- For Company PF ( For New DFID or  @AD_DEF_ID = 10  or  @AD_DEF_ID = 38 ) -- Added by Hardik 21/08/2018 for Full PF Case for Compentent Syngergis Client
					BEGIN	
					
						--Hardik 29/03/2019 As per New PF Rule
						If @Basic_Salary + @DA_Amount <= @PF_Limit And @Company_Full_PF =1 --And @Calculate_Full_PF_evenif_Basic_is_less_PF_Limit = 0
							Begin
							
								Set @Company_Full_PF = 0
							End
					
						
						IF @Company_Full_PF = 0
							Begin 
							 
								IF @Calculated_Amount > @PF_Limit
									Begin 
									
										SET @Calculated_Amount = @PF_Limit
										SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
										
									End
								Else
									Begin
										SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
									End
							End
						Else
							Begin							
								SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)	
							End

						If @E_AD_AMOUNT > @E_AD_MAX_LIMIT and @E_AD_MAX_LIMIT > 0          ---Add by hasmukh for check max limit for % type allowance 23082011
							set @E_AD_AMOUNT = @E_AD_MAX_LIMIT
							
					End					
				ELSE IF @AD_DEF_ID = 19	 /* Bonus Calculation */ 
					BEGIN
					
						DECLARE @Mini_Wages		NUMERIC(18,2)	--Ankit 09032016
						DECLARE @SkillType_ID	NUMERIC
						SET @Mini_Wages = 0
						SET @SkillType_ID =  0
						
						/* Get Minimum wages Amount */		
						SELECT @SkillType_ID = SkillType_ID FROM T0080_EMP_MASTER  WITH (NOLOCK) WHERE cmp_id = @Cmp_ID and emp_id = @Emp_ID
						
						SELECT @Mini_Wages = ISNULL(MW.Wages_Value,0) FROM T0050_Minimum_Wages_Master MW WITH (NOLOCK) INNER JOIN
							( SELECT MAX(Effective_Date) AS EffecDate,SkillType_ID FROM T0050_Minimum_Wages_Master WITH (NOLOCK)
								WHERE cmp_Id = @Cmp_ID AND SkillType_ID = @SkillType_ID AND Effective_Date <= @FOR_DATE GROUP BY SkillType_ID
							) Qry ON MW.SkillType_ID = Qry.SkillType_ID AND MW.Effective_Date = Qry.EffecDate
						WHERE MW.cmp_Id = @Cmp_ID AND MW.SkillType_ID = @SkillType_ID
						
						/* Bonus Calculated limit check : Bonus Max Limit In Company General Setting or Gov. Minimum Wages in Grade Master whichever is higher (Golcha EmailDated - Thu, Feb 25, 2016) -- Ankit 09032016   */
						IF ISNULL(@Mini_Wages,0) > 0 AND @Calculated_Amount >= @Max_Bonus_Salary_Amount 
							BEGIN
								IF @Mini_Wages > @Max_Bonus_Salary_Amount
									SET @Calculated_Amount = @Mini_Wages
								ELSE
									SET @Calculated_Amount = @Max_Bonus_Salary_Amount
							END
						
						
						SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
					END
				ELSE
					BEGIN							 
						--SET @E_AD_AMOUNT = @Calculated_Amount * @E_AD_PERCENTAGE/100
						
						IF @AD_Rounding = 1 or @AD_Def_Id= 4 -- For VPF
							SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
						ELSE
							SET @E_AD_AMOUNT = @Calculated_Amount * @E_AD_PERCENTAGE/100	


							If @AD_DEF_ID = 10 --added by Hardik 25/06/2014 for Admin charge for BMA
								Begin
									
									If @Company_Full_PF = 1
										Set @AC_2_3_Amount = @Calculated_Amount * @AC_2_3 /100									
									else
										If @Calculated_Amount > @PF_Limit
											Set @AC_2_3_Amount = @PF_Limit * @AC_2_3 /100
										Else
											Set @AC_2_3_Amount = @Calculated_Amount * @AC_2_3 /100
									
									If @Calculated_Amount > @PF_Limit
										Set @AC_21_1_Amount = Round(@PF_Limit * @AC_21_1/100,0)
									Else
										Set @AC_21_1_Amount = Round(@Calculated_Amount * @AC_21_1/100,0)

									If @Calculated_Amount > @PF_Limit
										Set @AC_22_3_Amount = Round(@PF_Limit * @AC_22_3/100,0)
									Else
										Set @AC_22_3_Amount = Round(@Calculated_Amount * @AC_22_3/100,0)
									
									IF @AD_Rounding = 1	
										SET @E_AD_AMOUNT = Round(Isnull(@AC_2_3_Amount,0) + Isnull(@AC_21_1_Amount,0) + Isnull(@AC_22_3_Amount,0),0)
									Else
										SET @E_AD_AMOUNT = Isnull(@AC_2_3_Amount,0) + Isnull(@AC_21_1_Amount,0) + Isnull(@AC_22_3_Amount,0)
								End
								--- End by Hardik 25/06/2014 for Admin Charge for BMA						

						
						If @E_AD_AMOUNT > @E_AD_MAX_LIMIT and @E_AD_MAX_LIMIT > 0          ---Add by hasmukh for check max limit for % type allowance 23082011
							set @E_AD_AMOUNT = @E_AD_MAX_LIMIT
						
						if @Is_Yearly = 1 -- added by mitesh on 17042012 for yearly salary input
							Begin
								set @E_AD_AMOUNT_YEARLY = @E_AD_AMOUNT
								IF @AD_Rounding = 1
									begin
										set @E_AD_AMOUNT = ROUND(@E_AD_AMOUNT/12,0)
									end
								else
									begin
										set @E_AD_AMOUNT = @E_AD_AMOUNT/12
									end
							End
					END   
			END
		
			IF @AD_Calculate_On ='FIX'
				BEGIN
					SET @E_AD_AMOUNT =@E_AD_AMOUNT	
					if @Is_Yearly = 1 -- added by mitesh on 17042012 for yearly salary input
						Begin
							set @E_AD_AMOUNT_YEARLY = @E_AD_AMOUNT
							IF @AD_Rounding = 1
									begin
										set @E_AD_AMOUNT = ROUND(@E_AD_AMOUNT/12,0)
									end
								else
									begin
										set @E_AD_AMOUNT = @E_AD_AMOUNT/12
									end
						End	
				END
					Else IF @AD_Calculate_On='Formula'	-- added by mitesh on 28042014
							Begin	
			
								Declare @Earning_Gross Numeric(18,2)
								Declare @Formula_amount Numeric(18,2)	
								set @Earning_Gross = 0
								set @Formula_amount = 0
								
								--Added By Ramiz on 21/04/2016--
								DECLARE @PASSED_FROM AS VARCHAR(50)
								SET @PASSED_FROM = 'EARN_DEDUCTION'
								--ENDS--
								
								--Added By Ramiz on 31/08/2017
								DECLARE @PASSED_AMOUNT AS NUMERIC(18,2)
								SET @PASSED_AMOUNT = ISNULL(@E_AD_AMOUNT, 0)
								--ENDS--
								
								--Select @Earning_Gross=SUM(ISNULL(M_AD_AMOUNT,0)) From dbo.T0210_MONTHLY_AD_DETAIL
								--	WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I'      
								--	AND AD_ID not in (select AD_ID from dbo.T0050_AD_MASTER where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 1)						
								SET @Earning_Gross = @Gross_Salary
								If @PASSED_AMOUNT = 0
									BEGIN
										EXEC CALCULATE_AD_AMOUNT_Formula_WISE_Salary  @Cmp_ID,@EMP_ID,@AD_ID,@FOR_DATE,@Earning_Gross,1,1,@Formula_amount output,@Basic_Salary,0,0,0,0,@PASSED_FROM , @PASSED_AMOUNT  --Passed Amount is Added By Ramiz on 04/09/2017
										SET @E_AD_AMOUNT = ISNULL(@Formula_amount,0)
									END
								ELSE
									SET @E_AD_AMOUNT = @PASSED_AMOUNT
			
								--If @M_AD_Amount > Isnull(@Max_Upper ,0) --For check max limit 16062012 hasmukh
								--	set @M_AD_Amount = isnull(@Max_Upper ,0)

							End 	
			Else If @AD_Calculate_On = 'Slab Wise'   -- Hasmukh for slab wise allowance
				Begin 
					exec CALCULATE_AD_AMOUNT_SLAB_WISE @CMP_ID,@Emp_ID,@AD_ID,@FOR_DATE,@Calculated_Amount output,@E_AD_AMOUNT output
				End
			Else If @AD_Calculate_On = 'Arrears CTC'   -- Hasmukh for Auto SP allowance when calc on CTC  --Changed the Spelling from "Arears" to "Arrears" by Ramiz on 16/11/2016
				Begin
									
					--Select @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)FROM T0100_EMP_EARN_DEDUCTION E Inner Join 
					--T0050_AD_MASTER A on E.AD_ID = A.AD_ID And E.CMP_ID=A.CMP_ID
					-- WHERE e.cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID 
					--		AND INCREMENT_ID = @INCREMENT_ID And E_AD_FLAG = 'I'   and Isnull(A.AD_PART_OF_CTC,0)=1 And A.AD_Id <> @AD_id	
					
					----Allowance get From Allowance Revice	---Ankit 25052015
					IF @Special_Allo_Cal_Setting = 1  -- Add by Deepal :- 16-04-24
					BEGIN
							DECLARE @Ad_Id_Temp Numeric(18,0)
							set @Ad_Id_Temp = 0
							Set @E_AD_PERCENTAGE = 0
			
							IF EXISTS(SELECT 1 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON EED.AD_ID = AD.AD_ID
										WHERE EED.CMP_ID = @Cmp_ID AND Emp_ID = @Emp_ID And Increment_Id = @Increment_Id AND (AD_Calculate_On = 'Arrears CTC'))
							BEGIN
								SET @Temp_Amount = 0
								SET @E_AD_AMOUNT = 0
						
								---------AD_Calculate_On = 'Arrears CTC'
								SELECT @Ad_Id_Temp = EED.AD_ID FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON EED.AD_ID = AD.AD_ID
								WHERE EED.CMP_ID = @Cmp_ID AND Emp_ID = @Emp_ID And Increment_Id = @Increment_Id And E_AD_FLAG = 'I' 
								and Isnull(AD.AD_PART_OF_CTC,0)=1 AND AD_Calculate_On = 'Arrears CTC'
							
								IF @Ad_Id_Temp > 0	
								BEGIN

										SET @Error = ''
										SET @E_AD_AMOUNT_AREARS = 0
							
										SET @E_AD_AMOUNT_AREARS = ISNULL(@E_AD_AMOUNT,0)
							
										SELECT @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)
										FROM (
											Select 
												 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /* Qry1.FOR_DATE > EED.FOR_DATE*/ Then
													Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
												 Else
													eed.e_ad_Amount End As E_Ad_Amount
												,eed.AD_ID
											FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) Inner Join 
												T0050_AD_MASTER A WITH (NOLOCK) on EED.AD_ID = A.AD_ID And EED.CMP_ID=A.CMP_ID LEFT OUTER JOIN
												( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE,EEDR.Increment_ID 
													From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
													( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised  WITH (NOLOCK)
														Where Emp_Id = @Emp_Id
														And For_date <=  CONVERT(DATETIME,CONVERT(VARCHAR(10), GETDATE(), 112))  
													 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
												) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID 
											WHERE EED.CMP_ID = @Cmp_ID AND EED.EMP_ID = @Emp_ID 
													AND EED.INCREMENT_ID = @INCREMENT_ID And A.AD_FLAG = 'I' AND Isnull(A.AD_PART_OF_CTC,0)=1
													and EED.AD_ID <> @AD_id
													and A.AD_LEVEL < @Ad_Level
								
											UNION ALL
	
											SELECT E_AD_Amount,EED.ad_id
											FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
												( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
													Where Emp_Id  = @Emp_Id And For_date <=  CONVERT(DATETIME,CONVERT(VARCHAR(10), GETDATE(), 112))  
													Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
											   INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID                     
											WHERE emp_id = @emp_id 
													And Adm.AD_ACTIVE = 1
													And EEd.ENTRY_TYPE = 'A'
													and EED.AD_ID <> @AD_id
													And ADM.AD_FLAG = 'I' AND Isnull(ADM.AD_PART_OF_CTC,0)=1
													and ADM.AD_LEVEL < @Ad_Level
													AND EED.INCREMENT_ID = @INCREMENT_ID
										)Temp	
				
										Set @E_AD_AMOUNT = @CTC - Isnull((@Basic_Salary + @Temp_Amount),0) 
							
										Declare @Salary_Based_on_Production_ArrearCTC AS INT
										Select  @Salary_Based_on_Production_ArrearCTC = ISNULL(Setting_ID,0) FROM dbo.T0040_SETTING WITH (NOLOCK)
										WHERE Cmp_ID = @Cmp_ID and Setting_Name='Calculate Salary Base on Production Details'

										IF @E_AD_AMOUNT_AREARS	<> @E_AD_AMOUNT AND @E_AD_AMOUNT_AREARS <> 0  And @Salary_Based_on_Production_ArrearCTC = 0 AND --Added By Ramiz on 20/02/2017 to Exclude this Condition for Production Based Salary
										EXISTS(SELECT 1 From T0095_INCREMENT WITH (NOLOCK) where Increment_ID = @Increment_Id And Increment_Type <> 'Transfer')  --Ankit 11122015--
										BEGIN
												SET @Error = '@@Special Allowance Calculate Wrong, Entered CTC : ' + CAST(@CTC AS VARCHAR(10)) + ', Actual CTC : ' + CAST((ISNULL(@Basic_Salary,0) + ISNULL(@Temp_Amount,0) + ISNULL(@E_AD_AMOUNT_AREARS,0) ) AS VARCHAR(10)) + '@@'
												RAISERROR(@Error ,16,2)
												Set @Temp_Amount = 0
												SET @Error = ''
												SET @E_AD_AMOUNT_AREARS = 0
												DELETE FROM T0100_EMP_EARN_DEDUCTION WHERE INCREMENT_ID = @Increment_Id
												RETURN -1
										END
								
										SET @TEMP_AMOUNT = 0
								END
						END
					END
					ELSE 
						BEGIN
								if Exists(Select 1 from  T0095_INCREMENT where Increment_ID = @INCREMENT_ID and Increment_Type = 'Joining')
								BEGIN

												SET @Error = ''
												SET @E_AD_AMOUNT_AREARS = ISNULL(@E_AD_AMOUNT,0)
					
												SELECT @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)
												FROM (
													Select 
														 Case When Qry1.Increment_ID >= EED.INCREMENT_ID Then
															Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
														 Else eed.e_ad_Amount End As E_Ad_Amount
														,eed.AD_ID
													FROM T0100_EMP_EARN_DEDUCTION EED Inner Join 
														T0050_AD_MASTER A on EED.AD_ID = A.AD_ID And EED.CMP_ID=A.CMP_ID LEFT OUTER JOIN
														( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE,EEDR.Increment_ID 
															From T0110_EMP_Earn_Deduction_Revised EEDR INNER JOIN
															( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
																Where Emp_Id = @Emp_Id
																And For_date <= CONVERT(DATETIME,CONVERT(VARCHAR(10), GETDATE(), 112))  
															 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
														) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID 
													WHERE EED.CMP_ID = @Cmp_ID AND EED.EMP_ID = @Emp_ID 
															AND EED.INCREMENT_ID = @INCREMENT_ID And E_AD_FLAG = 'I'  AND Isnull(A.AD_EFFECT_ON_CTC,0) = 1
															and EED.AD_ID <> @AD_id and A.AD_LEVEL < @Ad_Level
													)Tempe
						
												Set @E_AD_AMOUNT = @Gross_Salary - Isnull((@Basic_Salary + @Temp_Amount),0)
							END
						END
				End
			Else If @AD_Calculate_On = 'Arrears'   -- Hasmukh for Auto SP allowance when calc on gross  --Changed the Spelling from "Arears" to "Arrears" by Ramiz on 16/11/2016
				BEGIN
					
					IF @Special_Allo_Cal_Setting = 1 -- Add by Deepal :- 16-04-24 
					BEGIN
							DECLARE @Ad_Id_Temp1 Numeric(18,0)
							set @Ad_Id_Temp1 = 0
							Set @E_AD_PERCENTAGE = 0
							
							--IF EXISTS(SELECT 1 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON EED.AD_ID = AD.AD_ID
							--			WHERE EED.CMP_ID = @Cmp_ID )
										--AND Emp_ID = @Emp_ID And Increment_Id = @Increment_Id AND (AD_Calculate_On = 'Arrears')) --commented by yogesh on 20112024 to resovled bug #29266

							IF EXISTS(SELECT 1 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON EED.AD_ID = AD.AD_ID
										WHERE EED.CMP_ID = @Cmp_ID  And Increment_Id = @Increment_Id AND (AD_Calculate_On = 'Arrears'))
							BEGIN
								SET @Temp_Amount = 0
								SET @E_AD_AMOUNT = 0
						
								SELECT @Ad_Id_Temp1 = EED.AD_ID FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON EED.AD_ID = AD.AD_ID
								WHERE EED.CMP_ID = @Cmp_ID 
								AND Emp_ID = @Emp_ID And Increment_Id = @Increment_Id  --commented by yogesh on 20112024 to resovled bug #29266
								And E_AD_FLAG = 'I' 
								and Isnull(AD.AD_PART_OF_CTC,0)=1 AND AD_Calculate_On = 'Arrears'
							
								IF @Ad_Id_Temp1 > 0	
								BEGIN
										SET @Error = ''
										SET @E_AD_AMOUNT_AREARS = 0
										
										SET @E_AD_AMOUNT_AREARS = ISNULL(@E_AD_AMOUNT,0)
										
										SELECT @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)
										FROM (
											Select 
												--Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End As E_AD_AMOUNT
												 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
													Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
												 Else
													eed.e_ad_Amount End As E_Ad_Amount
												,eed.AD_ID
											FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) Inner Join 
												T0050_AD_MASTER A WITH (NOLOCK) on EED.AD_ID = A.AD_ID And EED.CMP_ID=A.CMP_ID LEFT OUTER JOIN
												( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE,EEDR.Increment_ID 
													From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
													( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
														Where Emp_Id = @Emp_Id
														And For_date <= CONVERT(DATETIME,CONVERT(VARCHAR(10), GETDATE(), 112))  
													 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
												) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID 
											WHERE EED.CMP_ID = @Cmp_ID AND EED.EMP_ID = @Emp_ID 
													AND EED.INCREMENT_ID = @INCREMENT_ID And E_AD_FLAG = 'I'  AND Isnull(A.AD_EFFECT_ON_CTC,0) = 1
													--AND EED.AD_ID not in (select AD_ID from dbo.T0050_AD_MASTER where Cmp_ID =@Cmp_ID and AD_Not_effect_salary = 1) 
													and EED.AD_ID <> @AD_id and A.AD_LEVEL < @Ad_Level
													
													
											UNION ALL
	
											SELECT E_AD_Amount,EED.ad_id
											FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
												( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
													Where Emp_Id  = @Emp_Id And For_date <= CONVERT(DATETIME,CONVERT(VARCHAR(10), GETDATE(), 112))  
													Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
											   INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID                     
											WHERE emp_id = @emp_id 
													And Adm.AD_ACTIVE = 1
													And EEd.ENTRY_TYPE = 'A'
													and EED.AD_ID <> @AD_id
													And E_AD_FLAG = 'I' AND Isnull(ADM.AD_EFFECT_ON_CTC,0)=1 
													and ADM.AD_LEVEL < @Ad_Level
													AND EED.INCREMENT_ID = @INCREMENT_ID
												--	AND EED.AD_ID not in (select AD_ID from dbo.T0050_AD_MASTER where Cmp_ID =@Cmp_ID and AD_Not_effect_salary = 1) 
											)Tempe
											
										----Allowance get From Allowance Revice	---Ankit 25052015
										
										Set @E_AD_AMOUNT = @Gross_Salary - Isnull((@Basic_Salary + @Temp_Amount),0) 
										
										Declare @Salary_Based_on_Production_Arrear AS INT
										Select  @Salary_Based_on_Production_Arrear = ISNULL(Setting_ID,0) FROM dbo.T0040_SETTING WITH (NOLOCK)
										                                      WHERE Cmp_ID = @Cmp_ID and Setting_Name='Calculate Salary Base on Production Details'

										IF @E_AD_AMOUNT_AREARS	<> @E_AD_AMOUNT AND @E_AD_AMOUNT_AREARS <> 0  And @Salary_Based_on_Production_Arrear = 0 AND
												 EXISTS(SELECT 1 From T0095_INCREMENT WITH (NOLOCK) where Increment_ID = @Increment_Id And Increment_Type <> 'Transfer')  --Ankit 11122015--
											BEGIN
												
												SET @Error = '@@Special Allowance Calculate Wrong, Entered Gross : ' + CAST(@Gross_Salary AS VARCHAR(10)) + ', Actual Gross : ' + CAST((ISNULL(@Basic_Salary,0) + ISNULL(@Temp_Amount,0) + ISNULL(@E_AD_AMOUNT_AREARS,0) ) AS VARCHAR(10)) + '@@'
												RAISERROR(@Error ,16,2)
												Set @Temp_Amount = 0
												SET @Error = ''
												SET @E_AD_AMOUNT_AREARS = 0
												
												DELETE FROM T0100_EMP_EARN_DEDUCTION WHERE INCREMENT_ID = @Increment_Id
												
												RETURN -1
											END
											
										Set @Temp_Amount = 0
								End
							End
							ELSE 
							BEGIN
									if Exists(Select 1 from  T0095_INCREMENT where Increment_ID = @INCREMENT_ID and Increment_Type = 'Joining')
									BEGIN

													SET @Error = ''
													SET @E_AD_AMOUNT_AREARS = ISNULL(@E_AD_AMOUNT,0)
					
													SELECT @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)
													FROM (
														Select 
															 Case When Qry1.Increment_ID >= EED.INCREMENT_ID Then
																Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
															 Else eed.e_ad_Amount End As E_Ad_Amount
															,eed.AD_ID
														FROM T0100_EMP_EARN_DEDUCTION EED Inner Join 
															T0050_AD_MASTER A on EED.AD_ID = A.AD_ID And EED.CMP_ID=A.CMP_ID LEFT OUTER JOIN
															( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE,EEDR.Increment_ID 
																From T0110_EMP_Earn_Deduction_Revised EEDR INNER JOIN
																( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
																	Where Emp_Id = @Emp_Id
																	And For_date <= CONVERT(DATETIME,CONVERT(VARCHAR(10), GETDATE(), 112))  
																 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
															) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID 
														WHERE EED.CMP_ID = @Cmp_ID AND EED.EMP_ID = @Emp_ID 
																AND EED.INCREMENT_ID = @INCREMENT_ID And E_AD_FLAG = 'I'  AND Isnull(A.AD_EFFECT_ON_CTC,0) = 1
																and EED.AD_ID <> @AD_id and A.AD_LEVEL < @Ad_Level
														)Tempe
							
													Set @E_AD_AMOUNT = @Gross_Salary - Isnull((@Basic_Salary + @Temp_Amount),0)
								END
							END
						End
						--ELSE
							--BEGIN 
							--	IF EXISTS(SELECT 1 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON EED.AD_ID = AD.AD_ID
							--			WHERE EED.CMP_ID = @Cmp_ID AND Emp_ID = @Emp_ID And Increment_Id = @Increment_Id)
							--	BEGIN
							--		DECLARE @EADAmount as numeric(18,2) = 0
							--		DECLARE @IncrementAmount as numeric(18,2) = 0
							--		select @EADAmount = SUM(isnull(E_AD_AMOUNT,0)) 
							--		from T0100_EMP_EARN_DEDUCTION WITH (NOLOCK)
							--		where Emp_Id = @EMP_ID and Cmp_ID = @CMP_ID and Increment_ID = @Increment_Id
									
							--		select @IncrementAmount  = (isnull(Gross_Salary,0) - isnull(Basic_Salary,0)) 
							--		from T0095_INCREMENT WITH (NOLOCK) where Emp_Id = @EMP_ID and Cmp_ID = @CMP_ID and Increment_ID = @Increment_Id and Increment_Type = 'Joining'

							--		set @E_AD_AMOUNT =  (@IncrementAmount - @EADAmount)
							--	END
							--ENd
						ELSE 
						BEGIN
								if Exists(Select 1 from  T0095_INCREMENT where Increment_ID = @INCREMENT_ID and Increment_Type = 'Joining')
								BEGIN

												SET @Error = ''
												SET @E_AD_AMOUNT_AREARS = ISNULL(@E_AD_AMOUNT,0)
					
												SELECT @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)
												FROM (
													Select 
														 Case When Qry1.Increment_ID >= EED.INCREMENT_ID Then
															Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
														 Else eed.e_ad_Amount End As E_Ad_Amount
														,eed.AD_ID
													FROM T0100_EMP_EARN_DEDUCTION EED Inner Join 
														T0050_AD_MASTER A on EED.AD_ID = A.AD_ID And EED.CMP_ID=A.CMP_ID LEFT OUTER JOIN
														( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE,EEDR.Increment_ID 
															From T0110_EMP_Earn_Deduction_Revised EEDR INNER JOIN
															( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
																Where Emp_Id = @Emp_Id
																And For_date <= CONVERT(DATETIME,CONVERT(VARCHAR(10), GETDATE(), 112))  
															 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
														) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID 
													WHERE EED.CMP_ID = @Cmp_ID AND EED.EMP_ID = @Emp_ID 
															AND EED.INCREMENT_ID = @INCREMENT_ID And E_AD_FLAG = 'I'  AND Isnull(A.AD_EFFECT_ON_CTC,0) = 1
															and EED.AD_ID <> @AD_id and A.AD_LEVEL < @Ad_Level
													)Tempe
						
												Set @E_AD_AMOUNT = @Gross_Salary - Isnull((@Basic_Salary + @Temp_Amount),0)
							END
						END
				END
			Else if @AD_Calculate_On = 'Branch + Grade'
				Begin
				
					Declare @Branch_Grade_Cal_On Varchar(100)
					Set @Branch_Grade_Cal_On = ''
					
					Declare @Branch_Grade_Amount Numeric(18,2)
					Set @Branch_Grade_Amount = 0
					
					Select @Branch_Grade_Cal_On = GB.AD_CALCULATE_ON, 
						   @Branch_Grade_Amount = GB.AD_Amount
					From T0100_AD_Grade_Branch_Wise GB 
					Inner Join(
								SELECT MAX(Effective_Date) as EffectiveDate,Branch_ID,Grd_ID,AD_ID 
								From T0100_AD_Grade_Branch_Wise WITH (NOLOCK)
								Where Effective_Date <= @For_Date
								group by Branch_ID,Grd_ID,AD_ID
							  ) as Qry 
					ON GB.Branch_ID = Qry.Branch_ID and GB.Grd_ID = Qry.Grd_ID and GB.AD_ID = Qry.AD_ID
					Where GB.Branch_ID = @Branch_ID and GB.Grd_ID = @Grd_ID and GB.AD_ID = @AD_ID
				
					IF @E_AD_MODE = '%'
						Begin
							if @Branch_Grade_Amount > 0
								Begin
									if @AD_Calculate_on_Grade_Branch = ''
									
									IF @Branch_Grade_Cal_On = 'Basic Salary'
										set @Calculated_Amount = @Basic_Salary 
									Else IF @Branch_Grade_Cal_On = 'CTC' 
										set @Calculated_Amount = @CTC 
									Else IF @Branch_Grade_Cal_On = 'Gross Salary'
										Set @Calculated_Amount =  @Gross_Salary
										
									IF @AD_Rounding = 1
										begin
										
											Set @E_AD_AMOUNT = ROUND((@Calculated_Amount * @Branch_Grade_Amount)/100,0)
										end
									else
										begin
										
											Set @E_AD_AMOUNT = (@Calculated_Amount * @Branch_Grade_Amount)/100
										end
								End
						End
					Else
					
						Begin
							Set @E_AD_AMOUNT = @Branch_Grade_Amount
						End
				End	
	--select @E_AD_AMOUNT
	Set @E_AD_AMOUNT = Isnull(@E_AD_AMOUNT,0)
	
	--select @E_AD_AMOUNT,@E_AD_MAX_LIMIT,@E_AD_MAX_LIMIT
	If @E_AD_AMOUNT > @E_AD_MAX_LIMIT and @E_AD_MAX_LIMIT > 0          ---Add by hasmukh for check max limit for % type allowance 23082011
		set @E_AD_AMOUNT = @E_AD_MAX_LIMIT
	
	--select @AD_ID,@E_AD_AMOUNT
	
	IF @tran_type  = 'I' 
			BEGIN		
			--SELECT AD_TRAN_ID FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND INCREMENT_ID=@INCREMENT_ID AND AD_ID=@AD_ID
			
				IF EXISTS(SELECT AD_TRAN_ID FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND INCREMENT_ID=@INCREMENT_ID AND AD_ID=@AD_ID)					
					BEGIN	
						SET @AD_ID = 0				
						RETURN
					END
				
				SELECT  @AD_TRAN_ID = ISNULL(MAX(AD_TRAN_ID),0) + 1 FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK)
				
			  -- select @AD_TRAN_ID,@EMP_ID,@CMP_ID,@AD_ID,@INCREMENT_ID,@FOR_DATE,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_MAX_LIMIT,@E_AD_AMOUNT_YEARLY
			
			
				INSERT INTO T0100_EMP_EARN_DEDUCTION
				       (AD_TRAN_ID,EMP_ID,CMP_ID,AD_ID,INCREMENT_ID,FOR_DATE,E_AD_FLAG,E_AD_MODE,E_AD_PERCENTAGE,E_AD_AMOUNT,E_AD_MAX_LIMIT,E_AD_YEARLY_AMOUNT,Is_Calculate_Zero)
				--VALUES (@AD_TRAN_ID,@EMP_ID,@CMP_ID,@AD_ID,@INCREMENT_ID,@FOR_DATE,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,CASE WHEN Isnull(@E_AD_AMOUNT,0) = -1 then 0 else @E_AD_AMOUNT end,@E_AD_MAX_LIMIT,@E_AD_AMOUNT_YEARLY, CASE WHEN Isnull(@E_AD_AMOUNT,0) = -1 then 1 else 0 end )
				VALUES (@AD_TRAN_ID,@EMP_ID,@CMP_ID,@AD_ID,@INCREMENT_ID,@FOR_DATE,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,CASE WHEN Isnull(@E_AD_AMOUNT,0) = -1 then 0 else @E_AD_AMOUNT end,@E_AD_MAX_LIMIT,@E_AD_AMOUNT_YEARLY, CASE WHEN Isnull(@E_AD_AMOUNT,0) = -1 then 1 else 0 end )
				
				--select  * from T0100_EMP_EARN_DEDUCTION where EMP_ID=@EMP_ID and ad_id=1488
				
				if Exists(Select Increment_ID From dbo.T0095_INCREMENT WITH (NOLOCK) Where Emp_ID = @Emp_ID and Increment_effective_Date > @for_Date and (Increment_Type = 'Transfer' or  Increment_Type = 'Deputation') and Increment_ID <> @INCREMENT_ID)
					begin
					
							Declare  @Inc_Table table(
							inc_id numeric,
							increment_type nvarchar(20)
						)
						
						insert into @Inc_table
						Select Increment_ID,Increment_Type From dbo.T0095_INCREMENT WITH (NOLOCK) Where Emp_ID = @Emp_ID and Increment_effective_Date > @FOR_DATE 
						
						declare @Inc_id_update numeric
						declare @Inc_flag numeric
						declare @inc_type_update nvarchar(20)
						set @Inc_id_update = 0
						set @inc_type_update = ''
						set @Inc_flag = 0
						
						
						
						Declare cur_inc cursor for	                  
							select inc_id,increment_type from @Inc_Table 
						Open cur_inc                      
						Fetch next from cur_inc into @Inc_id_update,@inc_type_update
						   	While @@fetch_status = 0                    
							Begin 		
							
									if @inc_type_update = 'Increment'
										begin
											set @Inc_flag = 1
										end
									else if @Inc_flag = 0 
									
									-- Added by rohit for increment update then enter duplicate allowance on 05-mar-2014
									 if EXISTS(SELECT AD_TRAN_ID FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND INCREMENT_ID=@Inc_id_update AND AD_ID=@AD_ID)					
										begin
										select @AD_TRAN_ID = AD_TRAN_ID FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND INCREMENT_ID=@Inc_id_update AND AD_ID=@AD_ID
										
										UPDATE    T0100_EMP_EARN_DEDUCTION
											SET       FOR_DATE=@FOR_DATE,
													  E_AD_FLAG=@E_AD_FLAG,
													  E_AD_MODE=@E_AD_MODE,
													  E_AD_PERCENTAGE=@E_AD_PERCENTAGE,
													  E_AD_AMOUNT=@E_AD_AMOUNT,
													  E_AD_MAX_LIMIT=@E_AD_MAX_LIMIT,
													  E_AD_YEARLY_AMOUNT = @E_AD_AMOUNT_YEARLY
											Where AD_TRAN_ID = @AD_TRAN_ID and EMP_ID = @EMP_ID and CMP_ID = @CMP_ID and INCREMENT_ID = @Inc_id_update and AD_ID = @AD_ID
										end
										
										else
										-- ended by rohit for increment update then enter duplicate allowance on 05-mar-2014
										begin
										
											SELECT  @AD_TRAN_ID = ISNULL(MAX(AD_TRAN_ID),0) + 1 FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK)
											INSERT INTO T0100_EMP_EARN_DEDUCTION
												(AD_TRAN_ID,EMP_ID,CMP_ID,AD_ID,INCREMENT_ID,FOR_DATE,E_AD_FLAG,E_AD_MODE,E_AD_PERCENTAGE,E_AD_AMOUNT,E_AD_MAX_LIMIT,E_AD_YEARLY_AMOUNT)
											VALUES (@AD_TRAN_ID,@EMP_ID,@CMP_ID,@AD_ID,@Inc_id_update,@FOR_DATE,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_MAX_LIMIT,@E_AD_AMOUNT_YEARLY)		
											
										end
									fetch next from cur_inc into @Inc_id_update,@inc_type_update
							  
							end                    
						close cur_inc                    
						deallocate cur_inc
						--drop table @Inc_Table							
					end
				
				--Added By Mukti 01-07-2016(Start)	
				if @User_Id<>0
				BEGIN		
					exec P9999_Audit_get @table = 'T0100_EMP_EARN_DEDUCTION' ,@key_column='AD_TRAN_ID',@key_Values=@AD_TRAN_ID,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
				end
				--Added By Mukti 01-07-2016(End)	
						
			END
	ELSE IF @Tran_Type = 'U' 
		BEGIN
		
				IF EXISTS(SELECT AD_TRAN_ID FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND INCREMENT_ID=@INCREMENT_ID AND AD_ID=@AD_ID)					
					BEGIN	    
						SET @AD_ID = 0
						RETURN
					END
			--Added By Mukti 01-07-2016(Start)		
			if @User_Id<>0
				BEGIN		
					exec P9999_Audit_get @table='T0100_EMP_EARN_DEDUCTION' ,@key_column='AD_TRAN_ID',@key_Values=@AD_TRAN_ID,@String=@String output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
				END
			--Added By Mukti 01-07-2016(End)		
				
			UPDATE    T0100_EMP_EARN_DEDUCTION
			SET       FOR_DATE=@FOR_DATE,
					  E_AD_FLAG=@E_AD_FLAG,
					  E_AD_MODE=@E_AD_MODE,
					  E_AD_PERCENTAGE=@E_AD_PERCENTAGE,
					  E_AD_AMOUNT=@E_AD_AMOUNT,
					  E_AD_MAX_LIMIT=@E_AD_MAX_LIMIT,
					  E_AD_YEARLY_AMOUNT = @E_AD_AMOUNT_YEARLY
            Where AD_TRAN_ID = @AD_TRAN_ID and EMP_ID = @EMP_ID and CMP_ID = @CMP_ID and INCREMENT_ID = @INCREMENT_ID and AD_ID = @AD_ID
				
			--Added By Mukti 01-07-2016(Start)	
			if @User_Id<>0
				BEGIN				
					exec P9999_Audit_get @table = 'T0100_EMP_EARN_DEDUCTION' ,@key_column='AD_TRAN_ID',@key_Values=@AD_TRAN_ID,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
				END
			--Added By Mukti 01-07-2016(End)	 
		end
	Else if @Tran_Type = 'D' 
		begin					
			--Added By Mukti 01-07-2016(Start)	
			if @User_Id<>0
				BEGIN			
					exec P9999_Audit_get @table='T0100_EMP_EARN_DEDUCTION' ,@key_column='AD_TRAN_ID',@key_Values=@AD_TRAN_ID,@String=@String output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
				END
			--Added By Mukti 01-07-2016(End)	
						
				Delete From T0100_EMP_EARN_DEDUCTION Where AD_TRAN_ID = @AD_TRAN_ID and Cmp_Id=@Cmp_ID
				
				IF EXISTS(SELECT EMP_ID FROM  T0110_EMP_EARN_DEDUCTION_REVISED WITH (NOLOCK) WHERE Cmp_Id = @Cmp_Id And Emp_Id = @Emp_id And AD_ID = @AD_ID And TRAN_ID = @AD_TRAN_ID )	--Ankit 29082014
					BEGIN
						IF EXISTS(SELECT EMP_ID FROM  T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) WHERE Cmp_Id=@Cmp_Id And Emp_Id=@Emp_id And S_Month_St_Date>=@FOR_DATE and S_Month_St_Date<=@FOR_DATE )
							BEGIN
								RAISERROR('Salary Settlement Exists',16,2)
								RETURN -1
							END
						
						DELETE FROM T0110_EMP_EARN_DEDUCTION_REVISED WHERE Cmp_Id = @Cmp_Id And Emp_Id = @Emp_id And AD_ID = @AD_ID And TRAN_ID = @AD_TRAN_ID 
						
					END
					
		end


	----------- PT update -------------------------------------------------------
		if @Emp_PT = 1
			begin
				--Select @AD_Other_Amount = isnull(sum(E_AD_Amount),0) from T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) where Increment_ID=@Increment_ID and E_AD_Flag ='I'
				Select @AD_Other_Amount = isnull(sum(E_AD_Amount),0) 
				from T0100_EMP_EARN_DEDUCTION EED
				INNER JOIN T0050_AD_MASTER AD ON EEd.AD_ID = AD.AD_ID
				where Increment_ID=@Increment_ID and E_AD_Flag ='I'
				and ad.AD_NOT_EFFECT_SALARY = 0
				and ad.AD_NOT_EFFECT_ON_PT = 0
				

				set @Basic_Salary = @Basic_Salary + isnull(@AD_Other_Amount,0)
				Exec SP_CALCULATE_PT_AMOUNT @Cmp_ID,@Emp_ID,@Current_Date,@Basic_Salary,@PT_Amount output,'',@Branch_ID
			end
			
		Update T0095_Increment set Emp_PT_Amount = @PT_Amount where Increment_ID = @Increment_ID 
	
	---------CTC Update-----------------------------
	/* 
		Code Uncommented and Managed from Admin Setting by Ramiz on 09/05/2016
		
		This CTC Update Portion was Commented because , if Salary Structure is dependent on CTC then it was Updating Incorrect CTC in Employee master ,
		So if the Structure is not dependent on CTC , enable this Settings from Admin Setting.
	   
	*/
		DECLARE @AUTO_CALCULATE_CTC	TINYINT
		SET @AUTO_CALCULATE_CTC = 0
		
		SELECT @AUTO_CALCULATE_CTC = ISNULL(SETTING_VALUE,0) FROM T0040_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND
											 SETTING_NAME = 'Auto Calculate CTC Amount during Salary Structure Assigning or Changing'
	
		IF (@AUTO_CALCULATE_CTC > 0)									
			BEGIN				
				DECLARE @CTC_Allow				NUMERIC(18,2)
				DECLARE @Increment_Amount_CTC	NUMERIC(18,2)
				SET @CTC_Allow			= 0
				SET @AD_Other_Amount	= 0
				SET @Basic_Salary		= 0
				SET @Increment_Amount_CTC = 0
				
				SELECT @Increment_Amount_CTC = SUM(ISNULL(Incerment_Amount_CTC,0)), @Basic_Salary = SUM(ISNULL(Basic_Salary,0)) 
				FROM T0095_INCREMENT WITH (NOLOCK) WHERE Increment_ID = @Increment_ID AND Increment_Type <> 'Joining'
				
				IF @Increment_Amount_CTC = 0
					BEGIN
						SELECT	@AD_Other_Amount = ISNULL(SUM(E_AD_Amount),0) 
						FROM	T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID
						WHERE	Increment_ID=@Increment_ID and E_AD_Flag ='I' AND AM.AD_PART_OF_CTC = 1
						
						SET @CTC_Allow = @Basic_Salary + ISNULL(@AD_Other_Amount,0)
						
						UPDATE T0095_Increment SET CTC = @CTC_Allow WHERE Increment_ID = @Increment_ID 
					END
			END
	------------------------------------------------
	
	if @User_Id<>0
		exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Grade Wise Allowance',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
RETURN

