---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0180_BONUS]
		 @Bonus_ID	numeric(18, 0) output
		,@Cmp_ID	numeric(18, 0)
		,@Emp_ID	numeric(18, 0)
		,@From_Date	datetime
		,@To_Date	datetime
		,@Bonus_Calculated_On	varchar(20)
		,@Bonus_Percentage	numeric(18, 5)
		,@Bonus_Fix_Amount	numeric(18, 0)
		,@Bonus_Effect_on_Sal	numeric(18, 0)
		,@Bonus_Effect_Month	numeric(18, 0)
		,@Bonus_Effect_Year	numeric(18, 0)
		,@Bonus_Comments	varchar(250)
		,@tran_type varchar(1)
		,@Is_FNF		int =0
		,@User_Id numeric(18,0) = 0		-- Added for audit trail By Ali 18102013
		,@IP_Address varchar(30)= ''	-- Added for audit trail By Ali 18102013
		,@Bonus_Cal_Type	varchar(50)= ''  --Added By Jimit 06122019
 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

										-- Added for audit trail By Ali 18102013 - Start
											Declare @Old_Emp_Name as varchar(150)
											Declare @Old_Emp_Id as numeric
											Declare @Old_From_Date as dateTIME
											Declare @Old_To_Date as datetime
											Declare @Old_Bonus_Calculated_On as	varchar(20)
											Declare @Old_Bonus_Percentage as numeric(18, 2)
											Declare @Old_Bonus_Fix_Amount as numeric(18, 0)
											Declare @Old_Bonus_Effect_on_Sal as	numeric(18, 0)
											Declare @Old_Bonus_Effect_Month as numeric(18, 0)
											Declare @Old_Bonus_Effect_Year as numeric(18, 0)
											Declare @Old_Bonus_Comments as varchar(250)
											Declare @OldValue as varchar(max)
											Declare @Old_Bonus_Amount as numeric
											Declare @Old_Bonus_Calculated_Amount as numeric
											
											
											Set @Old_Emp_Name = ''
											Set @Old_Emp_Id = 0
											Set @Old_From_Date = null
											Set @Old_To_Date = null
											Set @Old_Bonus_Calculated_On = ''
											Set @Old_Bonus_Percentage = 0
											Set @Old_Bonus_Fix_Amount = 0
											Set @Old_Bonus_Effect_on_Sal = 0
											Set @Old_Bonus_Effect_Month = 0
											Set @Old_Bonus_Effect_Year = 9
											Set @Old_Bonus_Comments = 0
											Set @OldValue = ''
											Set @Old_Bonus_Amount = 0
											Set @Old_Bonus_Calculated_Amount = 0
										-- Added for audit trail By Ali 18102013 - End			
										
	Declare @Bonus_Amount as 	numeric(18, 0)
	DECLARE @Bonus_Calculated_Amount as numeric(18, 2)     
	Declare @Branch_ID as numeric
	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime
	Declare @Bonus_Max_Limit Numeric(18,2)    
	Declare @Max_Bonus_Salary_Amount as Numeric(18,2) --Hardik 11/04/2013
	Declare @Increment_Id as Numeric --Hardik 11/04/2013
	Declare @Effect_Allow_Amount as Numeric(18,2) ---Hardik 11/04/2013
	Declare @Wages_Type as varchar(15) ---Hardik 11/04/2013
	Declare @Temp_For_Date Datetime   ---Hardik 11/04/2013
	Declare @Bonus_Tran_ID as Numeric ---Hardik 11/04/2013
	Declare @Paid_Weekoff_Daily_Wages as tinyint -- Hardik 12/04/2013
	
	Declare @Bonus_Cal_Days numeric(18,2)
	Declare @P_Day as numeric(18,2)
	Declare @Weekoff as numeric(18,2)
	Declare @Holiday as numeric(18,2)
	Declare @W_Day as numeric(18,2)
	Declare @Sal_Cal_Days as numeric(18,2)
	Declare @Actual_Gross_Salary as Numeric(22,2)
	
	--Hardik 18/04/2014
	Declare @Basic_Salary as numeric(18,2)
	Declare @Ex_Gratia_Calculated_Amount as Numeric(18,2)
	Declare @Monthly_Ex_Gratia_Calculated_Amt as Numeric(18,2)
	Declare @Bonus_Entitle_Limit as Numeric(18,2)
	Declare @Salary_Amount as Numeric(18,2)
	Declare @S_Salary_Amount as Numeric(18,2)
	
	Declare @Arear_Bonus_Calculated_Amount Numeric(18,2)
	Declare @Arear_P_Day Numeric(12,2)
	SET @Arear_Bonus_Calculated_Amount = 0
	SET @Arear_P_Day = 0
															
	set @Basic_Salary = 0
	Set @Ex_Gratia_Calculated_Amount = 0
	Set @Monthly_Ex_Gratia_Calculated_Amt = 0
	SEt @Bonus_Entitle_Limit = 0
	Set @Salary_Amount = 0
	

	Set @Effect_Allow_Amount = 0
	Set @Bonus_Tran_ID = 0
	Set @Bonus_Amount = 0
	Set @Paid_Weekoff_Daily_Wages = 0
	

	Set @Bonus_Cal_Days = 0
	Set @P_Day = 0
	Set @Weekoff = 0
	Set @Holiday = 0
	set @W_Day = 0
	Set @Sal_Cal_Days = 0
	Set @Bonus_Calculated_Amount = 0

	
	set @Bonus_Max_Limit = 0
	Set @Max_Bonus_Salary_Amount = 0
	Set @Temp_For_Date = @From_Date ---Hardik 11/04/2013
	Set @S_Salary_Amount = 0 
	
	DECLARE @Mini_Wages NUMERIC(18,2)	--Ankit 09032016
	DECLARE @SkillType_ID	NUMERIC
	Declare @OutOff_Days as numeric(18,2)
	Declare @Inc_Holiday as NUMERIC
	DECLARE @RESTRICT_PRESENT_DAYS AS CHAR	--ADDED BY RAMIZ ON 12/04/2017
	DECLARE @SAL_FIX_DAYS AS NUMERIC(18,2)	--ADDED BY RAMIZ ON 12/04/2017

	Declare @Emp_Fix_Salary tinyint --Hardik 15/10/2019 for Samarth Diamond
	Set @Emp_Fix_Salary = 0

	SET @Mini_Wages = 0
	SET @SkillType_ID =  0
	SET @OutOff_Days = 0
	SET @Inc_Holiday = 0
	SET @RESTRICT_PRESENT_DAYS = 'Y'	-- AS 'Y' IS ITS DEFAULT VALUE
	SET @SAL_FIX_DAYS = 0				-- AS '0' IS ITS DEFAULT VALUE
	
	DECLARE @Admin_Setting_Arear TINYINT	--Ankit 03062016
	SET @Admin_Setting_Arear = 0
	SELECT @Admin_Setting_Arear = ISNULL(Setting_Value,0) FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Bonus Detail - Salary Arear Amount Calculated In Arear Month'
	
		declare @Effect_Allowance_Amount1 as numeric(18,2)  --Added By Jimit 19092018
		DECLARE @Monthly_Ex_Gratia_Bonus_Amount NUMERIC(18,2)

	 --Hardik 15/10/2019 for Samarth Diamond
	SELECT @Emp_Fix_Salary = Emp_Fix_Salary FROM DBO.fn_getEmpIncrementWithoutTransfer(@Cmp_Id, @Emp_Id, @To_Date) INC 
		Inner Join T0095_INCREMENT I WITH (NOLOCK) On Inc.Increment_ID = I.Increment_ID


	if @tran_type = 'I'
			begin
				
				If @Bonus_Calculated_On <> 'Allowance'
				  BEGIN
					If exists(select Bonus_ID From T0180_BONUS WITH (NOLOCK) where Cmp_ID = @Cmp_ID and emp_ID =@EMP_ID
							And Bonus_Calculated_On = 'Consolidated' -- Added by Hardik 02/11/2020 for Wonder cement
							and ((@From_Date >= from_date and @From_Date <= to_date) or 
							(@To_Date >= from_date and 	@To_Date <= to_date) or 
							(from_date >= @From_Date and from_date <= @To_Date) or
							(to_date >= @From_Date and to_date <= @To_Date)	)
							) 
						Begin
								set @Bonus_ID = 0	
									
								return
						End
					END
				ELSE IF @Bonus_Calculated_On = 'Allowance'
				  BEGIN
					If exists(select Bonus_ID From T0180_BONUS WITH (NOLOCK) where Cmp_ID = @Cmp_ID and emp_ID =@EMP_ID
								and Bonus_Cal_Type = @Bonus_Cal_Type And Bonus_Calculated_On = 'Allowance'
							and ((@From_Date >= from_date and @From_Date <= to_date) or 
							(@To_Date >= from_date and 	@To_Date <= to_date) or 
							(from_date >= @From_Date and from_date <= @To_Date) or
							(to_date >= @From_Date and to_date <= @To_Date)	)
							) 
						Begin
								set @Bonus_ID = 0	
									
								return
						End
					END

			Select @Bonus_ID = Isnull(max(Bonus_ID),0) + 1 	From T0180_BONUS WITH (NOLOCK)
		
			INSERT INTO T0180_BONUS
					(Bonus_ID, Cmp_ID, Emp_ID, From_Date, To_Date, Bonus_Calculated_On, Bonus_Percentage, Bonus_Amount,
					 Bonus_Fix_Amount, Bonus_Effect_on_Sal, Bonus_Effect_Month, Bonus_Effect_Year, Bonus_Comments, Bonus_Calculated_Amount,Is_FNF,Bonus_Cal_Type)
			VALUES     
					(@Bonus_ID, @Cmp_ID, @Emp_ID, @From_Date, @To_Date, @Bonus_Calculated_On, @Bonus_Percentage, @Bonus_Amount,
						@Bonus_Fix_Amount, @Bonus_Effect_on_Sal, @Bonus_Effect_Month, @Bonus_Effect_Year, @Bonus_Comments,@Bonus_Calculated_Amount,@Is_FNF,@Bonus_Cal_Type)	
					
		  While @Temp_For_Date <= @To_Date     
				 begin	
							Set @Effect_Allow_Amount = 0
							Set @Bonus_Amount = 0
							Set @Paid_Weekoff_Daily_Wages = 0
							Set @Bonus_Cal_Days = 0
							Set @P_Day = 0
							Set @Weekoff = 0
							Set @Holiday = 0
							set @W_Day = 0
							Set @Sal_Cal_Days = 0
							Set @Bonus_Calculated_Amount = 0
							set @Bonus_Max_Limit = 0
							Set @Max_Bonus_Salary_Amount = 0
							Set @Actual_Gross_Salary = 0

							Set @Salary_Amount = 0
							set @Basic_Salary = 0
							Set @Ex_Gratia_Calculated_Amount = 0
							Set @Monthly_Ex_Gratia_Calculated_Amt = 0
							SEt @Bonus_Entitle_Limit = 0
							Set @S_Salary_Amount = 0
							SET @Arear_Bonus_Calculated_Amount = 0
							SET @Arear_P_Day = 0
							SET @Mini_Wages = 0
							SET @SkillType_ID =  0
							SET @OutOff_Days = 0
							SET @Inc_Holiday = 0
							SET @Effect_Allowance_Amount1 = 0
							SET @Monthly_Ex_Gratia_Calculated_Amt = 0
						--Select @Branch_Id = Branch_Id, @Increment_Id = I.Increment_ID, @Wages_Type = Wages_Type, @Basic_Salary = ISNULL(Basic_Salary,0)
						--	FROM T0095_Increment I inner join       
						--	 (SELECT max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment    --Changed by Hardik 09/09/2014 for Same Date Increment  
						--	  WHERE  --Increment_Effective_date <= @Temp_For_Date      
						--		Increment_Effective_date <= dbo.GET_MONTH_END_DATE(MONTH(@Temp_For_Date),YEAR(@Temp_For_Date)) --Check End Date B'cos Mid join Employee has Cal wrong Bonus - Ankit 28062016
						--	  AND Cmp_ID = @Cmp_ID      
						--	  GROUP BY emp_ID) Qry on      
						--	 I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id      --Changed by Hardik 09/09/2014 for Same Date Increment
						--WHERE I.Emp_ID = @Emp_ID
						
						--Added By Jimit 19092018
						SELECT	@BRANCH_ID = BRANCH_ID--, @INCREMENT_ID = I.INCREMENT_ID, @WAGES_TYPE = WAGES_TYPE, 
								--@BASIC_SALARY = ISNULL(BASIC_SALARY,0)
						FROM	T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
								(										
								   SELECT	MAX(I2.INCREMENT_ID) AS INCREMENT_ID,I2.EMP_ID 									
								   FROM	    T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN 
											T0080_EMP_MASTER E WITH (NOLOCK) ON I2.EMP_ID=E.EMP_ID INNER JOIN (
														 SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
														 FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.EMP_ID=E3.EMP_ID
														 WHERE	I3.INCREMENT_EFFECTIVE_DATE <= dbo.GET_MONTH_END_DATE(MONTH(@Temp_For_Date),YEAR(@Temp_For_Date)) AND 
																I3.CMP_ID =@CMP_ID	
														 GROUP BY I3.EMP_ID  					
														) I3 ON I2.INCREMENT_EFFECTIVE_DATE=I3.INCREMENT_EFFECTIVE_DATE AND I2.EMP_ID=I3.EMP_ID	
									GROUP BY I2.EMP_ID										
								) I_Q ON I.EMP_ID = I_Q.EMP_ID AND I.INCREMENT_ID=I_Q.INCREMENT_ID 
						WHERE I.EMP_ID = @EMP_ID
						
						SELECT	@INCREMENT_ID = I.INCREMENT_ID, @WAGES_TYPE = WAGES_TYPE,@BASIC_SALARY = ISNULL(BASIC_SALARY,0)
						FROM	T0095_INCREMENT I  WITH (NOLOCK) INNER JOIN
								(										
								   SELECT	MAX(I2.INCREMENT_ID) AS INCREMENT_ID,I2.EMP_ID 									
								   FROM	    T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN 
											T0080_EMP_MASTER E WITH (NOLOCK) ON I2.EMP_ID=E.EMP_ID INNER JOIN (
														 SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
														 FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.EMP_ID=E3.EMP_ID
														 WHERE	I3.INCREMENT_EFFECTIVE_DATE <= dbo.GET_MONTH_END_DATE(MONTH(@Temp_For_Date),YEAR(@Temp_For_Date)) AND 
																I3.CMP_ID =@CMP_ID AND I3.INCREMENT_TYPE NOT IN ('Transfer','Deputation')
														 GROUP BY I3.EMP_ID  					
														) I3 ON I2.INCREMENT_EFFECTIVE_DATE=I3.INCREMENT_EFFECTIVE_DATE AND I2.EMP_ID=I3.EMP_ID															
									WHERE I2.INCREMENT_TYPE NOT IN ('TRANSFER','DEPUTATION')
									GROUP BY I2.EMP_ID										
								) I_Q ON I.EMP_ID = I_Q.EMP_ID AND I.INCREMENT_ID=I_Q.INCREMENT_ID 
						WHERE I.EMP_ID = @EMP_ID						
						--Ended---
						
						If @Branch_ID is null   ---Added by hasmukh for check max limit 29 Mar 2012
							Begin 
								select Top 1 @Sal_St_Date  = Sal_st_Date,@Bonus_Max_Limit = isnull(Bonus_Max_Limit,0),@Max_Bonus_Salary_Amount = ISNULL(Max_Bonus_Salary_Amount,0),
									@Paid_Weekoff_Daily_Wages = Paid_Weekoff_Daily_Wages, @Bonus_Entitle_Limit = Bonus_Entitle_Limit , @RESTRICT_PRESENT_DAYS = ISNULL(Restrict_Present_days,'Y')
									,@SAL_FIX_DAYS = ISNULL(SAL_FIX_DAYS,0)
								  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
								  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Temp_For_Date and Cmp_ID = @Cmp_ID)    --Modified By Ramiz on 15092014
							End
						Else
							Begin
								select @Sal_St_Date  = Sal_st_Date, @Bonus_Max_Limit = isnull(Bonus_Max_Limit,0),@Max_Bonus_Salary_Amount = ISNULL(Max_Bonus_Salary_Amount,0),
									@Paid_Weekoff_Daily_Wages = Paid_Weekoff_Daily_Wages,@Bonus_Entitle_Limit = Bonus_Entitle_Limit , @RESTRICT_PRESENT_DAYS = ISNULL(Restrict_Present_days,'Y')
									,@SAL_FIX_DAYS = ISNULL(SAL_FIX_DAYS,0)
								  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
								  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Temp_For_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
							End
					
					/* Get Minimum wages Amount */		
					--SELECT @Mini_Wages = min_basic FROM T0040_GRADE_MASTER WHERE Grd_ID = @Grd_Id AND Cmp_ID = @Cmp_ID
					SELECT @SkillType_ID = SkillType_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE cmp_id=@Cmp_ID and emp_id=@Emp_ID
					SELECT @Mini_Wages = ISNULL(MW.Wages_Value,0) FROM T0050_Minimum_Wages_Master MW WITH (NOLOCK) INNER JOIN
						( SELECT MAX(Effective_Date) AS EffecDate,SkillType_ID FROM T0050_Minimum_Wages_Master WITH (NOLOCK)
							WHERE cmp_Id = @Cmp_ID AND SkillType_ID = @SkillType_ID AND Effective_Date <= @Temp_For_Date GROUP BY SkillType_ID
						) Qry ON MW.SkillType_ID = Qry.SkillType_ID AND MW.Effective_Date = Qry.EffecDate
					WHERE MW.cmp_Id = @Cmp_ID AND MW.SkillType_ID = @SkillType_ID
					
					
					IF @Bonus_Calculated_On ='Basic'   --- Calculate on Master Basic
						BEGIN																			
							select @Bonus_Calculated_Amount = isnull(sum(Basic_Salary) ,0),
								@Sal_Cal_Days = isnull(sum(Sal_Cal_Days),0), @W_Day = isnull(sum(Working_Days),0)
							from t0200_MONTHLY_SALARY WITH (NOLOCK)
							where cmp_id=@Cmp_ID and emp_id=@Emp_ID and Month(month_end_date) = Month(@Temp_For_Date) and Year(month_end_date) = Year(@Temp_For_Date)
							--where cmp_id=@Cmp_ID and emp_id=@Emp_ID and month_st_date >= @From_Date and month_end_date <=@To_Date
							
							SET @Bonus_Cal_Days = @Sal_Cal_Days
							--Select @Bonus_Calculated_Amount,@Effect_Allow_Amount
							--Hardik 11/04/2013
							Select @Effect_Allow_Amount = Isnull(Sum(E_AD_AMOUNT),0) 
							From T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) Inner Join
								T0050_AD_MASTER AM WITH (NOLOCK) on EED.AD_ID = AM.AD_ID 
							Where AD_EFFECT_ON_BONUS = 1 And EED.Cmp_ID=@Cmp_ID and Emp_id= @Emp_ID 
								And INCREMENT_ID = @Increment_Id
							
							
							SET @Bonus_Calculated_Amount = @Bonus_Calculated_Amount + @Effect_Allow_Amount
							SET @Bonus_Amount = ((@Bonus_Calculated_Amount * @Bonus_Percentage )/100)	
							
							IF @Bonus_Max_Limit > 0 and @Bonus_Amount > @Bonus_Max_Limit   ---Added by hasmukh for check max limit 29 Mar 2012
								set @Bonus_Amount = @Bonus_Max_Limit
							if @Bonus_Entitle_Limit < @Bonus_Calculated_Amount and @Bonus_Entitle_Limit > 0 		
								set @Bonus_Amount = 0
						END
					ELSE IF @Bonus_Calculated_On ='Gross'  --- Calculate on Salary Gross
						BEGIN
							select @Bonus_Calculated_Amount = isnull(sum(GROSS_salary) ,0),
								@Sal_Cal_Days = isnull(sum(Sal_Cal_Days),0), @W_Day = isnull(sum(Working_Days),0) 
							from t0200_MONTHLY_SALARY WITH (NOLOCK) where cmp_id=@Cmp_ID and emp_id=@Emp_ID and month_st_date >= @From_Date and month_end_date <=@To_Date
							
							SET @Bonus_Cal_Days = @Sal_Cal_Days
							
							SET @Bonus_Amount = ((@Bonus_Calculated_Amount * @Bonus_Percentage )/100)
							IF @Bonus_Max_Limit > 0 and @Bonus_Amount > @Bonus_Max_Limit
								set @Bonus_Amount = @Bonus_Max_Limit
						END
					ELSE IF @Bonus_Calculated_On ='Consolidated'  --- Calculate on Salary Basic (Prorata)
						BEGIN
							IF @Admin_Setting_Arear = 1 --Ankit 03062016
								BEGIN
									SELECT	@Salary_Amount = ISNULL(SUM(salary_Amount) ,0) + Isnull(Sum(Basic_Salary_Arear_cutoff),0), --  -  ISNULL(SUM(Arear_Basic) ,0), -- Commented by Hardik on 19/09/2017, Salary amount has no arear basic added
											@Sal_Cal_Days = ISNULL(SUM(Sal_Cal_Days),0)  + Isnull(Sum(Arear_Day_Previous_month),0), @W_Day = ISNULL(SUM(Working_Days),0) ,
											@Weekoff = ISNULL(SUM(Weekoff_Days) ,0), @OutOff_Days = ISNULL(SUM(Outof_Days),0),@Holiday = ISNULL(SUM(Holiday_Days),0) 
									FROM	T0200_MONTHLY_SALARY WITH (NOLOCK)
									WHERE	cmp_id=@Cmp_ID AND emp_id=@Emp_ID AND MONTH(month_end_date) = MONTH(@Temp_For_Date) AND YEAR(month_end_date) = YEAR(@Temp_For_Date)
								
								
									SELECT	@Salary_Amount = ISNULL(@Salary_Amount,0) + ISNULL(SUM(Arear_Basic),0),
											@Sal_Cal_Days  = ISNULL(@Sal_Cal_Days,0) + ISNULL(SUM(Arear_Day),0)
									FROM	T0200_MONTHLY_SALARY WITH (NOLOCK)
									WHERE	cmp_id=@Cmp_ID AND emp_id=@Emp_ID AND Arear_Month = MONTH(@Temp_For_Date) AND Arear_Year = YEAR(@Temp_For_Date)
								
								END
							ELSE
								BEGIN	
									Select @Salary_Amount = isnull(sum(salary_Amount) ,0) +  isnull(sum(Arear_Basic) ,0)+ Isnull(Sum(Basic_Salary_Arear_cutoff),0),
										@Sal_Cal_Days = isnull(sum(Sal_Cal_Days),0) + Isnull(Sum(Arear_Day_Previous_month),0), @W_Day = isnull(sum(Working_Days),0) 
										,@Weekoff = ISNULL(sum(Weekoff_Days) ,0), @OutOff_Days = ISNULL(sum(Outof_Days),0),@Holiday = isnull(sum(Holiday_Days),0) 
									from t0200_MONTHLY_SALARY WITH (NOLOCK)
									where cmp_id=@Cmp_ID and emp_id=@Emp_ID and Month(month_end_date) = Month(@Temp_For_Date) and Year(month_end_date) = Year(@Temp_For_Date)
									--where cmp_id=@Cmp_ID and emp_id=@Emp_ID and month_st_date >= @From_Date and month_end_date <=@To_Date
								END	
							
							Select @S_Salary_Amount = isnull(sum(s_salary_Amount) ,0) --+  isnull(sum(Arear_Basic) ,0),								
							from T0201_MONTHLY_SALARY_SETT WITH (NOLOCK)
							where cmp_id=@Cmp_ID and emp_id=@Emp_ID and Month(S_Eff_Date) = Month(@Temp_For_Date) and Year(S_Eff_Date) = Year(@Temp_For_Date)
							
							Set @Salary_Amount = @Salary_Amount + isnull(@S_Salary_Amount,0)

							SET @Bonus_Cal_Days = @Sal_Cal_Days

							If @Emp_Fix_Salary = 1 --Hardik 15/10/2019 for Samarth Diamond							
								Set @Bonus_Cal_Days = @W_Day
							
							--Hardik 11/04/2013
							Select @Effect_Allow_Amount = Isnull(Sum(M_AD_Amount),0) + Isnull(Sum(M_Arear_Amount),0)
								From T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) Inner Join
									T0050_AD_MASTER AM WITH (NOLOCK) on MAD.AD_ID = AM.AD_ID 
								Where AD_EFFECT_ON_BONUS = 1 And MAD.Cmp_ID=@Cmp_ID and Emp_id= @Emp_ID 
									and Month(To_date) = Month(@Temp_For_Date) and Year(To_date) = Year(@Temp_For_Date)

							--Added By Jimit 19092018 as there is case at RK Effect in BOnus heads are not coming in Bonus calculating amount
							Select @Effect_Allowance_Amount1 = Isnull(Sum(E_AD_AMOUNT),0) 
							From T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) Inner Join
								T0050_AD_MASTER AM WITH (NOLOCK) on EED.AD_ID = AM.AD_ID 
							Where AD_EFFECT_ON_BONUS = 1 And EED.Cmp_ID=@Cmp_ID and Emp_id= @Emp_ID 
								And INCREMENT_ID = @Increment_Id
							--Ended
							
								If @Wages_Type = 'Daily'
									Begin
										IF ISNULL(@Mini_Wages,0) > 0
											SET @Mini_Wages = @Mini_Wages --* 26
											
										If @Paid_Weekoff_Daily_Wages = 0
											Begin
												--Set @W_Day = @W_Day -- - @Weekoff
												
												---Ankit ----
												SET @W_Day = @OutOff_Days - @Weekoff
												
												IF @Inc_Holiday  = 1
													BEGIN
														SET @W_Day = @W_Day - @Holiday
													END
												---Ankit ----
												
												If @W_Day > 0
													Set @Actual_Gross_Salary = (@Basic_Salary * @W_Day) + (Isnull(@Effect_Allowance_Amount1,0)* @W_Day)
												Else 
													Set @Actual_Gross_Salary = 0
											End
									End
								Else
									Begin
										SET @Actual_Gross_Salary = @Basic_Salary + ISNULL(@Effect_Allowance_Amount1,0)
										--SET @Actual_Gross_Salary = @Salary_Amount + @Effect_Allow_Amount	--Ankit 30092015
									End
								
								--New Code Added By Ramiz on 12/04/2017
								IF @Bonus_Cal_Days > @W_Day AND ISNULL(@RESTRICT_PRESENT_DAYS,'Y') = 'Y'
									SET @Bonus_Cal_Days = @W_Day
								
								IF ISNULL(@SAL_FIX_DAYS,0) > 0
									SET @W_Day = ISNULL(@SAL_FIX_DAYS,0)
								--CODE ENDED BY RAMIZ ON 12/04/2017
									
							
							/* Bonus Calculated limit check : Bonus Max Limit In Company General Setting or Gov. Minimum Wages in Grade Master whichever is higher (Golcha EmailDated - Thu, Feb 25, 2016) -- Ankit 09032016   */
							IF ISNULL(@Mini_Wages,0) > 0 AND @Actual_Gross_Salary >= @Max_Bonus_Salary_Amount 
								BEGIN
									
									IF @Mini_Wages >= @Max_Bonus_Salary_Amount
										SET @Max_Bonus_Salary_Amount = @Mini_Wages
								END
							
							
							
							If @Actual_Gross_Salary >= @Max_Bonus_Salary_Amount And @Actual_Gross_Salary <= @Bonus_Entitle_Limit
								Begin
								
									If @Max_Bonus_Salary_Amount <= 0  --Hardik 11/04/2013
										Begin
											If @W_Day > 0
												SET @Bonus_Calculated_Amount = ((@Bonus_Calculated_Amount * @Bonus_Cal_Days) / @W_Day)
											Else
												SET @Bonus_Calculated_Amount = 0
										End
									Else
										Begin
											If @W_Day > 0
												Begin
												
													--If @Salary_Amount >= @Max_Bonus_Salary_Amount 
														Begin
															SET @Bonus_Calculated_Amount = ((@Max_Bonus_Salary_Amount * @Bonus_Cal_Days) / @W_Day)
															Set @Monthly_Ex_Gratia_Calculated_Amt = @Salary_Amount -  Round(@Bonus_Calculated_Amount,0)
														End
													--Else
													--	Begin
													--		SET @Bonus_Calculated_Amount = ((@Salary_Amount * @Bonus_Cal_Days) / @W_Day)
													--		Set @Monthly_Ex_Gratia_Calculated_Amt = @Salary_Amount -  Round(@Bonus_Calculated_Amount,0)
													--	End
												End
											Else
												SET @Bonus_Calculated_Amount = 0
										End									
								End
							Else If @Actual_Gross_Salary < @Max_Bonus_Salary_Amount and Isnull(@Max_Bonus_Salary_Amount,0) > 0
								Begin
									IF Isnull(@Max_Bonus_Salary_Amount,0) > @Salary_Amount -- Added by Hardik 29/09/2020 for Cera as Salary amount is going above 7000
										BEGIN
											Set @Bonus_Calculated_Amount = @Salary_Amount
											Set @Monthly_Ex_Gratia_Calculated_Amt = 0
										END
									ELSE
										BEGIN
											Set @Bonus_Calculated_Amount = @Max_Bonus_Salary_Amount
											Set @Monthly_Ex_Gratia_Calculated_Amt = @Salary_Amount - @Max_Bonus_Salary_Amount
										END
								End
							Else If @Actual_Gross_Salary > @Bonus_Entitle_Limit and Isnull(@Bonus_Entitle_Limit,0) > 0
								Begin								
									Set @Bonus_Calculated_Amount = 0
									Set @Monthly_Ex_Gratia_Calculated_Amt = @Salary_Amount
								End
							Else
								Begin
									Set @Bonus_Calculated_Amount = @Salary_Amount
								End
							
							
							--Set @Bonus_Calculated_Amount = @Bonus_Calculated_Amount + @Effect_Allow_Amount --Hardik 11/04/2013
																
							SET @Bonus_Amount = ROUND(((@Bonus_Calculated_Amount * @Bonus_Percentage )/100),0)
							
							IF @Bonus_Max_Limit > 0 and @Bonus_Amount > @Bonus_Max_Limit
								set @Bonus_Amount = @Bonus_Max_Limit
						END		
					-- Start -Added by Falak on 09-MAR-2011 
					ELSE IF @Bonus_Calculated_On ='Present Day'
							BEGIN --Last modified by Falak on 16-MAR-2011
								

								Select @Bonus_Calculated_Amount = isnull(sum(basic_salary) ,0),@Sal_Cal_Days = isnull(sum(Sal_Cal_Days),0),
								@P_Day = isnull(sum(Present_Days),0),@W_Day = isnull(sum(Outof_Days),0),@Weekoff = Isnull(sum(Weekoff_Days),0),@Holiday = isnull(sum(Holiday_Days),0) 
								from T0200_MONTHLY_SALARY WITH (NOLOCK) where cmp_id=@Cmp_ID and emp_id=@Emp_ID 
								and Month(month_end_date) = Month(@Temp_For_Date) and Year(month_end_date) = Year(@Temp_For_Date)


								--Hardik 11/04/2013
								Select @Effect_Allow_Amount = Isnull(Sum(E_AD_AMOUNT),0) 
								From T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) Inner Join
									T0050_AD_MASTER AM WITH (NOLOCK) on EED.AD_ID = AM.AD_ID 
								Where AD_EFFECT_ON_BONUS = 1 And EED.Cmp_ID=@Cmp_ID and Emp_id= @Emp_ID 
									And INCREMENT_ID = @Increment_Id
								
								-----Arear Bonus ---Ankit 06072015
								SELECT @Arear_Bonus_Calculated_Amount = isnull(sum(Arear_Basic) ,0) ,@Arear_P_Day = isnull(sum(Arear_Day),0)
								FROM T0200_MONTHLY_SALARY WITH (NOLOCK)
								WHERE cmp_id=@Cmp_ID and emp_id=@Emp_ID and Arear_Month = Month(@Temp_For_Date) and Arear_Year = Year(@Temp_For_Date)
								
								SET @Bonus_Cal_Days = @Sal_Cal_Days
								
								IF @Arear_P_Day > 0
									BEGIN 
										SET @P_Day = @P_Day + @Arear_P_Day
										SET @Bonus_Cal_Days = @Sal_Cal_Days + @Arear_P_Day
									END
								-----Arear Bonus ---
								
								If @Wages_Type = 'Daily'
									Begin
										If @Paid_Weekoff_Daily_Wages = 0
											Begin
												Set @W_Day = @W_Day - @Weekoff
												
												If @W_Day > 0
													Set @Actual_Gross_Salary = (@Bonus_Calculated_Amount * @W_Day)
												Else 
													Set @Bonus_Calculated_Amount = 0
											End
									End
								Else
									Begin
										SET @Actual_Gross_Salary = @Bonus_Calculated_Amount + @Effect_Allow_Amount
									End

								--SET @Bonus_Cal_Days = @Sal_Cal_Days
								
								SET @Bonus_Calculated_Amount = @Bonus_Calculated_Amount + @Effect_Allow_Amount
								
							
								IF @Bonus_Cal_Days > @W_Day
									SET @Bonus_Cal_Days = @W_Day


								If @Max_Bonus_Salary_Amount <= 0  --Hardik 11/04/2013
									Begin
										If @W_Day > 0
											SET @Bonus_Calculated_Amount = ((@Bonus_Calculated_Amount * @Bonus_Cal_Days) / @W_Day)
										Else
											SET @Bonus_Calculated_Amount = 0
									End
								Else
									Begin
										If @W_Day > 0
											Begin
												If @Actual_Gross_Salary >= @Max_Bonus_Salary_Amount 
													SET @Bonus_Calculated_Amount = ((@Max_Bonus_Salary_Amount * @Bonus_Cal_Days) / @W_Day)
												Else
													SET @Bonus_Calculated_Amount = ((@Bonus_Calculated_Amount * @Bonus_Cal_Days) / @W_Day)
											End
										Else
											SET @Bonus_Calculated_Amount = 0
									End									
							
								SET @Bonus_Amount = ((@Bonus_Calculated_Amount * @Bonus_Percentage )/100)
								
								IF @Bonus_Max_Limit > 0 and @Bonus_Amount > @Bonus_Max_Limit
									set @Bonus_Amount = @Bonus_Max_Limit
							END
					ELSE IF @Bonus_Calculated_On ='Allowance'   --Added By Jimit 12082019 For WCL
							BEGIN
									
									select	@Sal_Cal_Days = isnull(sum(Sal_Cal_Days),0)
									from	t0200_MONTHLY_SALARY WITH (NOLOCK)
									where	cmp_id=@Cmp_ID and emp_id=@Emp_ID and Month(month_end_date) = Month(@Temp_For_Date) and Year(month_end_date) = Year(@Temp_For_Date)

									SET		@Bonus_Cal_Days = @Sal_Cal_Days	


									if @Bonus_Cal_Type = 'Regular Bonus' 
										BEGIN
											Select	@Bonus_Calculated_Amount =  Isnull(sum(M_AD_Calculated_Amount),0),
													@Bonus_Amount =  ISNULL(SUM(M_AD_Amount),0)  + ISNULL(SUM(M_AREAR_AMOUNT),0)+ ISNULL(SUM(M_AREAR_AMOUNT_Cutoff),0)
											From	T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) Inner Join
													T0050_AD_MASTER AM WITH (NOLOCK) on MAD.AD_ID = AM.AD_ID 
											Where	MAD.Cmp_ID=@Cmp_ID and Emp_id= @Emp_ID AND AD_DEF_Id = 19
													and Month(for_date) = Month(@Temp_For_Date) and Year(for_date) = Year(@Temp_For_Date)

											
										END

									if @Bonus_Cal_Type = 'Exgratia Bonus'
										BEGIN
											Select	@Monthly_Ex_Gratia_Calculated_Amt =  Isnull(sum(M_AD_Calculated_Amount),0),
													@Monthly_Ex_Gratia_Bonus_Amount =   ISNULL(SUM(M_AD_Amount),0) + ISNULL(SUM(M_AREAR_AMOUNT),0)+ ISNULL(SUM(M_AREAR_AMOUNT_Cutoff),0) + ISNULL(@Monthly_Ex_Gratia_Bonus_Amount,0)
											From	T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) Inner Join
													T0050_AD_MASTER AM WITH (NOLOCK) on MAD.AD_ID = AM.AD_ID 
											Where	MAD.Cmp_ID=@Cmp_ID and Emp_id= @Emp_ID AND AD_DEF_Id = 32
													and Month(for_date) = Month(@Temp_For_Date) and Year(for_date) = Year(@Temp_For_Date)
										END
									
									

							END
					ELSE
						BEGIN
							SET @Bonus_Calculated_Amount = 0
							SET @Bonus_Amount = @Bonus_Fix_Amount

							-- Added by rohit For bonus Calculate on Fix Amount on 26062013
							select @Bonus_Tran_ID = Isnull(max(Bonus_Tran_ID),0) + 1 From T0190_BONUS_DETAIL WITH (NOLOCK)

							INSERT INTO T0190_BONUS_DETAIL
							(Bonus_Tran_ID, Bonus_ID, Cmp_ID, Bonus_Calculated_Amount, Bonus_Amount,Month_Date, Present_Days, Working_Days)
							VALUES     
							(@Bonus_Tran_ID, @Bonus_ID, @Cmp_ID, @Bonus_Calculated_Amount, @Bonus_Amount,@Temp_For_Date,@Bonus_Cal_Days,@W_Day)
							
							Break
							-- Ended by rohit For bonus Calculate on Fix Amount on 26062013
						END


					select @Bonus_Tran_ID = Isnull(max(Bonus_Tran_ID),0) + 1 From T0190_BONUS_DETAIL WITH (NOLOCK)
					
					INSERT INTO T0190_BONUS_DETAIL
						(Bonus_Tran_ID, Bonus_ID, Cmp_ID, Bonus_Calculated_Amount, Bonus_Amount,Month_Date, Present_Days, Working_Days, Monthly_Ex_Gratia_Calculated_Amt)
					VALUES     
						(@Bonus_Tran_ID, @Bonus_ID, @Cmp_ID, @Bonus_Calculated_Amount, @Bonus_Amount,@Temp_For_Date,@Bonus_Cal_Days,@W_Day, @Monthly_Ex_Gratia_Calculated_Amt)


				Set @Temp_For_Date = dateadd(m,1,@Temp_For_Date)
			End
					SET @Bonus_Cal_Days = 0
					
					Select @Bonus_Calculated_Amount = Isnull(SUM(Bonus_Calculated_Amount),0),
							 @Bonus_Amount = Isnull(SUM(Bonus_Amount),0),
							@Ex_Gratia_Calculated_Amount = ISNULL(Sum(Monthly_Ex_Gratia_Calculated_Amt),0),
						@Bonus_Cal_Days = SUM(Present_Days)
					From T0190_BONUS_DETAIL WITH (NOLOCK)
					Where Bonus_ID = @Bonus_ID And Month_Date >= @From_Date And Month_Date <= @To_Date
					
					IF @Bonus_Cal_Days < 30  And Datediff(DAY,@From_Date,@To_Date)>31 -- [ PRESENT DAYS < 30 IN AN YEAR , THEN BONUS AMOUNT SHOULD BE ZERO --Nirma Client --Ankit 21062016 ]  --- Datediff Condition added by Hardik 26/06/2017 as for Monthly Calculation for Bonus is getting Zero, Client : Centurion 
						BEGIN
							SET @Bonus_Amount = 0
							SET @Ex_Gratia_Calculated_Amount = 0
							
							UPDATE T0190_BONUS_DETAIL SET Bonus_Amount = 0 WHERE Bonus_ID = @Bonus_ID And Month_Date >= @From_Date And Month_Date <= @To_Date
							
						END
					
					IF @Bonus_Calculated_On ='Allowance'
					BEGIN
								Update	T0180_BONUS 
								Set		Bonus_Calculated_Amount = @Bonus_Calculated_Amount, 
										Bonus_Amount = @Bonus_Amount,
										Ex_Gratia_Calculated_Amount = @Monthly_Ex_Gratia_Calculated_Amt,
										Ex_Gratia_Bonus_Amount = @Monthly_Ex_Gratia_Bonus_Amount
										,Net_Payable_Bonus = isnull(@Bonus_Amount,0) + isnull(Round(@Monthly_Ex_Gratia_Calculated_Amt * @Bonus_Percentage /100,0),0)
								Where	Cmp_Id = @Cmp_ID And Emp_Id = @Emp_ID And Bonus_Id = @Bonus_ID
														
					END
					ELSE
						BEGIN
								Update	T0180_BONUS Set Bonus_Calculated_Amount = @Bonus_Calculated_Amount, 
										Bonus_Amount = @Bonus_Amount,
										--	Bonus_Amount = Round(@Bonus_Calculated_Amount * @Bonus_Percentage / 100,0), 
										Ex_Gratia_Calculated_Amount = @Ex_Gratia_Calculated_Amount,
										Ex_Gratia_Bonus_Amount = Round(@Ex_Gratia_Calculated_Amount * @Bonus_Percentage /100,0)
										,Net_Payable_Bonus = isnull(@Bonus_Amount,0) + isnull(Round(@Ex_Gratia_Calculated_Amount * @Bonus_Percentage /100,0),0) -- added by rohit on 18052016
								Where	Cmp_Id = @Cmp_ID And Emp_Id = @Emp_ID And Bonus_Id = @Bonus_ID
						END
										-- Added for audit trail By Ali 18102013 - Start
										
											Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID)
										
											set @OldValue = 'New Value' 
															+ '#' + 'Employee Name : ' + ISNULL(@Old_Emp_Name,'')
															+ '#' + 'Fix Amount : ' + CONVERT(nvarchar(100),ISNULL(@Bonus_Fix_Amount,0))
															+ '#' + 'Effect On Salary : ' + CASE ISNULL(@Bonus_Effect_on_Sal,0) WHEN 0 THEN 'NO' ELSE 'YES' END
															+ '#' + 'Bonus Percentage : ' + CONVERT(nvarchar(100),ISNULL(@Bonus_Percentage,0))
															+ '#' + 'Bonus amount : ' + CONVERT(nvarchar(100),ISNULL(@Bonus_Amount,0))
															+ '#' + 'Bonus Calculated amount : ' + CONVERT(nvarchar(100),ISNULL(@Bonus_Calculated_Amount,0))
															+ '#' + 'Effect On Month : ' + CONVERT(nvarchar(100),ISNULL(@Bonus_Effect_Month,0))
															+ '#' + 'Effect On Year : ' + CONVERT(nvarchar(100),ISNULL(@Bonus_Effect_Year,''))
															+ '#' + 'From Date : ' + cast(ISNULL(@From_Date,'') as nvarchar(11))
															+ '#' + 'To Date : ' + cast(ISNULL(@To_Date,'') as nvarchar(11))
																																												
											exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Bonus Detail',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1	
												
										-- Added for audit trail By Ali 18102013 - End

		END
			
	else if @tran_type ='U' 
				begin
				
				If Exists(select Bonus_ID From T0180_BONUS WITH (NOLOCK) Where Cmp_ID = @Cmp_ID  and From_Date = @From_Date AND To_Date=@To_Date and Bonus_ID <> @Bonus_ID )
						begin
							set @Bonus_ID = 0
							return 
					end
								
						UPDATE  T0180_BONUS
						SET        
										From_Date = @From_Date
										,To_Date = @To_Date
										,Bonus_Calculated_On = @Bonus_Calculated_On
										,Bonus_Percentage = @Bonus_Percentage
										,Bonus_Amount = @Bonus_Amount
										,Bonus_Fix_Amount = @Bonus_Fix_Amount
										,Bonus_Effect_on_Sal = @Bonus_Effect_on_Sal
										,Bonus_Effect_Month = @Bonus_Effect_Month 
										,Bonus_Effect_Year = @Bonus_Effect_Year
										,Bonus_Comments = @Bonus_Comments
										,Is_FNF =@Is_FNF
				         where Bonus_ID = @Bonus_ID and CMP_ID = @CMP_ID and EMP_ID =@EMP_ID	
				                      
				                      
				end
	else if @tran_type ='D'
		Begin
				DELETE FROM T0190_BONUS_DETAIL where Bonus_ID = @Bonus_ID 
				
				if not exists(select Bonus_ID  from T0190_BONUS_DETAIL WITH (NOLOCK) Where Bonus_ID = @Bonus_ID )
				 begin
				 
										-- Added for audit trail By Ali 18102013 - Start
											
											Select 
											@Old_Emp_Id = Emp_ID,
											@Old_Bonus_Fix_Amount = Bonus_Fix_Amount,
											@Old_Bonus_Effect_on_Sal = Bonus_Effect_on_Sal,
											@Old_Bonus_Percentage = Bonus_Percentage,
											@Old_Bonus_Amount = Bonus_Amount,
											@Old_Bonus_Calculated_Amount = Bonus_Calculated_Amount,
											@Old_Bonus_Effect_Month = Bonus_Effect_Month,
											@Old_Bonus_Effect_Year = Bonus_Effect_Year,
											@Old_From_Date = From_Date,
											@Old_To_Date = To_Date											
											From T0180_BONUS WITH (NOLOCK)
											where Bonus_ID = @Bonus_ID
											
											Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Old_Emp_Id)
										
											set @OldValue = 'old Value' 
															+ '#' + 'Employee Name : ' + ISNULL(@Old_Emp_Name,'')
															+ '#' + 'Fix Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Bonus_Fix_Amount,0))
															+ '#' + 'Effect On Salary : ' + CASE ISNULL(@Old_Bonus_Effect_on_Sal,0) WHEN 0 THEN 'NO' ELSE 'YES' END
															+ '#' + 'Bonus Percentage : ' + CONVERT(nvarchar(100),ISNULL(@Old_Bonus_Percentage,0))
															+ '#' + 'Bonus amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Bonus_Amount,0))
															+ '#' + 'Bonus Calculated amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Bonus_Calculated_Amount,0))
															+ '#' + 'Effect On Month : ' + CONVERT(nvarchar(100),ISNULL(@Old_Bonus_Effect_Month,0))
															+ '#' + 'Effect On Year : ' + CONVERT(nvarchar(100),ISNULL(@Old_Bonus_Effect_Year,''))
															+ '#' + 'From Date : ' + cast(ISNULL(@Old_From_Date,'') as nvarchar(11))
															+ '#' + 'To Date : ' + cast(ISNULL(@Old_To_Date,'') as nvarchar(11))
																																												
											exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Bonus Detail',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1	
												
										-- Added for audit trail By Ali 18102013 - End
						DELETE FROM T0180_BONUS where Bonus_ID = @Bonus_ID
				 End 
		End
