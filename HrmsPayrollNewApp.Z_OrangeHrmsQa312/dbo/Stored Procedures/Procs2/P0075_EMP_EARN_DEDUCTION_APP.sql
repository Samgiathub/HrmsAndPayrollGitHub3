
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0075_EMP_EARN_DEDUCTION_APP]
	 @AD_TRAN_ID	Int OUTPUT
	,@CMP_ID		Int
	,@Emp_Tran_ID bigint 
	,@Emp_Application_ID int 
	,@AD_ID			Int
	,@INCREMENT_ID	Int
	,@FOR_DATE		DateTime =Null
	,@E_AD_FLAG		Char(1)
	,@E_AD_MODE		Varchar(10)
	,@E_AD_PERCENTAGE	numeric(18,5) 
	,@E_AD_AMOUNT		numeric(18,2)
	,@E_AD_MAX_LIMIT	Int
	,@tran_type			varchar(1)
	,@AD_Calculate_on_Grade_Branch Varchar(100) = ''
	,@User_Id Int = 0   
	,@IP_Address varchar(30)= '' 
	,@Approved_Emp_ID int
	,@Approved_Date datetime = Null
	,@Rpt_Level int 
	
AS
		
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		
		Declare @AD_Calculate_On varchar(20)
		Declare @AD_Other_Amount	numeric (18,2)
		Declare @Calculated_Amount	numeric (18,2)
		Declare @AD_DEF_ID			int
		Declare @Emp_Full_PF		int
		Declare @Company_Full_PF	int 
		Declare @Emp_PT				int
		Declare @Basic_Salary		numeric(18,2)
		declare @PT_Amount			numeric 
		Declare @Branch_ID			numeric
		Declare @AD_Amount as numeric(18,2)
		Declare @Gross_Salary		numeric
		Declare @CTC				Numeric
		Declare @Temp_Amount		Numeric(18,2)  
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
		Set @Company_Full_PF = 0 
		
			
		declare @OldValue as  varchar(max)
		Declare @String as varchar(max)
		set @String=''
		set @OldValue =''
		
				
		if @E_AD_AMOUNT is null
			set @AD_Other_Amount = 0
			
		set @Emp_Full_PF =0 
		set @PT_Amount =0
		
		
		
		Declare @AC_2_3 as Numeric(18,3)
		Declare @AC_22_3 as Numeric(18,3)
		Declare @AC_21_1 as Numeric(18,3)
		Declare @PF_Limit as Numeric(18,2)
		Declare @AC_2_3_Amount as Numeric(18,2)
		Declare @AC_22_3_Amount as Numeric(18,2)
		Declare @AC_21_1_Amount as Numeric(18,2)
		Declare @AD_Rounding  INT	
		Declare @Max_Bonus_Salary_Amount as Numeric(18,2)	
		
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

		Declare @Ad_Level NUMERIC(18,0)	
		SET @Ad_Level = 0
		declare @IS_ROUNDING_Allowance int 
		
		SELECT @AD_DEF_ID = AD_DEF_ID ,@AD_Calculate_On = AD_CALCULATE_ON,@AD_Amount =Ad_Amount,@Is_Yearly = Is_Yearly, @Ad_Level = AD_LEVEL 
		 , @IS_ROUNDING_Allowance = is_rounding 
		FROM T0050_AD_MASTER WITH (NOLOCK) WHERE AD_ID =@AD_ID
		
		SELECT  @Branch_ID		= Branch_ID , @Emp_PT =Emp_PT, @Emp_Full_PF = Emp_Full_PF ,@Basic_Salary = isnull(Basic_Salary,0) ,@Calculated_Amount = isnull(Basic_Salary,0) 
				, @Gross_Salary = Isnull(Gross_Salary,0), @CTC = Isnull(CTC,0),@Grd_Id = Grd_ID, @Company_Full_PF = Isnull(Emp_Auto_VPF,0)
		FROM	T0070_EMP_INCREMENT_APP WITH (NOLOCK) WHERE Increment_ID =@Increment_ID

		Select Top 1 @AC_2_3 =ACC_2_3, @AC_22_3 = ACC_22_3,
			@AC_21_1 =ACC_21_1, @PF_Limit = PF_LIMIT, @AD_Rounding = AD_Rounding, @ESIC_Limit = ISNULL(ESIC_Upper_Limit,0) ,@Max_Bonus_Salary_Amount = ISNULL(Max_Bonus_Salary_Amount,0)
		from T0040_General_setting gs WITH (NOLOCK) Left outer join     
			T0050_General_Detail gd WITH (NOLOCK) on gs.gen_Id =gd.gen_ID     
		where gs.Cmp_Id=@cmp_Id and Branch_ID = isnull(@Branch_ID,Branch_ID)    
		and For_Date = (SELECT MAX(For_Date) FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID And For_Date <= @FOR_DATE)
		
		Select @E_AD_MAX_LIMIT = isnull(AD_MAX_LIMIT,0) from T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) where Ad_ID = @AD_ID And Grd_ID = @Grd_Id
		set @AD_Rounding =  isnull(@IS_ROUNDING_Allowance,@AD_Rounding)				
	
		
		Declare @Upper_Round_Employer_ESIC as int
		Select  @Upper_Round_Employer_ESIC = (Select Setting_ID from dbo.T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name='Upper Round for Employer ESIC')

		
	
		IF @AD_Calculate_On = 'Actual Gross' 
			set @Calculated_Amount = @Gross_Salary 
		Else IF @AD_Calculate_On = 'CTC' 
			set @Calculated_Amount = @CTC 
		Else if @AD_Calculate_On = 'Extra OT' 
			set @Calculated_Amount = 0
		Else
			Set @Calculated_Amount = @Basic_Salary 

	
		
		IF @E_AD_PERCENTAGE >  0
			BEGIN				
				SELECT @AD_Other_Amount = ISNULL(SUM(E_AD_Amount),0) FROM T0075_EMP_EARN_DEDUCTION_APP EED WITH (NOLOCK) inner join 
					T0050_ad_master AM WITH (NOLOCK) on eed.ad_id = am.ad_id WHERE Increment_ID=@Increment_ID  
						AND eed.AD_ID IN (SELECT AD_ID FROM T0060_EFFECT_AD_MASTER WITH (NOLOCK) WHERE Effect_AD_ID =@AD_ID)



				SELECT @AD_Other_Amount_esic = ISNULL(SUM(E_AD_Amount),0) FROM T0075_EMP_EARN_DEDUCTION_APP EED WITH (NOLOCK) inner join 
					T0050_ad_master AM WITH (NOLOCK) on eed.ad_id = am.ad_id WHERE Increment_ID=@Increment_ID and am.AD_CALCULATE_ON <> 'Import'   
						AND eed.AD_ID IN (SELECT AD_ID FROM T0060_EFFECT_AD_MASTER WITH (NOLOCK) WHERE Effect_AD_ID =@AD_ID)
											
			
								
				set @ESIC_limit_Calculated_Amount = @Calculated_Amount   

				SET @Calculated_Amount = @Calculated_Amount + @AD_Other_Amount

				Set @ESIC_limit_Calculated_Amount = @ESIC_limit_Calculated_Amount + @AD_Other_Amount_esic 
				
				

				if @AD_DEF_ID =3 or @AD_DEF_ID = 6 
					BEGIN
						IF @ESIC_Limit <> 0  
							BEGIN
								IF @Calculated_Amount <= @ESIC_Limit
									BEGIN
										If @AD_DEF_ID = 3
											SET @E_AD_Amount = CEILING((@Calculated_Amount * @E_AD_PERCENTAGE / 100)) 
										Else
											If @AD_DEF_ID = 6 And @Upper_Round_Employer_ESIC = 0  --Added by Hardik 25/06/2014
												SET @E_AD_Amount = Round(@Calculated_Amount * @E_AD_PERCENTAGE / 100,0) 
											Else
												SET @E_AD_Amount = CEILING((@Calculated_Amount * @E_AD_PERCENTAGE / 100)) 
									END	
								Else
									Begin
										SET @E_AD_Amount = 0
									End						
							END		
						ELSE
							BEGIN
								SET @E_AD_AMOUNT = 0 
							END
					END
				
				ELSE IF @AD_DEF_ID = 2
					BEGIN
					
						IF @Emp_Full_PF = 0
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

						If @E_AD_AMOUNT > @E_AD_MAX_LIMIT and @E_AD_MAX_LIMIT > 0          
							set @E_AD_AMOUNT = @E_AD_MAX_LIMIT
							
					End
				ELSE IF @AD_DEF_ID = 5 		 
					BEGIN
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

						If @E_AD_AMOUNT > @E_AD_MAX_LIMIT and @E_AD_MAX_LIMIT > 0          
							set @E_AD_AMOUNT = @E_AD_MAX_LIMIT
							
					End					
				ELSE IF @AD_DEF_ID = 19	 
					BEGIN
					
						DECLARE @Mini_Wages		NUMERIC(18,2)	
						DECLARE @SkillType_ID	NUMERIC
						SET @Mini_Wages = 0
						SET @SkillType_ID =  0
						
								
						SELECT @SkillType_ID = SkillType_ID FROM T0060_EMP_MASTER_APP WITH (NOLOCK) WHERE cmp_id = @Cmp_ID 
						and Emp_Tran_ID=@Emp_Tran_ID 
						
						
						
						SELECT @Mini_Wages = ISNULL(MW.Wages_Value,0) FROM T0050_Minimum_Wages_Master MW WITH (NOLOCK) INNER JOIN
							( SELECT MAX(Effective_Date) AS EffecDate,SkillType_ID FROM T0050_Minimum_Wages_Master WITH (NOLOCK)
								WHERE cmp_Id = @Cmp_ID AND SkillType_ID = @SkillType_ID AND Effective_Date <= @FOR_DATE GROUP BY SkillType_ID
							) Qry ON MW.SkillType_ID = Qry.SkillType_ID AND MW.Effective_Date = Qry.EffecDate
						WHERE MW.cmp_Id = @Cmp_ID AND MW.SkillType_ID = @SkillType_ID
						
					
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
						
						
						IF @AD_Rounding = 1 or @AD_Def_Id= 4 -- For VPF
							SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
						ELSE
							SET @E_AD_AMOUNT = @Calculated_Amount * @E_AD_PERCENTAGE/100	


							If @AD_DEF_ID = 10 
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
								


						If @E_AD_AMOUNT > @E_AD_MAX_LIMIT and @E_AD_MAX_LIMIT > 0         
							set @E_AD_AMOUNT = @E_AD_MAX_LIMIT
						
						if @Is_Yearly = 1 
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
					if @Is_Yearly = 1 
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
					Else IF @AD_Calculate_On='Formula'	
							Begin	
			
								Declare @Earning_Gross Numeric(18,2)
								Declare @Formula_amount Numeric(18,2)	
								set @Earning_Gross = 0
								set @Formula_amount = 0
								
								
								DECLARE @PASSED_FROM AS VARCHAR(50)
								SET @PASSED_FROM = 'EARN_DEDUCTION'
								
								
								
								DECLARE @PASSED_AMOUNT AS NUMERIC(18,2)
								SET @PASSED_AMOUNT = ISNULL(@E_AD_AMOUNT, 0)
								
								
								
								SET @Earning_Gross = @Gross_Salary
								If @PASSED_AMOUNT = 0
									BEGIN
										EXEC CALCULATE_AD_AMOUNT_Formula_WISE_Salary_FOR_EMP_APP @Cmp_ID,@Emp_Tran_ID,@Emp_Application_ID,@AD_ID,@FOR_DATE,@Earning_Gross,1,1,@Formula_amount output,@Basic_Salary,0,0,0,0, @PASSED_AMOUNT  
										
										SET @E_AD_AMOUNT = ISNULL(@Formula_amount,0)
									END
								ELSE
									SET @E_AD_AMOUNT = @PASSED_AMOUNT
			
								
							End 	
			Else If @AD_Calculate_On = 'Slab Wise'   
				Begin 
					exec CALCULATE_AD_AMOUNT_SLAB_WISE_FOR_EMP_APP @CMP_ID,@Emp_Tran_ID,@Emp_Application_ID,@AD_ID,@FOR_DATE,@Calculated_Amount output,@E_AD_AMOUNT output
				End
			Else If @AD_Calculate_On = 'Arrears CTC'  
				Begin
					
			
					SET @Error = ''
					SET @E_AD_AMOUNT_AREARS = 0
					
					SET @E_AD_AMOUNT_AREARS = ISNULL(@E_AD_AMOUNT,0)
					
					SELECT @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)
					FROM (Select eed.e_ad_Amount As E_Ad_Amount,eed.AD_ID
							FROM T0075_EMP_EARN_DEDUCTION_APP EED WITH (NOLOCK)
									Inner Join T0050_AD_MASTER A WITH (NOLOCK) on EED.AD_ID = A.AD_ID And EED.CMP_ID=A.CMP_ID 
						WHERE EED.CMP_ID = @Cmp_ID 
						AND EED.Emp_Tran_ID=@Emp_Tran_ID and EED.Emp_Application_ID=@Emp_Application_ID
						
								AND EED.INCREMENT_ID = @INCREMENT_ID And A.AD_FLAG = 'I' AND Isnull(A.AD_PART_OF_CTC,0)=1
								and EED.AD_ID <> @AD_id
								and A.AD_LEVEL < @Ad_Level)Temp	
								
					
					
					Set @E_AD_AMOUNT = @CTC - Isnull((@Basic_Salary + @Temp_Amount),0) 
					
					Declare @Salary_Based_on_Production_ArrearCTC AS INT
		            Select  @Salary_Based_on_Production_ArrearCTC = ISNULL(Setting_ID,0) FROM dbo.T0040_SETTING  WITH (NOLOCK)
		                                                  WHERE Cmp_ID = @Cmp_ID and Setting_Name='Calculate Salary Base on Production Details'

					IF @E_AD_AMOUNT_AREARS	<> @E_AD_AMOUNT AND @E_AD_AMOUNT_AREARS <> 0  And @Salary_Based_on_Production_ArrearCTC = 0 AND --Added By Ramiz on 20/02/2017 to Exclude this Condition for Production Based Salary
							 EXISTS(SELECT 1 From T0070_EMP_INCREMENT_APP WITH (NOLOCK) where Increment_ID = @Increment_Id And Increment_Type <> 'Transfer')  --Ankit 11122015--
						BEGIN
							
							SET @Error = '@@Special Allowance Calculate Wrong, Entered CTC : ' + CAST(@CTC AS VARCHAR(10)) + ', Actual CTC : ' + CAST((ISNULL(@Basic_Salary,0) + ISNULL(@Temp_Amount,0) + ISNULL(@E_AD_AMOUNT_AREARS,0) ) AS VARCHAR(10)) + '@@'
							RAISERROR(@Error ,16,2)
							Set @Temp_Amount = 0
							SET @Error = ''
							SET @E_AD_AMOUNT_AREARS = 0
							
							DELETE FROM T0075_EMP_EARN_DEDUCTION_APP WHERE INCREMENT_ID = @Increment_Id
							
							RETURN -1
						END
						
					Set @Temp_Amount = 0
					
					set @Temp_Amount = 0
				
				End
			Else If @AD_Calculate_On = 'Arrears'   
				Begin
					
					
					SET @Error = ''
					SET @E_AD_AMOUNT_AREARS = 0
					
					SET @E_AD_AMOUNT_AREARS = ISNULL(@E_AD_AMOUNT,0)
					SELECT @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)
					FROM (Select eed.e_ad_Amount As E_Ad_Amount,eed.AD_ID
							FROM T0075_EMP_EARN_DEDUCTION_APP EED WITH (NOLOCK)
									Inner Join T0050_AD_MASTER A WITH (NOLOCK) on EED.AD_ID = A.AD_ID And EED.CMP_ID=A.CMP_ID 
						WHERE EED.CMP_ID = @Cmp_ID 
						AND EED.Emp_Tran_ID=@Emp_Tran_ID and EED.Emp_Application_ID=@Emp_Application_ID
						
								AND EED.INCREMENT_ID = @INCREMENT_ID And A.AD_FLAG = 'I' AND Isnull(A.AD_PART_OF_CTC,0)=1
								and EED.AD_ID <> @AD_id
								and A.AD_LEVEL < @Ad_Level)Tempe	
								
					
					
					Set @E_AD_AMOUNT = @Gross_Salary - Isnull((@Basic_Salary + @Temp_Amount),0) 
					
					Declare @Salary_Based_on_Production_Arrear AS INT
		            Select  @Salary_Based_on_Production_Arrear = ISNULL(Setting_ID,0) FROM dbo.T0040_SETTING WITH (NOLOCK)
		                                                  WHERE Cmp_ID = @Cmp_ID and Setting_Name='Calculate Salary Base on Production Details'

					IF @E_AD_AMOUNT_AREARS	<> @E_AD_AMOUNT AND @E_AD_AMOUNT_AREARS <> 0  And @Salary_Based_on_Production_Arrear = 0 AND
							 EXISTS(SELECT 1 From T0070_EMP_INCREMENT_APP WITH (NOLOCK) where Increment_ID = @Increment_Id And Increment_Type <> 'Transfer')  --Ankit 11122015--
						BEGIN
							
							SET @Error = '@@Special Allowance Calculate Wrong, Entered Gross : ' + CAST(@Gross_Salary AS VARCHAR(10)) + ', Actual Gross : ' + CAST((ISNULL(@Basic_Salary,0) + ISNULL(@Temp_Amount,0) + ISNULL(@E_AD_AMOUNT_AREARS,0) ) AS VARCHAR(10)) + '@@'
							RAISERROR(@Error ,16,2)
							Set @Temp_Amount = 0
							SET @Error = ''
							SET @E_AD_AMOUNT_AREARS = 0
							
							DELETE FROM T0075_EMP_EARN_DEDUCTION_APP WHERE INCREMENT_ID = @Increment_Id
							
							RETURN -1
						END
						
					Set @Temp_Amount = 0
				End
			Else if @AD_Calculate_On = 'Branch + Grade'
				Begin
				
					Declare @Branch_Grade_Cal_On Varchar(100)
					Set @Branch_Grade_Cal_On = ''
					
					Declare @Branch_Grade_Amount Numeric(18,2)
					Set @Branch_Grade_Amount = 0
					
					Select @Branch_Grade_Cal_On = GB.AD_CALCULATE_ON, 
						   @Branch_Grade_Amount = GB.AD_Amount
					From T0100_AD_Grade_Branch_Wise GB WITH (NOLOCK)
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
	

	Set @E_AD_AMOUNT = Isnull(@E_AD_AMOUNT,0)
	
	
	If @E_AD_AMOUNT > @E_AD_MAX_LIMIT and @E_AD_MAX_LIMIT > 0          ---Add by hasmukh for check max limit for % type allowance 23082011
		set @E_AD_AMOUNT = @E_AD_MAX_LIMIT

	
	IF @tran_type  = 'I' 
			BEGIN		
			
				IF EXISTS(SELECT AD_TRAN_ID FROM T0075_EMP_EARN_DEDUCTION_APP WITH (NOLOCK)
							WHERE cmp_ID = @Cmp_ID AND Emp_Application_ID=@Emp_Application_ID 
								AND INCREMENT_ID=@INCREMENT_ID AND AD_ID=@AD_ID)					
					BEGIN	
						SET @AD_ID = 0				
						RETURN
					END
				
				SELECT  @AD_TRAN_ID = ISNULL(MAX(AD_TRAN_ID),0) + 1 FROM T0075_EMP_EARN_DEDUCTION_APP WITH (NOLOCK)
				
				
			
				If Exists(select 1 from  T0075_EMP_EARN_DEDUCTION_APP WITH (NOLOCK) where AD_ID = @AD_ID and  Emp_Tran_ID=@Emp_Tran_ID and CMP_ID = @CMP_ID)
				Begin
						
							  
					UPDATE    T0075_EMP_EARN_DEDUCTION_APP
					SET      
							  E_AD_FLAG=@E_AD_FLAG,
							  E_AD_MODE=@E_AD_MODE,
							  E_AD_PERCENTAGE=@E_AD_PERCENTAGE,
							  E_AD_AMOUNT=@E_AD_AMOUNT,
							  E_AD_MAX_LIMIT=@E_AD_MAX_LIMIT,
							  E_AD_YEARLY_AMOUNT = @E_AD_AMOUNT_YEARLY,
							  Approved_Date=getdate()
					Where   AD_ID = @AD_ID and  Emp_Tran_ID=@Emp_Tran_ID and CMP_ID = @CMP_ID
            
					--select  * from T0075_EMP_EARN_DEDUCTION_APP where AD_ID = @AD_ID and  Emp_Tran_ID=@Emp_Tran_ID and CMP_ID = @CMP_ID
				END
				Else
				Begin
				
							INSERT INTO T0075_EMP_EARN_DEDUCTION_APP
								   (Emp_Tran_ID,Emp_Application_ID,AD_TRAN_ID,CMP_ID,AD_ID,INCREMENT_ID,E_AD_FLAG,E_AD_MODE,E_AD_PERCENTAGE,E_AD_AMOUNT,E_AD_MAX_LIMIT,E_AD_YEARLY_AMOUNT,Is_Calculate_Zero,Approved_Emp_ID,Approved_Date,Rpt_Level)
							VALUES (@Emp_Tran_ID,@Emp_Application_ID,@AD_TRAN_ID,@CMP_ID,@AD_ID,@INCREMENT_ID,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,CASE WHEN Isnull(@E_AD_AMOUNT,0) = -1 then 0 else @E_AD_AMOUNT end,@E_AD_MAX_LIMIT,@E_AD_AMOUNT_YEARLY, CASE WHEN Isnull(@E_AD_AMOUNT,0) = -1 then 1 else 0 end ,@Approved_Emp_ID,getdate(),@Rpt_Level)
				
				End
				
				
            
				if Exists(Select Increment_ID From dbo.T0070_EMP_INCREMENT_APP WITH (NOLOCK)
								Where Emp_Tran_ID=@Emp_Tran_ID and Increment_effective_Date > @for_Date and (Increment_Type = 'Transfer' or  Increment_Type = 'Deputation') and Increment_ID <> @INCREMENT_ID)
					begin
							Declare  @Inc_Table table(
										inc_id numeric,
										increment_type nvarchar(20)
									)
						
						insert into @Inc_table
						Select Increment_ID,Increment_Type From dbo.T0070_EMP_INCREMENT_APP WITH (NOLOCK)
						Where Emp_Tran_ID=@Emp_Tran_ID and Increment_effective_Date > @FOR_DATE 
						
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
									
									
									 if EXISTS(SELECT AD_TRAN_ID FROM T0075_EMP_EARN_DEDUCTION_APP WITH (NOLOCK)
									  WHERE cmp_ID = @Cmp_ID 
									  AND Emp_Tran_ID=@Emp_Tran_ID 
									  AND INCREMENT_ID=@Inc_id_update AND AD_ID=@AD_ID)					
										begin
										select @AD_TRAN_ID = AD_TRAN_ID FROM T0075_EMP_EARN_DEDUCTION_APP WITH (NOLOCK)
										 WHERE cmp_ID = @Cmp_ID 
										 AND Emp_Tran_ID=@Emp_Tran_ID 
										 AND INCREMENT_ID=@Inc_id_update AND AD_ID=@AD_ID
										
										UPDATE    T0075_EMP_EARN_DEDUCTION_APP
											SET       
													  E_AD_FLAG=@E_AD_FLAG,
													  E_AD_MODE=@E_AD_MODE,
													  E_AD_PERCENTAGE=@E_AD_PERCENTAGE,
													  E_AD_AMOUNT=@E_AD_AMOUNT,
													  E_AD_MAX_LIMIT=@E_AD_MAX_LIMIT,
													  E_AD_YEARLY_AMOUNT = @E_AD_AMOUNT_YEARLY,
													  Approved_Date=@FOR_DATE
											Where AD_TRAN_ID = @AD_TRAN_ID and Emp_Tran_ID=@Emp_Tran_ID and CMP_ID = @CMP_ID and INCREMENT_ID = @Inc_id_update and AD_ID = @AD_ID
										end
										
										else
										
										begin
											SELECT  @AD_TRAN_ID = ISNULL(MAX(AD_TRAN_ID),0) + 1 FROM T0075_EMP_EARN_DEDUCTION_APP WITH (NOLOCK)
											INSERT INTO T0075_EMP_EARN_DEDUCTION_APP
												(Emp_Tran_ID,Emp_Application_ID,AD_TRAN_ID,CMP_ID,AD_ID,INCREMENT_ID,E_AD_FLAG,E_AD_MODE,E_AD_PERCENTAGE,E_AD_AMOUNT,E_AD_MAX_LIMIT,E_AD_YEARLY_AMOUNT,Approved_Emp_ID,Approved_Date,Rpt_Level)
											VALUES (@Emp_Tran_ID,@Emp_Application_ID,@AD_TRAN_ID,@CMP_ID,@AD_ID,@Inc_id_update,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_MAX_LIMIT,@E_AD_AMOUNT_YEARLY,@Approved_Emp_ID,@FOR_DATE,@Rpt_Level)		
											
										end
									fetch next from cur_inc into @Inc_id_update,@inc_type_update
							  
							end                    
						close cur_inc                    
						deallocate cur_inc
										
					end
				
				
						
			END
	ELSE IF @Tran_Type = 'U' 
		BEGIN

				IF EXISTS(SELECT AD_TRAN_ID FROM T0075_EMP_EARN_DEDUCTION_APP WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID 
				AND Emp_Tran_ID=@Emp_Tran_ID 
				
				 AND INCREMENT_ID=@INCREMENT_ID AND AD_ID=@AD_ID)					
					BEGIN	    
						SET @AD_ID = 0
						RETURN
					END
			
			if @User_Id<>0
				BEGIN		
					exec P9999_Audit_get @table='T0075_EMP_EARN_DEDUCTION_APP' ,@key_column='AD_TRAN_ID',@key_Values=@AD_TRAN_ID,@String=@String output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
				END
					
				
			UPDATE    T0075_EMP_EARN_DEDUCTION_APP
			SET      
					  E_AD_FLAG=@E_AD_FLAG,
					  E_AD_MODE=@E_AD_MODE,
					  E_AD_PERCENTAGE=@E_AD_PERCENTAGE,
					  E_AD_AMOUNT=@E_AD_AMOUNT,
					  E_AD_MAX_LIMIT=@E_AD_MAX_LIMIT,
					  E_AD_YEARLY_AMOUNT = @E_AD_AMOUNT_YEARLY,
					  Approved_Date=@FOR_DATE
            Where AD_TRAN_ID = @AD_TRAN_ID and  Emp_Tran_ID=@Emp_Tran_ID 
           
            and CMP_ID = @CMP_ID and INCREMENT_ID = @INCREMENT_ID and AD_ID = @AD_ID
				
				
			if @User_Id<>0
				BEGIN				
					exec P9999_Audit_get @table = 'T0075_EMP_EARN_DEDUCTION_APP' ,@key_column='AD_TRAN_ID',@key_Values=@AD_TRAN_ID,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
				END
			
		end
	Else if @Tran_Type = 'D' 
		begin					
			
			if @User_Id<>0
				BEGIN			
					exec P9999_Audit_get @table='T0075_EMP_EARN_DEDUCTION_APP' ,@key_column='AD_TRAN_ID',@key_Values=@AD_TRAN_ID,@String=@String output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
				END
			
						
				Delete From T0075_EMP_EARN_DEDUCTION_APP Where AD_TRAN_ID = @AD_TRAN_ID and Cmp_Id=@Cmp_ID
				
			
					
		end


	
		if @Emp_PT = 1
			begin
				Declare @Is_Fnf	int
				set @Is_Fnf =0
				Select @AD_Other_Amount = isnull(sum(E_AD_Amount),0) from T0075_EMP_EARN_DEDUCTION_APP WITH (NOLOCK) where Increment_ID=@Increment_ID and E_AD_Flag ='I'
				set @Basic_Salary = @Basic_Salary + isnull(@AD_Other_Amount,0)
				Exec SP_CALCULATE_PT_AMOUNT_FOR_EMP_APP @Cmp_ID,@Emp_Tran_ID,@Emp_Application_ID,@Current_Date,@Basic_Salary,@PT_Amount output,'',@Branch_ID,@Is_Fnf
			end
			
		Update T0070_EMP_INCREMENT_APP set Emp_PT_Amount = @PT_Amount where Increment_ID = @Increment_ID 
	

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
				FROM T0070_EMP_INCREMENT_APP WITH (NOLOCK) WHERE Increment_ID = @Increment_ID AND Increment_Type <> 'Joining'
				
				IF @Increment_Amount_CTC = 0
					BEGIN
						SELECT	@AD_Other_Amount = ISNULL(SUM(E_AD_Amount),0) 
						FROM	T0075_EMP_EARN_DEDUCTION_APP EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID
						WHERE	Increment_ID=@Increment_ID and E_AD_Flag ='I' AND AM.AD_PART_OF_CTC = 1
						
						SET @CTC_Allow = @Basic_Salary + ISNULL(@AD_Other_Amount,0)
						
						UPDATE T0070_EMP_INCREMENT_APP SET CTC = @CTC_Allow WHERE Increment_ID = @Increment_ID 
					END
			END

RETURN



