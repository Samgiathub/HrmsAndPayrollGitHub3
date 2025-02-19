

---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_GENERAL_SETTING_Copy]

@Source_Cmp_ID	numeric(18, 0)
,@Source_BranchID	numeric(18, 0)
,@Destination_BranchID	numeric(18, 0)
,@User_Id numeric(18,0) = 0
,@IP_Address varchar(30)= ''
,@Destination_Cmp_ID	numeric(18,0) = 0	--Optional ( Only to be Used in Terms of Cross Company from Backend)

AS

	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON 
	SET ANSI_WARNINGS OFF;
	
	if @Destination_Cmp_ID = 0
		set @Destination_Cmp_ID = @Source_Cmp_ID

/*	
Declare @source_Gen_id numeric(18,0)
Declare @Gen_ID	numeric(18, 0) 
Declare @Cmp_ID	numeric(18, 0)
Declare @Branch_ID	numeric(18, 0)
Declare @For_Date	datetime
Declare @Inc_Weekoff	numeric(1, 0)
Declare @Is_OT	numeric(1, 0)
Declare @ExOT_Setting	numeric(18, 2)
Declare @Late_Limit	varchar(50)
Declare @Late_Adj_Day	numeric(18, 0)
Declare @Is_PT	numeric(1, 0)
Declare @Is_LWF	numeric(1, 0)
Declare @Is_Revenue	numeric(1, 0)
Declare @Is_PF	numeric(1, 0)
Declare @Is_ESIC	numeric(1, 0)
Declare @Is_Late_Mark	numeric(1, 0)
Declare @Is_Credit	numeric(1, 0)
Declare @LWF_Amount	numeric(18, 0)
Declare @LWF_Month	varchar(30)
Declare @Revenue_Amount	numeric(18, 0)
Declare @Revenue_On_Amount	numeric(18, 0)
Declare @Credit_Limit	numeric(18, 0)
Declare @Chk_Server_Date	numeric(1, 0)
Declare @Is_Cancel_Weekoff	numeric(1, 0)
Declare @Is_Cancel_Holiday	numeric(1, 0)
Declare @Is_Daily_OT	numeric(1, 0)
Declare @In_Punch_Duration	varchar(10)
Declare @Last_Entry_Duration	varchar(10)
Declare @OT_App_Limit	varchar(10)
Declare @OT_Max_Limit	varchar(10)
Declare @OT_Fix_Work_Day	numeric(18, 0)
Declare @OT_Fix_Shift_Hours	varchar(10)
Declare @OT_Inc_Salary	numeric(1, 0)
Declare @ESIC_Upper_Limit numeric(18,0)
Declare @ESIC_Employer_Contribution numeric(18,2)
Declare @inout_Days numeric(18,0)
Declare @Late_Fix_Work_Days numeric(5,1)
Declare @Late_Fix_shift_Hours varchar(50)
Declare @Late_Deduction_Days numeric(3,1)
Declare @Late_Extra_Deduction numeric(3,1)
Declare @Is_Late_Cal_On_HO_WO numeric(1)
Declare @Is_Late_CF tinyint
Declare @Late_CF_Reset_On Varchar(50)
Declare @Sal_St_Date DateTime  
Declare @Sal_Fix_Days numeric(18,1)
Declare @Sal_Inout  numeric(1,0)

Declare @tran_type varchar(1)


Declare @Last_bonus		dateTime 
Declare @Gr_Min_Year		tinyint 
Declare @Gr_Cal_Month		tinyint 
Declare @Gr_ProRata_Cal	tinyint 
Declare @Gr_Min_P_Days		numeric(5,2)                            
Declare @Gr_Absent_Days	numeric(5,2)                              
Declare @Short_Fall_Days	numeric(5,2)        
Declare @Gr_Days			numeric(5,2)        
Declare @Gr_Percentage		numeric(5,2) 
Declare @Short_Fall_W_Days numeric(5,2)  
Declare @Leave_SMS         numeric(1,0)  
Declare @CTC_Auto_Cal      numeric(1,0)  
Declare @Inc_Holiday       numeric(1,0)  
Declare @Probation         numeric(2,0)  
Declare @Lv_Month			numeric(2,0) 
Declare @Is_Shortfall_Gradewise tinyint  
Declare @Actual_Gross numeric (18,2)     
Declare @Wage_Amount numeric (18,2)      
Declare @Dep_Reim_Days numeric(18,0)     
Declare @Con_Reim_Days numeric(18,0)     
Declare @Late_With_Leave numeric(18,0)   
Declare @Tras_Week_ot tinyint            
Declare @Bonus_Min_Limit Numeric(18,0)   
Declare @Bonus_Max_Limit Numeric(18,0)   
Declare @Bonus_Per Numeric(18,2)
Declare @Is_Organise_chart tinyint  
Declare @Is_Zero_Day_Salary tinyint 
Declare @OT_Auto  tinyint           
Declare @OT_Present tinyint         
Declare @Is_Negative_Ot Int         
Declare @Is_Present numeric(18,0)   
Declare @Is_Amount numeric(18,0)    
Declare @Mid_Increment numeric(18,0)
Declare @AD_Rounding numeric(18,0)  
Declare @Lv_Salary_Effect_on_PT numeric 
Declare @Lv_Encash_W_Day numeric        
Declare @Lv_Encash_Cal_On Varchar(50)   
Declare @In_Out_Login Int               
Declare @LWF_Max_Amount Numeric(18,2)   
Declare @LWF_Over_Amount Numeric(18,2)  
Declare @First_In_Last_Out_For_Att_Regularization tinyint 
Declare @First_In_Last_Out_For_InOut_Calculation tinyint  
Declare @Late_Count_Exemption	numeric(18, 2)	          
Declare @Early_Limit	varchar(50)	                      
Declare @Early_Adj_Day	numeric(18, 0)	                  
Declare @Early_Deduction_Days	numeric(3,1)	          
Declare @Early_Extra_Deduction	numeric(3,1)	          
Declare @Early_CF_Reset_On	varchar(50)
Declare @Is_Early_Calc_On_HO_WO	tinyint
Declare @Is_Early_CF	tinyint	       
Declare @Early_With_Leave	numeric(1, 0)	
Declare @Early_Count_Exemption	numeric(18, 2)
Declare @Deficit_Limit	varchar(50)	          
Declare @Deficit_Adj_Day	numeric(18, 0)	  
Declare @Deficit_Deduction_Days	numeric(3,1)
Declare @Deficit_Extra_Deduction	numeric(3,1)
Declare @Deficit_CF_Reset_On	varchar(50)	    
Declare @Is_Deficit_Calc_On_HO_WO	tinyint	    
Declare @Is_Deficit_CF	tinyint	                
Declare @Deficit_With_Leave	numeric(1, 0)       
Declare @Deficit_Count_Exemption	numeric(18, 2)
Declare @In_Out_Login_Popup Int                   
Declare @Late_Hour_Upper_Rounding numeric(18,2)   
Declare @is_Late_Calc_Slabwise tinyint            
Declare @Late_Calculate_type nvarchar(10)         
Declare @Early_Hour_Upper_Rounding numeric(18,2)  
Declare @is_Early_Calc_Slabwise tinyint           
Declare @Early_Calculate_type nvarchar(10)        
Declare @Is_Basic_Salary tinyint                  
Declare @Is_PreQuestion tinyint                  
Declare @Is_CompOff tinyint                      
Declare @CompOff_limit numeric(18,0)             
Declare @CompOff_Min_Hours varchar(10)           
Declare @Is_CompOff_WD tinyint                   
Declare @Is_CompOff_WOHO tinyint                 
Declare @Is_CF_On_Sal_Days tinyint  
Declare @Days_As_Per_Sal_Days tinyint 
Declare @Max_Late_Limit varchar(50)   
Declare @Max_Early_Limit varchar(50)  
Declare @Manual_Inout int             
Declare @Allow_Negative_Salary tinyint  
Declare @ESIC_OT_Allow Tinyint          
Declare @CompOff_Avail_Days Numeric(18,0)  
Declare @Paid_WeekOff_Daily_Wages tinyint  
Declare @Allowed_Full_WeekOf_MidJoining tinyint                               
Declare @is_weekoff_hour tinyint                               
Declare @weekoff_hours nvarchar(50)                            
Declare @is_all_emp_prob tinyint                              
Declare @Max_Late_Exem_Limit varchar(50)                     
Declare @Max_Early_Exem_Limit varchar(50)                    
Declare @Max_Bonus_salary_Amount numeric(18,2)               
Declare @Optional_Holiday_Days numeric(10,0)    
Declare @Bonus_Entitle_Limit numeric(18,2)						-- Added by Gadriwala  24012014          
Declare @OD_Transfer_to_OT tinyint								-- Added by Gadriwala  24012014
Declare @Monthly_deficit_Adjust_OT_Hrs tinyint					-- Added by Gadriwala  24012014
Declare @comp_off_hours_Editable tinyint						-- Added by Gadriwala  24012014
Declare @Allowed_Full_week_off_mid_Joining__day_Rate  tinyint	-- Added by Gadriwala  24012014

DECLARE @ALLOWEDFULLWEEKOFMIDLEFT TINYINT = 0
DECLARE @ALLOWEDFULLWEEKOFMIDLEFTDAYRATE TINYINT = 0 --ADDED BY SUMIT 14072016

,@Half_Day_Excepted_Count Numeric(18,2) --Hardik 13/02/2014
,@Half_Day_Excepted_Max_Count Numeric(18,2) 		--Hardik 13/02/2014
,@H_Comp_Off numeric 								--Sid 05022014
,@H_CompOff_Limit numeric 						--Sid 05022014
,@H_Min_CompOff_Hours varchar(max)			--Sid 05022014
,@H_CompOff_Avail_Days numeric 					--Sid 05022014
,@W_Comp_Off numeric 								--Sid 05022014
,@W_CompOff_Limit numeric 						--Sid 05022014
,@W_Min_CompOff_Hours varchar(max) 	--Sid 05022014
,@W_CompOff_Avail_Days numeric 					--Sid 05022014
,@AllowShowODOptInCompOff numeric 			--Sid 28022014
,@Net_Salary_Round integer							--Added By Gadriwala 03042014
,@type_net_salary_round varchar(10)					--Added By Gadriwala 03042014
Declare @Day_For_Security_Deposit numeric(3,0)          -- Added by rohit on 10-apr-2014
Declare @Is_Restrict_Present_days Char			--Added By Ramiz on 08/01/2016

set @Day_For_Security_Deposit = 0
set @Half_Day_Excepted_Count  =0			--Hardik 13/02/2014
set @Half_Day_Excepted_Max_Count  =0		--Hardik 13/02/2014
set @H_Comp_Off =0								--Sid 05022014
set @H_CompOff_Limit = 0						--Sid 05022014
set @H_Min_CompOff_Hours  = '00:00'		--Sid 05022014
set @H_CompOff_Avail_Days = 0					--Sid 05022014
set @W_Comp_Off  =0								--Sid 05022014
set @W_CompOff_Limit = 0						--Sid 05022014
set @W_Min_CompOff_Hours = '00:00'		--Sid 05022014
set @W_CompOff_Avail_Days = 0					--Sid 05022014
set @AllowShowODOptInCompOff = 0				--Sid 28022014
set @Is_Restrict_Present_days = 'Y'


Declare @OT_RoundingOff_To_Cpy as numeric(18,2)			--Added by Sid 20052014
Declare @OT_RoundingOff_Lower as numeric(1,0)		--Added by Sid 20052014

declare @MinWODays as numeric(18,2)
declare @MaxWODays as numeric(18,2)
declare @Is_H_Co_hour_Editable as numeric(18,2)
declare @Is_W_Co_hour_Editable as numeric(18,2)
declare @chk_otlimit_before_after_shift_time as numeric(18,2)
declare @chk_lv_calculate_on_working as numeric(18,0)		--=0 --Added by sumit 26112014
declare @chk_Attendance as numeric(18,0)					--=0 --Added by sumit 01/01/2015
declare @Sal_CutOff_Date as datetime						--=null --Added by sumit 01/01/2015
declare @Max_Cnt_RegDays as numeric(18,0)					--=null --Added by sumit 18022015
declare @Manual_Slr_Prd as tinyint							--=0 --Added by Sumit 20022015
declare @Is_WO_OD tinyint 								--Added by Gadriwala Muslim 31032015
declare @Is_HO_OD tinyint 								--Added by Gadriwala Muslim 31032015
declare @Is_WD_OD tinyint 								--Added by Gadriwala Muslim 31032015
DECLARE @DayRate_WO_Cancel tinyint --Hardik 20/05/2015
Declare @Training tinyint --Added by Sumit in Copy Setting
Declare @Dep_Reim_Days_Traning tinyint -- --Added by Sumit in Copy Setting

DECLARE @LateEarlyExemMaxLimit	VARCHAR(20)		--Ankit 03112015
DECLARE @LateEarlyExempCount	NUMERIC(18,2)	--Ankit 03112015
SET @LateEarlyExemMaxLimit  = '00:00'	
SET @LateEarlyExempCount  = 0

set @chk_lv_calculate_on_working=0
set @chk_Attendance=0
set @Sal_CutOff_Date=null
set @Max_Cnt_RegDays=null
set @Manual_Slr_Prd=0
Set @DayRate_WO_Cancel=0
Set @Training=0
set @Dep_Reim_Days_Traning=0

Declare @Emp_WeekDay_OT_Rate Numeric(18,2) --'Added by nilesh patel on 02022016
Declare @Emp_WeekOff_OT_Rate Numeric(18,2) --'Added by nilesh patel on 02022016
Declare @Emp_Holiday_OT_Rate Numeric(18,2) --'Added by nilesh patel on 02022016
Declare @Full_PF Numeric(5,0)  --'Added by nilesh patel on 02022016
Declare @Company_Full_PF Numeric(5,0) --'Added by nilesh patel on 02022016

Declare @Late_Mark_Scenario NUMERIC(1,0) --Added by nilesh patel on 19052016 
Declare @Late_Adj_Again_OT NUMERIC(2,0)  --Added by nilesh patel on 26052016 

Set @Emp_WeekDay_OT_Rate = 0
Set @Emp_WeekOff_OT_Rate = 0
Set @Emp_Holiday_OT_Rate = 0
Set @Full_PF = 0
Set @Company_Full_PF = 0
Set @Late_Mark_Scenario = 1 
Set @Late_Adj_Again_OT = 0
set @ALLOWEDFULLWEEKOFMIDLEFT=0
set @ALLOWEDFULLWEEKOFMIDLEFTDAYRATE=0


select @cmp_id=cmp_id,@gen_id = Gen_id,@Branch_ID=Branch_ID from t0040_General_Setting where cmp_id= @Source_Cmp_ID and branch_id = @Destination_BranchID 
and For_Date = (select max(for_date) From T0040_General_Setting where Cmp_ID = @Source_Cmp_ID and Branch_ID =@Destination_BranchID)  


select
	@source_Gen_id=Gen_ID,
	@For_Date = For_Date , 
	@Inc_Weekoff = Inc_Weekoff , 
	@Is_OT =Is_OT,
	@ExOT_Setting = ExOT_Setting ,
	@Late_Limit = Late_Limit ,
	@Late_Adj_Day = Late_Adj_Day ,
	@Is_PT =  Is_PT ,
	@Is_LWF = Is_LWF ,
	@Is_Revenue=  Is_Revenue ,
	@Is_PF=  Is_PF,
	@Is_ESIC =  Is_ESIC,
	@Is_Late_Mark = Is_Late_Mark,
	@Is_Credit =  Is_Credit,
	@LWF_Amount =  LWF_Amount,
	@LWF_Month =  LWF_Month ,
	@Revenue_Amount =  Revenue_Amount ,
	@Revenue_On_Amount =  Revenue_On_Amount ,
	@Credit_Limit =  Credit_Limit ,
	@Chk_Server_Date =  Chk_Server_Date , 
	@Is_Cancel_Weekoff = Is_Cancel_Weekoff ,
	@Is_Cancel_Holiday =  Is_Cancel_Holiday ,
	@Is_Daily_OT =  Is_Daily_OT ,
	@In_Punch_Duration =  In_Punch_Duration ,
	@Last_Entry_Duration =  Last_Entry_Duration ,
	@OT_App_Limit =  OT_App_Limit , 
	@OT_Max_Limit = OT_Max_Limit , 
	@OT_Fix_Work_Day = OT_Fix_Work_Day , 
	@OT_Fix_Shift_Hours = OT_Fix_Shift_Hours , 
	@OT_Inc_Salary = OT_Inc_Salary ,
	@ESIC_Upper_Limit = ESIC_Upper_Limit ,
	@ESIC_Employer_Contribution = ESIC_Employer_Contribution ,
	@inout_Days = inout_Days ,
	@Late_Fix_Work_Days = Late_Fix_Work_Days ,
	@Late_Fix_shift_Hours =  Late_Fix_shift_Hours,
	@Late_Deduction_Days = Late_Deduction_Days, 
	@Late_Extra_Deduction = Late_Extra_Deduction,
	@Is_Late_Cal_On_HO_WO =  Is_Late_Calc_On_HO_WO,
	@Is_Late_CF =  Is_Late_CF,
	@Late_CF_Reset_On = Late_CF_Reset_On,
	@Sal_St_Date = Sal_St_Date,
	@Sal_Fix_Days = Sal_fix_Days
	,@Sal_Inout = Is_inout_Sal
	,@Last_Bonus = Bonus_Last_Paid_Date 
	,@Gr_Min_Year = Gr_Min_Year
	,@Gr_Cal_Month = Gr_Cal_Month 
	,@Gr_ProRata_Cal = Gr_ProRata_Cal
	,@Gr_Min_P_Days = Gr_Min_P_Days 
	,@Gr_Absent_Days = Gr_Absent_Days
	,@Short_Fall_Days = Short_Fall_Days
	,@Gr_Days = Gr_Days
	,@Gr_Percentage = Gr_Percentage
	,@Short_Fall_W_Days =Short_Fall_W_Days
	,@Leave_SMS = Leave_SMS
	,@CTC_Auto_Cal= CTC_Auto_Cal
	,@Inc_Holiday = Inc_Holiday
	,@Probation = Probation
	,@Lv_Month = Lv_Month
	,@Is_Shortfall_Gradewise = Is_Shortfall_Gradewise
	,@Actual_Gross = Actual_Gross 
	,@Wage_Amount = Wages_Amount
	,@Dep_Reim_Days = Dep_Reim_Days
	,@Con_Reim_Days = Con_Reim_Days
	,@Late_with_leave = Late_With_leave
	,@Tras_Week_ot = Tras_Week_ot
	,@Bonus_Min_Limit= Bonus_Min_Limit
	,@Bonus_Max_Limit = Bonus_Max_Limit
	,@Bonus_Per = Bonus_Per
	,@Is_Organise_chart= Is_Organise_chart
	,@Is_Zero_Day_Salary = Is_Zero_Day_Salary
	,@OT_Auto= Is_OT_Auto_Calc
	,@OT_Present= OT_Present_days
	,@Is_Negative_Ot = Is_Negative_Ot
	,@Is_Present = Is_Present 
	,@Is_Amount = Is_Amount 
	,@Mid_Increment = Mid_Increment 
	,@AD_Rounding = AD_Rounding
	,@Lv_Salary_Effect_on_PT = Lv_Salary_Effect_on_PT 
	,@Lv_Encash_W_Day = Lv_Encash_W_Day 
	,@Lv_Encash_Cal_On = Lv_Encash_Cal_On 
	,@In_Out_Login =In_Out_Login 
	,@LWF_Max_Amount = LWF_Max_Amount 
	,@LWF_Over_Amount = LWF_Over_Amount 
	,@First_In_Last_Out_For_Att_Regularization = First_In_Last_Out_For_Att_Regularization 
	,@First_In_Last_Out_For_InOut_Calculation = First_In_Last_Out_For_InOut_Calculation 
	,@Late_Count_Exemption	=Late_Count_Exemption
	,@Early_Limit = Early_Limit
	,@Early_Adj_Day = Early_Adj_Day
	,@Early_Deduction_Days = Early_Deduction_Days
	,@Early_Extra_Deduction = Early_Extra_Deduction
	,@Early_CF_Reset_On = Early_CF_Reset_On
	,@Is_Early_Calc_On_HO_WO = Is_Early_Calc_On_HO_WO
	,@Is_Early_CF = Is_Early_CF
	,@Early_With_Leave = Early_With_Leave
	,@Early_Count_Exemption = Early_Count_Exemption
	,@Deficit_Limit = Deficit_Limit
	,@Deficit_Adj_Day = Deficit_Adj_Day
	,@Deficit_Deduction_Days = Deficit_Deduction_Days
	,@Deficit_Extra_Deduction = Deficit_Extra_Deduction
	,@Deficit_CF_Reset_On = Deficit_CF_Reset_On
	,@Is_Deficit_Calc_On_HO_WO = Is_Deficit_Calc_On_HO_WO
	,@Is_Deficit_CF = Is_Deficit_CF
	,@Deficit_With_Leave = Deficit_With_Leave
	,@Deficit_Count_Exemption = Deficit_Count_Exemption
	,@In_Out_Login_Popup = In_Out_Login_Popup
	,@Late_Hour_Upper_Rounding = Late_Hour_Upper_Rounding 
	,@is_Late_Calc_Slabwise =is_Late_Calc_Slabwise 
	,@Late_Calculate_type = Late_Calculate_type 
	,@Early_Hour_Upper_Rounding = Early_Hour_Upper_Rounding 
	,@is_Early_Calc_Slabwise = is_Early_Calc_Slabwise 
	,@Early_Calculate_type= Early_Calculate_type 
	,@Is_Basic_Salary = Is_Zero_Basic_Salary 
	,@Is_PreQuestion = Is_PreQuestion 
	, @Is_CompOff = Is_CompOff 
	,@CompOff_limit =  CompOff_Days_Limit 
	,@CompOff_Min_Hours =  CompOff_Min_Hours 
	,@Is_CompOff_WD = Is_CompOff_WD 
	,@Is_CompOff_WOHO  =  Is_CompOff_WOHO 
	,@Is_CF_On_Sal_Days = Is_CF_On_Sal_Days 
	,@Days_As_Per_Sal_Days = Days_As_Per_Sal_Days 
	,@Max_Late_Limit = Max_Late_Limit 
	,@Max_Early_Limit = Max_Early_Limit
	,@Manual_Inout	 = Manual_Inout
	,@Allow_Negative_Salary = Allow_Negative_Salary 
	,@ESIC_OT_Allow = Effect_ot_amount 
	,@CompOff_Avail_Days = CompOff_Avail_Days 
	,@Paid_WeekOff_Daily_Wages = Paid_WeekOff_Daily_Wages 
	,@Allowed_Full_WeekOf_MidJoining = Allowed_Full_WeekOf_MidJoining
	,@is_weekoff_hour = is_weekoff_hour 
	,@weekoff_hours = weekoff_hours 
	,@is_all_emp_prob = is_all_emp_prob 
	,@Max_Late_Exem_Limit = late_exemption_limit 
	,@Max_Early_Exem_Limit = early_exemption_limit 
	,@Max_Bonus_salary_Amount = Max_Bonus_salary_Amount
	,@Optional_Holiday_Days = Optional_Holiday_Days 
	,@OD_Transfer_to_OT = is_OD_Transfer_to_OT
	,@Bonus_Entitle_Limit = Bonus_Entitle_Limit				-- Added by Gadriwala 24012014
	,@comp_off_hours_Editable = Is_Co_hour_Editable			-- Added by Gadriwala 24012014
	,@Allowed_Full_week_off_mid_Joining__day_Rate= Allowed_Full_WeekOf_MidJoining_DayRate	-- Added by Gadriwala 24012014
	,@Monthly_deficit_Adjust_OT_Hrs =  Monthly_Deficit_Adjust_OT_Hrs	-- Added by Gadriwala 24012014
	,@Half_Day_Excepted_Count =Half_Day_Excepted_Count			--Hardik 13/02/2014
,@Half_Day_Excepted_Max_Count =Half_Day_Excepted_Max_Count		--Hardik 13/02/2014
,@H_Comp_Off = Is_HO_CompOff									--Sid 05022014
,@H_CompOff_Limit = H_CompOff_Days_Limit 						--Sid 05022014
,@H_Min_CompOff_Hours = H_CompOff_Min_Hours						--Sid 05022014
,@H_CompOff_Avail_Days = H_CompOff_Avail_Days					--Sid 05022014
,@W_Comp_Off = Is_W_CompOff										--Sid 05022014
,@W_CompOff_Limit = W_CompOff_Days_Limit 						--Sid 05022014
,@W_Min_CompOff_Hours = W_CompOff_Min_Hours						--Sid 05022014
,@W_CompOff_Avail_Days = W_CompOff_Avail_Days					--Sid 05022014
,@AllowShowODOptInCompOff = AllowShowODOptInCompOff				--Sid 28022014
,@Net_Salary_Round = Net_Salary_Round							--Added by Gadriwala 03042014
,@type_net_salary_round = type_net_salary_round					--Added by Gadriwala 03042014
,@Day_For_Security_Deposit = Day_For_Security_Deposit	
,@OT_RoundingOff_To_Cpy = OT_RoundingOff_To				--Added by Sid 20052014
,@OT_RoundingOff_Lower = OT_RoundingOff_Lower 		--Added by Sid 20052014
,@MinWODays = MinWODays
,@MaxWODays = MaxWODays
,@chk_otlimit_before_after_shift_time=Chk_otLimit_before_after_Shift_time
,@Is_H_Co_hour_Editable=Is_H_Co_hour_Editable
,@Is_W_Co_hour_Editable=Is_W_Co_hour_Editable
,@chk_lv_calculate_on_working=chk_Lv_On_Working --Added by sumit 26112014
,@chk_Attendance=Attendance_SMS
,@Sal_CutOff_Date=Cutoffdate_Salary --Added by sumit 19012015
,@Max_Cnt_RegDays=Attndnc_Reg_Max_Cnt
,@Manual_Slr_Prd=Manual_Salary_Period --Added by Sumit 20022015
,@Is_WO_OD = Is_WO_OD  -- Added by Gadriwala Muslim 31032015
,@Is_HO_OD = Is_HO_OD  -- Added by Gadriwala Muslim 31032015
,@Is_WD_OD = Is_WD_OD  -- Added by Gadriwala Muslim 31032015
,@DayRate_WO_Cancel = DayRate_WO_Cancel --Hardik 20/05/2015
,@Training=Traning
,@Dep_Reim_Days_Traning=Dep_Reim_Days_Traning
,@LateEarlyExemMaxLimit = LateEarly_Exemption_MaxLimit ,@LateEarlyExempCount = LateEarly_Exemption_Count
,@Is_Restrict_Present_days = Restrict_Present_days
,@Emp_WeekDay_OT_Rate = Emp_WeekDay_OT_Rate
,@Emp_WeekOff_OT_Rate = Emp_WeekOff_OT_Rate
,@Emp_Holiday_OT_Rate = Emp_Holiday_OT_Rate
,@Full_PF = Full_PF
,@Company_Full_PF = Company_Full_PF
,@Late_Mark_Scenario = Late_Mark_Scenario 
,@Late_Adj_Again_OT = Late_Adj_Again_OT
,@ALLOWEDFULLWEEKOFMIDLEFT=Allowed_Full_WeekOf_MidLeft
,@ALLOWEDFULLWEEKOFMIDLEFTDAYRATE=Allowed_Full_WeekOf_MidLeft_DayRate --Added by Sumit 14072016

	From T0040_GENERAL_SETTING Where Branch_ID = @Source_BranchID And Cmp_Id=@Source_Cmp_ID
	and For_Date = (select max(for_date) From T0040_General_Setting where Cmp_ID = @Source_Cmp_ID and Branch_ID =@Source_BranchID)  --Added By Ramiz on 13/07/2016
			
			

	exec P0040_GENERAL_SETTING @Gen_ID=@Gen_ID output,@Cmp_ID=@Cmp_ID,@Branch_ID=@Branch_ID,@For_Date=@For_Date,@Inc_Weekoff=@Inc_Weekoff,
		@Is_OT=@Is_OT,@ExOT_Setting=@ExOT_Setting,@Late_Limit=@Late_Limit,@Late_Adj_Day=@Late_Adj_Day,@Is_PT=@Is_PT,@Is_LWF=@Is_LWF,@Is_Revenue=@Is_Revenue,
		@Is_PF=@Is_PF,@Is_ESIC=@Is_ESIC,@Is_Late_Mark=@Is_Late_Mark,@Is_Credit=@Is_Credit,@LWF_Amount=@LWF_Amount,@LWF_Month=@LWF_Month,
		@Revenue_Amount=@Revenue_Amount,@Revenue_On_Amount=@Revenue_On_Amount,@Credit_Limit=@Credit_Limit,@Chk_Server_Date=@Chk_Server_Date,
		@Is_Cancel_Weekoff=@Is_Cancel_Weekoff,@Is_Cancel_Holiday=@Is_Cancel_Holiday,@Is_Daily_OT=@Is_Daily_OT,@In_Punch_Duration=@In_Punch_Duration,
		@Last_Entry_Duration=@Last_Entry_Duration,@OT_App_Limit=@OT_App_Limit,@OT_Max_Limit=@OT_Max_Limit,@OT_Fix_Work_Day=@OT_Fix_Work_Day,
		@OT_Fix_Shift_Hours=@OT_Fix_Shift_Hours,@OT_Inc_Salary=@OT_Inc_Salary,@ESIC_Upper_Limit=@ESIC_Upper_Limit,@ESIC_Employer_Contribution=@ESIC_Employer_Contribution,
		@inout_Days=@inout_Days,@Late_Fix_Work_Days=@Late_Fix_Work_Days,@Late_Fix_shift_hours=@Late_Fix_shift_hours,@Late_Deduction_Days=@Late_Deduction_Days,
		@Late_Extra_Deduction=@Late_Extra_Deduction,@Is_Late_Cal_On_HO_WO=@Is_Late_Cal_On_HO_WO,@Is_Late_CF=@Is_Late_CF,@Late_CF_Reset_On=@Late_CF_Reset_On,
		@Sal_St_Date=@Sal_St_Date,@Sal_fix_Days=@Sal_fix_Days,@Sal_Inout=@Sal_Inout,@tran_type='Upda',@Last_bonus=@Last_bonus,@Gr_Min_Year=@Gr_Min_Year,
		@Gr_Cal_Month=@Gr_Cal_Month,@Gr_ProRata_Cal=@Gr_ProRata_Cal,@Gr_Min_P_Days=@Gr_Min_P_Days,@Gr_Absent_Days=@Gr_Absent_Days,@Short_Fall_Days=@Short_Fall_Days,
		@Gr_Days=@Gr_Days,@Gr_Percentage=@Gr_Percentage,@Short_Fall_W_Days=@Short_Fall_W_Days,@Leave_SMS=@Leave_SMS,@CTC_Auto_Cal=@CTC_Auto_Cal,
		@Inc_Holiday=@Inc_Holiday,@Probation=@Probation,@Lv_Month=@Lv_Month,@Is_Shortfall_Gradewise=@Is_Shortfall_Gradewise,@Actual_Gross=@Actual_Gross,
		@Wage_Amount=@Wage_Amount,@Dep_Reim_Days=@Dep_Reim_Days,@Con_Reim_Days=@Con_Reim_Days,@Late_With_Leave=@Late_With_Leave,@Tras_Week_ot=@Tras_Week_ot,
		@Bonus_Min_Limit=@Bonus_Min_Limit,@Bonus_Max_Limit=@Bonus_Max_Limit,@Bonus_Per=@Bonus_Per,@Is_Organise_chart=@Is_Organise_chart,@Is_Zero_Day_Salary=@Is_Zero_Day_Salary,
		@OT_Auto=@OT_Auto,@OT_Present=@OT_Present,@Is_Negative_Ot=@Is_Negative_Ot,@Is_Present=@Is_Present,@Is_Amount=@Is_Amount,@Mid_Increment=@Mid_Increment,
		@AD_Rounding=@AD_Rounding,@Lv_Salary_Effect_on_PT=@Lv_Salary_Effect_on_PT,@Lv_Encash_W_Day=@Lv_Encash_W_Day,@Lv_Encash_Cal_On=@Lv_Encash_Cal_On,
		@In_Out_Login=@In_Out_Login,@LWF_Max_Amount=@LWF_Max_Amount,@LWF_Over_Amount=@LWF_Over_Amount,@First_In_Last_Out_For_Att_Regularization=@First_In_Last_Out_For_Att_Regularization,
		@First_In_Last_Out_For_InOut_Calculation=@First_In_Last_Out_For_InOut_Calculation,@Late_Count_Exemption=@Late_Count_Exemption,@Early_Limit=@Early_Limit,
		@Early_Adj_Day=@Early_Adj_Day,@Early_Deduction_Days=@Early_Deduction_Days,@Early_Extra_Deduction=@Early_Extra_Deduction,@Early_CF_Reset_On=@Early_CF_Reset_On,
		@Is_Early_Calc_On_HO_WO=@Is_Early_Calc_On_HO_WO,@Is_Early_CF=@Is_Early_CF,@Early_With_Leave=@Early_With_Leave,@Early_Count_Exemption=@Early_Count_Exemption,
		@Deficit_Limit=@Deficit_Limit,@Deficit_Adj_Day=@Deficit_Adj_Day,@Deficit_Deduction_Days=@Deficit_Deduction_Days,@Deficit_Extra_Deduction=@Deficit_Extra_Deduction,
		@Deficit_CF_Reset_On=@Deficit_CF_Reset_On,@Is_Deficit_Calc_On_HO_WO=@Is_Deficit_Calc_On_HO_WO,@Is_Deficit_CF=@Is_Deficit_CF,@Deficit_With_Leave=@Deficit_With_Leave,
		@Deficit_Count_Exemption=@Deficit_Count_Exemption,@In_Out_Login_Popup=@In_Out_Login_Popup,@Late_Hour_Upper_Rounding=@Late_Hour_Upper_Rounding,
		@is_Late_Calc_Slabwise=@is_Late_Calc_Slabwise,@Late_Calculate_type=@Late_Calculate_type,@Early_Hour_Upper_Rounding=@Early_Hour_Upper_Rounding,
		@is_Early_Calc_Slabwise=@is_Early_Calc_Slabwise,@Early_Calculate_type=@Early_Calculate_type,@Is_Basic_Salary=@Is_Basic_Salary,@Is_PreQuestion=@Is_PreQuestion,
		@Is_CompOff=@Is_CompOff,@CompOff_limit=@CompOff_limit,@CompOff_Min_Hours=@CompOff_Min_Hours,@Is_CompOff_WD=@Is_CompOff_WD,@Is_CompOff_WOHO=@Is_CompOff_WOHO,
		@Is_CF_On_Sal_Days=@Is_CF_On_Sal_Days,@Days_As_Per_Sal_Days=@Days_As_Per_Sal_Days,@Max_Late_Limit=@Max_Late_Limit,@Max_Early_Limit=@Max_Early_Limit,
		@Manual_Inout=@Manual_Inout,@Allow_Negative_Salary=@Allow_Negative_Salary,@CompOff_Avail_Days=@CompOff_Avail_Days,@ESIC_OT_Allow=@ESIC_OT_Allow,
		@Paid_WeekOff_Daily_Wages=@Paid_WeekOff_Daily_Wages,@Allowed_Full_WeekOf_MidJoining=@Allowed_Full_WeekOf_MidJoining,@is_weekoff_hour=@is_weekoff_hour,
		@weekoff_hours=@weekoff_hours,@is_all_emp_prob=@is_all_emp_prob,@User_Id=@User_Id,@IP_Address=@IP_Address,@Max_Late_Exem_Limit=@Max_Late_Exem_Limit,
		@Max_Early_Exem_Limit=@Max_Early_Exem_Limit,@Optional_Holiday_days=@Optional_Holiday_days,@Max_Bonus_Salary_Amount=@Max_Bonus_Salary_Amount,
		@Is_OD_Transfer_to_OT = @OD_Transfer_to_OT,@Is_Co_hour_Editable =@comp_off_hours_Editable,@Allowed_Full_WeekOf_MidJoining_Dayrate = @Allowed_Full_week_off_mid_Joining__day_Rate, 
		@Monthly_Deficit_Adjust_OT_Hrs=@Monthly_Deficit_Adjust_OT_Hrs,@Bonus_Entitle_Limit = @Bonus_Entitle_Limit ,@Half_Day_Excepted_Count =@Half_Day_Excepted_Count ,
		@Half_Day_Excepted_Max_Count =@Half_Day_Excepted_Max_Count ,@H_Comp_Off = @H_Comp_Off ,@H_CompOff_Limit = @H_CompOff_Limit ,
		@H_Min_CompOff_Hours = @H_Min_CompOff_Hours ,@H_CompOff_Avail_Days = @H_CompOff_Avail_Days ,@W_Comp_Off = @W_Comp_Off ,@W_CompOff_Limit = @W_CompOff_Limit ,
		@W_Min_CompOff_Hours = @W_Min_CompOff_Hours ,@W_CompOff_Avail_Days = @W_CompOff_Avail_Days ,@AllowShowODOptInCompOff = @AllowShowODOptInCompOff,
		@Net_Salary_Round =@Net_Salary_Round,@type_net_salary_round = @type_net_salary_round,@Day_For_Security_Deposit=@Day_For_Security_Deposit
		,@MinWOLimit = @MinWODays,@MaxWOLimit=@MaxWODays,@Is_H_Co_hour_Editable=@Is_H_Co_hour_Editable,@Is_W_Co_hour_Editable=@Is_W_Co_hour_Editable
		,@Chk_OT_limit_Before_Shift=@chk_otlimit_before_after_shift_time
		,@Chk_lv_on_Working=@chk_lv_calculate_on_working 
		,@Chk_Attendance_SMS=@chk_Attendance--Added by sumit 26112014
		,@Sal_CutOf_Date=@Sal_CutOff_Date --Added by sumit 19012015
		,@Max_Cnt_Reg=@Max_Cnt_RegDays	  --Added by Sumit 18022015	
		,@Manual_Salary_Prd=@Manual_Slr_Prd --Added by Sumit 20022015
		,@Is_WO_OD = @Is_WO_OD,@Is_HO_OD = @Is_HO_OD,@Is_WD_OD = @Is_WD_OD  --Added by Gadriwala Muslim 31032015
		,@DayRate_WO_Cancel = @DayRate_WO_Cancel
		,@OT_RoundingOff_To=@OT_RoundingOff_To_Cpy --Added by Sumit 11072015
		,@OT_RoundingOff_Lower=@OT_Roundingoff_Lower --Added by Sumit 11072015
		,@Traning=@Training --Added by Sumit 11072015
		,@Dep_Reim_Days_Traning=@Dep_Reim_Days_Traning
		,@LateEarlyExemMaxLimit = @LateEarlyExemMaxLimit,@LateEarlyExempCount = @LateEarlyExempCount
		,@Is_Restrict_Present_days = @Is_Restrict_Present_days
		,@Emp_Weekday_OT_Rate = @Emp_WeekDay_OT_Rate
		,@Emp_Weekoff_OT_Rate = @Emp_WeekOff_OT_Rate
		,@Emp_Holiday_OT_Rate = @Emp_Holiday_OT_Rate
		,@Full_PF = @Full_PF
		,@Company_Full_PF = @Company_Full_PF
		,@Late_Mark_Scenario = @Late_Mark_Scenario 
		,@Late_Adj_Again_OT = @Late_Adj_Again_OT
		,@Allowed_FullWeekof_MidLeft=@ALLOWEDFULLWEEKOFMIDLEFT
		,@Allowed_FullWeekof_MidLeft_DayRate=@ALLOWEDFULLWEEKOFMIDLEFTDAYRATE --Added by Sumit 14072016
	delete from T0050_GENERAL_DETAIL where GEN_ID =@Gen_ID and cmp_id=@cmp_id

*/

--Above Portion Commented By Ramiz on 18/06/2016 as Now General Settings will be Updated Dynamically , Now No Need to Add anything in this SP--


DECLARE @SOURCE_GEN_ID VARCHAR(10)
DECLARE @DESTINATION_GEN_ID	NUMERIC(18, 0) 
DECLARE @SOURCE_FOR_DATE DATETIME
DECLARE @DESTINATION_FOR_DATE DATETIME

DECLARE @CMP_ID	NUMERIC(18, 0)
DECLARE @BRANCH_ID	NUMERIC(18, 0)
DECLARE @STRING VARCHAR(MAX) = '' 
DECLARE @TRAN_TYPE CHAR
DECLARE @MAX_GEN_ID VARCHAR(10);


--Fetch the Source Branch Variables and Its MAX DATE Settings
SELECT @SOURCE_GEN_ID = GEN_ID , @SOURCE_FOR_DATE = For_Date FROM T0040_GENERAL_SETTING WITH (NOLOCK)
	WHERE CMP_ID= @SOURCE_CMP_ID AND BRANCH_ID = @SOURCE_BRANCHID 
		AND FOR_DATE = (
						 SELECT MAX(FOR_DATE) FROM T0040_GENERAL_SETTING WITH (NOLOCK)
						 WHERE CMP_ID = @SOURCE_CMP_ID AND BRANCH_ID =@SOURCE_BRANCHID
						)


--Fetch the Destination Branch Variables and Its MAX DATE Settings					
	SELECT @CMP_ID = CMP_ID,@DESTINATION_GEN_ID = GEN_ID , @DESTINATION_FOR_DATE = For_Date
	FROM T0040_GENERAL_SETTING WITH (NOLOCK)
	WHERE CMP_ID= @DESTINATION_CMP_ID AND BRANCH_ID = @DESTINATION_BRANCHID 
		AND FOR_DATE = (
						 SELECT MAX(FOR_DATE) FROM T0040_GENERAL_SETTING WITH (NOLOCK)
						 WHERE CMP_ID = @DESTINATION_CMP_ID AND BRANCH_ID =@DESTINATION_BRANCHID
						)  

	

DECLARE
  @TABLE			VARCHAR(MAX),	--SPECIFY THE TABLE NAME
  @KEY_COLUMN		SYSNAME,		--SPECIFY COLUMN NAME WHICH IS NOT TO BE INCLUDED IN SELECT QUERY
  @COLNAMES			NVARCHAR(MAX),
  @COLVALUES		NVARCHAR(MAX),
  @SQL				NVARCHAR(MAX),
  @NEWSQL			NVARCHAR(MAX),
  @UPDATE_QUERY		NVARCHAR(MAX),
  @PARMDEFINITION	NVARCHAR(MAX),
  @COLNAMES_ins			NVARCHAR(MAX),
  @COLVALUES_ins		NVARCHAR(MAX);
  
	SET @table = 'T0040_GENERAL_SETTING'
	SET @key_column = 'GEN_ID'
	
	SET @colNames = N''
	SET @colValues = N''
	SET @COLNAMES_ins = N''
	SET @COLVALUES_ins = N''
	
	SET @sql = N''
	SET @NewSql = N''
	Set @Update_Query = N''
   
	SET @ParmDefinition = N'@retvalOUT NVarchar(max) OUTPUT';
	
/* 
HERE WE WILL DECIDE THAT THE RECORDS SHOULD UPDATED OR INSERTED , ON BASIS OF  "@SOURCE_FOR_DATE" &  "@DESTINATION_FOR_DATE"
   
   1) IF "SAME DATE" OR "GREATER DATE" ENTRY EXISTS IN DESTINATION BRANCH, THEN WE WILL UPDATE THAT ENTRY.
   2) IF SMALLER DATE ENTRY EXISTS IN DESTINATION BRANCH, THEN WE WILL INSERT NEW ENTRY
   
*/
SELECT @TRAN_TYPE = CASE WHEN @SOURCE_FOR_DATE > @DESTINATION_FOR_DATE THEN 'I' ELSE 'U' END 

							
IF @TRAN_TYPE = 'U'  --FOR UPDATING GENERAL_SETTING
	BEGIN
		SELECT 
		  @colNames = @colNames + ', 
			' + QUOTENAME(COLUMN_NAME), 
		  @colValues = 
						@colValues + ',
						' + QUOTENAME(COLUMN_NAME)
						+ ' = CONVERT(VARCHAR(320), ' + QUOTENAME(COLUMN_NAME) + ')'
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME='T0040_GENERAL_SETTING'
		AND COLUMN_NAME NOT IN ( 'GEN_ID' , 'CMP_ID' , 'BRANCH_ID', 'FOR_DATE');  -- Specify Column Names which are not to be Updated


		SET @SQL = N'SELECT ' + @KEY_COLUMN + ', PROPERTY, VALUE INTO #DT
		FROM
		(
		  SELECT ' + @KEY_COLUMN + @COLVALUES + '
		   FROM ' + @TABLE + '
		) AS T
		UNPIVOT
		(
		  VALUE FOR PROPERTY IN (' + STUFF(@COLNAMES, 1, 1, '') + ')
		) AS UP;
		';

		
		SET @NEWSQL = 'SELECT @RETVALOUT = STUFF((SELECT '' '' + S.VALUE FROM ( SELECT ('''' + PROPERTY + '' = '''''' + VALUE + '''''','' ) AS VALUE, ' + @KEY_COLUMN + ' FROM #DT ) S WHERE S.'+ @KEY_COLUMN + '= T.'+ @KEY_COLUMN +' FOR XML PATH('''')),1,1,'''') FROM #DT AS T WHERE T.'+@KEY_COLUMN +'= '+ @SOURCE_GEN_ID + ' GROUP BY T.' + @KEY_COLUMN +';'
		SET @SQL = @SQL + @NEWSQL
		
		EXEC sp_executesql @sql,@ParmDefinition, @retvalOUT=@String OUTPUT;
		
		SET @Update_Query = N'UPDATE T0040_GENERAL_SETTING SET ' + LEFT(@STRING , LEN(@STRING)-1) + ' Where CMP_ID = '+ cast(@CMP_ID as varchar(3)) +' and Branch_ID = '+ CAST(@DESTINATION_BRANCHID as Varchar(10)) +' AND GEN_ID = '+ CAST(@DESTINATION_GEN_ID as varchar(10)) +''
		EXEC (@Update_Query);
		SET @SQL = ''
		SET @NEWSQL = ''
	END
ELSE IF @TRAN_TYPE = 'I' --FOR INSERTING GENERAL SETTING
	BEGIN
	
		SELECT @MAX_GEN_ID = ISNULL(MAX(GEN_ID),0) + 1 from dbo.T0040_GENERAL_SETTING  WITH (NOLOCK)  -- BEFORE INSERTING RECORDS , WE NEED MEX GEN_ID
		
		SELECT 
		  @COLNAMES_ins = @COLNAMES_ins + ', 
			' + QUOTENAME(COLUMN_NAME), 
		  @COLVALUES_ins = 
						@COLVALUES_ins + ',
						' + QUOTENAME(COLUMN_NAME)
						+ ' = CONVERT(VARCHAR(320), ' + QUOTENAME(COLUMN_NAME) + ')'
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME='T0040_GENERAL_SETTING'
		AND COLUMN_NAME NOT IN ( 'GEN_ID' , 'CMP_ID' , 'BRANCH_ID');  -- Specify Column Names which are not to be Updated

		SET @SQL = 
				'INSERT INTO T0040_GENERAL_SETTING (GEN_ID, CMP_ID, BRANCH_ID ' + @COLNAMES_ins + ')
				(SELECT ' + @MAX_GEN_ID + ' , ' + CAST(@CMP_ID AS VARCHAR(10))+ ' , ' + CAST(@DESTINATION_BRANCHID AS VARCHAR(10)) + @COLNAMES_ins + ' FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE GEN_ID=' + @SOURCE_GEN_ID +')'
		
		EXEC (@SQL);

		--NOW IN ORDER TO INSERT RECORDS OF PF , LATEMARK AND COMPOFF WE WILL SET "NEW_GEN_ID" AS OUR "DESTINATION_GEN_ID"
		SET @DESTINATION_GEN_ID = @MAX_GEN_ID
	END

		
Declare @Is_PF	Tinyint
Declare @Is_CompOff	Tinyint
Declare @Is_Late_Mark	Tinyint
Declare @Late_Mark_Scenario Tinyint
Declare @Early_Mark_Scenario Tinyint
Declare @Inc_Bonus Tinyint
DECLARE @OT_RATE_TYPE TINYINT --ADDED BY RAJPUT ON 13072018



	SELECT @IS_PF = IS_PF , @IS_COMPOFF = IS_COMPOFF ,@IS_LATE_MARK = IS_LATE_MARK , 
	@LATE_MARK_SCENARIO = LATE_MARK_SCENARIO ,@Inc_Bonus=isnull(Is_Bonus_Inc,0),@Early_Mark_Scenario = Early_Mark_Scenario
	FROM T0040_GENERAL_SETTING WITH (NOLOCK)
	WHERE CMP_ID= @DESTINATION_CMP_ID AND BRANCH_ID = @DESTINATION_BRANCHID AND Gen_ID = @DESTINATION_GEN_ID
		

	
if @IS_PF=1 
	Begin 

		Declare @GEN_TRAN_ID numeric 
		Declare @ACC_1_1 numeric(18,3)  
		Declare @ACC_1_2 numeric(18,3)  
		Declare @ACC_2_3 numeric(18,3)  
		Declare @ACC_10_1 numeric(18,3)  
		Declare @ACC_21_1 numeric(18,3)  
		Declare @ACC_22_3 numeric(18,3)  
		Declare @ACC_10_1_MAX_LIMIT numeric(18,3)  
		Declare @PF_LIMIT numeric  
		Declare @Is_Ncp_Prorata as numeric 
		
		set @Is_Ncp_Prorata = 0

		select 	
		@ACC_1_1 = ACC_1_1 ,
		@ACC_1_2 =  ACC_1_2 ,
		@ACC_2_3 =  ACC_2_3 ,
		@ACC_10_1 =  ACC_10_1 ,
		@ACC_21_1 = ACC_21_1 ,
		@ACC_22_3 = ACC_22_3 ,
		@ACC_10_1_MAX_LIMIT =  ACC_10_1_MAX_LIMIT , 
		@PF_LIMIT = PF_LIMIT ,
		@Is_Ncp_Prorata = Is_Ncp_Prorata
		from T0050_GENERAL_DETAIL WITH (NOLOCK)
		where Gen_id = @source_Gen_id AND CMP_ID = @Source_Cmp_ID  

	declare @p1 int
	set @p1=0
	--exec P0050_GENERAL_DETAIL @GEN_TRAN_ID=@p1 output,@CMP_ID=@CMP_ID,@GEN_ID=@DESTINATION_GEN_ID,@ACC_1_1=@ACC_1_1,@ACC_1_2=@ACC_1_2,@ACC_2_3=@ACC_2_3,@ACC_10_1=@ACC_10_1,@ACC_21_1=@ACC_21_1,@ACC_22_3=@ACC_22_3,@ACC_10_1_MAX_LIMIT=@ACC_10_1_MAX_LIMIT,@PF_LIMIT=@PF_LIMIT,@tran_type='Inse',@Is_Ncp_Prorata=@Is_Ncp_Prorata
	exec P0050_GENERAL_DETAIL @GEN_TRAN_ID=@p1 output,@CMP_ID=@CMP_ID,@GEN_ID=@DESTINATION_GEN_ID,@ACC_1_1=@ACC_1_1,@ACC_1_2=@ACC_1_2,@ACC_2_3=@ACC_2_3,@ACC_10_1=@ACC_10_1,@ACC_21_1=@ACC_21_1,@ACC_22_3=@ACC_22_3,@ACC_10_1_MAX_LIMIT=@ACC_10_1_MAX_LIMIT,@PF_LIMIT=@PF_LIMIT,@tran_type=@TRAN_TYPE,@Is_Ncp_Prorata=@Is_Ncp_Prorata	-- Dynamic Tran_Type Added by Ramiz on 12/09/2016
End

/*	
	Added By Ramiz on 12/09/2016

	If PF , COMP-OFF AND LATEMARK are not tickmarked then delete the Slab of Destination Branch
	Deleting the Slab is Compulsory , because if Slab is presnt in Table then it will effect in Salary , evn we do not have tick mark in General Setting
	So we prefer to delete it.
 */
 
	Delete from T0050_GENERAL_DETAIL_SLAB where Gen_ID = @DESTINATION_GEN_ID and Cmp_ID = @Cmp_ID
	Delete from T0050_GENERAL_LATEMARK_SLAB where Gen_ID = @DESTINATION_GEN_ID and Cmp_ID = @Cmp_ID
	Delete from T0050_LateMark_Rate_Designation where Gen_ID = @DESTINATION_GEN_ID and Cmp_ID = @Cmp_ID
	Delete from T0050_GENERAL_LATEMARK_SLAB_SCENARIO4 where Gen_ID = @DESTINATION_GEN_ID and Cmp_ID = @Cmp_ID
	Delete from T0050_GENERAL_EARLYMARK_SLAB where Gen_ID = @DESTINATION_GEN_ID and Cmp_ID = @Cmp_ID
if @IS_COMPOFF =1
begin
	Declare @Comp_From_hours  numeric(18,2) ---- Added (18,2) by Ramiz on 19/06/2014 bcoz Comp-off slab was not taking in Decimal
	Declare @Comp_To_hours	numeric(18,2)  ---- Added (18,2) by Ramiz on 19/06/2014
	Declare @Comp_Deduction_Days numeric(18,2)  ---- Added (18,2) by Ramiz on 19/06/2014
	Declare @Comp_Slab_Type varchar

		Declare curCompOff cursor for	    
			Select From_hours,To_hours,Deduction_Days,Slab_Type  from T0050_GENERAL_DETAIL_SLAB WITH (NOLOCK) where Gen_ID = @source_Gen_id and Cmp_ID=@Source_Cmp_ID and Slab_Type = 'C' 
		Open curCompOff
		Fetch next from curCompOff into @Comp_From_hours,@Comp_To_hours,@Comp_Deduction_Days,@Comp_Slab_Type
		While @@fetch_status = 0                    
		Begin     
			exec P0050_GENERAL_DETAIL_SLAB @Slab_Id=0,@GEN_ID=@DESTINATION_GEN_ID,@Cmp_ID=@Cmp_ID,@From_hours=@Comp_From_hours,@To_hours=@Comp_To_hours,@Deduction_Days=@Comp_Deduction_Days,@tran_type='Inse',@Slab_Type=@Comp_Slab_Type
			fetch next from curCompOff into @Comp_From_hours,@Comp_To_hours,@Comp_Deduction_Days,@Comp_Slab_Type
		end
		close curCompOff                    
		deallocate curCompOff

		Declare HcurCompOff cursor for	    
			Select From_hours,To_hours,Deduction_Days,Slab_Type  from T0050_GENERAL_DETAIL_SLAB WITH (NOLOCK) where Gen_ID = @source_Gen_id and Cmp_ID=@Source_Cmp_ID and Slab_Type = 'H' 
		Open HcurCompOff
		Fetch next from HcurCompOff into @Comp_From_hours,@Comp_To_hours,@Comp_Deduction_Days,@Comp_Slab_Type
		While @@fetch_status = 0                    
		Begin     
			exec P0050_GENERAL_DETAIL_SLAB @Slab_Id=0,@GEN_ID=@DESTINATION_GEN_ID,@Cmp_ID=@Cmp_ID,@From_hours=@Comp_From_hours,@To_hours=@Comp_To_hours,@Deduction_Days=@Comp_Deduction_Days,@tran_type='Inse',@Slab_Type=@Comp_Slab_Type
			fetch next from HcurCompOff into @Comp_From_hours,@Comp_To_hours,@Comp_Deduction_Days,@Comp_Slab_Type
		end
		close HcurCompOff                    
		deallocate HcurCompOff
		
		Declare WcurCompOff cursor for	    
			Select From_hours,To_hours,Deduction_Days,Slab_Type  from T0050_GENERAL_DETAIL_SLAB WITH (NOLOCK) where Gen_ID = @source_Gen_id and Cmp_ID=@Source_Cmp_ID and Slab_Type = 'W' 
		Open WcurCompOff
		Fetch next from WcurCompOff into @Comp_From_hours,@Comp_To_hours,@Comp_Deduction_Days,@Comp_Slab_Type
		While @@fetch_status = 0                    
		Begin     
			exec P0050_GENERAL_DETAIL_SLAB @Slab_Id=0,@GEN_ID=@DESTINATION_GEN_ID,@Cmp_ID=@Cmp_ID,@From_hours=@Comp_From_hours,@To_hours=@Comp_To_hours,@Deduction_Days=@Comp_Deduction_Days,@tran_type='Inse',@Slab_Type=@Comp_Slab_Type
			fetch next from WcurCompOff into @Comp_From_hours,@Comp_To_hours,@Comp_Deduction_Days,@Comp_Slab_Type
		end
		close WcurCompOff                    
		deallocate WcurCompOff

end

if @IS_LATE_MARK =1
Begin

		Declare @Late_From_hours	numeric(18,2)
		Declare @Late_To_hours	numeric(18,2)
		Declare @Late_mark_Deduction_Days	numeric(18, 2)
		Declare @Late_Slab_Type varchar

		Declare curLate cursor for	                  
		Select From_hours,To_hours,Deduction_Days,Slab_Type from T0050_GENERAL_DETAIL_SLAB WITH (NOLOCK) where Gen_ID = @source_Gen_id and Cmp_ID=@Source_Cmp_ID and Slab_Type = 'P'
		Open curLate 
			Fetch next from curLate  into @Late_From_hours,@Late_To_hours,@Late_mark_Deduction_Days,@Late_Slab_Type
			While @@fetch_status = 0                    
			Begin   
				exec P0050_GENERAL_DETAIL_SLAB @Slab_Id=0,@GEN_ID=@DESTINATION_GEN_ID,@Cmp_ID=@Cmp_ID,@From_hours=@Late_From_hours,@To_hours=@Late_To_hours,@Deduction_Days=@Late_mark_Deduction_Days,@tran_type='Inse',@Slab_Type=@Late_Slab_Type
				fetch next from curLate  into @Late_From_hours,@Late_To_hours,@Late_mark_Deduction_Days,@Late_Slab_Type
			end
		close curLate                     
		deallocate curLate 

End

If @LATE_MARK_SCENARIO = 2 
Begin
		Declare @FROM_MIN numeric(18,0)
		Declare @TO_MIN numeric(18,0)
		Declare @EXEMPTION_COUNT numeric(18,0)
		Declare @DEDUCTION numeric(18,2)
		Declare @DEDUCTION_TYPE Varchar(200)
		Declare @ONE_TIME_EXEMPTION numeric(18,0)
		
		Declare curLate_Mark cursor for	
		SELECT FROM_MIN,TO_MIN,EXEMPTION_COUNT,DEDUCTION,DEDUCTION_TYPE,ONE_TIME_EXEMPTION FROM T0050_GENERAL_LATEMARK_SLAB WITH (NOLOCK) where GEN_ID = @source_Gen_id and Cmp_ID=@Source_Cmp_ID 
		Open curLate_Mark
			Fetch next from  curLate_Mark Into @FROM_MIN,@TO_MIN,@EXEMPTION_COUNT,@DEDUCTION,@DEDUCTION_TYPE,@ONE_TIME_EXEMPTION
			WHILE @@Fetch_status = 0
				Begin
					Exec P0050_GENERAL_LATEMARK_SLAB @TRANS_ID = 0,@CMP_ID = @Cmp_ID,@FROM_MIN=@FROM_MIN,@TO_MIN = @TO_MIN,@EXEMPTION_COUNT = @EXEMPTION_COUNT,@DEDUCTION=@DEDUCTION,@DEDUCTION_TYPE = @DEDUCTION_TYPE,@GEN_ID = @DESTINATION_GEN_ID,@One_Time_Exemption = @ONE_TIME_EXEMPTION,@tran_type='I'
					Fetch next from  curLate_Mark Into @FROM_MIN,@TO_MIN,@EXEMPTION_COUNT,@DEDUCTION,@DEDUCTION_TYPE,@ONE_TIME_EXEMPTION
				End
		close curLate_Mark                     
		deallocate curLate_Mark 
End 
--added by jimit 27062017
If @LATE_MARK_SCENARIO = 3 
Begin
		--Declare @Trans_ID numeric(18,0)		
		Declare @Desig_ID numeric(18,0)
		DECLARE @NormalRate NUMERIC(18,2)
		DECLARE @LunchRate NUMERIC(18,2)
		
		Declare curLate_Mark_Designation cursor for	
		SELECT Desig_Id,Normal_Rate,Lunch_Rate FROM T0050_LateMark_Rate_Designation WITH (NOLOCK) where GEN_ID = @source_Gen_id and Cmp_ID=@Source_Cmp_ID 
		Open curLate_Mark_Designation
			Fetch next from  curLate_Mark_Designation Into @Desig_ID,@NormalRate,@LunchRate
			WHILE @@Fetch_status = 0
				Begin
					--SELECT @Trans_ID = max(Isnull(tran_Id,0)) + 1 from T0050_LateMark_Rate_Designation
					
					Exec P0050_LateMark_Rate_Designation @Tran_Id = 0,@Gen_Id = @DESTINATION_GEN_ID,@CMP_ID = @Cmp_ID,@Designation_ID = @Desig_ID,															
														 @Normal_Rate = @NormalRate,@Lunch_Rate = @LunchRate,@TRAN_TYPE = 'I'
					Fetch next from  curLate_Mark_Designation Into @Desig_ID,@NormalRate,@LunchRate
				End
		close curLate_Mark_Designation                     
		deallocate curLate_Mark_Designation 
End
--ended
--Added by Nilesh Patel on 15042019
If @LATE_MARK_SCENARIO = 4 
Begin
		Declare @FROM_MIN_SCENARIO4 numeric(18,0)
		Declare @TO_MIN_SCENARIO4 numeric(18,0)
		Declare @FROM_COUNT_SCENARIO4 numeric(18,0)
		Declare @TO_COUNT_SCENARIO4 numeric(18,0)
		Declare @DEDUCTION_SCENARIO4 numeric(18,2)
		
		Declare curLate_Mark_Secnario4 cursor for	
		SELECT FROM_MIN,TO_MIN,From_Count,To_Count,Deduction FROM T0050_GENERAL_LATEMARK_SLAB_SCENARIO4 WITH (NOLOCK) where GEN_ID = @source_Gen_id and Cmp_ID=@Source_Cmp_ID 
		Open curLate_Mark_Secnario4
			Fetch next from  curLate_Mark_Secnario4 Into @FROM_MIN_SCENARIO4,@TO_MIN_SCENARIO4,@FROM_COUNT_SCENARIO4,@TO_COUNT_SCENARIO4,@DEDUCTION_SCENARIO4
			WHILE @@Fetch_status = 0
				Begin
					Exec P0050_GENERAL_LATEMARK_SLAB_SCENARIO4 @TRANS_ID = 0,@CMP_ID = @Cmp_ID,@FROM_MIN=@FROM_MIN_SCENARIO4,@TO_MIN = @TO_MIN_SCENARIO4,@FROM_COUNT = @FROM_COUNT_SCENARIO4,@TO_COUNT = @TO_COUNT_SCENARIO4,@DEDUCTION=@DEDUCTION_SCENARIO4,@GEN_ID = @DESTINATION_GEN_ID,@MODIFY_BY = @User_Id,@IP_ADDRESS = @IP_Address
					Fetch next from  curLate_Mark_Secnario4 Into @FROM_MIN_SCENARIO4,@TO_MIN_SCENARIO4,@FROM_COUNT_SCENARIO4,@TO_COUNT_SCENARIO4,@DEDUCTION_SCENARIO4
				End
		close curLate_Mark_Secnario4                     
		deallocate curLate_Mark_Secnario4 
End 
--Added by Nilesh Patel on 15042019
If @EARLY_MARK_SCENARIO = 2	
    Begin
		Declare @Early_FROM_MIN numeric(18,0)
		Declare @Early_TO_MIN numeric(18,0)
		Declare @Early_DEDUCTION numeric(18,2)
		Declare @Early_DEDUCTION_TYPE Varchar(200)
		
		Declare curEarly_Mark cursor for	
		SELECT FROM_MIN,TO_MIN,DEDUCTION,DEDUCTION_TYPE FROM T0050_GENERAL_EARLYMARK_SLAB WITH (NOLOCK) where GEN_ID = @source_Gen_id and Cmp_ID=@Source_Cmp_ID 
		Open curEarly_Mark
			Fetch next from  curEarly_Mark Into @Early_FROM_MIN,@Early_TO_MIN,@Early_DEDUCTION,@Early_DEDUCTION_TYPE
			WHILE @@Fetch_status = 0
				Begin
					Exec P0050_GENERAL_EARLYMARK_SLAB @TRANS_ID = 0,@CMP_ID = @Cmp_ID,@FROM_MIN=@Early_FROM_MIN,@TO_MIN = @Early_TO_MIN,@DEDUCTION=@Early_DEDUCTION,@DEDUCTION_TYPE = @Early_DEDUCTION_TYPE,@GEN_ID = @DESTINATION_GEN_ID,@tran_type='I'
					Fetch next from  curEarly_Mark Into @Early_FROM_MIN,@Early_TO_MIN,@Early_DEDUCTION,@Early_DEDUCTION_TYPE
				End
		close curEarly_Mark                     
		deallocate curEarly_Mark
	End
/*
THIS SETTING WILL NOT BE COPIED ON BASIS OF GEN_ID , BUT WILL BE COPIEDD ON THE COMBINATION 
OF "BRANCH_ID" & "EFFECTIVE_DATE"
*/

if @Inc_Bonus=1
begin
		 DECLARE @TRAN_ID NUMERIC = 0
		 DECLARE @SOURCE_TRAN_ID NUMERIC = 0
		 DECLARE @DEST_TRAN_ID NUMERIC = 0
		 DECLARE @FOR_MAX_DATE DATETIME
			
		 
IF EXISTS (SELECT 1 FROM T0040_INCREMENT_CALC WITH (NOLOCK) WHERE CMP_ID = @SOURCE_CMP_ID AND BRANCH_ID = @SOURCE_BRANCHID)
	BEGIN
		--TAKING MAX DATE OF SOURCE BRANCH
		SELECT @FOR_MAX_DATE = MAX(FOR_DATE) FROM T0040_INCREMENT_CALC WITH (NOLOCK)
		WHERE CMP_ID = @Source_Cmp_ID AND BRANCH_ID = @Source_BranchID
	
		--TAKING TRAN_ID OF DESTINATION BRANCH , SO THAT WE CAN DELETE THE SLAB WITH ITS REFERENCE
		SELECT @DEST_TRAN_ID = TRAN_ID  FROM T0040_INCREMENT_CALC WITH (NOLOCK)
		WHERE FOR_DATE = @FOR_MAX_DATE AND CMP_ID = @DESTINATION_CMP_ID AND BRANCH_ID = @DESTINATION_BRANCHID 
		
		--DELETEING THE OLD ENTRIES OF DESTINATION BRANCH
		DELETE FROM T0045_INCREMENT_WAGES_SLAB  WHERE TRAN_ID = @DEST_TRAN_ID
		DELETE FROM T0045_INCREMENT_DAYS_SLAB   WHERE TRAN_ID = @DEST_TRAN_ID
		DELETE FROM T0040_INCREMENT_CALC  		WHERE TRAN_ID = @DEST_TRAN_ID
		
		----TAKING LATEST VALUES FROM SOURCE BRANCH
		SELECT @SOURCE_TRAN_ID = TRAN_ID 
		FROM T0040_INCREMENT_CALC WITH (NOLOCK)
		WHERE FOR_DATE = @FOR_MAX_DATE AND CMP_ID = @Source_Cmp_ID AND BRANCH_ID = @SOURCE_BRANCHID
		
		SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1  FROM dbo.T0040_INCREMENT_CALC WITH (NOLOCK)
		
		
		--INSERT NEW ENTREIS IN DESTINATION BRANCH	
		INSERT INTO dbo.T0040_INCREMENT_CALC
			(TRAN_ID,CMP_ID,FOR_DATE,BRANCH_ID,PARTICULARS,LOGIN_ID,SYSTEMDATE)
		SELECT  @TRAN_ID , @DESTINATION_CMP_ID , @FOR_MAX_DATE  , @Destination_BranchID , PARTICULARS  , LOGIN_ID , GETDATE()
		FROM T0040_INCREMENT_CALC WITH (NOLOCK)
		WHERE FOR_DATE = @FOR_MAX_DATE AND CMP_ID = @Source_Cmp_ID AND BRANCH_ID = @SOURCE_BRANCHID
		
		
		--INSERTING IN REST CHILD TABLES(T0045_INCREMENT_WAGES_SLAB)
		INSERT INTO dbo.T0045_INCREMENT_WAGES_SLAB
		(CMP_ID,TRAN_ID,FROM_WAGES,TO_WAGES,PERCENTAGE)
		SELECT @Source_Cmp_ID , @TRAN_ID , FROM_WAGES,TO_WAGES,PERCENTAGE
		FROM T0045_INCREMENT_WAGES_SLAB WITH (NOLOCK)
		WHERE TRAN_ID = @SOURCE_TRAN_ID AND CMP_ID = @Source_Cmp_ID
		
		--INSERTING IN REST CHILD TABLES(T0045_INCREMENT_DAYS_SLAB)
		INSERT INTO dbo.T0045_INCREMENT_DAYS_SLAB
			(CMP_ID,TRAN_ID,FROM_DAYS,TO_DAYS , PERCENTAGE)
		SELECT @Source_Cmp_ID , @TRAN_ID , FROM_DAYS,TO_DAYS ,PERCENTAGE
		FROM T0045_INCREMENT_DAYS_SLAB WITH (NOLOCK)
		WHERE TRAN_ID = @SOURCE_TRAN_ID AND CMP_ID = @Source_Cmp_ID
		
		
		
		--START - BONUS CALULCATION SLAB WISE
		
		
		--TAKING MAX DATE OF SOURCE BRANCH
		SELECT @FOR_MAX_DATE = MAX(FOR_DATE) FROM T0040_BONUS_CALC WITH (NOLOCK)
		WHERE CMP_ID = @Source_Cmp_ID AND BRANCH_ID = @Source_BranchID
	
		--TAKING TRAN_ID OF DESTINATION BRANCH , SO THAT WE CAN DELETE THE SLAB WITH ITS REFERENCE
		SELECT @DEST_TRAN_ID = TRAN_ID  FROM T0040_BONUS_CALC  WITH (NOLOCK)
		WHERE FOR_DATE = @FOR_MAX_DATE AND CMP_ID = @DESTINATION_CMP_ID AND BRANCH_ID = @DESTINATION_BRANCHID 
		
		--DELETEING THE OLD ENTRIES OF DESTINATION BRANCH
		DELETE FROM T0045_BONUS_DAYS_SLAB  WHERE TRAN_ID = @DEST_TRAN_ID
		DELETE FROM T0040_BONUS_CALC  		WHERE TRAN_ID = @DEST_TRAN_ID
		
		----TAKING LATEST VALUES FROM SOURCE BRANCH
		SELECT @SOURCE_TRAN_ID = TRAN_ID 
		FROM T0040_BONUS_CALC WITH (NOLOCK)
		WHERE FOR_DATE = @FOR_MAX_DATE AND CMP_ID = @Source_Cmp_ID AND BRANCH_ID = @SOURCE_BRANCHID
		
		SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1  FROM dbo.T0040_BONUS_CALC WITH (NOLOCK)
		
		--INSERT NEW ENTREIS IN DESTINATION BRANCH	
		INSERT INTO dbo.T0040_BONUS_CALC
			(TRAN_ID,CMP_ID,FOR_DATE,BRANCH_ID,PARTICULARS,LOGIN_ID,SYSTEMDATE)
		SELECT  @TRAN_ID , @DESTINATION_CMP_ID , @FOR_MAX_DATE  , @Destination_BranchID , PARTICULARS  , LOGIN_ID , GETDATE()
		FROM T0040_BONUS_CALC WITH (NOLOCK)
		WHERE FOR_DATE = @FOR_MAX_DATE AND CMP_ID = @Source_Cmp_ID AND BRANCH_ID = @SOURCE_BRANCHID
		
		
		--INSERTING IN REST CHILD TABLES(T0045_INCREMENT_WAGES_SLAB)
		INSERT INTO dbo.T0045_BONUS_DAYS_SLAB
		(CMP_ID,TRAN_ID,FROM_DAYS,To_Days,PERCENTAGE)
		SELECT @Source_Cmp_ID , @TRAN_ID , FROM_DAYS,TO_DAYS,PERCENTAGE
		FROM T0045_BONUS_DAYS_SLAB WITH (NOLOCK)
		WHERE TRAN_ID = @SOURCE_TRAN_ID AND CMP_ID = @Source_Cmp_ID
		
		
		
	END	
	
	
	
end

IF(ISNULL(@OT_RATE_TYPE,0) = 1) -- ADDED BY RAJPUT ON 13072018 FOR SLAB WISE OT SETTING
		BEGIN
		
			DECLARE @FROM_HOURS_P	NUMERIC(18,2)
			DECLARE @TO_HOURS_P	NUMERIC(18,2)
			DECLARE @WD_RATE_P NUMERIC(18,2)
			DECLARE @WO_RATE_P  NUMERIC(18,2)
			DECLARE @HO_RATE_P  NUMERIC(18,2)
			DECLARE @SYSTEM_DATE1 DATETIME = GETDATE()
			
			DECLARE CUROVERTIME CURSOR FOR	    
			SELECT FROM_HOURS,TO_HOURS,WD_RATE,WO_RATE,HO_RATE  FROM T0050_GENERAL_OT_RATE_SLABWISE WITH (NOLOCK) WHERE GEN_ID = @SOURCE_GEN_ID AND 
			CMP_ID=@SOURCE_CMP_ID 
			OPEN CUROVERTIME
			FETCH NEXT FROM CUROVERTIME INTO @FROM_HOURS_P,@TO_HOURS_P,@WD_RATE_P,@WO_RATE_P,@HO_RATE_P
			WHILE @@FETCH_STATUS = 0                    
			BEGIN     
			
				EXEC P0040_OT_CALC_SLAB @GEN_ID=@DESTINATION_GEN_ID,@CMP_ID=@CMP_ID,@FROM_HOURS=@FROM_HOURS_P,@TO_HOURS=@TO_HOURS_P,
				@WD_RATE=@WD_RATE_P,@WO_RATE=@WO_RATE_P,@HO_RATE=@HO_RATE_P,@SYSTEM_DATE = @SYSTEM_DATE1,@TRAN_TYPE='I'
				
				FETCH NEXT FROM CUROVERTIME INTO @FROM_HOURS_P,@TO_HOURS_P,@WD_RATE_P,@WO_RATE_P,@HO_RATE_P
			END
			CLOSE CUROVERTIME                    
			DEALLOCATE CUROVERTIME
		END




