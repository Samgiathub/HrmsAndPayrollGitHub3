CREATE TABLE [dbo].[T0050_AD_MASTER] (
    [AD_ID]                             NUMERIC (18)    NOT NULL,
    [CMP_ID]                            NUMERIC (18)    NOT NULL,
    [AD_NAME]                           VARCHAR (50)    NOT NULL,
    [AD_SORT_NAME]                      VARCHAR (10)    NOT NULL,
    [AD_LEVEL]                          NUMERIC (18)    NOT NULL,
    [AD_FLAG]                           CHAR (1)        NOT NULL,
    [AD_CALCULATE_ON]                   VARCHAR (30)    NOT NULL,
    [AD_MODE]                           VARCHAR (10)    NOT NULL,
    [AD_PERCENTAGE]                     NUMERIC (18, 5) NOT NULL,
    [AD_AMOUNT]                         NUMERIC (18, 4) NOT NULL,
    [AD_ACTIVE]                         NUMERIC (1)     NOT NULL,
    [AD_MAX_LIMIT]                      NUMERIC (18)    NOT NULL,
    [AD_DEF_ID]                         NUMERIC (18)    NULL,
    [AD_NOT_EFFECT_ON_PT]               NUMERIC (1)     CONSTRAINT [DF_T0050_AD_MASTER_AD_NOT_EFFECT_ON_PT] DEFAULT ((0)) NULL,
    [AD_NOT_EFFECT_SALARY]              NUMERIC (1)     CONSTRAINT [DF_T0050_AD_MASTER_AD_NOT_EFFECT_SALARY] DEFAULT ((0)) NULL,
    [AD_EFFECT_ON_OT]                   NUMERIC (1)     CONSTRAINT [DF_T0050_AD_MASTER_AD_EFFECT_ON_OT_CALC] DEFAULT ((0)) NULL,
    [AD_EFFECT_ON_EXTRA_DAY]            NUMERIC (1)     CONSTRAINT [DF_T0050_AD_MASTER_AD_EFFECT_ON_EXTRA_DAY] DEFAULT ((0)) NULL,
    [AD_EFFECT_ON_LATE]                 TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_AD_EFFECT_ON_LATE] DEFAULT ((0)) NULL,
    [AD_EFFECT_ON_LEAVE]                TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_AD_EFFECT_ON_LEAVE] DEFAULT ((0)) NULL,
    [AD_EFFECT_ON_BONUS]                TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_AD_EFFECT_ON_BONUS] DEFAULT ((0)) NULL,
    [AD_EFFECT_ON_GRATUITY]             TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_AD_EFFECT_ON_GRATUITY] DEFAULT ((0)) NULL,
    [AD_EFFECT_ON_SHORT_FALL]           TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_AD_EFFECT_ON_SHORT_FALL] DEFAULT ((0)) NULL,
    [AD_IT_DEF_ID]                      TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_AD_IT_DEF_ID] DEFAULT ((0)) NULL,
    [AD_RPT_DEF_ID]                     TINYINT         NULL,
    [AD_EFFECT_ON_CTC]                  NUMERIC (1)     NULL,
    [AD_EFFECT_MONTH]                   VARCHAR (100)   NULL,
    [LEAVE_TYPE]                        VARCHAR (10)    NULL,
    [AD_CAL_TYPE]                       VARCHAR (20)    NULL,
    [AD_EFFECT_FROM]                    VARCHAR (20)    NULL,
    [Effect_Net_Salary]                 NUMERIC (1)     NULL,
    [AD_EFFECT_ON_TDS]                  NUMERIC (1)     NULL,
    [AD_NOT_EFFECT_ON_LWP]              NUMERIC (1)     NULL,
    [AD_PART_OF_CTC]                    TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_AD_PART_OF_CTC] DEFAULT ((0)) NOT NULL,
    [FOR_FNF]                           TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_FOR_FNF] DEFAULT ((0)) NOT NULL,
    [NOT_EFFECT_ON_MONTHLY_CTC]         TINYINT         DEFAULT ((0)) NOT NULL,
    [Is_Yearly]                         TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_Is_Yearly] DEFAULT ((0)) NOT NULL,
    [Not_Effect_on_Basic_Calculation]   TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_Not_Effect_on_Basic_Calculation] DEFAULT ((0)) NOT NULL,
    [Attached_Mandatory]                TINYINT         DEFAULT ((0)) NULL,
    [Auto_Paid]                         TINYINT         DEFAULT ((0)) NULL,
    [Display_Balance]                   TINYINT         DEFAULT ((0)) NULL,
    [Allowance_Type]                    VARCHAR (10)    NULL,
    [Negative_Balance]                  TINYINT         DEFAULT ((0)) NULL,
    [LTA_Leave_App_Limit]               NUMERIC (18, 2) NULL,
    [No_Of_Month]                       NUMERIC (18, 1) CONSTRAINT [DF_T0050_AD_MASTER_No_Of_Month] DEFAULT ((0)) NULL,
    [Display_In_Salary]                 TINYINT         DEFAULT ((0)) NULL,
    [Add_in_sal_amt]                    TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_Add_in_sal_amt] DEFAULT ((0)) NOT NULL,
    [Is_Optional]                       TINYINT         DEFAULT ((0)) NULL,
    [AD_Code]                           VARCHAR (50)    NULL,
    [Monthly_Limit]                     INT             DEFAULT ((0)) NOT NULL,
    [DefineReimExpenseLimit]            TINYINT         DEFAULT ((0)) NOT NULL,
    [Ad_Effect_on_Nighthalt]            TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_Ad_Effect_on_Nighthalt] DEFAULT ((0)) NOT NULL,
    [Ad_Effect_on_Gatepass]             TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_Ad_Effect_on_Gatepass] DEFAULT ((0)) NOT NULL,
    [Ad_Effect_On_Esic]                 TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_Ad_Deduct_Esic] DEFAULT ((0)) NOT NULL,
    [Is_Calculated_On_Imported_Value]   TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_Is_Calculated_On Imported_Value] DEFAULT ((0)) NOT NULL,
    [Auto_Ded_TDS]                      TINYINT         DEFAULT ((0)) NOT NULL,
    [is_Rounding]                       TINYINT         NULL,
    [Reim_Guideline]                    VARCHAR (MAX)   NULL,
    [Is_Claim_Base]                     TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_Is_Claim_Base] DEFAULT ((1)) NOT NULL,
    [Not_display_auto_credit_amount_IT] TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_Not_display_auto_credit_amount_IT] DEFAULT ((0)) NOT NULL,
    [Hide_In_Reports]                   TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_Hide_In_Reports] DEFAULT ((0)) NOT NULL,
    [Gujarati_Alias]                    NVARCHAR (500)  NULL,
    [Show_In_Pay_Slip]                  TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_Show_In_Pay_Slip] DEFAULT ((0)) NOT NULL,
    [IS_Quarterly_Reim]                 TINYINT         DEFAULT ((0)) NOT NULL,
    [Prorata_On_Salary_Structure]       TINYINT         CONSTRAINT [DF_T0050_AD_MASTER_Prorata_On_Salary_Structure] DEFAULT ((0)) NOT NULL,
    [Claim_ID]                          NUMERIC (18)    DEFAULT ((0)) NOT NULL,
    [isBonusCalDays]                    INT             NULL,
    [BonusDays]                         INT             NULL,
    CONSTRAINT [PK_T0050_AD_MASTER] PRIMARY KEY CLUSTERED ([AD_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_AD_MASTER_T0010_COMPANY_MASTER] FOREIGN KEY ([CMP_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);


GO
CREATE NONCLUSTERED INDEX [T0050_AD_Master_Index]
    ON [dbo].[T0050_AD_MASTER]([CMP_ID] ASC, [AD_NAME] ASC, [AD_FLAG] ASC, [AD_DEF_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0050_AD_MASTER_10_1461580245__K1_K11_3_5_7_13_14_15_16_17_18_26_28_29_32_41_43_58]
    ON [dbo].[T0050_AD_MASTER]([AD_ID] ASC, [AD_ACTIVE] ASC)
    INCLUDE([AD_NAME], [AD_LEVEL], [AD_CALCULATE_ON], [AD_DEF_ID], [AD_NOT_EFFECT_ON_PT], [AD_NOT_EFFECT_SALARY], [AD_EFFECT_ON_OT], [AD_EFFECT_ON_EXTRA_DAY], [AD_EFFECT_ON_LATE], [AD_EFFECT_MONTH], [AD_CAL_TYPE], [AD_EFFECT_FROM], [AD_NOT_EFFECT_ON_LWP], [Auto_Paid], [Allowance_Type], [is_Rounding]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_T0050_AD_MASTER_SP_IT_TAX_PREPARATION]
    ON [dbo].[T0050_AD_MASTER]([AD_DEF_ID] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_T0050_AD_MASTER_SP_IT_TAX_PREPARATION1]
    ON [dbo].[T0050_AD_MASTER]([CMP_ID] ASC, [Is_Calculated_On_Imported_Value] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_T0050_AD_MASTER_For_P0200_Pre_Salary]
    ON [dbo].[T0050_AD_MASTER]([Claim_ID] ASC);


GO
CREATE STATISTICS [_dta_stat_1461580245_3_13_1]
    ON [dbo].[T0050_AD_MASTER]([AD_NAME], [AD_DEF_ID], [AD_ID]);


GO
CREATE STATISTICS [_dta_stat_1461580245_1_2_3_13]
    ON [dbo].[T0050_AD_MASTER]([AD_ID], [CMP_ID], [AD_NAME], [AD_DEF_ID]);


GO
CREATE STATISTICS [_dta_stat_1461580245_57_1_2]
    ON [dbo].[T0050_AD_MASTER]([Auto_Ded_TDS], [AD_ID], [CMP_ID]);

