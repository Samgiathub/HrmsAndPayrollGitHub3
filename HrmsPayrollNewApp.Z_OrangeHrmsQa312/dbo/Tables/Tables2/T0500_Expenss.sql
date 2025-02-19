CREATE TABLE [dbo].[T0500_Expenss] (
    [Tran_ID]         NUMERIC (18)    NOT NULL,
    [Cmp_ID]          NUMERIC (18)    NULL,
    [BM_Code]         VARCHAR (50)    NULL,
    [HR_Cost]         NUMERIC (18, 2) NULL,
    [Fixed_Cost]      NUMERIC (18, 2) NULL,
    [Non_Opt_Exp]     NUMERIC (18, 2) NULL,
    [Variable_Exp]    NUMERIC (18, 2) NULL,
    [Total_Exp]       NUMERIC (18, 2) NULL,
    [Allocation_Cost] NUMERIC (18, 2) NULL,
    [Total_Cost]      NUMERIC (18, 2) NULL,
    [UserID]          NUMERIC (18)    NULL,
    [Modify_Date]     DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

