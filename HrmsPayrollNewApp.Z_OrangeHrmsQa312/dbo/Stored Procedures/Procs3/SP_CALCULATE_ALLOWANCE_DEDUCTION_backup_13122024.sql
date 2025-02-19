create PROCEDURE [dbo].[SP_CALCULATE_ALLOWANCE_DEDUCTION_backup_13122024]
	  @Sal_Tran_ID   NUMERIC, -- Normal Salary Generation                    
	  @Emp_Id     NUMERIC ,                    
	  @Cmp_ID     NUMERIC ,                    
	  @Increment_ID   NUMERIC ,                    
	  @From_Date    DATETIME,                    
	  @To_Date    DATETIME,                    
	  @Wages_type    VARCHAR(10),                    
	  @Basic_Salary   NUMERIC(25,5),                    
	  @Gross_Salary_ProRata NUMERIC(25,5),                    
	  @Salary_Amount   NUMERIC(25,5),                    
	  @Present_Days   NUMERIC(18,3),                    
	  @numAbsentDays   NUMERIC(18,3) ,                    
	  @Leave_Days    NUMERIC(18,1),                    
	  @Salary_Cal_Day   NUMERIC(18, 4),                    
	  @Tot_Salary_Day   NUMERIC(18, 4),                    
	  @OT_Amount    NUMERIC(18, 4) OUTPUT,                    
	  @Day_Salary    NUMERIC(12,5),                    
	  @Branch_ID    NUMERIC ,                    
	  @IT_TAX_AMOUNT   NUMERIC ,                    
	  @L_Sal_Tran_ID   NUMERIC = NULL ,-- Leave Salary Generation                    
	  @late_Extra_Days     NUMERIC(18,1)=0,
	  @Allo_On_Leave NUMERIC(18,0)=1,    
	  @Out_Of_Days  NUMERIC(18,0)=0 , 
	  @Areas_dAYS NUMERIC(18, 4) =0   ,
	  @IS_ROUNDING NUMERIC(1,0)    ,
	  @OT_WO_AMOUNT   NUMERIC(18, 4) = 0 OUTPUT ,                           
	  @OT_HO_AMOUNT   NUMERIC(18, 4) = 0 OUTPUT ,
	  @Actual_Start_Date DATETIME = NULL,
	  @Actual_End_Date DATETIME = NULL,
	  @Arear_Days NUMERIC(18, 4)=0, --Hardik 07/01/2012
	  @Arear_Month NUMERIC(18, 4)=0,--Hardik 07/01/2012
	  @Arear_Year NUMERIC(18, 4)=0, --Hardik 07/01/2012
	  @Arear_Basic NUMERIC(18, 4)=0, --Hardik 31/05/2013
	  @No_of_increment numeric(18) = 0, -- added by mitesh on 21052014
	  @Working_days_Arear NUMERIC(18, 4) = 0  --Hardik 21/05/2014
	  ,@Absent_after_Cutoff_date NUMERIC(18, 4) = 0,
	  @Arear_Month_cutoff Numeric (18,0) =0,
	  @Arear_Year_cutoff numeric (18,0)=0,
	  @Salary_amount_Arear_cutoff NUMERIC(18, 4)=0,
	  @Working_days_Arear_cutoff NUMERIC(18, 4)=0,
	  @CA_OT_Amount Numeric(18,2) = 0, -- Added by Jaina 08-09-2016
	  @CutoffDate_Salary datetime = null, --Added by Rajput on 08122017
	  @Night_Shift_Count Numeric = 0, -- Added by nilesh on 01082018 -- For Enpay Client -- Nightshift Count Calculation 
	  @Shift_Wise_OT_Rate tinyint = 0, -- Added by Hardik 22/11/2018 for Shoft Ship Yard Client
	  @Actual_Working_Sec numeric = 0, -- Added by Hardik 22/12/2020 for Kaypee client
	  @Present_On_Holiday numeric = 0 -- Added by Hardik 22/12/2020 for Kaypee client
	  ,@Other_Working_Sec numeric =0 -- Added by Sajid 29/01/2022 for Tanvi client	  
	  ,@late_day_cutoff numeric(18,2) = 0.0 -- added by tejas 
	  ,@Early_day_cutoff numeric(18,2) = 0.0 
	AS                    
		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
		
		

		IF ISNULL(@Actual_Start_Date,0) = 0
			SET @Actual_Start_Date  = @From_Date     
			
		IF ISNULL(@Actual_End_Date ,0) = 0
			SET @Actual_End_Date  = @To_Date                    
		 
		DECLARE @AD_DEF_ID   INT                    
		DECLARE @IT_DEF_ID   INT                    
		DECLARE @PF_DEF_ID   INT                    
		DECLARE @ESIC_DEF_ID  INT                     
		DECLARE @Cmp_PF_DEF_ID   INT                    
		DECLARE @Cmp_ESIC_DEF_ID  INT  
		DECLARE @AREAR_PF_DEF_ID  INT   --Added by Hardik 09/07/2013
		DECLARE @VPF_DEF_ID	INT  --Added by Hasmukh 18/07/2013
		DECLARE @GPF_DEF_ID	INT	--Added By Nimesh 17-Jul-2015 (For Additional GPF Deduction)
		DECLARE @DA_DEF_ID		INT	--Ankit 13082015
		DECLARE @Bonus_DEF_ID   INT --Ankit 01042016
		DECLARE @CAR_RETENTION_DEF_ID INT 
		DECLARE @BOND_RETURN_DEF_ID INT -- ADDED BY RAJPUT ON 02112018
		DECLARE @COMPANY_LWF_DEF_ID INT --Hardik 04/12/2018 for Competent Client
		DECLARE @Is_Emp_LWF tinyint --Hardik 04/12/2018 for Competent Client
		Set @Is_Emp_LWF = 0

		DECLARE @DA_AMOUNT NUMERIC(18,4)
		SET @DA_AMOUNT = 0
		DECLARE @DA_AMOUNT_EARNING NUMERIC(18,4)
		SET @DA_AMOUNT_EARNING = 0
		
		
		DECLARE @BASIC_SALARY_PF NUMERIC(18,4) --Hardik 13/05/2020
		DECLARE @DA_AMOUNT_PF NUMERIC(18,4) --Hardik 13/05/2020

		DECLARE @CTC NUMERIC(18, 4)
		DECLARE @Join_Time_Def_ID INT    
		Declare @Claim_Deduction_Amount Numeric(18,2) = 0  --Added by Jaina 13-10-2020


		SET @CTC = 0	                      
		SET @IT_DEF_ID = 1                    
		SET @PF_DEF_ID = 2                    
		SET @ESIC_DEF_ID = 3      
		SET @VPF_DEF_ID = 4
		SET @Cmp_PF_DEF_ID  = 5                    
		SET @Cmp_ESIC_DEF_ID  =6
		SET @AREAR_PF_DEF_ID = 7
		SET @GPF_DEF_ID = 14
		SET @DA_DEF_ID = 11
		SET	@Bonus_DEF_ID = 19
		SET @Join_Time_Def_ID = 101
		SET @CAR_RETENTION_DEF_ID = 23          
		SET @BOND_RETURN_DEF_ID = 29 -- ADDED BY RAJPUT ON 02112019  
		SET @COMPANY_LWF_DEF_ID = 30           
		                  
		DECLARE @AD_ID      NUMERIC                    
		DECLARE  @Late_Mode AS VARCHAR(50)                  
		DECLARE  @Late_Scan AS VARCHAR(50)                  
		DECLARE  @Tmp_amount AS NUMERIC(18, 4)  
		DECLARE @P_Days AS NUMERIC(18, 4)
		--DECLARE @Out_Of_Days as NUMERIC(18, 4)   
		SET @P_Days= 0
		--SET @Out_Of_Days=0

		DECLARE @Total_M_AD_Amount_Arears    NUMERIC(22,5)                                  
		DECLARE @M_AD_Percentage   NUMERIC(18,5)      -- Changed by Gadriwala Muslim 19032015              
		DECLARE @M_AD_Amount    NUMERIC(18,5)                    
		DECLARE @M_AD_Flag     VARCHAR(1)                    
		DECLARE @Max_Upper     NUMERIC(27,5)                    
		DECLARE @varCalc_On     VARCHAR(50)                    
		DECLARE @Calc_On_Allow_Dedu   NUMERIC(18, 4)                     
		DECLARE @Other_Allow_Amount   NUMERIC(18, 4)  
		DECLARE @ESIC_Calculate_Amount NUMERIC(18, 4)                  
		DECLARE @M_AD_Actual_Per_Amount  NUMERIC(18,5)      -- Changed by Gadriwala Muslim 19032015              
		DECLARE @Temp_Percentage NUMERIC(18,5)     -- Changed by Gadriwala Muslim 19032015               
		DECLARE @Type    VARCHAR(20)                    
		DECLARE @M_AD_Tran_ID  NUMERIC                    
		DECLARE @PF_Limit   NUMERIC                     
		DECLARE @Emp_Full_Pf  NUMERIC                     
		DECLARE @ESIC_Limit   NUMERIC                     
		DECLARE @M_AD_NOT_EFFECT_ON_PT  NUMERIC(1,0)                    
		DECLARE @M_AD_NOT_EFFECT_SALARY  NUMERIC(1,0)                    
		DECLARE @M_AD_EFFECT_ON_OT   NUMERIC(1,0)                    
		DECLARE @M_AD_EFFECT_ON_EXTRA_DAY NUMERIC(1,0)                    
		DECLARE @M_AD_effect_on_Late  INT   
		DECLARE @AD_Effect_Month      VARCHAR(50)     
		DECLARE @StrMonth VARCHAR(5)          
		--                    
		DECLARE @PaySlip_Tran_ID   NUMERIC                     
		DECLARE @Allowance_Data    VARCHAR(8000)                    
		DECLARE @Deduction_Data    VARCHAR(8000)                    
		DECLARE @AD_Name     VARCHAR(50)                    
		DECLARE @Join_Date     DATETIME                    
		DECLARE @OT_Basic_Salary	NUMERIC(18, 4)
		DECLARE @ESIC_Basic_Salary NUMERIC(18, 4)
		DECLARE @Shift_Day_Sec		INT
		DECLARE @OT_Sec			NUMERIC
		DECLARE @WO_OT_Sec			NUMERIC
		DECLARE @HO_OT_Sec			NUMERIC
		DECLARE @Ex_OT_Setting		NUMERIC(18, 4)
		DECLARE @OT_Working_Day	NUMERIC(4,1)
		DECLARE @E_Ad_Amount NUMERIC(18, 4)
		DECLARE @AD_CAL_TYPE VARCHAR(20) 
		DECLARE @AD_EFFECT_FROM VARCHAR(15) 
		DECLARE @PERFORM_POINTS NUMERIC(18, 4)
		DECLARE @Gr_Salary AS NUMERIC(18, 4)
		DECLARE @Emp_Ot_Hours NUMERIC(18, 4)
		DECLARE @Hourly_Salary NUMERIC(18,5)
		Declare @EMP_MAX_OT_IN_HOURS NUMERIC(18,2) --Added By Ramiz on 04/05/2016
		
		DECLARE @IS_NOT_EFFECT_ON_LWP NUMERIC(1,0) 
		DECLARE @Salary_Cal_Day_LWP NUMERIC(18,3)
		DECLARE @Salary_Amount_LWP NUMERIC(25,5)

		DECLARE @Emp_WD_OT_Rate NUMERIC(5,3)
		DECLARE @Emp_WO_OT_Rate NUMERIC(5,3)
		DECLARE @Emp_HO_OT_Rate NUMERIC(5,3)

		DECLARE @IS_ROUNDING_Allowance int -- Added by rohit on 30072015
		DECLARE @IS_ROUNDING_temp int
		SET @IS_ROUNDING_temp = @IS_ROUNDING
		declare @After_Salary tinyint = 0 --Added by Jaina 11-09-2017


		--- ADDED BY RAJPUT ON 13072018 ---
		DECLARE @OT_RATE_TYPE AS TINYINT = 0 
	    DECLARE @OT_SLAB_TYPE AS TINYINT = 0 
		DECLARE @GEN_ID NUMERIC 
		DECLARE @EMP_OT_HOURS_NUM AS NUMERIC(18, 4)
		DECLARE @EMP_WO_OT_HOURS_NUM AS NUMERIC(22,3)
		DECLARE @EMP_HO_OT_HOURS_NUM AS NUMERIC(22,3)
		DECLARE @FIX_OT_SHIFT_SEC  NUMERIC    
		DECLARE @SHIFT_HOURS_NUM AS NUMERIC(18, 4)
		--- END ---
		
		--Added By Hardik 12/08/2013 for Azure Client
		DECLARE @Split_Shift_Count Numeric
		DECLARE @Split_Shift_Date Varchar(3000)
		SET @Split_Shift_Count = 0
		SET @Split_Shift_Date  = ''

		DECLARE @Effect_OT_IN_ESIC TINYINT -- added by mitesh on 07082012
		DECLARE @Calc_On_Allow_Dedu_Actual   NUMERIC(18, 4)                     
		DECLARE @Salary_Amount_actual   NUMERIC(25,5)                 
		DECLARE @Allow_Amount_actual   NUMERIC(18, 4)    
		DECLARE @ESIC_Basic_Salary_actual    NUMERIC(18, 4)    
		DECLARE @Other_Allow_Amount_actual   NUMERIC(18, 4) 
		DECLARE @Emp_Auto_VPF tinyint  --Added by Hasmukh 18/07/2013
		DECLARE @PF_Percentage NUMERIC(18, 4) --Added by Hasmukh 18/07/2013

		DECLARE @Is_ESIC tinyint --added by Hardik 26/10/2015
		SET @Is_ESIC = 0

		DECLARE @Allowance_type varchar(10) --Added by Hasmukh 18/07/2013
		DECLARE @ReimShow as tinyint
		DECLARE @AutoPaid as tinyint
		DECLARE @Other_Allow_Amount_mid as NUMERIC(18, 4)

		DECLARE @Total_M_AD_Amount_Arears_cutoff    NUMERIC(22,5)     -- Added by rohit on 13012015
		DECLARE @Other_Allow_Amount_Arear_cutoff as NUMERIC(18, 4) 
		SET @Other_Allow_Amount_Arear_cutoff = 0
		
		DECLARE @Mini_Wages		NUMERIC(18,2)	--Ankit 01042016
		DECLARE @SkillType_ID	NUMERIC
		Declare @Max_Bonus_Salary_Amount as Numeric(18,2)	
		
		Declare @Is_Calculate_Zero tinyint --Hardik 27/10/2017
		Set @Is_Calculate_Zero = 0

		Declare @Prorata_On_Salary_Structure tinyint --Hardik 27/07/2018 for Formula based allowance for Lubi
		Set @Prorata_On_Salary_Structure = 0

		
		SET @Mini_Wages = 0
		SET @SkillType_ID =  0
		SET @Max_Bonus_Salary_Amount = 0
		
		DECLARE @Salary_Depends_on_Production tinyint
		DECLARE @Production_Based_Salary tinyint
		
		SET @Salary_Depends_on_Production = 0
		SET @Production_Based_Salary = 0
		
		SELECT @Salary_Depends_on_Production =Isnull(Salary_Depends_on_Production,0),@SkillType_ID = SkillType_ID, @Is_Emp_LWF = Isnull(Is_LWF,0)  
		FROM T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_Id

		IF EXISTS (SELECT TOP 1 1 FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Salary_Depends_on_Production = 1 AND CMP_ID = @CMP_ID)	--this query will check that even if single employee of production based Salary exists or NOT.
			SET @Production_Based_Salary = 1
		
		SET @ReimShow =0
		SET @AutoPaid =0
		SET @Other_Allow_Amount_mid = 0 
		--Hardik 07/02/2013
		DECLARE @PF_Max_Amount NUMERIC(18, 4)
		SET @PF_Max_Amount = 0

		DECLARE @Other_Allow_Amount_Arear as NUMERIC(18, 4) ---Hardik 31/05/2013
		SET @Other_Allow_Amount_Arear = 0

		SET @Effect_OT_IN_ESIC = 0

		SET @Total_M_AD_Amount_Arears = 0   
		SET @Calc_On_Allow_Dedu = 0.0                    
		SET @Late_Scan=''                
		SET @varCalc_On = ''                    
		SET @Late_Scan=''                  
		SET @Other_Allow_Amount = 0     
		SET @ESIC_Calculate_Amount=0               
		SET @Calc_On_Allow_Dedu = 0.0                    
		SET @varCalc_On = ''                    
		SET @PF_Limit = 0                    
		SET @Emp_Full_Pf =0                     
		SET @ESIC_Limit = 0                    
		SET @PaySlip_Tran_ID = 0                    
		SET @StrMonth = '#' + CAST(MONTH(@To_datE) AS VARCHAR(2)) + '#'  
		SET @Gr_Salary =0

		SET @IS_NOT_EFFECT_ON_LWP = 0 
		SET @Salary_Cal_Day_LWP = @Salary_Cal_Day
		SET @Salary_Amount_LWP = @Salary_Amount


		SET @Emp_WD_OT_Rate = 0
		SET @Emp_WO_OT_Rate = 0
		SET @Emp_HO_OT_Rate = 0

		SET @Calc_On_Allow_Dedu_Actual = 0.0
		SET @Salary_Amount_actual = 0
		SET @Allow_Amount_actual = 0
		SET @ESIC_Basic_Salary_actual = 0.0
		SET @Other_Allow_Amount_actual = 0
		  
		IF @Sal_Tran_ID = 0                    
		SET @Sal_Tran_ID = NULL                    
		                 
		IF @L_Sal_Tran_ID =0                    
		SET @L_Sal_Tran_ID = NULL                     
		                  
		SET @M_AD_Actual_Per_Amount = 0.0                    
		                 
		SET @Allowance_Data = ''                    
		SET @Deduction_Data = ''                    
		SET @PaySlip_Tran_ID = 0  
		SET @E_Ad_Amount=0       
		SET @AD_CAL_TYPE=''    
		SET @AD_EFFECT_FROM=''
		SET @PERFORM_POINTS=0.00
		SET @Emp_Auto_VPF = 0  --Added by Hasmukh 18/07/2013 
		SET @PF_Percentage = 0 --Added by Hasmukh 18/07/2013 

		DECLARE @M_AD_Approval_Amount as NUMERIC(18, 4)


		DECLARE @Day_For_Security_Deposit as numeric (3,0)  -- Added by rohit on 09-apr-2014
		SET @Day_For_Security_Deposit=0	 

		DECLARE @Hour_Salary_OT numeric(18,4)
		Set @Hour_Salary_OT = 0

		SELECT  @OT_Basic_Salary = Basic_salary,@Day_Salary = Day_Salary,@OT_Sec=OT_Sec,@Ex_OT_Setting =Ex_OT_Setting ,@Shift_Day_Sec = ISNULL(Shift_Day_Sec,0) 
				,@OT_Working_Day = ISNULL(OT_Working_Day,0) ,@Emp_Ot_Hours=Emp_OT_Hour,@Hourly_Salary=Hourly_Salary ,@WO_OT_Sec = WO_OT_Sec , @HO_OT_Sec = HO_OT_Sec,
				@Hour_Salary_OT = ISNULL(Hourly_Salary,0)
		FROM #OT_DATA

		
	       
	   -- SET @ESIC_Basic_Salary = @OT_Basic_Salary 
		SET @ESIC_Basic_Salary = @Basic_Salary	
		
		SET @ESIC_Basic_Salary_actual  = @Basic_Salary 
		SET @Salary_Amount_actual= @Basic_Salary
		
		--Added By Ramiz on 19/11/2015
		
		
		DECLARE @OT_Max_Limit		VARCHAR(20)
		DECLARE @Sal_Fix_Days		numeric(5,2)   
		Declare @Fix_OT_Shift_Hours   VARCHAR(20)
		Declare @Fix_OT_Work_Days  NUMERIC(18, 4)    
		DECLARE @LWF_Amount				INT
		DECLARE @LWF_App_Month			VARCHAR(50)		--Ramiz 26022019
		Declare @Rate_Of_National_Holiday Int
		
		SET @OT_Max_Limit   = ''
		SET @Sal_Fix_Days = 0
		set @Fix_OT_Shift_Hours = ''
		SET @Fix_OT_Work_Days = 0
		SET @LWF_Amount    =0		--Ramiz 26022019
		SET @LWF_App_Month  = ''	--Ramiz 26022019


		-- Added by Hardik 07/03/2019 for Cliantha
		DECLARE @FIX_OT_HOUR_RATE_WD NUMERIC(18,2)
		SET @FIX_OT_HOUR_RATE_WD = 0
		DECLARE @FIX_OT_HOUR_RATE_WO_HO NUMERIC(18,2)
		SET @FIX_OT_HOUR_RATE_WO_HO = 0 

		
		if OBJECT_ID('tempdb..#Emp_WeekOff') IS NOT NUll
			Drop Table #Emp_WeekOff
		if OBJECT_ID('tempdb..#Emp_Holiday') IS NOT NUll
			Drop Table #Emp_Holiday
		

		SELECT @PF_Limit = PF_Limit  ,@ESIC_Limit = ISNULL(ESIC_Upper_Limit,0),@Is_ESIC = Isnull(g.Is_ESIC,0)    
			,@Effect_OT_IN_ESIC = ISNULL(g.Effect_Ot_Amount,0), @PF_Percentage = isnull(ACC_1_2,0)
			,@Day_For_Security_Deposit = isnull(g.Day_For_Security_Deposit,0) -- Added by rohit on 09-apr-2014
			,@OT_Max_Limit = Isnull(OT_Max_Limit,'00:00') , @Sal_Fix_Days = g.Sal_Fix_Days	--Added By Ramiz on 19/11/2015
			,@Max_Bonus_Salary_Amount = ISNULL(Max_Bonus_Salary_Amount,0)
			,@Fix_OT_Shift_Hours = ot_Fix_Shift_Hours ,@Fix_OT_Work_Days = isnull(OT_fiX_Work_Day,0)   
			,@OT_RATE_TYPE = ISNULL(OTRateType,0) -- ADDED BY RAJPUT ON 13072018
			,@OT_SLAB_TYPE = ISNULL(OTSLABTYPE,0) -- ADDED BY RAJPUT ON 13072018 
			,@GEN_ID = G.GEN_ID -- ADDED BY RAJPUT ON 13072018 
			,@LWF_Amount = LWF_Amount , @LWF_App_Month = LWF_Month	 -- ADDED BY RAMIZ ON 26022019
			,@Rate_Of_National_Holiday = Rate_Of_National_Holiday
		FROM dbo.T0040_GENERAL_SETTING G WITH (NOLOCK)
		 LEFT OUTER JOIN T0050_General_Detail GD WITH (NOLOCK) ON G.Gen_ID = GD.Gen_ID                    
		WHERE g.cmp_ID = @cmp_ID AND Branch_ID = @Branch_ID                    
		AND For_Date = (SELECT MAX(For_Date) FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID And For_Date <= @To_Date)                    


		IF @PF_Limit = 0                    
			SET @PF_Limit = 15000	                     

		DECLARE @SalaryBasis VARCHAR(20) --Added by Hardik 22/12/2020 for Kaypee Client
              
		SELECT @Emp_Full_Pf = ISNULL(Emp_Full_Pf,0),@Gr_Salary = Gross_salary, @Emp_WD_OT_Rate = Emp_WeekDay_OT_Rate , @Emp_WO_OT_Rate = Emp_WeekOff_OT_Rate , @Emp_HO_OT_Rate = Emp_Holiday_OT_Rate
			,@CTC = ISNULL(CTC,0), @Emp_Auto_VPF = isnull(Emp_Auto_VPF,0)
			,@FIX_OT_HOUR_RATE_WD = isnull(Fix_OT_Hour_Rate_WD,0),@FIX_OT_HOUR_RATE_WO_HO = ISNULL(Fix_OT_Hour_Rate_WO_HO,0) -- Added by Hardik 07/03/2019 for Cliantha
			,@SalaryBasis = Salary_Basis_On -- Added by Hardik 22/12/2020 for Kaypee Client
		FROM dbo.T0095_Increment WITH (NOLOCK) WHERE increment_id = @Increment_ID                    



	DECLARE @Left_date as datetime	                    
	  SELECT @Join_Date = Date_of_join, @Left_date=Emp_Left_Date FROM dbo.t0080_emp_master WITH (NOLOCK) WHERE emp_ID =@Emp_ID                    

		--Hardik 25/06/2014 for Upper Rouding for Employer ESIC
		DECLARE @Upper_Round_Employer_ESIC as int
		--Modified by Nimesh on 22-Dec-2015 (We use Value instead of Setting_ID)
		--Select  @Upper_Round_Employer_ESIC = (Select Setting_ID from dbo.T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name='Upper Round for Employer ESIC')
		
		Select @Upper_Round_Employer_ESIC = Cast(IsNull(Setting_Value,0) As Int) from dbo.T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name='Upper Round for Employer ESIC'
	    
	    --Setting of Mafatlals is Checked here--> Added By Ramiz on  06/06/2016                 
		DECLARE @Grade_Wise_Salary_Enabled as int
		DECLARE @Dynamic_Gross_Grade_Wise_Salary AS NUMERIC(18,2)
		DECLARE @LWF_compare_month  VARCHAR(5)    
		SELECT  @Grade_Wise_Salary_Enabled = CAST(IsNull(Setting_Value,0) AS INT) FROM dbo.T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID and Setting_Name='Show Gradewise Salary Textbox in Grade Master'
	    SET		@Dynamic_Gross_Grade_Wise_Salary = ISNULL(@Salary_Amount,0)
		SET		@LWF_compare_month = '#'+ CAST(Month(@To_Date) AS VARCHAR(2)) + '#'

		IF CHARINDEX(@LWF_compare_month,@LWF_App_Month , 1) <> 0 AND @is_emp_lwf = 1 And @Salary_Cal_Day > 0 --- Added condition And @Salary_Cal_Day > 0 for Mafatlal by Hardik 22/12/2020 as they dont want to deduct LWF if cal Days 0
			SET @Dynamic_Gross_Grade_Wise_Salary = @Dynamic_Gross_Grade_Wise_Salary - @LWF_Amount
	    --Ended By Ramiz on 06/06/2016

		/*For Circular Reference */
		CREATE TABLE  #DataCircularRef
		(
			Emp_ID	INT,
			Sal_Cal_Days	Numeric(9,3),
			Out_Of_Days		Numeric(9,3),
			For_Date		Datetime
		)

		InserT into #DataCircularRef VALUES(@Emp_ID, @Salary_Cal_Day, @Out_Of_Days,@From_Date)
	          
	  DECLARE @Unpaid_Leave NUMERIC(12,1) 
		SELECT @Unpaid_Leave = ISNULL(SUM(leave_Days),0) FROM dbo.T0210_Monthly_LEave_Detail WITH (NOLOCK) WHERE Emp_ID = @emp_ID AND       
						TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Leave_Paid_Unpaid = 'U'
	                             
	                      
	  IF ISNULL(@Sal_Tran_ID,0)>0                    
	   BEGIN                    
		SET @Allowance_Data = '<table width="100%" cellpedding="3">'                    
		SELECT @PaySlip_Tran_ID = ISNULL(MAX(PaySlip_Tran_ID),0)+ 1 FROM dbo.T0210_PAYSLIP_DATA WITH (NOLOCK)
		INSERT INTO dbo.T0210_PAYSLIP_DATA                    
			   (PaySlip_Tran_ID, Sal_Tran_ID, Cmp_ID, Allowance_Data, Deduction_Data, Temp_Sal_Tran_ID)                    
		VALUES     (@PaySlip_Tran_ID, NULL, @Cmp_ID, @Allowance_Data, @allowance_Data, @Sal_Tran_ID)                                               
	   END                    
	              
	    DECLARE @allCount numeric(18)
		DECLARE @intCount numeric(18)
		SET @allCount = 0
		SET @intCount = 1

	SET @Total_M_AD_Amount_Arears = 0   
	 -- below block Added by mitesh on 21052014 --- for midincrement esic effect start .---
	 DECLARE @Count_Allowance_Mid as numeric(18)
	 SET @Count_Allowance_Mid = 0


	 CREATE TABLE #Allowance_Mid_Prev_Detail
	 (
			emp_id numeric(18),
			Ad_id numeric(18),
			m_ad_amount NUMERIC(18, 4)
			
	 )


	 IF @No_of_increment > 1
		BEGIN
		
			insert into #Allowance_Mid_Prev_Detail
	 		SELECT	emp_id,ad_id, case when M_AD_Percentage > 0 then (M_AD_Calculated_Amount * M_AD_Percentage)/100 else  M_AD_Amount end 
	 		FROM	dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
			WHERE	Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND For_Date >=@Actual_Start_Date AND For_Date <= @Actual_End_Date
					AND ISNULL(Temp_Sal_Tran_ID,0) = ISNULL(@Sal_Tran_ID,ISNULL(Temp_Sal_Tran_ID,0))
					AND ISNULL(L_Sal_Tran_ID,0) = ISNULL(@L_Sal_Tran_ID,ISNULL(L_Sal_Tran_ID,0))
					AND EXISTS(SELECT 1 FROM dbo.T0060_EFFECT_AD_MASTER EFF WHERE EFF.Cmp_ID  = @Cmp_ID AND EFF.AD_iD=MAD.AD_ID)  

		
			select @Count_Allowance_Mid = count(1)  from #Allowance_Mid_Prev_Detail
	  end
	  
	--Added by Gadriwala Muslim 22062015
	DECLARE @Setting_Value as tinyint
	select @Setting_Value = Setting_Value from T0040_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and setting_Name = 'Monthly base get reimbursement claim amount'
	
	--Added By Sajid 29-01-2022
	declare @Shift_Day_Hour VARCHAR(20)    
	Declare @Shift_ID Numeric
	Set @Shift_ID = 0   
	If @Join_Date > @CutoffDate_Salary -- Condition added by Hardik 28/05/2018 For Arkray, Employee Joining date 22/05/2018 and Cutoff date is 20/05/2018 so Shift not getting.
                            Exec SP_CURR_T0100_EMP_SHIFT_GET @Emp_ID,@Cmp_ID,@Join_Date,null,null,@Shift_Day_Hour output,null,null,null,null,@Shift_ID output    
	Else
                            Exec SP_CURR_T0100_EMP_SHIFT_GET @Emp_ID,@Cmp_ID,@CutoffDate_Salary,null,null,@Shift_Day_Hour output,null,null,null,null,@Shift_ID output   
    --Added By Sajid 29-01-2022
	
	-- Break Hours is not consider in Hourly OT Rate Calculation for ShopShip Yard
	--DECLARE @Break_Hours_OT_Rate tinyint -- Added by Nilesh Patel on 26/06/2019 -- For ShoftShip Yard
	--Set @Break_Hours_OT_Rate = 0
	
	--SELECT @Break_Hours_OT_Rate = ISNULL(Setting_Value,0) 
	--FROM T0040_SETTING 
	--WHERE Setting_Name = 'Break Hours not consider in OT Hourly Rate Calculation, if Deduct Break Hour Ticked in Shift Master' And Cmp_Id = @Cmp_Id
	
	--Added By Nilesh For Deduct Second Break hours from Shift Duration for Calculate OT Rate --Shoftshipyard -- 04/06/2019
 --   Declare @Second_Break_Hours Varchar(10)
	--Declare @DeduHour_SecondBreak tinyint
	--Declare @Shift_ID Numeric 
	--Set @Second_Break_Hours  = ''
	--Set @DeduHour_SecondBreak = 0 
	--Set @Shift_ID = 0
	
	Declare @Grd_ID Numeric(18,0)
	Set @Grd_ID = 0
	Select @Grd_ID = Grd_ID From T0095_INCREMENT WITH (NOLOCK) Where Emp_ID = @Emp_ID and Increment_ID = @Increment_Id
	
	--Below Code For Allow Dedu Reviesed -- Ankit 10012015
	
	--ALTER TABLE dbo.T0210_MONTHLY_AD_DETAIL  DISABLE TRIGGER Tri_T0210_MONTHLY_AD_DETAIL_Delete
	
	DECLARE @AD_Level_temp Numeric
	SET @AD_Level_temp = 0
	
	SELECT  AD_ID,E_AD_PERCENTAGE,E_Ad_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,        --- Performance             
			AD_NOT_EFFECT_ON_PT,
			AD_NOT_EFFECT_SALARY,AD_EFFECT_ON_OT,
			AD_EFFECT_ON_EXTRA_DAY,
			AD_Name,AD_effect_on_Late,
			AD_Effect_Month,
			AD_CAL_TYPE,AD_EFFECT_FROM,AD_NOT_EFFECT_ON_LWP,
			Allowance_Type, AutoPaid,
			AD_LEVEL,is_rounding,Is_Calculate_Zero,Prorata_On_Salary_Structure,Claim_ID
	INTO	#AD_TABLE
		FROM (
		SELECT EED.AD_ID,
			
			--Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_Ad_Percentage End As E_AD_Percentage,
			--Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End As E_AD_Amount,
			 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
				Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_AD_PERCENTAGE End 
			 Else
				eed.E_AD_PERCENTAGE End As E_AD_PERCENTAGE,
			 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
				Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
			 Else
				eed.e_ad_Amount End As E_Ad_Amount,
			E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,                    
			ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,
			ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,
			ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY,
			AD_Name,ISNULL(AD_effect_on_Late,0) AS AD_effect_on_Late,
			ISNULL(AD_Effect_Month,'') AS AD_Effect_Month,
			ISNULL(AD_CAL_TYPE,'') AS AD_CAL_TYPE,ISNULL(AD_EFFECT_FROM,'') AS AD_EFFECT_FROM,
			ISNULL(ADM.AD_NOT_EFFECT_ON_LWP,0) AS AD_NOT_EFFECT_ON_LWP,
			ISNULL(ADM.Allowance_Type,'A') as Allowance_Type, 
			ISNULL(ADM.auto_paid,0) as AutoPaid,
			ADM.AD_LEVEL,ADM.is_rounding, 
			Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
				Qry1.Is_Calculate_Zero
			 Else
				ISNULL(EED.Is_Calculate_Zero,0) End As Is_Calculate_Zero,Prorata_On_Salary_Structure
				,adm.Claim_ID  --Added by Jaina 27-10-2020
		FROM dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN                    
			   dbo.T0050_AD_MASTER ADM WITH (NOLOCK)  ON EEd.AD_ID = ADM.AD_ID   LEFT OUTER JOIN
				( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID, EEDR.Is_Calculate_Zero
					From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
					( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised  WITH (NOLOCK)
						Where Emp_Id = @Emp_Id And For_date <= @to_date
					 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
				) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID  And Qry1.FOR_DATE>=EED.FOR_DATE                
		WHERE EED.EMP_ID = @emp_id AND eed.increment_id = @Increment_Id And Adm.AD_ACTIVE = 1
				And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
		UNION 
		
		SELECT EED.AD_ID,E_AD_Percentage,E_AD_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,                    
			ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,
			ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,
			ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,
			ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY
			,AD_Name,ISNULL(AD_effect_on_Late,0) AS AD_effect_on_Late ,ISNULL(AD_Effect_Month,'') AS AD_Effect_Month,
			ISNULL(AD_CAL_TYPE,'') AS AD_CAL_TYPE,ISNULL(AD_EFFECT_FROM,'') AS AD_EFFECT_FROM,
			ISNULL(ADM.AD_NOT_EFFECT_ON_LWP,0) AS AD_NOT_EFFECT_ON_LWP,
			ISNULL(ADM.Allowance_Type,'A') as Allowance_Type, 
			isnull(ADM.auto_paid,0) as AutoPaid,
			ADM.AD_LEVEL,ADM.is_rounding,ISNULL(EED.Is_Calculate_Zero,0) As Is_Calculate_Zero,Prorata_On_Salary_Structure
			,adm.Claim_ID  --Added by Jaina 27-10-2020
		FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
			( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
				Where Emp_Id  = @Emp_Id And For_date <= @to_date 
				Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
		   INNER JOIN dbo.T0050_AD_MASTER ADM  ON EEd.AD_ID = ADM.AD_ID                     
		WHERE emp_id = @emp_id 
				And Adm.AD_ACTIVE = 1
				And EEd.ENTRY_TYPE = 'A'
				AND EED.Increment_ID = @Increment_Id
		) Qry

		


	--SELECT AD_ID,E_AD_PERCENTAGE,E_Ad_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,        --- Performance             
	--		AD_NOT_EFFECT_ON_PT,
	--		AD_NOT_EFFECT_SALARY,AD_EFFECT_ON_OT,
	--		AD_EFFECT_ON_EXTRA_DAY,
	--		AD_Name,AD_effect_on_Late,
	--		AD_Effect_Month,
	--		AD_CAL_TYPE,AD_EFFECT_FROM,AD_NOT_EFFECT_ON_LWP,
	--		Allowance_Type, AutoPaid,
	--		AD_LEVEL,is_rounding
	--INTO	#AD_TABLE
	--	FROM (
	--	SELECT EED.AD_ID,
			
	--		 Case When Qry1.FOR_DATE >= EED.FOR_DATE Then
	--			Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_AD_PERCENTAGE End 
	--		 Else
	--			eed.E_AD_PERCENTAGE End As E_AD_PERCENTAGE,
	--		 Case When Qry1.FOR_DATE >= EED.FOR_DATE Then
	--			Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
	--		 Else
	--			eed.e_ad_Amount End As E_Ad_Amount,
	--		E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,                    
	--		ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,
	--		ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,
	--		ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY,
	--		AD_Name,ISNULL(AD_effect_on_Late,0) AS AD_effect_on_Late,
	--		ISNULL(AD_Effect_Month,'') AS AD_Effect_Month,
	--		ISNULL(AD_CAL_TYPE,'') AS AD_CAL_TYPE,ISNULL(AD_EFFECT_FROM,'') AS AD_EFFECT_FROM,
	--		ISNULL(ADM.AD_NOT_EFFECT_ON_LWP,0) AS AD_NOT_EFFECT_ON_LWP,
	--		ISNULL(ADM.Allowance_Type,'A') as Allowance_Type, 
	--		ISNULL(ADM.auto_paid,0) as AutoPaid,
	--		ADM.AD_LEVEL,ADM.is_rounding
	--	FROM dbo.T0100_EMP_EARN_DEDUCTION EED INNER JOIN                    
	--		   dbo.T0050_AD_MASTER ADM  ON EEd.AD_ID = ADM.AD_ID   LEFT OUTER JOIN
	--			( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE 
	--				From T0110_EMP_Earn_Deduction_Revised EEDR INNER JOIN
	--				( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
	--					Where Emp_Id = @Emp_Id
	--					And For_date <= @to_date
	--				 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
	--			) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID                  
	--	WHERE EED.EMP_ID = @emp_id AND increment_id = @Increment_Id And Adm.AD_ACTIVE = 1
	--			And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
	--	UNION 
		
	--	SELECT EED.AD_ID,E_AD_Percentage,E_AD_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,                    
	--		ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,
	--		ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,
	--		ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,
	--		ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY
	--		,AD_Name,ISNULL(AD_effect_on_Late,0) AS AD_effect_on_Late ,ISNULL(AD_Effect_Month,'') AS AD_Effect_Month,
	--		ISNULL(AD_CAL_TYPE,'') AS AD_CAL_TYPE,ISNULL(AD_EFFECT_FROM,'') AS AD_EFFECT_FROM,
	--		ISNULL(ADM.AD_NOT_EFFECT_ON_LWP,0) AS AD_NOT_EFFECT_ON_LWP,
	--		ISNULL(ADM.Allowance_Type,'A') as Allowance_Type, 
	--		isnull(ADM.auto_paid,0) as AutoPaid,
	--		ADM.AD_LEVEL,ADM.is_rounding
	--	FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED INNER JOIN  
	--		( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
	--			Where Emp_Id  = @Emp_Id And For_date <= @to_date 
	--			Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
	--	   INNER JOIN dbo.T0050_AD_MASTER ADM  ON EEd.AD_ID = ADM.AD_ID                     
	--	WHERE emp_id = @emp_id 
	--			And Adm.AD_ACTIVE = 1
	--			And EEd.ENTRY_TYPE = 'A'
	--	) Qry
		--ORDER BY AD_LEVEL, E_AD_Flag DESC 
	DECLARE @D_DIFF_TIME DATETIME
	Declare @AD_Claim_ID Numeric(18,0) = 0  --Added by Jaina 27-10-2020



	
	CREATE NONCLUSTERED INDEX IX_AD_TABLE_AD_ID ON #AD_TABLE(AD_ID);


	DECLARE curAD CURSOR FAST_FORWARD FOR 
	SELECT  AD_ID,E_AD_PERCENTAGE,E_Ad_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,        --- Performance             
			AD_NOT_EFFECT_ON_PT,
			AD_NOT_EFFECT_SALARY,AD_EFFECT_ON_OT,
			AD_EFFECT_ON_EXTRA_DAY,
			AD_Name,AD_effect_on_Late,
			AD_Effect_Month,
			AD_CAL_TYPE,AD_EFFECT_FROM,AD_NOT_EFFECT_ON_LWP,
			Allowance_Type, AutoPaid,
			AD_LEVEL,is_rounding,Is_Calculate_Zero,Prorata_On_Salary_Structure,Claim_ID
	FROM #AD_TABLE  
	ORDER BY AD_LEVEL, E_AD_Flag DESC 
		
	OPEN curAD                      
	  FETCH NEXT FROM curAD INTO @AD_ID,@M_AD_Percentage,@M_AD_Amount,@M_AD_Flag,@Max_Upper,@varCalc_On,@AD_DEF_ID,@M_AD_NOT_EFFECT_ON_PT,
	  @M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY ,@AD_Name,@M_AD_effect_on_Late,@AD_Effect_Month,@AD_CAL_TYPE,
	  @AD_EFFECT_FROM,@IS_NOT_EFFECT_ON_LWP,@Allowance_type,@AutoPaid,@AD_Level_temp,@IS_ROUNDING_Allowance,@Is_Calculate_Zero,@Prorata_On_Salary_Structure,@AD_Claim_ID
	  WHILE @@FETCH_STATUS = 0                    
	   BEGIN   

	   --	    If @Prorata_On_Salary_Structure = 1 And @varCalc_On In ('Actual Gross','Arrears','Formula','Gross Salary','Arrears CTC')
				--Set @varCalc_On = 'Basic Salary'
				
			If @Prorata_On_Salary_Structure = 1 And (@varCalc_On In ('Actual Gross','Arrears','Formula','Gross Salary','Arrears CTC') Or @M_AD_Percentage > 0)
			Begin
			
				Set @varCalc_On = 'Basic Salary'
				Set @M_AD_Percentage = 0
				
			End
			
			
			
			-- Added by Hardik 26/05/2020 for Covid benefit on PF by Government
			If Month(@To_Date) In (5,6,7) And Year(@To_Date)=2020 And @AD_DEF_ID in (@PF_DEF_ID,@Cmp_PF_DEF_ID)
				Set @M_AD_Percentage = 10.00
			
				
	 -- below block Added by mitesh on 21052014 --- for midincrement esic effect end---

	   --while @intCount <= @allCount             
	   BEGIN   

	   
	   
			SET @D_DIFF_TIME = GETDATE()
			--PRINT ''
			--PRINT ''
			--PRINT CONVERT(VARCHAR(20), GETDATE(), 114) +  ' : CALCULATE ON : ' + @varCalc_On ;
			
			DECLARE @is_eligible as tinyint 
			DECLARE @Earning_Gross_Eligible NUMERIC(18, 4)

			SET @is_eligible = 1 
			SET @Earning_Gross_Eligible = 0
			SET @M_AD_Actual_Per_Amount = 0
			
			SET @IS_ROUNDING =  isnull(@IS_ROUNDING_Allowance,@IS_ROUNDING_temp) -- added by rohit on 30072015	
			
			if exists (select 1 from T0040_AD_Formula_Eligible_Setting WITH (NOLOCK) where cmp_id = @cmp_id and ad_id = @ad_id And AD_Formula_Eligible <> '')
				BEGIN
		
					--PRINT  convert(varchar(20), getdate(), 114) + ' : Query 9001 : Start'                  
					Select	@Earning_Gross_Eligible=SUM(ISNULL(M_AD_AMOUNT,0)) 
					From	dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) 
							--LEFT OUTER JOIN  (SELECT  AD_ID FROM dbo.T0050_AD_MASTER AD WHERE AD.CMP_ID=@CMP_ID AND isnull(AD.AD_NOT_EFFECT_SALARY,0) = 1) AD  ON MAD.AD_ID=MAD.AD_ID 
					WHERE	Temp_Sal_Tran_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I'      
							AND NOT EXISTS (SELECT  AD_ID FROM dbo.T0050_AD_MASTER AD WITH (NOLOCK) WHERE AD.CMP_ID=@CMP_ID AND isnull(AD.AD_NOT_EFFECT_SALARY,0) = 1 AND AD.AD_ID= MAD.AD_ID)					
							--AND AD.AD_ID IS NULL
							--AND AD_ID not in (select AD_ID from dbo.T0050_AD_MASTER where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 1)	
					--PRINT  convert(varchar(20), getdate(), 114) + ' : Query 9001 : End'                  
					
					SET @Earning_Gross_Eligible = @Salary_Amount + ISNULL(@Earning_Gross_Eligible,0) + ISNULL(@OT_Amount,0) + ISNULL(@OT_HO_AMOUNT,0) + ISNULL(@OT_WO_AMOUNT,0)					
					exec dbo.Check_Eligible_Formula_Wise  @Cmp_ID,@EMP_ID,@AD_ID,@From_Date,@Earning_Gross_Eligible,@Salary_Cal_Day,@Tot_Salary_Day,@is_eligible output,@numAbsentDays,@Salary_Amount,@Arear_Days,@Present_Days,@CutoffDate_Salary					
					
				end	
				
			If Isnull(@Is_Calculate_Zero,0) = 1
				Set @is_eligible = 0

				 
			IF @is_eligible = 1 
				BEGIN
					
					SET @M_AD_Approval_Amount = 0    
					SET @ReimShow = 0

					-- Added by rohit on 03-apr-2014 for Security Deposit allowance
					DECLARE @Allowance_Get_Month as numeric(18,0)
					DECLARE @Allowance_Get as Numeric
					DECLARE @Joining_Date_temp as Datetime
					DECLARE @Count_Get as Numeric
					SET @Count_Get = 0
					SET @Allowance_Get = 1
					SET @Allowance_Get_Month = 0
					select @Allowance_Get_Month = no_of_month from t0050_ad_master WITH (NOLOCK) where ad_id=@ad_id and cmp_id=@cmp_id
					
					
					IF isnull(@Allowance_Get_Month,0) > 0
						BEGIN
							select	@Count_Get = Count(AD_ID) 
							from	T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) 
							where	Emp_ID=@emp_id and AD_ID=@ad_id and cmp_id=@cmp_id and m_Ad_Amount>0

							if isnull(@Allowance_Get_Month,0) > @Count_Get
								BEGIN
									SET @Allowance_Get = 1
								end
							else
								BEGIN
									SET @Allowance_Get = 0
								end
						END
					-- Ende by rohit on 03-apr-2014 for Security Deposit allowance

					--Added by Hardik 12/08/2013 for Azure Client       
					SET @Split_Shift_Count = 0
					SET @Split_Shift_Date  = ''


					SET @E_Ad_Amount = @M_AD_Amount             
					SET @Tmp_amount = 0  
					DECLARE @Allow_Amount NUMERIC(18, 4)
					SET @Allow_Amount=0

					SET @ESIC_Basic_Salary = @Basic_Salary    
					SET @ESIC_Basic_Salary_actual  = @Basic_Salary 
	
		
					--- Changes done for EFFECT On LWP by Falak on 06-jan-2010
				   IF @IS_NOT_EFFECT_ON_LWP = 1
						BEGIN
							SET @Salary_Cal_Day = @Salary_Cal_Day_LWP 
							SET @Salary_Amount  = @Salary_Amount_LWP  
							SET @Salary_Cal_Day = @Salary_Cal_Day + @Unpaid_Leave
							IF @Salary_cal_Day > @Out_Of_Days
								SET @Salary_Cal_Day = @Out_Of_Days 
							SET @Salary_Amount   = ROUND((@Basic_Salary  * @Salary_Cal_Day )/ @Out_Of_Days,0)
							--SET @Salary_Cal_Day = @Salary_Cal_Day_LWP
							--SET @Salary_Amount = @Basic_Salary_LWP		
						END
					ELSE
						BEGIN		
							SET @Salary_Amount = @Salary_Amount_LWP
							SET @Salary_Cal_Day = @Salary_Cal_Day_LWP  				
						END		

					--- Copy Declaration from below side for Import issue. Hardik 05/01/2016
					---Hardik 07/01/2012  Arear Calculation
					DECLARE @M_AREARS_AMOUNT AS NUMERIC(18, 4)
					DECLARE @Arear_Calculated_Amount AS NUMERIC(18, 4)
					DECLARE @Out_Of_Days_Arear AS NUMERIC(18,1)

	
					-- Added by rohit on 13012015
					DECLARE @M_AREARS_AMOUNT_Cutoff AS NUMERIC(18, 4)
					DECLARE @Arear_Calculated_Amount_Cutoff AS NUMERIC(18, 4)
					DECLARE @Out_Of_Days_Arear_Cutoff AS NUMERIC(18,1)
					
					SET	@M_AREARS_AMOUNT_Cutoff =0
					SET @Arear_Calculated_Amount_Cutoff = 0
					SET @Out_Of_Days_Arear_Cutoff = 0


					SET	@M_AREARS_AMOUNT =0
					SET @Arear_Calculated_Amount = 0
					SET @Out_Of_Days_Arear = 0
		
					
					IF @varCalc_On = 'Import'
						BEGIN    					
						
							--PRINT CONVERT(VARCHAR(20), GETDATE(), 114) +  ' :  @M_AD_Amount - START'
							SET @M_AD_Amount = 0                    
							SELECT @M_AD_Amount = Amount FROM dbo.T0190_Monthly_AD_Detail_import WITH (NOLOCK) 
							WHERE Emp_ID=@Emp_ID AND AD_ID =@AD_ID AND MONTH = MONTH(@Actual_End_Date) AND YEAR = YEAR(@Actual_End_Date)                    
							SET @M_AD_Actual_Per_Amount = 0
							--PRINT CONVERT(VARCHAR(20), GETDATE(), 114) +  ' :  @M_AD_Amount - END'
							--Modified by Nimesh on 08-Jan-2016 (Allowance is not TDS)
							IF @AD_DEF_ID <> @IT_DEF_ID	
								GOTO INSERT_RECORD;
						END     	                     
					ELSE IF @varCalc_On ='Gross Salary'                     
						BEGIN
							SELECT	@Allow_Amount = SUM(ISNULL(M_AD_AMOUNT,0)) 
							FROM	dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
									LEFT OUTER JOIN  dbo.T0050_AD_MASTER AD ON MAD.Cmp_ID=AD.CMP_ID AND MAD.AD_ID=MAD.AD_ID AND isnull(AD.AD_NOT_EFFECT_SALARY,0) = 1
							WHERE	Temp_Sal_Tran_ID = @Sal_Tran_ID AND MAD.Emp_ID = @Emp_ID AND MAD.M_AD_Flag ='I' 
									AND AD.AD_ID IS NULL
									--AND AD_ID NOT IN (SELECT AD_ID FROM dbo.T0050_AD_MASTER WHERE Cmp_ID =@Cmp_ID AND ISNULL(AD_Not_effect_salary,0) = 1)
		
							SET @Calc_On_Allow_Dedu = @Salary_Amount+ ISNULL(@Allow_Amount,0)								
						--	SET @ESIC_Basic_Salary=@Calc_On_Allow_Dedu comment by hasmukh 08112012
		
		
							SELECT	@Other_Allow_Amount_actual = ISNULL(SUM(E_AD_amount),0)  
							FROM	dbo.T0100_EMP_EARN_DEDUCTION  MAD WITH (NOLOCK)
									LEFT OUTER JOIN  dbo.T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.Cmp_ID=AD.CMP_ID AND MAD.AD_ID=MAD.AD_ID AND isnull(AD.AD_NOT_EFFECT_SALARY,0) = 1
							WHERE	MAD.Cmp_ID = @Cmp_ID AND MAD.Emp_ID = @Emp_ID  AND MAD.E_AD_Flag ='I' AND Increment_Id = @Increment_Id
									AND AD.AD_ID IS NULL
									--AND AD_ID NOT IN (SELECT AD_ID  FROM  dbo.T0050_AD_MASTER  WHERE   Cmp_ID  = @Cmp_ID AND ISNULL(AD_Not_effect_salary,0) = 1) 

							--PRINT  convert(varchar(20), getdate(), 114) + ' : Query 9002 : End'                  
					
							SET @Calc_On_Allow_Dedu_Actual = @salary_amount_actual + ISNULL(@Allow_Amount_actual,0)
						END	
					ELSE IF @varCalc_On='Actual Gross'	--Nikunj 09-Apr-2011
						BEGIN						
							IF @AD_Def_ID=3 
								BEGIN					
									SELECT	@Allow_Amount = SUM(ISNULL(M_AD_AMOUNT,0)) 
									FROM	dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
											LEFT OUTER JOIN  dbo.T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.Cmp_ID=AD.CMP_ID AND MAD.AD_ID=MAD.AD_ID AND isnull(AD.AD_NOT_EFFECT_SALARY,0) = 1
									WHERE	Temp_Sal_Tran_ID = @Sal_Tran_ID AND MAD.Emp_ID = @Emp_ID AND MAD.M_AD_Flag ='I'      
											AND AD.AD_ID IS NULL
											
				
									SELECT	@Allow_Amount_actual = ISNULL(SUM(E_AD_amount),0)  
									FROM	dbo.T0100_EMP_EARN_DEDUCTION  MAD WITH (NOLOCK)
											LEFT OUTER JOIN  dbo.T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.Cmp_ID=AD.CMP_ID AND MAD.AD_ID=MAD.AD_ID AND isnull(AD.AD_NOT_EFFECT_SALARY,0) = 1
									WHERE	MAD.Cmp_ID = @Cmp_ID AND MAD.Emp_ID = @Emp_ID  AND MAD.E_AD_Flag ='I'  AND MAD.Increment_Id = @Increment_Id
											--AND AD_ID NOT IN (SELECT AD_ID FROM dbo.T0050_AD_MASTER WHERE Cmp_ID =@Cmp_ID AND ISNULL(AD_Not_effect_salary,0) = 1)

											
									SET @Calc_On_Allow_Dedu = @Salary_Amount + ISNULL(@Allow_Amount,0)--Changed by Falak on 03-MAY-2011
				
									SET @Calc_On_Allow_Dedu_Actual = @salary_amount_actual + ISNULL(@Allow_Amount_actual,0)
				
								END
							ELSE If  @Wages_type = 'Daily'
							BEGIN
									Declare @EAdAmount as Numeric(18,2) = 0
									Select @EAdAmount = E.E_AD_AMOUNT From T0095_INCREMENT I 
									inner join T0100_EMP_EARN_DEDUCTION E on I.Emp_ID = E.EMP_ID
									where I.Wages_Type = 'Daily' and e.EMP_ID = @Emp_Id 
									and E.AD_ID = @AD_ID and E.CMP_ID = @Cmp_ID
									
									SET @Calc_On_Allow_Dedu = @EAdAmount * @Salary_Cal_Day
									SET @Calc_On_Allow_Dedu_Actual = @EAdAmount * @Salary_Cal_Day
									
									if @M_AD_Percentage > 0
										Set @M_AD_Amount =  @EAdAmount * @Salary_Cal_Day
									
							END
							ELSE
								BEGIN	
									--SET @Calc_On_Allow_Dedu = @Gr_Salary
									SET @Calc_On_Allow_Dedu = @Gross_Salary_ProRata
								--	SET @ESIC_Basic_Salary=@Calc_On_Allow_Dedu comment by hasmukh on 08112012
								
									SET @Calc_On_Allow_Dedu_Actual = @Gross_Salary_ProRata
									--SET @Calc_On_Allow_Dedu_Actual = @Gr_Salary
								END	
						END    	
					ELSE IF @varCalc_On = 'Arrears'  --Changed the Spelling from "Arears" to "Arrears" by Ramiz on 16/11/2016
						 BEGIN
						 
							 --Commented by Hardik 08/05/2018 for Havmor as below line is taking all Allowances.. we need to take only Effect on Gross Allowances for Arear Calculation
							 --SET @Allow_Amount = ISNULL(@Total_M_AD_Amount_Arears,0)
							 
							SELECT @Allow_Amount = Isnull(Sum(MAD.M_AD_Amount),0) FROM	dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) 
								INNER JOIN dbo.T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID=AD.AD_ID and mad.Cmp_ID= ad.CMP_ID	
							WHERE MAD.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID                     
								AND For_Date >=@Actual_Start_Date AND For_Date <=@Actual_End_Date                
								AND ISNULL(Temp_Sal_Tran_ID,0) = ISNULL(@Sal_Tran_ID,ISNULL(Temp_Sal_Tran_ID,0))
								And Isnull(AD.AD_EFFECT_ON_CTC,0) = 1 And Isnull(AD.AD_NOT_EFFECT_SALARY,0) = 0
								And MAD.AD_ID <> @AD_ID -- Added by Hardik 12/10/2020 for BGD and WHFL as they have issue while mid increment due to Probation to Confirmation Entry

							IF @No_of_increment > 1   --added by Hardik 10/04/2020 for Biomatrix client for mid increment case wrong
								BEGIN
									SELECT @Other_Allow_Amount_mid = Isnull(Sum(MAD.M_AD_Amount),0) 
									FROM	#Allowance_Mid_Prev_Detail MaD WITH (NOLOCK) 
											INNER JOIN dbo.T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID=AD.AD_ID 
									WHERE AD.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID                     
										And Isnull(AD.AD_EFFECT_ON_CTC,0) = 1 And Isnull(AD.AD_NOT_EFFECT_SALARY,0) = 0
										And MAD.AD_ID <> @AD_ID
									
									Set @Allow_Amount = @Allow_Amount - @Other_Allow_Amount_mid
								END
							 
        
							 DECLARE @Gr_Days AS NUMERIC(18, 4)
							 DECLARE @Gr_Salary_amount AS  NUMERIC(18, 4)
							 SET @Gr_Days =0
							 SET @Gr_Salary_amount =0	
							 
							 -- Added by rohit for Daily Wages Employee Arear Calculate Wrong on 08022016
							 Declare @temp_outofdays as numeric(18,2) 
							 set @temp_outofdays =1
							 IF @wages_Type <> 'Daily'
								 BEGIN
									SET @temp_outofdays = @Out_Of_Days
								 END
							-- Ended by rohit
								
							IF @Salary_Depends_on_Production = 1 AND @Salary_Cal_Day > 0 -- Added by Hardik 08/04/2015 for Samarth Import Gross Salary every month
								BEGIN
									Select  @Gr_Salary_amount = ISNULL(Gross_Amount,0), --((Gross_Amount/@Salary_Cal_Day)* @Out_Of_Days), --Gross_Salary ( As This Gross Will be Used for Other_Allowance(arrear Calculate)
									@Salary_Amount = @Basic_Salary
									From T0050_Production_Details_Import WITH (NOLOCK) Where Employee_ID=@Emp_Id and Production_Month = Month(@To_Date) and Production_Year=Year(@To_Date)
									
									IF @IS_ROUNDING = 1 
								      BEGIN
									    SET   @Calc_On_Allow_Dedu = ROUND(@Gr_Salary_amount - (@Salary_Amount  + @Allow_Amount),0)
								      END
							       ELSE
								      BEGIN
									    SET   @Calc_On_Allow_Dedu =  @Gr_Salary_amount - (@Salary_Amount  + @Allow_Amount) 
								      END
								END
							ELSE
								BEGIN
									SELECT @Gr_Salary_amount = Gross_salary,@Salary_Amount= Basic_Salary 
									FROM dbo.T0095_Increment WITH (NOLOCK) WHERE increment_id = @Increment_ID     										
									
									SELECT	@Gr_Salary_amount = Sum(E_AD_AMOUNT) + @Salary_Amount 
									FROM	dbo.fn_getEmpIncrementDetail(@Cmp_ID, @Emp_ID, @To_Date) INC 
											INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON INC.AD_ID=AD.AD_ID 
									WHERE	E_AD_FLAG='I' and AD.AD_NOT_EFFECT_SALARY=0 --and Increment_id=@Increment_ID 
											And Isnull(AD.AD_EFFECT_ON_CTC,0) = 1 And Isnull(AD.AD_NOT_EFFECT_SALARY,0) = 0  -- Added by Hardik 13/08/2020 for Trident client
								
									IF @IS_ROUNDING = 1 
									   BEGIN
										 SET   @Gr_Salary_amount = ROUND(@Gr_Salary_amount * @Salary_Cal_Day/@temp_outofdays,0) -- out of Days changed with @temp_outofdays changed by rohit on 08022016
										 SET   @Salary_Amount =  ROUND(@Salary_Amount * @Salary_Cal_Day /@temp_outofdays ,0)
										 SET   @Calc_On_Allow_Dedu = ROUND(@Gr_Salary_amount - (@Salary_Amount  + @Allow_Amount),0)
									   END
									ELSE
									  BEGIN
										SET   @Gr_Salary_amount = @Gr_Salary_amount * @Salary_Cal_Day/@temp_outofdays  
										SET   @Salary_Amount =   @Salary_Amount * @Salary_Cal_Day /@temp_outofdays  
										SET   @Calc_On_Allow_Dedu =  @Gr_Salary_amount - (@Salary_Amount  + @Allow_Amount) 
									  END
								END
								--IF @wages_Type <> 'Daily' --Added by Hardik 07/12/2015
									--BEGIN
									--	 SET   @Gr_Salary_amount = @Gr_Salary_amount * @Salary_Cal_Day/@Out_Of_Days  
									--	 SET   @Salary_Amount =   @Salary_Amount * @Salary_Cal_Day /@Out_Of_Days  
									--	 --SET   @Basic_Salary =  @Salary_Amount
									--	 SET   @Calc_On_Allow_Dedu =  @Gr_Salary_amount - (@Salary_Amount  + @Allow_Amount) 
									--end
								--Else
								--	BEGIN
								--		 SET   @Gr_Salary_amount = @Gr_Salary_amount * @Salary_Cal_Day
								--		 SET   @Salary_Amount =   @Salary_Amount * @Salary_Cal_Day
								--		 SET   @Calc_On_Allow_Dedu =  @Gr_Salary_amount - (@Salary_Amount  + @Allow_Amount) 
								--	end


							 IF @Calc_On_Allow_Dedu < 0			
								 SET @Calc_On_Allow_Dedu = 0
								 
							 SET   @M_AD_Amount =@Calc_On_Allow_Dedu
						 END
					ELSE IF @varCalc_On ='Leave Allowance'  --Hasmukh 01052013  Grind master
						BEGIN
							DECLARE @Tour_Day Numeric(18,1)
							DECLARE @tour_Amount NUMERIC(18, 4)
						
							SET @Tour_Day = 0
							SET @tour_Amount = 0
		
							DECLARE @curLeave_Id numeric
							DECLARE @curAmount numeric
							DECLARE CusrLeave cursor for	                  
							select Distinct Leave_id,Amount from T0100_Leave_Allowance_Amount_Details WITH (NOLOCK) WHERE Cmp_Id =@Cmp_ID and Emp_id=@emp_id and Effective_Date in (select Max(Effective_date) from T0100_Leave_Allowance_Amount_Details where Cmp_Id =@Cmp_ID and Emp_id=@emp_id and Effective_Date <= @From_Date )
							Open CusrLeave
							Fetch next from CusrLeave into @curLeave_id,@curAmount
							While @@fetch_status = 0                    
								BEGIN     
									SELECT @Tour_Day = ISNULL(SUM(leave_used),0)  + ISNULL(sum(CompOff_Used),0) FROM dbo.T0140_LEavE_Transaction WITH (NOLOCK) WHERE Emp_Id =@Emp_ID -- Changed By Gadriwala 02102014
									AND For_Date >=@From_Date AND For_Date <=@To_date AND Leave_ID = @curLeave_id
				
									SET @tour_Amount = @tour_Amount + (@Tour_Day * @curAmount)

									fetch next from CusrLeave into @curLeave_id	,@curAmount
								end
							close CusrLeave                    
							deallocate CusrLeave

							SET @M_AD_Amount = @tour_Amount
		
							-- Ended by rohit on 28052013
					

						End    	 
					ELSE IF @varCalc_On ='Basic Salary'  and @AD_DEF_ID NOT IN (2,5) --Condition added by ronakk  for NCP PF 06062023
						BEGIN
							

							SET @Calc_On_Allow_Dedu = @Salary_Amount
	
							SET @Calc_On_Allow_Dedu_Actual = @salary_amount_actual

						END


					ELSE IF @varCalc_On ='Basic Salary' and @AD_DEF_ID IN (2,5) 
					BEGIN	
					--Added by ronakk 06062023 For NCP Prorata case 

							if ((Select IS_NCP_PRORATA from T0050_GENERAL_DETAIL where GEN_ID in (Select G.Gen_ID from T0040_GENERAL_SETTING G 
											inner join (Select MAX(For_Date) as For_Date from T0040_GENERAL_SETTING where cmp_id = @Cmp_ID and Branch_ID = @Branch_ID) T on G.For_Date = T.For_Date 
											where cmp_id = @Cmp_ID and Branch_ID = @Branch_ID)) = 1)
							BEGIN
			
			

								IF @Basic_Salary > @PF_Limit and @Emp_Full_Pf=0 and @Emp_Auto_VPF=0 
								BEGIN 															
									SET @Calc_On_Allow_Dedu = @PF_Limit
									SET @Calc_On_Allow_Dedu_Actual = @salary_amount_actual
								END							
								ELSE
								BEGIN							
										SET @Calc_On_Allow_Dedu = @Salary_Amount
										SET @Calc_On_Allow_Dedu_Actual = @salary_amount_actual
								END
							end
							ELSE
							BEGIN							
									SET @Calc_On_Allow_Dedu = @Salary_Amount
									SET @Calc_On_Allow_Dedu_Actual = @salary_amount_actual
							END

		             END
					ELSE IF @varCalc_On ='CTC'  --Hasmukh 24082012
						BEGIN	
						
						
							DECLARE @CTC_Prorate NUMERIC(18, 4)
						
							SET @CTC_Prorate = 0
							SET @CTC_Prorate = @CTC
							SET @CTC_Prorate = @CTC_Prorate * @Salary_Cal_Day/@Out_Of_Days 				
							SET @Calc_On_Allow_Dedu = @CTC_Prorate
		
							SET @Calc_On_Allow_Dedu_Actual =  @CTC          
						END				
					ELSE  
						BEGIN
							SET @Calc_On_Allow_Dedu = @Basic_Salary         
		
							SET @Calc_On_Allow_Dedu_Actual =  @Basic_Salary    
							
							
						END  
					
														
					IF @No_of_increment > 1
						BEGIN									 
							IF @M_AD_Percentage > 0                     
								SET @M_AD_Actual_Per_Amount = @M_AD_Percentage  * @Salary_Cal_Day/@Out_Of_Days                  
							ELSE                   
								SET @M_AD_Actual_Per_Amount = @E_Ad_Amount * @Salary_Cal_Day/@Out_Of_Days
						end
					else
						BEGIN
							IF @M_AD_Percentage > 0                     
								SET @M_AD_Actual_Per_Amount = @M_AD_Percentage                    
							ELSE                   
								SET @M_AD_Actual_Per_Amount = @E_Ad_Amount

								
						end    
					
						
					SET @Other_Allow_Amount = 0         
					SET @ESIC_Calculate_Amount=0           
                    SET @Other_Allow_Amount_mid = 0

					--PERFORMANCE : START
					--PRINT  convert(varchar(20), getdate(), 114) + ' : EFF_ALL_AMT - START'
					SELECT  @Other_Allow_Amount = ISNULL(SUM(M_AD_amount),0),@Other_Allow_Amount_Arear = ISNULL(SUM(M_AREAR_AMOUNT),0),@Other_Allow_Amount_Arear_cutoff = ISNULL(SUM(M_AREAR_AMOUNT_Cutoff),0)
					FROM	dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) 
							INNER JOIN dbo.T0060_EFFECT_AD_MASTER   EAD WITH (NOLOCK) ON MAD.AD_ID=EAD.AD_ID and mad.Cmp_ID= ead.CMP_ID	
							INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) on MAD.AD_ID = am.AD_ID
					WHERE	MAD.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID                     
							AND For_Date >=@Actual_Start_Date AND For_Date <=@Actual_End_Date                
							AND ISNULL(Temp_Sal_Tran_ID,0) = ISNULL(@Sal_Tran_ID,ISNULL(Temp_Sal_Tran_ID,0))                    
							AND ISNULL(L_Sal_Tran_ID,0) = ISNULL(@L_Sal_Tran_ID,ISNULL(L_Sal_Tran_ID,0))                    
							AND EAD.EFFECT_AD_ID = @AD_ID
							
							--select @Other_Allow_Amount_Arear

					IF @AD_DEF_ID IN (@PF_DEF_ID,@VPF_DEF_ID,@Cmp_PF_DEF_ID)
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
									AND For_Date >=@Actual_Start_Date AND For_Date <=@Actual_End_Date                
									AND ISNULL(Temp_Sal_Tran_ID,0) = ISNULL(@Sal_Tran_ID,ISNULL(Temp_Sal_Tran_ID,0))                    
									AND ISNULL(L_Sal_Tran_ID,0) = ISNULL(@L_Sal_Tran_ID,ISNULL(L_Sal_Tran_ID,0))                    
						END
					ELSE
						SET @DA_AMOUNT = 0
						
					IF EXISTS(SELECT 1 FROM dbo.T0040_SETTING WITH (NOLOCK) 
							WHERE Cmp_ID = @Cmp_ID and Setting_Name='PF Limit Check with Earning Basic' And IsNull(Setting_Value,0) = 1)
						BEGIN
							SET @BASIC_SALARY_PF = @Salary_Amount
							SET @DA_AMOUNT_PF = @DA_AMOUNT_EARNING
				
						END
					ELSE
						BEGIN
							SET @BASIC_SALARY_PF = @Basic_Salary
							SET @DA_AMOUNT_PF = @DA_AMOUNT
						END

						
							-- Hardik 29/03/2019 for New PF Rule
							DECLARE @Calculate_Full_PF_evenif_Basic_is_above_PF_Limit AS BIT
							Declare @Calculate_Full_PF_evenif_Basic_is_less_PF_Limit As bit --Added By Hardik 27/07/2020 for GIFT City

							SET @Calculate_Full_PF_evenif_Basic_is_above_PF_Limit = 0

							SELECT @Calculate_Full_PF_evenif_Basic_is_above_PF_Limit = Isnull(setting_value,0) from T0040_SETTING WITH (NOLOCK)  --New PF Rules for Corona 20052019 added By Jimit
							WHERE Cmp_Id = @Cmp_ID and Setting_Name = 'Calculate Full PF, evenif Basic is above PF Limit'

							SET @Calculate_Full_PF_evenif_Basic_is_less_PF_Limit = 0

							select @Calculate_Full_PF_evenif_Basic_is_less_PF_Limit = setting_value from T0040_SETTING WITH (NOLOCK) --Added By Hardik 27/07/2020 for GIFT City
							Where Cmp_Id = @Cmp_ID and Setting_Name = 'Calculate Full PF, Evenif Basic is Less than PF Limit'
	
							
							--- Comment below Condition for MediTranscare as per email from Ravi on 29-Jul-2019 ---by Hardik 29/07/2019
							If (@AD_DEF_ID=@PF_DEF_ID or @AD_DEF_ID = @Cmp_PF_DEF_ID or @AD_DEF_ID = @VPF_DEF_ID) And @BASIC_SALARY_PF + @DA_AMOUNT_PF >= @PF_Limit
								and Isnull(@Calculate_Full_PF_evenif_Basic_is_above_PF_Limit,0) = 0
								BEGIN
									
									Set @Other_Allow_Amount = 0
									SET @Other_Allow_Amount_Arear = 0  --Added By Jimit 05092019 as per case at NLMK 
									set @Other_Allow_Amount_Arear_cutoff = 0 --Added By Jimit 04092019 as per case at NLMK 

									SELECT  @Other_Allow_Amount = ISNULL(SUM(M_AD_amount),0),@Other_Allow_Amount_Arear = ISNULL(SUM(M_AREAR_AMOUNT),0),@Other_Allow_Amount_Arear_cutoff = ISNULL(SUM(M_AREAR_AMOUNT_Cutoff),0)
									FROM	dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) 
											INNER JOIN dbo.T0060_EFFECT_AD_MASTER   EAD WITH (NOLOCK) ON MAD.AD_ID=EAD.AD_ID and mad.Cmp_ID= ead.CMP_ID	
											INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) on MAD.AD_ID = am.AD_ID
									WHERE	MAD.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID                     
											AND For_Date >=@Actual_Start_Date AND For_Date <=@Actual_End_Date                
											AND ISNULL(Temp_Sal_Tran_ID,0) = ISNULL(@Sal_Tran_ID,ISNULL(Temp_Sal_Tran_ID,0))                    
											AND ISNULL(L_Sal_Tran_ID,0) = ISNULL(@L_Sal_Tran_ID,ISNULL(L_Sal_Tran_ID,0))                    
											AND EAD.EFFECT_AD_ID = @AD_ID AND AM.AD_DEF_ID = @DA_DEF_ID

											
								END

							--Hardik 29/03/2019 As per New PF Rule
							If Case When @Wages_type = 'Daily' Then  (@Basic_Salary + @DA_AMOUNT) * 26 Else @BASIC_SALARY_PF + @DA_AMOUNT_PF End <= @PF_Limit And @Emp_Full_Pf =1 AND (@AD_DEF_ID=@PF_DEF_ID OR @AD_DEF_ID = @VPF_DEF_ID) AND @Calculate_Full_PF_evenif_Basic_is_less_PF_Limit = 0
								Begin
								   
									Set @Emp_Full_Pf=0
								End

							--Hardik 29/03/2019 As per New PF Rule
							If Case When @Wages_type = 'Daily' Then  (@Basic_Salary + @DA_AMOUNT) * 26 Else @BASIC_SALARY_PF + @DA_AMOUNT_PF End <= @PF_Limit And @Emp_Auto_VPF =1 AND @AD_DEF_ID = @Cmp_PF_DEF_ID AND @Calculate_Full_PF_evenif_Basic_is_less_PF_Limit = 0
								Begin
								
									Set @Emp_Auto_VPF=0
								End

						--Ended
					--PRINT  convert(varchar(20), getdate(), 114) + ' : EFF_ALL_AMT - START'
					--		AND AD_ID IN                     
					--(SELECT AD_ID  FROM dbo.T0060_EFFECT_AD_MASTER                     
					--WHERE Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID)  

					/*Commented by Nimesh on 07-Jan-2016 (Perfomance Optimization: We don't need to execute seperate query for each value)
					--Added by Hardik 31/05/2013
					SELECT @Other_Allow_Amount_Arear = ISNULL(SUM(M_AREAR_AMOUNT),0) 
					FROM	dbo.T0210_MONTHLY_AD_DETAIL MAD INNER JOIN dbo.T0060_EFFECT_AD_MASTER   EAD ON MAD.AD_ID=EAD.AD_ID and mad.Cmp_ID= ead.CMP_ID	
					WHERE	MAD.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID                     
							AND For_Date >=@Actual_Start_Date AND For_Date <=@Actual_End_Date                
							AND ISNULL(Temp_Sal_Tran_ID,0) = ISNULL(@Sal_Tran_ID,ISNULL(Temp_Sal_Tran_ID,0))                    
							AND ISNULL(L_Sal_Tran_ID,0) = ISNULL(@L_Sal_Tran_ID,ISNULL(L_Sal_Tran_ID,0))                    
							AND EAD.EFFECT_AD_ID = @AD_ID 
					--FROM dbo.T0210_MONTHLY_AD_DETAIL 
					--WHERE Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID                     
					--	 AND For_Date >=@Actual_Start_Date AND For_Date <=@Actual_End_Date                
					--	 AND ISNULL(Temp_Sal_Tran_ID,0) = ISNULL(@Sal_Tran_ID,ISNULL(Temp_Sal_Tran_ID,0))                    
					--	 AND ISNULL(L_Sal_Tran_ID,0) = ISNULL(@L_Sal_Tran_ID,ISNULL(L_Sal_Tran_ID,0))                    
					--	 AND AD_ID IN                     
					--(SELECT AD_ID  FROM dbo.T0060_EFFECT_AD_MASTER                     
					--WHERE Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID) 
					
					-- Added by rohit on 13012015
					SELECT @Other_Allow_Amount_Arear_cutoff = ISNULL(SUM(M_AREAR_AMOUNT_Cutoff),0)  
					FROM	dbo.T0210_MONTHLY_AD_DETAIL MAD INNER JOIN dbo.T0060_EFFECT_AD_MASTER   EAD ON MAD.AD_ID=EAD.AD_ID and mad.Cmp_ID= ead.CMP_ID	
					WHERE	MAD.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID                     
							AND For_Date >=@Actual_Start_Date AND For_Date <=@Actual_End_Date                
							AND ISNULL(Temp_Sal_Tran_ID,0) = ISNULL(@Sal_Tran_ID,ISNULL(Temp_Sal_Tran_ID,0))                    
							AND ISNULL(L_Sal_Tran_ID,0) = ISNULL(@L_Sal_Tran_ID,ISNULL(L_Sal_Tran_ID,0))                    
							AND EAD.EFFECT_AD_ID = @AD_ID
					--FROM dbo.T0210_MONTHLY_AD_DETAIL 
					--WHERE Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID                     
					--	 AND For_Date >=@Actual_Start_Date AND For_Date <=@Actual_End_Date                
					--	 AND ISNULL(Temp_Sal_Tran_ID,0) = ISNULL(@Sal_Tran_ID,ISNULL(Temp_Sal_Tran_ID,0))                    
					--	 AND ISNULL(L_Sal_Tran_ID,0) = ISNULL(@L_Sal_Tran_ID,ISNULL(L_Sal_Tran_ID,0))                    
					--	 AND AD_ID IN                     
					--(SELECT AD_ID  FROM dbo.T0060_EFFECT_AD_MASTER                     
					--WHERE Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID)  
					*/
					
					--PRINT  convert(varchar(20), getdate(), 114) + ' : Query 9003 : Start'
					--PERFORMANCE
					SELECT	@Other_Allow_Amount_actual = ISNULL(SUM(E_AD_amount),0)  
					FROM	dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) on eed.AD_ID = am.AD_ID
							INNER JOIN dbo.T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) ON EED.AD_ID=EAD.AD_ID
					WHERE	eed.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND Increment_Id = @Increment_Id  and am.AD_CALCULATE_ON NOT IN ('Import', 'Present + Paid Leave Days')
							AND EAD.EFFECT_AD_ID=@AD_ID
							--AND eed.AD_ID IN (SELECT AD_ID  FROM  dbo.T0060_EFFECT_AD_MASTER  WHERE Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID) 
					
					/*Added by Nimesh On 07-Dec-2017 (To consider the amount of allowance which are import based and included in ESIC Calculation) */
					--IF (@ESIC_DEF_ID = @AD_DEF_ID OR @Cmp_ESIC_DEF_ID = @AD_DEF_ID)
					--	BEGIN
					--		SELECT	@Other_Allow_Amount_actual =@Other_Allow_Amount_actual  + Isnull(SUM(ISNULL(M_AD_Amount,0)  / CASE WHEN @Wages_type = 'Daily' AND am.AD_CALCULATE_ON = 'Import' Then 26 ELSE 1 END),0)
					--		FROM	dbo.T0210_MONTHLY_AD_DETAIL EED INNER JOIN T0050_AD_MASTER AM on eed.AD_ID = am.AD_ID
					--				INNER JOIN dbo.T0060_EFFECT_AD_MASTER EAD ON EED.AD_ID=EAD.AD_ID
					--		WHERE	eed.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID 
					--				and am.AD_CALCULATE_ON IN ('Import', 'Present + Paid Leave Days') AND EAD.EFFECT_AD_ID=@AD_ID
					--				AND For_Date >=@Actual_Start_Date AND For_Date <= @Actual_End_Date
					--				AND ISNULL(Temp_Sal_Tran_ID,0) = ISNULL(@Sal_Tran_ID,ISNULL(Temp_Sal_Tran_ID,0))
					--				AND ISNULL(L_Sal_Tran_ID,0) = ISNULL(@L_Sal_Tran_ID,ISNULL(L_Sal_Tran_ID,0))
					--	END

    
					SELECT	@ESIC_Calculate_Amount = ISNULL(SUM(E_AD_amount),0)  
					FROM	dbo.T0100_EMP_EARN_DEDUCTION EARN WITH (NOLOCK) INNER JOIN dbo.T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) ON EARN.CMP_ID=EAD.CMP_ID AND EARN.AD_ID=EAD.AD_ID
					WHERE	EARN.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID                     
							--and For_Date >=@From_Date and For_Date <=@To_Date                
							AND Increment_Id = @Increment_Id 
							AND EAD.EFFECT_AD_ID = @AD_ID
					
					
					--PRINT  convert(varchar(20), getdate(), 114) + ' : STEP 1'
					IF @No_of_increment > 1 and @Other_Allow_Amount > 0  ---Added BY Jimit 25092019 As per case at G&D of mid increment and Basic is greater than PF limit
						BEGIN
							--PERFORMANCE
							SELECT	@Other_Allow_Amount_mid = ISNULL(SUM(M_AD_amount),0)  
							FROM	#Allowance_Mid_Prev_Detail MID 
									INNER JOIN dbo.T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) ON MID.Ad_id=EAD.AD_ID 
							WHERE	Emp_ID = @Emp_ID AND EAD.CMP_ID=@Cmp_ID AND EAD.EFFECT_AD_ID=@AD_ID
									--AND AD_ID IN (SELECT AD_ID  FROM dbo.T0060_EFFECT_AD_MASTER WHERE Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID)  

							SET @Other_Allow_Amount = @Other_Allow_Amount  - @Other_Allow_Amount_mid
						end    
					--PRINT  convert(varchar(20), getdate(), 114) + ' : STEP 2'

					If @varCalc_On <> 'On Effected Allowance' --Added by Hardik 25/02/2017 for Enlume Client for PF Calculation is calculated on "On Effected Alowance" Only 
						SET @Calc_On_Allow_Dedu = ISNULL(@Calc_On_Allow_Dedu,0) + ISNULL(@Other_Allow_Amount ,0) --+ @DA_AMOUNT
					ELSE
						SET @Calc_On_Allow_Dedu = ISNULL(@Other_Allow_Amount ,0) 

				   SET @Calc_On_Allow_Dedu_Actual =  ISNULL(@Calc_On_Allow_Dedu_Actual,0) + ISNULL(@Other_Allow_Amount_actual ,0)

				   
				   IF @varCalc_On <>'Gross Salary' AND (@ESIC_DEF_ID = @AD_DEF_ID OR @Cmp_ESIC_DEF_ID = @AD_DEF_ID)
						BEGIN 
							Declare @Fix_Allowance_actual numeric(18,4) -- Added by Hardik 22/01/2019 for Cera as they have Fix allowance which on Monthly base but employee is on Daily base

							Set @Fix_Allowance_actual = 0

							SELECT	@Fix_Allowance_actual = ISNULL(SUM(E_AD_amount),0)  
							FROM	dbo.T0100_EMP_EARN_DEDUCTION EARN WITH (NOLOCK) 
									INNER JOIN dbo.T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) ON EARN.CMP_ID=EAD.CMP_ID AND EARN.AD_ID=EAD.AD_ID
									Inner Join T0050_AD_MASTER AM WITH (NOLOCK) On EARN.Ad_Id = AM.AD_ID
							WHERE	EARN.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID                     
									AND Increment_Id = @Increment_Id 
									AND EAD.EFFECT_AD_ID = @AD_ID
									AND AM.AD_CALCULATE_ON In ('FIX', 'FIX + JOINING PRORATE')

							SET @ESIC_Basic_Salary = ISNULL(@ESIC_Basic_Salary,0) + ISNULL(@Other_Allow_Amount,0)     
							
					
							
							/*
							Following Code added by Nimesh On 19-Nov-2018 (if Wages Type is Daily then the tructure is uploaded for 
								daily bases)
							*/
							
							IF @Wages_type = 'Daily'
								BEGIN
									SET @ESIC_Basic_Salary_actual  = ISNULL(@ESIC_Basic_Salary_actual ,0)  + ISNULL(@Other_Allow_Amount_actual,0) - Isnull(@Fix_Allowance_actual,0)
									SET @ESIC_Basic_Salary_actual = (@ESIC_Basic_Salary_actual * 26) + @Fix_Allowance_actual
								END
							Else
								SET @ESIC_Basic_Salary_actual  = ISNULL(@ESIC_Basic_Salary_actual ,0)  + ISNULL(@Other_Allow_Amount_actual,0)     
						END

						
					--- ADDED BY HARDIK 18/01/2021 FOR KAYPEE CLIENT FOR PF AND COMPANY PF SHOULD BE CALCULATE ON MAX HOURLY BASIC
					IF (@PF_DEF_ID = @AD_DEF_ID OR @Cmp_PF_DEF_ID = @AD_DEF_ID) AND @SalaryBasis = 'Hour' AND @Wages_type = 'Daily' AND @Actual_Working_Sec > (@Shift_Day_Sec * @Out_Of_Days)
						BEGIN
						
							SET @Calc_On_Allow_Dedu = @Hourly_Salary * ((@Shift_Day_Sec * @Out_Of_Days)/3600)
							
						END
						

	 
					

					--PRINT  convert(varchar(20), getdate(), 114) + ' : STEP 2'
					----------------------------For ESIC range Calcuation from april to september as per Govt. ------------------------     	
					DECLARE @sal_tran_id1 NUMERIC(18,0)  
					SET  @sal_tran_id1=0           

					IF (@ESIC_DEF_ID = @AD_DEF_ID OR @Cmp_ESIC_DEF_ID = @AD_DEF_ID)
						BEGIN 
							DECLARE @FROM_TERM DATETIME
							DECLARE @TO_TERM DATETIME

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
		
							SELECT	TOP 1 @Sal_Tran_ID1=Sal_Tran_ID 
							FROM	dbo.T0200_MONTHLY_SALARY MS WITH (NOLOCK)
							WHERE	Emp_ID=@emp_id AND MS.Cmp_ID=@Cmp_ID AND MS.Month_End_Date BETWEEN @FROM_TERM AND @TO_TERM 
									AND (sal_tran_id <> @Sal_Tran_ID) AND Sal_Cal_Days > 0
									AND EXISTS(SELECT 1 
												FROM	T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) 
														INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID=AD.AD_ID
												WHERE	MS.SAL_TRAN_ID=MAD.SAL_TRAN_ID AND AD.AD_DEF_ID=3)
							ORDER BY MS.Month_End_Date ASC

							IF @sal_tran_id1 = 0 AND NOT EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK) 
																WHERE	MS.Emp_ID=@Emp_Id AND MS.Month_End_Date BETWEEN @FROM_TERM AND @TO_TERM
																		AND Sal_Cal_Days > 0
																		AND EXISTS(SELECT 1 
																					FROM	T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) 
																							INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID=AD.AD_ID
																					WHERE	MS.SAL_TRAN_ID=MAD.SAL_TRAN_ID AND AD.AD_DEF_ID=3)
																) 
								SET @sal_tran_id1 = -1

							-- Added by Hardik 02/02/2021 for Cera, 
							--As they have case that Employee has 0 day salary for Oct-2020 and gross is 16000, 
							--Now they have given Increment on Nov-2020 and gross is 22000, so they want to deduct ESIC in Nov-2020 
							--Also as Oct-2020 Gross is less than 21000, Also Confirm case with Rajeshbhai HMP
							Declare @ESIC_Actual_Gross_Salary_Term Numeric(18,2)
							Set @ESIC_Actual_Gross_Salary_Term = 0

							If  @sal_tran_id1 = -1
								Begin
									select @ESIC_Actual_Gross_Salary_Term= Gross_Salary
									From T0095_Increment I
									Where I.Emp_ID = @Emp_ID and Increment_ID in (SELECT Top 1 Increment_Id FROM T0200_MONTHLY_SALARY MS 
																WHERE	MS.Emp_ID=@Emp_Id AND MS.Month_End_Date BETWEEN @FROM_TERM AND @TO_TERM
																order by Sal_Tran_ID Desc)
									If @ESIC_Actual_Gross_Salary_Term < @ESIC_Limit And @ESIC_Actual_Gross_Salary_Term > 0 
										Set @sal_tran_id1 = -2
								End
							
							 
							IF NOT EXISTS(SELECT 1
										  FROM  dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) 
												INNER JOIN  dbo.T0050_AD_MASTER am WITH (NOLOCK) ON MAD.ad_id= am.ad_id
										  WHERE Sal_Tran_ID= @Sal_Tran_ID1 AND M_AD_Amount > 0 AND AD_DEF_ID=3
										 ) AND @Sal_Tran_ID1 > 0 AND @Production_Based_Salary = 0 
								SET @Sal_Tran_ID1 = 0
						END
					/*
					 IF MONTH(@To_Date)>= 4 AND MONTH(@To_Date)< = 9 AND (@ESIC_DEF_ID = @AD_DEF_ID OR @Cmp_ESIC_DEF_ID = @AD_DEF_ID)
						BEGIN							
							SELECT TOP 1 @Sal_Tran_ID1=M_AD_tran_id 
							FROM  dbo.T0210_MONTHLY_AD_DETAIL MAD 
									INNER JOIN  dbo.T0050_AD_MASTER am ON MAD.ad_id= am.ad_id
							WHERE	emp_id=@emp_id AND MAD.cmp_id=@cmp_id	AND YEAR(@To_Date)=YEAR(MAD.To_date) 
									AND MONTH(MAD.To_date)>=10 AND MONTH(MAD.To_date)<= 12 AND ad_def_id=3 AND (sal_tran_id <> @Sal_Tran_ID or temp_sal_tran_id <> @Sal_Tran_ID)
							ORDER BY MAD.To_date

							IF NOT EXISTS(SELECT 1
										FROM  dbo.T0210_MONTHLY_AD_DETAIL MAD INNER JOIN  dbo.T0050_AD_MASTER am ON MAD.ad_id= am.ad_id
										WHERE M_AD_tran_id= @Sal_Tran_ID1 AND M_AD_Amount > 0) AND @Sal_Tran_ID1 > 0
								SET @Sal_Tran_ID1 = 0
						END
					IF 	MONTH(@To_Date)>= 10 AND MONTH(@To_Date)< = 12 AND (@ESIC_DEF_ID = @AD_DEF_ID OR @Cmp_ESIC_DEF_ID = @AD_DEF_ID)
						BEGIN 
		
							SELECT @sal_tran_id1=M_AD_tran_id FROM dbo.T0210_MONTHLY_AD_DETAIL MAD INNER JOIN dbo.T0050_AD_MASTER am
							ON MAD.ad_id= am.ad_id
							WHERE emp_id=@emp_id AND MAD.cmp_id=@cmp_id	AND YEAR(@To_Date)=YEAR(MAD.To_date) 
							AND MONTH(MAD.To_date)>=10 AND MONTH(MAD.To_date)<= 12 AND ad_def_id=3 AND M_Ad_amount>0 AND (sal_tran_id <> @Sal_Tran_ID or temp_sal_tran_id <> @Sal_Tran_ID)
		
		
						END
					IF	MONTH(@To_Date)>= 1 AND MONTH(@To_Date)< = 3 AND (@ESIC_DEF_ID = @AD_DEF_ID OR @Cmp_ESIC_DEF_ID = @AD_DEF_ID)
						BEGIN 
							SELECT @sal_tran_id1=M_AD_tran_id FROM dbo.T0210_MONTHLY_AD_DETAIL MAD INNER JOIN dbo.T0050_AD_MASTER am
							ON MAD.ad_id= am.ad_id
							WHERE emp_id=@emp_id AND MAD.cmp_id=@cmp_id	AND  MONTH(MAD.To_date)>=1 AND MONTH(MAD.To_date)<= 3 AND M_Ad_amount>0
							AND YEAR(@To_Date)=YEAR(MAD.To_date) AND ad_def_id=3  AND (sal_tran_id <> @Sal_Tran_ID or temp_sal_tran_id <> @Sal_Tran_ID) -- or year(@From_Date)-1=year(for_date) 
							IF MONTH(@To_Date)= 1
								BEGIN
									set statistics time on
									SELECT @sal_tran_id1=M_AD_tran_id FROM dbo.T0210_MONTHLY_AD_DETAIL MAD INNER JOIN dbo.T0050_AD_MASTER am
									ON MAD.ad_id= am.ad_id
									WHERE emp_id=@emp_id AND MAD.cmp_id=@cmp_id	AND  MONTH(MAD.To_date)>=10 AND MONTH(MAD.To_date)<= 12
									AND YEAR(@To_Date)-1=YEAR(MAD.To_date) AND ad_def_id=3 AND M_Ad_amount>0  AND (sal_tran_id <> @Sal_Tran_ID or temp_sal_tran_id <> @Sal_Tran_ID)
									set statistics time off
								END
						END
					*/
					--PRINT  convert(varchar(20), getdate(), 114) + ' : STEP 3'
					----------------------------For ESIC range Calcuation from april to september as per Govt. ------------------------     	
					SELECT @After_Salary = Setting_Value FROM T0040_SETTING WITH (NOLOCK) where Setting_Name='After Salary Overtime Payment Process' AND Cmp_ID=@Cmp_ID  --Added by Jaina 11-09-2017
					
				
					IF @varCalc_On = 'Transfer OT'                     
					  BEGIN 
						IF @After_Salary = 0
							BEGIN	
								---Added by Hardik 07/03/2019 for Cliantha, To Set Fix Hourly OT Rate Calculation
								DECLARE @OT_AMOUNT_SALARY numeric(18,2)
								DECLARE @OT_WO_AMOUNT_SALARY numeric(18,2)
								DECLARE @OT_HO_AMOUNT_SALARY numeric(18,2)
								
								SET @OT_AMOUNT_SALARY = ISNULL(@OT_Amount,0)
								SET @OT_WO_AMOUNT_SALARY = ISNULL(@OT_WO_AMOUNT,0)
								SET @OT_HO_AMOUNT_SALARY = ISNULL(@OT_HO_AMOUNT,0)
								--- End by Hardik 07/03/2019 for Cliantha

							
								--Added By Ramiz on 04/05/2016
								DECLARE @GRADEWISE_SALARY_ISENABLED	TINYINT
								SET @GRADEWISE_SALARY_ISENABLED = 0
								
								SELECT @GRADEWISE_SALARY_ISENABLED = ISNULL(SETTING_VALUE,0) FROM T0040_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND
																	 SETTING_NAME = 'SHOW GRADEWISE SALARY TEXTBOX IN GRADE MASTER'
								--Ended By Ramiz on 04/05/2016 
								
								
									DECLARE @T_amt NUMERIC
									DECLARE @T_amt_WO NUMERIC
									DECLARE @T_amt_HO NUMERIC
									DECLARE @temp_t_amt NUMERIC
									DECLARE @Ot_temp_Amount_WO NUMERIC(18, 4)
									DECLARE @Ot_temp_Amount_HO NUMERIC(18, 4)
									DECLARE @OT_Max_Limit_Sec as Numeric	--Added By Ramiz 19/11/2015
									DECLARE @Emp_WO_HO_OT_Sec as Numeric

									--Added By Ramiz 19/11/2015
									SET @OT_Max_Limit_Sec	= dbo.F_Return_Sec(replace(cast(@OT_Max_Limit as varchar(20)),'.',':')) --> This is the Limit of General Setting
				
										SET @T_amt=0
										SET @T_amt_WO=0
										SET @T_amt_HO=0
										SET @temp_t_amt=0
										SET @Ot_temp_Amount_WO = 0
										SET @Ot_temp_Amount_HO = 0
					
									
									--Commented Above Code By Ramiz & Ankit on 13/01/2016
									SELECT @temp_t_amt = ISNULL(SUM(E_AD_amount),0)
											FROM (
											SELECT 
												 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
													Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
												 Else
													eed.e_ad_Amount End As E_Ad_Amount
											FROM dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN                    
												   dbo.T0050_AD_MASTER ADM WITH (NOLOCK)  ON EEd.AD_ID = ADM.AD_ID   LEFT OUTER JOIN
													( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.ENTRY_TYPE,EEDR.Increment_ID
														From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
														( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
															Where Emp_Id = @Emp_Id And For_date <= @to_date Group by Ad_Id 
														 ) Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
													) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID                  
											WHERE EED.EMP_ID = @emp_id AND eed.increment_id = @Increment_Id And Adm.AD_ACTIVE = 1 AND ISNULL(ADM.AD_EFFECT_ON_OT,0) = 0 -- Added AD_EFFECT_ON_OT Condition by Hardik 04/01/2018 for Chiripal as they tick on effect allowance and effect on OT
													And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
													AND EXISTS(SELECT AD_ID  FROM dbo.T0060_EFFECT_AD_MASTER EAD WHERE Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID AND EED.AD_ID=EAD.AD_ID) 
											UNION ALL
											
											SELECT E_AD_Amount
											FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
												( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
													Where Emp_Id  = @Emp_Id And For_date <= @to_date 
													Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
											   INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK)  ON EEd.AD_ID = ADM.AD_ID                     
											WHERE emp_id = @emp_id 
													And Adm.AD_ACTIVE = 1 AND ISNULL(ADM.AD_EFFECT_ON_OT,0) = 0 -- Added AD_EFFECT_ON_OT Condition by Hardik 04/01/2018 for Chiripal as they tick on effect allowance and effect on OT
													And EEd.ENTRY_TYPE = 'A' AND eed.increment_id = @Increment_Id
													AND EXISTS(SELECT AD_ID  FROM dbo.T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) WHERE Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID AND EED.AD_ID = EAD.AD_ID)
											) Qry
											--Query Ended							
									 	
						---------------------------------End ---------------------------------------------------------------------------------								
					
										If @Shift_Wise_OT_Rate = 1 And Isnull(@Emp_WD_OT_Rate,0) = 9 And Isnull(@Emp_WO_OT_Rate,0) = 9 And Isnull(@Emp_HO_OT_Rate,0) = 9  -- FOR SHOFT SHIP YARD, ADDED BY HARDIK 22/11/2018
											BEGIN
												IF  Cast(@Hour_Salary_OT As Numeric(18,2)) <> CAST(((@OT_Basic_Salary+ISNULL(@temp_t_amt,0)) /@OT_Working_Day) /(@Shift_Day_Sec/3600) As Numeric(18,2))
													BEGIN
														UPDATE	#ShiftWiseOT
															SET		HO_OT_Amount = (Holiday_OT_Sec/3600) * HO_OT_Rate * CAST(((@OT_Basic_Salary + ISNULL(@temp_t_amt,0)) /@OT_Working_Day) /(@Shift_Day_Sec/3600) As Numeric(18,4)),
																	WO_OT_Amount = (Weekoff_OT_Sec/3600) * WO_OT_Rate * CAST(((@OT_Basic_Salary + ISNULL(@temp_t_amt,0)) /@OT_Working_Day) /(@Shift_Day_Sec/3600) As Numeric(18,4)),
																	WD_OT_Amount = (OT_Sec/3600) * WD_OT_Rate * CAST(((@OT_Basic_Salary + ISNULL(@temp_t_amt,0)) /@OT_Working_Day) /(@Shift_Day_Sec/3600) As Numeric(18,4)),
																	Hourly_Salary = CAST((@OT_Basic_Salary /@OT_Working_Day) /(@Shift_Day_Sec/3600) As Numeric(18,4))
						
														SELECT @OT_HO_AMOUNT = Isnull(Case When @IS_ROUNDING = 1 Then Round(Sum(HO_OT_Amount),0) Else Sum(HO_OT_Amount) End,0),
															@OT_WO_AMOUNT = Isnull(Case When @IS_ROUNDING = 1 Then Round(Sum(WO_OT_Amount),0) Else Sum(WO_OT_Amount) End,0),
															@OT_Amount = Isnull(Case When @IS_ROUNDING = 1 Then Round(Sum(WD_OT_Amount),0) Else Sum(WD_OT_Amount) End,0)
														FROM #ShiftWiseOT

														SELECT @M_AD_Amount = ISNULL(@OT_Amount,0) + ISNULL(@OT_WO_AMOUNT,0) + ISNULL(@OT_HO_AMOUNT,0)
														SET @OT_Amount = 0
														SET @OT_WO_AMOUNT = 0
														SET @OT_HO_AMOUNT = 0
													END
												ELSE
													BEGIN
														SELECT @M_AD_Amount = ISNULL(@OT_Amount,0) + ISNULL(@OT_WO_AMOUNT,0) + ISNULL(@OT_HO_AMOUNT,0)
														SET @OT_Amount = 0
														SET @OT_WO_AMOUNT = 0
														SET @OT_HO_AMOUNT = 0
													END
											END
										
				
										IF @OT_Working_Day <> 0 AND @Shift_Day_Sec <> 0 and @Wages_type ='Monthly' And @Shift_Wise_OT_Rate = 0	--Here @Wages_type ='Monthly' is Added By Ramiz on 09/12/2015
											BEGIN
												--Started By Ramiz 19/11/2015
												IF @OT_Max_Limit_Sec > 0 AND (@Emp_WD_OT_Rate = @Emp_WO_OT_Rate) AND (@Emp_WO_OT_Rate = @Emp_HO_OT_Rate)
													BEGIN
														SET @Emp_WO_HO_OT_Sec	= ISNULL(@OT_Sec,0) + ISNULL(@WO_OT_Sec,0) + ISNUll(@HO_OT_Sec,0)
														IF @Emp_WO_HO_OT_Sec > 0 and @Emp_WO_HO_OT_Sec > @OT_Max_Limit_Sec
															BEGIN    
																SET @Emp_WO_HO_OT_Sec = @OT_Max_Limit_Sec 
															End
													END
												 Else	--This was Original Condition before Adding By Ramiz on 19/11/2015
													BEGIN
														IF @IS_ROUNDING = 1	--Rounding Condition Added By Ramiz on 17/07/2018 for Diamines
															BEGIN
																SET @T_Amt =  ROUND(@OT_Sec * ((@temp_t_amt /@OT_Working_Day) /@Shift_Day_Sec),0)
																SET @T_amt_WO =  ROUND(@WO_OT_Sec * ((@temp_t_amt /@OT_Working_Day) /@Shift_Day_Sec),0)
																SET @T_amt_HO =  ROUND(@HO_OT_Sec * ((@temp_t_amt /@OT_Working_Day) /@Shift_Day_Sec),0)
															END
														ELSE
															BEGIN
																SET @T_Amt =  @OT_Sec * ((@temp_t_amt /@OT_Working_Day) /@Shift_Day_Sec)
																SET @T_amt_WO =  @WO_OT_Sec * ((@temp_t_amt /@OT_Working_Day) /@Shift_Day_Sec)
																SET @T_amt_HO =  @HO_OT_Sec * ((@temp_t_amt /@OT_Working_Day) /@Shift_Day_Sec)
															END
													END
											END
										ELSE		--This Condition is for "Wages_types = Daily" Added By Ramiz on 09/12/2015
												BEGIN
													If @Shift_Day_Sec > 0 ---Codition added by Hardik 08/01/2016, if @Emp_OT = 0 then it will give divide by zero error
														BEGIN
															IF @IS_ROUNDING = 1	--Rounding Condition Added By Ramiz on 17/07/2018 for Diamines
																BEGIN
																	SET @T_Amt =  ROUND(@OT_Sec * (@temp_t_amt /@Shift_Day_Sec),0)
																	SET @T_amt_WO =  ROUND(@WO_OT_Sec * (@temp_t_amt /@Shift_Day_Sec),0)
																	SET @T_amt_HO =  ROUND(@HO_OT_Sec * (@temp_t_amt /@Shift_Day_Sec),0)
																END
															ELSE
																BEGIN
																	SET @T_Amt =  @OT_Sec * (@temp_t_amt /@Shift_Day_Sec)
																	SET @T_amt_WO =  @WO_OT_Sec * (@temp_t_amt /@Shift_Day_Sec)
																	SET @T_amt_HO =  @HO_OT_Sec * (@temp_t_amt /@Shift_Day_Sec)
																END
														END
												END

							IF(ISNULL(@OT_RATE_TYPE,0) = 0) And @Shift_Wise_OT_Rate = 0 -- This was Original Condition before Adding By Rajput on 18072018
								BEGIN

									SET @varCalc_On ='FIX'  
				
									IF @Wages_type ='Monthly'
									   BEGIN
   											IF @OT_Working_Day <> 0 AND @Shift_Day_Sec <> 0
											--Added By Ramiz 18/11/2015  -->Here Amount is Calculated ( This Code is Done for Mafatlal , And it will work if Max Limit is Assigned in General Settings
   												IF @OT_Max_Limit_Sec > 0 AND (@Emp_WD_OT_Rate = @Emp_WO_OT_Rate) AND (@Emp_WO_OT_Rate = @Emp_HO_OT_Rate)
													BEGIN
															If ISNULL(@Sal_Fix_Days,0) > 0 
																BEGIN
																	SET @OT_Amount = ROUND(@Emp_WO_HO_OT_Sec * ((@OT_Basic_Salary + @temp_t_amt)/@Sal_Fix_Days) /@Shift_Day_Sec,0)
																END
															Else
																BEGIN

																	SET @OT_Amount = ROUND(@Emp_WO_HO_OT_Sec * ((@OT_Basic_Salary + @temp_t_amt)/@OT_Working_Day) /@Shift_Day_Sec,0)
																END
														
														SET @OT_Amount = ISNULL(@OT_Amount,0) * @Emp_WD_OT_Rate
														SET @M_AD_Amount = ISNULL(@OT_Amount,0)
														
														--ADDED BY RAMIZ ON 04/05/2016 FOR MERGING OT HOURS UNDER SINGLE COLUMN
			  											IF (@GRADEWISE_SALARY_ISENABLED > 0)
			  												BEGIN
																SET @EMP_MAX_OT_IN_HOURS = Cast(REPLACE(dbo.F_Return_Hours(@Emp_WO_HO_OT_Sec),':','.') as Numeric(18,2))
																IF OBJECT_ID('tempdb..#OT_TABLE') IS NOT NULL
																	BEGIN
																		INSERT INTO #OT_TABLE (EMP_ID_TEMP , OT_HOURS_TEMP , OT_AMOUNT_TEMP) 
																		VALUES (@EMP_ID , @EMP_MAX_OT_IN_HOURS , @OT_AMOUNT)
																	END
			  												END
			  											--ENDED BY RAMIZ ON 04/05/2016
														
														SET @OT_AMOUNT = 0 
														SET @OT_WO_AMOUNT = 0 
														SET @OT_HO_AMOUNT = 0
													END
												 ELSE		--This was Original Condition
	  												BEGIN
	  												
	  													IF @IS_ROUNDING = 1
			  												BEGIN
	  															SET @OT_Amount = ROUND(@OT_Sec * (@OT_Basic_Salary /@OT_Working_Day) /@Shift_Day_Sec,0)			  			
	  															SET @Ot_temp_Amount_WO = ROUND(@WO_OT_Sec * (@OT_Basic_Salary /@OT_Working_Day) /@Shift_Day_Sec,0)			  			
	  															SET @Ot_temp_Amount_HO = ROUND(@HO_OT_Sec * (@OT_Basic_Salary /@OT_Working_Day) /@Shift_Day_Sec,0)			  			
				  											END
				  										ELSE
				  											BEGIN
				  												SET @OT_Amount = @OT_Sec * (@OT_Basic_Salary /@OT_Working_Day) /@Shift_Day_Sec
	  															SET @Ot_temp_Amount_WO = @WO_OT_Sec * (@OT_Basic_Salary /@OT_Working_Day) /@Shift_Day_Sec			  			
	  															SET @Ot_temp_Amount_HO = @HO_OT_Sec * (@OT_Basic_Salary /@OT_Working_Day) /@Shift_Day_Sec
				  											END
				  										
	  													--SET @OT_Amount = @OT_Amount + @T_amt
	  													--SET @OT_Amount = @OT_Amount * @Emp_WD_OT_Rate
														SET @OT_Amount = ROUND(@OT_Amount + @T_amt,0) -- Added By Sajid 03032022
	  													SET @OT_Amount = ROUND(@OT_Amount * @Emp_WD_OT_Rate,0) -- Added By Sajid 03032022
					    			
	    												SET @Ot_temp_Amount_WO = @Ot_temp_Amount_WO + @T_amt_WO
	  													SET @Ot_temp_Amount_WO = @Ot_temp_Amount_WO * @Emp_WO_OT_Rate
					    								
	    												SET @Ot_temp_Amount_HO = @Ot_temp_Amount_HO+ @T_amt_HO
	  													SET @Ot_temp_Amount_HO = @Ot_temp_Amount_HO * @Emp_HO_OT_Rate                            					

					    			  					--- Added below 2 IF Conditions by Hardik 07/03/2019 for Cliantha, for Fix Hourly OT Rate..
					    			  					IF ISNULL(@FIX_OT_HOUR_RATE_WD,0) <> 0
					    			  						SET @OT_AMOUNT = @OT_AMOUNT_SALARY
					    			  					
					    			  					If Isnull(@FIX_OT_HOUR_RATE_WO_HO,0) <> 0
															BEGIN
																SET @Ot_temp_Amount_WO = @OT_WO_AMOUNT_SALARY + @OT_HO_AMOUNT_SALARY
																Set @Ot_temp_Amount_HO = 0
															END
					    			  					
	    												SET @M_AD_Amount = ISNULL(@OT_Amount,0) + ISNULL(@Ot_temp_Amount_WO,0) + ISNULL(@Ot_temp_Amount_HO,0)				
			    									
	   													SET @OT_Amount = 0 
	   													SET @Ot_temp_Amount_WO = 0
														SET @Ot_temp_Amount_HO = 0  
									  
														-- below to var is set to get ouput in prodata sp START
														SET @OT_WO_AMOUNT = 0 
														SET @OT_HO_AMOUNT = 0 
														-- below to var is set to get ouput in prodata sp END
	   												END
									   END
									ELSE
										BEGIN
											IF @Shift_Day_Sec <> 0
												BEGIN
													IF @IS_ROUNDING = 1	--Rounding Condition Added By Ramiz on 17/07/2018 for Diamines
														BEGIN
															SET @OT_Amount = ROUND(@OT_Sec * (@OT_Basic_Salary) /@Shift_Day_Sec,0)
															SET @Ot_temp_Amount_WO = ROUND(@WO_OT_Sec * (@OT_Basic_Salary) /@Shift_Day_Sec,0)			  			
															SET @Ot_temp_Amount_HO = ROUND(@HO_OT_Sec * (@OT_Basic_Salary) /@Shift_Day_Sec,0)			  			
							  							END
							  						ELSE
							  							BEGIN
							  								SET @OT_Amount = @OT_Sec * (@OT_Basic_Salary) /@Shift_Day_Sec
															SET @Ot_temp_Amount_WO = @WO_OT_Sec * (@OT_Basic_Salary) /@Shift_Day_Sec
															SET @Ot_temp_Amount_HO = @HO_OT_Sec * (@OT_Basic_Salary) /@Shift_Day_Sec
							  							END
													
													--SET @OT_Amount = @OT_Amount + @T_amt 
													--SET @OT_Amount = @OT_Amount + @OT_Amount * @Ex_OT_Setting			
								
													SET @OT_Amount = @OT_Amount + @T_amt
													SET @OT_Amount = @OT_Amount * @Emp_WD_OT_Rate
				    			
													SET @Ot_temp_Amount_WO = @Ot_temp_Amount_WO + @T_amt_WO
													SET @Ot_temp_Amount_WO = @Ot_temp_Amount_WO * @Emp_WO_OT_Rate
				    			
													SET @Ot_temp_Amount_HO = @Ot_temp_Amount_HO+ @T_amt_HO
													SET @Ot_temp_Amount_HO = @Ot_temp_Amount_HO * @Emp_HO_OT_Rate                            					
				    						    			
													-- Deepal 14-09-2024 add for the west coast #31283
													IF ISNULL(@FIX_OT_HOUR_RATE_WD,0) <> 0
					    			  						SET @OT_AMOUNT = @OT_AMOUNT_SALARY

														If Isnull(@FIX_OT_HOUR_RATE_WO_HO,0) <> 0
															BEGIN
																SET @Ot_temp_Amount_WO = @OT_WO_AMOUNT_SALARY + @OT_HO_AMOUNT_SALARY
																Set @Ot_temp_Amount_HO = 0
															END
													-- Deepal 14-09-2024 add for the west coast #31283

													SET @M_AD_Amount = ISNULL(@OT_Amount,0) + ISNULL(@Ot_temp_Amount_WO,0) + ISNULL(@Ot_temp_Amount_HO,0)			                           
													
													SET @OT_Amount = 0    
													SET @Ot_temp_Amount_WO = 0
													SET @Ot_temp_Amount_HO = 0        
								
													-- below to var is set to get ouput in prodata sp START
													SET @OT_WO_AMOUNT = 0 
													SET @OT_HO_AMOUNT = 0 
													-- below to var is set to get ouput in prodata sp END  
												END     
										END		

							     END
							ELSE
								IF @Shift_Wise_OT_Rate = 0
								BEGIN
									---- GENCHI CLIENT FLOW FOR OVERTIME SLAB WISE WORK ADDED BY RAJPUT ON 18072018----
									If @OT_Sec > 0 OR  @WO_OT_Sec > 0 OR @HO_OT_Sec > 0
										BEGIN 
												
											CREATE TABLE #OT_SLAB_MASTER
											(
												 ROW_ID INT,
												 FROM_HOURS NUMERIC(18,2),
												 TO_HOURS NUMERIC(18,2),
												 WD_RATE NUMERIC(18,2),
												 WO_RATE NUMERIC(18,2),
												 HO_RATE NUMERIC(18,2),
												 PERIOD_HOURS NUMERIC(18,2),
												 OT_HOURS NUMERIC(18,2),
												 OT_SLAB_AMOUNT NUMERIC(18,2),
												 FLAG INT
											)
												
													
											DECLARE @OT_SLAB_DWOHO_HOURS AS NUMERIC(18,2) = 0
											
											IF EXISTS(SELECT 1 FROM DBO.T0050_GENERAL_OT_RATE_SLABWISE WITH (NOLOCK) WHERE Gen_ID=@GEN_ID AND @OT_SLAB_TYPE = 0)
												BEGIN
														INSERT INTO #OT_SLAB_MASTER
														SELECT	ROW_NUMBER() OVER (ORDER BY WO_RATE ASC) AS ROW_ID,FROM_HOURS,TO_HOURS,WD_RATE,WO_RATE,HO_RATE,0 AS PERIOD_HOURS,0 AS OT_HOURS,0 AS OT_SLAB_AMOUNT,0 AS FLAG 
														FROM DBO.T0050_GENERAL_OT_RATE_SLABWISE WITH (NOLOCK) 
														WHERE GEN_ID=@GEN_ID 	
															
														
														set @Emp_OT_Hours_Num = @OT_Sec/3600
														set @Emp_WO_OT_Hours_Num = @WO_OT_Sec/3600 
														set @Emp_HO_OT_Hours_Num = @HO_OT_Sec/3600 
														set @SHIFT_HOURS_NUM = @Shift_Day_Sec/3600 
														
														SET @OT_SLAB_DWOHO_HOURS = @Emp_OT_Hours_Num + @Emp_WO_OT_Hours_Num +  @Emp_HO_OT_Hours_Num
														
														
														DECLARE @FROM_HOURS AS NUMERIC(18,2),@TO_HOURS AS NUMERIC(18,2),@WD_RATE AS NUMERIC(18,2),@FLAG AS INTEGER	
														DECLARE @SLAB_DIFF AS NUMERIC(18,2) = 0 ,@OT_HOURS AS NUMERIC(18,2) = 0,@OT_SLAB_AMOUNT AS NUMERIC(18,2) = 0 
														DECLARE @CUR_COUNT AS INTEGER = 0,@PREV_TO_HOURS AS NUMERIC(18,2) = 0
														
														SET @OT_HOURS = @OT_SLAB_DWOHO_HOURS
														
														
														DECLARE OT_SLAB_CURSOR CURSOR fast_forward FOR 
														SELECT FROM_HOURS,TO_HOURS,WD_RATE,FLAG FROM #OT_SLAB_MASTER
														
														OPEN OT_SLAB_CURSOR    
														FETCH next FROM OT_SLAB_CURSOR INTO @FROM_HOURS,@TO_HOURS,@WD_RATE,@FLAG
														WHILE @@FETCH_STATUS = 0 
														BEGIN    
															
															SET @CUR_COUNT = @CUR_COUNT + 1
															
															
															
															IF(ISNULL(@CUR_COUNT,0) = 1)
																BEGIN
																	--SET @SLAB_DIFF = (ISNULL(@TO_HOURS,0) - ISNULL(@FROM_HOURS,0)) + 1
																	SET @SLAB_DIFF = (ISNULL(@TO_HOURS,0))
																	
																END
															ELSE
																BEGIN
																
																	SELECT @PREV_TO_HOURS = ISNULL(TO_HOURS,0) 
																	FROM #OT_SLAB_MASTER
																	WHERE ROW_ID = @CUR_COUNT - 1
																	
																	SET @SLAB_DIFF = (ISNULL(@TO_HOURS,0) - ISNULL(@PREV_TO_HOURS,0))
																	
																	
																END
																
															
															IF(@OT_HOURS >= @SLAB_DIFF)
																BEGIN
																
																
																	IF @IS_ROUNDING = 1   
																		BEGIN
																				
																			--SET @OT_SLAB_AMOUNT = ROUND(@Hour_Salary_OT * @WD_RATE * @SLAB_DIFF,0) 
																			SET @OT_SLAB_AMOUNT = ROUND(@WD_RATE * @SLAB_DIFF  * ((@OT_Basic_Salary)/@OT_Working_Day) /@SHIFT_HOURS_NUM,0)
																			
																		END
																	ELSE
																		BEGIN									
																			--SET @OT_SLAB_AMOUNT = (@Hour_Salary_OT) * @WD_RATE * @SLAB_DIFF
																			SET @OT_SLAB_AMOUNT = ROUND(@WD_RATE * @SLAB_DIFF  * ((@OT_Basic_Salary)/@OT_Working_Day) /@SHIFT_HOURS_NUM,0)
																		END
																	
																	
																	UPDATE	#OT_SLAB_MASTER SET PERIOD_HOURS = @SLAB_DIFF ,OT_HOURS = @SLAB_DIFF ,OT_SLAB_AMOUNT = @OT_SLAB_AMOUNT, FLAG = 1 WHERE From_Hours = @FROM_HOURS AND
																			TO_HOURS = @TO_HOURS AND WD_Rate = @WD_RATE
																			
																			
																END
															ELSE
																BEGIN
																
																	IF(@OT_HOURS > 0)
																		BEGIN
																			
																			IF @IS_ROUNDING = 1   
																				BEGIN
																					--SET @OT_SLAB_AMOUNT = ROUND(@Hour_Salary_OT * @WD_RATE * @OT_HOURS,0)
																					SET @OT_SLAB_AMOUNT = ROUND(@WD_RATE * @OT_HOURS  * ((@OT_Basic_Salary)/@OT_Working_Day) /@SHIFT_HOURS_NUM,0)
																				END
																			ELSE
																				BEGIN									
																					--SET @OT_SLAB_AMOUNT = (@Hour_Salary_OT) * @WD_RATE * @OT_HOURS
																					SET @OT_SLAB_AMOUNT = ROUND(@WD_RATE * @OT_HOURS  * ((@OT_Basic_Salary)/@OT_Working_Day) /@SHIFT_HOURS_NUM,0)
																				END
																			
																			
																			UPDATE #OT_SLAB_MASTER SET PERIOD_HOURS = @SLAB_DIFF,OT_HOURS = @OT_HOURS ,OT_SLAB_AMOUNT = @OT_SLAB_AMOUNT,FLAG = 1 WHERE From_Hours = @FROM_HOURS AND
																			TO_HOURS = @TO_HOURS AND WD_Rate = @WD_RATE
																				
																			
																		END
																END
																
														    
														  
															SET @OT_HOURS = @OT_HOURS - @SLAB_DIFF
															SET @OT_Amount = 0    -- SET FOR AUTO OT
															SET @Ot_temp_Amount_WO = 0
															SET @Ot_temp_Amount_HO = 0        
															SET @OT_WO_AMOUNT = 0 
															SET @OT_HO_AMOUNT = 0 
															
															
															FETCH NEXT FROM OT_SLAB_CURSOR     
															INTO @FROM_HOURS,@TO_HOURS,@WD_RATE,@FLAG
														END     
														CLOSE OT_SLAB_CURSOR;    
														DEALLOCATE OT_SLAB_CURSOR;  
														
														
														SELECT @M_AD_AMOUNT=SUM(OT_SLAB_AMOUNT) 
														FROM #OT_SLAB_MASTER
									
														END
											ELSE
												BEGIN
													IF EXISTS(SELECT 1 FROM DBO.T0050_GENERAL_OT_RATE_SLABWISE WITH (NOLOCK) WHERE Gen_ID=@GEN_ID AND @OT_SLAB_TYPE = 1)
														BEGIN
															
															INSERT INTO #OT_SLAB_MASTER
															SELECT	ROW_NUMBER() OVER (ORDER BY WO_RATE ASC) AS ROW_ID,FROM_HOURS,TO_HOURS,WD_RATE,WO_RATE,HO_RATE,0 AS PERIOD_HOURS,0 AS OT_HOURS,0 AS OT_SLAB_AMOUNT,0 AS FLAG 
															FROM DBO.T0050_GENERAL_OT_RATE_SLABWISE WITH (NOLOCK) 
															WHERE GEN_ID=@GEN_ID 
															
															set @Emp_OT_Hours_Num = @OT_Sec/3600
															set @Emp_WO_OT_Hours_Num = @WO_OT_Sec/3600 
															set @Emp_HO_OT_Hours_Num = @HO_OT_Sec/3600 
															set @SHIFT_HOURS_NUM = @Shift_Day_Sec/3600 
															
															SET @OT_SLAB_DWOHO_HOURS = @Emp_OT_Hours_Num + @Emp_WO_OT_Hours_Num +  @Emp_HO_OT_Hours_Num
															SET @OT_HOURS = @OT_SLAB_DWOHO_HOURS
															
															SELECT @WD_RATE = WD_RATE FROM #OT_SLAB_MASTER
															WHERE  @OT_HOURS BETWEEN FROM_HOURS AND TO_HOURS
															
															--IF @IS_ROUNDING = 1   
															--	BEGIN
															--		SET @OT_SLAB_AMOUNT = ROUND(@Hour_Salary_OT * @WD_RATE * @OT_HOURS,0) 
															--	END
															--ELSE
															--	BEGIN
															--		SET @OT_SLAB_AMOUNT = (@Hour_Salary_OT) * @WD_RATE * @OT_HOURS
															--	END
															
															IF @IS_ROUNDING = 1   
																BEGIN
																	SET @OT_SLAB_AMOUNT = ROUND(@WD_RATE * @OT_HOURS  * ((@OT_Basic_Salary)/@OT_Working_Day) /@SHIFT_HOURS_NUM,0)
																END
															ELSE
																BEGIN
																	SET @OT_SLAB_AMOUNT =  @WD_RATE * @OT_HOURS * ((@OT_Basic_Salary)/@OT_Working_Day) /@SHIFT_HOURS_NUM
																END
														  
															SET @M_AD_AMOUNT = @OT_SLAB_AMOUNT
															SET @OT_Amount = 0    -- SET FOR AUTO OT
															SET @Ot_temp_Amount_WO = 0
															SET @Ot_temp_Amount_HO = 0        
															SET @OT_WO_AMOUNT = 0 
															SET @OT_HO_AMOUNT = 0 
														END
													ELSE
														BEGIN
															SET @M_AD_AMOUNT = 0
														END
														
														
												END	
													
										END
									ELSE
										BEGIN
											SET @M_AD_AMOUNT = 0
										END		
									---- END ----	
								END
								   --Fix OT Rate--Ankit 05092016
								   /* 
										Day Rate Need to Update Manual In T0030_CATEGORY_MASTER Table : Column Name -OT_Rate_11PM : Guru Krupa Client
								   */
								   Declare @Cat_ID NUmeric
								   set @Cat_ID =0
							       
								   SELECT @Cat_ID = ISNULL(Cat_ID,0) FROM dbo.T0095_Increment WITH (NOLOCK) WHERE Increment_Id=@Increment_Id AND Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_ID
							       
								   IF @Cat_ID <> 0 AND EXISTS( SELECT 1 FROM T0030_CATEGORY_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Cat_ID = @Cat_ID AND OT_Rate_11PM > 0 )
										BEGIN
											DECLARE @OT_Sec_B_11 NUMERIC
											SET @OT_Sec_B_11 = 0
											
											DECLARE @OT_Sec_A_11 NUMERIC
											SET @OT_Sec_A_11 = 0
											
											DECLARE @OT_Rate_11PM NUMERIC(10,3)
											SET @OT_Rate_11PM = 0
											
											DECLARE @Fix_OT_Rate_Amount NUMERIC(18,2)
											SET @Fix_OT_Rate_Amount = 0	
																			
											DECLARE @Fix_OT_Salary NUMERIC(18,2)
											SET @Fix_OT_Salary = 0
											
											DECLARE @Fix_OT_Day_D NUMERIC
											SET @Fix_OT_Day_D = 0
											
											Declare @Fix_OT_Rate_Amount_A Numeric(18,2)
											set @Fix_OT_Rate_Amount_A = 0
											
											SELECT @OT_Rate_11PM = OT_Rate_11PM FROM T0030_CATEGORY_MASTER WITH (NOLOCK) 
											WHERE Cmp_ID = @Cmp_ID and OT_Rate_11PM > 0  and Cat_ID = @Cat_ID
											
											SET @Fix_OT_Salary = ISNULL(@OT_Basic_Salary,0) + ISNULL(@temp_t_amt,0)
									
											--SET @OT_Rate_11PM = 1.168
											
											--SELECT	@OT_Sec_B_11 = ISNULL(SUM(OT_Sec) + SUM(Weekoff_OT_Sec) + SUM(Holiday_OT_Sec) ,0)
											--FROM	#DATA 
											--WHERE	Emp_ID = @Emp_Id AND (OT_sec <> 0 OR Weekoff_OT_Sec <> 0 OR Holiday_OT_Sec <> 0)
											--			AND Out_Time <= For_Date + CONVERT(DATETIME,'23:00:00.000')
											
											SELECT	@OT_Sec_A_11 = ISNULL(SUM(OT_Sec) + SUM(Weekoff_OT_Sec) + SUM(Holiday_OT_Sec) ,0)
											FROM	#DATA 
											WHERE	Emp_ID = @Emp_Id AND (OT_sec <> 0 OR Weekoff_OT_Sec <> 0 OR Holiday_OT_Sec <> 0)
														AND Out_Time >= For_Date + CONVERT(DATETIME,'23:01:00.000') 
														AND Shift_Start_time < Shift_End_Time
										
											--NEW CODE ADDED BY RAMIZ ON 01/11/2017 FOR CALCULATING OT ON DIFFERENT RATES --
									
											IF @OT_Sec_A_11 <> 0
												BEGIN
													DECLARE @OT_Sec_B_11_OT as NUMERIC
													DECLARE @OT_Sec_B_11_OT_AMT as NUMERIC(18,2)
													SET @OT_Sec_B_11_OT = 0
													SET @OT_Sec_B_11_OT_AMT = 0 
													
													DECLARE @OT_Sec_B_11_WO as NUMERIC
													DECLARE @OT_Sec_B_11_WO_AMT as NUMERIC(18,2)
													SET @OT_Sec_B_11_WO = 0
													SET @OT_Sec_B_11_WO_AMT = 0
													
													DECLARE @OT_Sec_B_11_HO as NUMERIC
													DECLARE @OT_Sec_B_11_HO_AMT as NUMERIC(18,2)
													SET @OT_Sec_B_11_HO = 0
													SET @OT_Sec_B_11_HO_AMT = 0
												
													--CALCULATING NORMAL DAY OT HOURS 
													SELECT	@OT_Sec_B_11_OT = ISNULL(SUM(OT_Sec),0)
													FROM	#DATA 
													WHERE	Emp_ID = @Emp_Id AND OT_sec <> 0 AND Weekoff_OT_Sec = 0 AND Holiday_OT_Sec = 0
																AND Out_Time <= For_Date + CONVERT(DATETIME,'23:00:00.000')
																
													--CALCULATING WEEKOFF DAY OT HOURS 
													SELECT	@OT_Sec_B_11_WO = ISNULL(SUM(Weekoff_OT_Sec) ,0)
													FROM	#DATA 
													WHERE	Emp_ID = @Emp_Id AND OT_sec = 0 AND Weekoff_OT_Sec <> 0 AND Holiday_OT_Sec = 0
																AND Out_Time <= For_Date + CONVERT(DATETIME,'23:00:00.000')
													
													--CALCULATING HOLIDAY OT HOURS 
													SELECT	@OT_Sec_B_11_HO = ISNULL(SUM(Holiday_OT_Sec) ,0)
													FROM	#DATA 
													WHERE	Emp_ID = @Emp_Id AND OT_sec = 0 AND Weekoff_OT_Sec = 0 AND Holiday_OT_Sec <> 0
																AND Out_Time <= For_Date + CONVERT(DATETIME,'23:00:00.000')
													
												--NEW CODE ADDED BY RAMIZ ON 01/11/2017 FOR CALCULATING OT ON DIFFERENT RATES --			
												
												
													IF @Wages_type ='Monthly'
														BEGIN
															SET @OT_Sec_B_11_OT_AMT = ISNULL(ROUND( (@OT_Sec_B_11_OT * (@Fix_OT_Salary/@OT_Working_Day)) /@Shift_Day_Sec,0) * @Emp_WD_OT_Rate,0)
															SET @OT_Sec_B_11_WO_AMT = ISNULL(ROUND( (@OT_Sec_B_11_WO * (@Fix_OT_Salary/@OT_Working_Day)) /@Shift_Day_Sec,0) * @Emp_WO_OT_Rate,0)
															SET @OT_Sec_B_11_HO_AMT = ISNULL(ROUND( (@OT_Sec_B_11_HO * (@Fix_OT_Salary/@OT_Working_Day)) /@Shift_Day_Sec,0) * @Emp_HO_OT_Rate,0)
															
															SET @Fix_OT_Rate_Amount = ISNULL(@OT_Sec_B_11_OT_AMT,0) + ISNULL(@OT_Sec_B_11_WO_AMT,0) + ISNULL(@OT_Sec_B_11_HO_AMT,0) --ADDED BY RAMIZ ON 01/11/2017
															--SET @Fix_OT_Rate_Amount = ISNULL(ROUND( (@OT_Sec_B_11 * (@Fix_OT_Salary/@OT_Working_Day)) /@Shift_Day_Sec,0) * @Emp_WD_OT_Rate,0)
															SET @Fix_OT_Rate_Amount_A = ISNULL(ROUND( (@OT_Sec_A_11 * (@Fix_OT_Salary/@OT_Working_Day)) /@Shift_Day_Sec,0) * @OT_Rate_11PM,0)
														
														END
													ELSE
														BEGIN
															SET @OT_Sec_B_11_OT_AMT = ISNULL(ROUND( (@OT_Sec_B_11_OT * (@Fix_OT_Salary)) /@Shift_Day_Sec,0) * @Emp_WD_OT_Rate,0)
															SET @OT_Sec_B_11_WO_AMT = ISNULL(ROUND( (@OT_Sec_B_11_WO * (@Fix_OT_Salary)) /@Shift_Day_Sec,0) * @Emp_WO_OT_Rate,0)
															SET @OT_Sec_B_11_HO_AMT = ISNULL(ROUND( (@OT_Sec_B_11_HO * (@Fix_OT_Salary)) /@Shift_Day_Sec,0) * @Emp_HO_OT_Rate,0)
															
															SET @Fix_OT_Rate_Amount = ISNULL(@OT_Sec_B_11_OT_AMT,0) + ISNULL(@OT_Sec_B_11_WO_AMT,0) + ISNULL(@OT_Sec_B_11_HO_AMT,0) --ADDED BY RAMIZ ON 01/11/2017

															--SET @Fix_OT_Rate_Amount = ISNULL(ROUND( (@OT_Sec_B_11 * (@Fix_OT_Salary)) /@Shift_Day_Sec,0) * @Emp_WD_OT_Rate,0) --COMMENTED BY RAMIZ ON 01/11/2017
															SET @Fix_OT_Rate_Amount_A = ISNULL(ROUND( (@OT_Sec_A_11 * (@Fix_OT_Salary)) /@Shift_Day_Sec,0) * @OT_Rate_11PM,0)
														END		
												
														SET @M_AD_Amount = @Fix_OT_Rate_Amount + @Fix_OT_Rate_Amount_A
												END
										END
								END
					   --    --Fix OT Rate--
					  END      
					  Else IF @varCalc_On = 'Present on Holiday'                   
						BEGIN  
						
									Declare @temp_POH as numeric(18,2)  = 0

									set @M_AD_Amount = ISNULL(@Day_Salary,0) * isnull(@Rate_Of_National_Holiday,0) * isnull(@Present_On_Holiday,0)
									
									--SELECT @temp_POH = ISNULL(SUM(E_AD_amount),0)
									--		FROM (
									--		SELECT 
									--			 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
									--				Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
									--			 Else
									--				eed.e_ad_Amount End As E_Ad_Amount
									--		FROM dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN                    
									--			   dbo.T0050_AD_MASTER ADM WITH (NOLOCK)  ON EEd.AD_ID = ADM.AD_ID   LEFT OUTER JOIN
									--				( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.ENTRY_TYPE,EEDR.Increment_ID
									--					From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
									--					( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
									--						Where Emp_Id = @Emp_Id And For_date <= @to_date Group by Ad_Id 
									--					 ) Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
									--				) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID                  
									--		WHERE EED.EMP_ID = @emp_id AND eed.increment_id = @Increment_Id And Adm.AD_ACTIVE = 1 AND ISNULL(ADM.AD_EFFECT_ON_OT,0) = 0 -- Added AD_EFFECT_ON_OT Condition by Hardik 04/01/2018 for Chiripal as they tick on effect allowance and effect on OT
									--				And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
									--				AND EXISTS(SELECT AD_ID  FROM dbo.T0060_EFFECT_AD_MASTER EAD WHERE Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID AND EED.AD_ID=EAD.AD_ID) 
									--		UNION ALL
									--		SELECT E_AD_Amount
									--		FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
									--			( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
									--				Where Emp_Id  = @Emp_Id And For_date <= @to_date 
									--				Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
									--		   INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK)  ON EEd.AD_ID = ADM.AD_ID                     
									--		WHERE emp_id = @emp_id 
									--				And Adm.AD_ACTIVE = 1 AND ISNULL(ADM.AD_EFFECT_ON_OT,0) = 0 -- Added AD_EFFECT_ON_OT Condition by Hardik 04/01/2018 for Chiripal as they tick on effect allowance and effect on OT
									--				And EEd.ENTRY_TYPE = 'A' AND eed.increment_id = @Increment_Id
									--				AND EXISTS(SELECT AD_ID  FROM dbo.T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) 
									--				WHERE Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID AND EED.AD_ID = EAD.AD_ID)
									--		) Qry
									--		--Query Ended	
											 				
						END  
					-- Added By rohit on 17122014
					Else IF @varCalc_On = 'Night Halt'                     
						BEGIN  
							SELECT @M_AD_Amount = isnull(SUM(Amount),0) from T0120_NIGHT_HALT_APPROVAL WITH (NOLOCK) where Emp_ID=@Emp_Id and App_Status ='A' and isnull(Is_Effect_Sal,0) = 1 and
							month(@Actual_End_Date) = Eff_Month and Year(@Actual_End_Date)  = Eff_Year 
							--month(@Actual_End_Date) = month(To_Date) and Year(@Actual_End_Date)  = year(To_Date)  -- ( INDUCTOTHERM CLIENT ) ADDED BY RAJPUT ON 08012017 MAKE SALARY IN DEC-2017 AND NIGHT HALT AMOUNT APPROVE IN JAN-2018 , AMOUNT WAS WRONG IN SALARY
							 
					  		SET @varCalc_On ='FIX'  	
															
						END    
					  -- Ended By rohit on 17122014  
					Else IF @varCalc_On = 'Seniority Rewards'                     
						BEGIN  									
							SELECT @M_AD_Amount= isnull(SUM(Net_Amount),0) from dbo.T0210_Emp_Seniority_Detail WITH (NOLOCK) where Emp_id=@emp_id and Ad_id = @ad_id and month(@Actual_End_Date) = MONTH(for_date) and Year(@Actual_End_Date)  = year(for_date)
							SET @varCalc_On ='FIX'  									
						END
					ELSE IF @varCalc_On='Late'                      
						BEGIN  
							SELECT	@Tmp_amount = LIMIT,@Late_Mode=late_Mode,@Late_Scan=Calculate_On 
							FROM	dbo.T0040_Late_Extra_Amount WITH (NOLOCK)
							WHERE	CMP_ID = @CMP_ID                    
									AND  @late_Extra_Days >= from_Days AND @late_Extra_Days <=To_days                    
									AND Allowance_ID =@AD_ID    
  
							IF @Late_Mode ='%'  
								BEGIN  
									SET @M_AD_Amount = ROUND(@M_AD_Amount * @Tmp_amount /100,0)  
								END  
							ELSE  
								BEGIN  
									SET @M_AD_Amount = @Tmp_amount  
								END  
						END 

					ELSE IF @varCalc_On='Leave Senario'  
						BEGIN
							IF @Allo_On_Leave = 1
								BEGIN				
									DECLARE	@Total_Leave_Days NUMERIC(18,1)
									DECLARE @Leave_Type VARCHAR(10)
			
									SELECT @Leave_Type=Leave_Type FROM dbo.T0050_AD_MASTER WITH (NOLOCK) WHERE AD_ID=@AD_ID  
			
									IF @Leave_Type='Paid'
										SET @Leave_Type='P'
									IF 	@Leave_Type='UnPaid'
										SET @Leave_Type='U'
									IF 	@Leave_Type='Both'
										SET @Leave_Type='B'
					
									IF 	@Leave_Type <> 'B'
										BEGIN
											--Changed By Gadriwala Muslim 02102014 - Start
											SELECT @Total_Leave_Days = ISNULL(SUM(leave_used),0) + ISNULL(Sum(CompOff_Used),0) FROM dbo.T0140_LEavE_Transaction WITH (NOLOCK) WHERE Emp_Id =@Emp_ID 
											AND For_Date >=@From_Date AND For_Date <=@To_date AND Leave_ID IN 
											(SELECT Leave_ID FROM T0040_LEave_Master WITH (NOLOCK) WHERE Cmp_Id =@Cmp_ID AND Leave_Type <> 'Company Purpose' AND Leave_Paid_Unpaid=@Leave_Type)
										END
									ELSE
										BEGIN
											--Changed By Gadriwala Muslim 02102014 - Start
											SELECT @Total_Leave_Days = ISNULL(SUM(leave_used),0) + ISNULL(Sum(CompOff_Used),0) FROM dbo.T0140_LEavE_Transaction WITH (NOLOCK) WHERE Emp_Id =@Emp_ID 
											AND For_Date >=@From_Date AND For_Date <=@To_date AND Leave_ID IN 
											(SELECT Leave_ID FROM T0040_LEave_Master WITH (NOLOCK) WHERE Cmp_Id =@Cmp_ID AND Leave_Type <> 'Company Purpose' )
										END	
						
									SELECT	@Tmp_amount = LIMIT,@Late_Mode=late_Mode,@Late_Scan=Calculate_On FROM dbo.T0040_Late_Extra_Amount WITH (NOLOCK)                    
									WHERE	CMP_ID = @CMP_ID AND  @Total_Leave_Days >= from_Days AND @Total_Leave_Days <=To_days                    
											AND Allowance_ID =@AD_ID  AND LIMIT>0
				
				
									IF @From_Date < @Join_Date  AND @To_Date >= @Join_Date
										BEGIN							
											IF @Late_Mode ='%'  
												BEGIN  
													SET @M_AD_Amount = ROUND(@M_AD_Amount * @Tmp_amount /100,0) 
													SET @M_AD_Amount=(@M_AD_Amount/@Out_Of_Days)*@Salary_Cal_Day
								
												END  
											ELSE  
												BEGIN
													--select @Out_Of_Days,@Salary_Cal_Day
													SET @M_AD_Amount = @Tmp_amount 
													SET @M_AD_Amount=(@M_AD_Amount/@Out_Of_Days)*@Salary_Cal_Day
								
												END
										END		
									ELSE
										BEGIN
											IF @Late_Mode ='%'  
												BEGIN  
													SET @M_AD_Amount = ROUND(@M_AD_Amount * @Tmp_amount /100,0)  
												END  
											ELSE  
												BEGIN  
													SET @M_AD_Amount = @Tmp_amount  
												END  			
										END
								END	
						END		
	
					ELSE IF @varCalc_On='Bonus' 
						BEGIN
							 SET @M_AD_Amount=0
								DECLARE @Yearly_Bonus_Amount NUMERIC(18, 4)
								SET @Yearly_Bonus_Amount =0
								SELECT @Yearly_Bonus_Amount = ISNULL(Yearly_Bonus_Amount,0) FROM dbo.T0095_Increment WITH (NOLOCK) WHERE Increment_Id=@Increment_Id
							IF ISNULL(@Yearly_Bonus_Amount,0) > 0
								BEGIN
								IF @Ad_EFFECT_FROM = 'Joining'
									BEGIN 
							
												DECLARE @Eff_Month AS NUMERIC 
												DECLARE @Eff_Year AS NUMERIC
												SET @Eff_Month = MONTH(@Join_Date)
												SET @Eff_Year=YEAR(DATEADD(yy,0,@From_Date))
												IF  @M_AD_Percentage >0  
													BEGIN
														SET  @M_AD_Amount = ((@Yearly_Bonus_Amount*@M_AD_Percentage)/100)
													END
												ELSE
													BEGIN
														SET @M_AD_Amount =@Yearly_Bonus_Amount
													END	
													
													EXEC dbo.P0100_ANUAL_BONUS 0,@Cmp_ID,@Emp_ID,@Ad_ID,@M_AD_Amount,@Eff_Month,@Eff_Year,@Sal_Tran_ID,'I'		
													
													SET @M_AD_Amount=0
										IF MONTH(@Join_Date)=MONTH(@To_Date) AND YEAR(@Join_Date)<> YEAR(@To_Date)
											BEGIN
												SELECT @M_AD_Amount = SUM(ISNULL(Amount,0)) FROM dbo.t0100_Anual_bonus WHERE MONTH(@From_Date)=Effective_Month AND YEAR(@From_Date)=Effective_Year
												AND Emp_ID=@Emp_ID AND Ad_ID=@Ad_ID AND Cmp_Id=@Cmp_ID
											END
									END
								ELSE IF @Ad_EFFECT_FROM = 'Confirmation'
									BEGIN
												   DECLARE @Date_Confirmation DATETIME
												   SELECT @Date_Confirmation = ISNULL(Emp_Confirm_Date,'') FROM dbo.t0080_emp_master WITH (NOLOCK) WHERE Emp_ID=@Emp_ID
									IF @Date_Confirmation <> '' AND @Date_Confirmation < @To_Date
										BEGIN 
						
													IF  @M_AD_Percentage>0  
															BEGIN
																SET  @M_AD_Amount = ((@Yearly_Bonus_Amount*@M_AD_Percentage)/100)
															END
													ELSE
															BEGIN
																SET @M_AD_Amount =@Yearly_Bonus_Amount
															END	
												DECLARE @Eff_Month_Con AS NUMERIC 
												DECLARE @Eff_Year_Con AS NUMERIC
												SET @Eff_Month_Con = MONTH(@Date_Confirmation)
												SET @Eff_Year_Con=YEAR(DATEADD(yy,0,@From_Date))
												IF  @M_AD_Percentage >0  
													BEGIN
														SET  @M_AD_Amount = ((@Yearly_Bonus_Amount*@M_AD_Percentage)/100)
													END
												ELSE
													BEGIN
														SET @M_AD_Amount =@Yearly_Bonus_Amount
													END	
											
											EXEC dbo.P0100_ANUAL_BONUS 0,@Cmp_ID,@Emp_ID,@Ad_ID,@M_AD_Amount,@Eff_Month_Con,@Eff_Year_Con,@Sal_Tran_ID,'I'		
											
											SET @M_AD_Amount=0
										END
												IF @Date_Confirmation <> ''
													BEGIN
														IF MONTH(@Date_Confirmation)=MONTH(@To_Date) AND YEAR(@Date_Confirmation)<> YEAR(@To_Date)
															BEGIN			
																	SELECT @M_AD_Amount = SUM(ISNULL(Amount,0)) FROM dbo.t0100_Anual_bonus WITH (NOLOCK) WHERE MONTH(@From_Date)=Effective_Month AND YEAR(@From_Date)=Effective_Year
																	AND Emp_ID=@Emp_ID AND Ad_ID=@Ad_ID AND Cmp_Id=@Cmp_ID
															END
													END
									END
								END	
						END	
					ELSE IF @varCalc_On='Present Senario'                      
						BEGIN  
  
							DECLARE	@C_Paid_Days NUMERIC(18,1)
							DECLARE	@A_Days		NUMERIC(18,1)
							SELECT  @C_Paid_Days = ISNULL(SUM(leave_used),0) + ISNULL(Sum(CompOff_Used),0) FROM dbo.T0140_LEavE_Transaction WITH (NOLOCK) WHERE Emp_Id =@Emp_ID  -- Changed By Gadriwala Muslim 02102014 
									AND For_Date >=@From_Date AND For_Date <=@To_date AND Leave_ID IN
										(SELECT  Leave_ID FROM T0040_LEave_Master WITH (NOLOCK) WHERE Cmp_Id =@Cmp_ID AND Leave_Type <> 'Company Purpose')
					
							SET @A_Days = @Present_Days + @C_Paid_Days
		
							
								BEGIN	
									SELECT @Tmp_amount = LIMIT,@Late_Mode=late_Mode,@Late_Scan=Calculate_On FROM dbo.T0040_Late_Extra_Amount WITH (NOLOCK)                    
									WHERE CMP_ID = @CMP_ID                    
									AND  @A_Days >= from_Days AND @A_Days <=To_days                    
									AND Allowance_ID =@AD_ID    
								END
			
						IF @Late_Mode ='%'  
							BEGIN  
								SET @M_AD_Amount = ROUND(@M_AD_Amount * @Tmp_amount /100,0)  
							END
						ELSE  
							BEGIN  
								SET @M_AD_Amount = @Tmp_amount  
							END  
						 END
					ELSE IF @varCalc_On='Absent Senario'   --chirag on 30072012 for absent deduction slab wise                   
						BEGIN 
	  
								DECLARE	@C_Paid_Days_Abesent NUMERIC(18,1)
								DECLARE	@A_Days_Abesent		NUMERIC(18,1)
								
								SELECT  @C_Paid_Days_Abesent = ISNULL(SUM(leave_used),0) + ISNULL(sum(CompOff_Used),0) FROM dbo.T0140_LEavE_Transaction WITH (NOLOCK) WHERE Emp_Id =@Emp_ID 
								AND For_Date >=@From_Date AND For_Date <=@To_date AND Leave_ID NOT IN
								--(SELECT  Leave_ID FROM T0040_LEave_Master WHERE Cmp_Id =@Cmp_ID AND Leave_Type = 'Company Purpose')
								(SELECT  Leave_ID FROM T0040_LEave_Master WITH (NOLOCK) WHERE Cmp_Id =@cmp_id AND Leave_Type = 'Company Purpose' or Leave_Paid_Unpaid = 'U')  --Added by Ramiz on 25/05/2015 as Unpaid Leave is already Counted as Absent so it is Deducting double Amount

								SET @A_Days_Abesent = @numAbsentDays + @C_Paid_Days_Abesent
			
								
								SELECT @Tmp_amount = ISNULL(LIMIT,0),@Late_Mode=late_Mode,@Late_Scan=Calculate_On FROM dbo.T0040_Late_Extra_Amount WITH (NOLOCK)                    
								 WHERE CMP_ID = @CMP_ID                    
								 AND Allowance_ID =@AD_ID  AND @A_Days_Abesent BETWEEN from_days AND To_days--GROUP BY late_Mode,Calculate_On,Allowance_ID
								
				
								IF @Late_Mode ='%'  
									BEGIN  
										SET @M_AD_Amount = ROUND(@M_AD_Amount * @Tmp_amount /100,0)  
									END
								ELSE  
									BEGIN  
										SET @M_AD_Amount = @Tmp_amount  
									END  
								
								---Added Condition by Hardik 26/05/2015 for Bhasker if Mid Join then no allowance paid
								--IF @Join_date between @From_Date and @To_date		''Commented By Ramiz on 22062015 for Giving allowance if joined on 1st Date
								If (@Join_Date > @From_Date) and (@Join_Date <= @To_Date)
									SET @M_AD_Amount = 0
									
								---Added Condition by Hardik 26/05/2015 for Bhasker if Mid Left then no allowance paid
								--IF @Left_date between @From_Date and @To_date		''Commented By Ramiz on 22062015 for Giving allowance if Left on 31st Date
								If (@Left_Date >= @From_Date) and (@Left_Date < @To_Date)
									SET @M_AD_Amount = 0
			
			
							 END
					ELSE IF @varCalc_On = 'Shift Wise'
						BEGIN
							DECLARE @F_CutOff_Date as datetime
							DECLARE @T_CutOff_Date as datetime
							SET @F_CutOff_Date = @From_Date
							Set @T_CutOff_Date = @To_Date
										    
							SELECT	@F_CutOff_Date= DateAdd(dd,1,IsNull(Cutoff_Date,Month_End_Date)) 
							FROM	T0200_MONTHLY_SALARY WITH (NOLOCK) 
							WHERE	MONTH(Month_End_Date) =  MONTH(DateAdd(M,-1,@To_Date)) AND YEAR(Month_End_Date) =  YEAR(DateAdd(M,-1,@To_Date)) AND Emp_ID=@Emp_ID 

							SET @T_CutOff_Date = DateAdd(DD,-1,DateAdd(M,1,@F_CutOff_Date))
							exec dbo.CALCULATE_SHIFT_ALLOWANCE @cmp_id,@Emp_Id,@From_Date,@To_Date,@M_AD_Amount output,@AD_ID  --Added by Jaina 20-04-2018
							
						END	 
					ELSE IF @varCalc_On='Present Days'
						BEGIN --by Falak on 23/12/2010
							DECLARE	@C_Days NUMERIC(18,1)
							--DECLARE @P_Days numeric(18,1)
							--Changed by Gadriwala Muslim 02102014
							SELECT	@C_Days = ISNULL(SUM(leave_used),0) + ISNULL(Sum(CompOff_Used),0) 
							FROM	dbo.T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN dbo.T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Cmp_ID=LM.Cmp_ID AND LT.Leave_ID=LM.Leave_ID
							WHERE	LT.Emp_Id =@Emp_ID AND LT.For_Date >=@From_Date AND LT.For_Date <=@To_date AND LM.Leave_Type='Company Purpose'
									--AND Leave_ID IN (SELECT Leave_ID FROM T0040_LEave_Master WHERE Cmp_Id =@Cmp_ID AND Leave_Type = 'Company Purpose')
									
							SET @P_Days = @Present_Days + @C_Days 
							IF @P_Days < 0 
								SET @M_AD_Amount = 0
							ELSE
								SET @M_AD_Amount = @P_Days * @M_AD_Amount 
						END 		
					ELSE IF @varCalc_On='Present + Paid Leave Days' -- Added by Rohit on 28082014
						BEGIN --by Falak on 23/12/2010
							DECLARE	@PLeave_Days numeric(22,3)
							DECLARE	@CLeave_Days numeric(22,3)
							SET @PLeave_Days=0
							SET @CLeave_Days=0
							
							DECLARE @StrHoliday_Date varchar(max)
							DECLARE @Holiday_Days varchar(max)
							DECLARE @StrWeekoff_Date varchar(max)	
							DECLARE @Weekoff_Days varchar(Max)
							DECLARE @PLeave_Days_Week_hour as numeric(22,3)
							DECLARE @PLeave_Days_Week as numeric(22,3)
							SET @PLeave_Days_Week_hour=0
							SET @PLeave_Days_Week=0

							DECLARE @PLeave_Days_Holiday_hour as numeric(22,3)
							DECLARE @PLeave_Days_Holiday as numeric(22,3)
							SET @PLeave_Days_holiday_hour=0
							SET @PLeave_Days_Holiday=0							
						
							Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_date,Null,Null,9,@StrHoliday_Date output,@Holiday_Days output,Null,0,0,@StrWeekoff_Date
							Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_date,null,null,9,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,Null
						
								
							SELECT @PLeave_Days = isnull(sum(leave_Days),0) from T0210_Monthly_LEave_Detail M WITH (NOLOCK) Inner Join
								T0040_Leave_Master L WITH (NOLOCK) on M.Leave_Id = L.Leave_Id
							where Emp_ID = @emp_ID and       
							TEMP_SAL_TRAN_ID = @Sal_Tran_ID and M.Leave_Paid_Unpaid = 'P' --and Leave_type <> 'Encashable'
							and M.CmP_Id=@Cmp_ID 
							And Isnull(L.Default_Short_Name,'') <> 'COMP'
								     

								Declare @OD_Compoff_As_Present tinyint
								SET @OD_Compoff_As_Present = 0
                
								Select @OD_Compoff_As_Present = Isnull(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Setting_Name='OD and CompOff Leave Consider As Present'
                
				                if (@OD_Compoff_As_Present = 1)
									BEGIN
										SELECT @CLeave_Days = isnull(sum(leave_Days),0) from T0210_Monthly_LEave_Detail M WITH (NOLOCK) Inner Join
											T0040_Leave_Master L WITH (NOLOCK) on M.Leave_Id = L.Leave_Id
										WHERE Emp_ID = @emp_ID and       
										TEMP_SAL_TRAN_ID = @Sal_Tran_ID 
										and M.Cmp_Id=@Cmp_ID 
										And Isnull(L.Default_Short_Name,'') = 'COMP'	
									END
								
									--PERFORMANCE		
									SELECT 	* INTO #weekOff_Date
									FROM	(select  cast(data  as datetime) As For_Date from dbo.Split (@StrWeekoff_Date,';')) t
									where	IsNull(t.For_Date,'') <> ''
												
									if exists(select for_date from #weekOff_Date)
										BEGIN
										
										--PRINT  convert(varchar(20), getdate(), 114) + ' : Query 9004 : Start'                  
										SELECT	@PLeave_Days_Week = ISNULL(SUM(leave_used),0) 
										FROM	dbo.T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN (select Cmp_id, Leave_ID FROM dbo.T0040_LEAVE_MASTER LM WITH (NOLOCK) Where isnull(LM.Apply_Hourly,0) = 0 and LM.leave_paid_unpaid='P' And Isnull(LM.Default_Short_Name,'') <> 'COMP') LM ON LT.Cmp_ID = LM.Cmp_ID AND LT.Leave_ID=LM.Leave_ID
												--INNER JOIN #weekOff_Date WD ON LT.FOR_DATE = WD.FOR_DATE
										WHERE	LT.Emp_Id =@Emp_ID AND LT.For_Date >=@From_Date AND LT.For_Date <=@To_date 
												AND LT.Cmp_Id =@Cmp_ID --AND isnull(LM.Apply_Hourly,0) = 0 and LM.leave_paid_unpaid='P' And Isnull(LM.Default_Short_Name,'') <> 'COMP'
												and LT.For_Date in (select  cast(data  as varchar(max)) from dbo.Split (@StrWeekoff_Date,';'))												
												
												--AND Leave_ID IN (SELECT Leave_ID FROM T0040_LEave_Master WHERE Cmp_Id =@Cmp_ID AND isnull(Apply_Hourly,0) = 0 and leave_paid_unpaid='P' And Isnull(Default_Short_Name,'') <> 'COMP') and For_Date in (select  cast(data  as varchar(max)) from dbo.Split (@StrWeekoff_Date,';')  )
										
										
										SELECT	@PLeave_Days_Week = @PLeave_Days_Week + ISNULL(SUM(isnull(CompOff_Used,0) - isnull(Leave_Encash_Days ,0)),0) 
										FROM	dbo.T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN (select Cmp_id, Leave_ID FROM dbo.T0040_LEAVE_MASTER LM WITH (NOLOCK) Where isnull(LM.Apply_Hourly,0) = 0 and LM.leave_paid_unpaid='P' And Isnull(LM.Default_Short_Name,'') <> 'COMP') LM ON LT.Cmp_ID = LM.Cmp_ID AND LT.Leave_ID=LM.Leave_ID
												--INNER JOIN #weekOff_Date WD ON LT.FOR_DATE = WD.FOR_DATE
										WHERE	LT.Emp_Id =@Emp_ID AND LT.For_Date >=@From_Date AND LT.For_Date <=@To_date 
												AND LT.Cmp_Id =@Cmp_ID --AND isnull(LM.Apply_Hourly,0) = 0 and LM.leave_paid_unpaid='P' And Isnull(LM.Default_Short_Name,'') = 'COMP' 
												and LT.For_Date in (select  cast(data  as varchar(max)) from dbo.Split (@StrWeekoff_Date,';')  )
												
												--AND Leave_ID IN (SELECT Leave_ID FROM T0040_LEave_Master WHERE Cmp_Id =@Cmp_ID AND isnull(Apply_Hourly,0) = 0 and leave_paid_unpaid='P' And Isnull(Default_Short_Name,'') = 'COMP') and For_Date in (select  cast(data  as varchar(max)) from dbo.Split (@StrWeekoff_Date,';')  )
										
										
										SELECT	@PLeave_Days_Week_hour = ISNULL(SUM(case when leave_used >8 then 1 else leave_used * 0.125 end),0) 
										FROM	dbo.T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN (select Cmp_id, Leave_ID FROM dbo.T0040_LEAVE_MASTER LM WITH (NOLOCK) Where isnull(LM.Apply_Hourly,0) = 0 and LM.leave_paid_unpaid='P' And Isnull(LM.Default_Short_Name,'') <> 'COMP') LM ON LT.Cmp_ID = LM.Cmp_ID AND LT.Leave_ID=LM.Leave_ID
												--INNER JOIN #weekOff_Date WD ON LT.FOR_DATE = WD.FOR_DATE
										WHERE	Emp_Id =@Emp_ID AND LT.For_Date >=@From_Date AND LT.For_Date <=@To_date 
												AND LT.Cmp_Id =@Cmp_ID --AND isnull(LM.Apply_Hourly,0) = 1 and LM.leave_paid_unpaid='P' And Isnull(LM.Default_Short_Name,'') <> 'COMP' 
												and LT.For_Date in (select  cast(data  as varchar(max)) from dbo.Split (@StrWeekoff_Date,';')  )
												--AND Leave_ID IN (SELECT Leave_ID FROM T0040_LEave_Master WHERE Cmp_Id =@Cmp_ID AND isnull(Apply_Hourly,0) = 1 and leave_paid_unpaid='P' And Isnull(Default_Short_Name,'') <> 'COMP') and For_Date in (select  cast(data  as varchar(max)) from dbo.Split (@StrWeekoff_Date,';')  )


										SELECT	@PLeave_Days_Week_hour = @PLeave_Days_Week_hour + ISNULL(SUM(case when (isnull(CompOff_Used,0) - isnull(Leave_Encash_Days ,0)) >8 then 1 else (isnull(CompOff_Used,0) - isnull(Leave_Encash_Days ,0)) * 0.125 end),0) 
										FROM	dbo.T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN (select Cmp_id, Leave_ID FROM dbo.T0040_LEAVE_MASTER LM WITH (NOLOCK) Where isnull(LM.Apply_Hourly,0) = 0 and LM.leave_paid_unpaid='P' And Isnull(LM.Default_Short_Name,'') <> 'COMP') LM ON LT.Cmp_ID = LM.Cmp_ID AND LT.Leave_ID=LM.Leave_ID
												--INNER JOIN #weekOff_Date WD ON LT.FOR_DATE = WD.FOR_DATE
										WHERE	Emp_Id =@Emp_ID AND LT.For_Date >=@From_Date AND LT.For_Date <=@To_date 
												AND LT.Cmp_Id =@Cmp_ID -- AND isnull(Apply_Hourly,0) = 1 and leave_paid_unpaid='P' And Isnull(Default_Short_Name,'') = 'COMP' 
												and LT.For_Date in (select  cast(data  as varchar(max)) from dbo.Split (@StrWeekoff_Date,';')  )
												--AND Leave_ID IN (SELECT Leave_ID FROM T0040_LEave_Master WHERE Cmp_Id =@Cmp_ID AND isnull(Apply_Hourly,0) = 1 and leave_paid_unpaid='P' And Isnull(Default_Short_Name,'') = 'COMP') and For_Date in (select  cast(data  as varchar(max)) from dbo.Split (@StrWeekoff_Date,';')  )

										SELECT	@PLeave_Days_Holiday = ISNULL(SUM(leave_used),0) 
										FROM	dbo.T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN (select Cmp_id, Leave_ID FROM dbo.T0040_LEAVE_MASTER LM WITH (NOLOCK) Where isnull(LM.Apply_Hourly,0) = 0 and LM.leave_paid_unpaid='P' And Isnull(LM.Default_Short_Name,'') <> 'COMP') LM ON LT.Cmp_ID = LM.Cmp_ID AND LT.Leave_ID=LM.Leave_ID
												--INNER JOIN #weekOff_Date WD ON LT.FOR_DATE = WD.FOR_DATE
										WHERE	Emp_Id =@Emp_ID AND LT.For_Date >=@From_Date AND LT.For_Date <=@To_date 
												AND LT.Cmp_Id =@Cmp_ID --AND isnull(Apply_Hourly,0) = 0 and leave_paid_unpaid='P' And Isnull(Default_Short_Name,'') <> 'COMP' 
												AND LT.For_Date in (select  cast(data  as varchar(max)) from dbo.Split (@StrHoliday_Date,';')  )
												--AND Leave_ID IN (SELECT Leave_ID FROM T0040_LEave_Master WHERE Cmp_Id =@Cmp_ID AND isnull(Apply_Hourly,0) = 0 and leave_paid_unpaid='P' And Isnull(Default_Short_Name,'') <> 'COMP') and For_Date in (select  cast(data  as varchar(max)) from dbo.Split (@StrHoliday_Date,';')  )
										
										SELECT	@PLeave_Days_Holiday = @PLeave_Days_Holiday + ISNULL(SUM((isnull(CompOff_Used,0) - isnull(Leave_Encash_Days ,0))),0) 
										FROM	dbo.T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN (select Cmp_id, Leave_ID FROM dbo.T0040_LEAVE_MASTER LM WITH (NOLOCK) Where isnull(LM.Apply_Hourly,0) = 0 and LM.leave_paid_unpaid='P' And Isnull(LM.Default_Short_Name,'') <> 'COMP') LM ON LT.Cmp_ID = LM.Cmp_ID AND LT.Leave_ID=LM.Leave_ID
												--INNER JOIN #weekOff_Date WD ON LT.FOR_DATE = WD.FOR_DATE
										WHERE	LT.Emp_Id =@Emp_ID AND LT.For_Date >=@From_Date AND LT.For_Date <=@To_date 
												AND LT.Cmp_Id =@Cmp_ID --AND isnull(Apply_Hourly,0) = 0 and leave_paid_unpaid='P' And Isnull(Default_Short_Name,'') = 'COMP'
												AND LT.For_Date in (select cast(data  as varchar(max)) from dbo.Split (@StrHoliday_Date,';')  )
												--AND Leave_ID IN (SELECT Leave_ID FROM T0040_LEave_Master WHERE Cmp_Id =@Cmp_ID AND isnull(Apply_Hourly,0) = 0 and leave_paid_unpaid='P' And Isnull(Default_Short_Name,'') = 'COMP') and For_Date in (select  cast(data  as varchar(max)) from dbo.Split (@StrHoliday_Date,';')  )
										
										
										SELECT	@PLeave_Days_Holiday_hour = ISNULL(SUM(case when leave_used >8 then 1 else leave_used * 0.125 end),0) 
										FROM	dbo.T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN (select Cmp_id, Leave_ID FROM dbo.T0040_LEAVE_MASTER LM WITH (NOLOCK) Where isnull(LM.Apply_Hourly,0) = 0 and LM.leave_paid_unpaid='P' And Isnull(LM.Default_Short_Name,'') <> 'COMP') LM ON LT.Cmp_ID = LM.Cmp_ID AND LT.Leave_ID=LM.Leave_ID
												--INNER JOIN #weekOff_Date WD ON LT.FOR_DATE = WD.FOR_DATE
										WHERE	Emp_Id =@Emp_ID AND LT.For_Date >=@From_Date AND LT.For_Date <=@To_date 
												AND LT.Cmp_Id =@Cmp_ID --AND isnull(Apply_Hourly,0) = 1 and leave_paid_unpaid='P' And Isnull(Default_Short_Name,'') <> 'COMP' 
												AND LT.For_Date in (select  cast(data  as varchar(max)) from dbo.Split (@StrHoliday_Date,';')  )
												--AND Leave_ID IN (SELECT Leave_ID FROM T0040_LEave_Master WHERE Cmp_Id =@Cmp_ID AND isnull(Apply_Hourly,0) = 1 and leave_paid_unpaid='P' And Isnull(Default_Short_Name,'') <> 'COMP') and For_Date in (select  cast(data  as varchar(max)) from dbo.Split (@StrHoliday_Date,';')  )

										SELECT	@PLeave_Days_Holiday_hour = ISNULL(SUM(case when (isnull(CompOff_Used,0) - isnull(Leave_Encash_Days ,0)) >8 then 1 else (isnull(CompOff_Used,0) - isnull(Leave_Encash_Days ,0)) * 0.125 end),0) 
										FROM	dbo.T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN (select Cmp_id, Leave_ID FROM dbo.T0040_LEAVE_MASTER LM WITH (NOLOCK) Where isnull(LM.Apply_Hourly,0) = 0 and LM.leave_paid_unpaid='P' And Isnull(LM.Default_Short_Name,'') <> 'COMP') LM ON LT.Cmp_ID = LM.Cmp_ID AND LT.Leave_ID=LM.Leave_ID
												--INNER JOIN #weekOff_Date WD ON LT.FOR_DATE = WD.FOR_DATE
										WHERE	Emp_Id =@Emp_ID AND LT.For_Date >=@From_Date AND LT.For_Date <=@To_date 
												AND LT.Cmp_Id =@Cmp_ID --AND isnull(Apply_Hourly,0) = 1 and leave_paid_unpaid='P' And Isnull(Default_Short_Name,'') = 'COMP' 
												AND LT.For_Date in (select  cast(data  as varchar(max)) from dbo.Split (@StrHoliday_Date,';')  )
												--AND Leave_ID IN (SELECT Leave_ID FROM T0040_LEave_Master WHERE Cmp_Id =@Cmp_ID AND isnull(Apply_Hourly,0) = 1 and leave_paid_unpaid='P' And Isnull(Default_Short_Name,'') = 'COMP') and For_Date in (select  cast(data  as varchar(max)) from dbo.Split (@StrHoliday_Date,';')  )
									END 
									--PRINT  convert(varchar(20), getdate(), 114) + ' : Query 9004 : End'                  

							SET @P_Days = @Present_Days + @PLeave_Days + (@CLeave_Days) + isnull(@Arear_Days,0) - isnull(@PLeave_Days_Week,0) - isnull(@PLeave_Days_Week_hour,0)- isnull(@PLeave_Days_Holiday,0) - isnull(@PLeave_Days_Holiday_hour,0)
							SET @P_Days = ceiling(@P_Days)
							
							IF @P_Days > @Out_Of_Days + isnull(@Arear_Days,0) - isnull(@Holiday_Days,0)- isnull(@Weekoff_Days ,0)
							BEGIN
								SET @P_Days = @Out_Of_Days + isnull(@Arear_Days,0) - isnull(@Holiday_Days,0)- isnull(@Weekoff_Days ,0)
							end
							SET @varCalc_On ='FIX'  


							IF @P_Days < 0 
								SET @M_AD_Amount = 0
							ELSE
								SET @M_AD_Amount = @P_Days * @M_AD_Amount 
						END 					
					Else IF @varCalc_On='Formula'	-- added by mitesh on 28042014
						BEGIN	
						
							--Create Table HolidayTable(
							--Row_ID int,
							--Emp_id numeric(18,0),
							--Cmp_id numeric(18,0),
							--Alpha_Emp_Code varchar(50),
							--Emp_Full_Name varchar(100),
							--For_Date varchar(100),
							--Shift_id numeric(18,0),
							--Shift_Time Varchar(50),
							--Shift_WO Varchar(50),
							--Fix_WeekOff numeric(18,0)
							--)
							
							--insert into HolidayTable
							--exec Get_Roster_Shift_Weekoff_Monthly @Cmp_ID=120,@From_Date='2022-05-01 00:00:00',@To_Date='2022-05-31 00:00:00',@Emp_ID =27912,@Branch_ID=0	

							--select * from HolidayTable

							DECLARE @Ad_Formula varchar(max)
							SET @Ad_Formula = ''
							select @Ad_Formula = Actual_AD_Formula from T0040_AD_Formula_Setting WITH (NOLOCK) where Cmp_Id=@cmp_Id and AD_ID=@AD_ID
			
							if Isnull(@Ad_Formula,'') <> ''
							BEGIN			
							
								DECLARE @Earning_Gross NUMERIC(18, 4)
								DECLARE @Formula_amount NUMERIC(18, 4)	
								SET @Earning_Gross = 0
								SET @Formula_amount = 0
								
									--PERFORMANCE								
								--PRINT  convert(varchar(20), getdate(), 114) + ' : Query 9005 : Start'  
								Select	@Earning_Gross=SUM(ISNULL(M_AD_AMOUNT,0)) 
								From	dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) LEFT OUTER JOIN dbo.T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.CMP_ID=AD.CMP_ID AND MAD.AD_ID=AD.AD_ID AND  ISNULL(AD.AD_NOT_EFFECT_SALARY,0) = 1
								WHERE	Temp_Sal_Tran_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I'  
										AND AD.AD_ID IS NULL    
										--AND AD_ID not in (select AD_ID from dbo.T0050_AD_MASTER where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 1)						
								--PRINT  convert(varchar(20), getdate(), 114) + ' : Query 9005 : End'  
								SET @Earning_Gross = @Salary_Amount + ISNULL(@Earning_Gross,0) + ISNULL(@OT_Amount,0) + ISNULL(@OT_HO_AMOUNT,0) + ISNULL(@OT_WO_AMOUNT,0)			
								
								--EXEC dbo.CALCULATE_AD_AMOUNT_Formula_WISE_Salary  @Cmp_ID,@EMP_ID,@AD_ID,@From_Date,@Earning_Gross,@Salary_Cal_Day,@Out_Of_Days,@Formula_amount output,@Salary_Amount,@Present_Days,@Arear_Days	''Commented and Added Below By Ramiz on 31/08/2017
								
								EXEC dbo.CALCULATE_AD_AMOUNT_Formula_WISE_Salary  @Cmp_ID=@Cmp_ID,@EMP_ID=@EMP_ID,@AD_ID=@AD_ID,@For_date=@From_Date,@Earning_Gross=@Earning_Gross,@Salary_Cal_Day=@Salary_Cal_Day
								,@Out_Of_Days=@Out_Of_Days,@Formula_amount=@Formula_amount output,@Earning_Basic=@Salary_Amount,@Present_Days=@Present_Days,@arrear_Day=@Arear_Days
								,@absent_days=@numAbsentDays,@Salary_Settlement_Flag=0,@PASSED_FROM='',@PASSED_AMOUNT=@M_AD_Amount,@To_Date=@To_Date,@Calculate_Arrear=1,@Night_Shift_Count=@Night_Shift_Count	--Absent days(@numAbsentDays) passed by Ramiz on 06/11/2017 , previously it was going 0
								
								SET @M_AD_Amount = ISNULL(@Formula_amount,0)
							End
							--IF @M_AD_Amount > Isnull(@Max_Upper ,0) --For check max limit 16062012 hasmukh
							--	SET @M_AD_Amount = isnull(@Max_Upper ,0)
							
						End    	
					ELSE IF @varCalc_On='Split Shift'  -- Added by Hardik 12/08/2013 for Azure Client
						BEGIN 
							SELECT @M_AD_Amount = ISNULL(SUM(Split_Shift_Allow),0), @Split_Shift_Count = Split_Shift_Count,
								@Split_Shift_Date  = Split_Shift_Dates
							FROM #Split_Shift_Table WHERE Emp_Id =@Emp_ID 
							Group By Split_Shift_count,Split_shift_Dates
						END 	
					ELSE IF @varCalc_On = 'Extra OT' -- Added by Jaina 08-09-2016
							BEGIN
								if @CA_OT_Amount > 0 
									set @M_AD_Amount = (@CA_OT_Amount	* @M_AD_Percentage)/100
								else
									set @M_AD_Amount = 0
									
							END	
					ElSE IF @varCalc_On='Branch + Grade' 	
						BEGIN
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
										Where Effective_Date < @From_Date
										group by Branch_ID,Grd_ID,AD_ID
									  ) as Qry
							ON GB.Branch_ID = Qry.Branch_ID and GB.Grd_ID = Qry.Grd_ID and GB.AD_ID = Qry.AD_ID
							Where GB.Branch_ID = @Branch_ID and GB.Grd_ID = @Grd_ID and GB.AD_ID = @AD_ID
							
							--Added By Nimesh On 25-Jun-2018 (Application is taking structure amount even present days are 0)
							IF IsNull(@Branch_Grade_Cal_On,'') = ''
								BEGIN
									DECLARE @MSG VARCHAR(256)
									SET @MSG = 'Record does not exist in Branch + Grade for '
									SELECT	@MSG = @MSG  + Branch_Name + ' Branch & '
									FROM	T0030_Branch_Master WITH (NOLOCK) 
									Where	Branch_ID=@Branch_ID
									
									SELECT	@MSG = @MSG + Grd_Name + ' Grade.'
									FROM	T0040_Grade_Master  WITH (NOLOCK)
									Where	Grd_ID=@Grd_ID
									
									SET @M_AD_Amount = 0
																		
									
								END
							
							if @M_AD_Percentage > 0 
								Begin
									if @Branch_Grade_Cal_On = 'Basic Salary'
										Begin
											Set @M_AD_Amount = ((@Basic_Salary * @M_AD_Percentage)/100) * @Salary_Cal_Day / @Out_Of_Days
											
										End
									Else if @Branch_Grade_Cal_On = 'Gross Salary'
										Begin
											SELECT	@Allow_Amount = SUM(ISNULL(M_AD_AMOUNT,0)) 
											FROM	dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
													LEFT OUTER JOIN  dbo.T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.Cmp_ID=AD.CMP_ID AND MAD.AD_ID=MAD.AD_ID AND isnull(AD.AD_NOT_EFFECT_SALARY,0) = 1
											WHERE	Temp_Sal_Tran_ID = @Sal_Tran_ID AND MAD.Emp_ID = @Emp_ID AND MAD.M_AD_Flag ='I' 
													AND AD.AD_ID IS NULL
													
											SET @Calc_On_Allow_Dedu = @Salary_Amount+ ISNULL(@Allow_Amount,0)
											Set @M_AD_Amount = ((@Calc_On_Allow_Dedu * @M_AD_Percentage)/100) * @Salary_Cal_Day / @Out_Of_Days
										End
									Else if @Branch_Grade_Cal_On = 'CTC'
										Begin
											Set @M_AD_Amount = ((@CTC * @M_AD_Percentage)/100) * @Salary_Cal_Day / @Out_Of_Days
										End
								End
							Else
								Begin
									Set @M_AD_Amount = @E_Ad_Amount * @Salary_Cal_Day / @Out_Of_Days
									
								End
						END	
					Else IF @varCalc_On = 'Gradewise OT'                     
						BEGIN  
							if @M_AD_Flag = 'I'
								BEGIN
										DECLARE @OT_ALLOWANCES_AMT AS NUMERIC(18,2) = 0
										DECLARE @BASIC_DA_OT_AMT AS NUMERIC(18,2) = 0
										DECLARE @BASIC_DA_OT_HRS AS NUMERIC(18,2) = 0
										DECLARE @AMOUNT_CREDIT AS NUMERIC(18,2) = 0 -- Added By Sajid 22102021 for Mafatlal

										--For Removing Normal OT--
										set @OT_Amount = 0 
										set @OT_HO_AMOUNT = 0
										set @OT_WO_AMOUNT = 0							
										SELECT @OT_ALLOWANCES_AMT = ISNULL(SUM(E_AD_amount),0)
										FROM (
											SELECT 
											 Case When Qry1.Increment_ID >= EED.INCREMENT_ID Then
												Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
											 Else
												eed.e_ad_Amount End As E_Ad_Amount
											FROM dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) 
											INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK)  ON EEd.AD_ID = ADM.AD_ID
											LEFT OUTER JOIN
												(
													SELECT EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.ENTRY_TYPE,EEDR.Increment_ID
													FROM T0110_EMP_Earn_Deduction_Revised EEDR  WITH (NOLOCK)
													INNER JOIN
														(
														 SELECT Max(For_Date) For_Date, Ad_Id 
														 FROM T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
														 WHERE Emp_Id = @Emp_Id And For_date <= @to_date 
														 GROUP BY Ad_Id 
														) Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
												) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID                  
										WHERE EED.EMP_ID = @EMP_ID AND EED.INCREMENT_ID = @INCREMENT_ID AND ADM.AD_ACTIVE = 1 AND ADM.AD_DEF_ID <> 11	--EXCLUDING DA , AS IT IS ALREADY ADDED IN GRADEWISE SALARY
											  AND CASE WHEN QRY1.ENTRY_TYPE IS NULL THEN '' ELSE QRY1.ENTRY_TYPE END <> 'D'
											  AND EXISTS(SELECT AD_ID  FROM dbo.T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) WHERE Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID AND EED.AD_ID=EAD.AD_ID) 
							
										UNION ALL
							
										SELECT E_AD_Amount
										FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) 
										INNER JOIN  
											(
												Select MAX(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
												Where Emp_Id  = @Emp_Id And For_date <= @to_date 
												Group by Ad_Id 
											)Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
										INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK)  ON EEd.AD_ID = ADM.AD_ID                     
										WHERE emp_id = @emp_id And Adm.AD_ACTIVE = 1 And EEd.ENTRY_TYPE = 'A' AND eed.increment_id = @Increment_Id AND ADM.AD_DEF_ID <> 11	--EXCLUDING DA , AS IT IS ALREADY ADDED IN GRADEWISE SALARY
												AND EXISTS(SELECT AD_ID  FROM dbo.T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) WHERE Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID AND EED.AD_ID = EAD.AD_ID)
										) Qry
							
									IF OBJECT_ID('tempdb..#OT_Gradewise') IS NOT NULL
										BEGIN
											SELECT 
												@BASIC_DA_OT_AMT = ISNULL(SUM(Grd_Hour_Basic_Salary),0) + ISNULL(SUM(DA_Allow_Salary),0),
												@BASIC_DA_OT_HRS = ISNULL(SUM(Grd_OT_Hours),0),
												@AMOUNT_CREDIT = ISNULL(SUM(Amount_Credit),0) -- Added By Sajid 22102021 for Mafatlal
											FROM #OT_Gradewise
										END
					
									SET @OT_ALLOWANCES_AMT = (@OT_ALLOWANCES_AMT / @Fix_OT_Work_Days / Replace(@Fix_OT_Shift_Hours,':','.')) * ISNULL(@BASIC_DA_OT_HRS,0)
									SET @M_AD_AMOUNT = @BASIC_DA_OT_AMT + @OT_ALLOWANCES_AMT + @AMOUNT_CREDIT -- Added By Sajid 22102021 for Mafatlal	
									
								END
							ELSE IF @M_AD_Flag = 'D'
								BEGIN
								
									DECLARE @OT_ADVANCE AS NUMERIC(18,2) = 0
									IF OBJECT_ID('tempdb..#OT_Gradewise') IS NOT NULL
										BEGIN
											SELECT @OT_ADVANCE = ISNULL(SUM(Amount_Debit),0) 
											FROM #OT_Gradewise
											SET @M_AD_AMOUNT = @OT_ADVANCE
										END
								END
						--DELETE FROM #OT_Gradewise
						END
					ELSE IF @varCalc_On = 'Fix'   --Added by Jaina 13-10-2020 For Wonder
						BEGIN
						
								SELECT 	@Claim_Deduction_Amount=ISNULL(SUM(CLAIM_CLOSING),0) 
								FROM 	T0140_CLAIM_TRANSACTION AS CT WITH (NOLOCK) 
								INNER JOIN ( SELECT DISTINCT CLAIM_APR_ID,CLAIM_ID,CLAIM_APR_DATE,CMP_ID,Claim_Status FROM T0130_CLAIM_APPROVAL_DETAIL WITH (NOLOCK) ) CAD ON CAD.CLAIM_APR_DATE = CT.FOR_DATE  
								INNER JOIN T0120_CLAIM_APPROVAL AS CA WITH (NOLOCK) ON CA.CLAIM_APR_ID = CAD.CLAIM_APR_ID AND CT.EMP_ID=CA.EMP_ID AND CT.CLAIM_ID=CAD.CLAIM_ID 
								INNER JOIN T0040_CLAIM_MASTER CLM WITH (NOLOCK) ON CLM.CLAIM_ID=CAD.CLAIM_ID AND CLM.CMP_ID=CAD.CMP_ID 								
								Inner join T0050_AD_MASTER ADM WITH (NOLOCK) on ADm.Claim_ID = CAd.Claim_ID
								WHERE CT.CMP_ID=@CMP_ID AND CT.EMP_ID=@EMP_ID AND CA.CLAIM_APR_DATE<=@To_Date 
									 AND CA.CLAIM_APR_DATE>=@From_Date AND CLM.CLAIM_APR_DEDUCT_FROM_SAL=1 AND CLM.Claim_For_FNF=0  --Added by Jaina 10-11-2020
									 AND CLM.CLAIM_ALLOW_BEYOND_LIMIT = 1 AND CLM.Beyond_Max_Limit_Deduct_In_Salary = 1  and adm.AD_ID = @AD_ID and CAD.Claim_ID=@AD_Claim_ID
									 And CAD.Claim_Status = 'A'
							
								if @Claim_Deduction_Amount > 0
                                begin
                                    exec SP_CALCULATE_CLAIM_TRANSACTION @Cmp_Id,@Emp_Id,@From_Date,0,@From_Date,@To_Date,0,'I',1
									set @M_AD_Amount = @Claim_Deduction_Amount
                                end
								
							
								
								--Added by Jaina 29-10-2020
								Declare @Claim_Earning_Amount Numeric(18,0) = 0

								SELECT 	@Claim_Earning_Amount=ISNULL(SUM(CLAIM_CLOSING),0) 
								FROM 	T0140_CLAIM_TRANSACTION AS CT WITH (NOLOCK) 
								INNER JOIN ( SELECT DISTINCT CLAIM_APR_ID,CLAIM_ID,CLAIM_APR_DATE,CMP_ID,Claim_Status FROM T0130_CLAIM_APPROVAL_DETAIL WITH (NOLOCK) ) CAD ON CAD.CLAIM_APR_DATE = CT.FOR_DATE  
								INNER JOIN T0120_CLAIM_APPROVAL AS CA WITH (NOLOCK) ON CA.CLAIM_APR_ID = CAD.CLAIM_APR_ID AND CT.EMP_ID=CA.EMP_ID AND CT.CLAIM_ID=CAD.CLAIM_ID 
								INNER JOIN T0040_CLAIM_MASTER CLM WITH (NOLOCK) ON CLM.CLAIM_ID=CAD.CLAIM_ID AND CLM.CMP_ID=CAD.CMP_ID 								
								Inner join T0050_AD_MASTER ADM WITH (NOLOCK) on ADm.Claim_ID = CAd.Claim_ID
								WHERE CT.CMP_ID=@CMP_ID AND CT.EMP_ID=@EMP_ID AND CA.CLAIM_APR_DATE<=@To_Date 
									 AND CA.CLAIM_APR_DATE>=@From_Date AND CLM.CLAIM_APR_DEDUCT_FROM_SAL=1 
									 AND adm.AD_ID = @AD_ID and CAD.Claim_ID=@AD_Claim_ID And CAD.Claim_Status = 'A'

								if @Claim_Earning_Amount > 0
                                begin
                                    exec SP_CALCULATE_CLAIM_TRANSACTION @Cmp_Id,@Emp_Id,@From_Date,0,@From_Date,@To_Date,0,'I',1
									set @M_AD_Amount = @Claim_Earning_Amount
                                end

							
						END		   				    					          
					ELSE ---- Start Deduction                     
						BEGIN
							IF  @M_AD_Percentage > 0                    
								 BEGIN 
								                    
									IF @PF_DEF_ID = @AD_DEF_ID OR @Cmp_PF_DEF_ID = @AD_DEF_ID
										BEGIN
											
											--- Added by Hardik 09/07/2013 for Arear PF Def Id allowance add in PF Amount for Golcha ---- 
											DECLARE @Arear_PF_Amount as NUMERIC(18, 4)
											DECLARE @Temp_PF_Amount as NUMERIC(18, 4)
											SET @Arear_PF_Amount = 0
											SET @Temp_PF_Amount = 0
						
											SELECT @Arear_PF_Amount = ISNULL(SUM(M_AD_amount),0)  FROM dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) 
											WHERE Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID                     
											AND For_Date >=@Actual_Start_Date AND For_Date <=@Actual_End_Date                
											AND ISNULL(Temp_Sal_Tran_ID,0) = ISNULL(@Sal_Tran_ID,ISNULL(Temp_Sal_Tran_ID,0))                    
											AND ISNULL(L_Sal_Tran_ID,0) = ISNULL(@L_Sal_Tran_ID,ISNULL(L_Sal_Tran_ID,0))                    
											AND AD_ID IN                     
											(SELECT AD_ID  FROM dbo.T0050_AD_MASTER  WITH (NOLOCK)                    
											WHERE Cmp_ID  = @Cmp_ID And AD_DEF_ID = @AREAR_PF_DEF_ID) 
											
																			
											SET @Temp_PF_Amount = ROUND((@Arear_PF_Amount * @M_AD_Percentage / 100),0)
											
											
											
											----End for Arear PF Def Id
					  
											--Hardik 07/02/2013
											SET @PF_Max_Amount = Round((@PF_LIMIT * @M_AD_Percentage /100),0)
																																									
											IF  @Emp_Full_PF = 0 AND @PF_LIMIT > 0 AND @Calc_On_Allow_Dedu > @PF_LIMIT And @PF_DEF_ID = @AD_DEF_ID
													SET @Calc_On_Allow_Dedu = @PF_Limit                    
										
											-- Added by Jimit 23/10/2018 for Competent Client for Company Full PF Case
											IF  @Emp_Auto_VPF = 0 AND @PF_LIMIT > 0 AND @Calc_On_Allow_Dedu > @PF_LIMIT And @Cmp_PF_DEF_ID = @AD_DEF_ID
													SET @Calc_On_Allow_Dedu = @PF_Limit  
										
												
											--SET @M_AD_Amount = ROUND((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)
											
											IF @No_of_increment > 1 --''Ankit 08082016
												SET @M_AD_Amount = (@Calc_On_Allow_Dedu * @M_AD_Percentage / 100)
											ELSE
												SET @M_AD_Amount = ROUND((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)	
		
											--Added by Hardik 09/07/2013
											SET @Calc_On_Allow_Dedu = Isnull(@Calc_On_Allow_Dedu,0) + Isnull(@Arear_PF_Amount,0)
											
											SET @M_AD_Amount = Isnull(@M_AD_Amount,0) + ISNULL(@Temp_PF_Amount,0)
											
											


											-- NCP Logic Add by Deepal DT :- 15122022 Requirement given by Chintan bhai
											--if ((Select IS_NCP_PRORATA from T0050_GENERAL_DETAIL where GEN_ID in (Select Gen_ID from T0040_GENERAL_SETTING where cmp_id = Cmp_ID and Branch_ID = @Branch_ID)) = 1)
											if ((Select IS_NCP_PRORATA from T0050_GENERAL_DETAIL where GEN_ID in (Select G.Gen_ID from T0040_GENERAL_SETTING G inner join (Select MAX(For_Date) as For_Date from T0040_GENERAL_SETTING where cmp_id = @Cmp_ID and Branch_ID = @Branch_ID) T on G.For_Date = T.For_Date where cmp_id = @Cmp_ID and Branch_ID = @Branch_ID)) = 1)
											BEGIN
												DECLARE @PFLIMIT AS NUMERIC(10) = 0
												SELECT @PFLIMIT = ISNULL(PF_LIMIT ,0)
												FROM T0050_GENERAL_DETAIL 
												WHERE GEN_ID IN (SELECT GEN_ID FROM T0040_GENERAL_SETTING WHERE CMP_ID = CMP_ID AND BRANCH_ID = @BRANCH_ID)

													

												IF @PFLimit > 0 
												BEGIN
												--select @SALARY_CAL_DAY,@FROM_DATE,@TO_DATE
								
													IF @M_AD_AMOUNT >= ((@PFLIMIT * 12)/100)
													BEGIN
															--set @Calc_On_Allow_Dedu = (@Calc_On_Allow_Dedu /(DATEDIFF(D,@FROM_DATE,@TO_DATE) + 1)) * @SALARY_CAL_DAY
															set @Calc_On_Allow_Dedu = (@Calc_On_Allow_Dedu /@Out_Of_Days) * @SALARY_CAL_DAY
															SET @M_AD_AMOUNT = ROUND((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)
													END
												END	
												
											END	
											
											
											-- NCP Logic Add by Deepal DT :- 15122022 Requirement given by Chintan bhai
										END   
									ELSE IF @GPF_DEF_ID = @AD_DEF_ID /* ELSE IF --Ankit 08082016 - */
										BEGIN
											--Added By Nimesh 17-07-2015 (For Additional GPF Deduction)
											DECLARE @Additional_GPF NUMERIC(18, 4)
											
											SELECT	@Additional_GPF = Amount
											FROM	V0090_EMP_GPF_REQUEST GPF WITH (NOLOCK)
											WHERE	Emp_ID=@Emp_Id AND Cmp_ID=@Cmp_ID
													AND Effective_Date= (
																			SELECT	MAX(EFFECTIVE_DATE) 
																			FROM	V0090_EMP_GPF_REQUEST GP1
																			WHERE	GP1.Cmp_ID=GPF.Cmp_ID AND GP1.Emp_ID=GPF.Emp_ID
																					AND GP1.Effective_Date < @TO_DATE
																		)
											
											SET @M_AD_Amount = @M_AD_Amount  + IsNull(@Additional_GPF,0)
										END
									ELSE IF @ESIC_DEF_ID = @AD_DEF_ID OR @Cmp_ESIC_DEF_ID = @AD_DEF_ID                   
										BEGIN
											IF @Is_ESIC = 1 --- Added Condition by Hardik 26/10/2015 for Nirma as General Setting has no ESIC ticked then ESIC Allowance should not calculate
												BEGIN        
													IF @Salary_Depends_on_Production = 1 and ISNULL(@Salary_Cal_Day,0) > 0-- Added by Hardik 08/04/2015 for Samarth Import Gross Salary every month
														BEGIN
															Select  @ESIC_Basic_Salary_actual = ((Gross_Amount/@Salary_Cal_Day)*@Out_Of_Days)  --@Calc_On_Allow_Dedu --Gross_Amount
															, @Calc_On_Allow_Dedu = Case When @varCalc_On ='Gross Salary' then  Gross_Amount Else @Calc_On_Allow_Dedu End
															From T0050_Production_Details_Import WITH (NOLOCK) Where Employee_ID=@Emp_Id and Production_Month = Month(@To_Date) and Production_Year=Year(@To_Date)
															
															--IF @Present_Days > 0
															--BEGIN
															--	set	@ESIC_Basic_Salary_actual = (@ESIC_Basic_Salary_actual/ @Present_Days)* 26.00  --Kept Hard-Coded By Ramiz only for Samarth on 08/07/2015
															--End
															
														END

													IF @ESIC_Limit <> 0  
														BEGIN
															IF NOT EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID=@Emp_Id)  And @ESIC_Basic_Salary_actual <= @ESIC_Limit
																SET @sal_tran_id1 = -1 
															ELSE IF EXISTS(SELECT 1 FROM #Allowance_Mid_Prev_Detail WHERE AD_ID=@AD_ID AND EMP_ID=@EMP_ID)  --- Added by Hardik 29/04/2020 for Wonder as they have mid increment and in first increment gross less that 21000 and new increment above 21000 then ESIC should calculate on both increment in April and Oct month
																SET @sal_tran_id1 =@Sal_Tran_ID

															IF MONTH(@TO_DATE) NOT IN (4,10) and @sal_tran_id1 = 0
																SET @M_AD_Amount=0
															ELSE IF @ESIC_Basic_Salary_actual <= @ESIC_Limit
																	BEGIN
																	
																		IF @Effect_OT_IN_ESIC = 1
																			BEGIN 
																				SET @Calc_On_Allow_Dedu = @Calc_On_Allow_Dedu + Isnull(@OT_Amount,0) + Isnull(@OT_WO_AMOUNT,0) + Isnull(@OT_HO_AMOUNT,0)-- added by mitesh on 07082012
																			END
																		--	BEGIN
																		--		SET @M_AD_Amount = CEILING(CAST(((@Calc_On_Allow_Dedu + @OT_Amount) * @M_AD_Percentage / 100) AS NUMERIC(18, 4))) 
																		--	END
																		--ELSE
													
													
																		--Changed by Hardik 11/12/2013 for Employer ESIC should not round to ceiling	
																		--IF @ESIC_DEF_ID = @AD_DEF_ID
																		--	SET @M_AD_Amount = CEILING(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4))) 
																		--Else
																		--	SET @M_AD_Amount = Round(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4)),2) 

																			IF @No_of_increment > 1 -- added by mitesh for mid increment case = first time it will not do rounding /celling of amount , second time it will do.
																				BEGIN 
																					SET @M_AD_Amount = CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4))
																					
																					----Comment Below Code - Ankit/Hardikbhai - 10082016 
																					--if isnull(@Count_Allowance_Mid,0) > 0
																					--	BEGIN

																					--		IF @ESIC_DEF_ID = @AD_DEF_ID
																					--			SET @M_AD_Amount = CEILING(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4))) 
																					--		Else
																					--			IF @Cmp_ESIC_DEF_ID = @AD_DEF_ID And @Upper_Round_Employer_ESIC = 0 --Added by Hardik 25/06/2014 for BMA
																					--				SET @M_AD_Amount = Round(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4)),2) 
																					--			Else
																					--				SET @M_AD_Amount = CEILING(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4))) 
																					--	end
																					--else
																					--	BEGIN
																					--		IF @Cmp_ESIC_DEF_ID = @AD_DEF_ID And @Upper_Round_Employer_ESIC = 0 --Added by Hardik 25/06/2014 for BMA
																					--			SET @M_AD_Amount = Round(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4)),2) 
																					--		Else
																					--			SET @M_AD_Amount = CEILING(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4))) 
																					--	end
																					----Comment 
																				end
																			else
																				BEGIN 
																					IF @ESIC_DEF_ID = @AD_DEF_ID
																						SET @M_AD_Amount = CEILING(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4))) 
																					Else
																						IF @Cmp_ESIC_DEF_ID = @AD_DEF_ID And @Upper_Round_Employer_ESIC = 0 --Added by Hardik 25/06/2014 for BMA
																							SET @M_AD_Amount = Round(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4)),CASE WHEN @IS_ROUNDING = 1 THEN 0 ELSE 2 END) 
																						Else
																							SET @M_AD_Amount = Ceiling(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4))) 
													
																				end
										
																	END
															ELSE IF @ESIC_Basic_Salary_actual >= @ESIC_Limit and @No_of_increment > 1 -- Deepal Add the new condition after discussion the case with sandip bhai and Chintan bhai 13122022 -- 23472
															BEGIN
																	SET @M_AD_Amount = CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4))
															END
															ELSE IF @sal_tran_id1 > 0 OR (@ESIC_Basic_Salary_actual <= @ESIC_Limit AND @sal_tran_id1 = -1) Or @sal_tran_id1 = -2 ---  added -2 condition by Hardik for Cera, Description is above side
																	BEGIN	
																		IF @Effect_OT_IN_ESIC = 1 
																			BEGIN
																				--SET @M_AD_Amount = CEILING(CAST(((@Calc_On_Allow_Dedu  + @OT_Amount) * @M_AD_Percentage / 100) AS NUMERIC(18, 4)))    
																				SET @Calc_On_Allow_Dedu = @Calc_On_Allow_Dedu  + Isnull(@OT_Amount,0) + Isnull(@OT_WO_AMOUNT,0) + ISNULL(@OT_HO_AMOUNT,0)
																			END
																			
																		--Added condition by Hardik 12/09/2016 as ESIC should deduct on Limit even Salary increase the limit																	
																		--If @ESIC_Basic_Salary_actual > @ESIC_Limit
																		--	Begin
																		--		 SET @Calc_On_Allow_Dedu =@ESIC_Limit
																		--	End	

														
																		--Changed by Hardik 11/12/2013 for Employer ESIC should not round to ceiling	
																		--IF @ESIC_DEF_ID = @AD_DEF_ID
																		--	SET @M_AD_Amount = CEILING(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4))) 
																		--Else
																		--	SET @M_AD_Amount = Round(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4)),2) 

																		IF @No_of_increment > 1 -- added by mitesh for mid increment case = first time it will not do rounding /celling of amount , second time it will do.
																				BEGIN 
																					if isnull(@Count_Allowance_Mid,0) > 0
																						BEGIN
																							IF @ESIC_DEF_ID = @AD_DEF_ID
																								SET @M_AD_Amount = CEILING(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4))) 
																							Else
																								SET @M_AD_Amount = Round(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4)),2) 
																							
																						end
																					else
																						BEGIN
																							IF @ESIC_DEF_ID = @AD_DEF_ID
																								SET @M_AD_Amount = (CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4))) 
																							Else
																								SET @M_AD_Amount = (CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4))) 
																						end
																
																					end
																				else
																					BEGIN 

																						IF @ESIC_DEF_ID = @AD_DEF_ID
																							SET @M_AD_Amount = CEILING(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4))) 
																						Else
																							SET @M_AD_Amount = Round(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4)),2) 
														
																					end
														
																	END		
															ELSE
																	BEGIN	
																		SET @M_AD_Amount=0
																	END	
														END		
													ELSE
														BEGIN
																	IF @Effect_OT_IN_ESIC = 1 
																		BEGIN
																			SET @Calc_On_Allow_Dedu = @Calc_On_Allow_Dedu  + Isnull(@OT_Amount,0) + Isnull(@OT_WO_AMOUNT,0) + ISNULL(@OT_HO_AMOUNT,0)
																			--SET @M_AD_Amount = CEILING(CAST(((@Calc_On_Allow_Dedu  + @OT_Amount) * @M_AD_Percentage / 100) AS NUMERIC(18, 4)))    	
																		END
												
																		--Changed by Hardik 11/12/2013 for Employer ESIC should not round to ceiling	
																		--IF @ESIC_DEF_ID = @AD_DEF_ID
																		--	SET @M_AD_Amount = CEILING(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4))) 
																		--Else
																		--	SET @M_AD_Amount = Round(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4)),2) 

																			IF @No_of_increment > 1 -- added by mitesh for mid increment case = first time it will not do rounding /celling of amount , second time it will do.
																				BEGIN 
															
																					if isnull(@Count_Allowance_Mid,0) > 0
																						BEGIN
																							IF @ESIC_DEF_ID = @AD_DEF_ID
																								SET @M_AD_Amount = CEILING(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4))) 
																							Else
																								SET @M_AD_Amount = Round(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4)),2)
																						end
																					else
																						BEGIN
																							
																							IF @ESIC_DEF_ID = @AD_DEF_ID
																								SET @M_AD_Amount = (CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4))) 
																							Else
																								SET @M_AD_Amount = (CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4))) 
																						end
																
																					end
																				else
																					BEGIN 

																						IF @ESIC_DEF_ID = @AD_DEF_ID
																							SET @M_AD_Amount = CEILING(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4))) 
																						Else
																							SET @M_AD_Amount = Round(CAST((@Calc_On_Allow_Dedu  * @M_AD_Percentage / 100) AS NUMERIC(18, 4)),2) 
														
																					end

											
														END		
															
															
												END   
											ELSE
												BEGIN
													Set @M_AD_Amount = 0
												END                     	
										END
									ELSE IF ROUND((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0) > @Max_Upper AND @Max_Upper > 0                    
										BEGIN
											SET @M_AD_Amount = @Max_Upper                     
										END 
									ELSE IF @Bonus_DEF_ID = @AD_DEF_ID
										BEGIN
										
											SELECT @Mini_Wages = ISNULL(MW.Wages_Value,0) FROM T0050_Minimum_Wages_Master MW WITH (NOLOCK) INNER JOIN
												( SELECT MAX(Effective_Date) AS EffecDate,SkillType_ID FROM T0050_Minimum_Wages_Master WITH (NOLOCK)
													WHERE cmp_Id = @Cmp_ID AND SkillType_ID = @SkillType_ID AND Effective_Date <= @To_Date GROUP BY SkillType_ID
												) Qry ON MW.SkillType_ID = Qry.SkillType_ID AND MW.Effective_Date = Qry.EffecDate
											WHERE MW.cmp_Id = @Cmp_ID AND MW.SkillType_ID = @SkillType_ID
											
											/* Bonus Calculated limit check : Bonus Max Limit In Company General Setting or Gov. Minimum Wages in Grade Master whichever is higher (Golcha EmailDated - Thu, Feb 25, 2016) -- Ankit 09032016   */
											IF ISNULL(@Mini_Wages,0) > 0 AND @Calc_On_Allow_Dedu >= @Max_Bonus_Salary_Amount 
												BEGIN
													IF @Mini_Wages > @Max_Bonus_Salary_Amount
														SET @Calc_On_Allow_Dedu = @Mini_Wages
													ELSE
														SET @Calc_On_Allow_Dedu = @Max_Bonus_Salary_Amount
												END
											
											
											SET @M_AD_Amount = ROUND(@Calc_On_Allow_Dedu * @M_AD_Percentage/100,0)
										END
									ELSE                    
										BEGIN
										
											-- Commented by Hardik 29/04/2020 for Wonder as Patni School has VPF Amount showing 1800 which is wrong
											-- Hardik 01/04/2019 New PF Rule
											--IF @AD_DEF_ID=@VPF_DEF_ID And @Calc_On_Allow_Dedu > @PF_Limit And @Basic_Salary <= @PF_Limit
											--	Set @Calc_On_Allow_Dedu = @PF_Limit
											if @Wages_type <> 'Daily'
											BEGIN
											--If condition added Alpesh 20-Jul-2011
											IF @IS_ROUNDING = 1 AND @No_of_increment = 1   --Added @No_of_increment condition by Nimesh on 4-Oct-2018 (Allowance Amount is getting rounding twice in mid increment case)
												SET @M_AD_Amount = ROUND((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)
											ELSE
												SET @M_AD_Amount = (@Calc_On_Allow_Dedu * @M_AD_Percentage / 100)
											END

											--Added by ronakk 07012023 condtion of Agrawal CHM 
											 if exists(select 1 from T0050_AD_MASTER where AD_ID = @AD_ID and isBonusCalDays=1)
											 Begin

											     if exists(select 1 from V0080_EMP_MASTER_INCREMENT_GET where Emp_ID=@Emp_Id and increment_type='Joining')
												 Begin

														  declare @Bonusdays int = (select isnull(BonusDays,0) from T0050_AD_MASTER where AD_ID = @AD_ID)
														  Declare @Present_Sal_Date datetime =@To_Date
														  Declare @Previouse_Sal_date datetime = DATEADD(MONTH, -1, @Present_Sal_Date) 
												   		  
														  if 0<(select sum(M_AD_Amount) from T0210_MONTHLY_AD_DETAIL where AD_ID = @AD_ID
														  and Emp_ID = @Emp_Id and For_Date < @Present_Sal_Date)
														  Begin
														  	  set @M_AD_Amount = @M_AD_Amount
														  end
														  else
														  Begin 
													   
																 Declare @PRDAYS int 

																select @PRDAYS = isnull(sum(Present_Days),0)+@Present_Days  from T0200_MONTHLY_SALARY where Emp_ID=@Emp_Id
																and Month_End_Date between @Join_Date and @Present_Sal_Date

																 if @Bonusdays<=@PRDAYS
																 Begin
											
																	 select @M_AREARS_AMOUNT = sum(M_AD_Calculated_Amount*M_AD_Percentage/100)  from T0210_MONTHLY_AD_DETAIL where AD_ID = @AD_ID
																	 and Emp_ID = @Emp_Id and For_Date < @Present_Sal_Date

																	  set @M_AD_Amount = @M_AD_Amount

																 End
																 else if @Present_Days < @Bonusdays
																 Begin
																     set @M_AD_Amount=0
																 end

														 end


												 end
												 else
												 Begin
													  set @M_AD_Amount = @M_AD_Amount      
												 end
											 end
											--End by ronakk 07012023

											IF UPPER(@varCalc_On) ='FIX + JOINING PRORATE'                    -- Added by rohit on 25-nov-2014
												BEGIN 
													Declare @Actual_Amount_1 NUMERIC(18,2)
													Set @Actual_Amount_1 = @M_AD_AMOUNT
													
													IF (@JOIN_DATE >= @ACTUAL_START_DATE  AND @JOIN_DATE <= @ACTUAL_END_DATE)
														BEGIN
															SET @M_AD_AMOUNT = ROUND((@M_AD_AMOUNT * (DATEDIFF(day,@JOIN_DATE,@ACTUAL_END_DATE)+ 1) )/@OUT_OF_DAYS,0)
														END
													ELSE IF (@LEFT_DATE >= @ACTUAL_START_DATE  AND @LEFT_DATE <= @ACTUAL_END_DATE)
														BEGIN
															SET @M_AD_AMOUNT = ROUND((@M_AD_AMOUNT * (DATEDIFF(day,@ACTUAL_START_DATE,@LEFT_DATE) + 1))/@OUT_OF_DAYS,0)
														END
													ELSE
														BEGIN
															SET @M_AD_AMOUNT=@M_AD_AMOUNT							
														END
													
													-- Added By Nilesh Patel on 02082019 -- Bug ID = 0010290 Mantis
													IF @M_AD_AMOUNT > @Actual_Amount_1
														Set @M_AD_AMOUNT = @Actual_Amount_1
												END

										END
								END                     
							ELSE                    
								BEGIN 
								
									IF UPPER(@varCalc_On) ='FIX'                    
										BEGIN    		
										   SET @M_AD_Amount=@M_AD_Amount							
										END       
									Else IF UPPER(@varCalc_On) ='FIX + JOINING PRORATE'                    -- Added by rohit on 25-nov-2014
										BEGIN 
											Declare @Actual_Amount NUMERIC(18,2)
											Set @Actual_Amount = @M_AD_AMOUNT
											
											IF (@JOIN_DATE >= @ACTUAL_START_DATE  AND @JOIN_DATE <= @ACTUAL_END_DATE) 
												BEGIN
													  --SET @M_AD_AMOUNT = ROUND((@M_AD_AMOUNT * @SALARY_CAL_DAY)/@OUT_OF_DAYS,0)  --Comment By Nilesh patel on 10102018 -- After Discuss with Hardikbhai
													  -- Mantins bugs no 0007875 -- Fix Allowance is not properly calculate in case of LWP Leave apply and Emlpoyee left on Last Date.
													  SET @M_AD_AMOUNT = ROUND((@M_AD_AMOUNT * (DATEDIFF(day,@JOIN_DATE,@ACTUAL_END_DATE) + 1))/@OUT_OF_DAYS,0)
												 END
											ELSE IF (@LEFT_DATE >= @ACTUAL_START_DATE  AND @LEFT_DATE <= @ACTUAL_END_DATE)
												BEGIN
													SET @M_AD_AMOUNT = ROUND((@M_AD_AMOUNT * (DATEDIFF(day,@ACTUAL_START_DATE,@LEFT_DATE) + 1))/@OUT_OF_DAYS,0)
												END
											ELSE
												BEGIN
													SET @M_AD_AMOUNT=@M_AD_AMOUNT							
												END
											-- Added By Nilesh Patel on 02082019 -- Bug ID = 0010290 Mantis
											IF @M_AD_AMOUNT > @Actual_Amount
												Set @M_AD_AMOUNT = @Actual_Amount
										END   	      	  
									else IF UPPER(@varCalc_On) ='Security Deposit'                    -- Added by rohit on 03-apr-2014
										BEGIN    
											IF @Allowance_Get = 1
											BEGIN							                														   							   
												SET @M_AD_Amount=@M_AD_Amount							
											END
											else
											BEGIN
												SET @M_AD_Amount = 0							
											End	
										END     
									ELSE IF @varCalc_On ='Canteen Deduction'  --Nimesh 2015-05-13 (Canteen Deduction)
									    BEGIN							    																						
										    DECLARE @From_CutOff_Date as datetime
										    DECLARE @To_CutOff_Date as datetime
										    SET @From_CutOff_Date = @From_Date
											Set @To_CutOff_Date = @To_Date
										    
										    SELECT	@From_CutOff_Date= DateAdd(dd,1,IsNull(Cutoff_Date,Month_End_Date)) 
										    FROM	T0200_MONTHLY_SALARY WITH (NOLOCK) 
										    WHERE	MONTH(Month_End_Date) =  MONTH(DateAdd(M,-1,@To_Date)) AND YEAR(Month_End_Date) =  YEAR(DateAdd(M,-1,@To_Date)) AND Emp_ID=@Emp_ID 
									    	
									    	SET @To_CutOff_Date = DateAdd(DD,-1,DateAdd(M,1,@From_CutOff_Date))
									    	
									    	IF @FROM_DATE > @From_CutOff_Date
									    		SET @From_CutOff_Date = @FROM_DATE
									    	IF @TO_DATE < @To_CutOff_Date
									    		SET @To_CutOff_Date = @TO_DATE
							
										    Exec dbo.P0050_CALCULATE_CANTEEN_DEDUCTION @Cmp_ID, @Emp_Id, @From_CutOff_Date, @To_CutOff_Date, @M_AD_Amount OUTPUT																					    												    
										    
									    END  
									Else IF @varCalc_On = 'Insurance Deduction' -- LIC Deduction    --Added by Gadriwala Muslim 15/07/2015
										BEGIN
											select @M_AD_Amount = isnull(SUM(Monthly_Premium),0) from T0090_EMP_INSURANCE_DETAIL WITH (NOLOCK) 
											where isnull(Ins_Exp_Date,@To_Date) >= @To_Date and Sal_Effective_Date <= @To_Date 
											and Deduct_From_Salary = 1 and Emp_Id = @Emp_Id and Cmp_ID = @cmp_ID 
										END      
									ELSE 
									--IF @Wages_type = 'Monthly' and @varCalc_On <> 'Leave Allowance' and UPPER(@varCalc_On) <> 'FIX' and UPPER(@varCalc_On)<> 'FIX + JOINING PRORATE' AND UPPER(@varCalc_On) <> 'IMPORT'                     
									--	BEGIN										
									--		IF @varCalc_On <> 'Arrears' --Changed the Spelling from "Arears" to "Arrears" by Ramiz on 16/11/2016
									--			BEGIN													
									--				IF @IS_ROUNDING = 1 													
									--					SET @M_AD_Amount = ROUND((@M_AD_Amount * @Salary_Cal_Day)/@Out_Of_Days,0)  														
									--				ELSE 																										
									--					SET @M_AD_Amount =  (@M_AD_Amount * @Salary_Cal_Day)/@Out_Of_Days  															
									--			END
									--	END                    
									--ELSE 
						   -- Changed By Sajid 29/01/2022 for Tanvi Client Start						 
							IF @Wages_type = 'Monthly' and @varCalc_On <> 'Leave Allowance' and UPPER(@varCalc_On) <> 'FIX' and UPPER(@varCalc_On)<> 'FIX + JOINING PRORATE' AND UPPER(@varCalc_On) <> 'IMPORT'                     
							BEGIN										
								IF @varCalc_On <> 'Arrears' AND @Wages_type='Monthly'--Changed the Spelling from "Arears" to "Arrears" by Ramiz on 16/11/2016
									BEGIN
									PRINT 11
												if @SalaryBasis = 'Hour' and @Wages_type='Monthly'
												Begin												
													set @M_AD_Amount = (@M_AD_Amount/@Out_Of_Days)/ DATEPART(hh, @Shift_Day_Hour)												
													SET @M_AD_Amount = Round(@M_AD_Amount * (@Actual_Working_Sec + @Other_Working_Sec)/3600,0)												
												END
												ELSE	
												Begin
													IF @IS_ROUNDING = 1 
														SET @M_AD_Amount = ROUND((@M_AD_Amount * @Salary_Cal_Day)/@Out_Of_Days,0)  
													ELSE                   
														SET @M_AD_Amount =  (@M_AD_Amount * @Salary_Cal_Day)/@Out_Of_Days
												End
   								 END
							END    	
								
								-- Changed By Sajid 29/01/2022 for Tanvi Client END
									IF @varCalc_On <> 'Leave Allowance' and UPPER(@varCalc_On) <> 'FIX'  AND UPPER(@varCalc_On)<> 'FIX + JOINING PRORATE' AND UPPER(@varCalc_On) <> 'IMPORT'																	
										BEGIN										
											IF @varCalc_On <> 'Arrears' AND @Wages_type = 'Daily'  --Changed the Spelling from "Arears" to "Arrears" by Ramiz on 16/11/2016
												BEGIN													
													IF @SalaryBasis = 'Hour' And @Wages_type = 'Daily' -- Added by Hardik 22/12/2020 for Kaypee Client
														BEGIN														
															IF @IS_ROUNDING = 1                    			
																SET @M_AD_Amount = ROUND(((@M_AD_Amount/@Shift_Day_Sec)*3600)*(@Actual_Working_Sec/3600) ,0)       
															ELSE
																SET @M_AD_Amount =  ((@M_AD_Amount/@Shift_Day_Sec)*3600)*(@Actual_Working_Sec/3600)
														END
													ELSE
														BEGIN															
															--If condition added Alpesh 20-Jul-2011
															IF @IS_ROUNDING = 1                    			
																SET @M_AD_Amount = ROUND((@M_AD_Amount * @Salary_Cal_Day),0)       
															ELSE															
																SET @M_AD_Amount =  (@M_AD_Amount * @Salary_Cal_Day)                    
														END
												END
										END 
																				
								END                     
						END                    
					 					 
					 ----- ADDED BY RAJPUT ON 02112018 FOR RETURN BOND AMOUNT PROCESS ( SAMARTH CLIENT ) -----
					IF @varCalc_On = 'Fix' and  @AD_DEF_ID = @BOND_RETURN_DEF_ID
						BEGIN
							
							DECLARE @BOND_RETURN_DATE AS DATETIME
							DECLARE @BOND_RETURN_AMOUNT AS NUMERIC(18,2)
								SET @BOND_RETURN_AMOUNT = 0
							DECLARE @BOND_RETURN_MONTH AS INT
							DECLARE @BOND_RETURN_YEAR AS INT
							
							SELECT	@BOND_RETURN_MONTH = BOND_RETURN_MONTH,
									@BOND_RETURN_YEAR = BOND_RETURN_YEAR
							FROM	T0120_BOND_APPROVAL BA WITH (NOLOCK)
							WHERE	BA.CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID AND BOND_RETURN_MODE = 'S' AND ISNULL(BOND_APR_PENDING_AMOUNT,0) = 0 
							
						
							
							SELECT	@BOND_RETURN_AMOUNT = ISNULL(SUM(BOND_APR_AMOUNT) ,0)
							FROM	T0120_BOND_APPROVAL BA WITH (NOLOCK) 
							WHERE   CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID AND BOND_RETURN_MODE = 'S' AND ISNULL(BOND_APR_PENDING_AMOUNT,0) = 0 AND
									MONTH(@TO_DATE) >= @BOND_RETURN_MONTH AND YEAR(@TO_DATE) >= @BOND_RETURN_YEAR  AND (ISNULL(BOND_RETURN_STATUS,'') = '' or ISNULL(BOND_RETURN_STATUS,'No') = 'No')
							
							
							-- FOR RETURN DATE STATUS
							IF(MONTH(@TO_DATE) > @BOND_RETURN_MONTH AND YEAR(@TO_DATE) > @BOND_RETURN_YEAR)
								SET @BOND_RETURN_DATE = dbo.GET_MONTH_END_DATE(@BOND_RETURN_MONTH,@BOND_RETURN_YEAR)
							ELSE
								SET @BOND_RETURN_DATE = dbo.GET_MONTH_END_DATE(MONTH(@TO_DATE),YEAR(@TO_DATE))
							--  END
							
							
							UPDATE	B
							SET		BOND_RETURN_STATUS = 'Yes',
									BOND_RETURN_DATE = @BOND_RETURN_DATE
							FROM	T0120_BOND_APPROVAL B
							WHERE	CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID AND BOND_RETURN_MODE = 'S' AND ISNULL(BOND_APR_PENDING_AMOUNT,0) = 0 AND
									MONTH(@TO_DATE) >= @BOND_RETURN_MONTH AND YEAR(@TO_DATE) >= @BOND_RETURN_YEAR  AND
									(ISNULL(BOND_RETURN_STATUS,'No') = 'No' or ISNULL(BOND_RETURN_STATUS,'') = '')
									
							
							SET @M_AD_AMOUNT = @BOND_RETURN_AMOUNT    
							
						END
					----- END BY RAJPUT ON 02112018 FOR RETURN BOND AMOUNT PROCESS ( SAMARTH CLIENT ) -----
					
					
										
					
					--PRINT  convert(varchar(20), getdate(), 114) + ' : STEP 4'
					        
					IF @varCalc_On = 'Slab Wise'    --Hasmukh for slab wise calculation
						BEGIN 
							SET @M_AD_Amount = 0     
							EXEC dbo.CALCULATE_AD_AMOUNT_SLAB_WISE @CMP_ID,@Emp_ID,@AD_ID,@To_Date,@Calc_On_Allow_Dedu OUTPUT,@M_AD_Amount OUTPUT,@Out_Of_Days,@Salary_Cal_Day   -- Changed by Gadriwala Muslim 16022015
						END

					-- Added by Hardik 03/02/2020 for SLS client, Redmine id 6677, If exit application done by employee then this allowance not payable, no need to check approval.
					Declare @Exit_Apply tinyint
					Set @Exit_Apply = 0

					If Exists(Select 1 from T0200_Emp_ExitApplication WITH (NOLOCK) Where Emp_Id = @Emp_Id) Or @Left_Date Is Not null
						Set @Exit_Apply = 1
					
					
					--Alpesh 14-Aug-2012	
					IF @varCalc_On = 'Reference'   
						BEGIN 
						
							Declare @Emp_Referral_Days Numeric(5,0)
							Set @Emp_Referral_Days = 0
							Select @Emp_Referral_Days = Setting_Value From T0040_SETTING WITH (NOLOCK) Where Setting_Name='Employee Referral bonus paid after days' and Cmp_ID = @Cmp_ID
							
							If @Emp_Referral_Days = 0
								BEGIN
									SET @M_AD_Amount = 0 
									-- Comment by nilesh patel on 02092015 Remove Company ID condition( case of cross company Emp Reference Amount is not calculate after discuss with hardik bhai change it)                   
									--SELECT @M_AD_Amount = ISNULL(SUM(Amount),0) FROM dbo.T0090_EMP_REFERENCE_DETAIL WHERE R_Emp_ID=@Emp_ID AND Cmp_ID = @Cmp_ID AND MONTH(For_Date) = MONTH(@Actual_End_Date) AND YEAR(For_Date) = YEAR(@Actual_End_Date)
									SELECT @M_AD_Amount = ISNULL(SUM(Amount),0) 
									FROM dbo.T0090_EMP_REFERENCE_DETAIL LED WITH (NOLOCK)
									WHERE LED.R_Emp_ID=@Emp_ID AND LED.Ref_Month = MONTH(@Actual_End_Date) AND LED.Ref_Year = YEAR(@Actual_End_Date) and Isnull(LED.Effect_In_Salary,0) = 1   
									AND NOT EXISTS(Select 1 From T0100_LEFT_EMP LE WITH (NOLOCK) WHERE LE.Emp_ID = LED.Emp_ID)       
								END
							ELSE
								BEGIN
									-- Added By Nilesh patel on 08-08-2019 For Validation day for Employee Referral Payment
									--DECLARE @Ref_Emp_ID NUMERIC(10,0)
									--Set @Ref_Emp_ID = 0
									--SELECT @Ref_Emp_ID =  Emp_ID FROM dbo.T0090_EMP_REFERENCE_DETAIL WHERE R_Emp_ID=@Emp_ID and dbo.GET_MONTH_ST_DATE(Ref_Month,Ref_Year) >= @From_Date
									
									--IF EXISTS(Select 1 From T0080_EMP_MASTER Where Emp_ID = @Ref_Emp_ID and (Emp_Left <> 'Y' OR Emp_Left_Date Is null)) -- Not Added Company Condition for Cross Company Employee Referance
									--	BEGIN
											
											--Declare @ReferalDate As Datetime
											--Declare @Ref_Emp_DOJ As DATETIME
											--Select @Ref_Emp_DOJ = Date_Of_Join From T0080_EMP_MASTER Where Emp_ID = @Ref_Emp_ID and Cmp_ID = @Cmp_ID
											--IF @CutoffDate_Salary is not null 
												--Set @ReferalDate = dbo.GET_MONTH_END_DATE(Month(@To_Date),Year(@To_Date)) 
											--Else
												--Set @ReferalDate = @To_Date
											
											--If (DATEDIFF(day,@Ref_Emp_DOJ,@To_Date) + 1) > @Emp_Referral_Days 
												--Begin
													SELECT @M_AD_Amount = ISNULL(SUM(LED.Amount),0) 
														FROM dbo.T0090_EMP_REFERENCE_DETAIL LED WITH (NOLOCK) INNER JOIN
															T0080_EMP_MASTER EM WITH (NOLOCK) On LED.Emp_Id = EM.Emp_Id
													WHERE LED.R_Emp_ID=@Emp_ID AND LED.Ref_Month = MONTH(@Actual_End_Date) 
													AND LED.Ref_Year = YEAR(@Actual_End_Date) and Isnull(LED.Effect_In_Salary,0) = 1  
													AND NOT EXISTS(Select 1 From T0100_LEFT_EMP LE WITH (NOLOCK) WHERE LE.Emp_ID = LED.Emp_ID and LE.Left_Reason = 'Default Company Transfer' )
													AND (Emp_Left <> 'Y' OR Emp_Left_Date Is null)
												--END
										--End
								END
						END
						---- End ----
						
								

					IF UPPER(@varCalc_On) ='PERFORMANCE'         
						BEGIN 
							SELECT @PERFORM_POINTS=SUM(ISNULL(PERCENTAGE,0)) FROM dbo.T0100_EMP_PERFORMANCE_DETAIL WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND MONTH(FOR_DATE)=MONTH(@From_Date)  AND YEAR(FOR_DATE)=YEAR(@From_Date)       

							IF @IS_ROUNDING = 1    
								SET @M_AD_Amount = ROUND((@M_AD_Actual_Per_Amount  * ISNULL(@PERFORM_POINTS,0))/100,0)
							ELSE
								SET @M_AD_Amount = (@M_AD_Actual_Per_Amount  * ISNULL(@PERFORM_POINTS,0))/100 
						END   


				

					IF @AD_DEF_ID = @Join_Time_Def_ID                     
						BEGIN                    
							IF MONTH(@From_Date) <> MONTH(@Join_Date) OR YEAR(@From_Date) <> YEAR(@Join_Date)                     
								SET @M_AD_Amount =0                     
						END         
					
					
					IF @IT_DEF_ID = @AD_DEF_ID              -- changed by mitesh on 15052012 TDS     
						BEGIN               
							IF @IT_TAX_AMOUNT > 0                     
								SET @M_AD_Amount = @IT_TAX_AMOUNT                    						
						END              

						
	                 
					IF @DA_DEF_ID = @AD_DEF_ID and Isnull(@Grade_Wise_Salary_Enabled,0) = 1				----DA allowance Calculation (Mafatlal Client)   --Ankit 13082015
						BEGIN	
								DECLARE	@DA_Amount_0433		NUMERIC(18, 4)
								DECLARE	@DA_Amount_0144		NUMERIC(18, 4)

								SET @DA_Amount_0433 = @M_AD_Amount * 0.433
								SET @DA_Amount_0144 = @M_AD_Amount * 0.144
																								--New Logic of DA Calculation is Added By Ramiz on 04/09/2017
								IF OBJECT_ID('tempdb..#DA_Allowance') IS NOT NULL
									BEGIN
										IF EXISTS (select 1 from #DA_Allowance)
											BEGIN
												UPDATE DA
												SET DA_Allow_Salary = 
														CASE WHEN (Master_Basic + ISNULL(@Other_Allow_Amount_actual,0)) >= 400 THEN
															((400 * @DA_Amount_0433) / 100 + (( CASE WHEN (Master_Basic + ISNULL(@Other_Allow_Amount_actual,0)) > 700 THEN 700 
															ELSE (Master_Basic + ISNULL(@Other_Allow_Amount_actual,0)) END - 400 ) * @DA_Amount_0144	) / 100) / 26 * DA.Grd_Count
														ELSE
															(((Master_Basic + ISNULL(@Other_Allow_Amount_actual,0)) * @DA_Amount_0433) / 100 ) / 26 * DA.Grd_Count
														END
												FROM #DA_Allowance DA
											
												SELECT @M_AD_Amount = CASE WHEN @IS_ROUNDING = 1 THEN 
																				ROUND(SUM(ISNULL(DA_Allow_Salary,0)),0) 
																			ELSE 
																				SUM(ISNULL(DA_Allow_Salary,0))
																			END
												FROM #DA_Allowance
											END
									END
									
								IF OBJECT_ID('tempdb..#OT_Gradewise') IS NOT NULL
									BEGIN
									IF EXISTS (select 1 from #DA_Allowance)
											BEGIN
												UPDATE DA
												SET DA_Allow_Salary = 
														CASE WHEN (Master_Basic + ISNULL(@Other_Allow_Amount_actual,0)) >= 400 THEN
															 (((400 * @DA_Amount_0433) / 100 + (( CASE WHEN (Master_Basic + ISNULL(@Other_Allow_Amount_actual,0)) > 700 THEN 700 
															ELSE  (Master_Basic + ISNULL(@Other_Allow_Amount_actual,0)) END - 400 ) * @DA_Amount_0144) / 100) / @Fix_OT_Work_Days / Replace(@Fix_OT_Shift_Hours,':','.')) * DA.Grd_OT_Hours
														ELSE
															((((Master_Basic + ISNULL(@Other_Allow_Amount_actual,0)) * @DA_Amount_0433) / 100 ) / @Fix_OT_Work_Days / Replace(@Fix_OT_Shift_Hours,':','.') ) * DA.Grd_OT_Hours
														END
												FROM #OT_Gradewise DA
											END
										
									END
								
								IF OBJECT_ID('tempdb..#EFFICIENCY_SALARY') IS NOT NULL
									BEGIN
										IF EXISTS ( SELECT 1 FROM #EFFICIENCY_SALARY )
											BEGIN
												UPDATE DA
												SET DA_Allow_Salary = 
														CASE WHEN (Master_Basic + ISNULL(@Other_Allow_Amount_actual,0)) >= 400 
															THEN ((400 * @DA_Amount_0433) / 100 + (( CASE WHEN (Master_Basic + ISNULL(@Other_Allow_Amount_actual,0)) > 700 THEN 700 
																									  ELSE (Master_Basic + ISNULL(@Other_Allow_Amount_actual,0)) END - 400 ) * @DA_Amount_0144	) / 100) / 26 * DA.Days_Count
														ELSE
															(((Master_Basic + ISNULL(@Other_Allow_Amount_actual,0)) * @DA_Amount_0433) / 100 ) / 26 * DA.Days_Count
														END
												FROM #EFFICIENCY_SALARY DA
											
												SELECT @M_AD_Amount = CASE WHEN @IS_ROUNDING = 1 THEN 
																				ROUND(SUM(ISNULL(DA_Allow_Salary,0)),0) 
																			ELSE 
																				SUM(ISNULL(DA_Allow_Salary,0))
																			END
												FROM #EFFICIENCY_SALARY
											END
									END
						END	 

						
					
					IF (@IS_ROUNDING = 1 AND (@No_Of_Increment = 1 OR @intCount >=2)) AND NOT /*or*/ ( @VPF_DEF_ID = @Ad_Def_Id or @PF_DEF_ID = @AD_DEF_ID OR @Cmp_PF_DEF_ID = @AD_DEF_ID OR @ESIC_DEF_ID = @AD_DEF_ID OR @Cmp_ESIC_DEF_ID = @AD_DEF_ID) --Added By Ramiz on 07/09/2015 /* 'AND NOT' & 'OR @Cmp_PF_DEF_ID = @AD_DEF_ID' Condition Added By Ankit 08082016 AND Remove OR Condition(GTPL Mid Month Increment , Rounding Issue) */ 
						SET @M_AD_Amount = ROUND(@M_AD_Amount,0)                    
					ELSE
						SET @M_AD_Amount = @M_AD_Amount      
				           
					
					----------for Selected Month----------------------------------------                  
					IF @AD_Effect_Month <> '' AND CHARINDEX(@StrMonth,@AD_Effect_Month) = 0 AND ISNULL(@AD_CAL_TYPE,'')='' 
						BEGIN  
							SET @M_AD_Amount = 0  
						END  
					
					--------------------------------------------------------------------
					IF @M_AD_EFFECT_ON_OT = 1
						BEGIN
							IF @Wages_type ='Monthly'
								SET  @OT_Basic_Salary = @OT_Basic_Salary + @E_Ad_Amount
							ELSE IF @M_AD_Percentage > 0                     
								SET  @OT_Basic_Salary = @OT_Basic_Salary + ROUND(@Day_Salary * @M_AD_Actual_Per_Amount/100,0) 
							ELSE 
								SET  @OT_Basic_Salary = @OT_Basic_Salary + @M_AD_Actual_Per_Amount 									
							
						END
			
					IF @AD_Effect_Month <> '' AND CHARINDEX(@StrMonth,@AD_Effect_Month) <> 0 AND ISNULL(@AD_CAL_TYPE,'')<>'' 
						BEGIN  
							IF @AD_CAL_TYPE = 'Quaterly'
								SELECT @M_AD_Amount=ISNULL(@M_AD_Amount,0) +ISNULL(SUM(ISNULL(M_AD_AMOUNT,0)),0) FROM dbo.T0210_MONTHLY_AD_DETAIL WHERE For_Date >= DATEADD(m,-2,@From_Date) AND For_Date <= @To_Date AND Ad_ID = @Ad_ID and Emp_ID = @emp_id 
							IF @AD_CAL_TYPE = 'Half Yearly'
								SELECT @M_AD_Amount=ISNULL(@M_AD_Amount,0) +ISNULL(SUM(ISNULL(M_AD_AMOUNT,0)),0) FROM dbo.T0210_MONTHLY_AD_DETAIL WHERE For_Date >= DATEADD(m,-5,@From_Date) AND For_Date <= @To_Date	AND Ad_ID = @Ad_ID and Emp_ID = @emp_id  
							IF @AD_CAL_TYPE = 'Yearly'
								SELECT @M_AD_Amount=ISNULL(@M_AD_Amount,0) +ISNULL(SUM(ISNULL(M_AD_AMOUNT,0)),0) FROM dbo.T0210_MONTHLY_AD_DETAIL WHERE For_Date >= DATEADD(m,-11,@From_Date) AND For_Date <= @To_Date AND Ad_ID = @Ad_ID and Emp_ID = @emp_id 	  					  
						END  
						
						

					IF @Arear_Month = 0 OR @Arear_Month IS NULL
						SET @Arear_Month = MONTH(@To_Date)
	
					IF @Arear_Year = 0 OR @Arear_Year IS NULL
						SET @Arear_Year = YEAR(@To_Date)

					SET @Out_Of_Days_Arear = DATEDIFF(dd,dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year),dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year))+ 1

					-- Added by rohit on 13012015
					IF @Arear_Month_cutoff = 0 OR @Arear_Month_cutoff IS NULL
						SET @Arear_Month_cutoff = MONTH(@To_Date)
	
					IF @Arear_Year_cutoff = 0 OR @Arear_Year_cutoff IS NULL
						SET @Arear_Year_cutoff = YEAR(@To_Date)
					
					SET @Out_Of_Days_Arear_Cutoff = DATEDIFF(dd,dbo.GET_MONTH_ST_DATE(@Arear_Month_cutoff,@Arear_Year_cutoff),dbo.GET_MONTH_END_DATE(@Arear_Month_cutoff,@Arear_Year_cutoff))+ 1
			
					--PRINT  convert(varchar(20), getdate(), 114) + ' : STEP 5'
					-- Ended by rohit on 13012015
			
					--- This Condition Added by Hardik 31/05/2013 for Khimji (ESIC Problem)
					-- As They have Added Import Allowance Amount in Emp Master where in arear they will not give Import Amount, So Calculation is coming wrong on basis of Earn Deduction Table

					

					If ((Isnull(@Other_Allow_Amount_Arear,0) > 0 And Isnull(@M_AD_Percentage,0) > 0) OR (@PF_DEF_ID = @AD_DEF_ID OR @Cmp_PF_DEF_ID = @AD_DEF_ID) OR (@ESIC_DEF_ID = @AD_DEF_ID OR @Cmp_ESIC_DEF_ID = @AD_DEF_ID) ) --Added By Jimit 27052019 as case at WHFL Arear days calculation for Cut Off case not done for ESIc (disccusion done with Hardik bhai..)
						BEGIN
							--PRINT  convert(varchar(20), getdate(), 114) + ' : STEP 5'
							Select @Arear_Calculated_Amount = Isnull(@Arear_Basic,0) + Isnull(@Other_Allow_Amount_Arear,0)  

							--select @Arear_Calculated_Amount
							
							--IF @Arear_Days <> 0 AND @Arear_Calculated_Amount > 0 and UPPER(@varCalc_On) <> 'IMPORT'
							IF @Arear_Days <> 0 AND @Arear_Calculated_Amount <> 0 
							and  (UPPER(@varCalc_On) <> 'IMPORT' and UPPER(@varCalc_On) <> 'FIX' and UPPER(@varCalc_On) <> 'Security Deposit' and UPPER(@varCalc_On)<> 'FIX + JOINING PRORATE' and UPPER(@varCalc_On)<> 'FORMULA') -- Security Deposit Added by rohit on 03-apr-2014						  
								BEGIN
								
									IF @ESIC_DEF_ID = @AD_DEF_ID OR @Cmp_ESIC_DEF_ID = @AD_DEF_ID
										BEGIN
											IF EXISTS (Select 1 From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) Where Month(To_Date)=@Arear_Month And Year(To_Date)=@Arear_Year And M_AD_Amount >0 AND AD_ID=@AD_ID  And Emp_ID=@Emp_Id)
											   OR
											   NOT EXISTS (Select 1 From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Month(Month_End_Date)=@Arear_Month And Year(Month_End_Date)=@Arear_Year And Emp_ID=@Emp_Id)  -- Added Condition by Hardik 19/10/2018 for Arkray as after cutoff salary new join employee's ESIC not deducted
												BEGIN
													--IF @ESIC_Basic_Salary_actual <= @ESIC_Limit
													--	SET @M_AREARS_AMOUNT = Ceiling((@Arear_Calculated_Amount * @M_AD_Percentage / 100))
													--Else
													--	SET @M_AREARS_AMOUNT = 0
													If (@Arear_Calculated_Amount * @M_AD_Percentage / 100) < 0 -- -Added by Hardik 02/11/2020 for Arkray as they have Minus ESIC and it should upper round but it was going to lower round if amount is minus
														SET @M_AREARS_AMOUNT = floor((@Arear_Calculated_Amount * @M_AD_Percentage / 100))
													Else
														SET @M_AREARS_AMOUNT = Ceiling((@Arear_Calculated_Amount * @M_AD_Percentage / 100))
												END
											ELSE
												BEGIN
													SET @M_AREARS_AMOUNT = 0
												END										
										END
									-- Added by rohit on 01-apr-2014 for polycab case arear pf deduct more then 780
									Else IF @PF_DEF_ID = @AD_DEF_ID OR @Cmp_PF_DEF_ID = @AD_DEF_ID
										BEGIN
										
											IF (@Emp_Full_Pf=0 and @PF_DEF_ID = @AD_DEF_ID ) or ( @Emp_Full_Pf=1 and @Emp_Auto_VPF=0 and @Cmp_PF_DEF_ID = @AD_DEF_ID ) or (@Emp_Full_Pf=0 and @Cmp_PF_DEF_ID = @AD_DEF_ID  ) 
												BEGIN 
													DECLARE @Pf_Arear_Amount as NUMERIC(18, 4)
													DECLARE @M_AD_Percentage_Temp as NUMERIC(18, 4) -- Added by Hardik 26/05/2020 for Covid benefit on PF by Government

													SET @Pf_Arear_Amount = 0
													Set @M_AD_Percentage_Temp = 0
													
													-- Covid Changes
													SELECT @Pf_Arear_Amount = Sum(isnull(m_Ad_Amount,0)) --(Sum(isnull(m_Ad_Amount,0)) + Sum(isnull(M_Arear_Amount,0)))  
															,@M_AD_Percentage = Max(M_AD_Actual_Per_Amount)
													from T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) where Emp_ID=@emp_id and cmp_id=@cmp_id and To_date >= dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year) and to_date <= dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year) and ad_id=@AD_ID
													
													--select @Pf_Arear_Amount
													-- Added by Hardik 26/05/2020 for Covid benefit on PF by Government
													--If @Arear_Month In (5,6,7) And @Arear_Year=2020 And @AD_DEF_ID in (@PF_DEF_ID,@Cmp_PF_DEF_ID)
													--	Begin
													--		Set @M_AD_Percentage_Temp = @M_AD_Percentage
													--		Set @M_AD_Percentage = 10.00

													--	End
													--Else
													--	Begin
													--		Set @M_AD_Percentage_Temp = @M_AD_Percentage
													--		Set @M_AD_Percentage = 12.00
													--	End
				  									
													
													IF @Pf_Arear_Amount >=  ROUND((@PF_Limit * @M_AD_Percentage / 100),0) /*@PF_Limit*/ /* PF Limit Comment Because It Check Actual Limit Amount - Ankit 05092016 */
														BEGIN
															SET @M_AREARS_AMOUNT = 0
														END
													ELSE
														BEGIN										  				
															SET @Pf_Arear_Amount = ROUND((@PF_Limit * @M_AD_Percentage / 100),0)/*@PF_Limit*/ - @Pf_Arear_Amount
					  					
															IF @IS_ROUNDING = 1
																BEGIN
																	SET @M_AREARS_AMOUNT = ROUND((@Arear_Calculated_Amount * @M_AD_Percentage / 100),0)
																	IF @Pf_Arear_Amount < @M_AREARS_AMOUNT
																		SET @M_AREARS_AMOUNT = @Pf_Arear_Amount
																END	
															ELSE
																BEGIN
																	SET @M_AREARS_AMOUNT = (@Arear_Calculated_Amount * @M_AD_Percentage / 100)
																	IF @Pf_Arear_Amount < @M_AREARS_AMOUNT
																		SET @M_AREARS_AMOUNT = @Pf_Arear_Amount
																END															
														END
												END
											ELSE
												BEGIN 
													---- Added by Hardik 26/05/2020 for Covid benefit on PF by Government
													--If @Arear_Month In (5,6,7) And @Arear_Year=2020 And @AD_DEF_ID in (@PF_DEF_ID,@Cmp_PF_DEF_ID)
													--	Begin
													--		Set @M_AD_Percentage_Temp = @M_AD_Percentage
													--		Set @M_AD_Percentage = 10.00

													--	End
													--Else
													--	Begin
													--		Set @M_AD_Percentage_Temp = @M_AD_Percentage
													--		Set @M_AD_Percentage = 12.00
													--	End
													
													--Covid Changes
													SELECT @M_AD_Percentage = M_AD_Actual_Per_Amount
													from T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) where Emp_ID=@emp_id and cmp_id=@cmp_id 
													and To_date >= dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year) 
													and to_date <= dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year) and ad_id=@AD_ID

													IF (@IS_ROUNDING = 1 or @PF_DEF_ID = @AD_DEF_ID OR @Cmp_PF_DEF_ID = @AD_DEF_ID)   --Changed By Jimit 30052018 for PF amount is not rounding at WCL.
														SET @M_AREARS_AMOUNT = ROUND((@Arear_Calculated_Amount * @M_AD_Percentage / 100),0)
													ELSE
														SET @M_AREARS_AMOUNT = (@Arear_Calculated_Amount * @M_AD_Percentage / 100)
												END
										
										END			  											
									ELSE
										BEGIN															
											IF @IS_ROUNDING = 1                    
												SET @M_AREARS_AMOUNT = ROUND((@Arear_Calculated_Amount * @M_AD_Percentage / 100),0)
											ELSE
												SET @M_AREARS_AMOUNT = (@Arear_Calculated_Amount * @M_AD_Percentage / 100)
												
										End
										

									-- Added by Hardik 26/05/2020 for Covid benefit on PF by Government
									--If Month(@Arear_Month) In (5,6,7) And Year(@Arear_Year)=2020 And @AD_DEF_ID in (@PF_DEF_ID,@Cmp_PF_DEF_ID)
									--	Begin
									--		Set @M_AD_Percentage = @M_AD_Percentage_Temp
									--	End

								END
								
								
						
								
							-- Added by rohit on 13012015  
							Select @Arear_Calculated_Amount_Cutoff = Isnull(@Salary_amount_Arear_cutoff,0) + Isnull(@Other_Allow_Amount_Arear_cutoff,0)  

							If @Emp_Full_Pf = 1 And @BASIC_SALARY_PF >= @PF_Limit And @AD_DEF_ID In (@PF_DEF_ID,@Cmp_PF_DEF_ID) --- Added by Hardik 05/08/2019 for NLMK Cutoff Case, New PF Rule
								Select @Arear_Calculated_Amount_Cutoff = Isnull(@Salary_amount_Arear_cutoff,0) 
							
							

							--IF @Arear_Days <> 0 AND @Arear_Calculated_Amount > 0 and UPPER(@varCalc_On) <> 'IMPORT'
							IF @Absent_after_Cutoff_date <> 0 AND @Arear_Calculated_Amount_Cutoff <> 0 
								AND (UPPER(@varCalc_On) <> 'IMPORT' and UPPER(@varCalc_On) <> 'FIX' 
								AND UPPER(@varCalc_On) <> 'Security Deposit' and UPPER(@varCalc_On)<> 'FIX + JOINING PRORATE' 
								AND UPPER(@varCalc_On) <> 'FORMULA') -- Formula added by rohit for Arear amount Not Calculate on Formula on 06012015-- Security Deposit Added by rohit on 03-apr-2014
								BEGIN
									IF @ESIC_DEF_ID = @AD_DEF_ID OR @Cmp_ESIC_DEF_ID = @AD_DEF_ID --Ankit 30102013										
  										BEGIN
											IF EXISTS (Select 1 From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) Where Month(To_Date)=@Arear_Month_cutoff And Year(To_Date)=@Arear_Year_cutoff And M_AD_Amount >0 AND AD_ID=@AD_ID  And Emp_ID=@Emp_Id)
												BEGIN
													IF (@Arear_Calculated_Amount_Cutoff * @M_AD_Percentage / 100) < 0 -- -- -Added by Hardik 02/11/2020 for Arkray as they have Minus ESIC and it should upper round but it was going to lower round if amount is minus
  														SET @M_AREARS_AMOUNT_Cutoff  = Floor((@Arear_Calculated_Amount_Cutoff * @M_AD_Percentage / 100))
													ELSE
														SET @M_AREARS_AMOUNT_Cutoff  = Ceiling((@Arear_Calculated_Amount_Cutoff * @M_AD_Percentage / 100))
												END
											Else
												SET @M_AREARS_AMOUNT_Cutoff = 0

											
  											--IF @ESIC_Basic_Salary_actual <= @ESIC_Limit
  												--SET @M_AREARS_AMOUNT_Cutoff  = Ceiling((@Arear_Calculated_Amount_Cutoff * @M_AD_Percentage / 100))
											--Else IF @Sal_tran_id1 <> 0
											--	SET @M_AREARS_AMOUNT = Ceiling((@Arear_Calculated_Amount * @M_AD_Percentage / 100))
											--Else
												--SET @M_AREARS_AMOUNT_Cutoff = 0
  										End		  									
									Else IF @PF_DEF_ID = @AD_DEF_ID OR @Cmp_PF_DEF_ID = @AD_DEF_ID -- Added by rohit on 01-apr-2014 for polycab case arear pf deduct more then 780
										BEGIN	
											IF (@Emp_Full_Pf=0 and @PF_DEF_ID = @AD_DEF_ID ) 
												OR ( @Emp_Full_Pf=1 AND @Emp_Auto_VPF=0 AND @Cmp_PF_DEF_ID = @AD_DEF_ID ) 
												OR (@Emp_Full_Pf=0 and @Cmp_PF_DEF_ID = @AD_DEF_ID  ) 
												BEGIN 
													DECLARE @Pf_Arear_Amount_cutoff as NUMERIC(18, 4)
													SET @Pf_Arear_Amount_cutoff = 0

													Set @M_AD_Percentage_Temp = 0
													
													-- Added by Hardik 26/05/2020 for Covid benefit on PF by Government
													--If @Arear_Month_cutoff In (5,6,7) And @Arear_Year_cutoff=2020 And @AD_DEF_ID in (@PF_DEF_ID,@Cmp_PF_DEF_ID)
													--	Begin
													--		Set @M_AD_Percentage_Temp = @M_AD_Percentage
													--		Set @M_AD_Percentage = 10.00

													--	End
													--Else
													--	Begin
													--		Set @M_AD_Percentage_Temp = @M_AD_Percentage
													--		Set @M_AD_Percentage = 12.00
													--	End
													--Add by tejas for cutoof salary not absent days after cutoff date but late/Early have add into absent days wonder home finance case
													--IF @Absent_after_Cutoff_date = (@late_day_cutoff + @early_day_cutoff)

			  										-- Covid Changes
													SELECT	@Pf_Arear_Amount_cutoff = (isnull(m_Ad_Amount,0)) --+ isnull(M_AREAR_AMOUNT_Cutoff,0)) 
															,@M_AD_Percentage = M_AD_Actual_Per_Amount
													FROM	T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) 
													WHERE	Emp_ID=@emp_id and cmp_id=@cmp_id and To_date >= dbo.GET_MONTH_ST_DATE(@Arear_Month_cutoff,@Arear_Year_cutoff ) 
															AND to_date <= dbo.GET_MONTH_END_DATE(@Arear_Month_cutoff ,@Arear_Year_cutoff ) and ad_id=@AD_ID 

													
													--select @Pf_Arear_Amount_cutoff,@PF_Limit,@Basic_Salary , Abs(@Salary_amount_Arear_cutoff),@Emp_Full_Pf,@M_AREARS_AMOUNT_Cutoff --tejas
  													IF (@Pf_Arear_Amount_cutoff  > @PF_Limit) OR (@PF_Limit < (@Basic_Salary - Abs(@Salary_amount_Arear_cutoff)) and @Emp_Full_Pf = 0)
  														OR NOT EXISTS(SELECT 1 FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)   ---ADDED THIS CONDITION BY HARDIK 07/02/2019 FOR MENTIS BUG 0008723 IF PF IS NOT DEDUCTED IN AREAR MONTH THEN IT SHOULD NOT DEDUCT IN CUTOFF SALARY
																		WHERE	Emp_ID=@emp_id and cmp_id=@cmp_id and To_date >= dbo.GET_MONTH_ST_DATE(@Arear_Month_cutoff,@Arear_Year_cutoff ) 
																		AND to_date <= dbo.GET_MONTH_END_DATE(@Arear_Month_cutoff ,@Arear_Year_cutoff ) and ad_id=@AD_ID)
  														BEGIN
  															SET @M_AREARS_AMOUNT_Cutoff  = 0
  														END
  													ELSE
  														BEGIN
														
															SET @Pf_Arear_Amount_cutoff  = @PF_Limit - @Pf_Arear_Amount_cutoff 
																
  															IF @IS_ROUNDING = 1
  																BEGIN                    
																	SET @M_AREARS_AMOUNT_Cutoff  = ROUND((@Arear_Calculated_Amount_Cutoff  * @M_AD_Percentage / 100),0)
																	--select @Pf_Arear_Amount_cutoff,@M_AREARS_AMOUNT_Cutoff,@Arear_Calculated_Amount_Cutoff
																	IF @Pf_Arear_Amount_cutoff  < @M_AREARS_AMOUNT_Cutoff 
																		BEGIN
																			SET @M_AREARS_AMOUNT_Cutoff  = @Pf_Arear_Amount_cutoff 
																		END																								
																END	
															ELSE
																BEGIN	
																	
																	SET @M_AREARS_AMOUNT_Cutoff  = (@Arear_Calculated_Amount_Cutoff  * @M_AD_Percentage / 100)																	
																	IF @Pf_Arear_Amount_cutoff  < @M_AREARS_AMOUNT_Cutoff 
																		BEGIN
																			SET @M_AREARS_AMOUNT_Cutoff  = @Pf_Arear_Amount_cutoff 																			
																		END
																END

															
  														END
													
													
  												END
  											ELSE
												BEGIN 
													
													IF @IS_ROUNDING = 1                    
														SET @M_AREARS_AMOUNT_Cutoff  = ROUND((@Arear_Calculated_Amount_Cutoff  * @M_AD_Percentage / 100),0)
													ELSE
														SET @M_AREARS_AMOUNT_Cutoff  = (@Arear_Calculated_Amount_Cutoff  * @M_AD_Percentage / 100)
												END
				  							
										END									
									ELSE	-- Ended by rohit on 01-apr-2014	
										BEGIN
											
											IF @IS_ROUNDING = 1                    
												SET @M_AREARS_AMOUNT_Cutoff  = ROUND((@Arear_Calculated_Amount_Cutoff  * @M_AD_Percentage / 100),0)
											ELSE
												SET @M_AREARS_AMOUNT_Cutoff  = (@Arear_Calculated_Amount_Cutoff  * @M_AD_Percentage / 100)
										END
										
								END
							
							IF  (@PF_DEF_ID = @AD_DEF_ID OR @Cmp_PF_DEF_ID = @AD_DEF_ID) OR (@ESIC_DEF_ID = @AD_DEF_ID OR @Cmp_ESIC_DEF_ID = @AD_DEF_ID)  --Added By Jimit 27052019 as case at WHFL Arear days calculation for Cut Off case not done for ESIc (disccusion done with Hardik bhai..)
								SET @M_AREARS_AMOUNT_Cutoff = ROUND(@M_AREARS_AMOUNT_Cutoff, 0)			
							-- ended by rohit on 13012015   
							
									---- Added by Hardik 26/05/2020 for Covid benefit on PF by Government
									--If Month(@Arear_Month) In (5,6,7) And Year(@Arear_Year)=2020 And @AD_DEF_ID in (@PF_DEF_ID,@Cmp_PF_DEF_ID)
									--	Begin
									--		Set @M_AD_Percentage = @M_AD_Percentage_Temp
									--	End


						END
					ELSE
						BEGIN										
							--PRINT  convert(varchar(20), getdate(), 114) + ' : STEP 8'
							

							DECLARE @AREAR_DATE DATETIME
							SET @AREAR_DATE = dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year);
							
							--Ankit/Hardikbhai --01072016
							DECLARE @IncrementIdArear NUMERIC
							SET @IncrementIdArear = 0
							
							SELECT	@IncrementIdArear = EI.Increment_ID
							FROM	T0095_Increment EI WITH (NOLOCK) INNER JOIN
								 ( SELECT MAX(TI.Increment_ID) Increment_Id FROM t0095_increment TI WITH (NOLOCK) INNER JOIN
										( SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date FROM T0095_Increment WITH (NOLOCK) 
											WHERE Increment_effective_Date <= @AREAR_DATE AND Cmp_ID=@Cmp_Id AND Emp_ID = @Emp_Id 
													AND Increment_Type <> 'Transfer' AND Increment_Type <> 'Deputation'
										) new_inc ON Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
									WHERE TI.Increment_effective_Date <= @AREAR_DATE AND Emp_ID = @Emp_Id 
												AND Increment_Type <> 'Transfer' AND Increment_Type <> 'Deputation'
								  ) qry on qry.Increment_Id  = EI.Increment_ID
							---  
							
							Select @Arear_Calculated_Amount = SUM(Qry1.E_AD_AMOUNT) from
								(
								select
									Case When Qry1.Increment_ID >= EED.Increment_ID Then
										Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
									Else
										eed.e_ad_Amount End As E_Ad_Amount
								from dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) 
											Inner Join T0050_AD_MASTER AM WITH (NOLOCK) on EED.AD_ID = Am.AD_ID And EED.CMP_ID = Am.CMP_ID 
											LEFT OUTER JOIN
											( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID
												From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
												( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
													Where Emp_Id = @Emp_Id
													And For_date <= @AREAR_DATE
												 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
											) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID                  
										Where --INCREMENT_ID = @increment_id And \\** Commented By Ramiz on 17062015 for Arrear Case , Guided by Rohit Bhai
										EED.EMP_ID = @Emp_Id AND Am.AD_ID = @AD_ID   
											----
											--And EED.For_date =( SELECT MAX(FOR_DATE) FROM T0100_EMP_EARN_DEDUCTION WHERE CMP_ID = @Cmp_ID --\\** Added By Ramiz on 17062015 for Arrear Case , Guided by Rohit Bhai
											--AND AD_ID = @AD_ID AND EMP_ID = @Emp_Id 
											--AND FOR_DATE <= @AREAR_DATE )
											----Above Code Comment by Ankit Due to arear amount calculate double while Increment & Transfer [Wcl Email Dated-01072016]
										And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
										AND EED.INCREMENT_ID = @IncrementIdArear --Ankit 01072016

								UNION ALL			

								SELECT E_Ad_Amount
									FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
										( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
											Where Emp_Id  = @Emp_Id And For_date <= @AREAR_DATE
											Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
									   INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK)  ON EEd.AD_ID = ADM.AD_ID                     
									WHERE emp_id = @emp_id 
											And Adm.AD_ACTIVE = 1
											And EEd.ENTRY_TYPE = 'A' AND ADM.AD_ID = @AD_ID 
											AND EED.Increment_ID = @IncrementIdArear
											
											) Qry1
							
							--IF @Arear_Days <> 0 AND @Arear_Calculated_Amount > 0 and UPPER(@varCalc_On) <> 'IMPORT'
							IF @Arear_Days <> 0 AND @Arear_Calculated_Amount <> 0 and ( UPPER(@varCalc_On) <> 'IMPORT' and UPPER(@varCalc_On) <> 'FIX' and UPPER(@varCalc_On) <> 'Security Deposit' and  UPPER(@varCalc_On)<> 'FORMULA') -- Formula added by rohit for Arear amount Not Calculate on Formula on 06012015 --Security Deposit added by rohit on 03-apr-2014  -- Changed by rohit on 27032014 for fix type allowance not calculate in arear days for polycab 
								--UPPER(@varCalc_On)<> 'FIX + JOINING PRORATE' and remove from condition for Feature #32190
								BEGIN
									--select 2,@AD_ID,@varCalc_On,@M_AREARS_AMOUNT,@Wages_type,@Arear_Days as 'Arear_Days',@Arear_Calculated_Amount as 'Arear_Calculated_Amount',@varCalc_On -- tejas	
									IF @Wages_type ='Monthly'
										BEGIN
											
											IF @IS_ROUNDING = 1
												BEGIN
													IF @Working_days_Arear > 0	--Ankit 30062014
														SET @M_AREARS_AMOUNT = ROUND((@Arear_Calculated_Amount/@Working_days_Arear)* @Arear_Days,0)
												End
												
											ELSE
												BEGIN
													IF @Working_days_Arear > 0	--Ankit 30062014
														SET @M_AREARS_AMOUNT = (@Arear_Calculated_Amount/@Working_days_Arear)* @Arear_Days	
												End
												
										End
									Else
										BEGIN
											IF @IS_ROUNDING = 1
												SET @M_AREARS_AMOUNT = ROUND((@Arear_Calculated_Amount)* @Arear_Days,0)
											ELSE
												SET @M_AREARS_AMOUNT = (@Arear_Calculated_Amount)* @Arear_Days
										End
									
									
							   END
							-- Added by rohit on 13012015										
							
							Else IF UPPER(@varCalc_On)='FORMULA' And @Arear_Days <> 0 --AND @Arear_Calculated_Amount <> 0	-- Added by Rajput on 06032018 Condition Was in CERA But Not Exist into Live / Version Project
								BEGIN	

							

									SET @Ad_Formula = ''
									select @Ad_Formula = Actual_AD_Formula from T0040_AD_Formula_Setting WITH (NOLOCK) where Cmp_Id=@cmp_Id and AD_ID=@AD_ID
									if Isnull(@Ad_Formula,'') <> ''
										BEGIN			
											DECLARE @Earning_Gross_Arear NUMERIC(18, 4)
											DECLARE @Formula_amount_Arear NUMERIC(18, 4)
											Declare @Salary_Cal_Day_Arear Numeric(18,2)	
											Declare @Out_Of_Days_Arr as Numeric(18,2)
											Declare @Formula_amount_Arr As Numeric(18,4)
											Declare @Salary_Amount_Arear Numeric(18,2)
											Declare @Present_Days_Arr Numeric(18,2)
											Declare @From_Date_Arear datetime
											Declare @Pre_Paid_Amount numeric(18,4)
											Declare @Absent_days_Arr Numeric(18,4)
											Declare @is_eligible_Arr tinyint

											SET @Earning_Gross_Arear = 0
											SET @Formula_amount_Arear = 0
											Set @Salary_Cal_Day_Arear=0
											Set @Formula_amount_Arr=0
											Set @Salary_Amount_Arear=0
											Set @Present_Days_Arr=0
											Set @Out_Of_Days_Arr=0
											Set @Pre_Paid_Amount=0
											Set @Absent_days_Arr=0
											Set @is_eligible_Arr=1

											If exists(select 1 From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) Where  Month(To_Date)=@Arear_Month And Year(To_Date)=@Arear_Year and emp_id=@emp_id And AD_ID=@Ad_Id)
												Begin 
													Select	@Earning_Gross_Arear= Gross_Salary, @Salary_Cal_Day_Arear=Sal_Cal_Days + Isnull(Present_on_Holiday,0) --+ Isnull(Present_on_Holiday,0) Added on 06032018 Arear Amount come Wrong Discuss with hardik bhai. 
														, @From_Date_Arear=Month_St_Date,
														@Out_Of_Days_Arr=Working_Days,@Absent_days_Arr=Absent_Days,
														@Salary_Amount_Arear=Salary_Amount, @Present_Days_Arr =Present_Days + Isnull(Present_on_Holiday,0) --+ Isnull(Present_on_Holiday,0) Added on 06032018 Arear Amount come Wrong Discuss with hardik bhai. 
													From T0200_MONTHLY_SALARY WITH (NOLOCK) 
													Where Emp_Id=@Emp_Id And Month(Month_End_Date)=@Arear_Month And Year(Month_End_Date)=@Arear_Year
													
													--Added By Jimit 23092019 As per case at WCl Arrear amount is not calculate in formula.
													set @Salary_Amount_Arear = @Salary_Amount_Arear + @Arear_Basic	
													set @Earning_Gross_Arear = @Earning_Gross_Arear + @Arear_Basic
													--Ended

													Select @Pre_Paid_Amount= M_AD_Amount
													From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) Where  Month(To_Date)=@Arear_Month And Year(To_Date)=@Arear_Year and emp_id=@emp_id And AD_ID=@Ad_Id

													Set @Salary_Cal_Day_Arear=@Salary_Cal_Day_Arear + @Arear_Days
													Set @Present_Days_Arr=@Present_Days_Arr + @Arear_Days

													If @Absent_days_Arr >= @Arear_Days
														Set @Absent_days_Arr=@Absent_days_Arr - @Arear_Days
												
													if exists (select 1 from T0040_AD_Formula_Eligible_Setting WITH (NOLOCK) where cmp_id = @cmp_id and ad_id = @ad_id)
														exec dbo.Check_Eligible_Formula_Wise  @Cmp_ID,@EMP_ID,@AD_ID,@From_Date_Arear,@Earning_Gross_Arear,@Salary_Cal_Day_Arear,@Out_Of_Days_Arr,@is_eligible_Arr output,@Absent_days_Arr,@Salary_Amount_Arear,@Arear_Days,@Present_Days_Arr

													

													If @is_eligible_Arr =1
														EXEC dbo.CALCULATE_AD_AMOUNT_Formula_WISE_Salary  @Cmp_ID=@Cmp_ID,@EMP_ID=@EMP_ID,@AD_ID=@AD_ID,@For_date=@From_Date_Arear,@Earning_Gross=@Earning_Gross_Arear,@Salary_Cal_Day=@Salary_Cal_Day_Arear,@Out_Of_Days=@Out_Of_Days_Arr,@Formula_amount=@Formula_amount_Arr output,@Earning_Basic=@Salary_Amount_Arear,@Present_Days=@Present_Days_Arr,@arrear_Day=@Arear_Days, @absent_days=@Absent_days_Arr,@To_Date = @To_Date,@Calculate_Arrear=0,@Night_Shift_Count = @Night_Shift_Count
												
													If Isnull(@Formula_amount_Arr,0)>0
														Set @Formula_amount_Arr = @Formula_amount_Arr -Isnull( @Pre_Paid_Amount,0)

													Set @M_AREARS_AMOUNT=round(@Formula_amount_Arr,0)

												End
											Else
												Begin
													Set @M_AREARS_AMOUNT=0
												End
										End
								
								End
								
								
								
							-- Added By Ramiz on 07/12/2015 ---
							IF @DA_DEF_ID = @AD_DEF_ID and Isnull(@Grade_Wise_Salary_Enabled,0) = 1			----DA Allowance Arrear Calculation (Mafatlal Client)
								BEGIN

							

									IF OBJECT_ID('tempdb..#DA_Allowance') IS NOT NULL 
										BEGIN
											DECLARE @DA_Arrear_Amount as Numeric(18,2)
											DECLARE @Arrear_Sal_Cal_Days as Numeric(18,2)
								
											If Exists( Select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@emp_id and cmp_id=@cmp_id AND Month_St_Date = dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year) and Month_End_Date = dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year) )
												BEGIN															
													SELECT @DA_Arrear_Amount = (isnull(M_Ad_Amount,0) + isnull(M_Arear_Amount,0)), @Arrear_Sal_Cal_Days = MS.Sal_Cal_Days
													FROM T0210_MONTHLY_AD_DETAIL MA WITH (NOLOCK)
														Inner JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MA.Emp_ID = MS.Emp_ID and MA.For_Date = MS.Month_St_Date
													WHERE MA.Emp_ID=@EMP_ID and MA.CMP_ID=@CMP_ID and 
														For_Date >= dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year) and 
														To_date <= dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year) and AD_ID = @AD_ID
												
															--Commented By Ramiz on 05/01/2015
																--If @Working_days_Arear > 0
																--		SET @M_AREARS_AMOUNT = ROUND((isnull(@DA_Arrear_Amount,0)/isnull(@Arrear_Sal_Cal_Days,0))* @Arear_Days,0)
																
																--Added By Ramiz on 05/01/2015 for Mafatlals---
																If @Working_days_Arear > 0 and @DA_Arrear_Amount > 0
																	BEGIN
																		SET @M_AREARS_AMOUNT = ROUND((isnull(@DA_Arrear_Amount,0)/isnull(@Arrear_Sal_Cal_Days,0))* @Arear_Days,0)
																	END
																ELSE
																	BEGIN
																		SELECT @M_AD_Amount = CASE WHEN @IS_ROUNDING = 1 THEN 
																				ROUND(SUM(ISNULL(DA_Allow_Salary,0)),0) 
																			ELSE 
																				SUM(ISNULL(DA_Allow_Salary,0))
																			END
																		FROM #DA_Allowance
																		
																		If @Working_days_Arear > 0 and @M_AD_Amount > 0
																			SET @M_AREARS_AMOUNT = ROUND((isnull(@M_AD_Amount,0)/isnull(@Salary_Cal_Day,0))* @Arear_Days,0)
																	END

													DELETE FROM #DA_Allowance
												END
											Else
												BEGIN
													IF EXISTS(SELECT 1 FROM #DA_ALLOWANCE)
														BEGIN
															SELECT @M_AD_Amount = CASE WHEN @IS_ROUNDING = 1 THEN 
																				ROUND(SUM(ISNULL(DA_Allow_Salary,0)),0) 
																			ELSE 
																				SUM(ISNULL(DA_Allow_Salary,0))
																			END
															FROM #DA_Allowance
															
															IF @Working_days_Arear > 0 and @M_AD_Amount > 0
																	SET @M_AREARS_AMOUNT = ROUND((isnull(@M_AD_Amount,0)/isnull(@Salary_Cal_Day,0))* @Arear_Days,0)
															
															DELETE FROM #DA_Allowance
														END
												END
										END		

									IF OBJECT_ID('tempdb..#EFFICIENCY_SALARY') IS NOT NULL 
										BEGIN
											IF EXISTS(SELECT 1 FROM #EFFICIENCY_SALARY)
												BEGIN
													SELECT @M_AD_Amount = SUM(ISNULL(DA_Allow_Salary,0)) FROM #EFFICIENCY_SALARY	
													DELETE FROM #EFFICIENCY_SALARY
												END
										END		
								END
							-- Ended By Ramiz on 07/12/2015 ---
							
							
							DECLARE @AREAR_CUTOFF_DATE DATETIME
							SET @AREAR_CUTOFF_DATE =dbo.GET_MONTH_END_DATE(@Arear_Month_cutoff,@Arear_Year_cutoff)
							
										
							IF @Actual_End_Date <> @AREAR_CUTOFF_DATE
								BEGIN
									Select 	@Arear_Calculated_Amount_Cutoff = SUM(Qry1.E_AD_AMOUNT) 
									FROM 	(
												SELECT	
													Case When Qry1.Increment_ID >= EED.Increment_ID Then
														Case When Qry1.E_AD_AMOUNT IS null Then eed.E_AD_AMOUNT Else Qry1.E_AD_AMOUNT End 
													Else
														eed.e_ad_Amount End As E_Ad_Amount
												FROM	dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) 
														INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) on EED.AD_ID = Am.AD_ID And EED.CMP_ID = Am.CMP_ID 
														LEFT OUTER JOIN ( 
																			Select	EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID
																			FROM	T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) 
																					INNER JOIN ( 
																								SELECT	Max(For_Date) For_Date, Ad_Id 
																								From	T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
																								Where	Emp_Id = @Emp_Id 
																										And For_date <= @AREAR_CUTOFF_DATE
																								Group by Ad_Id 
																								)Qry ON Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
																		) Qry1 ON eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID                  
												Where --INCREMENT_ID = @increment_id And --\\** Commented By Ramiz on 17062015 for Arrear Case , Guided by Rohit Bhai
													EED.EMP_ID = @Emp_Id AND AM.AD_ID = @AD_ID
														and EED.INCREMENT_ID = 
															( SELECT i.Increment_ID FROM T0095_INCREMENT i WITH (NOLOCK) INNER JOIN	--Ankit 23112015
																	( select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
																		( Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
																			Where EMP_ID = @Emp_Id AND Increment_effective_Date <= dbo.GET_MONTH_END_DATE(@Arear_Month_cutoff,@Arear_Year_cutoff) And Increment_Type<>'Transfer' AND Increment_Type <> 'Deputation' Group by emp_ID
																		 ) new_inc on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
																		Where  TI.Emp_ID = @Emp_Id AND TI.Increment_effective_Date <= dbo.GET_MONTH_END_DATE(@Arear_Month_cutoff,@Arear_Year_cutoff) And Increment_Type<>'Transfer' AND Increment_Type <> 'Deputation' group by ti.emp_id
																	) Qry on I.Increment_Id = Qry.Increment_Id
															)
														-- And EED.For_date = (SELECT MAX(FOR_DATE) FROM T0100_EMP_EARN_DEDUCTION 
													 	--		WHERE CMP_ID = @Cmp_ID AND AD_ID = @AD_ID AND EMP_ID = @Emp_Id 
														--		AND FOR_DATE <= @AREAR_CUTOFF_DATE) --\\** Added By Ramiz on 17062015 for Arrear Case , Guided by Rohit Bhai
													And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'

											UNION ALL			

											SELECT E_Ad_Amount
												FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
													( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
														Where Emp_Id  = @Emp_Id And For_date <= @AREAR_CUTOFF_DATE
														Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
												   INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK)  ON EEd.AD_ID = ADM.AD_ID                     
												WHERE emp_id = @emp_id 
														And Adm.AD_ACTIVE = 1
														And EEd.ENTRY_TYPE = 'A' AND ADM.AD_ID = @AD_ID 
														
														) Qry1

														
								END
							
							

							--- Added below portion by Hardik 09/09/2019 for Unison as they have given Increment on Jul-19 and Gross above 21000, so ESIC Rate is 0 so Cutoff ESIC not calculated..
							DECLARE @ESIC_Flag tinyint = 0				
	
							IF (@ESIC_DEF_ID = @AD_DEF_ID OR @Cmp_ESIC_DEF_ID = @AD_DEF_ID) AND @Arear_Calculated_Amount_Cutoff = 0 AND EXISTS (Select 1 From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) Where Month(To_Date)=Month(@AREAR_CUTOFF_DATE) And Year(To_Date)=Year(@AREAR_CUTOFF_DATE) And M_AD_Amount <>0 AND AD_ID=@AD_ID  And Emp_ID=@Emp_Id)
								BEGIN	

									SET @Arear_Calculated_Amount_Cutoff= @Salary_amount_Arear_cutoff + @Other_Allow_Amount_Arear_cutoff
									If @Arear_Calculated_Amount_Cutoff <> 0 
										BEGIN
											IF @IS_ROUNDING = 1
												SET @M_AREARS_AMOUNT_Cutoff = ROUND((@Arear_Calculated_Amount_Cutoff * @M_AD_Percentage )/100,0)
											ELSE
												SET @M_AREARS_AMOUNT_Cutoff = (@Arear_Calculated_Amount_Cutoff/@M_AD_Percentage )* @Absent_after_Cutoff_date
				
											Set @ESIC_Flag = 1
										END
								END
								
							
							--IF @Arear_Days <> 0 AND @Arear_Calculated_Amount > 0 and UPPER(@varCalc_On) <> 'IMPORT'
							IF @Absent_after_Cutoff_date <> 0 AND @Arear_Calculated_Amount_Cutoff <> 0 and ( UPPER(@varCalc_On) <> 'IMPORT' and UPPER(@varCalc_On) <> 'FIX' and UPPER(@varCalc_On) <> 'Security Deposit' and UPPER(@varCalc_On)<> 'FIX + JOINING PRORATE' and UPPER(@varCalc_On)<> 'FORMULA') AND @ESIC_Flag = 0 -- Formula added by rohit for Arear amount Not Calculate on Formula on 06012015 --Security Deposit added by rohit on 03-apr-2014  -- Changed by rohit on 27032014 for fix type allowance not calculate in arear days for polycab 
								BEGIN		
								
									IF @Wages_type ='Monthly'
										BEGIN
											
											IF @ESIC_DEF_ID = @AD_DEF_ID OR @Cmp_ESIC_DEF_ID = @AD_DEF_ID --- Added by Hardik 31/07/2018 for Ifedora, as ESIC not deducted in normal salary but ESIC deducting in Cutoff month amount
												BEGIN
													IF EXISTS (Select 1 From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) Where Month(To_Date)=Month(@AREAR_CUTOFF_DATE) And Year(To_Date)=Year(@AREAR_CUTOFF_DATE) And M_AD_Amount <>0 AND AD_ID=@AD_ID  And Emp_ID=@Emp_Id)
														BEGIN
															IF @IS_ROUNDING = 1
																BEGIN
																	IF @Working_days_Arear_cutoff  > 0
																		SET @M_AREARS_AMOUNT_Cutoff = ROUND((@Arear_Calculated_Amount_Cutoff/@Working_days_Arear_cutoff )* @Absent_after_Cutoff_date,0)
																End
																
															ELSE
																BEGIN
																	IF @Working_days_Arear_cutoff > 0
																		SET @M_AREARS_AMOUNT_Cutoff = (@Arear_Calculated_Amount_Cutoff/@Working_days_Arear_cutoff)* @Absent_after_Cutoff_date	
																End
															
														END
													ELSE
														BEGIN
															Set @M_AREARS_AMOUNT_Cutoff = 0
														END
												END
											ELSE
												BEGIN
													
													IF @IS_ROUNDING = 1
														BEGIN
															IF @Working_days_Arear_cutoff  > 0	--Ankit 30062014
																SET @M_AREARS_AMOUNT_Cutoff = ROUND((@Arear_Calculated_Amount_Cutoff/@Working_days_Arear_cutoff )* @Absent_after_Cutoff_date,0)
														End
														
													ELSE
														BEGIN
															IF @Working_days_Arear_cutoff > 0	--Ankit 30062014
																SET @M_AREARS_AMOUNT_Cutoff = (@Arear_Calculated_Amount_Cutoff/@Working_days_Arear_cutoff)* @Absent_after_Cutoff_date	
														End
														
												END
										End
									Else
										BEGIN
											
											IF @IS_ROUNDING = 1
												SET @M_AREARS_AMOUNT_Cutoff = ROUND((@Arear_Calculated_Amount_Cutoff)* @Absent_after_Cutoff_date,0)
											ELSE
												SET @M_AREARS_AMOUNT_Cutoff = (@Arear_Calculated_Amount_Cutoff)* @Absent_after_Cutoff_date
										End
								END

							

							IF @Upper_Round_Employer_ESIC = 0 AND @Cmp_ESIC_DEF_ID = @AD_DEF_ID
								SET @M_AREARS_AMOUNT_Cutoff = ROUND(@M_AREARS_AMOUNT_Cutoff,0)
							ELSE IF (@ESIC_DEF_ID = @AD_DEF_ID OR @Cmp_ESIC_DEF_ID = @AD_DEF_ID)
								BEGIN 
									if @M_AREARS_AMOUNT_Cutoff > 0
										SET @M_AREARS_AMOUNT_Cutoff = CEILING(@M_AREARS_AMOUNT_Cutoff)
									ELSE
										SET @M_AREARS_AMOUNT_Cutoff = FLOOR(@M_AREARS_AMOUNT_Cutoff)	--When Amount  is negative then value rounding value will be reversed.
								END
							
							

							-- ended by rohit on 13012015
						END					
						
					--select 	@M_AREARS_AMOUNT,@Arear_Calculated_Amount,@Out_Of_Days_Arear,@Arear_Days,@AD_ID
					SET @Arear_Calculated_Amount = 0
					SET @Arear_Calculated_Amount_Cutoff = 0 -- Added by rohit on 13012015
									
  
					----- End for Arear Calculation
				END -- Eligible End
			ELSE
				BEGIN
					SET @M_AD_Amount = 0
			END
			
		INSERT_RECORD:
		

			--PRINT CONVERT(VARCHAR(20), GETDATE(), 114)  + ' : INSERT_RECORD - START'
			
			SELECT @M_AD_Tran_ID = ISNULL(MAX(M_AD_Tran_ID),0) + 1 FROM dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)    
			
			IF @M_AD_Amount IS NULL
				SET @M_AD_Amount =0     

			--Hardik 04/12/2018 for Competent Client
			IF @AD_DEF_ID = @COMPANY_LWF_DEF_ID AND @Is_Emp_LWF = 0
				SET @M_AD_Amount = 0
						
			DECLARE @temp_AD_Not_Effect_salary Numeric(22,5)
			SET @temp_AD_Not_Effect_salary = 0
			    
					
					
			IF EXISTS (SELECT Sal_Tran_ID FROM dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) WHERE  Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND AD_ID = @AD_ID AND For_Date = @Actual_Start_Date)
				BEGIN
					
					--Commented by Hardik 22/06/2020 as no required to enable and disable trigger.. condition added in Trigger

					--IF @Allowance_type = 'R' OR @AD_DEF_ID  = @GPF_DEF_ID -- Added by Hardik 18/12/2015 for Speed
					--	alter table dbo.T0210_MONTHLY_AD_DETAIL  ENABLE trigger Tri_T0210_MONTHLY_AD_DETAIL
					--Else
					--	alter table dbo.T0210_MONTHLY_AD_DETAIL  Disable trigger Tri_T0210_MONTHLY_AD_DETAIL
							
						
					----- START For get allowance total in arears calculation ---
					SELECT @temp_AD_Not_Effect_salary = ISNULL(AD_Not_effect_salary,0)  FROM dbo.T0050_AD_MASTER WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID AND AD_ID = @AD_ID
								
					IF @temp_AD_Not_Effect_salary = 0 AND @M_AD_Flag = 'I'
						BEGIN
							SET @Total_M_AD_Amount_Arears = ISNULL(@Total_M_AD_Amount_Arears,0) + ISNULL(@M_AD_Amount,0)
						END
							
					----- End For get allowance total in arears calculation ---
						
					DECLARE @temp_AD_Amt NUMERIC(18,3)
							
					SELECT   @temp_AD_Amt = M_AD_Amount FROM dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) WHERE  Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND AD_ID = @AD_ID AND For_Date = @Actual_Start_Date
					-------added by Hasmukh 22082013-------------
					----''Comment for fix allowance Calculate on Mid Increment --Ankit  04072014
					----''Uncomment For Mid-Increment Fix allowance amount calculate Double  ---Ankit 19022015												
					If (@varCalc_On = 'Fix' or @varCalc_On = 'Security Deposit' OR @varCalc_On = 'Slab Wise' OR  UPPER(@varCalc_On) = 'FIX + JOINING PRORATE')-- Security deposit added by rohit on 03-apr-2014,,-- Slab Wise Set 0 due Mid-Increment case it cal Double ----Ankit 27022015
						BEGIN  
							SET @temp_AD_Amt = 0
						end
					
						
					--Added By Mukti(start)02012017 for Mid Increment Allowance amount > Max_Upper_Limit_Amount than set Max_Upper amount 
					IF @M_AD_Amount + isnull(@temp_AD_Amt,0) > Isnull(@Max_Upper,0) And Isnull(@Max_Upper,0)>0
						BEGIN
							SET @M_AD_Amount = @Max_Upper
							Set @temp_AD_Amt=0
						END
					--Added By Mukti(end)02012017
								
					--IF @varCalc_On = 'Security Deposit' -- Security deposit added by rohit on 03-apr-2014
					--	BEGIN 
					--		SET @temp_AD_Amt = 0
					--	end
					
												
					-------added by Hasmukh 22082013-------------
					---Hardik 07/02/2013 for Check PF Max Limit for Multiple Increment	
					IF @PF_DEF_ID = @AD_DEF_ID OR @Cmp_PF_DEF_ID = @AD_DEF_ID And @M_AD_Percentage > 0 -- Added Percentage condition by Hardik 04/08/2020 for Iconic for mid increment case and they have no percent for PF
						BEGIN               														    
							SET @PF_Max_Amount = Round((@PF_LIMIT * @M_AD_Percentage /100),0)
							IF  @Emp_Full_PF = 0 AND @PF_LIMIT > 0 AND (@temp_AD_Amt + @M_AD_Amount) > @PF_Max_Amount
								BEGIN
									SET @Calc_On_Allow_Dedu = @PF_Limit                    
									SET @M_AD_Amount = @PF_Max_Amount
									SET @temp_AD_Amt = 0
											
									UPDATE	dbo.T0210_MONTHLY_AD_DETAIL  
									SET		M_AD_Calculated_Amount = 0
									WHERE	AD_ID = @AD_ID AND Emp_id = @Emp_Id AND For_Date = @Actual_Start_Date
								End
						END   
						
					IF NOT @varCalc_On = 'Import' 
						BEGIN									
							UPDATE	dbo.T0210_MONTHLY_AD_DETAIL  
							SET		M_AD_Percentage=@M_AD_Percentage, 
									M_AD_Amount = --@temp_AD_Amt + @M_AD_Amount, 
												  CASE WHEN @PF_DEF_ID = @AD_DEF_ID OR @Cmp_PF_DEF_ID = @AD_DEF_ID OR (@IS_ROUNDING = 1 AND @No_Of_Increment > 1) THEN  
															ROUND(@temp_AD_Amt + @M_AD_Amount,0)
													   WHEN @ESIC_DEF_ID = @AD_DEF_ID OR @Cmp_ESIC_DEF_ID = @AD_DEF_ID THEN
															CEILING(@temp_AD_Amt + @M_AD_Amount)	
													   ELSE
															@temp_AD_Amt + @M_AD_Amount
												  END,
									M_AD_Flag = @M_AD_Flag , M_AD_Actual_Per_Amount = CASE WHEN @M_AD_Percentage = M_AD_Percentage And @M_AD_Percentage>0 THEN @M_AD_Percentage ELSE  M_AD_Actual_Per_Amount + @M_AD_Actual_Per_Amount END ,                     
									M_AD_Calculated_Amount = M_AD_Calculated_Amount + @Calc_On_Allow_Dedu,M_AD_NOT_EFFECT_ON_PT = @M_AD_NOT_EFFECT_ON_PT , 
									M_AD_EFFECT_ON_EXTRA_DAY = @M_AD_EFFECT_ON_EXTRA_DAY,SAL_TYPE = 0,M_AD_effect_on_Late = @M_AD_effect_on_Late,
									--M_AREAR_AMOUNT = 0 ,M_AREAR_AMOUNT_Cutoff = 0   --Commented by Hardik 26/09/2016 as Ami life science has issue in Mid Increment and Arear days case in same month, Arear Amount making zero so set variables
									M_AREAR_AMOUNT = isnull(@M_AREARS_AMOUNT,0) ,M_AREAR_AMOUNT_Cutoff = Isnull(@M_AREARS_AMOUNT_Cutoff,0) --Hardik 26/09/2016 as Ami life science has issue in Mid Increment and Arear days case in same month, Arear Amount making zero so set variables
							WHERE	AD_ID = @AD_ID AND Emp_id = @Emp_Id AND For_Date = @Actual_Start_Date
					
							if @AutoPaid = 1 
								BEGIN
									IF (@AD_CAL_TYPE = 'Monthly')
											OR(@AD_CAL_TYPE = 'Quaterly' AND (Month(@From_Date) = 3  or 	Month(@From_Date) = 6 or Month(@From_Date) = 9 or Month(@From_Date) = 12))
									        OR(@AD_CAL_TYPE = 'Half Yearly' AND ((Month(@From_Date) = 3 and year(@From_Date) = Year(DATEADD(YEAR,0,@From_Date))) or Month(@From_Date) = 9 ))
									        OR(@AD_CAL_TYPE = 'Yearly' and ((Month(@From_Date) = 3 and year(@From_Date) = Year(DATEADD(YEAR,0,@From_Date)))))						
											BEGIN
										
													UPDATE	T0210_MONTHLY_Reim_DETAIL
													SET		Taxable = CASE WHEN @PF_DEF_ID = @AD_DEF_ID OR @Cmp_PF_DEF_ID = @AD_DEF_ID THEN  
																					ROUND(@temp_AD_Amt + @M_AD_Amount,0)
																			   WHEN @ESIC_DEF_ID = @AD_DEF_ID OR @Cmp_ESIC_DEF_ID = @AD_DEF_ID THEN
																					CEILING(@temp_AD_Amt + @M_AD_Amount)	
																			   ELSE
																					@temp_AD_Amt + @M_AD_Amount
																		  END
													WHERE	RC_ID = @AD_ID AND Emp_id = @Emp_Id AND For_Date = @Actual_Start_Date
																	
													UPDATE	dbo.T0210_MONTHLY_AD_DETAIL  
													SET		ReimAmount = ReimAmount + M_AD_Amount									
													WHERE	AD_ID = @AD_ID AND Emp_id = @Emp_Id AND For_Date = @Actual_Start_Date
											END
								END
						END

						
									   
				END           
			ELSE
				BEGIN
					----- START For get allowance total in arears calculation ---
							
					SET @temp_AD_Not_Effect_salary = 0
					SELECT @temp_AD_Not_Effect_salary = ISNULL(AD_Not_effect_salary,0)  FROM dbo.T0050_AD_MASTER WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID AND AD_ID = @AD_ID
																			
					IF @temp_AD_Not_Effect_salary = 0 AND @M_AD_Flag = 'I'
						BEGIN
							SET @Total_M_AD_Amount_Arears = ISNULL(@Total_M_AD_Amount_Arears,0) + ISNULL(@M_AD_Amount,0)
							SET @Total_M_AD_Amount_Arears_cutoff  = ISNULL(@Total_M_AD_Amount_Arears_cutoff ,0) + ISNULL(@M_AD_Amount,0)
						END
					----- End For get allowance total in arears calculation ---
					
					-- Added by rohit on 13012015
					--IF @temp_AD_Not_Effect_salary = 0 AND @M_AD_Flag = 'I'
					--	BEGIN
					--		SET @Total_M_AD_Amount_Arears_cutoff  = ISNULL(@Total_M_AD_Amount_Arears_cutoff ,0) + ISNULL(@M_AD_Amount,0)
					--	END
					-- Ended by rohit on 13012015
								
                   
                    IF @Allowance_type ='R'
						BEGIN	     
							
							DECLARE @RC_apR_ID numeric
							DECLARE @Taxable_amount NUMERIC(18, 4)
							DECLARE @Non_Taxable_amount NUMERIC(18, 4)
							
							SET @Taxable_amount =0
							SET @Non_Taxable_amount =0
							
							---Ripal 07July2014 Start
							IF @Setting_Value = 1 And @AD_DEF_ID = 9  -- 9 for Medical Reimbursement
								BEGIN
									DECLARE CURSOR_RC CURSOR FOR 
									select ISNULL(Apr_amount,0),RC_APR_ID, 
							    	Taxable_Exemption_Amount,Apr_Amount									
									from T0120_RC_Approval WITH (NOLOCK)
									where  --MONTH(@From_Date)=mONTH(Payment_date) AND YEAR(@From_Date)=yEAR(Payment_date)
									--Payment_date between @From_Date and @To_Date --18Sep2014    --- Commented by hardik 18/08/2015
									Payment_date between @Actual_Start_Date and @Actual_End_Date --Added this condition by Hardik 18/08/2015 because problem when Mid month increment and payment date is coming after new increment date
									AND Emp_ID=@Emp_ID AND rc_id=@Ad_ID AND Cmp_Id=@Cmp_ID AND 
									ISNULL(RC_Apr_Effect_In_Salary,0) = 1 AND APR_Status =1
								end
							else
								BEGIN
						
										DECLARE CURSOR_RC CURSOR FOR 
										select (ISNULL(Apr_amount,0) + ISNULL(Taxable_Exemption_Amount,0)),RC_APR_ID, 
								    	Taxable_Exemption_Amount,Apr_Amount									
										from T0120_RC_Approval WITH (NOLOCK)
										where  --MONTH(@From_Date)=mONTH(Payment_date) AND YEAR(@From_Date)=yEAR(Payment_date)
										--Payment_date between @From_Date and @To_Date --18Sep2014    --- Commented by hardik 18/08/2015
										Payment_date between @Actual_Start_Date and @Actual_End_Date --Added this condition by Hardik 18/08/2015 because problem when Mid month increment and payment date is coming after new increment date
									   AND Emp_ID=@Emp_ID AND rc_id=@Ad_ID AND Cmp_Id=@Cmp_ID AND 
									   ISNULL(RC_Apr_Effect_In_Salary,0) = 1 AND APR_Status =1
								end
									
							OPEN CURSOR_RC
							FETCH NEXT FROM CURSOR_RC into @M_AD_Approval_Amount,@RC_apR_ID,@Taxable_amount,@Non_Taxable_amount
							WHILE @@FETCH_STATUS = 0
								BEGIN		
								
									SET @ReimShow = 1
									IF @Setting_Value = 1
										BEGIN
											INSERT INTO T0210_MONTHLY_Reim_DETAIL (
											Cmp_ID,
											Emp_ID,
											RC_ID,
											RC_apr_ID,										
											Temp_Sal_tran_ID,
											Sal_tran_ID,
											for_Date,
											Amount,
											Taxable,
											Tax_Free_amount)
											VALUES(@cmp_ID,@Emp_ID,@Ad_ID,@RC_apR_ID,@Sal_Tran_ID,NULL,@Actual_Start_Date,@M_AD_Amount,0,@Non_Taxable_amount)
										end
									else
										BEGIN
										
											----------------Nilay18062014---------------------
											INSERT INTO T0210_MONTHLY_Reim_DETAIL (
												Cmp_ID,
												Emp_ID,
												RC_ID,
												RC_apr_ID,										
												Temp_Sal_tran_ID,
												Sal_tran_ID,
												for_Date,
												Amount,
												Taxable,
												Tax_Free_amount)
											VALUES(@cmp_ID,@Emp_ID,@Ad_ID,@RC_apR_ID,@Sal_Tran_ID,NULL,@Actual_Start_Date,@M_AD_Amount,@Taxable_amount,@Non_Taxable_amount)
											 ----------------Nilay18062014---------------------
										end
										--Commented by Hardik 22/06/2020 as no required to enable and disable trigger.. condition added in Trigger
										--IF @Allowance_type = 'R' OR @AD_DEF_ID  = @GPF_DEF_ID -- Added by Hardik 18/12/2015 for Speed
										--	ALTER TABLE dbo.T0210_MONTHLY_AD_DETAIL  ENABLE trigger Tri_T0210_MONTHLY_AD_DETAIL
										--Else
										--	ALTER TABLE dbo.T0210_MONTHLY_AD_DETAIL  Disable trigger Tri_T0210_MONTHLY_AD_DETAIL
									

									
										INSERT INTO dbo.T0210_MONTHLY_AD_DETAIL                    
											  (M_AD_Tran_ID, Sal_Tran_ID,Temp_Sal_Tran_ID ,L_Sal_Tran_ID,Emp_ID, Cmp_ID, AD_ID, For_Date, M_AD_Percentage, M_AD_Amount, M_AD_Flag, M_AD_Actual_Per_Amount,                     
											   M_AD_Calculated_Amount,M_AD_NOT_EFFECT_ON_PT,M_AD_NOT_EFFECT_SALARY,M_AD_EFFECT_ON_OT,M_AD_EFFECT_ON_EXTRA_DAY,SAL_TYPE,M_AD_effect_on_Late,M_AREAR_AMOUNT,To_date, Split_Shift_Count, Split_Shift_Date,Reimshow,ReimAmount,M_AREAR_AMOUNT_Cutoff)
			                    
										VALUES     (@M_AD_Tran_ID, NULL,@Sal_Tran_ID,@L_Sal_Tran_ID, @Emp_ID, @Cmp_ID, @AD_ID, @Actual_Start_Date, @M_AD_Percentage, @M_AD_Amount, @M_AD_Flag, @M_AD_Actual_Per_Amount,                     
											   @Calc_On_Allow_Dedu,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY,0,@M_AD_effect_on_Late,@M_AREARS_AMOUNT,@Actual_End_Date,@Split_Shift_Count, @Split_Shift_Date,@ReimShow,@M_AD_Approval_Amount,isnull(@M_AREARS_AMOUNT_Cutoff,0))                    							
										
										IF @Setting_Value = 1  -- Added by Gadriwala Muslim 04072015
											BEGIN													
												ALTER TABLE dbo.T0210_MONTHLY_AD_DETAIL  Disable trigger Tri_T0210_MONTHLY_AD_DETAIL
												
												Update	T0210_MONTHLY_AD_DETAIL  
												set		ReimAmount = isnull(RTP.Debit,0), ReimShow = 1 
												from	T0210_MONTHLY_AD_DETAIL MAD inner join
														T0140_ReimClaim_Transacation_Payment_Monthly RTP on MAD.Temp_Sal_Tran_ID = RTP.Sal_Trans_ID and RTP.Claim_ID = MAD.AD_ID
												where	MAD.Temp_Sal_Tran_ID = @Sal_Tran_ID and MAD.Emp_ID = @Emp_Id and MAD.Cmp_ID = @Cmp_ID and MAD.AD_ID = @AD_ID
													
												alter table dbo.T0210_MONTHLY_AD_DETAIL  Enable trigger Tri_T0210_MONTHLY_AD_DETAIL
											end
							   
										SELECT @M_AD_Tran_ID = ISNULL(MAX(M_AD_Tran_ID),0) + 1 FROM dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) 
										
										FETCH NEXT FROM CURSOR_RC  into @M_AD_Approval_Amount,@RC_apR_ID,@Taxable_amount,@Non_Taxable_amount
								END
							Close CURSOR_RC
							Deallocate CURSOR_RC
							---Ripal 07July2014 End
								
							-- SELECT @AD_ID, ISNULL(SUM(ISNULL(M_AD_AMOUNT,0)),0) FROM dbo.T0210_MONTHLY_AD_DETAIL WHERE For_Date >= DATEADD(m,-2,@From_Date) AND For_Date <= @To_Date AND Emp_ID=@EMP_id AND Ad_ID = @Ad_ID AND isnull(ReimShow,0) =0									  									  									
							DECLARE @MyDate DATETIME
							SET @MyDate = @from_Date

							DECLARE @StartDate DATETIME
							DECLARE @EndDate DATETIME
							SET @StartDate = DATEADD(dd,0, DATEDIFF(dd,0, DATEADD( mm, -(((12 + DATEPART(m, @MyDate)) - 4)%12), @MyDate ) - datePart(d,DATEADD( mm, -(((12 + DATEPART(m, @MyDate)) - 4)%12),@MyDate ))+1 ) )
								
											
							IF @AutoPaid = 1
								BEGIN
									DECLARE @Balance as NUMERIC(18, 4)
									SET @Balance = 0
									--select @From_Date,Year(DATEADD(YEAR,1,@From_Date))
					
									IF @AD_CAL_TYPE = 'Quaterly' AND (Month(@From_Date) = 3  or 	Month(@From_Date) = 6 or Month(@From_Date) = 9 or Month(@From_Date) = 12)						
										BEGIN		
											IF @Setting_Value = 1
												BEGIN
													select	@Balance = isnull(Balance,0) from T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK)
													where	for_date = (
																		select	max(for_date) 
																		from	T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK) 
																		where	for_date < @From_Date and Claim_Id = @Ad_ID and cmp_ID = @cmp_ID and emp_id = @emp_Id 
																	) 
															and cmp_ID = @cmp_ID and Claim_Id = @Ad_ID  and emp_id = @emp_Id
			    										
													IF @Balance is null
														SET @Balance = 0
													
													SELECT @M_AD_Approval_Amount=@M_AD_Amount + ISNULL(SUM(ISNULL(M_AD_AMOUNT,0)),0) FROM dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) WHERE For_Date >= DATEADD(m,-2,@From_Date) AND For_Date <= @To_Date AND Emp_ID=@EMP_id AND Ad_ID = @Ad_ID 									  									  									
													SELECT @M_AD_Approval_Amount= @M_AD_Approval_Amount - (ISNULL(SUM(ISNULL(M_AD_AMOUNT,0)),0) + @Balance) FROM dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) WHERE For_Date >= DATEADD(m,-2,@From_Date) AND For_Date <= @To_Date AND Emp_ID=@EMP_id AND Ad_ID = @Ad_ID AND isnull(ReimShow,0) =1									  									  									
													
													IF @M_AD_Approval_Amount < 0
														SET @M_AD_Approval_Amount = 0 
													
													SET @ReimShow = 1
												end
											else	
												BEGIN							
													SELECT @M_AD_Approval_Amount=@M_AD_Amount + ISNULL(SUM(ISNULL(M_AD_AMOUNT,0)),0) FROM dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) WHERE For_Date >= DATEADD(m,-2,@From_Date) AND For_Date <= @To_Date AND Emp_ID=@EMP_id AND Ad_ID = @Ad_ID AND isnull(ReimShow,0) =0									  									  									
													SET @ReimShow = 1
												end
										END 
								
								 
									ELSE IF @AD_CAL_TYPE = 'Monthly'
										BEGIN																			 		
											SET @M_AD_Approval_Amount=@M_AD_Amount
											SET @ReimShow = 1									  									 
										END
								
								 									 
									ELSE IF @AD_CAL_TYPE = 'Half Yearly' AND ((Month(@From_Date) = 3 and year(@From_Date) = Year(DATEADD(YEAR,0,@From_Date))) or Month(@From_Date) = 9 )
										BEGIN
											IF @Setting_Value = 1
													BEGIN
														select @Balance = isnull(Balance,0) from T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK)
														where for_date = (select max(for_date) from T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK) 
														where for_date < @From_Date and Claim_Id = @Ad_ID and cmp_ID = @cmp_ID and emp_id = @emp_Id ) 
														and cmp_ID = @cmp_ID and Claim_Id = @Ad_ID  and emp_id = @emp_Id
					    										
														IF @Balance is null
														SET @Balance = 0
	    												
														SELECT @M_AD_Approval_Amount=@M_AD_Amount + ISNULL(SUM(ISNULL(M_AD_AMOUNT,0)),0) FROM dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) WHERE For_Date >= DATEADD(m,-5,@From_Date) AND For_Date <= @To_Date AND Emp_ID=@EMP_id	AND Ad_ID = @Ad_ID 
														SELECT @M_AD_Approval_Amount= @M_AD_Approval_Amount - (ISNULL(SUM(ISNULL(ReimAmount,0)),0) + @Balance) FROM dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) WHERE For_Date >= DATEADD(m,-5,@From_Date) AND For_Date <= @To_Date AND Emp_ID=@EMP_id	AND Ad_ID = @Ad_ID  AND isnull(ReimShow,0) =1 
														IF @M_AD_Approval_Amount < 0
															SET @M_AD_Approval_Amount = 0 
														SET @ReimShow = 1
													end
												else
													BEGIN
										
															SELECT @M_AD_Approval_Amount=@M_AD_Amount + ISNULL(SUM(ISNULL(M_AD_AMOUNT,0)),0) FROM dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) WHERE For_Date >= DATEADD(m,-5,@From_Date) AND For_Date <= @To_Date AND Emp_ID=@EMP_id	AND Ad_ID = @Ad_ID AND isnull(ReimShow,0) =0
															SET @ReimShow = 1
													end
										END 
								
								 
									ELSE IF @AD_CAL_TYPE = 'Yearly' and ((Month(@From_Date) = 3 and year(@From_Date) = Year(DATEADD(YEAR,0,@From_Date))) )
										BEGIN
											IF @Setting_Value = 1
												BEGIN
												
														
													select @Balance = isnull(Balance,0) from T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK)
													where for_date = (select max(for_date) from T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK) 
													where for_date < @From_Date and Claim_Id = @Ad_ID and cmp_ID = @cmp_ID and emp_id = @emp_Id ) 
													and cmp_ID = @cmp_ID and Claim_Id = @Ad_ID  and emp_id = @emp_Id
				    										
													IF @Balance is null
													SET @Balance = 0
    													
													SET @EndDate = DATEADD(ss,-1,DATEADD(mm,12,@StartDate ))
													
													If Not EXISTS( SELECT 1 From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) where Emp_id = @Emp_Id And For_Date >= @Actual_Start_Date And For_Date <= @Actual_End_date And Ad_Id = @AD_Id)
														BEGIN
															SELECT @M_AD_Approval_Amount= @M_AD_Amount + ISNULL(SUM(ISNULL(M_AD_AMOUNT,0)),0) + ISNULL(SUM(ISNULL(M_AREAR_AMOUNT,0)),0) 
															FROM dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) WHERE For_Date >= @StartDate AND For_Date <= @EndDate AND Emp_ID=@EMP_id AND Ad_ID = @Ad_ID  
														END
													Else
														BEGIN
															SELECT @M_AD_Approval_Amount= ISNULL(SUM(ISNULL(M_AD_AMOUNT,0)),0) + ISNULL(SUM(ISNULL(M_AREAR_AMOUNT,0)),0) 
															FROM dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) WHERE For_Date >= @StartDate AND For_Date <= @EndDate AND Emp_ID=@EMP_id AND Ad_ID = @Ad_ID  
														END
													
													SELECT @M_AD_Approval_Amount = @M_AD_Approval_Amount - (ISNULL(SUM(ISNULL(ReimAmount,0)),0) + @Balance) 
													FROM dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) WHERE For_Date >= @StartDate AND For_Date <= @EndDate AND Emp_ID=@EMP_id AND Ad_ID = @Ad_ID  AND isnull(ReimShow,0) =1 
													
													IF @M_AD_Approval_Amount < 0
														SET @M_AD_Approval_Amount = 0 
													SET @ReimShow = 1
													
												end
											else
												BEGIN							
													SET @EndDate = DATEADD(ss,-1,DATEADD(mm,12,@StartDate ))
													
													
													-- Comment and Add by rohit For Auto paid remaining amount of Reimbershement on 17032016
													--SELECT @M_AD_Approval_Amount= @M_AD_Amount + ISNULL(SUM(ISNULL(M_AD_AMOUNT,0)),0) FROM dbo.T0210_MONTHLY_AD_DETAIL WHERE For_Date >= @StartDate AND For_Date <= @EndDate AND Emp_ID=@EMP_id AND Ad_ID = @Ad_ID	  AND isnull(ReimShow,0) =0
													
													select top 1 @M_AD_Approval_Amount = isnull(Reim_Closing,0) + isnull(@M_AD_Amount,0)  from T0140_ReimClaim_Transacation WITH (NOLOCK) where Emp_ID=@EMP_id and RC_ID=@AD_ID and for_date <= @EndDate order by For_Date desc
													--Change By Jaina 07-10-2016 As per discuss with Hardikbhai No need to add M_AD_Amount
													--select top 1 @M_AD_Approval_Amount = isnull(Reim_Closing,0) from T0140_ReimClaim_Transacation where Emp_ID=@EMP_id and RC_ID=@AD_ID and for_date <= @EndDate order by For_Date desc																																							
													SET @ReimShow = 1
													
													
												end
										END 
									ELSE
										BEGIN
											SET @M_AD_Approval_Amount = 0 
										END
										--- Added by Hardik 07/01/2016 as Autopaid amount should insert in this table while salary process

										

										If Isnull(@M_AD_Approval_Amount,0) >0 
											BEGIN
												INSERT INTO T0210_MONTHLY_Reim_DETAIL (
																Cmp_ID,
																Emp_ID,
																RC_ID,
																RC_apr_ID,										
																Temp_Sal_tran_ID,
																Sal_tran_ID,
																for_Date,
																Amount,
																Taxable,
																Tax_Free_amount)
												VALUES(@cmp_ID,@Emp_ID,@Ad_ID,Null,@Sal_Tran_ID,NULL,@Actual_Start_Date,0,@M_AD_Approval_Amount,0)
												
												--Set @M_AD_Approval_Amount = 0  -- Commenet by rohit Due to amount not shows in salary slip on 17032016


											END
											
										--- End by Hardik 07/01/2016
								
								END
                      		
													
						END

						-- Added by Hardik 28/03/2018 for Inductotherm as they applied negative claim and Auto paid. So negative amount should not claim as autopaid
						if Isnull(@M_AD_Approval_Amount,0) < 0 
							Set @M_AD_Approval_Amount = 0
					

					IF @AD_DEF_ID = 10 --added by Hardik 25/06/2014 for Admin charge for BMA
						BEGIN
							DECLARE @AC_2_3 as Numeric(18,3)
							DECLARE @AC_22_3 as Numeric(18,3)
							DECLARE @AC_21_1 as Numeric(18,3)
							DECLARE @AC_2_3_Amount as NUMERIC(18, 4)
							DECLARE @AC_22_3_Amount as NUMERIC(18, 4)
							DECLARE @AC_21_1_Amount as NUMERIC(18, 4)

							SET @AC_2_3 = 0
							SET @AC_22_3 = 0
							SET @AC_21_1 = 0
							SET @PF_Limit = 0
							SET @AC_2_3_Amount = 0
							SET @AC_22_3_Amount = 0
							SET @AC_21_1_Amount = 0

							Select Top 1 @AC_2_3 =ACC_2_3, @AC_22_3 = ACC_22_3,
								@AC_21_1 =ACC_21_1, @PF_Limit = PF_LIMIT
							from T0040_General_setting gs WITH (NOLOCK) inner join     
								T0050_General_Detail gd WITH (NOLOCK) on gs.gen_Id =gd.gen_ID     
							where gs.Cmp_Id=@cmp_Id and Branch_ID = isnull(@Branch_ID,Branch_ID)    
							and For_Date in (select max(For_Date) from T0040_General_setting  g inner join     
											T0050_General_Detail d on g.gen_Id =d.gen_ID       
											where g.Cmp_Id=@cmp_Id and Branch_ID = isnull(@Branch_ID,Branch_ID))    							

				  
							IF @Emp_Auto_VPF = 1
								SET @AC_2_3_Amount = @Calc_On_Allow_Dedu * @AC_2_3 /100									
							else
								IF @Calc_On_Allow_Dedu > @PF_Limit
									SET @AC_2_3_Amount = @PF_Limit * @AC_2_3 /100
								else
									SET @AC_2_3_Amount = @Calc_On_Allow_Dedu * @AC_2_3 /100									
							
							-- Commented by Hardik 04/01/2021 for Nepra client as A/c 21 is always calculate in 15000 limit
							--IF @Emp_Auto_VPF = 1
							--	SET @AC_21_1_Amount = @Calc_On_Allow_Dedu * @AC_21_1/100
							--else
								IF @Calc_On_Allow_Dedu > @PF_Limit
									SET @AC_21_1_Amount = Round(@PF_Limit * @AC_21_1/100,0)
								Else
									SET @AC_21_1_Amount = Round(@Calc_On_Allow_Dedu * @AC_21_1/100,0)

							IF @Emp_Auto_VPF = 1
								SET @AC_22_3_Amount = @Calc_On_Allow_Dedu * @AC_22_3/100
							else
								IF @Calc_On_Allow_Dedu > @PF_Limit
									SET @AC_22_3_Amount = Round(@PF_Limit * @AC_22_3/100,0)
								Else
									SET @AC_22_3_Amount = Round(@Calc_On_Allow_Dedu * @AC_22_3/100,0)
							
							IF @IS_ROUNDING = 1	
								SET @M_AD_AMOUNT = Round(Isnull(@AC_2_3_Amount,0) + Isnull(@AC_21_1_Amount,0) + Isnull(@AC_22_3_Amount,0),0)
							Else
								SET @M_AD_AMOUNT = Isnull(@AC_2_3_Amount,0) + Isnull(@AC_21_1_Amount,0) + Isnull(@AC_22_3_Amount,0)
						End
					--- End by Hardik 25/06/2014 for Admin Charge for BMA
					
					--Added by nilesh patel for Car Retention Allowance 13012017
					If @AD_DEF_ID = @CAR_RETENTION_DEF_ID	
						Begin
						
							Declare @Car_Retention Numeric(18,4)
							Declare @Car_Month Numeric(18,0)
							Declare @Effective_Date DateTime

							Set @Car_Retention = 0
							Set @Car_Month = 0
							Set @Effective_Date = NULL
							
							Select @Car_Retention = CR.AD_Amount,@Car_Month = CR.No_of_Month,@Effective_Date = CR.Effective_Date 
							From T0110_Car_Retention CR WITH (NOLOCK) Inner Join
								( Select Max(Effective_Date) as EffectiveDate,Emp_ID,AD_ID
									From T0110_Car_Retention WITH (NOLOCK) Where AD_ID = @AD_ID and Emp_ID = @Emp_ID and Effective_Date <= @To_Date
									Group by Emp_ID,AD_ID
								) As qry
							On Qry.EffectiveDate = CR.Effective_Date and Qry.Emp_ID = CR.Emp_ID and Qry.AD_ID = CR.AD_ID
							Where CR.Emp_ID = @Emp_ID and CR.AD_ID = @AD_ID

							Declare @AD_Ded_Count Numeric(18,0)
							Set @AD_Ded_Count = 0
							
							if @Effective_Date is not NULL 
								Begin
									Select @AD_Ded_Count = Count(1) From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
									Where AD_ID = @AD_ID and Emp_ID = @Emp_ID and M_AD_Amount > 0 
									and To_date >= @Effective_Date
								End
							
							if @AD_Ded_Count < @Car_Month
								Begin
									SET @M_AD_Amount = @Car_Retention
								End
							Else
								Begin
									SET @M_AD_Amount = 0
								End
						End 
						
					
					
					--Added by nilesh patel for Car Retention Allowance 13012017 
					--Hardik 25/06/2014 for Check Max Limit
					IF @M_AD_Amount > Isnull(@Max_Upper,0) And Isnull(@Max_Upper,0)>0
						SET @M_AD_Amount = @Max_Upper

					If @Left_Date < @Actual_Start_Date				--Hardik 03/06/2017 if Left date is less then Start Date then it should be 0 for SLS Client
						SET @M_AD_Amount = 0
				
					------------ Ramiz 26-Feb-2019 => FOR MAFATLAL - NADIAD ----------------
					
					/* This Provision if for Restricting Negative Salary , only Deduct the Allowances , until Gross Salary is Available. 
					   Rest All Allowance will be deducted as 0 */
					   
					IF (@Grade_Wise_Salary_Enabled = 1 AND @M_AD_NOT_EFFECT_SALARY = 0 AND @M_AD_Amount <> 0)
						BEGIN
							IF @M_AD_Flag = 'I'
								BEGIN
									SET @Dynamic_Gross_Grade_Wise_Salary	= ISNULL(@Dynamic_Gross_Grade_Wise_Salary ,0) + ISNULL(@M_AD_Amount,0)
								END
							ELSE IF @M_AD_Flag = 'D'
								BEGIN
									IF @Dynamic_Gross_Grade_Wise_Salary >= @M_AD_Amount AND @Dynamic_Gross_Grade_Wise_Salary > 0
										BEGIN
											SET @Dynamic_Gross_Grade_Wise_Salary = ISNULL(@Dynamic_Gross_Grade_Wise_Salary ,0) - ISNULL(@M_AD_Amount,0)
										END
									ELSE
										BEGIN
											SET @M_AD_Amount = ISNULL(@Dynamic_Gross_Grade_Wise_Salary ,0)
											SET @Dynamic_Gross_Grade_Wise_Salary = 0
										END
								END
						END
					
						
					------------ End -----------------------------	
					
					--PRINT CONVERT(VARCHAR(20), GETDATE(), 114)  + ' : AD_DETAIL - 2'		
					IF NOT EXISTS(SELECT 1 FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) where emp_ID=@Emp_ID and ad_ID=@ad_ID
												and cmp_Id=@Cmp_ID and for_date=@Actual_Start_Date)								
						BEGIN
							--Commented by Hardik 22/06/2020 as no required to enable and disable trigger.. condition added in Trigger

							--IF @Allowance_type = 'R' OR @AD_DEF_ID  = @GPF_DEF_ID -- Added by Hardik 18/12/2015 for Speed
							--	ALTER TABLE dbo.T0210_MONTHLY_AD_DETAIL  ENABLE trigger Tri_T0210_MONTHLY_AD_DETAIL
							--Else
							--	ALTER TABLE dbo.T0210_MONTHLY_AD_DETAIL  Disable trigger Tri_T0210_MONTHLY_AD_DETAIL
							
							

						--	ALTER TABLE dbo.T0210_MONTHLY_AD_DETAIL disable trigger Trg_T0210_MONTHLY_AD_DETAIL_CTC_Update
							--deepal added  01112021
							--Declare @Emp_Left_Date as DateTime = NULL
							
							--select @Emp_Left_Date = Emp_Left_Date from T0080_EMP_MASTER where Emp_ID = @Emp_Id and Cmp_ID = @Cmp_ID
							
							--If month(@Emp_Left_Date) = MONTH(@To_Date) and year(@Emp_Left_Date) = year(@To_Date)
							--Begin 
							--		if @varCalc_On = 'FIX' 
							--		--if @AD_ID = 10 --As per sAjid put fix ad_id from time being for Khimji Sons.
							--		Begin 
							--			set @M_AD_Amount = 0
							--		END
							--END
							--ENd deepal added  01112021
							
								INSERT INTO dbo.T0210_MONTHLY_AD_DETAIL                    
								  (M_AD_Tran_ID, Sal_Tran_ID,Temp_Sal_Tran_ID ,L_Sal_Tran_ID,Emp_ID, Cmp_ID, AD_ID, For_Date, M_AD_Percentage, M_AD_Amount, M_AD_Flag, M_AD_Actual_Per_Amount,                     
								   M_AD_Calculated_Amount,M_AD_NOT_EFFECT_ON_PT,M_AD_NOT_EFFECT_SALARY,M_AD_EFFECT_ON_OT,M_AD_EFFECT_ON_EXTRA_DAY,SAL_TYPE,M_AD_effect_on_Late,M_AREAR_AMOUNT,To_date, Split_Shift_Count, Split_Shift_Date,Reimshow,ReimAmount,M_AREAR_AMOUNT_Cutoff)
	            
								VALUES     (@M_AD_Tran_ID, NULL,@Sal_Tran_ID,@L_Sal_Tran_ID, @Emp_ID, @Cmp_ID, @AD_ID, @Actual_Start_Date, @M_AD_Percentage, @M_AD_Amount, @M_AD_Flag, @M_AD_Actual_Per_Amount,                     
									   @Calc_On_Allow_Dedu,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY,0,@M_AD_effect_on_Late,@M_AREARS_AMOUNT,@Actual_End_Date,@Split_Shift_Count, @Split_Shift_Date,@ReimShow,@M_AD_Approval_Amount,isnull(@M_AREARS_AMOUNT_Cutoff,0))                    							
							
							
							--ALTER TABLE dbo.T0210_MONTHLY_AD_DETAIL ENABLE trigger Trg_T0210_MONTHLY_AD_DETAIL_CTC_Update

							
							
							--PRINT CONVERT(VARCHAR(20), GETDATE(), 114)  + ' : AD_DETAIL - 2 002'
								
							IF @Setting_Value = 1  -- Added by Gadriwala Muslim 04072015
								BEGIN
									--IF @Allowance_type = 'R' OR @AD_DEF_ID = @GPF_DEF_ID
										ALTER TABLE dbo.T0210_MONTHLY_AD_DETAIL  DISABLE TRIGGER Tri_T0210_MONTHLY_AD_DETAIL
									
									UPDATE	T0210_MONTHLY_AD_DETAIL  
									SET		ReimAmount = isnull(RTP.Debit,0) , ReimShow = 1 
									from	T0210_MONTHLY_AD_DETAIL MAD inner join
											T0140_ReimClaim_Transacation_Payment_Monthly RTP on MAD.Temp_Sal_Tran_ID = RTP.Sal_Trans_ID and MAD.AD_ID = RTP.Claim_ID
									where	MAD.Temp_Sal_Tran_ID = @Sal_Tran_ID and MAD.Emp_ID = @Emp_Id and MAD.Cmp_ID = @Cmp_ID and MAD.AD_ID = @AD_ID
									
									--IF @Allowance_type <> 'R' AND @AD_DEF_ID <> @GPF_DEF_ID
										alter table dbo.T0210_MONTHLY_AD_DETAIL  Enable trigger Tri_T0210_MONTHLY_AD_DETAIL 
								END 
								

								
						END
				
				--PRINT CONVERT(VARCHAR(20), GETDATE(), 114)  + ' : AD_DETAIL - 3'	
				END
	                 
					                            
			IF ISNULL(@Sal_Tran_ID,0) > 0                    
				BEGIN                    
				--SET @Deduction_Data  = ''              
				--SET @Allowance_Data  = ''                    
				                 
				SELECT  TOP 1 @Deduction_Data = Deduction_Data , @Allowance_Data= Allowance_Data
				FROM	T0210_PAYSLIP_DATA WITH (NOLOCK)
				WHERE	TEMP_SAL_TRAN_ID = @SAL_TRAN_ID 
				 
				IF @M_AD_Flag ='D'  			
				begin
					SET @Deduction_Data = @Deduction_Data + '<Tr>  <td width=200> <Font size =1 > ' + @AD_Name + '</Font></td> <td> <Font size =1 > '  +    CAST(@M_AD_Amount AS VARCHAR(20)) + '</Font></td>'  + '</Tr>'                                     
					end
				ELSE                        
					SET @Allowance_Data  = @Allowance_Data + '<Tr> <td width=200> <Font size =1 > ' + @AD_Name + '</Font></td> <td> <Font size =1 > '  +    CAST(@M_AD_Amount AS VARCHAR(20)) + '</Font></td>'  + '</Tr>'                                     
				END      
				--PRINT  convert(varchar(20), getdate(), 114) + ' : 1024.003'  
				 /*Performance
				 --PRINT @Deduction_Data
				--PRINT  convert(varchar(20), getdate(), 114) + ' : 1025:001'                  
				UPDATE	dbo.T0210_PAYSLIP_DATA                     
				SET		Allowance_Data = Allowance_Data + @Allowance_Data,                    
						Deduction_Data = Deduction_Data + @Deduction_Data                    
				WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID                    
				*/                   
				    	--if @AD_ID = 823
									----select @AD_ID,@varCalc_On,@M_AD_Percentage,@M_AD_Amount,@Calc_On_Allow_Dedu,@varCalc_On --deepal	
									--select * from T0210_MONTHLY_AD_DETAIL where emp_id = 22364 and Cmp_ID =	172	 and ad_id = 823
					
		  SET @intCount = @intCount + 1	                  
	   END
			--PRINT '--------------------'
			--PRINT convert(varchar(20), getdate() - @D_DIFF_TIME, 114) + ' : DIFFERENCE'  
	         
		FETCH NEXT FROM curAD INTO @AD_ID,@M_AD_Percentage,@M_AD_Amount,@M_AD_Flag,@Max_Upper,@varCalc_On,@AD_DEF_ID,@M_AD_NOT_EFFECT_ON_PT,
		@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY ,@AD_Name,@M_AD_effect_on_Late,@AD_Effect_Month,@AD_CAL_TYPE,@AD_EFFECT_FROM
		,@IS_NOT_EFFECT_ON_LWP,@Allowance_type,@AutoPaid,@AD_Level_temp,@IS_ROUNDING_Allowance,@Is_Calculate_Zero,@Prorata_On_Salary_Structure,@AD_Claim_ID
	                  
	   END                    
	 CLOSE curAD                    
	 DEALLOCATE curAD   
		--PERFORMANCE

		

		--ADDED BY RAMIZ--
		IF OBJECT_ID('tempdb..#OT_Gradewise') IS NOT NULL
			BEGIN 
				DELETE FROM #OT_Gradewise
			END
			
		--ENDS

		IF ISNULL(@Sal_Tran_ID,0) > 0                    
		  BEGIN                    
			UPDATE	dbo.T0210_PAYSLIP_DATA                     
			SET		Allowance_Data = IsNull(@Allowance_Data,  Allowance_Data), 
					Deduction_Data = isNull(@Deduction_Data, Deduction_Data)                    
			WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID                    
			
			
		  END      
	                   
	   IF ISNULL(@Sal_Tran_ID,0)   >0                    
		BEGIN                    
		UPDATE dbo.T0210_PAYSLIP_DATA                     
		SET  Allowance_Data = Allowance_Data + '</table>',                    
		  Deduction_Data = Deduction_Data + '</table>'                    
		WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID            
	   END         
	                  
		drop table #Allowance_Mid_Prev_Detail

	 RETURN



