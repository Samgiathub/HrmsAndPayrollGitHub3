

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0110_EMP_EARN_DEDUCTION_REVISED]
	 @AD_TRAN_ID	Numeric OUTPUT
	,@EMP_Code		varchar(100)
	,@CMP_ID		Numeric
	,@AD_Name		Varchar(100)
	,@FOR_DATE		DateTime
	,@E_AD_AMOUNT	numeric(18,5)	--Modified by Nimesh on 27-Jul-2015 (parameter type modified from (18,2) to (18,5))
	,@tran_type		varchar(1)
	,@Log_Status	numeric = 0 OUTPUT 
	,@User_Id		numeric(18,0) = 0 
	,@GUID			Varchar(2000) = '' --Added by nilesh patel on 17062016
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
		Declare @AD_Calculate_On	varchar(20)
		Declare @AD_Other_Amount	numeric(18,2) 
		Declare @Calculated_Amount	numeric (18,2)
		Declare @AD_DEF_ID			int
		Declare @Emp_Full_PF		int
		Declare @Company_Full_PF	int 
		Declare @Emp_PT				int
		Declare @Basic_Salary		numeric(18,2)
		declare @PT_Amount			numeric 
		Declare @Branch_ID			numeric
		Declare @AD_Amount			as numeric(18,2)
		Declare @Gross_Salary		numeric(18,2)
		Declare @CTC				Numeric(18,2)
		Declare @Temp_Amount		Numeric(18,2)
		Declare @ESIC_Limit			numeric	
		Declare @Is_Yearly			numeric	
		Declare @E_AD_AMOUNT_YEARLY		numeric(18,2)		
		Declare @Current_Date			datetime
		Declare @AD_Other_Amount_ESIC	numeric(18,2) 
		Declare @ESIC_limit_Calculated_Amount Numeric (18,2)

		Declare @Grd_Id		as Numeric
		Declare @Entry_Type Varchar(10)
		Declare @E_AD_FLAG		Char(1)
		Declare @E_AD_MODE		Varchar(10)
		Declare @E_AD_PERCENTAGE	numeric(18,5)	--Modified by Nimesh on 27-Jul-2015 (parameter type modified from (18,2) to (18,5))
		Declare @E_AD_MAX_LIMIT		numeric(18,2)
		Declare @Emp_Id			Numeric
		Declare @Ad_Id			Numeric
		Declare @Date_oF_Join	Datetime
	
		Set @Entry_Type =''
		Set @Emp_Id = 0
		set @Ad_Id = 0
		Set @Log_Status = 0
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
		if @E_AD_AMOUNT is null
			set @AD_Other_Amount = 0
		if @E_AD_PERCENTAGE is null
			set @E_AD_PERCENTAGE = 0
		If ISNULL(@User_Id,0) = 0
			SET @User_Id = NULL
		
		set @Emp_Full_PF =0 
		set @PT_Amount =0
		
		Select @Emp_Id = Isnull(Emp_Id,0) , @Date_oF_Join = Date_Of_Join From T0080_EMP_MASTER WITH (NOLOCK) Where UPPER(Alpha_Emp_Code) = UPPER(@EMP_Code) AND Cmp_ID = @CMP_ID
		
		If @Emp_Id = 0
			Begin
				INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Emp_Code,'Employee Code Does not exists',@Emp_Code,'Employee Code Does not exists',GETDATE(),'Employee Allow/Dedu Revised',@GUID)     
				SET @Log_Status=1 
				Return
			End
		
		if @FOR_DATE IS NULL
			Begin
				INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Emp_Code,'For Date Does not exists',@Emp_Code,'For Date Does not exists',GETDATE(),'Employee Allow/Dedu Revised',@GUID)     
				SET @Log_Status=1 
				Return
			End

		IF @Date_oF_Join > @FOR_DATE
			Begin
				INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Emp_Code,'Enter Proper For Date',@Emp_Code,'For Date Less than or equal to employee Join date',GETDATE(),'Employee Allow/Dedu Revised',@GUID)     
				SET @Log_Status=1 
				Return
			End
		
		
		
		SELECT @AD_Id = AD_ID,@AD_DEF_ID = AD_DEF_ID ,@AD_Calculate_On = AD_CALCULATE_ON,
				@Is_Yearly = Is_Yearly,@E_AD_FLAG = AD_Flag
		FROM T0050_AD_MASTER WITH (NOLOCK)
		WHERE AD_NAME =LTRIM(RTRIM(@AD_Name))  AND CMP_ID = @CMP_ID
		

		If @AD_Id = 0
			Begin
				INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Emp_Code,'Allowance Details Does not Exists',@Emp_Code,'Verify Allowance Name From Allowance Master',GETDATE(),'Employee Allow/Dedu Revised',@GUID)     
				SET @Log_Status=1 
				Return
			End
		
		Declare @Increment_Id Numeric
		Declare @Increment_Id_Trans Numeric
		
		SELECT @Increment_Id_Trans = Increment_Id FROM T0095_Increment WITH (NOLOCK) WHERE Emp_ID = @EMP_ID And Increment_ID =
				(Select Max(Increment_Id) FROM T0095_Increment WITH (NOLOCK) WHERE Emp_ID = @EMP_ID And Increment_Effective_Date <= @FOR_DATE)
		
		SELECT @Increment_Id = Increment_Id FROM T0095_Increment WITH (NOLOCK) WHERE Emp_ID = @EMP_ID And Increment_ID =
				(Select Max(Increment_Id) FROM T0095_Increment WITH (NOLOCK) WHERE Emp_ID = @EMP_ID And Increment_Effective_Date <= @FOR_DATE And Increment_Type <> 'Transfer' And Increment_Type <> 'Deputation')
		
		SELECT  @Branch_ID = Branch_ID, @Grd_Id = Grd_ID
		FROM	T0095_Increment WITH (NOLOCK) WHERE Emp_ID = @EMP_ID And Increment_ID = @Increment_Id_Trans
				
		
		SELECT  @Emp_PT =Emp_PT, @Emp_Full_PF = Emp_Full_PF ,@Basic_Salary = isnull(Basic_Salary,0) ,@Calculated_Amount = isnull(Basic_Salary,0) 
				,@Gross_Salary = Isnull(Gross_Salary,0), @CTC = Isnull(CTC,0),@Company_Full_PF = Isnull(Emp_Auto_VPF,0)
		FROM	T0095_Increment WITH (NOLOCK) WHERE Emp_ID = @EMP_ID And Increment_ID = @Increment_Id

		Select @E_AD_MAX_LIMIT = isnull(AD_MAX_LIMIT,0) ,@AD_Amount =Ad_Amount, @E_AD_MODE = AD_MODE
		from T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) where Ad_ID = @AD_ID And Grd_ID = @Grd_Id
		
		If @E_AD_Mode = '%'
			Begin
				if @E_AD_AMOUNT > 999.99
					Begin
						INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Emp_Code,'Allowance Mode in Percentage So please Enter Allowance Amount less than 100',@Emp_Code,'Allowance Mode in Percentage So please Enter Allowance Amount less than 100',GETDATE(),'Employee Allow/Dedu Revised',@GUID)     
						SET @Log_Status=1 
						Return
					End
			End 
		
		IF @Tran_Type = 'D' 
			BEGIN
				
				IF EXISTS(SELECT EMP_ID FROM T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) WHERE Cmp_Id=@Cmp_Id And Emp_Id=@Emp_id And S_Month_St_Date>=@FOR_DATE and S_Month_St_Date<=@FOR_DATE )
					BEGIN
						Raiserror('Salary Settlement Exists',16,2)
						INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Emp_Code,'Salary Settlement Exists',@Emp_Code,'Salary Settlement Exists',GETDATE(),'Employee Allow/Dedu Revised',@GUID)     
						SET @Log_Status=1
						Return -1
					END
				
				IF EXISTS(SELECT EMP_ID FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Cmp_Id=@Cmp_Id And Emp_Id=@Emp_id And Month_St_Date>=@FOR_DATE and Month_St_Date<=@FOR_DATE )
					BEGIN
						Raiserror('Employee Salary Exists',16,2)
						INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Emp_Code,'Employee Salary Exists',@Emp_Code,'Employee Salary Exists',GETDATE(),'Employee Allow/Dedu Revised',@GUID)     
						SET @Log_Status=1
						Return -1
					END
				
				IF EXISTS(SELECT 1 FROM T0110_EMP_EARN_DEDUCTION_REVISED WITH (NOLOCK) WHERE EMP_ID =@EMP_ID And CMP_ID = @CMP_ID AND FOR_DATE > @FOR_DATE And AD_ID = @Ad_Id And TRAN_ID <> @AD_TRAN_ID)
					BEGIN
						Raiserror('Employee Next Entry Exists First Delete It',16,2)
						INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Emp_Code,'Employee Next Entry Exists First Delete It',@Emp_Code,'Employee Next Entry Exists First Delete It',GETDATE(),'Employee Allow/Dedu Revised',@GUID)     
						SET @Log_Status=1
						Return -1
					END
				
				Delete From T0110_EMP_EARN_DEDUCTION_REVISED Where TRAN_ID = @AD_TRAN_ID and Cmp_Id=@Cmp_ID And EMP_ID = @Emp_Id
				
				GOTO Special_Allowance_Calculate;
				
				Return
			END
		
		--ADDED BY RAMIZ ON 03/12/2016 FOR RESTRICTING REVISED ALLOWANCE IF SALARY IS GENERATED WITH SAME DATE AS DATE OF REVISED ALLOWANCE
		IF EXISTS (SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID = @Emp_Id AND Month_St_Date >= @For_Date)
			BEGIN
				RAISERROR('Employee Salary Exists , Cannot Revise Allowance with this Date',16,2)
				RETURN -1
			END
		--CODE ENDS BY RAMIZ
		


		Declare @AC_2_3 as Numeric(18,3)
		Declare @AC_22_3 as Numeric(18,3)
		Declare @AC_21_1 as Numeric(18,3)
		Declare @PF_Limit as Numeric(18,2)
		Declare @AC_2_3_Amount as Numeric(18,2)
		Declare @AC_22_3_Amount as Numeric(18,2)
		Declare @AC_21_1_Amount as Numeric(18,2)
		Declare @Max_Bonus_Salary_Amount as Numeric(18,2)	--Ankit 01042016

		Set @AC_2_3 = 0
		Set @AC_22_3 = 0
		Set @AC_21_1 = 0
		Set @PF_Limit = 0
		Set @AC_2_3_Amount = 0
		Set @AC_22_3_Amount = 0
		Set @AC_21_1_Amount = 0
		set @Max_Bonus_Salary_Amount = 0

		Select Top 1 @AC_2_3 =ACC_2_3, @AC_22_3 = ACC_22_3,
			@AC_21_1 =ACC_21_1, @PF_Limit = PF_LIMIT
		from T0040_General_setting gs WITH (NOLOCK) inner join     
			T0050_General_Detail gd WITH (NOLOCK) on gs.gen_Id =gd.gen_ID     
		where gs.Cmp_Id=@cmp_Id and Branch_ID = isnull(@Branch_ID,Branch_ID)    
		and For_Date in (select max(For_Date) from T0040_General_setting  g WITH (NOLOCK) inner join     
						T0050_General_Detail d WITH (NOLOCK) on g.gen_Id =d.gen_ID       
						where g.Cmp_Id=@cmp_Id and Branch_ID = isnull(@Branch_ID,Branch_ID))    							

		
		Declare @AD_Rounding  INT		
		SELECT @AD_Rounding = AD_Rounding,@ESIC_Limit = ISNULL(ESIC_Upper_Limit,0),@Max_Bonus_Salary_Amount = ISNULL(Max_Bonus_Salary_Amount,0)
		FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE Cmp_ID=@CMP_ID AND Branch_ID=@Branch_ID
		AND For_Date = ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK)
						  WHERE  Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)
			
		
		Declare @Upper_Round_Employer_ESIC as int
		Select  @Upper_Round_Employer_ESIC = (Select Setting_ID from dbo.T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name='Upper Round for Employer ESIC')
		
		Declare @Special_Allo_Cal_Setting INT
		SET @Special_Allo_Cal_Setting = 0
		
		SELECT @Special_Allo_Cal_Setting = ISNULL(Setting_Value,0) FROM dbo.T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @CMP_ID AND Setting_Name = 'Special Allowance Calculate From Employee Allowance/Deduction Revise'
		
		IF @AD_Calculate_On = 'Actual Gross' 
			set @Calculated_Amount = @Gross_Salary 
		Else IF @AD_Calculate_On = 'CTC' 
			set @Calculated_Amount = @CTC 
		Else
			Set @Calculated_Amount = @Basic_Salary 

		
		IF @E_AD_AMOUNT = -1 And @AD_Calculate_On = 'Formula' And ( Exists(Select 1 From T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) Where INCREMENT_ID = @Increment_Id And AD_ID = @Ad_Id ) OR EXISTS(SELECT TRAN_ID FROM T0110_EMP_EARN_DEDUCTION_Revised WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID And AD_ID=@AD_ID ) )
			Begin
				--Set @Entry_Type = 'D' -- Commented by Hardik 16/11/2017 for Unassigned Formula based allowance
				Set @Entry_Type = 'U' --Added by Hardik 16/11/2017 for Unassigned Formula based allowance
				Set @E_AD_AMOUNT = 0
				Set @E_AD_PERCENTAGE = 0
				
				
				IF NOT EXISTS(SELECT TRAN_ID FROM T0110_EMP_EARN_DEDUCTION_Revised WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID And AD_ID=@AD_ID And For_Date = @For_Date)
					Begin
						INSERT INTO T0110_EMP_EARN_DEDUCTION_Revised
							   (EMP_ID,CMP_ID,AD_ID,FOR_DATE,E_AD_FLAG,E_AD_MODE,E_AD_PERCENTAGE,E_AD_AMOUNT,E_AD_MAX_LIMIT,E_AD_YEARLY_AMOUNT, Entry_Type,Increment_ID,System_date,User_ID,Is_Calculate_Zero)
						VALUES (@EMP_ID,@CMP_ID,@AD_ID,@FOR_DATE,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_MAX_LIMIT,@E_AD_AMOUNT_YEARLY,@Entry_Type,@Increment_Id,GETDATE(),@User_Id,1)
												
					End				
				Else
					Begin
												
						UPDATE    T0110_EMP_EARN_DEDUCTION_Revised
						SET       E_AD_FLAG=@E_AD_FLAG,
								  E_AD_MODE=@E_AD_MODE,
								  E_AD_PERCENTAGE=@E_AD_PERCENTAGE,
								  E_AD_AMOUNT=@E_AD_AMOUNT,
								  E_AD_MAX_LIMIT=@E_AD_MAX_LIMIT,
								  E_AD_YEARLY_AMOUNT = @E_AD_AMOUNT_YEARLY,
								  Entry_Type = @Entry_Type,
								  Increment_ID = @Increment_Id,
								  System_Date = GETDATE(),
								  User_ID = @User_Id,
								  Is_Calculate_Zero=1
						Where	EMP_ID = @EMP_ID and CMP_ID = @CMP_ID and For_Date = @For_Date and AD_ID = @AD_ID
					
					End
					
				Return
			End				
		
		
		If @E_AD_Mode = '%'
			Begin
				Set @E_AD_PERCENTAGE = @E_AD_AMOUNT
				Set @E_AD_AMOUNT = 0 
			End
		Else
			Set @E_AD_PERCENTAGE = 0
			
		
		IF @E_AD_PERCENTAGE >  0
			BEGIN				
				SELECT @AD_Other_Amount = ISNULL(SUM(Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End),0) FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)
					inner join T0050_ad_master AM WITH (NOLOCK) on eed.ad_id = am.ad_id Left Outer Join
					(Select EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) Inner Join
						(Select Max(For_Date) For_Date, Ad_Id
						From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) Where Emp_Id = @EMP_ID And For_date <= @FOR_DATE Group by Ad_Id)Qry on 
							Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id And EMP_ID=@Emp_Id) Qry1 on eed.AD_ID = qry1.ad_Id And EED.EMP_ID = @Emp_id
					WHERE Increment_ID=@Increment_Id  
						AND eed.AD_ID IN (SELECT AD_ID FROM T0060_EFFECT_AD_MASTER WITH (NOLOCK) WHERE Effect_AD_ID =@AD_ID)
				---- EED.EMP_ID = @EMP_ID UPDATED BY RAJPUT ON 08052018 WRONG ALLOWANCE AMOUNT CALCULATE ( INDUCTOTHERM CLIENT )
				SET @Calculated_Amount = @Calculated_Amount + @AD_Other_Amount

				if @AD_DEF_ID =3 or @AD_DEF_ID = 6 
					BEGIN
						IF @ESIC_Limit <> 0  
							BEGIN
								IF @Calculated_Amount <= @ESIC_Limit
									BEGIN
										If @AD_DEF_ID = 3
											SET @E_AD_Amount = CEILING((@Calculated_Amount * @E_AD_PERCENTAGE / 100)) 
										Else
											If @AD_DEF_ID = 6 And @Upper_Round_Employer_ESIC = 0  
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
				ELSE IF @AD_DEF_ID = 2 or @AD_DEF_ID = 5		
					BEGIN
						IF @Emp_Full_PF = 0
							Begin 
								IF @Calculated_Amount > @PF_Limit
									Begin 
										SET @Calculated_Amount = @PF_Limit	
										SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
									End
								Else
									BEGIN
										SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
									END
							End
						Else
							Begin							
								SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)	
							End

						If @E_AD_AMOUNT > @E_AD_MAX_LIMIT and @E_AD_MAX_LIMIT > 0
							set @E_AD_AMOUNT = @E_AD_MAX_LIMIT
							
					End
				ELSE IF @AD_DEF_ID = 19	 /* Bonus Calculation */ 
					BEGIN
					
						DECLARE @Mini_Wages		NUMERIC(18,2)	--Ankit 09032016
						DECLARE @SkillType_ID	NUMERIC
						SET @Mini_Wages = 0
						SET @SkillType_ID =  0
						
						/* Get Minimum wages Amount */		
						SELECT @SkillType_ID = SkillType_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE cmp_id = @Cmp_ID and emp_id = @Emp_ID
						
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
						IF @AD_Rounding = 1 or @AD_DEF_ID = 4 -- For VPF
							SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
						ELSE
							SET @E_AD_AMOUNT = @Calculated_Amount * @E_AD_PERCENTAGE/100	

							If @AD_DEF_ID = 10 
								Begin
						  
									If @Company_Full_PF = 1
										Set @AC_2_3_Amount = @Calculated_Amount * @AC_2_3 /100									
									else
										Set @AC_2_3_Amount = @PF_Limit * @AC_2_3 /100
									
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
			Else If @AD_Calculate_On = 'Arrears CTC'   -- Hasmukh for Auto SP allowance when calc on CTC  ----Changed the Spelling from "Arears" to "Arrears" by Ramiz on 16/11/2016
				Begin
					Select @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)FROM T0100_EMP_EARN_DEDUCTION E WITH (NOLOCK) INNER JOIN 
						T0050_AD_MASTER A WITH (NOLOCK) on E.AD_ID = A.AD_ID And E.CMP_ID=A.CMP_ID
					WHERE e.cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID 
							AND INCREMENT_ID = @INCREMENT_ID And E_AD_FLAG = 'I'   and Isnull(A.AD_PART_OF_CTC,0)=1 And A.AD_Id <> @AD_id	
							
					Set @E_AD_AMOUNT = @CTC - Isnull((@Basic_Salary + @Temp_Amount),0) 
					set @Temp_Amount = 0
				End
			Else If @AD_Calculate_On = 'Arrears'   -- Hasmukh for Auto SP allowance when calc on gross --Changed the Spelling from "Arears" to "Arrears" by Ramiz on 16/11/2016
				Begin
					Select @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID 
							AND INCREMENT_ID = @INCREMENT_ID And E_AD_FLAG = 'I'
							AND AD_ID not in (select AD_ID from dbo.T0050_AD_MASTER WITH (NOLOCK) where Cmp_ID =@Cmp_ID and AD_Not_effect_salary = 1) 
					
					Set @E_AD_AMOUNT = @Gross_Salary - Isnull((@Basic_Salary + @Temp_Amount),0) 
					Set @Temp_Amount = 0
				End
				
	Set @E_AD_AMOUNT = Isnull(@E_AD_AMOUNT,0)
		
	IF @tran_type  = 'I' 
			BEGIN				
				IF EXISTS(SELECT AD_TRAN_ID FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID And Increment_Id = @Increment_Id AND AD_ID=@AD_ID)
					Set @Entry_Type = 'U'
				Else
					Set @Entry_Type = 'A'
	
				IF NOT EXISTS(SELECT TRAN_ID FROM T0110_EMP_EARN_DEDUCTION_Revised WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID And AD_ID=@AD_ID And For_Date = @For_Date)
					Begin						
						INSERT INTO T0110_EMP_EARN_DEDUCTION_Revised
							   (EMP_ID,CMP_ID,AD_ID,FOR_DATE,E_AD_FLAG,E_AD_MODE,E_AD_PERCENTAGE,E_AD_AMOUNT,E_AD_MAX_LIMIT,E_AD_YEARLY_AMOUNT, Entry_Type,Increment_ID,System_Date , User_ID,Is_Calculate_Zero)
						VALUES (@EMP_ID,@CMP_ID,@AD_ID,@FOR_DATE,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,CASE WHEN Isnull(@E_AD_AMOUNT,0) = -1 then 0 else @E_AD_AMOUNT end,@E_AD_MAX_LIMIT,@E_AD_AMOUNT_YEARLY,@Entry_Type,@Increment_Id,GETDATE(),@User_ID,CASE WHEN Isnull(@E_AD_AMOUNT,0) = -1 then 1 else 0 end)
					
					End				
				Else
					Begin
							
			
						UPDATE    T0110_EMP_EARN_DEDUCTION_Revised
						SET       E_AD_FLAG=@E_AD_FLAG,
								  E_AD_MODE=@E_AD_MODE,
								  E_AD_PERCENTAGE=@E_AD_PERCENTAGE,
								  E_AD_AMOUNT=CASE WHEN Isnull(@E_AD_AMOUNT,0) = -1 then 0 else @E_AD_AMOUNT end,
								  E_AD_MAX_LIMIT=@E_AD_MAX_LIMIT,
								  E_AD_YEARLY_AMOUNT = @E_AD_AMOUNT_YEARLY,
								  Entry_Type = @Entry_Type,
								  Increment_ID = @Increment_Id,
								  System_Date = GETDATE(),
								  User_ID = @User_ID,
								  Is_Calculate_Zero = CASE WHEN Isnull(@E_AD_AMOUNT,0) = -1 then 1 else 0 end
						Where EMP_ID = @EMP_ID and CMP_ID = @CMP_ID and For_Date = @For_Date and AD_ID = @AD_ID
						
					End			
				
				GOTO Special_Allowance_Calculate;
			END
			
	IF @tran_type  = 'U' 				
			BEGIN
				IF EXISTS(SELECT AD_TRAN_ID FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID And Increment_Id = @Increment_Id AND AD_ID=@AD_ID)
					Set @Entry_Type = 'U'
				Else
					Set @Entry_Type = 'A'
				
			
				
				UPDATE    T0110_EMP_EARN_DEDUCTION_REVISED
				SET       E_AD_FLAG=@E_AD_FLAG,
						  E_AD_MODE=@E_AD_MODE,
						  E_AD_PERCENTAGE=@E_AD_PERCENTAGE,
						  E_AD_AMOUNT=@E_AD_AMOUNT,
						  E_AD_MAX_LIMIT=@E_AD_MAX_LIMIT,
						  E_AD_YEARLY_AMOUNT = @E_AD_AMOUNT_YEARLY,
						  Entry_Type = @Entry_Type,
						  For_Date = @For_Date,
						  Increment_ID = @Increment_Id,
						  System_date = GETDATE(),
						  User_ID = @User_ID
				Where EMP_ID = @EMP_ID and CMP_ID = @CMP_ID AND AD_ID = @AD_ID AND TRAN_ID = @AD_TRAN_ID
			
				GOTO Special_Allowance_Calculate;
			END	
	
	
	---------Update Special Allowance ----------------
	Special_Allowance_Calculate:
	
	IF @Special_Allo_Cal_Setting = 1
		BEGIN
			DECLARE @Ad_Id_Temp Numeric(18,0)
			set @Ad_Id_Temp = 0
			Set @E_AD_PERCENTAGE = 0
			
			IF EXISTS(SELECT 1 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON EED.AD_ID = AD.AD_ID
						WHERE EED.CMP_ID = @Cmp_ID AND Emp_ID = @Emp_ID And Increment_Id = @Increment_Id AND (AD_Calculate_On = 'Arrears CTC' OR AD_Calculate_On = 'Arrears'))
				BEGIN
						SET @Temp_Amount = 0
						SET @E_AD_AMOUNT = 0
						
						---------AD_Calculate_On = 'Arrears CTC'
							SELECT @Ad_Id_Temp = EED.AD_ID FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON EED.AD_ID = AD.AD_ID
							WHERE EED.CMP_ID = @Cmp_ID AND Emp_ID = @Emp_ID And Increment_Id = @Increment_Id And E_AD_FLAG = 'I' and Isnull(AD.AD_PART_OF_CTC,0)=1 AND (AD_Calculate_On = 'Arrears CTC')
							
							IF @Ad_Id_Temp > 0	
								BEGIN
										SELECT @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)
										FROM (
											Select Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End As E_AD_AMOUNT,eed.AD_ID
											FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) Inner Join 
												T0050_AD_MASTER A WITH (NOLOCK) on EED.AD_ID = A.AD_ID And EED.CMP_ID=A.CMP_ID LEFT OUTER JOIN
												( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE 
													From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
													( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised  WITH (NOLOCK)
														Where Emp_Id = @Emp_Id
														And For_date <= @FOR_DATE 
													 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
												) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID 
											WHERE EED.cmp_ID = @Cmp_ID AND EED.EMP_ID = @Emp_ID 
													AND INCREMENT_ID = @INCREMENT_ID And E_AD_FLAG = 'I' AND Isnull(A.AD_PART_OF_CTC,0)=1
													--AND EED.AD_ID not in (select AD_ID from dbo.T0050_AD_MASTER where Cmp_ID =@Cmp_ID and AD_Not_effect_salary = 1) 
													and EED.AD_ID <> @Ad_Id_Temp
													
											UNION 
						
											SELECT E_AD_Amount,EED.ad_id
											FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
												( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised  WITH (NOLOCK)
													Where Emp_Id  = @Emp_Id And For_date <= @FOR_DATE 
													Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
											   INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID                     
											WHERE emp_id = @emp_id 
													And Adm.AD_ACTIVE = 1
													And EEd.ENTRY_TYPE = 'A'
													and EED.AD_ID <> @Ad_Id_Temp
											)Temp	
												
							
										SET @E_AD_AMOUNT = @CTC - Isnull((@Basic_Salary + @Temp_Amount),0) 
										SET @Temp_Amount = 0
									
										
										IF EXISTS(SELECT AD_TRAN_ID FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID And Increment_Id = @Increment_Id AND AD_ID=@Ad_Id_Temp)
											Set @Entry_Type = 'U'
										Else
											Set @Entry_Type = 'A'
							
										IF NOT EXISTS(SELECT TRAN_ID FROM T0110_EMP_EARN_DEDUCTION_Revised WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID And AD_ID=@Ad_Id_Temp And For_Date = @For_Date)
											Begin
												INSERT INTO T0110_EMP_EARN_DEDUCTION_Revised
													   (EMP_ID,CMP_ID,AD_ID,FOR_DATE,E_AD_FLAG,E_AD_MODE,E_AD_PERCENTAGE,E_AD_AMOUNT,E_AD_MAX_LIMIT,E_AD_YEARLY_AMOUNT, Entry_Type,Increment_ID,System_date,user_id)
												VALUES (@EMP_ID,@CMP_ID,@Ad_Id_Temp,@FOR_DATE,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_MAX_LIMIT,@E_AD_AMOUNT_YEARLY,@Entry_Type,@Increment_Id,GETDATE(),@User_Id)
											
											End				
										Else
											Begin											
												
												UPDATE    T0110_EMP_EARN_DEDUCTION_Revised
												SET       E_AD_FLAG=@E_AD_FLAG,
														  E_AD_MODE=@E_AD_MODE,
														  E_AD_PERCENTAGE=@E_AD_PERCENTAGE,
														  E_AD_AMOUNT=@E_AD_AMOUNT,
														  E_AD_MAX_LIMIT=@E_AD_MAX_LIMIT,
														  E_AD_YEARLY_AMOUNT = @E_AD_AMOUNT_YEARLY,
														  Entry_Type = @Entry_Type,
														  Increment_ID = @Increment_Id,
														  System_date = GETDATE(),
														  User_id = @User_Id
												Where EMP_ID = @EMP_ID and CMP_ID = @CMP_ID and For_Date = @For_Date and AD_ID = @Ad_Id_Temp
												
											End
																				
								END
						
						SET @Temp_Amount = 0
						SET @E_AD_AMOUNT = 0
						SET @Ad_Id_Temp  = 0
						Set @E_AD_PERCENTAGE = 0
						
						---------AD_Calculate_On = 'Arrears'
						SELECT @Ad_Id_Temp = EED.AD_ID FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON EED.AD_ID = AD.AD_ID
						WHERE EED.CMP_ID = @Cmp_ID AND Emp_ID = @Emp_ID And Increment_Id = @Increment_Id And E_AD_FLAG = 'I' AND (AD_Calculate_On = 'Arrears')
							
						IF ISNULL(@Ad_Id_Temp,0) > 0
								BEGIN
									
									--Select @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)FROM T0100_EMP_EARN_DEDUCTION WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID 
									--		AND INCREMENT_ID = @INCREMENT_ID And E_AD_FLAG = 'I'
									--		AND AD_ID not in (select AD_ID from dbo.T0050_AD_MASTER where Cmp_ID =@Cmp_ID and AD_Not_effect_salary = 1) 
											
									
									SELECT @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)
										FROM (
											Select Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End As E_AD_AMOUNT,eed.AD_ID
											FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) Inner Join 
												T0050_AD_MASTER A WITH (NOLOCK) on EED.AD_ID = A.AD_ID And EED.CMP_ID=A.CMP_ID LEFT OUTER JOIN
												( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE 
													From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
													( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
														Where Emp_Id = @Emp_Id
														And For_date <= @FOR_DATE 
													 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
												) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID 
											WHERE EED.cmp_ID = @Cmp_ID AND EED.EMP_ID = @Emp_ID 
													AND INCREMENT_ID = @INCREMENT_ID And E_AD_FLAG = 'I' AND Isnull(A.AD_PART_OF_CTC,0) = 1
													--AND EED.AD_ID not in (select AD_ID from dbo.T0050_AD_MASTER where Cmp_ID =@Cmp_ID and AD_Not_effect_salary = 1) 
													and EED.AD_ID <> @Ad_Id_Temp
													
											UNION 
						
											SELECT E_AD_Amount,EED.ad_id
											FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
												( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
													Where Emp_Id  = @Emp_Id And For_date <= @FOR_DATE 
													Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
											   INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID                     
											WHERE emp_id = @emp_id 
													And Adm.AD_ACTIVE = 1
													And EEd.ENTRY_TYPE = 'A'
													and EED.AD_ID <> @Ad_Id_Temp AND Isnull(ADM.AD_PART_OF_CTC,0)=1
											)Tempp
											
									Set @E_AD_AMOUNT = @Gross_Salary - Isnull((@Basic_Salary + @Temp_Amount),0) 
									Set @Temp_Amount = 0
									Set @E_AD_PERCENTAGE = 0
									
									IF EXISTS(SELECT AD_TRAN_ID FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID And Increment_Id = @Increment_Id AND AD_ID=@Ad_Id_Temp)
											Set @Entry_Type = 'U'
										Else
											Set @Entry_Type = 'A'
							
										IF NOT EXISTS(SELECT TRAN_ID FROM T0110_EMP_EARN_DEDUCTION_Revised WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID And AD_ID=@Ad_Id_Temp And For_Date = @For_Date)
											Begin
											
												INSERT INTO T0110_EMP_EARN_DEDUCTION_Revised
													   (EMP_ID,CMP_ID,AD_ID,FOR_DATE,E_AD_FLAG,E_AD_MODE,E_AD_PERCENTAGE,E_AD_AMOUNT,E_AD_MAX_LIMIT,E_AD_YEARLY_AMOUNT, Entry_Type,Increment_ID,System_date,User_ID)
												VALUES (@EMP_ID,@CMP_ID,@Ad_Id_Temp,@FOR_DATE,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_MAX_LIMIT,@E_AD_AMOUNT_YEARLY,@Entry_Type,@Increment_Id,GETDATE(),@User_Id)
												
											End				
										Else
											Begin
												
												UPDATE    T0110_EMP_EARN_DEDUCTION_Revised
												SET       E_AD_FLAG=@E_AD_FLAG,
														  E_AD_MODE=@E_AD_MODE,
														  E_AD_PERCENTAGE=@E_AD_PERCENTAGE,
														  E_AD_AMOUNT=@E_AD_AMOUNT,
														  E_AD_MAX_LIMIT=@E_AD_MAX_LIMIT,
														  E_AD_YEARLY_AMOUNT = @E_AD_AMOUNT_YEARLY,
														  Entry_Type = @Entry_Type,
														  Increment_ID = @Increment_Id,
														  System_Date = GETDATE(),
														  User_iD = @user_id
												Where EMP_ID = @EMP_ID and CMP_ID = @CMP_ID and For_Date = @For_Date and AD_ID = @Ad_Id_Temp
												
											End
										
									
								END		
					
				
				END
		END
	---------Update Special Allowance ----------------
	
	RETURN
