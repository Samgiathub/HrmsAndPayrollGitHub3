CREATE TABLE [dbo].[T0050_Uniform_Master_Detail] (
    [Tran_ID]                NUMERIC (18)    NOT NULL,
    [Cmp_ID]                 NUMERIC (18)    NULL,
    [Uni_ID]                 NUMERIC (18)    NULL,
    [Uni_Effective_Date]     DATETIME        NULL,
    [Uni_Rate]               NUMERIC (18, 2) NULL,
    [Uni_Deduct_Installment] NUMERIC (18)    NULL,
    [Uni_Refund_Installment] NUMERIC (18)    NULL,
    [Modify_By]              VARCHAR (100)   NULL,
    [Modify_Date]            DATETIME        NULL,
    [Ip_Address]             VARCHAR (100)   NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

