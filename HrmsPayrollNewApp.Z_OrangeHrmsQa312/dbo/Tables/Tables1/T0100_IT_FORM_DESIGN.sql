CREATE TABLE [dbo].[T0100_IT_FORM_DESIGN] (
    [Tran_ID]                     NUMERIC (18)    NOT NULL,
    [Cmp_ID]                      NUMERIC (18)    NOT NULL,
    [Format_Name]                 VARCHAR (20)    NOT NULL,
    [Row_ID]                      INT             NOT NULL,
    [Field_Name]                  VARCHAR (100)   NOT NULL,
    [AD_ID]                       NUMERIC (18)    NULL,
    [Rimb_ID]                     NUMERIC (18)    NULL,
    [Default_Def_Id]              INT             NOT NULL,
    [Is_Total]                    TINYINT         NOT NULL,
    [From_Row_ID]                 INT             NOT NULL,
    [To_Row_ID]                   INT             NOT NULL,
    [Multiple_Row_ID]             VARCHAR (200)   NOT NULL,
    [Is_Exempted]                 TINYINT         NOT NULL,
    [Max_Limit]                   NUMERIC (18)    NOT NULL,
    [Max_Limit_Compare_Row_ID]    INT             NOT NULL,
    [Max_Limit_Compare_Type]      TINYINT         NULL,
    [Is_Proof_Req]                TINYINT         NOT NULL,
    [Login_ID]                    NUMERIC (18)    NULL,
    [System_Date]                 DATETIME        NOT NULL,
    [IT_ID]                       NUMERIC (18)    NULL,
    [Field_Type]                  TINYINT         CONSTRAINT [DF_T0100_IT_FORM_DESIGN_Is_Final_Taxable_Amt] DEFAULT ((0)) NULL,
    [Is_Show]                     TINYINT         CONSTRAINT [DF_T0100_IT_FORM_DESIGN_Is_Show] DEFAULT ((1)) NULL,
    [Col_No]                      TINYINT         CONSTRAINT [DF_T0100_IT_FORM_DESIGN_Col_No] DEFAULT ((0)) NULL,
    [Form_ID]                     NUMERIC (18)    NULL,
    [Concate_Space]               TINYINT         CONSTRAINT [DF_T0100_IT_FORM_DESIGN_Concate_Space] DEFAULT ((0)) NULL,
    [Is_Salary_Comp]              TINYINT         CONSTRAINT [DF_T0100_IT_FORM_DESIGN_Is_Salary_Comp] DEFAULT ((0)) NULL,
    [Exem_Againt_Row_ID]          INT             CONSTRAINT [DF_T0100_IT_FORM_DESIGN_Exem_Againt_Row_ID] DEFAULT ((0)) NULL,
    [Financial_Year]              VARCHAR (10)    NULL,
    [For_Date]                    DATETIME        NULL,
    [Show_In_SalarySlip]          BIT             CONSTRAINT [DF_T0100_IT_FORM_DESIGN_Show_In_SalarySlip] DEFAULT ((0)) NOT NULL,
    [Display_Name_For_Salaryslip] VARCHAR (250)   NULL,
    [Column_24Q]                  NUMERIC (18)    CONSTRAINT [DF_T0100_IT_FORM_DESIGN_Column_24Q] DEFAULT ((0)) NOT NULL,
    [Net_Income_Range]            NUMERIC (18, 2) CONSTRAINT [DF_T0100_IT_FORM_DESIGN_Net_income_Range] DEFAULT ((0)) NOT NULL,
    [Field_Value]                 NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [TotalFormula]                VARCHAR (500)   NULL,
    [TotalFormula_Actual]         VARCHAR (500)   NULL,
    [Field_Value2]                NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0100_IT_FORM_DESIGN] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_IT_FORM_DESIGN_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_IT_FORM_DESIGN_T0040_FORM_MASTER] FOREIGN KEY ([Form_ID]) REFERENCES [dbo].[T0040_FORM_MASTER] ([Form_ID]),
    CONSTRAINT [FK_T0100_IT_FORM_DESIGN_T0050_AD_MASTER] FOREIGN KEY ([AD_ID]) REFERENCES [dbo].[T0050_AD_MASTER] ([AD_ID]),
    CONSTRAINT [FK_T0100_IT_FORM_DESIGN_T0070_IT_MASTER] FOREIGN KEY ([IT_ID]) REFERENCES [dbo].[T0070_IT_MASTER] ([IT_ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_T0100_IT_FORM_DESIGN]
    ON [dbo].[T0100_IT_FORM_DESIGN]([Tran_ID] ASC, [Default_Def_Id] ASC, [Row_ID] ASC, [AD_ID] ASC, [Cmp_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0100_IT_FORM_DESIGN_12_1352391887__K2_K8_K1_3_4_5_6_7_9_10_11_12_13_14_15_16_17_20_21_22_23_25_26_27_30_31]
    ON [dbo].[T0100_IT_FORM_DESIGN]([Cmp_ID] ASC, [Default_Def_Id] ASC, [Tran_ID] ASC)
    INCLUDE([Format_Name], [Row_ID], [Field_Name], [AD_ID], [Rimb_ID], [Is_Total], [From_Row_ID], [To_Row_ID], [Multiple_Row_ID], [Is_Exempted], [Max_Limit], [Max_Limit_Compare_Row_ID], [Max_Limit_Compare_Type], [Is_Proof_Req], [IT_ID], [Field_Type], [Is_Show], [Col_No], [Concate_Space], [Is_Salary_Comp], [Exem_Againt_Row_ID], [Show_In_SalarySlip], [Display_Name_For_Salaryslip]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_T0100_IT_FORM_DESIGN_SP_IT_TAX_PREPARATION1]
    ON [dbo].[T0100_IT_FORM_DESIGN]([Cmp_ID] ASC)
    INCLUDE([Financial_Year]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_T0100_IT_FORM_DESIGN_SP_IT_TAX_PREPARATION2]
    ON [dbo].[T0100_IT_FORM_DESIGN]([Cmp_ID] ASC, [Row_ID] ASC, [Default_Def_Id] ASC)
    INCLUDE([Format_Name], [Field_Name], [AD_ID], [Rimb_ID], [Is_Total], [From_Row_ID], [To_Row_ID], [Multiple_Row_ID], [Is_Exempted], [Max_Limit], [Max_Limit_Compare_Row_ID], [Max_Limit_Compare_Type], [Is_Proof_Req], [IT_ID], [Field_Type], [Is_Show], [Col_No], [Concate_Space], [Is_Salary_Comp], [Exem_Againt_Row_ID], [Financial_Year], [Show_In_SalarySlip], [Display_Name_For_Salaryslip], [Column_24Q]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_T0100_IT_FORM_DESIGN_SP_IT_TAX_PREPARATION3]
    ON [dbo].[T0100_IT_FORM_DESIGN]([Financial_Year] ASC, [Row_ID] ASC)
    INCLUDE([Cmp_ID], [Format_Name], [Field_Name], [AD_ID], [Rimb_ID], [Default_Def_Id], [Is_Total], [From_Row_ID], [To_Row_ID], [Multiple_Row_ID], [Is_Exempted], [Max_Limit], [Max_Limit_Compare_Row_ID], [Max_Limit_Compare_Type], [Is_Proof_Req], [Login_ID], [System_Date], [IT_ID], [Field_Type], [Is_Show], [Col_No], [Form_ID], [Concate_Space], [Is_Salary_Comp], [Exem_Againt_Row_ID], [For_Date], [Show_In_SalarySlip], [Display_Name_For_Salaryslip], [Column_24Q], [Net_Income_Range], [Field_Value], [TotalFormula], [TotalFormula_Actual]) WITH (FILLFACTOR = 90);


GO
CREATE STATISTICS [_dta_stat_1352391887_1_2_8]
    ON [dbo].[T0100_IT_FORM_DESIGN]([Tran_ID], [Cmp_ID], [Default_Def_Id]);

