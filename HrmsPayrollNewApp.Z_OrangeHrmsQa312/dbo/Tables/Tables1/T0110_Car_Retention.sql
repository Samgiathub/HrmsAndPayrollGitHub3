CREATE TABLE [dbo].[T0110_Car_Retention] (
    [Tran_ID]        NUMERIC (18)    NOT NULL,
    [Cmp_ID]         NUMERIC (18)    NULL,
    [Emp_ID]         NUMERIC (18)    NULL,
    [AD_ID]          NUMERIC (18)    NULL,
    [AD_Amount]      NUMERIC (18, 4) NULL,
    [Effective_Date] DATETIME        NULL,
    [Sys_DateTime]   DATETIME        NULL,
    [Login_ID]       VARCHAR (100)   NULL,
    [No_of_Month]    NUMERIC (18)    DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

