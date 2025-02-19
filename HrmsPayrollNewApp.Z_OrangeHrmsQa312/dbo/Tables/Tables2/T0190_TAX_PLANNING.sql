CREATE TABLE [dbo].[T0190_TAX_PLANNING] (
    [Tran_ID]                 NUMERIC (18) NOT NULL,
    [Cmp_ID]                  NUMERIC (18) NOT NULL,
    [Emp_Id]                  NUMERIC (18) NOT NULL,
    [From_Date]               DATETIME     NOT NULL,
    [To_Date]                 DATETIME     NOT NULL,
    [For_Date]                DATETIME     NOT NULL,
    [Taxable_Amount]          NUMERIC (18) NOT NULL,
    [IT_Y_Amount]             NUMERIC (10) NOT NULL,
    [IT_Y_Surcharge_Amount]   NUMERIC (18) NOT NULL,
    [IT_Y_ED_Cess_Amount]     NUMERIC (18) NULL,
    [IT_Y_Final_Amount]       NUMERIC (18) NOT NULL,
    [IT_Y_Paid_Amount]        NUMERIC (18) NOT NULL,
    [Month_Remain_For_Salary] TINYINT      NOT NULL,
    [IT_M_Amount]             NUMERIC (18) NOT NULL,
    [IT_M_Surcharge_Amount]   NUMERIC (18) NOT NULL,
    [IT_M_ED_Cess_Amount]     NUMERIC (18) NOT NULL,
    [IT_M_Final_Amount]       NUMERIC (10) NOT NULL,
    [Is_Repeat]               TINYINT      NOT NULL,
    [IT_Multiple_Month]       VARCHAR (50) NOT NULL,
    [Login_ID]                NUMERIC (18) NOT NULL,
    [System_Date]             DATETIME     NOT NULL,
    [IT_Declaration_Calc_On]  VARCHAR (20) CONSTRAINT [DF_T0190_TAX_PLANNING_IT_Declaration_Calc_On] DEFAULT ('On Regular') NOT NULL,
    CONSTRAINT [PK_T0190_TAX_PLANNING] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0190_TAX_PLANNING_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0190_TAX_PLANNING_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0190_TAX_PLANNING_24_891150220__K3_K2_K6_1_4_5_7_8_9_10_11_12_13_14_15_16_17_18_19_20_21]
    ON [dbo].[T0190_TAX_PLANNING]([Emp_Id] ASC, [Cmp_ID] ASC, [For_Date] ASC)
    INCLUDE([Tran_ID], [From_Date], [To_Date], [IT_Multiple_Month], [Login_ID], [System_Date], [Month_Remain_For_Salary], [IT_M_Amount], [IT_M_Surcharge_Amount], [IT_M_ED_Cess_Amount], [IT_M_Final_Amount], [Is_Repeat], [Taxable_Amount], [IT_Y_Amount], [IT_Y_Surcharge_Amount], [IT_Y_ED_Cess_Amount], [IT_Y_Final_Amount], [IT_Y_Paid_Amount]) WITH (FILLFACTOR = 80);

