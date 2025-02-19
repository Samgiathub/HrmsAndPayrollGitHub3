CREATE TABLE [dbo].[T0500_OPC] (
    [Tran_ID]     NUMERIC (18)    NOT NULL,
    [Cmp_ID]      NUMERIC (18)    NULL,
    [Client_Code] VARCHAR (50)    NULL,
    [Emp_Code]    VARCHAR (50)    NULL,
    [Amount]      NUMERIC (18, 2) NULL,
    [Opc_Date]    DATETIME        NULL,
    [UserID]      NUMERIC (18)    NULL,
    [Modify_Date] DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

