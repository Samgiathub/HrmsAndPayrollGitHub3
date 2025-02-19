CREATE TABLE [dbo].[T0500_LPC] (
    [Tran_ID]          NUMERIC (18)    NOT NULL,
    [Cmp_ID]           NUMERIC (18)    NULL,
    [Client_Code]      VARCHAR (50)    NULL,
    [Emp_Code]         VARCHAR (50)    NULL,
    [Rate_of_Interest] NUMERIC (18, 2) NULL,
    [LPC_Month]        NUMERIC (18)    NULL,
    [LPC_Year]         NUMERIC (18)    NULL,
    [UserID]           NUMERIC (18)    NULL,
    [Modify_Date]      DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

