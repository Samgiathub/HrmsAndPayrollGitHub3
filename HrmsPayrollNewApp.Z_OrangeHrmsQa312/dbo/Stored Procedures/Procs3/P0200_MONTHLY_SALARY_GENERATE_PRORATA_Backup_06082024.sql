CREATE PROCEDURE [dbo].[P0200_MONTHLY_SALARY_GENERATE_PRORATA_Backup_06082024]    
	@M_Sal_Tran_ID         NUMERIC OUTPUT    
	,@Emp_Id                NUMERIC    
	,@Cmp_ID                NUMERIC    
	,@Sal_Generate_Date     DATETIME    
	,@Month_St_Date         DATETIME    
	,@Month_End_Date        DATETIME    
	,@M_OT_Hours            NUMERIC(18, 4)    
	,@Areas_Amount          NUMERIC(18, 4)     
	,@M_IT_Tax              NUMERIC(18, 4)    
	,@Other_Dedu            NUMERIC(18, 4)    
	,@M_LOAN_AMOUNT         NUMERIC    
	,@M_ADV_AMOUNT          NUMERIC 
	,@IS_LOAN_DEDU          NUMERIC --(0,1)    
	,@Login_ID              NUMERIC = null    
	,@ErrRaise              VARCHAR(100)= null output    
	,@Is_Negetive           NUMERIC(1)     
	,@Status                VARCHAR(10)='Done'
	,@IT_M_ED_Cess_Amount   NUMERIC(18, 4)
	,@IT_M_Surcharge_Amount NUMERIC(18, 4)
	,@Allo_On_Leave         NUMERIC(18, 0)=1
	,@W_OT_Hours            NUMERIC(18, 4)
	,@H_OT_Hours            NUMERIC(18, 4)
	,@User_Id               numeric(18,0) = 0  -- Added for audit trail By Ali 16102013
	,@IP_Address            varchar(30)= ''    -- Added for audit trail By Ali 16102013
	,@IS_Bond_DEDU          BIT
AS    
    SET NOCOUNT ON;    
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    SET ARITHABORT OFF;  
    SET ANSI_WARNINGS OFF;


    IF EXISTS(SELECT 1 FROM sys.triggers WHERE is_disabled=1) --for sql 2005 added by hasmukh 
        BEGIN
            EXEC sp_msforeachtable 'ALTER TABLE ? ENABLE TRIGGER all'
            --SET @ErrRaise =':|:ERRT:|: Another Process Running. Try After Sometime'
            --return 
        END      

	    

    -- Variable Declaration      
    declare @Sal_Receipt_No     NUMERIC    
    declare @Increment_ID       NUMERIC    
    declare @Sal_Tran_ID        NUMERIC     
    declare @Branch_ID          NUMERIC     
    declare @Emp_OT             NUMERIC     
    declare @Emp_OT_Min_Limit   VARCHAR(10)    
    declare @Emp_OT_Max_Limit   VARCHAR(10)    
    declare @Emp_OT_Min_Sec     NUMERIC    
    declare @Emp_OT_Max_Sec     NUMERIC    
    declare @Emp_OT_Sec         NUMERIC    
    declare @Emp_OT_Hours       VARCHAR(10)    
    
    declare @Emp_WO_OT_Sec      Numeric --Mitesh 30/11/2011
    declare @Emp_WO_OT_Hours    Varchar(10) --Mitesh 30/11/2011   
    
    declare @Emp_HO_OT_Sec      Numeric --Rathod 15/11/2011
    declare @Emp_HO_OT_Hours    Varchar(10) --Rathod 15/11/2011   
    
    declare @Wages_Type             VARCHAR(10)    
    declare @SalaryBasis            VARCHAR(20)    
    declare @Payment_Mode           VARCHAR(20)    
    declare @Fix_Salary             INT    
    declare @numAbsentDays          NUMERIC(18, 4)           
    declare @numWorkingDays_Daily   NUMERIC(18, 4)    
    declare @numAbsentDays_Daily    NUMERIC(18, 4)    
    declare @Sal_cal_Days           NUMERIC(18, 4)    
    declare @Absent_Days            NUMERIC(18, 4)    
    declare @Holiday_Days           NUMERIC(18, 4)    
    declare @Weekoff_Days           NUMERIC(18, 4)    
    declare @Cancel_Holiday         NUMERIC(18, 4)    
    declare @Cancel_Weekoff         NUMERIC(18, 4)    
    declare @Working_days           NUMERIC(18, 4)    
    declare @OutOf_Days             NUMERIC            
    declare @Total_leave_Days       NUMERIC(18, 4)    
    declare @Paid_leave_Days        NUMERIC(18, 4)    
    
    DECLARE @OD_leave_Days          NUMERIC(18, 4) 
    Declare @Mid_OD_leave_Days      NUMERIC(18, 4)
    
    --Hardik 22/07/2014  
    DECLARE @Compoff_leave_Days     NUMERIC(18, 4) 
    Declare @Mid_Compoff_leave_Days NUMERIC(18, 4)
    
    declare @Actual_Working_Hours   VARCHAR(20)    
    declare @Actual_Working_Sec     NUMERIC    
    declare @Holiday_Sec            NUMERIC     
    declare @Weekoff_Sec            NUMERIC     
    declare @Leave_Sec              NUMERIC    
     
    declare @Other_Working_Sec      NUMERIC     
    declare @Working_Hours          VARCHAR(20)    
    declare @Outof_Hours            VARCHAR(20)    
    declare @Total_Hours            VARCHAR(20)    
    declare @Shift_Day_Sec          NUMERIC    
    declare @Shift_Day_Hour         VARCHAR(20)    
    declare @Basic_Salary           NUMERIC(18, 4)    
    declare @Gross_Salary           NUMERIC(18, 4)    
    declare @Actual_Gross_Salary    NUMERIC(18, 4)    
    declare @Gross_Salary_ProRata   NUMERIC(18, 4)    
    declare @Day_Salary             NUMERIC(22,5)    
    declare @Hour_Salary            NUMERIC(12,5)    
    declare @Salary_amount          NUMERIC(22,5)    
    declare @Allow_Amount           NUMERIC(18, 4)    
    DECLARE @Allow_Amount_Arear     NUMERIC(18, 4) --Hardik 07/01/2012
    declare @OT_Amount              NUMERIC(18, 4)   
    
    declare @WO_OT_Amount           Numeric(22,3)    -- Rathod 15/11/2011 
    declare @HO_OT_Amount           Numeric(22,3)    -- Rathod 15/11/2011 
    
    declare @Other_allow_Amount     NUMERIC(18, 4)    
    declare @Other_m_it_Amount      NUMERIC(18, 4)  
    declare @Dedu_Amount            NUMERIC(18, 4)  
    DECLARE @Dedu_Amount_Arear      NUMERIC(18, 4) --Hardik 07/01/2012   
    declare @Loan_Amount            NUMERIC(18, 4)    
    declare @Loan_Interest_Amount   NUMERIC(18, 4)    
    declare @Advance_Amount         NUMERIC(18, 4)    
    declare @Other_Dedu_Amount      NUMERIC(18, 4)    
    declare @Total_Dedu_Amount      NUMERIC(18, 4)    
    declare @Due_Loan_Amount        NUMERIC(18, 4)    
    declare @Net_Amount             NUMERIC(18, 4)    
    declare @Final_Amount           NUMERIC(18, 4)    
    declare @Hour_Salary_OT         NUMERIC(18, 4)    
    declare @ExOTSetting            NUMERIC(5,2)    
    declare @Inc_Weekoff            INT
    declare @Inc_Holiday            INT
    
    Declare @Late_Adj_Day           NUMERIC(5,2)    
    Declare @OT_Min_Limit           VARCHAR(20)    
    Declare @OT_Max_Limit           VARCHAR(20)    
    Declare @OT_Min_Sec             NUMERIC    
    Declare @OT_Max_Sec             NUMERIC    
    Declare @Is_OT_Inc_Salary       Float    
    Declare @Is_Daily_OT            CHAR(1)    
    Declare @Fix_OT_Shift_Hours     VARCHAR(20)
    Declare @Fix_OT_Shift_Sec       Numeric    
    Declare @Fix_OT_Work_Days       NUMERIC(18, 4)    
    Declare @Round                  NUMERIC    
    
    declare @Restrict_Present_Days  char(1)    
    Declare @Is_Cancel_Holiday      Numeric(1,0)    
    Declare @Is_Cancel_Weekoff      Numeric(1,0)    
    Declare @Join_Date              Datetime    
    Declare @Left_Date              Datetime     
    Declare @StrHoliday_Date        varchar(max)    
    Declare @StrWeekoff_Date        varchar(max)    
    
    Declare @Update_Adv_Amount      numeric  
    Declare @Total_Claim_Amount     numeric     
    Declare @Is_PT                  numeric    
    Declare @Is_Emp_PT              numeric    
    Declare @PT_Amount              numeric(18,2)    
    Declare @PT_Calculated_Amount   numeric     
    Declare @LWF_Amount             numeric     
    Declare @LWF_App_Month          varchar(50)    
    Declare @Revenue_Amount         numeric     
    Declare @Revenue_On_Amount      numeric     
    Declare @LWF_compare_month      varchar(5)    
    declare @PT_F_T_Limit           varchar(20)
    declare @Lv_Salary_Effect_on_PT Tinyint     
    Declare @Present_Days   NUMERIC(18, 4)    
    Declare @Half_Days    NUMERIC(18, 4)    
    Declare @Fix_late_W_Days  numeric(5,2)    
    Declare @Fix_late_W_Hours  varchar(10)    
    Declare @Fix_late_W_Shift_Sec  numeric    
    Declare @Late_deduction_Days numeric(5,2)    
    Declare @Extra_Late_Deduction numeric(3,2)    
    Declare @Hour_Salary_Late  numeric(12,5)    
    Declare @Late_Basic_Amount  numeric (27,5)    
    Declare @Sal_St_Date   Datetime    
    Declare @Sal_end_Date   Datetime    
    Declare @Sal_Fix_Days   numeric(5,2)    
    Declare @Bonus_Amount       numeric(10,0)    
    Declare @OT_Working_Day numeric(4,1)
    Declare @StrMonth varchar(10)  
    Declare @Is_Zero_Day_Salary Numeric(2)--nikunj At 7-sep-2010 for zero day
    Declare @Is_Negative_Ot Int     
    Declare @Wages_Amount as numeric(18,0)
    Declare @Is_Zero_Basic_Salary tinyint -- 'Alpesh 18-Oct-2011
    Declare @Gen_Id numeric
    DECLARE @Settelement_Amount    Numeric(12,0)
    Declare @No_Holiday_Days  NUMERIC(18, 4) -- Added by nilesh patel on 27042015    
    
    SET @Wages_Amount =0
    declare @Leave_Salary_Amount NUMERIC(18, 4) 
    SET @Leave_Salary_Amount=0
    Declare @Cmp_Name As Varchar(100)--nikunj 
    Declare @Leave_Encash_Day As NUMERIC(18, 4)--nikunj 
        SET @Leave_Encash_Day = 0
    Declare @Basic_Salary_Org As NUMERIC(18, 4)     
        SET @Basic_Salary_Org=0 
    Declare @L_Sal_Tran_ID As Numeric(18,0)     
        SET @L_Sal_Tran_ID=0
    Declare @Lv_Encash_Cal_On varchar(50)    
    
    Declare @Hour_Salary_Early  numeric(12,5) 
    
    declare @IS_ROUNDING AS NUMERIC(1,0)
    Declare @Is_OT_Auto_Calc tinyint
    
    
    declare @Is_Late_Slabwise tinyint
    declare @Is_Early_Slabwise tinyint
    declare @Late_Dedu_Type_inc varchar(10)
    declare @Early_Dedu_Type_inc varchar(10)
    
    declare @Is_Early_Mark      Numeric 
    declare @Is_late_Mark       Numeric 
    Declare @Is_Late_Mark_Gen  Numeric
    
    declare @Penalty_days_Early_Late  NUMERIC(18, 4) 
    
    declare @Emp_WD_OT_Rate numeric(5,1)
    declare @Emp_WO_OT_Rate numeric(5,1)
    declare @Emp_HO_OT_Rate numeric(5,1)
    
    Declare @OutOf_Days_Arear   Numeric(18,1)    --Hardik 07/01/2012
    DECLARE @Basic_Salary_Arear NUMERIC(18, 4)--Hardik 07/01/2012
    DECLARE @Gross_Salary_Arear NUMERIC(18, 4)--Hardik 07/01/2012 
    Declare @Arear_Day Numeric(18,4) --Hardik 04/01/2012
    Declare @Arear_Month Numeric(5,1) --Hardik 04/01/2012
    Declare @Arear_Year Numeric(5,1) --Hardik 04/01/2012
    Declare @Arear_Amount Numeric(22,4) -- Hardik 04/01/2012
    
    DECLARE @IsLoanCalculated BIT  --Added by Jaina 12-11-2018
    
    -- Added by rohit on 12012015
    Declare @OutOf_Days_Arear_Cutoff    Numeric(18,1)    
    DECLARE @Basic_Salary_Arear_cutoff  NUMERIC(18, 4)
    DECLARE @Gross_Salary_Arear_cutoff  NUMERIC(18, 4)
    Declare @Arear_Month_cutoff Numeric(5,1) 
    Declare @Arear_Year_cutoff Numeric(5,1) 
    Declare @Arear_Amount_cutoff Numeric(22,4) 
    
    declare @Holiday_Days_Arear_Cutoff  NUMERIC(18, 4)    
    declare @Weekoff_Days_Arear_cutoff  NUMERIC(18, 4)    
    declare @Working_days_Arear_cutoff  NUMERIC(18, 4)    
    Declare @StrHoliday_Date_Arear_cutoff  varchar(Max)  
    Declare @StrWeekoff_Date_Arear_cutoff varchar(Max)  
    
    DECLARE @Salary_amount_Arear_cutoff Numeric(12,5) 
    DECLARE @Day_Salary_Arear_cutoff        Numeric(12,5) 
    DECLARE @Allow_Amount_Arear_Cutoff  NUMERIC(18, 4) 
    DECLARE @Dedu_Amount_Arear_cutoff       NUMERIC(18, 4) 
    
	Declare @Is_OT tinyint --Hardik 04/10/2018
	Set @Is_OT = 0
    -- ended by rohit on 12012015
    
    
    
    DECLARE @Salary_amount_Arear    Numeric(12,5) --Hardik 07/01/2012 
    DECLARE @Day_Salary_Arear       Numeric(12,5) --Hardik 07/01/2012
    
    Declare @Extra_AB_Days numeric(18, 2)   ---Alpesh 20-Mar-2012
    Declare @Extra_AB_Rate numeric(18, 2)   ---Alpesh 20-Mar-2012
    Declare @Extra_AB_Amount numeric(18, 2)---Alpesh 20-Mar-2012
    
    Declare @Allow_Negative_Sal Tinyint --Mihir Trivedi 25/07/2012
    Declare @Next_Month_Advance NUMERIC(18, 4) --Mihir Trivedi 25/07/2012
    Declare @Next_Month_StrtDate Datetime --Mihir Trivedi 25/07/2012
    
    Declare @Alpha_Emp_Code varchar(50)     ----Alpesh 23-May-2012
    Declare @LogDesc    nvarchar(max)       ----Alpesh 23-May-2012
    
    declare @Unpaid_leave_Days NUMERIC(18, 4) --Alpesh 4-Aug-2012
    
    Declare @M_Cancel_weekOff Numeric(5,1) --Add by rohit for 24112012
    Declare @M_Cancel_Holiday Numeric(5,1) --Add by rohit for 24112012
    declare @is_emp_lwf tinyint
    
    declare @is_weekoff_hour      tinyint
    declare @weekoff_hours      nvarchar(50)
    Declare @Paid_Weekoff_Daily_Wages Tinyint
    
    declare @Allow_Amount_Effect_only_Net NUMERIC(18, 4) -- Rohit on 06-may-2013
    declare @Deduct_Amount_Effect_only_Net NUMERIC(18, 4) -- Rohit on 06-may-2013
    
    Declare @Monthly_Deficit_Adjust_OT_Hrs tinyint --Hardik 11/11/2013 for Pakistan
    
    Declare @Half_Day_Excepted_Count as NUMERIC(18, 4) --Hardik 13/02/2014 for Kataria
    Declare @Half_Day_Excepted_Max_Count as NUMERIC(18, 4) --Hardik 13/02/2014 for Kataria
    
    declare @Holiday_Days_Arear  NUMERIC(18, 4)    -- Added by Hardik 21/05/2014
    declare @Weekoff_Days_Arear  NUMERIC(18, 4)    --- Added by Hardik 21/05/2014
    declare @Working_days_Arear  NUMERIC(18, 4)    -- Added by Hardik 21/05/2014
    Declare @StrHoliday_Date_Arear  varchar(Max)    -- Added by Hardik 21/05/2014
    Declare @StrWeekoff_Date_Arear  varchar(Max)     -- Added by Hardik 21/05/2014
 
    DECLARE @net_round AS NUMERIC(18, 4)
    DECLARE @net_round_Type AS NVARCHAR(50)
    DECLARE @Temp_mid_Net_Amount NUMERIC(18, 4)
    DECLARE @mid_Net_Round_Diff_Amount NUMERIC(18, 4)
 
    declare @Security_Deposit_Amount NUMERIC(18, 4) -- Added by rohit on 30082014
    SET @Security_Deposit_Amount = 0

    DECLARE @Travel_Advance_Amount Numeric(18,3) -- Added by rohit on 24082015
    DECLARE @Travel_Amount Numeric(18,3) 

    DECLARE @mid_gross_Amount NUMERIC(18, 4)
    DECLARE @mid_basic_Amount NUMERIC(18, 4)
    DECLARE @mid_salary_Amount NUMERIC(18, 4)
    DECLARE @tmp_Month_St_Date DATETIME
    DECLARE @tmp_Month_End_Date DATETIME
    DECLARE @first_Month_End_Date DATETIME
    DECLARE @increment_Month NUMERIC
    DECLARE @Mid_Inc_Working_Day NUMERIC(18, 4) 
    DECLARE @mid_Sal_Cal_Days NUMERIC(18, 4)
    DECLARE @mid_Present_Days NUMERIC(18, 4)
    DECLARE @mid_Absent_Days NUMERIC(18, 4)
    DECLARE @mid_Holiday_Days NUMERIC(18, 4)
    DECLARE @mid_WeekOff_Days NUMERIC(18, 4)
    DECLARE @mid_cancel_holiday NUMERIC(18, 4)
    DECLARE @mid_cancel_weekoff NUMERIC(18, 4)
    DECLARE @mid_total_leave_days NUMERIC(18, 4)
    DECLARE @mid_paid_leave_days NUMERIC(18, 4)
    DECLARE @mid_Actual_Working_Hours VARCHAR(20)    
    DECLARE @mid_Working_Hours VARCHAR(20)    
    DECLARE @mid_Outof_Hours VARCHAR(20)   
    DECLARE @mid_OT_Hours   NUMERIC(18, 2)
    DECLARE @mid_Total_Hours    varchar(20)
    DECLARE @mid_Shift_Day_Sec  NUMERIC(18, 0)
    DECLARE @mid_Shift_Day_Hour varchar(20)
    
    DECLARE @mid_Day_Salary NUMERIC(18, 5)
    DECLARE @mid_Hour_Salary    NUMERIC(18, 5)
    DECLARE @mid_Allow_Amount   NUMERIC(18, 2)
    DECLARE @mid_OT_Amount  NUMERIC(18, 2)
    DECLARE @mid_Other_Allow_Amount NUMERIC(18, 2)
    
    DECLARE @mid_Dedu_Amount    NUMERIC(18, 2)
    DECLARE @mid_Loan_Amount    NUMERIC(18, 2)
    DECLARE @mid_Loan_Intrest_Amount    NUMERIC(18, 2)
    DECLARE @mid_Advance_Amount NUMERIC(18, 2)
    DECLARE @mid_Other_Dedu_Amount  NUMERIC(18, 2)
    DECLARE @mid_Total_Dedu_Amount  NUMERIC(18, 2)
    DECLARE @mid_Due_Loan_Amount    NUMERIC(18, 2)
    DECLARE @mid_Net_Amount NUMERIC(18, 2)
    DECLARE @mid_Actually_Gross_Salary  NUMERIC(18, 2)
    DECLARE @mid_PT_Amount  NUMERIC(18, 2)
    DECLARE @mid_PT_Calculated_Amount   NUMERIC(18, 0)
    DECLARE @mid_Total_Claim_Amount NUMERIC(18, 0)
    DECLARE @mid_M_OT_Hours NUMERIC(18, 1)
    DECLARE @mid_M_Adv_Amount   NUMERIC(18, 0)
    DECLARE @mid_M_Loan_Amount  NUMERIC(18, 0)
    DECLARE @mid_M_IT_Tax   NUMERIC(18, 0)
    DECLARE @mid_LWF_Amount NUMERIC(18, 0)
    DECLARE @mid_Revenue_Amount NUMERIC(18, 0)
    DECLARE @mid_PT_F_T_Limit   varchar(20) 
    DECLARE @mid_Leave_Salary_Amount    NUMERIC(18, 0)
    DECLARE @mid_Leave_Salary_Comments  varchar(250)
    DECLARE @mid_Late_Sec   NUMERIC(18, 0)
    DECLARE @mid_Late_Dedu_Amount   NUMERIC(18, 0)
    DECLARE @mid_Late_Extra_Dedu_Amount NUMERIC(18, 0)
    DECLARE @mid_Late_Days  NUMERIC(5, 2)
    DECLARE @mid_Short_Fall_Days    NUMERIC(5, 2)
    DECLARE @mid_Short_Fall_Dedu_Amount NUMERIC(10, 0)
    DECLARE @mid_Gratuity_Amount    NUMERIC(10, 0)
    DECLARE @mid_Is_FNF tinyint
    DECLARE @mid_Bonus_Amount   NUMERIC(10, 0)
    DECLARE @mid_Incentive_Amount   NUMERIC(10, 0)
    DECLARE @mid_Trav_Earn_Amount   NUMERIC(7, 0)
    DECLARE @mid_Cust_Res_Earn_Amount   NUMERIC(7, 0)
    DECLARE @mid_Trav_Rec_Amount    NUMERIC(7, 0)
    DECLARE @mid_Mobile_Rec_Amount  NUMERIC(7, 0)
    DECLARE @mid_Cust_Res_Rec_Amount    NUMERIC(7, 0)
    DECLARE @mid_Uniform_Rec_Amount NUMERIC(7, 0)
    DECLARE @mid_I_Card_Rec_Amount  NUMERIC(7, 0)
    DECLARE @mid_Excess_Salary_Rec_Amount   NUMERIC(10, 0)
    DECLARE @mid_Salary_Status  varchar(20)
    DECLARE @mid_Pre_Month_Net_Salary   NUMERIC(18, 0)
    DECLARE @mid_IT_M_ED_Cess_Amount    NUMERIC(18, 2)
    DECLARE @mid_IT_M_Surcharge_Amount  NUMERIC(18, 2)
    DECLARE @mid_Early_Sec  NUMERIC(18, 0)  
    DECLARE @mid_Early_Dedu_Amount  NUMERIC(18, 0)  
    DECLARE @mid_Early_Extra_Dedu_Amount    NUMERIC(18, 0)  
    DECLARE @mid_Early_Days NUMERIC(5, 2)   
    DECLARE @mid_Deficit_Sec    NUMERIC(18, 0)  
    DECLARE @mid_Deficit_Dedu_Amount    NUMERIC(18, 0)  
    DECLARE @mid_Deficit_Extra_Dedu_Amount  NUMERIC(18, 0)  
    DECLARE @mid_Deficit_Days   NUMERIC(5, 2)   
    DECLARE @mid_Total_Earning_Fraction NUMERIC(5, 2)   
    DECLARE @mid_Late_Early_Penalty_days    NUMERIC(5, 2)   
    DECLARE @mid_M_WO_OT_Hours  NUMERIC(18, 2)  
    DECLARE @mid_M_HO_OT_Hours  NUMERIC(18, 2)  
    DECLARE @mid_M_WO_OT_Amount NUMERIC(18, 2)  
    DECLARE @mid_M_HO_OT_Amount NUMERIC(18, 2)  
    DECLARE @mid_M_Working_Days NUMERIC(18, 2)  
    DECLARE @total_Present_Days   NUMERIC(18, 4)    
    DECLARE @total_count_all_incremnet NUMERIC(5)
    DECLARE @DayRate_WO_Cancel TINYINT --hardik 20/05/2014 for Nirma

    DECLARE @mid_OT_Adj_Days NUMERIC(18, 4)
    DECLARE @mid_OT_Adj_Hours Varchar(6)    --Added By Jimit 23072018


    DECLARE @Salary_Depends_on_Production AS TINYINT
    DECLARE @Grd_Id AS NUMERIC
    DECLARE @Production_Gross_Salary AS NUMERIC(18, 4)
    
    DECLARE @Half_Day_Count AS NUMERIC
    DECLARE @Qry AS VARCHAR(MAX)
    DECLARE @Is_Manual_Present AS TINYINT
    
    -------------------- Late Deduction ---------------------------    
    DECLARE @Late_Absent_Day  NUMERIC(18, 4)    
    DECLARE @Total_LMark   NUMERIC(18, 4)    
    DECLARE @Total_Late_Sec   NUMERIC     
    DECLARE @Late_Dedu_Amount  NUMERIC     
    DECLARE @Extra_Late_Dedu_Amount NUMERIC    
    DECLARE @late_Extra_Amount AS NUMERIC  
    DECLARE @Late_is_slabwise AS TINYINT
    DECLARE @Is_Late_Calc_HO_WO AS TINYINT
    DECLARE @Is_Early_Calc_HO_WO AS TINYINT 
    
    
    
    DECLARE @Absent_date_String VARCHAR(MAX)
    DECLARE @Absent_For_date AS DATETIME
    DECLARE @Cur_Weekoff_Sec    NUMERIC(18, 4)
    DECLARE @Cur_Holiday_Sec    NUMERIC(18, 4)
    
    
    -----------------------------Early-------------------Mitesh---
    DECLARE @Early_Adj_Day          NUMERIC(5,2)   
    DECLARE @Early_Sal_Dedu_Days    NUMERIC(18, 4)    
    DECLARE @Total_EarlyMark        NUMERIC(18, 4)    
    DECLARE @Total_Early_Sec        NUMERIC    
    DECLARE @Early_Dedu_Amount      NUMERIC     
    DECLARE @Extra_Early_Dedu_Amount NUMERIC    
    DECLARE @Early_Extra_Amount     NUMERIC  
    DECLARE @Fix_Early_W_Days       NUMERIC(5,2)    
    DECLARE @Fix_Early_W_Hours      VARCHAR(10)    
    DECLARE @Fix_Early_W_Shift_Sec  NUMERIC    
    DECLARE @Extra_Early_Deduction  NUMERIC(3,2)    
    DECLARE @Early_is_slabwise      TINYINT
    
    
    
    DECLARE @Total_Total_Sec NUMERIC
    DECLARE @Total_penalty_days NUMERIC(3,2)
    DECLARE @Total_Late_Hours VARCHAR(10)
    DECLARE @Total_Early_Hours VARCHAR(10)
    DECLARE @Total_LE_Hours nvarchar(10)
    DECLARE @Total_Days_Adjust NUMERIC(18, 4)
    DECLARE @tmp_Days_Adjust NUMERIC(18, 4)
    
    
    Declare @OldValue varchar(max)  -- Added By Gadriwala Muslim 08102014
    Declare @Old_Emp_Name varchar(max)  -- Added By Gadriwala Muslim 08102014
                

    DECLARE @Present_AfterCuttoff as NUMERIC(18,3) -- Added by rohit on 10012015
    DECLARE @Weekoff_AfterCuttoff as NUMERIC(18,3) -- Added by rohit on 10012015
    DECLARE @Holiday_AfterCuttoff as NUMERIC(18,3) -- Added by rohit on 10012015
    DECLARE @CutoffDate_Salary as DATETIME

    DECLARE @Is_Cutoff_Salary as tinyint --Added by Hardik 02/02/2016
    DECLARE @Asset_Installment NUMERIC(18, 4) --Mukti 23032015
    DECLARE @TotASSET_Closing NUMERIC(18, 4)--Mukti 25032015

    DECLARE @Absent_Day_Calc NUMERIC(18,2) --Added By nilesh on 04112015 (For abSent Day Calculation)
    DECLARE @Is_Cancel_Holiday_WO_HO_same_day TINYINT --Added By nilesh on 19112015(For Cancel Holiday When WO/HO on Same Day
    DECLARE @mid_travel_Advance_Amount  NUMERIC(18, 3) -- Added by rohit on 24082015
    DECLARE @mid_Travel_Amount  NUMERIC(18, 3)
    
    Declare @Emp_Part_Time numeric
    
    declare @manual_salary_period as numeric(18,0) -- Comment and added By rohit on 11022013
    declare @is_salary_cycle_emp_wise as tinyint -- added by mitesh on 03072013
    
    declare @Salary_Cycle_id as numeric
    
    declare @Absent_after_Cutoff_date as NUMERIC(18, 4)
    
    declare @last_Month_Cutoffdate as datetime
    declare @temp_previous_month_end_date as datetime
    
    declare @temp_increment_id as numeric
    declare @temp_increment_Effdate as Datetime
    
    DECLARE @cnt NUMERIC 
    DECLARE @CutoffDate_Salary_temp AS DATETIME  -- Added by rohit For Mid increment Case on 09052015

	DECLARE @Is_Consider_LWP_In_Same_Month tinyint -- Added by Hardik 19/02/2019 for Havmor
	Set @Is_Consider_LWP_In_Same_Month = 0
	
	SELECT @Is_Consider_LWP_In_Same_Month = ISNULL(Setting_Value,0) 
	FROM T0040_SETTING 
	WHERE Setting_Name = 'Consider LWP in Same Month for Cutoff Salary' And Cmp_Id = @Cmp_Id
	
	-- Break Hours is not consider in Hourly OT Rate Calculation for ShopShip Yard
	DECLARE @Break_Hours_OT_Rate tinyint -- Added by Nilesh Patel on 26/06/2019 -- For ShoftShip Yard
	Set @Break_Hours_OT_Rate = 0
	
	SELECT @Break_Hours_OT_Rate = ISNULL(Setting_Value,0) 
	FROM T0040_SETTING 
	WHERE Setting_Name = 'Break Hours not consider in OT Hourly Rate Calculation, if Deduct Break Hour Ticked in Shift Master' And Cmp_Id = @Cmp_Id

    --Hardik 16/10/2013
    Declare @Allowed_Full_WeekOff_MidJoining_DayRate as tinyint
    Declare @Allowed_Full_WeekOff_MidJoining as tinyint
    
    --Sumit 04/06/2016
    Declare @Allowed_Full_WeekOff_MidLeft_DayRate as tinyint
    Declare @Allowed_Full_WeekOff_MidLeft as tinyint
    
    --- Added by Hardik 04/05/2013 for SET From Date and To date as per Salary Cycle for Arear Month
    Declare @Sal_St_Date_Arear as Datetime
    Declare @Sal_End_Date_Arear as Datetime
    
    Declare @Sal_St_Date_Arear_Cutoff as Datetime
    Declare @Sal_End_Date_Arear_Cutoff as Datetime
    
    --Hardik 16/10/2013
    Declare @StrWeekoff_Date_DayRate as varchar(max)
	Declare @StrHoliday_Date_DayRate as varchar(max)
    DECLARE @Weekoff_Days_DayRate NUMERIC(18, 4)      
	declare	 @Holiday_Days_DayRate NUMERIC(18, 4)     
    
    Declare @Approved_OT_Sec as Numeric
    Declare @Approved_WO_OT_Sec as Numeric
    Declare @Approved_HO_OT_Sec As Numeric
    
    Declare @Emp_OT_Hours_Var As Varchar(10)--Nikunj
    Declare @Emp_OT_Hours_Num As NUMERIC(18, 4)--Nikunj


    Declare @Emp_WO_OT_Hours_Var As Varchar(10) --Hardik 29/11/2011
    Declare @Emp_WO_OT_Hours_Num As Numeric(22,3)--Hardik 29/11/2011
    Declare @Emp_HO_OT_Hours_Var As Varchar(10) --Hardik 29/11/2011
    Declare @Emp_HO_OT_Hours_Num As Numeric(22,3)--Hardik 29/11/2011
    
    Declare @Late_Mark_Scenario Numeric(2,0) --Added by nilesh patel 
    SET @Late_Mark_Scenario = 1

	Declare @Early_Mark_Scenario Numeric(2,0) --Added by nilesh patel 
    SET @Early_Mark_Scenario = 1
    
    Declare @Total_Late_OT_Hours NUMERIC(18,2) --Added by nilesh patel 22042019
    SET @Total_Late_OT_Hours = 0
    
    Declare @Late_Adj_Again_OT NUMERIC(5,0)
    SET @Late_Adj_Again_OT = 0
    
    Declare @Is_LateMark_Percent Numeric(1,0) --Added by nilesh patel 16062017
    SET @Is_LateMark_Percent = 0
    
    Declare @Is_LateMark_Calc_On Numeric(1,0) --Added by nilesh patel 16062017
    SET @Is_LateMark_Calc_On = 0

	Declare @Is_EarlyMark_Percent Numeric(1,0) --Added by nilesh patel 22042019
    SET @Is_EarlyMark_Percent = 0
    
    Declare @Is_EarlyMark_Calc_On Numeric(1,0) --Added by nilesh patel 22042019
    SET @Is_EarlyMark_Calc_On = 0

	Declare @LateEarly_Combine Numeric(2,0) 
    SET @LateEarly_Combine = 0

	Declare @LateEarly_MonthWise Numeric(2,0) 
    SET @LateEarly_MonthWise = 0

    DECLARE @is_present_on_holiday TINYINT -- Added by rohit on 29022016
    DECLARE @Rate_Of_National_Holiday NUMERIC(18,2)
    DECLARE @mid_present_on_holiday as NUMERIC(18,2) 
    
    DECLARE @WORKING_DAYS_DAY_RATE  NUMERIC(18, 4)
    SET @WORKING_DAYS_DAY_RATE=0; --ADDED BY SUMIT ON 09/11/2016
    
    DECLARE @FIX_OT_HOUR_RATE_WD NUMERIC(18,2)  --ADDED BY JAINA 15-03-2017
    SET @FIX_OT_HOUR_RATE_WD = 0
    DECLARE @FIX_OT_HOUR_RATE_WO_HO NUMERIC(18,2)   --ADDED BY JAINA 15-03-2017
    SET @FIX_OT_HOUR_RATE_WO_HO = 0 

    -- Added By Mukti On 13062017 for Uniform Modules 
    DECLARE @Uniform_Deduction_Amount Numeric(18,2)
    DECLARE @Uniform_Refund_Amount Numeric(18,2)
    DECLARE @mid_Unifrom_dedu_Amt  Numeric(18,2)
    DECLARE @mid_Unifrom_ref_Amt  Numeric(18,2)

    SET @Uniform_Deduction_Amount = 0
    SET @Uniform_Refund_Amount = 0
    SET @mid_Unifrom_dedu_Amt = 0
    SET @mid_Unifrom_ref_Amt = 0
    -- Added By Mukti On 13062017 for Uniform Modules 
    
    Declare @Late_Dedu_Amount_Percenatge Numeric(18,0)
    SET @Late_Dedu_Amount_Percenatge = 0
    DECLARE @Cutoff_Start_Date DATETIME  --Added by Jaina 28-11-2017

    DECLARE @SEGMENT_ID AS NUMERIC(18,0)
    SET @SEGMENT_ID = 0

    Declare @OT_Adj_Days Numeric(18,2)
    Set @OT_Adj_Days = 0

    Declare @Is_OT_Adj_against_Absent tinyint
    Set @Is_OT_Adj_against_Absent = 0
    
    --Added By Jimit 20072018   
    Declare @Is_OT_Adj_Against_Absent_Hour varchar(6)  
    Set @Is_OT_Adj_Against_Absent_Hour = '00:00'
    --Ended
    
    Declare @Night_Shift_Count Numeric
    Set @Night_Shift_Count = 0
    
    Declare @Late_Early_Ded_Combine Numeric
    Set @Late_Early_Ded_Combine = 0

    Declare @Mid_Inc_Late_Mark_Count Numeric(18,0)
	Declare @Mid_Inc_Early_Mark_Count Numeric(18,0)
    Set @Mid_Inc_Late_Mark_Count = 0
	set @Mid_Inc_Early_Mark_Count = 0
    
    DECLARE @BOND_AMOUNT			NUMERIC(18, 4) --ADDED BY RAJPUT ON 04102018
	

	-- Added by Hardik 14/11/2018 for Shoft Shift Yard Client
	DECLARE @Shift_Wise_OT_Rate TINYINT
	DECLARE @Shift_Wise_OT_Calculated tinyint
	SET @Shift_Wise_OT_Rate = 0

	SELECT @Shift_Wise_OT_Rate = Setting_Value FROM T0040_SETTING where CMP_ID = @Cmp_Id and Setting_Name = 'Enable Shift Wise Over Time Rate'
	declare @settingval as numeric = 0  --Added new setting by Mr.Mehul on 10-May-2023
	Select @settingval = Setting_Value from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name = 'Present On Holiday And Weekoff Calculate On Shift Master Slab Wise.'
	
    /*************************************************************************************************
    Modified by Nimesh on 21-Dec-2015 (Implemented cursor to make procedure execution only one time.
    *************************************************************************************************/
    
    
    /****************************************
    Creating Temp Tables
    ****************************************/     
    CREATE TABLE #OT_Data
    (
        Emp_ID          numeric ,
        Basic_Salary    NUMERIC(18,5),
        Day_Salary      NUMERIC(12,5),
        OT_Sec          numeric,
        Ex_OT_Setting   NUMERIC(18, 4),
        OT_Amount       numeric,
        Shift_Day_Sec   INT,
        OT_Working_Day  NUMERIC(4,1),
        Emp_OT_Hour     NUMERIC(18, 4),
        Hourly_Salary   NUMERIC(18,5) , 
        WO_OT_Sec       Numeric,
        WO_OT_Amount    NUMERIC(22,3),
        WO_OT_Hour      NUMERIC(22,3),
        HO_OT_Sec       Numeric,
        HO_OT_Amount    NUMERIC(22,3),
        HO_OT_Hour      NUMERIC(22,3)
    )    
    
    
    -- For Calculate Present Days    
    CREATE TABLE #Data     
    (     
        Emp_Id     NUMERIC ,     
        For_date   DATETIME,    
        Duration_in_sec  NUMERIC,    
        Shift_ID   NUMERIC ,    
        Shift_Type   NUMERIC ,    
        Emp_OT    NUMERIC ,    
        Emp_OT_min_Limit NUMERIC,    
        Emp_OT_max_Limit NUMERIC,    
        P_days    NUMERIC(18, 4) default 0,    
        OT_Sec    NUMERIC default 0,
        In_Time DATETIME default null,
        Shift_Start_Time DATETIME default null,
        OT_Start_Time NUMERIC default 0,
        Shift_Change TINYINT default 0 ,
        Flag Int Default 0  ,
        Weekoff_OT_Sec  NUMERIC default 0,
        Holiday_OT_Sec  NUMERIC default 0   ,
        Chk_By_Superior NUMERIC default 0,
        IO_Tran_Id     NUMERIC default 0,
        OUT_Time DATETIME, 
        Shift_End_Time DATETIME,        --Ankit 16112013
        OT_End_Time NUMERIC default 0,  --Ankit 16112013
        Working_Hrs_St_Time TINYINT default 0, --Hardik 14/02/2014
        Working_Hrs_End_Time TINYINT default 0, --Hardik 14/02/2014
        GatePass_Deduct_Days NUMERIC(18, 4) default 0 -- Added by Gadriwala Muslim 05012014   
    )
    
    --Added by Hardik 12/08/2013 for Split Shift Calculation
    CREATE TABLE #Split_Shift_Table
    (
        Emp_Id NUMERIC,
        Split_Shift_Count NUMERIC(18,0),
        Split_Shift_Dates VARCHAR(5000),
        Split_Shift_Allow NUMERIC(18, 4)
    )
    
    
    CREATE TABLE #Att_Muster_with_shift
    (
        Emp_Id      numeric , 
        Cmp_ID      numeric,
        For_Date    datetime,
        Status      varchar(10),
        Leave_Count NUMERIC(5,1),
        WO_HO       varchar(2),
        Status_2    varchar(10),
        Row_ID      numeric ,
        WO_HO_Day   NUMERIC(3,1) default 0,
        P_days      NUMERIC(5,4) default 0,
        A_days      NUMERIC(5,4) default 0,
        Join_Date   Datetime default null,
        Left_Date   Datetime default null,
        GatePass_Days NUMERIC(18, 4) default 0, --Added by Gadriwala Muslim 07042015
        Late_deduct_Days NUMERIC(18, 4) default 0,  --Added by Gadriwala Muslim 07042015
        Early_deduct_Days NUMERIC(18, 4) default 0,  --Added by Gadriwala Muslim 07042015
        shift_id    numeric
    )
    
    IF OBJECT_ID('tempdb..##Att_Muster1') IS NOT NULL
        TRUNCATE TABLE ##Att_Muster1
    ELSE
        CREATE TABLE ##Att_Muster1
        (
            Emp_Id NUMERIC , 
            Cmp_ID NUMERIC,
            Leave_Count NUMERIC(5,2) DEFAULT 0,
            WO NUMERIC(5,2) DEFAULT 0,
            HO NUMERIC(5,2) DEFAULT 0,
            Total_cycle_days NUMERIC(18, 4),
            Total_Present NUMERIC(18, 4)            
        )       
                
    CREATE TABLE #Mid_Increment
    (
        Emp_ID          numeric ,
        Increment_id    numeric,
        Increment_effective_Date    datetime    
    )
    
     CREATE TABLE #Mid_Increment1
      (
        Emp_ID          numeric ,
        Increment_id    numeric,
        Month_st_Date   datetime,
        Month_End_Date  datetime
      )
    CREATE TABLE #Total_leave_Id 
    (
        Total_leave_Days_Id nvarchar(50) 
    )
    
    Create Table #Loan_Due_Amount
    (
        Emp_ID Numeric,
        Loan_ID Numeric(18,0),
        Loan_Closing Numeric(18,2)
    ) 
    
    ----Updating Revised Allowance Ends here By Ramiz on 07/10/2015
    CREATE TABLE #DA_Allowance
    (
        Grd_Id          NUMERIC ,
        Grd_Count       NUMERIC(18, 4) ,
        Basic_Salary    NUMERIC(18, 4) DEFAULT 0,
        DA_Allow_Salary NUMERIC(18, 4) DEFAULT 0 ,
        BasicDA_OT_Salary       NUMERIC(18, 4) DEFAULT 0 ,
        Day_Night_Flag  NUMERIC(18) DEFAULT 0,  ----0: Day Shift, 1: Night Shift
        Is_Master_Grd   TINYINT DEFAULT 0,
        Master_Basic    numeric(18,2),
        Is_Leave_Applied TINYINT DEFAULT 0,
    ) 
    
        
    CREATE TABLE #OT_Gradewise
    (
        Grd_Id                  NUMERIC ,
        For_date                DATETIME,
        Grd_Hour_Basic_Salary   NUMERIC(18, 4) DEFAULT 0,
        DA_Allow_Salary         NUMERIC(18, 4) DEFAULT 0 ,
        Is_Master_Grd           TINYINT DEFAULT 0,
        Master_Basic            NUMERIC(18,2),
        Grd_OT_Hours            NUMERIC(18,2),
        Amount_Credit           NUMERIC(18,2),
        Amount_Debit            NUMERIC(18,2),
        Is_Leave_Applied        TINYINT DEFAULT 0       --0: Working Day , 1: Leave Day , 2: Holiday ,3: WeekOff
    ) 
    
    CREATE TABLE #EFFICIENCY_SALARY
    (   
        Machine_ID          VARCHAR(100),
        Days_Count          NUMERIC(18,0),
        Master_Basic        NUMERIC(18,2),  
        Calculated_Basic    NUMERIC(18,2),
        DA_Allow_Salary     NUMERIC(18,2),
        WORKED_IN           VARCHAR(20),
    )
    
    SELECT TOP 0 * INTO #T0210_MONTHLY_AD_DETAIL FROM T0210_MONTHLY_AD_DETAIL WHERE SAL_TRAN_ID=-1
    CREATE NONCLUSTERED INDEX IX_T0210_MONTHLY_AD_DETAIL_TEMP_SAL_TRAN_ID ON #T0210_MONTHLY_AD_DETAIL (TEMP_SAL_TRAN_ID,m_AD_Flag);

	-- Added by Hardik 19/02/2019 for Havmor
	CREATE TABLE #LWP_LEAVE_AFTER_CUTOFF
	(	Emp_Id				Numeric,
		Leave_Approval_Id	NUMERIC(18,0),
		Leave_Id			int,
		Leave_Period		NUMERIC(18,2),
		For_Date			Datetime
	)
	


    --CURSUR STARTED
    
    DECLARE @Count_emp_monthly AS NUMERIC;
    DECLARE @intFlag_monthly AS NUMERIC(18, 0);
    DECLARE @cur_mon_Tran_id AS NUMERIC(18,0);

    SELECT  @Count_emp_monthly = COUNT(row_ID)
    FROM    #Pre_Salary_Data_monthly_Exe 
    --WHERE EMP_ID=11
    
    --Added by Jaina 24-08-2016 Start
    DECLARE @CUST_AUDIT AS TINYINT
    DECLARE @OT_RATE_TYPE AS TINYINT = 0 -- ADDED BY RAJPUT ON 03072018
    DECLARE @OT_SLAB_TYPE AS TINYINT = 0 -- ADDED BY RAJPUT ON 03072018
    
   --Alpesh 23-Mar-2012 put this to get Branch_Id to get Salary_St_Date when Branches have diff Salary_St_date but chk for Mid Increment
     --SELECT @BRANCH_ID = BRANCH_ID , @CUST_AUDIT = ISNULL(I.CUSTOMER_AUDIT,0) FROM T0095_INCREMENT I INNER JOIN     
        --( 
        --SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM T0095_INCREMENT    
        --WHERE INCREMENT_EFFECTIVE_DATE <= @MONTH_END_DATE AND CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID GROUP BY EMP_ID
        --) QRY ON    
        --I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID WHERE I.EMP_ID = @EMP_ID 
   --Added by Jaina 24-08-2016 End
   
    /*GETTING SETTINGS FROM SETTING TABLE*/
        
    SET @is_salary_cycle_emp_wise = 0
    SELECT @is_salary_cycle_emp_wise = isnull(Setting_Value,0) from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name = 'Salary Cycle Employee Wise'
    
    -- Added By Nilesh Patel on 04112015 -Start
    SET @Absent_Day_Calc = 0;   
    SELECT @Absent_Day_Calc = Setting_Value From T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name='Show absent days in salary slip when calaculate salary on fix day'
    -- Added By Nilesh Patel on 04112015 End

    DECLARE @Gradewise_Salary_Enabled   tinyint    --Added By Ramiz for Mafatlals
    SET @Gradewise_Salary_Enabled = 0
    SELECT @Gradewise_Salary_Enabled = isnull(Setting_Value,0) from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name = 'Show Gradewise Salary Textbox in Grade Master'
            
    SET @intFlag_monthly = 1
    WHILE ( @intFlag_monthly <= @Count_emp_monthly )
        BEGIN
            SET @cur_mon_Tran_id = 0
            SET @Cmp_ID = 0
  SET @M_Sal_Tran_ID = 0
            SET @Emp_Id = 0
            SET @Sal_Generate_Date = NULL
            SET @Month_St_Date = NULL
            SET @Month_End_Date = NULL
            SET @M_OT_Hours = 0
            SET @Areas_Amount = 0
            SET @M_IT_Tax = 0
            SET @Other_Dedu = 0
            SET @M_LOAN_AMOUNT = 0
            SET @M_ADV_AMOUNT = 0
            SET @IS_LOAN_DEDU = 0
            SET @Login_ID = 0
            SET @ErrRaise = 0
            SET @Is_Negetive = 0
            SET @Status = ''
            SET @IT_M_ED_Cess_Amount = 0
            SET @IT_M_Surcharge_Amount = 0
            SET @Allo_On_Leave = 0
            SET @User_Id = 0
            SET @IP_Address = NULL
            SET  @CUST_AUDIT = 0
            SET @Sal_St_Date = NULL;
            set @Mid_Inc_Late_Mark_Count = 0 --Added by ronakk 08022024

            SET @IsLoanCalculated = 0;
            
            SELECT  @cur_mon_Tran_id = Tran_id ,
                    @Cmp_ID = Cmp_ID ,
                    @M_Sal_Tran_ID = M_Sal_Tran_ID ,
                    @Emp_Id = Emp_Id ,
                    @Sal_Generate_Date = Sal_Generate_Date ,
                    @Month_St_Date = Month_St_Date ,
                    @Month_End_Date = Month_End_Date ,
                    @M_OT_Hours = M_OT_Hours ,
                    @Areas_Amount = Areas_Amount ,
                    @M_IT_Tax = M_IT_Tax ,
                    @Other_Dedu = Other_Dedu ,
                    @M_LOAN_AMOUNT = M_LOAN_AMOUNT ,
                    @M_ADV_AMOUNT = M_ADV_AMOUNT ,
                    @IS_LOAN_DEDU = IS_LOAN_DEDU ,
                    @Login_ID = Login_ID ,
                    @ErrRaise = ErrRaise ,
                    @Is_Negetive = Is_Negetive ,
                    @Status = Status ,
                    @IT_M_ED_Cess_Amount = IT_M_ED_Cess_Amount ,
                    @IT_M_Surcharge_Amount = IT_M_Surcharge_Amount ,
                    @Allo_On_Leave = Allo_On_Leave ,
                    @User_Id = User_Id ,
                    @IP_Address = IP_Address 
            FROM    #Pre_Salary_Data_monthly_Exe
            WHERE   Row_ID = @intFlag_monthly 
                    
            IF IsNull(@Status,'') =''    
                SET @Status ='Done'    
                
            SET @Holiday_Days_Arear = 0 -- Added by Hardik 21/05/2014
            SET @Weekoff_Days_Arear = 0    --- Added by Hardik 21/05/2014
            SET @Working_days_Arear = 0    -- Added by Hardik 21/05/2014
            SET @OutOf_Days_Arear = 0
            SET @Day_Salary_Arear = 0
            
            -- Added by rohit on 12012015
            SET @Holiday_Days_Arear_Cutoff = 0  
            SET @Weekoff_Days_Arear_cutoff = 0 
            SET @Working_days_Arear_cutoff = 0 
            SET @OutOf_Days_Arear_Cutoff = 0
            SET @Day_Salary_Arear_cutoff = 0
            SET @OutOf_Days_Arear_Cutoff = 0
            SET @Dedu_Amount_Arear_cutoff = 0 
            
            -- ended by rohit on 12012015
            
            SET @is_emp_lwf = 0
            SET @Paid_Weekoff_Daily_Wages = 0
            SET @Monthly_Deficit_Adjust_OT_Hrs = 0

            
            -- Added By Ali 04042014 -- statr
            --DECLARE @net_round AS NUMERIC(18, 4)
            --DECLARE @net_round_Type AS NVARCHAR(50)
            --Declare @Temp_mid_Net_Amount NUMERIC(18, 4)
            --Declare @mid_Net_Round_Diff_Amount NUMERIC(18, 4)
            SET @net_round = 0
            SET @net_round_Type = ''
            SET @Temp_mid_Net_Amount = 0
            SET @mid_Net_Round_Diff_Amount = 0
            -- Added By Ali 04042014 -- statr
            
            SET @OldValue = ''              
            SET @Old_Emp_Name = ''

            
            SET @Present_AfterCuttoff=0;
            SET @Weekoff_AfterCuttoff =0;
            SET @Holiday_AfterCuttoff =0    ;
            SET @CutoffDate_Salary = Null;          
            
            SET @Asset_Installment=0
         SET @TotASSET_Closing = 0;
            
            SET @Absent_Day_Calc = 0
            SET @Is_Cancel_Holiday_WO_HO_same_day = 0
            SET @mid_travel_Advance_Amount=0
            SET @mid_Travel_Amount=0

            
            
            SET @is_weekoff_hour =0
            SET @weekoff_hours = '00:00'
            SET @OutOf_Days = datediff(d,@Month_St_Date,@Month_End_Date) + 1    
            SET @Emp_OT   = 0    
            SET @Wages_Type  = ''    
            SET @SalaryBasis = ''    
            SET @Payment_Mode = ''    
            SET @Fix_Salary  = 0
            SET @numAbsentDays =0    
            SET @numWorkingDays_Daily = 0    
            SET @numAbsentDays_Daily  = 0    
            SET @Sal_cal_Days  = 0    
            SET @Absent_Days  = 0    
            SET @Holiday_Days  = 0    
            SET @Weekoff_Days  = 0    
            SET @Cancel_Holiday  = 0    
            SET @Cancel_Weekoff  = 0    
            SET @Working_days  = 0    
            SET @Total_leave_Days  = 0    
            SET @Paid_leave_Days  = 0    
            SET @OD_leave_Days      = 0   
            SET @Mid_OD_leave_Days = 0
            
            SET @Compoff_leave_Days = 0
            SET @Mid_Compoff_leave_Days = 0 
            
            SET @Update_Adv_Amount = 0    
            SET @Total_Claim_Amount  = 0    
            SET @IS_ROUNDING = 1    
            
            SET @WO_OT_Amount   = 0   
            SET @HO_OT_Amount   = 0   
            
            SET @Gen_Id = 0
            SET @Actual_Working_Hours  =''    
            SET @Actual_Working_Sec = 0    
            SET @Holiday_Sec  = 0    
            SET @Weekoff_Sec  = 0    
            SET @Leave_Sec   = 0    
            
            SET @Other_Working_Sec =0    
            SET @Working_Hours  = ''    
            SET @Outof_Hours  = ''    
            SET @Total_Hours  = ''    
            SET @Shift_Day_Sec = 0     
            SET @Shift_Day_Hour   = ''    
            SET @Basic_Salary   = 0     
            SET @Day_Salary    = 0    
            SET @Hour_Salary   = 0    
            SET @Salary_amount   = 0    
            SET @Allow_Amount   = 0    
            SET @OT_Amount    = 0    
            SET @Other_allow_Amount  = @Areas_Amount    
            SET @Gross_Salary   = 0    
            SET @Dedu_Amount   = 0    
            SET @Loan_Amount   = 0    
            SET @Loan_Interest_Amount = 0    
            SET @Advance_Amount   = 0    
            SET @Other_Dedu_Amount = @Other_Dedu  
            SET @Other_m_it_Amount = 0--@M_IT_Tax commented by Falak on 13/10/2011 to ALTER TDS allowance       
            SET @Total_Dedu_Amount = 0    
            SET @Due_Loan_Amount = 0    
            SET @Net_Amount   = 0    
            SET @Final_Amount  = 0    
            SET @Hour_Salary_OT  = 0     
            SET @Inc_Weekoff = 1 
            SET @Inc_Holiday = 1    
            SET @Is_Late_Mark_Gen = 0
            
            SET @Late_Adj_Day = 0    
            SET @ExOTSetting   = 0    
            SET @OT_Min_Limit   =''    
            SET @OT_Max_Limit   = ''    
            SET @Is_OT_Inc_Salary  = 0   
            SET @Is_Daily_OT   = 'N'    
            SET @Fix_OT_Shift_Hours = ''    
            SET @Fix_OT_Shift_Sec = 0
            SET @Fix_OT_Work_Days = 0    
            SET @OT_Min_Sec  = 0    
            SET @OT_Max_Sec  = 0    
            SET @Round = 0    
            SET @Restrict_Present_Days = 'Y'    
            SET @Is_Cancel_Weekoff = 0    
            SET @Is_Cancel_Holiday = 0    
            SET @StrHoliday_Date = ''    
            SET @StrWeekoff_Date = ''    
            SET @Emp_OT_Min_Limit = ''    
            SET @Emp_OT_Max_Limit = ''    
            SET @Emp_OT_Min_Sec = 0    
            SET @Emp_OT_Max_Sec = 0    
            SET @Is_Cutoff_Salary = 0
            SET @H_OT_Hours = NULL
            SET @W_OT_Hours = Null
            
            --Hardik 14/05/2015 for Adding the Imported Week-off & Holiday OT Amount ---------
            If Exists (Select 1 From T0190_MONTHLY_PRESENT_IMPORT Where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_Id
                        And [Month] = Month(@Month_End_Date) And [Year] = Year(@Month_End_Date))
                Begin
                    Select  @M_OT_Hours = ISNULL(Over_Time,0), @W_OT_Hours = ISNULL(WO_OT_Hour,0) , @H_OT_Hours = ISNULL(HO_OT_Hour,0)
                    from    dbo.T0190_MONTHLY_PRESENT_IMPORT 
                    Where   Cmp_ID = @Cmp_ID And Emp_ID = @Emp_Id  And [Month] = Month(@Month_End_Date) And [Year] = Year(@Month_End_Date)                          
                End
            --Hardik 14/05/2015 for Adding the Imported Week-off & Holiday OT Amount ---------
            
            
            --SET @Emp_OT_Sec = @M_OT_Hours * 3600    
            --SET @Emp_WO_OT_Sec = @W_OT_Hours * 3600 --Hardik 29/11/2011
            --SET @Emp_HO_OT_Sec = @H_OT_Hours * 3600 --Hardik 29/11/2011
            
            -- changed by rohit on 29032017 for AIA case 
            SET @Emp_OT_Sec = case when isnull(@M_OT_Hours,0)= 0 THEN 0 ELSE dbo.F_Return_Sec(replace(@M_OT_Hours,'.',':')) end --* 3600    
            SET @Emp_WO_OT_Sec =  case when isnull(@W_OT_Hours,0)= 0 THEN 0 ELSE dbo.F_Return_Sec(replace(@W_OT_Hours,'.',':'))END   --* 3600 
            SET @Emp_HO_OT_Sec = case when isnull(@H_OT_Hours,0)= 0 THEN 0 ELSE dbo.F_Return_Sec(replace(@H_OT_Hours,'.',':'))END   --* 3600 
            
            SET @Is_PT = 0    
            SET @Is_Emp_PT = 0    
            SET @PT_Amount = 0    
            SET @PT_Calculated_Amount = 0    
            SET @LWF_Amount    =0    
            SET @LWF_App_Month  = ''    
            SET @Revenue_Amount   =0    
            SET @Revenue_On_Amount  = 0    
            SET @LWF_compare_month  =''
            SET @Lv_Salary_Effect_on_PT  =0    
            SET @PT_F_T_Limit = ''    
            SET @Fix_late_W_Days  = 0    
            SET @Fix_late_W_Hours  = ''    
            SET @Fix_late_W_Shift_Sec = 0     
            SET @Late_deduction_Days = 0    
            SET @Extra_Late_Deduction = 0    
            SET @Hour_Salary_Late  = 0    
            SET @Late_Basic_Amount  = 0    
            SET @Bonus_Amount = 0    
            SET @StrMonth='#' + cast(Month(@Month_End_Date) as varchar(2)) + '#' 
        
            SET @Emp_Part_Time =0 
            SET @Lv_Encash_Cal_On = ''    
            SET @Penalty_days_Early_Late  = 0
            SET @Hour_Salary_Early = 0
            
            SET @Is_Late_Slabwise  = 0
            SET @Is_Early_Slabwise  = 0
            SET @Late_Dedu_Type_inc  = 0
            SET @Early_Dedu_Type_inc = 0
            
            SET @Emp_WD_OT_Rate = 0
            SET @Emp_WO_OT_Rate = 0
            SET @Emp_HO_OT_Rate = 0
            
            SET @Arear_Day = 0  --Hardik 04/01/2012
            SET @Arear_Month = 0 --Hardik 04/01/2012
            SET @Arear_Year = 0 --Hardik 04/01/2012
            SET @Arear_Amount = 0 -- Hardik 04/01/2012
            SET @Dedu_Amount_Arear = 0 --Hardik 07/01/2012
            SET @Basic_Salary_Arear = 0
            SET @Gross_Salary_Arear = 0 --Hardik 07/01/2012
            SET @Salary_amount_Arear = 0 --Hardik 07/01/2012
            SET @Allow_Amount_Arear = 0 --Hardik 07/01/2012
            
            SET @Emp_WO_OT_Hours    = ''
            SET @Emp_HO_OT_Hours = ''
            SET @Settelement_Amount = 0
            
            SET @M_Cancel_weekOff = 0 --rohit 24112012
            SET @M_Cancel_Holiday = 0 --rohit 24112012 
            
            SET @Allow_Amount_Effect_only_Net=0 -- Rohit on 06-may-2013
            SET @Deduct_Amount_Effect_only_Net=0 -- rohit on 06-may-2013
            
            SET @Half_Day_Excepted_Count = 0
			SET @Half_Day_Excepted_Max_Count = 0
            SET @No_Holiday_Days = 0
        
        
            SET @Emp_OT_Hours_Var = NULL;
            SET @Emp_OT_Hours_Num = NULL;

            SET @Emp_WO_OT_Hours_Var = NULL;
            SET @Emp_WO_OT_Hours_Num = NULL;
            SET @Emp_HO_OT_Hours_Var = NULL;
            SET @Emp_HO_OT_Hours_Num = NULL;
            
            
            --Alpesh 23-Mar-2012 put this to get Branch_Id to get Salary_St_Date when Branches have diff Salary_St_date but chk for Mid Increment
            select  @Branch_ID = Branch_ID,@CUST_AUDIT = ISNULL(I.CUSTOMER_AUDIT,0)   --Change By Jaina 06-10-2016
            From    T0095_Increment I 
            inner join     
                    (
                        select max(Increment_ID) as Increment_ID 
                        from T0095_Increment    
                        where   Increment_Effective_date <= @Month_End_Date and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_id
                    ) Qry on I.Increment_ID = Qry.Increment_ID 
            Where I.Emp_ID = @Emp_ID 
            --End 
                    
            if @is_salary_cycle_emp_wise = 1
                begin
                    
                    SET @Salary_Cycle_id  = 0
                    
                    SELECT  @Salary_Cycle_id = salDate_id 
                    from    T0095_Emp_Salary_Cycle 
                    where   emp_id = @Emp_Id 
                            AND effective_date =(
                                        SELECT  MAX(effective_date) 
                                        from    T0095_Emp_Salary_Cycle 
                                        where   EMP_ID = @Emp_Id AND effective_date <=  @Month_End_Date
                                                )
                    
                    SELECT @Sal_St_Date = SALARY_ST_DATE FROM t0040_salary_cycle_master where tran_id = @Salary_Cycle_id
                    
                    ---Added by Hardik 16/08/2016 as if Sal Cycle is enabled for use of Vertical, sub vertical then Salary date 26 is not working
                    if @Sal_St_Date is NULL
                        BEGIN
                            SELECT  TOP 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) -- Comment and added By rohit on 11022013
                                    ,@CutoffDate_Salary =Cutoffdate_Salary -- Added by rohit on 09012014
                                    ,@Is_Cancel_Holiday_WO_HO_same_day = Is_Cancel_Holiday_WO_HO_same_day -- Added by nilesh patel on 19112015
                                    ,@Restrict_Present_Days = Restrict_Present_days
                            FROM    T0040_GENERAL_SETTING 
                            WHERE   cmp_ID = @cmp_ID  and Branch_ID = @Branch_ID and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@Month_End_Date and Cmp_ID = @Cmp_ID and Branch_ID = @Branch_ID) 

                        END
                    
                end
            else
                begin
                   If @Branch_ID is null
                        Begin 
                            SELECT  TOP 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) -- Comment and added By rohit on 11022013
                                    ,@CutoffDate_Salary =Cutoffdate_Salary -- Added by rohit on 09012014
                                    ,@Is_Cancel_Holiday_WO_HO_same_day = Is_Cancel_Holiday_WO_HO_same_day -- Added by nilesh patel on 19112015
                                    ,@Restrict_Present_Days = Restrict_Present_days
                            FROM    T0040_GENERAL_SETTING 
                            WHERE   cmp_ID = @cmp_ID  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@Month_End_Date and Cmp_ID = @Cmp_ID)    
                        End
                    ELSE
                        Begin
                            SELECT  @Sal_St_Date  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) -- Comment and added By rohit on 11022013
                                    ,@CutoffDate_Salary =Cutoffdate_Salary -- Added by rohit on 09012014
                                    ,@Is_Cancel_Holiday_WO_HO_same_day = Is_Cancel_Holiday_WO_HO_same_day -- Added by nilesh patel on 19112015
                                    ,@Restrict_Present_Days = Restrict_Present_days
                            FROM    T0040_GENERAL_SETTING 
                            WHERE   cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
                                    and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
                        END 
                    
                END 
            
            
                
            SET @manual_salary_period = isnull(@manual_salary_period,0) -- added by mitesh on 18072013
            if isnull(@Sal_St_Date,'') = ''    
                begin    
                    SET @Month_St_Date  = @Month_St_Date     
                    SET @Month_End_Date = @Month_End_Date    
                    SET @OutOf_Days = @OutOf_Days
                end     
            else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)= 1    
                BEGIN    
                    
                    SET @Month_St_Date  = @Month_St_Date     
                    SET @Month_End_Date = @Month_End_Date    
                    SET @OutOf_Days = @OutOf_Days              
                     
                END     
            else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
                begin    
                    -- Comment and added By rohit on 11022013
                    --SET @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Month_St_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Month_St_Date) )as varchar(10)) as smalldatetime)    
                    --SET @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
                    --SET @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1

                    --SET @Month_St_Date = @Sal_St_Date
                    --SET @Month_End_Date = @Sal_End_Date    
                      
                      
                    if @manual_salary_period = 0 
                        begin
                            SET @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Month_St_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Month_St_Date) )as varchar(10)) as smalldatetime)    
                            SET @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
                            SET @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
                       
                            SET @Month_St_Date = @Sal_St_Date
                            SET @Month_End_Date = @Sal_End_Date 
                        end 
                    else
                        begin
                            select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@Month_St_Date) and YEAR=year(@Month_St_Date)
                            SET @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
                           
                            SET @Month_St_Date = @Sal_St_Date
                            SET @Month_End_Date = @Sal_End_Date 
                        end   
                        -- Ended By rohit on 11022013
                  end
            
            
            IF EXISTS(SELECT EMP_ID FROM  T0200_MONTHLY_SALARY WHERE EMP_ID =@EMP_ID AND  Month_St_Date >= @Sal_End_Date)
                Begin
                    SET @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Month='+cast(MONTH(@Month_End_Date) as varchar)+', Year='+cast(year(@Month_End_Date) as varchar)
                    exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Salary','@@Next Month salary Exists@@',@LogDesc,1,'' ,@Sal_Generate_Date          
                    --Raiserror('Next Month salary Exists',16,2)
                    GOTO NEXT_EMP
                End

            
            If Exists(Select Pf_Challan_Id From dbo.T0220_Pf_Challan Where Cmp_Id=@Cmp_Id And Month=Month(@Month_End_Date) And Year = Year(@Month_End_Date) And CHARINDEX('#'+ Cast(@Branch_ID As VARCHAR(18)) +'','#' + Branch_ID_Multi) > 0)
                Begin
                    RAISERROR ('@@PF Challan Exists@@', -- Message text.
                                16, -- Severity.
                                1   -- State.
                                );
                    GOTO NEXT_EMP
                End
            If Exists(Select Esic_Challan_Id From dbo.T0220_ESIC_Challan Where Cmp_Id=@Cmp_Id And Month=Month(@Month_End_Date) And Year = Year(@Month_End_Date) And CHARINDEX('#'+ Cast(@Branch_ID As VARCHAR(18)) +'','#' + Branch_ID_Multi) > 0)
                Begin
                    RAISERROR ('@@ESIC Challan Exists@@', -- Message text.
                                16, -- Severity.
                                1   -- State.
                                );
                    GOTO NEXT_EMP
                End
                --added by chetan 27122017
            If Exists(Select  Challan_Id From dbo.T0220_TDS_CHALLAN Where Cmp_Id=@Cmp_Id And Month=Month(@Month_End_Date) And Year = Year(@Month_End_Date))
                Begin
				
                    RAISERROR ('@@TDS Challan Exists@@', -- Message text.
                                16, -- Severity.
                                1   -- State.
                                );
                    GOTO NEXT_EMP
                End
                If Exists(Select Challan_Id From dbo.T0220_PT_CHALLAN Where Cmp_Id=@Cmp_Id And Month=Month(@Month_End_Date) And Year = Year(@Month_End_Date) And CHARINDEX('#'+ Cast(@Branch_ID As VARCHAR(18)) +'','#' + Branch_ID_Multi) > 0)
                Begin
                    RAISERROR ('@@PT Challan Exists@@', -- Message text.
                                16, -- Severity.
                                1   -- State.
                                );
                    GOTO NEXT_EMP
                End
            --if    exists (select * from [tempdb].dbo.sysobjects where name like '#Att_Muster_with_shift' )        
            --      begin
            --          drop table #Att_Muster_with_shift
            --      end
                        
             
            
            SET @Absent_after_Cutoff_date =0 
            

            --Optimized for Performance
            if exists(select 1 from T0200_MONTHLY_SALARY where MONTH(Month_End_Date) =  month(dateadd(m,-1,@Month_End_Date)) 
                and year(Month_End_Date) =  Year( dateadd(m,-1,@Month_End_Date)) and Emp_ID=@Emp_Id 
                and cutoff_date <> Month_End_Date)  
                BEGIN
                    
                    SET @temp_previous_month_end_date = dateadd(dd,-1,@Month_St_Date)
                    select  @last_Month_Cutoffdate= dateadd(dd,1,Cutoff_Date) 
                    from    T0200_MONTHLY_SALARY 
                    where   MONTH(Month_End_Date) =  month(dateadd(m,-1,@Month_End_Date)) and year(Month_End_Date) =  Year( dateadd(m,-1,@Month_End_Date)) 
                            and Emp_ID=@Emp_Id 
                    
                    exec SP_RPT_EMP_ATTENDANCE_MUSTER_GET @Cmp_ID=@cmp_id,@From_Date=@last_Month_Cutoffdate,@To_Date=@temp_previous_month_end_date,@Branch_ID=@Branch_ID,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint=@Emp_Id,@Report_For='Absent_Cutoff'
                    
                    IF @Is_Consider_LWP_In_Same_Month = 1 --- Added by Hardik 20/02/2019 for Havmor
						SELECT @Absent_after_Cutoff_date =(isnull(sum(a_days),0)*(-1)) 
						FROM #Att_Muster_with_shift 
						WHERE Emp_Id=@Emp_Id And 
								Not Exists (Select 1 From T0210_LWP_Considered_Same_Salary_Cutoff LWP Where LWP.Emp_Id = @Emp_Id And #Att_Muster_with_shift.For_Date = LWP.For_Date)
					ELSE
						SELECT @Absent_after_Cutoff_date =(isnull(sum(a_days),0)*(-1)) 
						FROM #Att_Muster_with_shift 
						WHERE Emp_Id=@Emp_Id


                END
            
            IF ISNULL(@CutoffDate_Salary,'') <> ''  -- Added by rohit on 09012014
            BEGIN
                SET @CutoffDate_Salary =  cast(cast(day(@CutoffDate_Salary)as varchar(5)) + '-' + cast(datename(mm,@Month_St_Date) as varchar(10)) + '-' +  cast(year(@Month_St_Date )as varchar(10)) as smalldatetime)    
                SET @Is_Cutoff_Salary =1 --Added by Hardik 02/02/2016
                --Added by Jaina 16-12-2017
				if Month(@Month_St_Date) = 1
					Begin
						set @Cutoff_Start_Date = cast(cast(day(@CutoffDate_Salary+1)as varchar(5)) + '-' + cast(datename(mm,@Month_St_Date-1) as varchar(10)) + '-' +  cast(year(@Month_St_Date) - 1 as varchar(10)) as smalldatetime)    
					End
				Else
					Begin
						set @Cutoff_Start_Date = cast(cast(day(@CutoffDate_Salary+1)as varchar(5)) + '-' + cast(datename(mm,@Month_St_Date-1) as varchar(10)) + '-' +  cast(year(@Month_St_Date )as varchar(10)) as smalldatetime)    
					End
                --If OBJECT_ID('tempdb..##Att_Muster1') IS NOT NULL 
                --BEGIN
                --  DROP TABLE ##Att_Muster1
                --END
        
                        
                    
                --exec SP_EMP_SALARY_RECORD_GET_Manually @Cmp_ID=@Cmp_ID,@From_Date=@CutoffDate_Salary,@To_Date=@Month_End_Date ,@Branch_ID=0,@Cat_ID='',@Grd_ID='',@Type_ID=0,@Dept_ID='',@Desig_ID='',@Emp_ID =@Emp_Id,@Constraint='',@Salary_Status='All',@Salary_Cycle_id=0,@Branch_Constraint='',@Segment_ID='',@Vertical='',@SubVertical='',@SubBranch='',@CutoffDate_Salary=1
            
                declare @temp_cutoff as datetime 
                SET @temp_cutoff = dateadd(dd,1,@CutoffDate_Salary)
            
                EXEC SP_RPT_EMP_ATTENDANCE_MANUAL_SALARY_DAYS @Cmp_ID, @temp_cutoff, @Month_End_Date, 0, '', 0, '', '', '', @Emp_Id, '','','','',0,'','','','',1    
                select @Present_AfterCuttoff = isnull(Total_Present,0),@Weekoff_AfterCuttoff=isnull(WO,0),@Holiday_AfterCuttoff = isnull(HO,0) from ##Att_Muster1 where Cmp_ID=@Cmp_ID and Emp_Id=@Emp_Id                           
            end

                

            if isnull(@CutoffDate_Salary,'')=''
            begin
                SET @CutoffDate_Salary = @Month_End_Date
            end
                            
            SET @Salary_Depends_on_Production=0
            SET @Grd_Id=0
            SET @Production_Gross_Salary = 0
        
            
            Select @Alpha_Emp_Code=Alpha_Emp_Code, @Left_Date = Emp_Left_Date, @Join_Date = Date_Of_Join, @Salary_Depends_on_Production = Salary_Depends_on_Production
            from T0080_EMP_MASTER where Emp_ID = @Emp_Id    
            
            --ADDED BY NIMESH ON 23-JUL-2016 
            IF NOT (@Left_Date  BETWEEN @Month_St_Date AND @Month_End_Date)
                SET @Left_Date  = NULL  --LEFT DATE SHOULD NOT BE CONSIDRED IF USER PROCESS BACK DATED SALARY
            
            ----Alpesh 09-May-2012   --Updated on 1-Jan-2012
            --IF EXISTS(SELECT EMP_ID FROM  T0200_MONTHLY_SALARY WHERE Cmp_ID=@Cmp_ID and EMP_ID=@EMP_ID AND Month_St_Date=@Month_St_Date and Month_End_Date=@Month_End_Date)
            IF EXISTS(SELECT EMP_ID FROM  T0200_MONTHLY_SALARY WHERE Cmp_ID=@Cmp_ID and EMP_ID=@EMP_ID AND Month(Month_End_Date)=Month(@Month_End_Date) and YEAR(Month_End_Date)=YEAR(@Month_End_Date))
                Begin           
                    SELECT @M_Sal_Tran_ID=Sal_Tran_ID FROM  T0200_MONTHLY_SALARY WHERE Cmp_ID=@Cmp_ID and EMP_ID=@EMP_ID AND Month(Month_End_Date)=Month(@Month_End_Date) and YEAR(Month_End_Date)=YEAR(@Month_End_Date)
                End  
            ---- End ----
                   
                          
          
            If @M_Sal_Tran_ID > 0     
                Begin    
                    SET @Sal_Tran_ID  = @M_Sal_Tran_ID     

                    Delete FROM T0210_Monthly_Leave_Detail   Where emp_id = @Emp_id and Sal_Tran_ID = @Sal_Tran_ID     
                    Delete FROM T0210_MONTHLY_AD_DETAIL    Where emp_id = @emp_id and Sal_Tran_ID = @Sal_Tran_ID     
                    Delete FROM T0210_MONTHLY_LOAN_PAYMENT   Where Sal_Tran_ID = @Sal_Tran_ID    
                    --Delete FROM T0210_MONTHLY_CLAIM_PAYMENT   Where Sal_Tran_ID = @Sal_Tran_ID  
                    DELETE FROM T0210_Monthly_Salary_Slip_Gradecount where Sal_tran_Id=@SAL_TRAN_ID --Added by Ramiz 19112015    
                    DELETE FROM T0210_PAYSLIP_DATA    WHERE SAL_TRAN_ID = @SAL_TRAN_ID  
                    DELETE FROM t0100_Anual_bonus    WHERE SAL_TRAN_ID = @SAL_TRAN_ID  
                    delete from t0200_monthly_salary_leave  WHERE SAL_TRAN_ID = @SAL_TRAN_ID  
                    Delete FROM T0140_MONTHLY_LATEMARK_TRANSACTION  WHERE SAL_TRAN_ID = @SAL_TRAN_ID  
                    Delete FROM T0140_MONTHLY_LATEMARK_DESIGNATION  WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
                    Delete FROM  T0160_Late_Early_Validation  WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
					Delete T0210_LWP_Considered_Same_Salary_Cutoff Where Sal_tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id --Added by Hardik 20/02/2019 for Havmor
                    Delete FROM T0140_MONTHLY_EARLYMARK_TRANSACTION  WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
					Select @Sal_Receipt_No =  Sal_Receipt_No From T0200_MONTHLY_SALARY Where Sal_Tran_ID =@Sal_Tran_ID    
                End      
            Else    
                Begin    
                    
                    Select @Sal_Tran_Id =  Isnull(max(Sal_Tran_Id),0)  + 1   From T0200_MONTHLY_SALARY    
                    
                    Select  @Sal_Receipt_No =  isnull(max(sal_Receipt_No),0)  + 1  
                    From    T0200_MONTHLY_SALARY Where Month(Month_St_Date) = Month(@Month_St_DAte)     
                            and YEar(Month_St_Date) = Year(@Month_End_Date) and Cmp_ID= @Cmp_ID          
                    
                    --added by mitesh on 30/10/2012
                    --IF EXISTS (SELECT 1 FROM T0210_MONTHLY_LEAVE_DETAIL WHERE EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID  and ISNULL(Sal_Tran_ID,0) <> @Sal_Tran_ID )
                        BEGIN
                            DELETE FROM T0210_MONTHLY_LEAVE_DETAIL   WHERE EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID   AND CMP_ID=@CMP_ID  and isnull(Sal_Tran_ID,0) <> @Sal_Tran_ID 
                            DELETE FROM T0210_MONTHLY_AD_DETAIL    WHERE EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID   AND CMP_ID=@CMP_ID  and isnull(Sal_Tran_ID,0) <> @Sal_Tran_ID 
                            DELETE from dbo.T0210_MONTHLY_AD_DETAIL    WHERE EMP_ID = @EMP_ID AND CMP_ID=@CMP_ID and isnull(Sal_Tran_ID,0) <> @Sal_Tran_ID And MONTH(To_date)=MONTH(@Month_End_Date) And Year(To_date)=Year(@Month_End_Date)
                            DELETE FROM T0210_MONTHLY_LOAN_PAYMENT   WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID   AND CMP_ID=@CMP_ID  and isnull(Sal_Tran_ID,0) <> @Sal_Tran_ID 
                            --DELETE FROM T0210_MONTHLY_CLAIM_PAYMENT   WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID  AND CMP_ID=@CMP_ID  and isnull(Sal_Tran_ID,0) <> @Sal_Tran_ID 
                            DELETE FROM T0210_PAYSLIP_DATA    WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID  AND CMP_ID=@CMP_ID  and isnull(Sal_Tran_ID,0) <> @Sal_Tran_ID 
                            DELETE FROM T0210_MONTHLY_LOAN_PAYMENT WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID  AND CMP_ID=@CMP_ID and isnull(Sal_Tran_ID,0) <> @Sal_Tran_ID 
                            --Delete FROM T0140_MONTHLY_LATEMARK_TRANSACTION  WHERE EMP_ID = @EMP_ID AND CMP_ID=@CMP_ID and isnull(Sal_Tran_ID,0) <> @Sal_Tran_ID And MONTH(To_date)=MONTH(@Month_End_Date) And Year(To_date)=Year(@Month_End_Date)
                        END
                    --DELETE FROM t0100_Anual_bonus    WHERE temp_Sal_Tran_ID = @SAL_TRAN_ID  and Sal_Tran_ID <> @Sal_Tran_ID 
                    --DELETE from t0200_monthly_salary_leave  WHERE temp_Sal_Tran_ID = @SAL_TRAN_ID  and Sal_Tran_ID <> @Sal_Tran_ID 
                    --added by mitesh on 30/10/2012
                    
                    --Ankit 04042016
                    DELETE FROM dbo.T0200_MONTHLY_SALARY_LEAVE  WHERE EMP_ID = @EMP_ID AND CMP_ID=@CMP_ID AND ISNULL(Sal_Tran_ID,0) <> @Sal_Tran_ID AND MONTH(L_Month_End_Date)=MONTH(@Month_End_Date) AND YEAR(L_Month_End_Date)=YEAR(@Month_End_Date)
                    --Ankit 04042016
                End  
                
                   
                SET @temp_increment_id = 0;
                SET @temp_increment_Effdate = NULL;
                  
                insert into #Mid_Increment (Increment_effective_Date,Emp_ID,Increment_id)
                select  EI.Increment_effective_Date , EI.Emp_ID, EI.Increment_ID 
                from    T0095_Increment EI 
                where   Increment_ID in (select Max(TI.Increment_ID) Increment_Id from t0095_increment TI inner join
                        (Select Max(Increment_Effective_Date) as Increment_Effective_Date from T0095_Increment 
            
                        Where Increment_effective_Date <= @Month_St_Date And Cmp_ID=@Cmp_Id And Emp_ID = @Emp_Id 
                        and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation') new_inc
                    on Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
                    Where TI.Increment_effective_Date <= @Month_St_Date And Emp_ID = @Emp_Id and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation')
                

                
            /*    (select max(Increment_ID) as Increment_ID 
            
                    from T0095_Increment  where Increment_Effective_date <= @Month_St_Date  
                    and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' ) and Emp_ID = @Emp_Id and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' 
                  
            */
                 select @temp_increment_id = EI.Increment_ID 
                 from T0095_Increment EI
                 where Increment_ID in 
                     (select Max(TI.Increment_ID) Increment_Id from t0095_increment TI inner join
                    (Select Max(Increment_Effective_Date) as Increment_Effective_Date from T0095_Increment 
                        Where Increment_effective_Date <= @Month_St_Date And Cmp_ID=@Cmp_Id And Emp_ID = @Emp_Id 
                        and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation') new_inc
                    on Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
                    Where TI.Increment_effective_Date <= @Month_St_Date And Emp_ID = @Emp_Id and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation')
            
                     
                /*       (select max(Increment_ID) as Increment_ID 
                         from T0095_Increment  where Increment_Effective_date <= @Month_St_Date  and Cmp_ID = @Cmp_ID 
                         and Emp_ID = @Emp_Id and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' ) and Emp_ID = @Emp_Id   
                         and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' 

                */
            
            
                  
                insert into #Mid_Increment (Increment_effective_Date,Emp_ID,Increment_id)
                select Increment_effective_Date , Emp_ID, Increment_ID 
                from T0095_Increment 
                where Emp_ID = @Emp_Id and Increment_Effective_date >= @Month_St_Date 
                and Increment_Effective_date <= @Month_End_Date and Increment_ID <> @temp_increment_id --And Increment_Effective_Date <> @temp_increment_Effdate
                and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' 
                  
                
                -- insert into #Mid_Increment (Increment_effective_Date,Emp_ID,Increment_id)
                -- select EI.Increment_effective_Date , EI.Emp_ID, EI.Increment_ID from T0095_Increment EI where Increment_Effective_Date in (select max(Increment_effective_Date) as Increment_effective_Date from T0095_Increment  where Increment_Effective_date <= @Month_St_Date         and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' ) and Emp_ID = @Emp_Id and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' 

                --select @temp_increment_id = EI.Increment_ID from T0095_Increment EI where Increment_Effective_Date in (select max(Increment_effective_Date) as Increment_effective_Date from T0095_Increment  where Increment_Effective_date <= @Month_St_Date  and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' ) and Emp_ID = @Emp_Id   and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' 


                -- insert into #Mid_Increment (Increment_effective_Date,Emp_ID,Increment_id)
                -- select Increment_effective_Date , Emp_ID, Increment_ID from T0095_Increment where Emp_ID = @Emp_Id and Increment_Effective_date >= @Month_St_Date and Increment_Effective_date <= @Month_End_Date and Increment_ID <> @temp_increment_id and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' 
                

                SET @total_count_all_incremnet = 0  
                SET @mid_gross_Amount = 0
                SET @mid_basic_Amount = 0
                SET @mid_salary_Amount = 0
                SET @mid_Sal_Cal_Days = 0
                SET @mid_Present_Days = 0
                SET @mid_Absent_Days = 0
                SET @mid_Holiday_Days = 0
                SET @mid_WeekOff_Days = 0
                SET @mid_cancel_holiday = 0
                SET @mid_cancel_weekoff = 0
                SET @mid_total_leave_days = 0
                SET @mid_paid_leave_days = 0
                SET @mid_Actual_Working_Hours = ''
                SET @mid_Working_Hours = ''
                SET @mid_Outof_Hours  = ''
                SET @mid_OT_Hours    = 0
                SET @mid_Total_Hours    = ''
                SET @mid_Shift_Day_Sec   = 0
                SET @mid_Shift_Day_Hour = ''

                SET @mid_Day_Salary  = 0
                SET @mid_Hour_Salary     = 0
                SET @mid_Salary_Amount   = 0
                SET @mid_Allow_Amount    = 0
                SET @mid_OT_Amount   = 0
                SET @mid_Other_Allow_Amount  = 0

                SET @mid_Dedu_Amount     = 0
                SET @mid_Loan_Amount     = 0
                SET @mid_Loan_Intrest_Amount     = 0
                SET @mid_Advance_Amount  = 0
                SET @mid_Other_Dedu_Amount   = 0
                SET @mid_Total_Dedu_Amount   = 0
                SET @mid_Due_Loan_Amount     = 0
                SET @mid_Net_Amount  = 0
                SET @mid_Actually_Gross_Salary   = 0
                SET @mid_PT_Amount   = 0
                SET @mid_PT_Calculated_Amount    = 0
                SET @mid_Total_Claim_Amount  = 0
                SET @mid_M_OT_Hours  = 0
                SET @mid_M_Adv_Amount    = 0
                SET @mid_M_Loan_Amount   = 0
                SET @mid_M_IT_Tax    = 0
                SET @mid_LWF_Amount  = 0
                SET @mid_Revenue_Amount  = 0
                SET @mid_PT_F_T_Limit   = ''    
                SET @mid_Leave_Salary_Amount     = 0
                SET @mid_Late_Sec    = 0
                SET @mid_Late_Dedu_Amount    = 0
                SET @mid_Late_Extra_Dedu_Amount  = 0
                SET @mid_Late_Days   = 0
                SET @mid_Short_Fall_Days     = 0
                SET @mid_Short_Fall_Dedu_Amount  = 0
                SET @mid_Gratuity_Amount     = 0
                SET @mid_Is_FNF  = 0
                SET @mid_Bonus_Amount    = 0
                SET @mid_Incentive_Amount    = 0
                SET @mid_Trav_Earn_Amount    = 0
                SET @mid_Cust_Res_Earn_Amount    = 0
                SET @mid_Trav_Rec_Amount     = 0
                SET @mid_Mobile_Rec_Amount   = 0
                SET @mid_Cust_Res_Rec_Amount     = 0
                SET @mid_Uniform_Rec_Amount  = 0
                SET @mid_I_Card_Rec_Amount   = 0
                SET @mid_Excess_Salary_Rec_Amount    = 0
                SET @mid_Salary_Status   = ''
                SET @mid_Pre_Month_Net_Salary    = 0
                SET @mid_IT_M_ED_Cess_Amount     = 0
                SET @mid_IT_M_Surcharge_Amount   = 0
                SET @mid_Early_Sec  = 0 
                SET @mid_Early_Dedu_Amount  = 0 
                SET @mid_Early_Extra_Dedu_Amount    = 0 
                SET @mid_Early_Days = 0 
                SET @mid_Deficit_Sec    = 0 
                SET @mid_Deficit_Dedu_Amount    = 0 
                SET @mid_Deficit_Extra_Dedu_Amount  = 0 
                SET @mid_Deficit_Days   = 0 
                SET @mid_Total_Earning_Fraction  = 0        
                SET @mid_Late_Early_Penalty_days  = 0   
                SET @mid_M_WO_OT_Hours  = 0     
                SET @mid_M_HO_OT_Hours  = 0 
                SET @mid_M_WO_OT_Amount = 0 
                SET @mid_M_HO_OT_Amount = 0 
                SET @mid_M_Working_Days = 0

                SET @tmp_Month_St_Date = @Month_St_Date
                SET @tmp_Month_End_Date = @Month_End_Date
                SET @increment_Month = 0
                SET @total_Present_Days = 0
                SET @DayRate_WO_Cancel = 0
                
                
                SET @mid_present_on_holiday = 0
                SET @Rate_Of_National_Holiday =0  
                SET @is_present_on_holiday = 0
                Set @mid_OT_Adj_Days = 0

                Set @mid_OT_Adj_Days = 0
                set @mid_OT_Adj_Hours = ''  --added By Jimit 20072018
                    
                
                select top 1  @first_Month_End_Date = Increment_effective_Date  from T0095_Increment 
                where Emp_ID = @Emp_Id and Increment_Effective_date >= @Month_St_Date 
                and Increment_Effective_date <= @Month_End_Date     
                and Increment_ID <> @temp_increment_id 
                and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' 
				Order By Increment_effective_Date Asc
                
                
                
                select @increment_Month = COUNT(1)  from T0095_Increment where Emp_ID = @Emp_Id and Increment_Effective_date >= @Month_St_Date and Increment_Effective_date <= @Month_End_Date and Increment_ID <> @temp_increment_id and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' 
                
                
                select @total_count_all_incremnet  = count(*) from #Mid_Increment
                
                ---Added Condition by Hardik 03/12/2015 as Same Date Increment in showing twice entry
                Select @total_count_all_incremnet = Count(M.Increment_Id) from #Mid_Increment M Inner Join 
                (Select Emp_Id,Max(Increment_Id) as Increment_Id,Increment_Effective_date From #Mid_Increment group by Emp_Id,Increment_Effective_date) Qry
                on M.Emp_Id = Qry.Emp_Id And M.Increment_Id = Qry.Increment_Id  
                
                SET @cnt = 0
				SET @CutoffDate_Salary_temp = @CutoffDate_Salary
                    
                                
                declare curMDI cursor for                 
                ---Added Condition by Hardik 03/12/2015 as Same Date Increment in showing twice entry
                Select M.Increment_ID,M.Increment_effective_Date from #Mid_Increment M Inner Join 
                (Select Emp_Id,Max(Increment_Id) as Increment_Id,Increment_Effective_date From #Mid_Increment group by Emp_Id,Increment_Effective_date) Qry
                on M.Emp_Id = Qry.Emp_Id And M.Increment_Id = Qry.Increment_Id  
                Order By M.Increment_effective_Date
                --select Increment_ID,Increment_effective_Date from #Mid_Increment
                open curMDI                      
                fetch next from curMDI into @Increment_ID,@Month_End_Date
                                   
                WHILE @@fetch_status = 0                    
                BEGIN
                    SET @cnt = @cnt + 1
                    
                    if @total_count_all_incremnet > 1 
                        begin
                            if @cnt = 1 
                                begin   
                                    if @first_Month_End_Date <> '' 
                                        SET @Month_End_Date =  dateadd(d,-1,@first_Month_End_Date) 
                                    else
                                        SET @Month_End_Date = @tmp_Month_End_Date
                                end     
                            else if isnull(@increment_Month ,0) = @cnt -1 
                                SET @Month_End_Date = @tmp_Month_End_Date
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
                            SET @Month_St_Date = @tmp_Month_St_Date
                            SET @Month_End_Date = @tmp_Month_End_Date                       
                        end     
                    
                        
                        
                    --SET @CutoffDate_Salary =@Month_End_Date -- Added by rohit For Mid Increment Case on 09052015
                    --SET @CutoffDate_Salary_temp = @CutoffDate_Salary -- Added by nilesh patel on 04032016 For Mid Increment                       
                    if @month_end_date < @CutoffDate_Salary_temp --Change On 07042016 by Sumit as per the suggestion from Sr.Team (Rohit bhai,Nimesh Bhai and Hardik bhai)
                        begin   
                            SET @CutoffDate_Salary =@Month_End_Date -- Added by rohit For Mid Increment Case on 09052015
                        end                 
                    else
                        begin
                            SET @CutoffDate_Salary =@CutoffDate_Salary_temp 
                        end
                    
                    
                    If @cnt > 1 
						BEGIN
		                       SET @Other_allow_Amount = 0
							   SET @M_ADV_AMOUNT = 0 --Added By Jimit 13052019 as there is case at Gallops in that Advanced Amopunt is deducting twice in case of Mid Increment 
							   SET @Advance_Amount = 0 --Added By Jimit 13052019 as there is case at Gallops in that Advanced Amopunt is deducting twice in case of Mid Increment 
						END   

                    --@Increment_ID = Increment_ID ,
                        
                    select  @Wages_Type = Wages_type,@SalaryBasis = Salary_Basis_On    
                    ,@Emp_OT = Emp_OT , @Payment_Mode = Payment_Mode ,    
                    @Actual_Gross_Salary = isnull(Gross_Salary,0) ,@Basic_Salary = isnull(Basic_Salary,0),    
                    @Emp_OT_Min_Limit = Emp_OT_Min_Limit , @Emp_OT_Max_Limit = Emp_OT_Max_Limit, @Emp_Part_Time = isnull(Emp_Part_Time,0) ,        
                    @Branch_ID = Branch_ID,    
                    --@Is_Emp_PT =isnull(Emp_PT,0),
                    @Fix_Salary=isnull(Emp_Fix_Salary,0)    
                    ,@Late_Dedu_Type_inc  = isnull(Late_Dedu_Type,'') , @Early_Dedu_Type_inc = isnull(Early_Dedu_Type,'')
                    ,@Is_Early_Mark = isnull(Emp_Early_Mark,0),@Is_late_Mark = isnull(Emp_Late_mark,0)
                    ,@Emp_WD_OT_Rate = isnull(Emp_WeekDay_OT_Rate,0) , @Emp_WO_OT_Rate = isnull(Emp_WeekOff_OT_Rate,0) , @Emp_HO_OT_Rate = isnull(Emp_Holiday_OT_Rate,0)
                    ,@Monthly_Deficit_Adjust_OT_Hrs = Isnull(Monthly_Deficit_Adjust_OT_Hrs,0)
                    --,@FIX_OT_HOUR_RATE_WD = isnull(Fix_OT_Hour_Rate_WD,0)    --Added by Jaina 15-03-2017
                    --,@FIX_OT_HOUR_RATE_WO_HO = ISNULL(Fix_OT_Hour_Rate_WO_HO,0) --Added by Jaina 15-03-2017
                    ,@SEGMENT_ID = ISNULL(SEGMENT_ID,0)
                    From T0095_Increment I 
                    INNER JOIN  --Commented and New Code Added By Ramiz on 12/12/2017
                            ( SELECT MAX(I2.INCREMENT_ID) AS INCREMENT_ID, I2.EMP_ID 
                                FROM T0095_INCREMENT I2 
                                    INNER JOIN 
                                    (
                                            SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
                                            FROM T0095_INCREMENT I3
                                            WHERE I3.Increment_effective_Date <= @Month_End_Date and I3.Cmp_ID = @Cmp_ID and I3.Increment_Type <> 'Transfer' and I3.Increment_Type <> 'Deputation' AND I3.EMP_ID = @Emp_ID
                                            GROUP BY I3.EMP_ID  
                                        ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID 
                               WHERE I2.INCREMENT_EFFECTIVE_DATE <= @Month_End_Date and I2.Cmp_ID = @Cmp_ID and I2.Increment_Type <> 'Transfer' and I2.Increment_Type <> 'Deputation'
                               GROUP BY I2.emp_ID  
                            ) Qry on    I.Emp_ID = Qry.Emp_ID   and I.Increment_ID = Qry.Increment_ID 
                    WHERE I.CMP_ID = @Cmp_ID AND I.EMP_ID = @Emp_ID 
                    
                
                    if(ISNULL(@Fix_Salary,0)=1)  -- Added by Rajput on 03012017 ( INDUCTOTHERM CLIENT ISSUE) ISSUE WAS AREAR AMOUNT COME IN FIXED SALARY
                        set @Absent_after_Cutoff_date = 0
                
                    
                    --inner join     
                    -- ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment    
                    -- where Increment_Effective_date <= @Month_End_Date    
                    -- and Cmp_ID = @Cmp_ID and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation'   
                    -- group by emp_ID) Qry on    
                    -- I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID    
                    --Where I.Emp_ID = @Emp_ID    
                    
                  --Commented and New Code Added By Ramiz on 12/12/2017
                    SELECT @Branch_ID = Branch_ID    ,@Grd_Id=I.Grd_ID
                         ,@Is_Emp_PT =isnull(Emp_PT,0)      --Added By Jimit 25052018 Employee PT Applicable in Transfer then in salary not deduct PT amount due to transfer case (WCL)     
						 ,@FIX_OT_HOUR_RATE_WD = isnull(Fix_OT_Hour_Rate_WD,0)   --Added by Jimit 06022019   take fixed rate from increment case from transfer or deputation case (Kich)
						,@FIX_OT_HOUR_RATE_WO_HO = ISNULL(Fix_OT_Hour_Rate_WO_HO,0) --Added by Jimit 06022019
					From T0095_Increment I 
                    INNER JOIN  --Commented and New Code Added By Ramiz on 12/12/2017
                            ( SELECT MAX(I2.INCREMENT_ID) AS INCREMENT_ID, I2.EMP_ID 
                                FROM T0095_INCREMENT I2 
                                    INNER JOIN 
                                    (
                                            SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
                                            FROM T0095_INCREMENT I3
                                            WHERE I3.Increment_effective_Date <= @Month_End_Date and I3.Cmp_ID = @Cmp_ID
                                            GROUP BY I3.EMP_ID  
                                        ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID 
                               WHERE I2.INCREMENT_EFFECTIVE_DATE <= @Month_End_Date and I2.Cmp_ID = @Cmp_ID
                               GROUP BY I2.emp_ID  
                            ) Qry on    I.Emp_ID = Qry.Emp_ID   and I.Increment_ID = Qry.Increment_ID 
                    WHERE I.CMP_ID = @Cmp_ID AND I.EMP_ID = @Emp_ID
                    --inner join     
                    -- ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment    
                    -- where Increment_Effective_date <= @Month_End_Date    
                    -- and Cmp_ID = @Cmp_ID 
                    -- group by emp_ID) Qry on    
                    -- I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID    
                    --Where I.Emp_ID = @Emp_ID    

                    --Added by Hardik 10/04/2015 for Samarth Diaomond
                    If Isnull(@Salary_Depends_on_Production,0) = 1 and Isnull(@Basic_Salary,0)=0
                        BEGIN
                            DECLARE @Basic_Percentage as NUMERIC(18, 4)
                            DECLARE @Basic_Calc_On as varchar(50)
                            
                            Select @Basic_Percentage = Basic_Percentage, @Basic_Calc_On = Basic_Calc_On from T0040_GRADE_MASTER where Grd_ID=@Grd_Id
                            Select @Production_Gross_Salary = Gross_Amount from T0050_Production_Details_Import where Employee_ID = @Emp_id and Production_Month = Month(@Month_End_Date) And Production_Year=Year(@Month_End_Date)
                            
                            If @Basic_Percentage > 0 and @Production_Gross_Salary >0 And @Basic_Calc_On = 'Gross' 
                                Begin
                                    SET @Basic_Salary = @Production_Gross_Salary * @Basic_Percentage / 100
                                    SET @Gross_Salary = @Production_Gross_Salary
                                End
                        END
                    
                    IF EXISTS(SELECT 1 FROM  T0250_MONTHLY_LOCK_INFORMATION WHERE MONTH =  MONTH(@Month_End_Date) and YEAR =  year(@Month_End_Date) and Cmp_ID = @CMP_ID and (Branch_ID = isnull(@Branch_ID,0) or Branch_ID = 0)) and (@total_count_all_incremnet = 1 or @cnt <> 1)  -- @cnt condition added by Hardik 01/09/2015 as if salary cycle is 26 to 25 and increment given on 01st then month lock error is coming
                        Begin
                            SET @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Month='+cast(MONTH(@Month_End_Date) as varchar)+', Year='+cast(year(@Month_End_Date) as varchar)
                            exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Salary','Month Lock',@LogDesc,1,'',@Sal_Generate_Date
                            --Raiserror('Month Lock',16,2)
                            CLOSE curMDI;
          DEALLOCATE curMDI;
                            GOTO NEXT_EMP
                        End     
                        
    
                    --Hardik 16/10/2013
                    SET @Allowed_Full_WeekOff_MidJoining_DayRate = 0
                    SET @Allowed_Full_WeekOff_MidJoining = 0
                    --Sumit 04/06/2016
                    SET @Allowed_Full_WeekOff_MidLeft_DayRate = 0
                    SET @Allowed_Full_WeekOff_MidLeft = 0
                                        
                     
                    select @ExOTSetting = ExOT_Setting,@Inc_Weekoff = Inc_Weekoff,@Late_Adj_Day = isnull(Late_Adj_Day,0)    
                    ,@OT_Min_Limit = OT_APP_LIMIT ,@OT_Max_Limit = Isnull(OT_Max_Limit,'00:00')    
                    ,@Is_OT_Inc_Salary = isnull(OT_Inc_Salary,0)     
                    ,@Is_Daily_OT = Is_Daily_OT     
                    ,@Is_Cancel_Holiday = Is_Cancel_Holiday    
                    ,@Is_Cancel_Weekoff = Is_Cancel_Weekoff    
                    ,@Fix_OT_Shift_Hours = ot_Fix_Shift_Hours    
                    ,@Fix_OT_Work_Days = isnull(OT_fiX_Work_Day,0)    
                    ,@Is_PT = isnull(Is_PT,0) ,@Lv_Salary_Effect_on_PT = Lv_Salary_Effect_on_PT   
                    ,@LWF_Amount = LWF_Amount , @LWF_App_Month = LWF_Month,@Lv_Encash_Cal_On = Lv_Encash_Cal_On    
                    ,@Revenue_amount = Revenue_amount , @Revenue_on_Amount =Revenue_on_Amount ,@Wages_Amount =isnull(Wages_amount ,0)   
                    ,@Sal_Fix_Days = Sal_Fix_Days,@Inc_Holiday = isnull(Inc_Holiday,0),@Is_Zero_Day_Salary=isnull(Is_Zero_Day_Salary,0),@Is_Negative_Ot=Isnull(Is_Negative_Ot,0)
                    ,@IS_ROUNDING = Isnull(AD_Rounding,1)
                    ,@Is_OT_Auto_Calc = isnull(Is_OT_Auto_Calc,0),@Is_Zero_Basic_Salary = isnull(Is_Zero_Basic_Salary  ,0)
                    ,@Fix_late_W_Hours = late_fix_Shift_Hours,@Fix_late_W_Days = late_Fix_Work_Days
                    ,@Is_Late_Slabwise = isnull(is_Late_Calc_Slabwise,0) , @Is_Early_Slabwise = isnull(is_Early_Calc_Slabwise,0)
                    ,@Allow_Negative_Sal = Allow_Negative_Salary
                    ,@is_weekoff_hour = is_weekoff_hour , @weekoff_hours = weekoff_hours
                    ,@Paid_Weekoff_Daily_Wages = Paid_Weekoff_Daily_Wages,
                    @Is_Late_Mark_Gen = Is_Late_Mark,
                    @Half_Day_Excepted_Count =  Isnull(Half_Day_Excepted_Count,0),
                    @Half_Day_Excepted_Max_Count = Isnull(Half_Day_Excepted_Max_Count,0)
                    ,@net_round = ISNULL(net_salary_round,0) , @net_round_Type = ISNULL(type_net_salary_round,'') -- Added By Ali 04042014
                    ,@Allowed_Full_WeekOff_MidJoining_DayRate = Isnull(Allowed_Full_WeekOf_MidJoining_DayRate,0)
                    ,@Allowed_Full_WeekOff_MidJoining = Isnull(Allowed_Full_WeekOf_MidJoining,0),
                    @DayRate_WO_Cancel = ISNULL(DayRate_WO_Cancel,0)
                    ,@is_present_on_holiday = is_present_on_holiday -- Added by rohit on 29022016 for present on holiday
                    ,@Rate_Of_National_Holiday = ISNULL(Rate_Of_National_Holiday,0)
                    ,@Late_Adj_Again_OT = Isnull(Late_Adj_Again_OT,0) -- Added by nilesh patel on 03062016
                    ,@Allowed_Full_WeekOff_MidLeft=isnull(Allowed_Full_WeekOf_MidLeft,0)
                    ,@Allowed_Full_WeekOff_MidLeft_DayRate=isnull(Allowed_Full_WeekOf_MidLeft_DayRate,0) --Added by Sumit 04/06/2016
                    ,@Cust_Audit = CASE WHEN ISNULL(Is_Customer_Audit,0) = 1 THEN @Cust_Audit ELSE 0 END   --Added By Jaina 06-10-2016
                    ,@Late_Early_Ded_Combine = Isnull(Is_Chk_Late_Early_Mark,0)
                    ,@Is_OT_Adj_against_Absent = Is_OT_Adj_against_Absent
                    ,@OT_RATE_TYPE = ISNULL(OTRateType,0) -- ADDED BY RAJPUT ON 03072018
                    ,@OT_SLAB_TYPE = ISNULL(OTSLABTYPE,0) -- ADDED BY RAJPUT ON 03072018
					,@Is_OT = Isnull(IS_OT,0) --Hardik 04/10/2018 for VIVO Rajasthan
                    from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
                    and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
                    
                    --Added By Ramiz for Gradewise Salary Unpaid Holiday Logic--
                    Declare @Pass_UseTable as TinyInt = 0
                    if @Gradewise_Salary_Enabled = 1
                    set @Pass_UseTable = 2
                    --Ended--
                    
                    
                    
                    --Hardik 07/01/2012 for Arears Calculation
                    If Exists (Select 1 From T0190_MONTHLY_PRESENT_IMPORT Where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_Id  -- Condition Added Hardik 21/05/2014
                                And Month = Month(@Month_End_Date) And Year = Year(@Month_End_Date))
                        Begin
                            --Added by Nilesh Patel on 02082018 -- Start
                            DECLARE @Back_Dated_Setting tinyint 
                            Set @Back_Dated_Setting = 0
                            Select @Back_Dated_Setting = Isnull(Setting_Value,0) From T0040_SETTING Where Setting_Name='Enable Back Dated Leave As Leave Arrear Days in Next Month Salary' and Cmp_ID = @Cmp_ID
                            
                            if @Back_Dated_Setting = 1
                                Begin
                                    Select  @Arear_Day = isnull(Extra_Days,0) + isnull(Backdated_Leave_Days,0), @Arear_Month = Extra_Day_Month, @Arear_Year = Extra_Day_Year
                                            ,@M_Cancel_weekOff = Cancel_Weekoff_Day,@M_Cancel_Holiday = cancel_Holiday
                                    From    T0190_MONTHLY_PRESENT_IMPORT 
                                    Where   Cmp_ID = @Cmp_ID And Emp_ID = @Emp_Id 
                                            And Month = Month(@Month_End_Date) And Year = Year(@Month_End_Date)
                                End
                            Else
                                Begin
                                    Select  @Arear_Day = isnull(Extra_Days,0), @Arear_Month = Extra_Day_Month, @Arear_Year = Extra_Day_Year
                                            ,@M_Cancel_weekOff = Cancel_Weekoff_Day,@M_Cancel_Holiday = cancel_Holiday 
                                    From    T0190_MONTHLY_PRESENT_IMPORT 
                                    Where   Cmp_ID = @Cmp_ID And Emp_ID = @Emp_Id 
                                            And Month = Month(@Month_End_Date) And Year = Year(@Month_End_Date)
                                End
                            --Added by Nilesh Patel on 02082018 -- End

                            If @Arear_Month = 0 or @Arear_Month is null
                                Set @Arear_Month = Month(DATEADD(mm,-1,@Month_End_Date))
                    
                            If @Arear_Year = 0 or @Arear_Year is null
                                Set @Arear_Year = Year(DATEADD(mm,-1,@Month_End_Date))

                            --- Added by Hardik 04/05/2013 for SET From Date and To date as per Salary Cycle for Arear Month
                            SET @Sal_St_Date_Arear = NULL;
                            SET @Sal_End_Date_Arear = NULL;
                            
                            If @Branch_ID is null
                                Begin 
                                    select Top 1 @Sal_St_Date_Arear  = Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
                                      from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID    
                                      and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@Month_End_Date and Cmp_ID = @Cmp_ID)    
                                End
                            Else
                                Begin
                                    select @Sal_St_Date_Arear  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
                                      from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
                                      and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
                                End 
                                
                            if isnull(@Sal_St_Date_Arear,'') = ''    
                                  begin    
                                        SET @OutOf_Days_Arear = DATEDIFF(dd,dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year),dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year))+ 1
                                        SET @Sal_St_Date_Arear = dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year)
                                        SET @Sal_End_Date_Arear = dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year)
                                  end     
                                    
                             else if day(@Sal_St_Date_Arear) =1 --and month(@Sal_St_Date)= 1    
                                  begin    
                                        SET @OutOf_Days_Arear = DATEDIFF(dd,dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year),dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year))+ 1
                                        SET @Sal_St_Date_Arear = dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year)
                                        SET @Sal_End_Date_Arear = dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year)
                                  end     
                             else if @Sal_St_Date_Arear <> ''  and day(@Sal_St_Date_Arear) > 1   
                                  begin    
                                    if @manual_salary_period = 0 
                                       begin
                                            SET @Sal_St_Date_Arear =  cast(cast(day(@Sal_St_Date_Arear)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year))) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year)) )as varchar(10)) as smalldatetime)    
                                            SET @Sal_End_Date_Arear = dateadd(d,-1,dateadd(m,1,@Sal_St_Date_Arear)) 
                                            SET @OutOf_Days_Arear = datediff(d,@Sal_St_Date_Arear,@Sal_End_Date_Arear) + 1
                                       end 
                                     else
                                        begin
                                            select @Sal_St_Date_Arear = from_date, @Sal_End_Date_Arear = end_date 
                                            from salary_period where month= @Arear_Month and YEAR=@Arear_Year
                                            
                                            SET @OutOf_Days_Arear = datediff(d,@Sal_St_Date_Arear,@Sal_End_Date_Arear) + 1
                                           
                                        end   
                                  end
                            ---- End by Hardik 04/05/2013 for SET From Date and To Date for Arear Month

                            SELECT  @Basic_Salary_Arear = isnull(Basic_Salary,0)
                            FROM    T0095_Increment I inner join       
                                    (
                                        SELECT  MAX(Increment_ID) as Increment_ID 
                                        FROM    T0095_Increment      
                                        WHERE   Increment_Effective_date <= dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year)
                                                AND Cmp_ID = @Cmp_ID and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' AND EMP_ID=@Emp_ID                                     
                                    ) Qry ON I.Increment_ID = Qry.Increment_ID      
                            WHERE   I.Emp_ID = @Emp_ID 
                                
                            -- Added by Nilesh on 19112015 after discussion with hardikbhai(If salary is Exists than take working day from Salary Table)
                            If not exists(Select 1 from T0200_MONTHLY_SALARY where Month(Month_End_Date)= @Arear_Month and Year(Month_End_Date)= @Arear_Year  and Emp_id = @Emp_id)
                                Begin
                                    --if @Is_Cancel_Holiday_WO_HO_same_day = 1 
                                    --  Begin
                                    --      Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Sal_St_Date_Arear,@Sal_End_Date_Arear,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date_Arear,@StrWeekoff_Date_Arear output,@Weekoff_Days_Arear output ,Null
                                    --      Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Sal_St_Date_Arear,@Sal_End_Date_Arear,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date_Arear output,@Holiday_Days_Arear output,Null,0,@Branch_ID,@StrWeekoff_Date_Arear
                                    --  End
                                    --Else
                                    --  Begin                                           
                                    --      Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Sal_St_Date_Arear,@Sal_End_Date_Arear,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date_Arear output,@Holiday_Days_Arear output,Null,0,@Branch_ID,@StrWeekoff_Date_Arear
                                    --      Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Sal_St_Date_Arear,@Sal_End_Date_Arear,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date_Arear,@StrWeekoff_Date_Arear output,@Weekoff_Days_Arear output ,Null                                          
                                    --  End 
                                    SET @StrWeekoff_Date_Arear = NULL
                                    SELECT  @StrWeekoff_Date_Arear  = COALESCE(@StrWeekoff_Date_Arear + '', ';') + CAST(FOR_DATE AS VARCHAR(11))                                
                                    FROM    #EMP_WEEKOFF_SAL W
                                    WHERE   EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @Sal_St_Date_Arear AND @Sal_End_Date_Arear  AND IS_CANCEL=0                                         

                                    SET @StrHoliday_Date_Arear = NULL
                                    SELECT  @StrHoliday_Date_Arear  = COALESCE(@StrHoliday_Date_Arear + '', ';') + CAST(FOR_DATE AS VARCHAR(11))                                
                                    FROM    #EMP_HOLIDAY_SAL H
                                    WHERE   EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @Sal_St_Date_Arear AND @Sal_End_Date_Arear AND IS_CANCEL=0
                                            AND NOT EXISTS(SELECT 1 FROM #HW_DETAIL_SAL HD WHERE H.EMP_ID=HD.EMP_ID AND H.FOR_DATE=HD.FOR_DATE AND HD.Is_UnPaid=1)

                                    SELECT  @Weekoff_Days_Arear = ISNULL(SUM(W_Day),0) FROM #EMP_WEEKOFF_SAL
                                    WHERE   EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @Sal_St_Date_Arear AND @Sal_End_Date_Arear AND IS_CANCEL=0

                                    SELECT  @Holiday_Days_Arear = ISNULL(SUM(H_DAY),0) FROM #EMP_HOLIDAY_SAL H
                                    WHERE   EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @Sal_St_Date_Arear AND @Sal_End_Date_Arear AND IS_CANCEL=0                      
                                            AND NOT EXISTS(SELECT 1 FROM #HW_DETAIL_SAL HD WHERE H.EMP_ID=HD.EMP_ID AND H.FOR_DATE=HD.FOR_DATE AND HD.Is_UnPaid=1)      

                                    IF @StrWeekoff_Date_Arear IS NULL
                                        SET @StrWeekoff_Date_Arear = ''
                                    IF @StrHoliday_Date_Arear IS NULL
                                        SET @StrHoliday_Date_Arear = ''
                                End                     
                        End
                        ------------------ End for Arear
                        -- Added by rohit on 12012014
                            
                        if isnull(@Absent_after_Cutoff_date,0) <> 0 
                            Begin
                                SET @Arear_Month_Cutoff =month(dateadd(m,-1,@Month_End_Date))
                                SET @Arear_Year_Cutoff =Year(dateadd(m,-1,@Month_End_Date))
                            
                                SET @Sal_St_Date_Arear_Cutoff = NULL;
                                SET @Sal_End_Date_Arear_Cutoff = NULL;
                                        
                                If @Branch_ID is null
                                    Begin 
                                        select Top 1 @Sal_St_Date_Arear_Cutoff  = Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
                                          from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID    
                                          and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@Month_End_Date and Cmp_ID = @Cmp_ID)    
                                    End
                                Else
                                    Begin
                                        select @Sal_St_Date_Arear_Cutoff  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
                                          from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
                                          and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
                                    End 
                                    
                                if isnull(@Sal_St_Date_Arear_Cutoff,'') = ''    
                                      begin    
                                            SET @OutOf_Days_Arear_Cutoff = DATEDIFF(dd,dbo.GET_MONTH_ST_DATE(@Arear_Month_Cutoff,@Arear_Year_Cutoff),dbo.GET_MONTH_END_DATE(@Arear_Month_Cutoff,@Arear_Year_Cutoff))+ 1
                                            SET @Sal_St_Date_Arear_Cutoff = dbo.GET_MONTH_ST_DATE(@Arear_Month,@Arear_Year)
                                            SET @Sal_End_Date_Arear_Cutoff = dbo.GET_MONTH_END_DATE(@Arear_Month,@Arear_Year)
                                      end     
                                        
                                 else if day(@Sal_St_Date_Arear_Cutoff) =1 --and month(@Sal_St_Date)= 1    
                                      begin    
                                            SET @OutOf_Days_Arear_Cutoff = DATEDIFF(dd,dbo.GET_MONTH_ST_DATE(@Arear_Month_Cutoff,@Arear_Year_Cutoff),dbo.GET_MONTH_END_DATE(@Arear_Month_Cutoff,@Arear_Year_Cutoff))+ 1
                                            SET @Sal_St_Date_Arear_Cutoff = dbo.GET_MONTH_ST_DATE(@Arear_Month_Cutoff,@Arear_Year_Cutoff)
                                            SET @Sal_End_Date_Arear_Cutoff = dbo.GET_MONTH_END_DATE(@Arear_Month_Cutoff,@Arear_Year_Cutoff)
                                      end     
                                 else if @Sal_St_Date_Arear_Cutoff <> ''  and day(@Sal_St_Date_Arear_Cutoff) > 1   
                                      begin    
                                        if @manual_salary_period = 0 
                                           begin
                                                SET @Sal_St_Date_Arear_Cutoff =  cast(cast(day(@Sal_St_Date_Arear_Cutoff)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,dbo.GET_MONTH_ST_DATE(@Arear_Month_Cutoff,@Arear_Year_Cutoff))) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,dbo.GET_MONTH_ST_DATE(@Arear_Month_Cutoff,@Arear_Year_Cutoff)) )as varchar(10)) as smalldatetime)    
                                                SET @Sal_End_Date_Arear_Cutoff = dateadd(d,-1,dateadd(m,1,@Sal_St_Date_Arear_Cutoff)) 
                                                SET @OutOf_Days_Arear_Cutoff = datediff(d,@Sal_St_Date_Arear,@Sal_End_Date_Arear_Cutoff) + 1
                                           end 
                                         else
                                            begin
                                                select @Sal_St_Date_Arear_Cutoff = from_date, @Sal_End_Date_Arear_Cutoff = end_date 
                                                from salary_period where month= @Arear_Month and YEAR=@Arear_Year
                              
                                                SET @OutOf_Days_Arear_Cutoff = datediff(d,@Sal_St_Date_Arear_Cutoff,@Sal_End_Date_Arear_Cutoff) + 1
                                               
                                            end   
                                      end
                                ---- End by Hardik 04/05/2013 for SET From Date and To Date for Arear Month

                                SELECT @Basic_Salary_Arear_Cutoff = isnull(Basic_Salary,0)
                                 FROM T0095_Increment I inner join       
                                 (SELECT max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment      
                                     WHERE  Increment_Effective_date <= dbo.GET_MONTH_END_DATE(@Arear_Month_Cutoff,@Arear_Year_Cutoff)
                                     AND Cmp_ID = @Cmp_ID and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation'     
                                    GROUP BY emp_ID) Qry on      
                                 I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID      
                                    WHERE I.Emp_ID = @Emp_ID 
                                    
                                -- Added by Hardik 21/05/2014
                                -- Added by Nilesh on 19112015 after discussion with hardikbhai(If salary is Exists than take working day from Salary Table)
                                If NOT EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY where Month(Month_End_Date)= @Arear_Month and Year(Month_End_Date)= @Arear_Year  and Emp_id = @Emp_id)
                                    Begin
                                        --if @Is_Cancel_Holiday_WO_HO_same_day = 1 
                                        --  Begin                                               
                                        --      Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Sal_St_Date_Arear_Cutoff,@Sal_End_Date_Arear_Cutoff,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date_Arear_cutoff,@StrWeekoff_Date_Arear_cutoff output,@Weekoff_Days_Arear_cutoff output ,Null
                                        --      Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Sal_St_Date_Arear_Cutoff,@Sal_End_Date_Arear_Cutoff,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date_Arear_cutoff output,@Holiday_Days_Arear_cutoff output,Null,0,@Branch_ID,@StrWeekoff_Date_Arear_cutoff
                                        --  End
                                        --Else
                                        --  Begin                                               
                                        --      Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Sal_St_Date_Arear_Cutoff,@Sal_End_Date_Arear_Cutoff,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date_Arear_cutoff output,@Holiday_Days_Arear_cutoff output,Null,0,@Branch_ID,@StrWeekoff_Date_Arear_cutoff
                                        --      Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Sal_St_Date_Arear_Cutoff,@Sal_End_Date_Arear_Cutoff,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date_Arear_cutoff,@StrWeekoff_Date_Arear_cutoff output,@Weekoff_Days_Arear_cutoff output ,Null
                                        --  End
                                        SET @StrWeekoff_Date_Arear_cutoff = NULL
                                        SELECT  @StrWeekoff_Date_Arear_cutoff   = COALESCE(@StrWeekoff_Date_Arear_cutoff + '', ';') + CAST(FOR_DATE AS VARCHAR(11))                             
                                        FROM    #EMP_WEEKOFF_SAL
                                        WHERE   EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @Sal_St_Date_Arear_Cutoff AND @Sal_End_Date_Arear_Cutoff  AND IS_CANCEL=0

                                        SET @StrHoliday_Date_Arear_cutoff = NULL
                                        SELECT  @StrHoliday_Date_Arear_cutoff   = COALESCE(@StrHoliday_Date_Arear_cutoff + '', ';') + CAST(FOR_DATE AS VARCHAR(11))                             
                                        FROM    #EMP_HOLIDAY_SAL H
                                        WHERE   EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @Sal_St_Date_Arear_Cutoff AND @Sal_End_Date_Arear_Cutoff AND IS_CANCEL=0
                                                AND NOT EXISTS(SELECT 1 FROM #HW_DETAIL_SAL HD WHERE H.EMP_ID=HD.EMP_ID AND H.FOR_DATE=HD.FOR_DATE AND HD.Is_UnPaid=1)

                                        SELECT  @Weekoff_Days_Arear_cutoff = ISNULL(SUM(W_Day),0) FROM #EMP_WEEKOFF_SAL
                                        WHERE   EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @Sal_St_Date_Arear_Cutoff AND @Sal_End_Date_Arear_Cutoff AND IS_CANCEL=0

                                        SELECT  @Holiday_Days_Arear_cutoff = ISNULL(SUM(H_DAY),0) FROM #EMP_HOLIDAY_SAL H
                                        WHERE   EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @Sal_St_Date_Arear_Cutoff AND @Sal_End_Date_Arear_Cutoff AND IS_CANCEL=0                                        
                                                AND NOT EXISTS(SELECT 1 FROM #HW_DETAIL_SAL HD WHERE H.EMP_ID=HD.EMP_ID AND H.FOR_DATE=HD.FOR_DATE AND HD.Is_UnPaid=1)
                                        IF @StrWeekoff_Date_Arear_cutoff IS NULL
                                            SET @StrWeekoff_Date_Arear_cutoff = ''
                                        IF @StrHoliday_Date_Arear_cutoff IS NULL
                                            SET @StrHoliday_Date_Arear_cutoff = ''
                                    End
                                    
                                
                        End 
                        
                        --ended by rohit on 12012014
            
                        SET @Mid_Inc_Working_Day = datediff(d,@Month_St_Date,@Month_End_Date) + 1
                        
                        
                        if isnull(@Sal_Fix_Days,0) > 0 
                            begin                  
                                if @Mid_Inc_Working_Day > @Sal_Fix_Days or @total_count_all_incremnet = 1
                                SET @Mid_Inc_Working_Day  = @Sal_Fix_Days
                            end
                         
                        ---------------------
                               
                               
                        if isnull(@Sal_Fix_Days,0) > 0                     
                            SET @OutOf_Days = @Sal_Fix_Days
                            
                        Declare @Shift_ID Numeric
                        Set @Shift_ID = 0   
                            
                        Exec P0210_MONTHLY_LEAVE_INSERT @Cmp_ID ,@Emp_ID,@Month_St_Date,@CutoffDate_Salary,@Sal_Tran_ID 
                        If @Join_Date > @CutoffDate_Salary -- Condition added by Hardik 28/05/2018 For Arkray, Employee Joining date 22/05/2018 and Cutoff date is 20/05/2018 so Shift not getting.
                            Exec SP_CURR_T0100_EMP_SHIFT_GET @Emp_ID,@Cmp_ID,@Join_Date,null,null,@Shift_Day_Hour output,null,null,null,null,@Shift_ID output    
                        Else
                            Exec SP_CURR_T0100_EMP_SHIFT_GET @Emp_ID,@Cmp_ID,@CutoffDate_Salary,null,null,@Shift_Day_Hour output,null,null,null,null,@Shift_ID output        
						
						
                        --Hardik 16/10/2013
                        SET @StrWeekoff_Date_DayRate = ''
                        SET @Weekoff_Days_DayRate = 0

                        --- Added condition by Hardik 15/12/2014 for TOTO, to check if employee is mid join or left then only this condition work
                        --If ((@Join_Date >= @Month_St_Date and @Join_Date<=@Month_End_Date) or (@left_Date >= @Month_St_Date and @left_Date<=@Month_End_Date)) And @Allowed_Full_WeekOff_MidJoining_DayRate = 1 
                        --  SET @Allowed_Full_WeekOff_MidJoining_DayRate = 1
                        --Else
                        --  SET @Allowed_Full_WeekOff_MidJoining_DayRate = 0
                        
                        --If ((@Join_Date >= @Month_St_Date and @Join_Date<=@Month_End_Date) or (@left_Date >= @Month_St_Date and @left_Date<=@Month_End_Date)) And @Allowed_Full_WeekOff_MidJoining = 1 
                        --  SET @Allowed_Full_WeekOff_MidJoining = 1
                        --Else
                        --  SET @Allowed_Full_WeekOff_MidJoining = 0
                        
                        --Above Condition Commented and Newly added by Sumit 04/06/2016----------------------------------------------------------------------
                        If ((@Join_Date >= @Month_St_Date and @Join_Date<=@Month_End_Date) or (@left_Date >= @Month_St_Date and @left_Date<=@Month_End_Date)) And @Allowed_Full_WeekOff_MidJoining_DayRate = 1 and @Allowed_Full_WeekOff_MidLeft_DayRate = 1
                            --SET @Allowed_Full_WeekOff_MidJoining_DayRate = 1
                            SET @Allowed_Full_WeekOff_MidJoining_DayRate = 3
                        Else if ((@Join_Date >= @Month_St_Date and @Join_Date<=@Month_End_Date) or (@left_Date >= @Month_St_Date and @left_Date<=@Month_End_Date)) And @Allowed_Full_WeekOff_MidJoining_DayRate = 1 and @Allowed_Full_WeekOff_MidLeft_DayRate = 0
                            SET @Allowed_Full_WeekOff_MidJoining_DayRate = 1
                        Else if ((@Join_Date >= @Month_St_Date and @Join_Date<=@Month_End_Date) or (@left_Date >= @Month_St_Date and @left_Date<=@Month_End_Date)) And @Allowed_Full_WeekOff_MidJoining_DayRate = 0 and @Allowed_Full_WeekOff_MidLeft_DayRate = 1
                            SET @Allowed_Full_WeekOff_MidJoining_DayRate = 2
                        Else
                            SET @Allowed_Full_WeekOff_MidJoining_DayRate = 0
                        
                        If ((@Join_Date >= @Month_St_Date and @Join_Date<=@Month_End_Date) or (@left_Date >= @Month_St_Date and @left_Date<=@Month_End_Date)) And @Allowed_Full_WeekOff_MidJoining = 1 and @Allowed_Full_WeekOff_MidLeft=1
                            --SET @Allowed_Full_WeekOff_MidJoining = 1
                            SET @Allowed_Full_WeekOff_MidJoining = 3
                        Else If ((@Join_Date >= @Month_St_Date and @Join_Date<=@Month_End_Date) or (@left_Date >= @Month_St_Date and @left_Date<=@Month_End_Date)) And @Allowed_Full_WeekOff_MidJoining = 1 and @Allowed_Full_WeekOff_MidLeft=0
                            SET @Allowed_Full_WeekOff_MidJoining = 1
                        Else If ((@Join_Date >= @Month_St_Date and @Join_Date<=@Month_End_Date) or (@left_Date >= @Month_St_Date and @left_Date<=@Month_End_Date)) And @Allowed_Full_WeekOff_MidJoining = 0 and @Allowed_Full_WeekOff_MidLeft=1
                            SET @Allowed_Full_WeekOff_MidJoining = 2
                        Else
                            SET @Allowed_Full_WeekOff_MidJoining = 0
                        
          
                        --------------------------------------------------------------------------------
                        
                        
                        --Added by nilesh For Cancel Holiday When WO & HO on Same Day on 19112015
                        
                        --if @Is_Cancel_Holiday_WO_HO_same_day = 1 
                        --  Begin
                        --      Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output, 0,0,0,'',@Allowed_Full_WeekOff_MidJoining                                
                        --      Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output ,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date          
                        --  End
                        --Else
                        --  Begin
                        --      Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date
                        --      Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output, 0,0,0,'',@Allowed_Full_WeekOff_MidJoining
                        --  End

                        DECLARE @SAL_DAYS_FROM_DATE DATETIME
                        DECLARE @SAL_DAYS_TO_DATE DATETIME
                        DECLARE @varCancelWeekOff_Date AS VARCHAR(MAX)  --Added By Ramiz on 14/05/2018
                        
                        SET @SAL_DAYS_FROM_DATE= @Month_St_Date
                        SET @SAL_DAYS_TO_DATE  = @CutoffDate_Salary
                    
                        IF @Allowed_Full_WeekOff_MidJoining = 0     --Dont Consider WeekOff Before DOJ and After Left
                            BEGIN 
                                IF @Join_Date > @SAL_DAYS_FROM_DATE
                                    SET @SAL_DAYS_FROM_DATE = @Join_Date                                
                                IF @Left_Date < @SAL_DAYS_TO_DATE
                                    SET @SAL_DAYS_TO_DATE = @Left_Date
                            END
                        ELSE IF @Allowed_Full_WeekOff_MidJoining = 2    --All Weekoff should be consider after left date. but, not before date of joining
                            BEGIN                               
                                IF @Join_Date > @SAL_DAYS_FROM_DATE
                                    SET @SAL_DAYS_FROM_DATE = @Join_Date    
                            END
                        ELSE IF @Allowed_Full_WeekOff_MidJoining = 1    --All Weekoff should be consider before mid joining. but, not after left date
                            BEGIN                               
                                IF @Left_Date < @SAL_DAYS_TO_DATE
                                    SET @SAL_DAYS_TO_DATE = @Left_Date
                            END
                        
                        --ELSE  :: No need to check condition if @Allowed_Full_WeekOff_MidJoining_DayRate = 3
							SET @StrWeekoff_Date = NULL
							SELECT  @StrWeekoff_Date    = COALESCE(@StrWeekoff_Date + ';', '') + CAST(FOR_DATE AS VARCHAR(11))                              
							FROM    #EMP_WEEKOFF_SAL
							WHERE   EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @SAL_DAYS_FROM_DATE AND @SAL_DAYS_TO_DATE  AND IS_CANCEL=0

							SET @StrHoliday_Date = NULL
							SELECT  @StrHoliday_Date    = COALESCE(@StrHoliday_Date + ';', '') + CAST(FOR_DATE AS VARCHAR(11))                              
							FROM    #EMP_HOLIDAY_SAL H
							WHERE   EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @SAL_DAYS_FROM_DATE AND @SAL_DAYS_TO_DATE AND IS_CANCEL=0
									AND NOT EXISTS(SELECT 1 FROM #HW_DETAIL_SAL HD WHERE H.EMP_ID=HD.EMP_ID AND H.FOR_DATE=HD.FOR_DATE AND HD.Is_UnPaid=1)
							
							--Deepal 03072024 ticket Id 30014
							if @Join_Date > @SAL_DAYS_FROM_DATE
								set @SAL_DAYS_FROM_DATE = @Join_Date
							--Deepal 03072024

							SELECT  @Weekoff_Days = ISNULL(SUM(W_Day),0) FROM #EMP_WEEKOFF_SAL
							WHERE   EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @SAL_DAYS_FROM_DATE AND @SAL_DAYS_TO_DATE AND IS_CANCEL=0

							SELECT  @Holiday_days = ISNULL(SUM(H_DAY),0) FROM #EMP_HOLIDAY_SAL H
							WHERE   EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @SAL_DAYS_FROM_DATE AND @SAL_DAYS_TO_DATE AND IS_CANCEL=0
									AND NOT EXISTS(SELECT 1 FROM #HW_DETAIL_SAL HD WHERE H.EMP_ID=HD.EMP_ID AND H.FOR_DATE=HD.FOR_DATE AND HD.Is_UnPaid=1)
                     
						
                        IF @StrWeekoff_Date IS NULL
                            SET @StrWeekoff_Date = ''
                        IF @StrHoliday_Date IS NULL
                            SET @StrHoliday_Date = ''
                        
                        --Added By Ramiz on 14/05/2018--    
                        SET @varCancelWeekOff_Date = NULL
                        SELECT  @varCancelWeekOff_Date  = COALESCE(@StrWeekoff_Date + '', ';') + CAST(FOR_DATE AS VARCHAR(11))                              
                        FROM    #EMP_WEEKOFF_SAL
                        WHERE   EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @SAL_DAYS_FROM_DATE AND @SAL_DAYS_TO_DATE  AND IS_CANCEL = 1
                        
                        IF @varCancelWeekOff_Date IS NULL
                            SET @varCancelWeekOff_Date = ''
                        --Ended By Ramiz on 14/05/2018--
                        
                        --SELECT    @StrWeekoff_Date    = IsNull(WeekOffDate,''),
                        --      @Weekoff_Days       = IsNull(WeekOffCount,0),
                        --      @StrHoliday_Date    = IsNull(HolidayDate,'') + IsNull(';' + HalfHolidayDate,''),
                        --      @Holiday_days       = IsNull(HolidayCount,0) + IsNull(HalfHolidayCount,0)
                        --FROM  #EMP_WEEKOFF_SAL
                        --WHERE EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @SAL_DAYS_FROM_DATE AND @SAL_DAYS_TO_DATE

                    
                        --SELECT    @StrWeekoff_Date=WeekOffDate, @Weekoff_Days=WeekOffCount, @Cancel_Weekoff=CancelWeekOffCount,
                        --      @Holiday_days=HolidayCount,@Cancel_Holiday=CancelHolidayCount,
                        --      @StrWeekoff_Date_DayRate=WeekOffDate, @Weekoff_Days_DayRate=WeekOffCount
                        --FROM  #EMP_HW_CONS_SAL
                        --WHERE EMP_ID=@Emp_ID
                        
                        --Added by nilesh For Cancel Holiday When WO & HO on Same Day on 19112015
                        
                        -- Comment by nilesh patel on 19112015 _start       
                            --Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date
                            --Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output  
                        -- Comment by nilesh patel on 19112015 _End
                          
                        --Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_End_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date
                        
                        --If @Allowed_Full_WeekOff_MidJoining_DayRate = 1, Below Sp will take Full Weekoff if Mid Joining 
                        --Hardik 16/10/2013
                                    
                        --EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date_DayRate OUTPUT,@Weekoff_Days_DayRate OUTPUT ,@Cancel_Weekoff OUTPUT,0,0,0,'',@Allowed_Full_WeekOff_MidJoining_DayRate                       

                        DECLARE @DAY_RATE_FROM_DATE DATETIME
                        DECLARE @DAY_RATE_TO_DATE DATETIME

                        SET @DAY_RATE_FROM_DATE= @Month_St_Date
                        SET @DAY_RATE_TO_DATE  = @CutoffDate_Salary

                        IF @Allowed_Full_WeekOff_MidJoining_DayRate = 0     --Dont Consider WeekOff Before DOJ and After Left
                            BEGIN 
                                IF @Join_Date > @DAY_RATE_FROM_DATE
                                    SET @DAY_RATE_FROM_DATE = @Join_Date                                
                                IF @Left_Date < @DAY_RATE_TO_DATE
                                    SET @DAY_RATE_TO_DATE = @Left_Date
                            END
                        ELSE IF @Allowed_Full_WeekOff_MidJoining_DayRate = 2    --All Weekoff should be consider after left date. but, not before date of joining
                            BEGIN                               
                                IF @Join_Date > @DAY_RATE_FROM_DATE
                                    SET @DAY_RATE_FROM_DATE = @Join_Date    
                            END
                        ELSE IF @Allowed_Full_WeekOff_MidJoining_DayRate = 1    --All Weekoff should be consider before mid joining. but, not after left date
                            BEGIN                               
                                IF @Left_Date < @DAY_RATE_TO_DATE
                                    SET @DAY_RATE_TO_DATE = @Left_Date
                            END
                        
                        --ELSE  :: No need to check condition if @Allowed_Full_WeekOff_MidJoining_DayRate = 3

                        

                        SET @StrWeekoff_Date_DayRate = NULL
                        SELECT  @StrWeekoff_Date_DayRate    = COALESCE(@StrWeekoff_Date_DayRate + '', ';') + CAST(FOR_DATE AS VARCHAR(11))                              
                        FROM    #EMP_WEEKOFF_SAL
                        WHERE   EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @DAY_RATE_FROM_DATE AND @DAY_RATE_TO_DATE  AND IS_CANCEL=0
                        IF @StrWeekoff_Date_DayRate IS NULL
                            SET @StrWeekoff_Date_DayRate = ''


                        SELECT  @Weekoff_Days_DayRate = ISNULL(SUM(W_Day),0) FROM #EMP_WEEKOFF_SAL
                        WHERE   EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @DAY_RATE_FROM_DATE AND @DAY_RATE_TO_DATE AND IS_CANCEL=0

                        SELECT  @Cancel_Weekoff = ISNULL(SUM(W_Day),0) FROM #EMP_WEEKOFF_SAL
                        WHERE   EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @DAY_RATE_FROM_DATE AND @DAY_RATE_TO_DATE AND IS_CANCEL=1
                            
						
						SET @StrHoliday_Date_DayRate = NULL
						SELECT	@StrHoliday_Date_DayRate	= COALESCE(@StrHoliday_Date_DayRate + '', ';') + CAST(FOR_DATE AS VARCHAR(11))								
						FROM	#EMP_Holiday_SAL H
						WHERE	EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @DAY_RATE_FROM_DATE AND @DAY_RATE_TO_DATE  AND IS_CANCEL=0
								AND NOT EXISTS(SELECT 1 FROM #HW_DETAIL_SAL HD WHERE H.EMP_ID=HD.EMP_ID AND H.FOR_DATE=HD.FOR_DATE AND HD.Is_UnPaid=1)

						IF @StrHoliday_Date_DayRate IS NULL
							SET @StrHoliday_Date_DayRate = ''

						SELECT	@Holiday_Days_DayRate = ISNULL(SUM(H_Day),0) FROM #EMP_Holiday_SAL H
						WHERE	EMP_ID=@Emp_Id AND FOR_DATE BETWEEN @DAY_RATE_FROM_DATE AND @DAY_RATE_TO_DATE AND IS_CANCEL=0
								AND NOT EXISTS(SELECT 1 FROM #HW_DETAIL_SAL HD WHERE H.EMP_ID=HD.EMP_ID AND H.FOR_DATE=HD.FOR_DATE AND HD.Is_UnPaid=1)


						--select @Weekoff_Days_DayRate,@Holiday_Days_DayRate
                        --SELECT    @StrWeekoff_Date_DayRate=WeekOffDate, @Weekoff_Days_DayRate=WeekOffCount, @Cancel_Weekoff=CancelWeekOffCount
                        --FROM  #EMP_HW_CONS_SAL
                        --WHERE EMP_ID=@Emp_ID
                        --rohit on 24112012------  
                        
                        SET @Weekoff_Days_DayRate = @Weekoff_Days_DayRate + isnull(@Weekoff_AfterCuttoff,0) --Added by Rohit on 30-11-2015 (For CutOff Day Rate )
                        
                        If @M_Cancel_weekOff > 0 and @Weekoff_Days > 0  
                            Begin 
                                if @M_Cancel_weekOff <= @Weekoff_Days --Condition added by Hardik 03/05/2015 to check Manual Weekoff Cancel and weekoff day should not greter
                                    Begin
                                        SET @Weekoff_Days = @Weekoff_Days - @M_Cancel_weekOff
                                        SET @Cancel_Weekoff = @M_Cancel_weekOff
                                    End
                                Else
                                    Begin
                                        SET @Weekoff_Days = 0
                                        SET @Cancel_Weekoff = @M_Cancel_weekOff
                                    End
                            End
                        
                        --Added below condition by Hardik 03/05/2015 to change day rate if weekoff is cancel for NIRMA
                        If Isnull(@DayRate_WO_Cancel,0) = 1
                            BEGIN
                            
                                 If @M_Cancel_weekOff > 0 and @Weekoff_Days_DayRate > 0
                                    Begin 
                                        if @M_Cancel_weekOff <= @Weekoff_Days_DayRate --Condition added by Hardik 03/05/2015 to check Manual Weekoff Cancel and weekoff day should not greter
                                            Begin
                                                SET @Weekoff_Days_DayRate = @Weekoff_Days_DayRate - @M_Cancel_weekOff
                                            End
                                        Else
                                            Begin
                                                SET @Weekoff_Days_DayRate = 0
                                            End
                                    End
                            END         

                        
                        If @M_Cancel_holiday > 0 and @Holiday_days > 0  
                            Begin   
                                SET @Holiday_days = @Holiday_days - @M_Cancel_holiday  
                                SET @Cancel_Holiday = @M_Cancel_holiday  
                            End  
                        -----end by rohit on 24112012---------- 
                        
                        SET @Qry = null;
                        SET @Half_Day_Count = null;
                        SET @Is_Manual_Present = 0             
						
                    
                        ----------- Add By Jignesh 25-Mar-2013 -- (Get Present Days From Attandance Import Table)
                        IF EXISTS(SELECT EMP_ID FROM  T0170_EMP_ATTENDANCE_IMPORT WHERE Cmp_ID=@Cmp_ID and EMP_ID=@EMP_ID AND [Month]=Month(@Month_End_Date) and [year]=YEAR(@Month_End_Date))
                            Begin                                   
                                if @Month_End_Date <= @CutoffDate_Salary_temp
                                    EXEC SP_GET_PRESENT_DAYS @EMP_ID,@Cmp_ID,@Month_st_Date,@Month_End_Date, @Present_Days output,@Absent_Days output,@Holiday_Days output,@Weekoff_Days output,@Is_Cutoff_Salary,@tmp_Month_St_Date  ----Condition @Is_Cutoff_Salary added by Hardik 02/02/2016
                                else
                                    EXEC SP_GET_PRESENT_DAYS @EMP_ID,@Cmp_ID,@Month_st_Date,@CutoffDate_Salary_temp, @Present_Days output,@Absent_Days output,@Holiday_Days output,@Weekoff_Days output,@Is_Cutoff_Salary,@tmp_Month_St_Date  ----Condition @Is_Cutoff_Salary added by Hardik 02/02/2016

                                SET @Is_Manual_Present = 1
                                SET @Weekoff_Days_DayRate = ISNULL(@Weekoff_Days,0) --Ankit 05062015                                                
                            End                         
                        ------------------------ End----------------------------------------
                        
			
                    
                        Declare @GatePass_Deduct_Days NUMERIC(18, 4)
                        --Added by Jaina 30-04-2019 Start
						DECLARE @T_MONTH_START_DATE DateTime
						DECLARE @T_MONTH_END_DATE DateTime
						SET @T_MONTH_START_DATE = @Month_St_Date
						SET @T_MONTH_END_DATE = @Month_End_date
						
						
						if @Is_Cutoff_Salary = 1
							BEGIN											
								SET @T_MONTH_START_DATE = @Cutoff_Start_Date
								SET @T_MONTH_END_DATE = @CutoffDate_Salary
							END
						
						--Added by Jaina 30-04-2019 End


                        If @Is_Negative_Ot =1
                            Begin
                                If @Is_Manual_Present = 0
                                    Begin
                                        If Exists(Select Tran_Id From T0160_OT_Approval Where Emp_Id=@Emp_Id And Cmp_Id=@Cmp_Id And For_Date>=@Month_St_Date and For_Date <=@Month_End_Date )
                                            Begin
                                                
                                                    Select @Present_Days = ISNULL(P_Days_Count,0),@Actual_Working_Sec= ISNULL(SUM(Working_Sec),0), @Emp_OT_Sec =  ISNULL(Sum(Approved_OT_Sec),0), @Emp_WO_OT_Sec = ISNULL(sum(Approved_WO_OT_Sec),0) ,@Emp_HO_OT_Sec =  ISNULL(sum(Approved_HO_OT_Sec),0) 
                                                    From T0160_OT_Approval 
                                                    Where Emp_Id=@Emp_Id And Cmp_Id=@Cmp_Id And For_Date>=@Month_St_Date and For_Date <=@Month_End_Date and Isnull(Is_Approved,0) = 1
                                                    Group By P_days_count                               
                                                    SET @Actual_Working_Sec = @Actual_Working_Sec*3600                                              
                                            End
                                        Else
                                            Begin   
                                                
                                                --Exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@Month_St_Date,@CutoffDate_Salary,0,0,0,0,0,0,@emp_ID,'',4,'',0
                                                TRUNCATE TABLE #Data
                                                INSERT INTO #DATA 
                                                SELECT * FROM #Data_SAL WHERE EMP_ID=@Emp_ID 
                                                
                                                --Changed by rohit on 04102012 for filter approved comp-off in OT on week off
                                                Delete from #Data Where Emp_Id = @Emp_Id and (ISNULL(Weekoff_OT_Sec,0) <> 0 or ISNULL(Holiday_OT_Sec,0) <> 0)
                                                and For_Date in (Select Extra_Work_Date from T0120_CompOff_Approval where Extra_Work_Date >= @Month_St_Date and Extra_Work_Date <= @Month_End_Date and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id and Approve_Status = 'A')
                                            
                                                update #Data SET OT_Sec=0 Where Emp_Id = @Emp_Id and (ISNULL(Weekoff_OT_Sec,0) = 0 and ISNULL(Holiday_OT_Sec,0) = 0)
                                                and For_Date in (Select Extra_Work_Date from T0120_CompOff_Approval where Extra_Work_Date >= @Month_St_Date and Extra_Work_Date <= @Month_End_Date and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id and Approve_Status = 'A')  

                                                ---- Added by Hardik 13/02/2014 for Kataria to Except Half Days
                                            
                                                SET @Half_Day_Count = 0
                                                
                                                If @Half_Day_Excepted_Count >= 0
                                                    Begin
                                                        Select @Half_Day_Count = COUNT(Emp_Id) From #Data Where P_days = 0.5    
                                                        
                                                        If @Half_Day_Excepted_Max_Count > 0 And @Half_Day_Count > 0
                                                            Begin
                                                                If @Half_Day_Excepted_Max_Count >= @Half_Day_Count
                                                                    Begin
                                                                        --SET @Qry = 'Select top ' + Cast(Cast(@Half_Day_Excepted_Count as int) as varchar(10)) + ' For_Date From #Data Where P_days = 0.5'
                                                                        SET @Qry = 'Update #Data SET P_days = 1 Where For_Date in (Select top ' + Cast(Cast(@Half_Day_Excepted_Count as int) as varchar(10)) + ' For_Date From #Data Where P_days = 0.5)'
                                                                        Execute (@Qry)
                                                                    End
                                                            End
                                                    End
                                                ---- End by Hardik 13/02/2014 for Kataria to Except Half Days
                                                
                                                select @Present_Days = isnull(sum(P_Days),0), @Actual_Working_Sec =isnull(sum(Duration_In_Sec),0), @Emp_OT_Sec = isnull(sum(OT_Sec),0), @Emp_WO_OT_Sec = ISNULL(sum(Weekoff_OT_Sec),0) ,@Emp_HO_OT_Sec =  ISNULL(sum(Holiday_OT_Sec),0)  
                                                From  #Data where Emp_ID=@emp_ID     
                                                    and For_Date>=@Month_St_Date and For_Date <=@Month_End_Date  
                                                
                                                SELECT @GatePass_Deduct_Days = sum(isnull(GatePass_Deduct_Days,0))  FROM #Data where Emp_ID=@emp_ID      -- Changed by Gadriwala Muslim 05012015
                                                    and For_Date>=@Month_St_Date and For_Date <=@Month_End_Date 
                                            End
                                    End

                                end




                        Else
                            begin

							
                                
                                If @Is_Manual_Present = 0
                                    Begin
                                        TRUNCATE TABLE #Data
                                                                                                                                                            
                                        INSERT INTO #DATA 
                                        SELECT distinct * FROM #Data_SAL WHERE EMP_ID=@Emp_ID
                                                                                    
                                        --Exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@Month_St_Date,@CutoffDate_Salary,0,0,0,0,0,0,@emp_ID,'',4,'',0                                        
										
                                        if @Is_OT_Auto_Calc = 0
										begin
                                                
                                                update #Data         
                                                SET OT_Sec = 0 ,Weekoff_OT_Sec = 0, Holiday_OT_Sec = 0 -- * 3600        
                                                from #Data -- d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date         
                                            
                                                If exists (Select 1 From T0160_OT_Approval Where For_Date >= @T_MONTH_START_DATE And For_date <= @T_MONTH_END_DATE And Emp_Id=@Emp_Id and Is_Month_Wise = 0 and Is_Approved = 1)  -- add  Condition  Is_Approved = 1 by Gadriwala 28022014(Before add Discussed with Hardik bhai)
                                                    Begin
                                                        --New Code Added By Ramiz on 08/03/2016 for those who has applied OD on week off and need to take it as Overtime
                                                        If Exists(Select OA.For_Date From T0160_OT_Approval OA Left Outer JOin #Data D on D.For_date = OA.For_Date and D.Emp_Id = OA.Emp_ID
                                                            Where OA.For_Date >= @T_MONTH_START_DATE And OA.For_date <= @T_MONTH_END_DATE And OA.Emp_Id=@Emp_Id and Is_Month_Wise = 0 
                                                            and Is_Approved = 1 and OA.For_Date Not in ( Select For_Date from #Data Where For_Date >= @T_MONTH_START_DATE And For_date <= @T_MONTH_END_DATE And Emp_Id=@Emp_Id ))
                                                        
                                                            BEGIN
                                                                Insert into #Data 
                                                                    (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change,Chk_By_Superior,IO_Tran_Id,OUT_Time)
                                                                SELECT OA.Emp_id , OA.For_Date , 0 , IQ.Emp_OT , dbo.F_Return_Sec(IQ.Emp_OT_min_Limit),dbo.F_Return_Sec(IQ.Emp_OT_max_Limit) , NULL , NULL , 0 , 0 , 0 , 0 , NULL
                                                                FROM T0160_OT_Approval OA 
                                                                    INNER JOIN          
                                                                        (
                                                                            SELECT I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit 
                                                                            FROM dbo.T0095_INCREMENT  I 
                                                                            INNER JOIN  --Commented and New Code Added By Ramiz on 12/12/2017
                                                                                    ( SELECT MAX(I2.INCREMENT_ID) AS INCREMENT_ID, I2.EMP_ID 
                                                                                        FROM T0095_INCREMENT I2 
                                                                                            INNER JOIN 
                                                                                            (
                                                                                                    SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
                                                                                                    FROM T0095_INCREMENT I3
                                                                                                    WHERE I3.Increment_effective_Date <= @T_MONTH_END_DATE and I3.Cmp_ID = @Cmp_ID and I3.Increment_Type <> 'Transfer' and I3.Increment_Type <> 'Deputation'
                                                                                                 GROUP BY I3.EMP_ID  
                                                                                                ) I3 ON I2.Increment_Effective_Date = I3.Increment_Effective_Date AND I2.EMP_ID = I3.Emp_ID 
                                                                                       WHERE I2.INCREMENT_EFFECTIVE_DATE <= @T_MONTH_END_DATE and I2.Cmp_ID = @Cmp_ID and I2.Increment_Type <> 'Transfer' and I2.Increment_Type <> 'Deputation'
                                                                                       GROUP BY I2.emp_ID  
                                                                                    ) Qry on    I.Emp_ID = Qry.Emp_ID   and I.Increment_ID = Qry.Increment_ID 
                                                                            WHERE I.CMP_ID = @Cmp_ID AND I.EMP_ID = @Emp_ID
                                                                            --INNER JOIN         
                                                                            --  (
                                                                            --      SELECT max(Increment_ID)Increment_ID ,Emp_ID 
                                                                            --      FROM dbo.T0095_Increment
                                                                            --      WHERE increment_effective_Date <=@Month_End_date and Cmp_ID =@Cmp_ID and Emp_ID = @Emp_ID 
                                                                            --      GROUP BY Emp_ID
                                                                            --   )q on I.emp_ID =q.Emp_ID and I.Increment_ID = q.Increment_ID 
                                                                        ) IQ on OA.Emp_ID =iq.emp_ID 
                                                                WHERE OA.For_Date >= @T_MONTH_START_DATE And OA.For_date <= @T_MONTH_END_DATE And OA.Emp_Id=@Emp_Id and Is_Month_Wise = 0 
                                                                    and Is_Approved = 1 and OA.For_Date Not in ( Select For_Date from #Data Where For_Date >= @T_MONTH_START_DATE And For_date <= @T_MONTH_END_DATE And Emp_Id=@Emp_Id )
                                                            END                                                 
                                                        
                                                        update #Data         
                                                        SET OT_Sec = isnull(Approved_OT_Sec,0), Weekoff_OT_Sec = isnull(Approved_WO_OT_Sec,0), Holiday_OT_Sec = isnull(Approved_HO_OT_Sec,0)  -- * 3600        
                                                        from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date                                              
                                                        Where OA.Is_Approved = 1    
                                                    End
                                                Else
                                                    Begin
                                                        
                                                        SET  @Approved_OT_Sec = 0
                                                        SET @Approved_WO_OT_Sec =0
                                                        SET @Approved_HO_OT_Sec =0

                                                        Select @Approved_OT_Sec=Approved_OT_Sec ,
                                                                @Approved_WO_OT_Sec=Approved_WO_OT_Sec,
                                                                @Approved_HO_OT_Sec = Approved_HO_OT_Sec
                                                        From T0160_OT_APPROVAL Where For_Date >= @T_MONTH_START_DATE And For_date <= @T_MONTH_END_DATE And Emp_Id=@Emp_Id and Is_Month_Wise = 1

                                                        Update #data SET OT_sec = @Approved_OT_Sec, Weekoff_OT_Sec = @Approved_WO_OT_Sec, Holiday_OT_Sec = @Approved_HO_OT_Sec
                                                        Where For_Date = (Select Max(For_date) From #Data Where Emp_Id=@Emp_Id)
                                                    End
                                            end
                                        
                                        
                                      --Changed by rohit on 04102012 for filter approved comp-off in OT on week off
                                        Delete from #Data Where Emp_Id = @Emp_Id and ( ISNULL(Weekoff_OT_Sec,0) <> 0 or ISNULL(Holiday_OT_Sec,0) <> 0)
                                        and For_Date in (Select Extra_Work_Date from T0120_CompOff_Approval where Extra_Work_Date >= @T_MONTH_START_DATE and Extra_Work_Date <= @T_MONTH_END_DATE and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id and Approve_Status = 'A')
                                        
                                        update #Data SET OT_Sec=0 Where Emp_Id = @Emp_Id and ( ISNULL(Weekoff_OT_Sec,0)= 0 and ISNULL(Holiday_OT_Sec,0) = 0)
                                        and For_Date in (Select Extra_Work_Date from T0120_CompOff_Approval where Extra_Work_Date >= @T_MONTH_START_DATE and Extra_Work_Date <= @T_MONTH_END_DATE and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id and Approve_Status = 'A')
                                            
                                        ---- Added by Hardik 13/02/2014 for Kataria to Except Half Days

                                        SET @Half_Day_Count = 0
                                    
                                        If @Half_Day_Excepted_Count >= 0
                                            Begin
                                                Select @Half_Day_Count = COUNT(Emp_Id) From #Data Where P_days = 0.5    
                                                
                                                If @Half_Day_Excepted_Max_Count > 0 And @Half_Day_Count > 0
                                                    Begin
                                                        If @Half_Day_Excepted_Max_Count >= @Half_Day_Count
                                                            Begin
                                                                --SET @Qry = 'Select top ' + Cast(Cast(@Half_Day_Excepted_Count as int) as varchar(10)) + ' For_Date From #Data Where P_days = 0.5'
                                                                SET @Qry = 'Update #Data SET P_days = 1 Where For_Date in (Select top ' + Cast(Cast(@Half_Day_Excepted_Count as int) as varchar(10)) + ' For_Date From #Data Where P_days = 0.5)'
                                                                Execute (@Qry)
                                                            End
                                                    End
                                            End
                                        ---- End by Hardik 13/02/2014 for Kataria to Except Half Days
                                   
					

										if @Is_Cutoff_Salary = 1 --Deepal Cutoff Condition Dt :- 02122022
											select DISTINCT  @Present_Days = isnull(sum(P_Days),0), @Actual_Working_Sec =isnull(sum(Duration_In_Sec),0)
											From    #Data where Emp_ID=@emp_ID     
												and For_Date>=@Month_St_Date and For_Date <=@CutoffDate_Salary  
										else
											--- Below 2 conditions are different by Hardik 17/10/2019 as Cutoff Salary case Present day is count wrong                                        
											select DISTINCT  @Present_Days = isnull(sum(P_Days),0), @Actual_Working_Sec =isnull(sum(Duration_In_Sec),0)
											From    #Data where Emp_ID=@emp_ID     
												and For_Date>=@Month_St_Date and For_Date <=@Month_End_Date  

										

                                        select  @Emp_OT_Sec = isnull(sum(OT_Sec),0), @Emp_WO_OT_Sec = ISNULL(sum(Weekoff_OT_Sec),0) ,@Emp_HO_OT_Sec =  ISNULL(sum(Holiday_OT_Sec),0) 
                                        From    #Data where Emp_ID=@emp_ID     
                                            and For_Date>=@T_MONTH_START_DATE and For_Date <=@T_MONTH_END_DATE  
                                        
                                        if  @Is_Cutoff_Salary = 1 And --Added by Jaina 16-12-2017
                                            exists(select 1 from T0200_MONTHLY_SALARY where MONTH(Month_End_Date) =  month(dateadd(m,-1,@T_MONTH_END_DATE)) 
                                                and year(Month_End_Date) =  Year( dateadd(m,-1,@T_MONTH_END_DATE)) and Emp_ID=@Emp_Id 
                                                and cutoff_date <> Month_End_Date)
                                        begin
                                            select   @Emp_OT_Sec = isnull(sum(OT_Sec),0), @Emp_WO_OT_Sec = ISNULL(sum(Weekoff_OT_Sec),0) ,@Emp_HO_OT_Sec =  ISNULL(sum(Holiday_OT_Sec),0)  
                                            From    #Data where Emp_ID=@emp_ID  
                                                    and For_Date>=case when @Is_Cutoff_Salary = 0 then @T_MONTH_START_DATE ELSE @Cutoff_Start_Date END   --Added by Jaina 28-11-2017 (Add Cutoff date condition)
                                                    and For_Date <=case when @Is_Cutoff_Salary = 0 then @T_MONTH_END_DATE ELSE @CutoffDate_Salary END   --Added by Jaina 28-11-2017 (Add Cutoff date condition)    
                                        end
                                        select @GatePass_Deduct_Days = sum(isnull(GatePass_Deduct_Days,0)) from #Data where  Emp_ID=@emp_ID     
                                            and For_Date>=@T_MONTH_START_DATE and For_Date <=@T_MONTH_END_DATE     
                                        
                                  End

								
                            End

						-- Deepal 18062024 

						if exists(select 1 From T0150_EMP_INOUT_RECORD E 
						where E.For_date not in (Select For_date from #Data) 
						and e.For_date >= @Month_St_Date and E.For_date <= @Month_End_Date and e.Emp_ID = @Emp_Id and Chk_By_Superior = 1 and Cmp_ID = @Cmp_ID)
						BEGIN
							--Deepal 03072024
							Declare @MonthjoinDate as DATE
							if @Join_Date > @Month_St_Date
								set @MonthjoinDate = @Join_Date
							else
								set @MonthjoinDate = @Month_St_Date
														
							--Select @Present_Days =  @Present_Days + Count(1) 
							--From T0150_EMP_INOUT_RECORD E inner join (
							--Select ROW_NUMBER() OVER(Partition by Emp_id,for_date order by Emp_Id) as rn,e1.Emp_ID,e1.For_Date 
							--From T0150_EMP_INOUT_RECORD E1
							--where e1.For_date not in (Select For_date from #Data) 
							--and e1.For_date >= @Month_St_Date and e1.For_date <= @Month_End_Date and e1.Emp_ID = @Emp_Id and Chk_By_Superior = 1 and Cmp_ID = @Cmp_ID
							--) a on a.Emp_ID = e.Emp_ID and a.For_Date =e.For_Date
							--where E.For_date not in (Select For_date from #Data) 
							--and e.For_date >= @MonthjoinDate and E.For_date <= @Month_End_Date and e.Emp_ID = @Emp_Id and Chk_By_Superior = 1 and Cmp_ID = @Cmp_ID and a.rn = 1
							
								Select @Present_Days =  @Present_Days + Count(1)  from (
									Select  ROW_NUMBER() OVER(Partition by Emp_id,for_date order by Emp_Id) as rn,*
									From T0150_EMP_INOUT_RECORD E 
									where E.For_date not in (Select For_date from #Data) 
									and e.For_date >= @MonthjoinDate and E.For_date <= @Month_End_Date and e.Emp_ID = @Emp_Id and Chk_By_Superior = 1 and Cmp_ID = @Cmp_ID 
								) A where a.rn = 1
							--Deepal 03072024
						END
						-- Deepal 18062024
                            
                        Declare @present_on_holiday numeric(18,2)  -- Added by rohit on 19022016
                        SET @present_on_holiday = 0
                        
                        if @is_present_on_holiday = 1
                            BEGIN
                               SELECT @present_on_holiday =  count(1)       
                               FROM #Data D       
                               INNER JOIN (
                                            SELECT DISTINCT DAY(H_From_Date) as Day_1 ,Month(H_From_Date) as Month_1,is_National_Holiday 
                                            FROM  T0040_HOLIDAY_MASTER  WHERE cmp_id= @Cmp_ID and is_National_Holiday = 0  and (branch_id = @branch_id or isnull(branch_id,0)=0)
                                          ) HM ON month(D.For_date) = month_1 and Day(D.For_date) = Day_1 and HM.is_National_Holiday = 0       
                               WHERE  ISNULL(D.In_Time ,'') <> '' AND ISNULL(D.out_time,'') <> '' --Holiday_OT_Sec > 1000       
                               AND EMP_ID = @EMP_ID AND for_date <= @Month_End_Date and For_date >= @Month_St_Date      
                               AND  charindex(cast(D.For_date as varchar(11)),@StrHoliday_Date,0) > 0 -- Added by rohit on 26082016      
                                 
                               --select @present_on_holiday = isnull(@present_on_holiday,0) * isnull(@Rate_Of_National_Holiday,0)      
                               SELECT @present_on_holiday =  isnull(@present_on_holiday,0) + isnull(count(*),0)       
                               FROM #Data D       
                               INNER JOIN (
                                            SELECT DISTINCT DAY(H_From_Date) as Day_1 ,Month(H_From_Date) as Month_1,is_National_Holiday 
                                            FROM  T0040_HOLIDAY_MASTER  WHERE cmp_id= @Cmp_ID and is_National_Holiday=1  and (branch_id = @branch_id or isnull(branch_id,0)=0)
                                           ) HM on month(D.For_date) = month_1 and Day(D.For_date) = Day_1 and HM.is_National_Holiday = 1       
                               WHERE  isnull(D.In_Time ,'')<>'' and isnull(D.out_time,'')<>'' --Holiday_OT_Sec > 1000      
                                AND EMP_ID = @EMP_ID AND for_date <= @Month_End_Date and For_date >=@Month_St_Date 
                                AND charindex(cast(D.For_date as varchar(11)),@StrHoliday_Date,0) > 0 -- Added by rohit on 26082016
                                
                                SELECT @present_on_holiday = isnull(@present_on_holiday,0) * isnull(@Rate_Of_National_Holiday,0) --Re-opened Commented Portion By Ramiz For Calculating Common Rate for Both ( Festival & National ) from Single Variable.
                            end 
                        
                        
                        --If @Is_Manual_Present = 0 Comment By Nilesh Patel on 12082019 -- Mantis ID = 0008887
                        --If @Is_Manual_Present = 0 AND --Condition added by Hardik 02/02/2016
						IF @CutoffDate_Salary_temp Between @Month_St_Date And @Month_End_Date  -- Added condition by Hardik 07/02/2018 for Mid Increment case and Holiday is after cutoff date, mentis bug id 0008726
                            Begin     
								SET @Present_Days= @Present_Days + isnull(@Present_AfterCuttoff,0) -- Added by rohit
                                SET @Holiday_days = @Holiday_days + isnull(@Holiday_AfterCuttoff,0) 
                                SET @Weekoff_Days = @Weekoff_Days + isnull(@Weekoff_AfterCuttoff,0) 
                            End         
                        -- Added by Hardik 11/11/2013 for Sharp Image, Pakistan
                        If Isnull(@Monthly_Deficit_Adjust_OT_Hrs,0) = 1 And @SalaryBasis = 'Hour'
                            Begin
                            
                                Exec SP_RPT_EMP_INOUT_RECORD_GET @Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Branch_ID,0,0,0,0,0,@Emp_ID,'','SALARY'
                            
                                Declare @Hour_Rate_Deficit NUMERIC(18, 4)
                                Declare @Actual_OT_Sec NUMERIC(18, 4)
                                Declare @Actual_OT_Hours Varchar(10)
                                Declare @Shift_Sec_1 NUMERIC(18, 4)
                                
                                SET @Actual_OT_Sec = 0
                                SET @Actual_OT_Hours = ''
                                
                                Select @mid_Deficit_Sec = Isnull(Actual_Deficit_Sec,0),
                                    @Shift_Sec_1 = Shift_Sec, @Emp_OT_Sec = Actual_OT_Sec, 
                                    @Actual_OT_Hours = Actual_OT_Hour
                                From ##Salary Where Emp_Id = @Emp_Id

                                SET @Hour_Rate_Deficit = 0
                                SET @Hour_Rate_Deficit = @Actual_Gross_Salary / (@Shift_Sec_1/3600)
                            
                                SET @mid_Deficit_Dedu_Amount = (@mid_Deficit_Sec /3600) * @Hour_Rate_Deficit
                            End
						
						--Added By Nilesh For Deduct Second Break hours from Shift Duration for Calculate OT Rate --Shoftshipyard -- 04/06/2019
                        Declare @Second_Break_Hours Varchar(10)
						Declare @DeduHour_SecondBreak tinyint 
						Set @Second_Break_Hours  = ''
						Set @DeduHour_SecondBreak = 0   

                        Select @Second_Break_Hours = S_Duration, 
							   @DeduHour_SecondBreak = DeduHour_SecondBreak 
						From T0040_Shift_Master Where Shift_ID = @Shift_ID
				
						if @DeduHour_SecondBreak = 1 and @Second_Break_Hours <> '' and @Break_Hours_OT_Rate = 1
							Begin
								Set @Shift_Day_Sec = dbo.F_Return_Sec(isnull(@Shift_Day_Hour,'00:00'))  
								Set @Shift_Day_Sec = @Shift_Day_Sec - dbo.F_Return_Sec(isnull(@Second_Break_Hours,'00:00'))  
							End
						Else
							Begin
								Set @Shift_Day_Sec = dbo.F_Return_Sec(isnull(@Shift_Day_Hour,'00:00'))
							End
						--Added By Nilesh For Deduct Second Break hours from Shift Duration for Calculate OT Rate --Shoftshipyard -- 04/06/2019
							
                        SELECT @Fix_OT_Shift_Sec = dbo.F_Return_Sec(isnull(@Fix_OT_Shift_Hours,'00:00'))   
                        SELECT @Emp_OT_Min_Sec  = dbo.F_Return_Sec(isnull(@Emp_OT_Min_Limit,'00:00'))    
                        SELECT @Emp_OT_Max_Sec  = dbo.F_Return_Sec(isnull(@Emp_OT_Max_Limit,'00:00')) 
                        SELECT @Fix_late_W_Shift_Sec = dbo.F_Return_Sec(isnull(@Fix_late_W_Hours,'00:00'))   
                        SELECT @Actual_Working_Hours = dbo.F_Return_Hours(isnull(@Actual_Working_Sec,0))  
                        
                        --Alpesh 08-Aug-2012 -> for divide by zero error
                        If @Shift_Day_Sec = 0
                            Begin
                                SET @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Month='+cast(MONTH(@Month_End_Date) as varchar)+', Year='+cast(year(@Month_End_Date) as varchar)
                                exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Salary','Shift Is Not Proper',@LogDesc,1,''                         ,@Sal_Generate_Date
                                
                                CLOSE curMDI;
                                DEALLOCATE curMDI;
                                GOTO NEXT_EMP
                            End
                        
                        If @Fix_OT_Shift_Sec > 0
                            Begin  
                                SET @Fix_OT_Shift_Sec = @Fix_OT_Shift_Sec
                            End  
                        Else
                            Begin  
                                SET @Fix_OT_Shift_Sec = @Shift_Day_Sec
                            End  
                    
              If @Is_Manual_Present = 0     --Added by Ramiz on 04/07/2015 , in order to Add regular OT hours & Uploaded OT Hours ( For Bhaskar )
                Begin
                     if @M_OT_Hours > 0
                        SET @Emp_OT_Sec = isnull(@Emp_OT_Sec,0) + (@M_OT_Hours * 3600)
                     if @W_OT_Hours > 0 
                        SET @Emp_WO_OT_Sec = isnull(@Emp_WO_OT_Sec,0) + (@W_OT_Hours * 3600)
                     if @H_OT_Hours > 0     
                        SET @Emp_HO_OT_Sec = isnull(@Emp_HO_OT_Sec,0) + (@H_OT_Hours * 3600)
                End
                                                                    
                if @Inc_Weekoff <>1  
                    Begin                       
                        if @Inc_Holiday <>1  
                            Begin                                                                   
                                --SET @Working_Days = @OutOf_Days - (@Weekoff_Days_DayRate + @Holiday_days)                             
                                If isnull(@Sal_fix_days,0) = 0
                                Begin
                                   --SET @Working_Days = @OutOf_Days - (@Weekoff_Days_DayRate + @Holiday_days)
                                        SET @Working_Days = @OutOf_Days - (@Weekoff_Days + @Holiday_days) --Change this code by Sumit after discussion with Hardik bhai case of mid joining case in Ifedora for Day Rate tick mark in general setting on 09/11/2016
                                        SET @Working_Days_Day_rate = @OutOf_Days - (@Weekoff_Days_DayRate + @Holiday_Days_DayRate)  --@Holiday_days  changed by jimit for Webcluz case 12122019 redmine 4136
                                    End
                                Else
                                    Begin
                                        SET @Working_Days = @OutOf_Days
                                        SET @Working_Days_Day_rate =@OutOf_Days-- @Working_Days  --Commented By Ramiz as in Case of 26 Days also , it was going to 27      
                                    End     
                                
                                      
                                If @OutOf_Days_Arear > 0 
                                    Begin
                                        SET @Working_days_Arear = @OutOf_Days_Arear - (@Weekoff_Days_Arear + @Holiday_Days_Arear)    -- Added by Hardik 21/05/2014
                                    End
                                    
                                If @OutOf_Days_Arear_Cutoff > 0 
                                    Begin
                                        SET @Working_days_Arear_cutoff = @OutOf_Days_Arear_Cutoff - (@Weekoff_Days_Arear_cutoff + @Holiday_Days_Arear_Cutoff)    -- Added by Hardik 21/05/2014
                                    End
                                    
                                    
                                --SET @Mid_Inc_Working_Day = @Mid_Inc_Working_Day - (@Weekoff_Days_DayRate + @Holiday_days)       -- added by mitesh on 19062012 for basic salary calculation whene weekoff or holiday is not included
                                 If isnull(@Sal_fix_days,0) = 0 
                                    --SET @Mid_Inc_Working_Day = @Mid_Inc_Working_Day - (@Weekoff_Days_DayRate + @Holiday_days)       -- added by mitesh on 19062012 for basic salary calculation whene weekoff or holiday is not included
                                    SET @Mid_Inc_Working_Day = @Mid_Inc_Working_Day - (@Weekoff_Days + @Holiday_days) --Change day rate to Weekoff days on 09/11/2016 -- Sumit
                                 Else
                                    SET @Mid_Inc_Working_Day=@Working_Days 
                            End
                        else
                            Begin
                                
                                --SET @Working_Days = @OutOf_Days - (@Weekoff_Days_DayRate)
                                If isnull(@Sal_fix_days,0) = 0
                                    Begin
                                        SET @Working_Days =  @OutOf_Days - (@Weekoff_Days) --
                                        SET @Working_Days_Day_Rate =  @OutOf_Days - (@Weekoff_Days_DayRate) -- --Change this code by Sumit after discussion with Hardik bhai case of mid joining case in Ifedora for Day Rate tick mark in general setting on 09/11/2016
                                    End 
                                Else
                                    Begin
                                        --SET @Working_Days = @OutOf_Days  + @Holiday_days --It Was Added By Ramiz & Hardik Bhai for Mafatlals
                                        SET @Working_Days = @OutOf_Days  + @Holiday_days --It Was Added By Ramiz & Hardik Bhai for Mafatlals
                                        Set @Working_Days_Day_Rate = @OutOf_Days - (@Holiday_Days_DayRate) --@Working_Days --Commented By Ramiz as in Case of 26 Days also , it was going to 27
                                    End
                                    
                                                                
                                If @OutOf_Days_Arear > 0 
                                    Begin
                                        SET @Working_days_Arear = @OutOf_Days_Arear - (@Weekoff_Days_Arear)    -- Added by Hardik 21/05/2014   
                                    End
                                
                                If @OutOf_Days_Arear_Cutoff > 0 
                                    Begin
                                        SET @Working_days_Arear_cutoff = @OutOf_Days_Arear_Cutoff - (@Weekoff_Days_Arear_cutoff)    -- Added by Hardik 21/05/2014   
                                    End 
                                    
                                    
                                --SET @Mid_Inc_Working_Day = @Mid_Inc_Working_Day - (@Weekoff_Days_DayRate)       
                   If isnull(@Sal_fix_days,0) = 0  
                                    SET @Mid_Inc_Working_Day = @Mid_Inc_Working_Day - (@Weekoff_Days)
                                Else
                                    SET @Mid_Inc_Working_Day = @Working_Days
                            End 
                    End 
                else  
                    BEGIN    
                        if @Inc_Holiday <>1  
                            BEGIN 
                                SET @Working_Days = @OutOf_Days -  @Holiday_days
                                SET @Working_days_Day_Rate = @Working_Days
                                If @OutOf_Days_Arear > 0 
                                    Begin
                                        SET @Working_days_Arear = @OutOf_Days_Arear - @Holiday_Days_Arear    -- Added by Hardik 21/05/2014   
                                    End
                                If @OutOf_Days_Arear_Cutoff > 0 
                                    Begin
                                        SET @Working_days_Arear_cutoff = @OutOf_Days_Arear_Cutoff - @Holiday_Days_Arear_Cutoff    -- Added by Hardik 21/05/2014   
                                    End 
                                    
                                SET @Mid_Inc_Working_Day = @Mid_Inc_Working_Day - (@Holiday_days)       
                            End 
                        else
                            BEgin
                            
                                SET @Working_Days = @OutOf_Days 
                                SET @Working_days_Day_Rate = @Working_Days
                                If @OutOf_Days_Arear > 0 
                                    Begin
                                        SET @Working_days_Arear = @OutOf_Days_Arear -- Added by Hardik 21/05/2014   
                                    End
                                If @OutOf_Days_Arear_Cutoff > 0 
                                    Begin
                                        SET @Working_days_Arear_cutoff = @OutOf_Days_Arear_Cutoff -- Added by Hardik 21/05/2014   
                                    End     
                                SET @Mid_Inc_Working_Day = @Mid_Inc_Working_Day 
                            End 
                    End 


                --added by Hardik 06/05/2015 for Nirma 
                If exists (Select 1 from T0200_MONTHLY_SALARY where Month(Month_End_Date)= @Arear_Month and Year(Month_End_Date)= @Arear_Year  and Emp_id = @Emp_id)
                    Begin  
                        Select @Working_days_Arear = Working_Days,@Working_days_Arear_cutoff = Working_Days from dbo.T0200_MONTHLY_SALARY where Month(Month_End_Date) = @Arear_Month and Year(Month_End_Date) = @Arear_Year and Emp_id = @Emp_id
                    End

                if @SalaryBasis ='Hour'    
                BEGIN    
                    SET @Leave_Sec = @Paid_Leave_Days * @Shift_Day_Sec  
                    if @Inc_Holiday = 1
                        SET @Holiday_Sec = @Holiday_Days * @Shift_Day_Sec    
                    if @Inc_Weekoff =1    
                        SET @Weekoff_Sec = @WeekOff_Days * @Shift_Day_Sec    
                    
                    SET @Other_Working_Sec = @Leave_Sec + @Holiday_Sec + @Weekoff_Sec    
                   
                    select @Working_Hours = dbo.F_Return_Hours (@Other_Working_Sec)    
                end    
              
                if @is_weekoff_hour = 1 and isnull(@weekoff_hours,'00:00') <> '00:00'
                    begin   
                        declare @hours NUMERIC(18, 4)
                        declare @w_hours NUMERIC(18, 4)
                        declare @weekoff numeric
                        
                        SET @hours = CONVERT(decimal(10,2), @Actual_Working_Sec/3600)
                        SET @w_hours = CONVERT(decimal(10,2),dbo.F_Return_Sec(@weekoff_hours)/3600)
                        
                        SET @weekoff = floor(@hours/@w_hours)
                        SET @Weekoff_Days = @weekoff
                    end
            
                -------------------- Late Deduction ---------------------------    

                select @Late_Adj_Day =  isnull(Late_Adj_Day,0)   , @Gen_Id = Gen_ID  ,  @Late_is_slabwise = isnull(is_Late_Calc_Slabwise,0),
                @Is_Late_Calc_HO_WO = ISNULL(Is_Late_Calc_On_HO_WO,0), 
				@Is_Early_Calc_HO_WO = ISNULL(Is_Early_Calc_On_HO_WO,0),
                @Late_Mark_Scenario = ISNULL(Late_Mark_Scenario,1),
                @Is_LateMark_Percent = ISNULL(Is_Latemark_Percentage,0),
                @Is_LateMark_Calc_On = ISNULL(Is_Latemark_Cal_On,0),
				@Early_Mark_Scenario = ISNULL(Early_Mark_Scenario,1),
                @Is_EarlyMark_Percent = ISNULL(Is_Earlymark_Percentage,0),
                @Is_EarlyMark_Calc_On = ISNULL(Is_Earlymark_Cal_On,0),
				@LateEarly_Combine = ISNULL(LateEarly_Combine,0),
				@LateEarly_MonthWise = ISNULL(LateEarly_MonthWise,0)
                from T0040_General_Setting where Cmp_ID = @Cmp_ID and Branch_ID =@Branch_ID and For_date = (select max(for_date) From T0040_General_Setting     
                where Cmp_ID = @Cmp_ID and For_Date <=@Month_end_Date and Branch_ID =@Branch_ID)  


                SET @Late_Absent_Day = 0    
                SET @Total_LMark = 0    
                SET @Total_Late_Sec =0    
                SET @Late_Dedu_Amount = NULL;
                SET @Extra_Late_Dedu_Amount = NULL;
                SET @late_Extra_Amount = NULL;
                SET @Late_is_slabwise = NULL;
                SET @Is_Late_Calc_HO_WO = NULL;
                SET @Is_Early_Calc_HO_WO = NULL; 
                    


                if @Fix_late_W_Days =0 and @Wages_Type = 'Monthly'    
                    SET @Fix_late_W_Days = @OutOf_Days    
                else if @Wages_Type <> 'Monthly'    
                    SET @Fix_late_W_Days = 1     

                   
                  
                if @Fix_late_W_Shift_Sec =0    
                    SET @Fix_late_W_Shift_Sec =@Shift_Day_Sec         
                
                -- Added By Hardik 10/09/2012
                --Declare @Emp_Late_Mark as int
                --Declare @Emp_Early_Mark As int
                --SET @Emp_Late_Mark = 0
                
                --Select @Emp_Late_Mark = isnull(Emp_Late_Mark,0) 
                --from T0095_Increment I Where I.Emp_ID = @emp_ID and Increment_Id =@Increment_ID
                
                SET @Absent_date_String = ''
                SET @Cur_Weekoff_Sec = 0
                SET @Cur_Holiday_Sec = 0
                  --Added by Gadriwala Muslim 24062015 - Start 
   
                declare curCheckAbsent cursor fast_forward for 
                select For_Date,Weekoff_OT_Sec,Holiday_OT_Sec from #Data 
                where Emp_Id = @Emp_Id and For_date >= @Month_St_Date and For_date <= @CutoffDate_Salary and P_days = 0
                open curCheckAbsent
                Fetch next from curCheckAbsent into @Absent_For_date,@Cur_WeekOff_Sec,@Cur_Holiday_Sec  
                    while @@FETCH_STATUS = 0 
                        begin
                             if not @Is_Late_Calc_HO_WO = 1 and (@Cur_Weekoff_Sec > 0 or @Cur_Holiday_Sec > 0)
                                begin
                                    
                                     if @Absent_date_String = '' 
                                        SET @Absent_date_String = cast(@Absent_For_date as varchar(25))
                                     else
                                        SET @Absent_date_String = @Absent_date_String + '#' +  cast(@Absent_For_date as varchar(25))    
                                end
                                
                            If  (@Cur_Weekoff_Sec = 0 AND @Cur_Holiday_Sec = 0)     /* IF Employee Has Absent then Not count LateMark   --Muslimbhai & Ankit 04122015 after discuss with Hardikbhai */
                                BEGIN
                                    
                                     if @Absent_date_String = '' 
                                        SET @Absent_date_String = cast(@Absent_For_date as varchar(25))
                                     else
                                        SET @Absent_date_String = @Absent_date_String + '#' +  cast(@Absent_For_date as varchar(25)) 
                                END 
                                
                            Fetch next from curCheckAbsent into @Absent_For_date,@Cur_WeekOff_Sec,@Cur_Holiday_Sec
                        end
                close curCheckAbsent
                deallocate curcheckAbsent   
                --Added by Gadriwala Muslim 24062015 - End
                
				

                If @Is_Late_Mark = 1 And @Is_Late_Mark_Gen = 1 and @Is_Manual_Present = 0 -- Added By Hardik 10/09/2012
                    Begin
                        if @Late_Mark_Scenario = 2 and @Is_LateMark_Percent = 0 
                            Begin
                                exec SP_CALCULATE_LATE_DEDUCTION_SLABWISE @emp_Id,@Cmp_ID,@T_MONTH_START_DATE,@T_MONTH_END_DATE,@Late_Absent_Day output,@Total_LMark output,@Total_Late_Sec output,@Increment_ID,@StrWeekoff_Date,@StrHoliday_Date,0,'',0,@Absent_date_String,0,@Total_Late_OT_Hours output   
                            End
                        Else if @Late_Mark_Scenario = 2 and @Is_LateMark_Percent = 1 and @Is_LateMark_Calc_On <> 0
                            Begin
                                exec SP_CALCULATE_LATE_DEDUCTION_PERCENTAGE @emp_Id,@Cmp_ID,@T_MONTH_START_DATE,@T_MONTH_END_DATE,@Increment_ID,@StrWeekoff_Date,@StrHoliday_Date,0,0,@Absent_date_String,@Sal_Tran_ID,@tmp_Month_St_Date,@tmp_Month_End_Date
                            End
                        Else if @Late_Mark_Scenario = 3
                            Begin
                                exec SP_CALCULATE_LATE_DEDUCTION_DESIGNATION_WISE @emp_Id,@Cmp_ID,@T_MONTH_START_DATE,@T_MONTH_END_DATE,@Increment_ID,@StrWeekoff_Date,@StrHoliday_Date,0,0,@Absent_date_String,@Sal_Tran_ID,@tmp_Month_St_Date,@tmp_Month_End_Date
                            End
						Else if @Late_Mark_Scenario = 4
                            Begin
								exec SP_CALCULATE_LATE_DEDUCTION_SCENARIO4 @emp_Id,@Cmp_ID,@T_MONTH_START_DATE,@T_MONTH_END_DATE,@Late_Absent_Day output,@Increment_ID,@StrWeekoff_Date,@StrHoliday_Date,0,'',0,@Absent_date_String
							End
                        Else
                            Begin   
                                if @Late_Early_Ded_Combine = 1
                                    Begin
                                        Declare @var_Return_Early_Date Varchar(100)
                                        exec SP_CALCULATE_LATE_EARLY_DEDUCTION_COMBINE @emp_Id,@Cmp_ID,@T_MONTH_START_DATE,@T_MONTH_END_DATE,@Late_Absent_Day output,@Total_LMark output,@Total_Late_Sec output,@Increment_ID,@StrWeekoff_Date,@StrHoliday_Date,0,'',0,@Absent_date_String,0,0,@Sal_Tran_ID
                                    End
                                Else
                                    Begin
                                        exec SP_CALCULATE_LATE_DEDUCTION @emp_Id,@Cmp_ID,@T_MONTH_START_DATE,@T_MONTH_END_DATE,@Late_Absent_Day output,@Total_LMark output,@Total_Late_Sec output,@Increment_ID,@StrWeekoff_Date,@StrHoliday_Date,0,'',0,@Absent_date_String,0,@total_count_all_incremnet,@Mid_Inc_Late_Mark_Count
										
										--Added By Jimit 07112019  As mid increment case Late Mark Count is not calculate correctly Kich
										Set @Mid_Inc_Late_Mark_Count =  @Total_LMark 								
										if @cnt = 1 and @total_count_all_incremnet > 1
											Begin 
												Set @Late_Absent_Day = 0
											End
										 --Ended
									End
                            End
                    End
            
				--Century Enka Late Early Scenario 2 Develop by Jignesh bhai 20-03-2024

						----------------------- jignesh patel 01-Dec-2021---------------
					if @Late_Mark_Scenario = 2  and @LateEarly_MonthWise = 0 and  Exists(select 1 from T0050_GENERAL_LATEMARK_SLAB where DEDUCTION_TYPE = 'Hours' and CMP_ID = @Cmp_ID)
						begin
								IF Object_ID('tempdb..#Emp_Late_Early') Is not null
								Begin
									Drop Table #Emp_Late_Early
								End
			
							Create Table #Emp_Late_Early
							(
								Cmp_ID Numeric,
								Emp_ID Numeric,
								For_Date Datetime,  
								In_Time  Datetime,
								Out_Time Datetime,
								Shift_St_Time Datetime,
								Shift_End_Time Datetime,
								Late_Sec Numeric,
								Early_Sec Numeric,
								Late_Limit Varchar(10),
								Early_Limit Varchar(10),
								Late_Deduction Numeric(3,2),
								Early_Deduction Numeric(3,2),
								ExemptFlag char(5) NULL
							)
				
		
				
								exec SP_CALCULATE_LATE_EARLY_DEDUCTION_COMBINE_MULTIPLE_EXEMPT @Emp_ID,@Cmp_ID,@T_MONTH_START_DATE,@T_MONTH_END_DATE,@Late_Absent_Day output
								,@Total_LMark output,@Total_Late_Sec output,@Increment_ID,@StrWeekoff_Date,@StrHoliday_Date,0,'',0,'',0,1 --Changes by ronakk 17052023

								

								SELECT   
										@Late_Absent_Day = 
										ROUND((Isnull(sum([dbo].[F_Return_Sec](replace(Late_Deduction,'.',':')) ),0) + 
										Isnull(sum([dbo].[F_Return_Sec](replace(Early_Deduction,'.',':')) ),0)) / (3600*8),2),
										@Total_Late_Sec = Isnull(sum([dbo].[F_Return_Sec](replace(Late_Deduction,'.',':')) ),0)
										+Isnull(sum([dbo].[F_Return_Sec](replace(Early_Deduction,'.',':')) ),0)
										 from #Emp_Late_Early
								Where Emp_ID = @Emp_ID

							--	select @Late_Absent_Day,@Total_Late_Sec
		
     						---------------------- End --------------------
					
							end
				---- End 20-03-2024
                --Commented by Hardik and Put this line below Late deduct from Leave portion at below side. 03/03/2015                                              
                --SET @Present_Days = @Present_Days - isnull(@Late_Absent_Day,0)
                 
                ----Nilay Late Mark Deduction  ---- 30 may 2009  
                if @Late_Adj_Day < @Total_LMark
                    Begin
                        SET  @late_Extra_Amount=@Total_LMark - isnull(@Late_Adj_Day,0)    
                    end
                Else
                    Begin
                        SET  @late_Extra_Amount=@Total_LMark 
                    end
                
                
                If @SalaryBasis ='Hour'     
                    Begin    
                        SET @Actual_Working_Sec = @Actual_Working_Sec - (isnull(@Late_Absent_Day,0) * @Shift_Day_Sec)    
                        select @Actual_Working_Hours = dbo.F_Return_Hours (@Actual_Working_Sec)    
                    End    
                ----------------------------end -------------------------------    

                -----------------------------Early-------------------Mitesh---
                SET @Early_Adj_Day = 0
                SET @Early_Sal_Dedu_Days = 0    
                SET @Total_EarlyMark = 0    
                SET @Total_Early_Sec =0   
                SET @Early_Dedu_Amount = 0;
                SET @Extra_Early_Dedu_Amount = 0;
                SET @Early_Extra_Amount = 0;             
                SET @Fix_Early_W_Days = 0
                SET @Fix_Early_W_Hours = 0;
                SET @Fix_Early_W_Shift_Sec =0    
                SET @Extra_Early_Deduction = 0   
                SET @Early_is_slabwise = 0;    
               
                select @Early_Adj_Day =  isnull(Early_Adj_Day,0)   ,
                     @Gen_Id = Gen_ID ,  
                     @Early_is_slabwise = isnull(is_Early_Calc_Slabwise,0)
                    from T0040_General_Setting where Cmp_ID = @Cmp_ID and Branch_ID =@Branch_ID and For_date = (select max(for_date) From T0040_General_Setting     
                    where Cmp_ID = @Cmp_ID and For_Date <=@Month_end_Date and Branch_ID =@Branch_ID)  

                if @Fix_Early_W_Days =0 and @Wages_Type = 'Monthly'    
                    SET @Fix_Early_W_Days = @OutOf_Days    
                else if @Wages_Type <> 'Monthly'    
                    SET @Fix_Early_W_Days = 1     



                if @Fix_Early_W_Shift_Sec =0    
                    SET @Fix_Early_W_Shift_Sec =@Shift_Day_Sec  
                
                --   SET @Emp_Early_Mark = 0
                
                If @Is_Early_Mark = 1  and @Is_Manual_Present = 0 and @Late_Early_Ded_Combine = 0 and @Early_Mark_Scenario = 1 -- Added by Hardik 10/09/2012
                    Begin
                        exec SP_CALCULATE_EARLY_DEDUCTION @emp_Id,@Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Early_Sal_Dedu_Days output,@Total_EarlyMark output,@Total_Early_Sec output,@Increment_ID,@StrWeekoff_Date,@StrHoliday_Date,0,'',0,@Absent_date_String,@total_count_all_incremnet,@Mid_Inc_Early_Mark_Count

					--Added By Jimit 07112019  As mid increment case Early Mark Count is not calculate correctly Kich
						Set @Mid_Inc_Early_Mark_Count =  @Total_EarlyMark 								
						if @cnt = 1 and @total_count_all_incremnet > 1
							Begin 
								Set @Early_Sal_Dedu_Days = 0
							End

							
							--Ended
                    End
				Else if @Early_Mark_Scenario = 2 and @Is_EarlyMark_Percent = 1 and @Is_EarlyMark_Calc_On <> 0
                    Begin
                        exec SP_CALCULATE_EARLY_DEDUCTION_PERCENTAGE @emp_Id,@Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Increment_ID,@StrWeekoff_Date,@StrHoliday_Date,0,0,@Absent_date_String,@Sal_Tran_ID,@tmp_Month_St_Date,@tmp_Month_End_Date
                    End
    
	
                --Commented by Hardik and Put this line below Late deduct from Leave portion at below side. 03/03/2015                                              
                --SET @Present_Days = @Present_Days - isnull(@Early_Sal_Dedu_Days,0)
                
                If @SalaryBasis ='Hour'     
                   Begin    
                        SET @Actual_Working_Sec = @Actual_Working_Sec - (isnull(@Early_Sal_Dedu_Days,0) * @Shift_Day_Sec)    
                        select @Actual_Working_Hours = dbo.F_Return_Hours (@Actual_Working_Sec)    
                   End   
                       
                -----------------------------Early--End--------------------------

                if @Present_Days > @Working_Days and @Restrict_Present_Days = 'Y'    
                    begin    
                        SET @Present_Days = @Working_Days    
                    end    

                
				
                SET @Total_Total_Sec = 0;
                SET @Total_penalty_days = 0;
                
                
                SET @Total_Late_Hours = dbo.F_Return_Hours(@Total_Late_Sec)
                SET @Total_Early_Hours = dbo.F_Return_Hours(@Total_Early_Sec)
                SET @Total_LE_Hours = dbo.F_Return_Hours(@Total_Late_Sec + @Total_Early_Sec)
                SET @Total_Days_Adjust = 0
                SET @tmp_Days_Adjust = 0

                -------------chirag for slab day
                if  @Late_Dedu_Type_inc = 'Day' or @Early_Dedu_Type_inc = 'Day'
                    Begin   
                        if @Late_is_slabwise  = 0
                            begin
                               SET @Total_LMark=0
                            end
                        else
                            begin
                              SET @Total_LMark=isnull(@Total_LMark,0)
                            end
                        if @Early_is_slabwise  = 0
                            begin
                               SET @Total_EarlyMark=0
                            end
                        else
                            begin
                              SET @Total_EarlyMark=isnull(@Total_EarlyMark,0)
                            end
                            
                        SET @Total_LE_Hours=isnull(@Total_LMark,0)+ISNULL(@Total_EarlyMark,0)
                    End
                -------------end chirag for slab day
                
                if @Late_Dedu_Type_inc = 'Day' and Isnull(@Late_is_slabwise,0) = 0 and @Is_late_Mark=1 And @Is_Late_Mark_Gen = 1 ---chirag for slab day add and @Late_is_slabwise = 0 
                    begin
						
                        -- LATE with leave
                        exec ADJUST_LATE_EARLY_WITH_LEAVE @emp_Id,@Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Late_Absent_Day output,@Increment_ID,'L',@tmp_Days_Adjust output    
                        SET @Total_Days_Adjust = @Total_Days_Adjust + @tmp_Days_Adjust
                        SET @tmp_Days_Adjust = 0
                    end
                     
                if @Early_Dedu_Type_inc = 'Day' and @Early_is_slabwise = 0 and @Is_Early_Mark=1 ---chirag for slab add day add @Early_is_slabwise = 0
                    begin
                        -- early with leave
                        exec ADJUST_LATE_EARLY_WITH_LEAVE @emp_Id,@Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Early_Sal_Dedu_Days output,@Increment_ID,'E',@tmp_Days_Adjust output    
                        SET @Total_Days_Adjust = @Total_Days_Adjust + @tmp_Days_Adjust
                        SET @tmp_Days_Adjust = 0
                    end
                

                --SET @Present_Days = @Present_Days - isnull(@Late_Absent_Day,0)        --Commented By Nimesh On 14-Sep-2018 (@Late_Absent_Day value already getting deducted from @Present_Days in bottom line)
                --SET @Present_Days = @Present_Days - isnull(@Early_Sal_Dedu_Days,0)    --Commented By Nimesh On 14-Sep-2018 (Added Code to deduct @Early_Sal_Dedu_Days value at the bottom)

                
                --  if @Late_is_slabwise = 1 and @Early_is_slabwise = 1 and @Early_Dedu_Type_inc = 'Hour' and @Late_Dedu_Type_inc = 'Hour' and @Is_Early_Mark = 1 and @Is_late_Mark = 1
                if( @Late_is_slabwise = 1 and @Is_late_Mark = 1 And @Is_Late_Mark_Gen = 1) or( @Early_is_slabwise = 1  and @Is_Early_Mark = 1)  --chirag for slab day remove and @Early_Dedu_Type_inc = 'Hour' and @Late_Dedu_Type_inc = 'Hour' 
                    begin
                        exec SP_GET_LATE_EARLY_SLABWISE @Cmp_ID,@Gen_Id,@Total_LE_Hours ,@Total_penalty_days output,0               
                        SET @Penalty_days_Early_Late = @Total_penalty_days
                        
                        -- Penalty with leave
                        exec ADJUST_LATE_EARLY_WITH_LEAVE @emp_Id,@Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Penalty_days_Early_Late output,@Increment_ID,'LE',@tmp_Days_Adjust output        
                
                        SET @Total_Days_Adjust = @Total_Days_Adjust + @tmp_Days_Adjust
                        SET @tmp_Days_Adjust = 0
                        
                        --- If slabwise then individual amount should be 0 ------
                        SET @Late_Dedu_Amount = 0
                        SET @Extra_Late_Dedu_Amount = 0
                        SET @Total_Late_Sec = 0
                        
                        SET @Early_Dedu_Amount = 0
                        SET @Extra_Early_Dedu_Amount = 0
                        SET @Total_Early_Sec = 0
                        
                    end
                --else if @Late_is_slabwise = 1 and @Is_late_Mark = 1 And @Is_Late_Mark_Gen = 1 --chirag for slab day remove and @Late_Dedu_Type_inc = 'Hour' 
                --  begin
                --      exec SP_GET_LATE_EARLY_SLABWISE @Cmp_ID,@Gen_Id,@Total_Late_Hours,@Total_penalty_days output,0
                --      SET @Late_Absent_Day = @Total_penalty_days
                --      -- LATE with leave
                --      exec ADJUST_LATE_EARLY_WITH_LEAVE @emp_Id,@Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Late_Absent_Day output,@Increment_ID,'L',@tmp_Days_Adjust output    
                        
                --      SET @Total_Days_Adjust = @Total_Days_Adjust + @tmp_Days_Adjust
                --      SET @tmp_Days_Adjust = 0
                        
                --      SET @Late_Dedu_Amount = 0
                --      SET @Extra_Late_Dedu_Amount = 0
                --      SET @Total_Late_Sec = 0
                        
                --  end
                --else if @Early_is_slabwise = 1 and @Is_Early_Mark = 1 --chirag for slab day remove and @Early_Dedu_Type_inc = 'Hour'
                --  begin
                --      exec SP_GET_LATE_EARLY_SLABWISE @Cmp_ID,@Gen_Id,@Total_Early_Hours,@Total_penalty_days output,0 
                --      SET @Early_Sal_Dedu_Days = @Total_penalty_days
                    
                --      -- early with leave
                --      exec ADJUST_LATE_EARLY_WITH_LEAVE @emp_Id,@Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Early_Sal_Dedu_Days output,@Increment_ID,'E',@tmp_Days_Adjust output
                        
                --      SET @Total_Days_Adjust = @Total_Days_Adjust + @tmp_Days_Adjust
                --      SET @tmp_Days_Adjust = 0
                                    
                --      SET @Early_Dedu_Amount = 0
                --      SET @Extra_Early_Dedu_Amount = 0
                --      SET @Total_Early_Sec = 0            
                --  end 
                                
                /*Following Code moved by Nimesh on 14-Sep-2018 from below to here to put all Late/Early Deduction logic together*/
                SET @total_Present_Days = @total_Present_Days  + @Present_Days -- added by mitesh to check zero day salary
                --SET @Present_Days = @Present_Days - isnull(@Total_penalty_days,0) - ISNULL(@GatePass_Deduct_Days,0) - isnull(@Total_Days_Adjust,0)   -- added by rohit for absent days showing negative and total penalty minus from present day with adjust with leave on 28122016
                -- Comment by nilesh patel on 30062018 For Example - 8 Day Late Early Penalty and 5 Day adjust against leave and remaing 3 days are not consider in Absent so add this condition isnull(@Late_Absent_Day,0)
                SET @Present_Days = @Present_Days - isnull(@Total_penalty_days,0) - ISNULL(@GatePass_Deduct_Days,0) - isnull(@Total_Days_Adjust,0) - isnull(@Late_Absent_Day,0) - IsNull(@Early_Sal_Dedu_Days, 0)   -- added by rohit for absent days showing negative and total penalty minus from present day with adjust with leave on 28122016
				
				
			
                SET @Absent_Days = @Absent_Days + isnull(@Total_penalty_days,0) + isnull(@Late_Absent_Day,0) 
                    
					--select @Absent_Days
					           
                Declare @OD_Compoff_As_Present tinyint
                SET @OD_Compoff_As_Present = 0
                
                Select @OD_Compoff_As_Present = Isnull(Setting_Value,0) From T0040_SETTING Where Cmp_ID = @Cmp_ID And Setting_Name='OD and CompOff Leave Consider As Present'
                
                                
                if (@OD_Compoff_As_Present = 1)
                    select @Total_leave_Days = isnull(sum(leave_Days),0) 
                    from T0210_Monthly_LEave_Detail M INNER JOIN T0040_LEAVE_MASTER L ON M.Leave_ID=L.Leave_ID
                    where Emp_ID = @emp_ID and     
                    TEMP_SAL_TRAN_ID = @Sal_Tran_ID and M_Leave_Tran_ID not in (select * from #Total_leave_Id) and M.Cmp_Id=@Cmp_ID 
                    and M.Leave_Type <> 'Company Purpose' And Isnull(L.Default_Short_Name,'') <> 'COMP'
                ELSE
                    select @Total_leave_Days = isnull(sum(leave_Days),0) 
                    from T0210_Monthly_LEave_Detail where Emp_ID = @emp_ID and     
                    TEMP_SAL_TRAN_ID = @Sal_Tran_ID and M_Leave_Tran_ID not in (select * from #Total_leave_Id) and Cmp_Id=@Cmp_ID 
                        
                  
                            
                --select @Total_leave_Days = isnull(sum(leave_Days),0) from T0210_Monthly_LEave_Detail where Emp_ID = @emp_ID and     
                --TEMP_SAL_TRAN_ID = @Sal_Tran_ID and M_Leave_Tran_ID not in (select * from #Total_leave_Id) and Cmp_Id=@Cmp_ID 
                --     select @Paid_Leave_Days = isnull(sum(leave_Days),0) from T0210_Monthly_LEave_Detail where Emp_ID = @emp_ID and     
                --        TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Leave_Paid_Unpaid = 'P'  and M_Leave_Tran_ID not in (select * from #Total_leave_Id)
                            
                SELECT @Paid_Leave_Days = isnull(sum(leave_Days),0) from T0210_Monthly_LEave_Detail M Inner Join
                    T0040_Leave_Master L on M.Leave_Id = L.Leave_Id
                where Emp_ID = @emp_ID and       
                TEMP_SAL_TRAN_ID = @Sal_Tran_ID and M.Leave_Paid_Unpaid = 'P' and M.Leave_Type <> 'Company Purpose' --and Leave_type <> 'Encashable'
                and M_Leave_Tran_ID not in (select * from #Total_leave_Id) and M.Cmp_Id=@Cmp_ID 
                And Isnull(L.Default_Short_Name,'') <> 'COMP'

				-- Deepal ST :- 30/11/2022 Getting the count Week off base on salary generate date.19604
				DECLARE @PaidLeave as int = 0
				IF ((SELECT SETTING_VALUE FROM T0040_SETTING WHERE CMP_ID = @CMP_ID AND  SETTING_NAME = 'COUNT OF ACTUAL DAY SALARY IN CURRENT MONTH') = 1)
				BEGIN
						SELECT @PaidLeave = Count(1) from T0110_LEAVE_APPLICATION_DETAIL L inner join T0040_LEAVE_MASTER LM on L.Leave_ID = LM.Leave_ID
						WHERE Leave_Application_ID in (select Leave_Application_ID from T0100_LEAVE_APPLICATION where emp_id=@emp_id and cmp_id = @cmp_id and From_Date > cast(getdate() as date))
						and Leave_Paid_Unpaid = 'P'
						IF cast(@Paid_Leave_Days as int) >= cast(@PaidLeave as int)
							SET @Paid_Leave_Days = cast(@Paid_Leave_Days as int) - cast(@PaidLeave as int)
				END
				-- Deepal ST :- 30/11/2022 Getting the count Week off base on salary generate date.19604
                
                --Added by hasmukh for sapration of actual paid leave & Out duty type leave 17012012                        
                SELECT @OD_leave_Days = isnull(sum(leave_Days),0) from T0210_Monthly_LEave_Detail M Inner Join
                    T0040_Leave_Master L on M.Leave_Id = L.Leave_Id
                where Emp_ID = @emp_ID and       
                TEMP_SAL_TRAN_ID = @Sal_Tran_ID and M.Leave_Paid_Unpaid = 'P' and M.Leave_Type = 'Company Purpose' 
                and M_Leave_Tran_ID not in (select * from #Total_leave_Id) and M.Cmp_Id=@Cmp_ID 
                And Isnull(L.Default_Short_Name,'') <> 'COMP'
            ----------hasmukh OD leave                

                --Added by Hardik 22/07/2014 for Adding OD and Compoff Leave in Present Day (Magottaux Requirement)
                SELECT @Compoff_leave_Days = isnull(sum(leave_Days),0) from T0210_Monthly_LEave_Detail M Inner Join
                    T0040_Leave_Master L on M.Leave_Id = L.Leave_Id
                where Emp_ID = @emp_ID and       
                TEMP_SAL_TRAN_ID = @Sal_Tran_ID 
                and M_Leave_Tran_ID not in (select * from #Total_leave_Id) and M.Cmp_Id=@Cmp_ID 
                And Isnull(L.Default_Short_Name,'') = 'COMP'

                
                If @OD_Compoff_As_Present = 1
                    Begin                    
                        SET @Present_Days = @Present_Days + ISNULL(@OD_leave_Days,0) + ISNULL(@Compoff_Leave_Days,0)
                        SET @OD_leave_Days = 0                                              
                    End
                Else
                    Begin
                        SET @Paid_Leave_days = Isnull(@Paid_Leave_days,0) + Isnull(@Compoff_Leave_Days,0)                       
                    End
                SET @Compoff_Leave_Days = 0
                
				/*Added By Nimesh On 04-Oct-2018 (Hourly Leave is getting added and its reflecting round value with 0.01)*/
				if @Present_Days % 0.25 > 0 
					BEGIN
						IF (@Present_Days % 0.25) < 0.125
							set @Present_Days = @Present_Days - (@Present_Days % 0.25)
						ELSE
							set @Present_Days = @Present_Days - (@Present_Days % 0.25) + 0.25
					END


                --Alpesh 4-Aug-2012
                SELECT @Unpaid_leave_Days = isnull(sum(leave_Days),0) from T0210_Monthly_LEave_Detail where Emp_ID = @emp_ID and       
                TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Leave_Paid_Unpaid = 'U' and Leave_Type <> 'Company Purpose'
                and M_Leave_Tran_ID not in (select * from #Total_leave_Id) and Cmp_Id=@Cmp_ID 
                   
                  
                insert into #Total_leave_Id               
                select M_Leave_Tran_ID from T0210_Monthly_LEave_Detail where Emp_ID = @emp_ID and     
                TEMP_SAL_TRAN_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID 
      
                
				Declare @WOHO_OD_Leave_Count numeric(18,5)
				Set @WOHO_OD_Leave_Count = 0

				If @Is_OT = 0 Or @Emp_OT = 0 --- For Vivo Rajasthan as OD Leave Adjust with Absent, Hardik 05/02/2019
					Select @WOHO_OD_Leave_Count = Isnull(Sum(Leave_Used),0) From T0140_LEAVE_TRANSACTION LT 
					Where Emp_Id=@Emp_ID And For_Date Between @tmp_Month_St_Date And @tmp_Month_End_Date 
						And Exists (Select 1 From T0040_LEAVE_MASTER LM Where LT.Leave_Id = LM.Leave_Id And LM.Leave_Type = 'Company Purpose')
						And (Exists (Select 1 From #Emp_Weekoff_Sal EW Where LT.For_Date = EW.For_Date) Or Exists (Select 1 From #Emp_Holiday_Sal EH Where LT.For_Date = EH.For_Date))

				If @WOHO_OD_Leave_Count > 0 --- For Vivo Rajasthan as OD Leave Adjust with Absent, Hardik 05/02/2019
					BEGIN
						Set @Present_Days = @Present_Days + @WOHO_OD_Leave_Count
					END

				
                if  @Present_Days =0 And @Is_Zero_Day_Salary=1 And @Paid_Leave_Days = 0 and @OD_leave_Days = 0 And @Compoff_leave_Days = 0 And @Fix_Salary = 0--NIkunj 07-09-2010   --And @Fix_Salary = 0--Ankit 09052015
                     Begin
                         if @total_count_all_incremnet > 1  -- added by mitesh on 06/01/2012
                            begin
                                if @cnt <> 1
                                    begin
                                        SET @StrHoliday_Date=Null
                                        --SET @Holiday_days=0    --Commented by Ramiz on 21/08/2015
                                        SET @Cancel_Holiday=0 
                                        SET @Cancel_Weekoff=0
                                        --SET @Weekoff_Days=0   --Commented by Ramiz on 21/08/2015 as it was not giving the salary of weekoff on 1st date
                                        SET @StrWeekoff_Date=Null
                                    end
                            end
                         else
                            begin
                                SET @StrHoliday_Date=Null
                                --SET @Holiday_days=0  --Commented by Ramiz on 21/08/2015
                                SET @Cancel_Holiday=0 
                                SET @Cancel_Weekoff=0
                                --SET @Weekoff_Days=0   --Commented by Ramiz on 21/08/2015 as it was not giving the salary of weekoff on 1st date
                                SET @StrWeekoff_Date=Null
                            end
                     End
                
                 /*NIMESH: 15-DEC-2016 (Adjust Late Panelty in Present Days)*/
                
                --IF (@Total_Days_Adjust > 0)  -- commented by rohit for absent days showing negative and total penalty minus from present day with adjust with leave on 28122016   --Added by Muslim 18/03/2015
                --  BEGIN
                --      SET @Present_Days = @Present_Days - @Total_Days_Adjust;
                --      SET @Paid_Leave_Days = @Paid_Leave_Days + @Total_Days_Adjust;
                --      SET @Total_Days_Adjust = 0
                --  END 

                
                
                /*
                --Commented By Ramiz on 03/06/2016 , with discussion with Hardik bhai , as it was Adding Panelty days in Paid Leave , which is wrong
                -- uncommented by rohit penalty shows in paid leave and minus from present days for bma as per discussion with hardik bhai on 28122016 (mail dated:- 27122016) 
                */
                
                SET @Paid_Leave_Days = @Paid_Leave_Days + isnull(@Total_Days_Adjust,0)
                SET @Total_leave_Days = @Total_leave_Days + isnull(@Total_Days_Adjust,0)-- Add by Hasmukh 08012013
                /**/
                
              ---End-- Slabwise calculation for late/early
              
                --If @Inc_Weekoff = 1    
                --SET @Sal_cal_Days = @Present_Days +  @Weekoff_Days + @Paid_Leave_Days + @Holiday_Days  
                --Else    
                --SET @Sal_cal_Days = @Present_Days + @Paid_Leave_Days  + @Holiday_Days 
                --changed by Falak on 20-Jan-2011 


                
                If @Wages_Type = 'Monthly'
                    Begin               
                        If @Inc_Weekoff = 1    
                            begin                               
                                if @Inc_Holiday = 1
                                    begin
                                        SET @Sal_cal_Days = @Present_Days +  @Weekoff_Days + @Paid_Leave_Days + @Holiday_Days + @OD_leave_Days + @Compoff_leave_Days
                                    end
                                else        
                                    begin
                                        SET @Sal_cal_Days = @Present_Days +  @Weekoff_Days + @Paid_Leave_Days + @OD_leave_Days + @Compoff_leave_Days
                                    end
                            end
                        Else 
                            begin                                                               
                                if @Inc_Holiday = 1                                                                     
                                    SET @Sal_cal_Days = @Present_Days  + @Paid_Leave_Days + @Holiday_Days + @OD_leave_Days + @Compoff_leave_Days
                                else                                            
                                    SET @Sal_cal_Days = @Present_Days  + @Paid_Leave_Days + @OD_leave_Days  + @Compoff_leave_Days                               
                            end
      End
                Else
                    Begin
                        If @Paid_Weekoff_Daily_Wages = 0
                            Begin
                                if @Inc_Holiday = 1
                                    begin
                                        SET @Sal_cal_Days = @Present_Days +  @Paid_Leave_Days + @Holiday_Days + @OD_leave_Days + @Compoff_leave_Days
                                    end
                                else
                                    begin
                                        SET @Sal_cal_Days = @Present_Days +  @Paid_Leave_Days +  @OD_leave_Days + @Compoff_leave_Days
                                    end                                 
                                
                            End
                        Else
                            Begin
                                if @Inc_Holiday = 1
                                    begin                                                                               
                                        SET @Sal_cal_Days = @Present_Days +  @Weekoff_Days + @Paid_Leave_Days + @Holiday_Days + @OD_leave_Days + @Compoff_leave_Days
                                    end
                                else
                                    begin                                       
                                        SET @Sal_cal_Days = @Present_Days +  @Weekoff_Days + @Paid_Leave_Days + @OD_leave_Days + @Compoff_leave_Days
                                    end                                 
                            End
                    End
            
    
                -------------Hasmukh absent day SET from join date 04022012------------------------
                Declare @temp_join_date datetime
                Declare @Out_of_day_before_join NUMERIC(18, 4)

                SET @temp_join_date = ''
                SET @Out_of_day_before_join = 0

                select  @temp_join_date = Date_Of_Join,@Extra_AB_Rate = Extra_AB_Deduction , @is_emp_lwf = Is_LWF 
                from    T0080_EMP_MASTER 
                where   Emp_ID = @Emp_Id and Cmp_ID=@Cmp_ID

                if @temp_join_date between @Month_St_Date And @Month_End_Date
                    SET @Out_of_day_before_join = DATEDIFF(D,@Month_St_Date,@temp_join_date)
                -----------------------------------------------------------------------------------  
             
                IF EXISTS(SELECT  1 FROM #EMP_WEEKOFF_SAL WHERE EMP_ID=@Emp_Id AND FOR_DATE < @temp_join_date AND FOR_DATE >= @Month_St_Date)
					AND @Out_of_day_before_join >0 AND @Allowed_Full_WeekOff_MidJoining NOT IN (0,2)
					SET @Out_of_day_before_join = @Out_of_day_before_join - (SELECT SUM(1) FROM #EMP_WEEKOFF_SAL WHERE EMP_ID=@Emp_Id AND FOR_DATE < @temp_join_date AND FOR_DATE >= @Month_St_Date)
                --Added by Nilay on 29042013
                Declare @OutOf_Days_left as NUMERIC(18, 4) -- Added by Hardik 30/04/2013
                SET @OutOf_Days_left = 0  -- Added by Hardik 30/04/2013
                
                if @Left_Date between @tmp_Month_St_Date And @tmp_Month_End_Date
                    SET @OutOf_Days_left = datediff(d,@Left_Date,@Month_End_Date)    -- Added by Hardik 30/04/2013                      
                

				IF EXISTS(SELECT  1 FROM #EMP_WEEKOFF_SAL WHERE EMP_ID=@Emp_Id AND FOR_DATE > @Left_Date AND FOR_DATE <= @tmp_Month_End_Date)
					AND @OutOf_Days_left > 0 AND @Allowed_Full_WeekOff_MidJoining NOT IN (0,1)
					SET @OutOf_Days_left = @OutOf_Days_left - (SELECT SUM(1) FROM #EMP_WEEKOFF_SAL WHERE EMP_ID=@Emp_Id AND FOR_DATE > @Left_Date AND FOR_DATE <= @tmp_Month_End_Date)
                
                ---Added by Hardik 23/03/2015 for Vital Soft as they want to show All Half Paid leave in Count and don't want to show Absent Days. 
                DECLARE @Total_Half_Paid_Leave as NUMERIC(18, 4)
                
                SELECT @Total_Half_Paid_Leave = Isnull(SUM(Leave_Used),0) from T0140_LEAVE_TRANSACTION where emp_id=@emp_id and For_Date >= @month_St_Date and For_Date <= @Month_End_Date and
                Leave_Id in (Select Leave_Id From T0040_LEAVE_MASTER where cmp_id=@cmp_Id and Isnull(Half_Paid,0)=1) and Isnull(Half_Payment_Days,0)=0
             
                if @Total_Half_Paid_Leave > 0
                    BEGIN
                        SET @Total_leave_Days = @Total_leave_Days + (ISNULL(@Total_Half_Paid_Leave,0)/2)
                        SET @Paid_leave_Days = @Paid_leave_Days + (ISNULL(@Total_Half_Paid_Leave,0)/2)
                    End
                ---- End by Hardik 23/03/2015

                --/*Following condition added by Nimesh on 05-Oct-2018 
                --Client    : Pramoda
                --Case  : If Include Weekoff is not selected then days in @Mid_Inc_Working_Day variable already calculated without weekoff
                --        and if employee is getting left mid of the month then days in @OutOf_Days_left varible takes including weekoff.
                --        So, following condition is used to remove the weekoff days from @OutOf_Days_left variable
                --        Example: @Mid_Inc_Working_Day = 27 Days, @WeekOff_Days = 4 Days, @Left_Date = '2018-08-10', @OutOf_Days_left = 31-10 = 21 (Including WeekOff & Holiday)
                --*/
                --if @OutOf_Days_left > 0
                --  BEGIN
                --      SELECT  @OutOf_Days_left = @OutOf_Days_left - IsNull(SUM(W_DAY),0)
                --      FROM    #EMP_WEEKOFF_SAL W
                --      WHERE   EMP_ID=@Emp_Id AND FOR_DATE BETWEEN (@Left_Date + 1) AND @Month_End_Date AND IS_CANCEL=0                                                        

                --      SELECT  @OutOf_Days_left = @OutOf_Days_left - IsNull(SUM(H_DAY), 0)
                --      FROM    #EMP_HOLIDAY_SAL H
                --      WHERE   EMP_ID=@Emp_Id AND FOR_DATE BETWEEN (@Left_Date + 1) AND @Month_End_Date AND IS_CANCEL=0                        
                --              AND NOT EXISTS(SELECT 1 FROM #HW_DETAIL_SAL HD WHERE H.EMP_ID=HD.EMP_ID AND H.FOR_DATE=HD.FOR_DATE AND HD.Is_UnPaid=1)      
                --  END
                
                --SET @Absent_Days = @Outof_Days - (@Present_Days +  @WeekOff_Days + @Holiday_Days + @Paid_Leave_Days)    
                If @Wages_Type = 'Monthly'
                    Begin
                        If @Inc_Weekoff = 0  ---Added by Hasmukh 30102013
                            Begin
                                If @Inc_Holiday = 0
                                    Begin
                                        SET @Absent_Days = @Mid_Inc_Working_Day - (@Present_Days + @Paid_Leave_Days + @OD_leave_Days + isnull(@Out_of_day_before_join,0) + Isnull(@OutOf_Days_left,0) + Isnull(@Compoff_leave_Days,0)+ ISNULL(@GatePass_Deduct_Days,0) ) --Added gate pass by Muslim 18/03/2015                                      
                                    End
                                Else
                                    Begin
                                        SET @Absent_Days = @Mid_Inc_Working_Day - (@Present_Days + @Holiday_Days + @Paid_Leave_Days + @OD_leave_Days + isnull(@Out_of_day_before_join,0)+ Isnull(@OutOf_Days_left,0)+ Isnull(@Compoff_leave_Days,0)+ ISNULL(@GatePass_Deduct_Days,0))                                           
                                    End
                            End
                        Else
                            Begin
                                If @Inc_Holiday = 0
                                    Begin
                                        SET @Absent_Days = @Mid_Inc_Working_Day - (@Present_Days +  @WeekOff_Days + @Paid_Leave_Days + @OD_leave_Days + isnull(@Out_of_day_before_join,0)+ Isnull(@OutOf_Days_left,0)+ Isnull(@Compoff_leave_Days,0)+ ISNULL(@GatePass_Deduct_Days,0))                                          
                                    End
                                Else
                                    Begin


                                        SET @Absent_Days = @Mid_Inc_Working_Day - (@Present_Days +  @WeekOff_Days + @Holiday_Days + @Paid_Leave_Days + @OD_leave_Days + isnull(@Out_of_day_before_join,0)+ Isnull(@OutOf_Days_left,0)+ Isnull(@Compoff_leave_Days,0)+ ISNULL(@GatePass_Deduct_Days,0))                                          
                                    End
                            End            ---Added by Hasmukh 30102013 End
                    End
                Else -- Added by Hardik 13/08/2012 for Daily Employee
                    Begin
                        If @Is_Manual_Present = 0 --Added by Hardik 05/01/2016 if manually entered present absent then no need to SET absent days.
                            Begin       
                                If @Paid_Weekoff_Daily_Wages = 0
                                    Begin
                                    
                                    if @Inc_Holiday=1
                                    begin
                                        SET @Absent_Days = @Mid_Inc_Working_Day - (@Present_Days +  @Holiday_Days + @Paid_Leave_Days + @OD_leave_Days + isnull(@Out_of_day_before_join,0)+ Isnull(@OutOf_Days_left,0)+ Isnull(@Compoff_leave_Days,0)+ ISNULL(@GatePass_Deduct_Days,0))
                                    end
                                    else
                                    begin
                                        SET @Absent_Days = @Mid_Inc_Working_Day - (@Present_Days + @Paid_Leave_Days + @OD_leave_Days + isnull(@Out_of_day_before_join,0)+ Isnull(@OutOf_Days_left,0)+ Isnull(@Compoff_leave_Days,0)+ ISNULL(@GatePass_Deduct_Days,0))
                                    end 
                                    
                                    if @Inc_Weekoff = 1 -- change by rohit on 23032017 due to absent days showing Wrong in cera
                                    begin
                                        If @Absent_Days > 0 and @Absent_Days >= @Weekoff_Days
                                            SET @Absent_Days = @Absent_Days - @Weekoff_Days
                                    end
                                        --If @Absent_Days > 0 and @Absent_Days >= @Weekoff_Days
                                        --  SET @Absent_Days = @Absent_Days - @Weekoff_Days
                                        
                                    End
                                Else
                                    Begin
                                        SET @Absent_Days = @Mid_Inc_Working_Day - (@Present_Days +  @WeekOff_Days + @Holiday_Days + @Paid_Leave_Days + @OD_leave_Days + isnull(@Out_of_day_before_join,0)+ Isnull(@OutOf_Days_left,0)+ Isnull(@Compoff_leave_Days,0)+ ISNULL(@GatePass_Deduct_Days,0))
                                    End
                            End
                    End
                --SET @Absent_Days = @Mid_Inc_Working_Day - (@Present_Days +  @Paid_Leave_Days + @OD_leave_Days + isnull(@Out_of_day_before_join,0))    -- changed on 19062012 , already deducted aboce from @Mid_Inc_Working_Day 
                    
					            

                If @Absent_Days < 0    
                    BEGIN
                        if @Present_Days > 0 -- Added by nilesh on 29-03-2018 -- BMA -- Employee Present day is zero & Take 15 OD Leave here Present day consider in -1
                            Begin
                                SET @Present_Days= @Present_Days - ABS(@Absent_Days) --Condition added by Hardik 05/09/2017, for VIVO, Auto Absent Adjust for WO/HO Work for Mid Join/ Mid left case
                            End
                        if @Sal_cal_Days > 0
                            Begin
      SET @Sal_cal_Days= @Sal_cal_Days - ABS(@Absent_Days) --Condition added by Hardik 05/09/2017, for VIVO, Auto Absent Adjust for WO/HO Work for Mid Join/ Mid left case
                            End
                        SET @Absent_Days =0 
                    End
             
                --Hardik 15/10/2012
                If @Sal_cal_Days > @Mid_Inc_Working_Day and @Restrict_Present_Days = 'Y' 
                    SET @Sal_cal_Days = @Mid_Inc_Working_Day
                
                IF @Sal_cal_Days > @Working_Days and @Restrict_Present_Days = 'Y'    
                    SET @Sal_cal_Days = @Working_Days     

                 
                ---Alpesh 20-Mar-2012 for Extra Deduction on Absent     --Alpesh 02-Jul-2012 changed                
                if @Extra_AB_Rate is null
                    Begin
                        SET @Extra_AB_Rate = 0.0
                    End
                
                Declare @Temp_Absent_Days as NUMERIC(18, 4)
                
                SET @Temp_Absent_Days = (@Absent_Days - isnull(@Late_Absent_Day,0)-isnull(@Early_Sal_Dedu_Days,0)-ISNULL(@Unpaid_leave_Days,0))
            
                SET @Extra_AB_Days = ceiling((@Temp_Absent_Days * @Extra_AB_Rate)*2)/2 -- To make upper round 0.5
                
                if @Extra_AB_Days < 0
                    SET @Extra_AB_Days = 0
                
                
                
                --Hardik 10/04/2013 for Extra Absent Deduct from Present Day
                If @Sal_Cal_Days >= @Extra_AB_Days And @Present_Days >= @Extra_AB_Days And @Extra_AB_Days >= 0
                    Begin
                        --SET @Sal_Cal_Days = @Sal_Cal_Days - (@Temp_Absent_Days + Isnull(@Extra_AB_Days,0))
                        --SET @Present_Days = @Present_Days - (@Temp_Absent_Days + Isnull(@Extra_AB_Days,0))
                        
                        SET @Sal_Cal_Days = @Sal_Cal_Days - (Isnull(@Extra_AB_Days,0))
                        --SET @Present_Days = @Present_Days - (Isnull(@Extra_AB_Days,0))
                    End
                Else
                    Begin
                        
                        SET @Sal_Cal_Days = 0
                        --SET @Present_Days = 0
                    End
                
                --Added by nilesh patel on 27042015 --Start For Holiday Compulsory 
                Declare @Extra_AB_Days_Dection NUMERIC(18, 4)
                Declare @Holiday_Start_Date Varchar(20)
                Declare @Holiday_End_Date Varchar(20)

                Declare @Present_Day_on_Holiday NUMERIC(18, 4)
                SET @Present_Day_on_Holiday = 0
                SET @Extra_AB_Days_Dection = 0

                SET @Holiday_Start_Date = ''
                SET @Holiday_End_Date  = ''
                select @Extra_AB_Days_Dection = isnull(Setting_Value,0) from T0040_SETTING 
                where Cmp_ID = @Cmp_ID and Setting_Name = 'Present Compulsory Extra Days Deduction(Holiday Master)'
                
                IF @EXTRA_AB_DAYS_DECTION > 0 
                    BEGIN
                        If EXISTS(SELECT 1 From T0040_HOLIDAY_MASTER Where H_From_Date >= @Month_St_Date and H_To_Date <= @Month_End_Date AND ISNULL(Is_P_Comp,0)= 1 and cmp_Id = @Cmp_ID and isnull(Branch_ID,@Branch_ID) = @Branch_ID)
                            BEGIN
                                SELECT @Holiday_Start_Date = H_From_Date,@Holiday_End_Date = H_To_Date,@No_Holiday_Days = isnull(No_Of_Holiday,0)  
                                FROM T0040_HOLIDAY_MASTER 
                                WHERE H_From_Date >= @Month_St_Date and H_To_Date <= @Month_End_Date AND ISNULL(Is_P_Comp,0)= 1 and cmp_Id = @Cmp_ID and isnull(Branch_ID,@Branch_ID) = @Branch_ID 
                                
                                SELECT @Present_Day_on_Holiday = isnull(Sum(P_days),0) 
                                FROM #Data 
                              WHERE Emp_Id = @EMP_ID and For_date >= @Holiday_Start_Date and For_date <= @Holiday_End_Date
                                
                                SET @No_Holiday_Days = (@No_Holiday_Days - @Present_Day_on_Holiday) * @Extra_AB_Days_Dection
                                IF @No_Holiday_Days < 0 
                                    SET  @No_Holiday_Days = 0
                                
                                IF @Sal_Cal_Days >= @No_Holiday_Days And @Present_Days >= @No_Holiday_Days  And @No_Holiday_Days > 0    
                                    BEGIN
                                        SET @Sal_Cal_Days = @Sal_Cal_Days - (Isnull(@No_Holiday_Days,0))
                                    END
                            END 
                    END
                ELSE IF @EXTRA_AB_DAYS_DECTION < 0 --Added By Ramiz on 29/12/2017 (Logic:- If Employee is Present on Holiday then 1 Day Extra Payment and If not Present then Absent. Also Need to Show that in Holiday Only.)
                    BEGIN
                    /*
                        IF EXISTS(SELECT 1 From T0040_HOLIDAY_MASTER Where H_From_Date >= @Month_St_Date and H_To_Date <= @Month_End_Date AND ISNULL(Is_P_Comp,0)= 1 and cmp_Id = @Cmp_ID and isnull(Branch_ID,@Branch_ID) = @Branch_ID)
                            BEGIN
                                if IsNull(@StrHoliday_Date, '') = ''
                                    set @StrHoliday_Date = null
                                DECLARE curCheckHoliday CURSOR FAST_FORWARD FOR 
                                    SELECT H_From_Date, H_To_Date, isnull(No_Of_Holiday,0)  
                                    FROM T0040_HOLIDAY_MASTER 
                                    WHERE H_From_Date >= @Month_St_Date and H_To_Date <= @Month_End_Date AND ISNULL(Is_P_Comp,0)= 1 and cmp_Id = @Cmp_ID and isnull(Branch_ID,@Branch_ID) = @Branch_ID 
                                OPEN curCheckHoliday
                                FETCH NEXT FROM curCheckHoliday into @Holiday_Start_Date,@Holiday_End_Date,@No_Holiday_Days 
                                    WHILE @@FETCH_STATUS = 0 
                                        BEGIN
                                            SELECT @Present_Day_on_Holiday = ISNULL(SUM(P_days),0) 
                                            FROM #DATA 
                                            WHERE EMP_ID = @EMP_ID and FOR_DATE >= @Holiday_Start_Date and For_date <= @Holiday_End_Date
                                            
                                            SET @Present_Day_on_Holiday = @Present_Day_on_Holiday * ABS(@Extra_AB_Days_Dection)
                                            
                                            IF @Sal_Cal_Days >= @No_Holiday_Days And @Present_Days >= @No_Holiday_Days  And @No_Holiday_Days > 0    
                                                BEGIN
                                                    SET @Sal_Cal_Days = @Sal_Cal_Days + Isnull(@Present_Day_on_Holiday,0)
                                                    SET @Holiday_Days = @Holiday_Days + Isnull(@Present_Day_on_Holiday,0)
                                                    
                                                    --IF @StrHoliday_Date = ''
                                                        SET @StrHoliday_Date = IsNull(@StrHoliday_Date + ';', '') + CAST(@Holiday_Start_Date AS VARCHAR(11))
                                                END
                                            FETCH NEXT FROM curCheckHoliday into @Holiday_Start_Date,@Holiday_End_Date,@No_Holiday_Days
                                        END
                                CLOSE curCheckHoliday
                                DEALLOCATE curCheckHoliday
                                SET @StrHoliday_Date = IsNull(@StrHoliday_Date,'')
                            END 
                     */
          
						If OBJECT_ID('tempdb..#HOLIDAY_PAID') is NOT NULL
							 BEGIN
								DROP TABLE #HOLIDAY_PAID
							 END

						SELECT  * INTO #HOLIDAY_PAID
						FROM  (
								SELECT H_From_Date, H_To_Date , No_Of_Holiday , Is_P_Comp , Is_Unpaid_Holiday , 0 AS Is_Emp_Present
								FROM T0040_HOLIDAY_MASTER 
								WHERE H_From_Date >= @Month_St_Date and H_To_Date <= @Month_End_Date --AND ISNULL(Is_P_Comp,0)= 1 
										and cmp_Id = @Cmp_ID and isnull(Branch_ID,@Branch_ID) = @Branch_ID and Is_Fix = 'N' 
								UNION 
								SELECT H_From_Date, H_To_Date , No_Of_Holiday , Is_P_Comp , Is_Unpaid_Holiday , 0 AS Is_Emp_Present
								FROM T0040_HOLIDAY_MASTER 
								WHERE	(DATEADD(YYYY, YEAR(@Month_St_Date) - YEAR(H_From_Date), H_From_Date) BETWEEN @Month_St_Date AND @Month_End_Date
																				OR
										DATEADD(YYYY, YEAR(@Month_End_Date) - YEAR(H_From_Date), H_From_Date) BETWEEN @Month_St_Date AND @Month_End_Date)
										--AND ISNULL(Is_P_Comp,0)= 1 
										and cmp_Id = @Cmp_ID and isnull(Branch_ID,@Branch_ID) = @Branch_ID 
											and Is_Fix = 'Y'
								) H

			
						UPDATE	#HOLIDAY_PAID
						SET		H_From_Date = DateAdd(YYYY,Year(@Month_St_Date) - Year(H_From_Date),H_From_Date),
								H_To_Date = DateAdd(YYYY,Year(@Month_St_Date) - Year(H_To_Date),H_To_Date)
						WHERE   DATEADD(YYYY, YEAR(@Month_St_Date) - YEAR(H_From_Date), H_From_Date) BETWEEN @Month_St_Date AND @Month_End_Date

						UPDATE	#HOLIDAY_PAID
						SET		H_From_Date = DATEADD(YYYY, YEAR(@Month_End_Date) - YEAR(H_From_Date), H_From_Date),
								H_To_Date = DateAdd(YYYY,Year(@Month_End_Date) - Year(H_To_Date),H_To_Date)
						WHERE   DATEADD(YYYY, YEAR(@Month_End_Date) - YEAR(H_From_Date), H_From_Date) BETWEEN @Month_St_Date AND @Month_End_Date
						
						IF @Is_present_on_holiday = 1
							BEGIN
								UPDATE HP
								SET Is_Emp_Present = 1
								FROM #HOLIDAY_PAID HP
									INNER JOIN #DATA D ON d.For_date BETWEEN  H_From_Date and H_To_Date
								WHERE	EXISTS(SELECT 1 from dbo.Split(@StrHoliday_Date, ';') t WHERE Cast(T.Data as DateTime ) BETWEEN HP.H_From_Date AND HP.H_To_Date)
							END
							
						--SELECT	 @Present_Day_on_Holiday=  ISNULL(SUM(P_days),0) * ABS(@Extra_AB_Days_Dection)
						--FROm	#DATA d
						--		INNER JOIN #HOLIDAY_PAID H  on d.For_date BETWEEN H_From_Date and H_To_Date
						--WHERE	EXISTS(select 1 from dbo.Split(@StrHoliday_Date, ',') t where Cast(T.Data as DateTime ) BETWEEN H.H_From_Date AND H.H_To_Date)
						
						--IF @Sal_Cal_Days >= @No_Holiday_Days And @Present_Days >= @No_Holiday_Days  And @No_Holiday_Days > 0	
						--	BEGIN
						--		SET @Sal_Cal_Days = @Sal_Cal_Days + Isnull(@Present_Day_on_Holiday,0)
						--		SET @Holiday_Days = @Holiday_Days + Isnull(@Present_Day_on_Holiday,0)
						--	END
                    END
                --Added by nilesh patel on 27042015 --End
                    
                --- End --- 



                ------------Emp Partimer --------------------------------        
                ---Salary calculate days is Half if employee has parttimeer
                if @Emp_Part_Time = 1
                    SET @Sal_cal_days =   @Sal_cal_Days/2     
                Else
                    SET @Sal_cal_days =@Sal_cal_Days
                --------------Emp Partimer --------------------------------  
                --Declare @GatePassAmount as NUMERIC(18, 4) --Added by Gadriwala Muslim 06012015 
                --  SET @GatePassAmount = 0   
                

                
                If @Wages_Type = 'Monthly'     
                    if @Inc_Weekoff = 1    
                        begin 
                            if @Inc_Holiday = 1
                                Begin 
                                    SET @Day_Salary =  @Basic_Salary /@Outof_Days
                                    
                                    set @Gross_Salary_ProRata = @Actual_Gross_Salary/@Outof_Days      
                                    SET @OT_Working_Day = @Outof_Days           

                                    if @Working_days_Arear > 0 
                                        begin
                                            SET @Day_Salary_Arear =  @Basic_Salary_Arear /@Working_days_Arear --Hardik 07/01/2012
                                        end
                                    if @Working_days_Arear_cutoff > 0 
                                        begin
                                            SET @Day_Salary_Arear_cutoff =  @Basic_Salary_Arear_cutoff /@Working_days_Arear_cutoff 
                                        end 
                                End 
                                
                            Else
                                Begin
                                    if (@Working_Days > 0)
                                        SET @Day_Salary =  @Basic_Salary / @Working_days_Day_Rate --@Working_Days Changed by Sumit on 9/11/2016
                                    Else
                                        SET @Day_Salary =  0;
                                        
                                    If @Working_days_Arear > 0 
                                        Begin
                                            SET @Day_Salary_Arear =  @Basic_Salary_Arear / @Working_days_Arear --Hardik 07/01/2012
                                        End
                                        
                                    If @Working_days_Arear_cutoff > 0 
                                        Begin
                                            SET @Day_Salary_Arear_cutoff =  @Basic_Salary_Arear_cutoff  / @Working_days_Arear_cutoff 
                                        End     
                                        
                                    SET @Gross_Salary_ProRata = @Actual_Gross_Salary/ @Working_days_Day_Rate--@Working_Days      
                                    SET @OT_Working_Day = @Working_days_Day_Rate --@Working_Days -- Changed by Hardik 16/07/2019 due to wrong day rate for Shoft shipyard
                                   --SET @Outof_Days =@Outof_Days - @Holiday_Days
                                End
                        end   
                    else    
                        begin
                            If Isnull(@Sal_Fix_Days,0) = 0      --Sal fix Days Condition Added By Ramiz on 24/11/2015
                                Begin
                                    if (@Working_Days > 0)
                                        BEGIN
                                        IF @Salary_Depends_on_Production = 1 and @Sal_cal_Days > 0
                                            BEGIN
                                              SET @Day_Salary =  @Basic_Salary / @Sal_cal_Days
                                              SET @OT_Working_Day = @Sal_cal_Days -- Added by Hardik 16/07/2019 due to wrong day rate for Shoft shipyard
                                            END
                                          ELSE
                                            BEGIN
                                               SET @Day_Salary =  @Basic_Salary / @Working_days_Day_Rate--@Working_Days 
                                               SET @Gross_Salary_ProRata = @Actual_Gross_Salary / @Working_days_Day_Rate--@Working_Days    
                                               SET @OT_Working_Day = @Working_days_Day_Rate -- Added by Hardik 16/07/2019 due to wrong day rate for Shoft shipyard
                                            END
                                        END
                                    ELSE
                                        BEGIN
                                            SET @Day_Salary =  0
                                            SET @Gross_Salary_ProRata = 0
   SET @OT_Working_Day = 0 -- Added by Hardik 16/07/2019 due to wrong day rate for Shoft shipyard
                                        END
                                    
                                    
                                    --SET @OT_Working_Day = @Working_Days -- Commented by Hardik 16/07/2019 due to wrong day rate for Shoft shipyard  
                                    
                                    If @Working_days_Arear > 0 
                                        Begin
                                            SET @Day_Salary_Arear =  @Basic_Salary_Arear / @Working_days_Arear --Hardik 07/01/2012
                                        End
                                    If @Working_days_Arear_cutoff > 0 
                                        Begin
                                            SET @Day_Salary_Arear_cutoff =  @Basic_Salary_Arear_cutoff / @Working_days_Arear_cutoff --Hardik 07/01/2012
                                        End
                                End
                            Else
                                Begin
                                    SET @Day_Salary =  @Basic_Salary / @Outof_Days 
                                    SET @Gross_Salary_ProRata = @Actual_Gross_Salary/@Outof_Days    
                                    SET @OT_Working_Day = @Outof_Days   
                                    
                                    If @Working_days_Arear > 0 
                                        Begin
                                            SET @Day_Salary_Arear =  @Basic_Salary_Arear / @Outof_Days
                                        End
                                    If @Working_days_Arear_cutoff > 0 
                                        Begin
                                            SET @Day_Salary_Arear_cutoff =  @Basic_Salary_Arear_cutoff / @Outof_Days
                                        End
                                End

                        END     
                 Else    
                    begin
                        SET @Day_Salary   =  @Basic_Salary    
                        SET @Day_Salary_Arear =  @Basic_Salary_Arear --Hardik 07/01/2012
                        SET @OT_Working_Day =  @Working_Days 
                        SET @Day_Salary_Arear_cutoff =  @Basic_Salary_Arear_cutoff 
                    end

                                
                If @SalaryBasis='Fix Hour Rate'--Nikunj 19-04-2011
                    BEGIN                   
                        Set @Hour_Salary = @Day_Salary           
                    END
                ELSE
                    BEGIN   
                        Set @Hour_Salary = @Day_Salary * 3600 /@Shift_Day_Sec
                        
                        --Added Condition by Hardik 13/11/2013 for Sharp Images, Pakistan
                        IF ISNULL(@Monthly_Deficit_Adjust_OT_Hrs,0) = 1 And @SalaryBasis = 'Hour'
                            BEGIN
                                Set @Hour_Salary_OT = @Hour_Rate_Deficit
                                Set @Emp_WO_OT_Sec = 0
                                Set @Emp_HO_OT_Sec = 0  
                            END
                        ELSE
                            BEGIN
                                IF UPPER(@Wages_Type) = 'MONTHLY'   --Code Modified by Ramiz on 01/12/2017 , as condition of Daily Wages was not Added.
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
                                        IF ISNULL(@Fix_OT_Shift_Sec,0) > 0
                                            SET @Hour_Salary_OT = @Day_Salary * 3600  /  @Fix_OT_Shift_Sec        
                                        ELSE
                                            SET @Hour_Salary_OT = @Day_Salary * 3600  /  @Shift_Day_Sec 
                                    END
                            END
                    END
                  
				

                Declare @Sal_Cal_Days_temp as numeric(18,3) -- Added by rohit on 29022016
                Declare @Present_Days_temp as numeric(18,3) -- Added by rohit on 29022016 
				--SET @Sal_Cal_Days_temp = @Sal_Cal_Days
				--SET @Sal_Cal_Days = @Sal_Cal_Days + @present_on_holiday
				--SET @Present_Days_temp = @Present_Days 
				--SET @Present_Days = @Present_Days + @present_on_holiday   

				 --Added new setting by Mr.Mehul on 10-May-2023
				

                SET @Sal_Cal_Days_temp = @Sal_Cal_Days
                
				if @settingval = 1
				begin
						SET @Sal_Cal_Days = @Sal_Cal_Days 
						SET @Present_Days_temp = @Present_Days 
						SET @Present_Days = @Present_Days 

				end
				else
				begin 
						SET @Sal_Cal_Days = @Sal_Cal_Days + @present_on_holiday
						SET @Present_Days_temp = @Present_Days 
						SET @Present_Days = @Present_Days + @present_on_holiday     
				end
				--Added new setting by Mr.Mehul on 10-May-2023

				
                  
                 
                If @SalaryBasis ='Day'    
                    Begin    
                        -- Rounding condition Added by Mitesh 
                    
                        if @IS_ROUNDING = 1
                            Begin
                                SET @Salary_Amount  = Round(@Day_Salary * @Sal_Cal_Days,@Round) 
                                SET @Salary_amount_Arear = Round(@Day_Salary_Arear * @Arear_Day,@Round)--Hardik 07/01/2012  
                            --  SET @Salary_Amount  = Round(@Day_Salary * @Mid_Inc_Working_Day,@Round)  
                                SET @Salary_amount_Arear_cutoff = Round(@Day_Salary_Arear_cutoff * @Absent_after_Cutoff_date,@Round)
                            end
                        Else
                            Begin
                                SET @Salary_Amount  = Isnull(@Day_Salary * @Sal_Cal_Days,0)
                                SET @Salary_amount_Arear = Isnull(@Day_Salary_Arear * @Arear_Day,0) --Hardik 07/01/2012
                            --  SET @Salary_Amount  = Isnull(@Day_Salary * @Mid_Inc_Working_Day,0)
                                SET @Salary_amount_Arear_cutoff = Isnull(@Day_Salary_Arear_cutoff * @Absent_after_Cutoff_date,0) 
                            End 
                        
                        
                        ----Start-----Fix Basic Salary Grade Wise----Mafatlal Client---Ankit 27082015---
                        
                        DECLARE @Curr_For_date      DATETIME
                        DECLARE @Grade_BasicSalary  NUMERIC(18, 4)
                        DECLARE @Grade_Id           NUMERIC
                        DECLARE @Grade_Name         Varchar(100)
                        DECLARE @DA_E_ad_Amount     NUMERIC(18, 4)
                        DECLARE @DA_Amount_0433     NUMERIC(18, 4)
                        DECLARE @DA_Amount_0144     NUMERIC(18, 4)
                        DECLARE @DA_M_ad_Amount     NUMERIC(18, 4)
                        DECLARE @Grd_Leave_Used     NUMERIC(18, 4)
                        DECLARE @BasicDA_OT_Salary  NUMERIC(18, 4)
                        DECLARE @Grade_BasicSalary_Night    NUMERIC(18,2)
                        DECLARE @SALRY_SLIP_DA AS NUMERIC(18,2)
                        DECLARE @SALRY_SLIP_NIGHT_DA AS NUMERIC(18,2)
                        DECLARE @EMPMASTER_BASIC AS NUMERIC(18,2)
                        DECLARE @is_MachineBased as Tinyint
                        DECLARE @MachineEmpType as varchar(5)
                        DECLARE @Mchn_CL_Leave AS NUMERIC(18,2)
                        DECLARE @is_Mchn_Based AS TINYINT 
                        DECLARE @Is_Gradewise_Salary AS TINYINT
                        
                        SET @Grade_BasicSalary  = 0
                        SET @DA_E_ad_Amount     = 0
                        SET @DA_Amount_0433     = 0
                        SET @DA_Amount_0144     = 0
                        SET @DA_M_ad_Amount     = 0
                        SET @Grd_Leave_Used     = 0
                        SET @BasicDA_OT_Salary  = 0
                        SET @Grade_BasicSalary_Night = 0
                        SET @SALRY_SLIP_DA = 0
                        SET @SALRY_SLIP_NIGHT_DA = 0
                        SET @EMPMASTER_BASIC= 0.0
                        SET @is_MachineBased = 0
                        set @MachineEmpType = ''
                        SET @Mchn_CL_Leave = 0.00
                        SET @is_Mchn_Based = 0
                        SET @Is_Gradewise_Salary = 0

                        IF (@Gradewise_Salary_Enabled > 0)
                            SELECT  @Grade_BasicSalary = ISNULL(Fix_Basic_Salary,0) , 
                                    @Grade_BasicSalary_Night = ISNULL(Fix_Basic_Salary_Night,0), 
                                    @Grade_Name = ISNULL(Grd_Name,''),
                                    @Is_Gradewise_Salary = Is_Gradewise_Salary
                            FROM T0040_GRADE_MASTER WHERE Grd_ID = @Grd_Id
                            
                        SELECT @is_MachineBased = isnull(Is_MachineBased,0) , @MachineEmpType = isnull(MachineEmpType,'') 
                        FROM T0040_Business_Segment where Segment_ID = @SEGMENT_ID
        
		
				
                        ------WEAVER LOGIC-----
                        IF  @is_MachineBased = 1
                            BEGIN
                                EXEC SP_CALCULATE_MACHINE_BASED_SALARY @Emp_Id , @Cmp_ID ,@Increment_ID ,@Gen_Id , @Month_St_Date, @Month_End_Date, @StrHoliday_Date, @Sal_cal_Days , @MachineEmpType, @Salary_Amount OUTPUT , @Mchn_CL_Leave OUTPUT , @is_Mchn_Based output
                                SET @is_MachineBased = @is_Mchn_Based
                            END
                        ------WEAVER LOGIC-----



                        IF (@Grade_BasicSalary > 0 OR @Grade_BasicSalary_Night > 0 OR @Grade_Name = '999') --and @is_MachineBased = 0    --Added By Ramiz on 28/12/2015 for Mafatlals Grade wise Salary
                            BEGIN

                                If @Left_Date IS NOT NULL   --This Condition is Added By Ramiz on 06/06/2016 as in Case of Left Employee , Salary days  was Coming More
                                    BEGIN
                                        SET @Month_End_Date =  @Left_Date
                                    END
                                    
                                SELECT @EMPMASTER_BASIC = ISNULL(Basic_Salary ,0)
                                FROM T0095_INCREMENT 
                                WHERE Increment_ID = @Increment_ID AND Grd_ID = @Grd_Id --AND @Grade_Name = '999' --We Will use Employee Master Basic Salary Only For Nadiaid Unit

                                ----THIS IS THE MOST IMPORTANT CONDITION FROM WHERE WE ARE SPLITTING NAVSARI & NADIAD MAFATLALS POLICY  
                                SET @Day_Salary = CASE WHEN @Is_Gradewise_Salary = 1 THEN
                                                                    @EMPMASTER_BASIC 
                                                               ELSE 
                                                                    @Grade_BasicSalary END
                                                            
                                SET @GRADE_BASICSALARY_NIGHT = CASE WHEN @Is_Gradewise_Salary = 1 THEN
                                                                    @EMPMASTER_BASIC 
                                                               ELSE 
                                                                    @GRADE_BASICSALARY_NIGHT END                

                                IF @is_MachineBased = 0
                                    BEGIN                                                       
                                        SELECT @DA_E_ad_Amount = EED.E_AD_AMOUNT 
                                        FROM T0100_EMP_EARN_DEDUCTION EED INNER JOIN T0050_AD_MASTER AM ON EED.AD_ID = AM.AD_ID
                                        WHERE EED.EMP_ID = @emp_id AND AM.CMP_ID = @Cmp_id AND AM.AD_DEF_ID = 11 --( Def Id 11 : DA)
                                    
                                        ----Updating Revised Allowance Starts here By Ramiz on 07/10/2015
                                        SELECT @DA_E_ad_Amount =
                                            (Select 
                                             Case When Qry1.FOR_DATE >= EED.FOR_DATE Then
                                                Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
                                             Else
                                                eed.e_ad_Amount End As E_Ad_Amount
                                        FROM dbo.T0100_EMP_EARN_DEDUCTION EED INNER JOIN                    
                                               dbo.T0050_AD_MASTER ADM  ON EEd.AD_ID = ADM.AD_ID   LEFT OUTER JOIN
                                                ( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE 
                                                    From T0110_EMP_Earn_Deduction_Revised EEDR INNER JOIN
                                                    ( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
                                                        Where Emp_Id = @Emp_Id
                                                        And For_date <= @Month_End_Date
                                                     Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
                                                ) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID                  
                                        WHERE EED.EMP_ID = @emp_id AND increment_id = @Increment_Id And Adm.AD_ACTIVE = 1 and Adm.AD_DEF_ID = 11
                                                And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
                                        UNION 
                                        
                                        SELECT E_AD_Amount
                                        FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED INNER JOIN  
                                            ( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
                                                Where Emp_Id  = @Emp_Id And For_date <= @Month_End_Date 
                                                Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
                                           INNER JOIN dbo.T0050_AD_MASTER ADM  ON EEd.AD_ID = ADM.AD_ID                     
                                        WHERE emp_id = @emp_id and Adm.AD_DEF_ID = 11
                                                And Adm.AD_ACTIVE = 1
                                                And EEd.ENTRY_TYPE = 'A')                      
                        
                                        --  IF @Grade_Name = '999'
                                        --      BEGIN
                                        --          INSERT INTO #DA_Allowance   --Insert Master Grade ID --NADIAD
                                        --              ( Grd_Id , Grd_Count ,Basic_Salary, Is_Master_Grd)
                                        --          SELECT @Grd_ID , 0 , @Day_Salary , 1
                                        --      END
                                        --  ELSE
                                        --      BEGIN
                                        --          INSERT INTO #DA_Allowance   --Insert Master Grade ID    --NAVSARI
                                        --              ( Grd_Id , Grd_Count , Basic_Salary , Is_Master_Grd)
                                        --          SELECT @Grd_ID , 0 , @Day_Salary , 1
                                        --      END
                                
                                        INSERT INTO #DA_Allowance   --Insert Master Grade ID
                                                ( Grd_Id , Grd_Count ,Basic_Salary, Is_Master_Grd)
                                        SELECT @Grd_ID , 0 , @Day_Salary , 1
                        
                                        INSERT INTO #DA_Allowance   --Day Shift--Insert Employee Grade change Grd_Id & P Days
                                            ( Grd_Id , Grd_Count )
                                        SELECT Grd_ID , ISNULL(SUM(D.P_days),0) 
                                        FROM T0100_EMP_GRADE_DETAIL EGD INNER JOIN 
                                            #Data D ON EGD.Emp_ID = D.Emp_Id AND EGD.For_Date = D.For_date 
                                        WHERE EGD.EMP_ID = @EMP_ID AND EGD.For_Date BETWEEN @Month_St_Date AND @Month_end_Date AND D.P_days <> 0
                                            AND CONVERT(VARCHAR(8),Shift_Start_Time,108) < CONVERT(VARCHAR(8),Shift_End_Time,108) and EGD.Grd_ID <> @Grd_Id
                                        GROUP BY EGD.Grd_ID
                                
                                        --'' Below Condition Check For Work On Night shift
                                        IF Exists(SELECT 1 FROM #Data WHERE Emp_Id = @Emp_Id AND P_days <> 0  AND CONVERT(VARCHAR(8),Shift_Start_Time,108) > CONVERT(VARCHAR(8),Shift_End_Time,108))
                                            BEGIN
                                                --IF @Grade_Name = '999'
                                                --  BEGIN
                                                --      INSERT INTO #DA_Allowance   --Insert Master Grade ID --NADIAD
                                                --          ( Grd_Id , Grd_Count ,Basic_Salary, Day_Night_Flag ,Is_Master_Grd)
                                                --      SELECT @Grd_ID , 0 , @EMPMASTER_BASIC , 1 , 1
                                                --  END
                                                --ELSE
                                                --  BEGIN
                                                --      INSERT INTO #DA_Allowance   --Insert Master Grade ID    --NAVSARI
                                                --          ( Grd_Id , Grd_Count ,Basic_Salary, Day_Night_Flag ,Is_Master_Grd)
                                                --      SELECT @Grd_ID , 0 , @Grade_BasicSalary_Night , 1 , 1
                                                --  END
                                                INSERT INTO #DA_Allowance   --Insert Master Grade ID    --NAVSARI
                                                    ( Grd_Id , Grd_Count ,Basic_Salary, Day_Night_Flag ,Is_Master_Grd)
                                                SELECT @Grd_ID , 0 , @Grade_BasicSalary_Night , 1 , 1
                                                        
                                                INSERT INTO #DA_Allowance   --Night Shift--Insert Employee Grade change Grd_Id & P Days 
                                                    ( Grd_Id , Grd_Count ,Day_Night_Flag )
                                                SELECT Grd_ID , ISNULL(SUM(D.P_days),0)  ,1 
                  FROM T0100_EMP_GRADE_DETAIL EGD INNER JOIN 
                                                    #Data D ON EGD.Emp_ID = D.Emp_Id AND EGD.For_Date = D.For_date 
                                                WHERE EGD.EMP_ID = @EMP_ID AND EGD.For_Date BETWEEN @Month_St_Date AND @Month_end_Date AND D.P_days <> 0
                                                    AND CONVERT(VARCHAR(8),D.Shift_Start_Time,108) > CONVERT(VARCHAR(8),D.Shift_End_Time,108) and EGD.Grd_ID <> @Grd_Id
                                                GROUP BY EGD.Grd_ID
                                                
                                                    
                                                UPDATE #DA_Allowance        --Update Master Grade P Days //Night Shift
                                                SET Grd_Count = (   SELECT ISNULL(SUM(D.P_days),0)  FROM #Data D WHERE Emp_Id = @Emp_Id AND P_days <> 0 AND D.For_date  BETWEEN @Month_St_Date AND @Month_end_Date
                                                                    AND CONVERT(VARCHAR(8),Shift_Start_Time,108) > CONVERT(VARCHAR(8),Shift_End_Time,108)) - ISNULL(( SELECT SUM(Grd_Count) FROM #DA_Allowance WHERE Day_Night_Flag = 1 ),0)
                                                WHERE Grd_Id = @Grd_Id and Day_Night_Flag = 1 AND Is_Master_Grd = 1
                                                    
                                            END 
                                    
                                        UPDATE #DA_Allowance        --Update Master Grade P Days //Day shift
                                        SET Grd_Count = ( SELECT ISNULL(SUM(D.P_days),0)  FROM #Data D
                                                            WHERE Emp_Id = @Emp_Id AND P_days <> 0 AND D.For_date  BETWEEN @Month_St_Date AND @Month_end_Date) - ISNULL(( SELECT SUM(Grd_Count) FROM #DA_Allowance ),0)
                                        WHERE Grd_Id = @Grd_Id and Day_Night_Flag = 0 AND Is_Master_Grd = 1
                        


                                        --IF It is "Include Holiday" in General Setting then that days should be Added in Dayrate Calculation
                                        IF @Inc_Holiday = 1 AND @Holiday_Days > 0
                                            BEGIN
                                                IF @Grade_Name = '999'  --Nadiad Unit Logic of Counting Day Rate of Last Working Day
                                                    BEGIN
                                                        INSERT INTO #DA_Allowance ( Grd_Id , Grd_Count , Is_Leave_Applied)
                                                        SELECT  ISNULL(EGD.Grd_ID, @Grd_Id), 1 + ISNULL(@present_on_holiday,0) , 2                      --Is_Leave_Applied = 2 for Holiday
                                                        FROM    (SELECT CAST(DATA AS DATETIME) AS FOR_DATE 
                                                                 FROM dbo.Split(@StrHoliday_Date, ';') T Where Data <> '') T
                                                                 CROSS APPLY (SELECT    MAX(FOR_DATE)  AS FOR_DATE
                                                                              FROM      #Data D
                                                                              WHERE     D.For_date < T.FOR_DATE AND D.Emp_Id=@Emp_Id) D
                                                                LEFT OUTER JOIN T0100_EMP_GRADE_DETAIL EGD ON EGD.FOR_DATE=D.FOR_DATE AND EGD.Emp_ID=@Emp_Id
                                                                --INNER JOIN #DATA DA ON T.FOR_DATE = DA.FOR_DATE and da.emp_id = @emp_id
                                                    END
                                                ELSE
                                                    BEGIN               --Navsari Unit Logic of Counting Master Grade Day Rate
                                  UPDATE #DA_Allowance        
                                                        SET Grd_Count = ISNULL(Grd_Count,0) + ISNULL(@Holiday_Days,0)
                                                        WHERE Grd_Id = @Grd_Id and Day_Night_Flag = 0
                                                    END
                                            END
            
                                        --Adding Leave Records in Calculation
                                        SELECT @Grd_Leave_Used =(Isnull(Sum(Leave_Used),0) + isnull(Sum(CompOff_Used),0)) 
                                        FROM T0140_LEAVE_TRANSACTION LT 
                                        INNER JOIN T0040_LEAVE_MASTER LM ON LM.LEAVE_ID = LT.LEAVE_ID
                                        WHERE Emp_ID = @Emp_id and LEAVE_PAID_UNPAID = 'P' and For_Date BETWEEN @Month_St_Date AND @Month_end_Date
                                
                                      IF @Grd_Leave_Used > 0 AND @Grade_Name = '999' or @Is_Gradewise_Salary = 1    --NEED TO PAY ON THE BASIS OF PREVIOUS DAY
                                            BEGIN
                                                /*  Case 1:- If Leave is Applied After Upper Grade working, then Payment of Upper Grade is to be Paid.
                                                    Case 2:- If Leave is Applied After Same Grade Working , then Payment of Employee Master is to be Paid.
                                                    Case 3:- If Leave is Applied After Lower Grade Working, then Payment of Employee Master is to be Paid.
                                                */
                                            INSERT INTO #DA_Allowance ( Grd_Id , Grd_Count , Is_Leave_Applied)          
                                            SELECT  ISNULL(EGD.Grd_ID, @Grd_Id), T.Leave_Used , CASE WHEN C_FOR_DATE IS NOT NULL THEN 3 ELSE 1 END 
                                            FROM    (
                                                        SELECT FOR_DATE , Isnull(Leave_Used,0) AS Leave_Used, C_FOR_DATE
                                                        FROM T0140_LEAVE_TRANSACTION LT
                                                            INNER JOIN T0040_LEAVE_MASTER LM ON LM.LEAVE_ID = LT.LEAVE_ID
                                                            LEFT OUTER JOIN (SELECT CAST(DATA AS DATETIME) AS C_FOR_DATE FROM dbo.Split(@varCancelWeekOff_Date,';') T WHERE DATA <> '') CL ON CL.C_FOR_DATE=LT.For_Date
                                                        WHERE Emp_ID = @Emp_id and LEAVE_PAID_UNPAID = 'P' AND For_Date BETWEEN @Month_St_Date AND @Month_end_Date
                                                                AND Calculate_on_Previous_Month = 0 and LT.Leave_Used > 0                                                                   
                                                    ) T
                                                    CROSS APPLY (
                                                                    SELECT  MAX(FOR_DATE)  AS FOR_DATE
                                                                    FROM        #Data D
                                                                    WHERE       D.For_date < T.FOR_DATE AND D.Emp_Id=@Emp_Id
                                                                    ) D
                                            LEFT OUTER JOIN T0100_EMP_GRADE_DETAIL EGD ON EGD.FOR_DATE=D.FOR_DATE AND EGD.Emp_ID=@Emp_Id
                                            END
                                        ELSE
                                            BEGIN                                       --NEED TO PAY ON THE BASIS OF EMPLOYEE MASTER
                                                UPDATE #DA_Allowance
                                                SET Grd_Count = ISNULL(Grd_Count,0) + ISNULL(@Grd_Leave_Used,0)
                                         WHERE Grd_Id  = @Grd_Id and isnull(Day_Night_Flag,0) = 0
                                            END
                                --//Ended By Ramiz on 08/10/2015

                        /* COMMENTED PORTION of NAVSARI
                
                                UPDATE #DA_Allowance    --Calcualte DA Allowance on Day
                                SET Basic_Salary = (GM.Fix_Basic_Salary/ 26 ) * DA.Grd_Count,
                                    DA_Allow_Salary = 
                                        CASE WHEN GM.Fix_Basic_Salary >= 400 THEN
                                            ((400 * @DA_Amount_0433) / 100 + (( CASE WHEN GM.Fix_Basic_Salary >= 700 THEN 700 ELSE GM.Fix_Basic_Salary END - 400 ) * @DA_Amount_0144    ) / 100) / 26 * DA.Grd_Count
                                        ELSE
                                            ((GM.Fix_Basic_Salary * @DA_Amount_0433) / 100 ) / 26 * DA.Grd_Count
                                        END
                                FROM #DA_Allowance DA INNER JOIN
                                    T0040_GRADE_MASTER GM ON DA.Grd_Id = GM.Grd_ID
                                WHERE Day_Night_Flag = 0
                                
                                UPDATE #DA_Allowance    --Calcualte DA Allowance on Night
                                SET     Basic_Salary = (GM.Fix_Basic_Salary_Night / 26 ) * DA.Grd_Count,
                                        DA_Allow_Salary = 
                                            CASE WHEN GM.Fix_Basic_Salary_Night >= 400 THEN
                                                ((400 * @DA_Amount_0433) / 100 + (( CASE WHEN GM.Fix_Basic_Salary_Night >= 700 THEN 700 ELSE GM.Fix_Basic_Salary_Night END - 400 ) * @DA_Amount_0144    ) / 100) / 26 * DA.Grd_Count
                                            ELSE
                                                ((GM.Fix_Basic_Salary_Night * @DA_Amount_0433) / 100 ) / 26 * DA.Grd_Count
                                            END
                                FROM #DA_Allowance DA INNER JOIN
                                    T0040_GRADE_MASTER GM ON DA.Grd_Id = GM.Grd_ID
                                WHERE Day_Night_Flag = 1
                */
                                --Assign Calculated DA in Variable , Just to Show in Salary Slip , it is not User any where else. . .
                                --Added New Logic of 700 Max Limit on 31/07/2017 , as per Requirement of Mafatlal
                                
                                SET @DA_Amount_0433 = @DA_E_ad_Amount * 0.433
                                SET @DA_Amount_0144 = @DA_E_ad_Amount * 0.144
                                
                                SELECT @SALRY_SLIP_DA = CASE WHEN GM.Fix_Basic_Salary >= 400 THEN
                                                            ((400 * @DA_Amount_0433) / 100 + (( CASE WHEN GM.Fix_Basic_Salary >= 700 THEN 700 ELSE GM.Fix_Basic_Salary END - 400 ) * @DA_Amount_0144    ) / 100)
                                                        ELSE
                                                            ((GM.Fix_Basic_Salary * @DA_Amount_0433) / 100 )
                                                        END,
                                      @SALRY_SLIP_NIGHT_DA = CASE WHEN GM.Fix_Basic_Salary_Night >= 400 THEN
                                                                ((400 * @DA_Amount_0433) / 100 + (( CASE WHEN GM.Fix_Basic_Salary_Night >= 700 THEN 700 ELSE GM.Fix_Basic_Salary_Night END  - 400 ) * @DA_Amount_0144   ) / 100)
                                                            ELSE
                                                                ((GM.Fix_Basic_Salary_Night * @DA_Amount_0433) / 100 )
                                                            END  
                                FROM #DA_Allowance DA 
      INNER JOIN
                                        T0040_GRADE_MASTER GM ON DA.Grd_Id = GM.Grd_ID
                                WHERE DA.Grd_ID = @Grd_ID
                                
                                UPDATE  DA 
                                SET     Master_Basic = 
                                        CASE WHEN DA.Is_Master_Grd = 1 THEN 
                                                DA.Basic_Salary 
                                             WHEN DA.Day_Night_Flag = 0 THEN 
                                                CASE WHEN GM.Fix_Basic_Salary < @EMPMASTER_BASIC THEN @EMPMASTER_BASIC ELSE GM.Fix_Basic_Salary END
                                             ELSE 
                                                CASE WHEN GM.Fix_Basic_Salary_Night < @EMPMASTER_BASIC THEN @EMPMASTER_BASIC ELSE GM.Fix_Basic_Salary_Night END
                                        END
                                FROM    #DA_Allowance DA
                                        INNER JOIN T0040_GRADE_MASTER GM ON DA.Grd_Id = GM.Grd_ID
                                    

                                 --NEED TO INSERT WEEKOFF
                                IF @Inc_Weekoff = 1 AND @Weekoff_Days > 0 AND @Grade_Name <> '999' and @Is_Gradewise_Salary = 1
                                    BEGIN
                                        INSERT INTO #DA_Allowance 
                                            ( Grd_Id , Grd_Count ,Basic_Salary,Day_Night_Flag, Is_Master_Grd , Master_Basic , Is_Leave_Applied)
                                        VALUES 
                                            (@Grd_Id , @Weekoff_Days , @Day_Salary , 0 , 1 , @Day_Salary , 3)
                                    END
                
                                    UPDATE DA
                                    SET Basic_Salary = (Master_Basic / CASE WHEN @Sal_Fix_Days > 0 THEN @Sal_Fix_Days ELSE @OutOf_Days END ) * ISNULL(DA.Grd_Count,0)
                                    FROM #DA_Allowance DA

                                
                                    SELECT @Salary_Amount = ISNULL(SUM(Basic_Salary),0)
                                    FROM #DA_Allowance 
                                
                                --New Code Of Overtime for Mafatlals Client---
                                
                                --New Code Of Overtime for Mafatlals Client---
                                    --if @Grade_Name = '999'  --Nadiad Unit
                                    --    BEGIN
                                    --        IF @Emp_OT = 1
                                    --                BEGIN
                                                        --INSERT INTO #OT_Gradewise --Upper or Lower Grade Working
                                                        --  ( Grd_Id , For_date  , Is_Master_Grd , Grd_OT_Hours )
                                                        --SELECT @Grd_Id , D.For_date , 1 , (d.OT_Sec + d.Weekoff_OT_Sec + d.Holiday_OT_Sec)/3600
                                                        --FROM #DATA D
                                                        --WHERE D.Emp_ID = @Emp_Id
                                                        --AND ( d.OT_Sec > 0 or d.Weekoff_OT_Sec > 0 or d.Holiday_OT_Sec > 0 )
                                                        --AND D.For_Date BETWEEN @Month_St_Date AND @Month_end_Date
                                                
                                                        --UPDATE  O
                                                        --SET O.Grd_Id = EGD.OT_GRD_ID , O.Is_Master_Grd = 0
                                                        --FROM #OT_Gradewise O                              
                                                        --  INNER JOIN T0100_EMP_GRADE_DETAIL EGD ON O.For_date = EGD.For_Date AND EGD.Emp_ID = @Emp_Id
                                      
                                                        --UPDATE  O
                                                        --SET 
                                                        --O.Grd_Hour_Basic_Salary = CASE    WHEN Is_Master_Grd = 1 
                                                        --                                  THEN (@EMPMASTER_BASIC / @Fix_OT_Work_Days / Replace(@Fix_OT_Shift_Hours,':','.')) * Grd_OT_Hours -- MASTERBASIC / 26 / 8
                                                        --                              ELSE ( GM.Fix_Basic_Salary / @Fix_OT_Work_Days / Replace(@Fix_OT_Shift_Hours,':','.')) * Grd_OT_Hours --GRADEBASIC / 26 / 8
                                                        --                              END,
                                                        --O.Master_Basic = CASE WHEN Is_Master_Grd = 1 
                                                        --                      THEN @EMPMASTER_BASIC 
                                                        --                    ELSE GM.Fix_Basic_Salary 
                                                        --                    END
                                                        --FROM #OT_Gradewise O                              
                                                        --  INNER JOIN T0040_GRADE_MASTER GM ON O.Grd_Id = GM.Grd_ID

                                IF EXISTS (SELECT TOP 1 1 FROM T0100_EMP_GRADE_OVERTIME WHERE Emp_ID = @Emp_Id AND For_Date BETWEEN @Month_St_Date AND @Month_end_Date)
										BEGIN
											INSERT INTO #OT_Gradewise	--Upper or Lower Grade Working
												( Grd_Id , For_date  , Is_Master_Grd , Grd_OT_Hours  , Amount_Credit , Amount_Debit)
											SELECT	d.Grd_ID , D.For_date , CASE WHEN D.Grd_ID = @Grd_Id THEN 1 ELSE 0 END , d.OT_Hours, -- (dbo.F_Return_Sec(d.OT_Hours)/3600) ,
													d.Amount_Credit , d.Amount_Debit
											FROM T0100_EMP_GRADE_OVERTIME D
											WHERE D.Emp_ID = @Emp_Id
											AND D.For_Date BETWEEN @Month_St_Date AND @Month_end_Date
								
											UPDATE  O
											SET 
											O.Grd_Hour_Basic_Salary = CASE	WHEN Is_Master_Grd = 1 
																				THEN (@EMPMASTER_BASIC / @Fix_OT_Work_Days / Replace(@Fix_OT_Shift_Hours,':','.')) * Grd_OT_Hours -- MASTERBASIC / 26 / 8
																			ELSE ( GM.Fix_Basic_Salary / @Fix_OT_Work_Days / Replace(@Fix_OT_Shift_Hours,':','.')) * Grd_OT_Hours --GRADEBASIC / 26 / 8
																			END,
											O.Master_Basic = CASE WHEN Is_Master_Grd = 1 
																	THEN @EMPMASTER_BASIC 
																  ELSE GM.Fix_Basic_Salary 
																  END
											FROM #OT_Gradewise O
												INNER JOIN T0040_GRADE_MASTER GM ON O.Grd_Id = GM.Grd_ID	
                                        
                                        END
                                    ELSE
                                        BEGIN   --Navsari Unit
                                            Declare @Grd_count_OT Numeric(18,0)
                                            Declare @Grd_Basic_OT Numeric(18,0)
                                        
                                            SELECT @Grd_count_OT = SUM(Grd_Count) from #DA_Allowance where Grd_id <> @Grd_id 
                                        
                                            If @Grd_count_OT >= 14
                                               BEGIN 
                                                    SELECT TOP 1 @Grd_Basic_OT = GM.Fix_Basic_Salary 
                                                    FROM #DA_Allowance DA 
                                                        INNER JOIN  T0040_GRADE_MASTER GM ON DA.Grd_Id = GM.Grd_ID 
                                                    WHERE DA.Grd_id <> @Grd_id
                                               END
                                            ELSE
                                                BEGIN
                                                    SELECT @Grd_Basic_OT = GM.Fix_Basic_Salary 
                                                    FROM T0040_GRADE_MASTER GM
                                                    WHERE Grd_id = @Grd_id
                                                END
                                          
                                            
                                            IF @Grd_Basic_OT >= 400 
                                                BEGIN
                                                   SET  @BasicDA_OT_Salary = @Grd_Basic_OT + ((400 * @DA_Amount_0433) / 100 + (( @Grd_Basic_OT - 400 ) * @DA_Amount_0144    ) / 100) 
                                                END
                                            ELSE
                                                BEGIN
                                                   SET @BasicDA_OT_Salary = @Grd_Basic_OT + ((@Grd_Basic_OT * @DA_Amount_0433) / 100 ) 
                                                END 
                                            
                                            IF @IS_ROUNDING = 1
                                                BEGIN
                                                    SET @BasicDA_OT_Salary = ROUND(@BasicDA_OT_Salary,0)
                                                END                 
                                        END 
                                END

                                --This code is for Mafatlals Salary Slip Only , Added By Ramiz on 19/11/2015--
                                Declare @Actual_Grade_Day_Shift as Numeric(18,2)
                                Declare @Actual_Grade_Night_Shift as Numeric(18,2)
                                Declare @Upper_Grade_Day_Shift as Numeric(18,2)
                                Declare @Upper_Grade_Night_Shift as Numeric(18,2)
                                Declare @Day_Basic_Salary as Numeric(18,2)
                                Declare @Night_Basic_Salary as Numeric(18,2)
                                Declare @CL_Leave as Numeric(18,2)
                                Declare @Grd_OT_Hours Numeric(18,0)
                                
                                select @Actual_Grade_Day_Shift   = Sum(Grd_Count) from #DA_Allowance where Grd_Id = @Grd_Id and Day_Night_Flag = 0
                                select @Actual_Grade_Night_Shift = Sum(Grd_Count) from #DA_Allowance where Grd_Id = @Grd_Id and Day_Night_Flag = 1
                                select @Upper_Grade_Day_Shift    = Sum(Grd_Count) from #DA_Allowance where Grd_Id <> @Grd_Id and Day_Night_Flag = 0
                                select @Upper_Grade_Night_Shift  = Sum(Grd_Count) from #DA_Allowance where Grd_Id <> @Grd_Id and Day_Night_Flag = 1
                                select @CL_Leave = Sum(Grd_Count) from #DA_Allowance where Is_Leave_Applied = 1
                                SELECT @Grd_OT_Hours = SUM(Grd_OT_Hours) from #OT_Gradewise
                                
                                SET @CL_Leave = ISNULL(@CL_Leave,0) + ISNULL(@Mchn_CL_Leave,0)
                                SELECT  @Day_Basic_Salary = CASE WHEN @Is_Gradewise_Salary = 1 THEN @EMPMASTER_BASIC ELSE Fix_Basic_Salary END, 
                                        @Night_Basic_Salary = CASE WHEN @Is_Gradewise_Salary = 1 THEN @EMPMASTER_BASIC ELSE Fix_Basic_Salary_Night END  
                                FROM T0040_GRADE_MASTER where Grd_ID = @Grd_Id
                            END 
                        ----End-----Fix Basic Salary Grade Wise--------
                    End
                 Else     
                    Begin  
                        -- Rounding condition  Added by Mitesh
                        if @IS_ROUNDING = 1 
                            SET @Salary_Amount  = Round(@Hour_Salary * (@Actual_Working_Sec+ @Other_Working_Sec)/3600,@Round)    
                        Else
                            SELECT @Salary_Amount  = Isnull(@Hour_Salary * (@Actual_Working_Sec + @Other_Working_Sec)/3600,0)    
                    End
                  
                
                if @Wages_Type ='Monthly'    
                    SET @Late_Basic_Amount = @Basic_salary    
                else    
                    SET @Late_Basic_Amount = @Day_Salary    
                              
                   
                   
                if @Fix_Salary = 1
                    Begin
                        SET @Salary_Amount = @Basic_Salary
                    End      
                
                
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
								INNER JOIN T0040_SHIFT_MASTER SM ON D.Shift_ID=SM.Shift_ID
								LEFT OUTER JOIN #Emp_WeekOff_Sal W ON D.Emp_ID=W.Emp_ID AND D.For_Date = W.For_Date AND W.Is_Cancel=0
								LEFT OUTER JOIN #Emp_Holiday_Sal H ON D.Emp_ID=H.Emp_ID AND D.For_Date = H.For_Date AND H.Is_Cancel=0
								LEFT OUTER JOIN T0160_OT_APPROVAL OA ON OA.Emp_ID=D.Emp_Id And OA.For_Date = D.For_Date And OA.Is_Approved = 1
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
                    Begin  
                        
                        If @Emp_OT_Sec > 0  and @Emp_OT_Min_Sec > 0 and @Emp_OT_Sec < @Emp_OT_Min_Sec    
                            SET @Emp_OT_Sec = 0    
                        Else If @Emp_OT_Sec > 0 and @Emp_OT_Max_Sec > 0 and @Emp_OT_Sec > @Emp_OT_Max_Sec    
                            SET @Emp_OT_Sec = @Emp_OT_Max_Sec    

                        
                
                            --Added By Jaina 24-08-2016 Start               
                                
                            Declare @Cust_audit_Emp_OT_Sec numeric(18,0)
                            Declare @Extra_audit_Emp_OT_Num numeric(18,2)
                            Declare @Extra_Audit_OT_Amount as numeric(18,2)
                            Declare @Extra_audit_Emp_OT_Sec numeric(18,0)
                            
                            Declare @Cust_audit_Emp_WO_OT_Sec numeric(18,0)
                            Declare @Extra_audit_Emp_WO_OT_Num numeric(18,2)
                            Declare @Extra_audit_Emp_WO_OT_Amount numeric(18,2)
                            Declare @Extra_audit_Emp_WO_OT_Sec numeric(18,0)
                            Declare @Cust_audit_Emp_HO_OT_Sec numeric(18,0)
                            Declare @Extra_audit_Emp_HO_OT_Num numeric(18,2)
                            declare @Extra_audit_Emp_HO_OT_Amount numeric(18,2)
                            Declare @Extra_audit_Emp_HO_OT_Sec numeric(18,0)
                            Declare @Extra_Audit_Total_OT_Amount numeric(18,2)
                            
                            SET @Cust_audit_Emp_OT_Sec = 0
                            SET @Extra_audit_Emp_OT_Num = 0
                            SET @Extra_Audit_OT_Amount = 0
                            
                            SET @Cust_audit_Emp_WO_OT_Sec =0
                            SET @Extra_audit_Emp_WO_OT_Num = 0
                            SET @Extra_audit_Emp_WO_OT_Amount = 0
                            
                            SET @Cust_audit_Emp_HO_OT_Sec = 0
                            SET @Extra_audit_Emp_HO_OT_Num = 0
                            SET @Extra_audit_Emp_HO_OT_Amount = 0
                            SET @Extra_Audit_Total_OT_Amount  = 0
                            
               SET @Extra_audit_Emp_OT_Sec = 0
                            SET @Extra_audit_Emp_WO_OT_Sec = 0
                            SET @Extra_audit_Emp_HO_OT_Sec = 0
                            

                            if @Cust_Audit = 1
                                begin
                                    
                                    select 
                                        @Cust_audit_Emp_OT_Sec = sum(E.OT_Sec) ,
                                        @Cust_audit_Emp_HO_OT_Sec = sum(E.Holiday_OT_Sec),
                                        @Cust_audit_Emp_WO_OT_Sec = sum(E.Weekoff_OT_Sec)
                                    from T0010_Customer_Audit_Data E Left OUTER JOIN 
                                    T0160_OT_APPROVAL OTA on E.Emp_ID = OTA.Emp_ID and OTA.For_Date = E.For_date        
                                    where   E.Emp_Id = @emp_ID and
                                            OTA.Is_Approved = 1
                                            and (E.For_date between @Month_St_Date and  @Month_End_Date )   
                                                
                                    

                                    SET @Extra_audit_Emp_OT_Sec = isnull(@Emp_OT_sec,0)  - isnull(@Cust_audit_Emp_OT_Sec,0)     
                                    SET @Extra_audit_Emp_HO_OT_Sec  = isnull(@Emp_HO_OT_Sec,0) - ISNULL(@Cust_audit_Emp_HO_OT_Sec,0)
                                    SET @Extra_audit_Emp_WO_OT_Sec = ISNULL(@Emp_WO_OT_Sec,0) - ISNULL(@Cust_audit_Emp_WO_OT_Sec,0) 
                                    
                                
                                    If @Extra_audit_Emp_OT_Sec < 0 
                                        SET @Extra_audit_Emp_OT_Sec = 0
                                    IF @Extra_audit_Emp_HO_OT_Sec < 0 
                                        SET @Extra_audit_Emp_HO_OT_Sec = 0
                                    IF @Extra_audit_Emp_WO_OT_Sec < 0
                                        SET @Extra_audit_Emp_WO_OT_Sec = 0  
                                        
                                    SET @Emp_OT_sec  = isnull(@Cust_audit_Emp_OT_Sec,0)
                                    SET @Emp_HO_OT_Sec = ISNULL(@Cust_audit_Emp_HO_OT_Sec,0)
                                    SET @Emp_WO_OT_Sec = ISNULL(@Cust_audit_Emp_WO_OT_Sec,0)
                                    
                                    If @Emp_OT_sec < 0 
                                        SET @Emp_OT_sec = 0
                                    IF @Emp_HO_OT_Sec < 0 
                                        SET @Emp_HO_OT_Sec = 0
                                    IF @Emp_WO_OT_Sec < 0
                                        SET @Emp_WO_OT_Sec = 0          
                                end
                            --Added By Jaina 24-08-2016 End

							     


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
                                            --      Set @Emp_OT_Sec = @Emp_OT_Sec - @Absent_Sec
                                            --   End
                                            --else
                                            --   Begin
                                            --      Set @Absent_Sec = @Absent_Sec - @Emp_OT_Sec
                                            --      Set @Emp_WO_OT_Sec = @Emp_WO_OT_Sec - @Absent_Sec
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
                                        
                                        SET @IS_OT_Adj_Against_Absent_Hour = dbo.F_Return_Hours(@OT_Adj_Days * @Shift_Day_Sec)   --Added By Jimit 23072018
                                        
                                End
                            End

       

                            IF(ISNULL(@OT_RATE_TYPE,0) = 0) -- AS OLD CONDITION
                                BEGIN
                                    If @Emp_OT_Sec > 0   
                                        BEGIN 
                                            SET @Emp_OT_Hours_Var = dbo.F_Return_Hours(@Emp_OT_Sec)    --Nikunj
                                            SET @Emp_OT_Hours_Var =Replace(@Emp_OT_Hours_Var,':','.')--Nikunj
                                            --SET @Emp_OT_Hours_Num = @Emp_OT_Sec/3600 --Added Hardik 06072013
                                            SET @Emp_OT_Hours_Num =Replace(@Emp_OT_Hours_Var,':','.')
                                            if @IS_ROUNDING = 1   --Added by Jaina 15-03-2017
                                                Begin
                                                
                                                    if @Fix_OT_Hour_Rate_WD = 0   --Added by Jaina 15-03-2017
                                                        SET @OT_Amount = Round(ROUND((@Emp_OT_Hours_Num) * @Hour_Salary_OT,0) * @Emp_WD_OT_Rate,0)
                                                    else
                                                        SET @OT_Amount = Round(ROUND((@Emp_OT_Hours_Num) * @Fix_OT_Hour_Rate_WD,0) * @Emp_WD_OT_Rate,0)
                                                END
                                            ELSE
                                                BEGIN
                                                            
                                                    if @Fix_OT_Hour_Rate_WD = 0   
                                                    BEGIN
                                                        --print @Emp_OT_Hours_Num
                                                        --print @Hour_Salary_OT
                                                        --print @Emp_WD_OT_Rate
                                                        SET @OT_Amount = (@Emp_OT_Hours_Num * @Hour_Salary_OT * @Emp_WD_OT_Rate)                    
                                                        --print @OT_Amount
                                                    end 
                                                    else
                                                        SET @OT_Amount = (@Emp_OT_Hours_Num * @Fix_OT_Hour_Rate_WD * @Emp_WD_OT_Rate )                                                          
                                                END
                                            
                                            
                                            
                                        END     
                                        
                                    IF @EXTRA_AUDIT_EMP_OT_SEC > 0   --Added By Jaina 08-09-2016
                                        BEGIN
                                            SET @Extra_audit_Emp_OT_Num     = @Extra_audit_Emp_OT_Sec /3600 
                                            SET @Extra_Audit_OT_Amount = round( @Extra_audit_Emp_OT_Num * (@Hour_Salary_OT * @Emp_WD_OT_Rate ),0) 
                                        END             
                                    If @Emp_WO_OT_Sec > 0    
                                        BEGIN
                                            SET @Emp_WO_OT_Hours_Var = dbo.F_Return_Hours(@Emp_WO_OT_Sec)
                                            SET @Emp_WO_OT_Hours_Var = Replace(@Emp_WO_OT_Hours_Var,':','.')
                                            --SET @Emp_WO_OT_Hours_Num = Convert (Numeric(22,3), @Emp_WO_OT_Hours_Var)
                                            SET @Emp_WO_OT_Hours_Num = @Emp_WO_OT_Sec/3600 --Added Hardik 06072013
                                            
                                            if @IS_ROUNDING = 1   --Added by Jaina 15-03-2017
                                            begin
                                                                                
                                                IF @FIX_OT_HOUR_RATE_WO_HO = 0   --ADDED BY JAINA 15-03-2017
                                                        SET @WO_OT_Amount = round(ROUND((@Emp_WO_OT_Hours_Num) * @Hour_Salary_OT,0) * @Emp_WO_OT_Rate ,0)                   
												ELSE
                                                        SET @WO_OT_Amount = Round(ROUND((@Emp_WO_OT_Hours_Num) * @FIX_OT_HOUR_RATE_WO_HO,0) * @Emp_WO_OT_Rate,0) 
                                            End
                                            else
                                            begin
                                                                                
                                                IF @FIX_OT_HOUR_RATE_WO_HO = 0   --ADDED BY JAINA 15-03-2017
                                                        SET @WO_OT_Amount = ((@Emp_WO_OT_Hours_Num * @Hour_Salary_OT )* @Emp_WO_OT_Rate )
                                                ELSE
                                                        SET @WO_OT_Amount = ((@Emp_WO_OT_Hours_Num * @FIX_OT_HOUR_RATE_WO_HO) * @Emp_WO_OT_Rate )                   
                                            end
                                            

                                        END         
                                    IF @EXTRA_AUDIT_EMP_WO_OT_SEC > 0    --Added By Jaina 08-09-2016
                                        BEGIN
                                            SET @EXTRA_AUDIT_EMP_WO_OT_NUM  = @EXTRA_AUDIT_EMP_WO_OT_SEC/3600 
                                            SET @EXTRA_AUDIT_EMP_WO_OT_AMOUNT = ROUND((@EXTRA_AUDIT_EMP_WO_OT_NUM) * (@HOUR_SALARY_OT * @EMP_WO_OT_RATE ),0)                    
                                        END         
                                    IF @Emp_HO_OT_Sec > 0    
                                        BEGIN
                                            SET @Emp_HO_OT_Hours_Var = dbo.F_Return_Hours(@Emp_HO_OT_Sec)
                                            SET @Emp_HO_OT_Hours_Var = Replace(@Emp_HO_OT_Hours_Var,':','.')
                                            --SET @Emp_HO_OT_Hours_Num = Convert (Numeric(22,3), @Emp_HO_OT_Hours_Var)
                                            SET @Emp_HO_OT_Hours_Num = @Emp_HO_OT_Sec/3600 --Added Hardik 06072013
                                            
                                            if @IS_ROUNDING = 1  --Added by Jaina 15-03-2017
                                            begin
                                            
                                                if @FIX_OT_HOUR_RATE_WO_HO = 0   --Added by Jaina 15-03-2017
                                                    SET @HO_OT_Amount = round(ROUND((@Emp_HO_OT_Hours_Num) * @Hour_Salary_OT,0) * @Emp_HO_OT_Rate,0)                    
                                                else
                                                    SET @HO_OT_Amount = Round(ROUND((@Emp_HO_OT_Hours_Num) * @FIX_OT_HOUR_RATE_WO_HO,0) * @Emp_HO_OT_Rate,0)    
                                                    
                                            End
                                            else
                                            begin
                                                                                
                                                if @FIX_OT_HOUR_RATE_WO_HO = 0   --Added by Jaina 15-03-2017
                                                    SET @HO_OT_Amount = ((@Emp_HO_OT_Hours_Num * @Hour_Salary_OT )* @Emp_HO_OT_Rate)                    
                                                else
                                                    SET @HO_OT_Amount = ((@Emp_HO_OT_Hours_Num * @FIX_OT_HOUR_RATE_WO_HO) * @Emp_HO_OT_Rate )                   
                                            End
                                            
                                            
                                        END
                                    IF @EXTRA_AUDIT_EMP_HO_OT_SEC > 0 --Added By Jaina 08-09-2016
                                        BEGIN
                                            SET @EXTRA_AUDIT_EMP_HO_OT_NUM = @EXTRA_AUDIT_EMP_HO_OT_SEC /3600 
                                            SET @EXTRA_AUDIT_EMP_HO_OT_AMOUNT  = ROUND((@EXTRA_AUDIT_EMP_HO_OT_NUM) * (@HOUR_SALARY_OT * @EMP_WO_OT_RATE ),0) 
                                        END

                                    SET @Extra_Audit_Total_OT_Amount = isnull(@Extra_Audit_OT_Amount,0) + isnull(@Extra_audit_Emp_WO_OT_Amount,0) + isnull(@Extra_audit_Emp_HO_OT_Amount,0) 
                                    
                                END
                            ELSE
                                BEGIN

                                        ---- GENCHI CLIENT FLOW FOR OVERTIME SLAB WISE WORK ADDED BY RAJPUT ON 18072018----
                                        If @Emp_OT_Sec > 0 OR  @Emp_WO_OT_Sec > 0 OR @Emp_HO_OT_Sec > 0
                                            BEGIN 
                                                        
                                               -- EXEC P0050_GENERAL_OT_RATE_SLABWISE @GEN_ID,@OT_SLAB_TYPE,@EMP_OT_SEC,@Emp_WO_OT_Sec,@Emp_HO_OT_Sec,@Emp_WO_OT_Hours_Var,@Emp_HO_OT_Hours_Var,@Hour_Salary_OT,@IS_ROUNDING,@OT_AMOUNT OUTPUT
                                                
												--Added by ronakk 10032023
													if	 OBJECT_ID('tempdb..#OT_SLAB_MASTER') IS NOT NULL   		
													begin
														drop table #OT_SLAB_MASTER
													end
			                                    --End by ronakk 10032023


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
                                                            
                                                IF EXISTS(SELECT 1 FROM DBO.T0050_GENERAL_OT_RATE_SLABWISE WHERE Gen_ID=@GEN_ID AND @OT_SLAB_TYPE = 0)
                                                    BEGIN
                                                            INSERT INTO #OT_SLAB_MASTER
                                                            SELECT  ROW_NUMBER() OVER (ORDER BY WO_RATE ASC) AS ROW_ID,FROM_HOURS,TO_HOURS,WD_RATE,WO_RATE,HO_RATE,0 AS PERIOD_HOURS,0 AS OT_HOURS,0 AS OT_SLAB_AMOUNT,0 AS FLAG 
                                                            FROM DBO.T0050_GENERAL_OT_RATE_SLABWISE 
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
                                                                        
                                                                        
                                                                        UPDATE  #OT_SLAB_MASTER SET PERIOD_HOURS = @SLAB_DIFF ,OT_HOURS = @SLAB_DIFF ,OT_SLAB_AMOUNT = @OT_SLAB_AMOUNT, FLAG = 1 WHERE From_Hours = @FROM_HOURS AND
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
                                                        IF EXISTS(SELECT 1 FROM DBO.T0050_GENERAL_OT_RATE_SLABWISE WHERE Gen_ID=@GEN_ID AND @OT_SLAB_TYPE = 1)
                                                            BEGIN
                                                                
                                                                INSERT INTO #OT_SLAB_MASTER
                                                                SELECT  ROW_NUMBER() OVER (ORDER BY WO_RATE ASC) AS ROW_ID,FROM_HOURS,TO_HOURS,WD_RATE,WO_RATE,HO_RATE,0 AS PERIOD_HOURS,0 AS OT_HOURS,0 AS OT_SLAB_AMOUNT,0 AS FLAG 
                                                                FROM DBO.T0050_GENERAL_OT_RATE_SLABWISE 
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
                        --If @ExOTSetting > 0 and @OT_Amount > 0    
                        -- SET @OT_Amount = @OT_Amount + @OT_Amount * @ExOTSetting

                        If @Fix_OT_Work_Days > 0 
                            Begin
                                SET @Fix_OT_Work_Days = @Fix_OT_Work_Days
                            End
                        Else
                            Begin
                                SET @Fix_OT_Work_Days = @OT_Working_Day
                            End    
                        
                        
                        IF (@Grade_BasicSalary > 0 OR @Grade_BasicSalary_Night > 0) AND @BasicDA_OT_Salary > 0  --Overtime Calcualte Basic + DA Allowance   --Mafatlal Client   --**Ankit 27082015
                            BEGIN
                            
                                Declare @OT_Max_Limit_Sec as Numeric
                                Declare @OT_Min_Limit_Sec as Numeric
                                
                                SET @OT_Max_Limit_Sec = NULL
                                SET @OT_Min_Limit_Sec = NULL
                            
                                SET @WO_OT_Amount = 0
                                SET @HO_OT_Amount = 0
                                SET @OT_Amount = 0
                                
                                SET @Emp_OT_Hours_Num = ISNULL(@Emp_OT_Hours_Num,0) + ISNULL(@Emp_WO_OT_Hours_Num,0) + ISNULL(@Emp_HO_OT_Hours_Num,0)
                                
                                --SELECT @Emp_OT_Hours_Num , @BasicDA_OT_Salary , @Emp_WD_OT_Rate
                                
                                --New Code for Checking Monthly Max Limit is Added By Ramiz for Mafatlal on 19/11/2015
                                SET @Emp_OT_Sec         = dbo.F_Return_Sec(replace(cast(@Emp_OT_Hours_Num as varchar(20)),'.',':'))
                                SET @OT_Min_Limit_Sec   = dbo.F_Return_Sec(replace(cast(@OT_Min_Limit as varchar(20)),'.',':'))
                                SET @OT_Max_Limit_Sec   = dbo.F_Return_Sec(replace(cast(@OT_Max_Limit as varchar(20)),'.',':'))

                                If @Emp_OT_Sec > 0  and @OT_Min_Limit_Sec > 0 and @Emp_OT_Sec < @OT_Min_Limit_Sec
                                    Begin  
                                        SET @Emp_OT_Sec = 0   
                                    End
                                Else If @Emp_OT_Sec > 0 and @OT_Max_Limit_Sec > 0 and @Emp_OT_Sec > @OT_Max_Limit_Sec
                                    Begin    
                                        SET @Emp_OT_Sec = @OT_Max_Limit_Sec 
                                    End

                                SET @Emp_OT_Hours_Num = Replace(dbo.F_Return_Hours(@Emp_OT_Sec), ':' , '.')
                                --New Code for Checking Monthly Max Limit is Added By Ramiz for Mafatlal on 19/11/2015

                                if Replace(@Fix_OT_Shift_Hours,':','.') = '' OR @Fix_OT_Shift_Hours = '00:00'
                                    SET @Fix_OT_Shift_Hours = '08:00'
                                
                                
                                
                                SET @Hour_Salary_OT = @BasicDA_OT_Salary / 26 / Replace(@Fix_OT_Shift_Hours,':','.')
                                
                                SET @OT_Amount = ROUND((@Emp_OT_Hours_Num) * (@Hour_Salary_OT * @Emp_WD_OT_Rate ),0)      
                                
                            END
                                    
                        --Insert into #OT_Data(Shift_Day_Sec,OT_Working_Day)
                        --select @Fix_OT_Shift_Sec,@Fix_OT_Work_Days
                        
                        -- Added For Late Make Deduction From OT Prority Wise
                            -- 1st Deduction from WeekDay OT
                            -- 2nd Deduction from Weekoff OT
                            -- 3rd Deduction from Holiday OT
                            -- After Deduction if Late Make OT Hours Calculation is greater than Actual OT that time we consider Zero Late Make OT
                            
                        -- Added by nilesh patel on 03062016 --start 
                        if @Late_Adj_Again_OT > 0 and @Is_Late_Mark_Gen = 1   --Change by Jaina 16-03-2017
                            Begin
                                Declare @Total_Late_OT_Hours_Sec Numeric(18,4)
                                SET @Total_Late_OT_Hours_Sec = 0
                                
                                If @Total_Late_OT_Hours <> 0
                                    Begin
                                        SET @Total_Late_OT_Hours_Sec = @Total_Late_OT_Hours*3600
                                    End
                                
                                if @Emp_OT_Sec > 0 
                                    Begin
                                        
                                        if @Total_Late_OT_Hours_Sec > @Emp_OT_Sec 
                                            Begin
                                                SET @Total_Late_OT_Hours_Sec = (@Total_Late_OT_Hours_Sec - @Emp_OT_Sec)
                                                SET @Emp_OT_Sec = 0
                                            End
                                        Else
                                            Begin 
                                                SET @Emp_OT_Sec = (@Emp_OT_Sec - @Total_Late_OT_Hours_Sec)
                                                SET @Total_Late_OT_Hours_Sec = 0
                                            End 
                                    End 
                                
                         if @Emp_WO_OT_Sec > 0 
                                   Begin
                                        if @Total_Late_OT_Hours_Sec > @Emp_WO_OT_Sec 
                                            Begin
                                                SET @Total_Late_OT_Hours_Sec = (@Total_Late_OT_Hours_Sec - @Emp_WO_OT_Sec)
                                                SET @Emp_WO_OT_Sec = 0
                                            End
                                        Else
                                            Begin 
                                                SET @Emp_WO_OT_Sec = (@Emp_WO_OT_Sec - @Total_Late_OT_Hours_Sec)
                                                SET @Total_Late_OT_Hours_Sec = 0
                                            End     
                                   End  
                                
                                if @Emp_HO_OT_Sec > 0   
                                    Begin
                                        
                                        if @Total_Late_OT_Hours_Sec > @Emp_HO_OT_Sec 
                                            Begin
                                                SET @Total_Late_OT_Hours_Sec = (@Total_Late_OT_Hours_Sec - @Emp_HO_OT_Sec)
                                                SET @Emp_HO_OT_Sec = 0
                                            End
                                        Else
                                            Begin 
                                                SET @Emp_HO_OT_Sec = (@Emp_HO_OT_Sec - @Total_Late_OT_Hours_Sec)
                                                SET @Total_Late_OT_Hours_Sec = 0
                                            End 
                                    End         
                                
                                if @Total_Late_OT_Hours_Sec > 0
                                    Begin
                                        SET @Total_Late_OT_Hours_Sec = 0
                                    End
                                
                                SET @Emp_OT_Hours_Num = Replace(dbo.F_Return_Hours(@Emp_OT_Sec), ':' , '.')
                                SET @Emp_WO_OT_Hours_Num = Replace(dbo.F_Return_Hours(@Emp_WO_OT_Sec), ':' , '.')
                                SET @Emp_HO_OT_Hours_Num = Replace(dbo.F_Return_Hours(@Emp_HO_OT_Sec), ':' , '.')
                                
                                SET @OT_Amount = round((@Emp_OT_Hours_Num) * (@Hour_Salary_OT * @Emp_WD_OT_Rate ),0) 
                                SET @WO_OT_Amount = round((@Emp_WO_OT_Hours_Num) * (@Hour_Salary_OT * @Emp_WO_OT_Rate ),0)
                                SET @HO_OT_Amount = round((@Emp_HO_OT_Hours_Num) * (@Hour_Salary_OT * @Emp_HO_OT_Rate ),0) 
                                
                            End
                        -- Added by nilesh patel on 03062016 --End
                        
                        Insert into #OT_Data(Emp_Id,Basic_Salary,Day_Salary,OT_Sec,Ex_OT_SEtting,OT_Amount,Shift_Day_Sec,OT_Working_Day,Emp_OT_Hour,Hourly_Salary,WO_OT_Amount,WO_OT_Hour,WO_OT_Sec,HO_OT_Amount,HO_OT_Hour,HO_OT_Sec)
                        select @Emp_ID,@Basic_Salary,@Day_Salary,@Emp_OT_Sec,@ExOTSetting,@OT_Amount,@Fix_OT_Shift_Sec,@Fix_OT_Work_Days,@Emp_OT_Hours_Num,@Hour_Salary_OT,@WO_OT_Amount,@Emp_WO_OT_Hours_Num,@Emp_WO_OT_Sec,@HO_OT_Amount,@Emp_HO_OT_Hours_Num,@Emp_HO_OT_Sec
                        
                        select @Emp_OT_Hours = dbo.F_Return_Hours(@Emp_OT_Sec)   
                        select @Emp_WO_OT_Hours = dbo.F_Return_Hours(@Emp_WO_OT_Sec)     
                        select @Emp_HO_OT_Hours = dbo.F_Return_Hours(@Emp_HO_OT_Sec)  
                        
                    End    
                else    
					If @Shift_Wise_OT_Calculated = 0 
	                    Begin    
	                        SET @Emp_OT_Sec = 0    
	                        SET @OT_Amount = 0    
	                        SET @Emp_OT_Hours = '00:00' 
	
	                        SET @Emp_WO_OT_Sec = 0    
	                        SET @WO_OT_Amount = 0    
	                        SET @Emp_WO_OT_Hours = '00:00'  
	
	                        SET @Emp_HO_OT_Sec = 0    
	                        SET @HO_OT_Amount = 0    
	                        SET @Emp_HO_OT_Hours = '00:00'     
	
	                        Insert into #OT_Data(Emp_Id,Basic_Salary,Day_Salary,OT_Sec,Ex_OT_SEtting,OT_Amount,OT_Working_Day)
	                        select @Emp_ID,@Basic_Salary,@Day_Salary,0,0,0,0
						End  
                    --added by Jaina 4-10-2017
                    declare @After_Salary numeric
                    SELECT @After_Salary = Setting_Value FROM T0040_SETTING where Setting_Name='After Salary Overtime Payment Process' AND Cmp_ID=@Cmp_ID  --Added by Jaina 11-09-2017
                    if @After_Salary =1
                        begin
                            set @Ot_amount = 0
                            Set @WO_OT_Amount=0
                            Set @HO_OT_Amount=0
                            
                            SET @Emp_OT_Hours = 0
                            Set @Emp_WO_OT_Hours =0
                            SET @Emp_HO_OT_Hours =0
                        end

                    if @Wages_Amount = 1
                        Begin 
                            Declare @Gr_Days as NUMERIC(18, 4)
                            Declare @Gr_Salary_amount as  NUMERIC(18, 4)
                            SET @Gr_Days =0
                            SET @Gr_Salary_amount =0
                            
                            select @Gr_Salary_amount = Gross_salary,@Salary_Amount= Basic_Salary from T0095_Increment where increment_id = @Increment_ID    
                            SET   @Gr_Salary_amount = Round(@Gr_Salary_amount * @Sal_cal_days/@Outof_Days,0) 
                            SET   @Salary_Amount =  ROUND(@Gr_Salary_amount/2 ,0)
                            SET   @Basic_Salary =  @Salary_Amount
                            
                        End  
                    -- commenet and added by rohit on 13102016
                    --Alpesh 25-Nov-2011                        
                    --IF @Fix_Salary = 1 
                    --  Begin
                    --      if @Absent_Day_Calc = 0 
                    --          Begin
                    --              SET @Absent_days = 0
                    --          End
                    --      --SET @Sal_cal_Days = datediff(d,@Month_St_Date,@Month_End_Date) + 1
                    --      -- Comment And Add by rohit For Fix Salaried Employee  which has not Include week off Case For Sales India- 19072013
                    --      --SET @Sal_cal_Days = datediff(d,@Month_St_Date,@Month_End_Date) + 1
                    
                    
                    --      If @Inc_Weekoff = 1    
                    --          begin
                    --              if @Inc_Holiday = 1
                    --                  SET @Sal_cal_Days = datediff(d,@Month_St_Date,@Month_End_Date) + 1
                    --              else 
                    --                  SET @Sal_cal_Days = (datediff(d,@Month_St_Date,@Month_End_Date) + 1) - @Holiday_Days 
                    --          end
                    --      Else 
                    --          begin
                    --              if @Inc_Holiday = 1
                    --                  SET @Sal_cal_Days = (datediff(d,@Month_St_Date,@Month_End_Date) + 1) - @Weekoff_Days
                    --              else        
                    --                  SET @Sal_cal_Days = (datediff(d,@Month_St_Date,@Month_End_Date) + 1) - @Holiday_Days - @Weekoff_Days
                    --          end  
                                    
                    --      -- Ended by rohit on 19072013
                    
                    --      --------Present-----------
                    --      If @Inc_Weekoff = 1    
                    --          BEGIN
                    --              IF @Inc_Holiday = 1
                    --                  SET @Present_Days = @Mid_Inc_Working_Day - (@Weekoff_Days + @Paid_Leave_Days + @Holiday_Days + @OD_leave_Days + @Unpaid_leave_Days + Isnull(@Compoff_leave_Days,0))
                    --              ELSE 
                    --                  SET @Present_Days = @Mid_Inc_Working_Day - (@Weekoff_Days + @Paid_Leave_Days + @OD_leave_Days + @Unpaid_leave_Days + Isnull(@Compoff_leave_Days,0))
                    --          END
                    --      ELSE 
                    --          BEGIN
                    --              IF @Inc_Holiday = 1
                    --                  SET @Present_Days = @Mid_Inc_Working_Day - (@Paid_Leave_Days + @Holiday_Days + @OD_leave_Days + @Unpaid_leave_Days + Isnull(@Compoff_leave_Days,0))
                    --              ELSE        
                    --                  SET @Present_Days = @Mid_Inc_Working_Day - (@Paid_Leave_Days + @OD_leave_Days+ @Unpaid_leave_Days + Isnull(@Compoff_leave_Days,0))
                    --          END  
                    --              --------Present-----------      
                    --  End
                    -- Added by nilesh pate on 23012017 mid join in Fix Salary Days 
          


                    IF @Fix_Salary = 1 
                        Begin
                            if @Absent_Day_Calc = 0 
                                Begin
                                    SET @Absent_days = 0
                                End
                            --SET @Sal_cal_Days = datediff(d,@Month_St_Date,@Month_End_Date) + 1
                            -- Comment And Add by rohit For Fix Salaried Employee  which has not Include week off Case For Sales India- 19072013
                            --SET @Sal_cal_Days = datediff(d,@Month_St_Date,@Month_End_Date) + 1
                        -- SET @Mid_Inc_Working_Day = datediff(d,@Month_St_Date,isnull(@left_date,@Month_End_Date)) + 1
                    
                            If @Inc_Weekoff = 1    
                                begin
									if @Join_Date >= @Month_St_Date and @Left_Date <= @Month_End_Date and @Left_Date is not null -- Added By Nilesh patel on 12082019 Date of join and left in Same Month mantis ID = 0008777
										BEGIN
											if @Inc_Holiday = 1
                                              SET @Sal_cal_Days = (datediff(d,@Join_Date,@Left_Date) + 1)
                                            else 
                                              SET @Sal_cal_Days = datediff(d,@Join_Date,@Left_Date) + 1 - @Holiday_Days
										End
                                   Else if @Join_Date >= @Month_St_Date and @Join_Date <= @Month_End_Date 
                                        Begin
                                            if @Inc_Holiday = 1
                                              SET @Sal_cal_Days = (datediff(d,@Join_Date,@Month_End_Date) + 1)
                                            else 
                                              SET @Sal_cal_Days = datediff(d,@Join_Date,@Month_End_Date) + 1 - @Holiday_Days
                                        End
                                    Else
                                        Begin
                                            if @Inc_Holiday = 1
                                                SET @Sal_cal_Days = datediff(d,@Month_St_Date,isnull(@left_date,@Month_End_Date)) + 1
                                            else 
                                                SET @Sal_cal_Days = (datediff(d,@Month_St_Date,isnull(@left_date,@Month_End_Date)) + 1) - @Holiday_Days 
                                        End
                        	
									--Comment by ronakk 19012023 for #23931 hance this condtion never gone false (confirmed with sandip bhai and deepal bhai)
                                    --IF @Mid_Inc_Working_Day > @Sal_cal_Days -- Added By Nilesh Patel on 12082019 For Present day is greater then salary calculate day mantis ID = 0008775
									--	Set @Mid_Inc_Working_Day = @Sal_cal_Days
                                end
                            Else 
                                begin
									if @Join_Date >= @Month_St_Date and @Left_Date <= @Month_End_Date and @Left_Date is not null -- Added By Nilesh patel on 12082019 Date of join and left in Same Month mantis ID = 0008777
										BEGIN
											if @Inc_Holiday = 1
                                              SET @Sal_cal_Days = datediff(d,@Join_Date,@Left_Date) + 1 - @Weekoff_Days
                                            else 
                                              SET @Sal_cal_Days = datediff(d,@Join_Date,@Left_Date) + 1 - @Holiday_Days - @Weekoff_Days
										End
                                    Else if @Join_Date >= @Month_St_Date and @Join_Date <= @Month_End_Date 
                                        Begin
                                            if @Inc_Holiday = 1
                                              SET @Sal_cal_Days = datediff(d,@Join_Date,@Month_End_Date) + 1 - @Weekoff_Days
                                            else 
                                              SET @Sal_cal_Days = datediff(d,@Join_Date,@Month_End_Date) + 1 - @Holiday_Days - @Weekoff_Days
                                        End
                                    Else
                                        Begin
                                            if @Inc_Holiday = 1
                                                SET @Sal_cal_Days = (datediff(d,@Month_St_Date,isnull(@left_date,@Month_End_Date)) + 1) - @Weekoff_Days
                                            else        
                                                SET @Sal_cal_Days = (datediff(d,@Month_St_Date,isnull(@left_date,@Month_End_Date)) + 1) - @Holiday_Days - @Weekoff_Days
                                        End
                                    
										
									--Comment by ronakk 19012023 for #23931 hance this condtion never gone false (confirmed with sandip bhai and deepal bhai)
                                  --  IF @Mid_Inc_Working_Day > @Sal_cal_Days -- Added By Nilesh Patel on 12082019 For Present day is greater then salary calculate day mantis ID = 0008775
									--	Set @Mid_Inc_Working_Day = @Sal_cal_Days
                                end  
                                    
	

							
                            -- Ended by rohit on 19072013
                    
                            --------Present-----------
                            If @Inc_Weekoff = 1    
                                BEGIN
                                    IF @Inc_Holiday = 1
                                        SET @Present_Days = Isnull(@Mid_Inc_Working_Day,0) - (Isnull(@Weekoff_Days,0) + Isnull(@Paid_Leave_Days,0) + Isnull(@Holiday_Days,0) + Isnull(@OD_leave_Days,0) + Isnull(@Unpaid_leave_Days,0) + Isnull(@Compoff_leave_Days,0) + Isnull(@OutOf_Days_left,0)) ---changed by jimit 07022017
                                    ELSE 
                                        SET @Present_Days = ISNULL(@Mid_Inc_Working_Day,0) - (ISNULL(@Weekoff_Days,0) + ISNULL(@Paid_Leave_Days,0) + ISNULL(@OD_leave_Days,0) + ISNULL(@Unpaid_leave_Days,0) + Isnull(@Compoff_leave_Days,0) + ISNULL(@OutOf_Days_left,0))   ---changed by jimit 07022017
                                        --SET @Present_Days = @Mid_Inc_Working_Day - (@Weekoff_Days + @Paid_Leave_Days + @OD_leave_Days + @Unpaid_leave_Days + Isnull(@Compoff_leave_Days,0) + @OutOf_Days_left)
                                END
                            ELSE 
                                BEGIN
                                    IF @Inc_Holiday = 1
                                    SET @Present_Days = ISNULL(@Mid_Inc_Working_Day,0) - (ISNULL(@Paid_Leave_Days,0) + ISNULL(@Holiday_Days,0) + ISNULL(@OD_leave_Days,0) + ISNULL(@Unpaid_leave_Days,0) + Isnull(@Compoff_leave_Days,0) + ISNULL(@OutOf_Days_left,0))  ---changed by jimit 07022017
                                        --SET @Present_Days = @Mid_Inc_Working_Day - (@Paid_Leave_Days + @Holiday_Days + @OD_leave_Days + @Unpaid_leave_Days + Isnull(@Compoff_leave_Days,0) + @OutOf_Days_left)
                                    ELSE        
                                        SET @Present_Days = Isnull(@Mid_Inc_Working_Day,0) - (Isnull(@Paid_Leave_Days,0) + Isnull(@OD_leave_Days,0) + Isnull(@Unpaid_leave_Days,0) + Isnull(@Compoff_leave_Days,0) + Isnull(@OutOf_Days_left,0))  ---changed by jimit 07022017
                                        --SET @Present_Days = @Mid_Inc_Working_Day - (@Paid_Leave_Days + @OD_leave_Days+ @Unpaid_leave_Days + Isnull(@Compoff_leave_Days,0) + @OutOf_Days_left)
                                END  
                                    --------Present-----------  
                        If @SalaryBasis ='Day'          
                        begin
                            if @IS_ROUNDING = 1
                                Begin
                                    SET @Salary_Amount  = Round(@Day_Salary * @Sal_Cal_Days,@Round) 
                                    SET @Salary_amount_Arear = Round(@Day_Salary_Arear * @Arear_Day,@Round)
                                    SET @Salary_amount_Arear_cutoff = Round(@Day_Salary_Arear_cutoff * @Absent_after_Cutoff_date,@Round)
                                end
                            Else
                                Begin
                                    SET @Salary_Amount  = Isnull(@Day_Salary * @Sal_Cal_Days,0)
                                    SET @Salary_amount_Arear = Isnull(@Day_Salary_Arear * @Arear_Day,0)
                                    SET @Salary_amount_Arear_cutoff = Isnull(@Day_Salary_Arear_cutoff * @Absent_after_Cutoff_date,0) 
                                End 
                            end 
                                    
                        End
                        

														          
			
                            
                    SET @Gross_Salary_ProRata = Round(@Gross_Salary_ProRata * @Sal_Cal_Days,@Round)    
                    SET @M_IT_Tax = isnull(@M_IT_Tax,0) + ISNULL(@IT_M_ED_Cess_Amount,0)
                    
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
                
                    --Added by nilesh patel on 01082018 -- Count Night shift Assign 
                    
                        Select @Night_Shift_Count =  COUNT(1) 
                            From #Data 
                        Where CONVERT(time,Shift_Start_Time) > CONVERT(time,Shift_End_Time) and Emp_ID = @Emp_ID 
                        and For_Date >= @month_St_Date 
                        AND For_Date <= @Month_End_Date
                    --Added by nilesh patel on 01082018 -- Count Night shift Assign 
                    
                    --SELECT @Sal_Tran_ID,@emp_ID,@Cmp_ID,@Increment_ID,@month_St_Date,@Month_End_Date,@Wages_type,@Basic_Salary,@Gross_Salary_ProRata,@Salary_Amount,@Present_Days,@Absent_Days,@Paid_leave_Days,@Sal_Cal_Days,@OutOf_Days,@OT_Amount output,@Day_Salary ,@Branch_ID,@M_IT_Tax,null,@late_Extra_Amount,@Allo_On_Leave,@Working_days_Day_Rate  ,@Areas_Amount, @IS_ROUNDING , @WO_OT_Amount output , @HO_OT_Amount output , @tmp_Month_St_Date , @tmp_Month_End_Date,@Arear_Day,@Arear_Month,@Arear_Year,@Salary_Amount_Arear,@total_count_all_incremnet,@Working_days_Arear,@Absent_after_Cutoff_date,@Arear_Month_cutoff,@Arear_Year_cutoff,@Salary_amount_Arear_cutoff,@Working_days_Arear_cutoff,@Extra_Audit_Total_OT_Amount --Alpesh 20-Jul-2011 Rounding parameter added    --Change By Jaina 08-09-2016 --Change Working day perameter to @Working_days_Day_Rate Sumit on 09/11/2016
                    --EXEC dbo.SP_CALCULATE_ALLOWANCE_DEDUCTION @Sal_Tran_ID,@emp_ID,@Cmp_ID,@Increment_ID,@month_St_Date,@Month_End_Date,@Wages_type,@Basic_Salary,@Gross_Salary_ProRata,@Salary_Amount,@Present_Days,@Absent_Days,@Paid_leave_Days,@Sal_Cal_Days,@OutOf_Days,@OT_Amount output,@Day_Salary ,@Branch_ID,@M_IT_Tax,null,@late_Extra_Amount,@Allo_On_Leave,@Working_days  ,@Areas_Amount, @IS_ROUNDING , @WO_OT_Amount output , @HO_OT_Amount output , @tmp_Month_St_Date , @tmp_Month_End_Date,@Arear_Day,@Arear_Month,@Arear_Year,@Salary_Amount_Arear,@total_count_all_incremnet,@Working_days_Arear,@Absent_after_Cutoff_date,@Arear_Month_cutoff,@Arear_Year_cutoff,@Salary_amount_Arear_cutoff,@Working_days_Arear_cutoff,@Extra_Audit_Total_OT_Amount --Alpesh 20-Jul-2011 Rounding parameter added    --Change By Jaina 08-09-2016
                    

					--Birla century logic for Peresent on holiday
					--if @sal_cal_days > 0
					--Begin  
					--	if @present_on_holiday > 0
					--	Begin
					--		set @sal_cal_days = @sal_cal_days + @present_on_holiday
					--		Set @Salary_amount = isnull(@Day_Salary,0) * isnull(@sal_cal_days,0)
					--	END							
					--END


                    EXEC dbo.SP_CALCULATE_ALLOWANCE_DEDUCTION @Sal_Tran_ID,@emp_ID,@Cmp_ID,@Increment_ID,@month_St_Date,@Month_End_Date,@Wages_type,@Basic_Salary,@Gross_Salary_ProRata,@Salary_Amount,@Present_Days,@Absent_Days,@Paid_leave_Days,@Sal_Cal_Days,@OutOf_Days,@OT_Amount output,@Day_Salary ,@Branch_ID,@M_IT_Tax,null,@late_Extra_Amount,@Allo_On_Leave,@Working_days_Day_Rate  ,@Areas_Amount, @IS_ROUNDING , @WO_OT_Amount output , @HO_OT_Amount output , @tmp_Month_St_Date , @tmp_Month_End_Date,@Arear_Day,@Arear_Month,@Arear_Year,@Salary_Amount_Arear,@total_count_all_incremnet,@Working_days_Arear,@Absent_after_Cutoff_date,@Arear_Month_cutoff,@Arear_Year_cutoff,@Salary_amount_Arear_cutoff,@Working_days_Arear_cutoff,@Extra_Audit_Total_OT_Amount,@CutoffDate_Salary,@Night_Shift_Count,@Shift_Wise_OT_Rate --Alpesh 20-Jul-2011 Rounding parameter added    --Change By Jaina 08-09-2016 --Change Working day perameter to @Working_days_Day_Rate Sumit on 09/11/2016
                    
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
                        
                    TRUNCATE TABLE #T0210_MONTHLY_AD_DETAIL
                    INSERT INTO #T0210_MONTHLY_AD_DETAIL
                    SELECT * FROM dbo.T0210_MONTHLY_AD_DETAIL 
                    WHERE   TEMP_SAL_TRAN_ID=@SAL_TRAN_ID
                        
                    SET @M_IT_Tax = isnull(@M_IT_Tax,0) - ISNULL(@IT_M_ED_Cess_Amount,0)
                                
                    
                    -- Added by Hardik 30/08/2012 for TDS to be save in T0200_Monthly_Salary Table  
                    SELECT  @M_IT_Tax = Isnull(Sum(M_AD_Amount),0) 
                    FROM    #T0210_MONTHLY_AD_DETAIL MAD inner join   dbo.T0050_AD_MASTER AD ON  MAD.AD_ID=AD.AD_ID  
                    WHERE   MAD.TEMP_SAL_TRAN_ID = @Sal_Tran_Id   AND AD.Ad_Def_Id = 1 AND AD.Cmp_ID=@Cmp_ID
        
        
               
                    Declare @Temp_Allowance numeric(22,0)
                    Declare  @Temp_Allowance_Arear NUMERIC(18, 4) --Hardik 07/01/2012
                    Declare @Temp_Deduction numeric(22,0)
                    DECLARE  @Temp_Deduction_Arear NUMERIC(18, 4) --Hardik 07/01/2012
                    Declare @Temp_Allownace_PT numeric(22,0)
                    Declare @Reim_amount as NUMERIC(18, 4)
                    declare @adv_amt1 as NUMERIC(18, 4)
                    
                        -- Added by rohit on 12012015
                    Declare  @Temp_Allowance_Arear_Cutoff NUMERIC(18, 4)
                    DECLARE  @Temp_Deduction_Arear_Cutoff NUMERIC(18, 4)
                    
                    SET @Temp_Allowance_Arear_Cutoff = 0
                    SET @Temp_Deduction_Arear_Cutoff = 0
                    -- Ended by rohit on 12012015
                    
                    SET @Temp_Allowance=0
                    SET @Temp_Allowance_Arear=0
                    SET @Temp_Deduction=0
                    SET @Temp_Deduction_Arear=0
                    SET @Temp_Allownace_PT = 0
                    SET @Reim_amount =0

                    ----Added by Gadriwala Muslim 06012015 - Start
                    --Declare @Ad_Effect_Gate_Pass_Amount as NUMERIC(18, 4)
                    --SET @Ad_Effect_Gate_Pass_Amount = 0
                    
                    
                    --SELECT @Ad_Effect_Gate_Pass_Amount = isnull(SUM(ISNULL(M_AD_AMOUNT,0)),0) From T0210_MONTHLY_AD_DETAIL       
                    --  WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID  and m_AD_Flag ='I' and Cmp_Id=@Cmp_ID      
                    --  AND AD_ID in (select AD_ID from T0050_AD_Master where Cmp_ID =@Cmp_ID and isnull(AD_Effect_on_gatepass ,0) = 1 )
                    
                
                    -- if isnull(@GatePass_Deduct_Days,0) > 0 
                    --      SET @GatePassAmount =  ((@Basic_Salary +  isnull(@Ad_Effect_Gate_Pass_Amount,0)) /@Working_days)  *  @GatePass_Deduct_Days 
                    --else
                    --      SET @GatePassAmount = 0
                            
                    ----Added by Gadriwala Muslim 06012015 - End    


                           
                    --SELECT @Allow_Amount = sum(ISNULL(M_AD_AMOUNT,0)) From T0210_MONTHLY_AD_DETAIL       
                    --  WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I'  and Cmp_Id=@Cmp_ID      
                    --  AND AD_ID not in (select AD_ID from T0050_AD_Master where Cmp_ID =@Cmp_ID 
                    --  and  isnull(Ad_Effect_Month,'')<>'' or (isnull(AD_Not_effect_salary,0) = 1 )  )
                    
                    ---Change done by Hardik bhai in Bhaskar and Same done in Live by Ramiz on 10042015  ----
                    --Optimized by Nimesh on 22-Dec-2015 
                    ---Change done by Hardik bhai in Bhaskar and Same done in Live by Ramiz on 10042015  ----
                    SELECT  @Allow_Amount = SUM(ISNULL(M_AD_Amount  ,0)) 
                    From    dbo.T0210_MONTHLY_AD_DETAIL MAD
                            LEFT OUTER JOIN dbo.T0200_MONTHLY_SALARY MS ON MS.Emp_Id = MAD.Emp_ID and Is_FNF=1 AND MS.Sal_Tran_ID=MAD.Sal_Tran_ID
                            LEFT OUTER JOIN dbo.T0050_AD_Master AD ON AD.Cmp_ID=MAD.Cmp_ID AND AD.AD_ID=MAD.AD_ID 
                                                    AND  (ISNULL(Ad_Effect_Month,'') <> '' or (isnull(AD_Not_effect_salary,0) = 1))                                                 
                    WHERE   MAD.Emp_ID = @Emp_ID AND m_AD_Flag ='I' AND MAD.Cmp_Id=@Cmp_ID 
                            AND for_date=@tmp_Month_St_Date and To_date=@tmp_Month_End_Date 
                            AND MS.Sal_Tran_ID IS NULL AND AD.AD_ID IS NULL
                            --AND NOT EXISTS (Select TOP 1 Sal_Tran_Id From dbo.T0200_MONTHLY_SALARY MS WHERE Emp_Id = @Emp_Id and Is_FNF=1 AND MS.Sal_Tran_ID=MAD.Sal_Tran_ID) 
                            --AND NOT EXISTS (select    AD_ID from dbo.T0050_AD_Master AD 
                            --              where   Cmp_ID =@Cmp_ID AND AD.AD_ID=MAD.AD_ID 
                            --                      AND  (ISNULL(Ad_Effect_Month,'') <> '' or (isnull(AD_Not_effect_salary,0) = 1))
                            --               )
                    ---End of Changes done  -------

                    --SELECT @Allow_Amount = sum(ISNULL(M_AD_AMOUNT,0)) From T0210_MONTHLY_AD_DETAIL       
                    --  WHERE --TEMP_SAL_TRAN_ID = @Sal_Tran_ID and
                    --  Emp_ID = @Emp_ID and m_AD_Flag ='I'  and Cmp_Id=@Cmp_ID and
                    --  For_date = @month_st_date and To_date = @month_end_date 
                    --  and Sal_Tran_ID not in (Select Sal_Tran_Id From T0200_MONTHLY_SALARY where Emp_Id = @Emp_Id and Is_FNF=1)
                    --  AND AD_ID not in (select AD_ID from T0050_AD_Master where Cmp_ID =@Cmp_ID 
                    --  and  isnull(Ad_Effect_Month,'')<>'' or (isnull(AD_Not_effect_salary,0) = 1 )  )

                    ----Get Reimbursement Amount-------------
                    --Optimized by Nimesh on 22-Dec-2015 



                    SELECT  @Reim_amount = SUM(case when isnull(ReimShow,0) = 0 then ISNULL(M_AD_AMOUNT,0) ELSE isnull(ReimAmount,0) end)
                    FROM    #T0210_MONTHLY_AD_DETAIL MAD inner JOIN dbo.T0050_AD_Master AM ON MAD.AD_ID= AM.AD_ID
                    WHERE   MAD.TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='I' and Emp_ID = @Emp_ID  and AM.Cmp_Id=@Cmp_ID -- Uncomment by rohit on 17022017 for cera case
                            and (isnull(AD_Not_effect_salary,0) = 1 and isnull(MAD.ReimShow,0) = 1) 
                    ----Adding Reimbursement Amount Reimshow flag is equal to 1--------

                    SET @Allow_Amount =isnull(@Allow_Amount,0) + ISNULL(@Reim_amount,0) 

                    --Optimized by Nimesh on 22-Dec-2015 
                    SELECT  @Temp_Allowance = SUM(ISNULL(M_AD_AMOUNT,0)) From #T0210_MONTHLY_AD_DETAIL MAD
                    WHERE   TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='I' and Emp_ID = @Emp_ID and Cmp_Id=@Cmp_ID       
                            AND EXISTS (
                                        select  AD_ID from dbo.T0050_AD_Master AD 
                                        where   Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 0 And Charindex(@Strmonth,Ad_Effect_Month )<> 0
                                                AND AD.AD_ID=MAD.AD_ID
                                       )    
                    
                    --Hardik 07/01/2012 for Arears Allowance Amount
                    --Optimized by Nimesh on 22-Dec-2015 
                    SELECT  @Allow_Amount_Arear = SUM(ISNULL(M_AREAR_AMOUNT,0)) 
                    From    #T0210_MONTHLY_AD_DETAIL MAD
                            LEFT OUTER JOIN dbo.T0050_AD_Master AD ON AD.CMP_ID=MAD.Cmp_ID and (isnull(AD_Not_effect_salary,0) = 1 OR isnull(Ad_Effect_Month,'')<>'') AND MAD.AD_ID=AD.AD_ID
                    WHERE   TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='I' and Emp_ID = @Emp_ID  -- Uncomment by rohit on 17022017 for cera case
                            AND AD.AD_ID IS NULL
                    --AND NOT EXISTS (select AD_ID from dbo.T0050_AD_Master AD 
                    --              where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 1 OR isnull(Ad_Effect_Month,'')<>'' AND MAD.AD_ID=AD.AD_ID)

                    SELECT  @Allow_Amount_Arear = @Allow_Amount_Arear + Isnull(SUM(ISNULL(M_AREAR_AMOUNT,0)) ,0)
                    From    #T0210_MONTHLY_AD_DETAIL MAD
                            INNER JOIN dbo.T0050_AD_Master AD ON AD.CMP_ID=MAD.Cmp_ID and (isnull(AD_Not_effect_salary,0) = 1 OR isnull(Ad_Effect_Month,'')<>'') AND MAD.AD_ID=AD.AD_ID
                  WHERE   TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='I' and Emp_ID = @Emp_ID  
                            AND MAD.ReimShow=1 and 
							1 = Case when Auto_Paid = 1 then (case when AD_CAL_TYPE = 'Quaterly' and MONTH(mad.To_date) in (3,6,9,12) then 1 --Added By Jimit 03122018 need to check the Auto Piad case (WCl) if it is set to 1 then consider those reimbursements amount.
							                                   when AD_CAL_TYPE = 'Monthly' then 1
							                                   when AD_CAL_TYPE = 'Half Yearly' and MONTH(mad.To_date) in (3,9) then 1
							                                   when AD_CAL_TYPE = 'Yearly' and MONTH(mad.To_date) in (3) then 1
							                                   else 0
							                               end)
							                               else 0 end
                            
                    --SELECT @Temp_Allowance_Arear = SUM(ISNULL(M_AREAR_AMOUNT,0)) From #T0210_MONTHLY_AD_DETAIL MAD      
                    --WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='I'  and Emp_ID = @Emp_ID 
                    --AND EXISTS (select AD_ID from dbo.T0050_AD_Master AD where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 0 And Charindex(@Strmonth,Ad_Effect_Month )<> 0 AND MAD.AD_ID=AD.AD_ID)

                    -- Added by rohit on 12012015
                    --Optimized by Nimesh on 22-Dec-2015 
                    --SELECT @Allow_Amount_Arear_Cutoff = SUM(ISNULL(M_AREAR_AMOUNT_Cutoff,0)) From #T0210_MONTHLY_AD_DETAIL MAD     
                    --  WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID  and m_AD_Flag ='I' and Emp_ID = @Emp_ID
                    --  AND NOT EXISTS (select AD_ID from dbo.T0050_AD_Master AD where Cmp_ID =@Cmp_ID and (isnull(AD_Not_effect_salary,0) = 1 OR isnull(Ad_Effect_Month,'')<>'') AND MAD.AD_ID=AD.AD_ID)

                    ----Optimized by Nimesh on 22-Dec-2015 
                    --SELECT @Temp_Allowance_Arear_Cutoff = SUM(ISNULL(M_AREAR_AMOUNT_Cutoff,0)) From #T0210_MONTHLY_AD_DETAIL MAD
                    --  WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='I'  and Emp_ID = @Emp_ID 
                    --  AND EXISTS(select AD_ID from dbo.T0050_AD_Master AD where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 0 And Charindex(@Strmonth,Ad_Effect_Month )<> 0 AND MAD.AD_ID=AD.AD_ID)

                    -- ended by rohit on 12012015
                    
                    -- Commented above code by Hardik 26/06/2018 and added below code for Arkray as Arrear cutoff amount for reimbursement is not adding gross
                    SELECT  @Allow_Amount_Arear_Cutoff = SUM(ISNULL(M_AREAR_AMOUNT_Cutoff,0)) 
                    From    #T0210_MONTHLY_AD_DETAIL MAD
                            LEFT OUTER JOIN dbo.T0050_AD_Master AD ON AD.CMP_ID=MAD.Cmp_ID and (isnull(AD_Not_effect_salary,0) = 1 OR isnull(Ad_Effect_Month,'')<>'') AND MAD.AD_ID=AD.AD_ID
                    WHERE   TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='I' and Emp_ID = @Emp_ID  
                            AND AD.AD_ID IS NULL
                    
                    SELECT  @Allow_Amount_Arear_Cutoff = @Allow_Amount_Arear_Cutoff + Isnull(SUM(ISNULL(M_AREAR_AMOUNT_Cutoff,0)) ,0)
                    From    #T0210_MONTHLY_AD_DETAIL MAD
                            INNER JOIN dbo.T0050_AD_Master AD ON AD.CMP_ID=MAD.Cmp_ID and (isnull(AD_Not_effect_salary,0) = 1 OR isnull(Ad_Effect_Month,'')<>'') AND MAD.AD_ID=AD.AD_ID
                    WHERE   TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='I' and Emp_ID = @Emp_ID 
                            AND MAD.ReimShow=1
                    
                    

                    --change by Falak on 02-OCT-2010 for effecting 'Not Effect on PT' in Allownace/DED MAster
                    --Optimized by Nimesh on 22-Dec-2015 
                    SELECT @Temp_Allownace_PT = SUM(ISNULL(M_AD_AMOUNT,0)) From #T0210_MONTHLY_AD_DETAIL MAD      
       WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='I' and isnull(M_AD_Not_effect_ON_PT,0) = 1 and Emp_ID = @Emp_ID and Cmp_Id=@Cmp_ID      
                    and EXISTS (select AD_ID from dbo.T0050_AD_Master AD where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_ON_PT,0) = 1 and isnull(AD_Not_effect_salary,0) = 0 AND MAD.AD_ID=AD.AD_ID)

                        
                        -- Added by rohit for allowance that not effect on gross salary but calculate in net salary on 06-may-2013

                    --Optimized by Nimesh on 22-Dec-2015 
                    SELECT  @Allow_Amount_Effect_only_Net = SUM(ISNULL(M_AD_AMOUNT,0)) + SUM(ISNULL(M_AREAR_AMOUNT,0)) + SUM(ISNULL(M_AREAR_AMOUNT_Cutoff ,0)) 
                    From    #T0210_MONTHLY_AD_DETAIL MAD   
                    WHERE   TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='I' and Cmp_Id=@Cmp_ID and Emp_ID = @Emp_ID 
                            AND EXISTS (select AD_ID from dbo.T0050_AD_Master AD where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 1 and isnull(Effect_Net_Salary,0)=1 AND MAD.AD_ID=AD.AD_ID)

                    -- Ended by rohit  06-may-2013
                    
                    ---Changes done by Hardik bhai in Bhaskar , same done in Live by Ramiz on 10042015----------------                       
                     --SELECT @Dedu_Amount = SUM(ISNULL(M_AD_AMOUNT,0)) FRom T0210_MONTHLY_AD_DETAIL       
                     --  WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='D' and Cmp_Id=@Cmp_ID       
                        --and AD_ID not in (select AD_ID from T0050_AD_Master where Cmp_ID =@Cmp_ID and  isnull(AD_Not_effect_salary,0) = 1 OR isnull(Ad_Effect_Month,'')<>'')       
                        
                        
                    --Optimized by Nimesh on 22-Dec-2015    
                    SELECT  @Dedu_Amount = sum(ISNULL(M_AD_AMOUNT,0)) 
                    From    dbo.T0210_MONTHLY_AD_DETAIL MAD
                    WHERE   m_AD_Flag ='D' and Emp_ID = @Emp_ID --and Cmp_Id=@Cmp_ID 
                            and for_date=@tmp_Month_St_Date and To_date=@tmp_Month_End_Date 
                            and NOT EXISTS (Select Sal_Tran_Id From T0200_MONTHLY_SALARY MS where Emp_Id = @Emp_Id and Is_FNF=1 AND MS.Sal_Tran_ID=MAD.Sal_Tran_ID) 
                            AND NOT EXISTS (select AD_ID from dbo.T0050_AD_Master AD where Cmp_ID =@Cmp_ID  
                                                    and  (isnull(Ad_Effect_Month,'')<>'' or (isnull(AD_Not_effect_salary,0) = 1 )) AND MAD.AD_ID=AD.AD_ID
                                             )  
                    ---End of Changes done in Live by Ramiz on 10042015----------------
                     
                    --Optimized by Nimesh on 22-Dec-2015  
                    SELECT @Temp_Deduction = SUM(ISNULL(M_AD_AMOUNT,0)) 
                    From    #T0210_MONTHLY_AD_DETAIL MAD
                    WHERE   TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='D' and Cmp_Id=@Cmp_ID and Emp_ID = @Emp_ID 
                            AND EXISTS (SELECT AD_ID from dbo.T0050_AD_MASTER AD 
                                        where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 0 And Charindex(@Strmonth,Ad_Effect_Month )<> 0 AND MAD.AD_ID=AD.AD_ID)           
                    
                    --Hardik 07/01/2012
                    --Optimized by Nimesh on 22-Dec-2015  
                    SELECT  @Dedu_Amount_Arear = SUM(ISNULL(M_AREAR_AMOUNT,0)) 
                    FRom    #T0210_MONTHLY_AD_DETAIL MAD
                    WHERE   TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='D' and Emp_ID = @Emp_ID 
                            AND NOT EXISTS (SELECT AD_ID FROM dbo.T0050_AD_Master AD
                                        where Cmp_ID =@Cmp_ID and  (isnull(AD_Not_effect_salary,0) = 1 OR isnull(Ad_Effect_Month,'')<>'') AND MAD.AD_ID=AD.AD_ID)

                    --Optimized by Nimesh on 22-Dec-2015  
                    SELECT  @Temp_Deduction_Arear = SUM(ISNULL(M_AREAR_AMOUNT,0)) 
                    From    #T0210_MONTHLY_AD_DETAIL MAD
                    WHERE   TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='D' and Emp_ID = @Emp_ID 
                            AND EXISTS (SELECT AD_ID FROM dbo.T0050_AD_Master AD
                                        WHERE Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 0 And Charindex(@Strmonth,Ad_Effect_Month )<> 0 AND MAD.AD_ID=AD.AD_ID)           
                    
                    -- Added by rohit on 12012015
                    --Optimized by Nimesh on 22-Dec-2015  
                    SELECT  @Dedu_Amount_Arear_cutoff = SUM(ISNULL(M_AREAR_AMOUNT_cutoff,0)) 
                    FROM    #T0210_MONTHLY_AD_DETAIL MAD     
                    WHERE   TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='D'  and Emp_ID = @Emp_ID 
                            AND NOT EXISTS (SELECT AD_ID FROM dbo.T0050_AD_Master AD
                                            WHERE Cmp_ID =@Cmp_ID and  (isnull(AD_Not_effect_salary,0) = 1 OR isnull(Ad_Effect_Month,'')<>'') AND MAD.AD_ID=AD.AD_ID)

                    --Optimized by Nimesh on 22-Dec-2015  
                    SELECT  @Temp_Deduction_Arear_Cutoff = SUM(ISNULL(M_AREAR_AMOUNT_cutoff,0)) 
                    From    #T0210_MONTHLY_AD_DETAIL MAD
                    WHERE   TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='D'  and Emp_ID = @Emp_ID 
                            AND EXISTS (select AD_ID from dbo.T0050_AD_Master AD 
                                        where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 0 And Charindex(@Strmonth,Ad_Effect_Month )<> 0 AND MAD.AD_ID=AD.AD_ID)           

                    -- ended by rohit on 12012015
        
        
                    -- Added by rohit for allowance that not effect on gross salary but calculate in net salary on 06-may-2013
                    --Optimized by Nimesh on 22-Dec-2015  
                    SELECT  @Deduct_Amount_Effect_only_Net = SUM(ISNULL(M_AD_AMOUNT,0)) + SUM(ISNULL(M_AREAR_AMOUNT,0)) +SUM(ISNULL(M_AREAR_AMOUNT_Cutoff ,0)) 
                    From    #T0210_MONTHLY_AD_DETAIL MAD
                    WHERE   TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='D' and Emp_ID = @Emp_ID  and Cmp_Id=@Cmp_ID      
                            AND EXISTS (select AD_ID from dbo.T0050_AD_Master AD 
                                        where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 1 and isnull(Effect_Net_Salary,0)=1 AND MAD.AD_ID=AD.AD_ID)
                    -- Ended by rohit  06-may-2013
                        
                    SET  @Allow_Amount = isnull(@Allow_Amount,0) + isnull(@Temp_Allowance,0)
                    SET  @Allow_Amount_Arear = isnull(@Allow_Amount_Arear,0) + isnull(@Temp_Allowance_Arear,0) --Hardik 07/01/2012
                    SET @Dedu_Amount = isnull(@Dedu_Amount,0) + isnull(@Temp_Deduction,0)
                    SET @Dedu_Amount_Arear = isnull(@Dedu_Amount_Arear,0) + isnull(@Temp_Deduction_Arear,0)      --Hardik 07/01/2012
                    SET @Allow_Amount_Arear = isnull(@Allow_Amount_Arear,0)    --Hardik 07/01/2012
                    SET @Dedu_Amount_Arear = isnull(@Dedu_Amount_Arear,0)           --Hardik 07/01/2012
                    --Change by Falak on 29-OCT-2010
        
                    -- Added by rohit on 12012015
                    SET  @Allow_Amount_Arear_Cutoff = isnull(@Allow_Amount_Arear_Cutoff,0) + isnull(@Temp_Allowance_Arear_Cutoff,0) --Hardik 07/01/2012
                    SET @Dedu_Amount_Arear_cutoff = isnull(@Dedu_Amount_Arear_cutoff,0) + isnull(@Temp_Deduction_Arear_Cutoff,0)      --Hardik 07/01/2012
                    -- ended by rohit on 12012015
        
                    Declare @IS_Bonus_EFf_Sal numeric(1,0)

                    select @Bonus_Amount     = isnull(Bonus_Amount,0),@IS_Bonus_Eff_Sal = Bonus_Effect_On_Sal 
                    from T0180_bonus where Emp_Id =@Emp_ID 
                    and Bonus_Effect_Month =Month(@Month_End_Date) and Bonus_Effect_Year =Year(@Month_End_Date) 
                    And Bonus_Effect_on_Sal > 0 --Condition Added by Hardik 04/06/2013

                    --Added by Mukti(09102017)start
                    SELECT @Bonus_Amount = isnull(Total_Bonus_Amount,0),@IS_Bonus_Eff_Sal = Bonus_Effect_On_Sal from dbo.T0100_Bonus_Slabwise 
                    where Emp_Id =@Emp_ID and Bonus_Effect_Month =Month(@Month_End_Date) and Bonus_Effect_Year =Year(@Month_End_Date) and Bonus_Effect_on_Sal = 1
                    --Added by Mukti(09102017)end
                    
                     --------------- Hourly Late --------------------    
                    --Optimized by Nimesh on 22-Dec-2015  
                    SELECT  @Late_Basic_Amount = @Late_Basic_Amount +  isnull(SUM(ISNULL(M_AD_AMOUNT,0)),0) 
                    From    dbo.T0210_MONTHLY_AD_DETAIL     
                    WHERE   TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='I' AND isnull(M_AD_Effect_on_Late,0) = 1 and Emp_ID = @Emp_ID  and Cmp_Id=@Cmp_ID    
                    
                    SELECT @Late_Basic_Amount = @Late_Basic_Amount -  isnull(SUM(ISNULL(M_AD_AMOUNT,0)),0) 
                    From    dbo.T0210_MONTHLY_AD_DETAIL     
                    WHERE   TEMP_SAL_TRAN_ID = @Sal_Tran_ID and m_AD_Flag ='D' AND isnull(M_AD_Effect_on_Late,0) = 1 and Emp_ID = @Emp_ID  and Cmp_Id=@Cmp_ID    
             
                      
                    SET @Hour_Salary_Late = (@Late_Basic_Amount/@Fix_late_W_Days)/(@Fix_late_W_Shift_Sec/3600)    
                    SET @Late_Dedu_Amount = 0    
                    SET @Extra_Late_Dedu_Amount = 0  
                     
                    if @Total_Late_Sec > 0 and @Late_Mark_Scenario = 0    
                        begin    
                            SET @Late_Dedu_Amount = round(@Hour_Salary_Late * (@Total_Late_Sec /3600),0)    
                            SET @Extra_Late_Dedu_Amount = @Extra_Late_Deduction * @Late_Dedu_Amount    
                        end 
           
                    --Start----------------Early------------Mitesh-----------
           
           
                    SET @Hour_Salary_Early = (@Late_Basic_Amount/@Fix_Early_W_Days)/(@Fix_Early_W_Shift_Sec/3600)    
                    SET @Early_Dedu_Amount = 0    
                    SET @Extra_Early_Dedu_Amount = 0    
          
                    if @Total_Early_Sec > 0    
                        begin    
                            SET @Early_Dedu_Amount = round(@Hour_Salary_Early * (@Total_Early_Sec /3600),0)    
                            SET @Extra_Early_Dedu_Amount = @Extra_Early_Deduction * @Early_Dedu_Amount   
                        End
          
           
                     ------------------End-------------------------------------
                            
                              
                    ---------------------end ------------------------   
                  
                    IF @cnt = 1 
                        BEGIN
                            If Exists (Select Sal_Tran_Id From T0200_MONTHLY_SALARY Where Emp_ID =@Emp_Id And Cmp_ID=@Cmp_ID And Month_St_Date=@tmp_Month_St_Date And Month_End_Date =@tmp_Month_End_Date )
                                Select @Advance_Amount =  round( isnull(Advance_amount,0),0) From T0200_MONTHLY_SALARY  where Emp_id = @Emp_id And cmp_Id=@Cmp_ID  And Month_St_Date=@tmp_Month_St_Date And Month_End_Date =@tmp_Month_End_Date 
                            Else 
                                Select  @Advance_Amount =  round( isnull(Adv_closing,0),0) 
                                from    T0140_Advance_Transaction 
                                where   emp_id = @emp_id and Cmp_ID = @Cmp_ID      
                                        and for_date = (select max(for_date) from  T0140_Advance_Transaction where emp_id = @emp_id and Cmp_ID = @Cmp_ID      
                                        and for_date <=  @tmp_Month_End_Date) 
                        
                            IF @Advance_Amount < 0    
                                SET @Advance_Amount = 0    
                                                             
                            IF @Advance_Amount = 0  --Ankit 18102014
                                SET @M_ADV_AMOUNT = 0
                                            
                            --SET @Advance_Amount = isnull(@Advance_Amount,0)  +  @Update_Adv_Amount  commented By Mukti 22012015
                                    
                            --added By Mukti(start)20012015 
                            -- if @M_ADV_AMOUNT > 0   --Added By ankit 19062013
                                --SET @Advance_Amount=@M_ADV_AMOUNT         
                            IF @Advance_Amount > @M_ADV_AMOUNT
                                SET @Advance_Amount=@M_ADV_AMOUNT
                            ELSE 
                                SET @Advance_Amount=@Advance_Amount
                            --added By Mukti(end)20012015
                                    
                            --Ankit 18102014 --
                            SELECT  @Due_Loan_Amount = ISNULL(SUM(Loan_Closing),0) 
                            from    dbo.T0140_LOAN_TRANSACTION  LT 
                                    INNER JOIN  (
                                                SELECT  MAX(FOR_DATE) AS FOR_dATE , LOAN_ID ,EMP_ID 
                                                from    dbo.T0140_LOAN_TRANSACTION  
                                                WHERE   EMP_iD = @EMP_ID AND CMP_ID = @CMP_ID      
                                                        AND FOR_DATE <=@Month_end_Date      
                                                GROUP BY EMP_id ,LOAN_ID 
                                                ) AS QRY  ON QRY.LOAN_ID  = LT.LOAN_ID AND QRY.FOR_DATE = LT.FOR_DATE AND QRY.EMP_ID = LT.EMP_ID
                            WHERE   Is_Loan_Interest_Flag = 0 --Added by nilesh patel on 23072015

                            IF ISNULL(@Due_Loan_Amount,0) = 0
                                SET @M_LOAN_AMOUNT = 0
                            --Ankit 18102014 --
                                
                                                                
                            --Added by nilesh patel on 16072015 -start 
                            INSERT INTO #Loan_Due_Amount(Emp_ID,Loan_ID,Loan_Closing)
                            SELECT  LT.Emp_ID,LT.Loan_ID,Loan_CLosing
                            FROM    dbo.T0140_LOAN_TRANSACTION  LT 
                                    INNER JOIN (
                                                SELECT  MAX(FOR_DATE) AS FOR_dATE , LOAN_ID ,EMP_ID 
                                                FROM    dbo.T0140_LOAN_TRANSACTION  
                                                WHERE   EMP_iD = @emp_Id AND CMP_ID = @Cmp_ID      
                                                        AND FOR_DATE <= @Month_end_Date      
                                                GROUP BY EMP_id ,LOAN_ID 
                                                ) AS QRY  ON QRY.LOAN_ID  = LT.LOAN_ID AND QRY.FOR_DATE = LT.FOR_DATE AND QRY.EMP_ID = LT.EMP_ID
                                    INNER JOIN T0040_LOAN_MASTER LM On LM.Loan_ID = LT.Loan_ID
                            WHERE   Is_Loan_Interest_Flag = 0 and LM.Is_Principal_First_than_Int = 1
                                     

                           if @Due_Loan_Amount = 0
                           IF EXISTS(SELECT 1 From #Loan_Due_Amount where Loan_Closing = 0)
                                   EXEC SP_CALCULATE_LOAN_INTEREST_PAYMENT @Cmp_ID ,@emp_Id,@tmp_Month_St_Date,@tmp_Month_End_Date,@Sal_Tran_ID
              
                            --Change by ronakk 02052023
                            IF ISNULL(@IsLoanCalculated,0) = 0 
							Begin
					                    --Add for cutoff deduction properly as per discution with sandip bhai Feature #24906
									Declare @ct_ST_DT datetime
									declare @ct_ET_DT Datetime
			
									if Exists(select 1 from T0040_SETTING where Setting_Name='Allow Cutoff Date as Loan Installment/Paid Date' and Cmp_ID=@cmp_id and Setting_Value=1)
									Begin

											if (select Cutoffdate_Salary from T0040_GENERAL_SETTING  WHERE gen_id =(select max(Gen_ID) from T0040_GENERAL_SETTING WHERE Branch_ID= @branch_id)) is not null
											Begin
								
													Declare @cutDate datetime
													select @cutDate =  Cutoffdate_Salary from T0040_GENERAL_SETTING  WHERE gen_id =(select max(Gen_ID) from T0040_GENERAL_SETTING WHERE Branch_ID= @branch_id)
													
													select @ct_ST_DT= cast(Year(Dateadd(MM,-1,@tmp_Month_St_Date)) as nvarchar) +'-'+  cast((Format(Dateadd(MM,-1,@tmp_Month_St_Date),'MM')) as nvarchar) +'-'+Format(Dateadd(DAY,1,@cutDate),'dd')
													select @ct_ET_DT = cast(Year(@tmp_Month_St_Date) as nvarchar)+'-'+ format(@tmp_Month_St_Date,'MM')+'-'+format(@cutDate,'dd')

											End
											else 
											Begin
												set  @ct_ST_DT =  @tmp_Month_St_Date
												set  @ct_ET_DT = @tmp_Month_End_Date
											End

									End
									else
									Begin
												set  @ct_ST_DT =  @tmp_Month_St_Date
												set  @ct_ET_DT = @tmp_Month_End_Date

									end

									 EXEC dbo.SP_CALCULATE_LOAN_PAYMENT @Cmp_ID ,@emp_Id,@ct_ST_DT,@ct_ET_DT,@Sal_Tran_ID,@M_LOAN_AMOUNT,@IS_LOAN_DEDU  
                                    --EXEC dbo.SP_CALCULATE_LOAN_PAYMENT @Cmp_ID ,@emp_Id,@tmp_Month_St_Date,@tmp_Month_End_Date,@Sal_Tran_ID,@M_LOAN_AMOUNT,@IS_LOAN_DEDU  
                            End
								 
                            if Exists(Select 1 From T0120_LOAN_APPROVAL LA Inner join T0040_LOAN_MASTER LM ON LA.Loan_ID = LM.Loan_ID WHERE isnull(LM.Is_Intrest_Amount_As_Perquisite_IT,0) = 1 and LA.Loan_Apr_Pending_Amount > 0 and LA.Emp_ID = @emp_Id) 
                                BEGIN
                                    EXEC dbo.SP_CALCULATE_LOAN_PAYMENT_INT_PERQUISITE @Cmp_ID ,@emp_Id,@tmp_Month_St_Date,@tmp_Month_End_Date,@Sal_Tran_ID,@M_LOAN_AMOUNT,@IS_LOAN_DEDU    
                                End   

                                    
                            DECLARE @Is_First_Ded_Principal_Amt Numeric(18,0)
                            SET     @Is_First_Ded_Principal_Amt = NULL;
                            
                            SELECT  @Is_First_Ded_Principal_Amt = LM.Is_Principal_First_than_Int 
                            FROM    T0210_Monthly_Loan_Payment LP 
                                    inner join T0120_LOAN_APPROVAL LA on LA.Loan_Apr_ID = LP.Loan_Apr_ID 
                                    inner JOIN T0040_LOAN_MASTER LM ON LA.Loan_ID = LM.Loan_ID
                            WHERE   LP.Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID
                                     
                                     
                            IF @Is_First_Ded_Principal_Amt = 1 
                                BEGIN
                                     SELECT @Loan_Amount = ISNULL(SUM(Loan_Pay_Amount),0),@Loan_Interest_Amount = 0 from dbo.T0210_Monthly_Loan_Payment LP
                                     Inner join (       -- Changed by Gadriwala Muslim 25122014
                                                    select LA.Loan_ID,LP.Loan_Apr_ID from T0210_Monthly_Loan_Payment LP inner join
                                                    T0120_LOAN_APPROVAL LA on LA.Loan_Apr_ID = LP.Loan_Apr_ID
                                                    WHERE LP.Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID 
                                                ) Qry on Qry.Loan_Apr_ID = LP.Loan_Apr_ID  
                                     Inner join T0040_LOAN_MASTER LM on LM.Loan_ID = Qry.LOAN_ID and LM.Is_Interest_Subsidy_Limit = 0
                                     WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID and LP.Is_Loan_Interest_Flag = 0
                                     
                                     --if @Due_Loan_Amount = 0 
                                     if Exists(SELECT 1 From #Loan_Due_Amount where Loan_Closing = 0 AND Emp_Id = @emp_Id )
                                        Begin
                                            SELECT @Loan_Interest_Amount = ISNULL(Sum(Interest_Amount),0) from dbo.T0210_Monthly_Loan_Payment LP
                                             Inner join (       -- Changed by Gadriwala Muslim 25122014
                                                            select LA.Loan_ID,LP.Loan_Apr_ID from T0210_Monthly_Loan_Payment LP inner join
                                                            T0120_LOAN_APPROVAL LA on LA.Loan_Apr_ID = LP.Loan_Apr_ID
                                                            WHERE LP.Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID 
                                                        ) Qry on Qry.Loan_Apr_ID = LP.Loan_Apr_ID  
                                             Inner join T0040_LOAN_MASTER LM on LM.Loan_ID = Qry.LOAN_ID and LM.Is_Interest_Subsidy_Limit = 0
                                             WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID and LP.Is_Loan_Interest_Flag = 1
                 End
                                END    
                            Else
                                BEGIN
                                    SELECT @Loan_Amount = ISNULL(SUM(Loan_Pay_Amount),0) from dbo.T0210_Monthly_Loan_Payment LP
                                     Inner join (       -- Changed by Gadriwala Muslim 25122014
                                                    select LA.Loan_ID,LP.Loan_Apr_ID from T0210_Monthly_Loan_Payment LP inner join
                                                    T0120_LOAN_APPROVAL LA on LA.Loan_Apr_ID = LP.Loan_Apr_ID
                                                    WHERE LP.Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID 
                                                ) Qry on Qry.Loan_Apr_ID = LP.Loan_Apr_ID  
                                     Inner join T0040_LOAN_MASTER LM on LM.Loan_ID = Qry.LOAN_ID and LM.Is_Interest_Subsidy_Limit = 0
                                     WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID
                                     
                                     SELECT @Loan_Interest_Amount= ISNULL(Sum(Interest_Amount),0) from dbo.T0210_Monthly_Loan_Payment LP
                                     Inner join (       -- Changed by Gadriwala Muslim 25122014
                                                    select LA.Loan_ID,LP.Loan_Apr_ID from T0210_Monthly_Loan_Payment LP inner join
                                                    T0120_LOAN_APPROVAL LA on LA.Loan_Apr_ID = LP.Loan_Apr_ID
                                                    WHERE LP.Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID 
                                                ) Qry on Qry.Loan_Apr_ID = LP.Loan_Apr_ID  
                                     Inner join T0040_LOAN_MASTER LM on LM.Loan_ID = Qry.LOAN_ID and LM.Is_Interest_Subsidy_Limit = 0
                                     WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID and LM.Is_Principal_First_than_Int = 0 and Isnull(LM.Is_Intrest_Amount_As_Perquisite_IT,0) = 0
                                     
                                     if Exists(SELECT 1 From #Loan_Due_Amount where Loan_Closing = 0 AND Emp_Id = @emp_Id ) 
                                        Begin
                                            SELECT @Loan_Interest_Amount = @Loan_Interest_Amount + ISNULL(Sum(Interest_Amount),0) from dbo.T0210_Monthly_Loan_Payment LP
                                             Inner join (       -- Changed by Gadriwala Muslim 25122014
                                                            select LA.Loan_ID,LP.Loan_Apr_ID from T0210_Monthly_Loan_Payment LP inner join
                                                            T0120_LOAN_APPROVAL LA on LA.Loan_Apr_ID = LP.Loan_Apr_ID 
                                                            inner JOIN #Loan_Due_Amount LDA ON LDA.Emp_ID = LA.Emp_ID and LDA.Loan_ID = LA.Loan_ID
                                                            WHERE LP.Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID and LDA.Loan_Closing = 0
                                                        ) Qry on Qry.Loan_Apr_ID = LP.Loan_Apr_ID  
                                             Inner join T0040_LOAN_MASTER LM on LM.Loan_ID = Qry.LOAN_ID and LM.Is_Interest_Subsidy_Limit = 0
                                             WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID and LM.Is_Principal_First_than_Int = 1
                                        End
                                END 
                        
                            --Added by nilesh patel on 16072015 -End  

                            -- Comment by nilesh patel on 23072015 -Start    
                            --Select @Loan_Amount = Isnull(sum(Loan_Pay_Amount),0),@Loan_Interest_Amount= ISNULL(Sum(Interest_Amount),0)
                            --From T0210_Monthly_Loan_Payment  LP  -- Changed by Gadriwala Muslim 25122014
                            -- Inner join (
                            --              select LA.Loan_ID,LP.Loan_Apr_ID from T0210_Monthly_Loan_Payment LP inner join
                            --              T0120_LOAN_APPROVAL LA on LA.Loan_Apr_ID = LP.Loan_Apr_ID
                            --              where Temp_Sal_Tran_ID = @Sal_Tran_ID  and LP.Cmp_Id=@Cmp_ID   
                            --                      ) Qry on Qry.Loan_Apr_ID = LP.Loan_Apr_ID  
                            -- Inner join T0040_LOAN_MASTER LM on LM.Loan_ID = Qry.LOAN_ID and LM.Is_Interest_Subsidy_Limit = 0
                            --where Temp_Sal_Tran_ID = @Sal_Tran_ID  and LP.Cmp_Id=@Cmp_ID    
                            -- Comment by nilesh patel on 23072015 -End

                            -- Added by Gadriwala Muslim 26122014 - Start
                            Declare @Interest_Subsidy_Amount as NUMERIC(18, 4)

                            select @Interest_Subsidy_Amount = Isnull(Sum(Interest_subsidy_Amount),0) from dbo.T0210_Monthly_Loan_Payment LP
                            Inner join (
                                        select LA.Loan_ID,LP.Loan_Apr_ID from T0210_Monthly_Loan_Payment LP inner join
                                        T0120_LOAN_APPROVAL LA on LA.Loan_Apr_ID = LP.Loan_Apr_ID
                                        where Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID 
                                    ) Qry on Qry.Loan_Apr_ID = LP.Loan_Apr_ID  
                            Inner join T0040_LOAN_MASTER LM on LM.Loan_ID = Qry.LOAN_ID and LM.Is_Interest_Subsidy_Limit = 1
                            WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and LP.Cmp_Id=@Cmp_ID    
                         
                            Update T0210_MONTHLY_AD_DETAIL SET M_AD_Amount = isnull(@Interest_Subsidy_Amount,0)
                            From    T0210_MONTHLY_AD_DETAIL AD inner join 
                                    T0050_AD_MASTER AM on AD.AD_ID = AM.AD_ID and AM.AD_CALCULATE_ON = 'Interest Subsidy'  
                            where Temp_Sal_Tran_ID = @Sal_Tran_ID  and AD.Cmp_ID =@Cmp_ID
                                  
                            SET @Allow_Amount = isnull(@Allow_Amount,0) +  isnull(@Interest_Subsidy_Amount,0)
                            
                            --Added by Gadriwala Muslim 15042015 - Start
                            declare @Warning_Deduct_Amount as NUMERIC(18, 4)
                            SET @Warning_Deduct_Amount = 0
                            
                            exec calculate_Emp_Warning_deduction @cmp_ID,@Emp_Id,@Month_St_Date,@Month_End_Date,@Day_Salary,@Warning_Deduct_Amount output
                            IF @Round = 1
                                begin
                                 Update T0210_MONTHLY_AD_DETAIL SET M_AD_Amount = Round(isnull(@Warning_Deduct_Amount,0),0)
                                     From T0210_MONTHLY_AD_DETAIL AD inner join 
                                     T0050_AD_MASTER AM on AD.AD_ID = AM.AD_ID and AM.AD_CALCULATE_ON = 'warning deduction'  
                                     where Temp_Sal_Tran_ID = @Sal_Tran_ID  and AD.Cmp_ID =@Cmp_ID
                                end
                            else
                                begin
                                 Update T0210_MONTHLY_AD_DETAIL SET M_AD_Amount = isnull(@Warning_Deduct_Amount,0)
                                     From T0210_MONTHLY_AD_DETAIL AD inner join 
                                     T0050_AD_MASTER AM on AD.AD_ID = AM.AD_ID and AM.AD_CALCULATE_ON = 'warning deduction'  
                                     where Temp_Sal_Tran_ID = @Sal_Tran_ID  and AD.Cmp_ID =@Cmp_ID
                                end
                                 --SET @Due_Loan_Amount = 0
                            
                            SET @Dedu_Amount = ISNULL(@dedu_amount,0) + isnull(@Warning_Deduct_Amount,0)
                            
                            --- BOND DEDUCTION PORTION START ADDED BY RAJPUT ON 10102018 ----
							IF (@ALLOW_NEGATIVE_SAL = 1)
							BEGIN
								if @IS_Bond_DEDU = 1
									begin
										SET @BOND_AMOUNT = 0
										
										IF ISNULL(@BOND_AMOUNT,0) = 0
											EXEC DBO.SP_CALCULATE_BOND_PAYMENT @CMP_ID ,@EMP_ID,@TMP_MONTH_ST_DATE,@TMP_MONTH_END_DATE,@SAL_TRAN_ID,@IS_BOND_DEDU  
									
										SELECT @BOND_AMOUNT = ISNULL(SUM(BOND_PAY_AMOUNT),0) FROM DBO.T0210_MONTHLY_BOND_PAYMENT BP
										 INNER JOIN (	
														SELECT BA.BOND_ID,BP.BOND_APR_ID FROM T0210_MONTHLY_BOND_PAYMENT BP INNER JOIN
														T0120_BOND_APPROVAL BA ON BA.BOND_APR_ID = BP.BOND_APR_ID
														WHERE BP.SAL_TRAN_ID = @SAL_TRAN_ID AND BP.CMP_ID=@CMP_ID 
													) QRY ON QRY.BOND_APR_ID = BP.BOND_APR_ID  
										 INNER JOIN T0040_BOND_MASTER BM ON BM.BOND_ID = QRY.BOND_ID --AND BM.IS_INTEREST_SUBSIDY_LIMIT = 0
										 WHERE SAL_TRAN_ID = @SAL_TRAN_ID AND BP.CMP_ID=@CMP_ID
									end
							END
							
							---- END -----
							
                            
                            --Added by Gadriwala Muslim 15042015 - End   
                            
                            -- Added by Gadriwala Muslim 26122014 - End 
                            --SET @Due_Loan_Amount = 0
                            
                             
                            -- SELECT @Due_Loan_Amount = ISNULL(SUM(Loan_Closing),0) FROM T0140_LOAN_TRANSACTION  LT INNER JOIN     
                            --( SELECT MAX(FOR_DATE) AS FOR_dATE , LOAN_ID ,EMP_ID FROM T0140_LOAN_TRANSACTION  WHERE EMP_iD = @EMP_ID AND CMP_ID = @CMP_ID    
                            --AND FOR_DATE <=@tmp_Month_End_Date    
                            --GROUP BY EMP_id ,LOAN_ID ) AS QRY  ON QRY.LOAN_ID  = LT.LOAN_ID    
                            --AND QRY.FOR_DATE = LT.FOR_DATE     
                            --AND QRY.EMP_ID = LT.EMP_ID    
                               
                          
                            
                            --exec SP_CALCULATE_CLAIM_PAYMENT @Cmp_ID ,@emp_Id,@tmp_Month_End_Date,@Sal_Tran_ID,0,1,1--Pass 1 for @Rounding by sumit 06112014    
                             
                            --Select @Total_Claim_Amount  = Isnull(sum(Claim_Pay_Amount),0) From T0210_Monthly_Claim_Payment where Temp_Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
                            --select  @Total_Claim_Amount=ISNULL(SUM(Claim_Closing),0) 
                            --from    T0140_CLAIM_TRANSACTION AS CT INNER JOIN T0130_CLAIM_APPROVAL_DETAIL AS CAD ON CAD.Claim_Apr_Date = CT.For_Date  INNER JOIN T0120_CLAIM_APPROVAL AS CA ON CA.Claim_Apr_ID = CAD.Claim_Apr_ID  
                            --        and Ct.Emp_ID=Ca.emp_id and Ct.Claim_ID=CAD.Claim_ID INNER join T0040_CLAIM_MASTER Clm ON Clm.Claim_ID=CAD.Claim_ID and Clm.Cmp_ID=CAD.Cmp_ID where CT.cmp_id=@Cmp_ID and CT.Emp_ID=@emp_ID and CA.Claim_Apr_Date<=@Month_End_Date 
                            --        and CA.Claim_Apr_Date>=@Month_St_Date and Clm.Claim_Apr_Deduct_From_Sal=1
                            
                            SELECT 	@TOTAL_CLAIM_AMOUNT=ISNULL(SUM(CLAIM_CLOSING),0) -- ADDED BY RAJPUT ON 05032019
							FROM 	T0140_CLAIM_TRANSACTION AS CT 
							INNER JOIN ( SELECT DISTINCT CLAIM_APR_ID,CLAIM_ID,CLAIM_APR_DATE,CMP_ID FROM T0130_CLAIM_APPROVAL_DETAIL ) CAD ON CAD.CLAIM_APR_DATE = CT.FOR_DATE  
							INNER JOIN T0120_CLAIM_APPROVAL AS CA ON CA.CLAIM_APR_ID = CAD.CLAIM_APR_ID AND CT.EMP_ID=CA.EMP_ID AND CT.CLAIM_ID=CAD.CLAIM_ID 
							INNER JOIN T0040_CLAIM_MASTER CLM ON CLM.CLAIM_ID=CAD.CLAIM_ID AND CLM.CMP_ID=CAD.CMP_ID 
							WHERE CT.CMP_ID=@CMP_ID AND CT.EMP_ID=@EMP_ID AND CA.CLAIM_APR_DATE<=@MONTH_END_DATE AND CA.CLAIM_APR_DATE>=@MONTH_ST_DATE AND CLM.CLAIM_APR_DEDUCT_FROM_SAL=1
						   
                            -----Added by Rohit on  24082015------------------------------------------------------------------
                            SET @Travel_Advance_Amount = 0 
                            SET @Travel_Amount = 0  
                        
                            select @Travel_Advance_Amount=isnull(SUM(Advance_amount),0),@Travel_Amount = isnull((sum(isnull(Approved_Expance,0)+ISNULL(QRY.TravelAllowance,0))),0)  from T0150_Travel_Settlement_Approval TSA
                            inner join 
                            (       
                                select SUM(TravelAllowance) as TravelAllowance,Emp_ID,Travel_Set_Application_id 
                                from T0140_Travel_Settlement_Expense where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_Id    
                                Group by Emp_ID,Travel_Set_Application_id
                            ) Qry on Qry.Travel_Set_Application_id=TSA.Travel_Set_Application_id and Qry.Emp_ID=TSA.emp_id
                            where TSA.emp_id=@Emp_Id and cmp_id=@Cmp_ID and  Effect_Salary_date<=@Month_End_Date and Effect_Salary_date>=@Month_St_Date and isnull(Travel_Amt_in_salary,0)=1 and is_apr=1 --Added by Sumit 18082015
                            ---------------------------------------------------------------------       
                                
                                
                            if @Total_Claim_Amount >0
                                begin
                                    exec SP_CALCULATE_CLAIM_TRANSACTION @Cmp_Id,@Emp_Id,@Month_St_Date,0,@Month_St_Date,@Month_End_Date,0,'I'
                                end
                         
                            SELECT @Settelement_Amount = ISNULL(SUM(S_Net_Amount),0) FROM T0201_Monthly_Salary_Sett WHERE emp_ID =@Emp_ID 
                                AND MONTH(S_Eff_Date) =MONTH(@Month_End_Date) AND YEAR(S_Eff_Date) =YEAR(@Month_End_Date) 
                                AND isnull(Effect_On_Salary,0) = 1
                          
                            --Added By Mukti 25032015(start)
                            SELECT  @TotASSET_Closing=ISNULL(SUM(ASSET_Closing),0) from dbo.t0140_asset_transaction  LT INNER JOIN       
                                    (SELECT MAX(FOR_DATE) AS FOR_dATE , AssetM_ID ,EMP_ID from dbo.t0140_asset_transaction  
                                    WHERE   EMP_iD = @emp_id AND CMP_ID = @Cmp_ID 
                                            AND FOR_DATE <= @Month_end_Date      
                                    GROUP BY EMP_id ,AssetM_ID ) AS QRY  ON QRY.AssetM_ID  = LT.AssetM_ID      
                                   AND QRY.FOR_DATE = LT.FOR_DATE       
                                   AND QRY.EMP_ID = LT.EMP_ID
                        
                            IF @TotASSET_Closing >0
                                BEGIN   
                                    EXEC SP_CALCULATE_ASSET_PAYMENT @Cmp_ID ,@emp_Id,@Month_End_Date,@Sal_Tran_ID  
                                    SELECT @Asset_Installment  = ISNULL(SUM(Receive_Amount),0) from dbo.t0140_asset_transaction WHERE Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID      
                                END
                            --Added By Mukti 25032015(end)
                        --Added By Mukti(start)13062017
                        if Exists(SELECT 1 FROM T0100_Uniform_Emp_Issue where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID and (Deduct_Pending_Amount > 0 or (Refund_Pending_Amount >0 and Deduct_Pending_Amount = 0)))
                                Begin       
                                    Exec SP_CALCULATE_UNIFORM_PAYMENT @Cmp_ID ,@emp_Id,@tmp_Month_St_Date,@tmp_Month_End_Date,@Sal_Tran_ID
                                End
                            
                            SELECT @Uniform_Deduction_Amount = ISNULL(SUM(Payment_Amount),0) from dbo.T0210_Uniform_Monthly_Payment UMP
                            WHERE UMP.Sal_Tran_ID = @Sal_Tran_ID and UMP.Cmp_Id=@Cmp_ID and UMP.Uni_Flag = 0
                            
                            SELECT @Uniform_Refund_Amount = ISNULL(SUM(Payment_Amount),0) from dbo.T0210_Uniform_Monthly_Payment UMP
                            WHERE UMP.Sal_Tran_ID = @Sal_Tran_ID and UMP.Cmp_Id=@Cmp_ID and UMP.Uni_Flag = 1
                        --Added By Mukti(end)13062017
                            IF CHARINDEX('Ambuja',@cmp_Name,1) = 1 
                                BEGIN      
                                    SELECT @Leave_Encash_Day=Lv_Encash_Apr_Days from Dbo.T0120_Leave_Encash_Approval Where Month(Lv_Encash_Apr_Date) = Month(@tmp_Month_End_Date) And Year(Lv_Encash_Apr_Date)=Year(@tmp_Month_End_Date) And Cmp_ID = @Cmp_id And Emp_Id=@Emp_Id And Lv_Encash_Apr_Status='A'                           
                                            
                                    IF @Leave_Encash_Day<>0
                                        BEGIN 
                                            SET @Leave_Salary_Amount =(((@Basic_Salary_Org*12)/365)*@Leave_Encash_Day)
                                                
                                            IF EXISTS(SELECT L_Sal_Tran_Id From Dbo.T0200_Monthly_Salary_Leave Where Emp_Id=@Emp_Id And Cmp_Id=@Cmp_Id And L_Month_St_Date = @tmp_Month_St_Date)
                                                BEGIN
                                                    UPDATE  T0200_MONTHLY_SALARY_LEAVE
                                                    SET     Increment_ID = @Increment_ID, 
                                                            L_Month_St_Date = @tmp_Month_St_Date, L_Month_End_Date = @tmp_Month_End_Date, L_Sal_Generate_Date = @Sal_Generate_Date,
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
                                                    WHERE EMP_ID = @EMP_ID AND CMP_ID=@CMP_ID AND L_MONTH_ST_DATE = @TMP_MONTH_ST_DATE
                                                END
                                            ELSE
                                                BEGIN                                                   
                                                    SELECT @L_Sal_Tran_ID =  Isnull(max(L_Sal_Tran_ID),0)  + 1   From T0200_MONTHLY_SALARY_LEAVE
                       
                                                    INSERT INTO T0200_MONTHLY_SALARY_LEAVE
                                                                (L_Sal_Tran_ID, L_Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, L_Month_St_Date, L_Month_End_Date, L_Sal_Generate_Date, L_Sal_Cal_Days, 
                                                                L_Working_Days, L_Outof_Days, L_Shift_Day_Sec, L_Shift_Day_Hour, L_Basic_Salary, L_Day_Salary, L_Hour_Salary, L_Salary_Amount, 
                                                                L_Allow_Amount, L_Other_Allow_Amount, L_Gross_Salary, L_Dedu_Amount, L_Loan_Amount, L_Loan_Intrest_Amount, L_Advance_Amount, 
                                                                L_Other_Dedu_Amount, L_Total_Dedu_Amount, L_Due_Loan_Amount, L_Net_Amount, L_Actually_Gross_Salary, L_PT_Amount, 
                                                                L_PT_Calculated_Amount, L_M_Adv_Amount, L_M_Loan_Amount, L_M_IT_Tax, L_LWF_Amount, L_Revenue_Amount, L_PT_F_T_Limit, L_Sal_Type, 
                                                                L_Eff_Date, Login_ID, Modify_Date,IS_FNF,SAL_TRAN_ID)
                                                    VALUES    (@L_Sal_Tran_ID,@Sal_Receipt_No,@Emp_ID,@Cmp_ID,@Increment_ID,@tmp_Month_St_Date,@tmp_Month_End_Date,@Sal_Generate_Date,@Leave_Encash_Day,0,0,0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,@Leave_Salary_Amount,0,0,0,0,0,0,0,0,'',0,@tmp_Month_End_Date,@Login_ID,'',0,@SAL_TRAN_ID)                 
                                                End
                                        
                                        End             
                                End        
                            Else
                                Begin
                                    Exec dbo.P0200_MONTHLY_SALARY_GENERATE_LEAVE 0,@Emp_ID,@Cmp_ID,@Sal_Generate_Date,@tmp_Month_St_Date,@tmp_Month_End_Date,0,0,0,0,0,0,@Login_ID,'N','N',0,@tmp_Month_End_Date,0,@SAL_TRAN_ID,@StrWeekoff_Date,@Weekoff_Days,@Cancel_Weekoff,@StrHoliday_Date,@Holiday_days,@Cancel_Holiday
                                    Declare @Leave_GRoss_Salary NUMERIC(18, 4)              
                                    -- select @Leave_Salary = isnull(sum(L_Net_Amount),0) From T0200_MONTHLY_SALARY_LEAVE Where Emp_ID=@Emp_ID and isnull(Is_FNF,0) =0 and L_eff_Date >=@Month_St_Date and L_Eff_date <=@Month_end_Date
                                    --SELECT @Leave_Salary_Amount = ISNULL(SUM(L_Net_Amount),0) FROM T0200_Monthly_Salary_Leave WHERE emp_ID =@Emp_ID AND MONTH(L_Eff_Date) =MONTH(@Month_End_Date)  AND YEAR(L_Eff_Date) =YEAR(@Month_End_Date)
                                    SELECT @Leave_Salary_Amount = ISNULL(SUM(L_Net_Amount),0),@Leave_GRoss_Salary = sum(isnull(L_Actually_Gross_Salary,0)) FROM T0200_Monthly_Salary_Leave 
                                    WHERE emp_ID =@Emp_ID AND MONTH(L_Eff_Date) =MONTH(@tmp_Month_End_Date)  AND YEAR(L_Eff_Date) =YEAR(@tmp_Month_End_Date)
                                        AND Sal_tran_ID = @SAL_TRAN_ID  --Ankit 04042016
                                End 
                                  
                                    --Change done by Falak on 17-FEB-2011
                            If @Lv_Encash_Cal_On = 'Gross'
                                SET @Leave_Salary_Amount = isnull(@Leave_GRoss_Salary,0)
                        END
                    
                    --if @Is_OT_Inc_Salary =1       
                    --SET @Gross_Salary = @Salary_Amount + @Allow_Amount + @Other_Allow_Amount + @Total_Claim_Amount  + @OT_Amount + @Bonus_Amount      
                    --else      
                    --SET @Gross_Salary = @Salary_Amount + @Allow_Amount + @Other_Allow_Amount + @Total_Claim_Amount   + @Bonus_Amount

                 
                 
                    if not isnull(@increment_Month ,0) = @cnt -1  and @total_count_all_incremnet > 1 
                        begin
                            SET @Allow_Amount = 0
                            SET @Temp_Allowance = 0
                            SET @Temp_Allownace_PT = 0
                            SET @Dedu_Amount = 0
                            SET @Temp_Deduction = 0
                            SET @Salary_amount_Arear = 0 --Hardik 26/09/2016 as Ami life science has issue in Mid Increment and Arear days case in same month, it will add twice
                            SET @Allow_Amount_Arear =0 --Hardik 26/09/2016 as Ami life science has issue in Mid Increment and Arear days case in same month, it will add twice
                            SET @Dedu_Amount_Arear =  0 --Added By Jimit 07092018 as WCL (Issue in Mid Increment and adding PF Arrear amount twice)
                            
                                --SET @Leave_Salary_Amount = 0
                                --SET @Advance_Amount = 0
                                --SET @Loan_Amount = 0 
                                --SET @PT_Amount = 0
                                SET @LWF_Amount = 0
                                --SET @Revenue_Amount= 0    
							Set @Salary_amount_Arear_cutoff = 0
							Set @Allow_Amount_Arear_Cutoff = 0
						
                            
                        end
                    --Hardik 07/01/2012 for Arear
                    SET @Gross_Salary_Arear = Isnull(@Salary_amount_Arear,0) + Isnull(@Allow_Amount_Arear,0)
                        
                    SET @Gross_Salary_Arear_cutoff = Isnull(@Salary_amount_Arear_cutoff,0) + Isnull(@Allow_Amount_Arear_Cutoff,0) -- added by rohit on 12012015
                    if @Is_OT_Inc_Salary =1     
                        begin   
                            
                            if @IS_Bonus_EFf_Sal = 1
                                SET @Gross_Salary = @Salary_Amount + @Allow_Amount + @Other_Allow_Amount + @Total_Claim_Amount  + @OT_Amount  + @Bonus_Amount  + ISNULL(@WO_OT_Amount,0)  + ISNULL(@HO_OT_Amount,0) +  @Gross_Salary_Arear + @Gross_Salary_Arear_cutoff + isnull(@Travel_Amount,0)
                            else    
                                SET @Gross_Salary = @Salary_Amount + @Allow_Amount + @Other_Allow_Amount + @Total_Claim_Amount + @OT_Amount + ISNULL(@WO_OT_Amount,0) + ISNULL(@HO_OT_Amount,0) +  @Gross_Salary_Arear + @Gross_Salary_Arear_cutoff + isnull(@Travel_Amount,0)
                        end
                    else
                        begin
                            if @IS_Bonus_EFf_Sal = 1
                                SET @Gross_Salary = @Salary_Amount + @Allow_Amount + @Other_Allow_Amount + @Total_Claim_Amount   + @Bonus_Amount +  @Gross_Salary_Arear + @Gross_Salary_Arear_cutoff + isnull(@Travel_Amount,0)
                            else    
                                SET @Gross_Salary = @Salary_Amount + @Allow_Amount + @Other_Allow_Amount + @Total_Claim_Amount +  @Gross_Salary_Arear + @Gross_Salary_Arear_cutoff + isnull(@Travel_Amount,0)
                        end
        
                    
                    -------------------------Hasmukh for Gross fraction rounding 14/09/2011--------------------------
                    Declare @Temp_Round_Gross       NUMERIC(18, 4)
                    Declare @Total_Earning_Fraction Numeric (18,2)

                    SET @Temp_Round_Gross = 0
                    SET @Total_Earning_Fraction = 0


                    If @IS_ROUNDING = 1
                        Begin
                            SET @Temp_Round_Gross = Round(@Gross_Salary,0)
                            SET @Total_Earning_Fraction = ISNULL(@Temp_Round_Gross - @Gross_Salary,0)  --ISNULL Added By Ramiz on 04/05/2016
                        End

                    ---------------------------End Fraction----------------------------------------------------------


                    --If @Is_Emp_PT =1 and @Is_PT = 1     
             --Begin    
                    --  SET  @PT_Calculated_Amount = @Gross_Salary  - isnull(@Temp_Allownace_PT,0) -- change by Falak on 02-OCT-2010  
                    --  exec SP_CALCULATE_PT_AMOUNT @CMP_ID,@EMP_ID,@MONTH_END_DATE,@PT_Calculated_Amount,@PT_AMOUNT OUTPUT,@PT_F_T_LIMIT output,@Branch_ID    
                    --end    
                    --Changed by Falak on 16-FEB-2011   
                    IF @Is_Emp_PT =1 and @Is_PT = 1       
                        BEGIN      
                            IF @Lv_Salary_Effect_on_PT = 1      -- Changed By rohit on 03032015
                                SET  @PT_Calculated_Amount = @PT_Calculated_Amount + @Gross_Salary - ISNULL(@Temp_Allownace_PT,0) --change by Falak on 02-OCT-2010
                            ELSE
                                SET  @PT_Calculated_Amount = @PT_Calculated_Amount + @Gross_Salary - ISNULL(@Temp_Allownace_PT,0) + isnull(@Leave_Salary_Amount,0)
                        if @total_count_all_incremnet = @cnt
                            Begin
                                SET @PT_Calculated_Amount = @PT_Calculated_Amount + @Settelement_Amount -- Added by hardik 13/07/2015 as Havmor has issue that PT is not calculating on Arear done from Settlement
                                EXEC SP_CALCULATE_PT_AMOUNT @CMP_ID,@EMP_ID,@MONTH_END_DATE,@PT_Calculated_Amount,@PT_AMOUNT OUTPUT,@PT_F_T_LIMIT output,@Branch_ID     
                            END
                        END
                 
                    --SET @Gross_Salary = @Gross_Salary+ isnull(@Leave_Salary_Amount,0) 
                    --SET @Gross_Salary = @Gross_Salary+ isnull(@Settelement_Amount,0)  --Comment by Hasmukh 02082014 due to settlement & leave amount added twice in gross salary in case mid increment
             
                    If @Gross_Salary < @Revenue_on_Amount  and @Revenue_on_Amount> 0    
                        SET @Revenue_Amount = 0    
                    
                    SET @LWF_compare_month = '#'+ cast(Month(@Month_End_Date)as varchar(2)) + '#'    
             
             
             
                    If charindex(@LWF_compare_month,@LWF_App_Month,1) = 0 or @LWF_App_Month =''  or @is_emp_lwf = 0  or ISNULL(@Gross_Salary,0) = 0 --Condition of Gross Salary Added By Ramiz on 05072016 after discussion with Ankit Bhai
                        Begin    
                            SET @LWF_Amount = 0    
                        End      
                    
                    
                --Added By Ramiz on 03/08/2016 , becoz TDS should not be deducted if Gross Salary is 0
                    IF  ISNULL(@GROSS_SALARY,0) = 0
                        BEGIN                   
                            UPDATE MAD
                            SET MAD.M_AD_AMOUNT = 0
                            FROM #T0210_MONTHLY_AD_DETAIL AS MAD
                            INNER JOIN DBO.T0050_AD_MASTER AS AD ON  MAD.AD_ID=AD.AD_ID
                            WHERE MAD.TEMP_SAL_TRAN_ID = @SAL_TRAN_ID   AND AD.AD_DEF_ID = 1 AND AD.CMP_ID=@CMP_ID
                            
                            UPDATE MAD1
                            SET MAD1.M_AD_AMOUNT = 0
                            FROM T0210_MONTHLY_AD_DETAIL AS MAD1
                            INNER JOIN DBO.T0050_AD_MASTER AS AD ON  MAD1.AD_ID=AD.AD_ID
                            WHERE MAD1.TEMP_SAL_TRAN_ID = @SAL_TRAN_ID   AND AD.AD_DEF_ID = 1 AND AD.CMP_ID=@CMP_ID                                     
                            
                            SET @DEDU_AMOUNT = ISNULL(@DEDU_AMOUNT,0) - ISNULL(@M_IT_TAX,0)
                        END
                --TDS Condition Ended By Ramiz on 03/08/2016.
                
                    
                    --if not isnull(@increment_Month ,0) = @cnt -1 
                    --  begin
                        
                        
                    --      --SET @Leave_Salary_Amount = 0
                    --      --SET @Advance_Amount = 0
                    --      --SET @Loan_Amount = 0 
                    --      --SET @PT_Amount = 0
                    --      --SET @LWF_Amount = 0
                    --      --SET @Revenue_Amount= 0    
                        
                    --  end

                    ---Alpesh 20-Mar-2012 for Extra Deduction on Absent 
                    SET @Extra_AB_Amount = 0        
                    
                    --SET @Extra_AB_Amount = @Extra_AB_Amount + (@Extra_AB_Days * @Day_Salary)      
                    
                    --Commented by Hardik 10/04/2013.. Now Extra Absent Deduct from Present Days.. so no need to calculate Amount
                    --SET @Extra_AB_Amount = @Extra_AB_Amount + (@Extra_AB_Days * (@Actual_Gross_Salary/@Outof_Days))       
                    
                    ---End
                    if @Late_Mark_Scenario = 2 and @Is_LateMark_Percent = 1 and @Is_LateMark_Calc_On <> 0
                        Begin
                            Select 
								@Late_Dedu_Amount = Isnull(SUM(LATE_AMOUNT),0)
                            From T0140_MONTHLY_LATEMARK_TRANSACTION 
                            Where For_Date Between @MONTH_ST_DATE AND @MONTH_END_DATE and Emp_ID = @Emp_ID
                        End

					if @Early_Mark_Scenario = 2 and @Is_EarlyMark_Percent = 1 and @Is_EarlyMark_Calc_On <> 0
						Begin
							Select 
								@Late_Dedu_Amount = Isnull(@Late_Dedu_Amount,0) + Isnull(SUM(EARLY_AMOUNT),0)
                            From T0140_MONTHLY_EARLYMARK_TRANSACTION 
                            Where For_Date Between @MONTH_ST_DATE AND @MONTH_END_DATE and Emp_ID = @Emp_ID
						End

                    if @Late_Mark_Scenario = 3
                        Begin
                            Select 
                            @Late_Dedu_Amount = (Isnull(SUM(LATE_AMOUNT),0) + Isnull(SUM(LUNCH_AMOUNT),0))
                            From T0140_MONTHLY_LATEMARK_DESIGNATION 
                            Where For_Date Between @MONTH_ST_DATE AND @MONTH_END_DATE and Emp_ID = @Emp_ID
                        END
            
                    SET @Total_Dedu_Amount = isnull(@Dedu_Amount,0) + isnull(@Other_Dedu_Amount,0) + isnull(@Other_m_it_Amount,0) + 
                                isnull(@Advance_Amount,0) + isnull(@Loan_Amount,0)  + @PT_Amount + isnull(@LWF_Amount,0) +  
                                isnull(@Revenue_Amount,0) + Isnull(@Loan_Interest_Amount,0) + isnull(@Late_Dedu_Amount,0) + 
                                ISNULL(@Extra_Late_Dedu_Amount,0) + ISNULL(@Early_Dedu_Amount,0) + isnull(@Extra_Early_Dedu_Amount,0) + 
                                ISNULL(@Extra_AB_Amount,0) +  @Dedu_Amount_Arear + ISNULL(@mid_Deficit_Dedu_Amount,0) + @Dedu_Amount_Arear_cutoff + ISNULL(@Asset_Installment,0) + isnull(@Travel_Advance_Amount,0)+ --ADDED by mukti @Asset_Installment 24032015           
                                ISNULL(@Uniform_Deduction_Amount,0) + isnull(@Bond_Amount,0) 
                                
                   IF IsNull(@Loan_Amount,0) > 0 or @total_count_all_incremnet > 1					
						SET @IsLoanCalculated = 1
										
					if IsNull(@IsLoanCalculated,0) = 0 
						set @Total_Dedu_Amount = @Total_Dedu_Amount + isnull(@Loan_Amount,0)
                        
                    If @Is_Rounding = 1
                        Begin
                            SET @Gross_Salary = Round(@Gross_Salary,0)
                            SET @Total_Dedu_Amount = Round(@Total_Dedu_Amount,0)
                        End
                        
                    --SET @Net_Amount = Round(@Gross_Salary - @Total_Dedu_Amount,0)

                    
                    
                    SET @mid_gross_Amount = @mid_gross_Amount  + @Gross_Salary

                    If @SalaryBasis ='Day'    
                        Begin 
                 If @Salary_Depends_on_Production = 1
                          BEGIN
                            SET @mid_basic_Amount = Round(@mid_basic_Amount  + (@Day_Salary * @Sal_cal_Days),0)
                            SET @mid_salary_Amount = Round(@mid_salary_Amount  + (@Day_Salary * @Sal_cal_Days),0)   
                          END
                        ELSE
                          BEGIN
                            if @IS_ROUNDING = 1
                                begin
                                    If Isnull(@Sal_Fix_Days,0)=0
                                        SET @mid_basic_Amount = Round(@mid_basic_Amount  + (@Day_Salary * @Mid_Inc_Working_Day),0)
                                    Else
                                        SET @mid_basic_Amount = Round(@Basic_Salary,0)
                                        
                                    SET @mid_salary_Amount = Round(@mid_salary_Amount  + (@Day_Salary * @Sal_cal_Days),0)                                       
                                end
                            else
                                begin 
                                    If Isnull(@Sal_Fix_Days,0)=0
                                        SET @mid_basic_Amount = @mid_basic_Amount  + (@Day_Salary * @Mid_Inc_Working_Day)
                                    Else 
                                        SET @mid_basic_Amount = @Basic_Salary
                                        
                                    SET @mid_salary_Amount = @mid_salary_Amount  + (@Day_Salary * @Sal_cal_Days)
                                end
                         END
                            
                            IF @Grade_BasicSalary > 0 or @is_MachineBased = 1 or @Is_Gradewise_Salary = 1   --Ankit 07082015
                                BEGIN
                                    SET @MID_SALARY_AMOUNT = @Salary_Amount
                                    SET @BASIC_SALARY = @Salary_Amount
                                END
                        
                            
                            IF(@JOIN_DATE BETWEEN @MONTH_ST_DATE AND @MONTH_END_DATE OR @LEFT_DATE BETWEEN @MONTH_ST_DATE AND @MONTH_END_DATE)
                                BEGIN
                                    SET @MID_BASIC_AMOUNT=@BASIC_SALARY
                                END --ADDED BY SUMIT ON 11/11/2016 FOR MID JOINING DAY RATE BASIC Salary WAS WRONG  
                        End
                    Else     
                        Begin  
                            SET @mid_salary_Amount =@Salary_Amount
                            SET @mid_basic_Amount = @Basic_Salary
                        End
                    
                    --added by mehul on 10-may-2023
					if @settingval = 1 
					begin
							set @mid_Present_On_Holiday = 0
					end
					else
					begin
							set @mid_Present_On_Holiday = @mid_Present_On_Holiday + @Present_On_Holiday  -- Added by rohit on 29022016
					end
                    
                    --Commented By Ramiz and Hardik for Allowing Present days to Exceed from Month Days ( Mafatlals - Nadiad )
                    --set @Sal_cal_Days = @Sal_Cal_Days_temp
                    --set @Present_Days = @Present_Days_temp  
                    



                    SET @mid_Sal_Cal_Days = @mid_Sal_Cal_Days + @Sal_cal_Days
                    SET @mid_Present_Days = @mid_Present_Days + @Present_Days
                    SET @mid_Absent_Days = @mid_Absent_Days + @Absent_Days
                    SET @mid_OT_Adj_Days= @mid_OT_Adj_Days + @OT_Adj_Days
                    SET @mid_Holiday_Days = @mid_Holiday_Days  + @Holiday_Days
                    SET @mid_WeekOff_Days = @mid_WeekOff_Days + @Weekoff_Days
                    SET @mid_cancel_holiday = @mid_cancel_holiday + @Cancel_Holiday
                    SET @mid_cancel_weekoff = @mid_cancel_weekoff + @Cancel_Weekoff
                    
                    SET @mid_OT_Adj_Hours = @mid_OT_Adj_Hours + @IS_OT_Adj_Against_Absent_Hour  --Added By Jimit 20072018
 
                    SET @mid_total_leave_days = @mid_total_leave_days + @Total_Leave_Days
                    SET @mid_paid_leave_days = @mid_paid_leave_days + @Paid_Leave_Days
                    SET @Mid_OD_leave_Days = @Mid_OD_leave_Days + @OD_leave_Days
                    SET @Mid_Compoff_leave_Days = @Mid_Compoff_leave_Days + Isnull(@Compoff_leave_Days,0)
                                

                    SET @mid_Actual_Working_Hours =  dbo.F_Return_Hours(dbo.F_Return_Sec(isnull(@mid_Actual_Working_Hours,0)) + dbo.F_Return_Sec(Replace(isnull(@Actual_Working_Hours,0),'.',':'))) --deepal add replace for time to sec
                    SET @mid_Working_Hours = dbo.F_Return_Hours(dbo.F_Return_Sec(isnull(@mid_Working_Hours,0)) + dbo.F_Return_Sec(isnull(@Working_Hours,0)))
                    SET @mid_Outof_Hours  = dbo.F_Return_Hours(dbo.F_Return_Sec(isnull(@mid_Outof_Hours,0)) + dbo.F_Return_Sec(isnull(@Outof_Hours,0)))
                    
                    SET @mid_OT_Hours    = @mid_OT_Hours +  @Emp_OT_Hours_Num
                    SET @mid_Total_Hours    = dbo.F_Return_Hours(dbo.F_Return_Sec(isnull(@mid_Total_Hours,0)) + dbo.F_Return_Sec(isnull(@Total_Hours,0)))
                    SET @mid_Shift_Day_Sec   = @Shift_Day_Sec
                    SET @mid_Shift_Day_Hour = @Shift_Day_Hour
                    SET @mid_Day_Salary  = @Day_Salary
                    SET @mid_Hour_Salary     = @Hour_Salary
                    SET @mid_Allow_Amount    = @Allow_Amount
                    SET @mid_OT_Amount   = @mid_OT_Amount + @OT_Amount
                    SET @mid_Other_Allow_Amount  =@mid_Other_Allow_Amount + @Other_allow_Amount
                    SET @mid_Dedu_Amount     =  @Dedu_Amount 
                    SET @mid_Loan_Amount     =  @Loan_Amount
                    SET @mid_Loan_Intrest_Amount     = @Loan_Interest_Amount
                    SET @mid_Advance_Amount  = @Advance_Amount + @mid_M_Adv_Amount   --Changed BY Jimit 13052019 
                    SET @mid_Other_Dedu_Amount   = @mid_Other_Dedu_Amount +  @Other_Dedu_Amount
                    
						IF @IsLoanCalculated = 0  --Added by Jaina 23-01-2019
							begin
								SET @mid_Total_Dedu_Amount	 =  @mid_Total_Dedu_Amount + @Total_Dedu_Amount
							end
						else
							begin
								SET @mid_Total_Dedu_Amount = @Total_Dedu_Amount
							end
							
                    SET @mid_Due_Loan_Amount     = @Due_Loan_Amount
                    
                    SET @mid_Actually_Gross_Salary   = @mid_Actually_Gross_Salary + @Actual_Gross_Salary
                    SET @mid_PT_Amount   = @PT_Amount
                    SET @mid_PT_Calculated_Amount    = @PT_Calculated_Amount
                    SET @mid_Total_Claim_Amount  = @Total_Claim_Amount
                    SET @mid_M_OT_Hours  = @M_OT_Hours
                    SET @mid_M_Adv_Amount    = @mid_M_Adv_Amount + @M_ADV_AMOUNT
                    SET @mid_M_Loan_Amount   = @mid_M_Loan_Amount + @M_LOAN_AMOUNT
                    SET @mid_M_IT_Tax    =  @M_IT_Tax
                    SET @mid_LWF_Amount  = @LWF_Amount
                    SET @mid_Revenue_Amount  = @Revenue_Amount          
                    --SET @mid_Leave_Salary_Amount   = @mid_Leave_Salary_Amount + @Leave_Salary_Amount -- Comment by nilesh patel on 10032017 twice leave encashment in mid incremnt 
                    SET @mid_Leave_Salary_Amount     = @Leave_Salary_Amount
                    SET @mid_Late_Sec    = @mid_Late_Sec + @Total_Late_Sec 
                    SET @mid_Late_Dedu_Amount    = @mid_Late_Dedu_Amount + @Late_Dedu_Amount
                    SET @mid_Late_Extra_Dedu_Amount  = @mid_Late_Extra_Dedu_Amount + @late_Extra_Amount
                    SET @mid_Late_Days   = @mid_Late_Days + @Late_Absent_Day
                    SET @mid_Bonus_Amount    = @mid_Bonus_Amount + @Bonus_Amount
                    SET @mid_IT_M_ED_Cess_Amount     =  @IT_M_ED_Cess_Amount
                    SET @mid_IT_M_Surcharge_Amount   = @IT_M_Surcharge_Amount
                    
                    SET @mid_Early_Sec  = @mid_Early_Sec + @Total_Early_Sec 
                    SET @mid_Early_Dedu_Amount  = @mid_Early_Dedu_Amount + @Early_Dedu_Amount
                    SET @mid_Early_Extra_Dedu_Amount    = @mid_Early_Extra_Dedu_Amount + @Extra_Early_Dedu_Amount
                    SET @mid_Early_Days = @mid_Early_Days + @Early_Sal_Dedu_Days
                    
                    SET @mid_Total_Earning_Fraction  = @mid_Total_Earning_Fraction  + @Total_Earning_Fraction
                    SET @mid_Late_Early_Penalty_days  = @mid_Late_Early_Penalty_days + @Penalty_days_Early_Late 
                    SET @mid_M_WO_OT_Hours  = @mid_M_WO_OT_Hours + @Emp_WO_OT_Hours_Num
                    SET @mid_M_HO_OT_Hours  = @mid_M_HO_OT_Hours + @Emp_HO_OT_Hours_Num
                    SET @mid_M_WO_OT_Amount = @mid_M_WO_OT_Amount + @WO_OT_Amount
                    SET @mid_M_HO_OT_Amount = @mid_M_HO_OT_Amount + @HO_OT_Amount
                    
                    SET @mid_travel_Advance_Amount= @Travel_Advance_Amount -- Added by rohit on 24082015
                    SET @mid_Travel_Amount = @Travel_Amount
                    
                    SET @mid_Unifrom_dedu_Amt = @Uniform_Deduction_Amount
                    SET @mid_Unifrom_ref_Amt = @Uniform_Refund_Amount
                    SET @Month_St_Date = dateadd(d,1,@Month_End_Date )
                    
                    SET @mid_M_Working_Days = @mid_M_Working_Days + @Mid_Inc_Working_Day
                    --SET @Leave_Salary_Amount = 0
                    fetch next from curMDI into @Increment_ID,@Month_End_Date       
                END
                    
                        
                CLOSE curMDI
                DEALLOCATE curMDI
        
                    
                SET @CutoffDate_Salary = @CutoffDate_Salary_temp  -- -- Added by rohit For Mid increment Case on 09052015
                
                SET @mid_gross_Amount  = @mid_gross_Amount + ISNULL(@Leave_Salary_Amount,0) + isnull(@Settelement_Amount,0)   --Added by Hasmukh 02082014 due to settlement & leave amount added twice in gross salary in case mid increment         
            
                
                
                -- Comment and added by rohit for add allowance which not add in gross but calculate in net salary on 06-may-2013
                --SET @Net_Amount = Round(@mid_gross_Amount - @mid_Total_Dedu_Amount,0)
                
                If @Is_Rounding = 1
                    SET @Net_Amount = Round(@mid_gross_Amount - @mid_Total_Dedu_Amount,0) + isnull(@Allow_Amount_Effect_only_Net,0) - isnull(@Deduct_Amount_Effect_only_Net,0)
                Else
                    SET @Net_Amount = (@mid_gross_Amount - @mid_Total_Dedu_Amount) + isnull(@Allow_Amount_Effect_only_Net,0) - isnull(@Deduct_Amount_Effect_only_Net,0)
                    
                -- End by rohit on 06-may-2013
                SET @mid_Net_Amount  = @mid_Net_Amount + @Net_Amount

        
                SET @Security_Deposit_Amount =0
                -- Added by rohit on 30082014
                if isnull(@mid_Net_Amount,0) < 0
                    BEGIN
                        select @Security_Deposit_Amount = isnull(Sum(M_Ad_Amount),0) from T0210_MONTHLY_AD_DETAIL where Emp_ID=@emp_id and AD_ID in (
                        select AD_ID from T0050_AD_MASTER where CMP_ID=@cmp_id and AD_CALCULATE_ON ='Security Deposit') and temp_Sal_tran_Id=@sal_tran_id
                    
                        delete from T0210_MONTHLY_AD_DETAIL where Emp_ID=@emp_id and AD_ID in (
                        select AD_ID from T0050_AD_MASTER where CMP_ID=@cmp_id and AD_CALCULATE_ON ='Security Deposit') and temp_Sal_tran_Id=@sal_tran_id
                                    
                        SET @mid_Net_Amount = @mid_Net_Amount + @Security_Deposit_Amount
                        SET @mid_Total_Dedu_Amount = isnull(@mid_Total_Dedu_Amount,0) - isnull(@Security_Deposit_Amount,0)
                    END
                    
                -- below condition added by mitesh on 23/03/2012
                if @mid_Net_Amount < 0
                    BEGIN
                        IF (@Allow_Negative_Sal = 0)--Mihir Trivedi 25/07/2012
                            BEGIN
                            
                                --Ankit Rollback Loan Payment Transaction--09062014
                                    Delete From T0210_Monthly_Loan_Payment where Temp_Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
                                --Ankit Rollback Loan Payment Transaction--09062014
                                --Mukti Rollback AsSET Installment Payment Transaction--20042015
                                    Delete From t0140_asset_transaction where Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
                                --Mukti Rollback AsSET Installment Payment Transaction--20042015    
                                -- Added by rohit on 30082014
                            delete from dbo.T0210_Monthly_Leave_Detail   WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                            delete from dbo.T0210_MONTHLY_AD_DETAIL      WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                            --delete from dbo.T0210_MONTHLY_CLAIM_PAYMENT  WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id 
                            DELETE FROM T0210_Monthly_Salary_Slip_Gradecount where Sal_tran_Id=@SAL_TRAN_ID and cmp_id =@cmp_id --Added by Ramiz 19112015            
                            delete from dbo.T0210_PAYSLIP_DATA           WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                            delete from dbo.T0100_Anual_bonus            WHERE Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                            delete from dbo.T0200_monthly_salary_leave   WHERE Sal_tran_id = @Sal_Tran_ID and cmp_id =@cmp_id      
                            -- Ended by rohit
                            
                            --Added by Mukti Rollback Uniform Installment Payment Transaction--13062017
                            Delete From T0210_Uniform_Monthly_Payment where Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
                            --Added by Mukti Rollback Uniform Installment Payment Transaction--13062017     
                            
                            DELETE FROM T0140_MONTHLY_LATEMARK_TRANSACTION WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
                            DELETE FROM T0140_MONTHLY_LATEMARK_DESIGNATION WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
							Delete FROM T0140_MONTHLY_EARLYMARK_TRANSACTION  WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
                                
                            --Added For Rollback Late Mark Case When Basic Salary Zero 20082018
                                Delete FROM T0160_late_Approval Where For_Date = @tmp_Month_End_Date and Month_Date = @tmp_Month_St_Date and Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID
                                Update T0140_LEAVE_TRANSACTION SET Leave_Closing = Isnull(Leave_Closing,0) + Isnull(Leave_Adj_L_Mark,0) , Leave_Adj_L_Mark = 0 Where Emp_ID = @Emp_ID and For_Date = @Month_End_Date and Cmp_ID = @Cmp_ID
                            --Added For Rollback Late Mark Case When Basic Salary Zero 20082018         
    
                                SET @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Month='+cast(MONTH(@Month_End_Date) as varchar)+', Year='+cast(year(@Month_End_Date) as varchar)
                                exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Salary','Net Salary is Negative',@LogDesc,1,'',@Sal_Generate_Date
                                --RAISERROR ('Net Salary is Negative', 16,2);
                                GOTO NEXT_EMP
                            END
      ELSE --Mihir Trivedi 25/07/2012 for negative salary generation
                            BEGIN
                                SET @Next_Month_Advance = ABS(@mid_Net_Amount)
                                SET @mid_Net_Amount = 0

                                --Hardik 28/02/2013
                                if @manual_salary_period = 0   
                                    Begin
                                    --  SET @Next_Month_StrtDate = DATEADD(d,-1, DATEADD(m, 1, @sal_end_date))  --DATEADD(d, 1, @Month_End_Date) changed by mitesh                      
                                        SET @Next_Month_StrtDate =   DATEADD(d, 1, @Month_End_Date)
                                    End
                                Else
                                    Begin
                                        If Month(@Month_End_Date) < 12
                                            select @Next_Month_StrtDate=From_date from Salary_Period where month= (month(@Month_End_Date)+1) and YEAR=year(@Month_End_Date)
                                        else
                                            select @Next_Month_StrtDate=From_date from Salary_Period where month= 1 and YEAR=year(@Month_End_Date)+1
                                    End 

                                    --Added the Condition of NOT EXISTS by Ramiz on 23/05/2016--    
                                If Not Exists (Select Sal_Tran_Id From T0200_MONTHLY_SALARY Where Emp_ID =@Emp_Id And Cmp_ID=@Cmp_ID And Month_St_Date=@tmp_Month_St_Date And Month_End_Date =@tmp_Month_End_Date )
                                    BEGIN
                                        declare @Str varchar(1000)
                                        SET @Str = 'Due to Negative Salary for ' + Cast(@tmp_Month_End_Date As Varchar(12))
                                        EXEC P0100_ADVANCE_PAYMENT 0, @Cmp_ID, @Emp_ID, @Next_Month_StrtDate, @Next_Month_Advance, 0, 0, @Str, 'I' , 0 , '' , 0 , '' , 0 , @Sal_Tran_ID
                                    END
                                    --Ended by Ramiz on 23/05/2016--
                            END             
                    END
                ELSE -- added by Ali 04042014
                    BEGIN
                        
                        DECLARE @Rval NUMERIC(18, 4)
                        DECLARE @Rval_Add NUMERIC(18, 4)
                        SET @Rval =0
                            
                        IF @net_round >= 0 AND ISNULL(@net_round_Type,'') <> ''
                            BEGIN               
                                IF  @net_round_Type = 'Lower'
                                    BEGIN                   
                                        --select @mid_Net_Amount,@net_Round 
                                        --SET @mid_Net_Amount = @mid_Net_Amount + 125
                                        --select @mid_Net_Amount,@net_Round 
                                        
                                        SET @Temp_mid_Net_Amount = @mid_Net_Amount -- Added By Ali 04042014
                                        
                                        SET @Rval = CASE WHEN @net_round = 0   THEN 0 ELSE CASE WHEN @net_round = 10 THEN -1 ELSE CASE WHEN  @net_round = 100 THEN -2 ELSE 0 END END END
                                        --SET @Rval_Add = CASE WHEN @net_round = 0   THEN 0 ELSE CASE WHEN @net_round = 10 THEN 9 ELSE CASE WHEN  @net_round = 100 THEN 99 ELSE 0 END END END
                                        --SET @mid_Net_Amount =  floor((@mid_Net_Amount + @Rval_Add) / @Rval) * @Rval
                                        SET @mid_Net_Amount =  Round(@mid_Net_Amount, @Rval, 1)
                                        
                                        SET @mid_Net_Round_Diff_Amount = @mid_Net_Amount - @Temp_mid_Net_Amount -- Added By Ali 04042014
  
                                        --Select @mid_Net_Round_Diff_Amount
                                    END 
                                ELSE IF     @net_round_Type = 'Nearest'
                                    BEGIN                   
                                        --select @mid_Net_Amount,@net_Round 
                                        --SET @mid_Net_Amount = @mid_Net_Amount - 125
                                        --select @mid_Net_Amount,@net_Round 
                                        SET @Temp_mid_Net_Amount = @mid_Net_Amount  -- Added By Ali 04042014

                                        if @net_round > 0
                                            SET @mid_Net_Amount = ROUND(@mid_Net_Amount/@net_round,0) * @net_round
                                        Else
                                            SET @mid_Net_Amount = ROUND(@mid_Net_Amount,0)
                                        
                                        
                                        SET @mid_Net_Round_Diff_Amount = @mid_Net_Amount - @Temp_mid_Net_Amount -- Added By Ali 04042014
                                        
                                        --Select @mid_Net_Round_Diff_Amount
                                        
                                    END 
                                ELSE IF     @net_round_Type = 'Upper'
                                    BEGIN                   
                                        --select @mid_Net_Amount,@net_Round 
                                        --SET @mid_Net_Amount = @mid_Net_Amount + 125
                                        --select @mid_Net_Amount,@net_Round 
                                        SET @Temp_mid_Net_Amount = @mid_Net_Amount      -- Added By Ali 04042014
                                        
                                        
                                        IF (@net_round > 0)
                                            SET @mid_Net_Amount = @net_round * CEILING(@mid_Net_Amount/@net_round) -- Working as Upper
                                        Else
                                            SET @mid_Net_Amount = CEILING(@mid_Net_Amount)
                                        
                                        SET @mid_Net_Round_Diff_Amount = @mid_Net_Amount - @Temp_mid_Net_Amount     -- Added By Ali 04042014
                                        
                                        --Select @mid_Net_Round_Diff_Amount
                                    END 
                            end
                    END 
                
                if @mid_basic_Amount < 0 and @Allow_Negative_Sal = 0    --Added By Ramiz on 29/05/2017 (If Negative Salary is Allowed , we Should not Check this Again.)
                    begin
                        --Ankit Rollback Loan Payment Transaction--09062014
                                Delete From T0210_Monthly_Loan_Payment where Temp_Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
                        --Ankit Rollback Loan Payment Transaction--09062014
                        --Mukti Rollback AsSET Installment Payment Transaction--20042015
                                Delete From t0140_asset_transaction where Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
                        --Mukti Rollback AsSET Installment Payment Transaction--20042015    
                        -- Added by rohit on 30082014
                            delete from dbo.T0210_Monthly_Leave_Detail   WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                            delete from dbo.T0210_MONTHLY_AD_DETAIL      WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                            --delete from dbo.T0210_MONTHLY_CLAIM_PAYMENT  WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id 
                            DELETE FROM T0210_Monthly_Salary_Slip_Gradecount where Sal_tran_Id=@SAL_TRAN_ID and cmp_id =@cmp_id     --Added by Ramiz 19112015            
                            delete from dbo.T0210_PAYSLIP_DATA           WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                            delete from dbo.T0100_Anual_bonus            WHERE Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                            delete from dbo.T0200_monthly_salary_leave   WHERE Sal_tran_id = @Sal_Tran_ID and cmp_id =@cmp_id  
                            delete from dbo.T0210_Monthly_Reim_Detail   WHERE  Sal_tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id  
                            delete from dbo.T0140_ReimClaim_Transacation   WHERE  Sal_tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id               
                            -- Ended by rohit
                            --Added by Mukti Rollback Uniform Installment Payment Transaction--13062017
                            Delete From T0210_Uniform_Monthly_Payment where Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
                            --Added by Mukti Rollback Uniform Installment Payment Transaction--13062017     
                            DELETE FROM T0140_MONTHLY_LATEMARK_TRANSACTION WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
                            DELETE FROM T0140_MONTHLY_LATEMARK_DESIGNATION WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
							Delete FROM T0140_MONTHLY_EARLYMARK_TRANSACTION  WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
        
							Delete T0210_LWP_Considered_Same_Salary_Cutoff Where Sal_tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id --Added by Hardik 20/02/2019 for Havmor
							
                            --Added For Rollback Late Mark Case When Basic Salary Zero 20082018
                                Delete FROM T0160_late_Approval Where For_Date = @tmp_Month_End_Date and Month_Date = @tmp_Month_St_Date and Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID
                                Update T0140_LEAVE_TRANSACTION SET Leave_Closing = Isnull(Leave_Closing,0) + Isnull(Leave_Adj_L_Mark,0) , Leave_Adj_L_Mark = 0 Where Emp_ID = @Emp_ID and For_Date = @Month_End_Date and Cmp_ID = @Cmp_ID
                            --Added For Rollback Late Mark Case When Basic Salary Zero 20082018

                        SET @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Month='+cast(MONTH(@Month_End_Date) as varchar)+', Year='+cast(year(@Month_End_Date) as varchar)
                        exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Salary','Basic Salary is Negative',@LogDesc,1,'',@Sal_Generate_Date
                        --RAISERROR ('Basic Salary is Negative', 16,2);
                        GOTO NEXT_EMP   
                    end
                                                    
                if @mid_gross_Amount < 0 and @Allow_Negative_Sal = 0    --Added By Ramiz on 29/05/2017 (If Negative Salary is Allowed , we Should not Check this Again.)
                    begin
                        --Ankit Rollback Loan Payment Transaction--09062014
                                Delete From T0210_Monthly_Loan_Payment where Temp_Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
                        --Ankit Rollback Loan Payment Transaction--09062014
                        --Mukti Rollback AsSET Installment Payment Transaction--20042015
                                Delete From t0140_asset_transaction where Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
                        --Mukti Rollback AsSET Installment Payment Transaction--20042015    
                        -- Added by rohit on 30082014
                            delete from dbo.T0210_Monthly_Leave_Detail   WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                            delete from dbo.T0210_MONTHLY_AD_DETAIL      WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                            --delete from dbo.T0210_MONTHLY_CLAIM_PAYMENT  WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id 
                            DELETE FROM T0210_Monthly_Salary_Slip_Gradecount where Sal_tran_Id=@SAL_TRAN_ID and cmp_id =@cmp_id     --Added by Ramiz 19112015            
                            delete from dbo.T0210_PAYSLIP_DATA           WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                            delete from dbo.T0100_Anual_bonus            WHERE Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                            delete from dbo.T0200_monthly_salary_leave   WHERE Sal_tran_id = @Sal_Tran_ID and cmp_id =@cmp_id      
                            delete from dbo.T0210_Monthly_Reim_Detail   WHERE  Sal_tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id 
                            delete from dbo.T0140_ReimClaim_Transacation   WHERE  Sal_tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id                
                            -- Ended by rohit
                            
                            --Added by Mukti Rollback Uniform Installment Payment Transaction--13062017
                            Delete From T0210_Uniform_Monthly_Payment where Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
                            --Added by Mukti Rollback Uniform Installment Payment Transaction--13062017     
                            DELETE FROM T0140_MONTHLY_LATEMARK_TRANSACTION WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
                            DELETE FROM T0140_MONTHLY_LATEMARK_DESIGNATION WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
							Delete FROM T0140_MONTHLY_EARLYMARK_TRANSACTION  WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
                            
							Delete T0210_LWP_Considered_Same_Salary_Cutoff Where Sal_tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id --Added by Hardik 20/02/2019 for Havmor
							
                            --Added For Rollback Late Mark Case When Basic Salary Zero 20082018
                                Delete FROM T0160_late_Approval Where For_Date = @tmp_Month_End_Date and Month_Date = @tmp_Month_St_Date and Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID
                                Update T0140_LEAVE_TRANSACTION SET Leave_Closing = Isnull(Leave_Closing,0) + Isnull(Leave_Adj_L_Mark,0) , Leave_Adj_L_Mark = 0 Where Emp_ID = @Emp_ID and For_Date = @Month_End_Date and Cmp_ID = @Cmp_ID
                            --Added For Rollback Late Mark Case When Basic Salary Zero 20082018
                            
                        SET @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Month='+cast(MONTH(@Month_End_Date) as varchar)+', Year='+cast(year(@Month_End_Date) as varchar)
                        exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Salary','Gross Salary is Negative',@LogDesc,1,'',@Sal_Generate_Date
                        --RAISERROR ('Gross Salary is Negative', 16,2);
                        GOTO NEXT_EMP
                    end 

                -- above condition added by mitesh on 23/03/2012
		
                if @Is_Zero_Day_Salary = 0 and @Fix_Salary = 0  
                    begin
                        --if @total_Present_Days <= 0 -- Commented by rohit for check salcal day
                        if @Sal_cal_Days <= 0 
                            begin
                            --select * from dbo.T0140_ReimClaim_Transacation   WHERE  Emp_ID=10542 and cmp_id =55          
                                --Mukti Rollback AsSET Installment Payment Transaction--20042015
                                Delete From t0140_asset_transaction where Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
                                --Mukti Rollback AsSET Installment Payment Transaction--20042015    
                    
                                --Ankit Rollback Loan Payment Transaction--09062014
                                Delete From T0210_Monthly_Loan_Payment where Temp_Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
                                --Ankit Rollback Loan Payment Transaction--09062014
                                -- Added by rohit on 30082014
                                delete from dbo.T0210_Monthly_Leave_Detail   WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                                delete from dbo.T0210_MONTHLY_AD_DETAIL      WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                                --delete from dbo.T0210_MONTHLY_CLAIM_PAYMENT  WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id 
                                DELETE FROM T0210_Monthly_Salary_Slip_Gradecount where Sal_tran_Id=@SAL_TRAN_ID and cmp_id =@cmp_id       --Added By Ramiz  on 19/11/2015         
                                delete from dbo.T0210_PAYSLIP_DATA           WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                                delete from dbo.T0100_Anual_bonus            WHERE Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                                delete from dbo.T0200_monthly_salary_leave   WHERE Sal_tran_id = @Sal_Tran_ID and cmp_id =@cmp_id      
                                delete from dbo.T0210_Monthly_Reim_Detail   WHERE  Sal_tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id          
                                delete from dbo.T0140_ReimClaim_Transacation   WHERE  Sal_tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id          
                                
                                -- Ended by rohit
                                --Added by Mukti Rollback Uniform Installment Payment Transaction--13062017
                                Delete From T0210_Uniform_Monthly_Payment where Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
                                --Added by Mukti Rollback Uniform Installment Payment Transaction--13062017         
                                
								Delete T0210_LWP_Considered_Same_Salary_Cutoff Where Sal_tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id --Added by Hardik 20/02/2019 for Havmor
								
                                DELETE FROM T0140_MONTHLY_LATEMARK_TRANSACTION WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
                                DELETE FROM T0140_MONTHLY_LATEMARK_DESIGNATION WHERE SAL_TRAN_ID = @SAL_TRAN_ID
								Delete FROM T0140_MONTHLY_EARLYMARK_TRANSACTION  WHERE SAL_TRAN_ID = @SAL_TRAN_ID  
                                
                                --Added For Rollback Late Mark Case When Basic Salary Zero 20082018
                                Delete FROM T0160_late_Approval Where For_Date = @tmp_Month_End_Date and Month_Date = @tmp_Month_St_Date and Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID
                                Update T0140_LEAVE_TRANSACTION SET Leave_Closing = Isnull(Leave_Closing,0) + Isnull(Leave_Adj_L_Mark,0) , Leave_Adj_L_Mark = 0 Where Emp_ID = @Emp_ID and For_Date = @Month_End_Date and Cmp_ID = @Cmp_ID
                                --Added For Rollback Late Mark Case When Basic Salary Zero 20082018
                                
                                SET @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Month='+cast(MONTH(@Month_End_Date) as varchar)+', Year='+cast(year(@Month_End_Date) as varchar)
                                exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Salary','Zero Days Salary',@LogDesc,1,'',@Sal_Generate_Date
                                --RAISERROR ('Zero Days Salary', 16,2);
                                GOTO NEXT_EMP   
                            end
                    end
                 
                if @Is_Zero_Basic_Salary = 0
                    begin
                    
                        if @mid_basic_Amount = 0
                            begin
                                --Mukti Rollback AsSET Installment Payment Transaction--20042015
                                        Delete From t0140_asset_transaction where Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
                                --Mukti Rollback AsSET Installment Payment Transaction--20042015    
                            
                                --Ankit Rollback Loan Payment Transaction--09062014
                                    Delete From T0210_Monthly_Loan_Payment where Temp_Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
                                --Ankit Rollback Loan Payment Transaction--09062014
                                -- Added by rohit on 30082014
                                delete from dbo.T0210_Monthly_Leave_Detail   WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                                delete from dbo.T0210_MONTHLY_AD_DETAIL      WHERE  Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                                --delete from dbo.T0210_MONTHLY_CLAIM_PAYMENT  WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id
                                DELETE FROM T0210_Monthly_Salary_Slip_Gradecount where Sal_tran_Id=@SAL_TRAN_ID and cmp_id =@cmp_id       --Added By Ramiz on 19/11/2015           
                                delete from dbo.T0210_PAYSLIP_DATA           WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                                delete from dbo.T0100_Anual_bonus            WHERE Sal_Tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id      
                                delete from dbo.T0200_monthly_salary_leave   WHERE Sal_tran_id = @Sal_Tran_ID and cmp_id =@cmp_id      
                                delete from dbo.T0210_Monthly_Reim_Detail   WHERE  Sal_tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id          
                                delete from dbo.T0140_ReimClaim_Transacation   WHERE  Sal_tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id       
                                -- Ended by rohit
                                --Added by Mukti Rollback Uniform Installment Payment Transaction--13062017
                                Delete From T0210_Uniform_Monthly_Payment where Sal_Tran_ID = @Sal_Tran_ID  and Cmp_Id=@Cmp_ID    
                                --Added by Mukti Rollback Uniform Installment Payment Transaction--13062017     
                                DELETE FROM T0140_MONTHLY_LATEMARK_TRANSACTION WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
                                DELETE FROM T0140_MONTHLY_LATEMARK_DESIGNATION WHERE SAL_TRAN_ID = @SAL_TRAN_ID
								Delete FROM T0140_MONTHLY_EARLYMARK_TRANSACTION  WHERE SAL_TRAN_ID = @SAL_TRAN_ID      
                                
								Delete T0210_LWP_Considered_Same_Salary_Cutoff Where Sal_tran_ID = @Sal_Tran_ID and cmp_id =@cmp_id --Added by Hardik 20/02/2019 for Havmor
                                --Added For Rollback Late Mark Case When Basic Salary Zero 20082018
                                Delete FROM T0160_late_Approval Where For_Date = @tmp_Month_End_Date and Month_Date = @tmp_Month_St_Date and Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID
                                Update T0140_LEAVE_TRANSACTION SET Leave_Closing = Isnull(Leave_Closing,0) + Isnull(Leave_Adj_L_Mark,0) , Leave_Adj_L_Mark = 0 Where Emp_ID = @Emp_ID and For_Date = @Month_End_Date and Cmp_ID = @Cmp_ID
                                --Added For Rollback Late Mark Case When Basic Salary Zero 20082018

                                SET @LogDesc = 'Emp_Code='+@Alpha_Emp_Code+', Month='+cast(MONTH(@Month_End_Date) as varchar)+', Year='+cast(year(@Month_End_Date) as varchar)
                                exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Salary','Zero Basic Salary',@LogDesc,1,'',@Sal_Generate_Date
                                --RAISERROR ('Zero Basic Salary', 16,2);
                                GOTO NEXT_EMP
                            end
                    end

        -- END of Mid Increment Loop
        
        
        IF @M_Sal_Tran_ID > 0     
            BEGIN               
                UPDATE    T0200_MONTHLY_SALARY    
                SET       Increment_ID = @Increment_ID, Month_St_Date = @tmp_Month_St_Date, Month_End_Date = @tmp_Month_End_Date,     
                          Sal_Generate_Date = @Sal_Generate_Date, Sal_Cal_Days = @mid_Sal_cal_Days, Present_Days = @mid_Present_Days, Absent_Days = @mid_Absent_Days,     
                          Holiday_Days = @mid_Holiday_Days, Weekoff_Days = @mid_WeekOff_Days, Cancel_Holiday = @mid_cancel_holiday, Cancel_Weekoff = @mid_cancel_weekoff,     
                          Working_Days = @Working_Days, Outof_Days = @Outof_Days, Total_Leave_Days = @mid_total_leave_days, Paid_Leave_Days = @mid_paid_leave_days,     
                          Actual_Working_Hours = @mid_Actual_Working_Hours, Working_Hours = @mid_Working_Hours, Outof_Hours = @mid_Outof_Hours,     
                         -- OT_Hours = @Emp_OT_Sec / 3600, Total_Hours = @Total_Hours, Shift_Day_Sec = @Shift_Day_Sec, Shift_Day_Hour = @Shift_Day_Hour,     
                          OT_Hours =@mid_OT_Hours , Total_Hours = @mid_Total_Hours, Shift_Day_Sec = @mid_Shift_Day_Sec, Shift_Day_Hour = @mid_Shift_Day_Hour,     
                          Basic_Salary = @mid_basic_Amount , Day_Salary = @mid_Day_Salary, Hour_Salary = @mid_Hour_Salary, Salary_Amount = @mid_salary_Amount,     
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
                          ,Total_Earning_Fraction = @mid_Total_Earning_Fraction , Arear_Basic = @Salary_amount_Arear, Arear_Gross = @Gross_Salary_Arear, Arear_Day = @Arear_Day,
                          Late_Early_Penalty_days = @mid_Late_Early_Penalty_days, OD_leave_Days = @Mid_OD_leave_Days
                          ,Extra_AB_Days=@Extra_AB_Days,Extra_AB_Rate=@Extra_AB_Rate,Extra_AB_Amount=@Extra_AB_Amount, Settelement_Amount = @Settelement_Amount,
                          Deficit_Sec = @mid_Deficit_Sec, Deficit_Dedu_Amount = @mid_Deficit_Dedu_Amount
                          ,Net_Salary_Round_Diff_Amount = @mid_Net_Round_Diff_Amount -- Added By Ali 04042014
                           ,GatePass_Deduct_Days = isnull(@GatePass_Deduct_Days,0) -- Added by Gadriwala muslim 05012015
                          ,GatePass_Amount = 0     -- Added by Gadriwala muslim 06012015
                          ,cutoff_date=@CutoffDate_Salary
                          ,Arear_Day_Previous_month =isnull(@Absent_after_Cutoff_date,0),Basic_Salary_arear_cutoff = isnull(@Salary_amount_Arear_cutoff,0) ,Gross_Salary_arear_cutoff = isnull(@Gross_Salary_Arear_cutoff,0)
                         ,asset_installment=@Asset_Installment
                         ,Extra_AB_Holiday_Days_Dection = @No_Holiday_Days , Arear_Month = @Arear_Month,Arear_Year = @Arear_Year
                         ,Travel_Amount=@mid_Travel_Amount
                          ,Travel_Advance_Amount = @mid_travel_Advance_Amount
                          ,Present_On_Holiday =@mid_Present_On_Holiday -- Added by rohit on 19022016
                          ,Uniform_Dedu_Amount=@mid_Unifrom_dedu_Amt,Uniform_Refund_Amount=@mid_Unifrom_ref_Amt
                          ,OT_Adj_against_absent = @mid_OT_Adj_Days
                          ,OT_Adj_Against_Absent_Hours = @mid_OT_Adj_Hours  --Added By Jimit 20072018
                WHERE     (Sal_Tran_ID = @SAL_TRAN_ID) AND (Emp_ID = @EMP_ID)    
           
                Update  T0210_MONTHLY_LEAVE_DETAIL    
                SET     SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,    
                        TEMP_SAL_TRAN_ID = NULL    
                WHERE   EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID  and Cmp_Id=@Cmp_ID    
          
                ----------------Nilay18062014---------------------
                UPDATE T0210_Monthly_Reim_detail              
                    SET  SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,      
                         TEMP_SAL_TRAN_ID = NULL      
                WHERE EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID and Cmp_Id=@Cmp_ID     
                ----------------Nilay18062014--------------------- 
           
                UPDATE  T0210_MONTHLY_AD_DETAIL     
                SET     SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,    
                        TEMP_SAL_TRAN_ID = NULL    
                WHERE   EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID  and Cmp_Id=@Cmp_ID    

                alter table T0210_MONTHLY_LOAN_PAYMENT Disable trigger Tri_T0210_MONTHLY_LOAN_PAYMENT_UPDATE    

                UPDATE  T0210_MONTHLY_LOAN_PAYMENT    
                SET     SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,    
                        TEMP_SAL_TRAN_ID = NULL    
                WHERE   TEMP_SAL_TRAN_ID = @SAL_TRAN_ID and Cmp_Id=@Cmp_ID 
                        AND LOAN_APR_ID IN (SELECT LOAN_APR_ID FROM T0120_LOAN_APPROVAL WHERE EMP_ID = @EMP_ID)    

                alter table T0210_MONTHLY_LOAN_PAYMENT Enable trigger Tri_T0210_MONTHLY_LOAN_PAYMENT_UPDATE    

                --  alter table T0210_MONTHLY_CLAIM_PAYMENT Disable trigger Tri_T0210_MONTHLY_CLAIM_PAYMENT_UPDATE    
                   
                --  UPDATE T0210_MONTHLY_CLAIM_PAYMENT    
                --  SET SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,    
                -- TEMP_SAL_TRAN_ID = NULL    
                --  WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID and Cmp_Id=@Cmp_ID     
                --AND CLAIM_APR_ID IN (SELECT CLAIM_APR_ID FROM T0120_CLAIM_APPROVAL WHERE EMP_ID = @EMP_ID)        

                --  alter table T0210_MONTHLY_CLAIM_PAYMENT Enable trigger Tri_T0210_MONTHLY_CLAIM_PAYMENT_UPDATE    
        
                UPDATE  T0210_PAYSLIP_DATA     
                SET     SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,    
                        TEMP_SAL_TRAN_ID = NULL    
                WHERE   TEMP_SAL_TRAN_ID = @SAL_TRAN_ID and Cmp_Id=@Cmp_ID     

            END    
        ELSE    
            BEGIN

                if isnull(@W_OT_Hours,0) <= 0
                    begin       
                        SET @W_OT_Hours = @Emp_WO_OT_Hours_Num
                    end
                
                if isnull(@H_OT_Hours,0) <= 0
                    begin               
                        SET @H_OT_Hours = @Emp_HO_OT_Hours_Num          
                    end

                -- INSERT INTO T0200_MONTHLY_SALARY    
                --                       (Sal_Tran_ID, Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,     
                --                       Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,     
                --                       Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary,     
                --                       Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,     
                --                       Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, PT_Calculated_Amount, PT_Amount,     
                --                       Total_Claim_Amount, M_IT_Tax, M_Adv_Amount, M_Loan_Amount, M_OT_Hours, LWF_Amount, Revenue_Amount, PT_F_T_Limit,     
                --                       Actually_Gross_Salary,Leave_Salary_Amount, Late_Sec, Late_Dedu_Amount, Late_Extra_Dedu_Amount, Late_Days,Salary_Status,Bonus_Amount,IT_M_ED_Cess_Amount,IT_M_Surcharge_Amount,Early_Sec,Early_Dedu_Amount,Early_Extra_Dedu_Amount,Early_Days,Total_Earning_Fraction,Late_Early_Penalty_days,M_WO_OT_Hours,M_WO_OT_Amount,M_HO_OT_Hours,M_HO_OT_Amount)    
                -- VALUES     (@Sal_Tran_ID,@Sal_Receipt_No,@Emp_ID,@Cmp_ID,@Increment_ID,@Month_St_Date,@Month_End_Date,@Sal_Generate_Date,@Sal_cal_Days,@Present_Days,@Absent_Days,@Holiday_Days,@Weekoff_Days,@Cancel_Holiday,@Cancel_Weekoff,@Working_Days,@Outof_Days,@Total_Leave_Days,@Paid_Leave_Days,@Actual_Working_Hours,@Working_Hours,@Outof_Hours,
                    ----        @Emp_OT_Sec/ 3600,@Total_Hours,@Shift_Day_Sec,@Shift_Day_Hour,@Basic_Salary,@Day_Salary,@Hour_Salary,@Salary_Amount,@Allow_Amount,@OT_Amount,@Other_Allow_Amount,@Gross_Salary,@Dedu_Amount,@Loan_Amount,@Loan_Interest_Amount,@Advance_Amount,@Other_Dedu_Amount,@Total_Dedu_Amount,@Due_Loan_Amount,@Net_Amount,@PT_Calculated_Amount,@PT_Amount,@Total_Claim_Amount,@M_IT_Tax,@M_ADv_Amount,@M_Loan_Amount,@M_OT_Hours,@LWF_Amount,@REvenue_Amount,@PT_F_T_LIMIT,@Gross_Salary_ProRata,@Leave_Salary_Amount, @Total_Late_Sec, @Late_Dedu_Amount, @Extra_Late_Deduction, @Late_Absent_Day,@Status,@Bonus_Amount,@IT_M_ED_Cess_Amount,@IT_M_Surcharge_Amount)     
                    --      @Emp_OT_Hours_Num,@Total_Hours,@Shift_Day_Sec,@Shift_Day_Hour,@Basic_Salary,@Day_Salary,@Hour_Salary,@Salary_Amount,@Allow_Amount,@OT_Amount,@Other_Allow_Amount,@Gross_Salary,@Dedu_Amount,@Loan_Amount,@Loan_Interest_Amount,@Advance_Amount,@Other_Dedu_Amount,@Total_Dedu_Amount,@Due_Loan_Amount,@Net_Amount,@PT_Calculated_Amount,@PT_Amount,@Total_Claim_Amount,@M_IT_Tax,@M_ADv_Amount,@M_Loan_Amount,@M_OT_Hours,@LWF_Amount,@REvenue_Amount,@PT_F_T_LIMIT,@Gross_Salary_ProRata,@Leave_Salary_Amount, @Total_Late_Sec, @Late_Dedu_Amount, @Extra_Late_Deduction, @Late_Absent_Day,@Status,@Bonus_Amount,@IT_M_ED_Cess_Amount,@IT_M_Surcharge_Amount,@Total_Early_Sec,@Early_Dedu_Amount,@Extra_Early_Deduction,@Early_Sal_Dedu_Days,@Total_Earning_Fraction,@Penalty_days_Early_Late ,@W_OT_Hours, @WO_OT_Amount,@H_OT_Hours, @HO_OT_Amount)     
                  
                  -- Select * from T0200_MONTHLY_SALARY where emp_id=@Emp_ID



                INSERT INTO T0200_MONTHLY_SALARY    
                         (Sal_Tran_ID, Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,     
                         Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,     
                         Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary,     
                         Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,     
                         Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, PT_Calculated_Amount, PT_Amount,     
                         Total_Claim_Amount, M_IT_Tax, M_Adv_Amount, M_Loan_Amount, M_OT_Hours, LWF_Amount, Revenue_Amount, PT_F_T_Limit,     
                         Actually_Gross_Salary,Leave_Salary_Amount, Late_Sec, Late_Dedu_Amount, Late_Extra_Dedu_Amount, Late_Days,Salary_Status,Bonus_Amount
                         ,IT_M_ED_Cess_Amount,IT_M_Surcharge_Amount,Early_Sec,Early_Dedu_Amount,Early_Extra_Dedu_Amount,Early_Days,Total_Earning_Fraction
                         ,Late_Early_Penalty_days,M_WO_OT_Hours,M_WO_OT_Amount,M_HO_OT_Hours,M_HO_OT_Amount, Is_Monthly_Salary, Arear_Basic, Arear_Gross, Arear_Day, OD_leave_Days,Extra_AB_Days,Extra_AB_Rate,Extra_AB_Amount,Settelement_Amount,
                          Deficit_Sec,Deficit_Dedu_Amount,Net_Salary_Round_Diff_Amount,GatePass_Deduct_Days,GatePass_Amount,Cutoff_date,Arear_Day_Previous_month ,Basic_Salary_arear_cutoff,Gross_Salary_arear_cutoff,Asset_Installment,Extra_AB_Holiday_Days_Dection , Arear_Month,Arear_Year,Travel_Amount,travel_Advance_Amount,Present_On_Holiday,Uniform_Dedu_Amount,Uniform_Refund_Amount,OT_Adj_against_absent,OT_Adj_Against_Absent_Hours,BOND_Amount)
                VALUES  (@Sal_Tran_ID,@Sal_Receipt_No,@Emp_ID,@Cmp_ID,@Increment_ID,@tmp_Month_St_Date,@tmp_Month_End_Date,@Sal_Generate_Date,@mid_Sal_Cal_Days,@mid_Present_Days
                        ,@mid_Absent_Days,@mid_Holiday_Days,@mid_Weekoff_Days,@mid_Cancel_Holiday,@mid_Cancel_Weekoff,@Working_Days,@Outof_Days,@mid_Total_Leave_Days,@mid_Paid_Leave_Days
                        ,@mid_Actual_Working_Hours,@mid_Working_Hours,@mid_Outof_Hours,@mid_OT_Hours,@Total_Hours,@mid_Shift_Day_Sec,@mid_Shift_Day_Hour,@mid_basic_Amount ,@mid_Day_Salary
                        ,@mid_Hour_Salary,@mid_Salary_Amount,@mid_Allow_Amount,@mid_OT_Amount,@mid_Other_Allow_Amount,@mid_gross_Amount,@mid_Dedu_Amount,@mid_Loan_Amount,@mid_Loan_Intrest_Amount
                        ,@mid_Advance_Amount,@mid_Other_Dedu_Amount,@mid_Total_Dedu_Amount,@mid_Due_Loan_Amount,@mid_Net_Amount,@mid_PT_Calculated_Amount,@mid_PT_Amount
                        ,@mid_Total_Claim_Amount,@mid_M_IT_Tax,@mid_M_ADv_Amount,@mid_M_Loan_Amount,@mid_M_OT_Hours,@mid_LWF_Amount,@mid_REvenue_Amount,@mid_PT_F_T_LIMIT
                        ,@Gross_Salary_ProRata,@mid_Leave_Salary_Amount, @mid_Late_Sec, @mid_Late_Dedu_Amount, @Extra_Late_Deduction, @mid_Late_Days,@Status,@mid_Bonus_Amount
                        ,@mid_IT_M_ED_Cess_Amount,@mid_IT_M_Surcharge_Amount,@mid_Early_Sec,@mid_Early_Dedu_Amount,@mid_Early_Extra_Dedu_Amount,@mid_Early_Days,@mid_Total_Earning_Fraction
                        ,@mid_Late_Early_Penalty_days,@Emp_WO_OT_Hours_Var, @mid_M_WO_OT_Amount,@Emp_HO_OT_Hours_Var,@mid_M_HO_OT_Amount,1,@Salary_amount_Arear,@Gross_Salary_Arear,@Arear_Day,@Mid_OD_leave_Days,@Extra_AB_Days,@Extra_AB_Rate,@Extra_AB_Amount,@Settelement_Amount,
                        @mid_Deficit_Sec,@mid_Deficit_Dedu_Amount,@mid_Net_Round_Diff_Amount,isnull(@GatePass_Deduct_Days,0),0,@CutoffDate_Salary,@Absent_after_Cutoff_date ,isnull(@Salary_amount_Arear_cutoff,0),isnull(@Gross_Salary_Arear_cutoff,0),@Asset_Installment,@No_Holiday_Days ,@Arear_Month,@Arear_Year,@mid_Travel_Amount ,@mid_travel_Advance_Amount,@mid_Present_On_Holiday,@mid_Unifrom_dedu_Amt,@mid_Unifrom_ref_Amt,@mid_OT_Adj_Days,@mid_OT_Adj_Hours,@BOND_AMOUNT)
                --- Uncommented by Gadriwala Muslim 15102014
                ---- Added for audit trail By Ali 12102013 -- Start
                SET @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER Where Emp_ID = @Emp_ID)
                


                SET @OldValue = 'New Value' 
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
                                + '#' + 'Extra Late Deduction :' + CONVERT(nvarchar(100),ISNULL(@Extra_Late_Deduction,0))
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
                                + '#' + 'Uniform Ded Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Unifrom_dedu_Amt,0))
                                + '#' + 'Uniform Ref Amount :' + CONVERT(nvarchar(100),ISNULL(@mid_Unifrom_ref_Amt,0))                                              
                                + '#' + 'Status :' + CONVERT(nvarchar(100),ISNULL(@Status,0))
                                                                                        
                EXEC dbo.P9999_Audit_Trail @Cmp_ID,'I','Salary Monthly',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1
                                        -- Added for audit trail By Ali 12102013 -- End
           
                Update  T0210_MONTHLY_LEAVE_DETAIL    
                SET     SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,    
                        TEMP_SAL_TRAN_ID = NULL    
                WHERE   EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID  and Cmp_Id=@Cmp_ID    
        
                ALTER TABLE T0210_MONTHLY_AD_DETAIL DISABLE TRIGGER Tri_T0210_MONTHLY_AD_DETAIL 
            
                UPDATE   T0210_MONTHLY_AD_DETAIL     
                SET     SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,    
                        TEMP_SAL_TRAN_ID = NULL    
                WHERE   EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID  and Cmp_Id=@Cmp_ID    
       
                ALTER TABLE T0210_MONTHLY_AD_DETAIL ENABLE TRIGGER Tri_T0210_MONTHLY_AD_DETAIL 
           
                ALTER TABLE T0210_MONTHLY_LOAN_PAYMENT DISABLE TRIGGER Tri_T0210_MONTHLY_LOAN_PAYMENT_UPDATE    
           
                ----------------Nilay18062014---------------------
                UPDATE  T0210_Monthly_Reim_detail             
                SET     SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,      
                        TEMP_SAL_TRAN_ID = NULL      
                WHERE   EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID and Cmp_Id=@Cmp_ID     
                ----------------Nilay18062014---------------------
        
                UPDATE  T0210_MONTHLY_LOAN_PAYMENT    
                SET     SAL_TRAN_ID = TEMP_SAL_TRAN_ID  ,    
                        TEMP_SAL_TRAN_ID = NULL    
                WHERE   TEMP_SAL_TRAN_ID = @SAL_TRAN_ID  and Cmp_Id=@Cmp_ID    
                        AND LOAN_APR_ID IN (SELECT LOAN_APR_ID FROM T0120_LOAN_APPROVAL WHERE EMP_ID = @EMP_ID)    
           
                ALTER TABLE T0210_MONTHLY_LOAN_PAYMENT Enable trigger Tri_T0210_MONTHLY_LOAN_PAYMENT_UPDATE    
           
                --alter table T0210_MONTHLY_CLAIM_PAYMENT Disable trigger Tri_T0210_MONTHLY_CLAIM_PAYMENT_UPDATE    
           
                --  UPDATE T0210_MONTHLY_CLAIM_PAYMENT    
                --  SET SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,    
                -- TEMP_SAL_TRAN_ID = NULL    
                   
                --  WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID  and Cmp_Id=@Cmp_ID    
                --AND CLAIM_APR_ID IN (SELECT CLAIM_APR_ID FROM T0120_CLAIM_APPROVAL WHERE EMP_ID = @EMP_ID)        

                --  alter table T0210_MONTHLY_CLAIM_PAYMENT Enable trigger Tri_T0210_MONTHLY_CLAIM_PAYMENT_UPDATE    
                   
                UPDATE  T0210_PAYSLIP_DATA     
                SET     SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,    
                        TEMP_SAL_TRAN_ID = NULL    
                WHERE   TEMP_SAL_TRAN_ID = @SAL_TRAN_ID and Cmp_Id=@Cmp_ID     
            END    
      
		If exists(Select 1 From #LWP_LEAVE_AFTER_CUTOFF WHERE Emp_Id = @Emp_Id) And @Is_Consider_LWP_In_Same_Month = 1 --Added by Hardik 22/02/2019 for Havmor
			BEGIN
				INSERT INTO T0210_LWP_Considered_Same_Salary_Cutoff
				SELECT @Cmp_Id, Emp_Id, @Sal_Tran_Id, Leave_Approval_Id, Leave_Id, Leave_Period, For_Date
				FROM #LWP_LEAVE_AFTER_CUTOFF WHERE Emp_Id = @Emp_Id
			END
	  
        SET @M_SAL_TRAN_ID = @SAL_TRAN_ID       

        ---Added by Hardik 13/11/2013 for Sharp Images, Pakistan
        If exists (Select 1 from sys.objects where name = '##Salary' and type = 'U')
            Drop Table ##Salary --Hardik 11/11/2013
            
        --Added by Ramiz on 19/11/2015 For Mafatlals Salary Slip Records--

        
        IF @Grade_BasicSalary > 0 OR @Grade_BasicSalary_Night > 0 OR @Grade_Name = '999'
            BEGIN
                --As this is Only Used for Salary Slip , Keeping the Allowance Short Name as Hard Coded As discussed by Hardik bhai. . .Only 1 Allowance to be Added here to be displayed in Salary Slip.
                DECLARE @AVG_SAL AS NUMERIC(18,2)
                SET @AVG_SAL = 0
                SELECT TOP 1 @AVG_SAL = ISNULL(M_AD_Amount,0) FROM T0210_MONTHLY_AD_DETAIL MAD 
                    INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID AND Upper(AD.AD_SORT_NAME) = 'AVG_SAL'
                WHERE EMP_ID = @EMP_ID AND SAL_TRAN_ID = @SAL_TRAN_ID   
                SET @Day_Basic_Salary = ISNULL(@Day_Basic_Salary,0)
                SET @Night_Basic_Salary = ISNULL(@Night_Basic_Salary,0)
                
                Insert into T0210_Monthly_Salary_Slip_Gradecount
                (Sal_tran_id , Emp_id , Cmp_id , Sal_St_date , Sal_End_date , Actual_day_Count , Actual_night_count , Upgrade_day_count , Upgrade_night_count , Day_Basic_Salary , Night_Basic_Salary , Day_Basic_DA , Night_Basic_DA , CL_Leave , AVG_SAL , Grd_OT_Hours)
                Values
                (@Sal_Tran_ID , @Emp_Id , @Cmp_ID , @tmp_Month_St_Date , @tmp_Month_End_Date , @Actual_Grade_Day_Shift , @Actual_Grade_Night_Shift ,@Upper_Grade_Day_Shift , @Upper_Grade_Night_Shift , @Day_Basic_Salary , @Night_Basic_Salary , @SALRY_SLIP_DA , @SALRY_SLIP_NIGHT_DA , @CL_Leave , @AVG_SAL , ISNULL(@Grd_OT_Hours,0))
            END

    
        /**********************************************
        **********************************************/     
    NEXT_EMP:    
                 
        UPDATE  t0200_Pre_Salary_Data_monthly
        SET     is_processed = 1
        WHERE   Tran_ID = @cur_mon_Tran_id

        DECLARE @GUID_PART VARCHAR(32);
        Select  @GUID_PART = REVERSE(SUBSTRING(REVERSE(Batch_id),0, CHARINDEX('-', REVERSE(Batch_id)))) 
        FROM    t0200_Pre_Salary_Data_monthly 
        WHERE   Tran_ID = @cur_mon_Tran_id

        DECLARE @Processed INT;
        SELECT  @Processed = COUNT(1)
        FROM    t0200_Pre_Salary_Data_monthly 
        WHERE   Batch_id LIKE '%' + @GUID_PART and is_processed=1

        UPDATE  T0211_SALARY_PROCESSING_STATUS
        SET     Processed = @Processed
        WHERE   SPID = @@SPID

        TRUNCATE TABLE #OT_Data;
        TRUNCATE TABLE #Data;
        TRUNCATE TABLE #Split_Shift_Table;
        TRUNCATE TABLE #Att_Muster_with_shift;

		IF OBJECT_ID('tempdb..##Att_Muster1') IS NOT NULL
			TRUNCATE TABLE ##Att_Muster1;

        TRUNCATE TABLE #Mid_Increment;
        TRUNCATE TABLE #Total_leave_Id;
        TRUNCATE TABLE #Loan_Due_Amount;
        TRUNCATE TABLE #DA_Allowance;
        TRUNCATE TABLE #OT_Gradewise;
        TRUNCATE TABLE #EFFICIENCY_SALARY;
        
        SET @intFlag_monthly = @intFlag_monthly + 1
IF @intFlag_monthly > @Count_emp_monthly + 1
            BREAK;
            
    END --End of Loop

	IF OBJECT_ID('tempdb..##Att_Muster1') IS NOT NULL
		DROP TABLE ##Att_Muster1;

RETURN    




