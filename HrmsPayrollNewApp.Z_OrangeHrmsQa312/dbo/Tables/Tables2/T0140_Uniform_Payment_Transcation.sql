CREATE TABLE [dbo].[T0140_Uniform_Payment_Transcation] (
    [Uni_Tran_ID]      NUMERIC (18)    NOT NULL,
    [Uni_Apr_Id]       NUMERIC (18)    NULL,
    [Cmp_ID]           NUMERIC (18)    NULL,
    [Uni_ID]           NUMERIC (18)    NULL,
    [Emp_ID]           NUMERIC (18)    NULL,
    [For_Date]         DATETIME        NULL,
    [Uni_Opening]      NUMERIC (18, 2) NULL,
    [Uni_Credit]       NUMERIC (18, 2) NULL,
    [Uni_Debit]        NUMERIC (18, 2) NULL,
    [Uni_Balance]      NUMERIC (18, 2) NULL,
    [Uni_Flag]         BIT             NULL,
    [Fabric_Amount]    NUMERIC (18, 2) NULL,
    [Stitching_Amount] NUMERIC (18, 2) NULL,
    PRIMARY KEY CLUSTERED ([Uni_Tran_ID] ASC)
);

