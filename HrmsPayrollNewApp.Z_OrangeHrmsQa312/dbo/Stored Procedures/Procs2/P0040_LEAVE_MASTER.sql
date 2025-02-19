---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_LEAVE_MASTER]  
 @Leave_ID  numeric(9,0) output  
   ,@Cmp_ID numeric(9,0)  
   ,@Leave_Code varchar(5)  
   ,@Leave_Name varchar(50)  
   ,@Leave_Type varchar(50)  
   ,@Leave_Count numeric(18)  
   ,@Leave_Paid_Unpaid char(1)  
   ,@Leave_Min numeric(18,1)  
   ,@Leave_Max numeric(18,1)  
   ,@Leave_Min_Bal numeric(18,1)  
   ,@Leave_Max_Bal numeric(18,5)  
   ,@Leave_Min_Encash numeric(18,1)  
   ,@Leave_Max_Encash numeric(18,1)  
   ,@Leave_Notice_Period numeric(18,0)  
   ,@Leave_Applicable numeric(18,0)  
   ,@Leave_CF_Type varchar(50)  
   ,@Leave_PDays numeric(18,2)  
   ,@Leave_Get_Against_PDays numeric(18,5)  
   ,@Leave_Auto_Generation char(1)  
   ,@Leave_CF_Month numeric(18,0)  
   ,@tran_type varchar(1)  
   ,@Leave_Bal_Reset_Month numeric  
   ,@Leave_Negative_Allow  numeric  
   ,@Salary_on_Leave tinyint  
   ,@Is_Adj_Late  tinyint  
   ,@Is_Ho_Wo tinyint = 0  
   ,@Weekoff_as_leave tinyint = 0  
   ,@Holiday_as_leave tinyint = 0  
   ,@Leave_Sorting_No numeric(18,0)  
   ,@No_of_days_to_cancel_WOHO numeric(18,2) = 0  
   ,@Display_leave_balance tinyint = 1  
   ,@Is_Leave_CF_Rounding tinyint = 0  -- Added by Mihir 06/03/2012  
   ,@Is_Leave_CF_Prorata tinyint = 0    -- Added by Mihir 06/03/2012  
   ,@is_Leave_Clubbed tinyint = 1  
   ,@Can_Apply_Fraction tinyint = 1 ---Alpesh 10-May-2012  
   ,@Is_CF_On_Sal_Days tinyint = 0 ---Alpesh 10-May-2012  
   ,@Days_As_Per_Sal_Days tinyint = 0 ---Alpesh 10-May-2012  
   ,@Max_Accumulate_Balance numeric(18,2) ---Alpesh 10-May-2012  
   ,@Min_Present_Days numeric(18,2)  ---Alpesh 10-May-2012  
   ,@Default_Short_Name Varchar(20) = '' --Mihir Trivedi 25/05/2012  
   ,@Max_No_Of_Application numeric(18, 0) = 0 --Alpesh 11-Jul-2012  
   ,@L_Enc_Percentage_Of_Current_Balance numeric(18, 2) = 0 --Alpesh 11-Jul-2012  
   ,@Encashment_After_Months numeric(18, 2) = 0 --Alpesh 16-Jul-2012  
   ,@Leave_Status numeric(18, 2) = 1 -- Jainith PAtel 31-12-2012  
   ,@InActive_Effe_Date datetime = NULL  
   ,@leave_club_with  varchar(500)=null  
   ,@User_Id numeric(18,0) = 0 -- Added for audit trail by Ali 05102013   
   ,@IP_Address varchar(30)= '' -- Added for audit trail by Ali 05102013    
   ,@Document_required tinyint = 0     -- Added by rohit For Leave Document upload on 13122013  
   ,@Effect_Of_LTA int = 0 --Added By Ripal 16Jan2014  
   ,@Apply_Hours int = 0     ---Added by Sid for Comp off hourly 07022014  
   --,@CarryForwardHours varchar(5) = '00:00' ---Added by Sid for Comp off hourly 07022014  
   ,@BalanceToSalary int = 0    ---Added by Sid for Comp off hourly 07022014  
   ,@AllowNightHalt int = 0  
   ,@Attachment_Days numeric(18, 2) = 0   --Added By Mukti 08112014  
   ,@Half_Paid int=0 --Hardik 16/12/2014  
   ,@Neg_Max_Limit numeric(18,2)=0  --Added by Sumit 23012015  
   ,@MinPDay_Type tinyint = 0 -- Added by Gadriwala Muslim 10022015  
   ,@Trans_Leave_ID numeric(18,0) = 0 -- Added by Gadriwala Muslim 17022015  
   ,@Including_Holiday numeric(18,0) = 0  -- Added by nilesh Patel on 27032015  
   ,@Including_WeekOff numeric(18,0) = 0  -- Added by nilesh Patel on 27032015  
   ,@Including_Leave_Type Varchar(500) = '' -- Added by nilesh Patel on 28032015  
   ,@Lv_Encase_Calculation_Day Numeric(18,2)=0  
   ,@Multi_Branch_ID nvarchar(max) = '' -- Added by Gadriwala Muslim 06072015 
   ,@Multi_Allowance_ID nvarchar(max) = '' -- Added by Mr.Mehul 19072022
   ,@Medical_Leave  tinyint = 0 -- Added by Gadriwala Muslim 14092015  
   ,@Leave_EncashDay_Half_Payment tinyint = 0 --Ankit 25022016  
   ,@Max_Leave_Carry_Forward_From_Last_Year  numeric(18,1) = 0 --added jimit 10052016  
   ,@Punch_Required int = 0 --Mukti(18052016)  
   ,@PunchBoth_Required int = 0 --Mukti(18052016)  
   ,@Advance_Leave_Balance tinyint = 0 -- Added by Nilesh Patel on 03022016  
   ,@Is_InOut_Show_In_Email tinyint = 0  --added by jimit 06102016  
   ,@Effect_Salary_Cycle tinyint = 0  --Added by Jaina 18-03-2017  
   ,@Monthly_Max_Leave numeric(18,1)= 0 --Added by Jaina 27-03-2017  
   ,@NoticePeriod_Type tinyint = 0 --Added by Jaina 15-04-2017  
   ,@Working_Days numeric(18,2) =0  --Added by Jaina 04-05-2017  
   ,@Consecutive_Days numeric(18,2) = 0 --Added by Jaina 04-05-2017  
   ,@Min_Leave_Not_Mandatory numeric(18,0) = 0 --Added by Jaina 26-05-2017  
   ,@Consecutive_Club_Days numeric(18,2) = 0 --Added by Jaina 05-06-2017  
   ,@Working_Club_Days numeric(18,2) = 0 --Added by Jaina 05-06-2017  
   ,@Calculate_on_Previous_Month tinyint = 0 --Added by Mukti(24082017)  
   ,@No_Of_Allowed_Leave_CF_Yrs tinyint = 0 --Added By Nimesh (15-Mar-2018)  
   ,@Paternity_Leave_Balance numeric(18,2) = 0 --Added by Jaina 02-05-2018  
   ,@Paternity_Leave_Validity numeric(18,2) = 0 --Added by Jaina 02-05-2018  
   ,@Allowed_CF_Join_After_Day TinyInt = 0   --Added By Nimesh 19-Jun-2018  
   ,@First_Min_Bal_then_Percent_Curr_Balance tinyint = 0 --Added By Jimit 29082018  
   ,@Adv_Balance_Round_off Varchar(10) = '' -- Added By Nilesh patel   
   ,@Adv_Balance_Round_off_Type Numeric(5,2) = 0 -- Added By Nilesh patel   
   ,@Add_In_Working_Hour tinyint = 0 --Added by Jaina 21-01-2019  
   ,@Restrict_LeaveAfter_ExitNotice tinyint = 0  --Added by Jaina 21-01-2019  
   ,@Max_Leave_Lifetime numeric(18,2) = 0 --Added by Jaina 13-03-2019  
   ,@Is_Auto_Leave_From_Salary tinyint=0 --added by binal 04052020  
   ,@Is_DeductDouble int = null  
   ,@Count_WeekOff_Notice_Period tinyint=0 --Added by Mr.Mehul 09032023
   ,@Leave_Continuity tinyint = 0 --Added by Mr.Mehul 21032023
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
  
 -- Added for audit trail by Ali 05102013  --  Start  
   
 DECLARE @CarryForwardHours numeric  
   
 SET @CarryForwardHours = 0  
   
 Declare @Old_Leave_Name  varchar(50)  
 Declare @Old_Leave_Code  varchar(5)  
 Declare @Old_Leave_Applicable numeric(18,0)  
 Declare @Old_Leave_Type varchar(50)  
 Declare @Old_Leave_Sorting_No numeric(18,0)  
 Declare @Old_Leave_Paid_Unpaid char(1)  
 Declare @Old_Is_Adj_Late  tinyint  
 Declare @Old_Is_Leave_CF_Prorata tinyint  
 Declare @Old_Is_Leave_Clubbed tinyint   
 Declare @Old_Can_Apply_Fraction tinyint  
 Declare @Old_Is_Leave_CF_Rounding tinyint  
 Declare @Old_Leave_Negative_Allow numeric  
 Declare @Old_Holiday_as_leave tinyint  
 Declare @Old_Display_leave_balance tinyint  
 Declare @Old_Weekoff_as_leave tinyint   
 Declare @Old_Leave_Status numeric(18, 2)  
 Declare @OldValue as varchar(max)  
 Declare @Old_Leave_Min_Bal numeric(18,1)  
 Declare @Old_Leave_Min_Encash numeric(18,1)  
 Declare @Old_Leave_Max_Encash numeric(18,1)  
 Declare @Old_Max_No_Of_Application numeric(18, 0)  
 Declare @Old_L_Enc_Percentage_Of_Current_Balance numeric(18, 2)  
 Declare @Old_Encashment_After_Months numeric(18, 2)  
 Declare @Old_Document_required tinyint  -- Added by rohit on 13122013  
 Declare @Old_Effect_Of_LTA int --Added by Ripal 16Jan2014  
 Declare @OldApply_Hourly int ------Added by Sid 07022014  
 Declare @OldCarryForwardHours varchar(5) ------Added by Sid 07022014  
 Declare @OldBalanceToSalary int    ------Added by Sid 07022014  
 Declare @OldAllowNightHalt int  
 Declare @OldHalf_Paid int  
 Declare @OldNeg_Max_limit numeric(18,2)  
 Declare @OldMinPDay_Type tinyint -- Added by Gadriwala Muslim 10022015  
 Declare @OldLeave_Trans_ID numeric(18,0) -- Added by Gadriwala Muslim 16022015  
 Declare @OldIncluding_Holiday numeric(1,0) --Added by nilesh Patel on 27032015   
 Declare @OldIncluding_WeekOff numeric(1,0) --Added by nilesh Patel on 27032015   
 Declare @OldLv_Encase_Calculation_Day numeric(18,2)  
 Declare @OldMulti_Branch_ID nvarchar(max)  -- Added by Gadriwala Muslim 06072015  
 Declare @OldMulti_Allowance_ID nvarchar(max)  -- Added by Mr.Mehul 19072022
 Declare @OldMedical_Leave tinyint -- Added by Gadriwala Muslim 14092015  
 Declare @OldLeave_EncashDay_Half_Payment tinyint  
 DECLARE @OldMax_Leave_Carry_Forward_From_Last_Year NUMERIC(18,1)  
 DECLARE @OldPunch_Required INT  --Mukti(18-05-2016)  
 DECLARE @OldPunchBoth_Required INT  --Mukti(18-05-2016)  
 Declare @OldAdvance_Leave_Balance tinyint -- Added by Nilesh Patel on 03022016  
 Declare @OldIs_InOut_Show_In_Email tinyint --added by jimit 06102016  
 Declare @Old_Effect_Salary_Cycle tinyint   --Added by Jaina 18-03-2017  
 Declare @Old_Monthly_Max_Leave numeric(18,1)  --Added by Jaina 27-03-2017  
 Declare @Old_NoticePeriod_Type tinyint --Added by  Jaina 15-04-2017  
 Declare @Old_Working_Days numeric(18,2)  
 Declare @Old_Consecutive_Days numeric(18,2)  
 Declare @Old_Min_Leave_Not_Mandatory numeric(18,2)   
 Declare @Old_Consecutive_Club_Days numeric(18,2)  
 Declare @Old_Working_Club_Days numeric(18,2)  
 Declare @Old_Calculate_on_Previous_Month numeric(18,2)  
 Declare @Old_No_Of_Allowed_Leave_CF_Yrs TinyInt  
 Declare @Old_Paternity_Leave_Balance numeric(18,2)  
 Declare @Old_Paternity_Leave_Validity numeric(18,2)  
 Declare @Old_Allowed_CF_Join_After_Day As Varchar(10)  
 Declare @Old_First_Min_Bal_then_Percent_Curr_Balance As Varchar(10)  
 declare @Old_Restrict_LeaveAfter_ExitNotice as varchar(10)  
 declare @Old_Max_Leave_Lifetime as varchar(10)  
   
 SET @OldNeg_Max_limit =0  
 SET @OldLv_Encase_Calculation_Day =0  
 SET @Old_Leave_Name = ''  
 SET @Old_Leave_Code  = ''  
 SET @Old_Leave_Applicable = 0  
 SET @Old_Leave_Type = ''  
 SET @Old_Leave_Sorting_No = 0  
 SET @Old_Leave_Paid_Unpaid = ''  
 SET @Old_Is_Adj_Late  = 0  
 SET @Old_Is_Leave_CF_Prorata  = 0  
 SET @Old_Is_Leave_Clubbed  = 1  
 SET @Old_Can_Apply_Fraction = 1  
 SET @Old_Is_Leave_CF_Rounding = 0  
 SET @Old_Leave_Negative_Allow = 0  
 SET @Old_Holiday_as_leave = 0  
 SET @Old_Display_leave_balance = 1  
 SET @Old_Weekoff_as_leave = 0  
 SET @Old_Leave_Status = 0  
 SET @OldValue = ''  
 SET @Old_Leave_Min_Bal = 0  
 SET @Old_Leave_Min_Encash = 0  
 SET @Old_Leave_Max_Encash = 0  
 SET @Old_Max_No_Of_Application = 0  
 SET @Old_L_Enc_Percentage_Of_Current_Balance = 0  
 SET @Old_Encashment_After_Months = 0  
 SET @Old_Document_required = 0  -- Added by rohit on 13122013  
 SET @Old_Effect_Of_LTA = 0 -- Added By Ripal 16Jan2014  
 SET @OldApply_Hourly = 0  -----Added by Sid 07022014  
 SET @OldCarryForwardHours = 0 -----Added by Sid 07022014  
 SET @OldBalanceToSalary = 0  -----Added by Sid 07022014  
 SET @OldAllowNightHalt = 0  
 SET @OldHalf_Paid = 0  
 SET @OldMinPDay_Type = 0  
 SET @OldLeave_Trans_ID = 0 -- Added by Gadriwala Muslim 16022015  
 SET @OldIncluding_Holiday  = 0 -- Added by Nilesh Patel on 27032015  
 SET @OldIncluding_WeekOff = 0 -- Added by Nilesh Patel on 27032015  
 SET @OldMulti_Branch_ID = ''  
 SET @OldMulti_Allowance_ID = ''  
 SET @OldMedical_Leave = 0 -- Added by Gadriwala Muslim 14092015  
 SET @OldLeave_EncashDay_Half_Payment = 0  
 SET @OldMax_Leave_Carry_Forward_From_Last_Year = 0  
 SET @OldPunch_Required = 0 --Mukti(18-05-2016)  
 SET @OldPunchBoth_Required = 0 --Mukti(18-05-2016)  
 SET @OldAdvance_Leave_Balance = 0  
 SET @Old_Effect_Salary_Cycle = 0  
 SET @Old_Monthly_Max_Leave = 0  
 SET @Old_NoticePeriod_Type = 0  
 SET @Old_Working_Days = 0  
 SET @Old_Consecutive_Days = 0  
 SET @Old_Min_Leave_Not_Mandatory = 0  
 SET @Old_Consecutive_Club_Days = 0  
 SET @Old_Working_Club_Days = 0  
 -- Added for audit trail by Ali 05102013  --  End  
 SET @OldIs_InOut_Show_In_Email = 0  --added by jimit 06102016  
 SET @Old_Calculate_on_Previous_Month = 0 --Mukti(24082017)  
   
 SET @Old_Paternity_Leave_Balance = 0  
 SET @Old_Paternity_Leave_Validity = 0  
   
 SET @Old_Allowed_CF_Join_After_Day = '0'  
   
 SET @Old_First_Min_Bal_then_Percent_Curr_Balance = 0  
 set @Old_Restrict_LeaveAfter_ExitNotice = '0'  
 set @Old_Max_Leave_Lifetime = '0'  
   
 SET @Leave_Code = RTRIM(LTRIM(@Leave_Code))  
 SET @Leave_Name = RTRIM(LTRIM(@Leave_Name))  
   
 IF @TRAN_TYPE IN ('U', 'D')  
  BEGIN  
   Select @OldValue = 'old Value'   
     + '#Leave Name :' + ISNULL(Leave_Name,'')   
     + '#Leave Code:' +  CONVERT(nvarchar(20),ISNULL(Leave_Code,''))   
     + '#After Joining Days :' + CONVERT(nvarchar(20),ISNULL(Leave_Applicable,''))  
     + '#Type :' + ISNULL(Leave_Type,'')    
     + '#Sorting No :' + CONVERT(nvarchar(20),ISNULL(Leave_Sorting_No,0))  
     + '#Leave Is Paid :' + CASE ISNULL(Leave_Paid_Unpaid,'') WHEN '' THEN 'N' ELSE 'Y' END  
     + '#Adjust with Late :' + CASE ISNULL(Is_late_Adj,0) WHEN 0 THEN 'N' ELSE 'Y' END  
     + '#Leave CF Prorata :' + CASE ISNULL(Is_Leave_CF_Prorata,0) WHEN 0 THEN 'N' ELSE 'Y' END  
     + '#Is Clubbed :' + CASE ISNULL(Is_Leave_Clubbed ,0) WHEN 0 THEN 'N' ELSE 'Y' END  
     + '#Apply In Fraction :' + CASE ISNULL(Can_Apply_Fraction,0) WHEN 0 THEN 'N' ELSE 'Y' END  
     + '#Leave CF Rounding :' + CASE ISNULL(Is_Leave_CF_Rounding,0) WHEN 0 THEN 'N' ELSE 'Y' END  
     + '#Leave Negative Allow :' + CASE ISNULL(Leave_Negative_Allow,0) WHEN 0 THEN 'N' ELSE 'Y' END  
     + '#Holiday as Leave :' + CASE ISNULL(Holiday_as_leave,0) WHEN 0 THEN 'N' ELSE 'Y' END  
     + '#Display Leave Balance :' + CASE ISNULL(Display_leave_balance,0) WHEN 0 THEN 'N' ELSE 'Y' END  
     + '#WeekOff as Leave :' + CASE ISNULL(Weekoff_as_leave,0) WHEN 0 THEN 'N' ELSE 'Y' END  
     + '#Is Active :' + CASE ISNULL(Leave_Status,0) WHEN 0 THEN 'N' ELSE 'Y' END  
     + '#Balance After Encashment :' + CONVERT(nvarchar(20),ISNULL(Leave_Min_Bal,0))  
     + '#Minimum Leave To Encash :' + CONVERT(nvarchar(20),ISNULL(Leave_Min_Encash,0))  
     + '#Maximum Leave To Encash :' + CONVERT(nvarchar(20),ISNULL(Leave_Max_Encash,0))  
     + '#Max. No. of Application :' + CONVERT(nvarchar(20),ISNULL(Max_No_Of_Application,0))  
     + '#Leave Encashment :' + CONVERT(nvarchar(20),ISNULL(L_Enc_Percentage_Of_Current_Balance,0))  
     + '#Encashment Application After :' + CONVERT(nvarchar(20),ISNULL(Encashment_After_Months,0))  
     + '#Document Required :' + CASE ISNULL(is_Document_Required,0) WHEN 0 THEN 'N' ELSE 'Y' END   
     + '#Effect Of LTA :' + CASE ISNULL(Effect_Of_LTA,0) WHEN 0 THEN 'N' ELSE 'Y' END   
     + '#Allow Night Halt:' + Case AllowNightHalt when 0 then 'N' else 'Y' end  
     + '#Half Paid:' + Case Half_Paid when 0 then 'N' else 'Y' end  
     + '#Negative Max Limit :' + CONVERT(nvarchar(20),ISNULL(leave_negative_max_limit,0))  
     + '#Minimum Present Days Type' + case when MinPdays_Type = 0 then 'Days' else '%' end  
     + '#Encash Calculation Day on :' + CONVERT(nvarchar(20),ISNULL(Lv_Encase_Calculation_Day,0))  
     + '#Multi Branch ID :' + isnull(Multi_Branch_ID,'') -- Added by Gadriwala Muslim 06072015   
	 + '#Multi Allowance ID :' + isnull(Multi_Allowance_ID,'') -- Added by Mr.Mehul 19072022
     + '#Medical Leave :' + Convert(nvarchar(1),isnull(Medical_Leave,0)) -- Added by Gadriwala Muslim 14092015    
     + '#Leave EncashDay Half Payment :' + Convert(nvarchar(1),isnull(Leave_EncashDay_Half_Payment,0))  
     + '#Max_Leave_Carry_Forward_From_Last_Year :' + CONVERT(nvarchar(20),ISNULL(Max_CF_From_Last_Yr_Balance,0))  
     + '#Punch Required :' + CONVERT(nvarchar(20),ISNULL(Punch_Required,0))  --Mukti(18052016)  
     + '#Punch Both Required :' + CONVERT(nvarchar(20),ISNULL(PunchBoth_Required,0))  --Mehul(08102021)  
     + '#Advance Leave Balance :' + Convert(nvarchar(1),isnull(Is_Advance_Leave_Balance,0)) -- Added by Nilesh Patel on 03022016  
     + '#Is_InOut_Show_In_Email :' + CASE ISNULL(Is_InOut_Show_In_Email,0) WHEN 0 THEN 'N' ELSE 'Y' END  
     + '#Effect Salary Cycle :' + CASE ISNULL(Effect_Salary_Cycle,0)WHEN 0 THEN 'N' ELSE 'Y' END  
     + '#Monthly Max Leave :' + CONVERT(nvarchar(20),ISNULL(Monthly_Max_Leave,0))  
     + '#Notice Period Type :' + CASE ISNULL(NoticePeriod_Type,0) WHEN 0 THEN 'Regular' ELSE 'Slab Wise' END  
     + '#Working Days :' + CONVERT(nvarchar(10),ISNULL(Working_Days,0))  
     + '#Consecutive Days :' + CONVERT(nvarchar(10),ISNULL(Consecutive_Days,0))  
     + '#Min Leave Not Mandatory :' + CASE ISNULL(Min_Leave_Not_Mandatory,0)WHEN 0 THEN 'N' ELSE 'Y' END  
     + '#Working Club Days :' + CONVERT(nvarchar(10),ISNULL(Working_Club_Days,0))  
     + '#Consecutive Club Days :' + CONVERT(nvarchar(10),ISNULL(Consecutive_Club_Days,0))  
     + '#Calculate on Previous Month :' + CONVERT(nvarchar(10),ISNULL(Calculate_on_Previous_Month,0))  
     + '#Allowed Leave CF Years :' + CONVERT(nvarchar(10),ISNULL(No_Of_Allowed_Leave_CF_Yrs,0))  
     + '#Paternity Leave Balance :' + CONVERT(nvarchar(10),ISNULL(Paternity_Leave_Balance,0))  
     + '#Paternity Leave Validity :' + CONVERT(nvarchar(10),ISNULL(Paternity_Leave_Validity,0))                
     + '#Allow Carry Forward Before Joining :' + CONVERT(nvarchar(10),ISNULL(Allowed_CF_Join_After_Day,0))        
     + '#First_Min_Bal_then_Percent_Curr_Balance : ' + CONVERT(nvarchar(10),ISNULL(First_Min_Bal_then_Percent_Curr_Balance,0))   
     + '#Advance_Leave_Round_Off : ' + Cast(Adv_Balance_Round_off As Varchar(10))  
     + '#Advance_Leave_Round_Off_Type : ' + Cast(Adv_Balance_Round_off_Type As Varchar(10))      
     + '#Restrict_LeaveAfter_ExitNotice :' + CONVERT(nvarchar(10),ISNULL(Restrict_LeaveAfter_ExitNotice,0))  
     + '#Max_Leave_Lifetime :' + CAST(Max_Leave_Lifetime AS varchar(10))  
     + '#Is_Auto_Leave_From_Salary :' + CAST(Is_Auto_Leave_From_Salary AS varchar(1))  
   From T0040_LEAVE_MASTER WITH (NOLOCK) Where Leave_ID = @Leave_ID  
  END  
 IF @TRAN_TYPE IN ('I', 'U')  
  BEGIN  
   IF ISNULL(@OldValue, '') <> ''  
    SET @OldValue = '#';  
      
   SET @OldValue = @OldValue + 'New Value'   
       + '#'+ 'Leave Name :' + ISNULL( @Leave_Name,'')   
       + '#Leave Code:' +  CONVERT(nvarchar(20),ISNULL(@Leave_Code,''))   
       + '#After Joining Days :' + CONVERT(nvarchar(20),ISNULL(@Leave_Applicable,''))  
       + '#Type :' + ISNULL(@Leave_Type,'')    
       + '#Sorting No :' + CONVERT(nvarchar(20),ISNULL(@Leave_Sorting_No,0))  
       + '#Leave Is Paid :' + CASE ISNULL(@Leave_Paid_Unpaid,'') WHEN '' THEN 'N' ELSE 'Y' END  
       + '#Adjust with Late :' + CASE ISNULL(@Is_Adj_Late,0) WHEN 0 THEN 'N' ELSE 'Y' END  
       + '#Leave CF Prorata :' + CASE ISNULL(@Is_Leave_CF_Prorata,0) WHEN 0 THEN 'N' ELSE 'Y' END  
       + '#Is Clubbed :' + CASE ISNULL(@is_Leave_Clubbed ,0) WHEN 0 THEN 'N' ELSE 'Y' END  
       + '#Apply In Fraction :' + CASE ISNULL(@Can_Apply_Fraction,0) WHEN 0 THEN 'N' ELSE 'Y' END  
       + '#Leave CF Rounding :' + CASE ISNULL(@Is_Leave_CF_Rounding,0) WHEN 0 THEN 'N' ELSE 'Y' END  
       + '#Leave Negative Allow :' + CASE ISNULL(@Leave_Negative_Allow,0) WHEN 0 THEN 'N' ELSE 'Y' END  
       + '#Holiday as Leave :' + CASE ISNULL(@Holiday_as_leave,0) WHEN 0 THEN 'N' ELSE 'Y' END  
       + '#Display Leave Balance :' + CASE ISNULL(@Display_leave_balance,0) WHEN 0 THEN 'N' ELSE 'Y' END  
       + '#WeekOff as Leave :' + CASE ISNULL(@Weekoff_as_leave,0) WHEN 0 THEN 'N' ELSE 'Y' END  
       + '#Is Active :' + CASE ISNULL(@Leave_Status,0) WHEN 0 THEN 'N' ELSE 'Y' END  
       + '#Balance After Encashment :' + CONVERT(nvarchar(20),ISNULL(@Leave_Min_Bal,0))  
       + '#Minimum Leave To Encash :' + CONVERT(nvarchar(20),ISNULL(@Leave_Min_Encash,0))  
       + '#Maximum Leave To Encash :' + CONVERT(nvarchar(20),ISNULL(@Leave_Max_Encash,0))  
       + '#Max. No. of Application :' + CONVERT(nvarchar(20),ISNULL(@Max_No_Of_Application,0))  
       + '#Leave Encashment :' + CONVERT(nvarchar(20),ISNULL(@L_Enc_Percentage_Of_Current_Balance,0))  
       + '#Encashment Application After :' + CONVERT(nvarchar(20),ISNULL(@Encashment_After_Months,0))  
       + '#Document Required :' + CASE ISNULL(@Document_required,0) WHEN 0 THEN 'N' ELSE 'Y' END   
       + '#Effect Of LTA :' + CASE ISNULL(@Effect_Of_LTA,0) WHEN 0 THEN 'N' ELSE 'Y' END   
       + '#Apply Hourly: ' + Case isnull(@Apply_Hours,0) when 0 then 'N' else 'Y' end  
	  
       + '#Balance To Salary: ' + case isnull(@BalanceToSalary,0) when 0 then 'N' else 'Y' end  
       + '#Carry Forward Hours: ' + CAST(@CarryForwardHours AS VARCHAR(5))  
       + '#Allow Night Halt' + case when @AllowNightHalt = 0 then 'N' else 'Y' end  
        + '#Half Paid' + case when @Half_Paid = 0 then 'N' else 'Y' end  
        + '#Negative Max Limit :' + CONVERT(nvarchar(20),ISNULL(@Neg_Max_Limit,0)) --Added by Sumit 23012015  
        + '#Minimum Present Days Type' + case when @MinPDay_Type = 0 then 'Days' else '%' end  
        + '#Encash Calculation Day on :' + CONVERT(nvarchar(20),ISNULL(@Lv_Encase_Calculation_Day,0))  
        + '#Multi Branch ID :' + isnull(@Multi_Branch_ID,'') -- Added by Gadriwala Muslim 06072015  
		+ '#Multi Allowance ID :' + isnull(@Multi_Allowance_ID,'') -- Added by Mr.Mehul 19072022 
        + '#Medical Leave :' + Convert(nvarchar(1),isnull(@Medical_Leave,0)) -- Added by Gadriwala Muslim 14092015  
        + '#Leave EncashDay Half Payment:' + Convert(nvarchar(1),isnull(@Leave_EncashDay_Half_Payment,0))  
        + '#Max_Leave_Carry_Forward_From_Last_Year :' + CONVERT(nvarchar(20),ISNULL(@Max_Leave_Carry_Forward_From_Last_Year,0))  
        + '#Punch Required :' + CONVERT(nvarchar(20),ISNULL(@Punch_Required,0))  --Mukti(18052016)  
       + '#Punch Both Required :' + CONVERT(nvarchar(20),ISNULL(@PunchBoth_Required,0)) --Mehul(08102021)  
        + '#Advance Leave Balance :' + Convert(nvarchar(1),isnull(@Advance_Leave_Balance,0)) -- Added by Nilesh Patel on 03022016  
       + '#Is_InOut_Show_In_Email :' + CASE ISNULL(@Is_InOut_Show_In_Email,0) WHEN 0 THEN 'N' ELSE 'Y' END  --added by jimit 06102016  
       + '#Effect Salary Cycle :' + CASE ISNULL(@Effect_Salary_Cycle,0) WHEN 0 THEN 'N' ELSE 'Y' END   --Added by Jaina 18-03-2017  
       + '#Monthly Max Leave :' + CONVERT(nvarchar(20),ISNULL(@Monthly_Max_Leave,0))  
       + '#Notice Period Type :' + CASE ISNULL(@NoticePeriod_Type,0) WHEN 0 THEN 'Regular' ELSE 'Slab Wise' END  
       + '#Working Days :' + CONVERT(nvarchar(10),ISNULL(@Working_Days,0))  
       + '#Consecutive Days :' + CONVERT(nvarchar(10),ISNULL(@Consecutive_Days,0))  
       + '#Min Leave Not Mandatory :' + CASE ISNULL(@Min_Leave_Not_Mandatory,0) WHEN 0 THEN 'N' ELSE 'Y' END   --Added by Jaina 18-03-2017 
	  
       + '#Working Club Days :' + CONVERT(nvarchar(10),ISNULL(@Working_Club_Days,0))  
       + '#Consecutive Club Days :' + CONVERT(nvarchar(10),ISNULL(@Consecutive_Club_Days,0))  
       + '#Calculate on Previous Month :' + CONVERT(nvarchar(10),ISNULL(@Calculate_on_Previous_Month,0))  
       + '#Allowed Leave CF Years :' + CONVERT(nvarchar(10),ISNULL(@No_Of_Allowed_Leave_CF_Yrs,0))                
       + '#Paternity Leave Balance :' + CONVERT(nvarchar(10),ISNULL(@Paternity_Leave_Balance,0))  
       + '#Paternity Leave Validity :' + CONVERT(nvarchar(10),ISNULL(@Paternity_Leave_Validity,0))  
       + '#Allow Carry Forward Before Joining : ' + Cast(@Allowed_CF_Join_After_Day As Varchar(10))  
       + '#First_Min_Bal_then_Percent_Curr_Balance : ' + Cast(@First_Min_Bal_then_Percent_Curr_Balance As Varchar(10))  
       + '#Advance_Leave_Round_Off : ' + Cast(@Adv_Balance_Round_off As Varchar(10))  
       + '#Advance_Leave_Round_Off_Type : ' + Cast(@Adv_Balance_Round_off_Type As Varchar(10))  
       + '#Restrict_LeaveAfter_ExitNotice :' + CONVERT(nvarchar(10),ISNULL(@Restrict_LeaveAfter_ExitNotice,0))  
       + '#Max_Leave_Lifetime :' + CAST(@Max_Leave_Lifetime AS varchar(10))  
       + '#Is_Auto_Leave_From_Salary :' + CAST(@Is_Auto_Leave_From_Salary AS  varchar(1))  
  END  
   
 IF @TRAN_TYPE ='I'   
  begin  
   If Exists(select Leave_ID From dbo.T0040_LEAVE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID  and upper(Leave_Name) = upper(@Leave_Name) and Leave_ID <> @Leave_ID)  
    begin  
     SET @Leave_ID = 0  
     RAISERROR('@@Same Leave Name is already exists. Leave Cannot be updated!@@',16,2)  
     RETURN       
    end  
   Else If Exists(select Leave_ID From dbo.T0040_LEAVE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID  and Leave_Code = @Leave_Code and Leave_ID <> @Leave_ID)  
    begin  
     SET @Leave_ID = 0  
     RAISERROR('@@Same Leave Code is already exists. Leave Cannot be updated!@@',16,2)  
     RETURN       
    end  
      
   Declare @Leave_Def_Id As Numeric   
     
   SELECT @Leave_Def_Id =isnull(max(Leave_Def_ID),0)+ 1 From Dbo.T0040_Leave_Master WITH (NOLOCK) Where cmp_Id=@Cmp_Id  
   SELECT @Leave_ID = isnull(max(Leave_ID),0)+ 1  from dbo.T0040_LEAVE_MASTER WITH (NOLOCK)  
      
 INSERT INTO dbo.T0040_LEAVE_MASTER  
      (Leave_ID, Cmp_ID, Leave_Code, Leave_Name, Leave_Type, Leave_Count, Leave_Paid_Unpaid, Leave_Min, Leave_Max, Leave_Min_Bal,   
      Leave_Max_Bal, Leave_Min_Encash, Leave_Max_Encash, Leave_Notice_Period,Count_WeekOff_Notice_Period, Leave_Applicable, Leave_CF_Type, Leave_PDays,   
      Leave_Get_Against_PDays, Leave_Auto_Generation,Leave_CF_Month,leave_Precision,Leave_Def_Id,Leave_Bal_Reset_Month  
     ,Leave_Negative_Allow,Salary_on_Leave,Is_late_Adj,Is_Ho_Wo,Weekoff_as_leave,Holiday_as_leave,Leave_Sorting_No  
     ,No_Days_To_Cancel_WOHO,Display_leave_balance, Is_Leave_CF_Rounding,Is_Leave_CF_Prorata, Is_Leave_Clubbed  
     ,Can_Apply_Fraction,Is_CF_On_Sal_Days,Days_As_Per_Sal_Days,Max_Accumulate_Balance,Min_Present_Days,Default_Short_Name  
     ,Max_No_Of_Application,L_Enc_Percentage_Of_Current_Balance,Encashment_After_Months,Leave_Status,InActive_Effective_Date  
     ,leave_club_with,is_Document_Required,Effect_Of_LTA,Apply_Hourly,CarryForwardHours,BalanceToSalary,AllowNightHalt,Attachment_Days,Half_Paid,leave_negative_max_limit,MinPdays_Type,Trans_Leave_ID,Including_Holiday,Including_WeekOff,Including_Leave_Type
,Lv_Encase_Calculation_Day,Multi_Branch_ID,Medical_Leave,Leave_EncashDay_Half_Payment  
     ,Max_CF_From_Last_Yr_Balance,Punch_Required,PunchBoth_Required,Is_Advance_Leave_Balance,Is_InOut_Show_In_Email,Effect_Salary_Cycle,Monthly_Max_Leave,NoticePeriod_Type,Working_Days,Consecutive_Days,Min_Leave_Not_Mandatory,Consecutive_Club_Days,Working_Club_Days,  
     Calculate_on_Previous_Month,No_Of_Allowed_Leave_CF_Yrs,Paternity_Leave_Balance,Paternity_Leave_Validity,  
     Allowed_CF_Join_After_Day,First_Min_Bal_then_Percent_Curr_Balance,Adv_Balance_Round_off,Adv_Balance_Round_off_Type,Add_In_Working_Hour,Restrict_LeaveAfter_ExitNotice,  
     Max_Leave_Lifetime,Is_Auto_Leave_From_Salary,IsDoubleDeduct,Multi_Allowance_ID,Leave_Continuity)   
   VALUES (@Leave_ID,@Cmp_ID,@Leave_Code,@Leave_Name,@Leave_Type,@Leave_Count,@Leave_Paid_Unpaid,@Leave_Min,@Leave_Max,@Leave_Min_Bal  
    ,@Leave_Max_Bal,@Leave_Min_Encash,@Leave_Max_Encash,@Leave_Notice_Period,@Count_WeekOff_Notice_Period,@Leave_Applicable,@Leave_CF_Type,@Leave_PDays  
    ,@Leave_Get_Against_PDays,@Leave_Auto_Generation,@Leave_CF_Month,2.0,@Leave_Def_Id,@Leave_Bal_Reset_Month  
    ,@Leave_Negative_Allow,@Salary_on_Leave,@Is_Adj_Late,@Is_Ho_Wo,@Weekoff_as_leave,@Holiday_as_leave,@Leave_Sorting_No  
    ,@No_of_days_to_cancel_WOHO,@Display_leave_balance,@Is_Leave_CF_Rounding,@Is_Leave_CF_Prorata, @is_Leave_Clubbed  
    ,@Can_Apply_Fraction,@Is_CF_On_Sal_Days,@Days_As_Per_Sal_Days,@Max_Accumulate_Balance,@Min_Present_Days,@Default_Short_Name  
    ,@Max_No_Of_Application,@L_Enc_Percentage_Of_Current_Balance,@Encashment_After_Months,@Leave_Status,@InActive_Effe_Date  
    ,@leave_club_with,@Document_required,@Effect_Of_LTA,@Apply_Hours,@CarryForwardHours,@BalanceToSalary,@AllowNightHalt,@Attachment_Days,@Half_Paid,@Neg_Max_Limit,@MinPDay_Type,@Trans_Leave_ID,@Including_Holiday,@Including_WeekOff,Replace(@Including_Leave_Type,'9999',@Leave_ID),@Lv_Encase_Calculation_Day,@Multi_Branch_ID,@Medical_Leave,@Leave_EncashDay_Half_Payment  
    ,@Max_Leave_Carry_Forward_From_Last_Year,@Punch_Required,@PunchBoth_Required,@Advance_Leave_Balance,@Is_InOut_Show_In_Email,@Effect_Salary_Cycle,@Monthly_Max_Leave,@NoticePeriod_Type,@Working_Days,@Consecutive_Days,@Min_Leave_Not_Mandatory,@Consecutive_Club_Days,@Working_Club_Days,  
     @Calculate_on_Previous_Month,@No_Of_Allowed_Leave_CF_Yrs,@Paternity_Leave_Balance,@Paternity_Leave_Validity,  
     @Allowed_CF_Join_After_Day,@First_Min_Bal_then_Percent_Curr_Balance,@Adv_Balance_Round_off,@Adv_Balance_Round_off_Type  
     ,@Add_In_Working_Hour  
     --,@Apply_Hours -- Added By Sajid 04122021 For Hourly Leave Consider in Working Hours  
     ,@Restrict_LeaveAfter_ExitNotice,  
     @Max_Leave_Lifetime,@Is_Auto_Leave_From_Salary,@Is_DeductDouble,@Multi_Allowance_ID,@Leave_Continuity)  
      
   DELETE FROM T0045_LEAVE_APP_NOTICE_SLAB WHERE CMP_ID=@CMP_ID AND LEAVE_ID=@LEAVE_ID   --Added by Jaina 20-04-2017    ---- Added by for audit trail Ali 05102013  --  Start  
   DELETE FROM T0045_Leave_Shutdown_Period WHERE CMP_ID=@CMP_ID AND LEAVE_ID=@LEAVE_ID   --Added by Jaina 03-05-2017  
                
          
     
   ---- Added for audit trail by Ali 05102013  --  End             
  end   
 else if @tran_type ='U'   
  begin  
   If Exists(select Leave_ID From dbo.T0040_LEAVE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID  and upper(Leave_Name) = upper(@Leave_Name) and Leave_ID <> @Leave_ID)  
    begin  
     SET @Leave_ID = 0  
     RAISERROR('@@Same Leave Name is already exists. Leave Cannot be updated!@@',16,2)  
     RETURN       
    end  
   Else If Exists(select Leave_ID From dbo.T0040_LEAVE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID  and Leave_Code = @Leave_Code and Leave_ID <> @Leave_ID)  
    begin  
     SET @Leave_ID = 0  
     RAISERROR('@@Same Leave Code is already exists. Leave Cannot be updated!@@',16,2)  
     RETURN        
    end  
     
   UPDATE dbo.T0040_LEAVE_MASTER  
   SET  Leave_Code = @Leave_Code, Leave_Name = @Leave_Name, Leave_Type = @Leave_Type, Leave_Count = @Leave_Count,   
       Leave_Paid_Unpaid = @Leave_Paid_Unpaid, Leave_Min = @Leave_Min, Leave_Max = @Leave_Max, Leave_Min_Bal = @Leave_Min_Bal,   
       Leave_Max_Bal = @Leave_Max_Bal, Leave_Min_Encash = @Leave_Min_Encash, Leave_Max_Encash = @Leave_Max_Encash,   
       Leave_Notice_Period = @Leave_Notice_Period, Count_WeekOff_Notice_Period = @Count_WeekOff_Notice_Period,
	   Leave_Applicable = @Leave_Applicable, Leave_CF_Type = @Leave_CF_Type,   
       Leave_PDays = @Leave_PDays, Leave_Get_Against_PDays = @Leave_Get_Against_PDays,   
       Leave_Auto_Generation = @Leave_Auto_Generation,Leave_CF_Month =@Leave_CF_Month,leave_Precision=2.0,  
       Leave_Bal_Reset_Month=@Leave_Bal_Reset_Month,Leave_Negative_Allow=@Leave_Negative_Allow,Salary_on_Leave=@Salary_on_Leave,  
       Is_late_Adj =@Is_Adj_Late,Is_Ho_Wo=@Is_Ho_Wo,Weekoff_as_leave = @Weekoff_as_leave,Holiday_as_leave = @Holiday_as_leave,  
       Leave_Sorting_No = @Leave_Sorting_No,No_Days_To_Cancel_WOHO = @No_of_days_to_cancel_WOHO,Display_leave_balance = @Display_leave_balance,  
       Is_Leave_CF_Rounding = @Is_Leave_CF_Rounding,Is_Leave_CF_Prorata = @Is_Leave_CF_Prorata,Is_Leave_Clubbed = @is_Leave_Clubbed,  
       Can_Apply_Fraction = @Can_Apply_Fraction,Is_CF_On_Sal_Days = @Is_CF_On_Sal_Days,Days_As_Per_Sal_Days = @Days_As_Per_Sal_Days,  
       Max_Accumulate_Balance = @Max_Accumulate_Balance,Min_Present_Days = @Min_Present_Days,Max_No_Of_Application = @Max_No_Of_Application,  
       L_Enc_Percentage_Of_Current_Balance = @L_Enc_Percentage_Of_Current_Balance,Encashment_After_Months=@Encashment_After_Months,Leave_Status=@Leave_Status,  
       InActive_Effective_Date=@InActive_Effe_Date,leave_club_with=@leave_club_with,is_Document_Required = @Document_required,  
       Effect_Of_LTA = @Effect_Of_LTA,Apply_Hourly = @Apply_Hours,CarryForwardHours = @CarryForwardHours,BalanceToSalary = @BalanceToSalary,  
       AllowNightHalt = @AllowNightHalt,Attachment_Days=@Attachment_Days,Half_Paid = @Half_Paid,leave_negative_max_limit=@Neg_Max_Limit,  
       MinPdays_Type = @MinPDay_Type,Trans_Leave_ID = @Trans_Leave_ID,Including_Holiday = @Including_Holiday,Including_WeekOff = @Including_WeekOff,  
       Including_Leave_Type = @Including_Leave_Type,Lv_Encase_Calculation_Day = @Lv_Encase_Calculation_Day,Multi_Branch_ID = @Multi_Branch_ID,  
       Medical_LEave = @Medical_Leave,Leave_EncashDay_Half_Payment = @Leave_EncashDay_Half_Payment,  
       Max_CF_From_Last_Yr_Balance = @Max_Leave_Carry_Forward_From_Last_Year,Punch_Required=@Punch_Required,PunchBoth_Required=@PunchBoth_Required,Is_Advance_Leave_Balance = @Advance_Leave_Balance,  
       Is_InOut_Show_In_Email = @Is_InOut_Show_In_Email,Effect_Salary_Cycle = @Effect_Salary_Cycle,Monthly_Max_Leave = @Monthly_Max_Leave,  
       NoticePeriod_Type = @NoticePeriod_Type,Working_Days = @Working_Days,Consecutive_Days = @Consecutive_Days,  
       Min_Leave_Not_Mandatory = @Min_Leave_Not_Mandatory,Working_Club_Days = @Working_Club_Days,Consecutive_Club_Days = @Consecutive_Club_Days,  
       Calculate_on_Previous_Month=@Calculate_on_Previous_Month,No_Of_Allowed_Leave_CF_Yrs=@No_Of_Allowed_Leave_CF_Yrs,Paternity_Leave_Balance = @Paternity_Leave_Balance,  
       Paternity_Leave_Validity = @Paternity_Leave_Validity,Allowed_CF_Join_After_Day = @Allowed_CF_Join_After_Day,  
       First_Min_Bal_then_Percent_Curr_Balance = @First_Min_Bal_then_Percent_Curr_Balance,  
       Adv_Balance_Round_off = @Adv_Balance_Round_off,Adv_Balance_Round_off_Type = @Adv_Balance_Round_off_Type,  
       Add_In_Working_Hour = @Add_In_Working_Hour,  
       ---,Add_In_Working_Hour =@Apply_Hours, -- Added By Sajid 04122021 For Hourly Leave Consider in Working Hours  
       Restrict_LeaveAfter_ExitNotice = @Restrict_LeaveAfter_ExitNotice,  
        Max_Leave_Lifetime = @Max_Leave_Lifetime,  
        Is_Auto_Leave_From_Salary=@Is_Auto_Leave_From_Salary,  
        IsDoubleDeduct = @Is_DeductDouble ,Multi_Allowance_Id = @Multi_Allowance_ID,Leave_Continuity = @Leave_Continuity 
   WHERE     (Leave_ID = @Leave_ID)   
     
    
   DELETE FROM T0045_LEAVE_APP_NOTICE_SLAB WHERE CMP_ID=@CMP_ID AND LEAVE_ID=@LEAVE_ID   --Added by Jaina 20-04-2017                
   DELETE FROM T0045_Leave_Shutdown_Period WHERE CMP_ID=@CMP_ID AND LEAVE_ID=@LEAVE_ID   --Added by Jaina 03-05-2017  
  end  
 else if @tran_type ='d'  
  begin     
   BEGIN TRY         
    --EXEC P0050_Leave_Cf_Monthly_Setting 0,@Leave_ID,'1-jan-2000',@Cmp_ID,0,'D',NULL,NULL  
    EXEC P0050_Leave_Cf_Monthly_Setting @Leave_Tran_ID=0,@Leave_ID=@Leave_ID,@For_Date = NULL,@Cmp_ID=@Cmp_ID,@CF_M_Days=0,@CF_M_DaysAfterJoining=0,@tran_type='D',@Effective_Date=NULL,@Type_ID=NULL  
      
    DELETE FROM T0050_CF_EMP_TYPE_DETAIL where Cmp_ID=@Cmp_ID and Leave_ID=@Leave_ID    -- Added By Gadriwala 25022015  
    DELETE FROM dbo.T0040_LEAVE_MASTER where Leave_ID = @Leave_ID       
    DELETE FROM dbo.T0050_LEAVE_DETAIL where Leave_ID = @Leave_ID and Cmp_ID = @Cmp_ID  
    DELETE FROM dbo.T0050_LEAVE_CF_SLAB  where Leave_ID = @Leave_ID  and Cmp_ID = @Cmp_ID -- Added by nilesh Patel on 01042015  
    DELETE FROM dbo.T0050_LEAVE_CF_Present_Day  where Leave_ID = @Leave_ID  and Cmp_ID = @Cmp_ID -- Added by nilesh Patel on 01042015      
    DELETE FROM T0045_LEAVE_APP_NOTICE_SLAB WHERE CMP_ID=@CMP_ID AND LEAVE_ID=@LEAVE_ID   --Added by Jaina 20-04-2017  
    DELETE FROM T0045_Leave_Shutdown_Period WHERE CMP_ID=@CMP_ID AND LEAVE_ID=@LEAVE_ID   --Added by Jaina 03-05-2017  
   END TRY  
   BEGIN CATCH  
    DECLARE @Message Varchar(Max)  
    SET @Message = ERROR_MESSAGE();  
    IF CHARINDEX('DELETE statement conflicted with the REFERENCE constraint',@Message) > 0       
     SET @Message = '@@Reference Already Exist!@@'        
           
    RAISERROR(@Message,16,2)  
   END CATCH  
  end  
   
 EXEC P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Leave Master',@OldValue,@Leave_ID,@User_Id,@IP_Address     
 RETURN  
  
  
  
  
  
  
  
  
  
  
  
  
