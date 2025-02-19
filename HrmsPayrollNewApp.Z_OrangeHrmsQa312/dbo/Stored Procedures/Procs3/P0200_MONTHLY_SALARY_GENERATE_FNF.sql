---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0200_MONTHLY_SALARY_GENERATE_FNF]
	@M_Sal_Tran_ID				NUMERIC output,
	@Emp_Id						NUMERIC,
	@Cmp_ID						NUMERIC,
	@Sal_Generate_Date			datetime,
	@Month_St_Date				Datetime,
	@Month_END_Date				Datetime,
	@Present_Days				NUMERIC(18,2),
	@M_OT_Hours					NUMERIC(18,2),
	@Areas_Amount				NUMERIC(18,2) ,
	@M_IT_Tax					NUMERIC,
	@Other_Dedu					NUMERIC(18,2),
	@M_LOAN_AMOUNT				NUMERIC(18,2),
	@M_ADV_AMOUNT				NUMERIC(18,2),
	@Login_ID					NUMERIC,
	@Is_Gratuity_Cal			INT	,
	@TxtGratuity_Year			NUMERIC(18,2)=0, -- Added By Deepali 11122021
	@Gratuity_Months			NUMERIC(18,2)=0, -- Added By Deepali 104012022	
	@Is_Leave_Encash			INT	,
	@Is_Bonus					INT	,
	@Is_Short_Fall				INT,	
	@Incentive_Amount			NUMERIC(18,2),
	@Bonus_Amount				NUMERIC(18,2),
	@Trav_Earn_Amount			NUMERIC(18,2),
	@Cust_Res_Earn_Amount		NUMERIC(18,2),
	@Trav_Rec_Amount			NUMERIC(18,2),
	@Mobile_Rec_Amount			NUMERIC(18,2),
	@Cust_Res_Rec_Amount		NUMERIC(18,2),
	@Uniform_Rec_Amount			NUMERIC(18,2),
	@I_Card_Rec_Amount			NUMERIC(18,2),
	@Excess_Salary_Rec_Amount	NUMERIC(18,2),
	@Short_Fall_Days			NUMERIC(5,1),
	@User_Id NUMERIC(18,0) = 0,		-- Added for audit trail By Ali 17102013
	@IP_Address VARCHAR(30)= '',		-- Added for audit trail By Ali 17102013
	@arear_Days NUMERIC(18,2) = 0,		--Gadriwala 03122013
	@Access_Leave_Recovery NUMERIC(18,2) = 0.0,  -- Added By Ali 17022014
	@Access_Leave_Recovery_Type VARCHAR(200) = '',
	@Arear_Month NUMERIC=0,
	@Arear_Year NUMERIC=0,
	@TDS tinyint = 0, --Hardik 11/10/2014
	@Asset_amount NUMERIC(18,2), --Mukti 20032015
	@FNF_Subsidy_Recover_Amount NUMERIC(18,2) = 0,
	@FNF_Comments VARCHAR(max)='', --Added by Sumit 07112015
	@FNF_Training_Bnd_Rec_Amt NUMERIC(18,2)= 0,  -- Added by Gadriwala Muslim 01122016
	@Uniform_deduct_amount NUMERIC(18,2)= 0,  --Mukti(12052017)
	@Bonus_calculate_On  int = 0,		--Added By Jimit 09122019 0 for Consolidated
	@Uniform_Refund_Amount NUMERIC(18,2)= 0		--1 for Allowance

AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON   
	SET ANSI_WARNINGS OFF;

	--Added for audit trail By Ali 16102013 -- Start
	DECLARE @Old_Emp_Id AS NUMERIC
	DECLARE @Old_Emp_Name AS VARCHAR(150)
	DECLARE @Old_Sal_Receipt_No NUMERIC
	DECLARE @OldValue AS VARCHAR(max)
										
	DECLARE @Old_Increment_ID AS NUMERIC
	DECLARE @Old_tmp_Month_St_Date AS datetime
	DECLARE @Old_tmp_Month_END_Date AS datetime
	DECLARE @Old_Sal_Generate_Date AS datetime
	DECLARE @Old_mid_Sal_Cal_Days AS NUMERIC
	DECLARE @Old_mid_Present_Days AS NUMERIC
	DECLARE @Old_mid_Absent_Days AS NUMERIC
	DECLARE @Old_mid_Holiday_Days AS NUMERIC
	DECLARE @Old_mid_Weekoff_Days AS NUMERIC
	DECLARE @Old_mid_Cancel_Holiday AS NUMERIC
	DECLARE @Old_mid_Cancel_Weekoff AS NUMERIC
	DECLARE @Old_Working_Days AS NUMERIC
	DECLARE @Old_Outof_Days AS NUMERIC
	DECLARE @Old_mid_Total_Leave_Days AS NUMERIC
	DECLARE @Old_mid_Paid_Leave_Days AS NUMERIC
	DECLARE @Old_mid_Actual_Working_Hours AS VARCHAR(150)
	DECLARE @Old_mid_Working_Hours AS VARCHAR(150)
	DECLARE @Old_mid_Outof_Hours AS VARCHAR(150)
	DECLARE @Old_Emp_OT_Hours_Num AS NUMERIC
	DECLARE @Old_Total_Hours AS VARCHAR(100)
	DECLARE @Old_mid_Shift_Day_Sec  AS VARCHAR(100)
	DECLARE @Old_mid_Shift_Day_Hour AS VARCHAR(100)
	DECLARE @Old_mid_basic_Amount AS NUMERIC
	DECLARE @Old_mid_Day_Salary AS NUMERIC
	DECLARE @Old_mid_Hour_Salary AS NUMERIC
	DECLARE @Old_mid_Salary_Amount AS NUMERIC
	DECLARE @Old_mid_Allow_Amount AS NUMERIC
	DECLARE @Old_mid_OT_Amount AS NUMERIC
	DECLARE @Old_mid_Other_Allow_Amount AS NUMERIC
	DECLARE @Old_mid_gross_Amount AS NUMERIC
	DECLARE @Old_mid_Dedu_Amount AS NUMERIC
	DECLARE @Old_mid_Loan_Amount AS NUMERIC
	DECLARE @Old_mid_Loan_Intrest_Amount AS NUMERIC
	DECLARE @Old_mid_Advance_Amount AS NUMERIC
	DECLARE @Old_mid_Other_Dedu_Amount AS NUMERIC
	DECLARE @Old_mid_Total_Dedu_Amount AS NUMERIC
	DECLARE @Old_mid_Due_Loan_Amount AS NUMERIC
	DECLARE @Old_mid_Net_Amount AS NUMERIC
	DECLARE @Old_mid_PT_Calculated_Amount AS NUMERIC
	DECLARE @Old_mid_PT_Amount AS NUMERIC
	DECLARE @Old_mid_Total_Claim_Amount AS NUMERIC
	DECLARE @Old_mid_M_IT_Tax AS NUMERIC
	DECLARE @Old_mid_M_ADv_Amount AS NUMERIC
	DECLARE @Old_mid_M_Loan_Amount AS NUMERIC
	DECLARE @Old_mid_M_OT_Hours AS NUMERIC
	DECLARE @Old_mid_LWF_Amount AS NUMERIC
	DECLARE @Old_mid_REvenue_Amount AS NUMERIC
	DECLARE @Old_mid_PT_F_T_LIMIT AS VARCHAR(100)
	DECLARE @Old_Gross_Salary_ProRata AS NUMERIC
	DECLARE @Old_mid_Leave_Salary_Amount AS NUMERIC
	DECLARE @Old_mid_Late_Sec AS NUMERIC
	DECLARE @Old_mid_Late_Dedu_Amount AS NUMERIC
	DECLARE @Old_Extra_Late_Deduction AS NUMERIC
	DECLARE @Old_mid_Late_Days AS NUMERIC
	DECLARE @Old_Status AS VARCHAR(100)
	DECLARE @Old_mid_Bonus_Amount AS NUMERIC
	DECLARE @Old_mid_IT_M_ED_Cess_Amount AS NUMERIC
	DECLARE @Old_mid_IT_M_Surcharge_Amount AS NUMERIC
	DECLARE @Old_mid_Early_Sec AS NUMERIC
	DECLARE @Old_mid_Early_Dedu_Amount AS NUMERIC
	DECLARE @Old_mid_Early_Extra_Dedu_Amount AS NUMERIC
	DECLARE @Old_mid_Early_Days AS NUMERIC
	DECLARE @Old_mid_Total_Earning_Fraction AS NUMERIC
	DECLARE @Old_mid_Late_Early_Penalty_days AS NUMERIC
	DECLARE @Old_mid_M_WO_OT_Hours AS NUMERIC
	DECLARE @Old_mid_M_WO_OT_Amount AS NUMERIC
	DECLARE @Old_mid_M_HO_OT_Hours AS NUMERIC
	DECLARE @Old_mid_M_HO_OT_Amount AS NUMERIC
	DECLARE @Old_Salary_amount_Arear AS NUMERIC
	DECLARE @Old_Gross_Salary_Arear AS NUMERIC
	DECLARE @Old_Arear_Day AS NUMERIC
	DECLARE @Old_Mid_OD_leave_Days AS NUMERIC
	DECLARE @Old_Extra_AB_Days AS NUMERIC
	DECLARE @Old_Extra_AB_Rate AS NUMERIC
	DECLARE @Old_Extra_AB_Amount AS NUMERIC
	DECLARE @Old_Settelement_Amount AS NUMERIC
	DECLARE @Old_FNF_Subsidy_Recover_Amount AS NUMERIC(18,2)
	DECLARE @Old_FNF_Training_Bnd_Rec_Amt AS NUMERIC(18,2) -- Added by Gadriwala Muslim 01122016
	SET @Old_Emp_Id = 0
	SET @Old_Emp_Name = ''
	SET @Old_Sal_Receipt_No = 0
	SET @OldValue = ''
	SET @Old_Increment_ID = 0
	SET @Old_tmp_Month_St_Date = null
	SET @Old_tmp_Month_END_Date = null
	SET @Old_Sal_Generate_Date = null
	SET @Old_mid_Sal_Cal_Days = 0
	SET @Old_mid_Present_Days = 0
	SET @Old_mid_Absent_Days = 0
	SET @Old_mid_Holiday_Days = 0
	SET @Old_mid_Weekoff_Days = 0
	SET @Old_mid_Cancel_Holiday = 0
	SET @Old_mid_Cancel_Weekoff = 0
	SET @Old_Working_Days = 0
	SET @Old_Outof_Days = 0
	SET @Old_mid_Total_Leave_Days = 0
	SET @Old_mid_Paid_Leave_Days = 0
	SET @Old_mid_Actual_Working_Hours = ''
	SET @Old_mid_Working_Hours = ''
	SET @Old_mid_Outof_Hours = ''
	SET @Old_Emp_OT_Hours_Num = 0
	SET @Old_Total_Hours = ''
	SET @Old_mid_Shift_Day_Sec  = ''
	SET @Old_mid_Shift_Day_Hour = ''
	SET @Old_mid_basic_Amount = 0
	SET @Old_mid_Day_Salary = 0
	SET @Old_mid_Hour_Salary = 0
	SET @Old_mid_Salary_Amount = 0
	SET @Old_mid_Allow_Amount = 0
	SET @Old_mid_OT_Amount = 0
	SET @Old_mid_Other_Allow_Amount = 0
	SET @Old_mid_gross_Amount = 0
	SET @Old_mid_Dedu_Amount = 0
	SET @Old_mid_Loan_Amount = 0
	SET @Old_mid_Loan_Intrest_Amount = 0
	SET @Old_mid_Advance_Amount = 0
	SET @Old_mid_Other_Dedu_Amount = 0
	SET @Old_mid_Total_Dedu_Amount = 0
	SET @Old_mid_Due_Loan_Amount = 0
	SET @Old_mid_Net_Amount = 0
	SET @Old_mid_PT_Calculated_Amount = 0
	SET @Old_mid_PT_Amount = 0
	SET @Old_mid_Total_Claim_Amount = 0
	SET @Old_mid_M_IT_Tax = 0
	SET @Old_mid_M_ADv_Amount = 0
	SET @Old_mid_M_Loan_Amount = 0
	SET @Old_mid_M_OT_Hours = 0
	SET @Old_mid_LWF_Amount = 0
	SET @Old_mid_REvenue_Amount = 0
	SET @Old_mid_PT_F_T_LIMIT = ''
	SET @Old_Gross_Salary_ProRata = 0
	SET @Old_mid_Leave_Salary_Amount = 0
	SET @Old_mid_Late_Sec = 0
	SET @Old_mid_Late_Dedu_Amount = 0
	SET @Old_Extra_Late_Deduction = 0
	SET @Old_mid_Late_Days = 0
	SET @Old_Status = ''
	SET @Old_mid_Bonus_Amount = 0
	SET @Old_mid_IT_M_ED_Cess_Amount = 0
	SET @Old_mid_IT_M_Surcharge_Amount = 0
	SET @Old_mid_Early_Sec = 0
	SET @Old_mid_Early_Dedu_Amount = 0
	SET @Old_mid_Early_Extra_Dedu_Amount = 0
	SET @Old_mid_Early_Days = 0
	SET @Old_mid_Total_Earning_Fraction = 0
	SET @Old_mid_Late_Early_Penalty_days = 0
	SET @Old_mid_M_WO_OT_Hours = 0
	SET @Old_mid_M_WO_OT_Amount = 0
	SET @Old_mid_M_HO_OT_Hours = 0
	SET @Old_mid_M_HO_OT_Amount = 0
	SET @Old_Salary_amount_Arear = 0
	SET @Old_Gross_Salary_Arear = 0
	SET @Old_Arear_Day = 0
	SET @Old_Mid_OD_leave_Days = 0
	SET @Old_Extra_AB_Days = 0
	SET @Old_Extra_AB_Rate = 0
	SET @Old_Extra_AB_Amount = 0
	SET @Old_Settelement_Amount = 0
	SET @Old_FNF_Subsidy_Recover_Amount = 0
	SET @Old_FNF_Training_Bnd_Rec_Amt = 0 -- Added by Gadriwala Muslim 01122016
	--Added for audit trail By Ali 16102013 -- END
	
	
--	IF EXISTS(SELECT 1 FROM sys.triggers WHERE is_disabled=1) --for sql 2005 added by hasmukh 
----	IF not EXISTS(SELECT 1 FROM sysobjects a join sysobjects b on a.parent_obj=b.id WHERE a.type = 'tr' AND A.STATUS & 2048 = 0) -- for sql 2000
--		BEGIN
--			EXEC sp_msforeachTABLE 'ALTER TABLE ? ENABLE TRIGGER all'
--			--SET @ErrRaise =':|:ERRT:|: Another Process Running. Try After Sometime'
--			--return 
--		END
	
	-- Variable Declaration 	
	
	DECLARE @Sal_Receipt_No			NUMERIC
	DECLARE @Increment_ID			NUMERIC
	DECLARE @Sal_Tran_ID			NUMERIC 
	DECLARE @Branch_ID				NUMERIC 
	DECLARE @Emp_OT					NUMERIC 
	DECLARE @Emp_OT_Min_Limit		VARCHAR(10)
	DECLARE @Emp_OT_Max_Limit		VARCHAR(10)
	Declare	@Emp_OT_Min_Sec			NUMERIC
	DECLARE @Emp_OT_Max_Sec			NUMERIC
	DECLARE @Emp_OT_Sec				NUMERIC
	DECLARE @Emp_OT_Hours			VARCHAR(10)
	DECLARE @Wages_Type				VARCHAR(10)
	DECLARE @SalaryBasis			VARCHAR(20)
	DECLARE @Payment_Mode			VARCHAR(20)
	DECLARE @Fix_Salary				VARCHAR(1)
	DECLARE @numAbsentDays			NUMERIC(12,2)				   
	DECLARE @numWorkingDays_Daily	NUMERIC(12,2)
	DECLARE @numAbsentDays_Daily	NUMERIC(12,2)
	DECLARE @Sal_cal_Days			NUMERIC(12,2)
	DECLARE @Absent_Days			NUMERIC(12,2)
	DECLARE @Holiday_Days			NUMERIC(12,2)
	DECLARE @Weekoff_Days			NUMERIC(12,2)
	DECLARE @Cancel_Holiday			NUMERIC(12,2)
	DECLARE @Cancel_Weekoff			NUMERIC(12,2)
	DECLARE @Working_days			NUMERIC(12,2)
	DECLARE @OutOf_Days				NUMERIC        
	DECLARE @Total_leave_Days		NUMERIC(12,2)
	DECLARE @Paid_leave_Days		NUMERIC(12,2)
	
	DECLARE @Actual_Working_Hours	VARCHAR(20)
	DECLARE @Actual_Working_Sec		NUMERIC
	DECLARE @Holiday_Sec			NUMERIC 
	DECLARE @Weekoff_Sec			NUMERIC 
	DECLARE @Leave_Sec				NUMERIC
	
	DECLARE @Other_Working_Sec		NUMERIC 
	DECLARE @Working_Hours			VARCHAR(20)
	DECLARE @Outof_Hours			VARCHAR(20)
	DECLARE @Total_Hours			VARCHAR(20)
	DECLARE @Shift_Day_Sec			NUMERIC
	DECLARE @Shift_Day_Hour			VARCHAR(20)
	DECLARE @Basic_Salary			NUMERIC(25,2)
	DECLARE @Gross_Salary			NUMERIC(25,2)
	DECLARE @Actual_Gross_Salary	NUMERIC(25,2)
	DECLARE @Gross_Salary_ProRata	NUMERIC(25,2)
	DECLARE @Day_Salary				NUMERIC(12,5)
	DECLARE @Hour_Salary			NUMERIC(12,5)
	DECLARE @Salary_amount			NUMERIC(12,5)
	DECLARE @Allow_Amount			NUMERIC(18,2)
	DECLARE @OT_Amount				NUMERIC(18,2)
	DECLARE @Other_allow_Amount		NUMERIC(18,2)
	DECLARE @Dedu_Amount			NUMERIC(18,2)
	DECLARE @Loan_Amount			NUMERIC(18,2)
	DECLARE @Loan_Intrest_Amount	NUMERIC(18,2)
	DECLARE @Advance_Amount			NUMERIC(18,2)
	DECLARE @Other_Dedu_Amount		NUMERIC(18,2)
	DECLARE @Total_Dedu_Amount		NUMERIC(18,2)
	DECLARE @Due_Loan_Amount		NUMERIC(18,2)
	DECLARE @Net_Amount				NUMERIC(18,2)
	DECLARE @Final_Amount			NUMERIC(18,2)
	DECLARE @Hour_Salary_OT			NUMERIC(18,2)
	DECLARE @ExOTSetting			NUMERIC(5,2)
	DECLARE @Inc_Weekoff			char(1)
	DECLARE @Inc_Holiday			int
	DECLARE @Late_Adj_Day			NUMERIC(5,2)
	DECLARE @OT_Min_Limit			VARCHAR(20)
	DECLARE @OT_Max_Limit			VARCHAR(20)
	DECLARE @OT_Min_Sec				NUMERIC
	DECLARE @OT_Max_Sec				NUMERIC
	DECLARE @Is_OT_Inc_Salary		char(1)
	DECLARE @Is_Daily_OT			char(1)
	DECLARE @Fix_OT_Shift_Hours		VARCHAR(20)
	DECLARE @Fix_OT_Shift_Sec		NUMERIC    
	DECLARE @Fix_OT_Work_Days		NUMERIC(18,2)
	DECLARE @Round					NUMERIC
	DECLARE @Restrict_Present_Days	char(1)
	DECLARE @Is_Cancel_Holiday		NUMERIC(1,0)
	DECLARE @Is_Cancel_Weekoff		NUMERIC(1,0)
	DECLARE @Join_Date				Datetime
	DECLARE @Left_Date				Datetime	
	DECLARE @Reg_Accept_Date		Datetime
	DECLARE @StrHoliday_Date		VARCHAR(1000)
	DECLARE @StrWeekoff_Date		VARCHAR(1000)
	DECLARE @Update_Adv_Amount		NUMERIC 
	DECLARE @Total_Claim_Amount		NUMERIC 
	DECLARE @Is_PT					NUMERIC
	DECLARE @Is_Emp_PT				NUMERIC
	DECLARE @PT_Amount				NUMERIC
	DECLARE @PT_Calculated_Amount	NUMERIC 
	DECLARE @LWF_Amount				NUMERIC 
	DECLARE @LWF_App_Month			VARCHAR(50)
	DECLARE @Revenue_Amount			NUMERIC 
	DECLARE @Revenue_On_Amount		NUMERIC 
	DECLARE @LWF_compare_month		VARCHAR(5)
	DECLARE @PT_F_T_Limit			VARCHAR(20)
	DECLARE @Half_Days				NUMERIC(18,2)
	DECLARE @Fix_late_W_Days		NUMERIC(5,1)
	DECLARE @Fix_late_W_Hours		VARCHAR(10)
	DECLARE @Fix_late_W_Shift_Sec	NUMERIC
	DECLARE @Late_deduction_Days	NUMERIC(5,2)
	DECLARE @Extra_Late_Deduction	NUMERIC(3,2)
	DECLARE @Hour_Salary_Late		NUMERIC(12,5)
	DECLARE @Late_Basic_Amount		NUMERIC(27,5)
	DECLARE @Sal_St_Date			Datetime
	DECLARE @Sal_END_Date			Datetime
	DECLARE @Sal_Fix_Days			NUMERIC(5,2)
	DECLARE @Gratuity_Amount		NUMERIC
	DECLARE @Short_Fall_Days_Cons	NUMERIC
	DECLARE @Short_Fall_Dedu_Amount NUMERIC
	DECLARE @Month					INT
	DECLARE @Year					INT
	DECLARE @Yearly_Bonus_Per		NUMERIC(5,2)
	DECLARE @Is_Yearly_Bonus		INT
	DECLARE @Is_Gr_App				INT
	DECLARE @Last_Bonus_Date		Datetime
	DECLARE @Bonus_To_Date			Datetime
	DECLARE @Leave_ID				NUMERIC
	DECLARE @Leave_Days				NUMERIC(7,2)
	DECLARE @Leave_Salary			NUMERIC			
	DECLARE @Pre_Month_Net_Salary	NUMERIC(18,0)
	DECLARE @Grade_ID               NUMERIC(18,0)
	DECLARE @G_Short_Fall_Days      NUMERIC(18,0)
	DECLARE @G_Short_Fall_W_Days    NUMERIC(18,0)
	DECLARE @Is_Gradewise_Short_Fall INT  
	DECLARE @StrMonth				VARCHAR(10) 
	DECLARE @Wages_Amount			NUMERIC(18,0)
	DECLARE @Lv_Salary_Effect_on_PT Tinyint
	DECLARE @Lv_Encash_Cal_On		VARCHAR(50)	
	DECLARE @IS_ROUNDING			NUMERIC(1,0)	
	DECLARE @WO_OT_Amount			NUMERIC(22,3)    
	DECLARE @HO_OT_Amount			NUMERIC(22,3)
	DECLARE @Emp_WO_OT_Sec			NUMERIC
	DECLARE @Emp_HO_OT_Sec			NUMERIC
	DECLARE @Is_OT_Auto_Calc		Tinyint
	DECLARE @W_OT_Hours				NUMERIC(22,3)
	DECLARE @H_OT_Hours				NUMERIC(22,3)
	DECLARE @OT_Working_Day			NUMERIC(4,1)
	DECLARE @Emp_WD_OT_Rate			NUMERIC(5,1)
	DECLARE @Emp_WO_OT_Rate			NUMERIC(5,1)
	DECLARE @Emp_HO_OT_Rate			NUMERIC(5,1)
	DECLARE @Emp_WO_OT_Hours		VARCHAR(10)
	DECLARE @Emp_HO_OT_Hours		VARCHAR(10)
	DECLARE @Is_Terminate			Tinyint
	DECLARE @Is_LWF_App				INT
	
	
	-- Added by Hardik 14/11/2018 for Shoft Shift Yard Client
	DECLARE @Shift_Wise_OT_Rate TINYINT
	DECLARE @Shift_Wise_OT_Calculated tinyint
	SET @Shift_Wise_OT_Rate = 0

	SELECT @Shift_Wise_OT_Rate = Setting_Value FROM T0040_SETTING WITH (NOLOCK) where CMP_ID = @Cmp_Id and Setting_Name = 'Enable Shift Wise Over Time Rate'
	
	-- ADDED BY RAJPUT ON 13072018 ---
	DECLARE @OT_RATE_TYPE AS TINYINT = 0 
	DECLARE @OT_SLAB_TYPE AS TINYINT = 0 
	DECLARE @GEN_ID NUMERIC 
	SET @GEN_ID = 0 
	-- END ---
	
	-- Added by rohit For Fnf Generate for Next Month on 13062013
	DECLARE @check_month_END_Date Datetime
	SET @check_month_END_Date = @month_END_Date
	-- ENDed by rohit on 13062013
	
	SET @Wages_Amount =0
	SET @Lv_Salary_Effect_on_PT  =0
	SET @Lv_Encash_Cal_On = ''
	
	SET @G_Short_Fall_Days=0
	SET @G_Short_Fall_W_Days=0
	SET @Is_Gradewise_Short_Fall=0
	
	SET @WO_OT_Amount = 0
	SET @HO_OT_Amount = 0
	IF @FNF_Comments=''
		BEGIN
			SET @FNF_Comments=null;
		END --Added by Sumit 17112015
	
	------------------------------- Added By Ali 09122013 Start -------------------------------
	DECLARE @OutOf_Days_Arear	NUMERIC(18,2)
	DECLARE @Basic_Salary_Arear	NUMERIC(25,2)
	DECLARE @Gross_Salary_Arear	NUMERIC(25,2)
	DECLARE @Day_Salary_Arear	NUMERIC(12,5)
	DECLARE @Salary_amount_Arear	NUMERIC(12,5)
	DECLARE @Allow_Amount_Arear	NUMERIC(18,2)
	DECLARE @Dedu_Amount_Arear	NUMERIC(18,2)
	--DECLARE @Arear_Month NUMERIC(5,1)
	--DECLARE @Arear_Year NUMERIC(5,1)
	DECLARE @Arear_Amount NUMERIC(22,4)
	DECLARE @out_of_days_temp NUMERIC
	DECLARE @net_round AS NUMERIC(18,2)
	DECLARE @net_round_Type AS NVARCHAR(50)
	DECLARE @Temp_mid_Net_Amount NUMERIC(18,2)
	DECLARE @mid_Net_Round_Diff_Amount NUMERIC(18,2)
	DECLARE @mid_Net_Amount	NUMERIC(18, 2)
	
	 SET @net_round = 0
	 SET @net_round_Type = ''
	 SET @Temp_mid_Net_Amount = 0
	 SET @mid_Net_Round_Diff_Amount = 0
	 SET @mid_Net_Amount = 0

	SET @OutOf_Days_Arear = 0
	SET @Basic_Salary_Arear = 0 
	SET @Gross_Salary_Arear = 0 
	SET @Day_Salary_Arear = 0 
	SET @Salary_amount_Arear = 0 
	SET @Allow_Amount_Arear = 0 
	SET @Dedu_Amount_Arear = 0 
	--SET @Arear_Month = 0
	--SET @Arear_Year = 0
	SET @Arear_Amount = 0
	
	-- Added by rohit on 20012015
	DECLARE @OutOf_Days_Arear_cutoff	NUMERIC(18,2)
	DECLARE @Basic_Salary_Arear_cutoff	NUMERIC(25,2)
	DECLARE @Gross_Salary_Arear_cutoff	NUMERIC(25,2)
	DECLARE @Day_Salary_Arear_cutoff	NUMERIC(12,5)
	DECLARE @Salary_amount_Arear_cutoff	NUMERIC(12,5)
	DECLARE @Allow_Amount_Arear_cutoff	NUMERIC(18,2)
	DECLARE @Dedu_Amount_Arear_cutoff	NUMERIC(18,2)
	DECLARE @Arear_Amount_cutoff NUMERIC(22,4)
	DECLARE @Arear_Month_cutoff NUMERIC(5,1)
	DECLARE @Arear_Year_cutoff NUMERIC(5,1)
	DECLARE @fnf_Fix_Day NUMERIC(5,0) --Added by nilesh patel on 16062015
	DECLARE @Is_Cancel_Holiday_WO_HO_same_day tinyint --Added By nilesh on 01122015 (For Cancel Holiday When WO/HO on Same Day	
    SET @Is_Cancel_Holiday_WO_HO_same_day = 0
    
    DECLARE @Late_Mark_Scenario NUMERIC(2,0) --Added by nilesh patel 
	SET @Late_Mark_Scenario = 1
    
    DECLARE @Is_LateMark_Percent NUMERIC(1,0) --Added by nilesh patel 16062017
	SET @Is_LateMark_Percent = 0
	
	DECLARE @Is_LateMark_Calc_On NUMERIC(1,0) --Added by nilesh patel 16062017
	SET @Is_LateMark_Calc_On = 0
    
    DECLARE @ALLOWED_FULLWEEKOFF_MIDLEFT TINYINT
    DECLARE @ALLOWED_FULLWEEKOFF_MIDLEFTDAYRATE TINYINT
    DECLARE @StrWeekoff_Date_DayRate AS VARCHAR(max)
	DECLARE @Weekoff_Days_DayRate NUMERIC(18, 4) 
	
	
    
	
	SET @ALLOWED_FULLWEEKOFF_MIDLEFT =0;
	SET @ALLOWED_FULLWEEKOFF_MIDLEFTDAYRATE =0; --Added by Sumit in case full Weekoff in Mid Left Case on 25/07/2016
	
	SET @OutOf_Days_Arear_cutoff = 0
	SET @Basic_Salary_Arear_cutoff = 0 
	SET @Gross_Salary_Arear_cutoff = 0 
	SET @Day_Salary_Arear_cutoff = 0 
	SET @Salary_amount_Arear_cutoff = 0 
	SET @Allow_Amount_Arear_cutoff = 0 
	SET @Dedu_Amount_Arear_cutoff = 0 
	SET @Arear_Amount_cutoff = 0
	SET @Arear_Month_cutoff = 0
	SET @Arear_Year_cutoff = 0
	-- ENDed by rohit on 20012015
	
	
	SET @OutOf_Days	= DateDiff(d,@Month_St_Date,@Month_END_Date) + 1
	SET @out_of_days_temp = @OutOf_Days

	Declare @Night_Shift_Count Numeric
	Set @Night_Shift_Count = 0

	Declare @OT_Adj_Days Numeric(18,2)
	Set @OT_Adj_Days = 0

	Declare @Is_OT_Adj_against_Absent tinyint
	Set @Is_OT_Adj_against_Absent = 0
	
	------------------------------- Added By Ali 09122013 END ---------------------------------
	-- Added by Hardik 03/04/2019 for Genchi Client, for Adjust Late with Leave during F&F
	Declare @tmp_Days_Adjust NUMERIC(5,2)
	declare @Late_Dedu_Type_inc varchar(10)
	declare @Late_is_slabwise tinyint
	declare @Is_late_Mark		tinyint
	Declare @Is_Late_Mark_Gen  tinyint
	
	SET @Late_Dedu_Type_inc  = 0
	Set @Is_late_Mark = 0
	Set @Late_is_slabwise = 0
	Set @Is_Late_Mark_Gen = 0


	
	------------------------------ TABLE Creation -----------------------
 	CREATE TABLE #Salary   -- Short Fall deduction
		(
			Company_ID			NUMERIC,
			Emp_ID				NUMERIC,
			From_Date			Datetime,
			To_Date				DAtetime,
			Shoft_Fall_Days		NUMERIC(5,1),
			Salary_Amount		NUMERIC,
			Allow_Amount		NUMERIC,
			Gross_Salary		NUMERIC
			
		)
		
	CREATE TABLE #Salary_AD --- Short fall 
		(
			Company_ID	NUMERIC,
			Emp_ID		NUMERIC,
			Allow_Dedu_ID	NUMERIC,
			For_Date	Datetime,
			M_AD_Flag	VARCHAR(1),
			M_AD_Amount	NUMERIC
		)
	CREATE TABLE #OT_Data
	  (
		Emp_ID			NUMERIC ,
		Basic_Salary	NUMERIC(18,5),
		Day_Salary		NUMERIC(12,5),
		OT_Sec			NUMERIC,
		Ex_OT_Setting	tinyint,
		OT_Amount		NUMERIC,
		Shift_Day_Sec	int,
		OT_Working_Day	NUMERIC(4,1),
		Emp_OT_Hour     NUMERIC(18,2),
		Hourly_Salary   NUMERIC(18,5),
		WO_OT_Sec	NUMERIC,
		WO_OT_Amount NUMERIC(22,3),
		WO_OT_Hour	NUMERIC(22,3),
		HO_OT_Sec	NUMERIC,
		HO_OT_Amount NUMERIC(22,3),
		HO_OT_Hour	NUMERIC(22,3)
	  )  
	 -- For Calculate Present Days  
	 CREATE TABLE #Data   
	   (   
		  Emp_Id     NUMERIC ,   
		  For_date   datetime,  
		  Duration_in_sec  NUMERIC,  
		  Shift_ID   NUMERIC ,  
		  Shift_Type   NUMERIC ,  
		  Emp_OT    NUMERIC ,  
		  Emp_OT_min_Limit NUMERIC,  
		  Emp_OT_max_Limit NUMERIC,  
		  P_days    NUMERIC(12,2) default 0,  
		  OT_Sec    NUMERIC default 0,
		  In_Time datetime default null,
		  Shift_Start_Time datetime default null,
		  OT_Start_Time NUMERIC default 0,
		  Shift_Change tinyint default 0,
		  Flag int default 0    		  ,
		  Weekoff_OT_Sec  NUMERIC default 0,
		  Holiday_OT_Sec  NUMERIC default 0,
		  Chk_By_Superior NUMERIC default 0,
		  IO_Tran_Id	  NUMERIC default 0,
		  OUT_Time datetime,
		  Shift_END_Time datetime,			--Ankit 16112013
		  OT_END_Time NUMERIC default 0,		--Ankit 16112013		    
		  Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		  Working_Hrs_END_Time tinyint default 0, --Hardik 14/02/2014
		  GatePass_Deduct_Days NUMERIC(18,2) default 0 -- Add by Gadriwala Muslim 05012014
		  
	   )   
	   
	CREATE TABLE #Gratuity	
	(
		Emp_ID   NUMERIC(18,0),
		Emp_Left VARCHAR(10),
		Emp_Code NUMERIC(18,0),
		Emp_Full_Name VARCHAR(100),
		Date_Of_join datetime,
		Last_Gr_Date datetime,
		Gr_Year     NUMERIC(18,0),
		Work_Year   NUMERIC(18,0)
	)	
	
	CREATE TABLE #DA_Allowance
	(
		Grd_Id			NUMERIC ,
		Grd_Count		NUMERIC(18, 4) ,
		Basic_Salary	NUMERIC(18, 4) DEFAULT 0,
		DA_Allow_Salary	NUMERIC(18, 4) DEFAULT 0 ,
		BasicDA_OT_Salary		NUMERIC(18, 4) DEFAULT 0 ,
		Day_Night_Flag	NUMERIC(18) DEFAULT 0,	----0: Day Shift, 1: Night Shift
		Is_Master_Grd	TINYINT DEFAULT 0,
		Master_Basic	numeric(18,2),
		Is_Leave_Applied TINYINT DEFAULT 0,		--0: Working Day , 1: Leave Day , 2: Holiday
	) 
	
	---------------------------------------------------------------------
	
	
	--SET @OutOf_Days = DateDiff(d,@Month_St_Date,@Month_END_Date) + 1
	DECLARE @tmp_mon_END_date datetime
	SELECT @tmp_mon_END_date = dbo.GET_MONTH_END_DATE(MONTH(@Month_END_Date),YEAR(@Month_END_Date))	
	
	
	--Ankit 01072014
	
	IF EXISTS (SELECT 1 FROM T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_Id AND Month = MONTH(@Month_END_Date) AND Year = YEAR(@Month_END_Date)  )
		BEGIN
			SELECT @M_OT_Hours = IsNull(Over_Time,0) FROM T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK)
			WHERE Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_Id AND Month = MONTH(@Month_END_Date) AND Year = YEAR(@Month_END_Date)  
		END
	
	--Ankit 01072014
	
	SET @OutOf_Days = DateDiff(d,@Month_St_Date,@tmp_mon_END_date) + 1
	SET @Emp_OT			= 0
	SET @Wages_Type		= ''
	SET @SalaryBasis	= ''
	SET @Payment_Mode	= ''
	SET @Fix_Salary		= ''
	SET @numAbsentDays	=0
	SET @numWorkingDays_Daily = 0
	SET @numAbsentDays_Daily  = 0
	SET @Sal_cal_Days	 = 0
	SET @Absent_Days	 = 0
	SET @Holiday_Days	 = 0
	SET @Weekoff_Days	 = 0
	SET @Cancel_Holiday	 = 0
	SET @Cancel_Weekoff	 = 0
	SET @Working_days	 = 0
	SET @Total_leave_Days  = 0
	SET @Paid_leave_Days  = 0
	SET @Update_Adv_Amount	= 0
	SET @Total_Claim_Amount	 = 0
	SET @IS_ROUNDING = 1    
	
	SET @Actual_Working_Hours  =''
	SET @Actual_Working_Sec = 0
	SET @Holiday_Sec		= 0
	SET @Weekoff_Sec		= 0
	SET @Leave_Sec			= 0
	
	SET @Other_Working_Sec =0
	SET @Working_Hours  = ''
	SET @Outof_Hours  = ''
	SET @Total_Hours  = ''
	SET @Shift_Day_Sec	= 0 
	SET @Shift_Day_Hour		 = ''
	SET @Basic_Salary		 = 0 
	SET @Day_Salary			 = 0
	SET @Hour_Salary		 = 0
	SET @Salary_amount		 = 0
	SET @Allow_Amount		 = 0
	SET @OT_Amount			 = 0
	SET @Other_allow_Amount	 = @Areas_Amount
	SET @Gross_Salary		 = 0
	SET @Dedu_Amount		 = 0
	SET @Loan_Amount		 = 0
	SET @Loan_Intrest_Amount = 0
	SET @Advance_Amount		 = 0
	SET @Other_Dedu_Amount	= @Other_Dedu
	SET @Total_Dedu_Amount	= 0
	SET @Due_Loan_Amount	= 0
	SET @Net_Amount			= 0
	SET @Final_Amount		= 0
	SET @Hour_Salary_OT		= 0	
	SET @Inc_Weekoff = 1
	SET @Inc_Holiday = 1
	
	SET @Late_Adj_Day = 0
	SET @ExOTSetting			= 0
	SET @OT_Min_Limit			=''
	SET @OT_Max_Limit			= ''
	SET @Is_OT_Inc_Salary		= ''
	SET @Is_Daily_OT			= 'N'
	SET @Fix_OT_Shift_Hours		= ''
	SET @Fix_OT_Shift_Sec = 0
	SET @Fix_OT_Work_Days	= 0
	SET @OT_Min_Sec	 = 0
	SET @OT_Max_Sec	 = 0
	SET @Round = 0
	SET @Restrict_Present_Days = 'Y'
	SET @Is_Cancel_Weekoff = 0
	SET @Is_Cancel_Holiday = 0
	SET @StrHoliday_Date = ''
	SET @StrWeekoff_Date = ''
	SET @Emp_OT_Min_Limit = ''
	SET @Emp_OT_Max_Limit = ''
	SET @Emp_OT_Min_Sec	= 0
	SET @Emp_OT_Max_Sec = 0
	SET @Emp_OT_Sec = @M_OT_Hours * 3600
	SET @Emp_WO_OT_Sec = @W_OT_Hours * 3600 
	SET @Emp_HO_OT_Sec = @H_OT_Hours * 3600 
	SET @Is_PT = 0
	SET @Is_Emp_PT = 0
	SET @PT_Amount = 0
	SET @PT_Calculated_Amount = 0
	SET @LWF_Amount				=0
	SET @LWF_App_Month			=	''
	SET @Revenue_Amount			=0
	SET @Revenue_On_Amount		= 0
	SET @LWF_compare_month		= ''
	SET @PT_F_T_Limit = ''
	SET @Fix_late_W_Days		= 0
	SET @Fix_late_W_Hours		= ''
	SET @Fix_late_W_Shift_Sec	= 0 
	SET @Late_deduction_Days	= 0
	SET @Extra_Late_Deduction	= 0
	SET @Hour_Salary_Late		= 0
	SET @Late_Basic_Amount		= 0
	SET @Gratuity_Amount		= 0
	SET @Short_Fall_Days_Cons	= 0
	SET @Short_Fall_Dedu_Amount = 0
	SET @Yearly_Bonus_Per		= 0
	SET @Is_Yearly_Bonus		= 0
	SET @Is_Gr_App				= 0
	SET @Leave_Salary			= 0
	SET @Leave_Days				= 0
	SET @Pre_Month_Net_Salary   = 0 
	SET @StrMonth='#' + CAST(MONTH(@Month_END_Date) AS VARCHAR(2)) + '#' 
	SET @Emp_WO_OT_Sec = 0
	SET @Emp_HO_OT_Sec = 0
	SET @Is_OT_Auto_Calc = 0
	SET @W_OT_Hours = 0
	SET @H_OT_Hours = 0
	SET @OT_Working_Day = 0
	SET @Emp_WD_OT_Rate = 0
	SET @Emp_WO_OT_Rate = 0
	SET @Emp_HO_OT_Rate = 0
	SET @Emp_WO_OT_Hours = ''
	SET @Emp_HO_OT_Hours = ''
	SET @Is_Terminate = 0
	SET @fnf_Fix_Day = 0
	SET @Is_LWF_App=0

	Declare @Emp_Part_Time numeric
	set @Emp_Part_Time= 0  --Added by Jaina 06-05-2019
	
	
	SET @Month = MONTH(@Month_END_Date)
	SET @Year  = YEAR(@Month_END_Date)
	IF @Login_ID =0
		SET @Login_ID = NULL	


	SELECT @left_Date = Emp_Left_Date FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_Id	
	
	IF @M_Sal_Tran_ID > 0 
		BEGIN
				SET @Sal_Tran_ID  = @M_Sal_Tran_ID 
				Delete FROM T0210_Monthly_Leave_Detail			WHERE emp_id = @Emp_id	AND Sal_Tran_ID = @Sal_Tran_ID 
				Delete FROM T0210_MONTHLY_AD_DETAIL				WHERE emp_id = @emp_id	AND Sal_Tran_ID = @Sal_Tran_ID 
				DELETE FROM T0210_MONTHLY_AD_DETAIL WHERE IsNull(SAL_TRAN_ID,0) = 0 
				Delete FROM T0210_MONTHLY_LOAN_PAYMENT			WHERE Sal_Tran_ID = @Sal_Tran_ID
				--Delete FROM T0210_MONTHLY_CLAIM_PAYMENT			WHERE Sal_Tran_ID = @Sal_Tran_ID
				DELETE FROM T0210_PAYSLIP_DATA					WHERE SAL_TRAN_ID = @SAL_TRAN_ID
				SELECT @Sal_Receipt_No =  Sal_Receipt_No		FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Sal_Tran_ID =@Sal_Tran_ID
				
				IF IsNull(@Sal_Receipt_No,0)=0
					BEGIN
						SELECT @Sal_Receipt_No =  IsNull(MAX(sal_Receipt_No),0)  + 1  FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE MONTH(Month_St_Date) = MONTH(@Month_St_DAte) 
								AND YEAR(Month_St_Date) = YEAR(@Month_END_Date) AND Cmp_ID= @Cmp_ID
					END 
				
		END		
	ELSE
		BEGIN
			SELECT @Sal_Tran_Id =  IsNull(MAX(Sal_Tran_Id),0)  + 1   FROM T0200_MONTHLY_SALARY WITH (NOLOCK)
			SELECT @Sal_Receipt_No =  IsNull(MAX(sal_Receipt_No),0)  + 1  FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE MONTH(Month_St_Date) = MONTH(@Month_St_DAte) 
							AND YEAR(Month_St_Date) = YEAR(@Month_END_Date) AND Cmp_ID= @Cmp_ID
		END
		
		
		SELECT @Increment_ID = I.Increment_ID ,@Wages_Type = Wages_type,@SalaryBasis = Salary_Basis_On
			,@Emp_OT = Emp_OT , @Payment_Mode = Payment_Mode 
			,@Actual_Gross_Salary = Gross_Salary ,@Basic_Salary =I.Basic_Salary
			,@Emp_OT_Min_Limit = Emp_OT_Min_Limit , @Emp_OT_Max_Limit = Emp_OT_Max_Limit
			,@Is_Emp_PT =IsNull(Emp_PT,0)
			,@Yearly_Bonus_Per =IsNull(Yearly_Bonus_Per,0)
			,@Is_Yearly_Bonus  =IsNull(Is_Yearly_Bonus,0)		
			,@Is_Gr_App		 = IsNull(Is_Gr_App,0)
			,@Emp_WD_OT_Rate = IsNull(Emp_WeekDay_OT_Rate,0) , @Emp_WO_OT_Rate = IsNull(Emp_WeekOff_OT_Rate,0) , @Emp_HO_OT_Rate = IsNull(Emp_Holiday_OT_Rate,0)		
			,@Is_LWF_App = IsNull(is_Lwf,0)
			,@Emp_Part_Time = ISNULL(Emp_Part_Time,0)  --Added by Jaina 06-05-2019
			,@Late_Dedu_Type_inc  = isnull(Late_Dedu_Type,''), @Is_late_Mark = isnull(Emp_Late_mark,0)								
			FROM T0095_Increment I WITH (NOLOCK) inner join 
					( SELECT MAX(Increment_Id) AS Increment_Id , Emp_ID FROM T0095_Increment WITH (NOLOCK)  --Changed by Hardik 09/09/2014 for Same Date Increment
					WHERE Increment_Effective_date <= @Month_END_Date
					AND Cmp_ID = @Cmp_ID AND Emp_ID = @emp_id AND Increment_Type <> 'Transfer' AND Increment_Type <> 'Deputation' 
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	AND I.Increment_Id = Qry.Increment_Id Inner Join  --Changed by Hardik 09/09/2014 for Same Date Increment
					T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID
		WHERE I.Emp_ID = @Emp_ID

		SELECT	@Branch_ID = Branch_ID ,@Grade_ID=I.Grd_ID			
		FROM	T0095_Increment I WITH (NOLOCK) 
				INNER JOIN (SELECT	MAX(Increment_ID) AS Increment_ID,Emp_ID 
							FROM	T0095_Increment WITH (NOLOCK)   
							WHERE	Increment_Effective_date <= @Month_END_Date AND Cmp_ID = @Cmp_ID 
							GROUP BY emp_ID) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID    
		WHERE	I.Emp_ID = @Emp_ID 
	
		SELECT	@ExOTSetting = ExOT_Setting,@Inc_Weekoff = Inc_Weekoff,@Late_Adj_Day = IsNull(Late_Adj_Day,0),
				@OT_Min_Limit = OT_APP_LIMIT ,@OT_Max_Limit = IsNull(OT_Max_Limit,'00:00'),
				@Is_OT_Inc_Salary = IsNull(OT_Inc_Salary,'N'),
				@Is_Daily_OT = Is_Daily_OT,@Is_Cancel_Holiday = Is_Cancel_Holiday,@Is_Cancel_Weekoff = Is_Cancel_Weekoff,
				@Fix_OT_Shift_Hours = OT_Fix_Shift_Hours,@Fix_OT_Work_Days = IsNull(OT_fiX_Work_Day,0),
				@Is_PT = IsNull(Is_PT,0),@Lv_Salary_Effect_on_PT = Lv_Salary_Effect_on_PT,
				@LWF_Amount = LWF_Amount , @LWF_App_Month = LWF_Month,@Lv_Encash_Cal_On = Lv_Encash_Cal_On,
				@Revenue_amount = Revenue_amount , @Revenue_on_Amount =Revenue_on_Amount,
				@Sal_St_Date  =Sal_st_Date , @Sal_Fix_Days = Sal_Fix_Days,@Short_Fall_Days_Cons = IsNull(Short_Fall_Days,0),
				@Wages_Amount =Wages_amount,@Last_Bonus_Date =Bonus_last_Paid_Date,@Inc_Holiday=IsNull(Inc_Holiday,0),
				@Is_Gradewise_Short_Fall = IsNull(Is_Shortfall_Gradewise,0),@IS_ROUNDING = IsNull(AD_Rounding,1),
				@Is_OT_Auto_Calc = IsNull(Is_OT_Auto_Calc,0),@net_round = IsNull(net_salary_round,0),
				@net_round_Type = IsNull(type_net_salary_round,''),@fnf_Fix_Day = IsNull(Fnf_Fix_Day,0),
				@Is_Cancel_Holiday_WO_HO_same_day = IsNull(g.Is_Cancel_Holiday_WO_HO_same_day,0),
				@ALLOWED_FULLWEEKOFF_MIDLEFT=IsNull(Allowed_Full_WeekOf_MidLeft,0),
				@ALLOWED_FULLWEEKOFF_MIDLEFTDAYRATE=IsNull(Allowed_Full_WeekOf_MidLeft_DayRate,0),
				@Late_Mark_Scenario = IsNull(Late_Mark_Scenario,1),
				@Is_LateMark_Percent = IsNull(Is_Latemark_Percentage,0),
				@Is_LateMark_Calc_On = IsNull(Is_Latemark_Cal_On,0)
				,@Is_OT_Adj_against_Absent = Is_OT_Adj_against_Absent
				,@OT_RATE_TYPE = ISNULL(OTRateType,0) -- ADDED BY RAJPUT ON 13072018
				,@OT_SLAB_TYPE = ISNULL(OTSLABTYPE,0) -- ADDED BY RAJPUT ON 13072018
				,@GEN_ID = GEN_ID -- ADDED BY RAJPUT ON 13072018
				,@Late_is_slabwise = isnull(is_Late_Calc_Slabwise,0)
				,@Is_Late_Mark_Gen = Is_Late_Mark
		FROM	T0040_GENERAL_SETTING G WITH (NOLOCK) 
		WHERE	cmp_ID = @cmp_ID AND Branch_ID = @Branch_ID AND 
				For_Date = (SELECT	MAX(For_Date) 
							FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
							WHERE	For_Date <=@Month_END_Date AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)
		 
		SELECT	@Join_Date = Date_Of_Join
		FROM	T0080_EMP_MASTER WITH (NOLOCK)
		WHERE	Emp_ID = @Emp_Id --Added by Sumit on 16112016
		
		--Added By Jimit 09082018 as per case at WCL (Employee join on 2nd and left on 10th then consider total days as 10)
		if @Join_Date > @Month_St_Date
		set @Month_St_Date = @Join_Date
		--ended
		
	    IF @Is_Gradewise_Short_Fall=1
			BEGIN	
				SELECT	@G_Short_Fall_Days=Short_Fall_Days,@G_Short_Fall_W_Days=Short_Fall_W_Days  
				FROM	t0040_grade_master WITH (NOLOCK)
				WHERE	Grd_ID=@Grade_ID AND Cmp_Id=@Cmp_ID
				
				SET @Short_Fall_Days_Cons=@G_Short_Fall_Days
			END
	    
		IF IsNull(@Last_Bonus_Date,'') =''
			BEGIN
				SELECT	@Last_Bonus_Date = From_Date
				FROM	T0010_Company_Master WITH (NOLOCK) 
				WHERE	cmp_ID=@Cmp_ID
			END
		ELSE
			BEGIN
				SET @Last_Bonus_Date = DateAdd(d,1,@Last_Bonus_Date)
			END
	  
	  
		SET @Bonus_To_Date = DateAdd(d,-1,DateAdd(yy,1,@Last_Bonus_Date))
	
	
		-- added By rohit on 11022013
		DECLARE @manual_salary_period AS NUMERIC(18,0)
		SET @manual_salary_period = 0
 
		DECLARE @is_salary_cycle_emp_wise AS tinyint -- added by mitesh on 03072013
		SET @is_salary_cycle_emp_wise = 0
   
		SELECT @is_salary_cycle_emp_wise = IsNull(Setting_Value,0) FROM dbo.T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name = 'Salary Cycle Employee Wise'
   
   
   
		IF @is_salary_cycle_emp_wise = 1
			BEGIN
				DECLARE @Salary_Cycle_id AS NUMERIC
				SET @Salary_Cycle_id  = 0
			
				SELECT	@Salary_Cycle_id = salDate_id 
				FROM	dbo.T0095_Emp_Salary_Cycle WITH (NOLOCK)
				WHERE	emp_id = @Emp_Id AND 
						effective_date IN (SELECT	MAX(effective_date) AS effective_date 
										   FROM		dbo.T0095_Emp_Salary_Cycle WITH (NOLOCK)
										   WHERE	emp_id = @Emp_Id AND effective_date <=  @Month_END_Date
										   GROUP BY emp_id)
			
				SELECT	@Sal_St_Date = SALARY_ST_DATE 
				FROM	dbo.t0040_salary_cycle_master WITH (NOLOCK)
				WHERE tran_id = @Salary_Cycle_id			
			END
		ELSE
			BEGIN
				IF @Branch_ID IS NULL
					BEGIN 
						SELECT	Top 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_period=IsNull(Manual_Salary_Period ,0) -- added By rohit on 11022013
						FROM	dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
						WHERE	cmp_ID = @cmp_ID AND 
								For_Date = (SELECT	MAX(For_Date) 
											FROM	dbo.T0040_GENERAL_SETTING WITH (NOLOCK) 
											WHERE	For_Date <=@Month_END_Date AND Cmp_ID = @Cmp_ID)    
					END
				ELSE
					BEGIN
						SELECT	@Sal_St_Date  =Sal_st_Date ,@manual_salary_period=IsNull(Manual_Salary_Period ,0) -- added By rohit on 11022013
						FROM	dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
						WHERE	cmp_ID = @cmp_ID AND Branch_ID = @Branch_ID AND 
								For_Date = (SELECT	MAX(For_Date) 
											FROM	dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
											WHERE	For_Date <=@Month_END_Date AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)    
					END
			END	
			
			
		IF @Left_Date >= @check_month_END_Date
			BEGIN
				IF DAY(@Sal_St_Date) > 1    -- Added by mitesh on 14/03/2012 for 26 salary period getting problem
					BEGIN
						IF DAY(@left_date) >= DAY(@Sal_St_Date) 
							BEGIN
								IF MONTH(@left_date) = 12
									BEGIN
										--SET @Month_St_Date = CAST('01/' + CAST(dbo.F_GET_MONTH_NAME(MONTH(DateAdd(MM,1,@left_date))) AS NVARCHAR) + '/' + CAST((YEAR(@left_date) + 1) AS NVARCHAR) AS datetime)
										SET @Month_St_Date = CAST('01/' + CAST(dbo.F_GET_MONTH_NAME(MONTH(DateAdd(MM,1,@left_date))) AS NVARCHAR) + '/' + CAST((YEAR(@left_date) + 1) AS NVARCHAR) AS datetime)
									END
								ELSE
									BEGIN
										SET @Month_St_Date = CAST('01/' + CAST(dbo.F_GET_MONTH_NAME(MONTH(DateAdd(MM,1,@left_date))) AS NVARCHAR) + '/' + CAST(YEAR(@left_date) AS NVARCHAR) AS datetime)
									END
							END
						ELSE IF DAY(@Month_END_Date) > DAY(@Sal_St_Date)
							BEGIN
								SET @Month_St_Date = CAST('01/' + CAST(dbo.F_GET_MONTH_NAME(MONTH(DateAdd(MM,1,@Month_St_Date))) AS NVARCHAR) + '/' + CAST(YEAR(@Month_St_Date) AS NVARCHAR) AS datetime)
							END
				
					END
			END
		IF IsNull(@Sal_St_Date,'') = ''    
			BEGIN    
				SET @Month_St_Date  = @Month_St_Date     
				SET @Month_END_Date = @Month_END_Date    
				SET @OutOf_Days = @OutOf_Days
			END     
		ELSE IF DAY(@Sal_St_Date) = 1 --AND MONTH(@Sal_St_Date)= 1    
			BEGIN    
				SET @Month_St_Date  = @Month_St_Date     
				SET @Month_END_Date = @Month_END_Date    
				SET @OutOf_Days = @OutOf_Days    	         
			END     
		ELSE IF @Sal_St_Date <> ''  AND DAY(@Sal_St_Date) > 1   
			BEGIN    
				SET @Sal_St_Date =  CAST(CAST(DAY(@Sal_St_Date)as VARCHAR(5)) + '-' + CAST(datename(mm,DateAdd(m,-1,@Month_St_Date)) AS VARCHAR(10)) + '-' +  CAST(YEAR(DateAdd(m,-1,@Month_St_Date) )as VARCHAR(10)) AS smalldatetime)    
				SET @Sal_END_Date = DateAdd(d,-1,DateAdd(m,1,@Sal_St_Date)) 
				SET @OutOf_Days = DateDiff(d,@Sal_St_Date,@Sal_END_Date) + 1
		   
				SET @Month_St_Date = @Sal_St_Date
				SET @Month_END_Date = @Sal_END_Date    
			END
	
	  
		DECLARE @Temp_Sal_Tran_Id AS NUMERIC	   
		SELECT	@Temp_Sal_Tran_Id =  Sal_Tran_ID  
		FROM	T0200_MONTHLY_SALARY WITH (NOLOCK)
		WHERE	MONTH(Month_END_Date) = MONTH(@Month_END_Date) AND 
				YEAR(Month_END_Date) = YEAR(@Month_END_Date) AND Cmp_ID= @Cmp_ID AND Emp_ID = @Emp_Id

		IF @Temp_Sal_Tran_Id > 0 
			BEGIN
				Raiserror('Same Month Salary EXISTS, SELECT Next Month for Full AND Final Settlement',16,2)
				Return -1
			END
	
		IF EXISTS(SELECT Pf_Challan_Id FROM dbo.T0220_Pf_Challan WITH (NOLOCK) WHERE Cmp_Id=@Cmp_Id AND MONTH=MONTH(@Month_END_Date) AND YEAR = YEAR(@Month_END_Date) AND CHARINDEX('#'+ CAST(@Branch_ID AS VARCHAR(18)) +'','#' + Branch_ID_Multi) > 0)
			BEGIN
				RAISERROR ('PF Challan EXISTS', -- Message text.
						16, -- Severity.
						1   -- State.
						);
				RETURN -1
			END
		IF EXISTS(SELECT Esic_Challan_Id FROM dbo.T0220_ESIC_Challan WITH (NOLOCK) WHERE Cmp_Id=@Cmp_Id AND MONTH=MONTH(@Month_END_Date) AND YEAR = YEAR(@Month_END_Date) AND CHARINDEX('#'+ CAST(@Branch_ID AS VARCHAR(18)) +'','#' + Branch_ID_Multi) > 0)
			BEGIN
				RAISERROR ('ESIC Challan EXISTS', -- Message text.
						16, -- Severity.
						1   -- State.
						);
				RETURN -1
			END

		IF @Left_Date >= @Month_St_Date AND @Left_Date <= @Month_END_Date
			BEGIN
				SET @check_month_END_Date = @Left_Date
			END

	
		-- Added by rohit For Fnf Generate For next Month other then left month on 1262013
		--IF @Left_Date <> @check_month_END_Date  
		--BEGIN
		--		Goto ABC;
		--END
	       
		-- Added by rohit on 20012015	
		IF EXISTS (SELECT * FROM [tempdb].dbo.sysobjects WHERE name like '#Att_Muster_with_shift' )		
			BEGIN
				DROP TABLE #Att_Muster_with_shift
			END
			
		CREATE TABLE #Att_Muster_with_shift
		(
			Emp_Id		NUMERIC , 
			Cmp_ID		NUMERIC,
			For_Date	datetime,
			[Status]	VARCHAR(10),
			Leave_Count	NUMERIC(5,2),
			WO_HO		VARCHAR(3),
			Status_2	VARCHAR(10),
			Row_ID		NUMERIC ,
			WO_HO_Day	NUMERIC(3,2) default 0,
			P_days		NUMERIC(5,2) default 0,
			A_days		NUMERIC(5,2) default 0,
			Join_Date	Datetime default null,
			Left_Date	Datetime default null,
			GatePass_Days NUMERIC(18,2) default 0, --Added by Gadriwala Muslim 07042015
			Late_deduct_Days NUMERIC(18,2) default 0,  --Added by Gadriwala Muslim 07042015
			Early_deduct_Days NUMERIC(18,2) default 0,  --Added by Gadriwala Muslim 07042015
			shift_id	NUMERIC
		)
	
		DECLARE @Absent_after_Cutoff_date AS NUMERIC(18,2)
		SET @Absent_after_Cutoff_date =0 
	
		IF EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE MONTH(Month_END_Date) =  MONTH(DateAdd(m,-1,@Month_END_Date)) AND YEAR(Month_END_Date) =  YEAR( DateAdd(m,-1,@Month_END_Date)) AND Emp_ID=@Emp_Id AND Cutoff_Date<>Month_END_Date )	
			BEGIN
				DECLARE @last_Month_Cutoffdate AS datetime
				DECLARE @temp_previous_month_END_date AS datetime

				SET @temp_previous_month_END_date = DateAdd(dd,-1,@Month_St_Date)
				SELECT	@last_Month_Cutoffdate= DateAdd(dd,1,Cutoff_Date) 
				FROM	T0200_MONTHLY_SALARY WITH (NOLOCK) 
				WHERE	MONTH(Month_END_Date) =  MONTH(DateAdd(m,-1,@Month_END_Date)) 
						AND YEAR(Month_END_Date) =  YEAR( DateAdd(m,-1,@Month_END_Date)) AND Emp_ID=@Emp_Id 
		
				IF @last_Month_Cutoffdate < @Left_Date	--Added By Ramiz on 03/03/2017
					BEGIN
						EXEC SP_RPT_EMP_ATTENDANCE_MUSTER_GET @Cmp_ID=@Cmp_ID,@From_Date=@last_Month_Cutoffdate,@To_Date=@temp_previous_month_END_date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint=@Emp_Id,@Report_For='Absent_Cutoff'
						SELECT	@Absent_after_Cutoff_date =(IsNull(sum(a_days),0)*(-1)) 
						FROM	#Att_Muster_with_shift 
						WHERE	Emp_Id=@Emp_Id
					END
			END
		-- ENDed by rohit on 20012015 

	       
		IF IsNull(@Sal_Fix_Days,0) > 0    				   
			SET @OutOf_Days = @Sal_Fix_Days
	
		DECLARE @Total_Actual_Days NUMERIC
			SET @Total_Actual_Days = 0
	
		IF IsNull(@Left_Date ,0) <> 0
			SET @Total_Actual_Days = DateDiff(d,@Month_St_Date,@Left_Date) + 1

	
		CREATE TABLE #tblAllow
		(
			 Row_ID NUMERIC(18),
			 Emp_ID NUMERIC(18),
			 Increment_ID NUMERIC(18),
			 AD_ID NUMERIC(18),
			 M_AD_Percentage  NUMERIC(12,5),
			 M_AD_Amount  NUMERIC(12,5),
			 M_AD_Flag  VARCHAR(1),
			 Max_Upper   NUMERIC(27,5),
			 varCalc_On   VARCHAR(50),
			 AD_DEF_ID  INT,
			 M_AD_NOT_EFFECT_ON_PT   NUMERIC(1,0),
			 M_AD_NOT_EFFECT_SALARY  NUMERIC(1,0),
			 M_AD_EFFECT_ON_OT  NUMERIC(1,0),
			 M_AD_EFFECT_ON_EXTRA_DAY   NUMERIC(1,0),
			 AD_Name  VARCHAR(50),
			 M_AD_effect_on_Late  INT,
			 AD_Effect_Month  VARCHAR(50),
			 AD_CAL_TYPE  VARCHAR(50),
			 AD_EFFECT_FROM  VARCHAR(15),
			 IS_NOT_EFFECT_ON_LWP  NUMERIC(1,0),
			 Allowance_type  VARCHAR(10),
			 AutoPaid  tinyint,
			 AD_LEVEL NUMERIC(18, 0)    -- Added by Ramiz on 18092014 AS error was coming in F&F
		)      

		--,EED.INCREMENT_ID ,E_AD_Percentage,E_AD_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,                    
		-- AD_NOT_EFFECT_ON_PT , AD_NOT_EFFECT_SALARY , AD_EFFECT_ON_OT , AD_EFFECT_ON_EXTRA_DAY                     
		--,AD_Name, AD_effect_on_Late  , AD_Effect_Month , AD_CAL_TYPE , AD_EFFECT_FROM , ADM.AD_NOT_EFFECT_ON_LWP 
		--, ADM.Allowance_Type  ,  ADM.auto_paid 
		
		INSERT	INTO #tblAllow
		SELECT	ROW_NUMBER() OVER (PARTITION BY EMP_ID,EED.INCREMENT_ID ORDER BY AD_LEVEL,EED.AD_ID),EED.EMP_ID,EED.INCREMENT_ID,
				EED.AD_ID,E_AD_Percentage,E_AD_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID,IsNull(AD_NOT_EFFECT_ON_PT,0),
				IsNull(AD_NOT_EFFECT_SALARY,0),IsNull(AD_EFFECT_ON_OT,0),IsNull(AD_EFFECT_ON_EXTRA_DAY,0),AD_Name,IsNull(AD_effect_on_Late,0),
				IsNull(AD_Effect_Month,''),IsNull(AD_CAL_TYPE,''),IsNull(AD_EFFECT_FROM,''),IsNull(ADM.AD_NOT_EFFECT_ON_LWP,0),
				IsNull(ADM.Allowance_Type,'A') AS Allowance_Type, IsNull(ADM.auto_paid,0) AS AutoPaid , IsNull(ADM.AD_LEVEL,0) AS AD_LEVEL   -- Ramiz added on 18092014 AS error was coming in F&F
		FROM	dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) 
				INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID
		WHERE	emp_id = @emp_ID AND Adm.AD_ACTIVE = 1
		ORDER BY AD_LEVEL, E_AD_Flag DESC  
	
		------------------------ ----------- Added By Ali 09122013 Start  ----------------------------------------------
		IF @Arear_Month = 0 or @Arear_Month IS NULL AND  @Arear_Year = 0 or @Arear_Year IS NULL --Added by Hardik 13/06/2014 for Arear Month AND Year passing FROM Form Level
			BEGIN
				SELECT	@Arear_Month = Extra_Day_Month, @Arear_Year = Extra_Day_Year 
				FROM	T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK)
				WHERE	Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_Id AND Month = MONTH(@Month_END_Date) AND Year = YEAR(@Month_END_Date)  
			
				IF @Arear_Month = 0 OR @Arear_Month IS NULL
					SET @Arear_Month = (SELECT	MONTH(Emp_Left_Date) 
										FROM	T0080_EMP_MASTER WITH (NOLOCK) 
										WHERE	Emp_ID  = @Emp_Id AND Cmp_ID = @Cmp_ID AND Emp_Left = 'Y')
					
				IF @Arear_Year = 0 or @Arear_Year IS NULL
					SET @Arear_Year =	(SELECT	YEAR(Emp_Left_Date) 
										 FROM	T0080_EMP_MASTER WITH (NOLOCK)
										 WHERE	Emp_ID  = @Emp_Id AND Cmp_ID = @Cmp_ID AND Emp_Left = 'Y')
			END	
		-- Added by rohit on 20012015
		
		
		IF IsNull(@Absent_after_Cutoff_date,0) <> 0
			BEGIN
				SET @Arear_Month_Cutoff =MONTH(DateAdd(m,-1,@Month_END_Date))
				SET @Arear_Year_Cutoff =YEAR(DateAdd(m,-1,@Month_END_Date))
			
				IF @Arear_Month_Cutoff = 0 or @Arear_Month_Cutoff IS NULL
					SET @Arear_Month_Cutoff = (SELECT	MONTH(Emp_Left_Date) 
												FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID  = @Emp_Id AND Cmp_ID = @Cmp_ID AND Emp_Left = 'Y')
					
			IF @Arear_Year_Cutoff = 0 or @Arear_Year_Cutoff IS NULL
				SET @Arear_Year_Cutoff = (SELECT YEAR(Emp_Left_Date) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID  = @Emp_Id AND Cmp_ID = @Cmp_ID AND Emp_Left = 'Y')
		END	
			 			 
			 
	--- Added by Ali 09122013 for SET FROM Date AND To date AS per Salary Cycle for Arear Month
					DECLARE @Sal_St_Date_Arear AS Datetime
					DECLARE @Sal_END_Date_Arear AS Datetime
					--DECLARE @manual_salary_period AS NUMERIC(18,0)
					SET @manual_salary_period = 0
		-- Added by rohit on 20012015
					DECLARE @Sal_St_Date_Arear_cutoff AS Datetime
					DECLARE @Sal_END_Date_Arear_cutoff AS Datetime
					DECLARE @is_manual_arrear_cutoff  AS tinyint 
					SET @is_manual_arrear_cutoff   = 0			    
				    -- ENDed by rohit on 20012015				
				
	DECLARE @is_manual_arrear  AS tinyint 
	SET @is_manual_arrear   = 0
					
	IF @Arear_Month = MONTH(@Month_END_Date) AND @Arear_Year = YEAR(@Month_END_Date)
		BEGIN 
			SET @Sal_St_Date_Arear = @Month_St_Date
			SET @Sal_END_Date_Arear = @Month_END_Date
			SET @OutOf_Days_Arear = @OutOf_Days
			SET @is_manual_arrear = 1
			
		END
	
	ELSE IF @is_salary_cycle_emp_wise = 1
		BEGIN
			 
			SELECT @Sal_St_Date_Arear = SALARY_ST_DATE FROM dbo.t0040_salary_cycle_master WITH (NOLOCK) WHERE tran_id = @Salary_Cycle_id
			
		END
	ELSE
		BEGIN
				   IF @Branch_ID IS NULL
						BEGIN 
							SELECT Top 1 @Sal_St_Date_Arear  = Sal_st_Date ,@manual_salary_period=IsNull(Manual_Salary_Period ,0) 
							  FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE cmp_ID = @cmp_ID    
							  AND For_Date = ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=@Month_END_Date AND Cmp_ID = @Cmp_ID)    
						END
					ELSE
						BEGIN
							SELECT @Sal_St_Date_Arear  =Sal_st_Date ,@manual_salary_period=IsNull(Manual_Salary_Period ,0) 
							  FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE cmp_ID = @cmp_ID AND Branch_ID = @Branch_ID    
							  AND For_Date = ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=@Month_END_Date AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)    
						END 
		END
					
			IF @is_manual_arrear = 0
				BEGIN	
				   IF IsNull(@Sal_St_Date_Arear,'') = ''    
						  BEGIN    
								SET @OutOf_Days_Arear = DateDiff(dd,dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year),dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year))+ 1
						  END     
							
					 ELSE IF DAY(@Sal_St_Date_Arear) =1   
						  BEGIN    
								SET @OutOf_Days_Arear = DateDiff(dd,dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year),dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year))+ 1
						  END     
					 ELSE IF @Sal_St_Date_Arear <> ''  AND DAY(@Sal_St_Date_Arear) > 1   
						  BEGIN    
							IF @manual_salary_period = 0 
							   BEGIN
									SET @Sal_St_Date_Arear =  CAST(CAST(DAY(@Sal_St_Date_Arear)as VARCHAR(5)) + '-' + CAST(datename(mm,DateAdd(m,-1,dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year))) AS VARCHAR(10)) + '-' +  CAST(YEAR(DateAdd(m,-1,dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year)) )as VARCHAR(10)) AS smalldatetime)    
									SET @Sal_END_Date_Arear = DateAdd(d,-1,DateAdd(m,1,@Sal_St_Date_Arear)) 
									SET @OutOf_Days_Arear = DateDiff(d,@Sal_St_Date_Arear,@Sal_END_Date_Arear) + 1
							   END 
							 ELSE
								BEGIN
									SELECT @Sal_St_Date_Arear = from_date, @Sal_END_Date_Arear = END_date 
									FROM salary_period WHERE month= @Arear_Month AND YEAR=@Arear_Year
									SET @OutOf_Days_Arear = DateDiff(d,@Sal_St_Date_Arear,@Sal_END_Date_Arear) + 1
								END   
						  END
			END
			
		---- END by Ali 09122013 for SET FROM Date AND To Date for Arear Month

-- added by rohit on 20012015

IF @Arear_Month_cutoff = MONTH(@Month_END_Date) AND @Arear_Year_cutoff = YEAR(@Month_END_Date)
		BEGIN 
			SET @Sal_St_Date_Arear_cutoff  = @Month_St_Date
			SET @Sal_END_Date_Arear_cutoff = @Month_END_Date
			SET @OutOf_Days_Arear_cutoff = @OutOf_Days
			SET @is_manual_arrear_cutoff = 1
		END
	
	ELSE IF @is_salary_cycle_emp_wise = 1
		BEGIN
			 
			SELECT @Sal_St_Date_Arear_cutoff = SALARY_ST_DATE FROM dbo.t0040_salary_cycle_master WITH (NOLOCK) WHERE tran_id = @Salary_Cycle_id
			
		END
	ELSE
		BEGIN
				   IF @Branch_ID IS NULL
						BEGIN 
							SELECT Top 1 @Sal_St_Date_Arear_cutoff  = Sal_st_Date ,@manual_salary_period=IsNull(Manual_Salary_Period ,0) 
							  FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE cmp_ID = @cmp_ID    
							  AND For_Date = ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=@Month_END_Date AND Cmp_ID = @Cmp_ID)    
						END
					ELSE
						BEGIN
							SELECT @Sal_St_Date_Arear_cutoff  =Sal_st_Date ,@manual_salary_period=IsNull(Manual_Salary_Period ,0) 
							  FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE cmp_ID = @cmp_ID AND Branch_ID = @Branch_ID    
							  AND For_Date = ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=@Month_END_Date AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)    
						END 
		END
					
			IF @is_manual_arrear_cutoff  = 0
				BEGIN	
				   IF IsNull(@Sal_St_Date_Arear_cutoff,'') = ''    
						  BEGIN    
								SET @OutOf_Days_Arear_cutoff = DateDiff(dd,dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year),dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year))+ 1
						  END     
							
					 ELSE IF DAY(@Sal_St_Date_Arear_cutoff) =1   
						  BEGIN    
								SET @OutOf_Days_Arear_cutoff = DateDiff(dd,dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year),dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year))+ 1
						  END     
					 ELSE IF @Sal_St_Date_Arear_cutoff <> ''  AND DAY(@Sal_St_Date_Arear_cutoff) > 1   
						  BEGIN    
							IF @manual_salary_period = 0 
							   BEGIN
									SET @Sal_St_Date_Arear_cutoff =  CAST(CAST(DAY(@Sal_St_Date_Arear)as VARCHAR(5)) + '-' + CAST(datename(mm,DateAdd(m,-1,dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year))) AS VARCHAR(10)) + '-' +  CAST(YEAR(DateAdd(m,-1,dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year)) )as VARCHAR(10)) AS smalldatetime)    
									SET @Sal_END_Date_Arear_cutoff = DateAdd(d,-1,DateAdd(m,1,@Sal_St_Date_Arear)) 
									SET @OutOf_Days_Arear_cutoff = DateDiff(d,@Sal_St_Date_Arear,@Sal_END_Date_Arear) + 1
							   END 
							 ELSE
								BEGIN
									SELECT @Sal_St_Date_Arear_cutoff = from_date, @Sal_END_Date_Arear_cutoff = END_date 
									FROM salary_period WHERE month= @Arear_Month_cutoff AND YEAR=@Arear_Year_cutoff
									SET @OutOf_Days_Arear_cutoff = DateDiff(d,@Sal_St_Date_Arear_cutoff,@Sal_END_Date_Arear_cutoff) + 1
								END   
						  END
			END
	-- ENDed by rohit on 20012015



		
		SELECT @Basic_Salary_Arear = IsNull(Basic_Salary,0)
		  FROM T0095_INCREMENT I WITH (NOLOCK) inner join       
			 (SELECT MAX(Increment_Id) AS Increment_Id , Emp_ID FROM T0095_Increment WITH (NOLOCK)    --Changed by Hardik 09/09/2014 for Same Date Increment   
			  WHERE  Increment_Effective_date <= dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year)
			  AND Cmp_ID = @Cmp_ID      
			  GROUP BY emp_ID) Qry on      
			 I.Emp_ID = Qry.Emp_ID AND I.Increment_Id = Qry.Increment_Id   --Changed by Hardik 09/09/2014 for Same Date Increment    
		  WHERE I.Emp_ID = @Emp_ID 
   
   
     -- Added by rohit on 20012015
     
   IF IsNull(@Absent_after_Cutoff_date,0) <> 0
		BEGIN  
		   SELECT @Basic_Salary_Arear_cutoff = IsNull(Basic_Salary,0)
				  FROM T0095_INCREMENT I WITH (NOLOCK) inner join       
					 (SELECT MAX(Increment_Id) AS Increment_Id , Emp_ID FROM T0095_Increment WITH (NOLOCK)   --Changed by Hardik 09/09/2014 for Same Date Increment   
					  WHERE  Increment_Effective_date <= dbo.GET_MONTH_END_DATE(@Arear_Month_cutoff,@Arear_Year_cutoff)
					  AND Cmp_ID = @Cmp_ID      
					  GROUP BY emp_ID) Qry on      
					 I.Emp_ID = Qry.Emp_ID AND I.Increment_Id = Qry.Increment_Id   --Changed by Hardik 09/09/2014 for Same Date Increment    
				  WHERE I.Emp_ID = @Emp_ID 
		END
   -- ENDed by rohit on 20012015
   
   --Above Condition Commented AND Newly added by Sumit 25/07/2016----------------------------------------------------------------------
	IF ((@left_Date >= @Month_St_Date AND @left_Date<=@Month_END_Date) AND @ALLOWED_FULLWEEKOFF_MIDLEFTDAYRATE = 1)
		BEGIN
			SET @ALLOWED_FULLWEEKOFF_MIDLEFTDAYRATE = 2
			SET @Old_tmp_Month_END_Date=DateAdd(d,-1,DateAdd(m,1,@Month_St_Date)) --DateAdd(d,-1,DateAdd(mm, DateDiff(m,0,@Month_St_Date)+1,0))
		END		
	ELSE
		BEGIN
			SET @ALLOWED_FULLWEEKOFF_MIDLEFTDAYRATE = 0			
		END
	IF ((@left_Date >= @Month_St_Date AND @left_Date<=@Month_END_Date) AND @ALLOWED_FULLWEEKOFF_MIDLEFT = 1)
		BEGIN
			--SET @Allowed_Full_WeekOff_MidJoining = 1
			SET @ALLOWED_FULLWEEKOFF_MIDLEFT = 2
			SET @Old_tmp_Month_END_Date=DateAdd(d,-1,DateAdd(m,1,@Month_St_Date))--DateAdd(d,-1,DateAdd(mm, DateDiff(m,0,@Month_St_Date)+1,0))		
		END
	ELSE
		BEGIN
			SET @ALLOWED_FULLWEEKOFF_MIDLEFT = 0 					
		END
	
	IF ((@left_Date >= @Month_St_Date AND @left_Date<=@Month_END_Date AND @Join_Date is not null AND @Join_Date between @Month_St_Date AND @Month_END_Date) AND @ALLOWED_FULLWEEKOFF_MIDLEFTDAYRATE = 2)
		BEGIN			
			SET @ALLOWED_FULLWEEKOFF_MIDLEFTDAYRATE = 1
			--SET @Old_tmp_Month_END_Date=DateAdd(d,-1,DateAdd(m,1,@Month_St_Date)) --DateAdd(d,-1,DateAdd(mm, DateDiff(m,0,@Month_St_Date)+1,0))
		END	-- Added this condition by Sumit on 16112016 when Joining AND FNF both is same month
		
		SET @StrWeekoff_Date_DayRate = '';
		SET @Weekoff_Days_DayRate = 0;
	--------------------------------------------------------------------------------
   
   --SELECT @ALLOWED_FULLWEEKOFF_MIDLEFTDAYRATE
   
   ------------------------ ----------- Added By Ali 09122013 Start  ----------------------------------------------
   			
	EXEC P0210_MONTHLY_LEAVE_INSERT @Cmp_ID ,@Emp_ID,@Month_St_Date,@Month_END_Date,@Sal_Tran_ID
	
	EXEC SP_CURR_T0100_EMP_SHIFT_GET @Emp_Id,@Cmp_ID,@Month_END_Date,null,null,@Shift_Day_Hour output
	--IF @StrHoliday_Date=''
		--SET @StrHoliday_Date=null
		
	IF @Is_Cancel_Holiday_WO_HO_same_day = 1
		BEGIN
			
			--EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output,0,1
			IF (@ALLOWED_FULLWEEKOFF_MIDLEFT > 0 )
				BEGIN
					EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output,0,1,0,'',@ALLOWED_FULLWEEKOFF_MIDLEFT
					
				END
			ELSE
				BEGIN
					EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output,0,1
				END	
			
			EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date
			
		END
	ELSE
		BEGIN
		
			EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID  
			--EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID
			
		
			--IF @Inc_Weekoff <> 1
			--EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output,0,1
			IF (@ALLOWED_FULLWEEKOFF_MIDLEFT > 0 )
				BEGIN							
					EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Old_tmp_Month_END_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output,0,1,0,'',@ALLOWED_FULLWEEKOFF_MIDLEFT
					
				END
			ELSE
				BEGIN
					EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output,0,1--,0,'',@ALLOWED_FULLWEEKOFF_MIDLEFT
				END		
			
			--IF @Inc_Weekoff = 1
			--	EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output,0,0
		END 	
		
		IF (@ALLOWED_FULLWEEKOFF_MIDLEFTDAYRATE > 0)
				BEGIN	
					--EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Old_tmp_Month_END_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output,0,1,0,'',@ALLOWED_FULLWEEKOFF_MIDLEFTDAYRATE
					
					EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Old_tmp_Month_END_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date_DayRate OUTPUT,@Weekoff_Days_DayRate OUTPUT ,@Cancel_Weekoff OUTPUT,0,0,0,'',@ALLOWED_FULLWEEKOFF_MIDLEFTDAYRATE
				END
		ELSE
			BEGIN
				EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date_Dayrate output,@Weekoff_Days_DayRate OUTPUT ,@Cancel_Weekoff output,0,1,0,'',@ALLOWED_FULLWEEKOFF_MIDLEFTDAYRATE
			END			
	
	
	DECLARE @M_Cancel_weekOff NUMERIC(5,1) --Hasmukh 30/01/2012
	DECLARE @M_Cancel_Holiday NUMERIC(5,1) --Hasmukh 31/08/2012
	
	SET @M_Cancel_weekOff = 0 --Hasmukh 30/01/2012
	SET @M_Cancel_Holiday = 0
	
	SELECT  @M_Cancel_weekOff = Cancel_Weekoff_Day,
		@M_Cancel_Holiday = cancel_Holiday
		FROM T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_Id 
		AND Month = MONTH(@Month_END_Date) AND Year = YEAR(@Month_END_Date)
	
	 --Hasmukh for manual cancel weekoff 30012012------
	 
	 IF @M_Cancel_weekOff > 0 AND @Weekoff_Days > 0
		BEGIN 
			--Added by Jaina 26-09-2018
			if @M_Cancel_weekOff > @Weekoff_Days
			begin
				set @M_Cancel_weekOff =  @Weekoff_Days
			end
			
			SET @Weekoff_Days = @Weekoff_Days - @M_Cancel_weekOff
			SET @Cancel_Weekoff = @M_Cancel_weekOff
		END
	 --Hasmukh for manual cancel Holiday 31082012------	
	 IF @M_Cancel_holiday > 0 AND @Holiday_days > 0
		BEGIN 
			SET @Holiday_days = @Holiday_days - @M_Cancel_holiday
			SET @Cancel_Holiday = @M_Cancel_holiday
		END
	-----END hasmukh ----------

	/* Note: Below Condition SET Present Days Zero (0) IF employee Left Previous Month	--Ankit/Hardikbhai 03052016  */
	IF EXISTS (SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE EMP_ID = @EMP_ID AND @Left_Date BETWEEN Month_St_Date AND Month_END_Date )
		BEGIN
			SET @Present_Days = 0
		END
	
	
	IF @Present_Days = 0
		BEGIN
			
			EXEC SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@Month_St_Date,@Month_END_Date,0,0,0,0,0,0,@emp_ID,'',0
			
			
			IF @Is_OT_Auto_Calc = 0
				BEGIN
					update #Data         
						SET OT_Sec = 0 ,Weekoff_OT_Sec = 0, Holiday_OT_Sec = 0 -- * 3600        
						FROM #Data -- d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID AND d.For_Date = oa.For_Date         

				
				
					update #Data         
						  SET OT_Sec = IsNull(Approved_OT_Sec,0), Weekoff_OT_Sec = IsNull(Approved_WO_OT_Sec,0), Holiday_OT_Sec = IsNull(Approved_HO_OT_Sec,0)  -- * 3600        
						FROM #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID AND d.For_Date = oa.For_Date     
				END
					
			SELECT @Present_Days = IsNull(sum(P_Days),0), @Actual_Working_Sec =IsNull(sum(Duration_In_Sec),0), @Emp_OT_Sec = IsNull(sum(OT_Sec),0),@Emp_WO_OT_Sec = IsNull(sum(Weekoff_OT_Sec),0) ,@Emp_HO_OT_Sec =  IsNull(sum(Holiday_OT_Sec),0) FROM  #Data WHERE Emp_ID=@emp_ID 
						AND For_Date>=@Month_St_Date AND For_Date <=@Month_END_Date
		END
	ELSE
		BEGIN
			EXEC SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@Month_St_Date,@Month_END_Date,0,0,0,0,0,0,@emp_ID,'',0
			
			IF @Is_OT_Auto_Calc = 0
				BEGIN
					update #Data         
						SET OT_Sec = 0 ,Weekoff_OT_Sec = 0, Holiday_OT_Sec = 0 -- * 3600        
						FROM #Data -- d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID AND d.For_Date = oa.For_Date         

				
				
					update #Data         
						  SET OT_Sec = IsNull(Approved_OT_Sec,0), Weekoff_OT_Sec = IsNull(Approved_WO_OT_Sec,0), Holiday_OT_Sec = IsNull(Approved_HO_OT_Sec,0)  -- * 3600        
						FROM #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID AND d.For_Date = oa.For_Date     
				END
		
			SELECT @Actual_Working_Sec =IsNull(sum(Duration_In_Sec),0), @Emp_OT_Sec = IsNull(sum(OT_Sec),0),@Emp_WO_OT_Sec = IsNull(sum(Weekoff_OT_Sec),0) ,@Emp_HO_OT_Sec =  IsNull(sum(Holiday_OT_Sec),0) FROM  #Data WHERE Emp_ID=@emp_ID 
						AND For_Date>=@Month_St_Date AND For_Date <=@Month_END_Date
		
		END
	
	SELECT @Shift_Day_Sec	= dbo.F_Return_Sec(@Shift_Day_Hour)
	SELECT @Fix_OT_Shift_Sec = dbo.F_Return_Sec(@Fix_OT_Shift_Hours)
	SELECT @Emp_OT_Min_Sec  = dbo.F_Return_Sec(@Emp_OT_Min_Limit)
	SELECT @Emp_OT_Max_Sec  = dbo.F_Return_Sec(@Emp_OT_Max_Limit)
	SELECT @Actual_Working_Hours = dbo.F_Return_Hours (@Actual_Working_Sec)
	
	IF @Fix_OT_Shift_Sec > 0
		BEGIN  
			SET @Fix_OT_Shift_Sec = @Fix_OT_Shift_Sec
		END  
	ELSE
		BEGIN  
			SET @Fix_OT_Shift_Sec = @Shift_Day_Sec
		END 
	
	
	IF @M_OT_Hours > 0
		SET @Emp_OT_Sec = @M_OT_Hours * 3600
	
	IF @W_OT_Hours > 0    
		SET @Emp_WO_OT_Sec = @W_OT_Hours * 3600 
			   
	IF @H_OT_Hours > 0    
		SET @Emp_HO_OT_Sec = @H_OT_Hours * 3600
	
	
	IF @Inc_Weekoff <> 1	
		BEGIN
			IF @Inc_Holiday <> 1
				BEGIN
					--SET @Working_Days = @OutOf_Days - @WeekOff_Days - @Holiday_days
					SET @Working_Days = @OutOf_Days - case when @ALLOWED_FULLWEEKOFF_MIDLEFT > 0 or @ALLOWED_FULLWEEKOFF_MIDLEFTDAYRATE > 0 then @Weekoff_Days_DayRate ELSE @WeekOff_Days END - @Holiday_days
				END
			ELSE	
				BEGIN
				
					--SET @Working_Days = @OutOf_Days - @WeekOff_Days --Condition Added for Getting full weekoff in case mid left ticked in general setting 26072016
					SET @Working_Days = @OutOf_Days - case when @ALLOWED_FULLWEEKOFF_MIDLEFT > 0 or @ALLOWED_FULLWEEKOFF_MIDLEFTDAYRATE > 0 then @Weekoff_Days_DayRate ELSE @WeekOff_Days END
					--SELECT @Working_Days,@Weekoff_Days_DayRate
				END
		END	
	ELSE
			IF @Inc_Holiday <> 1
				BEGIN
					SET @Working_Days = @OutOf_Days - @Holiday_days
				END
			ELSE	
				BEGIN
					SET @Working_Days = @OutOf_Days 
				END
	
				
	IF @fnf_Fix_Day <> 0 --Added by nilesh patel on 16062015 -- For Fix Day Fnf 
		SET @Working_Days  = @fnf_Fix_Day

	
	SELECT @Total_leave_Days = IsNull(sum(leave_Days),0) FROM T0210_Monthly_LEave_Detail WITH (NOLOCK) WHERE Emp_ID = @emp_ID AND 
						TEMP_SAL_TRAN_ID = @Sal_Tran_ID
	SELECT @Paid_Leave_Days = IsNull(sum(leave_Days),0) FROM T0210_Monthly_LEave_Detail WITH (NOLOCK) WHERE Emp_ID = @emp_ID AND 
						TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Leave_Paid_Unpaid = 'P'
						
						
	DECLARE @No_Encash_Leave NUMERIC(18,2)
	SET @No_Encash_Leave = 0
	
	SELECT @No_Encash_Leave = Lv_Encash_Apr_Days  FROM t0120_Leave_Encash_Approval WITH (NOLOCK) WHERE Emp_ID = @Emp_Id AND Lv_Encash_Apr_Date = @Left_Date
	
	-- commented by mitesh on 04032013
	-----Comment By Ankit after discuss with hardikbhai on 04072015
	--IF @Paid_leave_Days >= @No_Encash_Leave 
	--	BEGIN
	--		SET @Paid_leave_Days = abs(@Paid_leave_Days - @No_Encash_Leave) 		
	--	END
	-----Comment By Ankit after discuss with hardikbhai

	IF @SalaryBasis ='Hour'
		BEGIN
			SET @Leave_Sec = @Paid_Leave_Days * @Shift_Day_Sec
			IF @Inc_Holiday = 1
				SET @Holiday_Sec = @Holiday_Days * @Shift_Day_Sec
			IF @Inc_Weekoff =1
				SET @Weekoff_Sec = @WeekOff_Days * @Shift_Day_Sec
			
			
			SET @Other_Working_Sec = @Leave_Sec + @Holiday_Sec + 	@Holiday_Sec
			SELECT @Working_Hours = dbo.F_Return_Hours (@Other_Working_Sec)
			
		END

	-------------------- Late Deduction ---------------------------
		DECLARE @Late_Absent_Day		NUMERIC(18,2)
		DECLARE @Total_LMark			NUMERIC(18,2)
		DECLARE @Total_Late_Sec			NUMERIC 
		DECLARE @Late_Dedu_Amount		NUMERIC 
		DECLARE @Extra_Late_Dedu_Amount NUMERIC

		SET @Late_Absent_Day = 0
		SET @Total_LMark = 0
		SET @Total_Late_Sec =0



		IF @Fix_late_W_Days =0 AND @Wages_Type = 'Monthly'
			SET @Fix_late_W_Days = @OutOf_Days
		ELSE IF @Wages_Type <> 'Monthly'
			SET @Fix_late_W_Days = 1	
			
			
		
		IF @Fix_late_W_Shift_Sec =0
			SET @Fix_late_W_Shift_Sec =@Shift_Day_Sec
			
		IF @Late_Mark_Scenario = 2 AND @Is_LateMark_Percent = 0 
			BEGIN
				EXEC SP_CALCULATE_LATE_DEDUCTION_SLABWISE @emp_Id,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Late_Absent_Day output,@Total_LMark output,@Total_Late_Sec output,@Increment_ID
			END	
		ELSE IF @Late_Mark_Scenario = 2 AND @Is_LateMark_Percent = 1 AND @Is_LateMark_Calc_On <> 0
			BEGIN
				EXEC SP_CALCULATE_LATE_DEDUCTION_PERCENTAGE @emp_Id,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Increment_ID,'','',0,0,'',@Sal_Tran_ID,@Month_St_Date,@Month_END_Date
			END
		ELSE IF @Late_Mark_Scenario = 3
			BEGIN
				EXEC SP_CALCULATE_LATE_DEDUCTION_DESIGNATION_WISE @emp_Id,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Increment_ID,'','',0,0,'',@Sal_Tran_ID,@Month_St_Date,@Month_END_Date
			END
		ELSE IF @LATE_MARK_SCENARIO = 4
				BEGIN
					EXEC SP_CALCULATE_LATE_DEDUCTION_SCENARIO4 @EMP_ID,@CMP_ID,@MONTH_ST_DATE,@Month_END_Date,@LATE_ABSENT_DAY OUTPUT,@INCREMENT_ID,@STRWEEKOFF_DATE,@STRHOLIDAY_DATE,0,'',0,''
				END
		ELSE
			BEGIN
				EXEC SP_CALCULATE_LATE_DEDUCTION @emp_Id,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Late_Absent_Day output,@Total_LMark output,@Total_Late_Sec output,@Increment_ID
			END		
		
		-- Added by Hardik 03/04/2019 for Genchi, as Late Mark adjust with Leave during F&F
		if @Late_Dedu_Type_inc = 'Day' and Isnull(@Late_is_slabwise,0) = 0 and @Is_late_Mark=1 And @Is_Late_Mark_Gen = 1
			begin
				-- LATE with leave
				exec ADJUST_LATE_EARLY_WITH_LEAVE @emp_Id,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Late_Absent_Day output,@Increment_ID,'L',@tmp_Days_Adjust output    
				SET @tmp_Days_Adjust = 0
			end		
		
		SET @Present_Days = @Present_Days - IsNull(@Late_Absent_Day,0)
		IF @SalaryBasis ='Hour' 
			BEGIN
				SET @Actual_Working_Sec = @Actual_Working_Sec - ( IsNull(@Late_Absent_Day,0) * @Shift_Day_Sec)
				SELECT @Actual_Working_Hours = dbo.F_Return_Hours (@Actual_Working_Sec)
			END
	----------------------------END -------------------------------
	

						
	IF @Present_Days > @Working_Days AND @Restrict_Present_Days = 'Y'
		BEGIN
			SET @Present_Days = @Working_Days
		END
		
		
	--IF @Inc_Weekoff = 1
		--SET @Sal_cal_Days = @Present_Days + @Holiday_Days + @Weekoff_Days + @Paid_Leave_Days
	--ELSE
		--SET @Sal_cal_Days = @Present_Days + @Holiday_Days + @Paid_Leave_Days
	  --changed by Falak on 20-Jan-2011 
	   IF @Inc_Weekoff = 1    
		BEGIN
			IF @Inc_Holiday = 1
				BEGIN
						SET @Sal_cal_Days = @Present_Days +  @Weekoff_Days + @Paid_Leave_Days + @Holiday_Days
						--SET @Sal_cal_Days = @Present_Days +  @Weekoff_Days + @Holiday_Days
				END
			ELSE 		
				BEGIN
						SET @Sal_cal_Days = @Present_Days +  @Weekoff_Days + @Paid_Leave_Days  
					--SET @Sal_cal_Days = @Present_Days +  @Weekoff_Days 
				END
		   END
		 ELSE 
		 BEGIN
		   IF @Inc_Holiday = 1
				BEGIN
					SET @Sal_cal_Days = @Present_Days  + @Paid_Leave_Days + @Holiday_Days
					--SET @Sal_cal_Days = @Present_Days  + @Holiday_Days
				END
			ELSE
				BEGIN 		
					SET @Sal_cal_Days = @Present_Days  + @Paid_Leave_Days  
				--	SET @Sal_cal_Days = @Present_Days  
				END
		   END

	IF @Sal_cal_Days > @Working_Days AND @Restrict_Present_Days = 'Y'
		SET @Sal_cal_Days = @Working_Days 
	
	--Added by Jaina 06-05-2019 Start
	
	if @Emp_Part_Time = 1
		SET @Sal_cal_days =   @Sal_cal_Days/2     
	--Added by Jaina 06-05-2019 End
	
	SET @Absent_Days = @Total_Actual_Days - (@Present_Days +  @WeekOff_Days + @Holiday_Days + @Paid_Leave_Days)
	--SET @Absent_Days = @Outof_Days - (@Present_Days +  @WeekOff_Days + @Holiday_Days)
	
	IF @Absent_Days < 0 
		SET @Absent_Days =0
	
	
	Set @numAbsentDays= @Absent_Days
	--SELECT @Present_Days AS P_Days,@Working_Days AS W_Days
	
	IF @Wages_Type = 'Monthly' 
		IF @Inc_Weekoff = 1
			BEGIN
				IF @Inc_Holiday = 1
					BEGIN
					    IF @fnf_Fix_Day <> 0 --Added by nilesh patel on 16062015
							BEGIN
								SET @Day_Salary = 	@Basic_Salary / @fnf_Fix_Day 
								
								IF @OutOf_Days_Arear > 0
									SET @Day_Salary_Arear = @Basic_Salary_Arear / @OutOf_Days_Arear -- Added By Ali 09122013
								
								SET @Gross_Salary_ProRata = @Actual_Gross_Salary/@fnf_Fix_Day
								SET @Day_Salary_Arear_cutoff = case when IsNull(@OutOf_Days_Arear_cutoff,0)=0 then 0 ELSE @Basic_Salary_Arear_cutoff / @OutOf_Days_Arear_cutoff END -- added by rohit on 20012015
							END
						ELSE
							BEGIN
								SET @Day_Salary = 	@Basic_Salary / @Outof_Days
								 
								IF @OutOf_Days_Arear > 0
									SET @Day_Salary_Arear = IsNull(@Basic_Salary_Arear,0) / IsNull(@OutOf_Days_Arear,0) -- Added By Ali 09122013
								
								SET @Gross_Salary_ProRata = @Actual_Gross_Salary/@Outof_Days
								SET @Day_Salary_Arear_cutoff = case when IsNull(@OutOf_Days_Arear_cutoff,0)=0 then 0 ELSE @Basic_Salary_Arear_cutoff / @OutOf_Days_Arear_cutoff END -- added by rohit on 20012015
							END 
					END
				ELSE
					BEGIN
						SET @Day_Salary = 	@Basic_Salary / @Working_Days
						SET @Day_Salary_Arear = @Basic_Salary_Arear / @Working_days -- Added By Ali 09122013
						SET @Gross_Salary_ProRata = @Actual_Gross_Salary/@Working_Days
						SET @Day_Salary_Arear_cutoff = @Basic_Salary_Arear_cutoff / @Working_days -- Added By rohit on 20012015
					END		
			END 
		ELSE
			BEGIN
				SET @Day_Salary = 	@Basic_Salary / @Working_Days
				SET @Day_Salary_Arear = @Basic_Salary_Arear / @Working_days -- Added By Ali 09122013
				SET @Gross_Salary_ProRata = @Actual_Gross_Salary/@Working_Days
				SET @Day_Salary_Arear_cutoff = @Basic_Salary_Arear_cutoff / @Working_days 
			END 
	ELSE
		BEGIN	
		SET @Day_Salary = 	@Basic_Salary
		SET @Day_Salary_Arear = @Basic_Salary_Arear -- Added By Ali 09122013
		SET @Day_Salary_Arear_cutoff = @Basic_Salary_Arear_cutoff -- Added by rohit on 20012015
		SET @Gross_Salary_ProRata = @Actual_Gross_Salary -- Added by Hardik 02/01/2019 for Shaily, LWF Amount not calculating
	END
		
	IF IsNull(@Shift_Day_Sec,0) < = 0
		SET @Shift_Day_Sec=28800
		 
SET @OT_Working_Day =  @Working_Days

IF @SalaryBasis='Fix Hour Rate'--Nikunj 19-04-2011
	BEGIN			 		
		 SET @Hour_Salary = @Day_Salary
	END
ELSE
	BEGIN
		SET @Hour_Salary = @Day_Salary * 3600/@Shift_Day_Sec
		--SET @Hour_Salary_OT = @Day_Salary * 3600/@Fix_OT_Shift_Sec ---COMMENTED BY RAJPUT ON 17072018 GENERAL SETTING DAY WISE NOT CALCULATED
		
		IF UPPER(@Wages_Type) = 'MONTHLY'	--CODE ADDED BY RAJPUT ON 17/07/2017 
			BEGIN
				IF ISNULL(@Fix_OT_Work_Days,0) = 0
					IF ISNULL(@Fix_OT_Shift_Sec,0) > 0
						SET @Hour_Salary_OT = @Day_Salary * 3600  /  @Fix_OT_Shift_Sec        
					ELSE
						SET @Hour_Salary_OT = @Day_Salary * 3600  /  @Shift_Day_Sec	
				ELSE
					IF ISNULL(@Fix_OT_Shift_Sec,0) > 0
						SET @Hour_Salary_OT =  (@Basic_Salary / @Fix_OT_Work_Days) * 3600  /  @Fix_OT_Shift_Sec
					ELSE
						SET @Hour_Salary_OT =  (@Basic_Salary / @Fix_OT_Work_Days) * 3600  /  @Shift_Day_Sec
			END
			ELSE
				BEGIN
					If ISNULL(@Fix_OT_Shift_Sec,0) > 0
						SET @Hour_Salary_OT = @Day_Salary * 3600  /  @Fix_OT_Shift_Sec        
					Else
						SET @Hour_Salary_OT = @Day_Salary * 3600  /  @Shift_Day_Sec	
				END
	END	
	
	--SET @Hour_Salary	= @Day_Salary * 3600	/  @Shift_Day_Sec	 
	--Set	@Hour_Salary_OT = @Day_Salary * 3600    /  @Shift_Day_Sec 
	

	
	IF @SalaryBasis ='Day'
		BEGIN
			IF @IS_ROUNDING = 1
				BEGIN
					SET @Salary_Amount  = Round(@Day_Salary * @Sal_Cal_Days,@Round)
					SET @Salary_amount_Arear = ROUND(@Day_Salary_Arear * @arear_Days,@Round) -- Added by Ali 09122013
					SET @Salary_amount_Arear_cutoff = ROUND(@Day_Salary_Arear_cutoff * @Absent_after_Cutoff_date ,@Round) 
				END		
			ELSE
				BEGIN
					SET @Salary_Amount  = IsNull(@Day_Salary * @Sal_Cal_Days,0)
					SET @Salary_amount_Arear = IsNull(@Day_Salary_Arear * @arear_Days,0) -- Added by Ali 09122013
					SET @Salary_amount_Arear_cutoff = IsNull(@Day_Salary_Arear_cutoff * @Absent_after_Cutoff_date ,0) 
				END
		END		
	ELSE
		BEGIN
			IF @IS_ROUNDING = 1
				SET @Salary_Amount  = Round(@Hour_Salary * (@Actual_Working_Sec+ @Other_Working_Sec)/3600,@Round)
			ELSE
				SET @Salary_Amount  = IsNull(@Hour_Salary * (@Actual_Working_Sec+ @Other_Working_Sec)/3600,0)
		END
		
	
		
	
	IF @Wages_Type ='Monthly'
		SET @Late_Basic_Amount = @Basic_salary
	ELSE
		SET @Late_Basic_Amount = @Day_Salary

		
		SET @Gross_Salary_ProRata = Round(@Gross_Salary_ProRata * @Sal_Cal_Days,@Round)
	
	IF IsNull(@GROSS_SALARY_PRORATA,0) = 0	--Added By Ramiz on 11/07/2016 AS Gross Salary is when Gross is 0 , LWF not to be deducted
		BEGIN
			SET @LWF_Amount = 0
		END
			
	--IF @EMP_OT = 1
	--	BEGIN
	--		IF @Emp_OT_Sec > 0  AND @Emp_OT_Min_Sec > 0 AND @Emp_OT_Sec < @Emp_OT_Min_Sec
	--			SET @Emp_OT_Sec = 0
	--		ELSE IF @Emp_OT_Sec > 0 AND @Emp_OT_Max_Sec > 0 AND @Emp_OT_Sec > @Emp_OT_Max_Sec
	--			SET @Emp_OT_Sec = @Emp_OT_Max_Sec
				
	--		IF @Emp_OT_Sec > 0
	--			SET @OT_Amount = round((@Emp_OT_Sec/3600) * @Hour_Salary_OT,0)
				
	--		IF @ExOTSetting > 0 AND @OT_Amount > 0
	--			SET @OT_Amount = @OT_Amount + @OT_Amount * @ExOTSetting 
				
	--		SELECT @Emp_OT_Hours = dbo.F_Return_Hours(@Emp_OT_Sec)
	--	END
	--ELSE
	--	BEGIN
	--		SET @Emp_OT_Sec = 0
	--		SET @OT_Amount = 0
	--		SET @Emp_OT_Hours = '00:00'
	--	END
	
	--Mafatlals Code Added By Ramiz on 02/06/2016--
	DECLARE @Curr_For_date		DATETIME
	DECLARE @Grade_BasicSalary	NUMERIC(18, 4)
	DECLARE @Grade_Name			VARCHAR(100)
	DECLARE @DA_E_ad_Amount		NUMERIC(18, 4)
	DECLARE	@DA_Amount_0433		NUMERIC(18, 4)
	DECLARE	@DA_Amount_0144		NUMERIC(18, 4)
	DECLARE @DA_M_ad_Amount		NUMERIC(18, 4)
	DECLARE @Grd_Leave_Used		NUMERIC(18, 4)
	DECLARE @BasicDA_OT_Salary	NUMERIC(18, 4)
	DECLARE @Grade_BasicSalary_Night	NUMERIC(18,2)
	DECLARE @Gradewise_Salary_Enabled	tinyint    --Added By Ramiz for Mafatlals
	DECLARE @Grd_Id AS NUMERIC
	
	SET @Grade_BasicSalary	= 0
	SET @DA_E_ad_Amount		= 0
	SET @DA_Amount_0433		= 0
	SET @DA_Amount_0144		= 0
	SET @DA_M_ad_Amount		= 0
	SET @Grd_Leave_Used		= 0
	SET @BasicDA_OT_Salary  = 0
	SET @Grade_BasicSalary_Night = 0
	SET @Gradewise_Salary_Enabled = 0
	SET @Grd_Id = 0
	

	SET @Grd_Id = @Grade_ID --As in SP of Prorata , All Code is done on @GRD_Id , so I have SET the Valuse in @GRD_ID , so code will remain Same
	SELECT @Grade_BasicSalary = IsNull(Fix_Basic_Salary,0) , @Grade_BasicSalary_Night = IsNull(Fix_Basic_Salary_Night,0) FROM T0040_GRADE_MASTER WITH (NOLOCK) WHERE Grd_ID = @Grd_Id						


	IF (@Grade_BasicSalary > 0 OR @Grade_BasicSalary_Night > 0)  --Added By Ramiz on 28/12/2015 for Mafatlals Grade wise Salary
		BEGIN

			SET @Day_Salary = @Grade_BasicSalary
			
			SELECT @DA_E_ad_Amount = EED.E_AD_AMOUNT 
			FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID
			WHERE EED.EMP_ID = @emp_id AND AM.CMP_ID = @Cmp_id AND AM.AD_DEF_ID = 11 --( Def Id 11 : DA)
	
		
			----Updating Revised Allowance Starts here By Ramiz on 07/10/2015
			SELECT @DA_E_ad_Amount =
				(SELECT 
				 Case When Qry1.FOR_DATE >= EED.FOR_DATE Then
					Case When Qry1.E_Ad_Amount IS NULL Then eed.E_AD_Amount ELSE Qry1.E_Ad_Amount END 
				 ELSE
					eed.e_ad_Amount END AS E_Ad_Amount
			FROM dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN                    
				   dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID   LEFT OUTER JOIN
					( SELECT EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE 
						FROM T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
						( SELECT MAX(For_Date) For_Date, Ad_Id FROM T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
							WHERE Emp_Id = @Emp_Id
							AND For_date <= @Month_END_Date
						 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date AND Eedr.Ad_Id = Qry.Ad_Id 
					) Qry1 on eed.AD_ID = qry1.ad_Id AND EEd.EMP_ID = Qry1.EMP_ID                  
			WHERE EED.EMP_ID = @emp_id AND increment_id = @Increment_Id AND Adm.AD_ACTIVE = 1 AND Adm.AD_DEF_ID = 11
					AND Case When Qry1.ENTRY_TYPE IS NULL Then '' ELSE Qry1.ENTRY_TYPE END <> 'D'
			UNION 
			
			SELECT E_AD_Amount
			FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
				( SELECT MAX(For_Date) For_Date, Ad_Id FROM T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
					WHERE Emp_Id  = @Emp_Id AND For_date <= @Month_END_Date 
					Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date AND EED.Ad_Id = Qry.Ad_Id                   
			   INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID                     
			WHERE emp_id = @emp_id AND Adm.AD_DEF_ID = 11
					AND Adm.AD_ACTIVE = 1
					AND EEd.ENTRY_TYPE = 'A')

			   
			 Delete FROM #DA_Allowance
			  
			INSERT INTO #DA_Allowance	--Insert Master Grade ID
				( Grd_Id , Grd_Count )
			SELECT @Grd_ID , 0
		
			
			INSERT INTO #DA_Allowance	--Day Shift--Insert Employee Grade change Grd_Id & P Days
				( Grd_Id , Grd_Count )
			SELECT Grd_ID , SUM(D.P_days) 
			FROM T0100_EMP_GRADE_DETAIL EGD WITH (NOLOCK) INNER JOIN 
				#Data D ON EGD.Emp_ID = D.Emp_Id AND EGD.For_Date = D.For_date 
			WHERE EGD.EMP_ID = @EMP_ID AND EGD.For_Date BETWEEN @Month_St_Date AND @Month_END_Date AND D.P_days <> 0
				AND CONVERT(VARCHAR(8),Shift_Start_Time,108) < CONVERT(VARCHAR(8),Shift_END_Time,108) AND EGD.Grd_ID <> @Grd_Id
			GROUP BY EGD.Grd_ID
			
			--'' Below Condition Check For Work On Night shift
			IF EXISTS(SELECT 1 FROM #Data WHERE Emp_Id = @Emp_Id AND P_days <> 0  AND CONVERT(VARCHAR(8),Shift_Start_Time,108) > CONVERT(VARCHAR(8),Shift_END_Time,108))
				BEGIN
					INSERT INTO #DA_Allowance	--Insert Master Grade ID - Night shift
						( Grd_Id , Grd_Count,Day_Night_Flag )
					SELECT @Grd_ID , 0 ,1
					
					INSERT INTO #DA_Allowance	--Night Shift--Insert Employee Grade change Grd_Id & P Days	
						( Grd_Id , Grd_Count ,Day_Night_Flag )
					SELECT Grd_ID , SUM(D.P_days) ,1 
					FROM T0100_EMP_GRADE_DETAIL EGD WITH (NOLOCK) INNER JOIN 
						#Data D ON EGD.Emp_ID = D.Emp_Id AND EGD.For_Date = D.For_date 
					WHERE EGD.EMP_ID = @EMP_ID AND EGD.For_Date BETWEEN @Month_St_Date AND @Month_END_Date AND D.P_days <> 0
						AND CONVERT(VARCHAR(8),D.Shift_Start_Time,108) > CONVERT(VARCHAR(8),D.Shift_END_Time,108) AND EGD.Grd_ID <> @Grd_Id
					GROUP BY EGD.Grd_ID
					
						
					UPDATE #DA_Allowance		--Update Master Grade P Days //Night Shift
					SET Grd_Count = ( SELECT SUM(P_days) FROM #Data 
										WHERE Emp_Id = @Emp_Id AND P_days <> 0  AND CONVERT(VARCHAR(8),Shift_Start_Time,108) > CONVERT(VARCHAR(8),Shift_END_Time,108)) - IsNull(( SELECT SUM(Grd_Count) FROM #DA_Allowance WHERE Day_Night_Flag = 1 ),0)
					WHERE Grd_Id = @Grd_Id AND Day_Night_Flag = 1
					
					
				END	
				
			UPDATE #DA_Allowance		--Update Master Grade P Days //Day shift
			SET Grd_Count = ( SELECT SUM(P_days) FROM #Data 
								WHERE Emp_Id = @Emp_Id AND P_days <> 0 ) - IsNull(( SELECT SUM(Grd_Count) FROM #DA_Allowance ),0)
			WHERE Grd_Id = @Grd_Id AND Day_Night_Flag = 0
			
			--IF It is "Include Holiday" in General Setting then that days should be Added in Dayrate Calculation
			IF @Inc_Holiday = 1
				BEGIN
					UPDATE #DA_Allowance		--Update Master Grade P Days //Day shift
					SET Grd_Count = IsNull(Grd_Count,0) + IsNull(@Holiday_Days,0)
					WHERE Grd_Id = @Grd_Id AND Day_Night_Flag = 0
				END
			
			SELECT @Grd_Leave_Used =(IsNull(Sum(Leave_Used),0) + IsNull(Sum(CompOff_Used),0)) 
			FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) 
			Left JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.LEAVE_ID = LT.LEAVE_ID
			WHERE Emp_ID = @Emp_id AND LEAVE_PAID_UNPAID = 'P' AND For_Date BETWEEN @Month_St_Date AND @Month_END_Date
			
			UPDATE #DA_Allowance
			SET Grd_Count = IsNull(Grd_Count,0) + IsNull(@Grd_Leave_Used,0)
			WHERE Grd_Id  = @Grd_Id AND IsNull(Day_Night_Flag,0) = 0
			
			
			SET @DA_Amount_0433 = @DA_E_ad_Amount * 0.433
			SET @DA_Amount_0144 = @DA_E_ad_Amount * 0.144
			
			UPDATE #DA_Allowance	--Calcualte DA Allowance on Day
			SET Basic_Salary = (GM.Fix_Basic_Salary / 26 ) * DA.Grd_Count,
				DA_Allow_Salary = 
					CASE WHEN GM.Fix_Basic_Salary >= 400 THEN
						((400 * @DA_Amount_0433) / 100 + (( GM.Fix_Basic_Salary - 400 ) * @DA_Amount_0144	) / 100) / 26 * DA.Grd_Count
					ELSE
						((GM.Fix_Basic_Salary * @DA_Amount_0433) / 100 ) / 26 * DA.Grd_Count
					END 
			FROM #DA_Allowance DA INNER JOIN
				T0040_GRADE_MASTER GM ON DA.Grd_Id = GM.Grd_ID
			WHERE Day_Night_Flag = 0
								
			UPDATE #DA_Allowance	--Calcualte DA Allowance on Night
			SET		Basic_Salary = (GM.Fix_Basic_Salary_Night / 26 ) * DA.Grd_Count,
					DA_Allow_Salary = 
						CASE WHEN GM.Fix_Basic_Salary_Night >= 400 THEN
							((400 * @DA_Amount_0433) / 100 + (( GM.Fix_Basic_Salary_Night - 400 ) * @DA_Amount_0144	) / 100) / 26 * DA.Grd_Count
						ELSE
							((GM.Fix_Basic_Salary_Night * @DA_Amount_0433) / 100 ) / 26 * DA.Grd_Count
						END
			FROM #DA_Allowance DA INNER JOIN
				T0040_GRADE_MASTER GM ON DA.Grd_Id = GM.Grd_ID
			WHERE Day_Night_Flag = 1
			
			
			DECLARE @Grd_count_OT NUMERIC(18,0)
			DECLARE @Grd_Basic_OT NUMERIC(18,0)
			
			SELECT @Grd_count_OT = SUM(Grd_Count) FROM #DA_Allowance WHERE Grd_id <> @Grd_id 
			
			IF @Grd_count_OT >= 14
			   BEGIN 
					SELECT TOP 1 @Grd_Basic_OT = GM.Fix_Basic_Salary FROM #DA_Allowance DA INNER JOIN
						T0040_GRADE_MASTER GM WITH (NOLOCK) ON DA.Grd_Id = GM.Grd_ID WHERE DA.Grd_id <> @Grd_id
			   END
			ELSE
				BEGIN
					SELECT @Grd_Basic_OT = GM.Fix_Basic_Salary FROM T0040_GRADE_MASTER GM WITH (NOLOCK)  WHERE Grd_id = @Grd_id
				END
			  
				
			IF @Grd_Basic_OT >= 400 
				BEGIN
				   SET  @BasicDA_OT_Salary = @Grd_Basic_OT + ((400 * @DA_Amount_0433) / 100 + (( @Grd_Basic_OT - 400 ) * @DA_Amount_0144	) / 100) 
				END
			ELSE
				BEGIN
				   SET @BasicDA_OT_Salary = @Grd_Basic_OT + ((@Grd_Basic_OT * @DA_Amount_0433) / 100 ) 
				END
			
			SELECT @Salary_Amount = SUM(Basic_Salary) --,@BasicDA_OT_Salary = SUM(BasicDA_OT_Salary)  
			FROM #DA_Allowance 
			
			
			SET @Salary_Amount = ROUND(@Salary_Amount,0)
			SET @BasicDA_OT_Salary = ROUND(@BasicDA_OT_Salary,0)
	END		
	--Mafatlals Code Added By Ramiz on 02/06/2016--
	--------------hasmukh-----------------
		DECLARE @Emp_OT_Hours_Var AS VARCHAR(10)--Nikunj
		DECLARE @Emp_OT_Hours_Num AS NUMERIC(18,2)--Nikunj		   
		DECLARE @Emp_WO_OT_Hours_Var AS VARCHAR(10) --Hardik 29/11/2011
		DECLARE @Emp_WO_OT_Hours_Num AS NUMERIC(22,3)--Hardik 29/11/2011
		DECLARE @Emp_HO_OT_Hours_Var AS VARCHAR(10) --Hardik 29/11/2011
		DECLARE @Emp_HO_OT_Hours_Num AS NUMERIC(22,3)--Hardik 29/11/2011
	

		--Added by Hardik 14/11/2018 for Shift Wise OT Rate, For Shoft Ship Yard 
		Set @Shift_Wise_OT_Calculated = 0
		
		If @EMP_OT = 1 And @Shift_Wise_OT_Rate = 1 And Isnull(@Emp_WD_OT_Rate,0) = 9 And Isnull(@Emp_WO_OT_Rate,0) = 9 And Isnull(@Emp_HO_OT_Rate,0) = 9
			BEGIN
				SELECT	D.EMP_ID, D.Shift_ID, D.For_Date, 
						Case When @Is_OT_Auto_Calc = 1 Then Isnull(D.OT_Sec,0) Else Isnull(OA.Approved_OT_Sec,0) End As OT_Sec, 
						Case When @Is_OT_Auto_Calc = 1 Then Isnull(D.Holiday_OT_Sec,0) Else Isnull(OA.Approved_HO_OT_Sec,0) End As Holiday_OT_Sec, 
						Case When @Is_OT_Auto_Calc = 1 Then Isnull(D.Weekoff_OT_Sec,0) Else Isnull(OA.Approved_WO_OT_Sec,0) End As Weekoff_OT_Sec, 
						Case WHEN H.For_Date IS NOT NULL THEN SM.Shift_Holiday_OT_Rate ELSE 0 END HO_OT_Rate,
						Case WHEN W.For_Date IS NOT NULL THEN SM.Shift_WeekOff_OT_Rate ELSE 0 END WO_OT_Rate,
						Case WHEN H.For_Date IS NULL AND W.For_Date IS NULL Then SM.Shift_WeekDay_OT_Rate Else 0 END As WD_OT_Rate,
						Cast(0.00 As Numeric(18,2)) As HO_OT_Amount, 
						Cast(0.00 As Numeric(18,2)) As WO_OT_Amount, 
						Cast(0.00 As Numeric(18,2)) As WD_OT_Amount,
						Cast(Isnull(@Hour_Salary_OT,0) As Numeric(18,4)) As Hourly_Salary
				INTO	#ShiftWiseOT
				FROM	#Data D
						INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON D.Shift_ID=SM.Shift_ID
						LEFT OUTER JOIN (SELECT Id,Cast(Data As Datetime)as For_Date FROM dbo.Split(@StrWeekoff_Date,';')) W On D.For_date = W.For_Date
						LEFT OUTER JOIN (SELECT Id,Cast(Data As Datetime)as For_Date FROM dbo.Split(@StrHoliday_Date,';')) H On D.For_date = H.For_Date
						--LEFT OUTER JOIN #Emp_WeekOff_Sal W ON D.Emp_ID=W.Emp_ID AND D.For_Date = W.For_Date AND W.Is_Cancel=0
						--LEFT OUTER JOIN #Emp_Holiday_Sal H ON D.Emp_ID=H.Emp_ID AND D.For_Date = H.For_Date AND H.Is_Cancel=0
						LEFT OUTER JOIN T0160_OT_APPROVAL OA WITH (NOLOCK) ON OA.Emp_ID=D.Emp_Id And OA.For_Date = D.For_Date And OA.Is_Approved = 1
				WHERE	D.Emp_Id = @Emp_Id And D.For_date Between @Month_St_Date And @Month_End_Date


				DELETE	#ShiftWiseOT 
				WHERE	(ISNULL(HO_OT_Rate,0) + ISNULL(WO_OT_Rate,0) + ISNULL(WD_OT_Rate,0) = 0) OR
						(ISNULL(OT_Sec,0) + ISNULL(Holiday_OT_Sec,0) + ISNULL(Weekoff_OT_Sec,0) = 0)

				/*
				UPDATE	#ShiftWiseOT
				SET		HO_OT_Amount = Cast(Replace(dbo.F_Return_Hours(Holiday_OT_Sec),':','.') As Numeric(18,2)) * HO_OT_Rate * @Hour_Salary_OT,
						WO_OT_Amount = Cast(Replace(dbo.F_Return_Hours(Weekoff_OT_Sec),':','.')As Numeric(18,2)) * WO_OT_Rate * @Hour_Salary_OT,
						WD_OT_Amount = Cast(Replace(dbo.F_Return_Hours(OT_Sec),':','.')As Numeric(18,2)) * WD_OT_Rate * @Hour_Salary_OT
				*/
				
				UPDATE	#ShiftWiseOT
				SET		HO_OT_Amount = (Holiday_OT_Sec/3600) * HO_OT_Rate * @Hour_Salary_OT,
						WO_OT_Amount = (Weekoff_OT_Sec/3600) * WO_OT_Rate * @Hour_Salary_OT,
						WD_OT_Amount = (OT_Sec/3600) * WD_OT_Rate * @Hour_Salary_OT

				SELECT
					@Emp_HO_OT_Hours_Num = Cast(Replace(dbo.F_Return_Hours(SUM(Holiday_OT_Sec)),':','.') As Numeric(18,2)),
					@Emp_HO_OT_Hours_Var = Cast(Replace(dbo.F_Return_Hours(SUM(Holiday_OT_Sec)),':','.') As Numeric(18,2)),
					@Emp_HO_OT_Sec = Sum(Holiday_OT_Sec), 
					@HO_OT_Amount = Isnull(Case When @IS_ROUNDING = 1 Then Round(Sum(HO_OT_Amount),0) Else Sum(HO_OT_Amount) End,0),
					
					@Emp_WO_OT_Hours_Num = Cast(Replace(dbo.F_Return_Hours(SUM(Weekoff_OT_Sec)),':','.') As Numeric(18,2)),
					@Emp_WO_OT_Hours_Var = Cast(Replace(dbo.F_Return_Hours(SUM(Weekoff_OT_Sec)),':','.') As Numeric(18,2)),
					@Emp_WO_OT_Sec = Sum(Weekoff_OT_Sec), 
					@WO_OT_Amount = Isnull(Case When @IS_ROUNDING = 1 Then Round(Sum(WO_OT_Amount),0) Else Sum(WO_OT_Amount) End,0),
					
					@Emp_OT_Hours_Num = Cast(Replace(dbo.F_Return_Hours(SUM(OT_Sec)),':','.') As Numeric(18,2)),
					@Emp_OT_Hours_Var = Cast(Replace(dbo.F_Return_Hours(SUM(OT_Sec)),':','.') As Numeric(18,2)),
					@Emp_OT_Sec = Sum(OT_Sec), 
					@OT_Amount = Isnull(Case When @IS_ROUNDING = 1 Then Round(Sum(WD_OT_Amount),0) Else Sum(WD_OT_Amount) End,0)
				FROM #ShiftWiseOT

				If @Fix_OT_Work_Days > 0 
					SET @Fix_OT_Work_Days = @Fix_OT_Work_Days
				Else
					SET @Fix_OT_Work_Days = @OT_Working_Day
						
				Insert into #OT_Data(Emp_Id,Basic_Salary,Day_Salary,OT_Sec,Ex_OT_SEtting,OT_Amount,Shift_Day_Sec,OT_Working_Day,Emp_OT_Hour,Hourly_Salary,WO_OT_Amount,WO_OT_Hour,WO_OT_Sec,HO_OT_Amount,HO_OT_Hour,HO_OT_Sec)
				select @Emp_ID,@Basic_Salary,@Day_Salary,@Emp_OT_Sec,@ExOTSetting,@OT_Amount,@Fix_OT_Shift_Sec,@Fix_OT_Work_Days,@Emp_OT_Hours_Num,@Hour_Salary_OT,@WO_OT_Amount,@Emp_WO_OT_Hours_Num,@Emp_WO_OT_Sec,@HO_OT_Amount,@Emp_HO_OT_Hours_Num,@Emp_HO_OT_Sec

				select @Emp_OT_Hours = dbo.F_Return_Hours(@Emp_OT_Sec)   
				select @Emp_WO_OT_Hours = dbo.F_Return_Hours(@Emp_WO_OT_Sec)     
				select @Emp_HO_OT_Hours = dbo.F_Return_Hours(@Emp_HO_OT_Sec)  
			
				
				Set @Shift_Wise_OT_Calculated = 1
			END	


IF @EMP_OT = 1 And @Shift_Wise_OT_Calculated = 0   
		BEGIN
		
		   IF @Emp_OT_Sec > 0  AND @Emp_OT_Min_Sec > 0 AND @Emp_OT_Sec < @Emp_OT_Min_Sec    
				SET @Emp_OT_Sec = 0    
		   ELSE IF @Emp_OT_Sec > 0 AND @Emp_OT_Max_Sec > 0 AND @Emp_OT_Sec > @Emp_OT_Max_Sec    
				SET @Emp_OT_Sec = @Emp_OT_Max_Sec    
				
		
		  if Isnull(@Is_OT_Adj_against_Absent,0) = 1 -- Added by nilesh patel on 02072018 -- For OT Adjust against Absent days -- Enpay Client 
			Begin	
				if Isnull(@Absent_Days,0) > 0
				Begin
					Declare @Absent_Sec Numeric(18,0)
					Set @Absent_Sec = 0

					Declare @Total_OT_Sec Numeric(18,2)
					Set @Total_OT_Sec = 0 

					Declare @OT_Remain_Sec Numeric(18,2)
					Set @OT_Remain_Sec = 0

					Set @Absent_Sec = @Shift_Day_Sec * @Absent_Days
									
									
					if (@Emp_OT_Sec + @Emp_WO_OT_Sec) > @Absent_Sec
						Begin
							Set @OT_Adj_Days = @Absent_Days
							Set @Present_Days = @Present_Days + @Absent_Days
							Set @Absent_Days = 0
							Set @Emp_OT_Sec = (@Emp_OT_Sec + @Emp_WO_OT_Sec) - @Absent_Sec
							SET @Emp_WO_OT_Sec = 0
							--if @Emp_OT_Sec > @Absent_Sec
							--   Begin
							--		Set @Emp_OT_Sec = @Emp_OT_Sec - @Absent_Sec
							--   End
							--else
							--   Begin
							--		Set @Absent_Sec = @Absent_Sec - @Emp_OT_Sec
							--		Set @Emp_WO_OT_Sec = @Emp_WO_OT_Sec - @Absent_Sec
							--   End
							Set @Sal_cal_Days = @Sal_cal_Days + @OT_Adj_Days				
						End
					Else
						Begin
							If (@Emp_OT_Sec + @Emp_WO_OT_Sec) % ((@Shift_Day_Sec/(3600 *2)) * 3600) = 0
								Begin
									Set @Absent_Sec = @Absent_Sec - (@Emp_OT_Sec + @Emp_WO_OT_Sec)
									Set @OT_Adj_Days = (@Emp_OT_Sec + @Emp_WO_OT_Sec)/@Shift_Day_Sec
									Set @Absent_Days = @Absent_Days - @OT_Adj_Days
									Set @Present_Days = @Present_Days + @OT_Adj_Days
									Set @Emp_OT_Sec = 0
									Set @Emp_WO_OT_Sec = 0
									Set @Sal_cal_Days = @Sal_cal_Days + @OT_Adj_Days
								End
							Else
								Begin
									Set @OT_Remain_Sec = (@Emp_OT_Sec + @Emp_WO_OT_Sec) % ((@Shift_Day_Sec/(3600 *2)) * 3600)
									Set @Emp_OT_Sec = (@Emp_OT_Sec + @Emp_WO_OT_Sec) - @OT_Remain_Sec
									Set @Absent_Sec = @Absent_Sec - (@Emp_OT_Sec + @Emp_WO_OT_Sec)
									Set @OT_Adj_Days = @Emp_OT_Sec /@Shift_Day_Sec
									Set @Absent_Days = @Absent_Days - @OT_Adj_Days
									Set @Present_Days = @Present_Days + @OT_Adj_Days
									Set @Emp_OT_Sec = @OT_Remain_Sec
									Set @Emp_WO_OT_Sec = 0
									Set @Sal_cal_Days = @Sal_cal_Days + @OT_Adj_Days
								End
						End
				End
			End	
				
			IF(ISNULL(@OT_RATE_TYPE,0) = 0)  --- AS OLD CONDITION ---
				BEGIN	
					
					IF @Emp_OT_Sec > 0   
						BEGIN 
							SET @OT_Amount = round((@Emp_OT_Sec/3600) * (@Hour_Salary_OT * @Emp_WD_OT_Rate ),0)      				
							SET @Emp_OT_Hours_Var = dbo.F_Return_Hours(@Emp_OT_Sec)    --Nikunj
							SET @Emp_OT_Hours_Var =Replace(@Emp_OT_Hours_Var,':','.')--Nikunj
							SET @Emp_OT_Hours_Num= Convert (NUMERIC(18,2), @Emp_OT_Hours_Var)--Nikunj   				  
						END
					
					IF @Emp_WO_OT_Sec > 0    
						BEGIN
							
							SET @WO_OT_Amount = round((@Emp_WO_OT_Sec/3600) * (@Hour_Salary_OT * @Emp_WO_OT_Rate ),0)      				
							SET @Emp_WO_OT_Hours_Var = dbo.F_Return_Hours(@Emp_WO_OT_Sec)
							SET @Emp_WO_OT_Hours_Var = Replace(@Emp_WO_OT_Hours_Var,':','.')
							SET @Emp_WO_OT_Hours_Num = Convert (NUMERIC(22,3), @Emp_WO_OT_Hours_Var)
						END
						
					IF @Emp_HO_OT_Sec > 0    
						BEGIN
							
							SET @HO_OT_Amount = round((@Emp_HO_OT_Sec/3600) * (@Hour_Salary_OT * @Emp_HO_OT_Rate ),0)      				
							SET @Emp_HO_OT_Hours_Var = dbo.F_Return_Hours(@Emp_HO_OT_Sec)
							SET @Emp_HO_OT_Hours_Var = Replace(@Emp_HO_OT_Hours_Var,':','.')
							SET @Emp_HO_OT_Hours_Num = Convert (NUMERIC(22,3), @Emp_HO_OT_Hours_Var)
						END
							
					SET @OT_Amount = IsNull(@OT_Amount,0)
					SET @WO_OT_Amount = IsNull(@WO_OT_Amount,0)
					SET @HO_OT_Amount = IsNull(@HO_OT_Amount,0)
						
				END
			ELSE
				BEGIN
							
							---- GENCHI CLIENT FLOW FOR OVERTIME SLAB WISE WORK ----
									If @Emp_OT_Sec > 0 OR  @Emp_WO_OT_Sec > 0 OR @Emp_HO_OT_Sec > 0
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
												
											IF(@Emp_WO_OT_Sec > 0)
												BEGIN
													SET @Emp_WO_OT_Hours_Var = dbo.F_Return_Hours(@Emp_WO_OT_Sec)
													Set @Emp_WO_OT_Hours_Var = Replace(@Emp_WO_OT_Hours_Var,':','.')	
													
												END
											IF(@Emp_HO_OT_Sec > 0)
												BEGIN
													SET @Emp_HO_OT_Hours_Var = dbo.F_Return_Hours(@Emp_HO_OT_Sec)
													Set @Emp_HO_OT_Hours_Var = Replace(@Emp_HO_OT_Hours_Var,':','.')
												END
													
											DECLARE @OT_SLAB_DWOHO_HOURS AS NUMERIC(18,2) = 0
														
											IF EXISTS(SELECT 1 FROM DBO.T0050_GENERAL_OT_RATE_SLABWISE WITH (NOLOCK) WHERE Gen_ID=@GEN_ID AND @OT_SLAB_TYPE = 0)
												BEGIN
														INSERT INTO #OT_SLAB_MASTER
														SELECT	ROW_NUMBER() OVER (ORDER BY WO_RATE ASC) AS ROW_ID,FROM_HOURS,TO_HOURS,WD_RATE,WO_RATE,HO_RATE,0 AS PERIOD_HOURS,0 AS OT_HOURS,0 AS OT_SLAB_AMOUNT,0 AS FLAG 
														FROM DBO.T0050_GENERAL_OT_RATE_SLABWISE WITH (NOLOCK)
														WHERE GEN_ID=@GEN_ID 	
															
														
														set @Emp_OT_Hours_Num = @Emp_OT_Sec/3600
														set @Emp_WO_OT_Hours_Num = @Emp_WO_OT_Sec/3600 
														set @Emp_HO_OT_Hours_Num = @Emp_HO_OT_Sec/3600 
														
														
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
																				
																			SET @OT_SLAB_AMOUNT = ROUND(@Hour_Salary_OT * @WD_RATE * @SLAB_DIFF,0) 
																			
																		END
																	ELSE
																		BEGIN									
																			SET @OT_SLAB_AMOUNT = (@Hour_Salary_OT) * @WD_RATE * @SLAB_DIFF
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
																					SET @OT_SLAB_AMOUNT = ROUND(@Hour_Salary_OT * @WD_RATE * @OT_HOURS,0)
																					
																				END
																			ELSE
																				BEGIN									
																					SET @OT_SLAB_AMOUNT = (@Hour_Salary_OT) * @WD_RATE * @OT_HOURS
																				END
																			
																			
																			UPDATE #OT_SLAB_MASTER SET PERIOD_HOURS = @SLAB_DIFF,OT_HOURS = @OT_HOURS ,OT_SLAB_AMOUNT = @OT_SLAB_AMOUNT,FLAG = 1 WHERE From_Hours = @FROM_HOURS AND
																			TO_HOURS = @TO_HOURS AND WD_Rate = @WD_RATE
																				
																			
																		END
																END
																
														    
														  
															SET @OT_HOURS = @OT_HOURS - @SLAB_DIFF
															
															
															
															FETCH NEXT FROM OT_SLAB_CURSOR     
															INTO @FROM_HOURS,@TO_HOURS,@WD_RATE,@FLAG
														END     
														CLOSE OT_SLAB_CURSOR;    
														DEALLOCATE OT_SLAB_CURSOR;  
														
														
														SELECT @OT_Amount=SUM(OT_SLAB_AMOUNT) 
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
															
															set @Emp_OT_Hours_Num = @Emp_OT_Sec/3600
															set @Emp_WO_OT_Hours_Num = @Emp_WO_OT_Sec/3600 
															set @Emp_HO_OT_Hours_Num = @Emp_HO_OT_Sec/3600 
															
															
															SET @OT_SLAB_DWOHO_HOURS = @Emp_OT_Hours_Num + @Emp_WO_OT_Hours_Num +  @Emp_HO_OT_Hours_Num
															SET @OT_HOURS = @OT_SLAB_DWOHO_HOURS
															
															SELECT @WD_RATE = WD_RATE FROM #OT_SLAB_MASTER
															WHERE  @OT_HOURS BETWEEN FROM_HOURS AND TO_HOURS
															
														   
															IF @IS_ROUNDING = 1   
																BEGIN
																	SET @OT_SLAB_AMOUNT = ROUND(@Hour_Salary_OT * @WD_RATE * @OT_HOURS,0) 
																END
															ELSE
																BEGIN
																	SET @OT_SLAB_AMOUNT = (@Hour_Salary_OT) * @WD_RATE * @OT_HOURS
																END
																
															SET @OT_AMOUNT = @OT_SLAB_AMOUNT
															
														END
													ELSE
														BEGIN
															SET @OT_AMOUNT = 0
														END
														
														
												END	
													
										END
									ELSE
										BEGIN
											SET @OT_AMOUNT = 0
										END		
							---- END ----
							
						END		
						
		   --IF @ExOTSetting > 0 AND @OT_Amount > 0    
		   -- SET @OT_Amount = @OT_Amount + @OT_Amount * @ExOTSetting
			
			IF @Fix_OT_Work_Days > 0 
				BEGIN
					SET @Fix_OT_Work_Days = @Fix_OT_Work_Days
				END
			ELSE
				BEGIN
					SET @Fix_OT_Work_Days = @OT_Working_Day
				END    
			
			  --New Code of Mafatlals Added By Ramiz on 02062016 --
		IF (@Grade_BasicSalary > 0 OR @Grade_BasicSalary_Night > 0) AND @BasicDA_OT_Salary > 0	--Overtime Calcualte Basic + DA Allowance	--Mafatlal Client	--**Ankit 27082015
			BEGIN
			
				DECLARE @OT_Max_Limit_Sec AS NUMERIC
				DECLARE @OT_Min_Limit_Sec AS NUMERIC
				
				SET @OT_Max_Limit_Sec = NULL
				SET @OT_Min_Limit_Sec = NULL
            
				SET @WO_OT_Amount = 0
				SET @HO_OT_Amount = 0
				SET @OT_Amount = 0
				
				SET @Emp_OT_Hours_Num = IsNull(@Emp_OT_Hours_Num,0) + IsNull(@Emp_WO_OT_Hours_Num,0) + IsNull(@Emp_HO_OT_Hours_Num,0)
			    
				--New Code for Checking Monthly Max Limit is Added By Ramiz for Mafatlal on 19/11/2015
				SET @Emp_OT_Sec			= dbo.F_Return_Sec(replace(CAST(@Emp_OT_Hours_Num AS VARCHAR(20)),'.',':'))
				SET @OT_Min_Limit_Sec	= dbo.F_Return_Sec(replace(CAST(@OT_Min_Limit AS VARCHAR(20)),'.',':'))
				SET @OT_Max_Limit_Sec	= dbo.F_Return_Sec(replace(CAST(@OT_Max_Limit AS VARCHAR(20)),'.',':'))

				IF @Emp_OT_Sec > 0  AND @OT_Min_Limit_Sec > 0 AND @Emp_OT_Sec < @OT_Min_Limit_Sec
					BEGIN  
						SET @Emp_OT_Sec = 0   
					END
				ELSE IF @Emp_OT_Sec > 0 AND @OT_Max_Limit_Sec > 0 AND @Emp_OT_Sec > @OT_Max_Limit_Sec
					BEGIN    
						SET @Emp_OT_Sec = @OT_Max_Limit_Sec 
					END

				SET @Emp_OT_Hours_Num = Replace(dbo.F_Return_Hours(@Emp_OT_Sec), ':' , '.')
				--New Code for Checking Monthly Max Limit is Added By Ramiz for Mafatlal on 19/11/2015

				IF Replace(@Fix_OT_Shift_Hours,':','.') = '' OR @Fix_OT_Shift_Hours = '00:00'
					SET @Fix_OT_Shift_Hours = '08:00'


				SET @Hour_Salary_OT = @BasicDA_OT_Salary / 26 / Replace(@Fix_OT_Shift_Hours,':','.')

				SET @OT_Amount = ROUND((@Emp_OT_Hours_Num) * (@Hour_Salary_OT * @Emp_WD_OT_Rate ),0)      

			END  
			--ENDed By Ramiz on 02062016
  
		   INSERT INTO #OT_Data(Emp_Id,Basic_Salary,Day_Salary,OT_Sec,Ex_OT_SEtting,OT_Amount,Shift_Day_Sec,OT_Working_Day,Emp_OT_Hour,Hourly_Salary,WO_OT_Amount,WO_OT_Hour,WO_OT_Sec,HO_OT_Amount,HO_OT_Hour,HO_OT_Sec)
		   SELECT @Emp_ID,@Basic_Salary,@Day_Salary,@Emp_OT_Sec,@ExOTSetting,@OT_Amount,@Fix_OT_Shift_Sec,@Fix_OT_Work_Days,@Emp_OT_Hours_Num,@Hour_Salary_OT,@WO_OT_Amount,@Emp_WO_OT_Hours_Num,@Emp_WO_OT_Sec,@HO_OT_Amount,@Emp_HO_OT_Hours_Num,@Emp_HO_OT_Sec
		   
		   
		   
		   SELECT @Emp_OT_Hours = dbo.F_Return_Hours(@Emp_OT_Sec)   
		   SELECT @Emp_WO_OT_Hours = dbo.F_Return_Hours(@Emp_WO_OT_Sec)     
		   SELECT @Emp_HO_OT_Hours = dbo.F_Return_Hours(@Emp_HO_OT_Sec)    
		   
		  END    
	ELSE    
		IF @Shift_Wise_OT_Calculated = 0   
		  BEGIN    
			   SET @Emp_OT_Sec = 0    
			   SET @OT_Amount = 0    
			   SET @Emp_OT_Hours = '00:00' 
			   
			   SET @Emp_WO_OT_Sec = 0    
			   SET @WO_OT_Amount = 0    
			   SET @Emp_WO_OT_Hours = '00:00'  
			   
			   SET @Emp_HO_OT_Sec = 0    
			   SET @HO_OT_Amount = 0    
			   SET @Emp_HO_OT_Hours = '00:00'     
			   
			   INSERT INTO #OT_Data(Emp_Id,Basic_Salary,Day_Salary,OT_Sec,Ex_OT_SEtting,OT_Amount,OT_Working_Day)
			   SELECT @Emp_ID,@Basic_Salary,@Day_Salary,0,0,0,0
			   
		  END
	--------------------------------------

	   --------ALTER By : Nilay -- for Basic salary effect 50% of CTC Saalry ---------------------------
       IF @Wages_Amount = 1
         BEGIN 
					 DECLARE @Gr_Days AS NUMERIC(18,2)
					 DECLARE @Gr_Salary_amount AS  NUMERIC(18,2)
					 SET @Gr_Days =0
					 SET @Gr_Salary_amount =0
					 SELECT @Gr_Salary_amount = Gross_salary,@Salary_Amount= Basic_Salary FROM T0095_Increment WITH (NOLOCK) WHERE increment_id = @Increment_ID    
					 SET   @Gr_Salary_amount = Round(@Gr_Salary_amount * @Sal_cal_days/@Outof_Days,0) 
					 SET   @Salary_Amount =  ROUND(@Gr_Salary_amount/2 ,0)
					 SET   @Basic_Salary =  @Salary_Amount
					 
         END
  --------ALTER By : Nilay -- for Basic salary effect 50% of CTC Saalry ---------------------------
	
	--Added by nilesh patel on 01082018 -- Count Night shift Assign 
						
	Select @Night_Shift_Count =  COUNT(1) 
	From #Data 
	Where CONVERT(time,Shift_Start_Time) > CONVERT(time,Shift_End_Time) and Emp_ID = @Emp_ID 
		and For_Date >= @month_St_Date 
		AND For_Date <= @Month_End_Date
	
	--Added by nilesh patel on 01082018 -- Count Night shift Assign	
	EXEC SP_CALCULATE_ALLOWANCE_DEDUCTION @Sal_Tran_ID,@emp_ID,@Cmp_ID,@Increment_ID,@month_St_Date,@Month_END_Date,@Wages_type,@Basic_Salary,@Gross_Salary_ProRata,@Salary_Amount,@Present_Days,@numAbsentDays,0,@Sal_Cal_Days,@Working_Days,@OT_Amount output,@Day_Salary ,@Branch_ID,@M_IT_Tax,null,0,1,@Working_Days,0,@IS_ROUNDING, @WO_OT_Amount output , @HO_OT_Amount output,null,null,@arear_Days,@Arear_Month,@Arear_Year,@Salary_amount_Arear,1,@OutOf_Days_Arear,@Absent_after_Cutoff_date,@Arear_Month_cutoff,@Arear_Year_cutoff,@Salary_amount_Arear_cutoff,@OutOf_Days_Arear_cutoff,0,NULL,@Night_Shift_Count   -- Added By Ali 09122013

ABC:

	EXEC SP_CALCULATE_ALLOWANCE_DEDUCTION_FNF @Sal_Tran_ID,@emp_ID,@Cmp_ID,@Increment_ID,@month_St_Date,@Month_END_Date,@Wages_type,@Basic_Salary,@Gross_Salary_ProRata,@Salary_Amount,@Present_Days,@numAbsentDays,0,@Sal_Cal_Days,@Working_Days,@OT_Amount output,@Day_Salary ,@Branch_ID,@M_IT_Tax,null,0

	EXEC SP_CALCULATE_ALLOWANCE_DEDUCTION_FOR_FNF @Sal_Tran_ID,@emp_ID,@Cmp_ID,@Increment_ID,@month_St_Date,@Month_END_Date,@Wages_type,@Basic_Salary,@Gross_Salary_ProRata,@Salary_Amount,@Present_Days,@numAbsentDays,0,@Sal_Cal_Days,@Working_Days,@OT_Amount output,@Day_Salary ,@Branch_ID,@M_IT_Tax,null,0
		


DECLARE @Reim_Allowance NUMERIC(22,0)	
DECLARE @Temp_Allowance NUMERIC(22,0)
DECLARE  @Temp_Allowance_Arear NUMERIC(22,2) -- Added By Ali 09122013
DECLARE @Temp_Deduction NUMERIC(22,0)
DECLARE  @Temp_Deduction_Arear NUMERIC(22,2) -- Added By Ali 09122013
SET @Temp_Allowance=0
SET @Temp_Deduction=0
SET @Temp_Allowance_Arear = 0
SET @Temp_Deduction_Arear = 0
SET @Reim_Allowance =0

DECLARE @FNF_Allowance NUMERIC(22,0)
DECLARE @FNF_Deduction NUMERIC(22,0)
SET @FNF_Allowance=0
SET @FNF_Deduction=0

-- Added by rohit on 20012015
DECLARE  @Temp_Allowance_Arear_cutoff NUMERIC(22,2) 
DECLARE  @Temp_Deduction_Arear_cutoff NUMERIC(22,2) 
SET @Temp_Allowance_Arear_cutoff =0
SET @Temp_Deduction_Arear_cutoff =0

-- ENDed by rohit on 20012015
    --Old Code Commented - Deepali _25122023 -Start    
 --SELECT @Allow_Amount = SUM(IsNull(M_AD_AMOUNT,0)) FROM T0210_MONTHLY_AD_DETAIL  WITH (NOLOCK)      
 --WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='I'      
 --and T0210_MONTHLY_AD_DETAIL.M_AD_NOT_EFFECT_ON_PT = 0
 --AND AD_ID not in (SELECT AD_ID FROM T0050_AD_Master WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID
 --AND IsNull(T0210_MONTHLY_AD_DETAIL.M_AD_NOT_EFFECT_SALARY,0) = 1 OR IsNull(Ad_Effect_Month,'')<>''  )     
 
           --Old Code Commented - Deepali _25122023 -End
		   
		      --New Code Added - Deepali _25122023 -Start  
 SELECT @Allow_Amount = SUM(IsNull(M_AD_AMOUNT,0)) FROM T0210_MONTHLY_AD_DETAIL  WITH (NOLOCK)      
 WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='I'      
 --and T0210_MONTHLY_AD_DETAIL.M_AD_NOT_EFFECT_ON_PT = 0   Commented - Deepali _25122023 -
 AND AD_ID not in (SELECT AD_ID FROM T0050_AD_Master WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID  and( IsNull(T0210_MONTHLY_AD_DETAIL.M_AD_NOT_EFFECT_SALARY,0) = 1 OR IsNull(Ad_Effect_Month,'')<>'')  )  
      --New Code Added - Deepali _25122023 -End  
	  
--  SELECT @Reim_Allowance = SUM(IsNull(M_AD_AMOUNT,0)) FROM T0210_MONTHLY_AD_DETAIL       --Changed M_AD_Amount to ReimAmount by Hardik 04/10/2017 for Autopaid and Claim base Reimbursement at SLS
  SELECT @Reim_Allowance = SUM(IsNull(ReimAmount,0)) FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)       
   WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='I'      
    AND AD_ID  in (SELECT AD_ID FROM T0050_AD_Master WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID AND IsNull(T0210_MONTHLY_AD_DETAIL.M_AD_NOT_EFFECT_SALARY,0) = 1 AND IsNull(Allowance_Type,'A') ='R'  )          
 
  ----Ankit 12082016

---Commented by Hardik 04/10/2017 as below code is same as above code
	--DECLARE @Rim_Allwance_paid NUMERIC(18,2)
	--SET @Rim_Allwance_paid = 0
	
	--SELECT @Rim_Allwance_paid = SUM(IsNull(ReimAmount,0)) FROM T0210_MONTHLY_AD_DETAIL       
	--WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='I'      
	--	AND AD_ID  IN ( SELECT AD_ID FROM T0050_AD_Master AM --INNER JOIN T0120_RC_Approval RA ON AM.AD_ID = RA.RC_ID
	--					WHERE AM.CMP_ID =@Cmp_ID AND IsNull(T0210_MONTHLY_AD_DETAIL.M_AD_NOT_EFFECT_SALARY,0) = 1 
	--					AND IsNull(Allowance_Type,'A') ='R'  
	--					AND Payment_date BETWEEN @Month_St_Date AND @Month_END_Date
	--					AND Emp_ID = @Emp_ID 
	--					AND IsNull(RC_Apr_Effect_In_Salary,0) = 1 AND APR_Status =1
	--				   )
  
  
	--SET @Allow_Amount = IsNull(@Allow_Amount,0) + IsNull(@Rim_Allwance_paid,0)

   --Below Code Comment Ankit - 12082016  
   ---Uncommented by Hardik 04/10/2017
   SET @Allow_Amount = IsNull(@Allow_Amount,0) + Isnull(@Reim_Allowance,0)
   
----Ankit 12082016        
 
 
SELECT @Temp_Allowance = SUM(IsNull(M_AD_AMOUNT,0)) FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)       
   WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='I'      
    AND AD_ID  in (SELECT AD_ID FROM T0050_AD_Master WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID AND IsNull(T0210_MONTHLY_AD_DETAIL.M_AD_NOT_EFFECT_SALARY,0) = 0 AND Charindex(@Strmonth,Ad_Effect_Month )<> 0)           
    
   
---------------------- Added By Ali 09122013 Start --------------------------------    

 SELECT @Allow_Amount_Arear = SUM(IsNull(M_AREAR_AMOUNT,0)) FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)      
		WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='I' AND Cmp_Id=@Cmp_ID       
			AND AD_ID not in (SELECT AD_ID FROM T0050_AD_Master WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID AND IsNull(AD_Not_effect_salary,0) = 1 OR IsNull(Ad_Effect_Month,'')<>'')

 SELECT @Temp_Allowance_Arear = SUM(IsNull(M_AREAR_AMOUNT,0)) FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)      
		WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='I'  AND Cmp_Id=@Cmp_ID      
			AND AD_ID  in (SELECT AD_ID FROM T0050_AD_Master WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID AND IsNull(AD_Not_effect_salary,0) = 0 AND Charindex(@Strmonth,Ad_Effect_Month )<> 0)

---------------------- Added By Ali 09122013 END  ---------------------------------- 
-- Added by rohit on 20012015
 SELECT @Allow_Amount_Arear_cutoff = SUM(IsNull(M_AREAR_AMOUNT_Cutoff,0)) FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)      
		WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='I' AND Cmp_Id=@Cmp_ID       
			AND AD_ID not in (SELECT AD_ID FROM T0050_AD_Master WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID AND IsNull(AD_Not_effect_salary,0) = 1 OR IsNull(Ad_Effect_Month,'')<>'')

 SELECT @Temp_Allowance_Arear_cutoff = SUM(IsNull(M_AREAR_AMOUNT_Cutoff,0)) FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)      
		WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='I'  AND Cmp_Id=@Cmp_ID      
			AND AD_ID  in (SELECT AD_ID FROM T0050_AD_Master WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID AND IsNull(AD_Not_effect_salary,0) = 0 AND Charindex(@Strmonth,Ad_Effect_Month )<> 0)

-- ENDed by rohit on 20012015


-- don't open this code IF need then ask to hasmukbhai
--SELECT @FNF_Allowance = SUM(IsNull(M_AD_AMOUNT,0)) FROM EMP_FNF_ALLOWANCE_DETAILS EFAD inner join
--  T0210_MONTHLY_AD_DETAIL  MAD on EFAD.FNF_ID=MAD.M_Ad_TRan_ID
--   WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND MAD.Emp_ID = @Emp_ID AND m_AD_Flag ='I'  
  
 

SET  @Allow_Amount = IsNull(@Allow_Amount,0) + IsNull(@Temp_Allowance,0) + IsNull(@FNF_Allowance,0)
                 
 SELECT @Dedu_Amount = SUM(IsNull(M_AD_AMOUNT,0)) FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)      
   WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='D'      
    AND AD_ID not in (SELECT AD_ID FROM T0050_AD_Master WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID AND  IsNull(T0210_MONTHLY_AD_DETAIL.M_AD_NOT_EFFECT_SALARY,0) = 1 OR IsNull(Ad_Effect_Month,'')<>'')       
 
 SELECT @Temp_Deduction = SUM(IsNull(M_AD_AMOUNT,0)) FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)      
   WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='D'      
    AND AD_ID  in (SELECT AD_ID FROM T0050_AD_Master WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID AND IsNull(T0210_MONTHLY_AD_DETAIL.M_AD_NOT_EFFECT_SALARY,0) = 0 AND Charindex(@Strmonth,Ad_Effect_Month )<> 0)           

---------------------- Added By Ali 09122013 Start --------------------------------    
    
    SELECT @Dedu_Amount_Arear = SUM(IsNull(M_AREAR_AMOUNT,0)) FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)       
		WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='D' AND Cmp_Id=@Cmp_ID       
			AND AD_ID not in (SELECT AD_ID FROM T0050_AD_Master WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID AND  IsNull(AD_Not_effect_salary,0) = 1 OR IsNull(Ad_Effect_Month,'')<>'')

	SELECT @Temp_Deduction_Arear = SUM(IsNull(M_AREAR_AMOUNT,0)) FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)      
		WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='D' AND Cmp_Id=@Cmp_ID       
			AND AD_ID  in (SELECT AD_ID FROM T0050_AD_Master WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID AND IsNull(AD_Not_effect_salary,0) = 0 AND Charindex(@Strmonth,Ad_Effect_Month )<> 0)           
			
---------------------- Added By Ali 09122013 END  ---------------------------------- 
-- Added by rohit on 20012015

 SELECT @Dedu_Amount_Arear_cutoff = SUM(IsNull(M_AREAR_AMOUNT_Cutoff,0)) FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)      
		WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='D' AND Cmp_Id=@Cmp_ID       
			AND AD_ID not in (SELECT AD_ID FROM T0050_AD_Master WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID AND  IsNull(AD_Not_effect_salary,0) = 1 OR IsNull(Ad_Effect_Month,'')<>'')

	SELECT @Temp_Deduction_Arear_cutoff = SUM(IsNull(M_AREAR_AMOUNT_Cutoff,0)) FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)      
		WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='D' AND Cmp_Id=@Cmp_ID       
			AND AD_ID  in (SELECT AD_ID FROM T0050_AD_Master WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID AND IsNull(AD_Not_effect_salary,0) = 0 AND Charindex(@Strmonth,Ad_Effect_Month )<> 0)           

-- ENDed by rohit on 20012015			


    -- don't open this code IF need then ask to hasmukbhai
   --SELECT @FNF_Deduction = SUM(IsNull(M_AD_AMOUNT,0)) FROM EMP_FNF_ALLOWANCE_DETAILS EFAD inner join
   --T0210_MONTHLY_AD_DETAIL  MAD on EFAD.FNF_ID=MAD.M_Ad_TRan_ID
   --WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND MAD.Emp_ID = @Emp_ID AND m_AD_Flag ='D'       
    
SET @Dedu_Amount = IsNull(@Dedu_Amount,0) + IsNull(@Temp_Deduction,0) + IsNull(@FNF_Deduction,0) 

	
	/*SELECT @Allow_Amount = SUM(IsNull(M_AD_AMOUNT,0)) FROM T0210_MONTHLY_AD_DETAIL 
			WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='I' AND IsNull(M_AD_Not_effect_salary,0) =0
				
																	
	SELECT @Dedu_Amount = SUM(IsNull(M_AD_AMOUNT,0)) FROM T0210_MONTHLY_AD_DETAIL 
			WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='D' AND IsNull(M_AD_Not_effect_salary,0) =0
				
	*/			
	SET @Dedu_Amount = IsNull(@Dedu_Amount,0)
	SET @Allow_Amount = IsNull(@Allow_Amount,0)
	SET @Allow_Amount_Arear = IsNull(@Allow_Amount_Arear,0) + IsNull(@Temp_Allowance_Arear,0) -- Added By Ali 09122013
	SET @Dedu_Amount_Arear = IsNull(@Dedu_Amount_Arear,0) + IsNull(@Temp_Deduction_Arear,0) -- Added By Ali 09122013
	SET @Allow_Amount_Arear = IsNull(@Allow_Amount_Arear,0) -- Added By Ali 09122013
	SET @Dedu_Amount_Arear = IsNull(@Dedu_Amount_Arear,0) -- Added By Ali 09122013
	--SET @Short_Fall_Days =0
  
   -- Added by rohit on 20012015
	SET @Allow_Amount_Arear_cutoff = IsNull(@Allow_Amount_Arear_cutoff,0) + IsNull(@Temp_Allowance_Arear_cutoff,0) -- Added By Ali 09122013
	SET @Dedu_Amount_Arear_cutoff = IsNull(@Dedu_Amount_Arear_cutoff,0) + IsNull(@Temp_Deduction_Arear_cutoff,0) -- Added By Ali 09122013
	
	-- ENDed by rohit on 20012015
 
  
	--IF @Short_Fall_Days =0 AND @Short_Fall_Days_Cons > 0 AND @Is_Short_Fall =1
	--	BEGIN
		   
	--		DECLARE @T_Amount NUMERIC 
	--		SET @T_Amount = 0
			
	--		SELECT @Reg_Accept_Date = IsNull(Reg_Accept_Date,Left_Date), @Left_Date =Left_Date FROM T0100_Left_Emp WHERE Emp_ID =@Emp_ID
			
	--		SET @Short_Fall_Days = DateDiff(d,@Reg_Accept_Date,@Left_Date)	
	--		SET @Short_Fall_Days = @Short_Fall_Days_Cons - @Short_Fall_Days
			
		   
	--		IF @Short_Fall_Days > 0
	--			BEGIN
				  
	--				EXEC dbo.P0200_MONTHLY_SALARY_GENERATE_SHORT_FALL 0,@Emp_ID,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Short_Fall_Days,@G_Short_Fall_W_Days,@Is_Gradewise_Short_Fall
					
	--				SELECT @Short_Fall_Dedu_Amount =  IsNull(Gross_Salary,0) FROM #Salary WHERE Emp_ID=@Emp_ID
					
	--			END
	--		ELSE			
	--			SET @Short_Fall_Days = 0
	--	END
	
	
	IF @Short_Fall_Days > 0
		BEGIN
		
			EXEC dbo.P0200_MONTHLY_SALARY_GENERATE_SHORT_FALL 0,@Emp_ID,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Short_Fall_Days,@G_Short_Fall_W_Days,@Is_Gradewise_Short_Fall
			
			--SELECT @Short_Fall_Dedu_Amount =  IsNull(Gross_Salary,0) FROM #Salary WHERE Emp_ID=@Emp_ID
			if @Lv_Encash_Cal_On = 'Basic'
				SELECT @Short_Fall_Dedu_Amount =  IsNull(Salary_Amount,0) FROM #Salary WHERE Emp_ID=@Emp_ID
			else
				SELECT @Short_Fall_Dedu_Amount =  IsNull(Gross_Salary,0) FROM #Salary WHERE Emp_ID=@Emp_ID
			
		END
	ELSE	
		BEGIN		
			SET @Short_Fall_Days = 0
		END
	
	IF @Is_Gratuity_Cal =1 AND @Is_Gr_App =1
		BEGIN
			
			DECLARE @Gratuity_Year NUMERIC
			DECLARE @Left_Date_Gratuity Datetime	
			DECLARE @Emp_Death tinyint
			EXEC SP_GRATUITY_EMP_RECORD_GET_FNF @Cmp_ID,@Month_St_Date,@Month_END_Date,@Branch_ID,0,0,0,0,0,@Emp_ID,''
			SET @Gratuity_Year =0

			SET @Emp_Death = 0
			--Change by Deepali -101221 - for Gratuity calculation depending on TxtGratuity_Year
			--SELECT @Gratuity_Year = IsNull(Gr_Year,0) FROM #Gratuity
			SET @Gratuity_Year= @TxtGratuity_Year
			SELECT @Emp_Death = Is_Death FROM T0100_LEFT_EMP WITH (NOLOCK) WHERE Emp_Id=@Emp_ID
			

			IF @Gratuity_Year > 0 OR @Emp_Death = 1
				BEGIN
					
					SELECT @Left_Date_Gratuity =Left_Date FROM T0100_Left_Emp WITH (NOLOCK) WHERE Emp_ID =@Emp_ID
					--Change by Deepali -131221
					EXEC P0100_GRATUITY_CALCULATION 0,@Cmp_ID,@Emp_ID,@Left_Date_Gratuity,@Sal_Generate_Date,'Last Basic','I',1,@TxtGratuity_Year ,@Gratuity_Months  -- Added By Deepali 11122021
					
					--'' Ankit 10052016
					DECLARE @Gratuity_Cal_Admin_Setting NUMERIC
					SET @Gratuity_Cal_Admin_Setting = 0
					SELECT @Gratuity_Cal_Admin_Setting = Setting_Value FROM T0040_SETTING WITH (NOLOCK)  WHERE Cmp_ID = @Cmp_ID AND Setting_Name = 'Gratuity Amount Hide In FNF Letter'
					
					IF @Gratuity_Cal_Admin_Setting = 0
						BEGIN
							SELECT @Gratuity_Amount = IsNull(SUM(GR_Amount),0) FROM T0100_GRATUITY WITH (NOLOCK) WHERE Emp_ID =@Emp_ID AND Gr_FNF =1
						END
					--'' Ankit 10052016
					
					--SELECT @Gratuity_Amount = IsNull(sum(GR_Amount),0) FROM T0100_GRATUITY WHERE Emp_ID =@Emp_ID AND Gr_FNF =1
					
				END		
		END	
	IF @Is_Bonus =1 AND @Is_Yearly_Bonus =1 
		BEGIN
			
			IF @Bonus_Amount > 0 
			BEGIN 
				
				EXEC dbo.P0180_BONUS 0,@Cmp_ID,@Emp_ID,@Last_Bonus_Date,@Bonus_To_Date,'Fix',@Yearly_Bonus_Per,@Bonus_Amount,1,@Month,@Year,'','I',1
				
			END	
			ELSE
			BEGIN
				--Change Bonus Calculated on 'Basic To Consolidated' --Ankit 19082016
				
				If @Bonus_calculate_On = 0
					BEGIN
						EXEC dbo.P0180_BONUS 0,@Cmp_ID,@Emp_ID,@Last_Bonus_Date,@Bonus_To_Date,'Consolidated',@Yearly_Bonus_Per,@Bonus_Amount,1,@Month,@Year,'','I',1
					END
				ELSE If @Bonus_calculate_On = 1
					BEGIN
						
							DECLARE	@BONUS_FROMDATE_REGULAR_EXGRATIA AS DATETIME
							DECLARE	@BONUS_TODATE_REGULAR_EXGRATIA AS DATETIME
							SET	@BONUS_TODATE_REGULAR_EXGRATIA = @LEFT_DATE
							IF EXISTS(SELECT 1 FROM T0180_BONUS WITH (NOLOCK) WHERE EMP_ID = @EMP_ID AND UPPER(BONUS_CAL_TYPE) = 'REGULAR BONUS'And Bonus_Calculated_On = 'Allowance')
								BEGIN
										SELECT TOP 1	@BONUS_FROMDATE_REGULAR_EXGRATIA = DATEADD(D,1,TO_DATE)
										FROM			T0180_BONUS WITH (NOLOCK) 
										WHERE			EMP_ID = @EMP_ID AND UPPER(BONUS_CAL_TYPE) = 'REGULAR BONUS' And Bonus_Calculated_On = 'Allowance'
										ORDER BY		TO_DATE DESC
								END
							ELSE
								BEGIN
										SELECT @BONUS_FROMDATE_REGULAR_EXGRATIA = DBO.GET_MONTH_ST_DATE(MONTH(DATE_OF_JOIN),YEAR(DATE_OF_JOIN))
										FROM	T0080_EMP_MASTER WITH (NOLOCK)
										WHERE	EMP_ID = @EMP_ID
								END

							EXEC dbo.P0180_BONUS @Bonus_ID = 0,@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@From_Date = @BONUS_FROMDATE_REGULAR_EXGRATIA,
														@To_Date = @BONUS_TODATE_REGULAR_EXGRATIA,@Bonus_Calculated_On = 'Allowance',@Bonus_Percentage = @Yearly_Bonus_Per,
														@Bonus_Fix_Amount = @Bonus_Amount,@Bonus_Effect_on_Sal = 1,@Bonus_Effect_Month = @Month,@Bonus_Effect_Year =@Year,
														@Bonus_Comments = '',@tran_type = 'I',@Is_FNF = 1,@Bonus_Cal_Type = 'Regular Bonus'


						IF EXISTS(SELECT 1 FROM T0180_BONUS WITH (NOLOCK) WHERE EMP_ID = @EMP_ID AND UPPER(BONUS_CAL_TYPE) = 'EXGRATIA BONUS' And Bonus_Calculated_On = 'Allowance')
								BEGIN
										SELECT TOP 1	@BONUS_FROMDATE_REGULAR_EXGRATIA = DATEADD(D,1,TO_DATE)
										FROM			T0180_BONUS WITH (NOLOCK)
										WHERE			EMP_ID = @EMP_ID AND UPPER(BONUS_CAL_TYPE) = 'EXGRATIA BONUS' And Bonus_Calculated_On = 'Allowance'
										ORDER BY		TO_DATE DESC
								END
							ELSE
								BEGIN
										SELECT @BONUS_FROMDATE_REGULAR_EXGRATIA = DBO.GET_MONTH_ST_DATE(MONTH(DATE_OF_JOIN),YEAR(DATE_OF_JOIN))
										FROM	T0080_EMP_MASTER WITH (NOLOCK)
										WHERE	EMP_ID = @EMP_ID
								END

							EXEC dbo.P0180_BONUS @Bonus_ID = 0,@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@From_Date = @BONUS_FROMDATE_REGULAR_EXGRATIA,
														@To_Date = @BONUS_TODATE_REGULAR_EXGRATIA,@Bonus_Calculated_On = 'Allowance',@Bonus_Percentage = @Yearly_Bonus_Per,
														@Bonus_Fix_Amount = @Bonus_Amount,@Bonus_Effect_on_Sal = 1,@Bonus_Effect_Month = @Month,@Bonus_Effect_Year =@Year,
														@Bonus_Comments = '',@tran_type = 'I',@Is_FNF = 1,@Bonus_Cal_Type = 'Exgratia Bonus'


					END
			END	
			SELECT @Bonus_Amount = IsNull(sum(Bonus_Amount),0) + IsNull(sum(Ex_Gratia_Bonus_Amount),0) FROM T0180_Bonus WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Is_FNF =1			
		END	
		
	IF @Is_Leave_Encash =1 
		BEGIN
				-- Carry Forward is commented because it is already called before calling this SP (called in SP_GET_EMP_FNF_DETAIL) MITESH
				
				---- Start Falak on 02-FEB-2011 to yearly leave carrforward 
				
				DECLARE @LEave_CF_ID AS NUMERIC
				DECLARE @leave_Tran_Date datetime
				SET @leave_Tran_Date = null
				SET @LEave_CF_ID = 0
				DECLARE cur_LEave_CF cursor for
					SELECT leavE_Id FROM T0040_leave_master WITH (NOLOCK) WHERE cmp_ID =@Cmp_ID 
					AND (( Leave_CF_Type ='Yearly') Or (leave_CF_Type ='Monthly') )  
					AND LeavE_Paid_Unpaid ='P'  AND IsNull(Is_Advance_Leave_Balance,0) <> 1
					 
				open cur_LEave_CF
				Fetch next FROM cur_LEave_CF into @leave_CF_ID
				while @@FETCH_STATUS = 0
				BEGIN
					
					SELECT @leave_Tran_Date = MAX(IsNull(CF_For_Date,'')) FROM T0100_LEAVE_CF_DETAIL  WITH (NOLOCK) WHERE Leave_ID = @LEave_CF_ID AND Emp_ID = @Emp_Id 
															
					IF @leave_Tran_Date IS NULL
						SELECT @leave_Tran_Date = min(for_date) FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE Emp_ID = @Emp_Id AND Leave_ID = @LEave_CF_ID  
					
					IF @leave_Tran_Date IS NULL
						SELECT @leave_Tran_Date = Date_Of_Join  FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_Id 
					--ELSE
						--SET @leave_Tran_Date = DATEADD (dd,1,@leave_Tran_Date)
					--SET @leave_Tran_Date = dbo.GET_MONTH_ST_DATE (MONTH(@leave_Tran_Date),YEAR(@leave_Tran_Date))
					--SELECT @leave_Tran_Date
					If Datediff(yy,@leave_Tran_Date,@Month_END_Date)<= 1
						Begin
							EXEC SP_LEAVE_CF 0,@cmp_ID,@leave_Tran_Date ,@Month_END_Date ,@Month_END_Date ,0,0,0,0,0,0,@Emp_Id,'',@leave_CF_ID,1
						end
				
					fetch next FROM cur_LEave_CF into @LEave_CF_ID
				END
				
				close cur_LEave_CF
				deallocate cur_LEave_CF
			--- END Falak on 02-FEB-2011	
		
			
				-- Below cursor is commented because it is called FROM form level - MITESH
					
				--DECLARE cur_leave cursor for
				--	SELECT lt.leavE_ID,leave_Closing FROM T0140_LEave_Transaction lt inner join
				--	(SELECT MAX(For_Date)For_Date,Emp_ID,LEave_ID FROM T0140_LEave_Transaction
				--	WHERE emp_ID =@Emp_ID
				--	group by emp_ID,LeavE_ID )Q on lt.emp_ID =q.emp_ID AND lt.leave_ID =q.leavE_ID AND lt.for_Date =q.for_Date inner join
				--	T0040_leave_master lm on lt.leavE_id =lm.leave_id AND  leave_type = 'Encashable'
				--open cur_leave
				--Fetch next FROM cur_leave into @Leave_ID ,@Leave_Days 
				--while @@Fetch_Status=0
				--	BEGIN
				--		EXEC dbo.P0120_Leave_Encash_Approval 0,0,@Cmp_Id,@Emp_Id,@Leave_ID,@Leave_Days,'',@Month_END_Date,'A','',@Login_ID,@Month_END_Date,'I',1
				--		Fetch next FROM cur_leave into @Leave_ID ,@Leave_Days 	
				--	END
				--close cur_leave
				--deallocate cur_leave
				
				
				EXEC dbo.P0200_MONTHLY_SALARY_GENERATE_LEAVE 0,@Emp_ID,@Cmp_ID,@Sal_Generate_Date,@Month_St_Date,@Month_END_Date,0,0,0,0,0,0,@Login_ID,'N','N',0,@Month_END_Date,1,@Sal_Tran_ID
				
				--SELECT @Leave_Salary = IsNull(sum(L_Net_Amount),0) FROM T0200_MONTHLY_SALARY_LEAVE WHERE Emp_ID=@Emp_ID AND Is_FNF =1
				DECLARE @Leave_GRoss_Salary NUMERIC(22,2)				
				-- SELECT @Leave_Salary = IsNull(sum(L_Net_Amount),0) FROM T0200_MONTHLY_SALARY_LEAVE WHERE Emp_ID=@Emp_ID AND IsNull(Is_FNF,0) =0 AND L_eff_Date >=@Month_St_Date AND L_Eff_date <=@Month_END_Date
				--SELECT @Leave_Salary_Amount = IsNull(SUM(L_Net_Amount),0) FROM T0200_Monthly_Salary_Leave WHERE emp_ID =@Emp_ID AND MONTH(L_Eff_Date) =MONTH(@Month_END_Date)  AND YEAR(L_Eff_Date) =YEAR(@Month_END_Date)
				SELECT @Leave_Salary = IsNull(SUM(L_Net_Amount),0),@Leave_GRoss_Salary = sum(IsNull(L_Actually_Gross_Salary,0)) 
				FROM T0200_Monthly_Salary_Leave WITH (NOLOCK) WHERE emp_ID =@Emp_ID AND MONTH(L_Eff_Date) =MONTH(@Month_END_Date)  AND YEAR(L_Eff_Date) =YEAR(@Month_END_Date)
						AND Is_FNF =1 --Added condition  By Deepali 20-May-2022 AND Is_FNF =1
				
		END
	--------------- Hourly Late --------------------

	SELECT @Late_Basic_Amount = @Late_Basic_Amount +  IsNull(SUM(IsNull(M_AD_AMOUNT,0)),0) FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
			WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='I' AND IsNull(M_AD_Effect_on_Late,0) =0
	
	SELECT @Late_Basic_Amount = @Late_Basic_Amount -  IsNull(SUM(IsNull(M_AD_AMOUNT,0)),0) FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
			WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='D' AND IsNull(M_AD_Effect_on_Late,0) =0
	
	 --Change done by Falak on 17-FEB-2011
	 IF @Lv_Encash_Cal_On = 'Gross'
		SET @Leave_Salary = @Leave_GRoss_Salary
		
		/*SET @Hour_Salary_Late = (@Late_Basic_Amount/@Fix_late_W_Days)/(@Fix_late_W_Shift_Sec/3600)
		SET @Late_Dedu_Amount = 0
		SET @Extra_Late_Dedu_Amount = 0
		IF @Total_Late_Sec > 0
			BEGIN
				SET @Late_Dedu_Amount = round(@Hour_Salary_Late * (@Total_Late_Sec /3600),0)
				SET @Extra_Late_Dedu_Amount = @Extra_Late_Deduction * @Late_Dedu_Amount
			END	*/	
			
	---------------------END ------------------------

			-- commented by rohit for IF SELECT Hold Salary then only pay in salary. on 27012016
			--	SELECT @Pre_Month_Net_Salary = IsNull(sum(Net_Amount),0) FROM T0200_MONTHLY_SALARY WHERE Emp_id =@Emp_ID AND Month_END_Date <@Month_St_Date AND IsNull(Salary_Status,'')='Hold'

			SELECT @Pre_Month_Net_Salary = IsNull(sum(Net_Amount),0) FROM T0200_Hold_Sal_FNF THS WITH (NOLOCK) inner join t0200_monthly_salary MS WITH (NOLOCK) ON THS.Sal_Tran_ID = MS.Sal_Tran_ID AND THS.emp_id=MS.Emp_ID
			WHERE MS.Emp_ID=@Emp_ID AND  ms.Month_END_Date <@Month_St_Date AND IsNull(ms.Salary_Status,'')='Hold'

			-- ENDed by rohit on 27012017
	
			SELECT @Advance_Amount =  round( IsNull(Adv_closing,0),0) FROM T0140_Advance_Transaction WITH (NOLOCK) WHERE emp_id = @emp_id AND Cmp_ID = @Cmp_ID
			AND for_date = (SELECT MAX(for_date) FROM  T0140_Advance_Transaction WITH (NOLOCK) WHERE emp_id = @emp_id AND Cmp_ID = @Cmp_ID
				AND for_date <=  @Month_END_Date)
	
			
	IF @Advance_Amount < 0
		SET @Advance_Amount = 0

	SET @Advance_Amount = IsNull(@Advance_Amount,0)  +  @Update_Adv_Amount
	
		

	EXEC SP_CALCULATE_LOAN_PAYMENT @Cmp_ID ,@emp_Id,@Month_st_Date,@Month_END_Date,@Sal_Tran_ID,0,1,1
	
	if Exists(Select 1 From T0120_LOAN_APPROVAL LA WITH (NOLOCK) Inner join T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA.Loan_ID = LM.Loan_ID WHERE isnull(LM.Is_Intrest_Amount_As_Perquisite_IT,0) = 1 and LA.Loan_Apr_Pending_Amount > 0 and LA.Emp_ID = @emp_Id)	
		BEGIN
			EXEC dbo.SP_CALCULATE_LOAN_PAYMENT_INT_PERQUISITE @Cmp_ID ,@emp_Id,@Month_st_Date,@Month_End_Date,@Sal_Tran_ID,0,1,1    
		End	 
	
	--Comment by nilesh patel on 25072015 --Start
	--SELECT @Loan_Amount = IsNull(sum(Loan_Pay_Amount),0),@Loan_Intrest_Amount = IsNull(sum(Interest_Amount),0) FROM V0210_Monthly_Loan_Payment LP
	--	Inner join T0040_LOAN_MASTER LM on LP.loan_ID = LM.Loan_ID AND LM.Is_Interest_Subsidy_Limit = 0
	-- WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID
	--Comment by nilesh patel on 25072015 --END
	
	--Added by nilesh patel on 25072015 -start
	
		--Select @Loan_Amount = Isnull(sum(Loan_Pay_Amount),0) From V0210_Monthly_Loan_Payment LP
		--	Inner join T0040_LOAN_MASTER LM on LP.loan_ID = LM.Loan_ID and LM.Is_Interest_Subsidy_Limit = 0
		--	Inner JOIN T0020_Interest_Deduction_FNF DF on DF.Loan_ID =  LM.Loan_ID and DF.Loan_Apr_id = LP.Loan_Apr_ID
		-- where Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Is_Loan_Interest_Flag = 0  --and DF.Is_Deduction_Flag = 1 
		 
		 
		 SELECT @Loan_Amount = ISNULL(SUM(Loan_Pay_Amount),0) from dbo.T0210_Monthly_Loan_Payment LP WITH (NOLOCK)
		 Inner join (		-- Changed by Gadriwala Muslim 25122014
						select LA.Loan_ID,LP.Loan_Apr_ID from T0210_Monthly_Loan_Payment LP WITH (NOLOCK) inner join
						T0120_LOAN_APPROVAL LA WITH (NOLOCK) on LA.Loan_Apr_ID = LP.Loan_Apr_ID
						WHERE LP.Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID 
					) Qry on Qry.Loan_Apr_ID = LP.Loan_Apr_ID  
		 Inner join T0040_LOAN_MASTER LM WITH (NOLOCK) on LM.Loan_ID = Qry.LOAN_ID and LM.Is_Interest_Subsidy_Limit = 0
		 WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID	 
		
		 
		Select 
			@Loan_Intrest_Amount = ISNULL(sum(Interest_Amount),0) From V0210_Monthly_Loan_Payment LP
			Inner join T0040_LOAN_MASTER LM WITH (NOLOCK) on LP.loan_ID = LM.Loan_ID and LM.Is_Interest_Subsidy_Limit = 0
			Inner JOIN T0020_Interest_Deduction_FNF DF WITH (NOLOCK) on DF.Loan_ID =  LM.Loan_ID and DF.Loan_Apr_id = LP.Loan_Apr_ID
		 where Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Is_Loan_Interest_Flag = 0  and DF.Is_Deduction_Flag = 1 
		 and LM.Is_Principal_First_than_Int = 0 and Isnull(LM.Is_Intrest_Amount_As_Perquisite_IT,0) = 0
	--Added by nilesh patel on 25072015 -End
	
	
	SET @Due_Loan_Amount = 0
	
	 SELECT @Due_Loan_Amount = IsNull(SUM(Loan_Closing),0) FROM T0140_LOAN_TRANSACTION  LT WITH (NOLOCK) INNER JOIN 
	( SELECT MAX(FOR_DATE) AS FOR_dATE , LOAN_ID ,EMP_ID FROM T0140_LOAN_TRANSACTION  WITH (NOLOCK) WHERE EMP_iD = @EMP_ID AND CMP_ID = @CMP_ID
	AND FOR_DATE <=@Month_END_Date
	GROUP BY EMP_id ,LOAN_ID ) AS QRY  ON QRY.LOAN_ID  = LT.LOAN_ID
	AND QRY.FOR_DATE = LT.FOR_DATE 
	AND QRY.EMP_ID = LT.EMP_ID
	WHERE Is_Loan_Interest_Flag = 0 --Added by nilesh patel on 23072015
	
	--Added by nilesh Patel on 24072015 --start (For First Deduct Principal Amount Than Interest Amount)
	 IF @Due_Loan_Amount = 0
		EXEC SP_CALCULATE_LOAN_INTEREST_PAYMENT @Cmp_ID ,@emp_Id,@Month_st_Date,@Month_END_Date,@Sal_Tran_ID,1
 
		 DECLARE @Is_First_Ded_Principal_Amt NUMERIC(18,0)
		 SELECT @Is_First_Ded_Principal_Amt = LM.Is_Principal_First_than_Int FROM T0210_Monthly_Loan_Payment LP WITH (NOLOCK) inner join 
		 T0120_LOAN_APPROVAL LA WITH (NOLOCK) on LA.Loan_Apr_ID = LP.Loan_Apr_ID inner JOIN
		 T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA.Loan_ID = LM.Loan_ID
		 WHERE LP.Temp_Sal_Tran_ID = @Sal_Tran_ID AND LP.Cmp_Id=@Cmp_ID
		 
			 
		 IF @Is_First_Ded_Principal_Amt = 1 
			BEGIN
				 IF @Due_Loan_Amount = 0 
					BEGIN
						
							DECLARE @Loan_Intrest_Amount_1 NUMERIC(18,2)
							SET @Loan_Intrest_Amount_1 = 0
							SELECT @Loan_Intrest_Amount_1 = IsNull(Sum(Interest_Amount),0) FROM dbo.T0210_Monthly_Loan_Payment LP WITH (NOLOCK)
							Inner join (		-- Changed by Gadriwala Muslim 25122014
										SELECT LA.Loan_ID,LP.Loan_Apr_ID FROM T0210_Monthly_Loan_Payment LP WITH (NOLOCK) inner join
										T0120_LOAN_APPROVAL LA WITH (NOLOCK) on LA.Loan_Apr_ID = LP.Loan_Apr_ID
										WHERE LP.Temp_Sal_Tran_ID = @Sal_Tran_ID AND LP.Cmp_Id=@Cmp_ID  AND LP.Is_Loan_Interest_Flag = 1
		   								) Qry on Qry.Loan_Apr_ID = LP.Loan_Apr_ID  
							Inner join T0040_LOAN_MASTER LM WITH (NOLOCK) on LM.Loan_ID = Qry.LOAN_ID AND LM.Is_Interest_Subsidy_Limit = 0
							Inner JOIN T0020_Interest_Deduction_FNF DF WITH (NOLOCK) on DF.Loan_ID =  LM.Loan_ID AND DF.Loan_Apr_id = LP.Loan_Apr_ID
							WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID AND LP.Cmp_Id=@Cmp_ID AND LP.Is_Loan_Interest_Flag = 1 AND DF.Is_Deduction_Flag = 1
							
							SET @Loan_Intrest_Amount = @Loan_Intrest_Amount + @Loan_Intrest_Amount_1
					END
			END 
	
	--Added by nilesh Patel on 24072015 --END
	
	
	--EXEC SP_CALCULATE_CLAIM_PAYMENT @Cmp_ID ,@emp_Id,@Month_END_Date,@Sal_Tran_ID,0,1,1

	
	--SELECT @Total_Claim_Amount  = IsNull(sum(Claim_Pay_Amount),0) FROM T0210_Monthly_Claim_Payment WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID
	SELECT	@Total_Claim_Amount=IsNull(SUM(Claim_Closing),0) 
	FROM	T0140_CLAIM_TRANSACTION AS CT WITH (NOLOCK) INNER JOIN 
			T0130_CLAIM_APPROVAL_DETAIL AS CAD WITH (NOLOCK) ON CAD.Claim_Apr_Date = CT.For_Date  INNER JOIN 
			T0120_CLAIM_APPROVAL AS CA WITH (NOLOCK) ON CA.Claim_Apr_ID = CAD.Claim_Apr_ID  AND Ct.Emp_ID=Ca.emp_id AND Ct.Claim_ID=CAD.Claim_ID 
	WHERE	CT.cmp_id=@Cmp_ID AND CT.Emp_ID=@emp_ID 
			--AND CA.Claim_Apr_Date<=@Month_END_Date     changed By Jimit 25112019 for getting claim Amount in FNF bug 417 Redmine
			AND  CA.Claim_Apr_Date <= dbo.GET_MONTH_END_DATE(Month(@Month_END_Date),YEar(@Month_END_Date))
			AND CA.Claim_Apr_Date>=@Month_St_Date
 
 

 IF @Total_Claim_Amount >0
 BEGIN
	EXEC SP_CALCULATE_CLAIM_TRANSACTION @Cmp_Id,@Emp_Id,@Month_St_Date,0,@Month_St_Date,@Month_END_Date,0,'I'
 END
   


	DECLARE @Temp_Allownace_PT NUMERIC(22,0)
	SET @Temp_Allownace_PT = 0
	
	--change by Falak on 02-OCT-2010 for effecting 'Not Effect on PT' in Allownace/DED MAster
	SELECT @Temp_Allownace_PT = SUM(IsNull(M_AD_AMOUNT,0)) FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)       
		WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='I' AND IsNull(M_AD_Not_effect_ON_PT,0) = 1     
		AND AD_ID  in (SELECT AD_ID FROM T0050_AD_Master WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID AND IsNull(AD_Not_effect_ON_PT,0) = 1 And (Isnull(AD_NOT_EFFECT_SALARY,0)= 0 or ISNULL(Allowance_Type,'A')='R')) -- AD_NOT_Effect_Salary condition added by Hardik 22/03/2018 for Knowcraft Client as Not effect allowance deducted from PT Calculated amount which is wrong
	
	--added by Jaina 16-05-2020
	declare @M_AD_Noteffect_ON_PT numeric(18,0)
	set @M_AD_Noteffect_ON_PT = 0
	SELECT @M_AD_Noteffect_ON_PT = ISNULL(M_AD_Not_effect_ON_PT,0) FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)      
		WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID AND Emp_ID = @Emp_ID AND m_AD_Flag ='I' AND IsNull(M_AD_Not_effect_ON_PT,0) = 1     
		AND AD_ID  in (SELECT AD_ID FROM T0050_AD_Master WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID AND IsNull(AD_Not_effect_ON_PT,0) = 1 And (Isnull(AD_NOT_EFFECT_SALARY,0)= 0 or ISNULL(Allowance_Type,'A')='R')) -- AD_NOT_Effect_Salary condition added by Hardik 22/03/2018 for Knowcraft Client as Not effect allowance deducted from PT Calculated amount which is wrong
	
	
	SET @Gross_Salary_Arear = IsNull(@Salary_amount_Arear,0) + IsNull(@Allow_Amount_Arear,0) -- Added By Ali 09122013
	
	SET @Gross_Salary_Arear_cutoff = IsNull(@Salary_amount_Arear_cutoff,0) + IsNull(@Allow_Amount_Arear_cutoff,0) -- Added By Ali 09122013
	
	IF @Is_OT_Inc_Salary =1 
		SET @Gross_Salary = IsNull(@Salary_Amount,0) + IsNull(@Allow_Amount,0) + IsNull(@Other_Allow_Amount,0) + IsNull(@Total_Claim_Amount ,0) + IsNull(@OT_Amount,0) + IsNull(@Incentive_Amount,0) + IsNull(@Bonus_Amount ,0) + IsNull(@Trav_Earn_Amount,0) + IsNull(@Cust_Res_Earn_Amount,0) + IsNull(@Gratuity_Amount,0) + IsNull(@Leave_Salary,0) + @Gross_Salary_Arear + IsNull(@WO_OT_Amount,0) + IsNull(@HO_OT_Amount,0)+ IsNull(@Gross_Salary_Arear_cutoff,0)  + ISNULL(@Uniform_Refund_Amount,0)-- Added By Ali 09122013
	ELSE
		SET @Gross_Salary = IsNull(@Salary_Amount,0) + IsNull(@Allow_Amount,0) + IsNull(@Other_Allow_Amount,0) + IsNull(@Total_Claim_Amount,0)  + IsNull(@Incentive_Amount,0) + IsNull(@Bonus_Amount ,0) + IsNull(@Trav_Earn_Amount,0) + IsNull(@Cust_Res_Earn_Amount,0) + IsNull(@Gratuity_Amount,0) + IsNull(@Leave_Salary,0) + @Gross_Salary_Arear+ IsNull(@Gross_Salary_Arear_cutoff,0)  + ISNULL(@Uniform_Refund_Amount,0) -- Added By Ali 09122013
	
	
	--IF @Is_Emp_PT =1 AND @Is_PT = 1 
		--BEGIN
			--IF IsNull(@Salary_Amount,0) > 0
				--BEGIN
					--SET  @PT_Calculated_Amount = @Gross_Salary
					--EXEC SP_CALCULATE_PT_AMOUNT @CMP_ID,@EMP_ID,@MONTH_END_DATE,@PT_Calculated_Amount,@PT_AMOUNT OUTPUT,@PT_F_T_LIMIT output,@Branch_ID
				--END	
		--END
	--Changed by Falak on 16-FEB-2011   
	 IF @Is_Emp_PT =1 AND @Is_PT = 1   -- Uncommented by Rohit for Pt Deduct on earn salary in fnf for cera on 27072015    
	  BEGIN 
			   
			IF @Lv_Salary_Effect_on_PT <> 1		
				SET  @PT_Calculated_Amount = @Gross_Salary - IsNull(@Temp_Allownace_PT,0) - IsNull(@Gratuity_Amount,0) -- Added by rohit for Pt Not Deduct on Gratuity AS per Discussion with Hardikbhai. on 20102015 
			ELSE
				SET  @PT_Calculated_Amount = @Gross_Salary - IsNull(@Temp_Allownace_PT,0) - IsNull(@Leave_Salary,0) - IsNull(@Gratuity_Amount,0)
			if @M_AD_Noteffect_ON_PT = 0	
				EXEC SP_CALCULATE_PT_AMOUNT @CMP_ID,@EMP_ID,@MONTH_END_DATE,@PT_Calculated_Amount,@PT_AMOUNT OUTPUT,@PT_F_T_LIMIT output,@Branch_ID,1    
			
	  END
	
	-- Added by rohit For Showing Settlement Amount in Fnf on 08082013
	DECLARE @Settelement_Amount  NUMERIC(18,2)
	SET @Settelement_Amount = 0
	
	SELECT @Settelement_Amount = IsNull(SUM(S_Net_Amount),0) FROM T0201_Monthly_Salary_Sett WITH (NOLOCK) WHERE emp_ID =@Emp_ID AND MONTH(S_Eff_Date) =MONTH(@Month_END_Date) AND YEAR(S_Eff_Date) =YEAR(@Month_END_Date)      
	SET @Gross_Salary  = @Gross_Salary  + IsNull(@Settelement_Amount,0) 
	-- ENDed by rohit on 08082013
	
	SET @Gross_Salary = @Gross_Salary  + @Pre_Month_Net_Salary
	
	IF   @Gross_Salary < @Revenue_on_Amount  AND @Revenue_on_Amount> 0
		SET @Revenue_Amount = 0
	
	SET @LWF_compare_month = '#'+ CAST(MONTH(@Month_End_Date)as VARCHAR(2)) + '#'
	
	
	IF charindex(@LWF_compare_month,@LWF_App_Month,1) = 0 or @LWF_App_Month ='' or IsNull(@Is_LWF_App,0)=0
		BEGIN
			SET @LWF_Amount = 0
		END		
	
	IF @Late_Mark_Scenario = 2 AND @Is_LateMark_Percent = 1 AND @Is_LateMark_Calc_On <> 0
		BEGIN
			SELECT 
				@Late_Dedu_Amount = IsNull(SUM(LATE_AMOUNT),0)
			FROM T0140_MONTHLY_LATEMARK_TRANSACTION WITH (NOLOCK)
			WHERE For_Date Between @Month_St_Date AND @Month_END_Date AND Emp_ID = @Emp_ID
		END
	
	IF @Late_Mark_Scenario = 3
		BEGIN
			SELECT 
			@Late_Dedu_Amount = (IsNull(SUM(LATE_AMOUNT),0) + IsNull(SUM(LUNCH_AMOUNT),0))
			FROM T0140_MONTHLY_LATEMARK_DESIGNATION WITH (NOLOCK) 
			WHERE For_Date Between @MONTH_ST_DATE AND @MONTH_END_DATE AND Emp_ID = @Emp_ID
		END
	-----------Hasmukh for Terminate case for payment 06082012-----
	SELECT @Is_Terminate = IsNull(Is_Terminate,0) FROM T0100_LEFT_EMP WITH (NOLOCK) WHERE Emp_Id=@Emp_ID
	
	IF @Is_Terminate = 1
		BEGIN
			SET @Gross_Salary = @Gross_Salary + IsNull(@Short_Fall_Dedu_Amount,0)
			SET @Total_Dedu_Amount = @Dedu_Amount + @Other_Dedu_Amount + @Advance_Amount + @Loan_Amount  + @PT_Amount + @LWF_Amount +  @Revenue_Amount   + @Trav_Rec_Amount + @Mobile_Rec_Amount + @Cust_Res_Rec_Amount  + @Uniform_deduct_amount	+ @I_Card_Rec_Amount	+ @Excess_Salary_Rec_Amount	+ IsNull(@Dedu_Amount_Arear,0) + IsNull(@Dedu_Amount_Arear_cutoff,0) + IsNull(@FNF_Subsidy_Recover_Amount,0) + IsNull(@Loan_Intrest_Amount,0)  + IsNull(@FNF_Training_Bnd_Rec_Amt,0) + IsNull(@Late_Dedu_Amount,0) --Added by Gadriwala Muslim 13042015   --Added Interest Amoutn by nilesh patel on 24072015
		END
	ELSE
		BEGIN
			SET @Total_Dedu_Amount = @Dedu_Amount + @Other_Dedu_Amount + @Advance_Amount + @Loan_Amount  + @PT_Amount + @LWF_Amount +  @Revenue_Amount   + @Trav_Rec_Amount + @Mobile_Rec_Amount + @Cust_Res_Rec_Amount  + @Uniform_deduct_amount	+ @I_Card_Rec_Amount	+ @Excess_Salary_Rec_Amount + @Short_Fall_Dedu_Amount + IsNull(@Dedu_Amount_Arear,0) + IsNull(@Dedu_Amount_Arear_cutoff,0) + IsNull(@FNF_Subsidy_Recover_Amount,0) + IsNull(@Loan_Intrest_Amount,0)  + IsNull(@FNF_Training_Bnd_Rec_Amt,0) + IsNull(@Late_Dedu_Amount,0) --Added by Gadriwala Muslim 13042015 --Added Interest Amoutn by nilesh patel on 24072015
		END
	
	------------------END Hasmukh 06082012--------------------------------
	
	-----------Added By Ali for Access Leave Recovery 17022014-----
	DECLARE @Encash_on AS VARCHAR(50)
	DECLARE @Encash_W_Day AS NUMERIC(18,0)
	DECLARE @Total_Access_Leave_Recovery AS NUMERIC(18,2)
	SET @Encash_on = ''
	SET @Encash_W_Day = 0
	SET @Total_Access_Leave_Recovery = 0
	
	SELECT @Encash_on = Lv_Encash_Cal_On,@Encash_W_Day = Lv_Encash_W_Day FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Branch_ID = @Branch_ID AND For_Date = (SELECT MAX(for_date) FROM T0040_General_Setting WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Branch_ID =@branch_id)  --Modified By Ramiz on 16092014
	
	
	---Added By Jimit 08022018
		DECLARE @LV_ENCASH_W_DAY_Master as NUMERIC
		SELECT @LV_ENCASH_W_DAY_Master = LEAVE_ENCASH_WORKING_DAYS 
		FROM T0080_EMP_MASTER WITH (NOLOCK)
		WHERE EMP_ID = @EMP_ID AND CMP_ID = @CMP_ID				
		
		IF @LV_ENCASH_W_DAY_Master > 0
			SET @Encash_W_Day = @LV_ENCASH_W_DAY_Master					
		---Ended
		
	
	IF @Access_Leave_Recovery > 0.0
	BEGIN
		DECLARE @Leave_Allow_Amount	NUMERIC(18,2)	--Ankit 28082015
		SET @Leave_Allow_Amount = 0
		
		SELECT @Leave_Allow_Amount = SUM(EED.E_AD_AMOUNT) FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID
		WHERE EED.EMP_ID = @EMP_ID AND EED.INCREMENT_ID = @Increment_ID AND AM.AD_EFFECT_ON_LEAVE = 1
		
		IF @Encash_W_Day > 0
		BEGIN					
			IF @Encash_on = 'Gross'		
				BEGIN
					IF @IS_ROUNDING = 1
						BEGIN
							SET @Total_Access_Leave_Recovery = Round((@Actual_Gross_Salary + IsNull(@Leave_Allow_Amount,0)) * @Access_Leave_Recovery/@Encash_W_Day,@Round) 
						END
					ELSE
						BEGIN
							SET @Total_Access_Leave_Recovery = Round((@Actual_Gross_Salary + IsNull(@Leave_Allow_Amount,0)) * @Access_Leave_Recovery/@Encash_W_Day,0) 
						END
				END
			ELSE
				BEGIN	
					IF @IS_ROUNDING = 1
						BEGIN
							SET @Total_Access_Leave_Recovery = Round((@Basic_Salary + IsNull(@Leave_Allow_Amount,0)) * @Access_Leave_Recovery/@Encash_W_Day,@Round) 
						END
					ELSE
						BEGIN
							SET @Total_Access_Leave_Recovery = Round((@Basic_Salary + IsNull(@Leave_Allow_Amount,0)) * @Access_Leave_Recovery/@Encash_W_Day,0) 
						END
				END
		END
		
		SET @Total_Dedu_Amount = @Total_Dedu_Amount + @Total_Access_Leave_Recovery
	END
	
	-----------Added By Ali for Access Leave Recovery 17022014-----	
	
	
	
--	SET @Net_Amount = @Gross_Salary - @Total_Dedu_Amount

	SET @Net_Amount = Round(@Gross_Salary - @Total_Dedu_Amount,0)

	 -------------------------ROUNDING  Ankit 09072014 --------------------------
		DECLARE @Temp_Round_Gross		NUMERIC(18,2)
		DECLARE @Total_Earning_Fraction NUMERIC (18,2)

		SET @Temp_Round_Gross = 0
		SET @Total_Earning_Fraction = 0


		IF @IS_ROUNDING = 0
			BEGIN
				SET @Temp_Round_Gross = Round(@Gross_Salary,0)
				SET @Total_Earning_Fraction = @Temp_Round_Gross - @Gross_Salary
			END
		
		DECLARE @Rval NUMERIC(18,2)
		DECLARE @Rval_Add NUMERIC(18,2)
		SET @Rval =0
								
		IF @net_round >= 0 AND IsNull(@net_round_Type,'') <> ''
			BEGIN	
				SET @mid_Net_Amount  = @Net_Amount
						
				IF 	@net_round_Type = 'Lower'
					BEGIN					
						SET @Temp_mid_Net_Amount = @mid_Net_Amount
						
						SET @Rval = CASE WHEN @net_round = 0   THEN 0 ELSE CASE WHEN @net_round = 10 THEN -1 ELSE CASE WHEN  @net_round = 100 THEN -2 ELSE 0 END END END
						SET @mid_Net_Amount =  Round(@mid_Net_Amount, @Rval, 1)
						
						SET @mid_Net_Round_Diff_Amount = @mid_Net_Amount - @Temp_mid_Net_Amount	 -- Added By Ali 04042014
					END 
				ELSE IF 	@net_round_Type = 'Nearest'
					BEGIN					
						
						SET @Temp_mid_Net_Amount = @mid_Net_Amount	-- Added By Ali 04042014
						
						IF @net_round > 0
							SET @mid_Net_Amount = ROUND(@mid_Net_Amount/@net_round,0) * @net_round
						ELSE
							SET @mid_Net_Amount = ROUND(@mid_Net_Amount,0)

						SET @mid_Net_Round_Diff_Amount = @mid_Net_Amount - @Temp_mid_Net_Amount		-- Added By Ali 04042014
					END 
				ELSE IF 	@net_round_Type = 'Upper'
					BEGIN					
						SET @Temp_mid_Net_Amount = @mid_Net_Amount		-- Added By Ali 04042014
						if @net_round > 0
							Begin
								SET @mid_Net_Amount = @net_round * CEILING(@mid_Net_Amount/@net_round) -- Working AS Upper
							End
						Else
							Begin
								SET @mid_Net_Amount = CEILING(@mid_Net_Amount) -- Working AS Upper
							End
						
						SET @mid_Net_Round_Diff_Amount = @mid_Net_Amount - @Temp_mid_Net_Amount		-- Added By Ali 04042014
					END 
			END
			
		
			--SET @mid_Net_Round_Diff_Amount = @Total_Earning_Fraction
		
	---------------------------END ROUNDING----------------------------------------------------------
	--SELECT @Salary_amount_Arear
	
		-- ADDED BY GADRIWALA MUSLIM 08092016 - ISSUE ON WRONG WORKING DAYS SHOWING
		IF @Total_Actual_Days < 0 
			SET @Working_days = 0

	
	   
		INSERT INTO T0200_MONTHLY_SALARY
		                      (Sal_Tran_ID, Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, Month_St_Date, Month_END_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days, 
		                      Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days, 
		                      Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary, 
		                      Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount, 
		                      Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, PT_Calculated_Amount, PT_Amount, 
		                      Total_Claim_Amount, M_IT_Tax, M_Adv_Amount, M_Loan_Amount, M_OT_Hours, LWF_Amount, Revenue_Amount, PT_F_T_Limit, 
		                      Actually_Gross_Salary, Late_Sec, Late_Dedu_Amount, Late_Extra_Dedu_Amount, Late_Days, Short_Fall_Days, Short_Fall_Dedu_Amount, 
		                      Gratuity_Amount, Is_FNF, Bonus_Amount, Incentive_Amount, Trav_Earn_Amount, Cust_Res_Earn_Amount, Trav_Rec_Amount, Mobile_Rec_Amount, 
		                      Cust_Res_Rec_Amount, Uniform_Rec_Amount, I_Card_Rec_Amount, Excess_Salary_Rec_Amount,Leave_Salary_Amount,Salary_Status,Pre_Month_Net_Salary,M_WO_OT_Hours,M_WO_OT_Amount,M_HO_OT_Hours,M_HO_OT_Amount,Settelement_Amount,Arear_Day,Arear_Basic,Arear_Gross,Access_Leave_Recovery,Access_Leave_Recovery_Day,Access_Leave_Recovery_Type,Arear_Month,Arear_Year,Net_Salary_Round_Diff_Amount,Total_Earning_Fraction,Cutoff_date,Arear_Day_Previous_month ,Basic_Salary_arear_cutoff,Gross_Salary_arear_cutoff,Asset_Installment,FNF_Subsidy_Recover_Amount,FNF_Comments,FNF_Training_Bnd_Rec_Amt,Uniform_Dedu_Amount,Uniform_Refund_Amount,OT_Adj_against_absent) -- Added by Ali 17022014
		VALUES     (@Sal_Tran_ID,@Sal_Receipt_No,@Emp_ID,@Cmp_ID,@Increment_ID,@Month_St_Date,@Month_END_Date,@Sal_Generate_Date,@Sal_cal_Days,@Present_Days,@Absent_Days,@Holiday_Days,@Weekoff_Days,@Cancel_Holiday,@Cancel_Weekoff,@Working_Days,@Outof_Days,@Total_Leave_Days,@Paid_Leave_Days,@Actual_Working_Hours,@Working_Hours,@Outof_Hours,
							  @Emp_OT_Hours_Num,@Total_Hours,@Shift_Day_Sec,@Shift_Day_Hour,@Basic_Salary,@Day_Salary,@Hour_Salary,@Salary_Amount,@Allow_Amount,@OT_Amount,@Other_Allow_Amount,@Gross_Salary,@Dedu_Amount,@Loan_Amount,@Loan_Intrest_Amount,@Advance_Amount,@Other_Dedu_Amount,@Total_Dedu_Amount,@Due_Loan_Amount,@Net_Amount,@PT_Calculated_Amount,@PT_Amount,@Total_Claim_Amount,@M_IT_Tax,@M_ADv_Amount,@M_Loan_Amount,@M_OT_Hours,@LWF_Amount,@REvenue_Amount,@PT_F_T_LIMIT,@Gross_Salary_ProRata,@Total_Late_Sec,@Late_Dedu_Amount,@Extra_Late_Deduction,@Late_Absent_Day,@Short_Fall_Days, @Short_Fall_Dedu_Amount, 
		                      @Gratuity_Amount, 1, @Bonus_Amount, @Incentive_Amount, @Trav_Earn_Amount, @Cust_Res_Earn_Amount, @Trav_Rec_Amount, @Mobile_Rec_Amount, 
		                      @Cust_Res_Rec_Amount, @Uniform_Rec_Amount, @I_Card_Rec_Amount, @Excess_Salary_Rec_Amount,@Leave_Salary,'Done',@Pre_Month_Net_Salary,@W_OT_Hours, @WO_OT_Amount,@H_OT_Hours, @HO_OT_Amount,@Settelement_Amount,@arear_Days,@Salary_amount_Arear,@Gross_Salary_Arear,@Total_Access_Leave_Recovery,@Access_Leave_Recovery,@Access_Leave_Recovery_Type,@Arear_Month,@Arear_Year,@mid_Net_Round_Diff_Amount,@Total_Earning_Fraction,@month_END_date,@Absent_after_Cutoff_date ,IsNull(@Salary_amount_Arear_cutoff,0),IsNull(@Gross_Salary_Arear_cutoff,0),IsNull(@Asset_amount,0),IsNull(@FNF_Subsidy_Recover_Amount,0),@FNF_Comments,IsNull(@FNF_Training_Bnd_Rec_Amt,0),@Uniform_deduct_amount,IsNull(@Uniform_Refund_Amount,0),@OT_Adj_Days) -- Added by Ali 17022014
	
	
					UPDATE T0200_Hold_Sal_FNF SET sal_tran_id_effect = @Sal_Tran_ID WHERE emp_id=@emp_id -- added by rohit on 27012016
	
								-- Added for audit trail By Ali 12102013 -- Start
									SET @Old_Emp_Name = (SELECT IsNull(Alpha_Emp_Code,'') + ' - ' + IsNull(Emp_Full_Name,'')   FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_ID)
									
									SET @OldValue = 'New Value' 
													+ '#' + 'Employee Name :' + IsNull(@Old_Emp_Name,'')
													+ '#' + 'Salary Receipt No :' + CONVERT(NVARCHAR(100),IsNull(@Sal_Receipt_No,0))
													+ '#' + 'Increment ID :' + CONVERT(NVARCHAR(100),IsNull(@Increment_ID,0))
													+ '#' + 'Month Start Date :' + CAST(IsNull(@Month_St_Date,'') AS NVARCHAR(11))
													+ '#' + 'Month END Date :' + CAST(IsNull(@Month_END_Date,'') AS NVARCHAR(11))
													+ '#' + 'Salary Generate Date :' + CAST(IsNull(@Sal_Generate_Date,'') AS NVARCHAR(11))
													+ '#' + 'Salary Calculate Days :' + CONVERT(NVARCHAR(100),IsNull(@Sal_cal_Days,0))
													+ '#' + 'Present Days :' + CONVERT(NVARCHAR(100),IsNull(@Present_Days,0))
													+ '#' + 'Absent Days :' + CONVERT(NVARCHAR(100),IsNull(@Absent_Days,0))
													+ '#' + 'Holiday Days :' + CONVERT(NVARCHAR(100),IsNull(@Holiday_Days,0))
													+ '#' + 'Weekoff Days :' + CONVERT(NVARCHAR(100),IsNull(@Weekoff_Days,0))
													+ '#' + 'Cancel Holiday :' + CONVERT(NVARCHAR(100),IsNull(@Cancel_Holiday,0))
													+ '#' + 'Cancel Weekoff :' + CONVERT(NVARCHAR(100),IsNull(@Cancel_Weekoff,0))													
													+ '#' + 'Outof Days :' + CONVERT(NVARCHAR(100),IsNull(@OutOf_Days,0))
													+ '#' + 'Paid Leave Days :' + CONVERT(NVARCHAR(100),IsNull(@Paid_leave_Days,0))
													+ '#' + 'Actual Working Hours :' + CONVERT(NVARCHAR(100),IsNull(@Actual_Working_Hours,0))
													+ '#' + 'Working Hours :' + CONVERT(NVARCHAR(100),IsNull(@Working_Hours,0))
													+ '#' + 'Outof Hours :' + CONVERT(NVARCHAR(100),IsNull(@Outof_Hours,0))
													+ '#' + 'Employee OT Hours :' + CONVERT(NVARCHAR(100),IsNull(@Emp_OT_Hours_Num,0))
													+ '#' + 'Total Leave Days :' + CONVERT(NVARCHAR(100),IsNull(@Total_leave_Days,0))
													+ '#' + 'Shift Day In Sec :' + CONVERT(NVARCHAR(100),IsNull(@Shift_Day_Sec,0))
													+ '#' + 'Shift Day In Hour :' + CONVERT(NVARCHAR(100),IsNull(@Shift_Day_Hour,0))
													+ '#' + 'Late Sec :' + CONVERT(NVARCHAR(100),IsNull(@Total_Late_Sec,0))
													+ '#' + 'Late Days :' + CONVERT(NVARCHAR(100),IsNull(@Late_Absent_Day,0))
													+ '#' + 'Arear Days :' + CONVERT(NVARCHAR(100),IsNull(@arear_Days,0))  -- Gadriwala 03122013	
													+ '#' + 'Total Hours :' + IsNull(@Total_Hours,'')
													+ '#' + 'Working Days :' + CONVERT(NVARCHAR(100),IsNull(@Working_days,0))
													+ '#' + 'Basic Amount :' + CONVERT(NVARCHAR(100),IsNull(@Basic_Salary,0))
													+ '#' + 'Day Salary :' + CONVERT(NVARCHAR(100),IsNull(@Day_Salary,0))
													+ '#' + 'Hour Salary :' + CONVERT(NVARCHAR(100),IsNull(@Hour_Salary,0))
													+ '#' + 'Salary Amount :' + CONVERT(NVARCHAR(100),IsNull(@Salary_amount,0))
													+ '#' + 'Allow Amount :' + CONVERT(NVARCHAR(100),IsNull(@Allow_Amount,0))
													+ '#' + 'Bonus Amount :' + CONVERT(NVARCHAR(100),IsNull(@Bonus_Amount,0))
													+ '#' + 'WeekOff OT Hours :' + CONVERT(NVARCHAR(100),IsNull(@W_OT_Hours,0))
													+ '#' + 'WeekOff OT Amount :' + CONVERT(NVARCHAR(100),IsNull(@WO_OT_Amount,0))
													+ '#' + 'Holiday OT Hours :' + CONVERT(NVARCHAR(100),IsNull(@H_OT_Hours,0))
													+ '#' + 'Holiday OT Amount :' + CONVERT(NVARCHAR(100),IsNull(@HO_OT_Amount,0))
													+ '#' + 'OT Hours :' + CONVERT(NVARCHAR(100),IsNull(@M_OT_Hours,0))
													+ '#' + 'OT Amount :' + CONVERT(NVARCHAR(100),IsNull(@OT_Amount,0))
													+ '#' + 'Other Allow Amount :' + CONVERT(NVARCHAR(100),IsNull(@Other_allow_Amount,0))
													+ '#' + 'Gross Amount :' + CONVERT(NVARCHAR(100),IsNull(@Gross_Salary,0))
													+ '#' + 'Dedu Amount :' + CONVERT(NVARCHAR(100),IsNull(@Dedu_Amount,0))
													+ '#' + 'Loan Amount :' + CONVERT(NVARCHAR(100),IsNull(@Loan_Amount,0))
													+ '#' + 'Loan Intrest Amount :' + CONVERT(NVARCHAR(100),IsNull(@Loan_Intrest_Amount,0))
													+ '#' + 'Late Dedu Amount :' + CONVERT(NVARCHAR(100),IsNull(@Late_Dedu_Amount,0))
													+ '#' + 'Extra Late Deduction :' + CONVERT(NVARCHAR(100),IsNull(@Extra_Late_Deduction,0))
													+ '#' + 'Advance Amount :' + CONVERT(NVARCHAR(100),IsNull(@Advance_Amount,0))
													+ '#' + 'Other Dedu Amount :' + CONVERT(NVARCHAR(100),IsNull(@Other_Dedu_Amount,0))
													+ '#' + 'Due Loan Amount :' + CONVERT(NVARCHAR(100),IsNull(@Due_Loan_Amount,0))
													+ '#' + 'LWF Amount :' + CONVERT(NVARCHAR(100),IsNull(@LWF_Amount,0))
													+ '#' + 'REvenue Amount :' + CONVERT(NVARCHAR(100),IsNull(@Revenue_Amount,0))
													+ '#' + 'PT Calculated Amount :' + CONVERT(NVARCHAR(100),IsNull(@PT_Calculated_Amount,0))
													+ '#' + 'PT Amount :' + CONVERT(NVARCHAR(100),IsNull(@PT_Amount,0))
													+ '#' + 'Total Claim Amount :' + CONVERT(NVARCHAR(100),IsNull(@Total_Claim_Amount,0))
													+ '#' + 'IT Tax :' + CONVERT(NVARCHAR(100),IsNull(@M_IT_Tax,0))
													+ '#' + 'ADV Amount :' + CONVERT(NVARCHAR(100),IsNull(@M_ADV_AMOUNT,0))
													+ '#' + 'Loan Amount :' + CONVERT(NVARCHAR(100),IsNull(@M_LOAN_AMOUNT,0))
													+ '#' + 'Total Dedu Amount :' + CONVERT(NVARCHAR(100),IsNull(@Total_Dedu_Amount,0))
													+ '#' + 'PT F T LIMIT :' + IsNull(@PT_F_T_Limit,'')
													+ '#' + 'Gross Salary ProRata :' + CONVERT(NVARCHAR(100),IsNull(@Gross_Salary_ProRata,0))
													+ '#' + 'Settelement Amount :' + CONVERT(NVARCHAR(100),IsNull(@Settelement_Amount,0))
													+ '#' + 'Net Amount :' + CONVERT(NVARCHAR(100),IsNull(@Net_Amount,0))
													+ '#' + 'Status :' + CONVERT(NVARCHAR(100),IsNull('Done',0))		
													+ '#' + 'FNF_Subsidy_Recover_Amount :' + Convert(NVARCHAR(100),IsNull(@FNF_Subsidy_Recover_Amount,0))
													+ '#' + 'FNF_Training_Bonds_Recover_Amount :' + Convert(NVARCHAR(100),IsNull(@FNF_Training_Bnd_Rec_Amt,0))
													+ '#' + 'FNF_Comments :' + IsNull(@FNF_Comments,'')																								
									EXEC P9999_Audit_Trail @Cmp_ID,'I','Full AND Final Settlement',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1
								--  Added for audit trail By Ali 12102013 -- END
	
		Update T0080_Emp_MASTER 
		SET is_Emp_FNF =1
		WHERE Emp_ID =@Emp_ID
		
		
		
		Update	T0210_MONTHLY_LEAVE_DETAIL
		SET		SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,
				TEMP_SAL_TRAN_ID = NULL 
		WHERE	EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID
		
		
		
		UPDATE	T0210_MONTHLY_AD_DETAIL 
		SET		SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,
				TEMP_SAL_TRAN_ID = NULL
		WHERE	EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID
		
		
		/* Note: Below Condition Update Amount Zero (0) IF employee Left Previous Month	--Ankit/Hardikbhai 25022016  */
		
		--UPDATE	T0210_MONTHLY_AD_DETAIL 
		--SET		M_AD_Amount = 0
		--WHERE	EMP_ID = @EMP_ID AND SAL_TRAN_ID = @SAL_TRAN_ID
		--		AND To_date >= DateAdd(m,1,@Left_Date)

		/* Employee Salary Status Done in Same Left Month && Next Month Generate FNF then update Zero (0) */
		--IF EXISTS ( SELECT 1 FROM T0200_MONTHLY_SALARY WHERE EMP_ID = @EMP_ID AND @Left_Date BETWEEN Month_St_Date AND Month_END_Date )-- AND Month_END_Date >= DateAdd(m,1,@Left_Date) )
		--	BEGIN
		--		ALTER TABLE T0200_MONTHLY_SALARY DISABLE TRIGGER Tri_T0200_MONTHLY_SALARY_UPDATE
					
		--			UPDATE	T0200_MONTHLY_SALARY
		--			SET		Salary_Amount = 0,Gross_Salary = 0,Total_Dedu_Amount = 0,Basic_Salary =0,Allow_Amount =0,Dedu_Amount =0,Net_Amount =0,Total_Earning_Fraction =0
		--					,Sal_Cal_Days = 0,Present_Days =0,Absent_Days =0,Weekoff_Days =0,Cancel_Holiday =0,Cancel_Weekoff=0,Working_Days =0,Total_Leave_Days =0,Paid_Leave_Days =0
		--			WHERE	EMP_ID = @EMP_ID AND SAL_TRAN_ID = @SAL_TRAN_ID
		--					--AND Month_END_Date >= DateAdd(m,1,@Left_Date)
							
		--		ALTER TABLE T0200_MONTHLY_SALARY Enable TRIGGER Tri_T0200_MONTHLY_SALARY_UPDATE			
		--	END
		
		
		alter TABLE T0210_MONTHLY_LOAN_PAYMENT Disable trigger Tri_T0210_MONTHLY_LOAN_PAYMENT_UPDATE
		
		
		UPDATE T0210_MONTHLY_LOAN_PAYMENT
		SET SAL_TRAN_ID = TEMP_SAL_TRAN_ID  ,
				TEMP_SAL_TRAN_ID = NULL
		WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID
			AND LOAN_APR_ID IN (SELECT LOAN_APR_ID FROM T0120_LOAN_APPROVAL WITH (NOLOCK) WHERE EMP_ID = @EMP_ID)
		
		alter TABLE T0210_MONTHLY_LOAN_PAYMENT Enable trigger Tri_T0210_MONTHLY_LOAN_PAYMENT_UPDATE
		
		--alter TABLE T0210_MONTHLY_CLAIM_PAYMENT Disable trigger Tri_T0210_MONTHLY_CLAIM_PAYMENT_UPDATE
		
		--UPDATE T0210_MONTHLY_CLAIM_PAYMENT
		--SET SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,
		--		TEMP_SAL_TRAN_ID = NULL
		
		--WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID
		--	AND CLAIM_APR_ID IN (SELECT CLAIM_APR_ID FROM T0120_CLAIM_APPROVAL WHERE EMP_ID = @EMP_ID)				

		--alter TABLE T0210_MONTHLY_CLAIM_PAYMENT Enable trigger Tri_T0210_MONTHLY_CLAIM_PAYMENT_UPDATE
		
		
		SET @M_SAL_TRAN_ID = @SAL_TRAN_ID


		-- Aded by Hardik 11/10/2014 for Auto Calculate PENDing TDS Amount

		IF @TDS = 1
			BEGIN
				DECLARE @From_Date VARCHAR(11)
				DECLARE @To_Date VARCHAR(11)
				
				DECLARE @AD_ID      NUMERIC 
				DECLARE @TDS_Amount NUMERIC(18,2)
				DECLARE @M_AD_Percentage   NUMERIC(12,5)                    
				DECLARE @M_AD_Amount    NUMERIC(12,5)                    
				DECLARE @M_AD_Flag     VARCHAR(1)                    
				DECLARE @Max_Upper     NUMERIC(27,5)                    
				DECLARE @varCalc_On     VARCHAR(50)                    
				DECLARE @Calc_On_Allow_Dedu   NUMERIC(18,2)                     
				DECLARE @ESIC_Calculate_Amount NUMERIC(18,2)                  
				DECLARE @M_AD_Actual_Per_Amount  NUMERIC(18,5)                    
				DECLARE @M_AD_Tran_ID  NUMERIC 
				DECLARE @L_Sal_Tran_ID  NUMERIC
				DECLARE @M_AD_NOT_EFFECT_ON_PT  NUMERIC(1,0)                    
				DECLARE @M_AD_NOT_EFFECT_SALARY  NUMERIC(1,0)                    
				DECLARE @M_AD_EFFECT_ON_OT   NUMERIC(1,0)                    
				DECLARE @M_AD_EFFECT_ON_EXTRA_DAY NUMERIC(1,0)                    
				DECLARE @M_AD_effect_on_Late  int   
				DECLARE @For_FNF tinyint
				DECLARE @allowance_type AS VARCHAR(10)


				 IF @L_Sal_Tran_ID =0                    
					  SET @L_Sal_Tran_ID = null                     


				Create TABLE #tbl_TDS 
				(	Emp_Id NUMERIC,
					TDS_Amount NUMERIC(18,2)
				)

				
				
				IF MONTH(@Left_Date) > 3
					BEGIN
						SET @From_Date = '01-Apr-' + CAST(YEAR(@Left_Date) AS VARCHAR(4))
						SET @To_Date = '31-Mar-' + CAST((YEAR(@Left_Date)+1) AS VARCHAR(4))
					END
				ELSE
					BEGIN
						SET @From_Date = '01-Apr-' + CAST((YEAR(@Left_Date)-1) AS VARCHAR(4))
						SET @To_Date = '31-Mar-' + CAST((YEAR(@Left_Date)) AS VARCHAR(4))
					END
				

				INSERT INTO #tbl_TDS 
				EXEC SP_IT_TAX_PREPARATION @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint=@Emp_ID,@Product_ID=0,@Taxable_Amount_Cond=0,@Form_ID=1,@Sp_Call_For='Full & Final'
				
				
				SELECT @TDS_Amount = TDS_Amount FROM #tbl_TDS
				
				IF @TDS_Amount > 0 
					BEGIN
						SELECT @AD_ID = AD_Id,@M_AD_Flag = AD_Flag,@M_AD_Percentage= AD_PERCENTAGE, @M_AD_NOT_EFFECT_ON_PT= AD_NOT_EFFECT_ON_PT, 
							@M_AD_NOT_EFFECT_SALARY = AD_NOT_EFFECT_SALARY, @M_AD_EFFECT_ON_OT= AD_EFFECT_ON_OT, @M_AD_EFFECT_ON_EXTRA_DAY = AD_EFFECT_ON_EXTRA_DAY, 
							@M_AD_effect_on_Late= AD_EFFECT_ON_LATE, @For_FNF= FOR_FNF, @allowance_type =Allowance_Type
						FROM T0050_AD_MASTER WITH (NOLOCK) WHERE AD_DEF_ID = 1 AND CMP_ID=@Cmp_ID
				
						IF not EXISTS(SELECT AD_Id FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Sal_Tran_ID = @Sal_Tran_ID AND AD_ID = @AD_ID)
							BEGIN
								SELECT @M_AD_Tran_ID = IsNull(MAX(M_AD_Tran_ID),0) + 1 FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
								
								INSERT INTO T0210_MONTHLY_AD_DETAIL                    
									  (M_AD_Tran_ID, Sal_Tran_ID,Temp_Sal_Tran_ID ,L_Sal_Tran_ID,Emp_ID, Cmp_ID, AD_ID, For_Date, M_AD_Percentage, M_AD_Amount, M_AD_Flag, M_AD_Actual_Per_Amount,                     
									   M_AD_Calculated_Amount,M_AD_NOT_EFFECT_ON_PT,M_AD_NOT_EFFECT_SALARY,M_AD_EFFECT_ON_OT,M_AD_EFFECT_ON_EXTRA_DAY,SAL_TYPE,M_AD_effect_on_Late,FOR_FNF,To_Date)                    
								VALUES     (@M_AD_Tran_ID, null,@Sal_Tran_ID,@L_Sal_Tran_ID, @Emp_ID, @Cmp_ID, @AD_ID, @Month_St_Date, @M_AD_Percentage, @TDS_Amount, @M_AD_Flag, IsNull(@M_AD_Actual_Per_Amount,0),                   
									   IsNull(@Calc_On_Allow_Dedu,0),@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY,0,@M_AD_effect_on_Late,@For_FNF,@Month_END_Date)                    
							END
						ELSE
							BEGIN
								Update T0210_MONTHLY_AD_DETAIL SET M_AD_Amount = @TDS_Amount WHERE Cmp_ID = @Cmp_ID AND Sal_Tran_ID = @Sal_Tran_ID AND AD_ID=@AD_ID
							END
					
						SET @Total_Dedu_Amount = @Total_Dedu_Amount + @TDS_Amount
						SET @Net_Amount = @Net_Amount - @TDS_Amount
						
						Update T0200_MONTHLY_SALARY SET Total_Dedu_Amount = @Total_Dedu_Amount, Net_Amount = @Net_Amount
						WHERE Sal_Tran_ID = @Sal_Tran_ID
						
						DROP TABLE #tbl_TDS
					END		
			END
						

		
	RETURN










