CREATE TABLE [dbo].[t0200_Pre_Salary_Data] (
    [Tran_id]               NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Type]                  NVARCHAR (50)   NULL,
    [M_Sal_Tran_ID]         NVARCHAR (50)   NULL,
    [Emp_Id]                NUMERIC (18)    NULL,
    [Cmp_ID]                NUMERIC (18)    NULL,
    [Sal_Generate_Date]     DATETIME        NULL,
    [Month_St_Date]         DATETIME        NULL,
    [Month_End_Date]        DATETIME        NULL,
    [Present_Days]          NUMERIC (18, 2) NULL,
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
    [User_Id]               NUMERIC (18)    NULL,
    [IP_Address]            VARCHAR (30)    NULL,
    [is_processed]          NUMERIC (18)    CONSTRAINT [DF__t0200_Pre__is_pr__1F5D7FA9] DEFAULT ((0)) NOT NULL,
    [Batch_id]              NVARCHAR (100)  NULL,
    [is_bond_dedu]          BIT             NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_t0200_Pre_Salary_Data_For_P0200_Pre_Salary1]
    ON [dbo].[t0200_Pre_Salary_Data]([is_processed] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_t0200_Pre_Salary_Data_Cmp_ID_Sal_Generate_Date]
    ON [dbo].[t0200_Pre_Salary_Data]([Cmp_ID] ASC, [Sal_Generate_Date] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_t0200_Pre_Salary_Data_Cmp_ID_is_processed_Sal_Generate_Date]
    ON [dbo].[t0200_Pre_Salary_Data]([Cmp_ID] ASC, [is_processed] ASC, [Sal_Generate_Date] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_t0200_Pre_Salary_Data_For_P0200_Pre_Salary2]
    ON [dbo].[t0200_Pre_Salary_Data]([Tran_id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_t0200_Pre_Salary_Data_For_P0200_Pre_Salary3]
    ON [dbo].[t0200_Pre_Salary_Data]([is_processed] ASC, [Batch_id] ASC);

