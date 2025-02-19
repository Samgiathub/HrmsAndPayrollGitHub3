
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0200_MONTHLY_SALARY_GENERATE_MANUAL]      
@M_Sal_Tran_ID  Numeric output      
,@Emp_Id   Numeric      
,@Cmp_ID   Numeric      
,@Sal_Generate_Date datetime      
,@Month_St_Date  Datetime      
,@Month_End_Date Datetime      
,@Present_Days  NUMERIC(18, 4)      
,@M_OT_Hours  NUMERIC(18, 4)      
,@Areas_Amount  NUMERIC(18, 4)       
,@M_IT_Tax   NUMERIC(18, 4)      
,@Other_Dedu  NUMERIC(18, 4)      
,@M_LOAN_AMOUNT  NUMERIC      
,@M_ADV_AMOUNT  NUMERIC      
,@IS_LOAN_DEDU  NUMERIC --(0,1)      
,@Login_ID   Numeric = null      
,@ErrRaise   Varchar(100)= null output      
,@Is_Negetive  Varchar(1)  
,@Status   varchar(10)='Done'  
,@IT_M_ED_Cess_Amount NUMERIC(18, 4)
,@IT_M_Surcharge_Amount NUMERIC(18, 4)
,@Allo_On_Leave numeric(18,0)=1
,@User_Id numeric(18,0) = 0		-- Added for audit trail By Ali 17102013
,@IP_Address varchar(30)= ''	-- Added for audit trail By Ali 17102013
,@wo_date varchar(1000) = ''
,@wo_count NUMERIC(18, 4) = 0
,@ho_date varchar(1000) = ''
,@ho_count NUMERIC(18, 4) = 0
,@wo_date_mid varchar(1000)
,@wo_count_mid NUMERIC(18, 4) = 0
,@IS_Bond_DEDU  BIT

AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
 
 
 	if exists(select 1 from sys.triggers where is_disabled=1) --for sql 2005 added by hasmukh 
--	if not exists(select 1 from sysobjects a join sysobjects b on a.parent_obj=b.id where a.type = 'tr' AND A.STATUS & 2048 = 0) -- for sql 2000
		begin		
			exec sp_msforeachtable 'ALTER TABLE ? ENABLE TRIGGER all'
			--set @ErrRaise =':|:ERRT:|: Another Process Running. Try After Sometime'
			--return 
		end

       
	
 if @STATUS =''      
  set @STATUS ='Done'      
      
 DECLARE @Sal_Receipt_No		Numeric      
 DECLARE @Increment_ID			Numeric      
 DECLARE @Sal_Tran_ID			Numeric       
 DECLARE @Branch_ID				Numeric       
 DECLARE @Emp_OT				Numeric       
 DECLARE @Emp_OT_Min_Limit		Varchar(10)      
 DECLARE @Emp_OT_Max_Limit		Varchar(10)  
 DECLARE @late_Extra_Amount     Numeric      
 DECLARE @Emp_OT_Min_Sec		Numeric      
 DECLARE @Emp_OT_Max_Sec		Numeric      
 DECLARE @Emp_OT_Sec			Numeric      
 DECLARE @Emp_OT_Hours			Varchar(10)      
 DECLARE @Wages_Type			Varchar(10)      
 DECLARE @SalaryBasis			Varchar(20)      
 DECLARE @Payment_Mode			Varchar(20)      
 DECLARE @Fix_Salary			Int
 DECLARE @numAbsentDays			NUMERIC(18, 4)             
 DECLARE @numWorkingDays_Daily	NUMERIC(18, 4)      
 declare @numAbsentDays_Daily	NUMERIC(18, 4)      
 DECLARE @Sal_cal_Days			NUMERIC(18, 4)      
 DECLARE @Absent_Days			NUMERIC(18, 4)      
 DECLARE @Holiday_Days			NUMERIC(18, 4)      
 DECLARE @Weekoff_Days			NUMERIC(18, 4)      
 DECLARE @Cancel_Holiday		NUMERIC(18, 4)      
 DECLARE @Cancel_Weekoff		NUMERIC(18, 4)      
 DECLARE @Working_days			NUMERIC(18, 4)      
 declare @OutOf_Days			Numeric      
 Declare @OutOf_Days_Arear		NUMERIC(18, 4)    --Hardik 07/01/2012
 DECLARE @Total_leave_Days		NUMERIC(18, 4)      
 DECLARE @Paid_leave_Days		NUMERIC(18, 4)      
 DECLARE @OD_leave_Days			NUMERIC(18, 4) 
 
 --Hardik 22/07/2014	 
 DECLARE @Compoff_leave_Days		  NUMERIC(18, 4) 
 Declare @Mid_Compoff_leave_Days	  NUMERIC(18, 4)

 
 DECLARE @Unpaid_Leave			NUMERIC(18, 4)      
 DECLARE @Actual_Working_Hours  Varchar(20)      
 DECLARE @Actual_Working_Sec	Numeric      
 DECLARE @Working_Hours			Varchar(20)      
 DECLARE @Outof_Hours			Varchar(20)      
 DECLARE @Total_Hours			Varchar(20)      
 DECLARE @Shift_Day_Sec			Numeric      
 DECLARE @Shift_Day_Hour		Varchar(20)      
 DECLARE @Basic_Salary			NUMERIC(18, 4)      
 DECLARE @Gross_Salary			NUMERIC(18, 4)      

 DECLARE @Basic_Salary_Arear	NUMERIC(18, 4)--Hardik 07/01/2012
 DECLARE @Gross_Salary_Arear	NUMERIC(18, 4)--Hardik 07/01/2012      

 DECLARE @Actual_Gross_Salary	NUMERIC(18, 4)      
 DECLARE @Gross_Salary_ProRata  NUMERIC(18, 4)      
 DECLARE @Day_Salary			Numeric(22,5)      
 DECLARE @Day_Salary_Arear		Numeric(22,5) --Hardik 07/01/2012
 DECLARE @Hour_Salary			Numeric(12,5)      
 DECLARE @Salary_amount			Numeric(22,5)      
 DECLARE @Salary_amount_Arear	Numeric(22,5) --Hardik 07/01/2012     
 DECLARE @Allow_Amount			NUMERIC(18, 4)      
 DECLARE @Allow_Amount_Arear	NUMERIC(18, 4) --Hardik 07/01/2012
 DECLARE @OT_Amount				NUMERIC(18, 4)      
 DECLARE @Other_allow_Amount	NUMERIC(18, 4)      
 DECLARE @Dedu_Amount			NUMERIC(18, 4)      
 DECLARE @Dedu_Amount_Arear		NUMERIC(18, 4) --Hardik 07/01/2012
 DECLARE @Loan_Amount			NUMERIC(18, 4)      
 DECLARE @Loan_Interest_Amount  NUMERIC(18, 4)      
 DECLARE @Loan_Interest_Percent NUMERIC(18, 4)  --Hardik 29/12/2011
 DECLARE @Advance_Amount		NUMERIC(18, 4)      
 DECLARE @Other_Dedu_Amount		NUMERIC(18, 4)   
 DECLARE @Other_m_it_Amount		NUMERIC(18, 4)   
 DECLARE @Total_Dedu_Amount		NUMERIC(18, 4)      
 DECLARE @Due_Loan_Amount		NUMERIC(18, 4)      
 DECLARE @Net_Amount		    NUMERIC(18, 4)      
 DECLARE @Final_Amount		    NUMERIC(18, 4)      
 DECLARE @Hour_Salary_OT        NUMERIC(18, 4)      
 DECLARE @ExOTSetting           Numeric(5,2)      
 DECLARE @Inc_Weekoff			Char(1) 
 DECLARE @Inc_Holiday			Char(1)  
 DECLARE @Late_Adj_Day			Numeric(5,2)      
 DECLARE @OT_Min_Limit			Varchar(20)      
 DECLARE @OT_Max_Limit			Varchar(20)      
 DECLARE @OT_Min_Sec			Numeric      
 DECLARE @OT_Max_Sec			Numeric      
 DECLARE @Is_OT_Inc_Salary		Float      
 DECLARE @Is_Daily_OT			Char(1)      
 Declare @Fix_OT_Shift_Hours   VARCHAR(20)
 Declare @Fix_OT_Shift_Sec  Numeric      
 DECLARE @Fix_OT_Work_Days		NUMERIC(18, 4)      
 DECLARE @Round					Numeric      
 declare @Restrict_Present_Days Char(1)      
 DECLARE @Is_Cancel_Holiday		Tinyint      
 DECLARE @Is_Cancel_Weekoff		Tinyint    
 DECLARE @Join_Date				Datetime      
 DECLARE @Left_Date				Datetime       
 DECLARE @StrHoliday_Date		Varchar(1000)      
 DECLARE @StrWeekoff_Date		Varchar(1000)      
 DECLARE @Update_Adv_Amount		Numeric       
 DECLARE @Total_Claim_Amount	Numeric(18,3)       
 DECLARE @Is_PT					Numeric      
 DECLARE @Is_Emp_PT				Numeric      
 DECLARE @PT_Amount				Numeric(18,2)      
 DECLARE @PT_Calculated_Amount  Numeric       
 DECLARE @LWF_Amount			Numeric       
 DECLARE @LWF_App_Month			Varchar(50)      
 DECLARE @Revenue_Amount		Numeric       
 DECLARE @Revenue_On_Amount		Numeric       
 DECLARE @LWF_compare_month		Varchar(5)      
 DECLARE @PT_F_T_Limit			Varchar(20)      
 DECLARE @Lv_Salary_Effect_on_PT Tinyint       
 DECLARE @Leave_Salary_Amount   Numeric(12,0)      
 DECLARE @Settelement_Amount    Numeric(12,0)      
 DECLARE @Bonus_Amount			Numeric(10,0)
 DECLARE @OT_Working_Day	    Numeric(4,1) 
 DECLARE @StrMonth			    Varchar(10)         
 DECLARE @Is_Zero_Day_Salary    Numeric(2)--nikunj At 7-sep-2010 for zero day
  Declare @Cmp_Name As Varchar(100)--nikunj 
 Declare @Leave_Encash_Day As NUMERIC(18, 4)--nikunj 
		Set @Leave_Encash_Day = 0
 Declare @Basic_Salary_Org As NUMERIC(18, 4)		
		Set @Basic_Salary_Org=0	
 Declare @L_Sal_Tran_ID As Numeric(18,0)		
		Set @L_Sal_Tran_ID=0
 
DECLARE @Travel_Advance_Amount Numeric(18,3) -- Added by rohit on 24082015
DECLARE @Travel_Amount Numeric(18,3) 

 
 
 declare @Present_Days_Total  NUMERIC(18, 4)
 
 Declare @Is_Zero_Basic_Salary tinyint -- 'Alpesh 25-Nov-2011
 Declare @out_of_days_temp Numeric
 
 Declare @Alpha_Emp_Code	varchar(50)		----Alpesh 23-May-2012
 Declare @LogDesc	nvarchar(max)		----Alpesh 23-May-2012
 
 Declare @Extra_AB_Days numeric(18, 2)	---Alpesh 20-Mar-2012
 Declare @Extra_AB_Rate numeric(18, 2)	---Alpesh 20-Mar-2012
 Declare @Extra_AB_Amount numeric(18, 2)---Alpesh 20-Mar-2012
 
 declare @Emp_WD_OT_Rate numeric(5,1)  --Hardik 17/07/2012
 Declare @Paid_Weekoff_Daily_Wages Tinyint  --Hardik 13/08/2012
 Set @Paid_Weekoff_Daily_Wages = 0
 
 Set @Extra_AB_Days = 0
 Set @Extra_AB_Rate = 0
 Set @Extra_AB_Amount = 0
 
 declare @is_emp_lwf tinyint
 set @is_emp_lwf = 0
 
 declare @Allow_Amount_Effect_only_Net NUMERIC(18, 4) -- Rohit on 06-may-2013
 declare @Deduct_Amount_Effect_only_Net NUMERIC(18, 4) -- Rohit on 06-may-2013
 declare @Fix_OT_Hour_Rate_WD numeric(18,3)			--Ankit 03122013

 DECLARE @net_round AS NUMERIC(18, 4)
 DECLARE @net_round_Type AS NVARCHAR(50)
 Declare @Temp_mid_Net_Amount NUMERIC(18, 4)
 Declare @mid_Net_Round_Diff_Amount NUMERIC(18, 4)
 SET @net_round = 0
 SET @net_round_Type = ''
 SET @Temp_mid_Net_Amount = 0
 SET @mid_Net_Round_Diff_Amount = 0
 set @OutOf_Days_Arear = 0
 Declare @OldValue varchar(max)  -- Added By Gadriwala Muslim 08102014
 set @OldValue = ''
 Declare @Old_Emp_Name varchar(max)  -- Added By Gadriwala Muslim 08102014
 set @Old_Emp_Name = ''

 --Ankit 06012015-- 
 Declare @WO_OT_Hours		NUMERIC(18, 4)	
 Declare @HO_OT_Hours		NUMERIC(18, 4)	
 declare @Emp_WO_OT_Sec		Numeric		
 declare @Emp_WO_OT_Hours	Varchar(10) 
 declare @Emp_HO_OT_Sec		Numeric		
 declare @Emp_HO_OT_Hours	Varchar(10) 
 declare @WO_OT_Amount		Numeric(22,3)
 declare @HO_OT_Amount		Numeric(22,3)
 
 declare @Emp_WO_OT_Rate	numeric(5,1)
 declare @Emp_HO_OT_Rate	numeric(5,1)
 Declare @Emp_WO_OT_Hours_Var As Varchar(10)	
 Declare @Emp_WO_OT_Hours_Num As Numeric(22,3)	
 Declare @Emp_HO_OT_Hours_Var As Varchar(10)	
 Declare @Emp_HO_OT_Hours_Num As Numeric(22,3)	
 Declare @Fix_OT_Hour_Rate_WOHO numeric(18,3)			--Ankit 03122013
 declare  @Asset_Installment NUMERIC(18, 4) --Mukti 23032015
 DECLARE @TotASSET_Closing NUMERIC(18, 4)--Mukti 25032015
 DECLARE @DayRate_WO_Cancel tinyint --Hardik 20/05/2015
 
 Declare @Is_Cancel_Holiday_WO_HO_same_day tinyint --Added By nilesh on 19112015(For Cancel Holiday When WO/HO on Same Day
 Set @Is_Cancel_Holiday_WO_HO_same_day = 0
 
 Declare @present_on_holiday numeric(18,2)  -- Added by rohit on 29022016 for present on holiday
 Declare @mid_Present_On_Holiday Numeric(18,2)
 declare @Present_Days_temp as numeric(18,2) --Added by Rohit on 29072016
 set @Present_Days_temp = @Present_Days
	
 set @mid_Present_On_Holiday = 0
 set @present_on_holiday = 0

 set @Asset_Installment=0	
 Set @WO_OT_Hours = 0
 Set @HO_OT_Hours = 0
 Set @Emp_WO_OT_Sec = 0
 Set @Emp_WO_OT_Hours = ''
 Set @Emp_HO_OT_Sec = 0
 Set @Emp_HO_OT_Hours = ''
 Set @WO_OT_Amount = 0
 Set @HO_OT_Amount = 0
 Set @Emp_WO_OT_Rate = 0
 Set @Emp_HO_OT_Rate = 0 
 
 Set @Emp_WO_OT_Rate	  = 0
 Set @Emp_HO_OT_Rate	  = 0 
 Set @Emp_WO_OT_Hours_Var = ''
 Set @Emp_WO_OT_Hours_Num = 0
 Set @Emp_HO_OT_Hours_Var = ''
 Set @Emp_HO_OT_Hours_Num = 0
 Set @Fix_OT_Hour_Rate_WOHO = 0
--Ankit 06012015
set @DayRate_WO_Cancel = 0


	DECLARE @BOND_AMOUNT			NUMERIC(18, 4) --ADDED BY RAJPUT ON 04102018
		SET @BOND_AMOUNT = 0

-- Added By Nilesh Patel On 06052017 for Uniform Modules 
DECLARE @Uniform_Deduction_Amount Numeric(18,2)
DECLARE @Uniform_Refund_Amount Numeric(18,2)
DECLARE @mid_Unifrom_dedu_Amt  Numeric(18,2)
DECLARE @mid_Unifrom_ref_Amt  Numeric(18,2)

Set @Uniform_Deduction_Amount = 0
Set @Uniform_Refund_Amount = 0
Set @mid_Unifrom_dedu_Amt = 0
Set @mid_Unifrom_ref_Amt = 0
-- Added By Nilesh Patel On 06052017 for Uniform Modules 

	-- ADDED BY RAJPUT ON 16072018
	DECLARE @OT_RATE_TYPE AS TINYINT = 0 
	DECLARE @OT_SLAB_TYPE AS TINYINT = 0 
	DECLARE @IS_ROUNDING AS NUMERIC(1,0) 
	SET @IS_ROUNDING = 1    
	DECLARE @GEN_ID NUMERIC 
	SET @GEN_ID = 0
	--- END ---

 -- Temporary Table------------- 
  CREATE TABLE #OT_Data
  (
	Emp_ID			Numeric ,
	Basic_Salary	Numeric(18,5),
	Day_Salary		Numeric(12,5),
	OT_Sec			Numeric,
	Ex_OT_Setting	Tinyint,
	OT_Amount		Numeric,
	Shift_Day_Sec	Int,
	OT_Working_Day	Numeric(4,1),
	Emp_OT_Hour     NUMERIC(18, 4),
	Hourly_Salary   Numeric(18,5), 
	WO_OT_Sec	Numeric,
	WO_OT_Amount Numeric(22,3),
	WO_OT_Hour	Numeric(22,3),
	HO_OT_Sec	Numeric,
	HO_OT_Amount Numeric(22,3),
	HO_OT_Hour	Numeric(22,3)
  )    
  

 CREATE TABLE #Emp_Holiday
	  (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			H_Day		numeric(3,1),
			is_Half_day tinyint
	  )	
-- Temporary Table------------- 

 Set @Present_Days_Total = @Present_Days
 SET @OutOf_Days			= DATEDIFF(d,@Month_St_Date,@Month_End_Date) + 1
 SET @Emp_OT				= 0      
 SET @Wages_Type			= ''      
 SET @SalaryBasis			= ''      
 SET @Payment_Mode			= ''      
 SET @Fix_Salary			= 0      
 SET @numAbsentDays			=0      
 SET @numWorkingDays_Daily  = 0      
 SET @numAbsentDays_Daily   = 0      
 SET @Sal_cal_Days			= 0      
 SET @Absent_Days			= 0      
 SET @Holiday_Days			= 0      
 SET @Weekoff_Days			= 0      
 SET @Cancel_Holiday		= 0      
 SET @Cancel_Weekoff	    = 0      
 SET @Working_days			= 0      
 SET @Total_leave_Days		= 0      
 SET @Paid_leave_Days		= 0      
 SET @OD_leave_Days		= 0      
 SET @Update_Adv_Amount		= 0      
 SET @Total_Claim_Amount    = 0      
 SET @Unpaid_Leave			=0
 SET @Actual_Working_Hours  =''      
 SET @Actual_Working_Sec	=0      
 SET @Working_Hours			= ''      
 SET @Outof_Hours			= ''      
 SET @Total_Hours			= ''      
 SET @Shift_Day_Sec			= 0       
 SET @Shift_Day_Hour	    = ''      
 SET @Basic_Salary			= 0       
 SET @Day_Salary			= 0      
 SET @Hour_Salary			= 0      
 SET @Salary_amount			= 0      
 SET @Allow_Amount			= 0      
 SET @OT_Amount				= 0      
 SET @Other_allow_Amount    = @Areas_Amount      
 SET @Gross_Salary			= 0      
 SET @Dedu_Amount			= 0      
 SET @Loan_Amount			= 0      
 SET @Loan_Interest_Amount	= 0      
 Set @Loan_Interest_Percent = 0
 SET @Advance_Amount		= 0      
 SET @Other_Dedu_Amount		= @Other_Dedu 
 SET @Other_m_it_Amount		= 0--@M_IT_Tax commented by Falak on 13/10/2011 to ALTER TDS allowance     
 SET @Total_Dedu_Amount		= 0      
 SET @Due_Loan_Amount		= 0      
 SET @Net_Amount			= 0      
 SET @Final_Amount			= 0      
 SET @Hour_Salary_OT		= 0       
 SET @Inc_Weekoff			= 1  
 SET @Inc_Holiday			=1
 SET @Late_Adj_Day			= 0      
 SET @ExOTSetting			= 0      
 SET @OT_Min_Limit			=''      
 SET @OT_Max_Limit			= ''      
 SET @Is_OT_Inc_Salary		= 0     
 SET @Is_Daily_OT			= 'N'      
 set @Fix_OT_Shift_Hours = ''    
 Set @Fix_OT_Shift_Sec = 0      
 SET @Fix_OT_Work_Days		= 0      
 SET @OT_Min_Sec			= 0      
 SET @OT_Max_Sec			= 0      
 SET @Round					= 0      
 SET @Restrict_Present_Days = 'Y'      
 SET @Is_Cancel_Weekoff		= 0  
 SET @Is_Cancel_Holiday		= 0       
 Set @StrHoliday_Date		= ''      
 SET @StrWeekoff_Date       = ''      
 SET @Emp_OT_Min_Limit      = ''      
 SET @Emp_OT_Max_Limit      = ''      
 SET @Emp_OT_Min_Sec        = 0      
 SET @Emp_OT_Max_Sec		= 0      
 SET @Emp_OT_Sec			= @M_OT_Hours * 3600      
 SET @Is_PT					= 0      
 SET @Is_Emp_PT				= 0      
 SET @PT_Amount				= 0      
 SET @PT_Calculated_Amount  = 0      
 SET @LWF_Amount			=0      
 SET @LWF_App_Month			= ''      
 SET @Revenue_Amount		=0      
 SET @Revenue_On_Amount		= 0      
 SET @LWF_compare_month		=''      
 SET @PT_F_T_Limit			= ''      
 SET @Lv_Salary_Effect_on_PT  =0      
 SET @Leave_Salary_Amount	= 0      
 SET @Settelement_Amount	= 0      
 SET @Bonus_Amount			=0       
 SET @StrMonth='#' + CAST(MONTH(@Month_End_Date) AS VARCHAR(2)) + '#' 
 Set @Basic_Salary_Arear = 0 --Hardik 07/01/2012
 Set @Gross_Salary_Arear = 0 --Hardik 07/01/2012
 Set @Salary_amount_Arear = 0 --Hardik 07/01/2012
 Set @Allow_Amount_Arear = 0 --Hardik 07/01/2012
 Set @Day_Salary_Arear = 0 --Hardik 07/01/2012
 Set @Dedu_Amount_Arear = 0 --Hardik 07/01/2012
 Set @Emp_WD_OT_Rate = 0 --Hardik 17/07/2012

 set @Allow_Amount_Effect_only_Net=0 -- Rohit on 06-may-2013
 set @Deduct_Amount_Effect_only_Net=0 -- rohit on 06-may-2013
 Set @Fix_OT_Hour_Rate_WD =0	--Ankit 03122013
 
 Set @Compoff_leave_Days = 0
 Set @Mid_Compoff_leave_Days = 0 

     
 DECLARE @Old_Present_Days2			  NUMERIC(18, 4)
 DECLARE @Old_basic_Salary            NUMERIC(18, 4)
 DECLARE @Old_Actuall_Gross_Salary    NUMERIC(18, 4)
 DECLARE @Present_Days1               NUMERIC(18, 4)
 DECLARE @Mid_Increment				  INTEGER
 DECLARE @Emp_Part_Time				  NUMERIC
 DECLARE @Wages_Amount				  NUMERIC(18,0)
 DECLARE @ROUNDING AS NUMERIC(18,0)
 Declare @Lv_Encash_Cal_On varchar(50)
 
 Declare @Arear_Day Numeric(5,1) --Hardik 04/01/2012
 Declare @Arear_Month Numeric(5,1) --Hardik 04/01/2012
 Declare @Arear_Year Numeric(5,1) --Hardik 04/01/2012
 Declare @Arear_Amount Numeric(22,4) -- Hardik 04/01/2012
 Declare @M_Cancel_weekOff Numeric(5,1) --Hasmukh 30/01/2012
 Declare @Allow_Negative_Sal Tinyint --Mihir Trivedi 25/07/2012
 Declare @Next_Month_Advance NUMERIC(18, 4) --Mihir Trivedi 25/07/2012
 Declare @Next_Month_StrtDate Datetime --Mihir Trivedi 25/07/2012
 Declare @M_Cancel_Holiday Numeric(5,1) --Hasmukh 31/08/2012  
 
 
 declare @Holiday_Days_Arear  NUMERIC(18, 4)    -- Added by Hardik 21/05/2014
 declare @Weekoff_Days_Arear  NUMERIC(18, 4)    --- Added by Hardik 21/05/2014
 declare @Working_days_Arear  NUMERIC(18, 4)    -- Added by Hardik 21/05/2014
 Declare @StrHoliday_Date_Arear  varchar(Max)    -- Added by Hardik 21/05/2014
 Declare @StrWeekoff_Date_Arear  varchar(Max)     -- Added by Hardik 21/05/2014

 Set @Holiday_Days_Arear = 0	-- Added by Hardik 21/05/2014
 Set @Weekoff_Days_Arear = 0    --- Added by Hardik 21/05/2014
 Set @Working_days_Arear = 0    -- Added by Hardik 21/05/2014

 SET @Mid_Increment				=0
 SET @Old_Present_Days2			=0
 SET @Present_Days1				=0
 SET @Old_Actuall_Gross_Salary  =0
 SET @Old_basic_Salary			=0
 SET @Wages_Amount				=0
 SET @Emp_Part_Time				=0
 set @M_Cancel_Holiday = 0  
 
 SET @Lv_Encash_Cal_On = ''
 SET @ROUNDING = 1
 
 Set @Arear_Day = 0  --Hardik 04/01/2012
 Set @Arear_Month = 0 --Hardik 04/01/2012
 Set @Arear_Year = 0 --Hardik 04/01/2012
 Set @Arear_Amount = 0 -- Hardik 04/01/2012
 set @M_Cancel_weekOff = 0 --Hasmukh 30/01/2012
 Set @Allow_Negative_Sal = 0 --Mihir trivedi 25/07/2012
 set @out_of_days_temp = @OutOf_Days

 -----Mid of Increment Salary----------------------
    -- set @Old_Present_Days2= @Present_Days
    --Exec P0200_Manually_Salary_Mid_Increment  @M_Sal_Tran_ID , @Emp_Id, @Cmp_ID , @Sal_Generate_Date , @Month_St_Date , @Month_End_Date, @Old_Present_Days2 output , @M_OT_Hours   , @Areas_Amount , @M_IT_Tax , @Other_Dedu , @M_LOAN_AMOUNT , $ , @IS_LOAN_DEDU , @Login_ID, @ErrRaise , @Is_Negetive , @Status , @IT_M_ED_Cess_Amount, @IT_M_Surcharge_Amount , @Allo_On_Leave,@Old_basic_Salary output ,@Old_Actuall_Gross_Salary output  ,@Present_Days1    output   
 -----Mid of Increment ----------------------
 
 --Added by Hardik 12/08/2013 for Split Shift Calculation
CREATE TABLE #Split_Shift_Table
(
 Emp_Id Numeric,
 Split_Shift_Count Numeric(18,0),
 Split_Shift_Dates varchar(5000),
 Split_Shift_Allow NUMERIC(18, 4)
)

 Create Table #Loan_Due_Amount
(
	Emp_ID Numeric,
	Loan_ID Numeric(18,0),
	Loan_Closing Numeric(18,2)
) 

 Declare @Sal_St_Date   Datetime    
 Declare @Sal_end_Date   Datetime   
 
 --Alpesh 23-Mar-2012 put this to get Branch_Id to get Salary_St_Date when Branches have diff Salary_St_date but chk for Mid Increment
   select @Branch_ID = Branch_ID From dbo.T0095_Increment I WITH (NOLOCK) inner join     
   (select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)   
   where Increment_Effective_date <= @Month_End_Date and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_id group by emp_ID) Qry on    
   I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID Where I.Emp_ID = @Emp_ID 
  --End 
 
 -- added By rohit on 11022013
 declare @manual_salary_period as numeric(18,0)
 set @manual_salary_period = 0
 
  --Added By Ramiz for Mafatlals
  DECLARE @Gradewise_Salary_Enabled	tinyint   
  SELECT @Gradewise_Salary_Enabled = isnull(Setting_Value,0) from T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name = 'Show Gradewise Salary Textbox in Grade Master'
   
 
  declare @is_salary_cycle_emp_wise as tinyint -- added by mitesh on 03072013
   set @is_salary_cycle_emp_wise = 0
   
   select @is_salary_cycle_emp_wise = isnull(Setting_Value,0) from dbo.T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name = 'Salary Cycle Employee Wise'
   
  
	DECLARE @Salary_Cycle_id AS NUMERIC
	SET @Salary_Cycle_id  = 0
	if @is_salary_cycle_emp_wise = 1
		begin						
			
			SELECT @Salary_Cycle_id = salDate_id from dbo.T0095_Emp_Salary_Cycle WITH (NOLOCK) where emp_id = @Emp_Id AND effective_date in
			(SELECT max(effective_date) as effective_date from dbo.T0095_Emp_Salary_Cycle WITH (NOLOCK) 
			where emp_id = @Emp_Id AND effective_date <=  @Month_End_Date
			GROUP by emp_id)
			
			SELECT @Sal_St_Date = SALARY_ST_DATE FROM dbo.t0040_salary_cycle_master WITH (NOLOCK) where tran_id = @Salary_Cycle_id
			
		end

	if @Salary_Cycle_id  = 0
		begin
			If @Branch_ID is null
				Begin 
					select Top 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) -- added By rohit on 11022013
					  ,@Is_Cancel_Holiday_WO_HO_same_day = Is_Cancel_Holiday_WO_HO_same_day -- Added by nilesh patel on 19112015
					  ,@Restrict_Present_Days = Restrict_Present_days
					  from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
					  and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Cmp_ID = @Cmp_ID)    
				End
			Else
				Begin
				
					select @Sal_St_Date  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) -- added By rohit on 11022013
					  ,@Is_Cancel_Holiday_WO_HO_same_day = Is_Cancel_Holiday_WO_HO_same_day -- Added by nilesh patel on 19112015
					  ,@Restrict_Present_Days = Restrict_Present_days
					  from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
					  and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
				End
		end	 
   
   
   
 if isnull(@Sal_St_Date,'') = ''    
	  begin    
		   set @Month_St_Date  = @Month_St_Date     
		   set @Month_End_Date = @Month_End_Date    
		   set @OutOf_Days = @OutOf_Days
	  end     
 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)= 1    
	  begin    
		   set @Month_St_Date  = @Month_St_Date     
		   set @Month_End_Date = @Month_End_Date    
		   set @OutOf_Days = @OutOf_Days    	         
	  end     
 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
	  begin    
		    -- Comment and added By rohit on 11022013
		   --set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Month_St_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Month_St_Date) )as varchar(10)) as smalldatetime)    
		   --set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
		   --set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
		   
		   --Set @Month_St_Date = @Sal_St_Date
		   --Set @Month_End_Date = @Sal_End_Date  		   
		   
		    if @manual_salary_period = 0   
				Begin
				   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Month_St_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Month_St_Date) )as varchar(10)) as smalldatetime)    
				   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
				   set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
		   
				   Set @Month_St_Date = @Sal_St_Date
				   Set @Month_End_Date = @Sal_End_Date
				End
			Else
				Begin
					select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@Month_St_Date) and YEAR=year(@Month_St_Date)
					set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
				   
				    Set @Month_St_Date = @Sal_St_Date
				    Set @Month_End_Date = @Sal_End_Date 
				End      
		-- Comment ended By rohit on 11022013  
	  end
	 
	----Alpesh 09-May-2012 --Updated on 1-Jan-2012
	--IF EXISTS(SELECT EMP_ID FROM  T0200_MONTHLY_SALARY WHERE Cmp_ID=@Cmp_ID and EMP_ID=@EMP_ID AND Month_St_Date=@Month_St_Date and Month_End_Date=@Month_End_Date)
	IF EXISTS(SELECT EMP_ID from dbo.T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and EMP_ID=@EMP_ID AND Month(Month_End_Date)=Month(@Month_End_Date) and YEAR(Month_End_Date)=YEAR(@Month_End_Date))
		Begin			
			SELECT @M_Sal_Tran_ID=Sal_Tran_ID from dbo.T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and EMP_ID=@EMP_ID AND Month(Month_End_Date)=Month(@Month_End_Date) and YEAR(Month_End_Date)=YEAR(@Month_End_Date)
		End  
    ---- End ----
    
    Declare @Salary_Depends_on_Production as tinyint
    Declare @Grd_Id as numeric
    Declare @Production_Gross_Salary as NUMERIC(18, 4)
    Set @Salary_Depends_on_Production=0
    Set @Grd_Id=0
    Set @Production_Gross_Salary = 0

    
    Select @Alpha_Emp_Code=Alpha_Emp_Code , @is_emp_lwf = Is_LWF,@Left_Date = Emp_Left_Date, @Join_Date = Date_Of_Join, @Salary_Depends_on_Production = Salary_Depends_on_Production   
    from dbo.T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_Id		
    
    --Hardik 15/10/2012	-- modified by mitesh
  --  If @Left_Date <= @Month_End_Date
		--begin
		--	set @Month_End_Date = @Left_Date
		--	set @OutOf_Days = datediff(d,@Month_St_Date,@Month_End_Date) + 1
		--end
    
	IF EXISTS(SELECT EMP_ID from dbo.T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE EMP_ID =@EMP_ID AND  Month_St_Date >= @Sal_End_Date)
		Begin
			set @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Month='+cast(MONTH(@Month_End_Date) as varchar)+', Year='+cast(year(@Month_End_Date) as varchar)
			--Changed by Gadriwala Muslim 17/01/2017 'Salary' to 'Salary Manual#'
			exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Salary Manual#','Next Month salary Exists',@LogDesc,1,''			 		
			--Raiserror('Next Month salary Exists',16,2)
			return -1
		End
		
		
    If Exists(Select Pf_Challan_Id From dbo.T0220_Pf_Challan WITH (NOLOCK) Where Cmp_Id=@Cmp_Id And Month=Month(@Sal_End_Date) And Year = Year(@Sal_End_Date) And CHARINDEX('#'+ Cast(@Branch_ID As VARCHAR(18)) +'','#' + Branch_ID_Multi) > 0)
		Begin
				--RAISERROR ('Pf Challan Exists', -- Message text.
				--					16, -- Severity.
				--					2   -- State.
				--					);
				RETURN
		End
    If Exists(Select Esic_Challan_Id From dbo.T0220_ESIC_Challan WITH (NOLOCK) Where Cmp_Id=@Cmp_Id And Month=Month(@Sal_End_Date) And Year = Year(@Sal_End_Date) And CHARINDEX('#'+ Cast(@Branch_ID As VARCHAR(18)) +'','#' + Branch_ID_Multi) > 0)
		Begin
				--RAISERROR ('ESIC Challan Exists', -- Message text.
				--					16, -- Severity.
				--					2   -- State.
				--					);
				RETURN
		End
 
 
 IF @M_Sal_Tran_ID > 0       
  BEGIN      
    SET @Sal_Tran_ID  = @M_Sal_Tran_ID       
    DELETE from dbo.T0210_Monthly_Leave_Detail   WHERE  emp_id = @Emp_id	 AND Sal_Tran_ID = @Sal_Tran_ID       
    DELETE from dbo.T0210_MONTHLY_AD_DETAIL      WHERE emp_id = @emp_id		 AND Sal_Tran_ID = @Sal_Tran_ID        
    DELETE from dbo.T0210_MONTHLY_LOAN_PAYMENT   WHERE Sal_Tran_ID = @Sal_Tran_ID      
    --DELETE from dbo.T0210_MONTHLY_CLAIM_PAYMENT  WHERE Sal_Tran_ID = @Sal_Tran_ID      
    DELETE from dbo.T0210_PAYSLIP_DATA			 WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
    DELETE from dbo.T0100_Anual_bonus			 WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
    DELETE from dbo.T0200_monthly_salary_leave   WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
    SELECT @Sal_Receipt_No =  Sal_Receipt_No from dbo.T0200_MONTHLY_SALARY	WITH (NOLOCK) WHERE Sal_Tran_ID =@Sal_Tran_ID 
    
  END
 ELSE      
  BEGIN
      
   SELECT @Sal_Tran_Id =  Isnull(max(Sal_Tran_Id),0)  + 1   from dbo.T0200_MONTHLY_SALARY WITH (NOLOCK)     
   SELECT @Sal_Receipt_No =  isnull(max(sal_Receipt_No),0)  + 1  from dbo.T0200_MONTHLY_SALARY WITH (NOLOCK) Where Month(Month_St_Date) = Month(@Month_St_DAte)       
   AND YEar(Month_St_Date) = Year(@Month_End_Date) and Cmp_ID= @Cmp_ID 
    
    
       -- added by mitesh on 30/10/2012
	    DELETE from dbo.T0210_MONTHLY_LEAVE_DETAIL   WHERE EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID   AND CMP_ID=@CMP_ID  and isnull(Sal_Tran_ID,0) <> @Sal_Tran_ID 
		DELETE from dbo.T0210_MONTHLY_AD_DETAIL    WHERE EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID   AND CMP_ID=@CMP_ID  and isnull(Sal_Tran_ID,0) <> @Sal_Tran_ID 
		DELETE from dbo.T0210_MONTHLY_AD_DETAIL    WHERE EMP_ID = @EMP_ID AND CMP_ID=@CMP_ID and isnull(Sal_Tran_ID,0) <> @Sal_Tran_ID And MONTH(To_date)=MONTH(@Month_End_Date) And Year(To_date)=Year(@Month_End_Date)		
		DELETE from dbo.T0210_MONTHLY_LOAN_PAYMENT   WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID   AND CMP_ID=@CMP_ID  and isnull(Sal_Tran_ID,0) <> @Sal_Tran_ID 
		--DELETE from dbo.T0210_MONTHLY_CLAIM_PAYMENT   WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID  AND CMP_ID=@CMP_ID  and isnull(Sal_Tran_ID,0) <> @Sal_Tran_ID 
		DELETE from dbo.T0210_PAYSLIP_DATA    WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID  AND CMP_ID=@CMP_ID  and isnull(Sal_Tran_ID,0) <> @Sal_Tran_ID 
		DELETE from dbo.T0210_MONTHLY_LOAN_PAYMENT WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID  AND CMP_ID=@CMP_ID and isnull(Sal_Tran_ID,0) <> @Sal_Tran_ID 
		--DELETE from dbo.T0100_Anual_bonus    WHERE temp_Sal_Tran_ID = @SAL_TRAN_ID  and Sal_Tran_ID <> @Sal_Tran_ID 
		--delete from dbo.T0200_monthly_salary_leave  WHERE temp_Sal_Tran_ID = @SAL_TRAN_ID  and Sal_Tran_ID <> @Sal_Tran_ID 
		-- added by mitesh on 30/10/2012
		
		--Ankit 04042016
		DELETE FROM dbo.T0200_MONTHLY_SALARY_LEAVE  WHERE EMP_ID = @EMP_ID AND CMP_ID=@CMP_ID AND ISNULL(Sal_Tran_ID,0) <> @Sal_Tran_ID AND MONTH(L_Month_End_Date)=MONTH(@Month_End_Date) AND YEAR(L_Month_End_Date)=YEAR(@Month_End_Date)
		--Ankit 04042016
  END      
  
  DECLARE @SAL_FIX_DAYS AS NUMERIC(18, 4)
  SET @SAL_FIX_DAYS =0
  
  
    
  CREATE TABLE #Mid_Increment
  (
	Emp_ID			numeric ,
	Increment_id	numeric,
	Increment_effective_Date	datetime	
  )
  
   declare @temp_increment_id as numeric
   declare @temp_increment_Effec_Date as Datetime	--Ankit 04092014
   
  SET @temp_increment_id = 0
  
  insert into #Mid_Increment (Increment_effective_Date,Emp_ID,Increment_id)
  select EI.Increment_effective_Date , EI.Emp_ID, EI.Increment_ID 
  from dbo.T0095_Increment EI WITH (NOLOCK)
  where Increment_ID in 
		  (select Max(TI.Increment_ID) Increment_Id from t0095_increment TI WITH (NOLOCK) inner join
		(Select Max(Increment_Effective_Date) as Increment_Effective_Date from T0095_Increment WITH (NOLOCK)
			Where Increment_effective_Date <= @Month_St_Date And Cmp_ID=@Cmp_Id And Emp_ID = @Emp_Id 
			and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation') new_inc
		on Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
		Where TI.Increment_effective_Date <= @Month_St_Date And Emp_ID = @Emp_Id and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation') 
 Order by EI.Increment_effective_Date

  
  --(select max(Increment_ID) as Increment_effective_Date 
		--				from dbo.T0095_Increment  where Increment_Effective_date <= @Month_St_Date and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id 
		--				and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' ) 
		--and Emp_ID = @Emp_Id and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation'
  

	
   select @temp_increment_id = EI.Increment_ID 
   from dbo.T0095_Increment EI WITH (NOLOCK) 
   where Increment_ID IN 
	   (select Max(TI.Increment_ID) Increment_Id from t0095_increment TI WITH (NOLOCK) inner join
			(Select Max(Increment_Effective_Date) as Increment_Effective_Date from T0095_Increment WITH (NOLOCK) 
				Where Increment_effective_Date <= @Month_St_Date And Cmp_ID=@Cmp_Id And Emp_ID = @Emp_Id 
				and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation') new_inc
			on Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
			Where TI.Increment_effective_Date <= @Month_St_Date And Emp_ID = @Emp_Id and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation')
	
		
   /* (select max(Increment_ID) as Increment_effective_Date 
						from dbo.T0095_Increment  
						where Increment_Effective_date <= @Month_St_Date  and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' )
		and Emp_ID = @Emp_Id  and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' 
*/

    
  insert into #Mid_Increment (Increment_effective_Date,Emp_ID,Increment_id)
  select Increment_effective_Date , Emp_ID, Increment_ID from dbo.T0095_Increment WITH (NOLOCK) 
  where Emp_ID = @Emp_Id and Increment_Effective_date >= @Month_St_Date 
	and Increment_Effective_date <= @Month_End_Date
	and Increment_ID <> @temp_increment_id --And Increment_Effective_date <> @temp_increment_Effec_Date
		and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' 
	
	
				
	declare @mid_gross_Amount NUMERIC(18, 4)
	declare @mid_basic_Amount NUMERIC(18, 4)
	declare @mid_salary_Amount NUMERIC(18, 4)
	declare @tmp_Month_St_Date datetime
	declare @tmp_Month_End_Date datetime
	declare @first_Month_End_Date datetime
	declare @increment_Month numeric
	declare @Mid_Inc_Working_Day NUMERIC(18, 4) 
	declare @mid_Sal_Cal_Days NUMERIC(18, 4)
	declare @mid_Present_Days NUMERIC(18, 4)
	declare @mid_Absent_Days NUMERIC(18, 4)
	declare @mid_Holiday_Days NUMERIC(18, 4)
	declare @mid_WeekOff_Days NUMERIC(18, 4)
	declare @mid_cancel_holiday NUMERIC(18, 4)
	declare @mid_cancel_weekoff NUMERIC(18, 4)
	declare @mid_total_leave_days NUMERIC(18, 4)
	declare @mid_paid_leave_days NUMERIC(18, 4)
	Declare @Mid_OD_leave_Days NUMERIC(18, 4)
	declare @mid_Actual_Working_Hours varchar(20)    
	declare @mid_Working_Hours varchar(20)    
	declare @mid_Outof_Hours varchar(20)   
	declare @mid_OT_Hours	numeric(18, 2)
	declare @mid_Total_Hours	varchar(20)
	declare @mid_Shift_Day_Sec	numeric(18, 0)
	declare @mid_Shift_Day_Hour	varchar(20)
	
	declare @mid_Day_Salary	numeric(18, 5)
	declare @mid_Hour_Salary	numeric(18, 5)
	declare @mid_Allow_Amount	numeric(18, 2)
	declare @mid_OT_Amount	numeric(18, 2)
	declare @mid_Other_Allow_Amount	numeric(18, 2)
	
	declare @mid_Dedu_Amount	numeric(18, 2)
	declare @mid_Loan_Amount	numeric(18, 2)
	declare @mid_Loan_Intrest_Amount	numeric(18, 2)
	declare @mid_Advance_Amount	numeric(18, 2)
	declare @mid_Other_Dedu_Amount	numeric(18, 2)
	declare @mid_Total_Dedu_Amount	numeric(18, 2)
	declare @mid_Due_Loan_Amount	numeric(18, 2)
	declare @mid_Net_Amount	numeric(18, 2)
	declare @mid_Actually_Gross_Salary	numeric(18, 2)
	declare @mid_PT_Amount	numeric(18, 2)
	declare @mid_PT_Calculated_Amount	numeric(18, 0)
	declare @mid_Total_Claim_Amount	numeric(18, 3)
	declare @mid_M_OT_Hours	numeric(18, 2)
	declare @mid_M_Adv_Amount	numeric(18, 0)
	declare @mid_M_Loan_Amount	numeric(18, 0)
	declare @mid_M_IT_Tax	numeric(18, 0)
	declare @mid_LWF_Amount	numeric(18, 0)
	declare @mid_Revenue_Amount	numeric(18, 0)
	declare @mid_PT_F_T_Limit	varchar(20)
	declare @mid_Settelement_Amount	numeric(18, 0)
	declare @mid_Settelement_Comments	varchar(250)
	declare @mid_Leave_Salary_Amount	numeric(18, 0)
	declare @mid_Leave_Salary_Comments	varchar(250)
	declare @mid_Late_Sec	numeric(18, 0)
	declare @mid_Late_Dedu_Amount	numeric(18, 0)
	declare @mid_Late_Extra_Dedu_Amount	numeric(18, 0)
	declare @mid_Late_Days	numeric(5, 2)
	declare @mid_Short_Fall_Days	numeric(5, 2)
	declare @mid_Short_Fall_Dedu_Amount	numeric(10, 0)
	declare @mid_Gratuity_Amount	numeric(10, 0)
	declare @mid_Is_FNF	tinyint
	declare @mid_Bonus_Amount	numeric(10, 0)
	declare @mid_Incentive_Amount	numeric(10, 0)
	declare @mid_Trav_Earn_Amount	numeric(7, 0)
	declare @mid_Cust_Res_Earn_Amount	numeric(7, 0)
	declare @mid_Trav_Rec_Amount	numeric(7, 0)
	declare @mid_Mobile_Rec_Amount	numeric(7, 0)
	declare @mid_Cust_Res_Rec_Amount	numeric(7, 0)
	declare @mid_Uniform_Rec_Amount	numeric(7, 0)
	declare @mid_I_Card_Rec_Amount	numeric(7, 0)
	declare @mid_Excess_Salary_Rec_Amount	numeric(10, 0)
	declare @mid_Salary_Status	varchar(20)
	declare @mid_Pre_Month_Net_Salary	numeric(18, 0)
	declare @mid_IT_M_ED_Cess_Amount	numeric(18, 2)
	declare @mid_IT_M_Surcharge_Amount	numeric(18, 2)
	declare @mid_Early_Sec	numeric(18, 0)	
	declare @mid_Early_Dedu_Amount	numeric(18, 0)	
	declare @mid_Early_Extra_Dedu_Amount	numeric(18, 0)	
	declare @mid_Early_Days	numeric(5, 2)	
	declare @mid_Deficit_Sec	numeric(18, 0)	
	declare @mid_Deficit_Dedu_Amount	numeric(18, 0)	
	declare @mid_Deficit_Extra_Dedu_Amount	numeric(18, 0)	
	declare @mid_Deficit_Days	numeric(5, 2)	
	declare @mid_Total_Earning_Fraction	numeric(5, 2)	
	declare @mid_Late_Early_Penalty_days	numeric(5, 2)	
	declare @mid_M_WO_OT_Hours	numeric(18, 2)	
	declare @mid_M_HO_OT_Hours	numeric(18, 2)	
	declare @mid_M_WO_OT_Amount	numeric(18, 2)	
	declare @mid_M_HO_OT_Amount	numeric(18, 2)	
	Declare @total_Present_Days   NUMERIC(18, 4)    
	declare @total_count_all_incremnet numeric(5)
	declare @mid_basic_Amount_total NUMERIC(18, 4)

   Declare @Emp_OT_Hours_Var As Varchar(10)--Nikunj
   Declare @Emp_OT_Hours_Num As NUMERIC(18, 4)--Nikunj
	
	declare @Security_Deposit_Amount NUMERIC(18, 4) -- Added by rohit on 30082014
	set @Security_Deposit_Amount = 0
	
	set @mid_basic_Amount_total = 0
	set @total_count_all_incremnet = 0	
	set @mid_gross_Amount = 0
	set @mid_basic_Amount = 0
	set @mid_salary_Amount = 0
	set @mid_Sal_Cal_Days = 0
	set @mid_Present_Days = 0
	set @mid_Absent_Days = 0
	set @mid_Holiday_Days = 0
	set @mid_WeekOff_Days = 0
	set @mid_cancel_holiday = 0
	set @mid_cancel_weekoff = 0
	set @mid_total_leave_days = 0
	set @mid_paid_leave_days = 0
	set @Mid_OD_leave_Days = 0
	set @mid_Actual_Working_Hours = ''
	set @mid_Working_Hours = ''
	set @mid_Outof_Hours  = ''
	set @mid_OT_Hours	 = 0
	set @mid_Total_Hours	= ''
	set @mid_Shift_Day_Sec	 = 0
	set @mid_Shift_Day_Hour	= ''
	
	set @mid_Day_Salary	 = 0
	set @mid_Hour_Salary	 = 0
	set @mid_Salary_Amount	 = 0
	set @mid_Allow_Amount	 = 0
	set @mid_OT_Amount	 = 0
	set @mid_Other_Allow_Amount	 = 0
	
	set @mid_Dedu_Amount	 = 0
	set @mid_Loan_Amount	 = 0
	set @mid_Loan_Intrest_Amount	 = 0
	set @mid_Advance_Amount	 = 0
	set @mid_Other_Dedu_Amount	 = 0
	set @mid_Total_Dedu_Amount	 = 0
	set @mid_Due_Loan_Amount	 = 0
	set @mid_Net_Amount	 = 0
	set @mid_Actually_Gross_Salary	 = 0
	set @mid_PT_Amount	 = 0
	set @mid_PT_Calculated_Amount	 = 0
	set @mid_Total_Claim_Amount	 = 0
	set @mid_M_OT_Hours	 = 0
	set @mid_M_Adv_Amount	 = 0
	set @mid_M_Loan_Amount	 = 0
	set @mid_M_IT_Tax	 = 0
	set @mid_LWF_Amount	 = 0
	set @mid_Revenue_Amount	 = 0
	set @mid_PT_F_T_Limit	= ''
	set @mid_Settelement_Amount	 = 0
	set @mid_Leave_Salary_Amount	 = 0
	set @mid_Late_Sec	 = 0
	set @mid_Late_Dedu_Amount	 = 0
	set @mid_Late_Extra_Dedu_Amount	 = 0
	set @mid_Late_Days	 = 0
	set @mid_Short_Fall_Days	 = 0
	set @mid_Short_Fall_Dedu_Amount	 = 0
	set @mid_Gratuity_Amount	 = 0
	set @mid_Is_FNF	 = 0
	set @mid_Bonus_Amount	 = 0
	set @mid_Incentive_Amount	 = 0
	set @mid_Trav_Earn_Amount	 = 0
	set @mid_Cust_Res_Earn_Amount	 = 0
	set @mid_Trav_Rec_Amount	 = 0
	set @mid_Mobile_Rec_Amount	 = 0
	set @mid_Cust_Res_Rec_Amount	 = 0
	set @mid_Uniform_Rec_Amount	 = 0
	set @mid_I_Card_Rec_Amount	 = 0
	set @mid_Excess_Salary_Rec_Amount	 = 0
	set @mid_Salary_Status	 = ''
	set @mid_Pre_Month_Net_Salary	 = 0
	set @mid_IT_M_ED_Cess_Amount	 = 0
	set @mid_IT_M_Surcharge_Amount	 = 0
	set @mid_Early_Sec	= 0	
	set @mid_Early_Dedu_Amount	= 0	
	set @mid_Early_Extra_Dedu_Amount	= 0	
	set @mid_Early_Days	= 0	
	set @mid_Deficit_Sec	= 0	
	set @mid_Deficit_Dedu_Amount	= 0	
	set @mid_Deficit_Extra_Dedu_Amount	= 0	
	set @mid_Deficit_Days	= 0	
	set @mid_Total_Earning_Fraction	 = 0		
	set @mid_Late_Early_Penalty_days  = 0	
	set @mid_M_WO_OT_Hours	= 0		
	set @mid_M_HO_OT_Hours	= 0	
	set @mid_M_WO_OT_Amount	= 0	
	set @mid_M_HO_OT_Amount	= 0	
		
	set @tmp_Month_St_Date = @Month_St_Date
	set @tmp_Month_End_Date = @Month_End_Date
	set @increment_Month = 0
	set @total_Present_Days = 0
	
	declare @mid_travel_Advance_Amount	numeric(18, 3) -- Added by rohit on 24082015
	declare @mid_Travel_Amount	numeric(18, 3)
	set @mid_travel_Advance_Amount=0
	set @mid_Travel_Amount=0

    if not @Left_Date between @tmp_Month_St_Date And @tmp_Month_End_Date
		set @Left_Date = Null
		
	
	CREATE TABLE #Total_leave_Id 
	(
		Total_leave_Days_Id nvarchar(50) 
	)
	
	select top 1  @first_Month_End_Date = Increment_effective_Date  from dbo.T0095_Increment WITH (NOLOCK) where Emp_ID = @Emp_Id and Increment_Effective_date >= @Month_St_Date 
			and Increment_Effective_date <= @Month_End_Date     
			and Increment_ID <> @temp_increment_id and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' 
	Order by Increment_effective_Date Asc

	select @increment_Month = COUNT(*)  from dbo.T0095_Increment WITH (NOLOCK) where Emp_ID = @Emp_Id and Increment_Effective_date >= @Month_St_Date and Increment_Effective_date <= @Month_End_Date     
	and Increment_ID <> @temp_increment_id and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' 

	
	select @total_count_all_incremnet  = count(*) from #Mid_Increment

	---Added Condition by Hardik 03/12/2015 as Same Date Increment in showing twice entry
	Select @total_count_all_incremnet = Count(M.Increment_Id) from #Mid_Increment M Inner Join 
	(Select Emp_Id,Max(Increment_Id) as Increment_Id,Increment_Effective_date From #Mid_Increment group by Emp_Id,Increment_Effective_date) Qry
	on M.Emp_Id = Qry.Emp_Id And M.Increment_Id = Qry.Increment_Id	

	
	Declare @cnt numeric 
	set @cnt = 0
	
	 -- --Start of Mid Increment Loop
------------Start Jignesh Cutoff_Date 02-Nov-2017-------
DECLARE @CutoffDate_Salary as DATETIME
SET @CutoffDate_Salary = Null;	

		If @Branch_ID is null
		Begin 
			SELECT	TOP 1 @CutoffDate_Salary =Cutoffdate_Salary 
			FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
			WHERE	cmp_ID = @cmp_ID  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Cmp_ID = @Cmp_ID)    
		End
		ELSE
		Begin
			SELECT	@CutoffDate_Salary =Cutoffdate_Salary
			FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
			WHERE	cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
					and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		END 

		IF ISNULL(@CutoffDate_Salary,'') <> '' 
			BEGIN
				SET @CutoffDate_Salary =  cast(cast(day(@CutoffDate_Salary)as varchar(5)) + '-' + cast(datename(mm,@Month_St_Date) as varchar(10)) + '-' +  cast(year(@Month_St_Date )as varchar(10)) as smalldatetime)    
			END

------------------- 
		

 
 declare curMDI cursor for                    
---Added Condition by Hardik 03/12/2015 as Same Date Increment in showing twice entry
	Select M.Increment_ID,M.Increment_effective_Date from #Mid_Increment M Inner Join 
	(Select Emp_Id,Max(Increment_Id) as Increment_Id,Increment_Effective_date From #Mid_Increment group by Emp_Id,Increment_Effective_date) Qry
	on M.Emp_Id = Qry.Emp_Id And M.Increment_Id = Qry.Increment_Id	
	Order by M.Increment_effective_Date
  --select Increment_ID,Increment_effective_Date from #Mid_Increment
  open curMDI                      
  fetch next from curMDI into @Increment_ID,@Month_End_Date
			   
  WHILE @@fetch_status = 0                    
   BEGIN
				set @cnt = @cnt + 1
				if @total_count_all_incremnet > 1 
				begin
						
						if @cnt = 1 
							begin	
								if @first_Month_End_Date <> '' 
									begin
										set @Month_End_Date =  dateadd(d,-1,@first_Month_End_Date) 
									end						
								else
									begin
										set @Month_End_Date = @tmp_Month_End_Date
									end
								
							end		
						else if isnull(@increment_Month ,0) = @cnt -1 
							begin
								set @Month_End_Date = @tmp_Month_End_Date
							end
						Else --- Added Condition by Hardik 30/12/2019 for Wonder (WCL) for 2 Mid increment in Same Month, e.g. one from 2-12-2019 and second from 10-12-2019
							Begin
								Declare @Next_Increment_Date datetime
								
								SELECT TOP 1 @Next_Increment_Date = Increment_effective_Date 
								FROM #Mid_Increment 
								WHERE Increment_effective_Date > @Month_End_Date 
								ORDER BY Increment_effective_Date Asc
								
								If @Next_Increment_Date Is not null
									Begin
										set @Month_End_Date =  dateadd(d,-1,@Next_Increment_Date)
									End
							End
						end
				else
					begin	
						set @Month_St_Date = @tmp_Month_St_Date
						set @Month_End_Date = @tmp_Month_End_Date
					end		

if @Join_Date > @Month_End_Date
	BEGIN
		Set @cnt=0
		Goto ABC
	END
			
			If @cnt > 1 
				Set @Other_allow_Amount = 0
					

		--@Increment_ID = Increment_ID ,		 
         
  SELECT @Wages_Type = Wages_type,@SalaryBasis = Salary_Basis_On,      
    @Emp_OT = Emp_OT , @Payment_Mode = Payment_Mode ,      
    @Actual_Gross_Salary = isnull(Gross_Salary,0) ,@Basic_Salary = isnull(Basic_Salary,0),      
    @Emp_OT_Min_Limit = Emp_OT_Min_Limit , @Emp_OT_Max_Limit = Emp_OT_Max_Limit, @Emp_Part_Time = isnull(Emp_Part_Time,0) ,    
    @Branch_ID = Branch_ID,      
    @Is_Emp_PT =isnull(Emp_PT,0),
    @Fix_Salary=isnull(Emp_Fix_Salary,0) ,
    @Emp_WD_OT_Rate = isnull(Emp_WeekDay_OT_Rate,0), --hardik 17/07/2012
    @Fix_OT_Hour_Rate_WD=Fix_OT_Hour_Rate_WD	--Ankit 03122013
    ,@Emp_WO_OT_Rate = isnull(Emp_WeekOff_OT_Rate,0) , @Emp_HO_OT_Rate = isnull(Emp_Holiday_OT_Rate,0), @Fix_OT_Hour_Rate_WOHO = Fix_OT_Hour_Rate_WO_HO --Ankit 07012015
  from dbo.T0095_Increment I WITH (NOLOCK)
  INNER JOIN	--Commented and New Code Added By Ramiz on 12/12/2017
			( SELECT MAX(I2.INCREMENT_ID) AS INCREMENT_ID, I2.EMP_ID 
				FROM T0095_INCREMENT I2 WITH (NOLOCK)
					INNER JOIN 
					(
							SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
							FROM T0095_INCREMENT I3 WITH (NOLOCK)
							WHERE I3.Increment_effective_Date <= @Month_End_Date and I3.Cmp_ID = @Cmp_ID and I3.Increment_Type <> 'Transfer' and I3.Increment_Type <> 'Deputation'
							GROUP BY I3.EMP_ID  
						) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID	
				WHERE I2.INCREMENT_EFFECTIVE_DATE <= @Month_End_Date and I2.Cmp_ID = @Cmp_ID and I2.Increment_Type <> 'Transfer' and I2.Increment_Type <> 'Deputation'
				GROUP BY I2.emp_ID  
			) Qry on	I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID 
   WHERE I.CMP_ID = @Cmp_ID AND I.EMP_ID = @Emp_ID	
  
 
 --As per chintan bhai request Below condition is added to check the effectiveDatae is not equal to month_start_date to take the max branch Id .The above query is to take the max increment id.  Deepal 02052022
DECLARE @IncrEffectDate as DATETIME  
SELECT @IncrEffectDate = max(Increment_effective_Date) from dbo.T0095_Increment WHERE  Increment_Effective_date <= @Month_End_Date AND Cmp_ID = @Cmp_ID  and Emp_ID = @Emp_Id GROUP BY emp_ID

--Comment by ronakk 08082023 because of this is specific change
--IF @IncrEffectDate <> @Month_St_Date
--BEGIN 
		--SELECT @Branch_ID = Qry.Branch_ID ,@Grd_Id=I.Grd_ID,@Is_Emp_PT =isnull(Qry.Emp_PT,0)     --Added By Jimit 25052018 Employee PT Applicable in Transfer then in salary not deduct PT amount due to transfer case (WCL) 	
		--from dbo.T0095_Increment I inner join       
		--   (
		--		SELECT MAX(I2.Branch_ID) AS Branch_ID, I2.EMP_ID ,I2.Emp_PT
		--		FROM T0095_INCREMENT I2 
		--			INNER JOIN 
		--			(
		--					SELECT max(Increment_effective_Date) as For_Date , Emp_ID,Max(Branch_ID) as Branch_ID
		--					  from dbo.T0095_Increment      
		--					WHERE  Increment_Effective_date <= @Month_End_Date      
		--					AND Cmp_ID = @Cmp_ID         
		--					GROUP BY emp_ID
		--		) I3 ON I2.Increment_Effective_Date=I3.For_Date AND I2.EMP_ID=I3.Emp_ID and I3.Branch_ID = I2.Branch_ID GROUP BY I2.emp_ID ,I2.Emp_PT   
		--	) Qry on I.Emp_ID = Qry.Emp_ID and i.Branch_ID = Qry.Branch_ID
		--WHERE I.Emp_ID = @Emp_ID  
--END

 --SELECT @Branch_ID = Branch_ID ,@Grd_Id=I.Grd_ID 
		--,@Is_Emp_PT =isnull(Emp_PT,0)     --Added By Jimit 25052018 Employee PT Applicable in Transfer then in salary not deduct PT amount due to transfer case (WCL) 	
  --from dbo.T0095_Increment I inner join       
  --   (SELECT max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment      
  --    WHERE  Increment_Effective_date <= @Month_End_Date      
  --    AND Cmp_ID = @Cmp_ID         
  --    GROUP BY emp_ID) Qry on      
  --   I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date      
  --WHERE I.Emp_ID = @Emp_ID  


--As per chintan bhai request Below condition is added to check the effectiveDatae is not equal to month_start_date to take the max branch Id .The above query is to take the max increment id.  Deepal 02052022


  --Added by Hardik 10/04/2015 for Samarth Diaomond
  
  If Isnull(@Salary_Depends_on_Production,0) = 1 and Isnull(@Basic_Salary,0)=0
	BEGIN
		DECLARE @Basic_Percentage as NUMERIC(18, 4)
		DECLARE @Basic_Calc_On as varchar(50)
		
		Select @Basic_Percentage = Basic_Percentage, @Basic_Calc_On = Basic_Calc_On from T0040_GRADE_MASTER WITH (NOLOCK) where Grd_ID=@Grd_Id
		Select @Production_Gross_Salary = Gross_Amount from T0050_Production_Details_Import WITH (NOLOCK) where Employee_ID = @Emp_id and Production_Month = Month(@Month_End_Date) And Production_Year=Year(@Month_End_Date)
		
		If @Basic_Percentage > 0 and @Production_Gross_Salary >0 And @Basic_Calc_On = 'Gross' 
			Begin
				Set @Basic_Salary = @Production_Gross_Salary * @Basic_Percentage / 100
				Set @Gross_Salary = @Production_Gross_Salary
			End
	END



    	IF EXISTS(SELECT 1 from dbo.T0250_MONTHLY_LOCK_INFORMATION WITH (NOLOCK) WHERE MONTH =  MONTH(@Month_End_Date) and YEAR =  year(@Month_End_Date) and Cmp_ID = @CMP_ID and (Branch_ID = isnull(@Branch_ID,0) or Branch_ID = 0)) and (@total_count_all_incremnet = 1 or @cnt <> 1)  -- @cnt condition added by Hardik 01/09/2015 as if salary cycle is 26 to 25 and increment given on 01st then month lock error is coming
			Begin
				set @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Month='+cast(MONTH(@Month_End_Date) as varchar)+', Year='+cast(year(@Month_End_Date) as varchar)
				--Changed by Gadriwala Muslim 17/01/2017 'Salary' to 'Salary Manual#'
				exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Salary Manual#','Month Lock',@LogDesc,1,''			 		
				--Raiserror('Month Lock',16,2)
				return -1
			End		

	--Hardik 16/10/2013
	Declare @Allowed_Full_WeekOff_MidJoining_DayRate as tinyint
	Declare @Allowed_Full_WeekOff_MidJoining as tinyint
	Set @Allowed_Full_WeekOff_MidJoining_DayRate = 0
	Set @Allowed_Full_WeekOff_MidJoining = 0
	
	--Added by Sumit -04/06/2016---------------------------------------------------------------
	Declare @Allowed_Full_WeekOff_MidLeft_DayRate as tinyint
	Declare @Allowed_Full_WeekOff_MidLeft as tinyint
	Set @Allowed_Full_WeekOff_MidLeft_DayRate = 0
	Set @Allowed_Full_WeekOff_MidLeft = 0
	
		    
    
  SELECT @ExOTSetting = ExOT_Setting,@Inc_Weekoff = Inc_Weekoff,@Late_Adj_Day = ISNULL(Late_Adj_Day,0)      
  ,@OT_Min_Limit = OT_APP_LIMIT ,@OT_Max_Limit = ISNULL(OT_Max_Limit,'00:00')      
  ,@Is_OT_Inc_Salary = ISNULL(OT_Inc_Salary,0)       
  ,@Is_Daily_OT = Is_Daily_OT       
  ,@Is_Cancel_Holiday = ISNULL(Is_Cancel_Holiday,0)      
  ,@Is_Cancel_Weekoff = ISNULL(Is_Cancel_Weekoff,0)      
  ,@Fix_OT_Shift_Hours = ot_Fix_Shift_Hours      
  ,@Fix_OT_Work_Days = ISNULL(OT_fiX_Work_Day,0)      
  ,@Is_PT = ISNULL(Is_PT,0)      
  ,@LWF_Amount = LWF_Amount , @LWF_App_Month = LWF_Month,@Mid_Increment =Mid_Increment ,@SAL_FIX_DAYS =SAL_FIX_dAYS     
  ,@Revenue_amount = Revenue_amount , @Revenue_on_Amount = Revenue_on_Amount     ,@Wages_Amount=Wages_Amount 
  ,@Lv_Salary_Effect_on_PT = Lv_Salary_Effect_on_PT,@Inc_Holiday = ISNULL(Inc_Holiday,0),@Is_Zero_Day_Salary=ISNULL(Is_Zero_Day_Salary,0)
  ,@ROUNDING =Ad_Rounding,@Lv_Encash_Cal_On = Lv_Encash_Cal_On,@Is_Zero_Basic_Salary = isnull(Is_Zero_Basic_Salary  ,0)
  ,@Sal_Fix_Days = isnull(Sal_Fix_Days,0) -- Added by Falak on 26-MAY-2011
  ,@Allow_Negative_Sal = Allow_Negative_Salary
  ,@Paid_Weekoff_Daily_Wages = Paid_Weekoff_Daily_Wages
  ,@Allowed_Full_WeekOff_MidJoining_DayRate = Isnull(Allowed_Full_WeekOf_MidJoining_DayRate,0)
  ,@Allowed_Full_WeekOff_MidJoining = Isnull(Allowed_Full_WeekOf_MidJoining,0)
  ,@net_round = ISNULL(net_salary_round,0) , @net_round_Type = ISNULL(type_net_salary_round,'')
  ,@DayRate_WO_Cancel = Isnull(DayRate_WO_Cancel,0)
  ,@Allowed_Full_WeekOff_MidLeft=isnull(Allowed_Full_WeekOf_MidLeft,0)
  ,@Allowed_Full_WeekOff_MidLeft_DayRate=isnull(Allowed_Full_WeekOf_MidLeft_DayRate,0)
  ,@OT_RATE_TYPE = ISNULL(OTRateType,0) -- ADDED BY RAJPUT ON 16072018
  ,@OT_SLAB_TYPE = ISNULL(OTSLABTYPE,0) -- ADDED BY RAJPUT ON 16072018
  ,@GEN_ID = GEN_ID -- ADDED BY RAJPUT ON 16072018
  ,@IS_ROUNDING = ISNULL(AD_ROUNDING,1) -- ADDED BY RAJPUT ON 16072018
  from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE cmp_ID = @cmp_ID AND Branch_ID = @Branch_ID      
  AND For_Date = (SELECT MAX(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=@Month_End_Date AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)      
  
  
  
  ---------------------
				set @Mid_Inc_Working_Day = datediff(d,@Month_St_Date,@Month_End_Date) + 1

				if isnull(@Sal_Fix_Days,0) > 0 
					begin 				   
						if @Mid_Inc_Working_Day > @Sal_Fix_Days or @total_count_all_incremnet = 1
						set @Mid_Inc_Working_Day  = @Sal_Fix_Days
					end
				

			
				--Hardik 16/10/2013
				Declare @StrWeekoff_Date_DayRate as varchar(8000)
				DECLARE @Weekoff_Days_DayRate NUMERIC(18, 4)  
				Declare @StrHoliday_Date_DayRate as varchar(8000) -- Added by Hardik 09/11/2020 for Gujarat Foil client for Mid Join, give all Holiday for Day Rate
				DECLARE @Holiday_Days_DayRate NUMERIC(18, 2)   -- Added by Hardik 09/11/2020 for Gujarat Foil client for Mid Join, give all Holiday for Day Rate   
				
				Set @StrWeekoff_Date_DayRate = ''
				Set @Weekoff_Days_DayRate = 0
				Set @StrHoliday_Date_DayRate = ''
				Set @Holiday_Days_DayRate = 0


				---Commented by Hardik on 26/05/2014 (Discuss with Mitesh, because mid join case is not checked in below conditions.)
				
				--Set @StrHoliday_Date = @ho_date
				--Set @Holiday_days = @ho_count
				--Set @StrWeekoff_Date =  @wo_date
				--Set @Weekoff_Days = @wo_count
				--set @StrWeekoff_Date_DayRate = @wo_date_mid
				--set @Weekoff_Days_DayRate = @wo_count_mid

				--- Added condition by Hardik 15/12/2014 for TOTO, to check if employee is mid join or left then only this condition work
				-------------
				--If ((@Join_Date >= @Month_St_Date and @Join_Date<=@Month_End_Date) or (@left_Date >= @Month_St_Date and @left_Date<=@Month_End_Date)) And @Allowed_Full_WeekOff_MidJoining_DayRate = 1 
				--	Set @Allowed_Full_WeekOff_MidJoining_DayRate = 1
				--Else
				--	Set @Allowed_Full_WeekOff_MidJoining_DayRate = 0
				
				--If ((@Join_Date >= @Month_St_Date and @Join_Date<=@Month_End_Date) or (@left_Date >= @Month_St_Date and @left_Date<=@Month_End_Date)) And @Allowed_Full_WeekOff_MidJoining = 1 
				--	Set @Allowed_Full_WeekOff_MidJoining = 1
				--Else
				--	Set @Allowed_Full_WeekOff_MidJoining = 0
				
				--Changed by Sumit on 04/06/2016 for Mid Left and Mid Join Seperated------------------------------------------------
				If ((@Join_Date >= @Month_St_Date and @Join_Date<=@Month_End_Date) or (@left_Date >= @Month_St_Date and @left_Date<=@Month_End_Date)) And @Allowed_Full_WeekOff_MidJoining_DayRate = 1 and @Allowed_Full_WeekOff_MidLeft_DayRate = 1
					--Set @Allowed_Full_WeekOff_MidJoining_DayRate = 1
					Set @Allowed_Full_WeekOff_MidJoining_DayRate = 3
				Else if ((@Join_Date >= @Month_St_Date and @Join_Date<=@Month_End_Date) or (@left_Date >= @Month_St_Date and @left_Date<=@Month_End_Date)) And @Allowed_Full_WeekOff_MidJoining_DayRate = 1 and @Allowed_Full_WeekOff_MidLeft_DayRate = 0
					Set @Allowed_Full_WeekOff_MidJoining_DayRate = 1
				Else if ((@Join_Date >= @Month_St_Date and @Join_Date<=@Month_End_Date) or (@left_Date >= @Month_St_Date and @left_Date<=@Month_End_Date)) And @Allowed_Full_WeekOff_MidJoining_DayRate = 0 and @Allowed_Full_WeekOff_MidLeft_DayRate = 1
					Set @Allowed_Full_WeekOff_MidJoining_DayRate = 2
				Else
					Set @Allowed_Full_WeekOff_MidJoining_DayRate = 0
				
				If ((@Join_Date >= @Month_St_Date and @Join_Date<=@Month_End_Date) or (@left_Date >= @Month_St_Date and @left_Date<=@Month_End_Date)) And @Allowed_Full_WeekOff_MidJoining = 1 and @Allowed_Full_WeekOff_MidLeft=1
					--Set @Allowed_Full_WeekOff_MidJoining = 1
					Set @Allowed_Full_WeekOff_MidJoining = 3
				Else If ((@Join_Date >= @Month_St_Date and @Join_Date<=@Month_End_Date) or (@left_Date >= @Month_St_Date and @left_Date<=@Month_End_Date)) And @Allowed_Full_WeekOff_MidJoining = 1 and @Allowed_Full_WeekOff_MidLeft=0
					set @Allowed_Full_WeekOff_MidJoining = 1
				Else If ((@Join_Date >= @Month_St_Date and @Join_Date<=@Month_End_Date) or (@left_Date >= @Month_St_Date and @left_Date<=@Month_End_Date)) And @Allowed_Full_WeekOff_MidJoining = 0 and @Allowed_Full_WeekOff_MidLeft=1
					set @Allowed_Full_WeekOff_MidJoining = 2
				Else
					Set @Allowed_Full_WeekOff_MidJoining = 0
				
				

				--	commented by mitesh on 19022014 - optimization
				-- Uncommented by Hardik on 26/05/2014 (discussed with Mitesh)
				--select @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_End_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date ,@Holiday_days ,@Cancel_Holiday ,0,@Branch_ID,@StrWeekoff_Date
				
				
				
				--If @Allowed_Full_WeekOff_MidJoining = 1, Below Sp will take Full Weekoff if Mid Joining 
				--Hardik 16/10/2013
				--Added by nilesh For Cancel Holiday When WO & HO on Same Day on 19112015
				if @Is_Cancel_Holiday_WO_HO_same_day = 1 
					Begin
						EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_End_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date OUTPUT,@Weekoff_Days OUTPUT ,@Cancel_Weekoff OUTPUT,0,0,0,'',@Allowed_Full_WeekOff_MidJoining
						EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_End_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date OUTPUT,@Holiday_days OUTPUT,@Cancel_Holiday OUTPUT,0,@Branch_ID,@StrWeekoff_Date
					End
				Else
					Begin
						EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_End_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date OUTPUT,@Holiday_days OUTPUT,@Cancel_Holiday OUTPUT,0,@Branch_ID,@StrWeekoff_Date
						EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_End_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date OUTPUT,@Weekoff_Days OUTPUT ,@Cancel_Weekoff OUTPUT,0,0,0,'',@Allowed_Full_WeekOff_MidJoining

					End 
				--Added by nilesh For Cancel Holiday When WO & HO on Same Day on 19112015
				
				--If @Allowed_Full_WeekOff_MidJoining_DayRate = 1, Below Sp will take Full Weekoff if Mid Joining 
				--Hardik 16/10/2013
				EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_End_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date_DayRate OUTPUT,@Holiday_Days_DayRate OUTPUT,@Cancel_Holiday OUTPUT,0,@Branch_ID,'',0,0,'',@Allowed_Full_WeekOff_MidJoining_DayRate
				EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_End_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date_DayRate,@StrWeekoff_Date_DayRate OUTPUT,@Weekoff_Days_DayRate OUTPUT ,@Cancel_Weekoff OUTPUT,0,0,0,'',@Allowed_Full_WeekOff_MidJoining_DayRate


				---Commented by Hardik on  31/10/2015 and added below side as mid increment case going wrong 
								
				--if @Mid_Inc_Working_Day < @Present_Days_Total
				--	begin	
				--		Set @Present_Days = @Mid_Inc_Working_Day - (@Weekoff_Days + @Holiday_Days)
				--		set @Present_Days_Total =@Present_Days_Total - (@Mid_Inc_Working_Day - (@Weekoff_Days + @Holiday_Days))
				--	end
				--else if @Mid_Inc_Working_Day >= @Present_Days_Total 
				--	begin
				--		Set @Present_Days = @Present_Days_Total
				--		set @Present_Days_Total = 0
				--	end


  -----------------------
		
		--Hardik 07/01/2012 for Arears Calculation  
		 If Exists (Select 1 From T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_Id  -- Condition Added Hardik 21/05/2014
						And Month = Month(@Month_End_Date) And Year = Year(@Month_End_Date))
			Begin
			
				Select @Arear_Day = isnull(Extra_Days,0) + isnull(Backdated_Leave_Days,0), @Arear_Month = Extra_Day_Month, @Arear_Year = Extra_Day_Year, @M_Cancel_weekOff = Cancel_Weekoff_Day,  
						@M_Cancel_Holiday = cancel_Holiday , @WO_OT_Hours = ISNULL(WO_OT_Hour,0) , @HO_OT_Hours = ISNULL(HO_OT_Hour,0)
						,@present_on_holiday =present_on_holiday  -- Added by rohit on 24022016
				from dbo.T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_Id   
				And Month = Month(@Month_End_Date) And Year = Year(@Month_End_Date)  

						If @Arear_Month = 0 or @Arear_Month is null
							Set @Arear_Month = Month(DATEADD(mm,-1,@Month_End_Date))
				
						If @Arear_Year = 0 or @Arear_Year is null
							Set @Arear_Year = Year(DATEADD(mm,-1,@Month_End_Date))

									 
							--- Added by Hardik 04/05/2013 for Set From Date and To date as per Salary Cycle for Arear Month
							Declare @Sal_St_Date_Arear as Datetime
							Declare @Sal_End_Date_Arear as Datetime
							
						   If @Branch_ID is null
								Begin 
									select Top 1 @Sal_St_Date_Arear  = Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
									  from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
									  and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Cmp_ID = @Cmp_ID)    
								End
							Else
								Begin
									select @Sal_St_Date_Arear  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
									  from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
									  and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
								End 
								
							if isnull(@Sal_St_Date_Arear,'') = ''    
								  begin    
										Set @OutOf_Days_Arear = DATEDIFF(dd,dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year),dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year))+ 1
										set @Sal_St_Date_Arear = dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year)
										set @Sal_End_Date_Arear = dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year)
								  end     
									
							 else if day(@Sal_St_Date_Arear) =1 --and month(@Sal_St_Date)= 1    
								  begin    
								  
										Set @OutOf_Days_Arear = DATEDIFF(dd,dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year),dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year))+ 1
										set @Sal_St_Date_Arear = dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year)
										set @Sal_End_Date_Arear = dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year)
								  end     
							 else if @Sal_St_Date_Arear <> ''  and day(@Sal_St_Date_Arear) > 1   
								  begin    
									if @manual_salary_period = 0 
									   begin
											set @Sal_St_Date_Arear =  cast(cast(day(@Sal_St_Date_Arear)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year))) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year)) )as varchar(10)) as smalldatetime)    
											set @Sal_End_Date_Arear = dateadd(d,-1,dateadd(m,1,@Sal_St_Date_Arear)) 
											set @OutOf_Days_Arear = datediff(d,@Sal_St_Date_Arear,@Sal_End_Date_Arear) + 1
									   end 
									 else
										begin
											select @Sal_St_Date_Arear = from_date, @Sal_End_Date_Arear = end_date 
											from salary_period WITH (NOLOCK) where month= @Arear_Month and YEAR=@Arear_Year
											
											set @OutOf_Days_Arear = datediff(d,@Sal_St_Date_Arear,@Sal_End_Date_Arear) + 1
										  
										end   
								  end
							---- End by Hardik 04/05/2013 for Set From Date and To Date for Arear Month

						

						SELECT @Basic_Salary_Arear = isnull(Basic_Salary,0)
						from dbo.T0095_Increment I WITH (NOLOCK) inner join       
							(SELECT max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)     
							WHERE  Increment_Effective_date <= dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year)
							AND Cmp_ID = @Cmp_ID and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation'     
							GROUP BY emp_ID) Qry on      
						I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date      
						WHERE I.Emp_ID = @Emp_ID 

					-- Added by Hardik 21/05/2014
					-- Added by Nilesh on 19112015 after discussion with hardikbhai(If salary is Exists than take working day from Salary Table)
					If not exists(Select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where Month(Month_End_Date)= @Arear_Month and Year(Month_End_Date)= @Arear_Year  and Emp_id = @Emp_id)
					  Begin
						if @Is_Cancel_Holiday_WO_HO_same_day = 1 
							Begin
								Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Sal_St_Date_Arear,@Sal_End_Date_Arear,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date_Arear,@StrWeekoff_Date_Arear output,@Weekoff_Days_Arear output ,Null
								Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Sal_St_Date_Arear,@Sal_End_Date_Arear,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date_Arear output,@Holiday_Days_Arear output,Null,0,@Branch_ID,@StrWeekoff_Date_Arear
							End
						Else
							Begin
								Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Sal_St_Date_Arear,@Sal_End_Date_Arear,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date_Arear output,@Holiday_Days_Arear output,Null,0,@Branch_ID,@StrWeekoff_Date_Arear
								Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Sal_St_Date_Arear,@Sal_End_Date_Arear,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date_Arear,@StrWeekoff_Date_Arear output,@Weekoff_Days_Arear output ,Null
							End
					  END	
			End
				---- End for Arear	       
	       
		   

	if isnull(@Sal_Fix_Days,0) > 0    				   
		set @OutOf_Days = @Sal_Fix_Days
  
      
 EXEC P0210_MONTHLY_LEAVE_INSERT @Cmp_ID ,@Emp_ID,@Month_St_Date,@Month_End_Date,@Sal_Tran_ID
 EXEC SP_CURR_T0100_EMP_SHIFT_GET @Emp_Id,@Cmp_ID,@Month_End_Date,NULL,NULL,@Shift_Day_Hour OUTPUT

 --set @Shift_Day_Hour ='08:00'
 


 --Commented by Hardik 07/09/2012 As it is already called above
 --EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_End_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date OUTPUT,@Weekoff_Days OUTPUT ,@Cancel_Weekoff OUTPUT         
 --EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_End_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date OUTPUT,@Holiday_days OUTPUT,@Cancel_Holiday OUTPUT,0,@Branch_ID,@StrWeekoff_Date  	 

 
 
 SELECT @Shift_Day_Sec = dbo.F_Return_Sec(isnull(@Shift_Day_Hour,'00:00'))
 select @Fix_OT_Shift_Sec = dbo.F_Return_Sec(isnull(@Fix_OT_Shift_Hours,'00:00'))      
 SELECT @Emp_OT_Min_Sec = dbo.F_Return_Sec(isnull(@Emp_OT_Min_Limit,'00:00'))      
 SELECT @Emp_OT_Max_Sec = dbo.F_Return_Sec(isnull(@Emp_OT_Max_Limit,'00:00')) 
 
 
 
 --Alpesh 08-Aug-2012 -> for divide by zero error
 If @Shift_Day_Sec = 0
	Begin
		set @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Month='+cast(MONTH(@Month_End_Date) as varchar)+', Year='+cast(year(@Month_End_Date) as varchar)
		--Changed by Gadriwala Muslim 17/01/2017 'Salary' to 'Salary Manual#'
		exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Salary Manual#','Shift Is Not Proper',@LogDesc,1,''							

		return -1
	End
 
  --Hasmukh for manual cancel weekoff 30012012------
 
 
 
 If @M_Cancel_weekOff > 0 and @Weekoff_Days > 0
	Begin 
		if @M_Cancel_weekOff <= @Weekoff_Days --Condition added by Hardik 03/05/2015 to check Manual Weekoff Cancel and weekoff day should not greter
			Begin
				set @Weekoff_Days = @Weekoff_Days - @M_Cancel_weekOff
				set @Cancel_Weekoff = @M_Cancel_weekOff
			End
		Else
			Begin
				set @Weekoff_Days = 0
				set @Cancel_Weekoff = @M_Cancel_weekOff
			End
	End


--Added below condition by Hardik 03/05/2015 to change day rate if weekoff is cancel for NIRMA
If Isnull(@DayRate_WO_Cancel,0) = 1
	BEGIN
		 If @M_Cancel_weekOff > 0 and @Weekoff_Days_DayRate > 0
			Begin 
				if @M_Cancel_weekOff <= @Weekoff_Days_DayRate --Condition added by Hardik 03/05/2015 to check Manual Weekoff Cancel and weekoff day should not greter
					Begin
						set @Weekoff_Days_DayRate = @Weekoff_Days_DayRate - @M_Cancel_weekOff
					End
				Else
					Begin
						set @Weekoff_Days_DayRate = 0
					End
			End
	END		
	
 --Hasmukh for manual cancel Holiday 31082012------   
 If @M_Cancel_holiday > 0 and @Holiday_days > 0  
 Begin   
  set @Holiday_days = @Holiday_days - @M_Cancel_holiday  
  set @Cancel_Holiday = @M_Cancel_holiday  
 End  
	
-----End hasmukh ----------
 
 If @Fix_OT_Shift_Sec > 0
	Begin  
		set @Fix_OT_Shift_Sec = @Fix_OT_Shift_Sec
	End  
Else
	Begin  
		set @Fix_OT_Shift_Sec = @Shift_Day_Sec
	End   
    
	 
	If @Wages_Type= 'Monthly'
			Begin
			 IF @Inc_Weekoff <>1  
				BEGIN
					--By Falak on 14-OCT-2010 don't delete this code it is kept for purpose to generate salary for any employee join in mid month.
					--declare @StrWeekoff_Date1	varchar(1000)
					--declare @Weekoff_Days1 NUMERIC(18, 4)
					--declare @Cancel_Weekoff1 NUMERIC(18, 4)
					--set @StrWeekoff_Date1=''
					--set @Weekoff_Days1=0
					--set @Cancel_Weekoff1=0
					--Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_DAte,@Month_End_DAte,@Month_St_DAte,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date1 output,@Weekoff_Days1 output ,@Cancel_Weekoff1 output		
				IF @Inc_Holiday <>1	 
					BEGIN
						Set @Working_Days = @Outof_Days - (@Weekoff_Days_DayRate + @Holiday_Days_DayRate)        --add Hardik 16/10/2013 for Weekoff DayRate
						If @total_count_all_incremnet = 1 
							Begin
								Set @Mid_Inc_Working_Day = @Outof_Days - (@Weekoff_Days_DayRate + @Holiday_Days_DayRate)        --add Hardik 02/06/2014 for Apollo Case, Discussed with Mitesh, Hasmukh
							End
						If @OutOf_Days_Arear >0
							Begin
								Set @Working_days_Arear = @OutOf_Days_Arear - (@Weekoff_Days_Arear + @Holiday_Days_Arear)    -- Added by Hardik 21/05/2014   						
							End
					END 
				ELSE
					BEGIN
						Set @Working_Days = @Outof_Days - (@Weekoff_Days_DayRate) --add Hardik 16/10/2013 for Weekoff DayRate
						If @total_count_all_incremnet = 1 
							Begin
								Set @Mid_Inc_Working_Day = @Outof_Days - (@Weekoff_Days_DayRate)        --add Hardik 02/06/2014 for Apollo Case, Discussed with Mitesh, Hasmukh
							End
						If @OutOf_Days_Arear >0
							Begin
								Set @Working_days_Arear = @OutOf_Days_Arear - (@Weekoff_Days_Arear) -- Added by Hardik 21/05/2014
							End
					END	
				END	
			 ELSE  
				BEGIN    
				IF @Inc_Holiday <>1  
					BEGIN
						SET @Working_Days = @Outof_Days -  @Holiday_Days_DayRate
						If @total_count_all_incremnet = 1 
							Begin
								Set @Mid_Inc_Working_Day = @Outof_Days - (@Holiday_Days_DayRate)        --add Hardik 02/06/2014 for Apollo Case, Discussed with Mitesh, Hasmukh
							End
						If @OutOf_Days_Arear >0
							Begin
								SET @Working_days_Arear = @OutOf_Days_Arear -  @Holiday_Days_Arear -- Added by Hardik 21/05/2014 
							End
					END
				ELSE
					BEGIN 
						SET @Working_Days = @Outof_Days 
						If @total_count_all_incremnet = 1 
							Begin
								Set @Mid_Inc_Working_Day = @Outof_Days --add Hardik 02/06/2014 for Apollo Case, Discussed with Mitesh, Hasmukh
							End
						If @OutOf_Days_Arear >0
							Begin
								SET @Working_days_Arear = @OutOf_Days_Arear  -- Added by Hardik 21/05/2014 
							End
					END	
				END	
			End
		Else
			Begin
			 IF @Inc_Weekoff <>1  
				BEGIN
				IF @Inc_Holiday <>1	 
					BEGIN
						Set @Working_Days = @Outof_Days - (@Weekoff_Days_DayRate + @Holiday_Days_DayRate)        --add Hardik 16/10/2013 for Weekoff DayRate
						If @OutOf_Days_Arear >0
							Begin
								Set @Working_days_Arear = @OutOf_Days_Arear - (@Weekoff_Days_Arear + @Holiday_Days_Arear)    -- Added by Hardik 21/05/2014   						
							End
					END 
				ELSE
					BEGIN
						Set @Working_Days = @Outof_Days - (@Weekoff_Days_DayRate) --add Hardik 16/10/2013 for Weekoff DayRate
						If @OutOf_Days_Arear >0
							Begin
								Set @Working_days_Arear = @OutOf_Days_Arear - (@Weekoff_Days_Arear) -- Added by Hardik 21/05/2014
							End
					END	
				END	
			 ELSE  
				BEGIN    
				IF @Inc_Holiday <>1  
					BEGIN
						SET @Working_Days = @Outof_Days -  @Holiday_Days_DayRate
						If @OutOf_Days_Arear >0
							Begin
								SET @Working_days_Arear = @OutOf_Days_Arear -  @Holiday_Days_Arear -- Added by Hardik 21/05/2014 
							End
					END
				ELSE
					BEGIN 
						SET @Working_Days = @Outof_Days 
						If @OutOf_Days_Arear >0
							Begin
								SET @Working_days_Arear = @OutOf_Days_Arear  -- Added by Hardik 21/05/2014 
							End
					END	
				END	
			End

		--added by Hardik 06/05/2015 for Nirma 
		If exists (Select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where Month(Month_End_Date)= @Arear_Month and Year(Month_End_Date)= @Arear_Year  and Emp_id = @Emp_id)
			Begin  
				Select @Working_days_Arear = Working_Days from dbo.T0200_MONTHLY_SALARY WITH (NOLOCK) where Month(Month_End_Date) = @Arear_Month and Year(Month_End_Date) = @Arear_Year and Emp_id = @Emp_id
			End

 				--if @Mid_Inc_Working_Day  <= @Present_Days_Total --Commented by Hardik 31/10/2015 as problem if mid increment in GIFT and after second increment all days showing as absent
 				--IF @Inc_Weekoff = 1 And @Inc_Holiday = 1
 				If @total_count_all_incremnet >1  --- condition added by Hardik 24/11/2015 for Not Include Weekoff Condtion going wrong and Present day getting decrease.
 					BEGIN
 						if (@Mid_Inc_Working_Day - (@Weekoff_Days + @Holiday_Days))  < @Present_Days_Total
							begin	
								Set @Present_Days = @Mid_Inc_Working_Day - (@Weekoff_Days + @Holiday_Days)
								set @Present_Days_Total =@Present_Days_Total - (@Mid_Inc_Working_Day - (@Weekoff_Days + @Holiday_Days))
							end
						else if @Mid_Inc_Working_Day >= @Present_Days_Total 
							begin
								Set @Present_Days = @Present_Days_Total
								set @Present_Days_Total = 0 --(@Mid_Inc_Working_Day +@Weekoff_Days + @Holiday_Days) - @Present_Days
							end
					END
				--Else
				--	BEGIN
 			--			if @Mid_Inc_Working_Day < @Present_Days_Total + (@Weekoff_Days + @Holiday_Days)
				--			begin	
				--				Set @Present_Days = @Working_Days - (@Weekoff_Days + @Holiday_Days)
				--				set @Present_Days_Total = (@Mid_Inc_Working_Day) -- - (@Weekoff_Days + @Holiday_Days))
				--			end
				--		else if @Mid_Inc_Working_Day >= @Present_Days_Total 
				--			begin
				--				Set @Present_Days = @Present_Days_Total
				--				set @Present_Days_Total = 0 --(@Mid_Inc_Working_Day +@Weekoff_Days + @Holiday_Days) - @Present_Days
				--			end
				--	END

	--Added by Hardik 17/10/2013 for Fix Salary Working days should be month day.. otherwise Allowance is not match with actual figure..	
	if @Fix_Salary = 1
		Begin
			Set @Working_Days = datediff(d,@Month_St_Date,@Month_End_Date) + 1
			set @Mid_Inc_Working_Day = datediff(d,@Month_St_Date,@Month_End_Date) + 1
		End


		
	SELECT @Total_leave_Days = isnull(sum(leave_Days),0) from dbo.T0210_Monthly_LEave_Detail WITH (NOLOCK) where Emp_ID = @emp_ID and       
      TEMP_SAL_TRAN_ID = @Sal_Tran_ID and M_Leave_Tran_ID not in (select * from #Total_leave_Id) and Cmp_Id=@Cmp_ID      
        
	SELECT @Paid_Leave_Days = isnull(sum(leave_Days),0) from dbo.T0210_Monthly_LEave_Detail M WITH (NOLOCK) Inner Join
			T0040_Leave_Master L WITH (NOLOCK) on M.Leave_Id = L.Leave_Id
		where Emp_ID = @emp_ID and       
      TEMP_SAL_TRAN_ID = @Sal_Tran_ID and M.Leave_Paid_Unpaid = 'P' and M.Leave_Type <> 'Company Purpose' 
     and M_Leave_Tran_ID not in (select * from #Total_leave_Id) and M.Cmp_Id=@Cmp_ID 
     And Isnull(L.Default_Short_Name,'') <> 'COMP'

     
     
    --Added by hasmukh for sapration of actual paid leave & Out duty type leave 17012012
     
    SELECT @OD_leave_Days = isnull(sum(leave_Days),0) from dbo.T0210_Monthly_LEave_Detail M WITH (NOLOCK)
			Inner Join
		T0040_Leave_Master L WITH (NOLOCK) on M.Leave_Id = L.Leave_Id
		where Emp_ID = @emp_ID and       
      TEMP_SAL_TRAN_ID = @Sal_Tran_ID and M.Leave_Paid_Unpaid = 'P' and M.Leave_Type = 'Company Purpose' 
      and M_Leave_Tran_ID not in (select * from #Total_leave_Id) and M.Cmp_Id=@Cmp_ID 
      And Isnull(L.Default_Short_Name,'') <> 'COMP'
    ----------hasmukh OD leave
    
     --Added by Hardik 22/07/2014 for Adding OD and Compoff Leave in Present Day (Magottaux Requirement)
		SELECT @Compoff_leave_Days = isnull(sum(leave_Days),0) from T0210_Monthly_LEave_Detail M WITH (NOLOCK) Inner Join
			T0040_Leave_Master L WITH (NOLOCK) on M.Leave_Id = L.Leave_Id
		where Emp_ID = @emp_ID and       
		TEMP_SAL_TRAN_ID = @Sal_Tran_ID 
		and M_Leave_Tran_ID not in (select * from #Total_leave_Id) and M.Cmp_Id=@Cmp_ID 
		And Isnull(L.Default_Short_Name,'') = 'COMP'

		Declare @OD_Compoff_As_Present tinyint
		Set @OD_Compoff_As_Present = 0
		
		Select @OD_Compoff_As_Present = Isnull(Setting_Value,0) From dbo.T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Setting_Name='OD and CompOff Leave Consider As Present'
		
		If @OD_Compoff_As_Present = 1
			Begin
				Set @Total_leave_Days = @Total_leave_Days - ISNULL(@OD_leave_Days,0) - ISNULL(@Compoff_Leave_Days,0)
				Set @Present_Days = @Present_Days + ISNULL(@OD_leave_Days,0) + ISNULL(@Compoff_Leave_Days,0)
				Set @OD_leave_Days = 0
				Set @Compoff_Leave_Days = 0
			End
		Else
			Begin
				Set @Paid_Leave_days = Isnull(@Paid_Leave_days,0) + Isnull(@Compoff_Leave_Days,0)
				Set @Compoff_Leave_Days = 0
			End
     
     
----Leave Unpaid Calculation --------------------------                  
	SELECT @Unpaid_Leave = isnull(sum(leave_Days),0) from dbo.T0210_Monthly_LEave_Detail WITH (NOLOCK) where Emp_ID = @emp_ID and       
	TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Leave_Paid_Unpaid = 'U'  
	and M_Leave_Tran_ID not in (select * from #Total_leave_Id) and Cmp_Id=@Cmp_ID 
----------------------------------------------------------- 

	insert into #Total_leave_Id 			  
			  select M_Leave_Tran_ID from dbo.T0210_Monthly_LEave_Detail WITH (NOLOCK) where Emp_ID = @emp_ID and     
				  TEMP_SAL_TRAN_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID  
				  
 ---------------------------------------------

	
	---
	   -------------Hasmukh absent day set from join date 04022012------------------------
 Declare @temp_join_date datetime
 Declare @Out_of_day_before_join numeric(18)
 
 set @temp_join_date = ''
 set @Out_of_day_before_join = 0
 
 select @temp_join_date = Date_Of_Join,@Extra_AB_Rate = Extra_AB_Deduction from dbo.T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_Id
 
 --If MONTH(@temp_join_date) = MONTH(@Month_End_Date) and Year(@temp_join_date) = year(@Month_End_Date) 
 If @temp_join_date >= @Month_St_Date and @temp_join_date <= @Month_End_Date 
	set @Out_of_day_before_join = DATEDIFF(D,@Month_St_Date,@temp_join_date)
 -----------------------------------------------------------------------------------

	
	 if @Out_of_day_before_join >0  and @Left_Date <= @Month_End_Date
		begin
				Declare @OutOf_Days_left_B as NUMERIC(18, 4) -- Added by Hardik 30/04/2013
				Declare @OutOf_Days_left1_B as NUMERIC(18, 4)	
				set @OutOf_Days_left1_B =0
				Set @OutOf_Days_left_B = 0  -- Added by Hardik 30/04/2013
			
		
				Set @OutOf_Days_left_B = datediff(d,@Left_Date,@Month_End_Date)    -- Added by Hardik 30/04/2013
				set @Month_End_Date = @Left_Date
				set @OutOf_Days_left1_B = datediff(d,@Month_St_Date,@Month_End_Date) + 1 
							
				if @Present_Days_Total >0 --- Added condition by Hardik 05/10/2016 as if Same month join and left then if present day pass 0 from front end, it will set present days wrong.
					Set @Present_Days = (@OutOf_Days - (@Out_of_day_before_join + @OutOf_Days_left_B)) - (isnull(@Total_leave_Days,0) + @Weekoff_Days + @Holiday_Days)
		end
	else if @Out_of_day_before_join >0 
		begin	
			IF @Present_Days > (@OutOf_Days - (@Out_of_day_before_join + isnull(@Total_leave_Days,0) + @Weekoff_Days + @Holiday_Days ))
				begin 
					Set @Present_Days = (@OutOf_Days - @Out_of_day_before_join) - (isnull(@Total_leave_Days,0) + @Weekoff_Days + @Holiday_Days)
				end
		end
	else if @Left_Date <= @Month_End_Date  ---Added code from below side 01/07/2013
		begin	
				--Added by Nilay on 29042013
				Declare @OutOf_Days_left as NUMERIC(18, 4) -- Added by Hardik 30/04/2013
				Declare @OutOf_Days_left1 as NUMERIC(18, 4)	
				set @OutOf_Days_left1 =0
				Set @OutOf_Days_left = 0  -- Added by Hardik 30/04/2013
				Set @OutOf_Days_left = datediff(d,@Left_Date,@Month_End_Date)    -- Added by Hardik 30/04/2013		

			IF @Present_Days > (@OutOf_Days - (@OutOf_Days_left + isnull(@Total_leave_Days,0) + @Weekoff_Days + @Holiday_Days ))
					Begin			
						set @Month_End_Date = @Left_Date
						set @OutOf_Days_left1 = datediff(d,@Month_St_Date,@Month_End_Date) + 1
						Set @Present_Days = (@OutOf_Days - @OutOf_Days_left) - (isnull(@Total_leave_Days,0) + @Weekoff_Days + @Holiday_Days)					
					End		
	
		end
	else
		begin
		
			IF @Present_Days > (@OutOf_Days - ( isnull(@Total_leave_Days,0) + @Weekoff_Days + @Holiday_Days ))
				begin
					set @Present_Days = (@OutOf_Days - ( isnull(@Total_leave_Days,0) + @Weekoff_Days + @Holiday_Days ))
				end
				
				---Commented by Hardik 01/07/2013 If Employee Left and Present day is Less than total days then this code will give full present to employee.. 
				---So copy this code to above condition...
				
					--Added by Nilay on 29042013
				--Declare @OutOf_Days_left as NUMERIC(18, 4) -- Added by Hardik 30/04/2013
				--Declare @OutOf_Days_left1 as NUMERIC(18, 4)	
				--set @OutOf_Days_left1 =0
				--Set @OutOf_Days_left = 0 -- Added by Hardik 30/04/2013
			
				--If @Left_Date <= @Month_End_Date
				--	Begin			
				--		Set @OutOf_Days_left = datediff(d,@Left_Date,@Month_End_Date)    -- Added by Hardik 30/04/2013
				--		set @Month_End_Date = @Left_Date
				--		set @OutOf_Days_left1 = datediff(d,@Month_St_Date,@Month_End_Date) + 1 
				--		Set @Present_Days = (@OutOf_Days_left1 ) - (isnull(@Total_leave_Days,0) + @Weekoff_Days + @Holiday_Days)					
				--	End				
		end	
		
		
			
		If @Present_Days < 0 
			Set @Present_Days = 0	
	
	--select @Present_Days,@Present_Days_Total,@Mid_Inc_Working_Day,(@Present_Days + @Total_leave_Days + @Weekoff_Days + @Holiday_Days),@total_count_all_incremnet
	
	if @Mid_Inc_Working_Day < (@Present_Days + @Total_leave_Days + @Weekoff_Days + @Holiday_Days) and @total_count_all_incremnet > 1
		begin		
			Set @Present_Days = @Present_Days - (isnull(@Total_leave_Days,0))
			set @Present_Days_Total = @Present_Days_Total + isnull(@Total_leave_Days,0)
		end
	
	
	
	--if @Present_Days = 0
	--	begin
	--		SET @Present_Days = (@WeekOff_Days + @Holiday_Days + @Paid_Leave_Days + @OD_leave_Days)      
	--	end
	--else
	--	begin				
	--		SET @Present_Days = @Present_Days - (@WeekOff_Days + @Holiday_Days + @Paid_Leave_Days + @OD_leave_Days)      			
	--	end
   
  
	 
 IF @Present_Days > @Working_Days and @Restrict_Present_Days = 'Y'      
  BEGIN
   SET @Present_Days = @Working_Days      
  END      
  
 if @Present_Days_temp < @Present_Days And @OD_Compoff_As_Present = 0 -- Added by rohit on 29072016  -- @OD_Compoff_As_Present condition added by Hardik 26/06/2018 for HNG where OD leave not consider in PresentAnd @OD_Compoff_As_Present = 0 -- Added by rohit on 29072016  -- @OD_Compoff_As_Present condition added by Hardik 26/06/2018 for HNG where OD leave not consider in Present
		 set @Present_Days = @Present_Days_temp 
   
 ----IF  @Present_Days =0 And @Is_Zero_Day_Salary=1 And @Paid_Leave_Days = 0 And @Unpaid_Leave = 0 and @OD_leave_Days = 0 --NIkunj 07-09-2010
 ----BEGIN
	---- SET @StrHoliday_Date=Null
	---- SET @Holiday_days=0
	---- SET @Cancel_Holiday=0 
	---- SET @Cancel_Weekoff=0
	---- SET @Weekoff_Days=0
	---- SET @StrWeekoff_Date=Null
 ----END
  
   

---Unpaid Leave Calculation  Nilay 10 -dec -2009  ---------------------------------

 --IF @Inc_Weekoff = 1
	 --SET @Sal_cal_Days = @Present_Days +   @Weekoff_Days + @Paid_Leave_Days + @Holiday_days 
 --ELSE  
--	SET @Sal_cal_Days = @Present_Days +  @Paid_Leave_Days + @Holiday_days  
  
  
	If @Wages_Type = 'Monthly'  
		Begin
			--changed by Falak on 20-Jan-2011 
			If @Inc_Weekoff = 1    
				begin
					if @Inc_Holiday = 1
						Begin
							set @Sal_cal_Days = @Present_Days +  @Weekoff_Days + @Paid_Leave_Days + @Holiday_Days + @OD_leave_Days + Isnull(@Compoff_leave_Days,0)
							--Hardik 15/10/2012
								 
							--Hardik 15/10/2012
							If @Sal_cal_Days > @Mid_Inc_Working_Day
								Begin															
									Set @Present_Days = @Mid_Inc_Working_Day - (@Weekoff_Days + @Paid_Leave_Days + @Holiday_Days + @OD_leave_Days + @Unpaid_Leave + Isnull(@Compoff_leave_Days,0))
									set @Sal_cal_Days = @Present_Days +  @Weekoff_Days + @Paid_Leave_Days + @Holiday_Days + @OD_leave_Days + Isnull(@Compoff_leave_Days,0)
								End
						End
					else 
						Begin		
							set @Sal_cal_Days = @Present_Days +  @Weekoff_Days + @Paid_Leave_Days + @OD_leave_Days + Isnull(@Compoff_leave_Days,0)
						--Hardik 15/10/2012
						If @Sal_cal_Days > @Mid_Inc_Working_Day
							Begin
								Set @Present_Days = @Mid_Inc_Working_Day - (@Weekoff_Days + @Paid_Leave_Days + @OD_leave_Days + @Unpaid_Leave + Isnull(@Compoff_leave_Days,0))
								set @Sal_cal_Days = @Present_Days +  @Weekoff_Days + @Paid_Leave_Days + @OD_leave_Days + Isnull(@Compoff_leave_Days,0)
							End
						End
				end
			Else 
				begin
					if @Inc_Holiday = 1
						Begin
							set @Sal_cal_Days = @Present_Days  + @Paid_Leave_Days + @Holiday_Days + @OD_leave_Days + Isnull(@Compoff_leave_Days,0)
							--Hardik 15/10/2012
							--Hardik 15/10/2012
							If @Sal_cal_Days > @Mid_Inc_Working_Day
								Begin
									Set @Present_Days = @Mid_Inc_Working_Day - (@Paid_Leave_Days + @Holiday_Days + @OD_leave_Days + @Unpaid_Leave + Isnull(@Compoff_leave_Days,0))
									set @Sal_cal_Days = @Present_Days  + @Paid_Leave_Days + @Holiday_Days + @OD_leave_Days + Isnull(@Compoff_leave_Days,0)
								End
						End
					else 		
						Begin
							set @Sal_cal_Days = @Present_Days  + @Paid_Leave_Days + @OD_leave_Days + Isnull(@Compoff_leave_Days,0)
							--Hardik 15/10/2012
							If @Sal_cal_Days > @Mid_Inc_Working_Day
								Begin
									Set @Present_Days = @Mid_Inc_Working_Day - (@Paid_Leave_Days + @OD_leave_Days+ @Unpaid_Leave + Isnull(@Compoff_leave_Days,0))
									set @Sal_cal_Days = @Present_Days  + @Paid_Leave_Days + @OD_leave_Days + Isnull(@Compoff_leave_Days,0)
								End
						End
				end  
		End
	Else -- Added by Hardik 13/08/2012 for Daily Employee
		Begin
			If @Paid_Weekoff_Daily_Wages = 0
				Begin
				if @Inc_Holiday = 1
				begin
					Set @Sal_cal_Days = @Present_Days +  @Paid_Leave_Days + @Holiday_Days + @OD_leave_Days + Isnull(@Compoff_leave_Days,0)
				end
				else
				begin
					Set @Sal_cal_Days = @Present_Days +  @Paid_Leave_Days + @OD_leave_Days + Isnull(@Compoff_leave_Days,0)
				end	
				End
			Else
				Begin
				if @Inc_Holiday = 1
				begin
					Set @Sal_cal_Days = @Present_Days +  @Weekoff_Days + @Paid_Leave_Days + @Holiday_Days + @OD_leave_Days + Isnull(@Compoff_leave_Days,0)
				end
				else
				begin
					Set @Sal_cal_Days = @Present_Days +  @Weekoff_Days + @Paid_Leave_Days +  @OD_leave_Days + Isnull(@Compoff_leave_Days,0)
				end	
				End
		End

		--Hardik 15/10/2012
		If @Sal_cal_Days > @Mid_Inc_Working_Day
			Set @Sal_cal_Days = @Mid_Inc_Working_Day

		

--	select  @Sal_cal_Days ,@Present_Days , @Weekoff_Days , @Paid_Leave_Days , @Holiday_Days , @OD_leave_Days


---------------------------------------------------------		
------------Emp Partimer --------------------------------        
---Salary calculate days is Half if employee has parttimeer
 IF @Emp_Part_Time = 1
   SET @Sal_cal_days =  @Sal_cal_Days/2     
 ELSE
   SET @Sal_cal_days =@Sal_cal_Days
--------------Emp Partimer --------------------------------        
   
      
 IF @Sal_cal_Days > @Working_Days and @Restrict_Present_Days = 'Y'      
  SET @Sal_cal_Days = @Working_Days       
  
  
  	Declare @Sal_Cal_Days_temp as numeric(18,3) -- Added by rohit on 19022016
	set @Sal_Cal_Days_temp = @Sal_Cal_Days
	set @Sal_Cal_Days = @Sal_Cal_Days + @present_on_holiday
 
 
	---Added by Hardik 23/03/2015 for Vital Soft as they want to show All Half Paid leave in Count and don't want to show Absent Days. 
	DECLARE @Total_Half_Paid_Leave as NUMERIC(18, 4)
	
	SELECT @Total_Half_Paid_Leave = Isnull(SUM(Leave_Used),0) from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where emp_id=@emp_id and For_Date >= @month_St_Date and For_Date <= @Month_End_Date and
	Leave_Id in (Select Leave_Id From T0040_LEAVE_MASTER WITH (NOLOCK) where cmp_id=@cmp_Id and Isnull(Half_Paid,0)=1) and Isnull(Half_Payment_Days,0)=0
 
	if @Total_Half_Paid_Leave > 0
		BEGIN
			Set @Total_leave_Days = @Total_leave_Days + (ISNULL(@Total_Half_Paid_Leave,0)/2)
			Set @Paid_leave_Days = @Paid_leave_Days + (ISNULL(@Total_Half_Paid_Leave,0)/2)
		End
	---- End by Hardik 23/03/2015
	
 
-- SET @Absent_Days = @Outof_Days - (@Present_Days +  @WeekOff_Days + @Holiday_Days + @Paid_Leave_Days + @Unpaid_Leave + @OD_leave_Days)      
   --SET @Absent_Days = @Outof_Days - (@Present_Days +  @WeekOff_Days + @Holiday_Days + @Paid_Leave_Days + @OD_leave_Days + isnull(@Out_of_day_before_join,0))      
  
     	
	If @Wages_Type = 'Monthly'
		Begin
			If @Inc_Weekoff = 0    ---Added by Hasmukh 30102013
				Begin
					If @Inc_Holiday = 0
						Begin
							SET @Absent_Days = @Mid_Inc_Working_Day - (@Present_Days + @Paid_Leave_Days + @OD_leave_Days + isnull(@Out_of_day_before_join,0) + isnull(@OutOf_Days_left,0))     --@OutOf_Days_left added by ankit for left emp cal absent days 04072013 
						End
					Else
						Begin
							SET @Absent_Days = @Mid_Inc_Working_Day - (@Present_Days + @Holiday_Days + @Paid_Leave_Days + @OD_leave_Days + isnull(@Out_of_day_before_join,0) + isnull(@OutOf_Days_left,0))     --@OutOf_Days_left added by ankit for left emp cal absent days 04072013 
						End
				End
			Else
				Begin
					If @Inc_Holiday = 0
						Begin
							SET @Absent_Days = @Mid_Inc_Working_Day - (@Present_Days +  @WeekOff_Days + @Paid_Leave_Days + @OD_leave_Days + isnull(@Out_of_day_before_join,0) + isnull(@OutOf_Days_left,0))     --@OutOf_Days_left added by ankit for left emp cal absent days 04072013 
						End
					Else
						Begin
							SET @Absent_Days = @Mid_Inc_Working_Day - (@Present_Days +  @WeekOff_Days + @Holiday_Days + @Paid_Leave_Days + @OD_leave_Days + isnull(@Out_of_day_before_join,0) + isnull(@OutOf_Days_left,0))     --@OutOf_Days_left added by ankit for left emp cal absent days 04072013 
						End
				End    ---Added by Hasmukh 30102013 End
		End
	Else -- Added by Hardik 13/08/2012 for Daily Employee
		Begin
			If @Paid_Weekoff_Daily_Wages = 0
				Begin
					SET @Absent_Days = @Mid_Inc_Working_Day - (@Present_Days +  @Holiday_Days + @Paid_Leave_Days + @OD_leave_Days + isnull(@Out_of_day_before_join,0)+ isnull(@OutOf_Days_left,0))
					If @Absent_Days > 0 --and @Absent_Days >= @Weekoff_Days -- commented by rohit for Absent Showing Wrong in cera on 25032016
						Set @Absent_Days = @Absent_Days - @Weekoff_Days
				End
			Else
				Begin
					SET @Absent_Days = @Mid_Inc_Working_Day - (@Present_Days +  @WeekOff_Days + @Holiday_Days + @Paid_Leave_Days + @OD_leave_Days + isnull(@Out_of_day_before_join,0)+ isnull(@OutOf_Days_left,0))
				End
		End
     
 
 IF @Absent_Days < 0       
  SET @Absent_Days =0      
  
--Alpesh 02-Jul-2012
if @Extra_AB_Rate is null
	Begin
		set @Extra_AB_Rate = 0.0
	End
	
				Declare @Temp_Absent_Days as NUMERIC(18, 4)
				
				Set @Temp_Absent_Days = (@Absent_Days - ISNULL(@Unpaid_Leave,0))
				
				set @Extra_AB_Days = @Temp_Absent_Days * @Extra_AB_Rate	
				
				if @Extra_AB_Days < 0
					set @Extra_AB_Days = 0

				--Hardik 10/04/2013 for Extra Absent Deduct from Present Day
				If @Sal_Cal_Days >= @Extra_AB_Days And @Present_Days >= @Extra_AB_Days And @Extra_AB_Rate > 0 And @Extra_AB_Days > 0
					Begin
						--Set @Sal_Cal_Days = @Sal_Cal_Days - (@Temp_Absent_Days + Isnull(@Extra_AB_Days,0))
						--Set @Present_Days = @Present_Days - (@Temp_Absent_Days + Isnull(@Extra_AB_Days,0))
						
						Set @Sal_Cal_Days = @Sal_Cal_Days - (Isnull(@Extra_AB_Days,0))
						Set @Present_Days = @Present_Days - (Isnull(@Extra_AB_Days,0))
					End
				--Else
				--	Begin
				--		Set @Sal_Cal_Days = 0
				--		Set @Present_Days = 0
				--	End
					
		
---- End ----

 IF @Wages_Type = 'Monthly'       
	 IF @Inc_Weekoff = 1      
	   BEGIN
			IF @Inc_Holiday = 1
				BEGIN 
					
					SET @Day_Salary =  @Basic_Salary /@Outof_Days
					
					SET @Gross_Salary_ProRata = @Actual_Gross_Salary/@Outof_Days      
					
					SET @OT_Working_Day = @Outof_Days     		
					if @Working_days_Arear > 0 
						begin
							SET @Day_Salary_Arear =  @Basic_Salary_Arear /@Working_days_Arear --Hardik 07/01/2012		
						end
				End	
			ELSE					
				BEGIN
					
					SET @Day_Salary =  @Basic_Salary / @Working_Days 
					If @Working_days_Arear > 0 
						Begin
							SET @Day_Salary_Arear =  @Basic_Salary_Arear / @Working_days_Arear --Hardik 07/01/2012
						End
						
					SET @Gross_Salary_ProRata = @Actual_Gross_Salary/@Working_Days  
					SET @OT_Working_Day = @Working_Days
					--set @Outof_Days =@Outof_Days - @Holiday_Days
				END
	   END       
	 ELSE      
	   BEGIN
			--set @Working_Days = @Working_Days - @Holiday_Days 
			--Added By Ramiz on 31/07/2017
			if @Salary_Depends_on_Production = 1
			   BEGIN
			      SET @Day_Salary =  @Basic_Salary / @Sal_Cal_Days 
			   END
			ELSE
			   BEGIN
			      SET @Day_Salary =  @Basic_Salary / @Working_Days 
			   END
			If @Working_days_Arear > 0 
				Begin
			   		SET @Day_Salary_Arear =  @Basic_Salary_Arear / @Working_days_Arear --Hardik 07/01/2012
			   	End
			SET @Gross_Salary_ProRata = @Actual_Gross_Salary/@Working_Days      
			SET @OT_Working_Day = @Working_Days     
	   END       
	ELSE
		BEGIN
			SET @Day_Salary =  @Basic_Salary
			SET @Day_Salary_Arear =  @Basic_Salary_Arear --Hardik 07/01/2012
			SET @OT_Working_Day = @Working_Days
		END
		
If @SalaryBasis='Fix Hour Rate'--Nikunj 19-04-2011
	Begin			 		
		 Set @Hour_Salary = @Day_Salary
	End
Else
	Begin
		SET @Hour_Salary = @Day_Salary * 3600 /  @Shift_Day_Sec        
		--SET @Hour_Salary_OT = @Day_Salary * 3600  /  @Fix_OT_Shift_Sec        
		If Isnull(@Fix_OT_Work_Days,0) = 0
			If Isnull(@Fix_OT_Shift_Sec,0) > 0
				SET @Hour_Salary_OT = @Day_Salary * 3600  /  @Fix_OT_Shift_Sec        
			Else
				SET @Hour_Salary_OT = @Day_Salary * 3600  /  @Shift_Day_Sec
		Else
			If Isnull(@Fix_OT_Shift_Sec,0) > 0
				SET @Hour_Salary_OT =  (@Basic_Salary / @Fix_OT_Work_Days) * 3600  /  @Fix_OT_Shift_Sec
			Else
				SET @Hour_Salary_OT =  (@Basic_Salary / @Fix_OT_Work_Days) * 3600  /  @Shift_Day_Sec
		
	End	

	

   IF @SalaryBasis ='Day'    
		BEGIN
			If @ROUNDING = 1
				Begin
					SET @Salary_Amount  = Round(@Day_Salary * @Sal_Cal_Days,@Round)
					SET @Salary_amount_Arear = Round(@Day_Salary_Arear * @Arear_Day,@Round)--Hardik 07/01/2012
					
					
				End
			Else
				Begin				
					SET @Salary_Amount  = Isnull(@Day_Salary * @Sal_Cal_Days,0)
					SET @Salary_amount_Arear = Isnull(@Day_Salary_Arear * @Arear_Day,0) --Hardik 07/01/2012
					
					--select @Day_Salary_Arear,@Arear_Day
					
					--select @Salary_amount_Arear
					
				End
		END
     
   ELSE
		BEGIN       
		   SELECT @Actual_Working_Sec =   @Shift_Day_Sec * @Sal_Cal_Days      
		   SELECT @Actual_Working_Hours = dbo.F_Return_Hours(@Actual_Working_Sec) 
		   If @ROUNDING = 1          
				SELECT @Salary_Amount  = Round(@Hour_Salary * @Actual_Working_Sec/3600,@Round)      
		   Else
				SELECT @Salary_Amount  = Isnull(@Hour_Salary * @Actual_Working_Sec/3600,0)      
		END       
 
	
	If @ROUNDING = 1
		SET @Gross_Salary_ProRata = Round(@Gross_Salary_ProRata * @Sal_Cal_Days,@Round)      
	Else
		SET @Gross_Salary_ProRata = Round(@Gross_Salary_ProRata * @Sal_Cal_Days,2)

	
 IF @Fix_Salary = 1
	BEGIN
		SET @Salary_Amount = @Basic_Salary	
	END     

	
	--Ankit 07012015--
	 If @WO_OT_Hours > 0    
		Set @Emp_WO_OT_Sec = @WO_OT_Hours * 3600 
			   
	 If @HO_OT_Hours > 0    
		Set @Emp_HO_OT_Sec = @HO_OT_Hours * 3600 
	--Ankit 07012015--
			
 IF @EMP_OT = 1      
  BEGIN
	IF @Emp_OT_Sec > 0  AND @Emp_OT_Min_Sec > 0 AND @Emp_OT_Sec < @Emp_OT_Min_Sec      
		SET @Emp_OT_Sec = 0      
	ELSE IF @Emp_OT_Sec > 0 AND @Emp_OT_Max_Sec > 0 AND @Emp_OT_Sec > @Emp_OT_Max_Sec      
		SET @Emp_OT_Sec = @Emp_OT_Max_Sec  
		
	     
   	IF(ISNULL(@OT_RATE_TYPE,0) = 0)
		BEGIN
		  
				IF @Emp_OT_Sec > 0      
				If @ROUNDING = 1
					Begin
						Set @Emp_OT_Hours_Var = dbo.F_Return_Hours(@Emp_OT_Sec)    --Nikunj
						Set @Emp_OT_Hours_Var =Replace(@Emp_OT_Hours_Var,':','.')--Nikunj
						--Set @Emp_OT_Hours_Num= Convert (NUMERIC(18, 4), @Emp_OT_Hours_Var)--Nikunj   
						Set @Emp_OT_Hours_Num= @Emp_OT_Sec / 3600	--Added By Hardik 06072013
						--SET @OT_Amount = Round(ROUND((@Emp_OT_Hours_Num) * @Hour_Salary_OT,@Round) * @Emp_WD_OT_Rate,@Round) --Hardik 17/07/2012
						IF @Fix_OT_Hour_Rate_WD = 0	--Ankit 03122013
							SET @OT_Amount = Round(ROUND((@Emp_OT_Hours_Num) * @Hour_Salary_OT,@Round) * @Emp_WD_OT_Rate,@Round) --Hardik 17/07/2012
						Else
							SET @OT_Amount = Round(ROUND((@Emp_OT_Hours_Num) * @Fix_OT_Hour_Rate_WD,@Round) * @Emp_WD_OT_Rate,@Round) 
					End
				else
					Begin
						Set @Emp_OT_Hours_Var = dbo.F_Return_Hours(@Emp_OT_Sec)    --Nikunj
						Set @Emp_OT_Hours_Var =Replace(@Emp_OT_Hours_Var,':','.')--Nikunj
						--Set @Emp_OT_Hours_Num= Convert (NUMERIC(18, 4), @Emp_OT_Hours_Var)--Nikunj   
						Set @Emp_OT_Hours_Num= @Emp_OT_Sec / 3600	--Added By Hardik 06072013
						--SET @OT_Amount = ((@Emp_OT_Hours_Num) * @Hour_Salary_OT) * @Emp_WD_OT_Rate --Hardik 17/07/2012
						IF @Fix_OT_Hour_Rate_WD = 0	--Ankit 03122013
							SET @OT_Amount = ((@Emp_OT_Hours_Num) * @Hour_Salary_OT) * @Emp_WD_OT_Rate --Hardik 17/07/2012
						Else
							SET @OT_Amount = ((@Emp_OT_Hours_Num) * @Fix_OT_Hour_Rate_WD) * @Emp_WD_OT_Rate --Hardik 17/07/2012
					End
			
				--Ankit 21102013--
				If @Emp_WO_OT_Sec > 0
					If @ROUNDING = 1
						Begin
							Set @Emp_WO_OT_Hours_Var = dbo.F_Return_Hours(@Emp_WO_OT_Sec)
							Set @Emp_WO_OT_Hours_Var = Replace(@Emp_WO_OT_Hours_Var,':','.')
							Set @Emp_WO_OT_Hours_Num = @Emp_WO_OT_Sec / 3600
							
							IF @Fix_OT_Hour_Rate_WOHO = 0	
								set @WO_OT_Amount = round((@Emp_WO_OT_Hours_Num) * (@Hour_Salary_OT * @Emp_WO_OT_Rate ),@Round)      				
							Else
								set @WO_OT_Amount = Round(ROUND((@Emp_WO_OT_Hours_Num) * @Fix_OT_Hour_Rate_WOHO,@Round) * @Emp_WO_OT_Rate,@Round) 
								
						End
					Else
						Begin
							Set @Emp_WO_OT_Hours_Var = dbo.F_Return_Hours(@Emp_WO_OT_Sec)
							Set @Emp_WO_OT_Hours_Var = Replace(@Emp_WO_OT_Hours_Var,':','.')
							Set @Emp_WO_OT_Hours_Num = @Emp_WO_OT_Sec / 3600
							IF @Fix_OT_Hour_Rate_WOHO = 0	
								set @WO_OT_Amount = ((@Emp_WO_OT_Hours_Num) * @Hour_Salary_OT) * @Emp_WO_OT_Rate   
							Else
								set @WO_OT_Amount = ((@Emp_WO_OT_Hours_Num) * @Fix_OT_Hour_Rate_WOHO) * @Emp_WO_OT_Rate  	
						End	
					
				If @Emp_HO_OT_Sec > 0   
					If @ROUNDING = 1
						Begin
							Set @Emp_HO_OT_Hours_Var = dbo.F_Return_Hours(@Emp_HO_OT_Sec)
							Set @Emp_HO_OT_Hours_Var = Replace(@Emp_HO_OT_Hours_Var,':','.')
							Set @Emp_HO_OT_Hours_Num = @Emp_HO_OT_Sec / 3600
							IF @Fix_OT_Hour_Rate_WOHO = 0
								set @HO_OT_Amount = round((@Emp_HO_OT_Hours_Num) * (@Hour_Salary_OT * @Emp_HO_OT_Rate ),@Round)      				
							Else
								set @HO_OT_Amount = Round(ROUND((@Emp_WO_OT_Hours_Num) * @Fix_OT_Hour_Rate_WOHO,@Round) * @Emp_HO_OT_Rate,@Round) 	
						End
					Else
						Begin
							Set @Emp_HO_OT_Hours_Var = dbo.F_Return_Hours(@Emp_HO_OT_Sec)
							Set @Emp_HO_OT_Hours_Var = Replace(@Emp_HO_OT_Hours_Var,':','.')
							Set @Emp_HO_OT_Hours_Num = @Emp_HO_OT_Sec / 3600
							
							IF @Fix_OT_Hour_Rate_WOHO = 0
								set @HO_OT_Amount = ((@Emp_HO_OT_Hours_Num) * @Hour_Salary_OT) * @Emp_HO_OT_Rate
							Else
								set @HO_OT_Amount = ((@Emp_HO_OT_Hours_Num) * @Fix_OT_Hour_Rate_WOHO) * @Emp_HO_OT_Rate
						End	
				--Ankit 21102013--
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
			
				
	
	IF @ExOTSetting > 0 AND @OT_Amount > 0     
		SET @OT_Amount = @OT_Amount + @OT_Amount * @ExOTSetting
		
	If @Fix_OT_Work_Days > 0 
		Begin
			set @Fix_OT_Work_Days = @Fix_OT_Work_Days
		End
	Else
		Begin
			Set @Fix_OT_Work_Days = @OT_Working_Day
		End       
         
		INSERT into #OT_Data(Emp_Id,Basic_Salary,Day_Salary,OT_Sec,Ex_OT_SEtting,OT_Amount,Shift_Day_Sec,OT_Working_Day
						,WO_OT_Amount,WO_OT_Hour,WO_OT_Sec,HO_OT_Amount,HO_OT_Hour,HO_OT_Sec)	--Ankit 07012015
		SELECT @Emp_ID,@Basic_Salary,@Day_Salary,@Emp_OT_Sec,@ExOTSetting,@OT_Amount,@Fix_OT_Shift_Sec,@Fix_OT_Work_Days			
						,@WO_OT_Amount,@Emp_WO_OT_Hours_Num,@Emp_WO_OT_Sec,@HO_OT_Amount,@Emp_HO_OT_Hours_Num,@Emp_HO_OT_Sec	--Ankit 07012015
		
		SELECT @Emp_OT_Hours = dbo.F_Return_Hours(@Emp_OT_Sec)   
		SELECT @Emp_WO_OT_Hours = dbo.F_Return_Hours(@Emp_WO_OT_Sec)	--Ankit 07012015    
		SELECT @Emp_HO_OT_Hours = dbo.F_Return_Hours(@Emp_HO_OT_Sec)	--Ankit 07012015   
    
	END      
   ELSE      
     BEGIN      
		SET @Emp_OT_Sec = 0      
		SET @OT_Amount = 0      
		SET @Emp_OT_Hours = '00:00'      
	    
	    SET @Emp_WO_OT_Sec = 0    --Ankit 21102013
	    SET @WO_OT_Amount = 0    
	    SET @Emp_WO_OT_Hours = '00:00'  
	   
	    SET @Emp_HO_OT_Sec = 0    --Ankit 21102013
	    SET @HO_OT_Amount = 0    
	    SET @Emp_HO_OT_Hours = '00:00' 
	    
	    INSERT INTO #OT_Data(Emp_Id,Basic_Salary,Day_Salary,OT_Sec,Ex_OT_SEtting,OT_Amount,OT_Working_Day)
		SELECT  @Emp_ID,@Basic_Salary,@Day_Salary,0,0,0,0 
	 END     
       
       
         IF @Wages_Amount = 1
		  BEGIN
			 DECLARE @Gr_Days           NUMERIC(18, 4)
			 DECLARE @Gr_Salary_amount  NUMERIC(18, 4)
			 SET @Gr_Days =0
			 SET @Gr_Salary_amount =0
			 SELECT @Gr_Salary_amount = Gross_salary,@Salary_Amount= Basic_Salary from dbo.T0095_Increment WITH (NOLOCK) where increment_id = @Increment_ID    
			 SET   @Gr_Salary_amount = Round(@Gr_Salary_amount * @Sal_cal_days/@Outof_Days,0) 
			 SET   @Salary_Amount =  ROUND(@Gr_Salary_amount/2 ,0)
			 SET   @Basic_Salary =  @Salary_Amount	
          END
    ------------------------------ALTER BY NILAY 27 -JAN -2010---------------------------      
    
 --   IF @ROUNDING =1
	--	Begin 				
	--		EXEC SP_CALCULATE_ALLOWANCE_DEDUCTION_ROUNDING @Sal_Tran_ID,@emp_ID,@Cmp_ID,@Increment_ID,@month_St_Date,@Month_End_Date,@Wages_type,@Basic_Salary,@Gross_Salary_ProRata,@Salary_Amount,@Present_Days,@Absent_Days,@Paid_leave_Days,@Sal_Cal_Days,@Working_Days,@OT_Amount output,@Day_Salary ,@Branch_ID,@M_IT_Tax,Null,@late_Extra_Amount,@Allo_On_Leave,@OutOf_Days,@Areas_Amount    
	--	End	
	--ELSE
	--	Begin				
		    --EXEC dbo.SP_CALCULATE_ALLOWANCE_DEDUCTION @Sal_Tran_ID,@emp_ID,@Cmp_ID,@Increment_ID,@month_St_Date,@Month_End_Date,@Wages_type,@Basic_Salary,@Gross_Salary_ProRata,@Salary_Amount,@Present_Days,@Absent_Days,@Paid_leave_Days,@Sal_Cal_Days,@Working_Days,@OT_Amount output,@Day_Salary ,@Branch_ID,@M_IT_Tax,Null,@late_Extra_Amount,@Allo_On_Leave,@OutOf_Days ,@Areas_Amount         		
		--End    
		
		--Alpesh 25-Nov-2011
		IF @Fix_Salary = 1
			Begin
			-- Comment And Add by rohit For Fix Salaried Employee  which has not Include week off Case For Sales India- 19072013
			
				 -- Added by nilesh pate on 23012017 mid join in Fix Salary Days 
					if @temp_join_date > @Month_St_Date and @temp_join_date <= @Month_End_Date and @Fix_Salary = 1
						Begin
							set @Sal_cal_Days = datediff(d,@temp_join_date,@Month_End_Date) + 1
							Set @Salary_Amount = ROUND((@Basic_Salary * @Sal_cal_Days)/@Working_days,@Round)
						End
					Else
						Begin
							set @Sal_cal_Days = datediff(d,@Month_St_Date,@Month_End_Date) + 1
						End
			--If @Inc_Weekoff = 1    
			--	begin
			--		if @Inc_Holiday = 1
			--			Begin
			--				set @Sal_cal_Days = datediff(d,@Month_St_Date,@Month_End_Date) + 1
			--			End
			--		else 
			--			Begin		
			--				set @Sal_cal_Days = (datediff(d,@Month_St_Date,@Month_End_Date) + 1) - @Holiday_Days  
						
			--			End
			--	end
			--Else 
			--	begin
			--		if @Inc_Holiday = 1
			--			Begin
			--				set @Sal_cal_Days = (datediff(d,@Month_St_Date,@Month_End_Date) + 1) - @Weekoff_Days
			--			End
			--		else 		
			--			Begin
			--				set @Sal_cal_Days = (datediff(d,@Month_St_Date,@Month_End_Date) + 1) - @Holiday_Days - @Weekoff_Days
			--			End
			--	end  
				-- Ended by rohit on 19072013
			End
		-- End
		Set @M_IT_Tax = isnull(@M_IT_Tax,0) + ISNULL(@IT_M_ED_Cess_Amount,0)
		
		--Added the code by Ramiz on 04/05/2016 for Only Gradewise Salary used in Mafatlals , discussed with Hardik bhai , as I need to Consolidate OT Hours in one single Header
			IF (@Gradewise_Salary_Enabled > 0)
				BEGIN
					If OBJECT_ID('tempdb..#OT_Table') is Not Null
					 BEGIN
						DROP TABLE #OT_TABLE
					 END
					 CREATE TABLE #OT_TABLE
					   (
						 EMP_ID_TEMP NUMERIC(18,0),
						 OT_HOURS_TEMP NUMERIC(18,2),
						 OT_AMOUNT_TEMP NUMERIC(18,2)
					   )
				END
		--Code Ends Here--
		--if @Sal_Cal_Days > 0

			EXEC dbo.SP_CALCULATE_ALLOWANCE_DEDUCTION @Sal_Tran_ID,@emp_ID,@Cmp_ID,@Increment_ID,@month_St_Date,@Month_End_Date,@Wages_type,@Basic_Salary,@Gross_Salary_ProRata,@Salary_Amount,@Present_Days,@Absent_Days,@Paid_leave_Days,@Sal_Cal_Days,@OutOf_Days,@OT_Amount output,@Day_Salary ,@Branch_ID,@M_IT_Tax,Null,@late_Extra_Amount,@Allo_On_Leave,@Working_days  ,@Areas_Amount ,@ROUNDING,@WO_OT_Amount output , @HO_OT_Amount output, @tmp_Month_St_Date , @tmp_Month_End_Date,@Arear_Day,@Arear_Month,@Arear_Year,@Salary_Amount_Arear,@total_count_all_incremnet,@Working_days_Arear,0,0,0,0,0  
		
		--Added the code by Ramiz on 04/05/2016 for Only Gradewise Salary used in Mafatlals , discussed with Hardik bhai , as I need to Consolidate OT Hours in one single Header
				IF (@Gradewise_Salary_Enabled > 0)
					BEGIN
						IF EXISTS (SELECT 1 FROM #OT_TABLE WHERE EMP_ID_TEMP = @EMP_ID )
							BEGIN
									SELECT @EMP_OT_HOURS_NUM = OT_HOURS_TEMP FROM #OT_TABLE 
									DELETE FROM #OT_TABLE
							END
					END
		--Code Ends Here--
					
		Set @M_IT_Tax = isnull(@M_IT_Tax,0) - ISNULL(@IT_M_ED_Cess_Amount,0)

	  -- Added by Hardik 30/08/2012 for TDS to be save in T0200_Monthly_Salary Table  
	  Select @M_IT_Tax = Sum(Isnull(M_AD_Amount,0)) from dbo.T0210_monthly_Ad_detail WITH (NOLOCK)  
	   where TEMP_SAL_TRAN_ID = @Sal_Tran_Id   
		And AD_Id In (Select AD_ID from dbo.T0050_ad_master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Ad_Def_Id = 1)  
		
	-----------------------------ALTER BY NILAY 27 -JAN -2010---------------------------      	    
	 	

------------- Allowance amount calculated but not effect on salary and release after ation-----------------///

 --developed : Girish---- 
DECLARE  @Temp_Allowance numeric(22,2)
Declare  @Temp_Allowance_Arear Numeric(22,2) --Hardik 07/01/2012
DECLARE  @Temp_Deduction numeric(22,2)
DECLARE  @Temp_Deduction_Arear numeric(22,2) --Hardik 07/01/2012
DECLARE  @Temp_Allownace_PT numeric(22,2)
Declare @Reim_amount as NUMERIC(18, 4)
declare @adv_amt1 as NUMERIC(18, 4)
 
SET @Temp_Allowance=0
SET @Temp_Allowance_Arear=0
SET @Temp_Deduction=0
SET @Temp_Deduction_Arear=0
SET @Temp_Allownace_PT = 0
set @Reim_amount =0 
     
    ---------Change done by Hardik bhai in Bhaskar , same done here by Ramiz on 10042015   -------
			--SELECT @Allow_Amount = SUM(ISNULL(M_AD_AMOUNT,0)) from dbo.T0210_MONTHLY_AD_DETAIL       
			--WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I'  and Cmp_Id=@Cmp_ID      
			--AND AD_ID not in (select AD_ID from dbo.T0050_AD_Master where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 1 OR isnull(Ad_Effect_Month,'')<>'')
			
			SELECT @Allow_Amount = sum(ISNULL(M_AD_AMOUNT,0)) From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)      				
			WHERE --TEMP_SAL_TRAN_ID = @Sal_Tran_ID and				
			Emp_ID = @Emp_ID and m_AD_Flag ='I'  and Cmp_Id=@Cmp_ID and				
			--for_date=@month_st_date and To_date=@month_end_date	----Mid-Increment Case, not get allowances amount** Comment by Ankit 05062015
				for_date=@tmp_Month_St_Date and To_date=@tmp_Month_End_Date	
			and Sal_Tran_ID not in (Select Sal_Tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_Id = @Emp_Id and Is_FNF=1)	AND 
			 AD_ID not in (select AD_ID from T0050_AD_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID 				
			and  isnull(Ad_Effect_Month,'')<>'' or (isnull(AD_Not_effect_salary,0) = 1 )  )
	---------Changes Ended by Hardik bhai in Bhaskar , same done here by Ramiz on 10042015   -------
		

	----Get Reimbursement Amount-------------
	 SELECT @Reim_amount = SUM(case when isnull(ReimShow,0) = 0 then ISNULL(M_AD_AMOUNT,0) ELSE isnull(ReimAmount,0) end)
		from dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) inner JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON
		MAD.AD_ID= AM.AD_ID
		WHERE MAD.TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I'  and AM.Cmp_Id=@Cmp_ID  and    
		(isnull(AD_Not_effect_salary,0) = 1 and isnull(MAD.ReimShow,0) = 1) 
	----Adding Reimbursement Amount Reimshow flag is equal to 1--------

	 Set @Allow_Amount =isnull(@Allow_Amount,0) + ISNULL(@Reim_amount,0)	
	 
	
		
	 SELECT @Temp_Allowance = SUM(ISNULL(M_AD_AMOUNT,0)) from dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)      
		WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I' and Cmp_Id=@Cmp_ID       
			AND AD_ID  in (select AD_ID from dbo.T0050_AD_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 0 And Charindex(@Strmonth,Ad_Effect_Month )<> 0 AND (isnull(AD_Not_effect_salary,0) = 0 OR isnull(ReimShow,0) =1))           

	--Hardik 07/01/2012 for Arears Allowance Amount
	 --SELECT @Allow_Amount_Arear = SUM(ISNULL(M_AREAR_AMOUNT,0)) from dbo.T0210_MONTHLY_AD_DETAIL       
		--WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I' and Cmp_Id=@Cmp_ID       
		--	AND AD_ID not in (select AD_ID from dbo.T0050_AD_Master where Cmp_ID =@Cmp_ID and (isnull(AD_Not_effect_salary,0) = 1 OR isnull(Ad_Effect_Month,'')<>''))

		SELECT	@Allow_Amount_Arear = SUM(ISNULL(M_AREAR_AMOUNT,0)) 
		From	dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
				LEFT OUTER JOIN dbo.T0050_AD_Master AD WITH (NOLOCK) ON AD.CMP_ID=MAD.Cmp_ID and (isnull(AD_Not_effect_salary,0) = 1 OR isnull(Ad_Effect_Month,'')<>'') AND MAD.AD_ID=AD.AD_ID
		WHERE	TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='I' and Emp_ID = @Emp_ID  -- Uncomment by rohit on 17022017 for cera case
				AND AD.AD_ID IS NULL

		SELECT	@Allow_Amount_Arear = @Allow_Amount_Arear + Isnull(SUM(ISNULL(M_AREAR_AMOUNT,0)) ,0)
		From	dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
				INNER JOIN dbo.T0050_AD_Master AD WITH (NOLOCK) ON AD.CMP_ID=MAD.Cmp_ID and (isnull(AD_Not_effect_salary,0) = 1 OR isnull(Ad_Effect_Month,'')<>'') AND MAD.AD_ID=AD.AD_ID
		WHERE	TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='I' and Emp_ID = @Emp_ID  
				AND MAD.ReimShow=1 --NMS

		

	--Added by Nilesh Patel on 05042018 - For Aarkary Client -- Auto Paid Reimbursement Arrear is not calculate in Gross Salary 
	 --Declare @Reim_Arrear Numeric(18,2)
	 --Set @Reim_Arrear = 0

	 --SELECT @Reim_Arrear = SUM(ISNULL(M_AREAR_AMOUNT,0)) from dbo.T0210_MONTHLY_AD_DETAIL MAD
	 --   Inner Join T0050_AD_MASTER  AD ON MAD.AD_ID = AD.AD_ID     
		--WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I' and MAD.Cmp_Id=@Cmp_ID   
		--	and isnull(AD_Not_effect_salary,0) = 1 and isnull(ReimShow,0) = 1 and AD_CAL_TYPE = 'Monthly'
	
	 --Set @Allow_Amount_Arear = @Allow_Amount_Arear + @Reim_Arrear
	 -- End code  

	 --SELECT @Temp_Allowance_Arear = SUM(ISNULL(M_AREAR_AMOUNT,0)) from dbo.T0210_MONTHLY_AD_DETAIL       
		--WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I'  and Cmp_Id=@Cmp_ID      
		--	AND AD_ID  in (select AD_ID from dbo.T0050_AD_Master where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 0 And Charindex(@Strmonth,Ad_Effect_Month )<> 0)

-- Added by rohit for allowance that not effect on gross salary but calculate in net salary on 06-may-2013

 SELECT @Allow_Amount_Effect_only_Net = SUM(ISNULL(M_AD_AMOUNT,0)) + SUM(ISNULL(M_AREAR_AMOUNT,0)) + SUM(ISNULL(M_AREAR_AMOUNT_Cutoff ,0)) From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)      
		WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I'  and Cmp_Id=@Cmp_ID      
			AND AD_ID in (select AD_ID from dbo.T0050_AD_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 1 and isnull(Effect_Net_Salary,0)=1)

-- Ended by rohit  06-may-2013

--change by Falak on 02-OCT-2010 for effecting 'Not Effect on PT' in Allownace/DED MAster
--Change by Hardik 07/01/2012
	SELECT @Temp_Allownace_PT = SUM(ISNULL(M_AD_AMOUNT,0)) + SUM(Isnull(M_AREAR_AMOUNT,0)) from dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)        
		WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I' and isnull(M_AD_Not_effect_ON_PT,0) = 1 and Cmp_Id=@Cmp_ID      
			AND AD_ID  in (select AD_ID from dbo.T0050_AD_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_ON_PT,0) = 1 and isnull(AD_Not_effect_salary,0) = 0) --And Charindex(@Strmonth,Ad_Effect_Month )<> 0)           
      
      ----------Changes done by Hardik bhai in Bhaskar , same done here by Ramiz on 10042015   --------------------
                  
	--SELECT @Dedu_Amount = SUM(ISNULL(M_AD_AMOUNT,0)) from dbo.T0210_MONTHLY_AD_DETAIL       
	--WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='D' and Cmp_Id=@Cmp_ID       
	--AND AD_ID not in (select AD_ID from dbo.T0050_AD_Master where Cmp_ID =@Cmp_ID and  isnull(AD_Not_effect_salary,0) = 1 OR isnull(Ad_Effect_Month,'')<>'')       
	
			SELECT @Dedu_Amount = sum(ISNULL(M_AD_AMOUNT,0)) From T0210_MONTHLY_AD_DETAIL  WITH (NOLOCK)     				
            WHERE --TEMP_SAL_TRAN_ID = @Sal_Tran_ID and				
            Emp_ID = @Emp_ID and m_AD_Flag ='D'  and Cmp_Id=@Cmp_ID and				
            --for_date=@month_st_date and To_date=@month_end_date	----Mid-Increment Case, not get allowances amount** Comment by Ankit 05062015
				for_date=@tmp_Month_St_Date and To_date=@tmp_Month_End_Date	
            and Sal_Tran_ID not in (Select Sal_Tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_Id = @Emp_Id and Is_FNF=1)	AND 
            AD_ID not in (select AD_ID from T0050_AD_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID 				
            and  isnull(Ad_Effect_Month,'')<>'' or (isnull(AD_Not_effect_salary,0) = 1 )  )
				
	
	----------Changes ended by Hardik bhai in Bhaskar , same done here by Ramiz on 10042015   --------------------
  
	SELECT @Temp_Deduction = SUM(ISNULL(M_AD_AMOUNT,0)) from dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)       
		WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='D' and Cmp_Id=@Cmp_ID       
			AND AD_ID  in (select AD_ID from dbo.T0050_AD_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 0 And Charindex(@Strmonth,Ad_Effect_Month )<> 0)           

	--Hardik 07/01/2012
	SELECT @Dedu_Amount_Arear = SUM(ISNULL(M_AREAR_AMOUNT,0)) from dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)      
		WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='D' and Cmp_Id=@Cmp_ID       
			AND AD_ID not in (select AD_ID from dbo.T0050_AD_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID and  isnull(AD_Not_effect_salary,0) = 1 OR isnull(Ad_Effect_Month,'')<>'')

	SELECT @Temp_Deduction_Arear = SUM(ISNULL(M_AREAR_AMOUNT,0)) from dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)       
		WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='D' and Cmp_Id=@Cmp_ID       
			AND AD_ID  in (select AD_ID from dbo.T0050_AD_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 0 And Charindex(@Strmonth,Ad_Effect_Month )<> 0)           

-- Added by rohit for allowance that not effect on gross salary but calculate in net salary on 06-may-2013
 SELECT @Deduct_Amount_Effect_only_Net = SUM(ISNULL(M_AD_AMOUNT,0)) + SUM(ISNULL(M_AREAR_AMOUNT,0)) +SUM(ISNULL(M_AREAR_AMOUNT_Cutoff ,0)) From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)      
		WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='D'  and Cmp_Id=@Cmp_ID      
			AND AD_ID in (select AD_ID from dbo.T0050_AD_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 1 and isnull(Effect_Net_Salary,0)=1)
-- Rohit On 06-may-2013			

	SET  @Allow_Amount = isnull(@Allow_Amount,0) + isnull(@Temp_Allowance,0)
	SET  @Allow_Amount_Arear = isnull(@Allow_Amount_Arear,0) + isnull(@Temp_Allowance_Arear,0) --Hardik 07/01/2012
	SET @Dedu_Amount = isnull(@Dedu_Amount,0) + isnull(@Temp_Deduction,0)      
	SET @Dedu_Amount_Arear = isnull(@Dedu_Amount_Arear,0) + isnull(@Temp_Deduction_Arear,0)      --Hardik 07/01/2012
	SET @Dedu_Amount = isnull(@Dedu_Amount,0)			
	SET @Allow_Amount = isnull(@Allow_Amount,0)      
	SET @Allow_Amount_Arear = isnull(@Allow_Amount_Arear,0)    --Hardik 07/01/2012
	SET @Dedu_Amount_Arear = isnull(@Dedu_Amount_Arear,0)			--Hardik 07/01/2012
 
 
 ----Change by Falak on 29-OCT-2010 --------------------------------------------
 
	DECLARE @IS_Bonus_EFf_Sal numeric(1,0)
	SELECT @Bonus_Amount	 = isnull(Bonus_Amount,0),@IS_Bonus_Eff_Sal = Bonus_Effect_On_Sal from dbo.T0180_bonus WITH (NOLOCK) where Emp_Id =@Emp_ID and Bonus_Effect_Month =Month(@Month_End_Date) and Bonus_Effect_Year =Year(@Month_End_Date) and Bonus_Effect_on_Sal = 1
	--Added by Mukti(09102017)start	
	SELECT @Bonus_Amount = isnull(Total_Bonus_Amount,0),@IS_Bonus_Eff_Sal = Bonus_Effect_On_Sal from dbo.T0100_Bonus_Slabwise WITH (NOLOCK) where Emp_Id =@Emp_ID and Bonus_Effect_Month =Month(@Month_End_Date) and Bonus_Effect_Year =Year(@Month_End_Date) and Bonus_Effect_on_Sal = 1
	--Added by Mukti(09102017)end
--------------------------------------------------------------------------       
       
IF EXISTS (Select Sal_Tran_Id from dbo.T0200_MONTHLY_SALARY WITH (NOLOCK) Where Emp_ID =@Emp_Id And Cmp_ID=@Cmp_ID And Month_St_Date=@Month_St_Date And Month_End_Date =@Month_End_Date )
	BEGIN	
	  SELECT @Advance_Amount =  round( isnull(Advance_amount,0),0) from dbo.T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_id = @Emp_id And cmp_Id=@Cmp_ID  And Month_St_Date=@Month_St_Date And Month_End_Date =@Month_End_Date 
	END
ELSE 
	BEGIN
		SELECT @Advance_Amount =  round( isnull(Adv_closing,0),0) from dbo.T0140_Advance_Transaction WITH (NOLOCK) where emp_id = @emp_id and Cmp_ID = @Cmp_ID      
		 AND for_date = (select max(for_date) from dbo.T0140_Advance_Transaction WITH (NOLOCK) where emp_id = @emp_id and Cmp_ID = @Cmp_ID      
		 AND for_date <=  @Month_End_Date) 
END
       
 IF @Advance_Amount < 0      
  SET @Advance_Amount = 0      
  
 IF @Advance_Amount = 0	--Ankit 18102014
	  SET @M_ADV_AMOUNT = 0
   
 --SET @Advance_Amount = ISNULL(@Advance_Amount,0)  +  @Update_Adv_Amount  + ISNULL(@M_ADV_AMOUNT,0)  
 
 --added By Mukti(start)20012015
	-- if @M_ADV_AMOUNT > 0   --Added By ankit 19062013
	--set @Advance_Amount=@M_ADV_AMOUNT

  if @Advance_Amount > @M_ADV_AMOUNT
	begin
		set @Advance_Amount=@M_ADV_AMOUNT
	end
 else 
	begin
		set	@Advance_Amount=@Advance_Amount
	end
 --added By Mukti(end)20012015 
	
--Ankit 18102014 --
	SELECT @Due_Loan_Amount = ISNULL(SUM(Loan_Closing),0) from dbo.T0140_LOAN_TRANSACTION  LT WITH (NOLOCK) INNER JOIN       
	  (SELECT MAX(FOR_DATE) AS FOR_dATE , LOAN_ID ,EMP_ID from dbo.T0140_LOAN_TRANSACTION WITH (NOLOCK)  WHERE EMP_iD = @EMP_ID AND CMP_ID = @CMP_ID      
	   AND FOR_DATE <=@Month_end_Date and Is_Loan_Interest_Flag = 0    
	   GROUP BY EMP_id ,LOAN_ID ) AS QRY  ON QRY.LOAN_ID  = LT.LOAN_ID      
	   AND QRY.FOR_DATE = LT.FOR_DATE       
	   AND QRY.EMP_ID = LT.EMP_ID 
	Where Is_Loan_Interest_Flag = 0 --Added by nilesh patel on 23072015

	IF ISNULL(@Due_Loan_Amount,0) = 0
		SET @M_LOAN_AMOUNT = 0
--Ankit 18102014 --
     
INSERT INTO #Loan_Due_Amount(Emp_ID,Loan_ID,Loan_Closing)
 								 SELECT  LT.Emp_ID,LT.Loan_ID,Loan_CLosing
								  from dbo.T0140_LOAN_TRANSACTION  LT WITH (NOLOCK) INNER JOIN       
									  (SELECT MAX(FOR_DATE) AS FOR_dATE , LOAN_ID ,EMP_ID from dbo.T0140_LOAN_TRANSACTION  WITH (NOLOCK)
									  WHERE EMP_iD = @emp_Id AND CMP_ID = @Cmp_ID      
									   AND FOR_DATE <= @Month_end_Date and Is_Loan_Interest_Flag = 0
									   GROUP BY EMP_id ,LOAN_ID ) AS QRY  ON QRY.LOAN_ID  = LT.LOAN_ID      
									   AND QRY.FOR_DATE = LT.FOR_DATE       
									   AND QRY.EMP_ID = LT.EMP_ID
									   INNER JOIN T0040_LOAN_MASTER LM WITH (NOLOCK) On LM.Loan_ID = LT.Loan_ID
									   Where Is_Loan_Interest_Flag = 0 and LM.Is_Principal_First_than_Int = 1  
								   
--Added by nilesh patel on 16072015 -start 
--if FLOOR(@Due_Loan_Amount) = 0
if Exists(SELECT 1 From #Loan_Due_Amount where Loan_Closing = 0 AND Emp_Id = @emp_Id )
	Begin
		EXEC SP_CALCULATE_LOAN_INTEREST_PAYMENT @Cmp_ID ,@emp_Id,@tmp_Month_St_Date,@tmp_Month_End_Date,@Sal_Tran_ID
	End
	

If Isnull(@Loan_Amount,0) = 0 And Exists(Select 1 From T0120_LOAN_APPROVAL LA WITH (NOLOCK) Inner join T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA.Loan_ID = LM.Loan_ID WHERE isnull(LM.Is_Intrest_Amount_As_Perquisite_IT,0) = 0 and LA.Loan_Apr_Pending_Amount > 0 and LA.Emp_ID = @emp_Id) --- Added condition by Hardik 01/10/2020 for Gift City Case
	Begin
		EXEC SP_CALCULATE_LOAN_PAYMENT @Cmp_ID ,@emp_Id,@tmp_Month_St_Date,@tmp_Month_End_Date,@Sal_Tran_ID,@M_LOAN_AMOUNT,@IS_LOAN_DEDU
	End

 if Isnull(@Loan_Amount,0) = 0 And Exists(Select 1 From T0120_LOAN_APPROVAL LA WITH (NOLOCK) Inner join T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA.Loan_ID = LM.Loan_ID WHERE isnull(LM.Is_Intrest_Amount_As_Perquisite_IT,0) = 1 and LA.Loan_Apr_Pending_Amount > 0 and LA.Emp_ID = @emp_Id)  --- Added condition by Hardik 01/10/2020 for Gift City Case	
	BEGIN
		EXEC dbo.SP_CALCULATE_LOAN_PAYMENT_INT_PERQUISITE @Cmp_ID ,@emp_Id,@tmp_Month_St_Date,@tmp_Month_End_Date,@Sal_Tran_ID,@M_LOAN_AMOUNT,@IS_LOAN_DEDU    
	End	 
	

 DECLARE @Is_First_Ded_Principal_Amt Numeric(18,0)
 select @Is_First_Ded_Principal_Amt = LM.Is_Principal_First_than_Int from T0210_Monthly_Loan_Payment LP WITH (NOLOCK) inner join 
 T0120_LOAN_APPROVAL LA WITH (NOLOCK) on LA.Loan_Apr_ID = LP.Loan_Apr_ID inner JOIN
 T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA.Loan_ID = LM.Loan_ID
 WHERE LP.Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID
 
 
 if @Is_First_Ded_Principal_Amt = 1 
	Begin
		 
		 SELECT @Loan_Amount = ISNULL(SUM(Loan_Pay_Amount),0),@Loan_Interest_Amount = 0 from dbo.T0210_Monthly_Loan_Payment LP WITH (NOLOCK)
		 Inner join (		-- Changed by Gadriwala Muslim 25122014
						select LA.Loan_ID,LP.Loan_Apr_ID from T0210_Monthly_Loan_Payment LP WITH (NOLOCK) inner join
						T0120_LOAN_APPROVAL LA WITH (NOLOCK) on LA.Loan_Apr_ID = LP.Loan_Apr_ID
						WHERE LP.Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID 
		   			) Qry on Qry.Loan_Apr_ID = LP.Loan_Apr_ID  
		 Inner join T0040_LOAN_MASTER LM WITH (NOLOCK) on LM.Loan_ID = Qry.LOAN_ID and LM.Is_Interest_Subsidy_Limit = 0
		 WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID and LP.Is_Loan_Interest_Flag = 0
		 
		--if FLOOR(@Due_Loan_Amount) = 0 
		if Exists(SELECT 1 From #Loan_Due_Amount where Loan_Closing = 0 AND Emp_Id = @emp_Id ) 
			Begin
				SELECT @Loan_Interest_Amount = ISNULL(Sum(Interest_Amount),0) from dbo.T0210_Monthly_Loan_Payment LP WITH (NOLOCK)
				 Inner join (		-- Changed by Gadriwala Muslim 25122014
								select LA.Loan_ID,LP.Loan_Apr_ID from T0210_Monthly_Loan_Payment LP WITH (NOLOCK) inner join
								T0120_LOAN_APPROVAL LA WITH (NOLOCK) on LA.Loan_Apr_ID = LP.Loan_Apr_ID
								inner JOIN #Loan_Due_Amount LDA ON LDA.Emp_ID = LA.Emp_ID and LDA.Loan_ID = LA.Loan_ID
								WHERE LP.Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID and LDA.Loan_Closing = 0
		   					) Qry on Qry.Loan_Apr_ID = LP.Loan_Apr_ID  
				 Inner join T0040_LOAN_MASTER LM WITH (NOLOCK) on LM.Loan_ID = Qry.LOAN_ID and LM.Is_Interest_Subsidy_Limit = 0
				 WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID and LP.Is_Loan_Interest_Flag = 1
				 
			End
	End    
 Else
	Begin
		SELECT @Loan_Amount = ISNULL(SUM(Loan_Pay_Amount),0) from dbo.T0210_Monthly_Loan_Payment LP WITH (NOLOCK)
		 Inner join (		-- Changed by Gadriwala Muslim 25122014
						select LA.Loan_ID,LP.Loan_Apr_ID from T0210_Monthly_Loan_Payment LP WITH (NOLOCK) inner join
						T0120_LOAN_APPROVAL LA WITH (NOLOCK) on LA.Loan_Apr_ID = LP.Loan_Apr_ID
						WHERE LP.Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID 
		   			) Qry on Qry.Loan_Apr_ID = LP.Loan_Apr_ID  
		 Inner join T0040_LOAN_MASTER LM WITH (NOLOCK) on LM.Loan_ID = Qry.LOAN_ID and LM.Is_Interest_Subsidy_Limit = 0
		 WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID 
		 
		 
		 SELECT @Loan_Interest_Amount = ISNULL(Sum(Interest_Amount),0) from dbo.T0210_Monthly_Loan_Payment LP WITH (NOLOCK)
		 Inner join (		-- Changed by Gadriwala Muslim 25122014
						select LA.Loan_ID,LP.Loan_Apr_ID from T0210_Monthly_Loan_Payment LP WITH (NOLOCK) inner join
						T0120_LOAN_APPROVAL LA WITH (NOLOCK) on LA.Loan_Apr_ID = LP.Loan_Apr_ID
						WHERE LP.Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID 
		   			) Qry on Qry.Loan_Apr_ID = LP.Loan_Apr_ID  
		 Inner join T0040_LOAN_MASTER LM WITH (NOLOCK) on LM.Loan_ID = Qry.LOAN_ID and LM.Is_Interest_Subsidy_Limit = 0
		 WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID and LM.Is_Principal_First_than_Int = 0 and Isnull(LM.Is_Intrest_Amount_As_Perquisite_IT,0) = 0
		 
		 if Exists(SELECT 1 From #Loan_Due_Amount where Loan_Closing = 0 AND Emp_Id = @emp_Id ) 
			Begin
				
				SELECT @Loan_Interest_Amount = @Loan_Interest_Amount + ISNULL(Sum(Interest_Amount),0) from dbo.T0210_Monthly_Loan_Payment LP WITH (NOLOCK)
				 Inner join (		-- Changed by Gadriwala Muslim 25122014
								select LA.Loan_ID,LP.Loan_Apr_ID from T0210_Monthly_Loan_Payment LP WITH (NOLOCK) inner join
								T0120_LOAN_APPROVAL LA WITH (NOLOCK) on LA.Loan_Apr_ID = LP.Loan_Apr_ID 
								inner JOIN #Loan_Due_Amount LDA ON LDA.Emp_ID = LA.Emp_ID and LDA.Loan_ID = LA.Loan_ID
								WHERE LP.Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID and LDA.Loan_Closing = 0
		   					) Qry on Qry.Loan_Apr_ID = LP.Loan_Apr_ID  
				 Inner join T0040_LOAN_MASTER LM WITH (NOLOCK) on LM.Loan_ID = Qry.LOAN_ID and LM.Is_Interest_Subsidy_Limit = 0
				 WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID and LM.Is_Principal_First_than_Int = 1
			End
	End 
	
	if Exists(SELECT 1 FROM T0100_Uniform_Emp_Issue WITH (NOLOCK) where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID and (Deduct_Pending_Amount > 0 or (Refund_Pending_Amount >0 and Deduct_Pending_Amount = 0)))
		Begin		
			Exec SP_CALCULATE_UNIFORM_PAYMENT @Cmp_ID ,@emp_Id,@tmp_Month_St_Date,@tmp_Month_End_Date,@Sal_Tran_ID
		End
	
	SELECT @Uniform_Deduction_Amount = ISNULL(SUM(Payment_Amount),0) from dbo.T0210_Uniform_Monthly_Payment UMP WITH (NOLOCK)
	WHERE UMP.Sal_Tran_ID = @Sal_Tran_ID and UMP.Cmp_Id=@Cmp_ID and UMP.Uni_Flag = 0
	
	SELECT @Uniform_Refund_Amount = ISNULL(SUM(Payment_Amount),0) from dbo.T0210_Uniform_Monthly_Payment UMP WITH (NOLOCK)
	WHERE UMP.Sal_Tran_ID = @Sal_Tran_ID and UMP.Cmp_Id=@Cmp_ID and UMP.Uni_Flag = 1
	
 --Added by nilesh patel on 16072015 -End 
 

  
 --Comment by nilesh patel on 29072015 --start        
 --SELECT @Loan_Amount = ISNULL(SUM(Loan_Pay_Amount),0),@Loan_Interest_Amount= ISNULL(Sum(Interest_Amount),0) from dbo.T0210_Monthly_Loan_Payment LP
 --Inner join (		-- Changed by Gadriwala Muslim 25122014
	--			select LA.Loan_ID,LP.Loan_Apr_ID from T0210_Monthly_Loan_Payment LP inner join
	--			T0120_LOAN_APPROVAL LA on LA.Loan_Apr_ID = LP.Loan_Apr_ID
	--			WHERE LP.Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID 
	--	   	) Qry on Qry.Loan_Apr_ID = LP.Loan_Apr_ID  
 --Inner join T0040_LOAN_MASTER LM on LM.Loan_ID = Qry.LOAN_ID and LM.Is_Interest_Subsidy_Limit = 0
 --WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID       
 --Comment by nilesh patel on 29072015 --End
 
 -- Added by Gadriwala Muslim 26122014 - Start
  Declare @Interest_Subsidy_Amount as NUMERIC(18, 4)
  
  select @Interest_Subsidy_Amount = Isnull(Sum(Interest_subsidy_Amount),0) from dbo.T0210_Monthly_Loan_Payment LP WITH (NOLOCK)
 Inner join (
				select LA.Loan_ID,LP.Loan_Apr_ID from T0210_Monthly_Loan_Payment LP WITH (NOLOCK) inner join
				T0120_LOAN_APPROVAL LA WITH (NOLOCK) on LA.Loan_Apr_ID = LP.Loan_Apr_ID
				where Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID 
		   	) Qry on Qry.Loan_Apr_ID = LP.Loan_Apr_ID  
 Inner join T0040_LOAN_MASTER LM WITH (NOLOCK) on LM.Loan_ID = Qry.LOAN_ID and LM.Is_Interest_Subsidy_Limit = 1
 WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID    
 
 Update T0210_MONTHLY_AD_DETAIL set M_AD_Amount = isnull(@Interest_Subsidy_Amount,0)
	 From T0210_MONTHLY_AD_DETAIL AD inner join 
	 T0050_AD_MASTER AM on AD.AD_ID = AM.AD_ID and AM.AD_CALCULATE_ON = 'Interest Subsidy'  
	 where Temp_Sal_Tran_ID = @Sal_Tran_ID  and AD.Cmp_ID =@Cmp_ID
	  
	 set @Allow_Amount = isnull(@Allow_Amount,0) +  isnull(@Interest_Subsidy_Amount,0)
	  -- Added by Gadriwala Muslim 26122014 - End 
   
   --Added by Gadriwala Muslim 15042015 - Start
   
		declare @Warning_Deduct_Amount as NUMERIC(18, 4)
		set @Warning_Deduct_Amount = 0
		
		exec calculate_Emp_Warning_deduction @cmp_ID,@Emp_Id,@Month_St_Date,@Month_End_Date,@Day_Salary,@Warning_Deduct_Amount output
		
		If @ROUNDING = 1
			Begin
					Update T0210_MONTHLY_AD_DETAIL set M_AD_Amount = Round(isnull(@Warning_Deduct_Amount,0),0)
					From T0210_MONTHLY_AD_DETAIL AD inner join 
					T0050_AD_MASTER AM on AD.AD_ID = AM.AD_ID and AM.AD_CALCULATE_ON = 'warning deduction'  
					where Temp_Sal_Tran_ID = @Sal_Tran_ID  and AD.Cmp_ID =@Cmp_ID
			end
		else
			begin
				Update T0210_MONTHLY_AD_DETAIL set M_AD_Amount = isnull(@Warning_Deduct_Amount,0)
					From T0210_MONTHLY_AD_DETAIL AD inner join 
					T0050_AD_MASTER AM on AD.AD_ID = AM.AD_ID and AM.AD_CALCULATE_ON = 'warning deduction'  
					where Temp_Sal_Tran_ID = @Sal_Tran_ID  and AD.Cmp_ID =@Cmp_ID
			end
		 --set @Due_Loan_Amount = 0
		
	set @Dedu_Amount = ISNULL(@dedu_amount,0) + isnull(@Warning_Deduct_Amount,0) 
	
	 --- BOND DEDUCTION PORTION START ADDED BY RAJPUT ON 10102018 ----
	 
	IF (@ALLOW_NEGATIVE_SAL = 1)
		BEGIN
			IF @IS_Bond_Dedu = 1
				BEGIN
					
					IF ISNULL(@BOND_AMOUNT,0) = 0 
						EXEC dbo.SP_CALCULATE_BOND_PAYMENT @CMP_ID ,@EMP_ID,@TMP_MONTH_ST_DATE,@TMP_MONTH_END_DATE,@SAL_TRAN_ID,@IS_BOND_DEDU  


					SELECT @BOND_AMOUNT = ISNULL(SUM(BOND_PAY_AMOUNT),0) FROM DBO.T0210_MONTHLY_BOND_PAYMENT BP WITH (NOLOCK)
					 INNER JOIN (	
									SELECT BA.BOND_ID,BP.BOND_APR_ID FROM T0210_MONTHLY_BOND_PAYMENT BP WITH (NOLOCK) INNER JOIN
									T0120_BOND_APPROVAL BA WITH (NOLOCK) ON BA.BOND_APR_ID = BP.BOND_APR_ID
									WHERE BP.SAL_TRAN_ID = @SAL_TRAN_ID AND BP.CMP_ID=@CMP_ID 
								) QRY ON QRY.BOND_APR_ID = BP.BOND_APR_ID  
					 INNER JOIN T0040_BOND_MASTER BM WITH (NOLOCK) ON BM.BOND_ID = QRY.BOND_ID --AND BM.IS_INTEREST_SUBSIDY_LIMIT = 0
					 WHERE SAL_TRAN_ID = @SAL_TRAN_ID AND BP.CMP_ID=@CMP_ID
				END
		END
		
	---- END -----
    
						--Added by Gadriwala Muslim 15042015 - End
	 
   -- Added by Gadriwala Muslim 26122014 - End  
  --SET @Due_Loan_Amount = 0   

	

  --SELECT @Due_Loan_Amount = ISNULL(SUM(Loan_Closing),0) from dbo.T0140_LOAN_TRANSACTION  LT INNER JOIN       
  --(SELECT MAX(FOR_DATE) AS FOR_dATE , LOAN_ID ,EMP_ID from dbo.T0140_LOAN_TRANSACTION  WHERE EMP_iD = @EMP_ID AND CMP_ID = @CMP_ID      
  -- AND FOR_DATE <=@Month_end_Date      
  -- GROUP BY EMP_id ,LOAN_ID ) AS QRY  ON QRY.LOAN_ID  = LT.LOAN_ID      
  -- AND QRY.FOR_DATE = LT.FOR_DATE       
  -- AND QRY.EMP_ID = LT.EMP_ID      
       
 --EXEC SP_CALCULATE_CLAIM_PAYMENT @Cmp_ID ,@emp_Id,@Month_End_Date,@Sal_Tran_ID,0,1,@ROUNDING    
       
 --SELECT @Total_Claim_Amount  = ISNULL(SUM(Claim_Pay_Amount),0) from dbo.T0210_Monthly_Claim_Payment WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
 -- select @Total_Claim_Amount=ISNULL(SUM(Claim_Closing),0) from T0140_CLAIM_TRANSACTION AS CT INNER JOIN T0130_CLAIM_APPROVAL_DETAIL AS CAD ON CAD.Claim_Apr_Date = CT.For_Date  INNER JOIN T0120_CLAIM_APPROVAL AS CA ON CA.Claim_Apr_ID = CAD.Claim_Apr_ID  and Ct.Emp_ID=Ca.emp_id and Ct.Claim_ID=CAD.Claim_ID where CT.cmp_id=@Cmp_ID and CT.Emp_ID=@emp_ID and CA.Claim_Apr_Date<=@Month_End_Date and CA.Claim_Apr_Date>=@Month_St_Date
 
 
			  

 SELECT 	@TOTAL_CLAIM_AMOUNT=ISNULL(SUM(CLAIM_CLOSING),0) -- ADDED BY RAJPUT ON 05032019
			FROM 	T0140_CLAIM_TRANSACTION AS CT WITH (NOLOCK)
			INNER JOIN ( SELECT DISTINCT CLAIM_APR_ID,CLAIM_ID,CLAIM_APR_DATE,CMP_ID FROM T0130_CLAIM_APPROVAL_DETAIL WITH (NOLOCK) ) CAD ON CAD.CLAIM_APR_DATE = CT.FOR_DATE  
			INNER JOIN T0120_CLAIM_APPROVAL AS CA WITH (NOLOCK) ON CA.CLAIM_APR_ID = CAD.CLAIM_APR_ID AND CT.EMP_ID=CA.EMP_ID AND CT.CLAIM_ID=CAD.CLAIM_ID 
			INNER JOIN T0040_CLAIM_MASTER CLM WITH (NOLOCK) ON CLM.CLAIM_ID=CAD.CLAIM_ID AND CLM.CMP_ID=CAD.CMP_ID 
			left join T0050_AD_MASTER ADM WITH (NOLOCK) on ADm.Claim_ID = CAd.Claim_ID   --Added by Jaina 30-10-2020
			WHERE CT.CMP_ID=@CMP_ID AND CT.EMP_ID=@EMP_ID AND CA.CLAIM_APR_DATE<=@MONTH_END_DATE AND CA.CLAIM_APR_DATE>=@MONTH_ST_DATE AND CLM.CLAIM_APR_DEDUCT_FROM_SAL=1
			  and  ADM.Claim_ID is null  --Added by Jaina 30-10-2020
		
	
-----Added by Rohit on  24082015------------------------------------------------------------------
set @Travel_Advance_Amount = 0 
set @Travel_Amount = 0  

--select @Travel_Advance_Amount=isnull(SUM(Advance_amount),0),@Travel_Amount = isnull(sum(Approved_Expance),0)  from T0150_Travel_Settlement_Approval
--where emp_id=@Emp_Id and cmp_id=@Cmp_ID and   Effect_Salary_date<=@Month_End_Date and Effect_Salary_date>=@Month_St_Date and isnull(Travel_Amt_in_salary,0)=1 and is_apr=1  --Added by Sumit 18082015
select @Travel_Advance_Amount=isnull(SUM(Advance_amount),0),@Travel_Amount = isnull((sum(isnull(Approved_Expance,0)+ISNULL(QRY.TravelAllowance,0))),0)  from T0150_Travel_Settlement_Approval TSA WITH (NOLOCK)
inner join 
(		
	select SUM(TravelAllowance) as TravelAllowance,Emp_ID,Travel_Set_Application_id 
	from T0140_Travel_Settlement_Expense WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_Id	
	Group by Emp_ID,Travel_Set_Application_id
) Qry on Qry.Travel_Set_Application_id=TSA.Travel_Set_Application_id and Qry.Emp_ID=TSA.emp_id
where TSA.emp_id=@Emp_Id and cmp_id=@Cmp_ID and  Effect_Salary_date<=@Month_End_Date and Effect_Salary_date>=@Month_St_Date and isnull(Travel_Amt_in_salary,0)=1 and is_apr=1 --Added by Sumit 18082015
---------------------------------------------------------------------	
---------------------------------------------------------------------		
 
 
 if @Total_Claim_Amount >0
	 begin
		exec SP_CALCULATE_CLAIM_TRANSACTION @Cmp_Id,@Emp_Id,@Month_St_Date,0,@Month_St_Date,@Month_End_Date,@ROUNDING,'I'

		UPDATE CT
		SET CT.Salary_Tran_ID=@Sal_Tran_ID
		FROM T0140_CLAIM_TRANSACTION AS CT 
		INNER JOIN ( SELECT DISTINCT CLAIM_APR_ID,CLAIM_ID,CLAIM_APR_DATE,CMP_ID FROM T0130_CLAIM_APPROVAL_DETAIL ) CAD ON CAD.CLAIM_APR_DATE = CT.FOR_DATE  
		INNER JOIN T0120_CLAIM_APPROVAL AS CA ON CA.CLAIM_APR_ID = CAD.CLAIM_APR_ID AND CT.EMP_ID=CA.EMP_ID AND CT.CLAIM_ID=CAD.CLAIM_ID 
		INNER JOIN T0040_CLAIM_MASTER CLM ON CLM.CLAIM_ID=CAD.CLAIM_ID AND CLM.CMP_ID=CAD.CMP_ID 
		left join T0050_AD_MASTER ADM on ADm.Claim_ID = CAd.Claim_ID   
		WHERE CT.CMP_ID=@CMP_ID AND CT.EMP_ID=@EMP_ID AND CA.CLAIM_APR_DATE<=@MONTH_END_DATE AND CA.CLAIM_APR_DATE>=@MONTH_ST_DATE 
		AND CLM.CLAIM_APR_DEDUCT_FROM_SAL=1 and  ADM.Claim_ID is Null
	 end
   
 SELECT @Settelement_Amount = ISNULL(SUM(S_Net_Amount),0) from dbo.T0201_Monthly_Salary_Sett WITH (NOLOCK) WHERE emp_ID =@Emp_ID AND MONTH(S_Eff_Date) =MONTH(@Month_End_Date) AND YEAR(S_Eff_Date) =YEAR(@Month_End_Date) AND isnull(Effect_On_Salary,0) = 1     


--Added By Mukti 25032015(start)
	  SELECT  @TotASSET_Closing=ISNULL(SUM(ASSET_Closing),0) from dbo.t0140_asset_transaction  LT WITH (NOLOCK) INNER JOIN       
	  (SELECT MAX(FOR_DATE) AS FOR_dATE , AssetM_ID ,EMP_ID from dbo.t0140_asset_transaction  WITH (NOLOCK)
	   WHERE EMP_iD = @emp_id AND CMP_ID = @Cmp_ID 
	   AND FOR_DATE <= @Month_end_Date      
	   GROUP BY EMP_id ,AssetM_ID ) AS QRY  ON QRY.AssetM_ID  = LT.AssetM_ID      
	   AND QRY.FOR_DATE = LT.FOR_DATE       
	   AND QRY.EMP_ID = LT.EMP_ID
	
		if @TotASSET_Closing >0
			begin   
				EXEC SP_CALCULATE_ASSET_PAYMENT @Cmp_ID,@emp_Id,@Month_End_Date,@Sal_Tran_ID  
				SELECT @Asset_Installment  = ISNULL(SUM(Receive_Amount),0) from dbo.t0140_asset_transaction WITH (NOLOCK) WHERE Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID      
			 end
--Added By Mukti 25032015(end)



IF CHARINDEX('Ambuja',@cmp_Name,1) = 1 
			Begin      
				Select @Leave_Encash_Day=Lv_Encash_Apr_Days from Dbo.T0120_Leave_Encash_Approval WITH (NOLOCK) Where Month(Lv_Encash_Apr_Date) = Month(@Month_End_Date)  And Year(Lv_Encash_Apr_Date)=Year(@Month_End_Date) And Cmp_ID = @Cmp_id And Emp_Id=@Emp_Id And Lv_Encash_Apr_Status='A'							
				If @Leave_Encash_Day<>0
					Begin 
						 Set @Leave_Salary_Amount =(((@Basic_Salary_Org*12)/365)*@Leave_Encash_Day)
					
					
					If Exists(Select L_Sal_Tran_Id From Dbo.T0200_Monthly_Salary_Leave WITH (NOLOCK) Where Emp_Id=@Emp_Id And Cmp_Id=@Cmp_Id And L_Month_St_Date = @Month_St_Date)
					Begin
							UPDATE  T0200_MONTHLY_SALARY_LEAVE
						SET		Increment_ID = @Increment_ID, 
								L_Month_St_Date = @Month_St_Date, L_Month_End_Date = @Month_End_Date, L_Sal_Generate_Date = @Sal_Generate_Date,
								L_Sal_Cal_Days = @Leave_Encash_Day, L_Working_Days = @Working_Days, 
								L_Outof_Days = @Outof_Days,L_Shift_Day_Sec = @Shift_Day_Sec, L_Shift_Day_Hour = @Shift_Day_Hour, L_Basic_Salary = @Basic_Salary, 
								L_Day_Salary = @Day_Salary, L_Hour_Salary = @Hour_Salary, L_Salary_Amount = @Salary_Amount, L_Allow_Amount = @Allow_Amount, 
								L_Other_Allow_Amount = @Other_Allow_Amount, L_Gross_Salary = @Gross_Salary, L_Dedu_Amount = @Dedu_Amount, 
								L_Loan_Amount = @Loan_Amount, L_Loan_Intrest_Amount = @Loan_Interest_Amount, L_Advance_Amount = @Advance_Amount, 
								L_Other_Dedu_Amount = @Other_Dedu_Amount, L_Total_Dedu_Amount = @Total_Dedu_Amount, L_Due_Loan_Amount = @Due_Loan_Amount, 
								L_Net_Amount = @Leave_Salary_Amount ,L_PT_Amount = @PT_Amount,L_PT_Calculated_Amount = @PT_Calculated_Amount
								,L_M_IT_Tax = @M_IT_Tax , L_M_Loan_Amount = @M_Loan_Amount ,L_M_Adv_Amount = @M_Adv_Amount
								,L_LWF_Amount = @LWF_Amount , L_Revenue_Amount = @Revenue_Amount ,L_PT_F_T_LIMIT = @PT_F_T_LIMIT
								,L_Actually_Gross_Salary = @Gross_Salary_ProRata
						WHERE EMP_ID = @EMP_ID And Cmp_Id=@Cmp_Id And L_Month_St_Date = @Month_St_Date
					End
					Else
						Begin 
						
						Select @L_Sal_Tran_ID =  Isnull(max(L_Sal_Tran_ID),0)  + 1   from dbo.T0200_MONTHLY_SALARY_LEAVE WITH (NOLOCK)
						
						 INSERT INTO T0200_MONTHLY_SALARY_LEAVE
			                      (L_Sal_Tran_ID, L_Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, L_Month_St_Date, L_Month_End_Date, L_Sal_Generate_Date, L_Sal_Cal_Days, 
			                      L_Working_Days, L_Outof_Days, L_Shift_Day_Sec, L_Shift_Day_Hour, L_Basic_Salary, L_Day_Salary, L_Hour_Salary, L_Salary_Amount, 
			                      L_Allow_Amount, L_Other_Allow_Amount, L_Gross_Salary, L_Dedu_Amount, L_Loan_Amount, L_Loan_Intrest_Amount, L_Advance_Amount, 
			                      L_Other_Dedu_Amount, L_Total_Dedu_Amount, L_Due_Loan_Amount, L_Net_Amount, L_Actually_Gross_Salary, L_PT_Amount, 
			                      L_PT_Calculated_Amount, L_M_Adv_Amount, L_M_Loan_Amount, L_M_IT_Tax, L_LWF_Amount, L_Revenue_Amount, L_PT_F_T_Limit, L_Sal_Type, 
			                      L_Eff_Date, Login_ID, Modify_Date,IS_FNF,SAL_TRAN_ID)
					VALUES     (@L_Sal_Tran_ID,@Sal_Receipt_No,@Emp_ID,@Cmp_ID,@Increment_ID,@Month_St_Date,@Month_End_Date,@Sal_Generate_Date,@Leave_Encash_Day,0,0,0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,@Leave_Salary_Amount,0,0,0,0,0,0,0,0,'',0,@Month_End_Date,@Login_ID,'',0,@SAL_TRAN_ID)					
					End
			
					End				
			End        
		Else
			Begin
				-- Changed by Hardik 07/09/2012
				--- Weekoff and Holiday Parameter passed from here
				
				Exec dbo.P0200_MONTHLY_SALARY_GENERATE_LEAVE 0,@Emp_ID,@Cmp_ID,@Sal_Generate_Date,@Month_St_Date,@Month_end_Date,0,0,0,0,0,0,@Login_ID,'N','N',0,@Month_End_Date,0,@SAL_TRAN_ID,@StrWeekoff_Date,@Weekoff_Days,@Cancel_Weekoff,@StrHoliday_Date,@Holiday_days,@Cancel_Holiday

				-- declare @Leave_Salary numeric(22,2)
				Declare @Leave_GRoss_Salary numeric(22,2)				
				-- select @Leave_Salary = isnull(sum(L_Net_Amount),0) from dbo.T0200_MONTHLY_SALARY_LEAVE Where Emp_ID=@Emp_ID and isnull(Is_FNF,0) =0 and L_eff_Date >=@Month_St_Date and L_Eff_date <=@Month_end_Date
				--SELECT @Leave_Salary_Amount = ISNULL(SUM(L_Net_Amount),0) from dbo.T0200_Monthly_Salary_Leave WHERE emp_ID =@Emp_ID AND MONTH(L_Eff_Date) =MONTH(@Month_End_Date)  AND YEAR(L_Eff_Date) =YEAR(@Month_End_Date)

				SELECT @Leave_Salary_Amount = ISNULL(SUM(L_Net_Amount),0),@Leave_GRoss_Salary = sum(isnull(L_Actually_Gross_Salary,0)) from dbo.T0200_Monthly_Salary_Leave WITH (NOLOCK)
				WHERE emp_ID =@Emp_ID AND MONTH(L_Eff_Date) =MONTH(@Month_End_Date)  AND YEAR(L_Eff_Date) =YEAR(@Month_End_Date)
						AND Sal_tran_ID = @SAL_TRAN_ID	--Ankit 04042016
			
			End	
  
	--set @Leave_Salary_Amount = isnull(@Leave_Salary_Amount,0) + isnull(@Leave_Salary,0)
    --select @LEave_Salary_Amount,@leave_Gross_Salary
    --Change done by Falak on 17-FEB-2011
    
    If @Lv_Encash_Cal_On = 'Gross'
		set @Leave_Salary_Amount = @Leave_GRoss_Salary    
		
		
	
 --if @Is_OT_Inc_Salary =1       
  --Set @Gross_Salary = @Salary_Amount + @Allow_Amount + @Other_Allow_Amount + @Total_Claim_Amount  + @OT_Amount + @Bonus_Amount      
 --else      
  --Set @Gross_Salary = @Salary_Amount + @Allow_Amount + @Other_Allow_Amount + @Total_Claim_Amount   + @Bonus_Amount
 
 /*  --Commented by Falak on 12-MAY-2011 
 DECLARE @AREAR_SALARY AS NUMERIC(18,0)
 DECLARE @AREAR_CLAIM  AS NUMERIC(18,0)
 DECLARE @AREAR_OT	   AS NUMERIC(18,0)
 DECLARE @AREAR_BONUS  AS NUMERIC(18,0)
 
 SET  @AREAR_SALARY =0
 SET  @AREAR_CLAIM  =0
 SET  @AREAR_OT =0
 SET  @AREAR_BONUS =0
 
 
 SET @AREAR_SALARY = ROUND(@Salary_Amount		 *   @Other_Allow_Amount/@OutOF_days,0)
 SET @AREAR_CLAIM =  ROUND(@Total_Claim_Amount   *   @Other_Allow_Amount/@OutOF_days,0)
 SET @AREAR_OT =	 ROUND(@OT_Amount            *   @Other_Allow_Amount/@OutOF_days,0)
 SET @AREAR_BONUS =	 ROUND(@Bonus_Amount         *   @Other_Allow_Amount/@OutOF_days,0)
 
 SET @Salary_Amount			= @Salary_Amount         + @AREAR_SALARY
 SET @Total_Claim_Amount	= @Total_Claim_Amount    + @AREAR_CLAIM
 SET @OT_Amount			    = @OT_Amount			 + @AREAR_OT
 SET @Bonus_Amount		    = @Bonus_Amount			 + @AREAR_BONUS  
 */
 
  if not isnull(@increment_Month ,0) = @cnt -1  and @total_count_all_incremnet > 1 
	begin
		set @Allow_Amount = 0
		set @Temp_Allowance = 0
		set @Temp_Allownace_PT = 0
		set @Dedu_Amount = 0
		set @Temp_Deduction = 0
		set @Settelement_Amount = 0
		set @Leave_Salary_Amount = 0
		set @Salary_amount_Arear = 0 --Hardik 26/09/2016 as Ami life science has issue in Mid Increment and Arear days case in same month, it will add twice
		set @Allow_Amount_Arear =0 --Hardik 26/09/2016 as Ami life science has issue in Mid Increment and Arear days case in same month, it will add twice
		
			--set @Leave_Salary_Amount = 0
			--set @Advance_Amount = 0
			--set @Loan_Amount = 0 
			--set @PT_Amount = 0
			--set @LWF_Amount = 0
			--set @Revenue_Amount= 0    
		
	end


 --Hardik 07/01/2012 for Arear
SET @Gross_Salary_Arear = Isnull(@Salary_amount_Arear,0) + Isnull(@Allow_Amount_Arear,0)

 IF @Is_OT_Inc_Salary =1     
	BEGIN	
		IF @IS_Bonus_EFf_Sal = 1					
			SET @Gross_Salary = Isnull(@Salary_Amount,0) + @Allow_Amount + @Other_Allow_Amount + @Total_Claim_Amount  + @OT_Amount  + @Bonus_Amount + @Gross_Salary_Arear --Hardik 07/01/2012
								+ ISNULL(@WO_OT_Amount,0)  + ISNULL(@HO_OT_Amount,0)+ isnull(@Travel_Amount,0) --Ankit 07012015
								+ ISNULL(@Uniform_Refund_Amount,0)
		
		ELSE

		

			SET @Gross_Salary = Isnull(@Salary_Amount,0) + @Allow_Amount + @Other_Allow_Amount + @Total_Claim_Amount + @OT_Amount + @Gross_Salary_Arear --Hardik 07/01/2012
								+ ISNULL(@WO_OT_Amount,0)  + ISNULL(@HO_OT_Amount,0)+ isnull(@Travel_Amount,0) --Ankit 07012015
								+ ISNULL(@Uniform_Refund_Amount,0)
			--select  Isnull(@Salary_Amount,0)as Salary_Amount, @Allow_Amount as Allow_Amount , @Other_Allow_Amount as  Other_Allow_Amount , @Total_Claim_Amount as Total_Claim_Amount , @OT_Amount as OT_Amount , @Gross_Salary_Arear as Gross_Salary_Arear --Hardik 07/01/2012
			--					, ISNULL(@WO_OT_Amount,0) as WO_OT_Amount  ,ISNULL(@HO_OT_Amount,0) as HO_OT_Amount,  isnull(@Travel_Amount,0) as Travel_Amount --Ankit 07012015
			--					, ISNULL(@Uniform_Refund_Amount,0) as Uniform_Refund_Amount
		
	END
ELSE
	BEGIN
		IF @IS_Bonus_EFf_Sal = 1		
			SET @Gross_Salary = Isnull(@Salary_Amount,0) + @Allow_Amount + @Other_Allow_Amount + @Total_Claim_Amount   + @Bonus_Amount + @Gross_Salary_Arear + isnull(@Travel_Amount,0) + ISNULL(@Uniform_Refund_Amount,0) --Hardik 07/01/2012		
		ELSE    			
			SET @Gross_Salary = Isnull(@Salary_Amount,0) + @Allow_Amount + @Other_Allow_Amount + @Total_Claim_Amount + @Gross_Salary_Arear + isnull(@Travel_Amount,0) + ISNULL(@Uniform_Refund_Amount,0) --Hardik 07/01/2012

	END      
       
       
      
-------------------------Hasmukh for Gross fraction rounding 14/09/2011--------------------------
Declare @Temp_Round_Gross		NUMERIC(18, 4)
Declare @Total_Earning_Fraction Numeric (18,2)

Set @Temp_Round_Gross = 0
Set @Total_Earning_Fraction = 0


If @ROUNDING = 1
	Begin
		Set @Temp_Round_Gross = Round(@Gross_Salary,0)
		Set @Total_Earning_Fraction = @Temp_Round_Gross - @Gross_Salary
	End

---------------------------End Fraction----------------------------------------------------------

 --If @Is_Emp_PT =1 and @Is_PT = 1     
  --Begin    
	--	set  @PT_Calculated_Amount = @Gross_Salary  - isnull(@Temp_Allownace_PT,0) -- change by Falak on 02-OCT-2010  
	--	exec SP_CALCULATE_PT_AMOUNT @CMP_ID,@EMP_ID,@MONTH_END_DATE,@PT_Calculated_Amount,@PT_AMOUNT OUTPUT,@PT_F_T_LIMIT output,@Branch_ID    
  --end    
 
	
    --Changed by Falak on 16-FEB-2011   
 IF @Is_Emp_PT =1 and @Is_PT = 1       
  BEGIN      
  
	
		IF @Lv_Salary_Effect_on_PT <> 1		
			SET  @PT_Calculated_Amount = @PT_Calculated_Amount + @Gross_Salary - ISNULL(@Temp_Allownace_PT,0) + isnull(@Leave_Salary_Amount,0) --change by Falak on 02-OCT-2010
		ELSE
			SET  @PT_Calculated_Amount = @PT_Calculated_Amount + @Gross_Salary - ISNULL(@Temp_Allownace_PT,0)   -- Changed by rohit For pt leave Salary effect on pt on 09012015
  if @total_count_all_incremnet = @cnt 
	BEGIN
		Set @PT_Calculated_Amount = @PT_Calculated_Amount + @Settelement_Amount -- Added by hardik 13/07/2015 as Havmor has issue that PT is not calculating on Arear done from Settlement
		EXEC SP_CALCULATE_PT_AMOUNT @CMP_ID,@EMP_ID,@MONTH_END_DATE,@PT_Calculated_Amount,@PT_AMOUNT OUTPUT,@PT_F_T_LIMIT output,@Branch_ID     
	END
  END   
     
     
    
   --SET @Gross_Salary  = @Gross_Salary + ISNULL(@Leave_Salary_Amount,0)             
   --SET @Gross_Salary  = @Gross_Salary  + isnull(@Settelement_Amount,0)     --Comment by Hasmukh 02082014 due to settlement & leave amount added twice in gross salary in case mid increment
        
 IF   @Gross_Salary < @Revenue_on_Amount  AND @Revenue_on_Amount> 0      
	  SET @Revenue_Amount = 0         
	  SET @LWF_compare_month = '#'+ CAST(MONTH(@Month_End_Date) AS VARCHAR(2)) + '#'      
       
       
 IF CHARINDEX(@LWF_compare_month,@LWF_App_Month,1) = 0 OR @LWF_App_Month ='' or @is_emp_lwf = 0  or ISNULL(@Gross_Salary,0) = 0 --Condition of Gross Salary Added By Ramiz on 05072016 after discussion with Ankit Bhai
	  BEGIN      
		SET @LWF_Amount = 0      
	  END        
	
	--Added By Ramiz on 03/08/2016 , becoz TDS should not be deducted if Gross Salary is 0
		IF 	ISNULL(@GROSS_SALARY,0) = 0
			BEGIN					
				UPDATE MAD1
				SET MAD1.M_AD_AMOUNT = 0
				FROM T0210_MONTHLY_AD_DETAIL AS MAD1
				INNER JOIN DBO.T0050_AD_MASTER AS AD ON  MAD1.AD_ID=AD.AD_ID
				WHERE MAD1.TEMP_SAL_TRAN_ID = @SAL_TRAN_ID   AND AD.AD_DEF_ID = 1 AND AD.CMP_ID=@CMP_ID										
				
				SET @DEDU_AMOUNT = ISNULL(@DEDU_AMOUNT,0) - ISNULL(@M_IT_TAX,0)
			END
	--TDS Condition Ended By Ramiz on 03/08/2016.
 
 --Alpesh 02-Jul-2012
set @Extra_AB_Amount = 0	
	
--Commented by Hardik 10/04/2013.. Now Extra Absent Deduct from Present Days.. so no need to calculate Amount
--set @Extra_AB_Amount = @Extra_AB_Amount + (@Extra_AB_Days * @Day_Salary) 

---- End ---
 
 SET @Total_Dedu_Amount = @Dedu_Amount + @Other_Dedu_Amount + @Other_m_it_Amount + @Advance_Amount + @Loan_Amount  + @PT_Amount + @LWF_Amount +  @Revenue_Amount  + Isnull(@Loan_Interest_Amount,0) + isnull(@Dedu_Amount_Arear,0) + ISNULL(@Extra_AB_Amount,0) + ISNULL(@Asset_Installment,0) + isnull(@Travel_Advance_Amount,0) + ISNULL(@Uniform_Deduction_Amount,0) + isnull(@Bond_Amount,0)  --ADDED by mukti @Asset_Installment 24032015
 --SET @Net_Amount = Round(@Gross_Salary - @Total_Dedu_Amount,0)  
 
 
 
		 	IF @Fix_Salary = 1
				begin
					set @mid_gross_Amount = @Gross_Salary
				end
			else
				begin
					set @mid_gross_Amount = @mid_gross_Amount  + @Gross_Salary
				end
			
 
			if @ROUNDING = 1
				begin
					
					--set @mid_basic_Amount = Round(@mid_basic_Amount  + (@Day_Salary * @Mid_Inc_Working_Day),0)
					
					set @mid_salary_Amount = Round(@mid_salary_Amount  + (@Day_Salary * @Sal_cal_Days),0)
					
					---- Mitesh 08032013 basic salary amount if wo/ho inclued or exlude START 
					If @Wages_Type = 'Monthly'  
						Begin
							--Added by Hardik 02/06/2014 for Apollo, because @Mid_Inc_Working_Day Already Set above as per weekoff and HO, So no need to Minus Weekoff and Holiday
							--set @mid_basic_Amount = Round(@mid_basic_Amount  + (@Day_Salary * @Mid_Inc_Working_Day),0)
							
							--Added By Ramiz on 31/07/2017
							if @Salary_Depends_on_Production = 1
					           BEGIN
					             set @mid_basic_Amount = Round(@mid_basic_Amount  + (@Day_Salary * @Sal_Cal_Days),0)
					           END	
					         else
					           BEGIN
					              set @mid_basic_Amount = Round(@mid_basic_Amount  + (@Day_Salary * @Mid_Inc_Working_Day),0) 
					           END
					           						
							--Below Commented by Hardik 02/06/2014 for Apollo, because @Mid_Inc_Working_Day Already Set above as per weekoff and HO, So no need to Minus Weekoff and Holiday
							--changed by Falak on 20-Jan-2011
							 
							--If @Inc_Weekoff = 1    
							--	begin
							--		if @Inc_Holiday = 1
							--			Begin	
							--				set @mid_basic_Amount = Round(@mid_basic_Amount  + (@Day_Salary * @Mid_Inc_Working_Day),0)
							--			end
							--		else
							--			begin
							--				set @mid_basic_Amount = Round(@mid_basic_Amount  + (@Day_Salary * (@Mid_Inc_Working_Day - @Holiday_Days) ),0)
							--			end		
							--	end
							--else
							--	begin
							--		if @Inc_Holiday = 1
							--			Begin
							--				set @mid_basic_Amount = Round(@mid_basic_Amount  + (@Day_Salary * (@Mid_Inc_Working_Day - @Weekoff_Days_DayRate) ),0)  --add Hardik 16/10/2013 for Weekoff DayRate
							--			end
							--		else
							--			begin
							--				set @mid_basic_Amount = Round(@mid_basic_Amount  + (@Day_Salary * (@Mid_Inc_Working_Day - @Holiday_Days  - @Weekoff_Days_DayRate) ),0) --add Hardik 16/10/2013 for Weekoff DayRate
							--			end
							--	end	
						end
					else	
						begin
							If @Paid_Weekoff_Daily_Wages = 0
								Begin
									set @mid_basic_Amount = Round(@mid_basic_Amount  + (@Day_Salary * (@Mid_Inc_Working_Day - @Weekoff_Days) ),0) 
								end
							else
								begin
									set @mid_basic_Amount = Round(@mid_basic_Amount  + (@Day_Salary * (@Mid_Inc_Working_Day) ),0)
								end
						end
						
						---- Mitesh 08032013 basic salary amount if wo/ho inclued or exlude END 
							
				end
			else
				begin 
					
					--set @mid_basic_Amount = @mid_basic_Amount  + (@Day_Salary * @Mid_Inc_Working_Day)
					 
					set @mid_salary_Amount = @mid_salary_Amount  + (@Day_Salary * @Sal_cal_Days)
					
					---- Mitesh 08032013 basic salary amount if wo/ho inclued or exlude START 
					If @Wages_Type = 'Monthly'  
						Begin
							--Added by Hardik 02/06/2014 for Apollo, because @Mid_Inc_Working_Day Already Set above as per weekoff and HO, So no need to Minus Weekoff and Holiday				
							set @mid_basic_Amount = @mid_basic_Amount  + (@Day_Salary * @Mid_Inc_Working_Day)

							--Below Commented by Hardik 02/06/2014 for Apollo, because @Mid_Inc_Working_Day Already Set above as per weekoff and HO, So no need to Minus Weekoff and Holiday						
							
							--changed by Falak on 20-Jan-2011 
							
							--If @Inc_Weekoff = 1    
							--	begin
							--		if @Inc_Holiday = 1
							--			Begin	
							--				set @mid_basic_Amount = (@mid_basic_Amount  + (@Day_Salary * @Mid_Inc_Working_Day))
							--			end
							--		else
							--			begin
							--				set @mid_basic_Amount = (@mid_basic_Amount  + (@Day_Salary * (@Mid_Inc_Working_Day - @Holiday_Days) ))
							--			end		
							--	end
							--else
							--	begin
							--		if @Inc_Holiday = 1
							--			Begin
							--				set @mid_basic_Amount = (@mid_basic_Amount  + (@Day_Salary * (@Mid_Inc_Working_Day - @Weekoff_Days_DayRate) )) --add Hardik 16/10/2013 for Weekoff DayRate
							--			end
							--		else
							--			begin
							--				set @mid_basic_Amount = (@mid_basic_Amount  + (@Day_Salary * (@Mid_Inc_Working_Day - @Holiday_Days  - @Weekoff_Days_DayRate) )) --add Hardik 16/10/2013 for Weekoff DayRate
							--			end
							--	end	
						end
					else	
						begin
							If @Paid_Weekoff_Daily_Wages = 0
								Begin
									set @mid_basic_Amount = (@mid_basic_Amount  + (@Day_Salary * (@Mid_Inc_Working_Day - @Weekoff_Days) )) 
								end
							else
								begin
									set @mid_basic_Amount = (@mid_basic_Amount  + (@Day_Salary * (@Mid_Inc_Working_Day) ))
								end
						end
						
						---- Mitesh 08032013 basic salary amount if wo/ho inclued or exlude END 
				end
			
			
			set @mid_Present_On_Holiday = @mid_Present_On_Holiday + @Present_On_Holiday
			set @Sal_cal_Days = @Sal_Cal_Days_temp -- Added by rohit on 19022016
			
			
			set @mid_Sal_Cal_Days = @mid_Sal_Cal_Days + @Sal_cal_Days
			set @mid_Present_Days = @mid_Present_Days + @Present_Days
			set @mid_Absent_Days = @mid_Absent_Days + @Absent_Days			
			set @mid_Holiday_Days = @mid_Holiday_Days  + @Holiday_Days
			set @mid_WeekOff_Days = @mid_WeekOff_Days + @Weekoff_Days
			set @mid_cancel_holiday = @mid_cancel_holiday + @Cancel_Holiday
			set @mid_cancel_weekoff = @mid_cancel_weekoff + @Cancel_Weekoff
			
			set @mid_total_leave_days = @mid_total_leave_days + @Total_Leave_Days
			set @mid_paid_leave_days = @mid_paid_leave_days + @Paid_Leave_Days
			set @Mid_OD_leave_Days = @Mid_OD_leave_Days + @OD_leave_Days
			Set @Mid_Compoff_leave_Days = @Mid_Compoff_leave_Days + Isnull(@Compoff_leave_Days,0)
						
			set @mid_Actual_Working_Hours =  dbo.F_Return_Hours(dbo.F_Return_Sec(isnull(@mid_Actual_Working_Hours,0)) + dbo.F_Return_Sec(isnull(@Actual_Working_Hours,0)))
			set @mid_Working_Hours = dbo.F_Return_Hours(dbo.F_Return_Sec(isnull(@mid_Working_Hours,0)) + dbo.F_Return_Sec(isnull(@Working_Hours,0)))
			set @mid_Outof_Hours  = dbo.F_Return_Hours(dbo.F_Return_Sec(isnull(@mid_Outof_Hours,0)) + dbo.F_Return_Sec(isnull(@Outof_Hours,0)))
			
			--set @mid_OT_Hours	 = @mid_OT_Hours +  @Emp_OT_Hours_Num
			set @mid_Total_Hours	= dbo.F_Return_Hours(dbo.F_Return_Sec(isnull(@mid_Total_Hours,0)) + dbo.F_Return_Sec(isnull(@Total_Hours,0)))
			set @mid_Shift_Day_Sec	 = @Shift_Day_Sec
			set @mid_Shift_Day_Hour	= @Shift_Day_Hour
			set @mid_Day_Salary	 = @Day_Salary
			set @mid_Hour_Salary	 = @Hour_Salary
			set @mid_Allow_Amount	 = @Allow_Amount
			set @mid_OT_Amount	 = @mid_OT_Amount + @OT_Amount
			set @mid_Other_Allow_Amount	 =@mid_Other_Allow_Amount + @Other_allow_Amount
			set @mid_Dedu_Amount	 =  @Dedu_Amount 
			set @mid_Loan_Amount	 =  @Loan_Amount
			set @mid_Loan_Intrest_Amount	 = @Loan_Interest_Amount
			set @mid_Advance_Amount	 = @Advance_Amount
			set @mid_Other_Dedu_Amount	 = @mid_Other_Dedu_Amount +  @Other_Dedu_Amount
			set @mid_Total_Dedu_Amount	 =  @Total_Dedu_Amount
			set @mid_Due_Loan_Amount	 = @Due_Loan_Amount
			
			set @mid_Actually_Gross_Salary	 = @mid_Actually_Gross_Salary + @Actual_Gross_Salary
			set @mid_PT_Amount	 = @PT_Amount
			set @mid_PT_Calculated_Amount	 =  @PT_Calculated_Amount
			set @mid_Total_Claim_Amount	 = @Total_Claim_Amount
			set @mid_M_OT_Hours	 = @M_OT_Hours
			set @mid_M_Adv_Amount	 = @mid_M_Adv_Amount + @M_ADV_AMOUNT
			set @mid_M_Loan_Amount	 = @mid_M_Loan_Amount + @M_LOAN_AMOUNT
			set @mid_M_IT_Tax	 =  @M_IT_Tax
			set @mid_LWF_Amount	 =  @LWF_Amount
			set @mid_Revenue_Amount	 = @Revenue_Amount
		--	set @mid_Settelement_Amount	 = @Settelement_Amount
			set @mid_Leave_Salary_Amount	 = @Leave_Salary_Amount
			--set @mid_Late_Sec	 = @mid_Late_Sec + @Total_Late_Sec
			--set @mid_Late_Dedu_Amount	 = @mid_Late_Dedu_Amount + @Late_Dedu_Amount
			set @mid_Late_Extra_Dedu_Amount	 = @mid_Late_Extra_Dedu_Amount + @late_Extra_Amount
			--set @mid_Late_Days	 = @mid_Late_Days + @Late_Absent_Day
			set @mid_Bonus_Amount	 = @mid_Bonus_Amount + @Bonus_Amount
			set @mid_IT_M_ED_Cess_Amount	 = @IT_M_ED_Cess_Amount
			set @mid_IT_M_Surcharge_Amount	 = @IT_M_Surcharge_Amount
			
			--set @mid_Early_Sec	= @mid_Early_Sec + @Total_Early_Sec 
			--set @mid_Early_Dedu_Amount	= @mid_Early_Dedu_Amount + @Early_Dedu_Amount
			--set @mid_Early_Extra_Dedu_Amount	= @mid_Early_Extra_Dedu_Amount + @Extra_Early_Dedu_Amount
			--set @mid_Early_Days	= @mid_Early_Days + @Early_Sal_Dedu_Days
			
			set @mid_Total_Earning_Fraction	 = @mid_Total_Earning_Fraction	+ @Total_Earning_Fraction
			--set @mid_Late_Early_Penalty_days  = @mid_Late_Early_Penalty_days + @Penalty_days_Early_Late 
			--set @mid_M_WO_OT_Hours	= @mid_M_WO_OT_Hours + @W_OT_Hours
			--set @mid_M_HO_OT_Hours	= @mid_M_HO_OT_Hours + @H_OT_Hours
			--set @mid_M_WO_OT_Amount	= @mid_M_WO_OT_Amount + @WO_OT_Amount
			--set @mid_M_HO_OT_Amount	= @mid_M_HO_OT_Amount + @HO_OT_Amount
			
			--Ankit 07012015
				set @mid_M_WO_OT_Hours	= @WO_OT_Hours
				set @mid_M_HO_OT_Hours	= @HO_OT_Hours
				set @mid_M_WO_OT_Amount	= @WO_OT_Amount
				set @mid_M_HO_OT_Amount	= @HO_OT_Amount

				Select @mid_OT_Hours
			
			--Ankit 07012015
			
			--Commented by Hardik as Mid_Basic_Amount is already Total Amount on 16/06/2014
			--set @mid_basic_Amount_total  = @mid_basic_Amount_total + @mid_basic_Amount
			set @mid_basic_Amount_total  = @mid_basic_Amount
			
			set @mid_travel_Advance_Amount= @Travel_Advance_Amount -- Added by rohit on 24082015
			set @mid_Travel_Amount = @Travel_Amount
			
			SET @mid_Unifrom_dedu_Amt = @Uniform_Deduction_Amount
			Set @mid_Unifrom_ref_Amt = @Uniform_Refund_Amount
ABC:		
			set @Month_St_Date = dateadd(d,1,@Month_End_Date )
			
			
			fetch next from curMDI into @Increment_ID,@Month_End_Date			
 END

 close curMDI
 deallocate curMDI
 
 SET @mid_gross_Amount  = @mid_gross_Amount + ISNULL(@Leave_Salary_Amount,0) + isnull(@Settelement_Amount,0)   --Added by Hasmukh 02082014 due to settlement & leave amount added twice in gross salary in case mid increment         
   
 -- Comment and added by rohit for add allowance which not add in gross but calculate in net salary on 06-may-2013
 --Set @Net_Amount = Round(@mid_gross_Amount - @mid_Total_Dedu_Amount,0)
 
 If @ROUNDING = 1
	Set @Net_Amount = Round(@mid_gross_Amount - @mid_Total_Dedu_Amount,0) + isnull(@Allow_Amount_Effect_only_Net,0) - isnull(@Deduct_Amount_Effect_only_Net,0)
 Else
	Set @Net_Amount = (@mid_gross_Amount - @mid_Total_Dedu_Amount) + isnull(@Allow_Amount_Effect_only_Net,0) - isnull(@Deduct_Amount_Effect_only_Net,0)
	
 set @mid_Net_Amount	 = @mid_Net_Amount + @Net_Amount
	
	Set @Security_Deposit_Amount =0
		-- Added by rohit on 30082014
		if isnull(@mid_Net_Amount,0) < 0
		BEGIN
			select @Security_Deposit_Amount = isnull(Sum(M_Ad_Amount),0) from T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) where Emp_ID=@emp_id and AD_ID in (
			select AD_ID from T0050_AD_MASTER WITH (NOLOCK) where CMP_ID=@cmp_id and AD_CALCULATE_ON ='Security Deposit') and temp_Sal_tran_Id=@sal_tran_id
		
			delete from T0210_MONTHLY_AD_DETAIL where Emp_ID=@emp_id and AD_ID in (
			select AD_ID from T0050_AD_MASTER WITH (NOLOCK) where CMP_ID=@cmp_id and AD_CALCULATE_ON ='Security Deposit') and temp_Sal_tran_Id=@sal_tran_id
						
			set @mid_Net_Amount = @mid_Net_Amount + @Security_Deposit_Amount
			set @mid_Total_Dedu_Amount = isnull(@mid_Total_Dedu_Amount,0) - isnull(@Security_Deposit_Amount,0)
		END


	-- below condition added by mitesh on 23/03/2012
	
	 --Alpesh 25-Nov-2011 present days must be greater than zero and if @Is_Zero_Day_Salary = 1 then only salary possible with Zero Basic salary
	 
 if @Is_Zero_Day_Salary = 0 and @Fix_Salary = 0  
	 begin
	 
		if @mid_Present_Days <= 0 And @Total_leave_Days =0
			begin			
				--Ankit Rollback Loan Payment Transaction--09062014
					Delete From T0210_Monthly_Loan_Payment where Temp_Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
				--Ankit Rollback Loan Payment Transaction--09062014
				
				--Mukti Rollback Asset Installment Payment Transaction--20042015
					Delete From t0140_asset_transaction where Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
				--Mukti Rollback Asset Installment Payment Transaction--20042015	
				-- Added by rohit on 30082014
				delete from dbo.T0210_Monthly_Leave_Detail   WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0210_MONTHLY_AD_DETAIL      WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				--delete from dbo.T0210_MONTHLY_CLAIM_PAYMENT  WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0210_PAYSLIP_DATA			 WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0100_Anual_bonus			 WHERE Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0200_monthly_salary_leave   WHERE Sal_tran_id = @Sal_Tran_ID and cmp_id =@cmp_id      
				-- Ended by rohit
				--Added by Mukti Rollback Uniform Installment Payment Transaction--13062017
					Delete From T0210_Uniform_Monthly_Payment where Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
				--Added by Mukti Rollback Uniform Installment Payment Transaction--13062017	
				set @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Month='+cast(MONTH(@Month_End_Date) as varchar)+', Year='+cast(year(@Month_End_Date) as varchar)
				--Changed by Gadriwala Muslim 17/01/2017 'Salary' to 'Salary Manual#'
				
				exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Salary Manual#','Zero Days Salary',@LogDesc,1,''
				--Raiserror('Zero Days Salary',16,2)
				print 321
				return -1		
			end	
	 end
	
if @Is_Zero_Basic_Salary = 0
	begin
		if @mid_basic_Amount_total = 0
			begin		

				--Ankit Rollback Loan Payment Transaction--09062014
					Delete From T0210_Monthly_Loan_Payment where Temp_Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
				--Ankit Rollback Loan Payment Transaction--09062014
				
				--Mukti Rollback Asset Installment Payment Transaction--20042015
					Delete From t0140_asset_transaction where Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
				--Mukti Rollback Asset Installment Payment Transaction--20042015	
					-- Added by rohit on 30082014
				delete from dbo.T0210_Monthly_Leave_Detail   WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0210_MONTHLY_AD_DETAIL      WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				--delete from dbo.T0210_MONTHLY_CLAIM_PAYMENT  WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0210_PAYSLIP_DATA			 WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0100_Anual_bonus			 WHERE Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0200_monthly_salary_leave   WHERE Sal_tran_id = @Sal_Tran_ID and cmp_id =@cmp_id      
				-- Ended by rohit
				--Added by Mukti Rollback Uniform Installment Payment Transaction--13062017
					Delete From T0210_Uniform_Monthly_Payment where Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
				--Added by Mukti Rollback Uniform Installment Payment Transaction--13062017	
				set @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Month='+cast(MONTH(@Month_End_Date) as varchar)+', Year='+cast(year(@Month_End_Date) as varchar)
				--Changed by Gadriwala Muslim 17/01/2017 'Salary' to 'Salary Manual#'
				exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Salary Manual#','Zero Basic Salary',@LogDesc,1,''
				--Raiserror('Zero Basic Salary',16,2)
				return -1	
			end
	end
 -- End --

 
 
	if @mid_Net_Amount < 0
		BEGIN
			IF (@Allow_Negative_Sal = 0)--Mihir Trivedi 25/07/2012
				BEGIN
					--Ankit Rollback Loan Payment Transaction--09062014
						Delete From T0210_Monthly_Loan_Payment where Temp_Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
					--Ankit Rollback Loan Payment Transaction--09062014
					
					--Mukti Rollback Asset Installment Payment Transaction--20042015
						Delete From t0140_asset_transaction where Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
					--Mukti Rollback Asset Installment Payment Transaction--20042015	
								
						-- Added by rohit on 30082014
							delete from dbo.T0210_Monthly_Leave_Detail   WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0210_MONTHLY_AD_DETAIL      WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				--delete from dbo.T0210_MONTHLY_CLAIM_PAYMENT  WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0210_PAYSLIP_DATA			 WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0100_Anual_bonus			 WHERE Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0200_monthly_salary_leave   WHERE Sal_tran_id = @Sal_Tran_ID and cmp_id =@cmp_id      
				-- Ended by rohit
				--Added by Mukti Rollback Uniform Installment Payment Transaction--13062017
					Delete From T0210_Uniform_Monthly_Payment where Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
				--Added by Mukti Rollback Uniform Installment Payment Transaction--13062017	

					set @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Month='+cast(MONTH(@Month_End_Date) as varchar)+', Year='+cast(year(@Month_End_Date) as varchar)
					--Changed by Gadriwala Muslim 17/01/2017 'Salary' to 'Salary Manual#'
					exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Salary Manual#','Net Salary is Negative',@LogDesc,1,''			 
					--RAISERROR ('Net Salary is Negative',16,2);
					Return -1
				END
			ELSE --Mihir Trivedi 25/07/2012 for negative salary generation
				BEGIN
				
					Set @Next_Month_Advance = ABS(@mid_Net_Amount)
					Set @mid_Net_Amount = 0

					--Hardik 28/02/2013
					if @manual_salary_period = 0   
						Begin
							--Set @Next_Month_StrtDate = DATEADD(d,-1, DATEADD(m, 1, @Month_End_Date))+1  --DATEADD(d, 1, @Month_End_Date) changed by mitesh						
							Set @Next_Month_StrtDate =   DATEADD(d, 1, @Month_End_Date) --changed by mitesh						
						End
					Else
						Begin
							If Month(@Month_End_Date) < 12
								select @Next_Month_StrtDate=From_date from Salary_Period WITH (NOLOCK) where month= (month(@Month_End_Date)+1) and YEAR=year(@Month_End_Date)
							else
								select @Next_Month_StrtDate=From_date from Salary_Period WITH (NOLOCK) where month= 1 and YEAR=year(@Month_End_Date)+1
						End      

				--Added the Condition of NOT EXISTS by Ramiz on 15/06/2016--	
			If Not Exists (Select Sal_Tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Emp_ID =@Emp_Id And Cmp_ID=@Cmp_ID And Month_St_Date=@tmp_Month_St_Date And Month_End_Date =@tmp_Month_End_Date )
				BEGIN
					declare @Str varchar(1000)
					set @Str = 'Due to Negative Salary for ' + Cast(dateadd(month,-1, @Next_Month_StrtDate) As Varchar(12))
					EXEC P0100_ADVANCE_PAYMENT 0, @Cmp_ID, @Emp_ID, @Next_Month_StrtDate, @Next_Month_Advance, 0, 0, @Str, 'I', 0 , '' , 0 , '' , 0 , @Sal_Tran_ID
				END
				--Ended by Ramiz on 15/06/2016--
			END			
		END
	ELSE -- added by mitesh
		BEGIN
			
			DECLARE @Rval NUMERIC(18, 4)
			DECLARE @Rval_Add NUMERIC(18, 4)
			SET @Rval =0
									
			IF @net_round >= 0 AND ISNULL(@net_round_Type,'') <> ''
				BEGIN				
					IF 	@net_round_Type = 'Lower'
						BEGIN					
							--select @mid_Net_Amount,@net_Round	
							--set @mid_Net_Amount = @mid_Net_Amount + 125
							--select @mid_Net_Amount,@net_Round	
							
							Set @Temp_mid_Net_Amount = @mid_Net_Amount -- Added By Ali 04042014
							
							SET @Rval = CASE WHEN @net_round = 0   THEN 0 ELSE CASE WHEN @net_round = 10 THEN -1 ELSE CASE WHEN  @net_round = 100 THEN -2 ELSE 0 END END END
							--SET @Rval_Add = CASE WHEN @net_round = 0   THEN 0 ELSE CASE WHEN @net_round = 10 THEN 9 ELSE CASE WHEN  @net_round = 100 THEN 99 ELSE 0 END END END
							--Set @mid_Net_Amount =  floor((@mid_Net_Amount + @Rval_Add) / @Rval) * @Rval
							Set @mid_Net_Amount =  Round(@mid_Net_Amount, @Rval, 1)
							
							Set @mid_Net_Round_Diff_Amount = @mid_Net_Amount - @Temp_mid_Net_Amount	 -- Added By Ali 04042014
							
							--Select @mid_Net_Round_Diff_Amount
						END 
					ELSE IF 	@net_round_Type = 'Nearest'
						BEGIN					
							--select @mid_Net_Amount,@net_Round	
							--set @mid_Net_Amount = @mid_Net_Amount - 125
							--select @mid_Net_Amount,@net_Round	
							Set @Temp_mid_Net_Amount = @mid_Net_Amount	-- Added By Ali 04042014
							
							if @net_round > 0
								Set @mid_Net_Amount = ROUND(@mid_Net_Amount/@net_round,0) * @net_round
							Else
								Set @mid_Net_Amount = ROUND(@mid_Net_Amount,0)
							
							Set @mid_Net_Round_Diff_Amount = @mid_Net_Amount - @Temp_mid_Net_Amount		-- Added By Ali 04042014
							
							--Select @mid_Net_Round_Diff_Amount
							
						END 
					ELSE IF 	@net_round_Type = 'Upper'
						BEGIN					
							--select @mid_Net_Amount,@net_Round	
							--set @mid_Net_Amount = @mid_Net_Amount + 125
							--select @mid_Net_Amount,@net_Round	
							Set @Temp_mid_Net_Amount = @mid_Net_Amount		-- Added By Ali 04042014
							
							--Set @mid_Net_Amount = @net_round * CEILING(@mid_Net_Amount/@net_round) -- Working as Upper
							if @net_round > 0
								Set @mid_Net_Amount = @net_round * CEILING(@mid_Net_Amount/@net_round) -- Working as Upper
							Else
								Set @mid_Net_Amount = CEILING(@mid_Net_Amount)
							
							Set @mid_Net_Round_Diff_Amount = @mid_Net_Amount - @Temp_mid_Net_Amount		-- Added By Ali 04042014
							
							--Select @mid_Net_Round_Diff_Amount
						END 
				end
				
			
		END 

	--Set @mid_Net_Round_Diff_Amount = @Total_Earning_Fraction  --Ankit 09072014
	
	if @Basic_Salary < 0 
		begin
			-- Added by rohit on 30082014
				delete from dbo.T0210_Monthly_Leave_Detail   WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0210_MONTHLY_AD_DETAIL      WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				--delete from dbo.T0210_MONTHLY_CLAIM_PAYMENT  WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0210_PAYSLIP_DATA			 WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0100_Anual_bonus			 WHERE Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0200_monthly_salary_leave   WHERE Sal_tran_id = @Sal_Tran_ID and cmp_id =@cmp_id      
				-- Ended by rohit
	
			set @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Month='+cast(MONTH(@Month_End_Date) as varchar)+', Year='+cast(year(@Month_End_Date) as varchar)
			--Changed by Gadriwala Muslim 17/01/2017 'Salary' to 'Salary Manual#'
			exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Salary Manual#','Basic Salary is Negative',@LogDesc,1,''			 
			--RAISERROR ('Basic Salary is Negative',16,2);
			return -1
		end
		
     if @Gross_Salary < 0 and  @Allow_Negative_Sal = 0
		begin
				-- Added by rohit on 30082014
				delete from dbo.T0210_Monthly_Leave_Detail   WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0210_MONTHLY_AD_DETAIL      WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				--delete from dbo.T0210_MONTHLY_CLAIM_PAYMENT  WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0210_PAYSLIP_DATA			 WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0100_Anual_bonus			 WHERE Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
				delete from dbo.T0200_monthly_salary_leave   WHERE Sal_tran_id = @Sal_Tran_ID and cmp_id =@cmp_id      
				-- Ended by rohit
	
			set @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Month='+cast(MONTH(@Month_End_Date) as varchar)+', Year='+cast(year(@Month_End_Date) as varchar)
			--Changed by Gadriwala Muslim 17/01/2017 'Salary' to 'Salary Manual#'
			exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Salary Manual#','Gross Salary is Negative',@LogDesc,1,''			 
			--RAISERROR ('Gross Salary is Negative',16,2);
			return -1
		end 
		
		
	-- above condition added by mitesh on 23/03/2012

      
 IF @M_Sal_Tran_ID > 0       
  BEGIN      
   	
    
  -- UPDATE  T0200_MONTHLY_SALARY      
  -- SET  Increment_ID = @Increment_ID,       
  --                Month_St_Date = @Month_St_Date, Month_End_Date = @Month_End_Date, Sal_Generate_Date = @Sal_Generate_Date,       
  --                Sal_Cal_Days = @Sal_cal_Days, Present_Days = @Present_Days, Absent_Days = @Absent_Days, Holiday_Days = @Holiday_Days,       
  --                Weekoff_Days = @Weekoff_Days, Cancel_Holiday = @Cancel_Holiday, Cancel_Weekoff = @Cancel_Weekoff, Working_Days = @Working_Days,       
  --                Outof_Days = @Outof_Days, Total_Leave_Days = @Total_Leave_Days, Paid_Leave_Days = @Paid_Leave_Days,       
  --                Actual_Working_Hours = @Actual_Working_Hours, Working_Hours = @Working_Hours, Outof_Hours = @Outof_Hours, OT_Hours = @Emp_OT_Sec/3600,       
  --                Total_Hours = @Total_Hours, Shift_Day_Sec = @Shift_Day_Sec, Shift_Day_Hour = @Shift_Day_Hour, Basic_Salary = @Basic_Salary,       
  --                Day_Salary = @Day_Salary, Hour_Salary = @Hour_Salary, Salary_Amount = @Salary_Amount, Allow_Amount = @Allow_Amount,       
  --                OT_Amount = @OT_Amount, Other_Allow_Amount = @Other_Allow_Amount, Gross_Salary = @Gross_Salary, Dedu_Amount = @Dedu_Amount,       
  --                Loan_Amount = @Loan_Amount, Loan_Intrest_Amount = @Loan_Interest_Amount, Advance_Amount = @Advance_Amount,       
  --                Other_Dedu_Amount = @Other_Dedu_Amount, Total_Dedu_Amount = @Total_Dedu_Amount, Due_Loan_Amount = @Due_Loan_Amount,       
  --                Net_Amount = @Net_Amount ,PT_Amount = @PT_Amount,PT_Calculated_Amount = @PT_Calculated_Amount ,Total_Claim_Amount = @Total_Claim_Amount      
  --                ,M_OT_Hours = @M_OT_Hours , M_IT_Tax = @M_IT_Tax , M_Loan_Amount = @M_Loan_Amount ,M_Adv_Amount = @M_Adv_Amount      
  --    ,LWF_Amount = @LWF_Amount , Revenue_Amount = @Revenue_Amount ,PT_F_T_LIMIT = @PT_F_T_LIMIT      
  --    ,Actually_Gross_Salary = @Gross_Salary_ProRata      
  --    ,Settelement_Amount = @Settelement_Amount , Leave_Salary_Amount = @Leave_Salary_Amount      
  --    ,Salary_Status =@Status  , Bonus_Amount = @Bonus_Amount, Total_Earning_Fraction = @Total_Earning_Fraction,
		--Arear_Basic = @Salary_amount_Arear,Arear_Gross = @Gross_Salary_Arear, Arear_Day = @Arear_Day , OD_leave_Days = @OD_leave_Days     
         
  -- WHERE SAL_TRAN_ID =@SAL_TRAN_ID AND EMP_ID = @EMP_ID
  
											
											---- Added for audit trail by Ali 16102013 -- Start
											--   Select	@Old_Increment_ID = Increment_ID
											--			,@Old_Sal_Receipt_No = Sal_Receipt_No
											--			, @Old_tmp_Month_St_Date = Month_St_Date
											--			, @Old_tmp_Month_End_Date = Month_End_Date
											--			, @Old_Sal_Generate_Date = Sal_Generate_Date
											--			, @Old_mid_Sal_Cal_Days = Sal_cal_Days
											--			, @Old_mid_Present_Days = Present_Days
											--			, @Old_mid_Absent_Days = Absent_Days
											--			, @Old_mid_Holiday_Days = Holiday_Days
											--			, @Old_mid_Weekoff_Days = WeekOff_Days
											--			, @Old_mid_Cancel_Holiday = Cancel_Holiday
											--			, @Old_mid_Cancel_Weekoff = Cancel_Weekoff
											--			, @Old_Working_Days = Working_Days
											--			, @Old_Outof_Days = Outof_Days
											--			, @Old_mid_Total_Leave_Days = Total_Leave_Days
											--			, @Old_mid_Paid_Leave_Days = Paid_Leave_Days
											--			, @Old_mid_Actual_Working_Hours = Actual_Working_Hours
											--			, @Old_mid_Working_Hours = Working_Hours
											--			, @Old_mid_Outof_Hours = Outof_Hours
											--			, @Old_Emp_OT_Hours_Num = OT_Hours
											--			, @Old_Total_Hours = Total_Hours
											--			, @Old_mid_Shift_Day_Sec = Shift_Day_Sec
											--			, @Old_mid_Shift_Day_Hour = Shift_Day_Hour
											--			, @Old_mid_basic_Amount = Basic_Salary
											--			, @Old_mid_Day_Salary = Day_Salary
											--			, @Old_mid_Hour_Salary = Hour_Salary
											--			, @Old_mid_Salary_Amount = Salary_Amount
											--			, @Old_mid_Allow_Amount = Allow_Amount
											--			, @Old_mid_OT_Amount = OT_Amount
											--			, @Old_mid_Other_Allow_Amount = Other_Allow_Amount
											--			, @Old_mid_gross_Amount = Gross_Salary
											--			, @Old_mid_Dedu_Amount = Dedu_Amount
											--			, @Old_mid_Loan_Amount = Loan_Amount
											--			, @Old_mid_Loan_Intrest_Amount = Loan_Intrest_Amount
											--			, @Old_mid_Advance_Amount = Advance_Amount
											--			, @Old_mid_Other_Dedu_Amount = Other_Dedu_Amount
											--			, @Old_mid_Total_Dedu_Amount = Total_Dedu_Amount
											--			, @Old_mid_Due_Loan_Amount = Due_Loan_Amount
											--			, @Old_mid_Net_Amount = Net_Amount
											--			, @Old_mid_PT_Amount = PT_Amount
											--			, @Old_mid_PT_Calculated_Amount = PT_Calculated_Amount
											--			, @Old_mid_Total_Claim_Amount = Total_Claim_Amount
											--			, @Old_mid_M_OT_Hours = M_OT_Hours
											--			, @Old_mid_M_IT_Tax = M_IT_Tax
											--			, @Old_mid_M_Loan_Amount = M_Loan_Amount
											--			, @Old_mid_M_ADv_Amount = M_Adv_Amount
											--			, @Old_mid_LWF_Amount = LWF_Amount
											--			, @Old_mid_REvenue_Amount = Revenue_Amount
											--			, @Old_mid_PT_F_T_LIMIT = PT_F_T_Limit
											--			, @Old_Gross_Salary_ProRata = Actually_Gross_Salary
											--			, @Old_mid_Late_Sec = Late_Sec
											--			, @Old_mid_Late_Dedu_Amount = Late_Dedu_Amount
											--			, @Old_Extra_Late_Deduction = Late_Extra_Dedu_Amount
											--			, @Old_mid_Late_Days = Late_Days
											--			, @Old_Status = Salary_Status  
											--			, @Old_mid_Bonus_Amount = Bonus_Amount 
											--			, @Old_mid_Leave_Salary_Amount =  Leave_Salary_Amount  
											--			, @Old_mid_Early_Sec = Early_Sec
											--			, @Old_mid_Early_Dedu_Amount = Early_Dedu_Amount
											--			, @Old_mid_Early_Extra_Dedu_Amount = Early_Extra_Dedu_Amount
											--			, @Old_mid_Early_Days = Early_Days
											--			, @Old_mid_Total_Earning_Fraction =  Total_Earning_Fraction 
											--			, @Old_Salary_amount_Arear = Arear_Basic
											--			, @Old_Gross_Salary_Arear = Arear_Gross
											--			, @Old_Arear_Day = Arear_Day
											--			, @Old_mid_Late_Early_Penalty_days = Late_Early_Penalty_days
											--			, @Old_Mid_OD_leave_Days = OD_leave_Days
											--			, @Old_Extra_AB_Days= Extra_AB_Days
											--			, @Old_Extra_AB_Rate= Extra_AB_Rate
											--			, @Old_Extra_AB_Amount = Extra_AB_Amount
											--			, @Old_Settelement_Amount =  Settelement_Amount
											--   from dbo.T0200_MONTHLY_SALARY	  
											--   WHERE (Sal_Tran_ID = @SAL_TRAN_ID) AND (Emp_ID = @EMP_ID)    
																						
											--	Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from dbo.T0080_EMP_MASTER Where Emp_ID = @Emp_ID)
												
											--	set @OldValue = 'old Value' 
											--					+ '#' + 'Employee Name :' + ISNULL(@Old_Emp_Name,'')
											--					+ '#' + 'Salary Receipt No :' + CONVERT(nvarchar(100),ISNULL(@Old_Sal_Receipt_No,0))
											--					+ '#' + 'Increment ID :' + CONVERT(nvarchar(100),ISNULL(@Old_Increment_ID,0))
											--					+ '#' + 'Month Start Date :' + cast(ISNULL(@Old_tmp_Month_St_Date,'') as nvarchar(11))
											--					+ '#' + 'Month End Date :' + cast(ISNULL(@Old_tmp_Month_End_Date,'') as nvarchar(11))
											--					+ '#' + 'Salary Generate Date :' + cast(ISNULL(@Old_Sal_Generate_Date,'') as nvarchar(11))
											--					+ '#' + 'Mid Salary Cal Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Sal_Cal_Days,0))
											--					+ '#' + 'Mid Present Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Present_Days,0))
											--					+ '#' + 'Mid Absent Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Absent_Days,0))
											--					+ '#' + 'Mid Holiday Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Holiday_Days,0))
											--					+ '#' + 'Mid Weekoff Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Weekoff_Days,0))
											--					+ '#' + 'Mid Cancel Holiday :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Cancel_Holiday,0))
											--					+ '#' + 'Mid Cancel Weekoff :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Cancel_Weekoff,0))													
											--					+ '#' + 'Working Days :' + CONVERT(nvarchar(100),ISNULL(@Old_Working_Days,0))
											--					+ '#' + 'Outof Days :' + CONVERT(nvarchar(100),ISNULL(@Old_Outof_Days,0))
											--					+ '#' + 'Mid Total Leave Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Total_Leave_Days,0))
											--					+ '#' + 'Mid Paid Leave Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Paid_Leave_Days,0))
											--					+ '#' + 'Mid Actual Working Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Actual_Working_Hours,0))
											--					+ '#' + 'Mid Working Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Working_Hours,0))
											--					+ '#' + 'Mid Outof Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Outof_Hours,0))
											--					+ '#' + 'Emp OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_Emp_OT_Hours_Num,0))
											--					+ '#' + 'Total Hours :' + ISNULL(@Old_Total_Hours,'')
											--					+ '#' + 'Mid Shift Day In Sec :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Shift_Day_Sec,0))
											--					+ '#' + 'Mid Shift Day In Hour :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Shift_Day_Hour,0))
											--					+ '#' + 'Mid basic Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_basic_Amount,0))
											--					+ '#' + 'Mid Day Salary :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Day_Salary,0))
											--					+ '#' + 'Mid Hour Salary :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Hour_Salary,0))
											--					+ '#' + 'Mid Salary Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_salary_Amount,0))
											--					+ '#' + 'Mid Allow Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Allow_Amount,0))
											--					+ '#' + 'Mid OT Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_OT_Amount,0))
											--					+ '#' + 'Mid Other Allow Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Other_Allow_Amount,0))
											--					+ '#' + 'Mid Gross Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_gross_Amount,0))
											--					+ '#' + 'Mid Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Dedu_Amount,0))
											--					+ '#' + 'Mid Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Loan_Amount,0))
											--					+ '#' + 'Mid Loan Intrest Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Loan_Intrest_Amount,0))
											--					+ '#' + 'Mid Advance Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Advance_Amount,0))
											--					+ '#' + 'Mid Other Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Other_Dedu_Amount,0))
											--					+ '#' + 'Mid Total Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Total_Dedu_Amount,0))
											--					+ '#' + 'Mid Due Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Due_Loan_Amount,0))
											--					+ '#' + 'Mid Net Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Net_Amount,0))
											--					+ '#' + 'Mid PT Calculated Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_PT_Calculated_Amount,0))
											--					+ '#' + 'Mid PT Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_PT_Amount,0))
											--					+ '#' + 'Mid Total Claim Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Total_Claim_Amount,0))
											--					+ '#' + 'Mid M IT Tax :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_IT_Tax,0))
											--					+ '#' + 'Mid M ADV Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_ADv_Amount,0))
											--					+ '#' + 'Mid M Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_Loan_Amount,0))
											--					+ '#' + 'Mid M OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_OT_Hours,0))
											--					+ '#' + 'Mid LWF Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_LWF_Amount,0))
											--					+ '#' + 'Mid REvenue Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_REvenue_Amount,0))
											--					+ '#' + 'Mid PT F T LIMIT :' + ISNULL(@Old_mid_PT_F_T_LIMIT,'')
											--					+ '#' + 'Gross Salary ProRata :' + CONVERT(nvarchar(100),ISNULL(@Old_Gross_Salary_ProRata,0))
											--					+ '#' + 'Mid Leave Salary Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Leave_Salary_Amount,0))
											--					+ '#' + 'Mid Late Sec :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Late_Sec,0))
											--					+ '#' + 'Mid Late Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Late_Dedu_Amount,0))																
											--					+ '#' + 'Mid Late Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Late_Days,0))
											--					+ '#' + 'Status :' + CONVERT(nvarchar(100),ISNULL(@Old_Status,0))
											--					+ '#' + 'Mid Bonus Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Bonus_Amount,0))
											--					+ '#' + 'Mid IT M ED Cess Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_IT_M_ED_Cess_Amount,0))
											--					+ '#' + 'Mid IT M Surcharge Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_IT_M_Surcharge_Amount,0))
											--					+ '#' + 'Mid Early Sec :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Early_Sec,0))
											--					+ '#' + 'Mid Early Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Early_Dedu_Amount,0))
											--					+ '#' + 'Mid Early Extra Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Early_Extra_Dedu_Amount,0))
											--					+ '#' + 'Mid Early Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Early_Days,0))
											--					+ '#' + 'Mid Total Earning Fraction :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Total_Earning_Fraction,0))
											--					+ '#' + 'Mid Late Early Penalty days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Late_Early_Penalty_days,0))
											--					+ '#' + 'Mid M WO OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_WO_OT_Hours,0))
											--					+ '#' + 'Mid M WO OT Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_WO_OT_Amount,0))
											--					+ '#' + 'Mid M HO OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_HO_OT_Hours,0))
											--					+ '#' + 'Mid M HO OT Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_HO_OT_Amount,0))
											--					+ '#' + 'Salary Amount Arear :' + CONVERT(nvarchar(100),ISNULL(@Old_Salary_amount_Arear,0))
											--					+ '#' + 'Gross Salary Arear :' + CONVERT(nvarchar(100),ISNULL(@Old_Gross_Salary_Arear,0))
											--					+ '#' + 'Arear Day :' + CONVERT(nvarchar(100),ISNULL(@Old_Arear_Day,0))
											--					+ '#' + 'Mid OD Leave Days :' + CONVERT(nvarchar(100),ISNULL(@Old_Mid_OD_leave_Days,0))
											--					+ '#' + 'Extra AB Days :' + CONVERT(nvarchar(100),ISNULL(@Old_Extra_AB_Days,0))
											--					+ '#' + 'Extra AB Rate :' + CONVERT(nvarchar(100),ISNULL(@Old_Extra_AB_Rate,0))
											--					+ '#' + 'Extra AB Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Extra_AB_Amount,0))													
											--					+ '#' + 'Settelement Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Settelement_Amount,0))
											--					+ '#' +
											--					+ 'New Value' +
											--					+ '#' + 'Employee Name :' + ISNULL(@Old_Emp_Name,'')
											--					+ '#' + 'Salary Receipt No :' + CONVERT(nvarchar(100),ISNULL(@Sal_Receipt_No,0))
											--					+ '#' + 'Increment ID :' + CONVERT(nvarchar(100),ISNULL(@Increment_ID,0))
											--					+ '#' + 'Month Start Date :' + cast(ISNULL(@tmp_Month_St_Date,'') as nvarchar(11))
											--					+ '#' + 'Month End Date :' + cast(ISNULL(@tmp_Month_End_Date,'') as nvarchar(11))
											--					+ '#' + 'Salary Generate Date :' + cast(ISNULL(@Sal_Generate_Date,'') as nvarchar(11))
											--					+ '#' + 'Mid Salary Cal Days :' + CONVERT(nvarchar(100),ISNULL(@mid_Sal_Cal_Days,0))
											--					+ '#' + 'Mid Present Days :' + CONVERT(nvarchar(100),ISNULL(@mid_Present_Days,0))
											--					+ '#' + 'Mid Absent Days :' + CONVERT(nvarchar(100),ISNULL(@mid_Absent_Days,0))
											--					+ '#' + 'Mid Holiday Days :' + CONVERT(nvarchar(100),ISNULL(@mid_Holiday_Days,0))
											--					+ '#' + 'Mid Weekoff Days :' + CONVERT(nvarchar(100),ISNULL(@mid_Weekoff_Days,0))
											--					+ '#' + 'Mid Cancel Holiday :' + CONVERT(nvarchar(100),ISNULL(@mid_Cancel_Holiday,0))
											--					+ '#' + 'Mid Cancel Weekoff :' + CONVERT(nvarchar(100),ISNULL(@mid_Cancel_Weekoff,0))													
											--					+ '#' + 'Working Days :' + CONVERT(nvarchar(100),ISNULL(@Working_Days,0))
											--					+ '#' + 'Outof Days :' + CONVERT(nvarchar(100),ISNULL(@Outof_Days,0))
											--					+ '#' + 'Mid Total Leave Days :' + CONVERT(nvarchar(100),ISNULL(@mid_Total_Leave_Days,0))
											--					+ '#' + 'Mid Paid Leave Days :' + CONVERT(nvarchar(100),ISNULL(@mid_Paid_Leave_Days,0))
											--					+ '#' + 'Mid Actual Working Hours :' + CONVERT(nvarchar(100),ISNULL(@mid_Actual_Working_Hours,0))
											--					+ '#' + 'Mid Working Hours :' + CONVERT(nvarchar(100),ISNULL(@mid_Working_Hours,0))
											--					+ '#' + 'Mid Outof Hours :' + CONVERT(nvarchar(100),ISNULL(@mid_Outof_Hours,0))
											--					+ '#' + 'Emp OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Emp_OT_Hours_Num,0))
											--					+ '#' + 'Total Hours :' + ISNULL(@Total_Hours,'')
											--					+ '#' + 'Mid Shift Day In Sec :' + CONVERT(nvarchar(100),ISNULL(@mid_Shift_Day_Sec,0))
											--					+ '#' + 'Mid Shift Day In Hour :' + CONVERT(nvarchar(100),ISNULL(@mid_Shift_Day_Hour,0))
											--					+ '#' + 'Mid basic Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_basic_Amount,0))
											--					+ '#' + 'Mid Day Salary :' + CONVERT(nvarchar(100),ISNULL(@mid_Day_Salary,0))
											--					+ '#' + 'Mid Hour Salary :' + CONVERT(nvarchar(100),ISNULL(@mid_Hour_Salary,0))
											--					+ '#' + 'Mid Salary Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_salary_Amount,0))
											--					+ '#' + 'Mid Allow Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Allow_Amount,0))
											--					+ '#' + 'Mid OT Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_OT_Amount,0))
											--					+ '#' + 'Mid Other Allow Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Other_Allow_Amount,0))
											--					+ '#' + 'Mid Gross Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_gross_Amount,0))
											--					+ '#' + 'Mid Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Dedu_Amount,0))
											--					+ '#' + 'Mid Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Loan_Amount,0))
											--					+ '#' + 'Mid Loan Intrest Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Loan_Intrest_Amount,0))
											--					+ '#' + 'Mid Advance Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Advance_Amount,0))
											--					+ '#' + 'Mid Other Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Other_Dedu_Amount,0))
											--					+ '#' + 'Mid Total Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Total_Dedu_Amount,0))
											--					+ '#' + 'Mid Due Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Due_Loan_Amount,0))
											--					+ '#' + 'Mid Net Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Net_Amount,0))
											--					+ '#' + 'Mid PT Calculated Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_PT_Calculated_Amount,0))
											--					+ '#' + 'Mid PT Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_PT_Amount,0))
											--					+ '#' + 'Mid Total Claim Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Total_Claim_Amount,0))
											--					+ '#' + 'Mid M IT Tax :' + CONVERT(nvarchar(100),ISNULL(@mid_M_IT_Tax,0))
											--					+ '#' + 'Mid M ADV Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_M_ADv_Amount,0))
											--					+ '#' + 'Mid M Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_M_Loan_Amount,0))
											--					+ '#' + 'Mid M OT Hours :' + CONVERT(nvarchar(100),ISNULL(@mid_M_OT_Hours,0))
											--					+ '#' + 'Mid LWF Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_LWF_Amount,0))
											--					+ '#' + 'Mid REvenue Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_REvenue_Amount,0))
											--					+ '#' + 'Mid PT F T LIMIT :' + ISNULL(@mid_PT_F_T_LIMIT,'')
											--					+ '#' + 'Gross Salary ProRata :' + CONVERT(nvarchar(100),ISNULL(@Gross_Salary_ProRata,0))
											--					+ '#' + 'Mid Leave Salary Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Leave_Salary_Amount,0))
											--					+ '#' + 'Mid Late Sec :' + CONVERT(nvarchar(100),ISNULL(@mid_Late_Sec,0))
											--					+ '#' + 'Mid Late Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Late_Dedu_Amount,0))																
											--					+ '#' + 'Mid Late Days :' + CONVERT(nvarchar(100),ISNULL(@mid_Late_Days,0))
											--					+ '#' + 'Status :' + CONVERT(nvarchar(100),ISNULL(@Status,0))
											--					+ '#' + 'Mid Bonus Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Bonus_Amount,0))
											--					+ '#' + 'Mid IT M ED Cess Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_IT_M_ED_Cess_Amount,0))
											--					+ '#' + 'Mid IT M Surcharge Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_IT_M_Surcharge_Amount,0))
											--					+ '#' + 'Mid Early Sec :' + CONVERT(nvarchar(100),ISNULL(@mid_Early_Sec,0))
											--					+ '#' + 'Mid Early Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Early_Dedu_Amount,0))
											--					+ '#' + 'Mid Early Extra Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Early_Extra_Dedu_Amount,0))
											--					+ '#' + 'Mid Early Days :' + CONVERT(nvarchar(100),ISNULL(@mid_Early_Days,0))
											--					+ '#' + 'Mid Total Earning Fraction :' + CONVERT(nvarchar(100),ISNULL(@mid_Total_Earning_Fraction,0))
											--					+ '#' + 'Mid Late Early Penalty days :' + CONVERT(nvarchar(100),ISNULL(@mid_Late_Early_Penalty_days,0))
											--					+ '#' + 'Mid M WO OT Hours :' + CONVERT(nvarchar(100),ISNULL(@mid_M_WO_OT_Hours,0))
											--					+ '#' + 'Mid M WO OT Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_M_WO_OT_Amount,0))
											--					+ '#' + 'Mid M HO OT Hours :' + CONVERT(nvarchar(100),ISNULL(@mid_M_HO_OT_Hours,0))
											--					+ '#' + 'Mid M HO OT Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_M_HO_OT_Amount,0))
											--					+ '#' + 'Salary Amount Arear :' + CONVERT(nvarchar(100),ISNULL(@Salary_amount_Arear,0))
											--					+ '#' + 'Gross Salary Arear :' + CONVERT(nvarchar(100),ISNULL(@Gross_Salary_Arear,0))
											--					+ '#' + 'Arear Day :' + CONVERT(nvarchar(100),ISNULL(@Arear_Day,0))
											--					+ '#' + 'Mid OD Leave Days :' + CONVERT(nvarchar(100),ISNULL(@Mid_OD_leave_Days,0))
											--					+ '#' + 'Extra AB Days :' + CONVERT(nvarchar(100),ISNULL(@Extra_AB_Days,0))
											--					+ '#' + 'Extra AB Rate :' + CONVERT(nvarchar(100),ISNULL(@Extra_AB_Rate,0))
											--					+ '#' + 'Extra AB Amount :' + CONVERT(nvarchar(100),ISNULL(@Extra_AB_Amount,0))													
											--					+ '#' + 'Settelement Amount :' + CONVERT(nvarchar(100),ISNULL(@Settelement_Amount,0))
																
																														
											--	exec P9999_Audit_Trail @Cmp_ID,'U','Salary Manually',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1
											---- Added for audit trail by Ali 16102013 -- End	
											
  
  
  UPDATE    T0200_MONTHLY_SALARY    
   SET       Increment_ID = @Increment_ID, Month_St_Date = @tmp_Month_St_Date, Month_End_Date = @tmp_Month_End_Date,     
			  Sal_Generate_Date = @Sal_Generate_Date, Sal_Cal_Days = @mid_Sal_cal_Days, Present_Days = @mid_Present_Days, Absent_Days = @mid_Absent_Days,     
			  Holiday_Days = @mid_Holiday_Days, Weekoff_Days = @mid_WeekOff_Days, Cancel_Holiday = @mid_cancel_holiday, Cancel_Weekoff = @mid_cancel_weekoff,     
			  Working_Days = @Working_Days, Outof_Days = @Outof_Days, Total_Leave_Days = @mid_total_leave_days, Paid_Leave_Days = @mid_paid_leave_days,     
			  Actual_Working_Hours = @mid_Actual_Working_Hours, Working_Hours = @mid_Working_Hours, Outof_Hours = @mid_Outof_Hours,     
			 -- OT_Hours = @Emp_OT_Sec / 3600, Total_Hours = @Total_Hours, Shift_Day_Sec = @Shift_Day_Sec, Shift_Day_Hour = @Shift_Day_Hour,     
			  OT_Hours =@Emp_OT_Sec/3600 , Total_Hours = @mid_Total_Hours, Shift_Day_Sec = @mid_Shift_Day_Sec, Shift_Day_Hour = @mid_Shift_Day_Hour,     
			  Basic_Salary = @mid_basic_Amount_total , Day_Salary = @mid_Day_Salary, Hour_Salary = @mid_Hour_Salary, Salary_Amount = @mid_salary_Amount,     
			  Allow_Amount = @mid_Allow_Amount, OT_Amount = @mid_OT_Amount, Other_Allow_Amount = @mid_Other_Allow_Amount, Gross_Salary = @mid_gross_Amount,     
			  Dedu_Amount = @mid_Dedu_Amount, Loan_Amount = @mid_Loan_Amount, Loan_Intrest_Amount = @mid_Loan_Intrest_Amount,     
			  Advance_Amount = @mid_Advance_Amount, Other_Dedu_Amount = @mid_Other_Dedu_Amount, Total_Dedu_Amount = @mid_Total_Dedu_Amount,     
			  Due_Loan_Amount = @mid_Due_Loan_Amount, Net_Amount = @mid_Net_Amount, PT_Amount = @mid_PT_Amount,     
			  PT_Calculated_Amount = @mid_PT_Calculated_Amount, Total_Claim_Amount = @mid_Total_Claim_Amount, M_OT_Hours = @mid_M_OT_Hours,     
			  M_IT_Tax = @mid_M_IT_Tax, M_Loan_Amount = @mid_M_Loan_Amount, M_Adv_Amount = @mid_M_Adv_Amount, LWF_Amount = @mid_LWF_Amount,     
			  Revenue_Amount = @mid_Revenue_Amount, PT_F_T_Limit = @mid_PT_F_T_Limit, Actually_Gross_Salary = @Gross_Salary_ProRata, Late_Sec =@mid_Late_Sec,     
			  Late_Dedu_Amount =@mid_Late_Dedu_Amount, Late_Extra_Dedu_Amount =@mid_Late_Extra_Dedu_Amount, Late_Days =@mid_Late_Days,    
			  Salary_Status =@Status  ,Bonus_Amount =@mid_Bonus_Amount ,Leave_Salary_Amount = @mid_Leave_Salary_Amount  
			  ,Early_Sec =@mid_Early_Sec,     
			  Early_Dedu_Amount =@mid_Early_Dedu_Amount, Early_Extra_Dedu_Amount =@mid_Early_Extra_Dedu_Amount, Early_Days =@mid_Early_Days
			  ,Total_Earning_Fraction = @mid_Total_Earning_Fraction     ,
			  Late_Early_Penalty_days = @mid_Late_Early_Penalty_days,
			  Arear_Basic = @Salary_amount_Arear,Arear_Gross = @Gross_Salary_Arear, Arear_Day = @Arear_Day , OD_leave_Days = @Mid_OD_leave_Days,
			  Extra_AB_Days=@Extra_AB_Days,Extra_AB_Rate=@Extra_AB_Rate,Extra_AB_Amount=@Extra_AB_Amount,Settelement_Amount = @Settelement_Amount,
			  Net_Salary_Round_Diff_Amount = @mid_Net_Round_Diff_Amount -- Added By Ali 04042014
			  ,asset_installment=@Asset_Installment , Arear_Month = @Arear_Month,Arear_Year = @Arear_Year
			   ,Travel_Amount=@mid_Travel_Amount
			  ,Travel_Advance_Amount = @mid_travel_Advance_Amount
			  ,Present_On_Holiday =@mid_Present_On_Holiday -- Added by rohit on 19022016
			  ,Uniform_Dedu_Amount = @mid_Unifrom_dedu_Amt
			  ,Uniform_Refund_Amount = @mid_Unifrom_ref_Amt
			  ,Cutoff_Date = @CutoffDate_Salary -------- Add by Jignesh 02-Nov-2017----
   WHERE     (Sal_Tran_ID = @SAL_TRAN_ID) AND (Emp_ID = @EMP_ID)     
     
    ----------------Nilay18062014---------------------
     	UPDATE T0210_Monthly_Reim_detail		      
			SET  SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,      
				 TEMP_SAL_TRAN_ID = NULL      
		WHERE EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID and Cmp_Id=@Cmp_ID     
	----------------Nilay18062014---------------------
      
         
   UPDATE T0210_MONTHLY_LEAVE_DETAIL      
   SET SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,      
     TEMP_SAL_TRAN_ID = NULL      
   WHERE EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID and Cmp_Id=@Cmp_ID       
   
   ALTER TABLE T0210_MONTHLY_AD_DETAIL Disable TRIGGER Tri_T0210_MONTHLY_AD_DETAIL           
         
   UPDATE T0210_MONTHLY_AD_DETAIL       
   SET SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,      
     TEMP_SAL_TRAN_ID = NULL      
   WHERE EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID and Cmp_Id=@Cmp_ID       
     
   ALTER TABLE T0210_MONTHLY_AD_DETAIL Enable TRIGGER Tri_T0210_MONTHLY_AD_DETAIL 
      
       
   ALTER TABLE T0210_MONTHLY_LOAN_PAYMENT Disable TRIGGER Tri_T0210_MONTHLY_LOAN_PAYMENT_UPDATE      
         
   UPDATE T0210_MONTHLY_LOAN_PAYMENT      
   SET SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,      
     TEMP_SAL_TRAN_ID = NULL      
   WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID and Cmp_Id=@Cmp_ID        
    AND LOAN_APR_ID IN (SELECT LOAN_APR_ID from dbo.T0120_LOAN_APPROVAL WITH (NOLOCK) WHERE EMP_ID = @EMP_ID)      
    
   ALTER TABLE T0210_MONTHLY_LOAN_PAYMENT Enable TRIGGER Tri_T0210_MONTHLY_LOAN_PAYMENT_UPDATE      
   --ALTER TABLE T0210_MONTHLY_CLAIM_PAYMENT Disable TRIGGER Tri_T0210_MONTHLY_CLAIM_PAYMENT_UPDATE      
         
   --UPDATE T0210_MONTHLY_CLAIM_PAYMENT      
   --SET SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,      
   --  TEMP_SAL_TRAN_ID = NULL      
   --WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID and Cmp_Id=@Cmp_ID       
   -- AND CLAIM_APR_ID IN (SELECT CLAIM_APR_ID from dbo.T0120_CLAIM_APPROVAL WHERE EMP_ID = @EMP_ID)          
      
   --ALTER TABLE T0210_MONTHLY_CLAIM_PAYMENT Enable TRIGGER Tri_T0210_MONTHLY_CLAIM_PAYMENT_UPDATE      
      
   UPDATE T0210_PAYSLIP_DATA       
   SET  SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,      
     TEMP_SAL_TRAN_ID = NULL      
   WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID and Cmp_Id=@Cmp_ID       
      
     

  END      
       
 ELSE      
  BEGIN      
   --- Check for exists employee condition -----------------------------------------------------------------------
   --  IF EXISTS (SELECT SAL_TRAN_ID from dbo.T0200_MONTHLY_SALARY WHERE EMP_ID=@EMP_ID AND CMP_ID=@CMP_ID AND MONTH_ST_DATE =@MONTH_ST_DATE AND MONTH_END_DATE=@MONTH_END_DATE)
   --         BEGIN
   --			SET @SAL_TRAN_id = 0
   --			RETURN
   --      END
   ------------------------------------------------------------------------------------------------------	
 
		--INSERT INTO T0200_MONTHLY_SALARY      
  --        (Sal_Tran_ID, Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,       
  --        Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,       
  --        Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary,       
  --        Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,       
  --        Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount,PT_Calculated_Amount,PT_Amount,Total_Claim_Amount,      
  --        M_IT_Tax,M_ADv_Amount,M_Loan_Amount,M_OT_Hours,LWF_Amount,REvenue_Amount,PT_F_T_LIMIT,Actually_Gross_Salary,Settelement_Amount,Leave_Salary_Amount,
  --        Salary_Status,Bonus_Amount,IT_M_ED_Cess_Amount,IT_M_Surcharge_Amount,Total_Earning_Fraction,Is_Monthly_Salary, Arear_Basic,Arear_Gross,Arear_Day,OD_leave_Days)      
	 --  VALUES (@Sal_Tran_ID, @Sal_Receipt_No, @Emp_ID, @Cmp_ID, @Increment_ID, @Month_St_Date, @Month_End_Date, @Sal_Generate_Date, @Sal_cal_Days, @Present_Days,       
  --        @Absent_Days, @Holiday_Days, @Weekoff_Days, @Cancel_Holiday, @Cancel_Weekoff, @Working_Days, @Outof_Days, @Total_Leave_Days, @Paid_Leave_Days,       
  --        @Actual_Working_Hours, @Working_Hours, @Outof_Hours, @Emp_OT_Sec/3600, @Total_Hours, @Shift_Day_Sec, @Shift_Day_Hour, @Basic_Salary, @Day_Salary,       
  --        @Hour_Salary, @Salary_Amount, @Allow_Amount, @OT_Amount, @Other_Allow_Amount, @Gross_Salary, @Dedu_Amount, @Loan_Amount, @Loan_Interest_Amount,       
  --        @Advance_Amount, @Other_Dedu_Amount, @Total_Dedu_Amount, @Due_Loan_Amount, @Net_Amount,@PT_Calculated_Amount,@PT_Amount,@Total_Claim_Amount,      
  --        @M_IT_Tax,@M_ADv_Amount,@M_Loan_Amount,@M_OT_Hours,@LWF_Amount,@REvenue_Amount,@PT_F_T_LIMIT,@Gross_Salary_ProRata,@Settelement_Amount,@Leave_Salary_Amount,
  --        @Status,@Bonus_Amount,@IT_M_ED_Cess_Amount,@IT_M_Surcharge_Amount,@Total_Earning_Fraction,0,@Salary_amount_Arear,@Gross_Salary_Arear,@Arear_Day,@OD_leave_Days)               
			
			--Add By deepal 09042021
				DECLARE @ISPieTranSal int = 0
				SELECT @ISPieTranSal = I.Is_Piece_Trans_Salary
				FROM   t0095_increment I 
				       INNER JOIN (SELECT Max(increment_effective_date) AS For_Date, emp_id 
						     	   FROM   t0095_increment 
								   WHERE  increment_effective_date <= Getdate() AND cmp_id = @Cmp_ID
								   GROUP  BY emp_id) Qry 
				 ON I.emp_id = Qry.emp_id AND I.increment_effective_date = Qry.for_date
				 WHERE i.Emp_ID = @Emp_Id and I.Cmp_ID = @Cmp_ID

				 IF @ISPieTranSal = 1
				 Begin
					 exec SP_EMP_PIECE_TRANS_CALC @cmp_Id ,@Month_St_Date ,@Month_End_Date ,@Emp_ID,@Salary_Amount OUTPUT
					 Set @Basic_Salary = @Salary_Amount
				 END
				 --Add By deepal 09042021
				 
    
          INSERT INTO T0200_MONTHLY_SALARY    
				 (Sal_Tran_ID, Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,     
				 Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,     
				 Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary,     
				 Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,     
				 Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, PT_Calculated_Amount, PT_Amount,     
				 Total_Claim_Amount, M_IT_Tax, M_Adv_Amount, M_Loan_Amount, M_OT_Hours, LWF_Amount, Revenue_Amount, PT_F_T_Limit,     
				 Actually_Gross_Salary,Leave_Salary_Amount, Late_Sec, Late_Dedu_Amount, Late_Extra_Dedu_Amount, Late_Days,Salary_Status,Bonus_Amount,
				 IT_M_ED_Cess_Amount,IT_M_Surcharge_Amount,Early_Sec,Early_Dedu_Amount,Early_Extra_Dedu_Amount,Early_Days,Total_Earning_Fraction,
				 Late_Early_Penalty_days,M_WO_OT_Hours,M_WO_OT_Amount,M_HO_OT_Hours,M_HO_OT_Amount,Is_Monthly_Salary,OD_leave_Days,Arear_Basic,Arear_Gross,Arear_Day,
				 Extra_AB_Days,Extra_AB_Rate,Extra_AB_Amount,Settelement_Amount,Net_Salary_Round_Diff_Amount,Asset_Installment,Arear_Month,Arear_Year,Travel_Amount,
				 travel_Advance_Amount,Present_On_Holiday,Uniform_Dedu_Amount,Uniform_Refund_Amount , Cutoff_Date,BOND_Amount)  -- Added By Ali 04042014  
		VALUES  (@Sal_Tran_ID,@Sal_Receipt_No,@Emp_ID,@Cmp_ID,@Increment_ID,@tmp_Month_St_Date,@tmp_Month_End_Date,@Sal_Generate_Date,@mid_Sal_Cal_Days,@mid_Present_Days
				,@mid_Absent_Days,@mid_Holiday_Days,@mid_Weekoff_Days,@mid_Cancel_Holiday,@mid_Cancel_Weekoff,@Working_Days,@Outof_Days,@mid_Total_Leave_Days,@mid_Paid_Leave_Days
				,@mid_Actual_Working_Hours,@mid_Working_Hours,@mid_Outof_Hours,@Emp_OT_Sec/3600,@Total_Hours,@mid_Shift_Day_Sec,@mid_Shift_Day_Hour,@mid_basic_Amount_total ,@mid_Day_Salary
			    ,@mid_Hour_Salary,@mid_Salary_Amount,@mid_Allow_Amount,@mid_OT_Amount,@mid_Other_Allow_Amount,@mid_gross_Amount,@mid_Dedu_Amount,@mid_Loan_Amount,@mid_Loan_Intrest_Amount
			    ,@mid_Advance_Amount,@mid_Other_Dedu_Amount,@mid_Total_Dedu_Amount,@mid_Due_Loan_Amount,@mid_Net_Amount,@mid_PT_Calculated_Amount,@mid_PT_Amount
			    ,@mid_Total_Claim_Amount,@mid_M_IT_Tax,@mid_M_ADv_Amount,@mid_M_Loan_Amount,@mid_M_OT_Hours,@mid_LWF_Amount,@mid_REvenue_Amount,@mid_PT_F_T_LIMIT
			    ,@Gross_Salary_ProRata,@mid_Leave_Salary_Amount, @mid_Late_Sec, @mid_Late_Dedu_Amount, 0, @mid_Late_Days,@Status,@mid_Bonus_Amount
			    ,@mid_IT_M_ED_Cess_Amount,@mid_IT_M_Surcharge_Amount,@mid_Early_Sec,@mid_Early_Dedu_Amount,@mid_Early_Extra_Dedu_Amount,@mid_Early_Days,@mid_Total_Earning_Fraction
			    ,@mid_Late_Early_Penalty_days,@mid_M_WO_OT_Hours, @mid_M_WO_OT_Amount,@mid_M_HO_OT_Hours,@mid_M_HO_OT_Amount,0,@Mid_OD_leave_Days,@Salary_amount_Arear,@Gross_Salary_Arear,@Arear_Day
			    ,@Extra_AB_Days,@Extra_AB_Rate,@Extra_AB_Amount,@Settelement_Amount,@mid_Net_Round_Diff_Amount,@Asset_Installment,@Arear_Month,@Arear_Year,@mid_Travel_Amount 
			    ,@mid_travel_Advance_Amount,@mid_Present_On_Holiday,@mid_Unifrom_dedu_Amt,@mid_Unifrom_ref_Amt , @CutoffDate_Salary,@BOND_AMOUNT)  -- Added By Ali 04042014   
	  
	  
							-- Uncommented Audit Trail by Gadriwala Muslim 15102014 - After Discussion with Hardik bhai,Hasmukh bhai
								-- Added for audit trail By Ali 12102013 -- Start  
									Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from dbo.T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID)
									
												
										set @OldValue = 'New Value' 
													+ '#' + 'Employee Name :' + ISNULL(@Old_Emp_Name,'')
													+ '#' + 'Salary Receipt No :' + CONVERT(nvarchar(100),ISNULL(@Sal_Receipt_No,0))
													+ '#' + 'Increment ID :' + CONVERT(nvarchar(100),ISNULL(@Increment_ID,0))
													+ '#' + 'Month Start Date :' + cast(ISNULL(@tmp_Month_St_Date,'') as nvarchar(11))
													+ '#' + 'Month End Date :' + cast(ISNULL(@tmp_Month_End_Date,'') as nvarchar(11))
													+ '#' + 'Salary Generate Date :' + cast(ISNULL(@Sal_Generate_Date,'') as nvarchar(11))
													+ '#' + 'Salary Calculate Days :' + CONVERT(nvarchar(100),ISNULL(@mid_Sal_Cal_Days,0))
													+ '#' + 'Present Days :' + CONVERT(nvarchar(100),ISNULL(@mid_Present_Days,0))
													+ '#' + 'Absent Days :' + CONVERT(nvarchar(100),ISNULL(@mid_Absent_Days,0))
													+ '#' + 'Holiday Days :' + CONVERT(nvarchar(100),ISNULL(@mid_Holiday_Days,0))
													+ '#' + 'Weekoff Days :' + CONVERT(nvarchar(100),ISNULL(@mid_Weekoff_Days,0))
													+ '#' + 'Cancel Holiday :' + CONVERT(nvarchar(100),ISNULL(@mid_Cancel_Holiday,0))
													+ '#' + 'Cancel Weekoff :' + CONVERT(nvarchar(100),ISNULL(@mid_Cancel_Weekoff,0))													
													+ '#' + 'Outof Days :' + CONVERT(nvarchar(100),ISNULL(@Outof_Days,0))
													+ '#' + 'Paid Leave Days :' + CONVERT(nvarchar(100),ISNULL(@mid_Paid_Leave_Days,0))
													+ '#' + 'Actual Working Hours :' + CONVERT(nvarchar(100),ISNULL(@mid_Actual_Working_Hours,0))
													+ '#' + 'Working Hours :' + CONVERT(nvarchar(100),ISNULL(@mid_Working_Hours,0))
													+ '#' + 'Outof Hours :' + CONVERT(nvarchar(100),ISNULL(@mid_Outof_Hours,0))
													+ '#' + 'Employee OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Emp_OT_Hours_Num,0))
													+ '#' + 'On Duty Leave Days :' + CONVERT(nvarchar(100),ISNULL(@Mid_OD_leave_Days,0))
													+ '#' + 'Shift Day In Sec :' + CONVERT(nvarchar(100),ISNULL(@mid_Shift_Day_Sec,0))
													+ '#' + 'Shift Day In Hour :' + CONVERT(nvarchar(100),ISNULL(@mid_Shift_Day_Hour,0))
													+ '#' + 'Early Sec :' + CONVERT(nvarchar(100),ISNULL(@mid_Early_Sec,0))
													+ '#' + 'Early Days :' + CONVERT(nvarchar(100),ISNULL(@mid_Early_Days,0))
													+ '#' + 'Late Sec :' + CONVERT(nvarchar(100),ISNULL(@mid_Late_Sec,0))
													+ '#' + 'Late Days :' + CONVERT(nvarchar(100),ISNULL(@mid_Late_Days,0))
													+ '#' + 'Late Early Penalty days :' + CONVERT(nvarchar(100),ISNULL(@mid_Late_Early_Penalty_days,0))
													+ '#' + 'Total Leave Days :' + CONVERT(nvarchar(100),ISNULL(@mid_Total_Leave_Days,0))
													+ '#' + 'Working Days :' + CONVERT(nvarchar(100),ISNULL(@Working_Days,0))
													+ '#' + 'Total Hours :' + ISNULL(@Total_Hours,'')
													+ '#' + 'PT LIMIT :' + ISNULL(@mid_PT_F_T_LIMIT,'')
													+ '#' + 'basic Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_basic_Amount,0))
													+ '#' + 'Day Salary :' + CONVERT(nvarchar(100),ISNULL(@mid_Day_Salary,0))
													+ '#' + 'Hour Salary :' + CONVERT(nvarchar(100),ISNULL(@mid_Hour_Salary,0))
													+ '#' + 'Salary Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_salary_Amount,0))
													+ '#' + 'Allowance Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Allow_Amount,0))
													+ '#' + 'Other Allowance Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Other_Allow_Amount,0))
													+ '#' + 'OT Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_OT_Amount,0))
													+ '#' + 'Leave Salary Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Leave_Salary_Amount,0))
													+ '#' + 'Bonus Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Bonus_Amount,0))
													+ '#' + 'WeekOff OT Hours :' + CONVERT(nvarchar(100),ISNULL(@mid_M_WO_OT_Hours,0))
													+ '#' + 'WeekOff OT Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_M_WO_OT_Amount,0))
													+ '#' + 'Holiday OT Hours :' + CONVERT(nvarchar(100),ISNULL(@mid_M_HO_OT_Hours,0))
													+ '#' + 'Holiday OT Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_M_HO_OT_Amount,0))
													+ '#' + 'Salary Amount Arear :' + CONVERT(nvarchar(100),ISNULL(@Salary_amount_Arear,0))
													+ '#' + 'Gross Salary Arear :' + CONVERT(nvarchar(100),ISNULL(@Gross_Salary_Arear,0))
													+ '#' + 'Arear Day :' + CONVERT(nvarchar(100),ISNULL(@Arear_Day,0))
													+ '#' + 'Total Earning Fraction :' + CONVERT(nvarchar(100),ISNULL(@mid_Total_Earning_Fraction,0))
													+ '#' + 'Gross Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_gross_Amount,0))
													+ '#' + 'Deduction Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Dedu_Amount,0))
													+ '#' + 'Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Loan_Amount,0))
													+ '#' + 'Loan Intrest Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Loan_Intrest_Amount,0))
													+ '#' + 'Advance Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Advance_Amount,0))
													+ '#' + 'Other Deduction Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Other_Dedu_Amount,0))
													+ '#' + 'Due Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Due_Loan_Amount,0))
													+ '#' + 'PT Calculated Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_PT_Calculated_Amount,0))
													+ '#' + 'PT Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_PT_Amount,0))
													+ '#' + 'Total Claim Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Total_Claim_Amount,0))
													+ '#' + 'IT Tax :' + CONVERT(nvarchar(100),ISNULL(@mid_M_IT_Tax,0))
													+ '#' + 'ADVANCE Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_M_ADv_Amount,0))
													+ '#' + 'Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_M_Loan_Amount,0))
													+ '#' + 'OT Hours :' + CONVERT(nvarchar(100),ISNULL(@mid_M_OT_Hours,0))
													+ '#' + 'LWF Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_LWF_Amount,0))
													+ '#' + 'Revenue Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_REvenue_Amount,0))
													+ '#' + 'Late Deduction Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Late_Dedu_Amount,0))
													+ '#' + 'Extra Late Deduction :' + CONVERT(nvarchar(100),0)
													+ '#' + 'Extra Absent Days :' + CONVERT(nvarchar(100),ISNULL(@Extra_AB_Days,0))
													+ '#' + 'Extra Absent Rate :' + CONVERT(nvarchar(100),ISNULL(@Extra_AB_Rate,0))
													+ '#' + 'Extra Absent Amount :' + CONVERT(nvarchar(100),ISNULL(@Extra_AB_Amount,0))	
													+ '#' + 'Early Deduction Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Early_Dedu_Amount,0))
													+ '#' + 'Early Extra Deduction Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Early_Extra_Dedu_Amount,0))
													+ '#' + 'IT ED Cess Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_IT_M_ED_Cess_Amount,0))
													+ '#' + 'IT Surcharge Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_IT_M_Surcharge_Amount,0))
													+ '#' + 'Total Deduction Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Total_Dedu_Amount,0))
													+ '#' + 'Gross Salary ProRata :' + CONVERT(nvarchar(100),ISNULL(@Gross_Salary_ProRata,0))		
													+ '#' + 'Settlement Amount :' + CONVERT(nvarchar(100),ISNULL(@Settelement_Amount,0))
													+ '#' + 'Net Round Diff Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Net_Round_Diff_Amount,0))
													+ '#' + 'Net Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Net_Amount,0))
													+ '#' + 'Status :' + CONVERT(nvarchar(100),ISNULL(@Status,0))
													+ '#' + 'Uniform Ded Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Unifrom_dedu_Amt,0))
													+ '#' + 'Uniform Ref Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Unifrom_ref_Amt,0))												
												exec P9999_Audit_Trail @Cmp_ID,'I','Salary Manually',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1
										
								-- Added for audit trail By Ali 12102013 -- End
           
		UPDATE T0210_MONTHLY_LEAVE_DETAIL      
			SET  SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,      
				 TEMP_SAL_TRAN_ID = NULL      
		WHERE EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID and Cmp_Id=@Cmp_ID       
        
        ALTER TABLE T0210_MONTHLY_AD_DETAIL Disable TRIGGER Tri_T0210_MONTHLY_AD_DETAIL 
         
		UPDATE T0210_MONTHLY_AD_DETAIL       
			SET  SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,      
				 TEMP_SAL_TRAN_ID = NULL      
		WHERE EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID and Cmp_Id=@Cmp_ID       
        
        ALTER TABLE T0210_MONTHLY_AD_DETAIL Enable TRIGGER Tri_T0210_MONTHLY_AD_DETAIL 
         
		ALTER TABLE T0210_MONTHLY_LOAN_PAYMENT Disable TRIGGER Tri_T0210_MONTHLY_LOAN_PAYMENT_UPDATE      
         
		UPDATE T0210_MONTHLY_LOAN_PAYMENT      
			SET SAL_TRAN_ID = TEMP_SAL_TRAN_ID  ,      
				TEMP_SAL_TRAN_ID = NULL      
		WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID and Cmp_Id=@Cmp_ID       
		AND LOAN_APR_ID IN (SELECT LOAN_APR_ID from dbo.T0120_LOAN_APPROVAL WITH (NOLOCK) WHERE EMP_ID = @EMP_ID)      
         
         
        ----------------Nilay18062014---------------------
		UPDATE T0210_Monthly_Reim_detail		      
			SET  SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,      
				 TEMP_SAL_TRAN_ID = NULL      
		WHERE EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID and Cmp_Id=@Cmp_ID          
        ----------------Nilay18062014---------------------
         
   ALTER TABLE T0210_MONTHLY_LOAN_PAYMENT Enable TRIGGER Tri_T0210_MONTHLY_LOAN_PAYMENT_UPDATE      
         
   --ALTER TABLE T0210_MONTHLY_CLAIM_PAYMENT Disable TRIGGER Tri_T0210_MONTHLY_CLAIM_PAYMENT_UPDATE      
         
   --UPDATE T0210_MONTHLY_CLAIM_PAYMENT      
   --SET SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,      
   --  TEMP_SAL_TRAN_ID = NULL      
         
   --WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID and Cmp_Id=@Cmp_ID       
   -- AND CLAIM_APR_ID IN (SELECT CLAIM_APR_ID from dbo.T0120_CLAIM_APPROVAL WHERE EMP_ID = @EMP_ID)          
      
   --ALTER TABLE T0210_MONTHLY_CLAIM_PAYMENT Enable TRIGGER Tri_T0210_MONTHLY_CLAIM_PAYMENT_UPDATE      
         
   UPDATE T0210_PAYSLIP_DATA       
   SET  SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,      
     TEMP_SAL_TRAN_ID = NULL      
   WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID and Cmp_Id=@Cmp_ID                
   

       
  END      
  SET @M_SAL_TRAN_ID = @SAL_TRAN_ID          
  
  
 RETURN      
      



