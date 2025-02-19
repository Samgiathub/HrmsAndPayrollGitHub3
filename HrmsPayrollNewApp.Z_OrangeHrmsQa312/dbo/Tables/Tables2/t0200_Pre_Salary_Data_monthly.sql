CREATE TABLE [dbo].[t0200_Pre_Salary_Data_monthly] (
    [tran_id]               NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Type]                  NVARCHAR (50)   NULL,
    [M_Sal_Tran_ID]         NVARCHAR (50)   NULL,
    [Emp_Id]                NUMERIC (18)    NULL,
    [Cmp_ID]                NUMERIC (18)    NULL,
    [Sal_Generate_Date]     DATETIME        NULL,
    [Month_St_Date]         DATETIME        NULL,
    [Month_End_Date]        DATETIME        NULL,
    [M_OT_Hours]            NUMERIC (18, 2) NULL,
    [Areas_Amount]          NUMERIC (18, 2) NULL,
    [M_IT_Tax]              NUMERIC (18, 2) NULL,
    [Other_Dedu]            NUMERIC (18, 2) NULL,
    [M_LOAN_AMOUNT]         NUMERIC (18)    NULL,
    [M_ADV_AMOUNT]          NUMERIC (18)    NULL,
    [IS_LOAN_DEDU]          NUMERIC (18)    NULL,
    [Login_ID]              NUMERIC (18)    NULL,
    [ErrRaise]              VARCHAR (100)   NULL,
    [Is_Negetive]           VARCHAR (1)     NULL,
    [Status]                VARCHAR (10)    NULL,
    [IT_M_ED_Cess_Amount]   NUMERIC (18, 2) NULL,
    [IT_M_Surcharge_Amount] NUMERIC (18, 2) NULL,
    [Allo_On_Leave]         NUMERIC (18)    NULL,
    [W_OT_Hours]            NUMERIC (18, 2) NULL,
    [H_OT_Hours]            NUMERIC (18, 2) NULL,
    [User_Id]               NUMERIC (18)    NULL,
    [IP_Address]            VARCHAR (30)    NULL,
    [is_processed]          NUMERIC (18)    CONSTRAINT [DF__t0200_Pre__is_pr__3A242279] DEFAULT ((0)) NOT NULL,
    [Batch_id]              NVARCHAR (100)  NULL,
    [is_bond_dedu]          BIT             NULL
);


GO
CREATE CLUSTERED INDEX [_dta_index_t0200_Pre_Salary_Data_monthly_c_8_1103447105__K27_K5]
    ON [dbo].[t0200_Pre_Salary_Data_monthly]([is_processed] ASC, [Cmp_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [ix_t0200_Pre_Salary_Data_monthly_Cmp_IDSal_Generate_Date]
    ON [dbo].[t0200_Pre_Salary_Data_monthly]([Cmp_ID] ASC, [Sal_Generate_Date] ASC);


GO
CREATE STATISTICS [_dta_stat_1103447105_27_5]
    ON [dbo].[t0200_Pre_Salary_Data_monthly]([is_processed], [Cmp_ID]);

