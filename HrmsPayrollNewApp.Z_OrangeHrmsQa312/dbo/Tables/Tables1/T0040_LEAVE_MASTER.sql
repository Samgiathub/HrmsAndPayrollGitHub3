CREATE TABLE [dbo].[T0040_LEAVE_MASTER] (
    [Leave_ID]                                NUMERIC (18)    NOT NULL,
    [Cmp_ID]                                  NUMERIC (18)    NOT NULL,
    [Leave_Code]                              VARCHAR (5)     NOT NULL,
    [Leave_Name]                              VARCHAR (50)    NOT NULL,
    [Leave_Type]                              VARCHAR (50)    NOT NULL,
    [Leave_Count]                             NUMERIC (18)    NOT NULL,
    [Leave_Paid_Unpaid]                       CHAR (1)        NOT NULL,
    [Leave_Min]                               NUMERIC (18, 2) NOT NULL,
    [Leave_Max]                               NUMERIC (18, 2) NOT NULL,
    [Leave_Min_Bal]                           NUMERIC (18, 1) NOT NULL,
    [Leave_Max_Bal]                           NUMERIC (18, 1) NOT NULL,
    [Leave_Min_Encash]                        NUMERIC (18, 1) NOT NULL,
    [Leave_Max_Encash]                        NUMERIC (18, 1) NOT NULL,
    [Leave_Notice_Period]                     NUMERIC (18)    NOT NULL,
    [Leave_Applicable]                        NUMERIC (18)    NOT NULL,
    [Leave_CF_Type]                           VARCHAR (50)    NOT NULL,
    [Leave_PDays]                             NUMERIC (18, 2) NOT NULL,
    [Leave_Get_Against_PDays]                 NUMERIC (18, 5) NOT NULL,
    [Leave_Auto_Generation]                   CHAR (1)        NOT NULL,
    [Leave_Status]                            NUMERIC (18)    NULL,
    [Leave_CF_Month]                          NUMERIC (18)    CONSTRAINT [DF_T0040_LEAVE_MASTER_Leave_CF_Month] DEFAULT ((0)) NULL,
    [Leave_Precision]                         NUMERIC (5, 1)  CONSTRAINT [DF_T0040_LEAVE_MASTER_Leave_Precision] DEFAULT ((0)) NULL,
    [Leave_Def_ID]                            NUMERIC (2)     CONSTRAINT [DF_T0040_LEAVE_MASTER_Leave_Def_ID] DEFAULT ((0)) NULL,
    [Is_Late_Adj]                             TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_Is_Late_Adj] DEFAULT ((0)) NULL,
    [Leave_Bal_Reset_Month]                   TINYINT         NULL,
    [Leave_Negative_Allow]                    TINYINT         NULL,
    [Salary_on_Leave]                         TINYINT         NULL,
    [Is_Ho_Wo]                                TINYINT         NULL,
    [Weekoff_as_leave]                        TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_Weekoff_as_leave] DEFAULT ((0)) NOT NULL,
    [Holiday_as_leave]                        TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_Holiday_as_leave] DEFAULT ((0)) NOT NULL,
    [Leave_Sorting_No]                        NUMERIC (18)    CONSTRAINT [DF_T0040_LEAVE_MASTER_Leave_Sorting_No] DEFAULT ((0)) NOT NULL,
    [No_Days_To_Cancel_WOHO]                  NUMERIC (18, 2) CONSTRAINT [DF_T0040_LEAVE_MASTER_No_Days_To_Cancel_WOHO] DEFAULT ((0)) NOT NULL,
    [Is_Leave_CF_Rounding]                    TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_Is_Leave_CF_Rounding] DEFAULT ((0)) NOT NULL,
    [Is_Leave_CF_Prorata]                     TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_Is_Leave_CF_Prorata] DEFAULT ((0)) NOT NULL,
    [Display_leave_balance]                   TINYINT         CONSTRAINT [DF__T0040_LEA__Displ__031D3AFB] DEFAULT ((1)) NOT NULL,
    [Is_Leave_Clubbed]                        TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_Is_Leave_Clubbed] DEFAULT ((1)) NOT NULL,
    [Can_Apply_Fraction]                      TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_Can_Apply_Fraction] DEFAULT ((1)) NOT NULL,
    [Is_CF_On_Sal_Days]                       TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_Is_CF_On_Sal_Days] DEFAULT ((0)) NULL,
    [Days_As_Per_Sal_Days]                    TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_Days_As_Per_Sal_Days] DEFAULT ((0)) NULL,
    [Max_Accumulate_Balance]                  NUMERIC (18, 2) CONSTRAINT [DF_T0040_LEAVE_MASTER_Max_Accumulate_Balance] DEFAULT ((0)) NULL,
    [Min_Present_Days]                        NUMERIC (18, 2) CONSTRAINT [DF_T0040_LEAVE_MASTER_Min_Present_Days] DEFAULT ((0)) NULL,
    [Default_Short_Name]                      VARCHAR (20)    NULL,
    [Max_No_Of_Application]                   NUMERIC (18)    CONSTRAINT [DF_T0040_LEAVE_MASTER_Max_No_Of_Application] DEFAULT ((0)) NOT NULL,
    [L_Enc_Percentage_Of_Current_Balance]     NUMERIC (18, 2) CONSTRAINT [DF_T0040_LEAVE_MASTER_L_Enc_Percentage_Of_Current_Balance] DEFAULT ((0)) NOT NULL,
    [Encashment_After_Months]                 NUMERIC (18, 2) CONSTRAINT [DF_T0040_LEAVE_MASTER_Encashment_After_Months] DEFAULT ((0)) NOT NULL,
    [InActive_Effective_Date]                 DATETIME        NULL,
    [leave_club_with]                         VARCHAR (500)   NULL,
    [is_Document_Required]                    TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_is_Document_Required] DEFAULT ((0)) NOT NULL,
    [Effect_Of_LTA]                           INT             NULL,
    [Apply_Hourly]                            INT             CONSTRAINT [DF_T0040_LEAVE_MASTER_Apply_Hourly] DEFAULT ((0)) NOT NULL,
    [CarryForwardHours]                       INT             CONSTRAINT [DF_T0040_LEAVE_MASTER_CarryForwardHours] DEFAULT ((0)) NOT NULL,
    [BalanceToSalary]                         INT             CONSTRAINT [DF_T0040_LEAVE_MASTER_BalanceToSalary] DEFAULT ((0)) NOT NULL,
    [AllowNightHalt]                          INT             CONSTRAINT [DF_T0040_LEAVE_MASTER_AllowNightHalt] DEFAULT ((0)) NOT NULL,
    [Attachment_Days]                         NUMERIC (18, 2) NULL,
    [Half_Paid]                               INT             CONSTRAINT [DF_T0040_LEAVE_MASTER_Half_Paid] DEFAULT ((0)) NOT NULL,
    [leave_negative_max_limit]                NUMERIC (18, 3) CONSTRAINT [DF_T0040_LEAVE_MASTER_leave_negative_max_limit] DEFAULT ((0)) NOT NULL,
    [MinPdays_Type]                           TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_MinPdays_Type] DEFAULT ((0)) NOT NULL,
    [Trans_Leave_ID]                          NUMERIC (18)    CONSTRAINT [DF_T0040_LEAVE_MASTER_Trans_Leave_ID] DEFAULT ((0)) NOT NULL,
    [Lv_Encase_Calculation_Day]               NUMERIC (18, 2) CONSTRAINT [DF_T0040_LEAVE_MASTER_Lv_Encase_Calculation_Day] DEFAULT ((0)) NOT NULL,
    [Including_Holiday]                       NUMERIC (1)     CONSTRAINT [DF_T0040_LEAVE_MASTER_Including_Holiday] DEFAULT ((0)) NOT NULL,
    [Including_WeekOff]                       NUMERIC (1)     CONSTRAINT [DF_T0040_LEAVE_MASTER_Including_WeekOff] DEFAULT ((0)) NOT NULL,
    [Including_Leave_Type]                    VARCHAR (500)   NULL,
    [Multi_Branch_ID]                         NVARCHAR (MAX)  NULL,
    [Medical_Leave]                           TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_Medical_Leave] DEFAULT ((0)) NOT NULL,
    [Leave_EncashDay_Half_Payment]            TINYINT         DEFAULT ((0)) NOT NULL,
    [Max_CF_From_Last_Yr_Balance]             NUMERIC (18, 1) DEFAULT ((0)) NOT NULL,
    [Punch_Required]                          INT             DEFAULT ((0)) NOT NULL,
    [Is_Advance_Leave_Balance]                TINYINT         DEFAULT ((0)) NOT NULL,
    [Is_InOut_Show_In_Email]                  TINYINT         DEFAULT ((0)) NOT NULL,
    [Effect_Salary_Cycle]                     TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_Effect_Salary_Cycle] DEFAULT ((0)) NOT NULL,
    [Monthly_Max_Leave]                       NUMERIC (18, 1) CONSTRAINT [DF_T0040_LEAVE_MASTER_Monthly_Max_Leave] DEFAULT ((0)) NOT NULL,
    [NoticePeriod_type]                       TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_Notice_type] DEFAULT ((0)) NOT NULL,
    [Working_Days]                            NUMERIC (18, 2) CONSTRAINT [DF_T0040_LEAVE_MASTER_Working_Days] DEFAULT ((0)) NOT NULL,
    [Consecutive_Days]                        NUMERIC (18, 2) CONSTRAINT [DF_T0040_LEAVE_MASTER_Consecutive_Days] DEFAULT ((0)) NOT NULL,
    [Min_Leave_Not_Mandatory]                 TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_Min_Leave_Not_Mandatory] DEFAULT ((0)) NOT NULL,
    [Consecutive_Club_Days]                   NUMERIC (18, 2) CONSTRAINT [DF_T0040_LEAVE_MASTER_Consecutive_Club_Days] DEFAULT ((0)) NOT NULL,
    [Working_Club_Days]                       NUMERIC (18, 2) CONSTRAINT [DF_T0040_LEAVE_MASTER_Working_Club_Days] DEFAULT ((0)) NOT NULL,
    [Gujarati_Alias]                          NVARCHAR (500)  NULL,
    [Calculate_on_Previous_Month]             TINYINT         DEFAULT ((0)) NOT NULL,
    [No_Of_Allowed_Leave_CF_Yrs]              TINYINT         DEFAULT ((0)) NOT NULL,
    [Paternity_Leave_Balance]                 NUMERIC (18, 2) CONSTRAINT [DF_T0040_LEAVE_MASTER_Paternity_Leave_Balance] DEFAULT ((0)) NOT NULL,
    [Paternity_Leave_Validity]                NUMERIC (18, 2) CONSTRAINT [DF_T0040_LEAVE_MASTER_Paternity_Leave_Validity] DEFAULT ((0)) NOT NULL,
    [Allowed_CF_Join_After_Day]               TINYINT         NULL,
    [First_Min_Bal_then_Percent_Curr_Balance] TINYINT         DEFAULT ((0)) NOT NULL,
    [Add_In_Working_Hour]                     TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_Add_In_Working_Hour] DEFAULT ((0)) NOT NULL,
    [Restrict_LeaveAfter_ExitNotice]          TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_Restrict_Leave_ExitNotice] DEFAULT ((0)) NOT NULL,
    [Leave_Paid_As_Allowance]                 TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_Leave_Paid_As_Allowance] DEFAULT ((0)) NOT NULL,
    [Not_Allow_CF_After_Joining]              TINYINT         NULL,
    [Adv_Balance_Round_off]                   VARCHAR (10)    NULL,
    [Adv_Balance_Round_off_Type]              NUMERIC (5, 2)  DEFAULT ((0)) NOT NULL,
    [Max_Leave_Lifetime]                      NUMERIC (18, 2) CONSTRAINT [DF_T0040_LEAVE_MASTER_Max_Leave_Lifetime] DEFAULT ((0)) NOT NULL,
    [Add_Alt_WO_Carry_Fwd]                    TINYINT         CONSTRAINT [DF_T0040_LEAVE_MASTER_Add_Alt_WO_Carry_Fwd] DEFAULT ((0)) NOT NULL,
    [Is_Auto_Leave_From_Salary]               TINYINT         NULL,
    [IsDoubleDeduct]                          INT             DEFAULT ((0)) NULL,
    [PunchBoth_Required]                      INT             NULL,
    [Multi_Allowance_ID]                      NVARCHAR (MAX)  NULL,
    [Count_WeekOff_Notice_Period]             TINYINT         NULL,
    [Leave_Continuity]                        TINYINT         NULL,
    CONSTRAINT [PK_T0040_LEAVE_MASTER] PRIMARY KEY CLUSTERED ([Leave_ID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0040_LEAVE_MASTER_9_1751729343__K1_4_5_7_8_9_14_15_20_37_42_50_53_55]
    ON [dbo].[T0040_LEAVE_MASTER]([Leave_ID] ASC)
    INCLUDE([Leave_Name], [Leave_Type], [Leave_Paid_Unpaid], [Leave_Min], [Leave_Max], [Leave_Notice_Period], [Leave_Applicable], [Leave_Status], [Can_Apply_Fraction], [Default_Short_Name], [Apply_Hourly], [AllowNightHalt], [Half_Paid]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0040_LEAVE_MASTER_26_1751729343__K35_K1_3_4_50]
    ON [dbo].[T0040_LEAVE_MASTER]([Display_leave_balance] ASC, [Leave_ID] ASC)
    INCLUDE([Leave_Code], [Leave_Name], [Apply_Hourly]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0040_LEAVE_MASTER_26_1751729343__K1_3_4_50]
    ON [dbo].[T0040_LEAVE_MASTER]([Leave_ID] ASC)
    INCLUDE([Leave_Code], [Leave_Name], [Apply_Hourly]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_Leave_Master_Cmp_Id]
    ON [dbo].[T0040_LEAVE_MASTER]([Cmp_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [ix_T0040_LEAVE_MASTER_Apply_Hourly]
    ON [dbo].[T0040_LEAVE_MASTER]([Apply_Hourly] ASC)
    INCLUDE([Cmp_ID]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [ix_T0040_LEAVE_MASTER_Leave_Paid_Unpaid_Apply_Hourly]
    ON [dbo].[T0040_LEAVE_MASTER]([Leave_Paid_Unpaid] ASC, [Apply_Hourly] ASC)
    INCLUDE([Leave_Name], [Leave_Status], [Default_Short_Name], [InActive_Effective_Date]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [ix_T0040_LEAVE_MASTER_Leave_Type]
    ON [dbo].[T0040_LEAVE_MASTER]([Leave_Type] ASC)
    INCLUDE([Leave_Name], [InActive_Effective_Date]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [ix_T0040_LEAVE_MASTER_Leave_Type1]
    ON [dbo].[T0040_LEAVE_MASTER]([Leave_Type] ASC)
    INCLUDE([Leave_Code], [Default_Short_Name]) WITH (FILLFACTOR = 90);


GO
CREATE STATISTICS [_dta_stat_1751729343_1_4]
    ON [dbo].[T0040_LEAVE_MASTER]([Leave_ID], [Leave_Name]);

