


CREATE PROCEDURE [dbo].[P0090_HRMS_RESUME_EARN_DEDUCTION]
	 @AD_Row_ID	numeric(18, 0)	output
	,@CMP_ID	numeric(18, 0)	
	,@Resume_id	numeric(18, 0)	
	,@AD_ID	numeric(18, 0)	
	,@E_AD_FLAG	char(1)	
	,@E_AD_MODE	varchar(10)	
	,@E_AD_PERCENTAGE	numeric(12, 2)	
	,@E_AD_AMOUNT	numeric(18, 2)	
	,@E_AD_MAX_LIMIT	numeric(18, 0)	
	,@Tran_ID	numeric(18, 0)	
	,@Trans_Type varchar(1)
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
		DECLARE @AD_Calculate_on_Grade_Branch Varchar(100) 
		SET @AD_Calculate_on_Grade_Branch = ''
		
		Declare @Grd_Id as Numeric
		
		SET @Current_Date = getdate()		
		Set @CTC = 0
		Set @Temp_Amount = 0
		set @ESIC_Limit = 0
		set @Is_Yearly = 0
		set @E_AD_AMOUNT_YEARLY = 0
		set @AD_Other_Amount_ESIC = 0
		set @ESIC_limit_Calculated_Amount = 0
		Set @Grd_Id = 0
		Set @Company_Full_PF = 0

	IF @AD_ID=0
		set @AD_ID=null
		
	IF @E_AD_AMOUNT is null
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
		DECLARE @FOR_DATE as DATETIME
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
		
		Declare @Ad_Level NUMERIC(18,0)	
		SET @Ad_Level = 0
		
		SELECT @AD_DEF_ID = AD_DEF_ID ,@AD_Calculate_On = AD_CALCULATE_ON,@AD_Amount =Ad_Amount,@Is_Yearly = Is_Yearly, @Ad_Level = AD_LEVEL --,@E_AD_MAX_LIMIT = AD_MAX_LIMIT
		FROM T0050_AD_MASTER WHERE AD_ID =@AD_ID
		
		SELECT  @Branch_ID		= Branch_ID , @Emp_PT =0, @Emp_Full_PF = 0 ,@Basic_Salary = isnull(Basic_Salay,0) ,@Calculated_Amount = isnull(Basic_Salay,0) 
				, @Gross_Salary = Isnull(Gross_Salary,0), @CTC = Isnull(Total_CTC,0),@Grd_Id = Grd_ID, @Company_Full_PF = Isnull(0,0)
				,@FOR_DATE = Joining_date
		FROM	T0060_RESUME_FINAL WHERE Resume_ID =@Resume_ID and Tran_ID = @Tran_ID
			
				
		SELECT TOP 1 @AC_2_3 =ACC_2_3, @AC_22_3 = ACC_22_3,
			@AC_21_1 =ACC_21_1, @PF_Limit = PF_LIMIT, @AD_Rounding = AD_Rounding, @ESIC_Limit = ISNULL(ESIC_Upper_Limit,0) ,@Max_Bonus_Salary_Amount = ISNULL(Max_Bonus_Salary_Amount,0)
		FROM T0040_General_setting gs Left outer join     
			T0050_General_Detail gd ON gs.gen_Id =gd.gen_ID     
		WHERE gs.Cmp_Id=@cmp_Id and Branch_ID = isnull(@Branch_ID,Branch_ID)    
		and For_Date = (SELECT MAX(For_Date) FROM dbo.T0040_GENERAL_SETTING WHERE Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID And For_Date <= @FOR_DATE)
		
		Select @E_AD_MAX_LIMIT = isnull(AD_MAX_LIMIT,0) from T0120_GRADEWISE_ALLOWANCE where Ad_ID = @AD_ID And Grd_ID = @Grd_Id
		
		Declare @Upper_Round_Employer_ESIC as int
		Select  @Upper_Round_Employer_ESIC = (Select Setting_ID from dbo.T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name='Upper Round for Employer ESIC')
		
	--declare @FOR_DATE as datetime
	--set @FOR_DATE = cast(getdate() as varchar(11))
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
				--SELECT @AD_Other_Amount = ISNULL(SUM(E_AD_Amount),0) FROM T0090_HRMS_RESUME_EARN_DEDUCTION EED inner join 
				--	T0050_ad_master AM on eed.ad_id = am.ad_id WHERE EED.TRAN_ID=@Tran_Id  
				--		AND eed.AD_ID IN (SELECT AD_ID FROM T0060_EFFECT_AD_MASTER WHERE Effect_AD_ID =@AD_ID)
				
				If @AD_DEF_ID = 2 or @AD_DEF_ID = 5 or @AD_DEF_ID = 4
					SELECT @AD_Other_Amount = ISNULL(SUM(E_AD_Amount),0) FROM T0090_HRMS_RESUME_EARN_DEDUCTION EED WITH (NOLOCK) inner join 
						T0050_ad_master AM WITH (NOLOCK) on eed.ad_id = am.ad_id WHERE EED.TRAN_ID=@Tran_Id
							AND eed.AD_ID IN (SELECT AD_ID FROM T0060_EFFECT_AD_MASTER WITH (NOLOCK) WHERE Effect_AD_ID =@AD_ID)
							AND AD_DEF_ID <> @DA_DEF_ID
				Else
					SELECT @AD_Other_Amount = ISNULL(SUM(E_AD_Amount),0) FROM T0090_HRMS_RESUME_EARN_DEDUCTION EED WITH (NOLOCK) inner join 
						T0050_ad_master AM  WITH (NOLOCK) on eed.ad_id = am.ad_id WHERE EED.TRAN_ID=@Tran_Id
							AND eed.AD_ID IN (SELECT AD_ID FROM T0060_EFFECT_AD_MASTER WITH (NOLOCK) WHERE Effect_AD_ID =@AD_ID)
				
				If @AD_DEF_ID = 2 or @AD_DEF_ID = 5 or @AD_DEF_ID = 4
					SELECT @DA_Amount = ISNULL(SUM(E_AD_Amount),0) FROM T0090_HRMS_RESUME_EARN_DEDUCTION EED WITH (NOLOCK) inner join 
						T0050_ad_master AM WITH (NOLOCK) on eed.ad_id = am.ad_id WHERE EED.TRAN_ID=@Tran_Id   and am.AD_CALCULATE_ON <> 'Import'   
							AND eed.AD_ID IN (SELECT AD_ID FROM T0060_EFFECT_AD_MASTER WITH (NOLOCK) WHERE Effect_AD_ID =@AD_ID)
							AND AD_DEF_ID = @DA_DEF_ID
				

											
				SET @ESIC_limit_Calculated_Amount = @Calculated_Amount  
				SET @Calculated_Amount = @Calculated_Amount + @AD_Other_Amount
				SET @ESIC_limit_Calculated_Amount = @ESIC_limit_Calculated_Amount + @AD_Other_Amount_esic 
				
				IF @AD_DEF_ID =3 or @AD_DEF_ID = 6 
					BEGIN
						IF @ESIC_Limit <> 0  
							BEGIN
								IF @Calculated_Amount <= @ESIC_Limit
									BEGIN
										If @AD_DEF_ID = 3
											SET @E_AD_Amount = CEILING((@Calculated_Amount * @E_AD_PERCENTAGE / 100)) 
										ELSE
											If @AD_DEF_ID = 6 And @Upper_Round_Employer_ESIC = 0  --Added by Hardik 25/06/2014
												SET @E_AD_Amount = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE / 100,0) 
											ELSE
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
				ELSE IF @AD_DEF_ID = 2 --or @AD_DEF_ID = 5		
					BEGIN
						IF @Emp_Full_PF = 0
							BEGIN 							 
								IF @Calculated_Amount > @PF_Limit
									BEGIN 									
										SET @Calculated_Amount = @PF_Limit
										SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
										
									END
								ELSE
									BEGIN
										SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
									END							
							END
						
						If @E_AD_AMOUNT > @E_AD_MAX_LIMIT and @E_AD_MAX_LIMIT > 0
							SET @E_AD_AMOUNT = @E_AD_MAX_LIMIT	
					END
				ELSE IF @AD_DEF_ID = 5 		 --- For Company PF -- Added by Hardik 21/08/2018 for Full PF Case for Compentent Syngergis Client
					BEGIN						
						--Hardik 29/03/2019 As per New PF Rule
						If @Basic_Salary + @DA_Amount <= @PF_Limit And @Company_Full_PF =1
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
							--select 333,@E_AD_AMOUNT,@Calculated_Amount
					End					
				ELSE IF @AD_DEF_ID = 19	 /* Bonus Calculation */ 
					BEGIN
						DECLARE @Mini_Wages		NUMERIC(18,2)	
						DECLARE @SkillType_ID	NUMERIC
						SET @Mini_Wages = 0
						SET @SkillType_ID =  0
						
						/* Get Minimum wages Amount */		
						SELECT @Mini_Wages = ISNULL(MW.Wages_Value,0) FROM T0050_Minimum_Wages_Master MW INNER JOIN
							( SELECT MAX(Effective_Date) AS EffecDate,SkillType_ID FROM T0050_Minimum_Wages_Master
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
						IF @AD_Rounding = 1 or @AD_Def_Id= 4 
							SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
						ELSE
							 SET @E_AD_AMOUNT = @Calculated_Amount * @E_AD_PERCENTAGE/100	
							
							
						If @AD_DEF_ID = 10
							BEGIN 
								IF @Company_Full_PF = 1
									Set @AC_2_3_Amount = @Calculated_Amount * @AC_2_3 /100									
								ELSE
									IF @Calculated_Amount > @PF_Limit
										SET @AC_2_3_Amount = @PF_Limit * @AC_2_3 /100
									ELSE
										SET @AC_2_3_Amount = @Calculated_Amount * @AC_2_3 /100
										
								If @Calculated_Amount > @PF_Limit
									SET @AC_21_1_Amount = Round(@PF_Limit * @AC_21_1/100,0)
								ELSE
									SET @AC_21_1_Amount = Round(@Calculated_Amount * @AC_21_1/100,0)

								IF @Calculated_Amount > @PF_Limit
									SET @AC_22_3_Amount = Round(@PF_Limit * @AC_22_3/100,0)
								ELSE
									SET @AC_22_3_Amount = Round(@Calculated_Amount * @AC_22_3/100,0)
									
								IF @AD_Rounding = 1	
									SET @E_AD_AMOUNT = Round(Isnull(@AC_2_3_Amount,0) + Isnull(@AC_21_1_Amount,0) + Isnull(@AC_22_3_Amount,0),0)
								Else
									SET @E_AD_AMOUNT = Isnull(@AC_2_3_Amount,0) + Isnull(@AC_21_1_Amount,0) + Isnull(@AC_22_3_Amount,0)
							END
							
						If @E_AD_AMOUNT > @E_AD_MAX_LIMIT and @E_AD_MAX_LIMIT > 0      
							set @E_AD_AMOUNT = @E_AD_MAX_LIMIT
							
						IF @Is_Yearly = 1 
							BEGIN
								SET @E_AD_AMOUNT_YEARLY = @E_AD_AMOUNT
								IF @AD_Rounding = 1
									BEGIN
										SET @E_AD_AMOUNT = ROUND(@E_AD_AMOUNT/12,0)
									END
								ELSE
									BEGIN
										SET @E_AD_AMOUNT = @E_AD_AMOUNT/12
									END
							End
					END
			END
		IF @AD_Calculate_On ='FIX'
			BEGIN
				SET @E_AD_AMOUNT =@E_AD_AMOUNT	
				IF @Is_Yearly = 1
					BEGIN
						SET @E_AD_AMOUNT_YEARLY = @E_AD_AMOUNT
						IF @AD_Rounding = 1
							BEGIN
								SET @E_AD_AMOUNT = ROUND(@E_AD_AMOUNT/12,0)
							END
						ELSE
							BEGIN
								SET @E_AD_AMOUNT = @E_AD_AMOUNT/12
							END
					END
			END
		ELSE IF @AD_Calculate_On='Formula'
			BEGIN
				DECLARE @Earning_Gross NUMERIC(18,2)
				DECLARE @Formula_amount NUMERIC(18,2)	
				SET @Earning_Gross = 0
				SET @Formula_amount = 0
				
				DECLARE @PASSED_FROM AS VARCHAR(50)
				SET @PASSED_FROM = 'EARN_DEDUCTION'
				
				SET @Earning_Gross = @Gross_Salary
								
				--exec CALCULATE_AD_AMOUNT_Formula_WISE_Salary  @Cmp_ID,@EMP_ID,@AD_ID,@FOR_DATE,@Earning_Gross,1,1,@Formula_amount output,@Basic_Salary,0,0,0,0,@PASSED_FROM
				--set @E_AD_AMOUNT = ISNULL(@Formula_amount,0)
			END
		--ELSE IF @AD_Calculate_On = 'Slab Wise'   -- Hasmukh for slab wise allowance
		--	Begin 
		--		exec CALCULATE_AD_AMOUNT_SLAB_WISE @CMP_ID,@Emp_ID,@AD_ID,@FOR_DATE,@Calculated_Amount output,@E_AD_AMOUNT output
		--	End
		ELSE If @AD_Calculate_On = 'Arrears CTC'
			BEGIN	
				SET @Error = ''
				SET @E_AD_AMOUNT_AREARS = 0					
				SET @E_AD_AMOUNT_AREARS = ISNULL(@E_AD_AMOUNT,0)	
				SELECT @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)
				FROM (
					SELECT EED.E_AD_AMOUNT
					FROM T0100_EMP_EARN_DEDUCTION EED Inner Join 
						 T0050_AD_MASTER A on EED.AD_ID = A.AD_ID And EED.CMP_ID=A.CMP_ID 
				    WHERE EED.CMP_ID = @Cmp_ID AND EED.EMP_ID = @Resume_id 
								AND EED.INCREMENT_ID = @TRAN_ID And A.AD_FLAG = 'I' AND Isnull(A.AD_PART_OF_CTC,0)=1
								AND EED.AD_ID <> @AD_id
								AND A.AD_LEVEL < @Ad_Level
				)Temp	
				SET @E_AD_AMOUNT = @CTC - ISNULL((@Basic_Salary + @Temp_Amount),0) 
				--DECLARE @Salary_Based_on_Production_ArrearCTC AS INT
		  --      SELECT  @Salary_Based_on_Production_ArrearCTC = ISNULL(Setting_ID,0) FROM dbo.T0040_SETTING 
		  --                                  WHERE Cmp_ID = @Cmp_ID and Setting_Name='Calculate Salary Base on Production Details'
		        SET @Temp_Amount = 0
			END
		ELSE IF @AD_Calculate_On = 'Arrears' 
			BEGIN
				SET @Error = ''
				SET @E_AD_AMOUNT_AREARS = 0					
				SET @E_AD_AMOUNT_AREARS = ISNULL(@E_AD_AMOUNT,0)
				SELECT @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)
				FROM(
						SELECT EED.E_AD_AMOUNT
						FROM  T0090_HRMS_RESUME_EARN_DEDUCTION EED Inner Join 
							  T0050_AD_MASTER A on EED.AD_ID = A.AD_ID And EED.CMP_ID=A.CMP_ID
						WHERE EED.CMP_ID = @Cmp_ID AND EED.Resume_id = @Resume_id 
								AND EED.TRAN_ID = @TRAN_ID And E_AD_FLAG = 'I'  AND Isnull(A.AD_EFFECT_ON_CTC,0) = 1	  
								AND EED.AD_ID <> @AD_id and A.AD_LEVEL < @Ad_Level
				)Tempe
				print @Temp_Amount
				SET @E_AD_AMOUNT = @Gross_Salary - Isnull((@Basic_Salary + @Temp_Amount),0) 
				--select @E_AD_AMOUNT,@Gross_Salary,@Basic_Salary,@Ad_Level
				--DECLARE @Salary_Based_on_Production_Arrear AS INT
		  --      SELECT  @Salary_Based_on_Production_Arrear = ISNULL(Setting_ID,0) 
		  --      FROM dbo.T0040_SETTING 
		  --      WHERE Cmp_ID = @Cmp_ID and Setting_Name='Calculate Salary Base on Production Details'
		        
		        SET @Temp_Amount = 0
		    END
		Else IF @AD_Calculate_On = 'Branch + Grade'
			BEGIN
				IF @E_AD_MODE = '%'
					BEGIN
						IF @E_AD_PERCENTAGE > 0
							Begin
								IF @AD_Calculate_on_Grade_Branch = ''								
								IF @AD_Calculate_on_Grade_Branch = 'Basic Salary'
									SET @Calculated_Amount = @Basic_Salary 
								Else IF @AD_Calculate_On = 'CTC' 
									SET @Calculated_Amount = @CTC 
								Else IF @AD_Calculate_on_Grade_Branch = 'Gross Salary'
									SET @Calculated_Amount =  @Gross_Salary
									
								SET @E_AD_AMOUNT = (@Calculated_Amount * @E_AD_PERCENTAGE)/100
							End
					END
			END
			
	--SET @E_AD_AMOUNT = Isnull(@E_AD_AMOUNT,0)
	
	IF @E_AD_AMOUNT > @E_AD_MAX_LIMIT and @E_AD_MAX_LIMIT > 0       
		SET @E_AD_AMOUNT = @E_AD_MAX_LIMIT
		
	--SELECT 333,@E_AD_AMOUNT
			
	If @Trans_Type  = 'I'
		BEGIN 
				IF Exists(SELECT AD_Row_ID FROM T0090_HRMS_RESUME_EARN_DEDUCTION  WHERE Cmp_ID = @Cmp_ID and AD_ID = @AD_ID and Resume_id=@Resume_id)
					BEGIN
						SET @AD_Row_ID = 0
					RETURN 
				END
				
				SELECT @AD_Row_ID= Isnull(max(AD_Row_ID),0) + 1 FROM T0090_HRMS_RESUME_EARN_DEDUCTION 
				
				INSERT INTO T0090_HRMS_RESUME_EARN_DEDUCTION
				                      ( AD_Row_ID
										,CMP_ID
										,Resume_id
										,AD_ID
										,FOR_DATE
										,E_AD_FLAG
										,E_AD_MODE
										,E_AD_PERCENTAGE
										,E_AD_AMOUNT
										,E_AD_MAX_LIMIT
										,Tran_ID
										)
				VALUES					(@AD_Row_ID
										,@CMP_ID
										,@Resume_id
										,@AD_ID
										,@FOR_DATE
										,@E_AD_FLAG
										,@E_AD_MODE
										,@E_AD_PERCENTAGE
										,@E_AD_AMOUNT
										,@E_AD_MAX_LIMIT
										,@Tran_ID
										)
										
		END
	Else IF @Trans_Type = 'U'
		begin  
				Update T0090_HRMS_RESUME_EARN_DEDUCTION
				set 
					 E_AD_FLAG=@E_AD_FLAG
					,E_AD_MODE=@E_AD_MODE
					,E_AD_PERCENTAGE=@E_AD_PERCENTAGE
					,E_AD_AMOUNT=@E_AD_AMOUNT
					,E_AD_MAX_LIMIT=@E_AD_MAX_LIMIT
			where Resume_id = @Resume_id and AD_ID=@AD_ID and Tran_ID=@Tran_ID and cmp_id=@cmp_id
				
		end
	Else if @Trans_Type = 'D'
		begin
				Delete From T0090_HRMS_RESUME_EARN_DEDUCTION Where AD_Row_ID= @AD_Row_ID
				
		end
		
		
	DECLARE @AUTO_CALCULATE_CTC	TINYINT
		SET @AUTO_CALCULATE_CTC = 0
		
	SELECT @AUTO_CALCULATE_CTC = ISNULL(SETTING_VALUE,0) FROM T0040_SETTING WHERE CMP_ID = @CMP_ID AND
											 SETTING_NAME = 'Auto Calculate CTC Amount during Salary Structure Assigning or Changing'
											 
											 
	IF (@AUTO_CALCULATE_CTC > 0)	
		BEGIN 
			DECLARE @CTC_Allow				NUMERIC(18,2)
			DECLARE @Increment_Amount_CTC	NUMERIC(18,2)
			SET @CTC_Allow			= 0
			SET @AD_Other_Amount	= 0
			SET @Basic_Salary		= 0
			SET @Increment_Amount_CTC = 0
			
			SELECT @Increment_Amount_CTC = 0, @Basic_Salary = SUM(ISNULL(Basic_Salay,0)) 
			FROM T0060_RESUME_FINAL WHERE TRAN_ID = @tran_Id 
			
			IF @Increment_Amount_CTC = 0
				BEGIN 
					SELECT	@AD_Other_Amount = ISNULL(SUM(E_AD_Amount),0) 
					FROM	T0090_HRMS_RESUME_EARN_DEDUCTION EED INNER JOIN T0050_AD_MASTER AM ON EED.AD_ID = AM.AD_ID
					WHERE	EED.TRAN_ID=@tran_Id and E_AD_Flag ='I' AND AM.AD_PART_OF_CTC = 1 
							
					
					SET @CTC_Allow = @Basic_Salary + ISNULL(@AD_Other_Amount,0)--
					
					UPDATE T0060_RESUME_FINAL SET Total_CTC = @CTC_Allow WHERE TRAN_ID = @tran_Id 
				END	
		END

	RETURN




