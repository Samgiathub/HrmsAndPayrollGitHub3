
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_IT_TAX_ALLOW_DEDU_CALCULATION_ALL]
	@cmp_ID					Numeric ,
	@Increment_ID			Numeric ,
	@From_Date				DateTime,
	@To_Date				DateTime ,
	@Month_Diff				TinyInt,
	@Month_Date				DateTime	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF OBJECT_ID('tempdb..#Emp_Cons') IS NOT NULL
		CREATE table #Emp_Cons 
		(      
			Emp_ID numeric ,     
			Branch_ID numeric,
			Increment_ID numeric    
		)     

	DECLARE @Left_date		DateTime
	DECLARE @join_date		DateTime
	DECLARE @Cont_Basic_Sal TinyInt
	DECLARE @Cont_PT_Amount TinyInt 
	SET @Cont_Basic_Sal =1
	SET @Cont_PT_Amount =10

	CREATE TABLE #EMP_TAX
	(
		EMP_ID			INT,
		Increment_ID	INT,
		EMP_LEFT_DATE	DateTime,
		Date_of_Join	DateTime,
		Branch_ID		INT,
		Basic_Salary	Numeric(18,2),
		Gross_Salary_ProRata	Numeric(18,2),
		CTC_ProRata				Numeric(18,2),
		Emp_Full_Pf		TinyInt,
		Emp_PT			TinyInt,
		Wages_type		TinyInt,
	)

	INSERT INTO #EMP_TAX (EMP_ID, Increment_ID, Branch_ID)
	SELECT  EMP_ID, Increment_ID, Branch_ID FROM #EMP_CONS 


	UPDATE	T
	SET		EMP_LEFT_DATE = IsNull(E.Emp_Left_Date,@To_date),
			Date_of_Join = E.Date_Of_Join,
			Basic_Salary = I.Basic_Salary , Emp_Full_Pf = I.Emp_Full_Pf,
			Emp_PT = I.Emp_PT,Gross_Salary_ProRata = I.Gross_Salary , 
			Wages_type= I.Wages_type,CTC_ProRata = I.CTC -- added by rohit on 20052017
	FROM	#EMP_TAX  T
			INNER JOIN T0080_EMP_MASTER E ON T.EMP_ID=E.Emp_ID
			INNER JOIN T0095_INCREMENT I ON T.Increment_ID=I.Increment_ID AND T.EMP_ID=I.Emp_ID

	--SELECT  @Left_date = IsNull(Emp_Left_Date,@To_date) ,@join_date = Date_Of_Join  
	--FROM	T0080_emp_Master 
	--WHERE	Emp_ID = @Emp_ID 


	
	DECLARE @AD_DEF_ID  NUMERIC  
	DECLARE @IT_DEF_ID	NUMERIC
	DECLARE @PF_DEF_ID	NUMERIC 
	DECLARE @ESIC_DEF_ID	NUMERIC 
		
	SET  @IT_DEF_ID = 1
	SET  @PF_DEF_ID = 2
	SET  @ESIC_DEF_ID = 3
	
	IF IsNull(@Month_Date,'')=''
		SET @Month_Date =@To_Date



	-- Added by rohit on 11052015

	DECLARE @It_Estimated_SETting as TinyInt
	SET @It_Estimated_SETting=0
	SELECT @It_Estimated_SETting = isnull(SETting_Value,0) from T0040_SETTING WITH (NOLOCK) where SETting_Name ='Enable Import Option for Estimated Amount' and Cmp_ID=@cmp_ID
	DECLARE @It_Estimated_Amount as Numeric(18,2)
	SET @It_Estimated_Amount = 0

	DECLARE @SETting_Reim as TinyInt
	SET @SETting_Reim =0
	SELECT @SETting_Reim = isnull(SETting_Value,0)  from T0040_SETTING WITH (NOLOCK) where SETting_Name ='Reimbershment Shows in IT Computation' and Cmp_ID= @cmp_id
				


	-- Ended by rohit on 11052015	

		 
	DECLARE @AD_ID						numeric
	DECLARE @M_AD_Percentage			numeric(12,5)
	DECLARE @M_AD_Amount				numeric(12,5)
	DECLARE @M_AD_Flag					varchar(1)
	DECLARE @Max_Upper					numeric(27,5)
	DECLARE @varCalc_On					varchar(50)
	DECLARE @Calc_On_Allow_Dedu			numeric(18,2) 
	DECLARE @Other_Allow_Amount			numeric(18,2)
	DECLARE @M_AD_Actual_Per_Amount		numeric(18,5)
	DECLARE @Temp_Percentage			numeric(18,5)
	DECLARE @Type						varchar(20)
	DECLARE @M_AD_Tran_ID				numeric
	DECLARE @Wages_type					varchar(10)
	DECLARE @Basic_Salary				Numeric(25,5)
	DECLARE @Gross_Salary_ProRata		Numeric(25,5)
	DECLARE @CTC_ProRata				Numeric(25,5)
	DECLARE @M_AD_NOT_EFFECT_ON_PT		TinyInt
	DECLARE @M_AD_NOT_EFFECT_SALARY		TinyInt
	DECLARE @M_AD_EFFECT_ON_OT			TinyInt 
	DECLARE @M_AD_EFFECT_ON_EXTRA_DAY	TinyInt
	DECLARE @AD_Name					varchar(20)
	DECLARE @M_AD_effect_on_Late		TinyInt
	DECLARE @Emp_Full_Pf				TinyInt
	DECLARE @Emp_PT						TinyInt
	DECLARE @PF_Limit					int
	DECLARE @old_M_AD_Amount			numeric 
	DECLARE @Branch_ID					numeric 
	DECLARE @ESIC_Limit					int
	DECLARE @PT_Calculated_Amount		numeric
	DECLARE @old_PT_Amount				int
	DECLARE @old_Salary_Amount			numeric	
	DECLARE @PT_Amount					int 
	DECLARE @AD_Effect_On_TDs			Int
	DECLARE @temp_month_diff		numeric
	DECLARE @cur_increment_id numeric
	DECLARE @AD_CAL_TYPE as varchar(10)
	DECLARE @Is_Round					TinyInt
	DECLARE @Is_Calculated_On_Imported_Value int
	DECLARE @Not_display_auto_credit_amount_IT int  -- Added by rohit on 09032016
	
	DECLARE @AD_Level_Temp		NUMERIC(18,0)	--Ankit 02052015
	SET @AD_Level_Temp = 0
	
	SET @temp_month_diff	 = @Month_Diff
	SET @old_PT_Amount			=0
	SET @old_Salary_Amount	=0
	SET @PT_Amount =0
	SET @PT_Calculated_Amount = 0
	SET @Calc_On_Allow_Dedu = 0.0
	SET @varCalc_On = ''
	SET @Other_Allow_Amount = 0
	SET @Calc_On_Allow_Dedu = 0.0
	SET @varCalc_On = ''
	SET @cur_increment_id = 0
	SET @M_AD_Actual_Per_Amount = 0.0
	SET @PF_Limit =0
	SET @Esic_Limit =0
	SET @Is_Round = 0
	SET @Is_Calculated_On_Imported_Value = 0
	SET @Not_display_auto_credit_amount_IT = 0
	
	

	-- Added by rohit on 08-apr-2014
	SET @Wages_Type=''
	DECLARE @Day_Count as numeric(18,2)
	SET @Day_Count = 26
	-- Ended by rohit on 08-apr-2014	
	
	

	--SELECT	@Basic_Salary = Basic_Salary , @Emp_Full_Pf = Emp_Full_Pf,
	--		@Emp_PT = Emp_PT,@Gross_Salary_ProRata = Gross_Salary , @Branch_ID =Branch_ID,
	--		@Wages_Type=Wages_type,@CTC_ProRata = CTC -- added by rohit on 20052017
	--From	T0095_Increment where Emp_ID =@Emp_ID and Increment_ID =@Increment_ID 

	UPDATE	#EMP_TAX
	SET		Basic_Salary = Basic_Salary  * @Day_Count,
			Gross_Salary_ProRata  = Gross_Salary_ProRata * @Day_Count,
			CTC_ProRata = CTC_ProRata * @Day_Count
	Where	Wages_type = 'Daily'
	
	--IF @Wages_Type='Daily' -- Added by rohit on 08-apr-2014	
	--	BEGIN
	--		SET @Basic_Salary = (@Basic_Salary * @Day_Count)
	--		SET @Gross_Salary_ProRata = (@Gross_Salary_ProRata * @Day_Count)
	--		SET @CTC_ProRata = (@CTC_ProRata * @Day_Count)
	--	END

	SELECT DISTINCT BRANCH_ID INTO #BRANCH FROM #Emp_Cons

	
	
	SELECT	PF_Limit = isnull(PF_Limit,0),ESIC_Limit = ESIC_Upper_Limit, Is_Round = isnull(g.AD_Rounding,0)
	FROM	T0040_GENERAL_SETTING g WITH (NOLOCK)
			INNER JOIN T0050_General_Detail gd WITH (NOLOCK) on g.Gen_ID = Gd.gen_ID
			INNER JOIN (SELECT MAX(GEN_ID) AS GEN_ID, G1.BRANCH_ID	
						FROM	T0040_GENERAL_SETTING G1 WITH (NOLOCK)
								INNER JOIN (SELECT	MAX(G2.FOR_DATE) AS FOR_DATE, G2.BRANCH_ID
											FROM	T0040_GENERAL_SETTING G2 WITH (NOLOCK)
													INNER JOIN #BRANCH B ON G2.Branch_ID=B.Branch_ID
											WHERE	G2.For_Date <= @To_Date
											Group BY G2.BRANCH_ID) G2 ON G1.Branch_ID=G2.Branch_ID
								INNER JOIN #BRANCH B ON G1.Branch_ID=B.Branch_ID
						GROUP BY G1.Branch_ID) G1 ON G.Branch_ID=G1.Branch_ID AND G.Gen_ID=G1.GEN_ID

								

	--SELECT @PF_Limit = isnull(PF_Limit,0)  ,@ESIC_Limit	 = ESIC_Upper_Limit, @Is_Round = isnull(g.AD_Rounding,0)
	--FROM	T0040_GENERAL_SETTING g 
	--		INNER JOIN T0050_General_Detail gd on g.Gen_ID = Gd.gen_ID
	--WHERE	g.cmp_ID = @cmp_ID	and Branch_ID = @Branch_ID
	--	and For_Date = ( SELECT max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)

	--IF @PF_Limit =0	
	 --SET @PF_Limit =6500

	SELECT EMP_ID, AD_ID INTO #SALARY_EXISTS
	FROM	(
				SELECT	DISTINCT MS.Emp_ID, AD_ID 
				FROM	T0210_MONTHLY_AD_DETAIL MS WITH (NOLOCK)
						INNER JOIN #Emp_Cons EC ON MS.Emp_ID=EC.Emp_ID
				where	To_date >= @From_Date AND To_date <= @To_Date
				UNION 
				SELECT	EC.EMP_ID, AM.AD_ID 
				From	T0050_AD_MASTER AM WITH (NOLOCK)
						CROSS JOIN #Emp_Cons EC 
				Where	Isnull(Is_Calculated_On_Imported_Value,0) =1 And CMP_ID = @Cmp_Id
			) T
	
	/*Employee Having Salary Between Dates*/
	SELECT	*
	INTO	#TAX_AD
	FROM	(
				SELECT EED.EMP_ID, EED.AD_ID,
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
						dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID   LEFT OUTER JOIN
						( SELECT EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID
							From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
							( SELECT	Max(For_Date) For_Date, Ad_Id 
								From	T0110_EMP_Earn_Deduction_Revised  EDR WITH (NOLOCK)
										INNER JOIN #Emp_Cons EC ON EC.Emp_ID=EDR.EMP_ID
								Where	For_Date <= @To_Date
								Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
						) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID AND EED.FOR_DATE <= Qry1.FOR_DATE 
						INNER JOIN #SALARY_EXISTS T On EED.AD_ID = T.AD_ID and EED.EMP_ID=T.Emp_ID
				WHERE	Adm.AD_ACTIVE = 1 
						and EED.INCREMENT_ID = @Increment_ID --Added by Nilesh on 31012017 For Aculife  
						AND Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
						/* and eed.AD_ID in (SELECT distinct ad_id from T0210_MONTHLY_AD_DETAIL where Emp_ID = @Emp_Id and to_date >= @From_Date AND To_date <= @To_Date
											UNION ALL
											SELECT AD_ID From T0050_AD_MASTER Where Isnull(Is_Calculated_On_Imported_Value,0) =1 And CMP_ID = @Cmp_Id)
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
						( SELECT Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
							Where --Emp_Id  = @Emp_Id  and 
									For_Date <= @To_Date
							Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
						INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID                     
						INNER JOIN #TMP_AD T On EED.AD_ID = T.AD_ID 
					WHERE	--emp_id = @emp_id And 
							Adm.AD_ACTIVE = 1
							and EED.INCREMENT_ID = @Increment_ID --Added by Nilesh on 31012017 For Aculife  
							AND EEd.ENTRY_TYPE = 'A'
							/* AND eed.AD_ID in (SELECT distinct ad_id from T0210_MONTHLY_AD_DETAIL where Emp_ID = @Emp_Id and to_date >= @From_Date AND To_date <= @To_Date
												UNION ALL
												SELECT AD_ID From T0050_AD_MASTER Where Isnull(Is_Calculated_On_Imported_Value,0) =1 And CMP_ID = @Cmp_Id)
							*/
					) Qry
					ORDER BY AD_LEVEL, E_AD_Flag, INCREMENT_ID  DESC

		/*Employee NOT Having Salary Between Dates*/

		INSERT INTO #TAX_AD
		SELECT	*
		FROM	(
				SELECT EED.EMP_ID, EED.AD_ID,
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
					   dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID   LEFT OUTER JOIN
						( SELECT EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID
							From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
							( SELECT Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
								Where --Emp_Id = @Emp_Id  and 
									For_Date <= @To_Date
							 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
						) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID AND EED.FOR_DATE <= Qry1.FOR_DATE
				WHERE Adm.AD_ACTIVE = 1
					    and EED.INCREMENT_ID = @Increment_ID --Added by Nilesh on 31012017 For Aculife  
						AND (Case When Qry1.E_Ad_Amount IS NULL Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End > 0 or FOR_FNF = 1 OR AD_Calculate_On = 'Import') 
						AND Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
						AND NOT EXISTS(SELECT 1 FROM #SALARY_EXISTS SE WHERE EED.EMP_ID=SE.Emp_ID)
						
				UNION ALL
				
				SELECT EED.AD_ID,E_AD_Percentage,E_AD_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,ISNULL(ADM.Allowance_Type,'A') AS Allowance_Type, AD_DEF_ID ,                    
					ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,
					ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY,
					AD_Name,ISNULL(AD_effect_on_Late,0) AS AD_effect_on_Late ,ISNULL(Ad_Effect_On_TDS,0) AS Ad_Effect_On_TDS,
					0 AS INCREMENT_ID,0 AS It_Estimated_Amount,
					ADM.AD_LEVEL,Is_Calculated_On_Imported_Value
					,Not_display_auto_credit_amount_IT  
				FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
					( SELECT	Max(For_Date) For_Date, Ad_Id 
						From	T0110_EMP_Earn_Deduction_Revised  WITH (NOLOCK)
						Where --Emp_Id  = @Emp_Id  and 
							For_Date <= @To_Date
						Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
				   INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID                     
				WHERE Adm.AD_ACTIVE = 1
						and EED.INCREMENT_ID = @Increment_ID --Added by Nilesh on 31012017 For Aculife  
						and (EED.E_AD_AMOUNT > 0 or FOR_FNF = 1 OR AD_Calculate_On = 'Import') 
						And EEd.ENTRY_TYPE = 'A'
						AND NOT EXISTS(SELECT 1 FROM #SALARY_EXISTS SE WHERE EED.EMP_ID=SE.Emp_ID)
						
				) Qry
		ORDER BY AD_LEVEL, E_AD_Flag, INCREMENT_ID  DESC


	Insert into #Salary_AD (Emp_Id,AD_ID,For_Date,Cmp_ID,M_AD_Amount,Month_Count,Old_M_AD_Amount,AD_NOT_EFFECT_ON_PT,AD_NOT_EFFECT_ON_SAL,Ad_Effect_On_TDS,Month_Diff_Amount)
	SELECT	DISTINCT Emp_ID, AD_ID, @From_Date, @cmp_ID, E_Ad_Amount, 0, 0, AD_NOT_EFFECT_ON_PT, AD_NOT_EFFECT_SALARY, Ad_Effect_On_TDS, 0
	FROM	#TAX_AD

	UPDATE	SAD
	SET		M_AD_Amount = M_AD_Amount * @Day_Count
	FROM	#Salary_AD SAD			
			INNER JOIN #EMP_TAX ET ON SAD.EMP_ID=ET.EMP_ID			
	WHERE	ET.Wages_type ='Daily'

	CREATE TABLE #TEMP_AD_SALADY
	(
		Emp_ID				INT,
		AD_CALC_ON			Varchar(64),
		AD_CALC_ON_AMOUNT	NUMERIC(18,4),
		M_AD_Actual_Per_Amount	NUMERIC(18,4),
	)

	INSERT INTO #TEMP_AD_SALADY(EMP_ID, AD_CALC_ON, AD_CALC_ON_AMOUNT)
	SELECT	TAD.EMP_ID, AD.AD_CALCULATE_ON, 
			CASE AD.AD_CALCULATE_ON 
				WHEN 'Actual Gross' THEN ET.Gross_Salary_ProRata
				WHEN 'Basic Salary' THEN ET.Basic_Salary
				WHEN 'CTC' THEN ET.CTC_ProRata
				ELSE ET.Basic_Salary
			END
	FROM	(SELECT DISTINCT EMP_ID, AD_ID FROM #TAX_AD ) TAD 
			INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON TAD.AD_ID=AD.AD_ID
			INNER JOIN #EMP_TAX ET ON TAD.EMP_ID=ET.EMP_ID

	--UPDATE	SAL
	--SET		M_AD_Actual_Per_Amount
	--FROM	#TEMP_AD_SALADY SAL
	--		INNER JOIN #EMP_TAX ET ON SAL.EMP_ID=ET.EMP_ID AND SAL.AD

		/*
		IF EXISTS(SELECT distinct 1 from T0210_MONTHLY_AD_DETAIL where Emp_ID = @Emp_Id and to_date >= @From_Date AND To_date <= @To_Date) 	
			BEGIN
				-- Added below code by Hardik, Nimesh 13/07/2018 as Import_Calc_Value allowances are not coming in Cursor Query, for Kivilabs (HMP)
				SELECT AD_ID INTO #TMP_AD
				FROM	(
							SELECT distinct ad_id from T0210_MONTHLY_AD_DETAIL where Emp_ID = @Emp_Id and to_date >= @From_Date AND To_date <= @To_Date
							UNION 
							SELECT AD_ID From T0050_AD_MASTER Where Isnull(Is_Calculated_On_Imported_Value,0) =1 And CMP_ID = @Cmp_Id
						) T

				DECLARE curAD cursor FOR
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
						,ADM.Not_display_auto_credit_amount_IT  
					FROM dbo.T0100_EMP_EARN_DEDUCTION EED INNER JOIN                    
						   dbo.T0050_AD_MASTER ADM  ON EEd.AD_ID = ADM.AD_ID   LEFT OUTER JOIN
							( SELECT EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID
								From T0110_EMP_Earn_Deduction_Revised EEDR INNER JOIN
								( SELECT Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
									Where Emp_Id = @Emp_Id and For_Date <= @To_Date
								 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
							) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID AND EED.FOR_DATE <= Qry1.FOR_DATE 
							INNER JOIN #TMP_AD T On EED.AD_ID = T.AD_ID          
					WHERE EED.EMP_ID = @emp_id And Adm.AD_ACTIVE = 1 
							and EED.INCREMENT_ID = @Increment_ID --Added by Nilesh on 31012017 For Aculife  
							AND Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
							/* and eed.AD_ID in (SELECT distinct ad_id from T0210_MONTHLY_AD_DETAIL where Emp_ID = @Emp_Id and to_date >= @From_Date AND To_date <= @To_Date
												UNION ALL
												SELECT AD_ID From T0050_AD_MASTER Where Isnull(Is_Calculated_On_Imported_Value,0) =1 And CMP_ID = @Cmp_Id)
							*/
					UNION ALL
					
					SELECT EED.AD_ID,E_AD_Percentage,E_AD_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,ISNULL(ADM.Allowance_Type,'A') AS Allowance_Type, AD_DEF_ID ,                    
						ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,
						ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY,
						AD_Name,ISNULL(AD_effect_on_Late,0) AS AD_effect_on_Late ,ISNULL(Ad_Effect_On_TDS,0) AS Ad_Effect_On_TDS,
						0 AS INCREMENT_ID,0 AS It_Estimated_Amount,
						ADM.AD_LEVEL,Is_Calculated_On_Imported_Value
						,Not_display_auto_credit_amount_IT  
					FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED INNER JOIN  
						( SELECT Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
							Where Emp_Id  = @Emp_Id  and For_Date <= @To_Date
							Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
					   INNER JOIN dbo.T0050_AD_MASTER ADM  ON EEd.AD_ID = ADM.AD_ID                     
					   INNER JOIN #TMP_AD T On EED.AD_ID = T.AD_ID 
					WHERE emp_id = @emp_id And Adm.AD_ACTIVE = 1
							and EED.INCREMENT_ID = @Increment_ID --Added by Nilesh on 31012017 For Aculife  
							AND EEd.ENTRY_TYPE = 'A'
							/* AND eed.AD_ID in (SELECT distinct ad_id from T0210_MONTHLY_AD_DETAIL where Emp_ID = @Emp_Id and to_date >= @From_Date AND To_date <= @To_Date
												UNION ALL
												SELECT AD_ID From T0050_AD_MASTER Where Isnull(Is_Calculated_On_Imported_Value,0) =1 And CMP_ID = @Cmp_Id)
							*/
					) Qry
					ORDER BY AD_LEVEL, E_AD_Flag, INCREMENT_ID  DESC
			END
		ELSE	
			BEGIN
				
				DECLARE curAD cursor for
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
				FROM dbo.T0100_EMP_EARN_DEDUCTION EED INNER JOIN                    
					   dbo.T0050_AD_MASTER ADM  ON EEd.AD_ID = ADM.AD_ID   LEFT OUTER JOIN
						( SELECT EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID
							From T0110_EMP_Earn_Deduction_Revised EEDR INNER JOIN
							( SELECT Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
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
				FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED INNER JOIN  
					( SELECT Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
						Where Emp_Id  = @Emp_Id  and For_Date <= @To_Date
						Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
				   INNER JOIN dbo.T0050_AD_MASTER ADM  ON EEd.AD_ID = ADM.AD_ID                     
				WHERE emp_id = @emp_id And Adm.AD_ACTIVE = 1
						and EED.INCREMENT_ID = @Increment_ID --Added by Nilesh on 31012017 For Aculife  
						and (EED.E_AD_AMOUNT > 0 or FOR_FNF = 1 OR AD_Calculate_On = 'Import') 
						And EEd.ENTRY_TYPE = 'A'
						
				) Qry
				ORDER BY AD_LEVEL, E_AD_Flag, INCREMENT_ID  DESC
				
			END 
		*/
	open curAD		
		fetch next from curAD into @AD_ID,@M_AD_Percentage,@M_AD_Amount,@M_AD_Flag,@Max_Upper,@varCalc_On,@AD_CAL_TYPE,@AD_DEF_ID,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY ,@AD_Name,@M_AD_effect_on_Late,@AD_Effect_On_TDs,@cur_increment_id,@It_Estimated_Amount,@AD_Level_Temp,@Is_Calculated_On_Imported_Value,@Not_display_auto_credit_amount_IT
		while @@fetch_status = 0
			Begin
			
			
			
		--IF @Wages_Type='Daily' -- Added by rohit on 08-apr-2014	
		--	BEGIN
		--		SET @M_AD_Amount = ( @M_AD_Amount * @Day_Count )
		--	END
		
		
				IF @cur_increment_id = @Increment_Id
					begin
					
						--IF @varCalc_On ='Actual Gross'	
						--	SET @Calc_On_Allow_Dedu = @Gross_Salary_ProRata
						--Else IF @varCalc_On ='Basic Salary'	
						--	SET @Calc_On_Allow_Dedu = @Basic_Salary
						--Else IF @varCalc_On ='CTC'	
						--	SET @Calc_On_Allow_Dedu = @CTC_ProRata	
						--Else 
						--	SET @Calc_On_Allow_Dedu = @Basic_Salary


						IF @M_AD_Percentage > 0 
							SET @M_AD_Actual_Per_Amount = @M_AD_Percentage
						else
							SET @M_AD_Actual_Per_Amount = @M_AD_Amount


						SET @Other_Allow_Amount = 0

						SELECT @Other_Allow_Amount = sum(Isnull(M_AD_amount,0))  from #Salary_AD
						where Cmp_ID = @Cmp_ID --and Emp_ID = @Emp_ID 
						and For_Date >=@From_Date and For_Date <=@To_Date --and Ad_effect_on_TDS = 1
						and AD_ID in (SELECT AD_ID  from T0060_EFFECT_AD_MASTER  WITH (NOLOCK)
								Where Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID)

					

						SET @Calc_On_Allow_Dedu = isnull(@Calc_On_Allow_Dedu,0) + isnull(@Other_Allow_Amount ,0)

						IF @M_AD_Flag = 'I'
							begin
							
								IF  @M_AD_Percentage > 0
										begin
											IF round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0) > @Max_Upper and @Max_Upper > 0
												begin
														SET @M_AD_Amount = @Max_Upper	
												end	
											else		
												begin
												
														--SET @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)	
													IF @Is_Round = 1
														Begin 
															SET @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)																											
														End
													else
														Begin
															SET @M_AD_Amount = (@Calc_On_Allow_Dedu * @M_AD_Percentage / 100)
														End
														
												end
										end	
								Else
									begin
										SET @M_AD_Amount =  @M_AD_Amount 
									end
							end
						else	---- Start Deduction 
									begin
										IF  @M_AD_Percentage > 0
											Begin
													IF @PF_DEF_ID = @AD_DEF_ID
														Begin	
															IF  @Emp_Full_PF = 0 and @PF_LIMIT > 0 and @Calc_On_Allow_Dedu > @PF_LIMIT 
																SET @Calc_On_Allow_Dedu = @PF_Limit
																
															
															SET @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)
															
															DECLARE @PF_Arrear Numeric(18,4)
															SET @PF_Arrear = 0
															
															SELECT @PF_Arrear = SUM(Isnull(MAD.M_AD_Amount,0)) FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
															INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK)
															ON MAD.AD_ID = AD.AD_ID  Where --EMP_ID = @Emp_Id and 
																	AD.AD_DEF_ID = 2 and AD.AD_CALCULATE_ON='Import'
															and MAD.For_Date >=@From_Date and MAD.For_Date <=@To_Date
																
														End
													else IF @ESIC_DEF_ID = @AD_DEF_ID
														BEGIN
														--	IF @Calc_On_Allow_Dedu > @ESIC_LIMIT AND @ESIC_LIMIT > 0 
														--		SET @M_AD_Amount = 0
														--	ELSE
																SET @M_AD_Amount = Ceiling((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100))
														END
													else IF round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0) > @Max_Upper and @Max_Upper > 0
														begin
															SET @M_AD_Amount = @Max_Upper	
														end 	
													Else
														begin
														
															SET @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)	
														end
											End	
										Else
											begin
													--SET @M_AD_Amount =  @M_AD_Amount
												IF @Is_Round = 1
													Begin 
														--SET @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)	
														SET @M_AD_Amount = round(@M_AD_Amount,0) -- Added by rohit on 15052015																										
													End
												else
													Begin
													--	SET @M_AD_Amount = (@Calc_On_Allow_Dedu * @M_AD_Percentage / 100)
													SET @M_AD_Amount = @M_AD_Amount -- Added by rohit on 15052015
													End	
											End	
									End
					end

				--Else
				--	Begin
				--		SET @M_AD_Amount = 0
				--		SET @M_Ad_Percentage = 0
				--	end 	

					--SET @M_AD_Amount = ROUND(@M_AD_Amount,0)
					
					IF @Is_Round = 1
						Begin
							SET @M_AD_Amount = ROUND(@M_AD_Amount,0)
						End
					Else
						Begin
							SET @M_AD_Amount = @M_AD_Amount
						End
						
					SET @old_M_AD_Amount = 0 
					
										
				-- commented by rohit due to inductotherm case
					--SELECT @old_M_AD_Amount = sum(Isnull(M_AD_Amount,0)) + sum(isnull(M_AREAR_AMOUNT,0)) 
					--From T0210_Monthly_AD_Detail where Emp_ID =@Emp_ID and AD_ID =@AD_ID 
					--	and To_Date >=@From_Date and To_Date <=@Month_Date
						--and For_FNF = 0 --Comment by Ankit Due to FNF Allowance amount not calculate in tax report (WCL Email Date - Wed, Jun 1, 2016 at 2:36 PM)
						
						--- Condition added by Hardik 27/12/2017 for Havmor, Bonus case
						IF EXISTS(SELECT 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) Where --Emp_ID=@Emp_Id And 
								Month_St_Date >= @From_Date And Month_End_Date <= @Month_Date And Is_FNF=1) AND
							EXISTS(SELECT 1 From T0050_AD_MASTER WITH (NOLOCK) where CMP_ID=@Cmp_Id And AD_ID = @AD_Id And Allowance_Type='A' And AD_NOT_EFFECT_SALARY=1)
								BEGIN
									SELECT @old_M_AD_Amount = sum(Isnull(M_AD_Amount,0)) + sum(isnull(M_AREAR_AMOUNT,0)) + Isnull(@PF_Arrear,0)
									FROM T0210_Monthly_AD_Detail MAD WITH (NOLOCK) left join 
									   T0050_AD_MASTER Am WITH (NOLOCK) on mad.AD_ID=Am.ad_id   where ---Emp_ID =@Emp_ID and 
									   mad.AD_ID =@AD_ID 
									and To_Date >=@From_Date and To_Date <=@Month_Date
									and Am.allowance_type='A' And AM.AD_NOT_EFFECT_SALARY=1 And Isnull(MAD.FOR_FNF,0)=1
								END
							ELSE
								BEGIN
									SELECT @old_M_AD_Amount = sum(Isnull(M_AD_Amount,0)) + sum(isnull(M_AREAR_AMOUNT,0)) + Isnull(@PF_Arrear,0)
									FROM T0210_Monthly_AD_Detail MAD WITH (NOLOCK) left join T0050_AD_MASTER Am WITH (NOLOCK) on mad.AD_ID=Am.ad_id   
									where --Emp_ID =@Emp_ID and 
									mad.AD_ID =@AD_ID 
									and To_Date >=@From_Date and To_Date <=@Month_Date
									and 1=(case when am.Allowance_Type='R' and mad.for_fnf=0 then 1 when Am.allowance_type='A' then 1 else 0 end)
									--and For_FNF = 0 --Comment by Ankit Due to FNF Allowance amount not calculate in tax report (WCL Email Date - Wed, Jun 1, 2016 at 2:36 PM)

									SELECT @old_M_AD_Amount = Case when Am.Allowance_Type='R' Then SUM(Isnull(Qry.M_AD_Amount,MAD.M_AD_Amount)) Else SUM(Isnull(MAD.M_AD_Amount,0)) END + sum(isnull(M_AREAR_AMOUNT,0)) + Isnull(@PF_Arrear,0)
									FROM T0210_Monthly_AD_Detail mad WITH (NOLOCK) inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on mad.Sal_Tran_ID=ms.Sal_Tran_ID
										Left outer JOIN(
														SELECT ma.Sal_Tran_ID,ma.Emp_ID,Sum(ma.M_AD_Amount) As M_AD_Amount , MA.AD_ID 
														FROM T0210_Monthly_AD_Detail ma WITH (NOLOCK) inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on ma.Sal_Tran_ID=ms.Sal_Tran_ID
														WHERE --ma.Emp_ID=@Emp_ID And 
															AD_Id=@AD_ID 
															and For_Date BETWEEN @From_Date and @Month_Date And MS.Is_FNF=1 And ma.M_AD_NOT_EFFECT_SALARY=0
														Group by ma.Sal_Tran_ID,ma.Emp_ID,MA.AD_ID)Qry 
											ON Mad.Sal_Tran_ID=qry.sal_tran_id and mad.Emp_ID=qry.emp_id And MAD.AD_ID=Qry.AD_ID
										left join T0050_AD_MASTER Am WITH (NOLOCK) on mad.AD_ID=Am.ad_id 
									where --mad.Emp_ID = @Emp_ID and 
											For_Date BETWEEN @From_Date and @Month_Date 
											And mad.M_AD_NOT_EFFECT_SALARY = Case when Am.allowance_type='A' then 0 else 1 end 
											And MAD.AD_Id=@AD_ID
										and 1=(case when am.Allowance_Type='R' and mad.for_fnf=0 then 1 when Am.allowance_type='A' then 1 else 0 end)
									GROUP by Am.Allowance_Type
								END
						--ended by rohit

						SELECT @old_M_AD_Amount = @old_M_AD_Amount +  IsNull(sum(Isnull(M_AD_Amount,0)) + sum(isnull(M_AREAR_AMOUNT,0)) + Isnull(@PF_Arrear,0),0)
						From T0210_Monthly_AD_Detail MAD WITH (NOLOCK)  left join T0050_AD_MASTER Am WITH (NOLOCK) on mad.AD_ID=Am.ad_id   where --Emp_ID =@Emp_ID and 
						mad.AD_ID =@AD_ID 
						--and To_Date >=@From_Date and To_Date <=@Month_Date
						and 1=(case when am.Allowance_Type='R' and mad.for_fnf=0 then 1 when Am.allowance_type='A' then 1 else 0 end)
						AND EXISTS(SELECT 1 FROM T0201_MONTHLY_SALARY_SETT MS1 WITH (NOLOCK)
									WHERE ms1.S_Sal_Tran_ID=mad.S_Sal_Tran_ID
											AND mad.Emp_ID=MS1.EMP_ID and MS1.S_Eff_Date >= @FROM_DATE AND MS1.S_Eff_Date <= @TO_DATE 											
											AND EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK) WHERE MS1.Emp_ID=MS.Emp_ID AND MONTH(MS.MONTH_END_DATE)=MONTH(MS1.S_EFF_DATE) AND YEAR(MS.MONTH_END_DATE)=YEAR(MS1.S_EFF_DATE))
											)
						--and For_FNF = 0 --Comment by Ankit Due to FNF Allowance amount not calculate in tax report (WCL Email Date - Wed, Jun 1, 2016 at 2:36 PM)
						
						--ended by rohit
					
					IF isnull(@Is_Calculated_On_Imported_Value,0) = 1
					begin
						SELECT @old_M_AD_Amount = sum(Isnull(Amount,0))  From T0190_MONTHLY_AD_DETAIL_IMPORT WITH (NOLOCK) where --Emp_ID =@Emp_ID and 
							AD_ID =@AD_ID 
						and For_Date >=@From_Date and For_Date<=@Month_Date
					end

						IF not exists (SELECT EED.AD_ID From T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) inner join T0050_AD_MASTER ADM WITH (NOLOCK) on EEd.AD_ID = ADM.AD_ID where --emp_id = @emp_id and 
						increment_id = @Increment_Id	 and EED.AD_ID = @AD_ID)
							begin								
								SET @Month_Diff = 0
							end
						else
							begin																
								SET @Month_Diff = @temp_month_diff
							end
							

					
					IF @varCalc_On = 'Import'
						SET @M_AD_Amount = 0
						
					-- Added By rohit on 11052015 	
					IF @It_Estimated_SETting = 1
					begin 
					    IF @varCalc_On in ('Late','Present Senario','Absent Senario','Leave Senario','Performance','Transfer OT','Import','Bonus','Present Days','Slab Wise','Reference','Shift Wise','Leave Allowance','Split Shift','Formula','Security Deposit','Present + Paid Leave Days','Night Halt')
						begin 
							IF @It_Estimated_Amount > 0
								SET @M_AD_Amount = @It_Estimated_Amount
						end
					end	
					
					-- Ended by rohit on 11052015

					IF @SETting_Reim = 0 or isnull(@Not_display_auto_credit_amount_IT,0) = 1
					begin	
						IF @AD_CAL_TYPE='R'	
						BEGIN
						
							SELECT @old_M_AD_Amount = isnull(sum(Taxable),0) + isnull(sum(Tax_free_amount),0)  From T0210_MONTHLY_rEIM_DETAIL WITH (NOLOCK) INNER JOIN 
							T0050_AD_MASTER WITH (NOLOCK) ON T0210_MONTHLY_rEIM_DETAIL.RC_ID=T0050_AD_MASTER.AD_ID						
							where --Emp_ID =@Emp_ID and 
							RC_ID =@AD_ID AND ISNULL(AD_NOT_EFFECT_SALARY,0) = 1 AND ISNULL(Allowance_Type,'A')='R'
							and for_Date >=@From_Date and for_Date <=@Month_Date 
							--AND Sal_tran_ID > 0  -- Commneted by rohit For Approved reimbershement not Effect on Salary Shown in the report on 08092015
							AND T0050_AD_MASTER.CMP_ID=@CMP_id
							--and RC_apr_ID IS NOT NULL	--Display only Reim Approved Amount -- Ankit	24082015
							--and Amount> 0		--commeny by Ankit 24082015
							
							SET @M_AD_Amount = 0 -- Added by rohit on 12052015

						END
					end

					--IF not exists (SELECT @AD_ID from #Salary_AD where AD_ID = @AD_ID AND Emp_Id = @emp_id AND for_date = @From_Date )
					--	begin
						
						
					--		--Insert into #Salary_AD (Emp_Id,AD_ID,For_Date,Cmp_ID,M_AD_Amount,Month_Count,Old_M_AD_Amount,AD_NOT_EFFECT_ON_PT,AD_NOT_EFFECT_ON_SAL,Ad_Effect_On_TDS,Month_Diff_Amount)
					--		--SELECT @Emp_ID,@AD_Id,@From_Date,@Cmp_ID,@M_AD_Amount,@Month_Diff,@old_M_AD_Amount,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@AD_Effect_On_TDs,@M_AD_Amount * @Month_Diff
							
							
														
					--	end	
					                    
				fetch next from curAD into @AD_ID,@M_AD_Percentage,@M_AD_Amount,@M_AD_Flag,@Max_Upper,@varCalc_On,@AD_CAL_TYPE,@AD_DEF_ID,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY ,@AD_Name,@M_AD_effect_on_Late,@AD_Effect_On_TDs,@cur_increment_id,@It_Estimated_Amount,@AD_Level_Temp,@Is_Calculated_On_Imported_Value,@Not_display_auto_credit_amount_IT
			end
	close curAD
	deallocate curAD
  
	 SET @Month_Diff = @temp_month_diff
		--start  month wise pt calculation 21/05/2012
		
		DECLARE @tempFrom_Date as DateTime
		DECLARE @tempPTCal_Amount numeric(18,2)
		DECLARE @tempSal_Amount numeric(18,2)
		DECLARE @tempPT_Amount numeric(18,2)
		
		SET @tempFrom_Date = @From_Date
		SET @tempPTCal_Amount = 0
		SET @tempSal_Amount = 0
		SET @tempPT_Amount = 0
			
		
		DECLARE @flg TinyInt

		SET @flg = 0

		while @tempFrom_Date <= @To_Date
			Begin
			
			SET @PT_Calculated_Amount = 0
			
			SELECT  @PT_Calculated_Amount = sum(isnull(M_AD_Amount,0)) from #Salary_AD SA 
						inner join T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)
							on SA.ad_id = EED.AD_ID and SA.Emp_id = EED.EMP_ID
						inner join T0050_AD_MASTER AM WITH (NOLOCK) on AM.AD_ID = SA.ad_id 
					Where --SA.Emp_ID = @Emp_ID and 
					EED.E_AD_FLAG = 'I'  and AM.AD_NOT_EFFECT_SALARY = 0 and AM.AD_NOT_EFFECT_ON_PT = 0
					and EED.Increment_Id = (SELECT max(Increment_Id) from  T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) where --emp_id = @emp_id and 
							for_date <= @tempFrom_Date)
					--Commented by Hardik 05/09/2014 for Same Date Increment
					--and EED.FOR_DATE = (SELECT max(for_date) from  T0100_EMP_EARN_DEDUCTION where emp_id = @emp_id and for_date <= @tempFrom_Date)
					
				-- changed by rohit on 02-apr-2014	
		--SET @PT_Calculated_Amount =  @PT_Calculated_Amount	 + @Basic_Salary
		
		SET @PT_Calculated_Amount =  isnull(@PT_Calculated_Amount,0) + isnull(@Basic_Salary,0)
		
		IF @Emp_PT = 0
			SET @PT_Calculated_Amount = 0
				
				SET @tempPTCal_Amount = 0
				SET @tempSal_Amount = 0
				SET @tempPT_Amount = 0

-- Commented by rohit on 03062016 for Pt not showing which deduct in fnf.
				--IF isnull(@Left_date,0) <> 0 and @Left_date < @tempFrom_Date --and @tempFrom_Date  >= @join_date 
				--	begin
				--		break	
				--	end

					
				IF (month(@tempFrom_Date)  >= month(@join_date) and year(@tempFrom_Date)  >= year(@join_date)) or @tempFrom_Date  >= @join_date
					begin
						IF EXISTS ( SELECT Sal_Tran_ID from T0200_MONTHLY_SALARY WITH (NOLOCK) where MONTH(Month_End_Date) = MONTH(@tempFrom_Date) and Year(Month_End_Date) = Year(@tempFrom_Date)) --and Emp_ID = @Emp_Id )
							begin
								SELECT @tempSal_Amount= isnull(Salary_Amount,0) + isnull(Arear_Basic,0) + ISNULL(Basic_Salary_Arear_cutoff,0),
									@tempPTCal_Amount= isnull(PT_Amount,0) 
								From T0200_Monthly_Salary WITH (NOLOCK) where --Emp_ID =@Emp_ID and 
								MONTH(Month_End_Date) = MONTH(@tempFrom_Date) and Year(Month_End_Date) = Year(@tempFrom_Date) 
							end
						else
							begin
							IF not EXISTS ( SELECT Sal_Tran_ID from T0200_MONTHLY_SALARY WITH (NOLOCK) where Month_End_Date >=  @tempFrom_Date --and Emp_ID = @Emp_Id  
							) and @month_diff <> 0 -- Added by rohit on 02-apr-2014 , Month_Diff Condition added by Hardik 15/03/2016 as Form-16 has to display only Actual deducted figure
								begin
								-- changed by rohit on 03062016 for Pt not showing which deduct in fnf.
								IF isnull(@Left_date,0) <> 0 and @Left_date < @tempFrom_Date --and @tempFrom_Date  >= @join_date
								begin
									SET @tempPT_Amount = 0
								end
								--else
								--begin
								--    exec SP_CALCULATE_PT_AMOUNT @CMP_ID,@EMP_ID,@tempFrom_Date,@PT_Calculated_Amount,@tempPT_Amount OUTPUT,'' ,@Branch_ID
								--end
								-- ended by rohit on 03062016
								end
							end
				
						
						SET @Old_Salary_Amount = isnull(@Old_Salary_Amount,0)   + isnull(@tempSal_Amount,0)
						SET @Old_PT_Amount = isnull(@Old_PT_Amount,0)  + isnull(@tempPTCal_Amount,0)
						SET @PT_Amount = isnull(@PT_Amount,0) + isnull(@tempPT_Amount,0)
						

					end
						SET @tempFrom_Date = DATEADD(MM,1,@tempFrom_Date)	
					
								
			end
		
		
		-- end
	
          
		--SELECT  @PT_Calculated_Amount = isnull(sum(M_AD_Amount) ,0) from #Salary_AD SA inner join T0100_EMP_EARN_DEDUCTION EED on SA.ad_id = EED.AD_ID and SA.Emp_id = EED.EMP_ID
		--			Where SA.Emp_ID = @Emp_ID and EED.E_AD_FLAG = 'I'
		
		--SET @PT_Calculated_Amount =  @PT_Calculated_Amount	 + @Basic_Salary
		
		--IF @Emp_PT = 0
		--	SET @PT_Calculated_Amount = 0
		
		--exec SP_CALCULATE_PT_AMOUNT @CMP_ID,@EMP_ID,@To_Date,@PT_Calculated_Amount,@PT_AMOUNT OUTPUT,'' ,@Branch_ID

		--SELECT @Old_Salary_Amount = isnull(Sum(Salary_Amount),0) ,
		--	@Old_PT_Amount = isnull(sum(PT_Amount),0) 
		--From T0200_Monthly_Salary where Emp_ID =@Emp_ID and Month_St_Date >=@From_Date and Month_St_Date <=@To_Date  and	 Month_st_Date <=@Month_Date


		--Insert into #Salary_AD (Emp_Id,AD_ID,For_Date,Cmp_ID,M_AD_Amount,Month_Count,Old_M_AD_Amount,AD_NOT_EFFECT_ON_PT,AD_NOT_EFFECT_ON_SAL,Month_Diff_Amount,Default_Def_ID)
		--SELECT @Emp_ID,0,@From_Date,@Cmp_ID,@Basic_Salary,@Month_Diff,@Old_Salary_Amount,0,0,@Basic_Salary * @Month_Diff,@Cont_Basic_Sal
				
		--Insert into #Salary_AD (Emp_Id,AD_ID,For_Date,Cmp_ID,M_AD_Amount,Month_Count,Old_M_AD_Amount,AD_NOT_EFFECT_ON_PT,AD_NOT_EFFECT_ON_SAL,Month_Diff_Amount,Default_Def_ID)
		--SELECT @Emp_ID,0,@From_Date,@Cmp_ID,@PT_AMOUNT,@Month_Diff,@Old_PT_Amount,0,0,@PT_AMOUNT ,@Cont_PT_Amount
		
	
	
	-- jaysukh 14-Mar-09
	IF @Month_Diff = 0
	  begin
		Update #Salary_AD
		SET M_AD_Amount = 0 
   	 end
	
	RETURN

