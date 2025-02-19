

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_GENERAL_SETTING]
 @Gen_ID	numeric(18, 0) output
,@Cmp_ID	numeric(18, 0)
,@Branch_ID	numeric(18, 0)
,@For_Date	datetime
,@Inc_Weekoff	numeric(1, 0)
,@Is_OT	numeric(1, 0)
,@ExOT_Setting	numeric(18, 2)
,@Late_Limit	varchar(50)
,@Late_Adj_Day	numeric(18, 0)
,@Is_PT	numeric(1, 0)
,@Is_LWF	numeric(1, 0)
,@Is_Revenue	numeric(1, 0)
,@Is_PF	numeric(1, 0)
,@Is_ESIC	numeric(1, 0)
,@Is_Late_Mark	numeric(1, 0)
,@Is_Credit	numeric(1, 0)
,@LWF_Amount	numeric(18, 0)
,@LWF_Month	varchar(30)
,@Revenue_Amount	numeric(18, 0)
,@Revenue_On_Amount	numeric(18, 0)
,@Credit_Limit	numeric(18, 0)
,@Chk_Server_Date	numeric(1, 0)
,@Is_Cancel_Weekoff	numeric(1, 0)
,@Is_Cancel_Holiday	numeric(1, 0)
,@Is_Daily_OT	numeric(1, 0)
,@In_Punch_Duration	varchar(10)
,@Last_Entry_Duration	varchar(10)
,@OT_App_Limit	varchar(10)
,@OT_Max_Limit	varchar(10)
,@OT_Fix_Work_Day	numeric(18, 0)
,@OT_Fix_Shift_Hours	varchar(10)
,@OT_Inc_Salary	numeric(1, 0)
,@ESIC_Upper_Limit numeric(18,0)
,@ESIC_Employer_Contribution numeric(18,2)
,@inout_Days numeric(18,0)
,@Late_Fix_Work_Days numeric(5,1)
,@Late_Fix_shift_Hours varchar(50)
,@Late_Deduction_Days numeric(3,2)
,@Late_Extra_Deduction numeric(3,2)
,@Is_Late_Cal_On_HO_WO numeric(1)
,@Is_Late_CF tinyint
,@Late_CF_Reset_On Varchar(50)
,@Sal_St_Date DateTime  = null
,@Sal_Fix_Days numeric(18,1)
,@Sal_Inout  numeric(1,0)
,@tran_type varchar(1)

,@Last_bonus		dateTime = null
,@Gr_Min_Year		tinyint = 0
,@Gr_Cal_Month		tinyint =0
,@Gr_ProRata_Cal	tinyint = 0
,@Gr_Min_P_Days		numeric(5,2) =0 
,@Gr_Absent_Days	numeric(5,2)=0
,@Short_Fall_Days	numeric(5,2) =0
,@Gr_Days			numeric(5,2)=0
,@Gr_Percentage		numeric(5,2)=0
,@Short_Fall_W_Days numeric(5,2)=0
,@Leave_SMS         numeric(1,0)=0
,@CTC_Auto_Cal      numeric(1,0)=0
,@Inc_Holiday       numeric(1,0)=1
,@Probation         numeric(18,0)=0
,@Lv_Month			numeric(2,0)=0
,@Is_Shortfall_Gradewise tinyint =0    
,@Actual_Gross numeric (18,2) =0
,@Wage_Amount numeric (18,2) =0
,@Dep_Reim_Days numeric(18,0)=0
,@Con_Reim_Days numeric(18,0)=0
,@Late_With_Leave numeric(18,0)=0
,@Tras_Week_ot tinyint =0    
,@Bonus_Min_Limit Numeric(18,0)=0
,@Bonus_Max_Limit Numeric(18,0)=0
,@Bonus_Per Numeric(18,2)=0.00
,@Is_Organise_chart tinyint = 0
,@Is_Zero_Day_Salary tinyint=0
,@OT_Auto  tinyint =0
,@OT_Present tinyint =0
,@Is_Negative_Ot Int=0
,@Is_Present numeric(18,0)=0
,@Is_Amount numeric(18,0)=0
,@Mid_Increment numeric(18,0)=0
,@AD_Rounding numeric(18,0)=0
,@Lv_Salary_Effect_on_PT numeric=0--'Added By Falak on 16-FEB-2011
,@Lv_Encash_W_Day numeric=0--'Added By Falak on 16-FEB-2011
,@Lv_Encash_Cal_On Varchar(50)=0--'Added By Falak on 16-FEB-2011
,@In_Out_Login Int = 0 --'Added By Nikunj on 18-May-2011
,@LWF_Max_Amount Numeric(18,2)=0.0
,@LWF_Over_Amount Numeric(18,2)=0.0
,@First_In_Last_Out_For_Att_Regularization tinyint = 0--Alpesh 04-Aug-2011
,@First_In_Last_Out_For_InOut_Calculation tinyint = 0 --Alpesh 04-Aug-2011
,@Late_Count_Exemption	numeric(18, 2)	= 0.0 -- Start Added by Mitesh on 18/08/2011
,@Early_Limit	varchar(50)	= ''
,@Early_Adj_Day	numeric(18, 0)	= 0
,@Early_Deduction_Days	numeric(3,2)	 = 0.0
,@Early_Extra_Deduction	numeric(3,2)	= 0.0
,@Early_CF_Reset_On	varchar(50)	= ''
,@Is_Early_Calc_On_HO_WO	tinyint	= 0
,@Is_Early_CF	tinyint	= 0
,@Early_With_Leave	numeric(1, 0)	= 0
,@Early_Count_Exemption	numeric(18, 2)= 0.0	
,@Deficit_Limit	varchar(50)	= ''
,@Deficit_Adj_Day	numeric(18, 0)	= 0
,@Deficit_Deduction_Days	numeric(3,1)	= 0.0
,@Deficit_Extra_Deduction	numeric(3,1)	= 0.0
,@Deficit_CF_Reset_On	varchar(50)	= ''
,@Is_Deficit_Calc_On_HO_WO	tinyint	= 0
,@Is_Deficit_CF	tinyint	= 0
,@Deficit_With_Leave	numeric(1, 0) = 0
,@Deficit_Count_Exemption	numeric(18, 2)= 0.0 
,@In_Out_Login_Popup Int = 0 -- ^ End Added by Mitesh on 18/08/2011
,@Late_Hour_Upper_Rounding numeric(18,2) = 0.0
,@is_Late_Calc_Slabwise tinyint = 0
,@Late_Calculate_type nvarchar(10) = 'Hour'
,@Early_Hour_Upper_Rounding numeric(18,2) = 0.0
,@is_Early_Calc_Slabwise tinyint = 0
,@Early_Calculate_type nvarchar(10) = 'Hour'
,@Is_Basic_Salary tinyint=0
,@Is_PreQuestion tinyint = 0 --Added by Sneha for exit on 26 march 2012
,@Is_CompOff tinyint = 0 --Added by Mihir Trivedi on 05/10/2012 for compoff
,@CompOff_limit numeric(18,0) = 1 --Added by Mihir Trivedi on 05/10/2012 for compoff
,@CompOff_Min_Hours varchar(10) = '00:00' --Added by Mihir Trivedi on 12/05/2012 for compoff
,@Is_CompOff_WD tinyint = 1 --Added by Mihir Trivedi on 18/05/2012 for compoff
,@Is_CompOff_WOHO tinyint = 1 --Added by Mihir Trivedi on 18/05/2012 for compoff
,@Is_CF_On_Sal_Days tinyint = 0		----Alpesh 22-May-2012
,@Days_As_Per_Sal_Days tinyint = 0	----Alpesh 22-May-2012
,@Max_Late_Limit varchar(50) = '00:00'	--Alpesh 20-Jul-2012
,@Max_Early_Limit varchar(50) = '00:00'	--Alpesh 20-Jul-2012
,@Manual_Inout int = 0	--Alpesh 20-Jul-2012
,@Allow_Negative_Salary tinyint = 0 --Mihir Trivedi 25/07/2012
,@ESIC_OT_Allow Tinyint = 0
,@CompOff_Avail_Days Numeric(18,0) = 0
,@Paid_WeekOff_Daily_Wages tinyint =0
,@Allowed_Full_WeekOf_MidJoining tinyint =0 ---Jignesh 03-Sep-2012
,@is_weekoff_hour tinyint = 0
,@weekoff_hours nvarchar(50) = ''
,@is_all_emp_prob tinyint = 0				-- Added By Hiral On 13 Oct,2012
--132
,@User_Id numeric(18,0) = 0
,@IP_Address varchar(30)= ''         --Add By Paras 15-10-2012
,@Max_Late_Exem_Limit varchar(50) = '00:00'	--Alpesh 20-Jul-2012
,@Max_Early_Exem_Limit varchar(50) = '00:00'	--Alpesh 20-Jul-2012
,@Max_Bonus_salary_Amount numeric(18,2)=0	--Ankit	12042013
,@Optional_Holiday_Days numeric(10,0)=0	--Ankit	12042013
,@Is_OD_Transfer_to_OT Tinyint=0	--Rohit	13082013
,@Is_Co_hour_Editable Tinyint = 0	--Rohit on 13082013
,@Bonus_Entitle_Limit numeric(18,2)=0				--Ankit	10102013
,@Allowed_Full_WeekOf_MidJoining_DayRate tinyint =0 --Ankit 11102013
,@Monthly_Deficit_Adjust_OT_Hrs tinyint =0			--Ankit 25102013
,@Half_Day_Excepted_Count Numeric(18,2) =0 --Hardik 13/02/2014
,@Half_Day_Excepted_Max_Count Numeric(18,2) =0 --Hardik 13/02/2014
,@H_Comp_Off numeric =0								--Sid 05022014
,@H_CompOff_Limit numeric = 0						--Sid 05022014
,@H_Min_CompOff_Hours varchar(max) = '00:00'		--Sid 05022014
,@H_CompOff_Avail_Days numeric = 0					--Sid 05022014
,@W_Comp_Off numeric =0								--Sid 05022014
,@W_CompOff_Limit numeric = 0						--Sid 05022014
,@W_Min_CompOff_Hours varchar(max) = '00:00'		--Sid 05022014
,@W_CompOff_Avail_Days numeric = 0					--Sid 05022014
,@AllowShowODOptInCompOff numeric = 0				--Sid 28022014
,@Is_H_Co_hour_Editable Tinyint = 0					--Sid 20/03/2014
,@Is_W_Co_hour_Editable Tinyint = 0					--Sid 20/03/2014
,@Net_Salary_Round int = -1							--Added By Gadriwala 03042014
,@type_net_salary_round varchar(10) = ''			--Added By Gadriwala 03042014
,@Day_For_Security_Deposit numeric(3,0)=0          -- Added by rohit on 10-apr-2014
,@OT_RoundingOff_To		numeric(18,2)=0.00			--Added by Sid 20052014
,@OT_Roundingoff_Lower	numeric(1,0)=0				--Added by Sid 20052014
,@MinWOLimit	numeric(18,0) = 0					--Added by Ali 05062014
,@MaxWOLimit	numeric(18,0) =0					--Added by Ali 05062014
,@Chk_OT_limit_Before_Shift tinyint=0
,@Chk_lv_on_Working tinyint=0						--Added by sumit 26112014
--,@Chk_Leave_SMS tinyint=0							--Added by sumit 01/01/2015
,@Chk_Attendance_SMS tinyint=0						--Added by sumit 01/01/2015
,@Sal_CutOf_Date datetime=null						--Added by sumit 19/01/2015		
,@Max_Cnt_Reg numeric(18,0)=0						--Added by Sumit 17/02/2015
,@Manual_Salary_Prd tinyint=0						--Added by Sumit 20/02/2015
,@Is_WO_OD tinyint = 1								--Added by Gadriwala Muslim 02042015
,@Is_HO_OD tinyint = 1								--Added by Gadriwala Muslim 02042015
,@Is_WD_OD tinyint = 1								--Added by Gadriwala Muslim 02042015
,@DayRate_WO_Cancel tinyint=0						--Added by Hardik Barot 20/05/2015
,@Training_Month Numeric(18,0)=0									--Added by Nilesh Patel 29/05/2015
,@Dep_Reim_Days_Traning tinyint=0					--Added by Nilesh Patel 29/05/2015
,@Fnf_Fix_Day Numeric(18,0) = 0
,@LateEarlyExemMaxLimit	VARCHAR(20) = '00:00'		--Ankit 03112015
,@LateEarlyExempCount	NUMERIC(18,2) = 0			--Ankit 03112015
,@Is_Cancel_Holiday_WO_HO_same_day tinyint=0  -- Added by Nilesh Patel On 18112015
,@Is_Restrict_Present_days Char = 'Y'	--Added By Ramiz on 08/01/2016
,@Emp_Weekday_OT_Rate NUMERIC(10,3) = 0.000 --Added by nilesh patel on 09/01/2016
,@Emp_Weekoff_OT_Rate NUMERIC(10,3) = 0.000 --Added by nilesh patel on 09/01/2016
,@Emp_Holiday_OT_Rate NUMERIC(10,3) = 0.000 --Added by nilesh patel on 09/01/2016
,@Full_PF NUMERIC(1,0) = 0 --Added by nilesh patel on 09/01/2016
,@Company_Full_PF NUMERIC(1,0) = 0 --Added by nilesh patel on 09/01/2016
,@present_on_holiday NUMERIC(1,0) = 0 
,@Rate_of_national_holiday NUMERIC(5,2) = 0 
,@Late_Mark_Scenario NUMERIC(1,0) = 1 --Added by nilesh patel on 19052016 
,@Late_Adj_Again_OT NUMERIC(2,0) = 0 --Added by nilesh patel on 26052016 
,@Allowed_FullWeekof_MidLeft tinyint = 0 
,@Allowed_FullWeekof_MidLeft_DayRate tinyint = 0 --Added by Sumit 30052016

,@Audit_Daily_OT_limit As numeric(18,2) = 0 -- Added By Jaina 19-08-2016
,@Audit_Daily_Exemption_OT_limit As numeric(18,2) = 0 -- Added By Jaina 19-08-2016
,@Audit_Daily_Final_OT_limit As numeric(18,2) = 0 -- Added By Jaina 19-08-2016
,@Audit_Weekly_OT_limit As numeric(18,2) = 0 -- Added By Jaina 19-08-2016
,@Audit_Weekly_Exemption_OT_limit As numeric(18,2) = 0 -- Added By Jaina 19-08-2016
,@Audit_Weekly_Final_OT_limit As numeric(18,2) = 0 -- Added By Jaina 19-08-2016
,@Audit_Monthly_OT_limit As numeric(18,2) = 0 -- Added By Jaina 19-08-2016
,@Audit_Monthly_Exemption_OT_limit As numeric(18,2) = 0 -- Added By Jaina 19-08-2016
,@Audit_Monthly_Final_OT_limit As numeric(18,2) = 0 -- Added By Jaina 19-08-2016
,@Audit_Quarterly_OT_limit As numeric(18,2) = 0 -- Added By Jaina 19-08-2016
,@Audit_Quarterly_Exemption_OT_limit As numeric(18,2) = 0 -- Added By Jaina 19-08-2016
,@Audit_Quarterly_Final_OT_limit As numeric(18,2) = 0 -- Added By Jaina 19-08-2016
,@Validity_Period_Type tinyint = 0 -- Added by Jaina 23-08-2016
,@COPH_Avail_limit numeric(18,0) = 0				-- 
,@COND_avail_limit numeric(18,0) = 0 --Added by Sumit 29092016
,@Is_Customer_Audit tinyint = 0  --Added By Jaina 01-10-2016
,@Is_Bonus_Inc	tinyint = 0  --added by jimit 03042017
,@Is_Regular_Bon	tinyint = 0  --added by Rajput 19042017
,@Is_LateMark_Percent Numeric(18,2) = 0 
,@Is_LateMark_Cal_On Numeric(1,0) = 0
,@Probation_Review VARCHAR(15)='' --Mukti(02122017)
,@Trainee_Review VARCHAR(15)=''--Mukti(02122017)
,@Late_Limit_Regularization varchar(50) = '00:00' --Added by Jaina 11-01-2018
,@Show_PT_in_Payslip_if_Zero int = 0	-- Added by Krushna 28-05-2018
,@Show_LWF_in_Payslip_if_Zero int = 0	-- Added by Krushna 28-05-2018
,@Is_Check_Late_Early_Combine bit = 0
,@Check_Last_LateEarly int = 0
,@Global_Sal_Days int = 0 --Hardik 26/06/2018 for Lubi
,@Is_OT_Adj_against_Absent int = 0
,@OTRateType TINYINT = 0 --Added by Rajput on 03072018
,@OTSlabType TINYINT = 0 --Added by Rajput on 03072018
,@Is_Probation_Month_Days TINYINT = 0 --Added by Mukti(15102018)
,@Is_Trainee_Month_Days TINYINT = 0 --Added by Mukti(15102018)
,@Early_Mark_Scenario TINYINT = 1 --Added by Nilesh 19042019
,@Is_EarlyMark_percent TINYINT = 1 --Added by Nilesh 19042019
,@Is_EarlyMark_Cal_On TINYINT = 1 --Added by Nilesh 19042019
,@Holiday_CompOff_Avail_After_Days TINYINT = 1 --added binal 31012020
,@Weekoff_COPH_Avail_After_Days  TINYINT = 1 --added binal 01022020
,@Weekday_COPH_Avail_After_Days  TINYINT = 1 --added binal 01022020
,@Attendance_Reg_Weekday nvarchar(50) = ''  ---Added by Jaina 01-05-2020
,@Approval_Up_To_Date tinyint = 0  --Added by Jaina 01-05-2020
,@LateEarly_Combine tinyint  = 0 --Added by Jaina 21-09-2020
,@Monthly_Exemption_Limit varchar(20) = '00:00' --Added by Jaina 21-09-2020
,@CancelHolidayOneSideAbsent INT = null
,@CancelWeekoffOneSideAbsent INT = null
,@LateEarly_MonthWise tinyint  = 0 --Added by Jaina 21-09-2020
AS


SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


declare @OldValue as  varchar(max)
Declare @String as varchar(max)

set @String =''
set @OldValue = ''


--declare @OldCmp_ID	 as varchar(18)

declare @OldFor_Date as datetime
declare @OldInc_Weekoff as varchar(1)
declare @OldIs_OT as varchar(1)
declare @OldExOT_Setting as varchar(20)
declare @OldLate_Limit as varchar(50)
declare @OldLate_Adj_Day as varchar(18)
declare @OldIs_PT as varchar(1)

declare @OldIs_LWF as varchar(1)
declare @OldIs_Revenue as varchar(1)
declare @OldIs_PF as varchar(1)
declare @OldIs_ESIC as varchar(1)
declare @OldIs_Late_Mark as varchar(1)
declare @OldIs_Credit as varchar(1)

declare @OldLWF_Amount as varchar(18)
declare @OldLWF_Month as varchar(30)
declare @OldRevenue_Amount as varchar(18)
declare @OldRevenue_On_Amount as varchar(18)
declare @OldCredit_Limit as varchar(18)
declare @OldChk_Server_Date as varchar(1)
declare @OldIs_Cancel_Weekoff as varchar(1)
declare @OldIs_Cancel_Holiday as varchar(1)
declare @OldIs_Daily_OT as varchar(1)

declare @OldIn_Punch_Duration as varchar(10)
declare @OldLast_Entry_Duration as varchar(10)
declare @OldOT_App_Limit as varchar(10)
declare @OldOT_Max_Limit as varchar(10)
declare @OldOT_Fix_Work_Day as varchar(18)
declare @OldOT_Fix_Shift_Hours as varchar(10)
declare @OldOT_Inc_Salary as varchar(1)
declare @OldESIC_Upper_Limit as varchar(180)
declare @OldESIC_Employer_Contribution as varchar(182)
declare @Oldinout_Days as varchar(180)
declare @OldLate_Fix_Work_Days as varchar(51)
declare @OldLate_Fix_shift_Hours as varchar(50)
declare @OldLate_Deduction_Days as varchar(31)
declare @OldLate_Extra_Deduction as varchar(31)

declare @OldIs_Late_Cal_On_HO_WO as varchar(1)
declare @OldIs_Late_CF as varchar(1)
declare @OldLate_CF_Reset_On as varchar(50)
declare @OldSal_St_Date as dateTime
declare @OldSal_Fix_Days as varchar(181)
declare @OldSal_Inout as varchar(10)
declare @OldLast_bonus as datetime
declare @OldGr_Min_Year as varchar(1)
declare @OldGr_Cal_Month as varchar(1)
declare @OldGr_ProRata_Cal as varchar(1)
declare @OldGr_Min_P_Days as varchar(52)
declare @OldGr_Absent_Days as varchar(52)
declare @OldShort_Fall_Days as varchar(52)
declare @OldGr_Days as varchar(52)

declare @OldGr_Percentage as varchar(52)
declare @OldShort_Fall_W_Days as varchar(52)
declare @OldLeave_SMS as varchar(10)
declare @OldCTC_Auto_Cal  as varchar(10)
declare @OldInc_Holiday as varchar(10)
declare @OldProbation  as varchar(20)
declare @OldLv_Month as varchar(20)
declare @OldIs_Shortfall_Gradewise as varchar(1)
declare @OldActual_Gross  as varchar(182)
declare @OldWage_Amount as varchar(182)
declare @OldDep_Reim_Days as varchar(180)
declare @OldCon_Reim_Days as varchar(180)
declare @OldLate_With_Leave as varchar(180)
declare @OldTras_Week_ot as varchar(1)


declare @OldBonus_Min_Limit as varchar(180)
declare @OldBonus_Max_Limit as varchar(180)
declare @OldBonus_Per as varchar(182)
declare @OldIs_Organise_chart  as varchar(1)
declare @OldIs_Zero_Day_Salary as varchar(1)
declare @OldOT_Auto  as varchar(1)
declare @OldOT_Present as varchar(1)
declare @OldIs_Negative_Ot as varchar(4)
declare @OldIs_Present  as varchar(180)
declare @OldIs_Amount as varchar(180)
declare @OldMid_Increment as varchar(180)
declare @OldAD_Rounding  as varchar(180)
declare @OldLv_Salary_Effect_on_PT as varchar(20)
declare @OldLv_Encash_W_Day as varchar(20)

declare @OldLv_Encash_Cal_On as varchar(50)
declare @OldIn_Out_Login as varchar(4)
declare @OldLWF_Max_Amount as varchar(182)
declare @OldLWF_Over_Amount  as varchar(182)
declare @OldFirst_In_Last_Out_For_Att_Regularization as  varchar(1)
declare @OldFirst_In_Last_Out_For_InOut_Calculation  as varchar(1)
declare @OldLate_Count_Exemption as varchar(18)
declare @OldEarly_Limit as varchar(50)
declare @OldEarly_Adj_Day  as varchar(18)
declare @OldEarly_Deduction_Days as varchar(31)
declare @OldEarly_Extra_Deduction as varchar(31)
declare @OldEarly_CF_Reset_On  as varchar(50)
declare @OldIs_Early_Calc_On_HO_WO as varchar(1)
declare @OldIs_Early_CF as varchar(1)

declare @OldEarly_With_Leave as varchar(1)
declare @OldEarly_Count_Exemption as varchar(18)
declare @OldDeficit_Limit as varchar(50)
declare @OldDeficit_Adj_Day  as varchar(18)
declare @OldDeficit_Deduction_Days as  varchar(31)
declare @OldDeficit_Extra_Deduction as varchar(31)
declare @OldDeficit_CF_Reset_On as varchar(50)
declare @OldIs_Deficit_Calc_On_HO_WO as varchar(1)
declare @OldIs_Deficit_CF  as varchar(1)
declare @OldDeficit_With_Leave as varchar(1)
declare @OldDeficit_Count_Exemption as varchar(18)
declare @OldIn_Out_Login_Popup  as varchar(4)
declare @OldLate_Hour_Upper_Rounding as varchar(182)
declare @Oldis_Late_Calc_Slabwise  as varchar(1)

declare @OldLate_Calculate_type as varchar(10)
declare @OldEarly_Hour_Upper_Rounding as varchar(182)
declare @Oldis_Early_Calc_Slabwise as varchar(1)
declare @OldEarly_Calculate_type  as varchar(10)
declare @OldIs_Basic_Salary as  varchar(1)
declare @OldIs_PreQuestion as varchar(1)
declare @OldIs_CompOff as varchar(1)
declare @OldCompOff_limit as varchar(180)
declare @OldCompOff_Min_Hours  as varchar(10)
declare @OldIs_CompOff_WD  as varchar(1)
declare @OldIs_CompOff_WOHO as varchar(1)
declare @OldIs_CF_On_Sal_Days  as varchar(1)
declare @OldDays_As_Per_Sal_Days as varchar(1)
declare @OldMax_Late_Limit varchar(50)


declare @OldMax_Early_Limit as varchar(50)
declare @OldManual_Inout as varchar(4)
declare @OldAllow_Negative_Salary as varchar(1)
declare @OldESIC_OT_Allow  as varchar(1)
declare @OldCompOff_Avail_Days as  varchar(180)
declare @OldPaid_WeekOff_Daily_Wages as varchar(1)
declare @OldAllowed_Full_WeekOf_MidJoining as varchar(1)
declare @Oldis_weekoff_hour as varchar(180)
declare @Oldweekoff_hours  as varchar(50)
declare @Oldis_all_emp_prob  as varchar(1)
declare @OldMax_Bonus_salary_Amount as Varchar(180)
declare @OldIs_OD_Transfer_to_OT as Varchar(1)
declare @OldIs_Co_hour_Editable as Varchar(1)
declare @OldBonus_Entitle_Limit as varchar(100)
declare @OldAllowed_Full_WeekOf_MidJoining_DayRate as varchar(1)
declare @OldMonthly_Deficit_Adjust_OT_Hrs as Varchar(1)
declare @OldDay_For_Security_Deposit as varchar(3)

declare @OldChk_OT_limit_Before_Shift as tinyint

DECLARE @OldIs_H_Co_hour_Editable AS VARCHAR(1)			--sid 20/03/2014
DECLARE @oldIs_W_Co_hour_Editable AS VARCHAR(1)			--sid 20/03/2014

declare @OldH_Comp_Off numeric 								--Sid 05022014
		,@OldH_CompOff_Limit numeric 						--Sid 05022014
		,@OldH_Min_CompOff_Hours varchar(max) 				--Sid 05022014
		,@OldH_CompOff_Avail_Days numeric 					--Sid 05022014

declare @OldW_Comp_Off numeric 								--Sid 05022014
		,@OldW_CompOff_Limit numeric 						--Sid 05022014
		,@OldW_Min_CompOff_Hours varchar(max) 				--Sid 05022014
		,@OldW_CompOff_Avail_Days numeric 					--Sid 05022014

declare @OldAllowShowODOptInCompOff numeric					--Sid 28022014
declare @OldNet_Salary_Round varchar(5)						--Gadriwala Muslim 03042014
declare @Oldtype_net_salary_round varchar(10)	

declare @OldOT_RoundingOff_To		numeric(18,2)			--Sid 20052014
declare @OldOT_RoundingOff_Lower	numeric(1,0)			--Sid 20052014

declare @Old_lv_on_wroking tinyint

declare @Old_LeaveSMS tinyint
declare @Old_AttendanceSMS tinyint
declare @OldSal_Cutoff_Date as datetime
SET @OldSal_Cutoff_Date=null
declare @OldMax_Cnt_Reg as Numeric(18,0)				--Added by sumit 18022015
declare @OldManual_Salary_Prd as tinyint					--Added by Sumit 20022015

set @OldMax_Cnt_Reg = 0 --Added by Sumit 20022015
set @OldManual_Salary_Prd = 0 --Added by Sumit 20022015

Declare @OldIs_WO_OD as tinyint -- Added by Gadriwala Muslim 31032015
Declare @OldIs_HO_OD as tinyint -- Added by Gadriwala Muslim 31032015
Declare @OldIs_WD_OD as tinyint -- Added by Gadriwala Muslim 31032015
set @OldIs_WO_OD  = 1 -- Added by Gadriwala Muslim 31032015
set @OldIs_HO_OD  = 1 -- Added by Gadriwala Muslim 31032015
set @OldIs_WD_OD = 1 -- Added by Gadriwala Muslim 31032015

DECLARE @OldLateEarlyExemMaxLimit	VARCHAR(20) 		--Ankit 03112015
DECLARE @OldLateEarlyExempCount		NUMERIC(18,2) 		--Ankit 03112015
SET @OldLateEarlyExemMaxLimit	= '00:00'
SET @OldLateEarlyExempCount		= 0

Declare @Old_Is_Cancel_Holiday_WO_HO_same_day NUMERIC(3,0)
Set @Old_Is_Cancel_Holiday_WO_HO_same_day = 0

Declare @Old_Is_Restrict_Present_days Char	--Ramiz 08/01/2016
Set @Old_Is_Restrict_Present_days = ' '

Declare @Old_Emp_WeekDay_OT_Rate as Numeric(10,3) --Added by nilesh patel on 09012016
Declare @Old_Emp_WeekOff_OT_Rate as Numeric(10,3) --Added by nilesh patel on 09012016
Declare @Old_Emp_Holiday_OT_Rate as Numeric(10,3) --Added by nilesh patel on 09012016

--declare @String as varchar(max)
--set @String = ''

set   @OldValue = ''
set   @OldFor_Date = ' '
set   @OldInc_Weekoff = ' '
set   @OldIs_OT = ' '
set   @OldExOT_Setting = ' '
set   @OldLate_Limit = ' '
set   @OldLate_Adj_Day = ' '
set   @OldIs_PT = ' '

set   @OldIs_LWF = ' '
set   @OldIs_Revenue = ' '
set   @OldIs_PF = ' '
set   @OldIs_ESIC = ' '
set   @OldIs_Late_Mark = ' '
set   @OldIs_Credit = ' '

set   @OldLWF_Amount = ' '
set   @OldLWF_Month = ' '
set   @OldRevenue_Amount = ' '
set   @OldRevenue_On_Amount = ' '
set   @OldCredit_Limit = ' '
set   @OldChk_Server_Date = ' '
set   @OldIs_Cancel_Weekoff = ' '
set   @OldIs_Cancel_Holiday = ' '
set   @OldIs_Daily_OT = ' '

set   @OldIn_Punch_Duration = ' '
set   @OldLast_Entry_Duration = ' '
set   @OldOT_App_Limit = ' '
set   @OldOT_Max_Limit = ' '
set   @OldOT_Fix_Work_Day = ' '
set   @OldOT_Fix_Shift_Hours = ' '
set   @OldOT_Inc_Salary = ' '
set   @OldESIC_Upper_Limit = ' '
set   @OldESIC_Employer_Contribution = ' '
set   @Oldinout_Days = ' '
set   @OldLate_Fix_Work_Days = ' '
set   @OldLate_Fix_shift_Hours = ' '
set   @OldLate_Deduction_Days = ' '
set   @OldLate_Extra_Deduction = ' '

set   @OldIs_Late_Cal_On_HO_WO = ' '
set   @OldIs_Late_CF = ' '
set   @OldLate_CF_Reset_On = ' '
set   @OldSal_St_Date = ' '
set   @OldSal_Fix_Days = ' '
set   @OldSal_Inout = ' '
set   @OldLast_bonus = ' '
set   @OldGr_Min_Year = ' '
set   @OldGr_Cal_Month = ' '
set   @OldGr_ProRata_Cal = ' '
set   @OldGr_Min_P_Days = ' '
set   @OldGr_Absent_Days = ' '
set   @OldShort_Fall_Days = ' '
set   @OldGr_Days = ' '

set   @OldGr_Percentage = ' '
set   @OldShort_Fall_W_Days = ' '
set   @OldLeave_SMS = ' '
set   @OldCTC_Auto_Cal  = ' '
set   @OldInc_Holiday = ' '
set   @OldProbation  = ' '
set   @OldLv_Month = ' '
set   @OldIs_Shortfall_Gradewise = ' '
set   @OldActual_Gross  = ' '
set   @OldWage_Amount = ' '
set   @OldDep_Reim_Days = ' '
set   @OldCon_Reim_Days = ' '
set   @OldLate_With_Leave = ' '
set   @OldTras_Week_ot = ' '


set   @OldBonus_Min_Limit = ' '
set   @OldBonus_Max_Limit = ' '
set   @OldBonus_Per = ' '
set   @OldIs_Organise_chart  = ' '
set   @OldIs_Zero_Day_Salary = ' '
set   @OldOT_Auto  = ' '
set   @OldOT_Present = ' '
set   @OldIs_Negative_Ot = ' '
set   @OldIs_Present  = ' '
set   @OldIs_Amount = ' '
set   @OldMid_Increment = ' '
set   @OldAD_Rounding  = ' '
set   @OldLv_Salary_Effect_on_PT = ' '
set   @OldLv_Encash_W_Day = ' '

set   @OldLv_Encash_Cal_On = ' '
set   @OldIn_Out_Login = ' '
set   @OldLWF_Max_Amount = ' '
set   @OldLWF_Over_Amount  = ' '
set   @OldFirst_In_Last_Out_For_Att_Regularization = ' '
set   @OldFirst_In_Last_Out_For_InOut_Calculation  = ' '
set   @OldLate_Count_Exemption = ' '
set   @OldEarly_Limit = ' '
set   @OldEarly_Adj_Day  = ' '
set   @OldEarly_Deduction_Days = ' '
set   @OldEarly_Extra_Deduction = ' '
set   @OldEarly_CF_Reset_On  = ' '
set   @OldIs_Early_Calc_On_HO_WO = ' '
set   @OldIs_Early_CF = ' '

set   @OldEarly_With_Leave = ' '
set   @OldEarly_Count_Exemption = ' '
set   @OldDeficit_Limit = ' '
set   @OldDeficit_Adj_Day  = ' '
set   @OldDeficit_Deduction_Days = ' '
set   @OldDeficit_Extra_Deduction = ' '
set   @OldDeficit_CF_Reset_On = ' '
set   @OldIs_Deficit_Calc_On_HO_WO = ' '
set   @OldIs_Deficit_CF  = ' '
set   @OldDeficit_With_Leave = ' '
set   @OldDeficit_Count_Exemption = ' '
set   @OldIn_Out_Login_Popup  = ' '
set   @OldLate_Hour_Upper_Rounding = ' '
set   @Oldis_Late_Calc_Slabwise  = ' '

set   @OldLate_Calculate_type = ' '
set   @OldEarly_Hour_Upper_Rounding = ' '
set   @Oldis_Early_Calc_Slabwise = ' '
set   @OldEarly_Calculate_type  = ' '
set   @OldIs_Basic_Salary = ' '
set   @OldIs_PreQuestion = ' '
set   @OldIs_CompOff = ' '
set   @OldCompOff_limit = ' '
set   @OldCompOff_Min_Hours  = ' '
set   @OldIs_CompOff_WD  = ' '
set   @OldIs_CompOff_WOHO = ' '
set   @OldIs_CF_On_Sal_Days  = ' '
set   @OldDays_As_Per_Sal_Days = ' '
set   @OldMax_Late_Limit = ' '


set   @OldMax_Early_Limit = ' '
set   @OldManual_Inout = ' '
set   @OldAllow_Negative_Salary = ' '
set   @OldESIC_OT_Allow  = ' '
set   @OldCompOff_Avail_Days = ' '
set   @OldPaid_WeekOff_Daily_Wages = ' '
set   @OldAllowed_Full_WeekOf_MidJoining = ' '
set   @Oldis_weekoff_hour = ' '
set   @Oldweekoff_hours  = ' '
set   @Oldis_all_emp_prob  = ' '
set	  @OldMax_Bonus_salary_Amount=''
set   @OldIs_OD_Transfer_to_OT = 0
Set   @OldIs_Co_hour_Editable = 0
set   @OldBonus_Entitle_Limit =' '
set   @OldAllowed_Full_WeekOf_MidJoining_DayRate = ' '
set   @OldMonthly_Deficit_Adjust_OT_Hrs = ' '

Set	@OldH_Comp_Off = 0								--Sid 05022014
set @OldH_CompOff_Limit = 0							--Sid 05022014
Set @OldH_Min_CompOff_Hours  = '00:00'				--Sid 05022014
set @OldH_CompOff_Avail_Days= 0						--Sid 05022014

Set @OldW_Comp_Off =0								--Sid 05022014
set	@OldW_CompOff_Limit = 0							--Sid 05022014
set	@OldW_Min_CompOff_Hours = '00:00'				--Sid 05022014
set	@OldW_CompOff_Avail_Days = 0					--Sid 05022014

set @oldAllowShowODOptInCompOff = 0					--Sid 28022014
SET @OldIs_H_Co_hour_Editable = 0					--Sid 20032014
SET @oldIs_W_Co_hour_Editable = 0					--Sid 20032014

set @OldNet_Salary_Round = -1						--Gadriwala Muslim 03042014
set @Oldtype_net_salary_round = ''					--Gadriwala Muslim 03042014

set	  @OldDay_For_Security_Deposit =	''
set @OldOT_RoundingOff_To = 0.00					--Sid 20052014
set @OldOT_RoundingOff_Lower = 0					--Sid 20052014
set @OldChk_OT_limit_Before_Shift=0
set @Old_lv_on_wroking =0							--Added by sumit 26112014
--set @Old_LeaveSMS=0
set @Old_AttendanceSMS=0

set @OldSal_Cutoff_Date=null

Set @Old_Emp_WeekDay_OT_Rate = 0.000 --Added by nilesh Patel on 09012016
Set @Old_Emp_WeekOff_OT_Rate = 0.000 --Added by nilesh Patel on 09012016
Set @Old_Emp_Holiday_OT_Rate = 0.000 --Added by nilesh Patel on 09012016

Declare @Old_Full_PF Numeric(1,0)
Declare @Old_Company_Full_PF Numeric(1,0)

Set @Old_Full_PF  = 0
Set @Old_Company_Full_PF = 0




	if @Sal_St_Date =  ''
		set  @Sal_St_Date = null
	
	if @Last_bonus = ''
		set @Last_bonus = null
		
	if @Sal_CutOf_Date =  ''
		set  @Sal_CutOf_Date = null	
			
   Set @OT_Inc_Salary = 1--NIkunj Put because it's static in insert from very early.and in update it's parameter and parameter pass 0 from form level so sometime it ALTER Problem 7-Jan-2011			

	if @Branch_ID = 0
		begin
			Raiserror('@@Select Branch@@',16,2)
			set @Gen_ID = 0
			return 
		end
		
		--If Upper(@tran_type) ='U' 
		--	begin	
		--		If not exists (Select Gen_ID  from dbo.T0040_GENERAL_SETTING Where Branch_ID = @Branch_ID  and  Cmp_ID =@cmp_ID)
		--			begin
		--				Set @tran_type = 'I'			
		--			end
		--	end
		
	
If Upper(@tran_type) ='I' 
			begin
			------Commented By Ramiz on 13092014 for adding New Entries in General Setting with Effective Date------------
			
			--If exists (Select Gen_ID  from dbo.T0040_GENERAL_SETTING Where Branch_ID = @Branch_ID  and  Cmp_ID =@cmp_ID) 
			--		begin
			--			delete from dbo.T0040_GENERAL_SETTING Where Branch_ID = @Branch_ID  and  Cmp_ID =@cmp_ID 
			--		end
			------Ended By Ramiz on 13092014 for adding New Entries in General Setting with Effective Date------------	
					select @Gen_ID = isnull(max(Gen_ID),0) + 1 from dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
										
					INSERT INTO dbo.T0040_GENERAL_SETTING
					                      (Gen_ID, Cmp_ID, Branch_ID, For_Date, Inc_Weekoff, Is_OT, ExOT_Setting, Late_Limit, Late_Adj_Day, Is_PT, Is_LWF, Is_Revenue, Is_PF, Is_ESIC, 
					                      Is_Late_Mark, Is_Credit, LWF_Amount, LWF_Month, Revenue_Amount, Revenue_On_Amount, Credit_Limit, Chk_Server_Date, Is_Cancel_Weekoff, 
					                      Is_Cancel_Holiday, Is_Daily_OT, In_Punch_Duration, Last_Entry_Duration, OT_App_Limit, OT_Max_Limit, OT_Fix_Work_Day, OT_Fix_Shift_Hours, 
					                      OT_Inc_Salary,ESIC_Upper_Limit,ESIC_Employer_Contribution,Inout_Days,
					                      Late_Fix_Work_Days,
					                      Late_Fix_shift_Hours,
					                      Late_Deduction_Days,
					                      Late_Extra_Deduction,
					                      Is_Late_Calc_On_HO_WO,
					                      Is_Late_CF,
					                      Late_CF_Reset_On,
					                      Sal_St_Date,
					                      Sal_fix_Days,
					                      Is_inout_Sal,
					                      Bonus_Last_Paid_Date, --					                      
					                      Gr_Min_Year ,
										  Gr_Cal_Month ,
										  Gr_ProRata_Cal, 
										  Gr_Min_P_Days,
										  Gr_Absent_Days, 
										  Short_Fall_Days ,
										  Gr_Days ,
										  Gr_Percentage ,
										  Short_Fall_W_Days ,
										  Leave_SMS,
										  CTC_Auto_Cal,
										  Inc_Holiday,
										  Probation,
										  Lv_Month,
										  Is_Shortfall_Gradewise,
										  Actual_Gross,
										  Wages_Amount,
										  Dep_Reim_Days,
										  Con_Reim_Days,
										  Late_With_leave,
										  Tras_Week_ot,
										  Bonus_Min_Limit,
										  Bonus_Max_Limit,
										  Bonus_Per,
										  Is_Organise_chart,
										  Is_Zero_Day_Salary,
										  Is_OT_Auto_Calc,
										  OT_Present_days,
										  Is_Negative_Ot,
										  Is_Present,
										  Is_Amount,
										  Mid_Increment,
										  AD_Rounding,
										  Lv_Encash_W_Day,
										  Lv_Salary_Effect_on_PT,
										  Lv_Encash_Cal_On,
										  In_Out_Login,
										  LWF_Max_Amount,
										  LWF_Over_Amount,
										  First_In_Last_Out_For_Att_Regularization, --Alpesh 04-Aug-2011
										  First_In_Last_Out_For_InOut_Calculation --Alpesh 04-Aug-2011
										  ,Late_Count_Exemption	
										 ,Early_Limit
										,Early_Adj_Day
										,Early_Deduction_Days
										,Early_Extra_Deduction
										,Early_CF_Reset_On
										,Is_Early_Calc_On_HO_WO
										,Is_Early_CF
										,Early_With_Leave
										,Early_Count_Exemption
										,Deficit_Limit
										,Deficit_Adj_Day
										,Deficit_Deduction_Days
										,Deficit_Extra_Deduction
										,Deficit_CF_Reset_On
										,Is_Deficit_Calc_On_HO_WO
										,Is_Deficit_CF
										,Deficit_With_Leave
										,Deficit_Count_Exemption
										,In_Out_Login_Popup
										,Late_Hour_Upper_Rounding ,is_Late_Calc_Slabwise,Late_Calculate_type,Early_Hour_Upper_Rounding,is_Early_Calc_Slabwise ,Early_Calculate_type,Is_Zero_Basic_Salary,Is_preQuestion,Is_CompOff,CompOff_Days_Limit,CompOff_Min_Hours,Is_CompOff_WD,Is_CompOff_WOHO  
										,Is_CF_On_Sal_Days,Days_As_Per_Sal_Days,Max_Late_Limit,Max_Early_Limit,Manual_Inout,Allow_Negative_Salary,Effect_ot_amount,CompOff_Avail_Days,Paid_WeekOff_Daily_Wages
										,Allowed_Full_WeekOf_MidJoining
										,is_weekoff_hour
										,weekoff_hours
										,is_all_emp_prob				-- Added By Hiral On 13 Oct,2012
										,late_exemption_limit
										,early_exemption_limit
										,Max_Bonus_salary_Amount
										,Optional_Holiday_Days
										,Is_OD_Transfer_to_OT   
										,Is_Co_hour_Editable 
										,Bonus_Entitle_Limit
										,Allowed_Full_WeekOf_MidJoining_DayRate
										,Monthly_Deficit_Adjust_OT_Hrs
										,Half_Day_Excepted_Count
										,Half_Day_Excepted_Max_Count
										,Is_HO_CompOff				-----Added by Sid 31032014
										,H_CompOff_Days_Limit		-----Added by Sid 31032014
										,H_CompOff_Min_Hours		-----Added by Sid 31032014
										,H_CompOff_Avail_Days		-----Added by Sid 31032014
										,Is_W_CompOff				-----Added by Sid 31032014
										,W_CompOff_Days_Limit		-----Added by Sid 31032014
										,W_CompOff_Min_Hours		-----Added by Sid 31032014
										,W_CompOff_Avail_Days		-----Added by Sid 31032014
										,AllowShowODOptInCompOff	-----Added by Sid 31032014
										,Is_H_Co_hour_Editable		-----Added by Sid 31032014
										,Is_W_Co_hour_Editable		-----Added by Sid 31032014
										,Net_Salary_Round			--Gadriwala Muslim 03042014
										,type_net_salary_round		--Gadriwala Muslim 03042014	
										,Day_For_Security_Deposit
										,OT_RoundingOff_To			-----Added by Sid 20052014
										,OT_RoundingOff_Lower		-----Added by Sid 20052014
										,MinWODays					-----Added by Ali 05062014
										,MaxWODays					-----Added by Ali 05062014
										,Chk_otLimit_before_after_Shift_time
										,chk_Lv_On_Working          -----Added by sumit 26112014
										--,Leave_SMS					-----Added by sumit 01/01/2015
										,Attendance_SMS				-----Added by sumit 01/01/2015
										,Cutoffdate_Salary          -----Added by sumit 19/01/2015
										,Attndnc_Reg_Max_Cnt		----Added by Sumit 17/02/2015
										,Manual_Salary_Period		----Added by Sumit 20022015
										,Is_WO_OD  -- Added by Gadriwala Muslim 31032015
										,Is_WD_OD  -- Added by Gadriwala Muslim 31032015
										,Is_HO_OD  -- Added by Gadriwala Muslim 31032015
										,DayRate_WO_Cancel
										,Training_Month
										,Dep_Reim_Days_Traning
										,Fnf_Fix_Day
										,LateEarly_Exemption_MaxLimit,LateEarly_Exemption_Count,Is_Cancel_Holiday_WO_HO_same_day
										,Restrict_Present_days
										,Emp_WeekDay_OT_Rate
										,Emp_WeekOff_OT_Rate
										,Emp_Holiday_OT_Rate
										,Full_PF
										,Company_Full_PF
										,is_present_on_holiday
										,Rate_Of_National_Holiday
										,Late_Mark_Scenario
										,Late_Adj_Again_OT
										,Allowed_Full_WeekOf_MidLeft
										,Allowed_Full_WeekOf_MidLeft_DayRate
										
										,Audit_Daily_OT_limit --Added By Jaina 19-08-2016 
										,Audit_Daily_Exemption_OT_limit --Added By Jaina 19-08-2016
										,Audit_Daily_Final_OT_limit --Added By Jaina 19-08-2016
										,Audit_Weekly_OT_limit --Added By Jaina 19-08-2016
										,Audit_Weekly_Exemption_OT_limit --Added By Jaina 19-08-2016
										,Audit_Weekly_Final_OT_limit --Added By Jaina 19-08-2016
										,Audit_Monthly_OT_limit --Added By Jaina 19-08-2016 
										,Audit_Monthly_Exemption_OT_limit --Added By Jaina 19-08-2016
										,Audit_Monthly_Final_OT_limit --Added By Jaina 19-08-2016
										,Audit_Quarterly_OT_limit --Added By Jaina 19-08-2016
										,Audit_Quarterly_Exemption_OT_limit --Added By Jaina 19-08-2016
										,Audit_Quarterly_Final_OT_limit --Added By Jaina 19-08-2016
										,Validity_Period_type  --Added By Jaina 23-08-2016
										,COPH_Avail_limit
										,COND_avail_limit --Added by Sumit on 29092016
										,Is_Customer_Audit  --Added By Jaina 01-10-2016
										,Is_Bonus_Inc  --added by jimit 03042017
										,Is_Regular_Bon --added by Rajput 19042017
										,Is_Latemark_Percentage
										,Is_Latemark_Cal_On
										,Probation_Review
										,Trainee_Review
										,Late_Limit_Regularization  --Added by Jaina 11-01-2018
										,Show_PT_in_Payslip_if_Zero 
										,Show_LWF_in_Payslip_if_Zero 
										,Is_Chk_Late_Early_Mark
										,Chk_Last_Late_Early_Month
										,Global_Salary_Days
										,Is_OT_Adj_against_Absent
										,OTRateType
										,OTSlabType
										,Is_Probation_Month_Days
										,Is_Trainee_Month_Days
										,Early_Mark_Scenario
										,Is_Earlymark_Percentage
										,Is_EarlyMark_Cal_On
										,Holiday_CompOff_Avail_After_Days --added binal 31012020
										,WeekOff_CompOff_Avail_After_Days --added binal 01022020
										,WeekDay_CompOff_Avail_After_Days --added binal 01022020
										,Attendance_Reg_Weekday
										,Approval_Up_To_Date
										,LateEarly_Combine 
										,Monthly_Exemption_Limit
										,Is_Cancel_Holiday_IfOneSideAbsent
										,Is_Cancel_Weekoff_IfOneSideAbsent
										,LateEarly_MonthWise
										 )										  
					VALUES     
										(@Gen_ID, @Cmp_ID, @Branch_ID, @For_Date, @Inc_Weekoff, @Is_OT, @ExOT_Setting, @Late_Limit, @Late_Adj_Day, @Is_PT, @Is_LWF, @Is_Revenue, @Is_PF, @Is_ESIC, 
					                      @Is_Late_Mark, @Is_Credit, @LWF_Amount, @LWF_Month, @Revenue_Amount, @Revenue_On_Amount, @Credit_Limit, @Chk_Server_Date, @Is_Cancel_Weekoff, 
					                      @Is_Cancel_Holiday, @Is_Daily_OT, @In_Punch_Duration, @Last_Entry_Duration, @OT_App_Limit, @OT_Max_Limit, @OT_Fix_Work_Day, @OT_Fix_Shift_Hours, 
					                      @OT_Inc_Salary,@ESIC_Upper_Limit,@ESIC_Employer_Contribution,@inout_Days,@Late_Fix_Work_Days,
					                      @Late_Fix_shift_Hours,
					                      @Late_Deduction_Days,
					                      @Late_Extra_Deduction,
					                      @Is_Late_Cal_On_HO_WO,
					                      @Is_Late_CF,
					                      @Late_CF_Reset_On,
					                      @Sal_St_Date,
					                      @Sal_Fix_Days,
					                      @Sal_Inout,
					                      @Last_Bonus,
					                      @Gr_Min_Year ,
										  @Gr_Cal_Month ,
										  @Gr_ProRata_Cal, 
										  @Gr_Min_P_Days,
										  @Gr_Absent_Days, 
										  @Short_Fall_Days ,
										  @Gr_Days ,
										  @Gr_Percentage ,
										  @Short_Fall_W_Days ,
					                      @Leave_SMS,
					                      @CTC_Auto_Cal,
					                      @Inc_Holiday,
					                      @Probation,
					                      @Lv_Month,
					                      @Is_Shortfall_Gradewise,
					                      @Actual_Gross,
					                      @Wage_Amount,
					                      @Dep_Reim_Days,
					                      @Con_Reim_Days,
					                      @Late_With_leave,
					                      @Tras_Week_ot,
					                      @Bonus_Min_Limit,
										  @Bonus_Max_Limit,
										  @Bonus_Per,
										  @Is_Organise_chart,
										  @Is_Zero_Day_Salary,
										  @OT_Auto,
										  @OT_Present,
										  @Is_Negative_Ot,
										  @Is_Present,
										  @Is_Amount,
										  @Mid_Increment,
										  @AD_Rounding,
										  @Lv_Encash_W_Day,
										  @Lv_Salary_Effect_on_PT,
										  @Lv_Encash_Cal_On,
										  @In_Out_Login,
										  @LWF_Max_Amount,
										  @LWF_Over_Amount,
										  @First_In_Last_Out_For_Att_Regularization, --Alpesh 04-Aug-2011
										  @First_In_Last_Out_For_InOut_Calculation	--Alpesh 04-Aug-2011	 
										  ,@Late_Count_Exemption	-- Start Added by Mitesh on 18/08/2011
										 ,@Early_Limit
										,@Early_Adj_Day
										,@Early_Deduction_Days
										,@Early_Extra_Deduction
										,@Early_CF_Reset_On
										,@Is_Early_Calc_On_HO_WO
										,@Is_Early_CF
										,@Early_With_Leave
										,@Early_Count_Exemption
										,@Deficit_Limit
										,@Deficit_Adj_Day
										,@Deficit_Deduction_Days
										,@Deficit_Extra_Deduction
										,@Deficit_CF_Reset_On
										,@Is_Deficit_Calc_On_HO_WO
										,@Is_Deficit_CF
										,@Deficit_With_Leave
										,@Deficit_Count_Exemption			-- End Added by Mitesh on 18/08/2011				
										,@In_Out_Login_Popup  
										,@Late_Hour_Upper_Rounding ,@is_Late_Calc_Slabwise,@Late_Calculate_type,@Early_Hour_Upper_Rounding,@is_Early_Calc_Slabwise ,@Early_Calculate_type,@Is_Basic_Salary,@Is_PreQuestion,@Is_CompOff,@CompOff_limit,@CompOff_Min_Hours,@Is_CompOff_WD,@Is_CompOff_WOHO  
										,@Is_CF_On_Sal_Days,@Days_As_Per_Sal_Days,@Max_Late_Limit,@Max_Early_Limit,@Manual_Inout,@Allow_Negative_Salary,@ESIC_OT_Allow,@CompOff_Avail_Days,@Paid_WeekOff_Daily_Wages   
										,@Allowed_Full_WeekOf_MidJoining
										,@is_weekoff_hour
										,@weekoff_hours
										,@is_all_emp_prob				-- Added By Hiral On 13 Oct,2012
										,@Max_Late_Exem_Limit 
										,@Max_Early_Exem_Limit
										,@Max_Bonus_salary_Amount
										,@Optional_Holiday_Days
										,@Is_OD_Transfer_to_OT   
										,@Is_Co_hour_Editable 
										,@Bonus_Entitle_Limit
										,@Allowed_Full_WeekOf_MidJoining_DayRate
										,@Monthly_Deficit_Adjust_OT_Hrs
										,@Half_Day_Excepted_Count
										,@Half_Day_Excepted_Max_Count
										,@H_Comp_Off  							--Sid 05022014
										,@H_CompOff_Limit  						--Sid 05022014
										,@H_Min_CompOff_Hours  					--Sid 05022014
										,@H_CompOff_Avail_Days 					--Sid 05022014
										,@W_Comp_Off 							--Sid 05022014
										,@W_CompOff_Limit 						--Sid 05022014
										,@W_Min_CompOff_Hours 					--Sid 05022014
										,@W_CompOff_Avail_Days 					--Sid 05022014
										,@AllowShowODOptInCompOff				--Sid 28022014
										,@Is_H_Co_hour_Editable					--Sid 20032014
										,@Is_W_Co_hour_Editable					--Sid 20032014
										,@Net_Salary_Round						--Gadriwala Muslim 03042014
										,@type_net_salary_round					--Gadriwala Muslim 03042014
										,@Day_For_Security_Deposit
										,@OT_RoundingOff_To						-----Added by Sid 20052014
										,@OT_Roundingoff_Lower					-----Added by Sid 20052014
										,@MinWOLimit							-----Added by Ali 05062014
										,@MaxWOLimit							-----Added by Ali 05062014
										,@Chk_OT_limit_Before_Shift
										,@Chk_lv_on_Working						-----Added by sumit 26112014
										,@Chk_Attendance_SMS										
										,@Sal_CutOf_Date						-----Added by sumit 26112014
										,@Max_Cnt_Reg							-----Added by sumit 17022015
										,@Manual_Salary_Prd						----Added by Sumit 20022015
										,@Is_WO_OD			--Added by Gadriwala Muslim 31032015
										,@Is_HO_OD			--Added by Gadriwala Muslim 31032015
										,@Is_WD_OD			--Added by Gadriwala Muslim 31032015
										,@DayRate_WO_Cancel
										,@Training_Month
										,@Dep_Reim_Days_Traning
										,@Fnf_Fix_Day
										,@LateEarlyExemMaxLimit,@LateEarlyExempCount,@Is_Cancel_Holiday_WO_HO_same_day
										,@Is_Restrict_Present_days
										,@Emp_Weekday_OT_Rate
										,@Emp_Weekoff_OT_Rate
										,@Emp_Holiday_OT_Rate
										,@Full_PF
										,@Company_Full_PF
										,@present_on_holiday 
										,@Rate_of_national_holiday
										,@Late_Mark_Scenario
										,@Late_Adj_Again_OT
										,@Allowed_FullWeekof_MidLeft
										,@Allowed_FullWeekof_MidLeft_DayRate
										
										,@Audit_Daily_OT_limit -- Added by Jaina 19-08-2016
										,@Audit_Daily_Exemption_OT_limit -- Added by Jaina 19-08-2016
										,@Audit_Daily_Final_OT_limit -- Added by Jaina 19-08-2016
										,@Audit_Weekly_OT_limit -- Added by Jaina 19-08-2016
										,@Audit_Weekly_Exemption_OT_limit -- Added by Jaina 19-08-2016
										,@Audit_Weekly_Final_OT_limit -- Added by Jaina 19-08-2016
										,@Audit_Monthly_OT_limit -- Added by Jaina 19-08-2016 
										,@Audit_Monthly_Exemption_OT_limit -- Added by Jaina 19-08-2016
										,@Audit_Monthly_Final_OT_limit -- Added by Jaina 19-08-2016
										,@Audit_Quarterly_OT_limit -- Added by Jaina 19-08-2016
										,@Audit_Quarterly_Exemption_OT_limit -- Added by Jaina 19-08-2016
										,@Audit_Quarterly_Final_OT_limit -- Added by Jaina 19-08-2016
										,@Validity_Period_type  --Added By Jaina 23-08-2016
										,@COPH_Avail_limit
										,@COND_avail_limit --Added by Sumit on 29092016
										,@Is_Customer_Audit  --Added by Jaina 01-10-2016
										,@Is_Bonus_Inc   --added by jimit 03042017
										,@Is_Regular_Bon   --added by Rajput 19042017
										,@Is_LateMark_Percent 
										,@Is_LateMark_Cal_On
										,@Probation_Review
										,@Trainee_Review
										,@Late_Limit_Regularization --Added by Jaina 11-01-2018
										,@Show_PT_in_Payslip_if_Zero -- added By Krushna 28-05-2018
										,@Show_LWF_in_Payslip_if_Zero -- added By Krushna 28-05-2018
										,@Is_Check_Late_Early_Combine
										,@Check_Last_LateEarly
										,@Global_Sal_Days
										,@Is_OT_Adj_against_Absent
										,@OTRateType --Added by rajput on 03072018
										,@OTSlabType --Added by rajput on 03072018
										,@Is_Probation_Month_Days
										,@Is_Trainee_Month_Days
										,@Early_Mark_Scenario
										,@Is_EarlyMark_percent
										,@Is_EarlyMark_Cal_On
										,@Holiday_CompOff_Avail_After_Days  --added binal 31012020
										,@Weekoff_COPH_Avail_After_Days  
										,@Weekday_COPH_Avail_After_Days  
										,@Attendance_Reg_Weekday
										,@Approval_Up_To_Date
										,@LateEarly_Combine
										,@Monthly_Exemption_Limit
										,@CancelHolidayOneSideAbsent
										,@CancelWeekoffOneSideAbsent
										,@LateEarly_MonthWise
										  )
										  
										  --Add by PAras 15-10-2012
										
										  
		                                 --set @OldValue = 'New Value' + '#'+ 'For Date :' + cast(ISNULL( @For_Date,'')as varchar(11)) + '#' + 'Inc Weekoff :' + CAST(ISNULL( @Inc_Weekoff,0)as varchar(1)) + '#' + 'Is OT :' + CAST(ISNULL(@Is_OT,0) AS VARCHAR(1)) + '#' + 'ExOT Setting :' +CAST( ISNULL( @ExOT_Setting,0)AS VARCHAR(18)) + '#' + 'Late Limit :' +ISNULL( @Late_Limit,'') + ' #'+ 'Late Adj Day :' +CAST(ISNULL(@Late_Adj_Day,0)AS VARCHAR(18)) + ' #'+ 'Is PT :' + CAST(ISNULL( @Is_PT,0)as varchar(1)) + ' #'+ 'Is LWF :' + CAST(ISNULL(@Is_LWF,0)AS VARCHAR(1))  + ' #'
										                                  
										                         --         + 'Is Revenue :' + cast(ISNULL(@Is_Revenue,0)as varchar(1)) + '#' + 'Is PF :' + CAST(ISNULL( @Is_PF,0)as varchar(1)) + '#' + 'Is ESIC :' + CAST(ISNULL(@Is_ESIC,0) AS VARCHAR(1)) + '#' + 'Is Late Mark :' +CAST( ISNULL( @Is_Late_Mark,0)AS VARCHAR(1)) + '#' + 'Is Credit :' +CAST(ISNULL( @Is_Credit,0)AS VARCHAR(1)) + ' #'+ 'LWF Amount :' +CAST(ISNULL(@LWF_Amount,0)AS VARCHAR(18)) + ' #'+ 'LWF Month :' + ISNULL( @LWF_Month,'') + ' #'+ 'Revenue Amount :' + CAST(ISNULL(@Revenue_Amount,0)AS VARCHAR(18))  + ' #'    
										                                  
										                         --         + 'Revenue On Amount :' + cast(ISNULL(@Revenue_On_Amount,0)as varchar(18)) + '#' + 'Credit Limit :' + CAST(ISNULL(@Credit_Limit,0)as varchar(18)) + '#' + 'Chk Server Date :' + CAST(ISNULL(@Chk_Server_Date,0) AS VARCHAR(1)) + '#' + 'Is Cancel Weekoff :' +CAST( ISNULL( @Is_Cancel_Weekoff,0)AS VARCHAR(1)) + '#' + 'Is Cancel Holiday :' +CAST(ISNULL(@Is_Cancel_Holiday,0)AS VARCHAR(1)) + ' #'+ 'Is Daily OT :' +CAST(ISNULL(@Is_Daily_OT,0)AS VARCHAR(1)) + ' #'+ 'In Punch Duration :' + ISNULL(@In_Punch_Duration,'') + ' #'+ 'Last Entry Duration :' + ISNULL(@Last_Entry_Duration,'')  + ' #' 
										                                  
										                         --         + 'OT App Limit:' + ISNULL(@OT_App_Limit,'') + '#' + 'OT Max Limit :' + ISNULL(@OT_Max_Limit,'') + '#' + 'OT Fix Work Day :' + CAST(ISNULL(@OT_Fix_Work_Day,0) AS VARCHAR(18)) + '#' + 'OT Fix Shift Hours :' +ISNULL(@OT_Fix_Shift_Hours,'') + '#' + 'OT Inc Salary :' +CAST(ISNULL(@OT_Inc_Salary,0)AS VARCHAR(1)) + ' #'+ 'ESIC Upper Limit :' +CAST(ISNULL(@ESIC_Upper_Limit,0)AS VARCHAR(180)) + ' #'+ 'ESIC Employer Contribution :' + CAST(ISNULL(@ESIC_Employer_Contribution,0)as varchar(182)) + ' #'+ 'inout Days :' + CAST(ISNULL(@inout_Days,0)AS VARCHAR(182))  + ' #' 
										                                  
										                         --         + 'Late Fix Work Days :' + cast(ISNULL(@Late_Fix_Work_Days,0)as varchar(51)) + '#' + 'Late Fix shift Hours :' + ISNULL(@Late_Fix_shift_Hours,'') + '#' + 'Late Deduction Days :' + CAST(ISNULL(@Late_Deduction_Days,0) AS VARCHAR(31)) + '#' + 'Late Extra Deduction :' +CAST( ISNULL( @Late_Extra_Deduction,0)AS VARCHAR(31)) + '#' + 'Is Late Cal On HO WO :' +CAST(ISNULL(@Is_Cancel_Holiday,0)AS VARCHAR(1)) + ' #'+ 'Is Late CF :' +CAST(ISNULL(@Is_Daily_OT,0)AS VARCHAR(1)) + ' #'+ 'Late CF Reset On :' + ISNULL(@Late_CF_Reset_On,'') + ' #'+ 'Sal St Date :' + CAST(ISNULL(@Last_Entry_Duration,0)AS VARCHAR(11))  + ' #' 
										                                  
										                         --         + 'Sal Fix Days :' + cast(ISNULL(@Sal_Fix_Days,0)as varchar(181)) + '#' + 'Sal Inout :' + CAST(ISNULL(@Sal_Inout,0)as varchar(11)) + '#' + 'Last bonus :' + CAST(ISNULL(@Last_bonus,0) AS VARCHAR(11)) + '#' + 'Gr Min Year :' +CAST( ISNULL(@Gr_Min_Year,0)AS VARCHAR(1)) + '#' + 'Gr Cal Month :' +CAST(ISNULL(@Gr_Cal_Month,0)AS VARCHAR(1)) + ' #'+ 'Gr ProRata Cal :' +CAST(ISNULL(@Gr_ProRata_Cal,0)AS VARCHAR(1)) + ' #'+ 'Gr Min P Days :' + CAST(ISNULL(@In_Punch_Duration,0)as varchar(52)) + ' #'+ 'Gr Absent Days :' + CAST(ISNULL(@Gr_Absent_Days,0)AS VARCHAR(52))  + ' #' 
										                                  
										                         --         + 'Short Fall Days :' + cast(ISNULL(@Short_Fall_Days,0)as varchar(52)) + '#' + 'Gr Days :' + CAST(ISNULL(@Gr_Days,0)as varchar(52)) + '#' + 'Gr Percentage :' + CAST(ISNULL(@Gr_Percentage,0) AS VARCHAR(52)) + '#' + 'Short Fall W Days :' +CAST( ISNULL( @Short_Fall_W_Days,0)AS VARCHAR(52)) + '#' + 'Leave SMS :' +CAST(ISNULL(@Leave_SMS,0)AS VARCHAR(52)) + ' #'+ 'CTC Auto Cal :' +CAST(ISNULL(@CTC_Auto_Cal,0)AS VARCHAR(52)) + ' #'+ 'Inc Holiday :' + CAST(ISNULL(@Inc_Holiday,'')as varchar(10)) + ' #'+ 'Probation :' + CAST(ISNULL(@Probation,'')AS VARCHAR(20))  + ' #' 
										                                  
										                         --         + 'Lv Month :' + cast(ISNULL(@Lv_Month,0)as varchar(20)) + '#' + 'Is Shortfall Gradewise :' + CAST(ISNULL(@Is_Shortfall_Gradewise,0)as varchar(1)) + '#' + 'Actual Gross :' + CAST(ISNULL(@Actual_Gross,0) AS VARCHAR(182)) + '#' + 'Wage Amount :' +CAST( ISNULL( @Wage_Amount,0)AS VARCHAR(182)) + '#' + 'Dep Reim Days :' +CAST(ISNULL(@Dep_Reim_Days,0)AS VARCHAR(180)) + ' #'+ 'Con Reim Days :' +CAST(ISNULL(@Con_Reim_Days,0)AS VARCHAR(182)) + ' #'+ 'Late With Leave :' + CAST(ISNULL(@Late_With_Leave,'')as varchar(182)) + ' #'+ 'Tras Week ot :' + CAST(ISNULL(@Tras_Week_ot,'')AS VARCHAR(1))  + ' #' 
										                                  
										                         --         + 'Bonus Min Limit :' + cast(ISNULL(@Bonus_Min_Limit,0)as varchar(180)) + '#' + 'Bonus Max Limit :' + CAST(ISNULL(@Bonus_Max_Limit,0)as varchar(180)) + '#' + 'Bonus Per :' + CAST(ISNULL(@Bonus_Per,0) AS VARCHAR(182)) + '#' + 'Is Organise chart :' +CAST( ISNULL(@Is_Organise_chart,0)AS VARCHAR(1)) + '#' + 'Is Zero Day Salary :' +CAST(ISNULL(@Is_Zero_Day_Salary,0)AS VARCHAR(1)) + ' #'+ 'OT Auto :' +CAST(ISNULL(@OT_Auto,0)AS VARCHAR(1)) + ' #'+ 'OT Present :' + CAST(ISNULL(@OT_Present,0)as varchar(4)) + ' #'+ 'Is Negative Ot :' + CAST(ISNULL(@Is_Negative_Ot,0)AS VARCHAR(4))  + ' #' 
										                                  
										                         --         + 'Is Present :' + cast(ISNULL(@Is_Present,0)as varchar(180)) + '#' + 'Is Amount :' + CAST(ISNULL(@Is_Amount,0)as varchar(180)) + '#' + 'Mid Increment :' + CAST(ISNULL(@Mid_Increment,0) AS VARCHAR(180)) + '#' + 'AD Rounding :' +CAST( ISNULL(@AD_Rounding,0)AS VARCHAR(180)) + '#' + 'Lv Salary Effect on PT :' +CAST(ISNULL(@Lv_Salary_Effect_on_PT,0)AS VARCHAR(10)) + ' #'+ 'Lv Encash W Day :' +CAST(ISNULL(@Lv_Encash_W_Day,0)AS VARCHAR(10)) + ' #'+ 'Lv Encash Cal On :' + ISNULL(@Lv_Encash_Cal_On,'') + ' #'+ 'In Out Login :' + CAST(ISNULL(@In_Out_Login,'')AS VARCHAR(4))  + ' #' 
										                                  
										                         --         + 'LWF Max Amount :' + cast(ISNULL(@LWF_Max_Amount,0)as varchar(182)) + '#' + 'LWF Over Amount :' + CAST(ISNULL(@LWF_Over_Amount,0)as varchar(182)) + '#' + 'First In Last Out For Att Regularization :' + CAST(ISNULL(@First_In_Last_Out_For_Att_Regularization,0) AS VARCHAR(1)) + '#' + 'First In Last Out For InOut Calculation :' +CAST( ISNULL(@First_In_Last_Out_For_InOut_Calculation,0)AS VARCHAR(1)) + '#' + 'Late Count Exemption :' +CAST(ISNULL(@Late_Count_Exemption,0)AS VARCHAR(20)) + ' #'+ 'Early Limit :' +ISNULL(@Early_Limit,'') + ' #'+ 'Early Adj Day :' + CAST(ISNULL(@Early_Adj_Day,'')as varchar(18)) + ' #'+ 'Early Deduction Days :' + CAST(ISNULL(@Early_Deduction_Days,'')AS VARCHAR(31))  + ' #' 
										                                  
										                         --         + 'Early Extra Deduction :' + cast(ISNULL(@Early_Extra_Deduction,0)as varchar(31)) + '#' + 'Early CF Reset On :' + ISNULL(@Early_CF_Reset_On,'') + '#' + 'Is Early Calc On HO WO :' + CAST(ISNULL(@Is_Early_Calc_On_HO_WO,0) AS VARCHAR(1)) + '#' + 'Is Early CF:' +CAST( ISNULL(@Is_Early_CF,0)AS VARCHAR(1)) + '#' + 'Early With Leave :' +CAST(ISNULL(@Early_With_Leave,0)AS VARCHAR(3)) + ' #'+ 'Early Count Exemption	:' +CAST(ISNULL(@Early_Count_Exemption,'')AS VARCHAR(20)) + ' #'+ 'Deficit Limit :' + ISNULL(@Deficit_Limit,'') + ' #'+ 'Deficit Adj Day :' + CAST(ISNULL(@Deficit_Adj_Day,'')AS VARCHAR(18))  + ' #' 
										                                  
										                         --         + 'Deficit Deduction Days :' + cast(ISNULL(@Deficit_Deduction_Days,0)as varchar(31)) + '#' + 'Deficit Extra Deduction :' + CAST(ISNULL(@Deficit_Extra_Deduction,0)as varchar(31)) + '#' + 'Deficit CF Reset On :' +ISNULL(@Deficit_CF_Reset_On,'')  + '#' + 'Is Deficit Calc On HO WO:' +CAST( ISNULL(@Is_Deficit_Calc_On_HO_WO,0)AS VARCHAR(1)) + '#' + 'Is Deficit CF :' +CAST(ISNULL(@Is_Deficit_CF,0)AS VARCHAR(1)) + ' #'+ 'Deficit With Leave	:' +CAST(ISNULL(@Deficit_With_Leave,'')AS VARCHAR(5)) + ' #'+ 'Deficit Count Exemption :' + CAST(ISNULL(@Deficit_Count_Exemption,'')as varchar(20)) + ' #'+ 'In Out Login Popup:' + CAST(ISNULL(@In_Out_Login_Popup,'')AS VARCHAR(4))  + ' #' 
										                                  
										                         --         + 'Late Hour Upper Rounding :' + cast(ISNULL(@Late_Hour_Upper_Rounding,0)as varchar(182)) + '#' + 'is Late Calc Slabwise :' + CAST(ISNULL(@is_Late_Calc_Slabwise,0)as varchar(1)) + '#' + 'Late Calculate type :' + ISNULL(@Late_Calculate_type,'') + '#' + 'Early Hour Upper Rounding  :' +CAST( ISNULL( @Early_Hour_Upper_Rounding ,0)AS VARCHAR(182)) + '#' + 'is Early Calc Slabwise:' +CAST(ISNULL(@is_Early_Calc_Slabwise,0)AS VARCHAR(1)) + ' #'+ 'Early Calculate type :' +CAST(ISNULL(@Early_Calculate_type,0)AS VARCHAR(10)) + ' #'+ 'Is Basic Salary :' + CAST(ISNULL(@Is_Basic_Salary,'')as varchar(1)) + ' #'+ 'Is PreQuestion :' + CAST(ISNULL(@Is_PreQuestion,'')AS VARCHAR(1))  + ' #' 
										                                  
										                         --         + 'Is CompOff :' + cast(ISNULL(@Is_CompOff,0)as varchar(1)) + '#' + 'CompOff limit :' + CAST(ISNULL(@CompOff_limit,0)as varchar(180)) + '#' + 'CompOff Min Hours :' + ISNULL(@CompOff_Min_Hours,'')  + '#' + 'Is CompOff WD :' +CAST(ISNULL(@Is_CompOff_WD,0)AS VARCHAR(1)) + '#' + 'Is CompOff WOHO:' +CAST(ISNULL(@Is_CompOff_WOHO,0)AS VARCHAR(1)) + ' #'+ 'Is CF On Sal Days :' +CAST(ISNULL(@Is_CF_On_Sal_Days,0)AS VARCHAR(1)) + ' #'+ 'Days As Per Sal Days :' + CAST(ISNULL(@Days_As_Per_Sal_Days,'')as varchar(1)) + ' #'+ 'Max Late Limit :' + ISNULL(@Max_Late_Limit,'')  + ' #' 
										                                  
										                         --         + 'Max Early Limit :' + cast(ISNULL(@Max_Early_Limit,0)as varchar(50)) + '#' + 'Manual Inout :' + CAST(ISNULL(@Manual_Inout,0)as varchar(4)) + '#' + 'Allow Negative Salary :' + CAST(ISNULL(@Allow_Negative_Salary,0) AS VARCHAR(1)) + '#' + 'ESIC OT Allow:' +CAST( ISNULL( @ESIC_OT_Allow,0)AS VARCHAR(1)) + '#' + 'CompOff Avail Days:' +CAST(ISNULL(@CompOff_Avail_Days,0)AS VARCHAR(180)) + ' #'+ 'Paid WeekOff Daily Wages :' +CAST(ISNULL(@Paid_WeekOff_Daily_Wages,0)AS VARCHAR(1)) + ' #'+ 'Allowed Full WeekOf MidJoining:' + CAST(ISNULL(@Allowed_Full_WeekOf_MidJoining,'')as varchar(1)) + ' #'+ 'isweekoff hour :' + CAST(ISNULL(@is_weekoff_hour,'')AS VARCHAR(2))  + ' #' 
										                                  
										                         --         + 'weekoff hours :' + ISNULL(@weekoff_hours,0) + '#' + 'is all emp prob :' + CAST(ISNULL(@is_all_emp_prob,0)as varchar(1)) + '#'
										  
										   
					exec P9999_Audit_get @table = 'T0040_GENERAL_SETTING' ,@key_column='Gen_Id',@key_Values=@Gen_ID ,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))				  
					
				end 
	Else If Upper(@tran_type) ='U' 
				begin
					
					------Commented By Ramiz on 13092014 for adding New Entries in General Setting with Effective Date------------
					
						--delete from dbo.T0040_GENERAL_SETTING Where Branch_ID = @Branch_ID  and  Cmp_ID =@cmp_ID And Gen_ID <> @Gen_ID 				
					
					------Ended By Ramiz on 13092014 ------------
					
						select @OldFor_Date  =ISNULL(For_Date,'') ,@OldInc_Weekoff  =ISNULL(Inc_Weekoff,''),@OldIs_OT  =isnull(Is_OT,0),@OldExOT_Setting  =isnull(ExOT_Setting,0),@OldLate_Limit =isnull(Late_Limit,''),@OldLate_Adj_Day  =isnull(Late_Adj_Day,0),@OldIs_PT = isnull(Is_PT,0),@OldIs_LWF  =isnull(Is_LWF ,0) , 
										
										       @OldIs_Revenue  =ISNULL(Is_Revenue,0) ,@OldIs_PF  =ISNULL(Is_PF,0),@OldIs_ESIC  =isnull(Is_ESIC,0),@OldIs_Late_Mark  =isnull(Is_Late_Mark,0),@OldIs_Credit  =isnull(Is_Credit,0),@OldLWF_Amount  = isnull(LWF_Amount,0),@OldLWF_Month  =isnull(LWF_Month ,0),@OldRevenue_Amount =isnull(Revenue_Amount,0),
										       
										       @OldRevenue_On_Amount  =ISNULL(Revenue_On_Amount,0) ,@OldCredit_Limit =ISNULL(Credit_Limit,0),@OldChk_Server_Date  =isnull(Chk_Server_Date,0),@OldIs_Cancel_Weekoff  =isnull(Is_Cancel_Weekoff,0),@OldIs_Cancel_Holiday =isnull(Is_Cancel_Holiday,0),@OldIs_Daily_OT  =isnull(Is_Daily_OT,0),@OldIn_Punch_Duration  = isnull(In_Punch_Duration,''),@OldLast_Entry_Duration  =isnull(Last_Entry_Duration ,0) ,
										       
										       @OldOT_App_Limit  =ISNULL(OT_App_Limit,'') ,@OldOT_Max_Limit  =ISNULL(OT_Max_Limit,''),@OldOT_Fix_Work_Day =isnull(OT_Fix_Work_Day,0),@OldOT_Fix_Shift_Hours  =isnull(OT_Fix_Shift_Hours,0),@OldOT_Inc_Salary =isnull(OT_Inc_Salary,0),@OldESIC_Upper_Limit  =isnull(ESIC_Upper_Limit,0),@OldESIC_Employer_Contribution  = isnull(ESIC_Employer_Contribution,''),@Oldinout_Days  =isnull(inout_Days ,0)  ,
										       
										       @OldLate_Fix_Work_Days  =ISNULL(Late_Fix_Work_Days,0) ,@OldLate_Fix_shift_Hours  =ISNULL(Late_Fix_Shift_Hours,0),@OldLate_Deduction_Days  =isnull(Late_Deduction_Days,0),@OldLate_Extra_Deduction  =isnull(Late_Extra_Deduction,0),@OldIs_Late_Cal_On_HO_WO  =isnull(Is_Late_Calc_On_HO_WO,0),@OldIs_Late_CF  = isnull(Is_Late_CF,0),@OldLate_CF_Reset_On  =isnull(Late_CF_Reset_On ,0),@OldSal_St_Date =isnull(Sal_St_Date,0),
										       
										       @OldSal_Fix_Days  =ISNULL(Sal_Fix_Days,0) ,@OldSal_Inout  =ISNULL(Is_Inout_Sal,''),@OldLast_bonus  =isnull(Bonus_Last_Paid_Date,0),@OldGr_Min_Year  =isnull(Gr_Min_Year,0),@OldGr_Cal_Month =isnull(Gr_Cal_Month,0),@OldGr_ProRata_Cal  =isnull(Gr_ProRata_Cal,0),@OldGr_Min_P_Days  = isnull(Gr_Min_P_Days,''),@OldGr_Absent_Days  =isnull(Gr_Absent_Days ,0) ,
										       
										       @OldShort_Fall_Days  =ISNULL(Short_Fall_Days,'') ,@OldGr_Days  =ISNULL(Gr_Days,''),@OldGr_Percentage  =isnull(Gr_Percentage,0),@OldShort_Fall_W_Days =isnull(Short_Fall_W_Days,0),@OldLeave_SMS  =isnull(Leave_SMS,0),@OldCTC_Auto_Cal = isnull(CTC_Auto_Cal,''),@OldInc_Holiday  =isnull(Inc_Holiday ,0),@OldProbation  =isnull(Probation ,0),
										       
										       @OldLv_Month  =ISNULL(Lv_Month,'') ,@OldIs_Shortfall_Gradewise  =ISNULL(Is_Shortfall_Gradewise,''),@OldActual_Gross  =isnull(Actual_Gross,0),@OldWage_Amount =isnull(Wages_Amount,0),@OldDep_Reim_Days =isnull(Dep_Reim_Days,0),@OldCon_Reim_Days  =isnull(Con_Reim_Days,0),@OldLate_With_Leave  = isnull(Late_With_Leave,''),@OldTras_Week_ot  =isnull(Tras_Week_ot ,0),
										       
										       @OldBonus_Min_Limit =ISNULL(Bonus_Min_Limit,'') ,@OldBonus_Max_Limit  =ISNULL(Bonus_Max_Limit,''),@OldBonus_Per  =isnull(Bonus_Per,0),@OldIs_Organise_chart  =isnull(Is_Organise_chart,0),@OldIs_Zero_Day_Salary=isnull(Is_Zero_Day_Salary,0),@OldOT_Auto   =isnull(Is_OT_Auto_Calc,0),@OldOT_Present = isnull(OT_Present_Days,''),@OldIs_Negative_Ot  =isnull(Is_Negative_Ot ,0),
										       
										       @OldIs_Present  =ISNULL(Is_Present,'') ,@OldIs_Amount =ISNULL(Is_Amount,''),@OldMid_Increment =isnull(Mid_Increment,0),@OldAD_Rounding   =isnull(AD_Rounding ,0),@OldLv_Salary_Effect_on_PT =isnull(Lv_Salary_Effect_on_PT,0),@OldLv_Encash_W_Day  =isnull(Lv_Encash_W_Day,0),@OldLv_Encash_Cal_On = isnull(Lv_Encash_Cal_On,''),@OldIn_Out_Login =isnull(In_Out_Login ,0),
										       
										       @OldLWF_Max_Amount  =ISNULL(LWF_Max_Amount,'') ,@OldLWF_Over_Amount  =ISNULL(LWF_Over_Amount,''),@OldFirst_In_Last_Out_For_Att_Regularization  =isnull(First_In_Last_Out_For_Att_Regularization,0),@OldFirst_In_Last_Out_For_InOut_Calculation  =isnull(First_In_Last_Out_For_InOut_Calculation,0),@OldLate_Count_Exemption =isnull(Late_Count_Exemption,0),@OldEarly_Limit  =isnull(Early_Limit,0),@OldEarly_Adj_Day  = isnull(Early_Adj_Day,''),@OldEarly_Deduction_Days  =isnull(Early_Deduction_Days ,0) ,
										       
										       @OldEarly_Extra_Deduction =ISNULL(Early_Extra_Deduction,'') ,@OldEarly_CF_Reset_On =ISNULL(Early_CF_Reset_On,''),@OldIs_Early_Calc_On_HO_WO =isnull(Is_Early_Calc_On_HO_WO,0),@OldIs_Early_CF  =isnull(Is_Early_CF,0),@OldEarly_With_Leave=isnull(Early_With_Leave,0),@OldEarly_Count_Exemption =isnull(Early_Count_Exemption,0),@OldDeficit_Limit  = isnull(Deficit_Limit,''),@OldDeficit_Adj_Day  =isnull(Deficit_Adj_Day ,0) ,
										       
										       @OldDeficit_Deduction_Days  =ISNULL(Deficit_Deduction_Days,'') ,@OldDeficit_Extra_Deduction  =ISNULL(Deficit_Extra_Deduction,''),@OldDeficit_CF_Reset_On =isnull(Deficit_CF_Reset_On,0),@OldIs_Deficit_Calc_On_HO_WO  =isnull(Is_Deficit_Calc_On_HO_WO,0),@OldIs_Deficit_CF =isnull(Is_Deficit_CF,0),@OldDeficit_With_Leave  =isnull(Deficit_With_Leave,0),@OldDeficit_Count_Exemption  = isnull(Deficit_Count_Exemption,''),@OldIn_Out_Login_Popup  =isnull(In_Out_Login_Popup ,0) ,
										       
										       @OldLate_Hour_Upper_Rounding  =ISNULL(Late_Hour_Upper_Rounding,'') ,@Oldis_Late_Calc_Slabwise  =ISNULL(is_Late_Calc_Slabwise,''),@OldLate_Calculate_type   =isnull(Late_Calculate_type ,0),@OldEarly_Hour_Upper_Rounding  =isnull(Early_Hour_Upper_Rounding,0),@OldIs_PreQuestion =isnull(Is_PreQuestion,0),@Oldis_Early_Calc_Slabwise  =isnull(is_Early_Calc_Slabwise,0),@OldEarly_Calculate_type  = isnull(Early_Calculate_type,''),@OldIs_Basic_Salary  =isnull(Is_Zero_Basic_Salary ,0),
										       
										       @OldIs_CompOff  =ISNULL(Is_CompOff,'') ,@OldCompOff_limit  =ISNULL(CompOff_Days_Limit,''),@OldCompOff_Min_Hours  =isnull(CompOff_Min_Hours,0),@OldIs_CompOff_WD  =isnull(Is_CompOff_WD,0),@OldIs_CompOff_WOHO =isnull(Is_CompOff_WOHO,0),@OldIs_CF_On_Sal_Days  =isnull(Is_CF_On_Sal_Days,0),@OldDays_As_Per_Sal_Days  = isnull(Days_As_Per_Sal_Days,''),@OldMax_Late_Limit  =isnull(Max_Late_Limit ,0),
										       
										       @OldMax_Early_Limit  =ISNULL(Max_Early_Limit,'') ,@OldManual_Inout  =ISNULL(Manual_Inout,''),@OldAllow_Negative_Salary  =isnull(Allow_Negative_Salary,0),@OldESIC_OT_Allow  =isnull(Effect_ot_amount,0),@OldCompOff_Avail_Days =isnull(CompOff_Avail_Days,0),@OldPaid_WeekOff_Daily_Wages  =isnull(Paid_WeekOff_Daily_Wages,0),@OldAllowed_Full_WeekOf_MidJoining  = isnull(Allowed_Full_WeekOf_MidJoining,''),@Oldis_weekoff_hour  =isnull(is_weekoff_hour ,0),
										       
										       @Oldweekoff_hours  =ISNULL(weekoff_hours,'') ,@Oldis_all_emp_prob  =ISNULL(is_all_emp_prob,'')
										       
										        From dbo.T0040_GENERAL_SETTING Where Cmp_ID = @Cmp_ID and Gen_ID = @Gen_ID
		
			exec P9999_Audit_get @table='T0040_GENERAL_SETTING' ,@key_column='Gen_Id',@key_Values=@gen_id,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			    			
				
				UPDATE    dbo.T0040_GENERAL_SETTING
				SET              Branch_ID = @Branch_ID, For_Date = @For_Date, Inc_Weekoff = @Inc_Weekoff, Is_OT = @Is_OT, ExOT_Setting = @ExOT_Setting, Late_Limit = @Late_Limit, Late_Adj_Day = @Late_Adj_Day, Is_PT = @Is_PT, Is_LWF = @Is_LWF, Is_Revenue = @Is_Revenue, Is_PF = @Is_PF, Is_ESIC = @Is_ESIC,
                       Is_Late_Mark = @Is_Late_Mark, Is_Credit = @Is_Credit, LWF_Amount = @LWF_Amount, LWF_Month = @LWF_Month, Revenue_Amount = @Revenue_Amount, Revenue_On_Amount = @Revenue_On_Amount, Credit_Limit = @Credit_Limit, Chk_Server_Date = @Chk_Server_Date, 
                      Is_Cancel_Weekoff = @Is_Cancel_Weekoff, Is_Cancel_Holiday = @Is_Cancel_Holiday, Is_Daily_OT = @Is_Daily_OT, In_Punch_Duration = @In_Punch_Duration, Last_Entry_Duration = @Last_Entry_Duration , OT_App_Limit = @OT_App_Limit, OT_Max_Limit = @OT_Max_Limit, 
                      OT_Fix_Work_Day = @OT_Fix_Work_Day, OT_Fix_Shift_Hours = @OT_Fix_Shift_Hours, OT_Inc_Salary = @OT_Inc_Salary,ESIC_Upper_Limit = @ESIC_Upper_Limit,ESIC_Employer_Contribution = @ESIC_Employer_Contribution,inout_Days=@inout_Days
                    
					                      ,Late_Fix_Work_Days =@Late_Fix_Work_Days
					                     , Late_Fix_shift_Hours=@Late_Fix_shift_Hours
					                      ,Late_Deduction_Days=@Late_Deduction_Days
					                     , Late_Extra_Deduction=@Late_Extra_Deduction
					                     , Is_Late_Calc_On_HO_WO=@Is_Late_Cal_On_HO_WO
					                      , Is_Late_CF=@Is_Late_CF
					                      ,Late_CF_Reset_On=@Late_CF_Reset_On
					                      ,Sal_St_Date =@Sal_St_Date
					                      ,Sal_fix_Days=@Sal_Fix_Days
					                      ,Is_inout_Sal= @Sal_Inout
					                      ,Bonus_Last_Paid_Date = @Last_Bonus					                      
					                    ,Gr_Min_Year=  @Gr_Min_Year 
										,Gr_Cal_Month =@Gr_Cal_Month 
										,Gr_ProRata_Cal =@Gr_ProRata_Cal 
										,Gr_Min_P_Days =@Gr_Min_P_Days
										,Gr_Absent_Days =@Gr_Absent_Days 
										,Short_Fall_Days=@Short_Fall_Days 
										,Gr_Days=@Gr_Days 
										,Gr_Percentage=@Gr_Percentage 
										,Short_Fall_W_Days=@Short_Fall_W_Days 
										,Leave_SMS = @Leave_SMS
										,CTC_Auto_Cal=@CTC_Auto_Cal
										,Inc_Holiday=@Inc_Holiday
										,Probation=@Probation
										,Lv_Month=@Lv_Month
										,Is_Shortfall_Gradewise=@Is_Shortfall_Gradewise
										,Actual_Gross = @Actual_Gross
										,Wages_Amount=@Wage_Amount
										,Dep_Reim_Days=@Dep_Reim_Days
										,Con_Reim_Days=@Con_Reim_Days
										,Late_With_leave=@Late_with_leave
										,Tras_Week_ot=@Tras_Week_ot
										,Bonus_Min_Limit=@Bonus_Min_Limit
										,Bonus_Max_Limit=@Bonus_Max_Limit
										,Bonus_Per=@Bonus_Per
										,Is_Organise_chart=@Is_Organise_chart
										,Is_Zero_Day_Salary=@Is_Zero_Day_Salary
										,Is_OT_Auto_Calc=@OT_Auto
										,OT_Present_days = @OT_Present
										,Is_Negative_Ot  = @Is_Negative_Ot
										,Is_Present =@Is_Present
										,Is_Amount =@Is_Amount
										,Mid_Increment =@Mid_Increment
										,AD_Rounding=@AD_Rounding
										,Lv_Salary_Effect_on_PT = @Lv_Salary_Effect_on_PT--'Added By Falak on 16-FEB-2011
										,Lv_Encash_W_Day = @Lv_Encash_W_Day--'Added By Falak on 16-FEB-2011
										,Lv_Encash_Cal_On = @Lv_Encash_Cal_On
										,In_Out_Login = @In_Out_Login--Added By Nikunj 18-May-2011
										,LWF_Max_Amount = @LWF_Max_Amount --Hardik 27/06/2011
										,LWF_Over_Amount = @LWF_Over_Amount --Hardik 27/06/2011
										,First_In_Last_Out_For_Att_Regularization = @First_In_Last_Out_For_Att_Regularization --Alpesh 04-Aug-2011
										,First_In_Last_Out_For_InOut_Calculation = @First_In_Last_Out_For_InOut_Calculation --Alpesh 04-Aug-2011
										,Late_Count_Exemption=@Late_Count_Exemption	-- Start Added by Mitesh on 18/08/2011
										,Early_Limit=@Early_Limit
										,Early_Adj_Day=@Early_Adj_Day
										,Early_Deduction_Days=@Early_Deduction_Days
										,Early_Extra_Deduction=@Early_Extra_Deduction
										,Early_CF_Reset_On=@Early_CF_Reset_On
										,Is_Early_Calc_On_HO_WO=@Is_Early_Calc_On_HO_WO
										,Is_Early_CF=@Is_Early_CF
										,Early_With_Leave=@Early_With_Leave
										,Early_Count_Exemption=@Early_Count_Exemption
										,Deficit_Limit=@Deficit_Limit
										,Deficit_Adj_Day=@Deficit_Adj_Day
										,Deficit_Deduction_Days=@Deficit_Deduction_Days
										,Deficit_Extra_Deduction=@Deficit_Extra_Deduction
										,Deficit_CF_Reset_On=@Deficit_CF_Reset_On
										,Is_Deficit_Calc_On_HO_WO=@Is_Deficit_Calc_On_HO_WO
										,Is_Deficit_CF=@Is_Deficit_CF
										,Deficit_With_Leave=@Deficit_With_Leave
										,Deficit_Count_Exemption=@Deficit_Count_Exemption			-- End Added by Mitesh on 18/08/2011
										,In_Out_Login_Popup=@In_Out_Login_Popup		
										,Late_Hour_Upper_Rounding =@Late_Hour_Upper_Rounding,is_Late_Calc_Slabwise = @is_Late_Calc_Slabwise ,Late_Calculate_type = @Late_Calculate_type , Early_Hour_Upper_Rounding = @Early_Hour_Upper_Rounding ,is_Early_Calc_Slabwise = @is_Early_Calc_Slabwise ,Early_Calculate_type = @Early_Calculate_type, Is_Zero_Basic_Salary = @Is_Basic_Salary ,Is_PreQuestion = @Is_PreQuestion, Is_CompOff = @Is_CompOff, CompOff_Days_Limit = @CompOff_limit, CompOff_Min_Hours = @CompOff_Min_Hours, Is_CompOff_WD = @Is_CompOff_WD, Is_CompOff_WOHO = @Is_CompOff_WOHO  
										,Is_CF_On_Sal_Days = @Is_CF_On_Sal_Days
										,Days_As_Per_Sal_Days = @Days_As_Per_Sal_Days
										,Max_Late_Limit = @Max_Late_Limit
										,Max_Early_Limit = @Max_Early_Limit
										,Manual_Inout=@Manual_Inout	
										,Allow_Negative_Salary = @Allow_Negative_Salary 
										,Effect_ot_amount = @ESIC_OT_Allow 
										,CompOff_Avail_Days = @CompOff_Avail_Days 
										,Paid_WeekOff_Daily_Wages =@Paid_WeekOff_Daily_Wages
										,Allowed_Full_WeekOf_MidJoining=@Allowed_Full_WeekOf_MidJoining
										,is_weekoff_hour = @is_weekoff_hour , weekoff_hours = @weekoff_hours
										,is_all_emp_prob = @is_all_emp_prob				-- Added By Hiral On 13 Oct,2012
										,late_exemption_limit = @Max_Late_Exem_Limit
										,early_exemption_limit = @Max_Early_Exem_Limit
										,Max_Bonus_salary_Amount=@Max_Bonus_salary_Amount
										,Optional_Holiday_Days = @Optional_Holiday_Days
										,Is_OD_Transfer_to_OT  = @Is_OD_Transfer_to_OT    
										,Is_Co_hour_Editable = @Is_Co_hour_Editable
										,Bonus_Entitle_Limit=@Bonus_Entitle_Limit
										,Allowed_Full_WeekOf_MidJoining_DayRate=@Allowed_Full_WeekOf_MidJoining_DayRate
										,Monthly_Deficit_Adjust_OT_Hrs=@Monthly_Deficit_Adjust_OT_Hrs
										,Half_Day_Excepted_Count = @Half_Day_Excepted_Count
										,Half_Day_Excepted_Max_Count = @Half_Day_Excepted_Max_Count
										,Is_HO_CompOff  = @H_Comp_Off 						----- added by sid 05/02/2014
										,H_CompOff_Days_Limit = @H_CompOff_Limit 			----- added by sid 05/02/2014
										,H_CompOff_Min_Hours = @H_Min_CompOff_Hours 		----- added by sid 05/02/2014
										,H_CompOff_Avail_Days = @H_CompOff_Avail_Days 		----- added by sid 05/02/2014
										,Is_W_CompOff = @W_Comp_Off							----- added by sid 05/02/2014
										,W_CompOff_Days_Limit = @W_CompOff_Limit			----- added by sid 05/02/2014
										,W_CompOff_Min_Hours = @W_Min_CompOff_Hours			----- added by sid 05/02/2014
										,W_CompOff_Avail_Days = @W_CompOff_Avail_Days		----- added by sid 05/02/2014										
										,AllowShowODOptInCompOff = @AllowShowODOptInCompOff ----- added by sid 05/02/2014
										,Is_H_Co_hour_Editable = @Is_H_Co_hour_Editable		----- added by sid 05/02/2014
										,Is_W_Co_hour_Editable = @Is_W_Co_hour_Editable		----- added by sid 05/02/2014
										,Net_Salary_Round = @Net_Salary_Round				--Gadriwala Muslim 03042014
										,type_net_salary_round = @type_net_salary_round		--Gadriwala Muslim 03042014
										,Day_For_Security_Deposit = @Day_For_Security_Deposit
										,OT_RoundingOff_To = @OT_RoundingOff_To 
										,OT_RoundingOff_Lower = @OT_Roundingoff_Lower 
										,MinWODays = @MinWOLimit							-----Added by Ali 05062014
										,MaxWODays = @MaxWOLimit							-----Added by Ali 05062014
										,Chk_otLimit_before_after_Shift_time=@Chk_OT_limit_Before_Shift
										,chk_Lv_On_Working=@Chk_lv_on_Working				----Added by sumit 26112014		
										,Attendance_SMS=@Chk_Attendance_SMS
										,Cutoffdate_Salary=@Sal_CutOf_Date					----Added by sumit 19012015
										,Attndnc_Reg_Max_Cnt=@Max_Cnt_Reg					----Added by sumit 17022015
										,Manual_Salary_Period=@Manual_Salary_Prd			----Added by Sumit 20022015
										,Is_WO_OD = @Is_WO_OD		--Added by Gadriwala Muslim 31032015
										,Is_WD_OD = @Is_WD_OD       --Added by Gadriwala Muslim 31032015
										,Is_HO_OD = @Is_HO_OD		--Added by Gadriwala Muslim 31032015
										,DayRate_WO_Cancel = @DayRate_WO_Cancel
										,Training_Month = @Training_Month
										,Dep_Reim_Days_Traning = @Dep_Reim_Days_Traning
										,Fnf_Fix_Day = @Fnf_Fix_Day
										,LateEarly_Exemption_MaxLimit = @LateEarlyExemMaxLimit ,LateEarly_Exemption_Count = @LateEarlyExempCount
										,Is_Cancel_Holiday_WO_HO_same_day = @Is_Cancel_Holiday_WO_HO_same_day
										,Restrict_Present_days = @Is_Restrict_Present_days	--Ramiz on 08/01/2016
										,Emp_WeekDay_OT_Rate = @Emp_Weekday_OT_Rate
										,Emp_WeekOff_OT_Rate = @Emp_Weekoff_OT_Rate
										,Emp_Holiday_OT_Rate = @Emp_Holiday_OT_Rate
										,Full_PF = @Full_PF
										,Company_Full_PF = @Company_Full_PF
										,is_present_on_holiday = @present_on_holiday
										,Rate_Of_National_Holiday = @Rate_of_national_holiday
										,Late_Mark_Scenario = @Late_Mark_Scenario
										,Late_Adj_Again_OT = @Late_Adj_Again_OT
										,Allowed_Full_WeekOf_MidLeft=@Allowed_FullWeekof_MidLeft
										,Allowed_Full_WeekOf_MidLeft_DayRate=@Allowed_FullWeekof_MidLeft_DayRate
										
										,Audit_Daily_OT_limit = @Audit_Daily_OT_limit -- Added By Jaina 19-08-2016
										,Audit_Daily_Exemption_OT_limit = @Audit_Daily_Exemption_OT_limit -- Added By Jaina 19-08-2016
										,Audit_Daily_Final_OT_limit = @Audit_Daily_Final_OT_limit -- Added By Jaina 19-08-2016
										,Audit_Weekly_OT_limit = @Audit_Weekly_OT_limit -- Added By Jaina 19-08-2016
										,Audit_Weekly_Exemption_OT_limit = @Audit_Weekly_Exemption_OT_limit -- Added By Jaina 19-08-2016
										,Audit_Weekly_Final_OT_limit = @Audit_Weekly_Final_OT_limit -- Added By Jaina 19-08-2016
										,Audit_Monthly_OT_limit = @Audit_Monthly_OT_limit -- Added By Jaina 19-08-2016
										,Audit_Monthly_Exemption_OT_limit = @Audit_Monthly_Exemption_OT_limit -- Added By Jaina 19-08-2016
										,Audit_Monthly_Final_OT_limit = @Audit_Monthly_Final_OT_limit -- Added By Jaina 19-08-2016
										,Audit_Quarterly_OT_limit = @Audit_Quarterly_OT_limit -- Added By Jaina 19-08-2016
										,Audit_Quarterly_Exemption_OT_limit = @Audit_Quarterly_Exemption_OT_limit -- Added By Jaina 19-08-2016
										,Audit_Quarterly_Final_OT_limit = @Audit_Quarterly_Final_OT_limit -- Added By Jaina 19-08-2016
										,Validity_Period_type = @Validity_Period_type   --Added By Jaina 23-08-2016
										,COPH_avail_limit=@COPH_Avail_limit
										,COND_avail_limit=@COND_avail_limit --Added by Sumit on 29092016
										,Is_Customer_Audit = @Is_Customer_Audit  --Added By Jaina 01-10-2016
										,Is_Bonus_Inc = @Is_Bonus_Inc  --added by jimit 03042017
										,Is_Regular_Bon = @Is_Regular_Bon  --added by Rajput 19042017
										,Is_Latemark_Cal_On = @Is_LateMark_Cal_On
										,Is_Latemark_Percentage = @Is_LateMark_Percent
										,Probation_Review = @Probation_Review
										,Trainee_Review = @Trainee_Review
										,Late_Limit_Regularization =@Late_Limit_Regularization  --Added by Jaina 11-01-2018
										,Show_PT_in_Payslip_if_Zero  = @Show_PT_in_Payslip_if_Zero 
										,Show_LWF_in_Payslip_if_Zero = @Show_LWF_in_Payslip_if_Zero 
										,Is_Chk_Late_Early_Mark = @Is_Check_Late_Early_Combine
										,Chk_Last_Late_Early_Month = @Check_Last_LateEarly
										,Global_Salary_Days = @Global_Sal_Days
										,Is_OT_Adj_against_Absent = @Is_OT_Adj_against_Absent
										,OTRateType=@OTRateType -- ADDED BY RAJPUT ON 03072018
										,OTSlabType=@OTSlabType -- ADDED BY RAJPUT ON 03072018
										,Is_Probation_Month_Days=@Is_Probation_Month_Days
										,Is_Trainee_Month_Days=@Is_Trainee_Month_Days
										,Early_Mark_Scenario = @Early_Mark_Scenario
										,Is_Earlymark_Percentage = @Is_EarlyMark_percent
										,Is_EarlyMark_Cal_On = @Is_EarlyMark_Cal_On
										,Holiday_CompOff_Avail_After_Days=@Holiday_CompOff_Avail_After_Days  --added binal 31012020
										,WeekOff_CompOff_Avail_After_Days=@Weekoff_COPH_Avail_After_Days   --added binal 01022020
										,WeekDay_CompOff_Avail_After_Days=@Weekday_COPH_Avail_After_Days    --added binal 01022020
										,Attendance_Reg_Weekday=@Attendance_Reg_Weekday
										,Approval_Up_To_Date=@Approval_Up_To_Date
										,LateEarly_Combine = @LateEarly_Combine
										,Monthly_Exemption_Limit = @Monthly_Exemption_Limit
										,Is_Cancel_Holiday_IfOneSideAbsent = @CancelHolidayOneSideAbsent
										,Is_Cancel_Weekoff_IfOneSideAbsent = @CancelWeekoffOneSideAbsent
										,LateEarly_MonthWise = @LateEarly_MonthWise
										Where Gen_ID = @Gen_ID	And Cmp_Id=@Cmp_Id

					exec P9999_Audit_get @table = 'T0040_GENERAL_SETTING' ,@key_column='Gen_Id',@key_Values=@Gen_ID ,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))								
										--Add By Paras  15-10-2012
									
										
										 set @OldValue = 'old Value' + '#'+ 'For Date :' + cast(ISNULL( @OldFor_Date,'')as varchar(11)) + '#' + 'Inc Weekoff :' + CAST(ISNULL( @OldInc_Weekoff,0)as varchar(1)) + '#' + 'Is OT :' + CAST(ISNULL(@OldIs_OT,0) AS VARCHAR(1)) + '#' + 'ExOT Setting :' +CAST( ISNULL( @OldExOT_Setting,0)AS VARCHAR(18)) + '#' + 'Late Limit :' +ISNULL( @OldLate_Limit,'') + ' #'+ 'Late Adj Day :' +CAST(ISNULL(@OldLate_Adj_Day,0)AS VARCHAR(18)) + ' #'+ 'Is PT :' + CAST(ISNULL( @OldIs_PT,0)as varchar(1)) + ' #'+ 'Is LWF :' + CAST(ISNULL(@OldIs_LWF,0)AS VARCHAR(1))  + ' #'
										                                  + 'Is Revenue :' + cast(ISNULL(@OldIs_Revenue,0)as varchar(1)) + '#' + 'Is PF :' + CAST(ISNULL( @OldIs_PF,0)as varchar(1)) + '#' + 'Is ESIC :' + CAST(ISNULL(@OldIs_ESIC,0) AS VARCHAR(1)) + '#' + 'Is Late Mark :' +CAST( ISNULL( @OldIs_Late_Mark,0)AS VARCHAR(1)) + '#' + 'Is Credit :' +CAST(ISNULL( @OldIs_Credit,0)AS VARCHAR(1)) + ' #'+ 'LWF Amount :' +CAST(ISNULL(@OldLWF_Amount,0)AS VARCHAR(18)) + ' #'+ 'LWF Month :' + ISNULL( @OldLWF_Month,'') + ' #'+ 'Revenue Amount :' + CAST(ISNULL(@OldRevenue_Amount,0)AS VARCHAR(18))  + ' #'    
										                                  + 'Revenue On Amount :' + cast(ISNULL(@OldRevenue_On_Amount,0)as varchar(18)) + '#' + 'Credit Limit :' + CAST(ISNULL(@OldCredit_Limit,0)as varchar(18)) + '#' + 'Chk Server Date :' + CAST(ISNULL(@OldChk_Server_Date,0) AS VARCHAR(1)) + '#' + 'Is Cancel Weekoff :' +CAST( ISNULL( @OldIs_Cancel_Weekoff,0)AS VARCHAR(1)) + '#' + 'Is Cancel Holiday :' +CAST(ISNULL(@OldIs_Cancel_Holiday,0)AS VARCHAR(1)) + ' #'+ 'Is Daily OT :' +CAST(ISNULL(@OldIs_Daily_OT,0)AS VARCHAR(1)) + ' #'+ 'In Punch Duration :' + ISNULL(@OldIn_Punch_Duration,'') + ' #'+ 'Last Entry Duration :' + ISNULL(@OldLast_Entry_Duration,'')  + ' #' 
										                                  + 'OT App Limit:' + ISNULL(@OldOT_App_Limit,'') + '#' + 'OT Max Limit :' + ISNULL(@OldOT_Max_Limit,'') + '#' + 'OT Fix Work Day :' + CAST(ISNULL(@OldOT_Fix_Work_Day,0) AS VARCHAR(18)) + '#' + 'OT Fix Shift Hours :' +ISNULL(@OldOT_Fix_Shift_Hours,'') + '#' + 'OT Inc Salary :' +CAST(ISNULL(@OldOT_Inc_Salary,0)AS VARCHAR(1)) + ' #'+ 'ESIC Upper Limit :' +CAST(ISNULL(@OldESIC_Upper_Limit,0)AS VARCHAR(180)) + ' #'+ 'ESIC Employer Contribution :' + CAST(ISNULL(@OldESIC_Employer_Contribution,0)as varchar(182)) + ' #'+ 'inout Days :' + CAST(ISNULL(@Oldinout_Days,0)AS VARCHAR(182))  + ' #' 
										                                  + 'Late Fix Work Days :' + cast(ISNULL(@OldLate_Fix_Work_Days,0)as varchar(51)) + '#' + 'Late Fix shift Hours :' + ISNULL(@OldLate_Fix_shift_Hours,'') + '#' + 'Late Deduction Days :' + CAST(ISNULL(@OldLate_Deduction_Days,0) AS VARCHAR(31)) + '#' + 'Late Extra Deduction :' +CAST( ISNULL( @OldLate_Extra_Deduction,0)AS VARCHAR(31)) + '#' + 'Is Late Cal On HO WO :' +CAST(ISNULL(@OldIs_Cancel_Holiday,0)AS VARCHAR(1)) + ' #'+ 'Is Late CF :' +CAST(ISNULL(@OldIs_Daily_OT,0)AS VARCHAR(1)) + ' #'+ 'Late CF Reset On :' + ISNULL(@OldLate_CF_Reset_On,'') + ' #'+ 'Sal St Date :' + CAST(ISNULL(@OldLast_Entry_Duration,0)AS VARCHAR(11))  + ' #' 
										                                  + 'Sal Fix Days :' + cast(ISNULL(@OldSal_Fix_Days,0)as varchar(181)) + '#' + 'Sal Inout :' + CAST(ISNULL(@OldSal_Inout,0)as varchar(11)) + '#' + 'Last bonus :' + CAST(ISNULL(@OldLast_bonus,0) AS VARCHAR(11)) + '#' + 'Gr Min Year :' +CAST( ISNULL(@OldGr_Min_Year,0)AS VARCHAR(1)) + '#' + 'Gr Cal Month :' +CAST(ISNULL(@OldGr_Cal_Month,0)AS VARCHAR(1)) + ' #'+ 'Gr ProRata Cal :' +CAST(ISNULL(@OldGr_ProRata_Cal,0)AS VARCHAR(1)) + ' #'+ 'Gr Min P Days :' + CAST(ISNULL(@OldIn_Punch_Duration,0)as varchar(52)) + ' #'+ 'Gr Absent Days :' + CAST(ISNULL(@OldGr_Absent_Days,0)AS VARCHAR(52))  + ' #' 
										                                  + 'Short Fall Days :' + cast(ISNULL(@OldShort_Fall_Days,0)as varchar(52)) + '#' + 'Gr Days :' + CAST(ISNULL(@OldGr_Days,0)as varchar(52)) + '#' + 'Gr Percentage :' + CAST(ISNULL(@OldGr_Percentage,0) AS VARCHAR(52)) + '#' + 'Short Fall W Days :' +CAST( ISNULL(@OldShort_Fall_W_Days,0)AS VARCHAR(52)) + '#' + 'Leave SMS :' +CAST(ISNULL(@OldLeave_SMS,0)AS VARCHAR(52)) + ' #'+ 'CTC Auto Cal :' +CAST(ISNULL(@OldCTC_Auto_Cal,0)AS VARCHAR(52)) + ' #'+ 'Inc Holiday :' + CAST(ISNULL(@OldInc_Holiday,'')as varchar(10)) + ' #'+ 'Probation :' + CAST(ISNULL(@OldProbation,'')AS VARCHAR(20))  + ' #' 
										                                  + 'Lv Month :' + cast(ISNULL(@OldLv_Month,0)as varchar(20)) + '#' + 'Is Shortfall Gradewise :' + CAST(ISNULL(@OldIs_Shortfall_Gradewise,0)as varchar(1)) + '#' + 'Actual Gross :' + CAST(ISNULL(@OldActual_Gross,0) AS VARCHAR(182)) + '#' + 'Wage Amount :' +CAST( ISNULL( @OldWage_Amount,0)AS VARCHAR(182)) + '#' + 'Dep Reim Days :' +CAST(ISNULL(@OldDep_Reim_Days,0)AS VARCHAR(180)) + ' #'+ 'Con Reim Days :' +CAST(ISNULL(@OldCon_Reim_Days,0)AS VARCHAR(182)) + ' #'+ 'Late With Leave :' + CAST(ISNULL(@OldLate_With_Leave,'')as varchar(182)) + ' #'+ 'Tras Week ot :' + CAST(ISNULL(@OldTras_Week_ot,'')AS VARCHAR(1))  + ' #' 
										                                  + 'Bonus Min Limit :' + cast(ISNULL(@OldBonus_Min_Limit,0)as varchar(180)) + '#' + 'Bonus Max Limit :' + CAST(ISNULL(@OldBonus_Max_Limit,0)as varchar(180)) + '#' + 'Bonus Per :' + CAST(ISNULL(@OldBonus_Per,0) AS VARCHAR(182)) + '#' + 'Is Organise chart :' +CAST( ISNULL(@OldIs_Organise_chart,0)AS VARCHAR(1)) + '#' + 'Is Zero Day Salary :' +CAST(ISNULL(@OldIs_Zero_Day_Salary,0)AS VARCHAR(1)) + ' #'+ 'OT Auto :' +CAST(ISNULL(@OldOT_Auto,0)AS VARCHAR(1)) + ' #'+ 'OT Present :' + CAST(ISNULL(@OldOT_Present,0)as varchar(4)) + ' #'+ 'Is Negative Ot :' + CAST(ISNULL(@OldIs_Negative_Ot,0)AS VARCHAR(4))  + ' #' 
										                                  + 'Is Present :' + cast(ISNULL(@OldIs_Present,0)as varchar(180)) + '#' + 'Is Amount :' + CAST(ISNULL(@OldIs_Amount,0)as varchar(180)) + '#' + 'Mid Increment :' + CAST(ISNULL(@OldMid_Increment,0) AS VARCHAR(180)) + '#' + 'AD Rounding :' +CAST( ISNULL(@OldAD_Rounding,0)AS VARCHAR(180)) + '#' + 'Lv Salary Effect on PT :' +CAST(ISNULL(@OldLv_Salary_Effect_on_PT,0)AS VARCHAR(10)) + ' #'+ 'Lv Encash W Day :' +CAST(ISNULL(@OldLv_Encash_W_Day,0)AS VARCHAR(10)) + ' #'+ 'Lv Encash Cal On :' + ISNULL(@OldLv_Encash_Cal_On,'') + ' #'+ 'In Out Login :' + CAST(ISNULL(@OldIn_Out_Login,'')AS VARCHAR(4))  + ' #' 
										                                  + 'LWF Max Amount :' + cast(ISNULL(@OldLWF_Max_Amount,0)as varchar(182)) + '#' + 'LWF Over Amount :' + CAST(ISNULL(@OldLWF_Over_Amount,0)as varchar(182)) + '#' + 'First In Last Out For Att Regularization :' + CAST(ISNULL(@OldFirst_In_Last_Out_For_Att_Regularization,0) AS VARCHAR(1)) + '#' + 'First In Last Out For InOut Calculation :' +CAST( ISNULL(@OldFirst_In_Last_Out_For_InOut_Calculation,0)AS VARCHAR(1)) + '#' + 'Late Count Exemption :' +CAST(ISNULL(@OldLate_Count_Exemption,0)AS VARCHAR(20)) + ' #'+ 'Early Limit :' +ISNULL(@OldEarly_Limit,'') + ' #'+ 'Early Adj Day :' + CAST(ISNULL(@OldEarly_Adj_Day,'')as varchar(18)) + ' #'+ 'Early Deduction Days :' + CAST(ISNULL(@OldEarly_Deduction_Days,'')AS VARCHAR(31))  + ' #' 
										                                  + 'Early Extra Deduction :' + cast(ISNULL(@OldEarly_Extra_Deduction,0)as varchar(31)) + '#' + 'Early CF Reset On :' + ISNULL(@OldEarly_CF_Reset_On,'') + '#' + 'Is Early Calc On HO WO :' + CAST(ISNULL(@OldIs_Early_Calc_On_HO_WO,0) AS VARCHAR(1)) + '#' + 'Is Early CF:' +CAST( ISNULL(@OldIs_Early_CF,0)AS VARCHAR(1)) + '#' + 'Early With Leave :' +CAST(ISNULL(@OldEarly_With_Leave,0)AS VARCHAR(3)) + ' #'+ 'Early Count Exemption	:' +CAST(ISNULL(@OldEarly_Count_Exemption,'')AS VARCHAR(20)) + ' #'+ 'Deficit Limit :' + ISNULL(@OldDeficit_Limit,'') + ' #'+ 'Deficit Adj Day :' + CAST(ISNULL(@OldDeficit_Adj_Day,'')AS VARCHAR(18))  + ' #' 
										                                  + 'Deficit Deduction Days :' + cast(ISNULL(@OldDeficit_Deduction_Days,0)as varchar(31)) + '#' + 'Deficit Extra Deduction :' + CAST(ISNULL(@OldDeficit_Extra_Deduction,0)as varchar(31)) + '#' + 'Deficit CF Reset On :' +ISNULL(@OldDeficit_CF_Reset_On,'')  + '#' + 'Is Deficit Calc On HO WO:' +CAST( ISNULL(@OldIs_Deficit_Calc_On_HO_WO,0)AS VARCHAR(1)) + '#' + 'Is Deficit CF :' +CAST(ISNULL(@OldIs_Deficit_CF,0)AS VARCHAR(1)) + ' #'+ 'Deficit With Leave	:' +CAST(ISNULL(@OldDeficit_With_Leave,'')AS VARCHAR(5)) + ' #'+ 'Deficit Count Exemption :' + CAST(ISNULL(@OldDeficit_Count_Exemption,'')as varchar(20)) + ' #'+ 'In Out Login Popup:' + CAST(ISNULL(@OldIn_Out_Login_Popup,'')AS VARCHAR(4))  + ' #' 
										                                  + 'Late Hour Upper Rounding :' + cast(ISNULL(@OldLate_Hour_Upper_Rounding,0)as varchar(182)) + '#' + 'is Late Calc Slabwise :' + CAST(ISNULL(@Oldis_Late_Calc_Slabwise,0)as varchar(1)) + '#' + 'Late Calculate type :' + ISNULL(@OldLate_Calculate_type,'') + '#' + 'Early Hour Upper Rounding  :' +CAST( ISNULL( @OldEarly_Hour_Upper_Rounding ,0)AS VARCHAR(182)) + '#' + 'is Early Calc Slabwise:' +CAST(ISNULL(@Oldis_Early_Calc_Slabwise,0)AS VARCHAR(1)) + ' #'+ 'Early Calculate type :' +CAST(ISNULL(@OldEarly_Calculate_type,0)AS VARCHAR(10)) + ' #'+ 'Is Basic Salary :' + CAST(ISNULL(@OldIs_Basic_Salary,'')as varchar(1)) + ' #'+ 'Is PreQuestion :' + CAST(ISNULL(@OldIs_PreQuestion,'')AS VARCHAR(1))  + ' #' 
										                                  + 'Is CompOff :' + cast(ISNULL(@OldIs_CompOff,0)as varchar(1)) + '#' + 'CompOff limit :' + CAST(ISNULL(@OldCompOff_limit,0)as varchar(180)) + '#' + 'CompOff Min Hours :' + ISNULL(@OldCompOff_Min_Hours,'')  + '#' + 'Is CompOff WD :' +CAST(ISNULL(@OldIs_CompOff_WD,0)AS VARCHAR(1)) + '#' + 'Is CompOff WOHO:' +CAST(ISNULL(@OldIs_CompOff_WOHO,0)AS VARCHAR(1)) + ' #'+ 'Is CF On Sal Days :' +CAST(ISNULL(@OldIs_CF_On_Sal_Days,0)AS VARCHAR(1)) + ' #'+ 'Days As Per Sal Days :' + CAST(ISNULL(@OldDays_As_Per_Sal_Days,'')as varchar(1)) + ' #'+ 'Max Late Limit :' + ISNULL(@OldMax_Late_Limit,'')  + ' #' 
										                                  + 'Max Early Limit :' + cast(ISNULL(@OldMax_Early_Limit,0)as varchar(50)) + '#' + 'Manual Inout :' + CAST(ISNULL(@OldManual_Inout,0)as varchar(4)) + '#' + 'Allow Negative Salary :' + CAST(ISNULL(@OldAllow_Negative_Salary,0) AS VARCHAR(1)) + '#' + 'ESIC OT Allow:' +CAST( ISNULL( @OldESIC_OT_Allow,0)AS VARCHAR(1)) + '#' + 'CompOff Avail Days:' +CAST(ISNULL(@OldCompOff_Avail_Days,0)AS VARCHAR(180)) + ' #'+ 'Paid WeekOff Daily Wages :' +CAST(ISNULL(@OldPaid_WeekOff_Daily_Wages,0)AS VARCHAR(1)) + ' #'+ 'Allowed Full WeekOf MidJoining:' + CAST(ISNULL(@OldAllowed_Full_WeekOf_MidJoining,'')as varchar(1)) + ' #'+ 'isweekoff hour :' + CAST(ISNULL(@Oldis_weekoff_hour,'')AS VARCHAR(2))  + ' #' 
										                                  + 'weekoff hours :' + ISNULL(@Oldweekoff_hours,0) + '#' + 'is all emp prob :' + CAST(ISNULL(@Oldis_all_emp_prob,0)as varchar(1)) + '#' +
										                   +  'New Value' + '#'+ 'For Date :' + cast(ISNULL( @For_Date,'')as varchar(11)) + '#' + 'Inc Weekoff :' + CAST(ISNULL( @Inc_Weekoff,0)as varchar(1)) + '#' + 'Is OT :' + CAST(ISNULL(@Is_OT,0) AS VARCHAR(1)) + '#' + 'ExOT Setting :' +CAST( ISNULL( @ExOT_Setting,0)AS VARCHAR(18)) + '#' + 'Late Limit :' +ISNULL( @Late_Limit,'') + ' #'+ 'Late Adj Day :' +CAST(ISNULL(@Late_Adj_Day,0)AS VARCHAR(18)) + ' #'+ 'Is PT :' + CAST(ISNULL( @Is_PT,0)as varchar(1)) + ' #'+ 'Is LWF :' + CAST(ISNULL(@Is_LWF,0)AS VARCHAR(1))  + ' #'
										                                  + 'Is Revenue :' + cast(ISNULL(@Is_Revenue,0)as varchar(1)) + '#' + 'Is PF :' + CAST(ISNULL( @Is_PF,0)as varchar(1)) + '#' + 'Is ESIC :' + CAST(ISNULL(@Is_ESIC,0) AS VARCHAR(1)) + '#' + 'Is Late Mark :' +CAST( ISNULL( @Is_Late_Mark,0)AS VARCHAR(1)) + '#' + 'Is Credit :' +CAST(ISNULL( @Is_Credit,0)AS VARCHAR(1)) + ' #'+ 'LWF Amount :' +CAST(ISNULL(@LWF_Amount,0)AS VARCHAR(18)) + ' #'+ 'LWF Month :' + ISNULL( @LWF_Month,'') + ' #'+ 'Revenue Amount :' + CAST(ISNULL(@Revenue_Amount,0)AS VARCHAR(18))  + ' #'    
										                                  + 'Revenue On Amount :' + cast(ISNULL(@Revenue_On_Amount,0)as varchar(18)) + '#' + 'Credit Limit :' + CAST(ISNULL(@Credit_Limit,0)as varchar(18)) + '#' + 'Chk Server Date :' + CAST(ISNULL(@Chk_Server_Date,0) AS VARCHAR(1)) + '#' + 'Is Cancel Weekoff :' +CAST( ISNULL( @Is_Cancel_Weekoff,0)AS VARCHAR(1)) + '#' + 'Is Cancel Holiday :' +CAST(ISNULL(@Is_Cancel_Holiday,0)AS VARCHAR(1)) + ' #'+ 'Is Daily OT :' +CAST(ISNULL(@Is_Daily_OT,0)AS VARCHAR(1)) + ' #'+ 'In Punch Duration :' + ISNULL(@In_Punch_Duration,'') + ' #'+ 'Last Entry Duration :' + ISNULL(@Last_Entry_Duration,'')  + ' #' 
										                                  + 'OT App Limit:' + ISNULL(@OT_App_Limit,'') + '#' + 'OT Max Limit :' + ISNULL(@OT_Max_Limit,'') + '#' + 'OT Fix Work Day :' + CAST(ISNULL(@OT_Fix_Work_Day,0) AS VARCHAR(18)) + '#' + 'OT Fix Shift Hours :' +ISNULL(@OT_Fix_Shift_Hours,'') + '#' + 'OT Inc Salary :' +CAST(ISNULL(@OT_Inc_Salary,0)AS VARCHAR(1)) + ' #'+ 'ESIC Upper Limit :' +CAST(ISNULL(@ESIC_Upper_Limit,0)AS VARCHAR(180)) + ' #'+ 'ESIC Employer Contribution :' + CAST(ISNULL(@ESIC_Employer_Contribution,0)as varchar(182)) + ' #'+ 'inout Days :' + CAST(ISNULL(@inout_Days,0)AS VARCHAR(182))  + ' #' 
										                                  + 'Late Fix Work Days :' + cast(ISNULL(@Late_Fix_Work_Days,0)as varchar(51)) + '#' + 'Late Fix shift Hours :' + ISNULL(@Late_Fix_shift_Hours,'') + '#' + 'Late Deduction Days :' + CAST(ISNULL(@Late_Deduction_Days,0) AS VARCHAR(31)) + '#' + 'Late Extra Deduction :' +CAST( ISNULL( @Late_Extra_Deduction,0)AS VARCHAR(31)) + '#' + 'Is Late Cal On HO WO :' +CAST(ISNULL(@Is_Cancel_Holiday,0)AS VARCHAR(1)) + ' #'+ 'Is Late CF :' +CAST(ISNULL(@Is_Daily_OT,0)AS VARCHAR(1)) + ' #'+ 'Late CF Reset On :' + ISNULL(@Late_CF_Reset_On,'') + ' #'+ 'Sal St Date :' + CAST(ISNULL(@Last_Entry_Duration,0)AS VARCHAR(11))  + ' #' 
										                                  + 'Sal Fix Days :' + cast(ISNULL(@Sal_Fix_Days,0)as varchar(181)) + '#' + 'Sal Inout :' + CAST(ISNULL(@Sal_Inout,0)as varchar(11)) + '#' + 'Last bonus :' + CAST(ISNULL(@Last_bonus,0) AS VARCHAR(11)) + '#' + 'Gr Min Year :' +CAST( ISNULL(@Gr_Min_Year,0)AS VARCHAR(1)) + '#' + 'Gr Cal Month :' +CAST(ISNULL(@Gr_Cal_Month,0)AS VARCHAR(1)) + ' #'+ 'Gr ProRata Cal :' +CAST(ISNULL(@Gr_ProRata_Cal,0)AS VARCHAR(1)) + ' #'+ 'Gr Min P Days :' + CAST(ISNULL(@In_Punch_Duration,0)as varchar(52)) + ' #'+ 'Gr Absent Days :' + CAST(ISNULL(@Gr_Absent_Days,0)AS VARCHAR(52))  + ' #' 
										                                  + 'Short Fall Days :' + cast(ISNULL(@Short_Fall_Days,0)as varchar(52)) + '#' + 'Gr Days :' + CAST(ISNULL(@Gr_Days,0)as varchar(52)) + '#' + 'Gr Percentage :' + CAST(ISNULL(@Gr_Percentage,0) AS VARCHAR(52)) + '#' + 'Short Fall W Days :' +CAST( ISNULL( @Short_Fall_W_Days,0)AS VARCHAR(52)) + '#' + 'Leave SMS :' +CAST(ISNULL(@Leave_SMS,0)AS VARCHAR(52)) + ' #'+ 'CTC Auto Cal :' +CAST(ISNULL(@CTC_Auto_Cal,0)AS VARCHAR(52)) + ' #'+ 'Inc Holiday :' + CAST(ISNULL(@Inc_Holiday,'')as varchar(10)) + ' #'+ 'Probation :' + CAST(ISNULL(@Probation,'')AS VARCHAR(20))  + ' #' 
										                                  + 'Lv Month :' + cast(ISNULL(@Lv_Month,0)as varchar(20)) + '#' + 'Is Shortfall Gradewise :' + CAST(ISNULL(@Is_Shortfall_Gradewise,0)as varchar(1)) + '#' + 'Actual Gross :' + CAST(ISNULL(@Actual_Gross,0) AS VARCHAR(182)) + '#' + 'Wage Amount :' +CAST( ISNULL( @Wage_Amount,0)AS VARCHAR(182)) + '#' + 'Dep Reim Days :' +CAST(ISNULL(@Dep_Reim_Days,0)AS VARCHAR(180)) + ' #'+ 'Con Reim Days :' +CAST(ISNULL(@Con_Reim_Days,0)AS VARCHAR(182)) + ' #'+ 'Late With Leave :' + CAST(ISNULL(@Late_With_Leave,'')as varchar(182)) + ' #'+ 'Tras Week ot :' + CAST(ISNULL(@Tras_Week_ot,'')AS VARCHAR(1))  + ' #' 
										                                  + 'Bonus Min Limit :' + cast(ISNULL(@Bonus_Min_Limit,0)as varchar(180)) + '#' + 'Bonus Max Limit :' + CAST(ISNULL(@Bonus_Max_Limit,0)as varchar(180)) + '#' + 'Bonus Per :' + CAST(ISNULL(@Bonus_Per,0) AS VARCHAR(182)) + '#' + 'Is Organise chart :' +CAST( ISNULL(@Is_Organise_chart,0)AS VARCHAR(1)) + '#' + 'Is Zero Day Salary :' +CAST(ISNULL(@Is_Zero_Day_Salary,0)AS VARCHAR(1)) + ' #'+ 'OT Auto :' +CAST(ISNULL(@OT_Auto,0)AS VARCHAR(1)) + ' #'+ 'OT Present :' + CAST(ISNULL(@OT_Present,0)as varchar(4)) + ' #'+ 'Is Negative Ot :' + CAST(ISNULL(@Is_Negative_Ot,0)AS VARCHAR(4))  + ' #' 
										                                  + 'Is Present :' + cast(ISNULL(@Is_Present,0)as varchar(180)) + '#' + 'Is Amount :' + CAST(ISNULL(@Is_Amount,0)as varchar(180)) + '#' + 'Mid Increment :' + CAST(ISNULL(@Mid_Increment,0) AS VARCHAR(180)) + '#' + 'AD Rounding :' +CAST( ISNULL(@AD_Rounding,0)AS VARCHAR(180)) + '#' + 'Lv Salary Effect on PT :' +CAST(ISNULL(@Lv_Salary_Effect_on_PT,0)AS VARCHAR(10)) + ' #'+ 'Lv Encash W Day :' +CAST(ISNULL(@Lv_Encash_W_Day,0)AS VARCHAR(10)) + ' #'+ 'Lv Encash Cal On :' + ISNULL(@Lv_Encash_Cal_On,'') + ' #'+ 'In Out Login :' + CAST(ISNULL(@In_Out_Login,'')AS VARCHAR(4))  + ' #' 
										                                  + 'LWF Max Amount :' + cast(ISNULL(@LWF_Max_Amount,0)as varchar(182)) + '#' + 'LWF Over Amount :' + CAST(ISNULL(@LWF_Over_Amount,0)as varchar(182)) + '#' + 'First In Last Out For Att Regularization :' + CAST(ISNULL(@First_In_Last_Out_For_Att_Regularization,0) AS VARCHAR(1)) + '#' + 'First In Last Out For InOut Calculation :' +CAST( ISNULL(@First_In_Last_Out_For_InOut_Calculation,0)AS VARCHAR(1)) + '#' + 'Late Count Exemption :' +CAST(ISNULL(@Late_Count_Exemption,0)AS VARCHAR(20)) + ' #'+ 'Early Limit :' +ISNULL(@Early_Limit,'') + ' #'+ 'Early Adj Day :' + CAST(ISNULL(@Early_Adj_Day,'')as varchar(18)) + ' #'+ 'Early Deduction Days :' + CAST(ISNULL(@Early_Deduction_Days,'')AS VARCHAR(31))  + ' #' 
										                                  + 'Early Extra Deduction :' + cast(ISNULL(@Early_Extra_Deduction,0)as varchar(31)) + '#' + 'Early CF Reset On :' + ISNULL(@Early_CF_Reset_On,'') + '#' + 'Is Early Calc On HO WO :' + CAST(ISNULL(@Is_Early_Calc_On_HO_WO,0) AS VARCHAR(1)) + '#' + 'Is Early CF:' +CAST( ISNULL(@Is_Early_CF,0)AS VARCHAR(1)) + '#' + 'Early With Leave :' +CAST(ISNULL(@Early_With_Leave,0)AS VARCHAR(3)) + ' #'+ 'Early Count Exemption	:' +CAST(ISNULL(@Early_Count_Exemption,'')AS VARCHAR(20)) + ' #'+ 'Deficit Limit :' + ISNULL(@Deficit_Limit,'') + ' #'+ 'Deficit Adj Day :' + CAST(ISNULL(@Deficit_Adj_Day,'')AS VARCHAR(18))  + ' #' 
										                                  + 'Deficit Deduction Days :' + cast(ISNULL(@Deficit_Deduction_Days,0)as varchar(31)) + '#' + 'Deficit Extra Deduction :' + CAST(ISNULL(@Deficit_Extra_Deduction,0)as varchar(31)) + '#' + 'Deficit CF Reset On :' +ISNULL(@Deficit_CF_Reset_On,'')  + '#' + 'Is Deficit Calc On HO WO:' +CAST( ISNULL(@Is_Deficit_Calc_On_HO_WO,0)AS VARCHAR(1)) + '#' + 'Is Deficit CF :' +CAST(ISNULL(@Is_Deficit_CF,0)AS VARCHAR(1)) + ' #'+ 'Deficit With Leave	:' +CAST(ISNULL(@Deficit_With_Leave,'')AS VARCHAR(5)) + ' #'+ 'Deficit Count Exemption :' + CAST(ISNULL(@Deficit_Count_Exemption,'')as varchar(20)) + ' #'+ 'In Out Login Popup:' + CAST(ISNULL(@In_Out_Login_Popup,'')AS VARCHAR(4))  + ' #' 
										                                  + 'Late Hour Upper Rounding :' + cast(ISNULL(@Late_Hour_Upper_Rounding,0)as varchar(182)) + '#' + 'is Late Calc Slabwise :' + CAST(ISNULL(@is_Late_Calc_Slabwise,0)as varchar(1)) + '#' + 'Late Calculate type :' + ISNULL(@Late_Calculate_type,'') + '#' + 'Early Hour Upper Rounding  :' +CAST( ISNULL( @Early_Hour_Upper_Rounding ,0)AS VARCHAR(182)) + '#' + 'is Early Calc Slabwise:' +CAST(ISNULL(@is_Early_Calc_Slabwise,0)AS VARCHAR(1)) + ' #'+ 'Early Calculate type :' +CAST(ISNULL(@Early_Calculate_type,0)AS VARCHAR(10)) + ' #'+ 'Is Basic Salary :' + CAST(ISNULL(@Is_Basic_Salary,'')as varchar(1)) + ' #'+ 'Is PreQuestion :' + CAST(ISNULL(@Is_PreQuestion,'')AS VARCHAR(1))  + ' #' 
										                                  + 'Is CompOff :' + cast(ISNULL(@Is_CompOff,0)as varchar(1)) + '#' + 'CompOff limit :' + CAST(ISNULL(@CompOff_limit,0)as varchar(180)) + '#' + 'CompOff Min Hours :' + ISNULL(@CompOff_Min_Hours,'')  + '#' + 'Is CompOff WD :' +CAST(ISNULL(@Is_CompOff_WD,0)AS VARCHAR(1)) + '#' + 'Is CompOff WOHO:' +CAST(ISNULL(@Is_CompOff_WOHO,0)AS VARCHAR(1)) + ' #'+ 'Is CF On Sal Days :' +CAST(ISNULL(@Is_CF_On_Sal_Days,0)AS VARCHAR(1)) + ' #'+ 'Days As Per Sal Days :' + CAST(ISNULL(@Days_As_Per_Sal_Days,'')as varchar(1)) + ' #'+ 'Max Late Limit :' + ISNULL(@Max_Late_Limit,'')  + ' #' 
										                                  + 'Max Early Limit :' + cast(ISNULL(@Max_Early_Limit,0)as varchar(50)) + '#' + 'Manual Inout :' + CAST(ISNULL(@Manual_Inout,0)as varchar(4)) + '#' + 'Allow Negative Salary :' + CAST(ISNULL(@Allow_Negative_Salary,0) AS VARCHAR(1)) + '#' + 'ESIC OT Allow:' +CAST( ISNULL( @ESIC_OT_Allow,0)AS VARCHAR(1)) + '#' + 'CompOff Avail Days:' +CAST(ISNULL(@CompOff_Avail_Days,0)AS VARCHAR(180)) + ' #'+ 'Paid WeekOff Daily Wages :' +CAST(ISNULL(@Paid_WeekOff_Daily_Wages,0)AS VARCHAR(1)) + ' #'+ 'Allowed Full WeekOf MidJoining:' + CAST(ISNULL(@Allowed_Full_WeekOf_MidJoining,'')as varchar(1)) + ' #'+ 'isweekoff hour :' + CAST(ISNULL(@is_weekoff_hour,'')AS VARCHAR(2))  + ' #' 
										                                  + 'weekoff hours :' + ISNULL(@weekoff_hours,0) + '#' + 'is all emp prob :' + CAST(ISNULL(@is_all_emp_prob,0)as varchar(1)) 
										  
										
				end
				
	Else If UPPER(@tran_type) ='D'
			BEGIN
			-----Add By paras 16-10-2012
			
			--select @OldFor_Date  =ISNULL(For_Date,'') ,@OldInc_Weekoff  =ISNULL(Inc_Weekoff,''),@OldIs_OT  =isnull(Is_OT,0),@OldExOT_Setting  =isnull(ExOT_Setting,0),@OldLate_Limit =isnull(Late_Limit,''),@OldLate_Adj_Day  =isnull(Late_Adj_Day,0),@OldIs_PT = isnull(Is_PT,0),@OldIs_LWF  =isnull(Is_LWF ,0) ,
										
			--						          @OldIs_Revenue  =ISNULL(Is_Revenue,0) ,@OldIs_PF  =ISNULL(Is_PF,0),@OldIs_ESIC  =isnull(Is_ESIC,0),@OldIs_Late_Mark  =isnull(Is_Late_Mark,0),@OldIs_Credit  =isnull(Is_Credit,0),@OldLWF_Amount  = isnull(LWF_Amount,0),@OldLWF_Month  =isnull(LWF_Month ,0),@OldRevenue_Amount =isnull(Revenue_Amount,0),
										       
			--							       @OldRevenue_On_Amount  =ISNULL(Revenue_On_Amount,0) ,@OldCredit_Limit =ISNULL(Credit_Limit,0),@OldChk_Server_Date  =isnull(Chk_Server_Date,0),@OldIs_Cancel_Weekoff  =isnull(Is_Cancel_Weekoff,0),@OldIs_Cancel_Holiday =isnull(Is_Cancel_Holiday,0),@OldIs_Daily_OT  =isnull(Is_Daily_OT,0),@OldIn_Punch_Duration  = isnull(In_Punch_Duration,''),@OldLast_Entry_Duration  =isnull(Last_Entry_Duration ,0) ,
										       
			--							       @OldOT_App_Limit  =ISNULL(OT_App_Limit,'') ,@OldOT_Max_Limit  =ISNULL(OT_Max_Limit,''),@OT_Fix_Work_Day =isnull(OT_Fix_Work_Day,0),@OldOT_Fix_Shift_Hours  =isnull(OT_Fix_Shift_Hours,0),@OldOT_Inc_Salary =isnull(OT_Inc_Salary,0),@OldESIC_Upper_Limit  =isnull(ESIC_Upper_Limit,0),@OldESIC_Employer_Contribution  = isnull(ESIC_Employer_Contribution,''),@Oldinout_Days  =isnull(inout_Days ,0)  ,
										       
			--							       @OldLate_Fix_Work_Days  =ISNULL(Late_Fix_Work_Days,0) ,@OldLate_Fix_shift_Hours  =ISNULL(Late_Fix_Shift_Hours,0),@OldLate_Deduction_Days  =isnull(Late_Deduction_Days,0),@OldLate_Extra_Deduction  =isnull(Late_Extra_Deduction,0),@OldIs_Late_Cal_On_HO_WO  =isnull(Is_Late_Calc_On_HO_WO,0),@OldIs_Late_CF  = isnull(Is_Late_CF,0),@OldLate_CF_Reset_On  =isnull(Late_CF_Reset_On ,0),@OldSal_St_Date =isnull(Sal_St_Date,0),
										       
			--							       @OldSal_Fix_Days  =ISNULL(Sal_Fix_Days,0) ,@OldSal_Inout  =ISNULL(Is_Inout_Sal,''),@OldLast_bonus  =isnull(Bonus_Last_Paid_Date,0),@OldGr_Min_Year  =isnull(Gr_Min_Year,0),@OldGr_Cal_Month =isnull(Gr_Cal_Month,0),@OldGr_ProRata_Cal  =isnull(Gr_ProRata_Cal,0),@OldGr_Min_P_Days  = isnull(Gr_Min_P_Days,''),@OldGr_Absent_Days  =isnull(Gr_Absent_Days ,0) ,
										       
			--							       @OldShort_Fall_Days  =ISNULL(Short_Fall_Days,'') ,@OldGr_Days  =ISNULL(Gr_Days,''),@OldGr_Percentage  =isnull(Gr_Percentage,0),@OldShort_Fall_W_Days =isnull(Short_Fall_W_Days,0),@OldLeave_SMS  =isnull(Leave_SMS,0),@OldCTC_Auto_Cal = isnull(CTC_Auto_Cal,''),@OldInc_Holiday  =isnull(Inc_Holiday ,0),@OldProbation  =isnull(Probation ,0),
										       
			--							       @OldLv_Month  =ISNULL(Lv_Month,'') ,@OldIs_Shortfall_Gradewise  =ISNULL(Is_Shortfall_Gradewise,''),@OldActual_Gross  =isnull(Actual_Gross,0),@OldWage_Amount =isnull(Wages_Amount,0),@OldDep_Reim_Days =isnull(Dep_Reim_Days,0),@OldCon_Reim_Days  =isnull(Con_Reim_Days,0),@OldLate_With_Leave  = isnull(Late_With_Leave,''),@OldTras_Week_ot  =isnull(Tras_Week_ot ,0),
										       
			--							       @OldBonus_Min_Limit =ISNULL(Bonus_Min_Limit,'') ,@OldBonus_Max_Limit  =ISNULL(Bonus_Max_Limit,''),@OldBonus_Per  =isnull(Bonus_Per,0),@OldIs_Organise_chart  =isnull(Is_Organise_chart,0),@OldIs_Zero_Day_Salary=isnull(Is_Zero_Day_Salary,0),@OldOT_Auto   =isnull(Is_OT_Auto_Calc,0),@OldOT_Present = isnull(OT_Present_Days,''),@OldIs_Negative_Ot  =isnull(Is_Negative_Ot ,0),
										       
			--							       @OldIs_Present  =ISNULL(Is_Present,'') ,@OldIs_Amount =ISNULL(Is_Amount,''),@OldMid_Increment =isnull(Mid_Increment,0),@OldAD_Rounding   =isnull(AD_Rounding ,0),@OldLv_Salary_Effect_on_PT =isnull(Lv_Salary_Effect_on_PT,0),@OldLv_Encash_W_Day  =isnull(Lv_Encash_W_Day,0),@OldLv_Encash_Cal_On = isnull(Lv_Encash_Cal_On,''),@OldIn_Out_Login =isnull(In_Out_Login ,0),
										       
			--							       @OldLWF_Max_Amount  =ISNULL(LWF_Max_Amount,'') ,@OldLWF_Over_Amount  =ISNULL(LWF_Over_Amount,''),@OldFirst_In_Last_Out_For_Att_Regularization  =isnull(First_In_Last_Out_For_Att_Regularization,0),@OldFirst_In_Last_Out_For_InOut_Calculation  =isnull(First_In_Last_Out_For_InOut_Calculation,0),@OldLate_Count_Exemption =isnull(Late_Count_Exemption,0),@OldEarly_Limit  =isnull(Early_Limit,0),@OldEarly_Adj_Day  = isnull(Early_Adj_Day,''),@OldEarly_Deduction_Days  =isnull(Early_Deduction_Days ,0) ,
										       
			--							       @OldEarly_Extra_Deduction =ISNULL(Early_Extra_Deduction,'') ,@OldEarly_CF_Reset_On =ISNULL(Early_CF_Reset_On,''),@OldIs_Early_Calc_On_HO_WO =isnull(Is_Early_Calc_On_HO_WO,0),@OldIs_Early_CF  =isnull(Is_Early_CF,0),@OldEarly_With_Leave=isnull(Early_With_Leave,0),@OldEarly_Count_Exemption =isnull(Early_Count_Exemption,0),@OldDeficit_Limit  = isnull(Deficit_Limit,''),@OldDeficit_Adj_Day  =isnull(Deficit_Adj_Day ,0) ,
										       
			--							       @OldDeficit_Deduction_Days  =ISNULL(Deficit_Deduction_Days,'') ,@OldDeficit_Extra_Deduction  =ISNULL(Deficit_Extra_Deduction,''),@OldDeficit_CF_Reset_On =isnull(Deficit_CF_Reset_On,0),@OldIs_Deficit_Calc_On_HO_WO  =isnull(Is_Deficit_Calc_On_HO_WO,0),@OldIs_Deficit_CF =isnull(Is_Deficit_CF,0),@OldDeficit_With_Leave  =isnull(Deficit_With_Leave,0),@OldDeficit_Count_Exemption  = isnull(Deficit_Count_Exemption,''),@OldIn_Out_Login_Popup  =isnull(In_Out_Login_Popup ,0) ,
										       
			--							       @OldLate_Hour_Upper_Rounding  =ISNULL(Late_Hour_Upper_Rounding,'') ,@Oldis_Late_Calc_Slabwise  =ISNULL(is_Late_Calc_Slabwise,''),@OldLate_Calculate_type   =isnull(Late_Calculate_type ,0),@OldEarly_Hour_Upper_Rounding  =isnull(Early_Hour_Upper_Rounding,0),@OldIs_PreQuestion =isnull(Is_PreQuestion,0),@Oldis_Early_Calc_Slabwise  =isnull(is_Early_Calc_Slabwise,0),@OldEarly_Calculate_type  = isnull(Early_Calculate_type,''),@OldIs_Basic_Salary  =isnull(Is_Zero_Basic_Salary ,0),
										       
			--							       @OldIs_CompOff  =ISNULL(Is_CompOff,'') ,@OldCompOff_limit  =ISNULL(CompOff_Days_Limit,''),@OldCompOff_Min_Hours  =isnull(CompOff_Min_Hours,0),@OldIs_CompOff_WD  =isnull(Is_CompOff_WD,0),@OldIs_CompOff_WOHO =isnull(Is_CompOff_WOHO,0),@OldIs_CF_On_Sal_Days  =isnull(Is_CF_On_Sal_Days,0),@OldDays_As_Per_Sal_Days  = isnull(Days_As_Per_Sal_Days,''),@OldMax_Late_Limit  =isnull(Max_Late_Limit ,0),
										       
			--							       @OldMax_Early_Limit  =ISNULL(Max_Early_Limit,'') ,@OldManual_Inout  =ISNULL(Manual_Inout,''),@OldAllow_Negative_Salary  =isnull(Allow_Negative_Salary,0),@OldESIC_OT_Allow  =isnull(Effect_ot_amount,0),@OldCompOff_Avail_Days =isnull(CompOff_Avail_Days,0),@OldPaid_WeekOff_Daily_Wages  =isnull(Paid_WeekOff_Daily_Wages,0),@OldAllowed_Full_WeekOf_MidJoining  = isnull(Allowed_Full_WeekOf_MidJoining,''),@Oldis_weekoff_hour  =isnull(is_weekoff_hour ,0),
										       
			--							       @Oldweekoff_hours  =ISNULL(weekoff_hours,'') ,
			--							       @Oldis_all_emp_prob  =ISNULL(is_all_emp_prob,''),
			--							       @OldMax_Bonus_salary_Amount=ISNULL(Max_Bonus_salary_Amount,''),
			--							       @OldIs_OD_Transfer_to_OT  = Is_OD_Transfer_to_OT,
			--							       @OldIs_Co_hour_Editable = Is_Co_hour_Editable,
			--							       @OldBonus_Entitle_Limit=ISNULL(Bonus_Entitle_Limit,0),
			--							       @OldAllowed_Full_WeekOf_MidJoining_DayRate  = ISNULL(Allowed_Full_WeekOf_MidJoining_DayRate,''),
			--							       @OldMonthly_Deficit_Adjust_OT_Hrs = ISNULL(Monthly_Deficit_Adjust_OT_Hrs,''),
			--							       @OldH_Comp_Off = Is_HO_CompOff  ,@OldH_CompOff_Limit = H_CompOff_Days_Limit ,@OldH_Min_CompOff_Hours  = H_CompOff_Min_Hours  ,@OldH_CompOff_Avail_Days = H_CompOff_Avail_Days, 				--Sid 05022014
			--							       @OldW_Comp_Off = Is_W_CompOff ,@OldW_CompOff_Limit = W_CompOff_Days_Limit ,@OldW_Min_CompOff_Hours = W_CompOff_Min_Hours ,@OldW_CompOff_Avail_Days= W_CompOff_Avail_Days, 					--Sid 05022014
			--							       @OldAllowShowODOptInCompOff = AllowShowODOptInCompOff,@oldIs_H_Co_hour_Editable = Is_H_Co_hour_Editable,@oldIs_W_Co_hour_Editable = Is_W_Co_hour_Editable									--Sid 28022014
			--							        ,@OldNet_Salary_Round = Net_Salary_Round,@Oldtype_net_salary_round =type_net_salary_round --Gadriwala Muslim 03042014
			--							        ,@OldDay_For_Security_Deposit = Day_For_Security_Deposit
			--									,@OldOT_RoundingOff_To = OT_RoundingOff_To 
			--									,@OldOT_RoundingOff_Lower = OT_RoundingOff_Lower 
			--									,@OldChk_OT_limit_Before_Shift  =ISNULL(Chk_otLimit_before_after_Shift_time,0)
			--									,@Old_lv_on_wroking=ISNULL(chk_Lv_On_Working,0) --Added by sumit 26112014 
			--									,@Old_AttendanceSMS=ISNULL(attendance_SMS,0) --Added by sumit 26112014
			--									,@OldSal_Cutoff_Date=ISNULL(Cutoffdate_Salary,null) --Added by sumit 19012015
			--									,@OldMax_Cnt_Reg=ISNULL(Attndnc_Reg_Max_Cnt,null) --Added by sumit 17022015
			--									,@OldManual_Salary_Prd=ISNULL(Manual_Salary_Period,0) --Added by sumit 20022015
			--									,@OldIs_WO_OD = isnull(Is_WO_OD,1)
			--									,@OldIs_WD_OD = isnull(Is_WD_OD,1)
			--									,@OldIs_HO_OD = isnull(Is_HO_OD,1)
			--									,@OldLateEarlyExemMaxLimit = ISNULL(LateEarly_Exemption_MaxLimit,'00:00')
			--									,@OldLateEarlyExempCount = ISNULL(LateEarly_Exemption_Count,0)
			--									,@Old_Is_Cancel_Holiday_WO_HO_same_day = Is_Cancel_Holiday_WO_HO_same_day
			--									,@Old_Is_Restrict_Present_days = Restrict_Present_days
			--									,@Old_Emp_WeekDay_OT_Rate = Emp_WeekDay_OT_Rate
			--									,@Old_Emp_WeekOff_OT_Rate = Emp_WeekOff_OT_Rate
			--									,@Old_Emp_Holiday_OT_Rate = Emp_Holiday_OT_Rate
			--							        From dbo.T0040_GENERAL_SETTING Where Cmp_ID = @Cmp_ID and Gen_ID = @Gen_ID
				
							exec P9999_Audit_get @table = 'T0040_GENERAL_SETTING' ,@key_column='Gen_Id',@key_Values=@Gen_ID ,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))				  
					
								
			---- Added by rohit For Showing Stack over flow Error on 12082013
			--	declare @od_value as varchar(max)	
			--	set @od_value=''		                        
			--	declare @new_od_value as varchar(max)	
			--	set @new_od_value=''
			----Ended by rohit on 12082013
					                        Delete from dbo.T0040_GENERAL_SETTING where Gen_ID = @Gen_ID And Cmp_Id=@Cmp_Id	
					                        
					                        
					                        --set @OldValue = 'old Value' + '#'+ 'For Date :' + cast(ISNULL( @OldFor_Date,'')as varchar(11)) + '#' + 'Inc Weekoff :' + CAST(ISNULL( @OldInc_Weekoff,0)as varchar(1)) + '#' + 'Is OT :' + CAST(ISNULL(@OldIs_OT,0) AS VARCHAR(1)) + '#' + 'ExOT Setting :' +CAST( ISNULL( @OldExOT_Setting,0)AS VARCHAR(18)) + '#' + 'Late Limit :' +ISNULL( @OldLate_Limit,'') + ' #'+ 'Late Adj Day :' +CAST(ISNULL(@OldLate_Adj_Day,0)AS VARCHAR(18)) + ' #'+ 'Is PT :' + CAST(ISNULL( @OldIs_PT,0)as varchar(1)) + ' #'+ 'Is LWF :' + CAST(ISNULL(@OldIs_LWF,0)AS VARCHAR(1))  + ' #'
										                                  
										                   --               + 'Is Revenue :' + cast(ISNULL(@OldIs_Revenue,0)as varchar(1)) + '#' + 'Is PF :' + CAST(ISNULL( @OldIs_PF,0)as varchar(1)) + '#' + 'Is ESIC :' + CAST(ISNULL(@OldIs_ESIC,0) AS VARCHAR(1)) + '#' + 'Is Late Mark :' +CAST( ISNULL( @OldIs_Late_Mark,0)AS VARCHAR(1)) + '#' + 'Is Credit :' +CAST(ISNULL( @OldIs_Credit,0)AS VARCHAR(1)) + ' #'+ 'LWF Amount :' +CAST(ISNULL(@OldLWF_Amount,0)AS VARCHAR(18)) + ' #'+ 'LWF Month :' + ISNULL( @OldLWF_Month,'') + ' #'+ 'Revenue Amount :' + CAST(ISNULL(@OldRevenue_Amount,0)AS VARCHAR(18))  + ' #'    
										                                  
										                   --               + 'Revenue On Amount :' + cast(ISNULL(@OldRevenue_On_Amount,0)as varchar(18)) + '#' + 'Credit Limit :' + CAST(ISNULL(@OldCredit_Limit,0)as varchar(18)) + '#' + 'Chk Server Date :' + CAST(ISNULL(@OldChk_Server_Date,0) AS VARCHAR(1)) + '#' + 'Is Cancel Weekoff :' +CAST( ISNULL( @OldIs_Cancel_Weekoff,0)AS VARCHAR(1)) + '#' + 'Is Cancel Holiday :' +CAST(ISNULL(@OldIs_Cancel_Holiday,0)AS VARCHAR(1)) + ' #'+ 'Is Daily OT :' +CAST(ISNULL(@OldIs_Daily_OT,0)AS VARCHAR(1)) + ' #'+ 'In Punch Duration :' + ISNULL(@OldIn_Punch_Duration,'') + ' #'+ 'Last Entry Duration :' + ISNULL(@OldLast_Entry_Duration,'')  + ' #' 
										                                  
										                   --               + 'OT App Limit:' + ISNULL(@OldOT_App_Limit,'') + '#' + 'OT Max Limit :' + ISNULL(@OldOT_Max_Limit,'') + '#' + 'OT Fix Work Day :' + CAST(ISNULL(@OldOT_Fix_Work_Day,0) AS VARCHAR(18)) + '#' + 'OT Fix Shift Hours :' +ISNULL(@OldOT_Fix_Shift_Hours,'') + '#' + 'OT Inc Salary :' +CAST(ISNULL(@OldOT_Inc_Salary,0)AS VARCHAR(1)) + ' #'+ 'ESIC Upper Limit :' +CAST(ISNULL(@OldESIC_Upper_Limit,0)AS VARCHAR(180)) + ' #'+ 'ESIC Employer Contribution :' + CAST(ISNULL(@OldESIC_Employer_Contribution,0)as varchar(182)) + ' #'+ 'inout Days :' + CAST(ISNULL(@Oldinout_Days,0)AS VARCHAR(182))  + ' #' 
										                                  
										                   --               + 'Late Fix Work Days :' + cast(ISNULL(@OldLate_Fix_Work_Days,0)as varchar(51)) + '#' + 'Late Fix shift Hours :' + ISNULL(@OldLate_Fix_shift_Hours,'') + '#' + 'Late Deduction Days :' + CAST(ISNULL(@OldLate_Deduction_Days,0) AS VARCHAR(31)) + '#' + 'Late Extra Deduction :' +CAST( ISNULL( @OldLate_Extra_Deduction,0)AS VARCHAR(31)) + '#' + 'Is Late Cal On HO WO :' +CAST(ISNULL(@OldIs_Cancel_Holiday,0)AS VARCHAR(1)) + ' #'+ 'Is Late CF :' +CAST(ISNULL(@OldIs_Daily_OT,0)AS VARCHAR(1)) + ' #'+ 'Late CF Reset On :' + ISNULL(@OldLate_CF_Reset_On,'') + ' #'+ 'Sal St Date :' + CAST(ISNULL(@OldLast_Entry_Duration,0)AS VARCHAR(11))  + ' #' 
										                                  
										                   --               + 'Sal Fix Days :' + cast(ISNULL(@OldSal_Fix_Days,0)as varchar(181)) + '#' + 'Sal Inout :' + CAST(ISNULL(@OldSal_Inout,0)as varchar(11)) + '#' + 'Last bonus :' + CAST(ISNULL(@OldLast_bonus,0) AS VARCHAR(11)) + '#' + 'Gr Min Year :' +CAST( ISNULL(@OldGr_Min_Year,0)AS VARCHAR(1)) + '#' + 'Gr Cal Month :' +CAST(ISNULL(@OldGr_Cal_Month,0)AS VARCHAR(1)) + ' #'+ 'Gr ProRata Cal :' +CAST(ISNULL(@OldGr_ProRata_Cal,0)AS VARCHAR(1)) + ' #'+ 'Gr Min P Days :' + CAST(ISNULL(@OldIn_Punch_Duration,0)as varchar(52)) + ' #'+ 'Gr Absent Days :' + CAST(ISNULL(@OldGr_Absent_Days,0)AS VARCHAR(52))  + ' #' 
										                                  
										                   --               + 'Short Fall Days :' + cast(ISNULL(@OldShort_Fall_Days,0)as varchar(52)) + '#' + 'Gr Days :' + CAST(ISNULL(@OldGr_Days,0)as varchar(52)) + '#' + 'Gr Percentage :' + CAST(ISNULL(@OldGr_Percentage,0) AS VARCHAR(52)) + '#' + 'Short Fall W Days :' +CAST( ISNULL(@OldShort_Fall_W_Days,0)AS VARCHAR(52)) + '#' + 'Leave SMS :' +CAST(ISNULL(@OldLeave_SMS,0)AS VARCHAR(52)) + ' #'+ 'CTC Auto Cal :' +CAST(ISNULL(@OldCTC_Auto_Cal,0)AS VARCHAR(52)) + ' #'+ 'Inc Holiday :' + CAST(ISNULL(@OldInc_Holiday,'')as varchar(10)) + ' #'+ 'Probation :' + CAST(ISNULL(@OldProbation,'')AS VARCHAR(20))  + ' #' 
										                                  
										                   --               + 'Lv Month :' + cast(ISNULL(@OldLv_Month,0)as varchar(20)) + '#' + 'Is Shortfall Gradewise :' + CAST(ISNULL(@OldIs_Shortfall_Gradewise,0)as varchar(1)) + '#' + 'Actual Gross :' + CAST(ISNULL(@OldActual_Gross,0) AS VARCHAR(182)) + '#' + 'Wage Amount :' +CAST( ISNULL( @OldWage_Amount,0)AS VARCHAR(182)) + '#' + 'Dep Reim Days :' +CAST(ISNULL(@OldDep_Reim_Days,0)AS VARCHAR(180)) + ' #'+ 'Con Reim Days :' +CAST(ISNULL(@OldCon_Reim_Days,0)AS VARCHAR(182)) + ' #'+ 'Late With Leave :' + CAST(ISNULL(@OldLate_With_Leave,'')as varchar(182)) + ' #'+ 'Tras Week ot :' + CAST(ISNULL(@OldTras_Week_ot,'')AS VARCHAR(1))  + ' #' 
										                                  
										                   --               + 'OT Limit Before Shift Time :' + cast(isnull(@Old_lv_on_wroking,0)as varchar(20)) + '#' 
										                                  
										                   --               + 'Leave Encash Calculate on Working :' + cast(isnull(@Old_lv_on_wroking,0)as varchar(20)) + '#' ---Added by sumit 26112014
										                                  
										                                
					--					      set @od_value = 'Bonus Min Limit :' + cast(ISNULL(@OldBonus_Min_Limit,0)as varchar(180)) + '#' + 'Bonus Max Limit :' + CAST(ISNULL(@OldBonus_Max_Limit,0)as varchar(180)) + '#' + 'Bonus Per :' + CAST(ISNULL(@OldBonus_Per,0) AS VARCHAR(182)) + '#' + 'Is Organise chart :' +CAST( ISNULL(@OldIs_Organise_chart,0)AS VARCHAR(1)) + '#' + 'Is Zero Day Salary :' +CAST(ISNULL(@OldIs_Zero_Day_Salary,0)AS VARCHAR(1)) + ' #' + 'OT Auto :' +CAST(ISNULL(@OldOT_Auto,0)AS VARCHAR(1)) + ' #'+ 'OT Present :' + CAST(ISNULL(@OldOT_Present,0)as varchar(4)) + ' #'+ 'Is Negative Ot :' + CAST(ISNULL(@OldIs_Negative_Ot,0)AS VARCHAR(4))  + ' #' 
										                                  
					--					                                  + 'Is Present :' + cast(ISNULL(@OldIs_Present,0)as varchar(180)) + '#' + 'Is Amount :' + CAST(ISNULL(@OldIs_Amount,0)as varchar(180)) + '#' + 'Mid Increment :' + CAST(ISNULL(@OldMid_Increment,0) AS VARCHAR(180)) + '#' + 'AD Rounding :' +CAST( ISNULL(@OldAD_Rounding,0)AS VARCHAR(180)) + '#' + 'Lv Salary Effect on PT :' +CAST(ISNULL(@OldLv_Salary_Effect_on_PT,0)AS VARCHAR(10)) + ' #'+ 'Lv Encash W Day :' +CAST(ISNULL(@OldLv_Encash_W_Day,0)AS VARCHAR(10)) + ' #'+ 'Lv Encash Cal On :' + ISNULL(@OldLv_Encash_Cal_On,'') + ' #'+ 'In Out Login :' + CAST(ISNULL(@OldIn_Out_Login,'')AS VARCHAR(4))  + ' #' 
										                                  
					--					                                  + 'LWF Max Amount :' + cast(ISNULL(@OldLWF_Max_Amount,0)as varchar(182)) + '#' + 'LWF Over Amount :' + CAST(ISNULL(@OldLWF_Over_Amount,0)as varchar(182)) + '#' + 'First In Last Out For Att Regularization :' + CAST(ISNULL(@OldFirst_In_Last_Out_For_Att_Regularization,0) AS VARCHAR(1)) + '#' + 'First In Last Out For InOut Calculation :' +CAST( ISNULL(@OldFirst_In_Last_Out_For_InOut_Calculation,0)AS VARCHAR(1)) + '#' + 'Late Count Exemption :' +CAST(ISNULL(@OldLate_Count_Exemption,0)AS VARCHAR(20)) + ' #'+ 'Early Limit :' +ISNULL(@OldEarly_Limit,'') + ' #'+ 'Early Adj Day :' + CAST(ISNULL(@OldEarly_Adj_Day,'')as varchar(18)) + ' #'+ 'Early Deduction Days :' + CAST(ISNULL(@OldEarly_Deduction_Days,'')AS VARCHAR(31))  + ' #' 
										                                  
					--					                                  + 'Early Extra Deduction :' + cast(ISNULL(@OldEarly_Extra_Deduction,0)as varchar(31)) + '#' + 'Early CF Reset On :' + ISNULL(@OldEarly_CF_Reset_On,'') + '#' + 'Is Early Calc On HO WO :' + CAST(ISNULL(@OldIs_Early_Calc_On_HO_WO,0) AS VARCHAR(1)) + '#' + 'Is Early CF:' +CAST( ISNULL(@OldIs_Early_CF,0)AS VARCHAR(1)) + '#' + 'Early With Leave :' +CAST(ISNULL(@OldEarly_With_Leave,0)AS VARCHAR(3)) + ' #'+ 'Early Count Exemption	:' +CAST(ISNULL(@OldEarly_Count_Exemption,'')AS VARCHAR(20)) + ' #'+ 'Deficit Limit :' + ISNULL(@OldDeficit_Limit,'') + ' #'+ 'Deficit Adj Day :' + CAST(ISNULL(@OldDeficit_Adj_Day,'')AS VARCHAR(18))  + ' #' 
										                                  
					--					                                  + 'Deficit Deduction Days :' + cast(ISNULL(@OldDeficit_Deduction_Days,0)as varchar(31)) + '#' + 'Deficit Extra Deduction :' + CAST(ISNULL(@OldDeficit_Extra_Deduction,0)as varchar(31)) + '#' + 'Deficit CF Reset On :' +ISNULL(@OldDeficit_CF_Reset_On,'')  + '#' + 'Is Deficit Calc On HO WO:' +CAST( ISNULL(@OldIs_Deficit_Calc_On_HO_WO,0)AS VARCHAR(1)) + '#' + 'Is Deficit CF :' +CAST(ISNULL(@OldIs_Deficit_CF,0)AS VARCHAR(1)) + ' #'+ 'Deficit With Leave	:' +CAST(ISNULL(@OldDeficit_With_Leave,'')AS VARCHAR(5)) + ' #'+ 'Deficit Count Exemption :' + CAST(ISNULL(@OldDeficit_Count_Exemption,'')as varchar(20)) + ' #'+ 'In Out Login Popup:' + CAST(ISNULL(@OldIn_Out_Login_Popup,'')AS VARCHAR(4))  + ' #' 
										                                  
					--					                                  + 'Late Hour Upper Rounding :' + cast(ISNULL(@OldLate_Hour_Upper_Rounding,0)as varchar(182)) + '#' + 'is Late Calc Slabwise :' + CAST(ISNULL(@Oldis_Late_Calc_Slabwise,0)as varchar(1)) + '#' + 'Late Calculate type :' + ISNULL(@OldLate_Calculate_type,'') + '#' + 'Early Hour Upper Rounding  :' +CAST( ISNULL( @OldEarly_Hour_Upper_Rounding ,0)AS VARCHAR(182)) + '#' + 'is Early Calc Slabwise:' +CAST(ISNULL(@Oldis_Early_Calc_Slabwise,0)AS VARCHAR(1)) + ' #'+ 'Early Calculate type :' +CAST(ISNULL(@OldEarly_Calculate_type,0)AS VARCHAR(10)) + ' #'+ 'Is Basic Salary :' + CAST(ISNULL(@OldIs_Basic_Salary,'')as varchar(1)) + ' #'+ 'Is PreQuestion :' + CAST(ISNULL(@OldIs_PreQuestion,'')AS VARCHAR(1))  + ' #' 
										                                  
					--					                                  + 'Is CompOff :' + cast(ISNULL(@OldIs_CompOff,0)as varchar(1)) + '#' + 'CompOff limit :' + CAST(ISNULL(@OldCompOff_limit,0)as varchar(180)) + '#' + 'CompOff Min Hours :' + ISNULL(@OldCompOff_Min_Hours,'')  + '#' + 'Is CompOff WD :' +CAST(ISNULL(@OldIs_CompOff_WD,0)AS VARCHAR(1)) + '#' + 'Is CompOff WOHO:' +CAST(ISNULL(@OldIs_CompOff_WOHO,0)AS VARCHAR(1)) + ' #'+ 'Is CF On Sal Days :' +CAST(ISNULL(@OldIs_CF_On_Sal_Days,0)AS VARCHAR(1)) + ' #'+ 'Days As Per Sal Days :' + CAST(ISNULL(@OldDays_As_Per_Sal_Days,'')as varchar(1)) + ' #'+ 'Max Late Limit :' + ISNULL(@OldMax_Late_Limit,'')  + ' #' 
										                                  
					--					                                  + 'Max Early Limit :' + cast(ISNULL(@OldMax_Early_Limit,0)as varchar(50)) + '#' + 'Manual Inout :' + CAST(ISNULL(@OldManual_Inout,0)as varchar(4)) + '#' + 'Allow Negative Salary :' + CAST(ISNULL(@OldAllow_Negative_Salary,0) AS VARCHAR(1)) + '#' + 'ESIC OT Allow:' +CAST( ISNULL( @OldESIC_OT_Allow,0)AS VARCHAR(1)) + '#' + 'CompOff Avail Days:' +CAST(ISNULL(@OldCompOff_Avail_Days,0)AS VARCHAR(180)) + ' #'+ 'Paid WeekOff Daily Wages :' +CAST(ISNULL(@OldPaid_WeekOff_Daily_Wages,0)AS VARCHAR(1)) + ' #'+ 'Allowed Full WeekOf MidJoining:' + CAST(ISNULL(@OldAllowed_Full_WeekOf_MidJoining,'')as varchar(1)) + ' #'+ 'isweekoff hour :' + CAST(ISNULL(@Oldis_weekoff_hour,'')AS VARCHAR(2))  + ' #' 
										                                  
					--					                                  + 'weekoff hours :' + ISNULL(@Oldweekoff_hours,0) + '#' + 'is all emp prob :' + CAST(ISNULL(@Oldis_all_emp_prob,0)as varchar(1)) + '#' + 'Max Bonus Salary Amount :' + CAST(ISNULL(@OldMax_Bonus_salary_Amount,0) as varchar(180))  + '#' + 'Is OD Transfer to OT :' + Cast(isnull(@OldIs_OD_Transfer_to_OT,0) as varchar(1))   + '#' + 'Is Comp Off Hour Enable :' + Cast(isnull(@OldIs_Co_hour_Editable,0) as varchar(1)) + '#' + 'Bonus Entitle Limit :' + CAST(ISNULL(@OldBonus_Entitle_Limit,0) as varchar(180)) + '#' + 'Allowed Full WeekOf MidJoining DayRate:' + CAST(ISNULL(@OldAllowed_Full_WeekOf_MidJoining_DayRate,'')as varchar(1)) + '#' + 'Monthly Deficit Adjust OT Hrs:' + CAST(ISNULL(@OldMonthly_Deficit_Adjust_OT_Hrs,'')as varchar(1))
					--					                                  + '#' + 'Is WeekDay Comp Off Allowed:' + CAST(ISNULL(@OldH_Comp_Off ,'')as varchar(1))					---- added by sid 20/02/2014
					--					                                  + '#' + 'WeekDay Comp Off Days limit:' + CAST(ISNULL(@OldH_CompOff_Limit,'')as varchar(5))				---- added by sid 20/02/2014
					--					                                  + '#' + 'WeekDay Comp Off Min Hours:' + CAST(ISNULL(@OldH_Min_CompOff_Hours ,'')as varchar(Max))			---- added by sid 20/02/2014
					--					                                  + '#' + 'WeekDay Comp Off Avail Limit:' + CAST(ISNULL(@OldH_CompOff_Avail_Days ,'')as varchar(5))			---- added by sid 20/02/2014
					--					                                  + '#' + 'Is WeekOff Comp Off Allowed:' + CAST(ISNULL(@OldW_Comp_Off,'')as varchar(1))						---- added by sid 20/02/2014
					--					                                  + '#' + 'WeekOff Comp Off Days limit:' + CAST(ISNULL(@OldW_CompOff_Limit,'')as varchar(5))				---- added by sid 20/02/2014
					--					                                  + '#' + 'WeekOff Comp Off Min Hours:' + CAST(ISNULL(@OldW_Min_CompOff_Hours,'')as varchar(Max))			---- added by sid 20/02/2014
					--					                                  + '#' + 'WeekOff Comp Off Avail Limit:' + CAST(ISNULL(@OldW_CompOff_Avail_Days,'')as varchar(5))			---- added by sid 20/02/2014
					--					                                  + '#' + 'Allow Show OD Opt In CompOff:' + case when @OldAllowShowODOptInCompOff = 1 then 'Y' else 'N' end	---- Added by Sid 28/02/2014
					--					                                  + '#' + 'Is H Compoff hours editable:' + CASE WHEN @oldIs_H_Co_hour_Editable = 1 THEN 'Y' ELSE 'N' END	-----Added by Sid 20/03/2014
					--					                                  + '#' + 'Is W Compoff hours editable:' + case when @oldIs_W_Co_hour_Editable = 1 THEN 'Y' ELSE 'N' END	-----Added by Sid 20/03/2014
					--													  + '#' + 'Net_Salary_Round:' + CAST(ISNULL(@OldNet_Salary_Round,'-1')as varchar(5))				---- added by Gadriwala 03042014
					--													  + '#' + 'type_net_salary_round:' + CAST(ISNULL(@Oldtype_net_salary_round,'')as varchar(10))		---- added by Gadriwala 03042014	                          
					--													  + '#' + 'Day_For_Security_Deposit:' + CAST(isnull(@OldDay_For_Security_Deposit,0) as varchar(3))
					--													  + '#' + 'OT_RoundingOff_To:' + Cast(isnull(@OldOT_RoundingOff_To,0.00) as varchar(max))			-----Added by Sid 20052014
					--													  + '#' + 'OT_RoundingOff_Lower:' + Cast(isnull(@OldOT_RoundingOff_Lower,0.00) as varchar(max))			-----Added by Sid 20052014
					--													  + '#' + 'OT_Limit_Before_shift:'+ cast(isnull(@oldchk_OT_limit_before_shift,0)as varchar(20)) 
					--													  + '#' + 'Leave_Encash_Calculate_on_working:'+ cast(isnull(@Old_lv_on_wroking,0)as varchar(20)) --Added by sumit 26112014 
					--													  + '#' + 'Attendance:'+ cast(isnull(@Old_AttendanceSMS,0)as varchar(20)) --Added by sumit 01/01/2015
					--													  + '#' + 'CutOff_Date_Sal:'+ cast(isnull(@OldSal_Cutoff_Date,null)as varchar(30)) --Added by sumit 01/01/2015
					--													  + '#' + 'Attendance_Reg_Max_Cnt:'+ cast(isnull(@OldMax_Cnt_Reg,null)as varchar(30)) --Added by sumit 17/02/2015
					--													  + '#' + 'Manual_Salary_Period:'+ cast(isnull(@OldManual_Salary_Prd,0)as varchar(30)) --Added by sumit 17/02/2015
					--													  + '#' + 'IS_WO_OD:'+ cast(isnull(@OldIs_WO_OD,1)as varchar(2))			
					--													  + '#' + 'IS_HO_OD:'+ cast(isnull(@OldIs_HO_OD,1)as varchar(2))
					--													  + '#' + 'IS_WD_OD:'+ cast(isnull(@OldIs_WD_OD,1)as varchar(2))	
					--													  + '#' + 'Exemption Max Limit:'+ isnull(@OldLateEarlyExemMaxLimit,'00:00')	
					--													  + '#' + 'Count Exemption:'+ cast(isnull(@OldLateEarlyExempCount,0)as varchar(4))	--chnged by jimit to varchar(4) from varchar(2)
					--													  + '#' + 'Cancel Holiday HO WO Same Day:' + cast(@Old_Is_Cancel_Holiday_WO_HO_same_day as varchar(2))
					--													  + '#' + 'Is Restrict Present Days:' + cast(@Old_Is_Restrict_Present_days as char(1))
					--													  + '#' + 'Emp_WeekDay_OT_Rate:' + cast(@Old_Emp_WeekDay_OT_Rate as varchar(100))
					--													  + '#' + 'Emp_WeekOff_OT_Rate:' + cast(@Old_Emp_WeekOff_OT_Rate as varchar(100))
					--													  + '#' + 'Emp_Holiday_OT_Rate:' + cast(@Old_Emp_Holiday_OT_Rate as varchar(100))
					--													  + '#' + 'Full_PF:' + CAST(@Old_Full_PF AS varchar(10))
					--													  + '#' + 'Company_Full_PF:'  + CAST(@Old_Company_Full_PF AS varchar(10)) 
																		 
		   --set @new_od_value = @OldValue + @od_value -- Added by rohit For Stack overflow error on 12082013
		   --------------			
			End			

			exec P9999_Audit_Trail @Cmp_ID,@tran_type,'General Setting',@OldValue,@Gen_ID,@User_Id,@IP_Address 
			--select @User_Id,@IP_Address
			
	RETURN

	
	
	













