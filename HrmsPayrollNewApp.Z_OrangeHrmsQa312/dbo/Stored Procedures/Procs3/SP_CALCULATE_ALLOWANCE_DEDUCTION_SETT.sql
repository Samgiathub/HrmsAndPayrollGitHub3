
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CALCULATE_ALLOWANCE_DEDUCTION_SETT]
	@S_Sal_Tran_ID			NUMERIC,	-- Normal Salary Generation
	@Emp_Id					Numeric ,
	@Cmp_ID					Numeric ,
	@Increment_ID			Numeric ,
	@From_Date				Datetime,
	@To_Date				Datetime,
	@Wages_type				varchar(10),
	@Basic_Salary			Numeric(25,2),
	@Gross_Salary_ProRata	Numeric(25,2),
	@Salary_Amount			numeric(25,2),
	@Present_Days			numeric(12,1),
	@numAbsentDays			numeric(12,1) ,
	@Leave_Days				numeric(18,1),
	@Salary_Cal_Day_sett	numeric(18,2),
	@Tot_Salary_Day			numeric(18,1),
	@OT_Amount				numeric(18,2) output ,
	@Day_Salary				numeric(12,2),
	@Branch_ID				numeric ,
	@IT_TAX_AMOUNT				numeric ,
	@Basic_Salary_Sett			Numeric(25,2),
	@Gross_Salary_ProRata_Sett	Numeric(25,2),
	@Salary_Amount_Sett			Numeric(25,2),
	@Sal_Tran_ID				numeric,
	@Salary_Cal_Day		        numeric(18,1) ,
	@Old_Basic_Salary			Numeric(25,2),
	@Old_Gross_Salary_ProRata	Numeric(25,2),
	@Old_Salary_Amount			numeric(25,2),
	@Is_Rounding				Tinyint,
	@Out_Of_Days			numeric(18,2),
	@WO_OT_Amount			Numeric(18,2) output, -- Added by Hardik 29/08/2019 for Diamines client for Transfer OT Allowance
	@HO_OT_Amount			Numeric(18,2) output,  -- Added by Hardik 29/08/2019 for Diamines client for Transfer OT Allowance
	@Shift_Day_Sec			Numeric(18,2) = 0,     --Added By Jimit for diamines case of Transfer OT Calculation in settlement 03092019
    @Emp_WD_OT_Rate			Numeric(18,2) = 0,		--Added By Jimit for diamines case of Transfer OT Calculation in settlement 03092019
	@Emp_OT_Hours_Num		Numeric(18,2) = 0,		--Added By Jimit for diamines case of Transfer OT Calculation in settlement 03092019
	@Fix_OT_Work_Days		Numeric(18,2) = 0,		--Added By Jimit for diamines case of Transfer OT Calculation in settlement 03092019
	@Emp_WO_OT_Hours_Num	Numeric(18,2) = 0,		--Added By Jimit for diamines case of Transfer OT Calculation in settlement 03092019
	@Emp_HO_OT_Hours_Num	Numeric(18,2) = 0,		--Added By Jimit for diamines case of Transfer OT Calculation in settlement 03092019
	@Emp_WO_OT_Rate			Numeric(18,0) = 0,		--Added By Jimit for diamines case of Transfer OT Calculation in settlement 03092019
	@Emp_HO_OT_Rate			Numeric(18,0) = 0		--Added By Jimit for diamines case of Transfer OT Calculation in settlement 03092019
	AS 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 
-- SELECT @Basic_Salary_Sett,@Old_Basic_Salary,@Old_Salary_Amount,@Out_Of_Days,@Day_Salary,@Tot_Salary_Day

	
	DECLARE @AD_DEF_ID			Int
	DECLARE @IT_DEF_ID			Int
	DECLARE @PF_DEF_ID			Int
	DECLARE @ESIC_DEF_ID		Int
	Declare @Join_Time_Def_ID	int		
	Declare @CPF_DEF_ID			int   -- Added by Gadriwala Muslim 23072015
	Declare @EPF_DEF_ID			int	  -- Added by Gadriwala Muslim 23072015	
	DECLARE @Cmp_PF_DEF_ID		INT 
	DECLARE @Cmp_ESIC_DEF_ID  INT   --Hardik 01/06/2018
	DECLARE @DA_DEF_ID		INT
	
	SET  @IT_DEF_ID			= 1
	SET  @PF_DEF_ID			= 2
	SET  @ESIC_DEF_ID		= 3
	set  @Join_Time_Def_ID  = 101
	SET  @CPF_DEF_ID		= 15
	SET  @EPF_DEF_ID		= 16
	SET  @Cmp_PF_DEF_ID		= 5
	SET @Cmp_ESIC_DEF_ID = 6 --Hardik 01/06/2018
	SET @DA_DEF_ID = 11

	DECLARE @DA_AMOUNT NUMERIC(18,4)
	SET @DA_AMOUNT = 0
	DECLARE @DA_AMOUNT_EARNING NUMERIC(18,4)
	SET @DA_AMOUNT_EARNING = 0

	DECLARE @OLD_DA_AMOUNT NUMERIC(18,4)
	SET @OLD_DA_AMOUNT = 0
	DECLARE @OLD_DA_AMOUNT_EARNING NUMERIC(18,4)
	SET @OLD_DA_AMOUNT_EARNING = 0

	DECLARE @BASIC_SALARY_PF NUMERIC(18,4) --Hardik 13/05/2020
	DECLARE @DA_AMOUNT_PF NUMERIC(18,4) --Hardik 13/05/2020

	 
	declare @AD_ID						numeric
	declare @M_AD_Percentage			numeric(18,5)-- Changed by Gadriwala Muslim 19032015
	declare @M_AD_Amount				numeric(12,2)
	declare @M_AD_Flag					varchar(1)
	declare @Max_Upper					numeric(27,2)
	Declare @varCalc_On					varchar(50)
	Declare @Calc_On_Allow_Dedu			numeric(18,2) 
	Declare @Other_Allow_Amount			numeric(18,2)
	Declare @M_AD_Actual_Per_Amount		numeric(18,5)-- Changed by Gadriwala Muslim 19032015
	declare @Temp_Percentage	numeric(18,2)
	Declare @Type				varchar(20)
	Declare @M_AD_Tran_ID		numeric
	Declare @PF_Limit			numeric 
	Declare @Emp_Full_Pf		numeric 
	Declare @ESIC_Limit			numeric 
	Declare @M_AD_NOT_EFFECT_ON_PT		numeric(1,0)
	Declare @M_AD_NOT_EFFECT_SALARY		Numeric(1,0)
	Declare @M_AD_EFFECT_ON_OT			Numeric(1,0)
	Declare @M_AD_EFFECT_ON_EXTRA_DAY	Numeric(1,0)
	Declare @Is_Calculate_Zero tinyint --Hardik 20/12/2017
	--
	Declare @PaySlip_Tran_ID			numeric 
	Declare @Allowance_Data				varchar(8000)
	Declare @Deduction_Data				varchar(8000)
	Declare @AD_Name					varchar(50)
	Declare @Old_M_AD_Actual_Per_Amount		numeric(25,5) -- Changed by Gadriwala Muslim 19032015
	Declare @Old_M_AD_Calculated_Amount		numeric(25,2)
	Declare @Old_M_AD_Amount				numeric(25,2)
	Declare @Old_M_AD_Percent				numeric(25,5) -- Changed by Gadriwala Muslim 19032015
	Declare @Join_Date					Datetime
	Declare @Left_Date					Datetime -- Hardik 25/01/2019
	--Declare @Tmp_Sal_cal_Days				Numeric(18,2)
	
	declare @Auto_Paid    tinyint  --Added By Jimit 31072018
	set @Auto_Paid = 0 
	DECLARE @AD_CAL_TYPE		VARCHAR(20)		--Ankit 01122015
	DECLARE @AD_Effect_Month    VARCHAR(50)
	DECLARE @StrMonth			VARCHAR(5)
	DECLARE @Emp_Auto_VPF		tinyint 
	declare @IsRounding    tinyint = 0
	
	DECLARE @Emp_Full_Pf2	TINYINT
	DECLARE @Emp_Auto_VPF2	TINYINT
	SET	@Emp_Full_Pf2 = 0
	SET @Emp_Auto_VPF2 = 0
	
	Declare @ESIC_Basic Numeric(18,2) --Hardik 01/06/2018
	Declare @ESIC_Other_Allow_Actual numeric(18,2) --- Hardik 01/06/2018
	
	Set @ESIC_Basic = 0 --- Hardik 01/06/2018
	Set @ESIC_Other_Allow_Actual = 0 --- Hardik 01/06/2018
	
	Declare @E_AD_Mode as varchar(20) --Hardik 01/08/2016
	
	
	SET @StrMonth = '#' + CAST(MONTH(@To_datE) AS VARCHAR(2)) + '#'  
	SET @AD_CAL_TYPE='' 
	set @Calc_On_Allow_Dedu = 0.0
	SET @varCalc_On = ''
	set @Other_Allow_Amount = 0
	set @Calc_On_Allow_Dedu = 0.0
	SET @varCalc_On = ''
	set @PF_Limit = 0
	set @Emp_Full_Pf =0 
	set @ESIC_Limit	= 0
	set @PaySlip_Tran_ID = 0
	set @Old_M_AD_Percent = 0
	set @Old_M_AD_Actual_Per_Amount = 0
	set @Old_M_AD_Calculated_Amount	=0
	
	If @S_Sal_Tran_ID = 0
		set @S_Sal_Tran_ID = null
	
	set @M_AD_Actual_Per_Amount = 0.0
	set @Allowance_Data = ''
	set @Deduction_Data = ''
	set @PaySlip_Tran_ID = 0
	set @Old_M_AD_Amount =0 
	--set @Tmp_Sal_cal_Days = 0
	
	SET @StrMonth = '#' + CAST(MONTH(@To_datE) AS VARCHAR(2)) + '#'  
	SET @Emp_Auto_VPF = 0
	 --select @Salary_Amount_Sett as sal_sett,@Basic_Salary as BS
	 
	DECLARE @PF_Calc_On_Allow_Dedu	NUMERIC(18,2)
	SET @PF_Calc_On_Allow_Dedu = 0
	
	Declare @CTC Numeric(18,2)
	set @CTC=0
	Declare @pre_CTC Numeric(18,2)
	set @pre_CTC=0
		
	
		select @PF_Limit = PF_Limit  ,@ESIC_Limit	 = ESIC_Upper_Limit
		from T0040_GENERAL_SETTING g WITH (NOLOCK) Inner join T0050_General_Detail gd WITH (NOLOCK) on g.Gen_ID = Gd.gen_ID
		where g.cmp_ID = @cmp_ID	and Branch_ID = @Branch_ID
		and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID) --Uncommented by Ramiz
	
		select @Emp_Full_Pf = isnull(Emp_Full_Pf,0) ,  @Emp_Auto_VPF = isnull(Emp_Auto_VPF,0),@CTC=ctc,@pre_CTC=Pre_CTC_Salary,
			@ESIC_Basic = Basic_Salary --Hardik 01/06/2018
		from T0095_Increment WITH (NOLOCK) where increment_id = @Increment_ID


		SELECT @Emp_Full_Pf2 = ISNULL(Emp_Full_Pf,0) ,  @Emp_Auto_VPF2 = ISNULL(Emp_Auto_VPF,0) FROM T0095_INCREMENT WITH (NOLOCK)	--Ankit 30052016   
		WHERE 	Emp_ID =@Emp_ID AND Increment_ID <> @Increment_ID AND Increment_ID IN 
			( SELECT MAX(Increment_ID) FROM T0095_INCREMENT TI WITH (NOLOCK) INNER JOIN
				( SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date FROM T0095_Increment WITH (NOLOCK)
					WHERE Increment_effective_Date <= @To_Date AND Cmp_ID=@Cmp_Id AND Emp_ID = @Emp_ID AND Increment_ID <> @Increment_ID 
				 ) new_inc ON Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
			  WHERE Emp_ID =@Emp_ID  ) 
				
													
		select @Join_Date = Date_of_join,@Left_Date = Emp_Left_Date From T0080_Emp_master WITH (NOLOCK) where emp_ID =@Emp_ID

		--select @Tmp_Sal_cal_Days = Sal_cal_Days 
		--	from T0200_MONTHLY_SALARY WHERE EMP_ID=@EMP_ID AND MONTH(Month_End_Date) =MONTH(@To_Date)AND YEAR(Month_End_Date) =YEAR(@To_Date)
		
		--Added By Jimit 31072018
		Declare @ReimShow as  tinyint
		set @ReimShow = 0
		--DECLARE @Setting_Value as tinyint
		--select @Setting_Value = Setting_Value from T0040_Setting where Cmp_ID = @Cmp_ID and setting_Name = 'Monthly base get reimbursement claim amount'
	   --Ended

		--if @PF_Limit = 0
		--	set @PF_Limit = 6500

		DECLARE @Pre_Sett_EffDate	DATETIME
		SELECT @Pre_Sett_EffDate = S_Eff_Date
		FROM T0201_MONTHLY_SALARY_SETT WITH (NOLOCK)
		WHERE Emp_id = @Emp_id AND Sal_Tran_ID = @Sal_Tran_ID 

	---------- case of Allowance is Remove In Revised Increment
	Declare @PRE_MONTH_AD_DETAIL TABle
	 (  M_Tran_ID					numeric Identity(1,1) ,
		AD_ID						numeric ,
		M_AD_AMOUNT					Numeric(18,5) ,
		M_AD_Percentage				numeric(18,5),-- Changed by Gadriwala Muslim 19032015
		M_AD_Flag					varchar(5),
		M_AD_Actual_Per_Amount		numeric(18,5),-- Changed by Gadriwala Muslim 19032015
		M_AD_not_Effect_On_PT		numeric(1),
		M_AD_NOT_EFFECT_SALARY		numeric(1),
		M_AD_EFFECT_ON_OT			numeric(1),
	    M_AD_EFFECT_ON_EXTRA_DAY	numeric(1) ,
	    M_AD_Calculated_Amount		numeric(18,5)
	   )
	
	
	--INSERT INTO @PRE_MONTH_AD_DETAIL (AD_ID,M_AD_AMOUNT,M_AD_Percentage,M_AD_Flag,M_AD_Actual_Per_Amount,M_AD_not_Effect_On_PT,
		--								M_AD_NOT_EFFECT_SALARY,M_AD_EFFECT_ON_OT,M_AD_EFFECT_ON_EXTRA_DAY,M_AD_Calculated_Amount)
	 --select AD_ID,round(isnull((isnull(M_AD_Amount * @Tot_Salary_Day/@Tmp_Sal_cal_Days,0)) * @Salary_Cal_Day_Sett /@Tot_Salary_Day,0),0),M_AD_Percentage,M_AD_Flag,M_AD_Actual_Per_Amount,M_AD_not_Effect_On_PT,   --added round(isnull((isnull(M_AD_Amount * @Tot_Salary_Day/@Tmp_Sal_cal_Days,0)) * @Salary_Cal_Day_Sett /@Tot_Salary_Day,0),0) condition added by hasmukh 17 Sep 2013 for Mid increment, LWP case
		--								M_AD_NOT_EFFECT_SALARY,M_AD_EFFECT_ON_OT,M_AD_EFFECT_ON_EXTRA_DAY ,M_AD_Calculated_Amount From T0210_MONTHLY_AD_DETAIL Where Sal_Tran_ID = @Sal_Tran_ID
	 --and isnull(Sal_Type,0) =0 and For_Date >=@From_Date and For_Date <=@To_Date and M_AD_Amount >0
	 --and AD_ID not in (Select AD_ID From T0100_EMP_EARN_DEDUCTION EED  Where emp_id = @emp_id and increment_id = @Increment_Id	)

	 ----Start-- Revised Salary get Allow/Dedu Detail --Ankit 30072014
			CREATE TABLE #TBLALLOW
				(
				  ROW_ID		NUMERIC(18) IDENTITY(1,1) ,
				  EMP_ID		NUMERIC(18) ,
				  INCREMENT_ID	NUMERIC(18) ,
				  AD_ID			NUMERIC(18) ,
				  E_AD_PERCENTAGE	NUMERIC(18, 5) ,-- Changed by Gadriwala Muslim 19032015
				  E_AD_AMOUNT		NUMERIC(12, 5) ,
				  AD_CALCULATE_ON	VARCHAR(50),
				  E_AD_FLAG			VARCHAR(1) ,
				  E_AD_MAX_LIMIT	NUMERIC(27, 5) ,
				  AD_DEF_ID			INT ,
				  AD_NOT_EFFECT_ON_PT	NUMERIC(1, 0) ,
				  AD_NOT_EFFECT_SALARY	NUMERIC(1, 0) ,
				  AD_EFFECT_ON_OT		NUMERIC(1, 0) ,
				  AD_EFFECT_ON_EXTRA_DAY	NUMERIC(1, 0) ,
				  AD_NAME			VARCHAR(50) ,
				  AD_LEVEL			NUMERIC(18, 0),
				  AD_Effect_Month	VARCHAR(50) ,	--Ankit 01122015
				  AD_CAL_TYPE		VARCHAR(20) ,	--Ankit 01122015
				  E_AD_Mode varchar(20), --Hardik 01/08/2016
				  Is_Calculate_Zero tinyint, --Hardik 20/12/2017
				  Auto_Paid        tinyint,     --Added By Jimit 31072018
				  Prorata_On_Salary_Structure tinyInt,
				  IsRounding tinyint
				)      
	
			INSERT  INTO #TBLALLOW
			SELECT *
			FROM 
				(
					SELECT  
					        EED.EMP_ID ,
                            EED.INCREMENT_ID ,
                            EED.AD_ID ,
							 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
								Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_AD_PERCENTAGE End 
							 Else
								eed.E_AD_PERCENTAGE End As E_AD_PERCENTAGE,
							 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
								Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
							 Else
								eed.e_ad_Amount End As E_Ad_Amount,
                            AD_Calculate_On ,
                            E_AD_Flag ,
                            E_AD_Max_Limit ,
                            AD_DEF_ID ,
                            ISNULL(AD_NOT_EFFECT_ON_PT, 0) As AD_NOT_EFFECT_ON_PT ,
                            ISNULL(AD_NOT_EFFECT_SALARY, 0) As AD_NOT_EFFECT_SALARY ,
                            ISNULL(AD_EFFECT_ON_OT, 0) As AD_EFFECT_ON_OT ,
                            ISNULL(AD_EFFECT_ON_EXTRA_DAY, 0) As AD_EFFECT_ON_EXTRA_DAY ,
                            AD_Name ,
                            AD_LEVEL,
                            ISNULL(AD_Effect_Month,'') AS AD_Effect_Month,
							ISNULL(AD_CAL_TYPE,'') AS AD_CAL_TYPE,
							E_AD_Mode,
							Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
								Case When Qry1.Is_Calculate_Zero IS null Then eed.Is_Calculate_Zero Else Qry1.Is_Calculate_Zero End 
							 Else
								eed.Is_Calculate_Zero End As Is_Calculate_Zero,
							IsNull(Adm.auto_Paid ,0) as auto_Paid,Prorata_On_Salary_Structure	,is_Rounding                    
							FROM    dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)
                            INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID LEFT OUTER JOIN
							( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID, EEDR.Is_Calculate_Zero
								From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
								( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
									Where Emp_Id = @Emp_Id And For_date <= @To_Date
								 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
							) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID and Qry1.Increment_ID >= EED.INCREMENT_ID  --added By Jimit 04072017 as it changed at WCL
                    WHERE   EEd.emp_id = @Emp_Id
                            AND Adm.AD_ACTIVE = 1
                            And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
                            And EED.INCREMENT_ID = @Increment_ID
                    
                    Union ALL
                    
                    SELECT  
					        EED.EMP_ID ,
                            EM.INCREMENT_ID ,
                            EED.AD_ID ,
                            E_AD_Percentage ,
                            E_AD_Amount ,
                            AD_Calculate_On ,
                            E_AD_Flag ,
                            E_AD_Max_Limit ,
                            AD_DEF_ID ,
                            ISNULL(AD_NOT_EFFECT_ON_PT, 0) As AD_NOT_EFFECT_ON_PT ,
                            ISNULL(AD_NOT_EFFECT_SALARY, 0) As AD_NOT_EFFECT_SALARY ,
                            ISNULL(AD_EFFECT_ON_OT, 0) As AD_EFFECT_ON_OT ,
                            ISNULL(AD_EFFECT_ON_EXTRA_DAY, 0) As AD_EFFECT_ON_EXTRA_DAY ,
                            AD_Name ,
                            AD_LEVEL,
                            ISNULL(AD_Effect_Month,'') AS AD_Effect_Month,
							ISNULL(AD_CAL_TYPE,'') AS AD_CAL_TYPE,
							E_AD_Mode,
							Is_Calculate_Zero,
							IsNull(Adm.auto_Paid ,0) as auto_Paid,Prorata_On_Salary_Structure,is_Rounding
                    FROM    dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK)
							INNER JOIN ( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
										Where Emp_Id = @Emp_Id And For_date <= @To_Date 
										Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id 
                            INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID
                            INNER JOIN dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON EED.Emp_ID = EM.Emp_ID
                    
                    WHERE   EED.EMP_ID = @Emp_ID
                            AND Adm.AD_ACTIVE = 1
                            And EEd.ENTRY_TYPE = 'A' And EED.INCREMENT_ID = @Increment_ID
                            
                ) Qry
                
            ORDER BY AD_LEVEL ,E_AD_FLAG DESC 
		
			----Below Code Comment For Twise Sett Generate	--Ankit 07012016
			--INSERT INTO @PRE_MONTH_AD_DETAIL 
			--		(AD_ID,M_AD_AMOUNT,M_AD_Percentage,M_AD_Flag,M_AD_Actual_Per_Amount,M_AD_not_Effect_On_PT,
			--			M_AD_NOT_EFFECT_SALARY,M_AD_EFFECT_ON_OT,M_AD_EFFECT_ON_EXTRA_DAY,M_AD_Calculated_Amount)
			-- select		
			--		AD_ID,ISNULL(M_AD_Amount,0), --round(isnull((isnull(M_AD_Amount * @Tot_Salary_Day/@Tmp_Sal_cal_Days,0)) * @Salary_Cal_Day_Sett /@Tot_Salary_Day,0),0),
			--			M_AD_Percentage,M_AD_Flag,M_AD_Actual_Per_Amount,M_AD_not_Effect_On_PT,   --added round(isnull((isnull(M_AD_Amount * @Tot_Salary_Day/@Tmp_Sal_cal_Days,0)) * @Salary_Cal_Day_Sett /@Tot_Salary_Day,0),0) condition added by hasmukh 17 Sep 2013 for Mid increment, LWP case
			--			M_AD_NOT_EFFECT_SALARY,M_AD_EFFECT_ON_OT,M_AD_EFFECT_ON_EXTRA_DAY ,M_AD_Calculated_Amount 
			-- From T0210_MONTHLY_AD_DETAIL 
			-- Where Sal_Tran_ID = @Sal_Tran_ID and isnull(Sal_Type,0) =0 
			-- and For_Date >=@From_Date and For_Date <=@To_Date and M_AD_Amount >0
			--		 and AD_ID not in (Select AD_ID From #TBLALLOW Where emp_id = @emp_id and increment_id = @Increment_Id	)
			
			--Twice Sett Generate	--Ankit 07012016
			
			
			INSERT INTO @PRE_MONTH_AD_DETAIL 
				(AD_ID,M_AD_AMOUNT,M_AD_Percentage,M_AD_Flag,M_AD_Actual_Per_Amount,M_AD_not_Effect_On_PT,
						M_AD_NOT_EFFECT_SALARY,M_AD_EFFECT_ON_OT,M_AD_EFFECT_ON_EXTRA_DAY,M_AD_Calculated_Amount)
			select	
					AD_ID, SUM(ISNULL(M_AD_Amount,0)) , --round(isnull((isnull(SUM(M_AD_Amount) * @Tot_Salary_Day/@Tmp_Sal_cal_Days,0)) * @Salary_Cal_Day_Sett /@Tot_Salary_Day,0),0), -- Comment Formula Calculation and get amount direct from table -- By Ankit after Discuss with Hardikbhai --07012016
					M_AD_Percentage,M_AD_Flag,SUM(M_AD_Actual_Per_Amount),M_AD_not_Effect_On_PT,   
					M_AD_NOT_EFFECT_SALARY,M_AD_EFFECT_ON_OT,M_AD_EFFECT_ON_EXTRA_DAY ,SUM(M_AD_Calculated_Amount )
			 From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
			 Where Sal_Tran_ID = @Sal_Tran_ID and  emp_id = @emp_id
				--and For_Date >=@From_Date and For_Date <=@To_Date --and M_AD_Amount > 0
				and month(To_date) = Month(@To_Date) and Year(To_Date)=Year(@to_Date)
				and AD_ID not in (Select AD_ID From #TBLALLOW Where emp_id = @emp_id and increment_id = @Increment_Id	)
			GROUP BY AD_ID	,M_AD_Percentage,M_AD_Flag,M_AD_not_Effect_On_PT,
					M_AD_NOT_EFFECT_SALARY,M_AD_EFFECT_ON_OT,M_AD_EFFECT_ON_EXTRA_DAY
					
			
		----End-- Revised Salary get Allow/Dedu Detail --Ankit 29072014
		     
	  SELECT @M_AD_Tran_ID = ISNULL(MAX(M_AD_Tran_ID),0) + 1 FROM T0210_MONTHLY_AD_DETAIL  WITH (NOLOCK) 
	  	
		

	  INSERT INTO T0210_MONTHLY_AD_DETAIL
					                     (M_AD_Tran_ID, Sal_Tran_ID,S_Sal_Tran_ID,Emp_ID, Cmp_ID, AD_ID, For_Date, M_AD_Percentage, M_AD_Amount, M_AD_Flag, M_AD_Actual_Per_Amount, 
					                      M_AD_Calculated_Amount,M_AD_NOT_EFFECT_ON_PT,M_AD_NOT_EFFECT_SALARY,M_AD_EFFECT_ON_OT,M_AD_EFFECT_ON_EXTRA_DAY,Sal_Type,To_date)
		
	  select @M_AD_Tran_ID + M_Tran_ID , @Sal_Tran_ID,@S_Sal_Tran_ID,@Emp_ID, @Cmp_ID, AD_ID, @From_Date, M_AD_Percentage, M_AD_Amount * 0, M_AD_Flag, M_AD_Actual_Per_Amount, 
					                      M_AD_Calculated_Amount,M_AD_NOT_EFFECT_ON_PT,M_AD_NOT_EFFECT_SALARY,M_AD_EFFECT_ON_OT,M_AD_EFFECT_ON_EXTRA_DAY,1,@To_Date From  @PRE_MONTH_AD_DETAIL
		--select @M_AD_Tran_ID + M_Tran_ID , @Sal_Tran_ID,@S_Sal_Tran_ID,@Emp_ID, @Cmp_ID, AD_ID, @From_Date, M_AD_Percentage, M_AD_Amount * -1, M_AD_Flag, M_AD_Actual_Per_Amount,-- Deepal change done in Inditrade. Replace -1 to 0 dt :- 03082022
	---------------------
	--Added by nilesh patel on 06042017
   --Declare @Prev_Month_AD_Amount Numeric(18,2)
   --Set @Prev_Month_AD_Amount = 0
   
   Declare @Prev_Max_AD_Amount Numeric(18,2)
   Set @Prev_Max_AD_Amount = 0
   --Added by nilesh patel on 06042017

   -- Added by Hardik 31/12/2020 for Cera Client
   Declare @is_eligible tinyint
   Set @is_eligible = 1


   Declare @Old_Sal_Cal_Days Numeric(18,2)
   Set @Old_Sal_Cal_Days = 0

	Select @Old_Sal_Cal_Days = Sal_Cal_Days
	From T0200_MONTHLY_SALARY  WITH (NOLOCK)
	Where Sal_Tran_ID =@Sal_Tran_ID and month(Month_End_Date) = Month(@To_Date) and Year(Month_End_Date)=Year(@to_Date) and  emp_id = @emp_id

	

	

Declare @Prorata_On_Salary_Structure tinyint --Hardik 27/07/2018 for Formula based allowance for Lubi
		Set @Prorata_On_Salary_Structure = 0
			
	declare CurAD_Sett cursor for
		--select EED.AD_ID,E_AD_Percentage,E_AD_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,
		--		isnull(AD_NOT_EFFECT_ON_PT,0),Isnull(AD_NOT_EFFECT_SALARY,0),isnull(AD_EFFECT_ON_OT,0),isnull(AD_EFFECT_ON_EXTRA_DAY,0) 
		--		,AD_Name
		--From T0100_EMP_EARN_DEDUCTION EED inner join
		--	T0050_AD_MASTER ADM  on EEd.AD_ID = ADM.AD_ID 
		--	where emp_id = @emp_id and increment_id = @Increment_Id	
		--order by AD_LEVEL, E_AD_Flag desc
		
		SELECT AD_ID,E_AD_PERCENTAGE,E_AD_AMOUNT,E_AD_FLAG,E_AD_MAX_LIMIT ,AD_CALCULATE_ON ,AD_DEF_ID ,
				ISNULL(AD_NOT_EFFECT_ON_PT,0),ISNULL(AD_NOT_EFFECT_SALARY,0),ISNULL(AD_EFFECT_ON_OT,0),ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) 
				,AD_NAME , AD_Effect_Month,AD_CAL_TYPE,E_AD_Mode, Is_Calculate_Zero,Auto_Paid,Prorata_On_Salary_Structure,IsRounding
		FROM   #TBLALLOW	
		WHERE EMP_ID = @EMP_ID AND INCREMENT_ID = @INCREMENT_ID	ORDER BY AD_LEVEL, E_AD_FLAG DESC	
	open CurAD_Sett		
		fetch next from CurAD_Sett into @AD_ID,@M_AD_Percentage,@M_AD_Amount,@M_AD_Flag,@Max_Upper,@varCalc_On,@AD_DEF_ID,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY
		,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY ,@AD_Name,@AD_Effect_Month,@AD_CAL_TYPE,@E_AD_Mode,@Is_Calculate_Zero,@Auto_Paid,@IsRounding
		,@Prorata_On_Salary_Structure
		while @@fetch_status = 0
			begin

				if @Is_Rounding = 1
					set @IsRounding = 1

				If @Prorata_On_Salary_Structure = 1 And @varCalc_On In ('Actual Gross','Arrears','Formula','Gross Salary','Arrears CTC')
											Set @varCalc_On = 'Basic Salary'

						--Added by ronakk 01072023 For Refrence
				   	    --If @Prorata_On_Salary_Structure = 1
						--BEGIN
						--	Set @varCalc_On = 'Basic Salary'				
						--	Set @M_AD_Percentage = 0				
						--END
						--End by ronakk 01072023
					

				set @Old_M_AD_Actual_Per_Amount =0	
				set @Old_M_AD_Actual_Per_Amount =0
				Set @Old_M_AD_Amount = 0
				set @Old_M_AD_Percent = 0 --Added By Jimit 04072018 
				set @ReimShow = 0 --Added By Jimit 31072018
				
				select @Old_M_AD_Actual_Per_Amount = isnull(M_AD_Actual_Per_Amount,0) ,@Old_M_AD_Calculated_Amount	 = isnull(M_AD_Calculated_Amount,0),@Old_M_AD_Amount = M_AD_Amount 	
					,@Old_M_AD_Percent = isnull(M_AD_Percentage,0)
				 From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
				 Where Sal_Tran_ID =@Sal_Tran_ID
						and AD_ID =@AD_ID
						and isnull(Sal_Type,0) =0 
						--and For_Date >=@From_Date and For_Date <=@To_Date
						and month(To_date) = Month(@To_Date) and Year(To_Date)=Year(@to_Date)
					
					
					
				--- Added below codition by Hardik 03/03/2021 for WCL, as August-20 Arear given in September-20 month, so that arear amount should be add in Old Amount
				-- Deepal commented as per chintan bhai discuss with wonder client 28092021
				--SELECT @Old_M_AD_Amount = @Old_M_AD_Amount + Isnull(M.M_AREAR_AMOUNT,0)--,
				--	--@Salary_Cal_Day_Sett = @Salary_Cal_Day_Sett + Isnull(MS.Arear_Day,0)
				--FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN 
				--	T0210_MONTHLY_AD_DETAIL M WITH (NOLOCK) ON MS.SAL_TRAN_ID = M.SAL_TRAN_ID INNER JOIN 
				--	T0050_AD_MASTER A WITH (NOLOCK) ON M.AD_ID=A.AD_ID  
				--WHERE MS.EMP_ID=@EMP_ID  AND AREAR_MONTH = MONTH(@TO_DATE) AND AREAR_YEAR = YEAR(@TO_DATE) AND M.AD_ID = @AD_ID
				-- Deepal commented as per chintan bhai discuss with wonder client 28092021

				IF EXISTS ( SELECT 1 FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) Where Sal_Tran_ID = @Sal_Tran_ID and AD_ID =@AD_ID and isnull(Sal_Type,0) = 1  and For_Date >=@From_Date and For_Date <=@To_Date ) --AND  @M_AD_Percentage = 0 
					BEGIN
						
						SELECT 
							@Old_M_AD_Actual_Per_Amount = @Old_M_AD_Actual_Per_Amount + isnull(M_AD_Actual_Per_Amount,0) ,
							@Old_M_AD_Calculated_Amount	 = @Old_M_AD_Calculated_Amount + isnull(M_AD_Calculated_Amount,0),
							@Old_M_AD_Amount = @Old_M_AD_Amount + M_AD_Amount --,
							--@Old_M_AD_Percent = isnull(M_AD_Percentage,0)
						 From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
						 Where Sal_Tran_ID =@Sal_Tran_ID
								and AD_ID =@AD_ID
								and isnull(Sal_Type,0) = 1  
								--and For_Date >=@From_Date and For_Date <=@To_Date
								and month(To_date) = Month(@To_Date) and Year(To_Date)=Year(@to_Date)
						
					END
					

					-- Comment by Deepal 23092021 Need to comment below code as client request to get the specail amount when Join date and Increment Date on same date comment the hardik code
					--AddedBy Jimit 25062019 as Case at WCL Mid increment Already given in normal salary HRA A but again amount isgiven in settlement
					--If Exists(select 1 from t0095_Increment WITH (NOLOCK) where Increment_ID = @Increment_ID and
					--			Day(Increment_Effective_date) <> DAY(@From_Date)) And @Old_M_AD_Actual_Per_Amount > 0 -- Added this and condition by Hardik 28/02/2020 for WCL as Mid Increment Project Allowance not calculated in Settlement
					--	BEGIN											
					--			SET @Old_M_AD_Actual_Per_Amount = @M_Ad_Amount
					--	END
					--Ended
					--End Comment by Deepal 23092021 Need to comment below code as client request to get the specail amount when Join date and Increment Date on same date comment the hardik code

				-- Added by Hardik on 24/08/2018 for Cliantha
					If @Old_Sal_Cal_Days <> @Salary_Cal_Day_sett And @Tot_Salary_Day >0 
					and (@Old_Basic_Salary+@Basic_Salary) < @PF_Limit -- deepal Add by 08122021 when Basic is getter the pf_limit then this condition will not applicable
					Begin
						Set @Old_M_AD_Amount = (@Old_M_AD_Amount / @Tot_Salary_Day) *@Salary_Cal_Day_sett
					End
									
										
				--- Added by Hardik 31/12/2020 for Cera Client
				IF EXISTS (SELECT 1 from T0040_AD_Formula_Eligible_Setting WITH (NOLOCK) where cmp_id = @cmp_id and ad_id = @ad_id)
					BEGIN
						EXEC dbo.Check_Eligible_Formula_Wise  @Cmp_ID,@EMP_ID,@AD_ID,@From_Date,0,@Salary_Cal_Day,@Tot_Salary_Day,@is_eligible output,@numAbsentDays,@Salary_Amount,0,@Present_Days,@To_Date

						If @IS_ELIGIBLE = 0
							Begin
								Set @M_AD_Amount = 0
								Goto Insert_Record
							End
					END			

				---Commented by Hardik / Hasmukh 12/07/2014

				--if @Old_M_AD_Actual_Per_Amount = 0 and @M_AD_Percentage > 0 
				--	begin
				--		If @varCalc_On ='Gross Salary' or @varCalc_On ='Actual Gross'	--changed by Falak on 14-APR-2011
				--			set @Calc_On_Allow_Dedu = @Gross_Salary_ProRata_Sett + isnull(@Old_Gross_Salary_ProRata,0)
				--		Else If @varCalc_On ='Basic Salary'	
				--			--set @Calc_On_Allow_Dedu = @Salary_Amount_Sett + isnull(@OLD_Salary_Amount,0)
				--			set @Calc_On_Allow_Dedu = @Salary_Amount_Sett --+ isnull(@OLD_Salary_Amount,0) --Hardik 13/06/2012 for increment given in Percentage of allowance also
				--		Else 
				--			set @Calc_On_Allow_Dedu = @Basic_Salary_Sett + isnull(@Old_Basic_Salary,0)
				--	end
				--else
					begin
						If @varCalc_On ='Gross Salary'	or @varCalc_On ='Actual Gross' --changed by Falak on 14-APR-2011
							begin
								If @Old_M_AD_Percent <> @M_AD_Percentage
									set @Calc_On_Allow_Dedu = @Gross_Salary_ProRata_Sett  + isnull(@Old_Gross_Salary_ProRata,0)
								else
									set @Calc_On_Allow_Dedu = @Gross_Salary_ProRata_Sett  --+ isnull(@Old_Gross_Salary_ProRata,0)
							end
						else If @varCalc_On ='CTC'	
							begin
								If @Old_M_AD_Percent <> @M_AD_Percentage
									set @Calc_On_Allow_Dedu = @CTC * @Salary_Cal_Day_sett / @Tot_Salary_Day -- Changed by Hardik 11/02/2021 for Manubhai to calculate Prorata Amount
								else
									set @Calc_On_Allow_Dedu = (@CTC * @Salary_Cal_Day_sett / @Tot_Salary_Day) - (@pre_CTC * @Salary_Cal_Day_sett / @Tot_Salary_Day) --@Gross_Salary_ProRata_Sett  --+ isnull(@Old_Gross_Salary_ProRata,0)
							end
						Else If @varCalc_On ='Basic Salary'	
							begin

								--Set @Prev_Month_AD_Amount = 0
								--Select @Prev_Month_AD_Amount = Isnull(M_AD_Amount,0) From T0210_MONTHLY_AD_DETAIL Where AD_ID = @AD_ID and Sal_Tran_ID = @Sal_Tran_ID
								If @Old_M_AD_Percent <> @M_AD_Percentage or @Old_M_AD_Amount=0
									set @Calc_On_Allow_Dedu = @Salary_Amount_Sett  + isnull(@OLD_Salary_Amount,0)
								else
									set @Calc_On_Allow_Dedu = @Salary_Amount_Sett  --+ isnull(@OLD_Salary_Amount,0)
							
							end
						Else 
							begin
							
							if @M_AD_Percentage >0 
							begin 
							
								If @Old_M_AD_Percent <> @M_AD_Percentage
									set @Calc_On_Allow_Dedu = @Salary_Amount_Sett  + isnull(@OLD_Salary_Amount,0)
								else
									set @Calc_On_Allow_Dedu = @Salary_Amount_Sett  --+ isnull(@Old_Basic_Salary,0)
							end
							else
							begin
								If @Old_M_AD_Percent <> @M_AD_Percentage
									set @Calc_On_Allow_Dedu = @Basic_Salary_Sett  + isnull(@Old_Basic_Salary,0)
								else
									set @Calc_On_Allow_Dedu = @Basic_Salary_Sett  --+ isnull(@Old_Basic_Salary,0)
									
							end		
							end
					end
					
				if @M_AD_Percentage > 0 Or @E_AD_Mode = '%' --Added by Hardik 01/08/2016 for Aculife as ESIC Case wrong for Emp Code 023485 for Jun-16 Settlement
					set @M_AD_Actual_Per_Amount = @M_AD_Percentage
				else
					begin
						set @M_AD_Actual_Per_Amount = @M_AD_Amount  - isnull(@Old_M_AD_Actual_Per_Amount,0) 
						set @M_AD_Amount = @M_AD_Actual_Per_Amount 
					end 

				set @Other_Allow_Amount = 0

				--select @Other_Allow_Amount = isnull(sum(M_AD_amount),0)  from T0210_MONTHLY_AD_DETAIL
				--where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID 
				--and S_Sal_Tran_ID = @S_Sal_Tran_ID and isnull(Sal_Type,0) =1 
				--and For_Date >=@From_Date and For_Date <=@To_Date
				--and AD_ID in 
				--(select AD_ID  from T0060_EFFECT_AD_MASTER 
				--where Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID )

			
				IF @M_AD_Percentage > 0 And @Old_M_AD_Percent <> @M_AD_Percentage and @PF_DEF_ID <> @AD_DEF_ID and @ESIC_DEF_ID <> @AD_DEF_ID And @CMP_ESIC_DEF_ID <> @AD_DEF_ID and @EPF_DEF_ID <> @AD_DEF_ID and @CPF_DEF_ID <> @AD_DEF_ID AND @Emp_Auto_VPF <> @AD_DEF_ID AND @Cmp_PF_DEF_ID <> @AD_DEF_ID   -- Changed by Gadriwala Muslim 24072015 , --@Emp_Auto_VPF --Ankit 09012016
					Begin
						select @Other_Allow_Amount = isnull(sum(E_AD_amount),0)  from T0100_emp_earn_deduction WITH (NOLOCK)
						where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID  and INCREMENT_ID=@Increment_ID    --as it is changed at Client side Jimit 15072017
						--and S_Sal_Tran_ID = @S_Sal_Tran_ID and isnull(Sal_Type,0) =1 
						and For_Date in (select MAX(for_date) from T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) where CMP_ID=@Cmp_ID
						and EMP_ID=@Emp_Id and for_date <= @to_date)
						and AD_ID in 
						(select AD_ID  from T0060_EFFECT_AD_MASTER WITH (NOLOCK)
						where Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID )
						
						Set @ESIC_Other_Allow_Actual = @Other_Allow_Amount --Hardik 01/06/2018

						
						
						Set @Other_Allow_Amount = (@Other_Allow_Amount / @Tot_Salary_Day) * @Salary_Cal_Day_sett
					
					End
				Else
					Begin
						select @Other_Allow_Amount = isnull(sum(M_AD_amount),0)  from T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
						where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID 
						and S_Sal_Tran_ID = @S_Sal_Tran_ID and isnull(Sal_Type,0) =1 
						and For_Date >=@From_Date and For_Date <=@To_Date
						and AD_ID in 
						(select AD_ID  from T0060_EFFECT_AD_MASTER WITH (NOLOCK)
						where Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID )

						
						If @ESIC_DEF_ID = @AD_DEF_ID Or @Cmp_ESIC_DEF_ID = @AD_DEF_ID And Isnull(@Old_M_AD_Percent,0) =0  --Hardik 01/06/2018
							BEGIN
								SELECT @ESIC_Other_Allow_Actual = isnull(sum(E_AD_amount),0)  
								FROM T0100_EMP_EARN_DEDUCTION E WITH (NOLOCK) inner join T0050_AD_MASTER AM WITH (NOLOCK) on E.AD_ID=AM.AD_ID
								WHERE E.CMP_ID = @Cmp_ID and Emp_ID = @Emp_ID  and INCREMENT_ID=@Increment_ID
									and E.AD_ID in 
										(select AD_ID  from T0060_EFFECT_AD_MASTER WITH (NOLOCK) 
										where Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID)
									AND Isnull(AM.AD_NOT_EFFECT_SALARY,0) = 0 AND AM.AD_FLAG = 'I'
									
								If @Old_M_AD_Percent <> @M_AD_Percentage
									BEGIN
										Set @Other_Allow_Amount = @ESIC_Other_Allow_Actual
										Set @Other_Allow_Amount = (@Other_Allow_Amount / @Tot_Salary_Day) * @Salary_Cal_Day_sett
									END
							END
							
					End

					IF @AD_DEF_ID IN (@PF_DEF_ID,@Cmp_PF_DEF_ID)
						BEGIN
							SELECT  @DA_AMOUNT = ISNULL(SUM(E_AD_amount),0)  
							FROM	dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) on eed.AD_ID = am.AD_ID
									INNER JOIN dbo.T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) ON EED.AD_ID=EAD.AD_ID
							WHERE	eed.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND Increment_Id = @Increment_Id  and am.AD_CALCULATE_ON NOT IN ('Import', 'Present + Paid Leave Days')
									AND EAD.EFFECT_AD_ID=@AD_ID AND AM.AD_DEF_ID = @DA_DEF_ID

							SELECT  @DA_AMOUNT_EARNING = ISNULL(SUM(M_AD_Amount),0)  
							FROM	dbo.T0210_MONTHLY_AD_DETAIL EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) on eed.AD_ID = am.AD_ID
									INNER JOIN dbo.T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) ON EED.AD_ID=EAD.AD_ID
							WHERE	eed.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID and am.AD_CALCULATE_ON NOT IN ('Import', 'Present + Paid Leave Days')
									AND EAD.EFFECT_AD_ID=@AD_ID AND AM.AD_DEF_ID = @DA_DEF_ID
									AND For_Date >=@From_Date AND For_Date <=@To_Date                
									AND ISNULL(S_Sal_Tran_ID,0) = ISNULL(@S_Sal_Tran_ID,ISNULL(S_Sal_Tran_ID,0))

							SELECT  @OLD_DA_AMOUNT_EARNING = ISNULL(SUM(M_AD_Amount),0)  
							FROM	dbo.T0210_MONTHLY_AD_DETAIL EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) on eed.AD_ID = am.AD_ID
									INNER JOIN dbo.T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) ON EED.AD_ID=EAD.AD_ID
							WHERE	eed.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID and am.AD_CALCULATE_ON NOT IN ('Import', 'Present + Paid Leave Days')
									AND EAD.EFFECT_AD_ID=@AD_ID AND AM.AD_DEF_ID = @DA_DEF_ID
									AND For_Date >=@From_Date AND For_Date <=@To_Date                
									AND ISNULL(Sal_Tran_ID,0) = ISNULL(@Sal_Tran_ID,ISNULL(Temp_Sal_Tran_ID,0))                    
						END
					ELSE
						SET @DA_AMOUNT = 0

					IF @AD_DEF_ID IN (@PF_DEF_ID,@Cmp_PF_DEF_ID)
						BEGIN
							IF EXISTS(SELECT 1 FROM dbo.T0040_SETTING WITH (NOLOCK)
									WHERE Cmp_ID = @Cmp_ID and Setting_Name='PF Limit Check with Earning Basic' And IsNull(Setting_Value,0) = 1)
								BEGIN
									SET @BASIC_SALARY_PF = @Salary_Amount_Sett + isnull(@Old_Salary_Amount,0)
									SET @DA_AMOUNT_PF = @DA_AMOUNT_EARNING + @OLD_DA_AMOUNT_EARNING
								END
							ELSE
								BEGIN

									SET @BASIC_SALARY_PF = @Basic_Salary_Sett + isnull(@Old_Basic_Salary,0) 
									SET @DA_AMOUNT_PF = @DA_AMOUNT
								END
						END
					-- Hardik 29/03/2019 for New PF Rule
					DECLARE @Calculate_Full_PF_evenif_Basic_is_above_PF_Limit As bit
					--Declare @Calculate_Full_PF_evenif_Basic_is_less_PF_Limit As bit --Added By Hardik 27/07/2020 for GIFT City

					SET @Calculate_Full_PF_evenif_Basic_is_above_PF_Limit = 0
					--SET @Calculate_Full_PF_evenif_Basic_is_less_PF_Limit = 0

					SELECT @Calculate_Full_PF_evenif_Basic_is_above_PF_Limit = setting_value from T0040_SETTING WITH (NOLOCK)  --New PF Rules for Corona 20052019 added By Jimit
					Where Cmp_Id = @Cmp_ID and Setting_Name = 'Calculate Full PF, evenif Basic is above PF Limit'

					--select @Calculate_Full_PF_evenif_Basic_is_less_PF_Limit = setting_value from T0040_SETTING WITH (NOLOCK) --Added By Hardik 27/07/2020 for GIFT City
					--Where Cmp_Id = @Cmp_ID and Setting_Name = 'Calculate Full PF, Evenif Basic is Less than PF Limit'

					If (@AD_DEF_ID=@PF_DEF_ID or @AD_DEF_ID = @Cmp_PF_DEF_ID OR @AD_DEF_ID=4) And @Basic_Salary_Sett  + isnull(@Old_Basic_Salary,0) >= @PF_Limit
						and IsNull(@Calculate_Full_PF_evenif_Basic_is_above_PF_Limit,0) = 0
						BEGIN
							Set @Other_Allow_Amount = 0
						END

						--Hardik 29/03/2019 As per New PF Rule
						If Case When @Wages_type = 'Daily' Then  (@Basic_Salary + @DA_AMOUNT) * 26 Else @BASIC_SALARY_PF + @DA_AMOUNT_PF End <= @PF_Limit And @Emp_Full_Pf =1 AND (@AD_DEF_ID=@PF_DEF_ID OR @AD_DEF_ID = @Emp_Auto_VPF)
						--AND @Calculate_Full_PF_evenif_Basic_is_less_PF_Limit = 0
							Begin
								Set @Emp_Full_Pf=0
							End

						--Hardik 29/03/2019 As per New PF Rule
						If Case When @Wages_type = 'Daily' Then  (@Basic_Salary + @DA_AMOUNT) * 26 Else @BASIC_SALARY_PF + @DA_AMOUNT_PF End <= @PF_Limit And @Emp_Auto_VPF =1 AND @AD_DEF_ID = @Cmp_PF_DEF_ID
						--AND @Calculate_Full_PF_evenif_Basic_is_less_PF_Limit = 0
							Begin
								Set @Emp_Auto_VPF=0
							End			
			
			
				If @varCalc_On <> 'On Effected Allowance' --Added by Hardik 21/02/2019 for Enlume Client for PF Calculation is calculated on "On Effected Alowance" Only 
					set @Calc_On_Allow_Dedu = isnull(@Calc_On_Allow_Dedu,0) + isnull(@Other_Allow_Amount ,0)
				ELSE
					set @Calc_On_Allow_Dedu = isnull(@Other_Allow_Amount ,0)

				

				IF (@PF_DEF_ID = @AD_DEF_ID OR @AD_DEF_ID=4 OR @Emp_Auto_VPF = @AD_DEF_ID OR @Cmp_PF_DEF_ID = @AD_DEF_ID  ) --AND @Basic_Salary_Sett = 0
					BEGIN
						SET @PF_Calc_On_Allow_Dedu =  @Calc_On_Allow_Dedu -- @Old_Salary_Amount -- changed by rohit for pf calculate Wrong While zero increment. on 03062016
						--SET @PF_Calc_On_Allow_Dedu = ISNULL(@PF_Calc_On_Allow_Dedu,0) + isnull(@Other_Allow_Amount ,0)
					END
		
	
				if @M_AD_Flag = 'I'
					BEGIN
						--If  @M_AD_Percentage > 0


						If ( @Old_M_AD_Percent <> @M_AD_Percentage) or @M_AD_Percentage > 0    --added by jimit 30122016 after discussion with Hardik bhai.
							BEGIN

								If @CMP_ESIC_DEF_ID = @AD_DEF_ID
									Begin
										Declare @ESIC_Count numeric(22,2)
												
										select 	@ESIC_Count=M_Ad_Amount from t0210_monthly_ad_detail WITH (NOLOCK) where Ad_Id=@AD_ID And Emp_Id=@Emp_Id And Month(For_Date)=Month(@From_Date) And Year(For_Date)= Year(@From_Date)
										--Deepal 01072021 Comnent the old code and adding the comp ESIC logic
										--if isnull(@ESIC_Count,0) > 0
										--	Begin
										--		set @M_AD_Amount = ceiling((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100))
										--	End
										--else
										--	Begin
										--		set @M_AD_Amount=0
										--	End	
										if isnull(@ESIC_Count,0) > 0
											Begin
												set @M_AD_Amount = ceiling((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100))
											End
										ELSE IF Month(@To_Date) In (4,10) And (@ESIC_Basic + Isnull(@ESIC_Other_Allow_Actual,0) <= @ESIC_Limit) 
											BEGIN
												
												SET @M_AD_Amount = ceiling((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100))
											END
										ELSE IF @ESIC_Basic + Isnull(@ESIC_Other_Allow_Actual,0) <= @ESIC_Limit
											BEGIN
											
												DECLARE @sal_tran_id1CmpESIC NUMERIC(18,0)  
												DECLARE @FROM_TERMCmpESIC DATETIME
												DECLARE @TO_TERMCmpESIC DATETIME
												Declare @Month_End_Date_MininumCmpESIC datetime
												
												SET  @sal_tran_id1CmpESIC=0  
												
												IF MONTH(@To_Date) BETWEEN 4 AND 9
													BEGIN								
														SET @FROM_TERMCmpESIC = CAST(YEAR(@To_Date) AS VARCHAR(10)) + '-04-01' 
														SET @TO_TERMCmpESIC = CAST(YEAR(@To_Date) AS VARCHAR(10)) + '-09-30' 
													END
												ELSE
													BEGIN
														IF MONTH(@To_Date) BETWEEN 1 AND 3
															SET @FROM_TERMCmpESIC = CAST((YEAR(@To_Date)-1) AS VARCHAR(10)) + '-10-01' 
														ELSE
															SET @FROM_TERMCmpESIC = CAST(YEAR(@To_Date) AS VARCHAR(10)) + '-10-01' 

														SET @TO_TERMCmpESIC =DATEADD(D,-1, DATEADD(M, 6, @FROM_TERMCmpESIC));
													END

							
												SELECT	TOP 1 @sal_tran_id1CmpESIC=Sal_Tran_ID, @Month_End_Date_MininumCmpESIC = MS.Month_End_Date
												FROM	dbo.T0200_MONTHLY_SALARY MS
												WHERE	Emp_ID=@emp_id AND MS.Cmp_ID=@Cmp_ID AND MS.Month_End_Date BETWEEN @FROM_TERMCmpESIC AND @TO_TERMCmpESIC 
														--AND (sal_tran_id <> @Sal_Tran_ID)
												ORDER BY MS.Month_End_Date desc
												
												--Below Line is commented for Wonder client 31082021
												--If Month(@Month_End_Date_MininumCmpESIC) = Month(@To_Date) And Year(@Month_End_Date_MininumCmpESIC) = Year(@To_Date)
												--	BEGIN
													--	SET @M_AD_Amount = ceiling((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100))
												--	END
												
													SET @M_AD_Amount = ceiling((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100))
											END
										else
											Begin
												set @M_AD_Amount=0
											End	
									End
								Else
									Begin
									
								if round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0) > @Max_Upper and @Max_Upper > 0
									begin
										set @M_AD_Amount = @Max_Upper	
									end	
								else		
									begin
										--SELECT @Is_Rounding = is_Rounding from T0050_AD_MASTER where CMP_ID = @Cmp_ID and AD_ID = @AD_ID
										
										If @IsRounding = 1
											set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0) 
										Else											
											set @M_AD_Amount = (@Calc_On_Allow_Dedu * @M_AD_Percentage / 100) 

										-- Check max limit of allowance
										--Added by nilesh patel on 06042017
									
										if (Isnull(@Old_M_AD_Amount,0) + Isnull(@M_AD_Amount,0)) >= @Max_Upper and @Max_Upper > 0
											Begin
												Set @M_AD_Amount = @Max_Upper - @Old_M_AD_Amount
											End
											
										--Added by nilesh patel on 06042017
										IF @Cmp_PF_DEF_ID = @AD_DEF_ID  -- Company PF -- Ankit 09012016
											BEGIN
												
												Declare @CmpPFArrearAmount as numeric(18,0) = 0
												Declare @TotalCmpPFArrearAmount as numeric(18,0) = 0

												IF @Basic_Salary_Sett = 0
													SET @Calc_On_Allow_Dedu = @PF_Calc_On_Allow_Dedu

												
												--Added by nilesh on 10012017 For Full PF Settelment (Last month PF Deduction in PF Limit & Enter Back Date Increment and Set Full PF Deduction)
												if ((@Old_M_AD_Calculated_Amount = @PF_LIMIT) and isnull(@Emp_Auto_VPF,0) = 1) --and isnull(@Emp_Auto_VPF2,0) = 0 Or (isnull(@Emp_Auto_VPF,0) = 1 And (@Old_Basic_Salary + @Basic_Salary > @PF_Limit)) --- Change Condition by Hardik 23/02/2021 for WCL
													Begin
														Set @Calc_On_Allow_Dedu = isnull(@Calc_On_Allow_Dedu,0) + (isnull(@Old_Salary_Amount,0) - isnull(@PF_LIMIT,0))														
													End
												--Else --- Change Condition by Hardik 23/02/2021 for WCL
												--	Begin
												--		Set @Calc_On_Allow_Dedu = 0
												--	End
												
												-- Added by Hardik 26/02/2021 for WCL
												--select @Old_Basic_Salary , @Basic_Salary , isnull(@Emp_Full_PF,0)  , @Old_M_AD_Amount ,@Calc_On_Allow_Dedu
												If @Old_Basic_Salary + @Basic_Salary < @PF_Limit And isnull(@Emp_Full_PF,0) = 1 And @Old_M_AD_Amount = 1800
													Set @Calc_On_Allow_Dedu =0
												else IF @Old_Basic_Salary + @Basic_Salary > @PF_Limit And isnull(@Emp_Full_PF,0) = 1
													set @Calc_On_Allow_Dedu = (@Old_Basic_Salary + @Basic_Salary)

												
												IF  ISNULL(@Emp_Auto_VPF,0) = 0 AND @PF_LIMIT > 0 AND ISNULL(@Calc_On_Allow_Dedu,0) + ISNULL(@Old_M_AD_Calculated_Amount,0)  > @PF_LIMIT
													SET @Calc_On_Allow_Dedu = @PF_Limit - ISNULL(@Old_M_AD_Calculated_Amount,0)																
												ELSE IF  @Emp_Auto_VPF = 0 AND @PF_LIMIT > 0 AND @Old_M_AD_Calculated_Amount > @PF_LIMIT  
													SET @Calc_On_Allow_Dedu = 0
												
												
												-- Added by Hardik 26/02/2021 for WCL
												--If @Old_Basic_Salary < @PF_Limit and @Old_Basic_Salary + @Basic_Salary > isnull(@PF_LIMIT,0)
												--	Begin														
												--		Set @Calc_On_Allow_Dedu = @Old_Basic_Salary + @Basic_Salary - isnull(@PF_LIMIT,0)
												--	End
												--- For Wonder Specific Condition
												-- old condition before 31-03-2021 Deepal
												--If exists(Select 1 from T0080_Emp_Master Where Emp_Id = @Emp_Id and Alpha_Emp_Code In (20058,20411,20532,20557,20599,20678,20679,20748,20868,20874,20968,20989,20999,21060,21096,21100,21103,21180,21185,21193,21221,21234,21346,21362,21381,21407,21425,21427,21430,21433,21458,21466,21470,21502,21514,21521,21543,21550,21552,21566,21575,21582,21587,21611,21627,21631,21633,21636,21654))
												--	Begin
												--		Set @Calc_On_Allow_Dedu = @Old_Basic_Salary + @Basic_Salary - isnull(@PF_LIMIT,0)
														
												--	End
												--select @Salary_Cal_Day_sett,@Out_Of_Days,@Basic_Salary,@Old_Basic_Salary,@Old_M_AD_Calculated_Amount,@Calc_On_Allow_Dedu,@Old_Salary_Amount,@Old_M_AD_Amount
												
												--if @Salary_Cal_Day_sett < @Out_Of_Days and @Basic_Salary <> 0
												--Begin 
												--	set @Calc_On_Allow_Dedu = ((((isnull(@Old_Basic_Salary,0) + isnull(@Basic_Salary,0))/@tot_salary_day)*@Salary_Cal_Day_sett)+ @Calc_On_Allow_Dedu) - @Old_M_AD_Calculated_Amount
													
												--END
												--else
												--Begin
												
												--IF EXISTS(SELECT 1 FROM dbo.T0040_SETTING WITH (NOLOCK)
												--WHERE Cmp_ID = @Cmp_ID and Setting_Name='PF Limit Check with Earning Basic' And IsNull(Setting_Value,0) = 1)
												--BEGIN
												--END
													
												if @Salary_Cal_Day_sett < @Out_Of_Days and @Basic_Salary <> 0 --and @Emp_Full_Pf > 0
												Begin 
													--set @Calc_On_Allow_Dedu = (((isnull(@Old_Basic_Salary,0) + isnull(@Basic_Salary,0))/@Out_Of_Days)*@Salary_Cal_Day_sett) - @Old_M_AD_Calculated_Amount
													if @Emp_Full_Pf = 0 
														if @Old_M_AD_Calculated_Amount <= 15000  -- Add by Deepal this Condition in RMP with chintan bhai
															set @Calc_On_Allow_Dedu = 15000 - @Old_M_AD_Calculated_Amount 	
														else
															set @Calc_On_Allow_Dedu = (((isnull(@Old_Basic_Salary,0) + isnull(@Basic_Salary,0))/@Out_Of_Days)*@Salary_Cal_Day_sett) - @Old_M_AD_Calculated_Amount
													else
														set @Calc_On_Allow_Dedu = (((isnull(@Basic_Salary,0))/@Out_Of_Days)*@Salary_Cal_Day_sett) 
													--if @Emp_Full_Pf = 0 
													--	set @Calc_On_Allow_Dedu = (((isnull(@Old_Basic_Salary,0) + isnull(@Basic_Salary,0))/@Out_Of_Days)*@Salary_Cal_Day_sett) - @Old_M_AD_Calculated_Amount
													--else
													--	set @Calc_On_Allow_Dedu = (((isnull(@Basic_Salary,0))/@Out_Of_Days)*@Salary_Cal_Day_sett)
												END
												else
												Begin
													
													if @Basic_Salary < 1800 and @Old_M_AD_Calculated_Amount >= 15000 and @Basic_Salary <> 0  and @Emp_Full_Pf > 0
													begin 
													select @AD_ID,@M_AD_Percentage,@Old_M_AD_Percent,@AD_Name,@PF_DEF_ID,@AD_DEF_ID,@Calc_On_Allow_Dedu	,@Old_Basic_Salary , @Basic_Salary,@PF_LIMIT,@Calc_On_Allow_Dedu
													select isnull(@Old_Basic_Salary,0) , isnull(@Basic_Salary,0) , @Old_M_AD_Calculated_Amount
														set @Calc_On_Allow_Dedu = (isnull(@Old_Basic_Salary,0) + isnull(@Basic_Salary,0)) - @Old_M_AD_Calculated_Amount
													end
													else If @Old_M_AD_Calculated_Amount = 15000 and @Emp_Full_Pf > 0
													Begin 
														set @Calc_On_Allow_Dedu = (isnull(@Old_Basic_Salary,0) + isnull(@Basic_Salary,0)) - @Old_M_AD_Calculated_Amount
													END
												END

												if @Old_M_AD_Calculated_Amount <= 15000 -- Add by Deepal this Condition in RMP with chintan bhai
												BEGIN
													set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)

													if @Calc_On_Allow_Dedu < @M_AD_Amount
														set @M_AD_Amount  = @Calc_On_Allow_Dedu
													
												END

												Select @CmpPFArrearAmount = ma.M_AREAR_AMOUNT
												From T0200_MONTHLY_SALARY MS inner join T0210_MONTHLY_AD_DETAIL MA on ms.Sal_Tran_ID = ma.Sal_Tran_ID
												Where Arear_Month = Month(@To_Date) and Arear_Year =Year(@to_Date) and  ms.emp_id = @emp_id and ma.AD_ID = @AD_ID

												if @Emp_Full_Pf = 0
												Begin

													set @TotalCmpPFArrearAmount = @Old_M_AD_Amount +  @CmpPFArrearAmount 

													if @TotalCmpPFArrearAmount >= 1800 and @Emp_Full_Pf = 0
													Begin 
														set @M_AD_Amount = 0
													END
													else if @TotalCmpPFArrearAmount < 1800 and @Emp_Full_Pf = 0
													Begin 
														if (1800 -  @TotalCmpPFArrearAmount) < @M_AD_Amount
														begin 
															set @M_AD_Amount = (1800 -  @TotalCmpPFArrearAmount)
														END
													END
													else
													Begin 
														set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)
													END
												end
												else
												Begin 
													if @Emp_Full_Pf = 1 and @Calc_On_Allow_Dedu > @PF_Limit
													Begin 
														set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0) - (@Old_M_AD_Amount + @CmpPFArrearAmount)
														If @Old_Sal_Cal_Days <> @Salary_Cal_Day_sett And @Tot_Salary_Day >0 
														Begin
															Set @M_AD_Amount = round((@M_AD_Amount / @Tot_Salary_Day) *@Salary_Cal_Day_sett,0)
														End
													END
													else
													Begin 
														set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)
													END
												END
												--END
												-- New logic add by  Deepal For Wonder New basic - gross - HRA calculation 27-08-2021 only for settlement

												--select @Calc_On_Allow_Dedu
												--select @Calc_On_Allow_Dedu,@M_AD_Percentage
											
												--SET @M_AD_Amount = ROUND((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)
												-- old condition 31-03-2021 Deepal

												--Deepal Addd need to check not kept in wonder so comment in local DT:- 03122021
												--IF @Old_Basic_Salary + @Basic_Salary > @PF_Limit And isnull(@Emp_Full_PF,0) = 1 
												--	Set @Calc_On_Allow_Dedu = 0
												--Deepal End need to check not kept in wonder so comment in local DT:- 03122021
												--else
												--Begin
												--	If exists(Select 1 from T0080_Emp_Master Where Emp_Id = @Emp_Id and Alpha_Emp_Code In (20058,20411,20532,20557,20599,20678,20679,20748,20868,20874,20968,20989,20999,21060,21096,21100,21103,21180,21185,21193,21221,21234,21346,21362,21381,21407,21425,21427,21430,21433,21458,21466,21470,21502,21514,21521,21543,21550,21552,21566,21575,21582,21587,21611,21627,21631,21633,21636,21654))
												--	Begin
												--		Set @Calc_On_Allow_Dedu = @Old_Basic_Salary + @Basic_Salary - isnull(@PF_LIMIT,0)
												--	End
												--END
												--Deepal Addd need to check not kept in wonder so comment in local DT:- 03122021
												--SET @M_AD_Amount = ROUND((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)
												--Deepal End need to check not kept in wonder so comment in local DT:- 03122021												
												
												-- Added by Hardik 26/02/2021 for WCL
												--if (@Old_Basic_Salary + @Basic_Salary < @PF_Limit And @Old_M_AD_Amount <= 1800 And @M_AD_Amount > 1800 - @Old_M_AD_Amount) Or isnull(@Emp_Auto_VPF,0) = 0
												--begin													
												--	Set @M_AD_Amount = 1800 - @Old_M_AD_Amount
												--end
												--Deepal Addd need to check not kept in wonder so comment in local DT:- 03122021
												--if @Old_Basic_Salary + @Basic_Salary < @PF_Limit And isnull(@Emp_Full_PF,0) = 1 And @Old_M_AD_Amount < 1800 And @M_AD_Amount > 1800 - @Old_M_AD_Amount
												--	Set @M_AD_Amount = 1800 - @Old_M_AD_Amount
												--Deepal End need to check not kept in wonder so comment in local DT:- 03122021												
												
												if @Calculate_Full_PF_evenif_Basic_is_above_PF_Limit = 1
												begin
													select @Calc_On_Allow_Dedu = ((@Old_Basic_Salary + @Basic_Salary) * @M_AD_Percentage / 100)
													select @M_AD_Amount = ROUND(@Calc_On_Allow_Dedu - @Old_M_AD_Amount,0)
												end
												
												--select @M_AD_Amount,@Old_M_AD_Amount,@Old_Basic_Salary + @Basic_Salary
												-- commeneted by rohit for pf not calculate in settlement on 27062016
												--IF @Emp_Auto_VPF = 1 AND @Emp_Auto_VPF2 = 0
												--	SET @M_AD_Amount = @M_AD_Amount - @Old_M_AD_Amount
												
												--IF @M_AD_Amount < 0 SET @M_AD_Amount = 0 --COMMENTED BY HARDIK 02/12/2020 FOR UNISON AS THEY HAVE MINUS PF
												
											END
											
									end
							END	
						END
						Else
							BEGIN
								If upper(@varCalc_On) ='FIX'
									begin
										set @M_AD_Amount =  @M_AD_Amount
									end
								Else IF UPPER(@VARCALC_ON) ='FIX + JOINING PRORATE' -- Added by Hardik 25/01/2019
									BEGIN
										IF (@JOIN_DATE >= @From_Date  AND @JOIN_DATE <= @To_Date)
											BEGIN
												SET @M_AD_AMOUNT = ROUND((@M_AD_AMOUNT * (DATEDIFF(day,@JOIN_DATE,@To_Date) + 1))/@OUT_OF_DAYS,0)
											END
										ELSE IF (@LEFT_DATE >= @From_Date  AND @LEFT_DATE <= @To_Date)
											BEGIN
												SET @M_AD_AMOUNT = ROUND((@M_AD_AMOUNT * (DATEDIFF(day,@From_Date,@LEFT_DATE) + 1))/@OUT_OF_DAYS,0)
											END
										ELSE
											BEGIN
												SET @M_AD_AMOUNT=@M_AD_AMOUNT							
											END
									END   	   	
								Else IF UPPER(@VARCALC_ON) ='TRANSFER OT' -- Added by Hardik 29/08/2019 For Diamines client
									BEGIN
										
										
										--Added By Jimit 03092019
										declare @Temp_Ot_Amt Numeric(18,2)
										declare @Day_Sal_Temp Numeric(18,2)
										declare @Hour_Sal_Temp Numeric(18,2)
										
										
										SELECT  @Temp_Ot_Amt = ISNULL(SUM(M_AD_Actual_Per_Amount),0)
										FROM     T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
										         INNER JOIn T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK) ON MS.Emp_ID = MAD.Emp_ID AND MAD.S_Sal_Tran_ID = MS.S_Sal_Tran_ID
										         Inner Join T0050_AD_MASTER Am WITH (NOLOCK) On Am.AD_ID = MAD.AD_ID 
										WHERE   ISNULL(M_AD_Effect_On_Ot,0) = 1 and Mad.Emp_ID = @Emp_Id
										        ANd MONTH(To_Date) = MONTH(@To_date) And YEAR(To_date) = YEAR(@TO_date)
										
										IF  @Emp_OT_Hours_Num > 0 
											  BEGIN
												IF @Fix_OT_Work_Days > 0 AND @Shift_Day_Sec > 0
													BEGIN
															set @Day_Sal_Temp = @Temp_Ot_Amt / @Fix_OT_Work_Days
															set  @Hour_Sal_Temp = @Day_Sal_Temp * 3600 / @Shift_Day_Sec								
												
															SET @OT_Amount = @OT_Amount + (@Emp_OT_Hours_Num * @Hour_Sal_Temp) * @Emp_WD_OT_Rate										
													END
												END
										IF  @Emp_HO_OT_Hours_Num > 0 
											  BEGIN
												IF @Fix_OT_Work_Days > 0 AND @Shift_Day_Sec > 0
													BEGIN
															set @Day_Sal_Temp = @Temp_Ot_Amt / @Fix_OT_Work_Days
															set  @Hour_Sal_Temp = @Day_Sal_Temp * 3600 / @Shift_Day_Sec								
												
															SET @HO_OT_Amount = @HO_OT_Amount + (@Emp_HO_OT_Hours_Num * @Hour_Sal_Temp) * @Emp_HO_OT_Rate										
													END
												END
										IF  @Emp_WO_OT_Hours_Num > 0 
										  BEGIN
											IF @Fix_OT_Work_Days > 0 AND @Shift_Day_Sec > 0
												BEGIN
														set @Day_Sal_Temp = @Temp_Ot_Amt / @Fix_OT_Work_Days
														set  @Hour_Sal_Temp = @Day_Sal_Temp * 3600 / @Shift_Day_Sec								
											
														SET @WO_OT_Amount = @WO_OT_Amount + (@Emp_WO_OT_Hours_Num * @Hour_Sal_Temp) * @Emp_WO_OT_Rate										
												END
											END
										
										
										--Ended

										
										SET @M_AD_AMOUNT = Isnull(@OT_Amount,0) + Isnull(@WO_OT_Amount,0) + Isnull(@HO_OT_Amount,0)

										Set @OT_Amount = 0
										Set @WO_OT_Amount = 0
										Set @HO_OT_Amount = 0
									END   	   	
								Else IF upper(@varCalc_On)='FORMULA'	-- added by mitesh on 28042014
									BEGIN
										Declare @Earning_Gross_I NUMERIC(18, 4)
										Declare @Formula_amount_I NUMERIC(18, 4)	
										set @Earning_Gross_I = 0
										set @Formula_amount_I = 0
										
										Select @Earning_Gross_I=SUM(ISNULL(M_AD_AMOUNT,0)) From dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
											WHERE S_Sal_Tran_ID = @S_Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I'      
											AND AD_ID not in (select AD_ID from dbo.T0050_AD_MASTER WITH (NOLOCK) where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 1)						
										
										Declare @From_Date1 as datetime
										DECLARE @Increment_Eff_Date as datetime
										Select @Increment_Eff_Date = Increment_Effective_Date From T0095_INCREMENT WITH (NOLOCK) Where Increment_ID = @Increment_ID
										
										If @Increment_Eff_Date Between @From_Date And @To_Date
											Set @From_Date1 = @Increment_Eff_Date
										ELSE
											Set @From_Date1 = @From_Date
										
										SET @Earning_Gross_I = @Salary_Amount_Sett + ISNULL(@Earning_Gross_I,0) --+ ISNULL(@OT_Amount,0) + ISNULL(@OT_HO_AMOUNT,0) + ISNULL(@OT_WO_AMOUNT,0)			
									
										If isnull(@Is_Calculate_Zero,0) = 0	--- Hardik 20/12/2017
											exec CALCULATE_AD_AMOUNT_Formula_WISE_Salary  @Cmp_ID,@EMP_ID,@AD_ID,@From_Date1,@Earning_Gross_I,@Salary_Cal_Day_Sett,@Out_Of_Days,@Formula_amount_I output,@Salary_Amount_Sett,@Present_Days,0,@numAbsentDays,1,'',0,@To_Date  --Added by nilesh For Mid Salary Cycle case formula wise calculation is not working on 24112015 
										
										--Commented below line and Added new line by Hardik 17/08/2016 as Kich has problem 
										--set @M_AD_Amount = ISNULL(@Formula_amount_I,0)
										if @Formula_amount_I <> 0
											set @M_AD_Amount = ISNULL(@Formula_amount_I,0) - ISNULL(@Old_M_AD_Amount,0) -- COMMENTED ON 07062018 BY RAJPUT  -- Uncommented by Hardik 18/09/2018 discussed with Rajput / Nimesh
										else
											set @M_AD_Amount = @Formula_amount_I
										
									END
								Else if @Wages_type = 'Monthly'					 
									begin

										If @IsRounding = 1  --Added By Jimit 26062019 for rounding the head amount if is rounding is tick marked in allowance master (case of WCL)
											set @M_AD_Amount =  Round((@M_AD_Amount * @Salary_Cal_Day_Sett)/@Tot_Salary_Day,0) 
										Else
										    set @M_AD_Amount =  (@M_AD_Amount * @Salary_Cal_Day_Sett)/@Tot_Salary_Day 
	
									-- Specific for Wonder -- to zero HRA A Allowance
											--If Exists(Select 1 from t0080_emp_master where emp_id = @Emp_id and Alpha_Emp_Code in ('20635','20971','20574','21346','21385')) And @AD_Id = 54
											--	Set @M_AD_Amount =0
											
											---- Specific for Wonder -- to zero Project Allowance
											--If Exists(Select 1 from t0080_emp_master where emp_id = @Emp_id and Alpha_Emp_Code in ('21413','21434','20883','21170','21568','21341','21346','21611','20635','20985','21058')) And @AD_Id = 56
											--	Set @M_AD_Amount =0

											---- Specific for Wonder -- to zero Deputation Allowance
											--If Exists(Select 1 from t0080_emp_master where emp_id = @Emp_id and Alpha_Emp_Code in ('21413','21434','20883','21170','21568','21341','21346','21611','20635','20985','21058')) And @AD_Id = 29
											--	Set @M_AD_Amount =0
									end
								Else 
									begin
										set @M_AD_Amount =  @M_AD_Amount * @Salary_Cal_Day_Sett 
									end					
							END
					END
				else	---- Start Deduction 
					BEGIN
						--If  @M_AD_Percentage > 0
						If ( @Old_M_AD_Percent <> @M_AD_Percentage) or @M_AD_Percentage > 0   --added by jimit 30122016 after discussion with Hardik Bhai.
							BEGIN
								
									If @IsRounding = 1
											set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0) 
										Else											
											set @M_AD_Amount = (@Calc_On_Allow_Dedu * @M_AD_Percentage / 100) 

											

								--select @Salary_Cal_Day,@Tot_Salary_Day,@Salary_Cal_Day_sett,@Salary_Amount_Sett,@Salary_Amount,@Other_Allow_Amount
								If @PF_DEF_ID = @AD_DEF_ID Or @AD_DEF_ID=4									
								BEGIN
										--set @Calc_On_Allow_Dedu = isnull(@Calc_On_Allow_Dedu,0) - isnull(@Old_Salary_Amount,0)
											Declare @PFArrearAmount as numeric(18,0) = 0
											Declare @TotalPFArrearAmount as numeric(18,0) = 0
											
											
										--Ankit 08012016
										IF @Basic_Salary_Sett = 0
											SET @Calc_On_Allow_Dedu = @PF_Calc_On_Allow_Dedu
								
										--Added by nilesh on 10012017 For Full PF Settelment (Last month PF Deduction in PF Limit & Enter Back Date Increment and Set Full PF Deduction)
										if ((@Old_M_AD_Calculated_Amount = @PF_LIMIT) and isnull(@Emp_Full_PF,0) = 1) --and isnull(@Emp_Full_Pf2,0) = 0 Or (isnull(@Emp_Full_PF,0) = 1 And (@Old_Basic_Salary + @Basic_Salary > @PF_Limit)) --- Change Condition by Hardik 23/02/2021 for WCL
											Begin
												Set @Calc_On_Allow_Dedu = isnull(@Calc_On_Allow_Dedu,0) + (isnull(@Old_Salary_Amount,0) - isnull(@PF_LIMIT,0))
											End
										--Else --- Change Condition by Hardik 23/02/2021 for WCL
										--	Begin
										--		Set @Calc_On_Allow_Dedu = 0
										--	End
										
										-- Added by Hardik 26/02/2021 for WCL
										If @Old_Basic_Salary + @Basic_Salary < @PF_Limit And isnull(@Emp_Full_PF,0) = 1 And @Old_M_AD_Amount = 1800
											Set @Calc_On_Allow_Dedu =0
										else IF @Old_Basic_Salary + @Basic_Salary > @PF_Limit And isnull(@Emp_Full_PF,0) = 1
													set @Calc_On_Allow_Dedu = (@Old_Basic_Salary + @Basic_Salary)
										
										if  isnull(@Emp_Full_PF,0) = 0 and @PF_LIMIT > 0 and isnull(@Calc_On_Allow_Dedu,0) + isnull(@Old_M_AD_Calculated_Amount,0)  > @PF_LIMIT  --and @Calc_On_Allow_Dedu < @PF_LIMIT
											set @Calc_On_Allow_Dedu = @PF_Limit - isnull(@Old_M_AD_Calculated_Amount,0)																
										else if  @Emp_Full_PF = 0 and @PF_LIMIT > 0 and @Old_M_AD_Calculated_Amount > @PF_LIMIT  
											set @Calc_On_Allow_Dedu = 0
										--- For Wonder Specific Condition
										-- old condition before 31-03-2021 Deepal
										--If exists(Select 1 from T0080_Emp_Master Where Emp_Id = @Emp_Id and Alpha_Emp_Code In (20058,20411,20532,20557,20599,20678,20679,20748,20868,20874,20968,20989,20999,21060,21096,21100,21103,21180,21185,21193,21221,21234,21346,21362,21381,21407,21425,21427,21430,21433,21458,21466,21470,21502,21514,21521,21543,21550,21552,21566,21575,21582,21587,21611,21627,21631,21633,21636,21654))
										--	Begin
										--		Set @Calc_On_Allow_Dedu = @Old_Basic_Salary + @Basic_Salary - isnull(@PF_LIMIT,0)
										--	End
										-- old condition before 31-03-2021 Deepal
										
										-- Added by Hardik 26/02/2021 for WCL
										--If @Old_Basic_Salary < @PF_Limit and @Old_Basic_Salary + @Basic_Salary > isnull(@PF_LIMIT,0)
										--Begin
										--	Set @Calc_On_Allow_Dedu = @Old_Basic_Salary + @Basic_Salary - isnull(@PF_LIMIT,0)
										--End
										
										--If @Old_Basic_Salary + @Basic_Salary < @PF_Limit And isnull(@Emp_Full_PF,0) = 1 And @Old_M_AD_Amount = 1800
										--		Set @Calc_On_Allow_Dedu =0
												
										if  isnull(@Emp_Full_PF,0) = 0 and @PF_LIMIT > 0 and isnull(@Calc_On_Allow_Dedu,0) + isnull(@Old_M_AD_Calculated_Amount,0)  > @PF_LIMIT  --and @Calc_On_Allow_Dedu < @PF_LIMIT
										Begin
												set @Calc_On_Allow_Dedu = @PF_Limit - isnull(@Old_M_AD_Calculated_Amount,0)		
										END
										else if  @Emp_Full_PF = 0 and @PF_LIMIT > 0 and @Old_M_AD_Calculated_Amount > @PF_LIMIT  
												set @Calc_On_Allow_Dedu = 0

												
										--IF @Old_Basic_Salary + @Basic_Salary > @PF_Limit And isnull(@Emp_Full_PF,0) = 1 
										--			Set @Calc_On_Allow_Dedu = 0
										--ELSE
										--	Begin
												--If exists(Select 1 from T0080_Emp_Master Where Emp_Id = @Emp_Id and Alpha_Emp_Code In (20058,20411,20532,20557,20599,20678,20679,20748,20868,20874,20968,20989,20999,21060,21096,21100,21103,21180,21185,21193,21221,21234,21346,21362,21381,21407,21425,21427,21430,21433,21458,21466,21470,21502,21514,21521,21543,21550,21552,21566,21575,21582,21587,21611,21627,21631,21633,21636,21654))
												--Begin
												--		Set @Calc_On_Allow_Dedu = @Old_Basic_Salary + @Basic_Salary - isnull(@PF_LIMIT,0)
												--End			
										--	END
										--If exists(Select 1 from T0080_Emp_Master Where Emp_Id = @Emp_Id and Alpha_Emp_Code In (20058,20411,20532,20557,20599,20678,20679,20748,20868,20874,20968,20989,20999,21060,21096,21100,21103,21180,21185,21193,21221,21234,21346,21362,21381,21407,21425,21427,21430,21433,21458,21466,21470,21502,21514,21521,21543,21550,21552,21566,21575,21582,21587,21611,21627,21631,21633,21636,21654))
										--Begin
										--		Set @Calc_On_Allow_Dedu = @Old_Basic_Salary + @Basic_Salary - isnull(@PF_LIMIT,0)
										--End
										
										--ADD New logic add by  Deepal For Wonder New basic - gross - HRA calculation 27-08-2021 only for settlement, PFFFFFFFFFFFF
										
											
										 --Select @M_AD_Amount
										 --Select @M_AD_Amount= isnull(E_AD_AMOUNT,0) from #TBLALLOW where AD_DEF_ID = 2
											--	 Select @M_AD_Amount
											
												--if @Salary_Cal_Day_sett < @Out_Of_Days and @Basic_Salary <> 0
												--Begin 
												--	set @Calc_On_Allow_Dedu = (((isnull(@Old_Basic_Salary,0) + isnull(@Basic_Salary,0))/@Tot_Salary_Day)*@Salary_Cal_Day_sett) - @Old_M_AD_Calculated_Amount
												--END
												--else
												--Begin

												if @Salary_Cal_Day_sett < @Out_Of_Days and @Basic_Salary <> 0 --and @Emp_Full_Pf > 0
												Begin 
													if @Emp_Full_Pf = 0 
														if @Old_M_AD_Calculated_Amount <= 15000  -- Add by Deepal this Condition in RMP with chintan bhai
															set @Calc_On_Allow_Dedu = 15000 - @Old_M_AD_Calculated_Amount 	
														else
															set @Calc_On_Allow_Dedu = (((isnull(@Old_Basic_Salary,0) + isnull(@Basic_Salary,0))/@Out_Of_Days)*@Salary_Cal_Day_sett) - @Old_M_AD_Calculated_Amount
													else
														set @Calc_On_Allow_Dedu = (((isnull(@Basic_Salary,0))/@Out_Of_Days)*@Salary_Cal_Day_sett) 
													--if @Emp_Full_Pf = 0 
													--	set @Calc_On_Allow_Dedu = (((isnull(@Old_Basic_Salary,0) + isnull(@Basic_Salary,0))/@Out_Of_Days)*@Salary_Cal_Day_sett) - @Old_M_AD_Calculated_Amount
													--else
													--	set @Calc_On_Allow_Dedu = (((isnull(@Basic_Salary,0))/@Out_Of_Days)*@Salary_Cal_Day_sett)
												END
												else
												Begin
													--select @Basic_Salary,@Old_M_AD_Calculated_Amount
													if @Basic_Salary < 1800 and @Old_M_AD_Calculated_Amount >= 15000 and @Basic_Salary <> 0  and @Emp_Full_Pf > 0
													begin 
													--select @AD_ID,@M_AD_Percentage,@Old_M_AD_Percent,@AD_Name,@PF_DEF_ID,@AD_DEF_ID,@Calc_On_Allow_Dedu	,@Old_Basic_Salary , @Basic_Salary,@PF_LIMIT,@Calc_On_Allow_Dedu
													--select isnull(@Old_Basic_Salary,0) , isnull(@Basic_Salary,0) , @Old_M_AD_Calculated_Amount
														set @Calc_On_Allow_Dedu = (isnull(@Old_Basic_Salary,0) + isnull(@Basic_Salary,0)) - @Old_M_AD_Calculated_Amount
													end
													else If @Old_M_AD_Calculated_Amount = 15000 and @Emp_Full_Pf > 0
													Begin 
														set @Calc_On_Allow_Dedu = (isnull(@Old_Basic_Salary,0) + isnull(@Basic_Salary,0)) - @Old_M_AD_Calculated_Amount
													END
												END
												--END
										-- New logic add by  Deepal For Wonder New basic - gross - HRA calculation 27-08-2021 only for settlement
											if @Old_M_AD_Calculated_Amount <= 15000
											BEGIN
													set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)

													if @Calc_On_Allow_Dedu < @M_AD_Amount
														set @M_AD_Amount  = @Calc_On_Allow_Dedu
													
											END
											
--										set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)
													Select @PFArrearAmount = ma.M_AREAR_AMOUNT
													From T0200_MONTHLY_SALARY MS inner join T0210_MONTHLY_AD_DETAIL MA on ms.Sal_Tran_ID = ma.Sal_Tran_ID
													Where Arear_Month = Month(@To_Date) and Arear_Year =Year(@to_Date) and  ms.emp_id = @emp_id and ma.AD_ID = @AD_ID
											if @Emp_Full_Pf = 0
												Begin
												

													set @TotalPFArrearAmount = @Old_M_AD_Amount +  @PFArrearAmount 
													
													if @TotalPFArrearAmount >= 1800 and @Emp_Full_Pf = 0
													Begin 
												
														set @M_AD_Amount = 0
													END
													else if @TotalPFArrearAmount < 1800 and @Emp_Full_Pf = 0
													Begin 
														if (1800 -  @TotalPFArrearAmount) < @M_AD_Amount
															set @M_AD_Amount = (1800 -  @TotalPFArrearAmount)
													END
													else
													Begin 
														set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)
													END
												end
												else
												Begin 
													if @Emp_Full_Pf = 1 and @Calc_On_Allow_Dedu > @PF_Limit
													Begin 
														set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0) - (@Old_M_AD_Amount + @PFArrearAmount)
														If @Old_Sal_Cal_Days <> @Salary_Cal_Day_sett And @Tot_Salary_Day >0 
														Begin
															Set @M_AD_Amount = round((@M_AD_Amount / @Tot_Salary_Day) *@Salary_Cal_Day_sett,0)
														End
													END
													else
														set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)
												END
										-- Added by Hardik 26/02/2021 for WCL
										--if (@Old_Basic_Salary + @Basic_Salary < @PF_Limit And @Old_M_AD_Amount <= 1800 And @M_AD_Amount > 1800 - @Old_M_AD_Amount) Or isnull(@Emp_Full_PF,0) = 0
										--	Set @M_AD_Amount = 1800 - @Old_M_AD_Amount

										if @Old_Basic_Salary + @Basic_Salary < @PF_Limit And isnull(@Emp_Full_PF,0) = 1 And @Old_M_AD_Amount < 1800 And @M_AD_Amount > 1800 - @Old_M_AD_Amount
											Set @M_AD_Amount = 1800 - @Old_M_AD_Amount

										
										----Comment by Ankit 30052016 : Case Email Date- Fri, May 27, 2016 at 7:17 PM
										--IF @Emp_Full_PF = 1 AND @Emp_Full_PF2 = 0
										--	SET @M_AD_Amount = @M_AD_Amount - @Old_M_AD_Amount
										
										--IF @M_AD_Amount < 0 SET @M_AD_Amount = 0 --COMMENTED BY HARDIK 02/12/2020 FOR UNISON AS THEY HAVE MINUS PF
										if @Calculate_Full_PF_evenif_Basic_is_above_PF_Limit = 1
												begin
													select @Calc_On_Allow_Dedu = ((@Old_Basic_Salary + @Basic_Salary) * @M_AD_Percentage / 100)
													select @M_AD_Amount = ROUND(@Calc_On_Allow_Dedu - @Old_M_AD_Amount,0)
												end
												
									END
								else if @ESIC_DEF_ID = @AD_DEF_ID
									BEGIN
										
										Declare @ESIC_Count1 numeric(22,2)
												
										select 	@ESIC_Count1=M_Ad_Amount from t0210_monthly_ad_detail WITH (NOLOCK) where Ad_Id=@AD_ID And Emp_Id=@Emp_Id And Month(For_Date)=Month(@From_Date) And Year(For_Date)= Year(@From_Date)
										
										if isnull(@ESIC_Count1,0) > 0
											Begin
												set @M_AD_Amount = ceiling((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100))
											End
										ELSE IF Month(@To_Date) In (4,10) And (@ESIC_Basic + Isnull(@ESIC_Other_Allow_Actual,0) <= @ESIC_Limit) 
											BEGIN
												SET @M_AD_Amount = ceiling((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100))
											END
										ELSE IF @ESIC_Basic + Isnull(@ESIC_Other_Allow_Actual,0) <= @ESIC_Limit
											BEGIN
												DECLARE @sal_tran_id1 NUMERIC(18,0)  
												DECLARE @FROM_TERM DATETIME
												DECLARE @TO_TERM DATETIME
												Declare @Month_End_Date_Mininum datetime
												
												SET  @sal_tran_id1=0  

												IF MONTH(@To_Date) BETWEEN 4 AND 9
													BEGIN								
														SET @FROM_TERM = CAST(YEAR(@To_Date) AS VARCHAR(10)) + '-04-01' 
														SET @TO_TERM = CAST(YEAR(@To_Date) AS VARCHAR(10)) + '-09-30' 
													END
												ELSE
													BEGIN
														IF MONTH(@To_Date) BETWEEN 1 AND 3
															SET @FROM_TERM = CAST((YEAR(@To_Date)-1) AS VARCHAR(10)) + '-10-01' 
														ELSE
															SET @FROM_TERM = CAST(YEAR(@To_Date) AS VARCHAR(10)) + '-10-01' 

														SET @TO_TERM =DATEADD(D,-1, DATEADD(M, 6, @FROM_TERM));
													END
							
												SELECT	TOP 1 @Sal_Tran_ID1=Sal_Tran_ID, @Month_End_Date_Mininum = MS.Month_End_Date
												FROM	dbo.T0200_MONTHLY_SALARY MS WITH (NOLOCK)
												WHERE	Emp_ID=@emp_id AND MS.Cmp_ID=@Cmp_ID AND MS.Month_End_Date BETWEEN @FROM_TERM AND @TO_TERM 
														--AND (sal_tran_id <> @Sal_Tran_ID)
												ORDER BY MS.Month_End_Date ASC

												-- Below Line is commented for Wonder by Deepal 31082021
												--If Month(@Month_End_Date_Mininum) = Month(@To_Date) And Year(@Month_End_Date_Mininum) = Year(@To_Date)
												--	BEGIN
														
												--		SET @M_AD_Amount = ceiling((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100))
												--	END
													SET @M_AD_Amount = ceiling((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100))
											END
										else
											Begin
												set @M_AD_Amount=0
											End	
									END
								else If round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0) > @Max_Upper and @Max_Upper > 0
									begin
										set @M_AD_Amount = @Max_Upper	
									end 	
								Else
									begin
										set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)	
									end
							END
						Else
							BEGIN
								if @IT_DEF_ID = @AD_DEF_ID 
									BEGIN
										IF @IT_TAX_AMOUNT > 0 
											SET @M_AD_Amount = @IT_TAX_AMOUNT
									END 
								else If upper(@varCalc_On) ='FIX'
									Begin
										set @M_AD_Amount =  @M_AD_Amount
									End
								Else IF UPPER(@VARCALC_ON) ='FIX + JOINING PRORATE' -- Added by Hardik 25/01/2019
									BEGIN
										IF (@JOIN_DATE >= @From_Date  AND @JOIN_DATE <= @To_Date)
											BEGIN
												SET @M_AD_AMOUNT = ROUND((@M_AD_AMOUNT * (DATEDIFF(day,@JOIN_DATE,@To_Date) + 1))/@OUT_OF_DAYS,0)
											END
										ELSE IF (@LEFT_DATE >= @From_Date  AND @LEFT_DATE <= @To_Date)
											BEGIN
												SET @M_AD_AMOUNT = ROUND((@M_AD_AMOUNT * (DATEDIFF(day,@From_Date,@LEFT_DATE) + 1))/@OUT_OF_DAYS,0)
											END
										ELSE
											BEGIN
												SET @M_AD_AMOUNT=@M_AD_AMOUNT							
											END
									END   	   	
								Else IF upper(@varCalc_On)='FORMULA'	-- added by mitesh on 28042014
									Begin
										
										Declare @Earning_Gross NUMERIC(18, 4)
										Declare @Formula_amount NUMERIC(18, 4)	
										set @Earning_Gross = 0
										set @Formula_amount = 0
										Select @Earning_Gross=SUM(ISNULL(M_AD_AMOUNT,0)) From dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
											WHERE S_Sal_Tran_ID = @S_Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I'      
											AND AD_ID not in (select AD_ID from dbo.T0050_AD_MASTER WITH (NOLOCK) where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 1)						
										
										SET @Earning_Gross = @Salary_Amount_Sett + ISNULL(@Earning_Gross,0) --+ ISNULL(@OT_Amount,0) + ISNULL(@OT_HO_AMOUNT,0) + ISNULL(@OT_WO_AMOUNT,0)			
										
										exec CALCULATE_AD_AMOUNT_Formula_WISE_Salary  @Cmp_ID,@EMP_ID,@AD_ID,@From_Date,@Earning_Gross,@Salary_Cal_Day_Sett,@Out_Of_Days,@Formula_amount output,@Salary_Amount,@Present_Days,0,@numAbsentDays,1--,@To_Date  --Added by nilesh For Mid Salary Cycle case formula wise calculation is not working on 24112015 

										--Commented below line and Added new line by Hardik 17/08/2016 as Kich has problem 
										--set @M_AD_Amount = ISNULL(@Formula_amount,0)
										set @M_AD_Amount = ISNULL(@Formula_amount,0) - ISNULL(@Old_M_AD_Amount,0)
										
										
									End 
								Else if @Wages_type = 'Monthly'					
									Begin
										set @M_AD_Amount =  (@M_AD_Amount * @Salary_Cal_Day_Sett)/@Tot_Salary_Day 
									End
								Else 
									Begin
										set @M_AD_Amount =  (@M_AD_Amount * @Salary_Cal_Day_Sett) 
									End	
							END
					END

					--If  @M_AD_Percentage > 0 and @PF_DEF_ID <> @AD_DEF_ID And @ESIC_DEF_ID <> @AD_DEF_ID And @Old_M_AD_Percent <> @M_AD_Percentage and @EPF_DEF_ID <> @AD_DEF_ID and @CPF_DEF_ID <> @AD_DEF_ID  -- Changed by Gadriwala Muslim 23072015
					--if @PF_DEF_ID <> @AD_DEF_ID And @ESIC_DEF_ID <> @AD_DEF_ID AND @AD_DEF_ID <> 4  And( @Old_M_AD_Percent <> @M_AD_Percentage )  and @EPF_DEF_ID <> @AD_DEF_ID and @CPF_DEF_ID <> @AD_DEF_ID  -- Old Condition commenting By deepal 26082021 Removing the VPF def Id
					if @PF_DEF_ID <> @AD_DEF_ID And @ESIC_DEF_ID <> @AD_DEF_ID  And( @Old_M_AD_Percent <> @M_AD_Percentage )  and @EPF_DEF_ID <> @AD_DEF_ID and @CPF_DEF_ID <> @AD_DEF_ID  
					Begin
							If @IsRounding = 1
								set @M_AD_Amount = round(@M_AD_Amount - Isnull(@Old_M_AD_Amount,0) ,0)  --Old amount Minus added by Hardik 13/06/2012 for Increment on Percentage also
							Else
								set @M_AD_Amount = @M_AD_Amount - Isnull(@Old_M_AD_Amount,0) --Old amount Minus added by Hardik 13/06/2012 for Increment on Percentage also
							
							-- for WCL
							--If @AD_id = 1 and @Emp_Id = 1170
							--	Set @M_AD_Amount = 339
						End
					
					IF UPPER(@varCalc_On)='IMPORT'	--Ankit 01122015 /* While Import Allowance Amount Set In Employee master salary structure */
						BEGIN
							IF (@Old_M_AD_Amount = 0 OR Exists(SELECT 1 FROM dbo.T0190_Monthly_AD_Detail_import WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND AD_ID =@AD_ID AND MONTH = MONTH(@To_Date) AND YEAR = YEAR(@To_Date) ))
								SET @M_AD_Amount = 0
						END
					 
					 	IF UPPER(@varCalc_On)='FIX' AND @Old_M_AD_Amount <> 0 	--Ankit 27072016 /* Fix Allowance Should not be calcualte */added by jimit as it had nbeen added at client side but remaining here.
						BEGIN
							SET @M_AD_Amount = 0
						END
					----------for Selected Month---------------------------------------- /* For Effected Month Allowance Get And else Set '0' */
					IF @AD_Effect_Month <> '' AND CHARINDEX(@StrMonth,@AD_Effect_Month) = 0 AND ISNULL(@AD_CAL_TYPE,'')='' 
						BEGIN  
							SET @M_AD_Amount = 0  
						END  
					--------------------------------------------------------------------

					
				--Added By Jimit 31072018
					  IF @Auto_Paid = 1
								BEGIN
								      IF @AD_CAL_TYPE = 'Quaterly' AND (Month(@To_Date) = 3  or 	Month(@To_Date) = 6 or Month(@To_Date) = 9 or Month(@To_Date) = 12)						
											BEGIN		
												SET @ReimShow = 1											
											END
									  ELSE IF @AD_CAL_TYPE = 'Monthly'
											BEGIN																			 													
												SET @ReimShow = 1									  									 
											END
									ELSE IF @AD_CAL_TYPE = 'Half Yearly' AND ((Month(@To_Date) = 3 and year(@To_Date) = Year(DATEADD(YEAR,0,@To_Date))) or Month(@To_Date) = 9 )
											BEGIN
												SET @ReimShow = 1											
											END
									ELSE IF @AD_CAL_TYPE = 'Yearly' and ((Month(@To_Date) = 3 and year(@To_Date) = Year(DATEADD(YEAR,0,@To_Date))) )
											BEGIN
												SET @ReimShow = 1
											END
									ELSE
											BEGIN
												SET @ReimShow = 1
											END
									END

					--ended

Insert_Record:
					SELECT @M_AD_Tran_ID = ISNULL(MAX(M_AD_Tran_ID),0) + 1 FROM T0210_MONTHLY_AD_DETAIL  WITH (NOLOCK) 
				--	SET @M_AD_Amount = ROUND(@M_AD_Amount,0)
				
			
			
					INSERT INTO T0210_MONTHLY_AD_DETAIL
					                     (M_AD_Tran_ID, Sal_Tran_ID,S_Sal_Tran_ID,Emp_ID, Cmp_ID, AD_ID, For_Date, M_AD_Percentage, M_AD_Amount, M_AD_Flag, M_AD_Actual_Per_Amount, 
					                      M_AD_Calculated_Amount,M_AD_NOT_EFFECT_ON_PT,M_AD_NOT_EFFECT_SALARY,M_AD_EFFECT_ON_OT,M_AD_EFFECT_ON_EXTRA_DAY,Sal_Type,to_date,ReimShow)
					VALUES     (@M_AD_Tran_ID,@Sal_Tran_ID, @S_Sal_Tran_ID, @Emp_ID, @Cmp_ID, @AD_ID, @From_Date, @M_AD_Percentage, @M_AD_Amount, @M_AD_Flag, @M_AD_Actual_Per_Amount, 
					                      @Calc_On_Allow_Dedu,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY,1,@to_date,@ReimShow)
					                    
				

				fetch next from CurAD_Sett into @AD_ID,@M_AD_Percentage,@M_AD_Amount,@M_AD_Flag,@Max_Upper,@varCalc_On,@AD_DEF_ID,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY ,@AD_Name,@AD_Effect_Month,@AD_CAL_TYPE,@E_AD_Mode,@Is_Calculate_Zero,@Auto_Paid,@Prorata_On_Salary_Structure,@IsRounding
			end
	close CurAD_Sett
	deallocate CurAD_Sett

	
--select @Salary_Cal_Day  as sal_d
	--if @Salary_Cal_Day > 0 
	--	begin
	--			declare curAD cursor for
	--				select EED.AD_ID,E_AD_Percentage,E_AD_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,
	--						isnull(AD_NOT_EFFECT_ON_PT,0),Isnull(AD_NOT_EFFECT_SALARY,0),isnull(AD_EFFECT_ON_OT,0),isnull(AD_EFFECT_ON_EXTRA_DAY,0) 
	--						,AD_Name
	--				From T0100_EMP_EARN_DEDUCTION EED inner join
	--					T0050_AD_MASTER ADM  on EEd.AD_ID = ADM.AD_ID 
	--					where emp_id = @emp_id and increment_id = @Increment_Id	
	--				order by AD_LEVEL, E_AD_Flag desc
	--			open curAD		
	--				fetch next from curAD into @AD_ID,@M_AD_Percentage,@M_AD_Amount,@M_AD_Flag,@Max_Upper,@varCalc_On,@AD_DEF_ID,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY ,@AD_Name
	--				while @@fetch_status = 0
	--					begin
							
	--							set @Old_M_AD_Calculated_Amount	 =0
	--							set @Old_M_AD_Amount =0
	--							select @Old_M_AD_Calculated_Amount	 = isnull(sum(M_AD_Calculated_Amount),0)	 
	--									,@Old_M_AD_Amount = isnull(sum(M_AD_Amount),0)	  
	--							From T0210_MONTHLY_AD_DETAIL Where AD_ID =@AD_ID
	--							and For_Date >=@From_Date and For_Date <=@To_Date and Emp_ID = @Emp_Id 
	--							--change by Falak on 29-SEP-2010 condition added of checking emp_id

							
	--						If @varCalc_On ='Gross Salary'	or @varCalc_On ='Actual Gross'
	--							set @Calc_On_Allow_Dedu = @Gross_Salary_ProRata
	--						Else If @varCalc_On ='Basic Salary'	
	--							set @Calc_On_Allow_Dedu = @Salary_Amount
	--						Else 
	--							set @Calc_On_Allow_Dedu = @Basic_Salary
							
	--						--select @Calc_On_Allow_Dedu as cal
	--						if @M_AD_Percentage > 0 
	--							set @M_AD_Actual_Per_Amount = @M_AD_Percentage
	--						else
	--							set @M_AD_Actual_Per_Amount = @M_AD_Amount


	--						set @Other_Allow_Amount = 0

	--						select @Other_Allow_Amount = isnull(sum(M_AD_amount),0)  from T0210_MONTHLY_AD_DETAIL
	--						where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID 
	--						and S_Sal_Tran_ID = @S_Sal_Tran_ID and isnull(Sal_Type,0) =2
	--						and For_Date >=@From_Date and For_Date <=@To_Date
	--						and AD_ID in 
	--						(select AD_ID  from T0060_EFFECT_AD_MASTER 
	--						where Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID )
							
	--						set @Calc_On_Allow_Dedu = isnull(@Calc_On_Allow_Dedu,0) + isnull(@Other_Allow_Amount ,0)

	--						if @M_AD_Flag = 'I'
	--							begin
									
	--								If  @M_AD_Percentage > 0
	--										begin
	--											if round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0) > @Max_Upper and @Max_Upper > 0
	--												begin
	--													set @M_AD_Amount = @Max_Upper	
	--												end	
	--											else		
	--												begin
	--													If @Is_Rounding = 1
	--														set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)	
	--													else
	--														set @M_AD_Amount = (@Calc_On_Allow_Dedu * @M_AD_Percentage / 100)
	--												end
	--										end	
	--								Else
	--										begin
	--											If upper(@varCalc_On) ='FIX' 
	--												begin
	--														set @M_AD_Amount =  @M_AD_Amount - @Old_M_AD_Amount
	--												end
	--											Else if @Wages_type = 'Monthly'					 
	--													begin
	--														set @M_AD_Amount =  (@M_AD_Amount * @Salary_Cal_Day)/@Tot_Salary_Day 
	--													end
	--											Else 
	--													begin
	--														set @M_AD_Amount =  @M_AD_Amount * @Salary_Cal_Day 
	--													end					
	--											End	
	--									end
	--								else	---- Start Deduction 
	--									begin
	--										If  @M_AD_Percentage > 0
	--											Begin
												
	--													If @PF_DEF_ID = @AD_DEF_ID
	--														Begin	
	--															--if  @Emp_Full_PF = 0 and @PF_LIMIT > 0 and @Calc_On_Allow_Dedu + @Old_M_AD_Calculated_Amount  > @PF_LIMIT  and @Calc_On_Allow_Dedu < @PF_LIMIT
	--															--	set @Calc_On_Allow_Dedu = @PF_Limit - @Old_M_AD_Calculated_Amount
	--	 													--	else if  @Emp_Full_PF = 0 and @PF_LIMIT > 0 and @Old_M_AD_Calculated_Amount > @PF_LIMIT  
	--	 													--		set @Calc_On_Allow_Dedu = 0
	--	 													--select @Old_M_AD_Amount as old
	--	 													--CHANGE BY FALAK ON 29-SEP-2010 FOR CALCULATING DEDUCTION IF SALARY FOR GIVEN MONTH IS NOT GENERATED
	--	 													if @Old_M_AD_Amount > 0
	--														begin
	--															if  @Emp_Full_PF = 1 and @PF_LIMIT > 0 and @Calc_On_Allow_Dedu + @Old_M_AD_Calculated_Amount  > @PF_LIMIT  --and @Calc_On_Allow_Dedu < @PF_LIMIT
	--																set @Calc_On_Allow_Dedu = @PF_Limit - @Old_M_AD_Calculated_Amount
	--	 														else if  @Emp_Full_PF = 0 and @PF_LIMIT > 0 and @Old_M_AD_Calculated_Amount > @PF_LIMIT  
	--	 															set @Calc_On_Allow_Dedu = 0
	--														end
	--														else
	--														begin
	--															if  @Emp_Full_PF = 1 and @PF_LIMIT > 0 and @Calc_On_Allow_Dedu + @Old_M_AD_Calculated_Amount  > @PF_LIMIT  and @Calc_On_Allow_Dedu < @PF_LIMIT
	--																set @Calc_On_Allow_Dedu = @PF_Limit - @Old_M_AD_Calculated_Amount
	--	 														else if  @Emp_Full_PF = 0 and @PF_LIMIT > 0 
	--	 															set @Calc_On_Allow_Dedu = @PF_Limit - @Old_M_AD_Calculated_Amount
	--														end
					 											
	--															set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)
	--														End
	--													else if @ESIC_DEF_ID = @AD_DEF_ID
	--														BEGIN
	--															Declare @ESIC_Count numeric(22,2)
	--															select 	@ESIC_Count=M_Ad_Amount from t0210_monthly_ad_detail where Ad_Id=@AD_ID And Emp_Id=@Emp_Id And Month(For_Date)=Month(@From_Date) And Year(For_Date)= Year(@From_Date)
	--															if isnull(@ESIC_Count,0) > 0
	--																Begin
	--																	set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0,1)
	--																End
	--															else
	--																Begin
	--																	set @M_AD_Amount=0
	--																End	
																	
																	
	--														END
	--													else If round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0) > @Max_Upper and @Max_Upper > 0
	--														begin
	--															set @M_AD_Amount = @Max_Upper	
	--														end 	
	--													Else
	--														begin
	--															set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)	
	--														end
	--											End	
	--										Else
	--											begin
	--												if @IT_DEF_ID = @AD_DEF_ID 
	--													BEGIN
	--														IF @IT_TAX_AMOUNT > 0 
	--															SET @M_AD_Amount = @IT_TAX_AMOUNT
	--													END 
	--												else If upper(@varCalc_On) ='FIX'
	--													Begin
	--														set @M_AD_Amount =  @M_AD_Amount - @Old_M_AD_Amount
	--													End
	--												Else if @Wages_type = 'Monthly'					
	--													Begin
	--														set @M_AD_Amount =  (@M_AD_Amount * @Salary_Cal_Day)/@Tot_Salary_Day 
	--													End
	--												Else 
	--													Begin
	--														set @M_AD_Amount =  (@M_AD_Amount * @Salary_Cal_Day) 
	--													End	
	--											End	
	--									End
							
	--							if @M_AD_Percentage =0	and (@M_AD_Actual_Per_Amount - (@M_AD_Amount + @Old_M_AD_Amount))between -2 and 2
	--								begin
	--									set @M_AD_Amount   =@M_AD_Amount   + ( @M_AD_Actual_Per_Amount - (@M_AD_Amount + @Old_M_AD_Amount))
	--								end

	--						if @AD_DEF_ID = @Join_Time_Def_ID 
	--							begin
	--								 if Month(@From_Date) <> Month(@Join_Date) or year(@From_Date) <> year(@Join_Date)	
	--									begin
	--										set @M_AD_Amount =0 
	--									end
	--							end

								
	--							SELECT @M_AD_Tran_ID = ISNULL(MAX(M_AD_Tran_ID),0) + 1 FROM T0210_MONTHLY_AD_DETAIL   
	--						--	SET @M_AD_Amount = ROUND(@M_AD_Amount,0)
								
	--							INSERT INTO T0210_MONTHLY_AD_DETAIL
	--												 (M_AD_Tran_ID,Sal_Tran_ID, S_Sal_Tran_ID,Emp_ID, Cmp_ID, AD_ID, For_Date, M_AD_Percentage, M_AD_Amount, M_AD_Flag, M_AD_Actual_Per_Amount, 
	--												  M_AD_Calculated_Amount,M_AD_NOT_EFFECT_ON_PT,M_AD_NOT_EFFECT_SALARY,M_AD_EFFECT_ON_OT,M_AD_EFFECT_ON_EXTRA_DAY,Sal_Type)
	--							VALUES     (@M_AD_Tran_ID,@Sal_Tran_ID, @S_Sal_Tran_ID, @Emp_ID, @Cmp_ID, @AD_ID, @From_Date, @M_AD_Percentage, @M_AD_Amount, @M_AD_Flag, @M_AD_Actual_Per_Amount, 
	--												  @Calc_On_Allow_Dedu,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY,2)
								                    
	--						fetch next from curAD into @AD_ID,@M_AD_Percentage,@M_AD_Amount,@M_AD_Flag,@Max_Upper,@varCalc_On,@AD_DEF_ID,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY ,@AD_Name
	--					end
	--			close curAD
	--			deallocate curAD
	--	end
	 
	RETURN



