CREATE TABLE [dbo].[T0040_GENERAL_SETTING] (
    [Gen_ID]                                   NUMERIC (18)    CONSTRAINT [DF_T0040_GENERAL_SETTING_Gen_ID] DEFAULT ((0)) NOT NULL,
    [Cmp_ID]                                   NUMERIC (18)    NOT NULL,
    [Branch_ID]                                NUMERIC (18)    NOT NULL,
    [For_Date]                                 DATETIME        NOT NULL,
    [Inc_Weekoff]                              NUMERIC (1)     NOT NULL,
    [Is_OT]                                    NUMERIC (1)     NOT NULL,
    [ExOT_Setting]                             NUMERIC (18, 2) NOT NULL,
    [Late_Limit]                               VARCHAR (50)    NOT NULL,
    [Late_Adj_Day]                             NUMERIC (18)    NOT NULL,
    [Is_PT]                                    NUMERIC (1)     NOT NULL,
    [Is_LWF]                                   NUMERIC (1)     NOT NULL,
    [Is_Revenue]                               NUMERIC (1)     NOT NULL,
    [Is_PF]                                    NUMERIC (1)     NOT NULL,
    [Is_ESIC]                                  NUMERIC (1)     NOT NULL,
    [Is_Late_Mark]                             NUMERIC (1)     NOT NULL,
    [Is_Credit]                                NUMERIC (1)     NOT NULL,
    [LWF_Amount]                               NUMERIC (18)    NOT NULL,
    [LWF_Month]                                VARCHAR (30)    NOT NULL,
    [Revenue_Amount]                           NUMERIC (18)    NOT NULL,
    [Revenue_On_Amount]                        NUMERIC (18)    NOT NULL,
    [Credit_Limit]                             NUMERIC (18)    NOT NULL,
    [Chk_Server_Date]                          NUMERIC (1)     NOT NULL,
    [Is_Cancel_Weekoff]                        NUMERIC (1)     NOT NULL,
    [Is_Cancel_Holiday]                        NUMERIC (1)     NOT NULL,
    [Is_Daily_OT]                              NUMERIC (1)     NOT NULL,
    [In_Punch_Duration]                        VARCHAR (10)    NOT NULL,
    [Last_Entry_Duration]                      VARCHAR (10)    NOT NULL,
    [OT_App_Limit]                             VARCHAR (10)    NOT NULL,
    [OT_Max_Limit]                             VARCHAR (10)    NOT NULL,
    [OT_Fix_Work_Day]                          NUMERIC (18)    NOT NULL,
    [OT_Fix_Shift_Hours]                       VARCHAR (10)    NOT NULL,
    [OT_Inc_Salary]                            NUMERIC (1)     NOT NULL,
    [ESIC_Upper_Limit]                         NUMERIC (18)    NULL,
    [ESIC_Employer_Contribution]               NUMERIC (18, 2) NULL,
    [Skip_out]                                 NUMERIC (18)    CONSTRAINT [DF_T0040_GENERAL_SETTING_Skip_out] DEFAULT ((0)) NULL,
    [Lv_Encash_W_Day]                          NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Lv_Encash_Day_Rate] DEFAULT ((0)) NULL,
    [Lv_Salary_Effect_on_PT]                   TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Lv_Salary_Effect_on_PT] DEFAULT ((0)) NULL,
    [Late_Fix_Work_Days]                       NUMERIC (5, 1)  CONSTRAINT [DF_T0040_GENERAL_SETTING_Fix_Late_W_Days] DEFAULT ((0)) NULL,
    [Late_Fix_Shift_Hours]                     VARCHAR (50)    CONSTRAINT [DF_T0040_GENERAL_SETTING_Fix_Late_W_Hours] DEFAULT ('') NULL,
    [Late_Deduction_Days]                      NUMERIC (3, 2)  CONSTRAINT [DF_T0040_GENERAL_SETTING_Late_Deduction_Days] DEFAULT ((0)) NULL,
    [Late_Extra_Deduction]                     NUMERIC (3, 2)  CONSTRAINT [DF_T0040_GENERAL_SETTING_Extra_Late_Deduction] DEFAULT ((0)) NULL,
    [Is_Late_Calc_On_HO_WO]                    TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Is_Late_Calc_On_HO_WO] DEFAULT ((0)) NULL,
    [Is_Late_CF]                               TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Is_Late_CF] DEFAULT ((0)) NULL,
    [Late_CF_Reset_On]                         VARCHAR (50)    CONSTRAINT [DF_T0040_GENERAL_SETTING_Late_CF_Reset_On] DEFAULT ('') NULL,
    [Inout_days]                               NUMERIC (5, 1)  CONSTRAINT [DF_T0040_GENERAL_SETTING_Inout_days] DEFAULT ((0)) NULL,
    [Sal_St_Date]                              DATETIME        NULL,
    [Sal_Fix_Days]                             NUMERIC (5, 1)  CONSTRAINT [DF_T0040_GENERAL_SETTING_Sal_Fix_Days] DEFAULT ((0)) NULL,
    [Is_Inout_Sal]                             NUMERIC (1)     CONSTRAINT [DF_T0040_GENERAL_SETTING_is_Inout_Sal] DEFAULT ((0)) NULL,
    [Gr_Min_Year]                              TINYINT         NULL,
    [Gr_Cal_Month]                             TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Gr_Cal_Month] DEFAULT ((0)) NULL,
    [Gr_ProRata_Cal]                           TINYINT         NULL,
    [Gr_Min_P_Days]                            NUMERIC (5)     NULL,
    [Gr_Absent_Days]                           NUMERIC (5)     NULL,
    [Short_Fall_Days]                          NUMERIC (5, 1)  CONSTRAINT [DF_T0040_GENERAL_SETTING_Short_Fall_Days] DEFAULT ((0)) NULL,
    [Gr_Days]                                  NUMERIC (5, 1)  CONSTRAINT [DF_T0040_GENERAL_SETTING_Gr_Days] DEFAULT ((0)) NULL,
    [Gr_Percentage]                            NUMERIC (5, 2)  CONSTRAINT [DF_T0040_GENERAL_SETTING_Gr_Percentage] DEFAULT ((0)) NULL,
    [Short_Fall_W_Days]                        NUMERIC (5, 1)  CONSTRAINT [DF_T0040_GENERAL_SETTING_Short_Fall_W_Days] DEFAULT ((0)) NULL,
    [Bonus_Last_Paid_Date]                     DATETIME        NULL,
    [Is_Gr_Yearly_Paid]                        TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Is_Gr_Yearly_Paid] DEFAULT ((0)) NULL,
    [Leave_SMS]                                NUMERIC (1)     NULL,
    [CTC_Auto_Cal]                             NUMERIC (1)     NULL,
    [Inc_Holiday]                              NUMERIC (1)     NULL,
    [Probation]                                NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Probation] DEFAULT ((0)) NULL,
    [Lv_Month]                                 NUMERIC (2)     CONSTRAINT [DF_T0040_GENERAL_SETTING_Lv_Month] DEFAULT ((0)) NOT NULL,
    [Is_Shortfall_Gradewise]                   TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Is_Shortfall_Gradewise] DEFAULT ((0)) NOT NULL,
    [Actual_Gross]                             NUMERIC (18, 2) NULL,
    [Wages_Amount]                             NUMERIC (18, 2) NULL,
    [Dep_Reim_Days]                            NUMERIC (18)    CONSTRAINT [DF_T0040_GENERAL_SETTING_Dep_Reim_Days] DEFAULT ((0)) NOT NULL,
    [Con_Reim_Days]                            NUMERIC (18)    CONSTRAINT [DF_T0040_GENERAL_SETTING_Con_Reim_Days] DEFAULT ((0)) NOT NULL,
    [Late_With_Leave]                          NUMERIC (1)     NULL,
    [Late_with_Leaeve]                         NUMERIC (18)    NULL,
    [Tras_Week_ot]                             TINYINT         NULL,
    [Bonus_Min_Limit]                          NUMERIC (18)    NULL,
    [Bonus_Max_Limit]                          NUMERIC (18)    NULL,
    [Bonus_Per]                                NUMERIC (18, 2) NULL,
    [Is_Organise_chart]                        TINYINT         NULL,
    [Is_Zero_Day_Salary]                       TINYINT         NULL,
    [Is_OT_Auto_Calc]                          TINYINT         CONSTRAINT [DF_T0040_General_Setting_Is_OT_Auto_Calc] DEFAULT ((0)) NULL,
    [OT_Present_Days]                          TINYINT         CONSTRAINT [DF_T0040_General_Setting_OT_Present_Days] DEFAULT ((0)) NULL,
    [Is_Negative_Ot]                           INT             NULL,
    [Is_Present]                               NUMERIC (18, 2) NULL,
    [Is_Amount]                                NUMERIC (18, 2) NULL,
    [Mid_Increment]                            NUMERIC (18)    NULL,
    [AD_Rounding]                              NUMERIC (1)     NULL,
    [Lv_Encash_Cal_On]                         VARCHAR (50)    NULL,
    [In_Out_Login]                             INT             NULL,
    [LWF_Over_Amount]                          NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_LWF_Over_Amount] DEFAULT ((0)) NOT NULL,
    [LWF_Max_Amount]                           NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_LWF_Max_Amount] DEFAULT ((0)) NOT NULL,
    [First_In_Last_Out_For_Att_Regularization] TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_First_In_Last_Out_For_Att_Regularization] DEFAULT ((0)) NULL,
    [First_In_Last_Out_For_InOut_Calculation]  TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_First_In_Last_Out_For_InOut_Calculation] DEFAULT ((0)) NULL,
    [Late_Count_Exemption]                     NUMERIC (18, 2) CONSTRAINT [DF__T0040_GEN__Late___10174366] DEFAULT ((0)) NULL,
    [Early_Limit]                              VARCHAR (50)    NULL,
    [Early_Adj_Day]                            NUMERIC (18)    NULL,
    [Early_Deduction_Days]                     NUMERIC (3, 2)  CONSTRAINT [DF_T0040_GENERAL_SETTING_Early_Deduction_Days] DEFAULT ((0)) NULL,
    [Early_Extra_Deduction]                    NUMERIC (3, 2)  CONSTRAINT [DF_T0040_GENERAL_SETTING_Early_Extra_Deduction] DEFAULT ((0)) NULL,
    [Early_CF_Reset_On]                        VARCHAR (50)    CONSTRAINT [DF__T0040_GEN__Early__110B679F] DEFAULT ('') NULL,
    [Is_Early_Calc_On_HO_WO]                   TINYINT         CONSTRAINT [DF__T0040_GEN__Is_Ea__11FF8BD8] DEFAULT ((0)) NULL,
    [Is_Early_CF]                              TINYINT         CONSTRAINT [DF__T0040_GEN__Is_Ea__12F3B011] DEFAULT ((0)) NULL,
    [Early_With_Leave]                         NUMERIC (1)     CONSTRAINT [DF__T0040_GEN__Early__13E7D44A] DEFAULT ((0)) NULL,
    [Early_Count_Exemption]                    NUMERIC (18, 2) CONSTRAINT [DF__T0040_GEN__Early__14DBF883] DEFAULT ((0)) NULL,
    [Deficit_Limit]                            VARCHAR (50)    NULL,
    [Deficit_Adj_Day]                          NUMERIC (18)    NULL,
    [Deficit_Deduction_Days]                   NUMERIC (3, 1)  CONSTRAINT [DF_T0040_GENERAL_SETTING_Deficit_Deduction_Days] DEFAULT ((0)) NULL,
    [Deficit_Extra_Deduction]                  NUMERIC (3, 1)  CONSTRAINT [DF_T0040_GENERAL_SETTING_Deficit_Extra_Deduction] DEFAULT ((0)) NULL,
    [Deficit_CF_Reset_On]                      VARCHAR (50)    CONSTRAINT [DF__T0040_GEN__Defic__15D01CBC] DEFAULT ('') NULL,
    [Is_Deficit_Calc_On_HO_WO]                 TINYINT         CONSTRAINT [DF__T0040_GEN__Is_De__16C440F5] DEFAULT ((0)) NULL,
    [Is_Deficit_CF]                            TINYINT         CONSTRAINT [DF__T0040_GEN__Is_De__17B8652E] DEFAULT ((0)) NULL,
    [Deficit_With_Leave]                       NUMERIC (1)     CONSTRAINT [DF__T0040_GEN__Defic__18AC8967] DEFAULT ((0)) NULL,
    [Deficit_Count_Exemption]                  NUMERIC (18, 2) CONSTRAINT [DF__T0040_GEN__Defic__19A0ADA0] DEFAULT ((0)) NULL,
    [In_Out_Login_Popup]                       TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_In_Out_Login_Popup] DEFAULT ((0)) NULL,
    [Is_Zero_Basic_Salary]                     TINYINT         NULL,
    [Late_Hour_Upper_Rounding]                 NUMERIC (18, 2) CONSTRAINT [DF__T0040_GEN__Late___0C9BB83D] DEFAULT ((0)) NOT NULL,
    [is_Late_Calc_Slabwise]                    TINYINT         CONSTRAINT [DF__T0040_GEN__is_La__0D8FDC76] DEFAULT ((0)) NOT NULL,
    [Late_Calculate_type]                      NVARCHAR (10)   CONSTRAINT [DF__T0040_GEN__Late___0E8400AF] DEFAULT ('Hour') NULL,
    [Early_Hour_Upper_Rounding]                NUMERIC (18, 2) CONSTRAINT [DF__T0040_GEN__Early__0F7824E8] DEFAULT ((0)) NOT NULL,
    [is_Early_Calc_Slabwise]                   TINYINT         CONSTRAINT [DF__T0040_GEN__is_Ea__106C4921] DEFAULT ((0)) NOT NULL,
    [Early_Calculate_type]                     NVARCHAR (10)   CONSTRAINT [DF__T0040_GEN__Early__11606D5A] DEFAULT ('Hour') NULL,
    [late_exemption_limit]                     VARCHAR (20)    CONSTRAINT [DF_T0040_GENERAL_SETTING_late_exemption_limit] DEFAULT ('00:00') NULL,
    [early_exemption_limit]                    VARCHAR (20)    CONSTRAINT [DF_T0040_GENERAL_SETTING_early_exemption_limit] DEFAULT ('00:00') NOT NULL,
    [Is_PreQuestion]                           TINYINT         NULL,
    [Is_CompOff]                               TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Is_CompOff] DEFAULT ((0)) NOT NULL,
    [CompOff_Days_Limit]                       NUMERIC (18)    CONSTRAINT [DF_T0040_GENERAL_SETTING_CompOff_Days_Limit] DEFAULT ((1)) NOT NULL,
    [CompOff_Min_Hours]                        VARCHAR (10)    CONSTRAINT [DF_T0040_GENERAL_SETTING_CompOff_Min_Hours] DEFAULT ('00:00') NOT NULL,
    [Is_CompOff_WD]                            TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Is_CompOff_WD] DEFAULT ((1)) NOT NULL,
    [Is_CompOff_WOHO]                          TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Is_CompOff_WOHO] DEFAULT ((1)) NOT NULL,
    [Is_CF_On_Sal_Days]                        TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Is_CF_On_Sal_Days] DEFAULT ((0)) NULL,
    [Days_As_Per_Sal_Days]                     TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Days_As_Per_Sal_Days] DEFAULT ((0)) NULL,
    [Max_Late_Limit]                           VARCHAR (50)    CONSTRAINT [DF_T0040_GENERAL_SETTING_Max_Late_Limit] DEFAULT ('00:00') NULL,
    [Max_Early_Limit]                          VARCHAR (50)    CONSTRAINT [DF_T0040_GENERAL_SETTING_Max_Early_Limit] DEFAULT ('00:00') NULL,
    [Manual_Inout]                             INT             CONSTRAINT [DF_T0040_GENERAL_SETTING_Manual_Inout] DEFAULT ((0)) NOT NULL,
    [Allow_Negative_Salary]                    TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Allow_Negative_Salary] DEFAULT ((0)) NOT NULL,
    [Effect_ot_amount]                         TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Effect_ot_amount] DEFAULT ((0)) NOT NULL,
    [CompOff_Avail_Days]                       NUMERIC (18)    CONSTRAINT [DF_T0040_GENERAL_SETTING_CompOff_Avail_Days] DEFAULT ((0)) NOT NULL,
    [Paid_WeekOff_Daily_Wages]                 TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Paid_WeekOff_Daily_Wages] DEFAULT ((0)) NOT NULL,
    [Allowed_Full_WeekOf_MidJoining]           TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Allowed_Full_WeekOf_MidJoining] DEFAULT ((0)) NOT NULL,
    [is_weekoff_hour]                          TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_is_weekoff_hour] DEFAULT ((0)) NOT NULL,
    [weekoff_hours]                            NVARCHAR (50)   NULL,
    [is_all_emp_prob]                          TINYINT         DEFAULT ((0)) NOT NULL,
    [Manual_Salary_Period]                     INT             CONSTRAINT [DF_T0040_GENERAL_SETTING_Manual_Salary_Period] DEFAULT ((0)) NOT NULL,
    [Max_Bonus_Salary_Amount]                  NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Max_Bonus_Salary_Amount] DEFAULT ((0)) NOT NULL,
    [Optional_Holiday_Days]                    NUMERIC (10)    NULL,
    [Is_OD_Transfer_to_OT]                     TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Is_OD_Transfer_to_OT] DEFAULT ((0)) NOT NULL,
    [Is_Co_hour_Editable]                      TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Is_Co_hour_Editable] DEFAULT ((0)) NOT NULL,
    [Attendance_SMS]                           NUMERIC (1)     CONSTRAINT [DF_T0040_GENERAL_SETTING_Attendance_SMS] DEFAULT ((0)) NULL,
    [Bonus_Entitle_Limit]                      NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Bonus_Entitle_Limit] DEFAULT ((0)) NOT NULL,
    [Allowed_Full_WeekOf_MidJoining_DayRate]   TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Allowed_Full_WeekOf_MidJoining_DayRate] DEFAULT ((0)) NOT NULL,
    [Monthly_Deficit_Adjust_OT_Hrs]            TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Monthly_Deficit_Adjust_OT_Hours] DEFAULT ((0)) NOT NULL,
    [Half_day_Excepted_count]                  NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Half_day_Excepted_count] DEFAULT ((0)) NOT NULL,
    [Half_Day_Excepted_Max_Count]              NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Half_Day_Excepted_Max_Count] DEFAULT ((0)) NOT NULL,
    [Net_Salary_Round]                         NUMERIC (18)    CONSTRAINT [DF_T0040_GENERAL_SETTING_Net_Salary_Round] DEFAULT ((-1)) NOT NULL,
    [Is_HO_CompOff]                            NUMERIC (1)     CONSTRAINT [DF_T0040_GENERAL_SETTING_Is_HO_CompOff] DEFAULT ((0)) NOT NULL,
    [H_CompOff_Days_Limit]                     NUMERIC (18)    CONSTRAINT [DF_T0040_GENERAL_SETTING_H_CompOff_Days_Limit] DEFAULT ((0)) NOT NULL,
    [H_CompOff_Min_Hours]                      NVARCHAR (10)   CONSTRAINT [DF_T0040_GENERAL_SETTING_H_CompOff_Min_Hours] DEFAULT (N'00:00') NOT NULL,
    [H_CompOff_Avail_Days]                     NUMERIC (18)    CONSTRAINT [DF_T0040_GENERAL_SETTING_H_CompOff_Avail_Days] DEFAULT ((0)) NOT NULL,
    [Is_W_CompOff]                             NUMERIC (1)     CONSTRAINT [DF_T0040_GENERAL_SETTING_Is_W_CompOff] DEFAULT ((0)) NOT NULL,
    [W_CompOff_Days_Limit]                     NUMERIC (18)    CONSTRAINT [DF_T0040_GENERAL_SETTING_W_CompOff_Days_Limit] DEFAULT ((0)) NOT NULL,
    [W_CompOff_Min_Hours]                      NVARCHAR (10)   CONSTRAINT [DF_T0040_GENERAL_SETTING_W_CompOff_Min_Hours] DEFAULT (N'00:00') NOT NULL,
    [W_CompOff_Avail_Days]                     NUMERIC (18)    CONSTRAINT [DF_T0040_GENERAL_SETTING_W_CompOff_Avail_Days] DEFAULT ((0)) NOT NULL,
    [AllowShowODOptInCompOff]                  NUMERIC (18)    CONSTRAINT [DF_T0040_GENERAL_SETTING_AllowShowODOptInCompOff] DEFAULT ((0)) NOT NULL,
    [Is_H_Co_hour_Editable]                    NUMERIC (18)    CONSTRAINT [DF_T0040_GENERAL_SETTING_Is_H_Co_hour_Editable] DEFAULT ((0)) NOT NULL,
    [Is_W_Co_hour_Editable]                    NUMERIC (18)    CONSTRAINT [DF_T0040_GENERAL_SETTING_Is_W_Co_hour_Editable] DEFAULT ((0)) NOT NULL,
    [Type_Net_Salary_Round]                    NVARCHAR (50)   NULL,
    [Day_For_Security_Deposit]                 NUMERIC (3)     NULL,
    [OT_RoundingOff_To]                        NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_OT_RoundingOff_To] DEFAULT ((0.00)) NOT NULL,
    [OT_RoundingOff_Lower]                     NUMERIC (1)     CONSTRAINT [DF_T0040_GENERAL_SETTING_OT_RoundingOff_Lower] DEFAULT ((0)) NOT NULL,
    [MinWODays]                                NUMERIC (18)    CONSTRAINT [DF_T0040_GENERAL_SETTING_MinWoDays] DEFAULT ((0)) NOT NULL,
    [MaxWODays]                                NUMERIC (18)    CONSTRAINT [DF_T0040_GENERAL_SETTING_MaxWODays] DEFAULT ((0)) NOT NULL,
    [Chk_otLimit_before_after_Shift_time]      TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Chk_otLimit_before_after_Shift_time] DEFAULT ((0)) NOT NULL,
    [chk_Lv_On_Working]                        TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_chk_Lv_On_Working] DEFAULT ((0)) NOT NULL,
    [Cutoffdate_Salary]                        DATETIME        NULL,
    [Attndnc_Reg_Max_Cnt]                      NUMERIC (18)    DEFAULT ((0)) NULL,
    [Is_WD_OD]                                 TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Is_WD_OD] DEFAULT ((1)) NOT NULL,
    [Is_WO_OD]                                 TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Is_WO_OD] DEFAULT ((1)) NOT NULL,
    [Is_HO_OD]                                 TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Is_HO_OD] DEFAULT ((1)) NOT NULL,
    [DayRate_WO_Cancel]                        TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_DayRate_WO_Cancel] DEFAULT ((0)) NOT NULL,
    [Training_Month]                           NUMERIC (18, 2) DEFAULT ((0)) NULL,
    [Dep_Reim_Days_Traning]                    NUMERIC (2)     DEFAULT ((0)) NOT NULL,
    [Fnf_Fix_Day]                              NUMERIC (18)    DEFAULT ((0)) NOT NULL,
    [Is_Cancel_Holiday_WO_HO_same_day]         NUMERIC (5)     DEFAULT ((0)) NOT NULL,
    [LateEarly_Exemption_MaxLimit]             VARCHAR (20)    CONSTRAINT [DF_T0040_GENERAL_SETTING_LateEarly_Exemption_MaxLimit] DEFAULT ('00:00') NULL,
    [LateEarly_Exemption_Count]                NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_LateEarly_Exemption_Count] DEFAULT ((0)) NULL,
    [Restrict_Present_days]                    CHAR (1)        DEFAULT ('Y') NOT NULL,
    [Emp_WeekDay_OT_Rate]                      NUMERIC (10, 3) DEFAULT ((0)) NOT NULL,
    [Emp_WeekOff_OT_Rate]                      NUMERIC (10, 3) DEFAULT ((0)) NOT NULL,
    [Emp_Holiday_OT_Rate]                      NUMERIC (10, 3) DEFAULT ((0)) NOT NULL,
    [Full_PF]                                  NUMERIC (1)     DEFAULT ((0)) NOT NULL,
    [Company_Full_PF]                          NUMERIC (1)     DEFAULT ((0)) NOT NULL,
    [is_present_on_holiday]                    TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_is_present_on_holiday] DEFAULT ((0)) NOT NULL,
    [Rate_Of_National_Holiday]                 NUMERIC (5, 2)  CONSTRAINT [DF_T0040_GENERAL_SETTING_Rate_Of_National_Holiday] DEFAULT ((0)) NULL,
    [Late_Adj_Again_OT]                        NUMERIC (2)     DEFAULT ((0)) NOT NULL,
    [Late_Mark_Scenario]                       NUMERIC (2)     DEFAULT ((1)) NOT NULL,
    [Allowed_Full_WeekOf_MidLeft]              TINYINT         DEFAULT ((0)) NOT NULL,
    [Allowed_Full_WeekOf_MidLeft_DayRate]      TINYINT         DEFAULT ((0)) NOT NULL,
    [Audit_Daily_OT_limit]                     NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Audit_Daily_OT_limit] DEFAULT ((0)) NOT NULL,
    [Audit_Daily_Exemption_OT_limit]           NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Audit_Daily_Exemption_OT_limit] DEFAULT ((0)) NOT NULL,
    [Audit_Daily_Final_OT_limit]               NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Audit_Daily_Final_OT_limit] DEFAULT ((0)) NOT NULL,
    [Audit_Weekly_OT_limit]                    NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Audit_Weekly_OT_limit] DEFAULT ((0)) NOT NULL,
    [Audit_Weekly_Exemption_OT_limit]          NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Audit_Weekly_Exemption_OT_limit] DEFAULT ((0)) NOT NULL,
    [Audit_Weekly_Final_OT_limit]              NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Audit_Weekly_Final_OT_limit] DEFAULT ((0)) NOT NULL,
    [Audit_Monthly_OT_limit]                   NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Audit_Monthly_OT_limit] DEFAULT ((0)) NOT NULL,
    [Audit_Monthly_Exemption_OT_limit]         NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Audit_Monthly_Exemption_OT_limit] DEFAULT ((0)) NOT NULL,
    [Audit_Monthly_Final_OT_limit]             NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Audit_Monthly_Final_OT_limit] DEFAULT ((0)) NOT NULL,
    [Audit_Quarterly_OT_limit]                 NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Audit_Quarterly_OT_limit] DEFAULT ((0)) NOT NULL,
    [Audit_Quarterly_Exemption_OT_limit]       NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Audit_Quarterly_Exemption_OT_limit] DEFAULT ((0)) NOT NULL,
    [Audit_Quarterly_Final_OT_limit]           NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Audit_Quarterly_Final_OT_limit] DEFAULT ((0)) NOT NULL,
    [Validity_Period_Type]                     TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Validity_Period_Type] DEFAULT ((0)) NOT NULL,
    [Is_Customer_Audit]                        TINYINT         CONSTRAINT [DF_T0040_GENERAL_SETTING_Is_Customer_Audit] DEFAULT ((0)) NOT NULL,
    [Is_Bonus_Inc]                             TINYINT         NULL,
    [Is_Regular_Bon]                           TINYINT         NULL,
    [Traning]                                  NUMERIC (2)     DEFAULT ((0)) NOT NULL,
    [COPH_Avail_limit]                         NUMERIC (18)    DEFAULT ((0)) NOT NULL,
    [COND_avail_limit]                         NUMERIC (18)    DEFAULT ((0)) NOT NULL,
    [Is_Latemark_Percentage]                   NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [Is_Latemark_Cal_On]                       NUMERIC (1)     DEFAULT ((0)) NOT NULL,
    [Probation_Review]                         VARCHAR (15)    DEFAULT ('') NOT NULL,
    [Trainee_Review]                           VARCHAR (15)    DEFAULT ('') NOT NULL,
    [Late_Limit_Regularization]                VARCHAR (50)    CONSTRAINT [DF_T0040_GENERAL_SETTING_Late_Limit_Regularization] DEFAULT ('0') NOT NULL,
    [Show_PT_in_Payslip_if_Zero]               TINYINT         DEFAULT ((0)) NOT NULL,
    [Show_LWF_in_Payslip_if_Zero]              TINYINT         DEFAULT ((0)) NOT NULL,
    [OTRateType]                               TINYINT         DEFAULT ((0)) NOT NULL,
    [OTSlabType]                               TINYINT         DEFAULT ((0)) NOT NULL,
    [Is_Chk_Late_Early_Mark]                   TINYINT         DEFAULT ((0)) NOT NULL,
    [Chk_Last_Late_Early_Month]                TINYINT         DEFAULT ((0)) NOT NULL,
    [Global_Salary_Days]                       NUMERIC (18, 2) CONSTRAINT [DF_T0040_GENERAL_SETTING_Global_Salary_Days] DEFAULT ((0)) NOT NULL,
    [Is_OT_Adj_against_Absent]                 BIT             DEFAULT ((0)) NOT NULL,
    [Is_Probation_Month_Days]                  TINYINT         DEFAULT ((0)) NOT NULL,
    [Is_Trainee_Month_Days]                    TINYINT         DEFAULT ((0)) NOT NULL,
    [Early_Mark_Scenario]                      TINYINT         DEFAULT ((1)) NOT NULL,
    [Is_Earlymark_Percentage]                  TINYINT         DEFAULT ((0)) NOT NULL,
    [Is_EarlyMark_Cal_On]                      TINYINT         DEFAULT ((0)) NOT NULL,
    [Holiday_CompOff_Avail_After_Days]         NUMERIC (18)    DEFAULT ((0)) NULL,
    [WeekOff_CompOff_Avail_After_Days]         NUMERIC (18)    DEFAULT ((0)) NULL,
    [WeekDay_CompOff_Avail_After_Days]         NUMERIC (18)    DEFAULT ((0)) NULL,
    [Attendance_Reg_Weekday]                   NVARCHAR (50)   DEFAULT ('-') NOT NULL,
    [Approval_Up_To_Date]                      TINYINT         DEFAULT ((0)) NOT NULL,
    [LateEarly_Combine]                        TINYINT         DEFAULT ((0)) NULL,
    [Monthly_Exemption_Limit]                  VARCHAR (20)    NULL,
    [Is_Cancel_Holiday_IfOneSideAbsent]        INT             NULL,
    [Is_Cancel_Weekoff_IfOneSideAbsent]        INT             NULL,
    [Daily_Monthly]                            TINYINT         NULL,
    [LateEarly_MonthWise]                      TINYINT         NULL,
    [IsDeficit]                                BIT             NULL,
    CONSTRAINT [PK_T0040_GENERAL_SETTING] PRIMARY KEY CLUSTERED ([Gen_ID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_T0040_GENERAL_SETTING]
    ON [dbo].[T0040_GENERAL_SETTING]([Gen_ID] ASC, [Branch_ID] ASC, [Cmp_ID] ASC, [For_Date] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0040_GENERAL_SETTING_26_274868096__K3_K63]
    ON [dbo].[T0040_GENERAL_SETTING]([Branch_ID] ASC, [Probation] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0040_GENERAL_SETTING_26_274868096__K2_K3_K86_K1_110]
    ON [dbo].[T0040_GENERAL_SETTING]([Cmp_ID] ASC, [Branch_ID] ASC, [In_Out_Login] ASC, [Gen_ID] ASC)
    INCLUDE([In_Out_Login_Popup]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_T0040_GENERAL_SETTING_C_F]
    ON [dbo].[T0040_GENERAL_SETTING]([Cmp_ID] ASC, [For_Date] ASC)
    INCLUDE([Sal_St_Date]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0040_GENERAL_SETTING_10_274868096__K3_K2_K4_K1_33_132_168]
    ON [dbo].[T0040_GENERAL_SETTING]([Branch_ID] ASC, [Cmp_ID] ASC, [For_Date] ASC, [Gen_ID] ASC)
    INCLUDE([ESIC_Upper_Limit], [Effect_ot_amount], [Day_For_Security_Deposit]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_T0040_GENERAL_SETTING_For_SP_Mobile_HRMS_WebService_AttendanceRegularization]
    ON [dbo].[T0040_GENERAL_SETTING]([Cmp_ID] ASC, [For_Date] ASC)
    INCLUDE([Sal_St_Date], [Tras_Week_ot], [Manual_Salary_Period], [Is_Cancel_Holiday_WO_HO_same_day]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_T0040_GENERAL_SETTING_For_SP_CALCULATE_PRESENT_DAYS]
    ON [dbo].[T0040_GENERAL_SETTING]([For_Date] ASC)
    INCLUDE([Branch_ID], [Is_OT], [First_In_Last_Out_For_InOut_Calculation], [Chk_otLimit_before_after_Shift_time]);


GO
CREATE STATISTICS [_dta_stat_274868096_1_86]
    ON [dbo].[T0040_GENERAL_SETTING]([Gen_ID], [In_Out_Login]);


GO
CREATE STATISTICS [_dta_stat_274868096_1_2_3_86]
    ON [dbo].[T0040_GENERAL_SETTING]([Gen_ID], [Cmp_ID], [Branch_ID], [In_Out_Login]);


GO
CREATE STATISTICS [_dta_stat_274868096_4_3_2]
    ON [dbo].[T0040_GENERAL_SETTING]([For_Date], [Branch_ID], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_274868096_2_1_4]
    ON [dbo].[T0040_GENERAL_SETTING]([Cmp_ID], [Gen_ID], [For_Date]);

