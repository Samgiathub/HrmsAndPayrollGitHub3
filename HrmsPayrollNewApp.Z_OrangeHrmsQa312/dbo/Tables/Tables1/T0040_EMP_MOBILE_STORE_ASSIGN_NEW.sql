CREATE TABLE [dbo].[T0040_EMP_MOBILE_STORE_ASSIGN_NEW] (
    [STORE_TRAN_ID]  NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]         NUMERIC (18) NOT NULL,
    [Emp_ID]         NUMERIC (18) NOT NULL,
    [Emp_Code]       VARCHAR (50) NULL,
    [Store_ID]       NUMERIC (18) NOT NULL,
    [Effective_Date] DATETIME     NOT NULL,
    [System_Date]    DATETIME     NULL,
    [Login_ID]       NUMERIC (18) NULL,
    PRIMARY KEY CLUSTERED ([STORE_TRAN_ID] ASC) WITH (FILLFACTOR = 95)
);

